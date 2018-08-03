//
//  MapVC.swift
//  Arounds
//
//  Created by Samvel Pahlevanyan on 5/16/18.
//  Copyright © 2018 Samvel Pahlevanyan. All rights reserved.
//

import CoreLocation
import GoogleMaps
import UIKit

class ARClusterRenderer: GMUDefaultClusterRenderer {
    
    override func shouldRender(as cluster: GMUCluster, atZoom zoom: Float) -> Bool {
        
        return cluster.count >= 2 && zoom >= 2
    }
    
}

class MapVC: UIViewController,CLLocationManagerDelegate {
    
    @IBOutlet weak var distanceSlider: ARDistanceSlider!
    @IBOutlet weak var radarChatButton: ARGradientedButton!
    @IBOutlet weak var mapView: GMSMapView!
    
    var closteringMarkerArray = [POIItem]()
    var markerArray = [GMSMarker]()
    var viewModel = MapViewModel()
    var locManager: CLLocationManager!
    var mapStyle: GMSMapStyle!
    var clusterManager: GMUClusterManager!
    
    let isClostering: Bool = true
    let isCustom: Bool = true
    var lastCoordinate:CLLocationCoordinate2D?
    lazy var filter = ARUserFilter()
    lazy var mapFilter = ARUserFilter()

    lazy var makeRadarChat = ARMakeRadarChat.loadFromNib(filter: filter)
    lazy var clusteredUser = ARClusteredUsers.loadFromNib()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //        mapView?.isMyLocationEnabled = true
        locManager = CLLocationManager()
        locManager.delegate = self
        locManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locManager.startUpdatingLocation()
        mapView.delegate = self
        self.navigationController?.isNavigationBarHidden = true
        listeners()
        mapStyle = try? GMSMapStyle.init(contentsOfFileURL: Bundle.main.url(forResource: "map_style", withExtension: "json")!)
        mapView.mapStyle = mapStyle
        
        if isClostering {
            var iconGenerator : GMUDefaultClusterIconGenerator!
            if isCustom {
                let image = UIImage.init(named: "closter") ?? UIImage()
                iconGenerator = GMUDefaultClusterIconGenerator.init(buckets: [1000000], backgroundImages: [image])
            } else {
                iconGenerator = GMUDefaultClusterIconGenerator()
            }
            
            let algoritm = GMUNonHierarchicalDistanceBasedAlgorithm()
            let render = ARClusterRenderer.init(mapView: mapView, clusterIconGenerator: iconGenerator)
            render.delegate = self
            clusterManager = GMUClusterManager.init(map: mapView, algorithm: algoritm, renderer: render)
            clusterManager.cluster()
            clusterManager.setDelegate(self, mapDelegate: self)
        }
        mapView.settings.allowScrollGesturesDuringRotateOrZoom = false
        
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateUI()
        locManager.startUpdatingLocation()
    }
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
    
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            //            mapView.animate(toZoom: 15)
            MapUtil.setRadius(radius: Double(self.mapFilter.distance), withCity: location.coordinate, InMapView: mapView)
            mapView.animate(toLocation: location.coordinate)
            lastCoordinate = location.coordinate
            locManager.stopUpdatingLocation()
            getUsers()

        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .denied {
            
        }
    }

    @IBAction func didClickChatButton(_ sender: UIButton) {
        
        if UserDefaults.standard.bool(forKey: "kAgreeTermsOfUse") != true {
            let spamView = NonSpamView.loadFromNib()
            spamView.didCloseSpamView = {
                self.openRadarChat()
            }
            spamView.show()
            return
        }
        self.openRadarChat()
    }
    
    func openRadarChat() {
        makeRadarChat.show()
//        makeRadarChat.didCloseSadarChat = {[weak self] filter in
//            self?.filter = filter
//            self?.updateUI()
//        }
    }
    
    func updateUI() {
        distanceSlider.selectedDistance = CGFloat(mapFilter.distance)
        distanceSlider.didEndSlide?(distanceSlider.selectedDistance)
    }
    
    func listeners() {
        distanceSlider.didEndSlide = { [weak self] value in
            guard let weakSelf = self else {return}
            
            weakSelf.locManager.startUpdatingLocation()
            weakSelf.mapFilter.distance = Int(value)
            weakSelf.getUsers()
        }
    }
    
    func getUsers() {
        let filter = ARUserFilter()
        filter.distance = Int(distanceSlider.selectedDistance)
        viewModel.getUsers(by: filter, completion: {[weak self] (users) in
            //
            let rangeDate = Calendar.current.date(byAdding: .minute, value: -5, to: Date()) ?? Date()
            let onlineUsers = users.filter({ (obj) -> Bool in
                return obj.lastOnlone ?? Date() > rangeDate
            })
            //
            self?.markerArray.removeAll()
            self?.closteringMarkerArray.removeAll()
            self?.clusterManager.clearItems()
            //
            var mixedUser = onlineUsers
            if !(self?.closteringMarkerArray.contains(where: { (marker) -> Bool in
                if  let currentUserID = ARUser.currentUser?.id {
                    return marker.name == currentUserID
                }
                return false
            }))! {
                mixedUser.append(ARUser.currentUser!)
            }
            self?.drawClosteringUsers(users: mixedUser)
            
        })
    }
    
    func drawUsers(users:[ARUser]) {
        for user in users {
            let marker = GMSMarker()
            markerArray.append(marker)
            marker.userData = ["userID":user.id];
            //            marker.icon = UIImage.init(named: "femaleAvatar")
            let asMarker = ARMarker.loadFromNib(with: user)
            marker.iconView?.frame.size = asMarker.frame.size
            marker.groundAnchor = CGPoint.init(x: 0.5, y: 1.0)
            marker.iconView?.addSubview(asMarker)
            marker.position = CLLocationCoordinate2D(latitude: user.coordinate?.lat ?? 0, longitude: user.coordinate?.lng ?? 0)
            marker.map = mapView
        }
    }
    
    func drawClosteringUsers(users:[ARUser]) {
        for user in users {
            //
            //            let marker = GMSMarker()
            //            markerArray.append(marker)
            //            marker.userData = ["userID":user.id];
            //            marker.icon = UIImage.init(named: "femaleAvatar")
            //            marker.icon = ARMarker.loadFromNib(with: user).toImage()
            //            marker.position = CLLocationCoordinate2D(latitude: user.coordinate?.lat ?? 0, longitude: user.coordinate?.lng ?? 0)
            //                        marker.map = mapView
            //
            let image = ARMarker.loadFromNib(with: user).toImage()
            let item = POIItem.init(position: CLLocationCoordinate2D(latitude: user.coordinate?.lat ?? 0,
                                                                     longitude: user.coordinate?.lng ?? 0)
                , name: user.id ?? "", image: image!)
            
            closteringMarkerArray.append(item)
            clusterManager.add(item)
            clusterManager.cluster()
        }
    }
    
    func user(by item: POIItem) -> ARUser? {
        return viewModel.nearestUser.filter { (user) -> Bool in
            return user.id == item.name
            }.first
    }
    
}

extension MapVC: GMSMapViewDelegate, GMUClusterManagerDelegate, GMUClusterRendererDelegate {
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        if let userData = marker.userData as? [String:Any], let savedID = userData["userID"] as? String {
            if let currentUserID = ARUser.currentUser?.id, savedID != currentUserID {
                print(viewModel.nearestUser.filter({$0.id == savedID}).first?.fullName ?? "")
            }
        }
        return true
    }
    
    func clusterManager(_ clusterManager: GMUClusterManager, didTap cluster: GMUCluster) -> Bool {
        
        let users = cluster.items.map { (item) -> ARUser? in
            if let item = item as? POIItem, let user = viewModel.nearestUser.filter({$0.id == item.name}).first {
                return user
            }
            return nil
            }.filter({$0 != nil})
        
        clusteredUser.show(with: users as! [ARUser], onVC: self)
        return true
    }
    
    func clusterManager(_ clusterManager: GMUClusterManager, didTap clusterItem: GMUClusterItem) -> Bool {
        if let item = clusterItem as? POIItem, let user = user(by: item) {
            let vc = ProfileVC.instantiate(from: .Profile)
            vc.viewModel = OtherProfileViewModel.init(with: user)
            self.navigationController?.pushViewController(vc, animated: true)
        }
        return true
    }
    
    func shouldRender(as cluster: GMUCluster, atZoom zoom: Float) -> Bool {
        return true
    }

    func renderer(_ renderer: GMUClusterRenderer, markerFor object: Any) -> GMSMarker? {
        if let item = object as? POIItem {
            let marker = GMSMarker.init(position: item.position)
            marker.icon = item.image
            marker.groundAnchor = CGPoint.init(x: 0.5, y: 0.5)
            return marker
        }
        //        let cluster = GMSMarker.init()
        //        cluster.icon = UIImage.init(named: "closter") ?? UIImage()
        return nil
    }
    
}

class POIItem:NSObject, GMUClusterItem {
    var position: CLLocationCoordinate2D
    var name: String!
    var image: UIImage!
    
    init(position: CLLocationCoordinate2D, name: String, image: UIImage) {
        self.position = position
        self.name = name
        self.image = image
    }
}

extension GMSCameraUpdate {
    
    static func fit(coordinate: CLLocationCoordinate2D, radius: Double) -> GMSCameraUpdate {
        var leftCoordinate = coordinate
        var rigthCoordinate = coordinate
        
        let region = MKCoordinateRegionMakeWithDistance(coordinate, radius, radius)
        let span = region.span
        
        leftCoordinate.latitude = coordinate.latitude - span.latitudeDelta
        leftCoordinate.longitude = coordinate.longitude - span.longitudeDelta
        rigthCoordinate.latitude = coordinate.latitude + span.latitudeDelta
        rigthCoordinate.longitude = coordinate.longitude + span.longitudeDelta
        
        let bounds = GMSCoordinateBounds(coordinate: leftCoordinate, coordinate: rigthCoordinate)
        let update = GMSCameraUpdate.fit(bounds, withPadding: -15.0)
        
        return update
    }
    
}


class MapUtil {
    
    class func translateCoordinate(coordinate: CLLocationCoordinate2D, metersLat: Double,metersLong: Double) -> (CLLocationCoordinate2D) {
        var tempCoord = coordinate
        
        let tempRegion = MKCoordinateRegionMakeWithDistance(coordinate, metersLat, metersLong)
        let tempSpan = tempRegion.span
        
        tempCoord.latitude = coordinate.latitude + tempSpan.latitudeDelta
        tempCoord.longitude = coordinate.longitude + tempSpan.longitudeDelta
        
        return tempCoord
    }
    
    class func setRadius(radius: Double,withCity city: CLLocationCoordinate2D,InMapView mapView: GMSMapView) {
        
        let update = GMSCameraUpdate.fit(coordinate: city, radius: radius)    // padding set to 5.0
        mapView.moveCamera(update)
    }
    
}
