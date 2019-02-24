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
import SVProgressHUD

class ARClusterRenderer: GMUDefaultClusterRenderer {
    
    override func shouldRender(as cluster: GMUCluster, atZoom zoom: Float) -> Bool {
        
        return cluster.count >= 2 && zoom >= 2
    }
    
}

class MapVC: UIViewController,CLLocationManagerDelegate {
    
    @IBOutlet weak var chatRadarButtonOfflineImage: UIImageView!
    @IBOutlet weak var distanceSlider: ARDistanceSlider!
    @IBOutlet weak var radarChatButton: ARGradientedButton!
    @IBOutlet weak var mapView: GMSMapView!
    
    var closteringMarkerArray = [POIItem]()
    var markerArray = [GMSMarker]()
    var viewModel = MapViewModel()
    var locManager: CLLocationManager!
    var mapStyle: GMSMapStyle!
    var clusterManager: GMUClusterManager!
    var onlineOffline: OnlineOffline!
    
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
                iconGenerator = GMUDefaultClusterIconGenerator(buckets: [1000000], backgroundImages: [image])
            } else {
                iconGenerator = GMUDefaultClusterIconGenerator()
            }
            
            let algoritm = GMUNonHierarchicalDistanceBasedAlgorithm()
            let render = ARClusterRenderer(mapView: mapView, clusterIconGenerator: iconGenerator)
            render.delegate = self
            clusterManager = GMUClusterManager(map: mapView, algorithm: algoritm, renderer: render)
            clusterManager.cluster()
            clusterManager.setDelegate(self, mapDelegate: self)
        }
        mapView.settings.allowScrollGesturesDuringRotateOrZoom = false
        setupOnlineOffline()
        updateUI()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        locManager.startUpdatingLocation()
        
        self.chatRadarButtonOfflineImage.isHidden = self.onlineOffline?.isOnline == false
        self.radarChatButton.startColor = UIColor.withHex(self.onlineOffline?.isOnline == true ? "FF3FB4" : "88889C" )
        self.radarChatButton.endColor = UIColor.withHex(self.onlineOffline?.isOnline == true ? "F35119" : "88889C" )
        
    }
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
    
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            //            mapView.animate(toZoom: 15)
            MapUtil.setRadius(radius: Double(distanceSlider.selectedDistance), withCity: location.coordinate, InMapView: mapView)
            mapView.animate(toLocation: location.coordinate)
            ARUser.currentUser?.coordinate = ARCoordinate(lat: location.coordinate.latitude, lng : location.coordinate.longitude)
            if lastCoordinate == nil {
                getUsers(distance: 1700000)
            }
            lastCoordinate = location.coordinate
            locManager.stopUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .denied {
        }
        if status == .authorizedAlways || status == .authorizedWhenInUse {
            LocationManager.shared.allowRequest()
        }
        
    }
    
    @IBAction func didClickChatButton(_ sender: UIButton) {
        
        if CLLocationManager.authorizationStatus() == .denied  {
            LocationRequired.shared.show()
        }
        
        if onlineOffline.isOnline == false || ARUser.currentUser?.coordinate == nil {
            return
        }
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
    }
    
    func updateUI() {
        distanceSlider.selectedDistance = CGFloat(mapFilter.distance)
        fetch(value: distanceSlider.selectedDistance)
        getUsers(distance: 1700000)
        //        distanceSlider.didEndSlide?(distanceSlider.selectedDistance)
    }
    
    func listeners() {
        distanceSlider.didEndSlide = { [weak self] value in
            guard let wSelf = self else {return}
            wSelf.distanceSlider.selectedDistance = value
            wSelf.locManager.startUpdatingLocation()
            // wSelf.fetch(value: value)
        }
    }
    
    func fetch(value:CGFloat) {
        mapFilter.distance = value
        getUsers(distance: value)
    }
    
    func setupOnlineOffline() {
        onlineOffline = OnlineOffline.loadFromNib()
        view.addSubview(onlineOffline)
        onlineOffline.isOnline = UserDefaults.standard.bool(forKey: "isOnline")
        onlineOffline.didSwitchOnline = {[weak self] isOnline in
            UserDefaults.standard.set(isOnline, forKey: "isOnline")
            UserDefaults.standard.synchronize()
            
            self?.closteringMarkerArray.removeAll()
            self?.markerArray.removeAll()
            self?.viewModel.nearestUser.removeAll()
            self?.clusterManager.cluster()
            self?.getUsers(distance: 1700000)
            if isOnline == true && CLLocationManager.authorizationStatus() == .denied  {
                LocationRequired.shared.show()
            }
            
            self?.chatRadarButtonOfflineImage.isHidden = self?.onlineOffline?.isOnline == false
            self?.radarChatButton.startColor = UIColor.withHex(self?.onlineOffline?.isOnline == true ? "FF3FB4" : "88889C" )
            self?.radarChatButton.endColor = UIColor.withHex(self?.onlineOffline?.isOnline == true ? "F35119" : "88889C" )
            
        }
    }
    
    func getUsers(distance: CGFloat) {
        let filter = ARUserFilter()
        filter.distance = distance
        viewModel.getUsers(by: filter, completion: {[weak self] (users) in
            //
            let rangeDate = Calendar.current.date(byAdding: .minute, value: -5, to: Date()) ?? Date()
             let onlineUsers = users.filter({ (obj) -> Bool in
                return obj.lastOnlone ?? Date() > rangeDate
            })
            
            var mixedUser = onlineUsers
            if !(self?.closteringMarkerArray.contains(where: { (marker) -> Bool in
                if  let currentUserID = ARUser.currentUser?.id {
                    return marker.name == currentUserID
                }
                return false
            }))! {
                if self?.onlineOffline.isOnline ?? false == false {mixedUser.removeAll()}
                if !mixedUser.contains(ARUser.currentUser!) {
                   mixedUser.append(ARUser.currentUser!)
                }
                print(mixedUser.count)
            }
            self?.drawClosteringUsers(users: mixedUser)
            
        })
    }
    
    //    func drawUsers(users:[ARUser]) {
    //
    //        for user in users {
    //            let marker = GMSMarker()
    //            markerArray.append(marker)
    //            marker.userData = ["userID":user.id];
    //            //            marker.icon = UIImage.init(named: "femaleAvatar")
    //            let asMarker = ARMarker.loadFromNib(with: user, complition: <#(() -> Void)#>)
    //            asMarker.borderImageView.isHighlighted = self.onlineOffline.isOnline == false
    //            marker.iconView?.frame.size = asMarker.frame.size
    //            marker.groundAnchor = CGPoint.init(x: 0.5, y: 1.0)
    //            marker.iconView?.addSubview(asMarker)
    //
    //            marker.position = CLLocationCoordinate2D(latitude: user.coordinate?.lat ?? 0, longitude: user.coordinate?.lng ?? 0)
    //            marker.map = mapView
    //        }
    //    }
    
    func drawClosteringUsers(users:[ARUser]) {
//            SVProgressHUD.show()
        //
        markerArray.removeAll()
        closteringMarkerArray.removeAll()
        clusterManager.clearItems()
        //

        var array = [ARMarker]()
        for user in users {
            var image:ARMarker!
            image = ARMarker.loadFromNib(with: user) {[weak self] in
                guard let `self` = self else {return}
                image.borderImageView.isHighlighted = self.onlineOffline.isOnline == false
                self.chatRadarButtonOfflineImage.isHidden = self.onlineOffline.isOnline == false
                self.radarChatButton.startColor = UIColor.withHex(self.onlineOffline.isOnline == true ? "FF3FB4" : "88889C" )
                self.radarChatButton.endColor = UIColor.withHex(self.onlineOffline.isOnline == true ? "F35119" : "88889C" )
                array.append(image)
                if array.count == users.count {
                    
                    self.closteringMarkerArray = array.map({self.getPOIItem(by: $0)})
                    self.clusterManager.add(self.closteringMarkerArray)
                    self.clusterManager.cluster()
//                    SVProgressHUD.dismiss()
                }
            }
        }
        
    }
    
    func getPOIItem(by marker:ARMarker) -> POIItem {
        let location = CLLocationCoordinate2D(latitude: marker.user.coordinate?.lat ?? 0,
                                              longitude: marker.user.coordinate?.lng ?? 0)
        
        return POIItem(position: location , name: marker.user.id ?? "", image: marker.toImage()!)
    }
    
    func user(by item: POIItem) -> ARUser? {
        return viewModel.nearestUser.filter { (user) -> Bool in
            return user.id == item.name
            }.first
    }
    
}
var lastRadius:CGFloat = 0

extension MapVC: GMSMapViewDelegate, GMUClusterManagerDelegate, GMUClusterRendererDelegate {
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
//        if let userData = marker.userData as? [String:Any], let savedID = userData["userID"] as? String {
//            if let currentUserID = ARUser.currentUser?.id, savedID != currentUserID {
//                print(viewModel.nearestUser.filter({$0.id == savedID}).first?.fullName ?? "")
//            }
//        }
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
            let marker = GMSMarker(position: item.position)
            marker.icon = item.image
            marker.groundAnchor = CGPoint(x: 0.5, y: 0.5)
            return marker
        }
        return nil
    }
    
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        let radius = CGFloat(position.getRadius(mapView: mapView)/1.338)
        let a = (radius*1.0059572138)-radius
        if lastRadius == 0 ||
            ((lastRadius > (radius - a)) && (lastRadius < radius + a)) {
            lastRadius = radius
            return
        }
        print(radius)
        var number = 1
        if radius < lastRadius {
            if radius > 6000 {
                number = 5
            }else if (4800...5999).contains(radius) {
                number = 4
            } else if (1990...4779).contains(radius) {
                number = 3
            } else if (990...1989).contains(radius) {
                number = 2
            } else if 950 > radius {
                number = 1
            }
        } else {
            if radius > 4000 {
                number = 5
            } else if (1800...3999).contains(radius) {
                number = 4
            } else if (1001...1799).contains(radius) {
                number = 3
            } else if (500...1000).contains(radius) {
                number = 2
            }
        }
        distanceSlider.slide(as: number, notify: false)
        filter.distance = distanceSlider.indexToRadius(index: number)
        //        fetch(value: distanceSlider.indexToRadius(index: number))
        
        lastRadius = radius
        
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
extension GMSCameraPosition {
    func getCenterCoordinate(mapView: GMSMapView) -> CLLocationCoordinate2D {
        let centerPoint = mapView.center
        let centerCoordinate = mapView.projection.coordinate(for: centerPoint)
        return centerCoordinate
    }
    
    func getTopCenterCoordinate(mapView: GMSMapView) -> CLLocationCoordinate2D {
        // to get coordinate from CGPoint of your map
        
        let topCenterCoor = mapView.convert(CGPoint(x: mapView.frame.size.width / 2.0, y: 0), to: mapView)
        let point = mapView.projection.coordinate(for: topCenterCoor)
        return point
    }
    
    func getRadius(mapView: GMSMapView) -> CLLocationDistance {
        
        let centerCoordinate = getCenterCoordinate(mapView: mapView)
        // init center location from center coordinate
        let centerLocation = CLLocation(latitude: centerCoordinate.latitude, longitude: centerCoordinate.longitude)
        let topCenterCoordinate = self.getTopCenterCoordinate(mapView: mapView)
        let topCenterLocation = CLLocation(latitude: topCenterCoordinate.latitude, longitude: topCenterCoordinate.longitude)
        
        let radius = CLLocationDistance(centerLocation.distance(from: topCenterLocation))
        
        return round(radius)
    }
}

extension GMSCoordinateBounds {
    
    static func createBounds(coordinate: CLLocationCoordinate2D, radius: Double) -> GMSCoordinateBounds {
        var leftCoordinate = coordinate
        var rigthCoordinate = coordinate
        
        let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: radius, longitudinalMeters: radius)
        let span = region.span
        
        leftCoordinate.latitude = coordinate.latitude - span.latitudeDelta
        leftCoordinate.longitude = coordinate.longitude - span.longitudeDelta
        rigthCoordinate.latitude = coordinate.latitude + span.latitudeDelta
        rigthCoordinate.longitude = coordinate.longitude + span.longitudeDelta
        
        return GMSCoordinateBounds(coordinate: leftCoordinate, coordinate: rigthCoordinate)
    }
}


extension GMSCameraUpdate {
    
    static func fit(coordinate: CLLocationCoordinate2D, radius: Double) -> GMSCameraUpdate {
        let bounds = GMSCoordinateBounds.createBounds(coordinate: coordinate, radius: radius)
        let update = GMSCameraUpdate.fit(bounds, withPadding: -50)
        return update
    }
    
}


class MapUtil {
    
    class func translateCoordinate(coordinate: CLLocationCoordinate2D, metersLat: Double, metersLong: Double) -> (CLLocationCoordinate2D) {
        var tempCoord = coordinate
        
        let tempRegion = MKCoordinateRegion(center: coordinate, latitudinalMeters: metersLat, longitudinalMeters: metersLong)
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
