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
    
    fileprivate func setupFetchedResultsController() {
        let fetchRequest:NSFetchRequest<Pin> = Pin.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: "pins")
        fetchedResultsController.delegate = self
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        do {
         setRegion()
        } catch {
            print(error)
        }
        setTapGesture()
        setupFetchedResultsController()
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
        
        self.navigationController!.pushViewController(photoAlbumViewController, animated: true)
    }

}

extension MapViewController:NSFetchedResultsControllerDelegate {
    
//    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
//        switch type {
//        case .insert:
//            tableView.insertRows(at: [newIndexPath!], with: .fade)
//            break
//        case .delete:
//            tableView.deleteRows(at: [indexPath!], with: .fade)
//            break
//        case .update:
//            tableView.reloadRows(at: [indexPath!], with: .fade)
//        case .move:
//            tableView.moveRow(at: indexPath!, to: newIndexPath!)
//        }
//    }
    
//    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
//        let indexSet = IndexSet(integer: sectionIndex)
//        switch type {
//        case .insert: tableView.insertSections(indexSet, with: .fade)
//        case .delete: tableView.deleteSections(indexSet, with: .fade)
//        case .update, .move:
//            fatalError("Invalid change type in controller(_:didChange:atSectionIndex:for:). Only .insert or .delete should be possible.")
//        }
//    }

    
//    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
//
//    }
//
//    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
//
//    }
    
}
