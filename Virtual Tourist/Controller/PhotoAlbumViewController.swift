//
//  PhotoAlbumViewController.swift
//  Virtual Tourist
//
//  Created by Paek, Jae on 11/23/20.
//

import UIKit
import MapKit
import CoreData

class PhotoAlbumViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    var coordinate:CLLocationCoordinate2D!
    var span:MKCoordinateSpan!
    var photos: [FlickrPhoto]!
    var fetchedResultsController:NSFetchedResultsController<Photo>!
    var dataController:DataController!
    var pin:Pin!
    
    @IBOutlet weak var noImageLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var photoView: UICollectionView!
    
    fileprivate func setupFetchedResultsController() {
        let fetchRequest:NSFetchRequest<Photo> = Photo.fetchRequest()
        let predicate = NSPredicate(format: "pin == %@", pin)
        fetchRequest.predicate = predicate
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: "\(pin.id)-photos")
        fetchedResultsController.delegate = self

        do {
            try fetchedResultsController.performFetch()
            print(fetchedResultsController.fetchedObjects)
            photoView.reloadData()
        } catch {
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.removeAnnotations(mapView.annotations)
        photoView.delegate = self
        photoView.dataSource = self
        let annotation = getAnnotation()
        mapView.addAnnotation(annotation)
        zoomMapToAnnotation(annotation)
        setupFetchedResultsController()
        if fetchedResultsController.sections?[0].numberOfObjects == 0 {
            getPhotos(annotation)
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    @IBAction func refreshCollection(_ sender: Any) {
        do {
            try fetchedResultsController.performFetch()
            print(fetchedResultsController.fetchedObjects)
            fetchedResultsController.fetchedObjects?.forEach{ photo in
                dataController.viewContext.delete(photo)
                try? dataController.viewContext.save()
            }
            photoView.reloadData()
        } catch {
            print("Failed to delete")
        }
        
        FlickrClient.pageNumber! += 1
        if FlickrClient.pageNumber! > (FlickrClient.maxPage ?? 1) {
            FlickrClient.pageNumber = 1
        }
        getPhotos(getAnnotation())
    }
    
    
    func getAnnotation() -> MKPointAnnotation {
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        return annotation
    }
    
    func zoomMapToAnnotation(_ annotation: MKPointAnnotation) {
        let viewRegion = MKCoordinateRegion(center: annotation.coordinate, span: span)
        mapView.setRegion(viewRegion, animated: false)
    }
    
    func getPhotos(_ annotation: MKPointAnnotation) {
        _ = FlickrClient.getPhotos(latitude: annotation.coordinate.latitude, longitude: annotation.coordinate.longitude, completion: { (photos, error) in
            self.photos = photos
            self.photoView.reloadData()

            if photos.count == 0 {
                self.noImageLabel.isHidden = false
                return
            }
            
            photos.forEach{ photo in
                FlickrClient.downloadPhotoImage(photo: photo, completion: { data, error in
                    guard let data = data else {
                        return
                    }
                    //let image = UIImage(data: data)
                    let newPhoto = Photo(context: self.dataController.viewContext)
                    newPhoto.creationDate = Date()
                    newPhoto.pin = self.pin
                    newPhoto.photo = data
                    
                    do {
                        try self.dataController.viewContext.save()
                        print("Saved")
                    } catch {
                        print("Failed to save \(newPhoto)")
                    }
                    
                    
                    DispatchQueue.main.async {
                        try? self.fetchedResultsController.performFetch()
                        print(self.fetchedResultsController.fetchedObjects)
                        self.photoView.reloadData()
                    }

                })
            }
            
        })
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let fetchedCount = self.fetchedResultsController.fetchedObjects?.count {
            if fetchedCount > 0 {
                return fetchedCount
            }
        }
        if let photoCount = self.photos?.count {
            return photoCount
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCollectionViewCell", for: indexPath) as! PhotoCollectionViewCell
        if fetchedResultsController.fetchedObjects?.count ?? 0 > (indexPath as NSIndexPath).row {
            let photo: Photo? = fetchedResultsController.object(at: indexPath)
            
            // Set the name and image
            if let image = photo?.photo {
                cell.imageView?.image = UIImage(data: image)
            } else {
                cell.imageView?.image = UIImage(systemName: "photo")
            }
        
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let photoToBeDeleted = fetchedResultsController.object(at: indexPath)
        dataController.viewContext.delete(photoToBeDeleted)
        try? dataController.viewContext.save()
    }
}

extension PhotoAlbumViewController:NSFetchedResultsControllerDelegate {
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .delete:
            if let indexPath = indexPath {
                photoView.deleteItems(at: [indexPath])
            }
            break
        default:
            break
        }
    }
    
}
