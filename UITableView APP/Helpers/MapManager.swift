//
//  MapManager.swift
//  UITableView APP
//
//  Created by Егор Грива on 06.02.2020.
//  Copyright © 2020 Егор Грива. All rights reserved.
//

import UIKit
import MapKit

class MapManager{
    
    let locationManager = CLLocationManager()
    private let regionInMeters = 1000.00
    private var placeCoordinate: CLLocationCoordinate2D?
    private var directionsArray: [MKDirections] = []
    
    func setupPlacemark(place: Place, mapView: MKMapView){
           guard let location = place.location else {return}
           
           let geocoder = CLGeocoder()
           geocoder.geocodeAddressString(location) { (placemarks, error) in
               if let error = error{
                       print(error)
                       return
               }
               guard let placemarks = placemarks else {return}
               
               let placemark = placemarks.first
               
               let annotation = MKPointAnnotation()
               annotation.title = place.name
               annotation.subtitle = place.type
               
               guard let placemarkLocation = placemark?.location else {return}
               
               annotation.coordinate = placemarkLocation.coordinate
               self.placeCoordinate = placemarkLocation.coordinate
               
               mapView.showAnnotations([annotation], animated: true)
               mapView.selectAnnotation(annotation, animated: true)
           }
       }
    
    
    
    func checkLocationServices(mapView: MKMapView, segueIdentifier: String, closure:() -> ()){
        if CLLocationManager.locationServicesEnabled(){
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            checkLocationAutorization(mapView: mapView, segueIdentifier: segueIdentifier)
            closure()
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now()+1){
                self.showAllert(title: "Location services is disabled", message: "Enable plz")
            }
        }
    }
    
    func checkLocationAutorization(mapView: MKMapView, segueIdentifier: String){
           switch CLLocationManager.authorizationStatus() {
           case .authorizedWhenInUse:
               mapView.showsUserLocation = true
               if segueIdentifier == "getAdress"{showUserLocation(mapView: mapView)}
               break
           case .denied:
               DispatchQueue.main.asyncAfter(deadline: .now()+1){
                             self.showAllert(title: "Location services is disabled", message: "Enable plz")
                         }
               break
           case .notDetermined:
               locationManager.requestWhenInUseAuthorization()
           case .restricted:
               break
           case .authorizedAlways:
               break
                   
           @unknown default:
               print("new case is avialeable")
           }
       }
    
    func showUserLocation(mapView: MKMapView){
        if let location = locationManager.location?.coordinate{
            let region = MKCoordinateRegion(center: location, latitudinalMeters: regionInMeters, longitudinalMeters: regionInMeters)
            mapView.setRegion(region, animated: true)
        }
    }
    
    func getDirections(for mapView: MKMapView, previousLocation: (CLLocation) ->()){
        guard let location = locationManager.location?.coordinate else {
            showAllert(title: "Error", message: "Current location is not found")
            return
        }
        
        locationManager.startUpdatingLocation()
        previousLocation(CLLocation(latitude: location.latitude, longitude: location.longitude))
        guard let request = createDirectionsrequest(from: location) else {
            showAllert(title: "Error", message: "Destination is not found")
            return
        }
        let directions = MKDirections(request: request)
        resetMapView(withNew: directions,mapView: mapView)
        directions.calculate { (response, error) in
            if let error = error{
                print(error)
                return
            }
            guard let response = response else {
                self.showAllert(title: "Error", message: "Directions is not available")
                return
            }
            for route in response.routes {
                mapView.addOverlay(route.polyline)
                mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
                let distance = String(format: "%.1f", route.distance/1000)
                let timeInterval = route.expectedTravelTime
                
                print("Расстояние до места: \(distance) км.")
                print("Время в пути составит: \(timeInterval) сек.")
            }
        }
    }
    
    func createDirectionsrequest(from coordinate: CLLocationCoordinate2D) -> MKDirections.Request?{
        guard let destinationCoordinate = placeCoordinate else {return nil}
        let startingLocation = MKPlacemark(coordinate: coordinate)
        let destination = MKPlacemark(coordinate: destinationCoordinate)
        
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: startingLocation)
        request.destination = MKMapItem(placemark: destination)
        request.transportType = .automobile
        request.requestsAlternateRoutes = true
        
        return request
        
    }
    
    func startTrackingUserLocation(for mapView: MKMapView, and location: CLLocation?, closure: (_ currentLocation: CLLocation) -> ()){
           guard let location = location else {return}
           let center = getCenterLocation(for: mapView)
           guard center.distance(from: location) > 25 else {return}
           closure(center)
       }
    
    func resetMapView(withNew directions: MKDirections, mapView:MKMapView){
        mapView.removeOverlays(mapView.overlays)
        directionsArray.append(directions)
        let _ = directionsArray.map {$0.cancel()}
        directionsArray.removeAll()
    }
    
    func getCenterLocation(for mapView: MKMapView) -> CLLocation{
           let latitude = mapView.centerCoordinate.latitude
           let longitude = mapView.centerCoordinate.longitude
           
           return CLLocation(latitude: latitude, longitude: longitude)
       }
    
    
    
    func showAllert(title: String, message: String){
        let allert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ок", style: .default)
        
        allert.addAction(okAction)
        
        let alertWindow = UIWindow(frame: UIScreen.main.bounds)
        alertWindow.rootViewController = UIViewController()
        alertWindow.windowLevel = UIWindow.Level.alert + 1
        alertWindow.makeKeyAndVisible()
        alertWindow.rootViewController?.present(allert,animated: true)
    }
    
    /*
    func setupLocationManager(){
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
    }*/
    
}
