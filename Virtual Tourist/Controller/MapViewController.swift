//
//  ViewController.swift
//  Virtual Tourist
//
//  Created by Paek, Jae on 11/23/20.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {
    
    let LAT = "lat", LON = "lon", LON_DELTA = "lonDelta", LAT_DELTA = "latDelta"

    @IBOutlet weak var mapView: MKMapView!
    override func viewDidLoad() {
        super.viewDidLoad()
        setRegion()
        setTapGesture()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        UserDefaults.standard.set([LON: mapView.region.center.longitude, LAT: mapView.region.center.latitude, LON_DELTA: mapView.region.span.longitudeDelta, LAT_DELTA: mapView.region.span.latitudeDelta], forKey: "initRegion")
    }
    
    func setRegion() {
        if let regionMap = UserDefaults.standard.object(forKey: "initRegion") as? [String: Double] {
            let coordinate = CLLocationCoordinate2D(latitude: regionMap[LAT] ?? 0, longitude:  regionMap[LON] ?? 0)
            let span = MKCoordinateSpan(latitudeDelta: regionMap[LAT_DELTA] ?? 10, longitudeDelta: regionMap[LON_DELTA] ?? 10)
            mapView.setRegion(MKCoordinateRegion(center: coordinate, span: span), animated: false)
        }
    }
    
    func setTapGesture() {
        let gestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(addAnnotation(_:)))
        mapView.addGestureRecognizer(gestureRecognizer)
    }
    
    @objc func addAnnotation(_ gestureRecognizer: UILongPressGestureRecognizer) {
        let location = gestureRecognizer.location(in: mapView)
        let coordinate = mapView.convert(location, toCoordinateFrom: mapView)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        
        mapView.addAnnotation(annotation)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView

        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = false
            pinView!.pinColor = .red
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        let photoAlbumViewController = self.storyboard!.instantiateViewController(withIdentifier: "PhotoAlbumViewController") as! PhotoAlbumViewController
        
        photoAlbumViewController.coordinate = view.annotation?.coordinate
        photoAlbumViewController.span = mapView.region.span
        
        self.navigationController!.pushViewController(photoAlbumViewController, animated: true)
    }

}

