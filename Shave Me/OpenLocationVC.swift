//
//  OpenLocationVC.swift
//  Shave Me
//
//  Created by NoorAli on 2/27/17.
//  Copyright © 2017 NoorAli. All rights reserved.
//

import UIKit
import GoogleMaps
import MapKit

class OpenLocationVC: BaseSideMenuViewController {
    
    @IBOutlet weak var mapView: GMSMapView!
    
    var currentLocationMarker: GMSMarker = GMSMarker()
    
    var coordinates: CLLocationCoordinate2D!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Create a GMSCameraPosition that tells the map to display the
        let camera = GMSCameraPosition.camera(withTarget: coordinates, zoom: 13.0)
        mapView.camera = camera
        
        // Creates a marker in the center of the map.
        currentLocationMarker.map = mapView
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onClickOpenInMaps(_ sender: UIButton) {
        guard let url = URL(string:"comgooglemaps://"), UIApplication.shared.canOpenURL(url) else {
            self.openInMaps()
            return
        }
        
        let alert = UIAlertController(title: "choose_application".localized(), message: "", preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: "open_in_maps".localized(), style: .default, handler: {(action) in
            self.openInMaps()
        }))
        alert.addAction(UIAlertAction(title: "open_in_google_maps".localized(), style: .default, handler:  {(action) in
            self.openInGoogleMaps()
        }))
        alert.addAction(UIAlertAction(title: "cancel".localized(), style: .cancel, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
        
        
    }
    
    func openInMaps() {
        let regionDistance:CLLocationDistance = 10000
        
        let regionSpan = MKCoordinateRegionMakeWithDistance(coordinates, regionDistance, regionDistance)
        let options = [
            MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center),
            MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span)
        ]
        let placemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = self.title ?? ""
        mapItem.openInMaps(launchOptions: options)
    }
    
    func openInGoogleMaps() {
        let lat = String(coordinates.latitude)
        let lon = String(coordinates.longitude)
        let coordinateString = "\(lat),\(lon)"
        
        guard let url = URL(string:
            "comgooglemaps://?q=\(coordinateString)&center=\(lat),\(lon)&zoom=13&views=traffic") else {
                self.openInMaps()
                return
        }
        
        UIApplication.shared.open(url, options: [:],
                                  completionHandler: {
                                    (success) in
                                    print("Open \(success)")
        })
    }
}
