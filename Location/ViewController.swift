//
//  ViewController.swift
//  Location
//
//  Created by Eric  on 04.08.22.
//

import UIKit
import MapKit
import Foundation

var restaurantsItaly = Array<ViewController.Restaurant>()
var restaurantsAsian = Array<ViewController.Restaurant>()
var restaurantsMexican = Array<ViewController.Restaurant>()
var tuples = [(Array<ViewController.Restaurant>(), CGFloat())]
var mapViewer = MKMapView()
var asiaFilterXYPort = CGPoint(x: 70, y: 744)
var italianFilterXYPort =  CGPoint(x: 320, y: 744)
var mexicanFilterXYPort = CGPoint(x: 205, y: 744)
var firstColor = UIColor()
var secondColor = UIColor()
var thirdColor = UIColor()


class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {

    @IBOutlet var mapView: MKMapView!
    var mapSize = CGSize()
    
    @IBOutlet var firstFilter: UIImageView!
    @IBOutlet var secondFilter: UIImageView!
    @IBOutlet var thirdFilter: UIImageView!
    
    // set mapview
    lazy var restrictedRegion: MKCoordinateRegion = {
        let location = CLLocationCoordinate2DMake(47.659216, 9.1750718) //constance
        //let location = CLLocationCoordinate2DMake(51.4962331, 0.2000000) //london
        // Span and region
        let span = MKCoordinateSpan(latitudeDelta: 0.03, longitudeDelta: 0.03) //constance
        // let span = MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5) //london 
        return MKCoordinateRegion(center: location, span: span)
    }()
    
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        return NonClusteringMKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "MyMarker")
    }
    
  
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.isZoomEnabled = false
        mapView.isScrollEnabled = false
        mapView.isUserInteractionEnabled = false
        mapView.delegate = self
        mapViewer = mapView
        mapSize = mapView.frame.size
        mapView.setRegion(restrictedRegion, animated: false)
        
        var longitude = 0.0
        var latitude = 0.0
        var restaurantName = ""
        var restaurantCuisine =  ""
        var coordinates = Coordinates()
        
        let fileUrl = Bundle.main.path(forResource: "konstanz", ofType: "rtf")
        //let fileUrl = Bundle.main.path(forResource: "halfLondon", ofType: "rtf")
      
        guard let file = freopen(fileUrl, "r", stdin) else {
            return
        }
        defer {
            fclose(file)
        }

        // gets restaurant data from rtf file
        while let line = readLine() {

            if(line.contains("\"name\"") || line.contains("lat") || line.contains("cuisine")){
                let infoArray = line.components(separatedBy: "\" ")
               
                for string in infoArray {
                    if(string.contains("lat")){
                        let allowedCharset = CharacterSet
                            .decimalDigits
                            .union(CharacterSet(charactersIn: "."))
                        latitude = Double(String(string.unicodeScalars.filter(allowedCharset.contains))) ?? 0.0
                    }
                    
                    if(string.contains("lon")){
                        let allowedCharset = CharacterSet
                            .decimalDigits
                            .union(CharacterSet(charactersIn: "."))
                        longitude = Double(String(string.unicodeScalars.filter(allowedCharset.contains))) ?? 0.0
                    }
                    
                    if(string.contains("cuisine")){
                        restaurantCuisine = infoArray[1].components(separatedBy: "\"")[1]
                        coordinates = Coordinates(latitude: latitude,longitude: longitude)
                    }
                    
                    if(string.contains("name")){
                        
                            restaurantName = infoArray[1].components(separatedBy: "\"")[1]
                           
                    
                    
                        if(restaurantCuisine.contains("italian")){
                            restaurantsItaly.append(Restaurant(restaurantCoordinates: coordinates, restaurantName: restaurantName, restaurantCuisine: "italian", xyPoints: coordinatesToXY(coordinatsOfInterest: coordinates)))
                            restaurantCuisine = ""
                            restaurantName = ""
                        }else if(restaurantCuisine.contains("mexican")){
                            restaurantsMexican.append(Restaurant(restaurantCoordinates: coordinates, restaurantName: restaurantName, restaurantCuisine: "mexican", xyPoints: coordinatesToXY(coordinatsOfInterest: coordinates)))
                            restaurantCuisine = ""
                            restaurantName = ""
                        }else if(restaurantCuisine.contains("asian")){
                            restaurantsAsian.append(Restaurant(restaurantCoordinates: coordinates, restaurantName: restaurantName, restaurantCuisine: "asian", xyPoints: coordinatesToXY(coordinatsOfInterest: coordinates)))
                            restaurantCuisine = ""
                            restaurantName = ""
                        }
                    }
                }
            }
        }
    loadFilterPics()
    }

    // transforms the long and lat into the screenpoint x and y
    func coordinatesToXY(coordinatsOfInterest: Coordinates) -> Array<Double>{
        
        //coordinates from edges of mapview to calculate xy scales
        let northWest = mapView.convert(CGPoint(x: mapView.bounds.minX, y: mapView.bounds.minY), toCoordinateFrom: mapView)
        let southEast = mapView.convert(CGPoint(x: mapView.bounds.maxX, y: mapView.bounds.maxY), toCoordinateFrom: mapView)
        // These should roughly box Germany - use the actual values appropriate to your image
        let minLat = northWest.latitude
        let minLong = northWest.longitude
        let maxLat = southEast.latitude
        let maxLong = southEast.longitude

        // Determine the map scale (points per degree)
        let xScale = mapSize.width / (maxLong - minLong)
        let yScale = mapSize.height / (maxLat - minLat)

        // Latitude and longitude of restaurant
        let spotLat = coordinatsOfInterest.latitude;
        let spotLong = coordinatsOfInterest.longitude;

        // position of map image for point
        let x = (spotLong - minLong) * xScale
        let y = (spotLat - minLat) * yScale
        
        return [x, y]
    }
    
    //orders the filters accordingly for the center of their points of interests
    func loadFilterPics(){
        
        var italianX = Double()
        var asianX = Double()
        var mexicanX = Double()
        
        for restaurant1 in restaurantsItaly {
            italianX += restaurant1.x / Double(restaurantsItaly.count)
        }
        for restaurant2 in restaurantsAsian {
            asianX += restaurant2.x / Double(restaurantsAsian.count)
        }
        for restaurant3 in restaurantsMexican {
            mexicanX += restaurant3.x / Double(restaurantsMexican.count)
        }
        print(italianX,asianX,mexicanX)
        
        if(italianX > max(asianX, mexicanX) && asianX > mexicanX){
            italianFilterXYPort = CGPoint(x: 320, y: 744)
            asiaFilterXYPort = CGPoint(x: 205, y: 744)
            mexicanFilterXYPort = CGPoint(x: 70, y: 744)
            firstFilter.image = UIImage(named: "MexicanFilter2")
            secondFilter.image = UIImage(named: "AsiaFilter2")
            thirdFilter.image = UIImage(named: "ItalianFilter2")
            firstColor = UIColor.black
            secondColor = UIColor.red
            thirdColor = UIColor.blue
        }else if(italianX > max(asianX, mexicanX) && mexicanX > asianX){
            italianFilterXYPort = CGPoint(x: 320, y: 744)
            mexicanFilterXYPort = CGPoint(x: 205, y: 744)
            asiaFilterXYPort = CGPoint(x: 70, y: 744)
            firstFilter.image = UIImage(named: "AsiaFilter2")
            secondFilter.image = UIImage(named: "MexicanFilter2")
            thirdFilter.image = UIImage(named: "ItalianFilter2")
            firstColor = UIColor.red
            secondColor = UIColor.black
            thirdColor = UIColor.blue
        }else if(asianX > max(italianX, mexicanX) && italianX > mexicanX){
            asiaFilterXYPort = CGPoint(x: 320, y: 744)
            italianFilterXYPort = CGPoint(x: 205, y: 744)
            mexicanFilterXYPort = CGPoint(x: 70, y: 744)
            firstFilter.image = UIImage(named: "MexicanFilter2")
            secondFilter.image = UIImage(named: "ItalianFilter2")
            thirdFilter.image = UIImage(named: "AsiaFilter2")
            firstColor = UIColor.black
            secondColor = UIColor.blue
            thirdColor = UIColor.red
        }else if(asianX > max(italianX, mexicanX) && mexicanX > italianX){
            asiaFilterXYPort = CGPoint(x: 320, y: 744)
            mexicanFilterXYPort = CGPoint(x: 205, y: 744)
            italianFilterXYPort = CGPoint(x: 70, y: 744)
            firstFilter.image = UIImage(named: "ItalianFilter2")
            secondFilter.image = UIImage(named: "MexicanFilter2")
            thirdFilter.image = UIImage(named: "AsiaFilter2")
            firstColor = UIColor.blue
            secondColor = UIColor.black
            thirdColor = UIColor.red
        }else if(mexicanX > max(italianX, asianX) && italianX > asianX){
            mexicanFilterXYPort = CGPoint(x: 320, y: 744)
            italianFilterXYPort = CGPoint(x: 205, y: 744)
            mexicanFilterXYPort = CGPoint(x: 70, y: 744)
            firstFilter.image = UIImage(named: "AsiaFilter2")
            secondFilter.image = UIImage(named: "ItalianFilter2")
            thirdFilter.image = UIImage(named: "MexicanFilter2")
            firstColor = UIColor.red
            secondColor = UIColor.blue
            thirdColor = UIColor.black
        }else{
            mexicanFilterXYPort = CGPoint(x: 320, y: 744)
            asiaFilterXYPort = CGPoint(x: 205, y: 744)
            italianFilterXYPort = CGPoint(x: 70, y: 744)
            firstFilter.image = UIImage(named: "ItalianFilter2")
            secondFilter.image = UIImage(named: "AsiaFilter2")
            thirdFilter.image = UIImage(named: "MexicanFilter2")
            firstColor = UIColor.blue
            secondColor = UIColor.red
            thirdColor = UIColor.black
        }
    }
    
    /**
        Restaurant with his x,y coordinate, cuisine type and name
     */
    struct Restaurant {
        var coordinates = Coordinates()
        var name = ""
        var cuisine = ""
        var x = 0.0
        var y = 0.0
        var description: String {
            return "Restaurant: \(name), cuisine: \(cuisine)"
        }
        init(restaurantCoordinates: Coordinates, restaurantName: String, restaurantCuisine: String, xyPoints: [Double]){
            name.self = restaurantName
            coordinates.self = restaurantCoordinates
            cuisine.self = restaurantCuisine
            x.self = xyPoints[0]
            y.self = xyPoints[1]
        }
    }
    
    struct Coordinates {
        var latitude = 0.0
        var longitude = 0.0
    }
}

