import UIKit
import MapKit
import CoreLocation




var searchKey = ""
let GOOGLE_API_KEY = "AIzaSyB9Yzf1rT5v01NZBiv4mj4HPzRr4AhOC0w"

class ViewController: UIViewController, UITextFieldDelegate, CLLocationManagerDelegate{
    
    
    let locationManager = CLLocationManager()
    
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var keyword: UITextField!
    
    
    
    
    
    var locValue:CLLocation!{
        didSet{
            let coord = self.locValue.coordinate
            print (coord.latitude)
            print(coord.longitude)
        }
    }
    
    
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        let annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "myspot")
        annotationView.animatesDrop = true
        annotationView.canShowCallout = true
        annotationView.pinTintColor = UIColor.blueColor()
        
        let button = UIButton(type: .DetailDisclosure)
        annotationView.rightCalloutAccessoryView = button
    
        

        return annotationView
    }
//
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        let location = view.annotation as! mapLocation
        let title = location.title
        
        let placeId = location.placeId
//        let alert = UIAlertController(title: title, message: "Got Place Id for Next Page", preferredStyle: .Alert)
//        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler:nil ))
//        presentViewController(alert, animated:true, completion:nil)
        print ("we are here")
       // performSegueWithIdentifier("hello", sender: self)
        self.performSegueWithIdentifier("DetailPageSegue", sender: location)
        
    }
    
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "DetailPageSegue"){
            let detailView:DetailViewController = segue.destinationViewController as! DetailViewController
            
            detailView.detaillocation = (sender as? mapLocation)!
        }
    }
    
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        
        //resigning as first responder
        keyword.resignFirstResponder()
        
        
        //remove previous annotations
        let annotationsToRemove = mapView.annotations.filter { $0 !== mapView.userLocation }
        mapView.removeAnnotations( annotationsToRemove )

        
        searchKey = keyword.text!
        
        
        print (searchKey)
        print (locValue.coordinate.longitude)
        
        var baseURL = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=\(locValue.coordinate.latitude),\(locValue.coordinate.longitude)&radius=500&type=restaurant&name=\(searchKey)&key=\(GOOGLE_API_KEY)"
        
        
       // here we declare center and vicinity of the map
        let center = CLLocationCoordinate2DMake(locValue.coordinate.latitude, locValue.coordinate.longitude)
        let region = MKCoordinateRegion(center:center, span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02))
        
        let session = NSURLSession.sharedSession()
        let request = NSMutableURLRequest(URL: NSURL(string: baseURL)!)
        let task = session.dataTaskWithRequest(request){
            (data, response, error)-> Void in
            if error != nil {
                
                print (error!.localizedDescription)
                return
            }
            
            
            do{
                let json = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments)
                
                //we go through the jsonobject as results we get
                
                if let items = json["results"] as? [[String: AnyObject]]{
                    for items in items{
                        
                        print (items)
                        
                        
                        
                        if let name = items["name"] as? String, let vicinity = items["vicinity"] as? String{
                            
                            let coords: [Double] = self.getCoords(items["geometry"] as! Dictionary)
                            
                            
                            var annotation = mapLocation(title: name, coordinate: CLLocationCoordinate2D(latitude: coords[0], longitude:coords[1]), placeId: vicinity, subtitle: "delicious")

                            
//                            //defining annotations
//                          //  annotation.coordinate = CLLocationCoordinate2D(
//                                latitude: coords[0],
//                                longitude: coords[1]
//                            )
//                            
//                            annotation.title = name + vicinity
//                            
//                            //pinning annotations
                            
                            self.mapView.addAnnotation(annotation)
                            
                        }
                        
                    }
                    //updating UI on the main thread
                    dispatch_async(dispatch_get_main_queue()){
                        self.mapView.setRegion(region, animated: true)
                    }
                    
                    
                }

                
            }catch{
                print("error serializing json")
            }
            
            
            
        }
        task.resume()
        
        return true;
        
    }
    
    
    override func viewDidLoad() {
        
  
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        
        self.keyword.becomeFirstResponder()
        super.viewDidLoad()
    
        var center = CLLocationCoordinate2DMake(38.90, -77.016)
        var region = MKCoordinateRegion(center:center, span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
        
        //pinning annotations when view loads
        self.mapView.setRegion(region, animated: true)
        
        
    }
    
    

    
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print ("yes")
        locValue = manager.location!
        
        //center = CLLocationCoordinate2DMake(locValue.latitude, locValue.longitude)
        locationManager.stopUpdatingLocation()
        
        
        print("locations = \(locValue.coordinate.latitude) \(locValue.coordinate.longitude)")
    }
    
    
    
    func getCoords(data: [String:AnyObject]) -> [Double]{
        let c = data["location"] as![String: AnyObject]
        print (c)
        return [c["lat"] as! Double, c["lng"] as! Double]
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}








