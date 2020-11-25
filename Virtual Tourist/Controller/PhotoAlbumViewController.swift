//
//  PhotoAlbumViewController.swift
//  Virtual Tourist
//
//  Created by Paek, Jae on 11/23/20.
//

import UIKit
import MapKit

class PhotoAlbumViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    var coordinate:CLLocationCoordinate2D!
    var span:MKCoordinateSpan!
    var photos: [FlickrPhoto]!
    
    @IBOutlet weak var noImageLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var photoView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.removeAnnotations(mapView.annotations)
        photoView.delegate = self
        photoView.dataSource = self
        let annotation = getAnnotation()
        mapView.addAnnotation(annotation)
        zoomMapToAnnotation(annotation)
        getPhotos(annotation)
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
    
    func getPhotos(_ annotation: MKPointAnnotation) {
        _ = FlickrClient.getPhotos(latitude: annotation.coordinate.latitude, longitude: annotation.coordinate.longitude, completion: { (photos, error) in
            self.photos = photos
            self.photoView.reloadData()

            
            photos.forEach{ photo in
                FlickrClient.downloadPhotoImage(photo: photo, completion: { data, error in
                    guard let data = data else {
                        return
                    }
                    let image = UIImage(data: data)
                    if let row = self.photos.firstIndex(where: {prevPhoto in
                        return prevPhoto.id == photo.id
                    }) {
                        if let cell = self.photoView.cellForItem(at: IndexPath(row: row, section: 0)) as? PhotoCollectionViewCell {
                            cell.imageView.image = image
                            self.photoView.reloadData()
                        } else {
                            print("Unknown row: \(row)")
                        }
                        
                    }

                })
            }
            
        })
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.photos?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCollectionViewCell", for: indexPath) as! PhotoCollectionViewCell
//        let photo = self.photos[(indexPath as NSIndexPath).row]
        
        // Set the name and image
        //cell.imageView?.image = UIImage(named: photo.)
        //cell.schemeLabel.text = "Scheme: \(villain.evilScheme)"
        
        return cell
    }
}
