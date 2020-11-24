//
//  PhotoAlbumViewController.swift
//  Virtual Tourist
//
//  Created by Paek, Jae on 11/23/20.
//

import UIKit
import MapKit

class PhotoAlbumViewController: UIViewController {
    
    var coordinate:CLLocationCoordinate2D!
    var span:MKCoordinateSpan!
    @IBOutlet weak var noImageLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.removeAnnotations(mapView.annotations)
        let annotation = getAnnotation()
        mapView.addAnnotation(annotation)
        zoomMapToAnnotation(annotation)
        
    }
    
    func getAnnotation() -> MKPointAnnotation {
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
//        annotation.title = "\(firstName) \(lastName)"
//        annotation.subtitle = mediaURL
        
        return annotation
    }
    
    func zoomMapToAnnotation(_ annotation: MKPointAnnotation) {
        let viewRegion = MKCoordinateRegion(center: annotation.coordinate, span: span)
        mapView.setRegion(viewRegion, animated: false)
    }
}
