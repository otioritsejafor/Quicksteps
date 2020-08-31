//
//  PathViewController.swift
//  MP4
//
//  Created by Oti Oritsejafor on 11/1/19.
//  Copyright © 2019 Magloboid. All rights reserved.
//

import Foundation
import UIKit
import Mapbox

class PathViewController: UIViewController, MGLMapViewDelegate {
    @IBOutlet weak var pathMap: MGLMapView!
    var pathCoordinates: [CLLocationCoordinate2D] = []
    var locations: [Location]!
    var polylineSource: MGLShapeSource?
    
    override func viewDidLoad() {
        pathMap.delegate = self
       
        for location in locations {
            pathCoordinates.append(CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude))
        }
         let first = pathCoordinates.first
        
        pathMap.setCenter(CLLocationCoordinate2D(latitude: first!.latitude, longitude: first!.longitude), zoomLevel: 15, animated: false)
    }
    
    @IBAction func goBack(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    func createPolylineWithCoordinates(coordinates: [CLLocationCoordinate2D]) {
        var mutableCoordinates = coordinates
        
        let polyline = MGLPolylineFeature(coordinates: &mutableCoordinates, count: UInt(mutableCoordinates.count))
        polylineSource?.shape = polyline
    }
    
    func mapViewDidFinishLoadingMap(_ mapView: MGLMapView) {
        addPolyline(to: mapView.style!)
        createPolylineWithCoordinates(coordinates: pathCoordinates)
    }
    
    func addPolyline(to style: MGLStyle) {
      
        let source = MGLShapeSource(identifier: "polyline", shape: nil, options: nil)
        style.addSource(source)
        polylineSource = source
 
        let layer = MGLLineStyleLayer(identifier: "polyline", source: source)
        layer.lineJoin = NSExpression(forConstantValue: "round")
        layer.lineCap = NSExpression(forConstantValue: "round")
        layer.lineColor = NSExpression(forConstantValue: #colorLiteral(red: 0.3647058904, green: 0.06666667014, blue: 0.9686274529, alpha: 1))
  
        layer.lineWidth = NSExpression(format: "mgl_interpolate:withCurveType:parameters:stops:($zoomLevel, 'linear', nil, %@)",
                                       [14: 5, 18: 20])
        style.addLayer(layer)
    }
}
