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
        
        return cluster.count >= 2 && zoom >= 7
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
    
    lazy var filter = ARUserFilter()
    lazy var makeRadarChat = ARMakeRadarChat.loadFromNib(filter: filter, mapViewModel: viewModel)
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
                iconGenerator = GMUDefaultClusterIconGenerator.init(buckets: [2,4,6,8,10,15,20,25,30,35,40,45,50,80,100], backgroundImages: [image,image,image,image,image,image,image,image,image,image,image,image,image,image,image])
            } else {
                iconGenerator = GMUDefaultClusterIconGenerator()
            }
            
            let algoritm = GMUGridBasedClusterAlgorithm()
            let render = ARClusterRenderer.init(mapView: mapView, clusterIconGenerator: iconGenerator)
            render.delegate = self
            clusterManager = GMUClusterManager.init(map: mapView, algorithm: algoritm, renderer: render)
            clusterManager.cluster()
            clusterManager.setDelegate(self, mapDelegate: self)
        }
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateUI()
    }
    
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            mapView.animate(toLocation: location.coordinate)
            mapView.animate(toZoom: 15)
            locManager.stopUpdatingLocation()
        }
    }
    
    @IBAction func didClickChatButton(_ sender: UIButton) {
        makeRadarChat.show()
        makeRadarChat.didCloseSadarChat = {[weak self] filter in
            self?.filter = filter
            self?.updateUI()
        }
    }
    
    func updateUI() {
        distanceSlider.selectedDistance = CGFloat(filter.distance)
    }
    
    func listeners() {
        distanceSlider.didEndSlide = { [weak self] value in
            guard let weakSelf = self else {return}
            weakSelf.filter.distance = Int(value)
            weakSelf.viewModel.getUsers(by: weakSelf.filter, completion: {[weak self] (users) in
                //
                self?.markerArray.removeAll()
                self?.closteringMarkerArray.removeAll()
                self?.clusterManager.clearItems()
                //
                var mixedUser = users
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
    }
    
    //    func listeners() {
    //        distanceSlider.didEndSlide = { [weak self] value in
    //            guard let weakSelf = self else {return}
    //            weakSelf.filter.distance = Int(value)
    //            weakSelf.viewModel.getUsers(by: weakSelf.filter, completion: {[weak self] (users) in
    //                var mixedUser = users
    //                if !(self?.markerArray.contains(where: { (marker) -> Bool in
    //                    if let userData = marker.userData as? [String:Any], let savedID = userData["userID"] as? String, let currentUserID = ARUser.currentUser?.id {
    //                        return savedID == currentUserID
    //                    }
    //                    return false
    //                }))! {
    //                    mixedUser.append(ARUser.currentUser!)
    //                }
    ////                self?.drawClosteringUsers(users: mixedUser)
    //
    //                self?.drawUsers(users: mixedUser)
    //            })
    //        }
    //    }
    
    func drawUsers(users:[ARUser]) {
        for user in users {
            let marker = GMSMarker()
            markerArray.append(marker)
            marker.userData = ["userID":user.id];
            //            marker.icon = UIImage.init(named: "femaleAvatar")
            marker.icon = ARMarker.loadFromNib(with: user).toImage()
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
            let image = ARMarker.loadFromNib(with: user).toImage() ?? UIImage(named: "femaleAvatar") ?? UIImage()
            let item = POIItem.init(position: CLLocationCoordinate2D(latitude: user.coordinate?.lat ?? 0,
                                                                     longitude: user.coordinate?.lng ?? 0)
                , name: user.id ?? "", image: image)
            
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
        print(cluster)
        
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
    
    func renderer(_ renderer: GMUClusterRenderer, markerFor object: Any) -> GMSMarker? {
        if let item = object as? POIItem {
            let marker = GMSMarker.init(position: item.position)
            marker.icon = item.image
            print("marker \(item.name)")
            
            return marker
        }
        let cluster = GMSMarker.init()
        cluster.icon = UIImage.init(named: "closter") ?? UIImage()
        return cluster
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
