//
//  ViewController.swift
//  Virtual Tourist
//
//  Created by Paek, Jae on 11/23/20.
//

import UIKit
import MapKit
import CoreData

class MapViewController: UIViewController, MKMapViewDelegate  {
    
    let LAT = "lat", LON = "lon", LON_DELTA = "lonDelta", LAT_DELTA = "latDelta"
    

    @IBOutlet weak var mapView: MKMapView!
    
    var dataController:DataController!
    
    var fetchedResultsController:NSFetchedResultsController<Pin>!
    
    fileprivate func setupFetchedResultsController(completion: () -> Void) {
        let fetchRequest:NSFetchRequest<Pin> = Pin.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: "pins")
        do {
            try fetchedResultsController.performFetch()
            completion()
        } catch {
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        FlickrClient.pageNumber = 1
        setRegion()
        setTapGesture()
        setupFetchedResultsController(completion:setAnnotations)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupFetchedResultsController(completion:setAnnotations)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UserDefaults.standard.set([LON: mapView.region.center.longitude, LAT: mapView.region.center.latitude, LON_DELTA: mapView.region.span.longitudeDelta, LAT_DELTA: mapView.region.span.latitudeDelta], forKey: "initRegion")
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        fetchedResultsController = nil
    }
    
    func setRegion() {
        if let regionMap = UserDefaults.standard.object(forKey: "initRegion") as? [String: Double] {
            let coordinate = CLLocationCoordinate2D(latitude: regionMap[LAT] ?? 0, longitude:  regionMap[LON] ?? 0)
            let span = MKCoordinateSpan(latitudeDelta: regionMap[LAT_DELTA] ?? 10, longitudeDelta: regionMap[LON_DELTA] ?? 10)
            mapView.setRegion(MKCoordinateRegion(center: coordinate, span: span), animated: false)
        }
    }
    
    func setAnnotations() {
        mapView.removeAnnotations(mapView.annotations)
        var annotations: [MKPointAnnotation] = [MKPointAnnotation]()
        
        fetchedResultsController.fetchedObjects?.forEach{ pin in
            let annotation = MKPointAnnotation()
            annotation.coordinate = CLLocationCoordinate2D(latitude: pin.latitude, longitude: pin.longitude)
            annotations.append(annotation)
        }
        mapView.addAnnotations(annotations)
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
        
        let pin = Pin(context: dataController.viewContext)
        pin.latitude = annotation.coordinate.latitude
        pin.longitude = annotation.coordinate.longitude
        pin.creationDate = Date()
        try? dataController.viewContext.save()
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView

        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = false
            pinView!.pinTintColor = .red
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
        photoAlbumViewController.dataController = dataController
        do {
            try fetchedResultsController.performFetch()
            fetchedResultsController.fetchedObjects?.forEach{ pin in
                if pin.latitude == view.annotation?.coordinate.latitude && pin.longitude == view.annotation?.coordinate.longitude {
                    photoAlbumViewController.pin = pin
                }
            }
        } catch {
            
        }
        
        
        self.navigationController!.pushViewController(photoAlbumViewController, animated: true)
    }

}
