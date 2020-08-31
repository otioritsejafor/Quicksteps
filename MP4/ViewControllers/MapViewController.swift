//
//  ViewController.swift
//  MP4
//
//  Created by Oti Oritsejafor on 10/28/19.
//  Copyright © 2019 Magloboid. All rights reserved.
//

import UIKit
import MapKit
import Mapbox
import CoreLocation

class MapViewController: UIViewController {

    // MARK: Outlets
    @IBOutlet weak var mapView: MGLMapView!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var avgSpeedLabel: UILabel!
    
    // MARK: Location and Time
    var run: Run?
    private var seconds: Int = 0
    private var timer: Timer?
    private var lineTimer: Timer?
    private var distance = Measurement(value: 0, unit: UnitLength.meters)
    private var paces: [Double] = []
    private var locationList: [CLLocation] = []
    private var coordinateList: [CLLocationCoordinate2D] = []
    var polylineSource: MGLShapeSource?
    var userLocation: CLLocation?
    
    var coordinates = CLLocationCoordinate2D()
    fileprivate let locationManager: CLLocationManager = CLLocationManager()
    let current_loc = MGLPointAnnotation()
    
    // MARK: Counters
    var mode = 0
    var currentIndex = 1
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpButton()
        //configureUI()
        
        enableLocationServices()
        setUpLocation()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func startTapped() {
        startRun()
    }
    
    func configureUI() {
        let label = UILabel()
        label.textColor = UIColor.black
        label.text = "Past Runs"
       
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(customView: label)
    }
    
    private func saveRun() {
        let averagePace = paces.average()
        let newRun = Run(context: DataStack.context)
        newRun.distance = distance.value
        newRun.duration = Int16(seconds)
        newRun.timestamp = Date()
        newRun.averageSpeed = averagePace
        //newRun. 
        
        for location in locationList {
            let locationObject = Location(context: DataStack.context)
            locationObject.latitude = location.coordinate.latitude
            locationObject.longitude = location.coordinate.longitude
            locationObject.timestamp = location.timestamp
            newRun.addToLocations(locationObject)
        }
        
        DataStack.saveContext()
        
        run = newRun
    }
    
    func setUpButton() {
        startButton.backgroundColor = #colorLiteral(red: 0, green: 0.6711811423, blue: 0.9963676333, alpha: 1)
        startButton.layer.cornerRadius = 25.0
        startButton.tintColor = UIColor.white
        startButton.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        startButton.layer.shadowOffset = CGSize(width: 0, height: 3)
        startButton.layer.shadowOpacity = 1.0
        startButton.layer.shadowRadius = 10.0
        startButton.layer.masksToBounds = false
    }
    
    func setUpLocation() {
        guard let _ = locationManager.location?.coordinate else {
            return
        }
        
        coordinates = (locationManager.location?.coordinate)!
        
        current_loc.coordinate = CLLocationCoordinate2D(latitude: coordinates.latitude, longitude: coordinates.longitude)
        current_loc.title = "You"
        
        mapView.setCenter(CLLocationCoordinate2D(latitude: coordinates.latitude, longitude: coordinates.longitude), zoomLevel: 15, animated: false)
        
        mapView.delegate = self
        mapView.addAnnotation(current_loc)
        
        locationManager.stopUpdatingLocation()
    }
    
    private func startLocationUpdates() {
        locationManager.activityType = .fitness
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 10
        locationManager.startUpdatingLocation()
    }
    
    private func startRun() {
        if mode == 0 {
            startButton.backgroundColor = #colorLiteral(red: 1, green: 0.1248341114, blue: 0.1351750396, alpha: 1)
            startButton.setTitle("Stop", for: .normal)
            mode = 1
           
            mapView.userTrackingMode = .followWithHeading
            
            
            //mapView.removeAnnotation(current_loc)
            currentIndex = 1
            seconds = 0
            distance = Measurement(value: 0, unit: UnitLength.meters)
            locationList.removeAll()
            coordinateList.removeAll()
            updateDisplay()
            timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
                self.eachSecond()
            }
            startLocationUpdates()
            mapView.locationManager.startUpdatingLocation()
            mapView.locationManager.startUpdatingHeading()
            //animateLine()
            
        } else {
            presentEndAlert()
            startButton.backgroundColor = #colorLiteral(red: 0, green: 0.6711811423, blue: 0.9963676333, alpha: 1)
            startButton.setTitle("Start Run", for: .normal)
            timer?.invalidate()
            locationManager.stopUpdatingLocation()
            
            mode = 0
            
            mapView.userTrackingMode = .none
            mapView.locationManager.stopUpdatingLocation()
            mapView.locationManager.stopUpdatingHeading()
            updateDisplay()
        }
    }
    
    private func animateLine() {
        if currentIndex > coordinateList.count {

            return
        }
        // Create a subarray of locations up to the current index.
        let newCoordinates = Array(coordinateList[0..<currentIndex])
        
        // Update our MGLShapeSource with the current locations.
        updatePolylineWithCoordinates(coordinates: newCoordinates)
        
        currentIndex += 1
    }
    
    func eachSecond() {
        seconds += 1
        updateDisplay()
        if currentIndex > coordinateList.count {
            return
        }
  
        let newCoordinates = Array(coordinateList[0..<currentIndex])
        
        
        self.updatePolylineWithCoordinates(coordinates: newCoordinates)
        currentIndex += 1
        
    }
    
    private func updateDisplay() {
        let formattedDistance = FormatDisplay.distance(distance)
        let formattedTime = FormatDisplay.time(seconds)
        //let formattedPace = FormatDisplay.pace(distance: distance,
                                         //      seconds: seconds,
                                         //      outputUnit: .kilometersPerHour)
        
        let pace = (distance.value/Double(seconds)) * 2.237
        paces.append(pace)
       
       
        self.distanceLabel.text = String("\(formattedDistance)".dropLast(3))
        self.timeLabel.text = "\(formattedTime)"
        self.avgSpeedLabel.text = "\(pace.rounded())"
    }
    
    func presentEndAlert() {
        let alertController = UIAlertController(title: "Run Ended",
                                                message: "Do you want to save your run?",
                                                preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: "No", style: .cancel))
        alertController.addAction(UIAlertAction(title: "Yes", style: .default) { _ in
            self.saveRun()
        })
        
        present(alertController, animated: true)
    }
    
    func updatePolylineWithCoordinates(coordinates: [CLLocationCoordinate2D]) {
        var mutableCoordinates = coordinates
        
        let polyline = MGLPolylineFeature(coordinates: &mutableCoordinates, count: UInt(mutableCoordinates.count))
        
        // Updating the MGLShapeSource’s shape will have the map redraw our polyline with the current coordinates.
        polylineSource?.shape = polyline
    }
    
    func addPolyline(to style: MGLStyle) {
        // Add an empty MGLShapeSource, we’ll keep a reference to this and add points to this later.
        let source = MGLShapeSource(identifier: "polyline", shape: nil, options: nil)
        style.addSource(source)
        polylineSource = source
        
        // Add a layer to style our polyline.
        let layer = MGLLineStyleLayer(identifier: "polyline", source: source)
        layer.lineJoin = NSExpression(forConstantValue: "round")
        layer.lineCap = NSExpression(forConstantValue: "round")
        layer.lineColor = NSExpression(forConstantValue: #colorLiteral(red: 0.3647058904, green: 0.06666667014, blue: 0.9686274529, alpha: 1))
        
        // The line width should gradually increase based on the zoom level.
        layer.lineWidth = NSExpression(format: "mgl_interpolate:withCurveType:parameters:stops:($zoomLevel, 'linear', nil, %@)",
                                       [15: 1, 18: 20])
        style.addLayer(layer)
    }
    
}

extension MapViewController: CLLocationManagerDelegate {
    func enableLocationServices() {
        locationManager.delegate = self
        
        switch CLLocationManager.authorizationStatus() {
            
        case .notDetermined:
            print("DEBUG: Not Determined")
            locationManager.requestWhenInUseAuthorization()
        case .restricted, .denied:
            self.displayAlert(message: "Please enable location under app settings to use this app", action: "OK")
           // locationManager.requestWhenInUseAuthorization()
        case .authorizedAlways:
            print("DEBUG: Auth Always")
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
        case .authorizedWhenInUse:
            //locationManager.requestAlwaysAuthorization()
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            print("DEBUG: Auth when in use")
        @unknown default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        userLocation = manager.location
        
        for newLocation in locations {
            // TODO: Filter locations for accuracy
            let timeSince = abs(newLocation.timestamp.timeIntervalSinceNow)
            guard  timeSince < 10 else { continue }
            
            if let lastLoc = locationList.last {
                let nextDistance = newLocation.distance(from: lastLoc)
                distance = distance + Measurement(value: nextDistance, unit: .meters)
                
            }
            
            locationList.append(newLocation)
            coordinateList.append(newLocation.coordinate)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            locationManager.startUpdatingLocation()
            setUpLocation()
        }
        
        if status == .denied || status == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        }
        //setUpLocation()
    }
    
}



extension MapViewController: MGLMapViewDelegate {
    func mapViewDidFinishLoadingMap(_ mapView: MGLMapView) {
        //locationManager.requestWhenInUseAuthorization()
        setUpLocation()
        addPolyline(to: mapView.style!)
        
    }
    
    func mapView(_ mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool {
        return true
    }
    
    
    func mapView(_ mapView: MGLMapView, rightCalloutAccessoryViewFor annotation: MGLAnnotation) -> UIView? {
        return UIButton(type: .detailDisclosure)
    }
    
    func mapView(_ mapView: MGLMapView, fillColorForPolygonAnnotation annotation: MGLPolygon) -> UIColor {
        return UIColor.blue
    }
    
    func mapView(_ mapView: MGLMapView, alphaForShapeAnnotation annotation: MGLShape) -> CGFloat {
        // Set the alpha for all shape annotations to 1 (full opacity)
        return 1
    }
    
    func mapView(_ mapView: MGLMapView, lineWidthForPolylineAnnotation annotation: MGLPolyline) -> CGFloat {
        // Set the line width for polyline annotations
        return 2.0
    }
    
    func mapView(_ mapView: MGLMapView, strokeColorForShapeAnnotation annotation: MGLShape) -> UIColor {
        // Give our polyline a unique color by checking for its `title` property
        if (annotation.title == "Crema to Council Crest" && annotation is MGLPolyline) {
            // Mapbox cyan
            return #colorLiteral(red: 0.3647058904, green: 0.06666667014, blue: 0.9686274529, alpha: 1)
        } else {
            return #colorLiteral(red: 0.3647058904, green: 0.06666667014, blue: 0.9686274529, alpha: 1)
        }
    }
    
    // Optional: tap the user location annotation to toggle heading tracking mode.
    func mapView(_ mapView: MGLMapView, didSelect annotation: MGLAnnotation) {
        if mapView.userTrackingMode != .followWithHeading {
            mapView.userTrackingMode = .followWithHeading
        } else {
            mapView.resetNorth()
        }
        
        // We're borrowing this method as a gesture recognizer, so reset selection state.
        mapView.deselectAnnotation(annotation, animated: false)
    }
    
    
    

    
    
}

