//
//  CanvasView.swift
//  Location
//
//  Created by Eric  on 19.08.22.
//

import UIKit
import MapKit

var setToShow = 0

var italianTree = [[( Array<ViewController.Restaurant>() , [UIBezierPath()])]]
var asianTree = [[( Array<ViewController.Restaurant>() , [UIBezierPath()])]]
var mexicanTree = [[( Array<ViewController.Restaurant>() , [UIBezierPath()])]]

class CanvasView: UIView {
 
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
       
        createButtons()
        italianTree = makeTrees(filteredGroups: [restaurantsItaly])
        asianTree = makeTrees(filteredGroups: [restaurantsAsian])
        mexicanTree = makeTrees(filteredGroups: [restaurantsMexican])

        
        if(setToShow == 0){
            treeCutter(dominanTree: italianTree
                       , secondTree: asianTree, thirdTree: mexicanTree)
        }
        else if(setToShow == 1){
            treeCutter(dominanTree: asianTree
                       , secondTree: italianTree, thirdTree: mexicanTree)
        }
        else if(setToShow == 2){
            treeCutter(dominanTree: mexicanTree
                       , secondTree: italianTree, thirdTree: asianTree)
        }
    }
    
    /**
                Draws the trees respecting their colors
     */
    func drawTree(tree: [[( Array<ViewController.Restaurant> , [UIBezierPath])]]){
        
        var color = UIColor()
        
        //sets color depending on what filters tree gets drawn
        for lowArray in tree{
            for tupel in lowArray{
                if(!tupel.0.isEmpty){
                    let restaurant = tupel.0[0]
                    if(restaurant.cuisine.contains("italian")){
                          color = UIColor.blue
                    }else if(restaurant.cuisine.contains("asian")){
                          color = UIColor.red
                    }else if(restaurant.cuisine.contains("mexican")){
                          color = UIColor.black
                    }
                    color.setStroke()
                }
            }
        }
        
        //places annotations and drawing the paths
        for groups in tree{
            for restaurant in groups{
                for path in restaurant.1{
                    path.stroke()
                }
                for ping in restaurant.0{
                    Location.mapViewer.addAnnotation((MKPointAnnotation(__coordinate: CLLocationCoordinate2D(latitude: ping.coordinates.latitude, longitude: ping.coordinates.longitude), title: ping.name, subtitle: "")))
                }
            }
        }
    }
    
    /**
        Takes three trees and will cut away branches that are intersecting, where the first input tree has the highest
        priority nothing gets cut, then second second highest and third with the lowest priority.
     */
    func treeCutter(dominanTree: [[( Array<ViewController.Restaurant> , [UIBezierPath])]], secondTree: [[( Array<ViewController.Restaurant> , [UIBezierPath])]], thirdTree: [[( Array<ViewController.Restaurant> , [UIBezierPath])]]){
        
        var treeNoInt = [[( Array<ViewController.Restaurant>() , [UIBezierPath()])]]
        var dominantPaths = [UIBezierPath()]

        // adds paths that wont be cut
            for group in dominanTree{
                for tupel in group{
                    for bezierPath in tupel.1{
                        dominantPaths.append(bezierPath)
                    }
                }
            }
    
        var intersections = 0;
        
        // checks for paths that will not intersect with the higher priority paths and add them with there restaurants
            for group in secondTree{
                for tupel in group{
                    if(tupel.1.count == 2){
                        for path in dominantPaths{
                            if( !path.isEmpty &&  !tupel.1[0].isEmpty &&  !tupel.1[1].isEmpty && (linesCross(segment1: tupel.1[0].cgPath.points(), segment2: path.cgPath.points()) || linesCross(segment1: tupel.1[1].cgPath.points(), segment2: path.cgPath.points()))) {
                                intersections+=1;
                            }
                        }
                    }else if(tupel.1.count == 1){
                        for path in dominantPaths{
                            if(!path.isEmpty && !tupel.1[0].isEmpty && (linesCross(segment1: tupel.1[0].cgPath.points(), segment2: path.cgPath.points()))) {
                                intersections+=1;
                            }
                        }
                    }
                }
                if(intersections == 0){
                    treeNoInt.append(group)
                }
                intersections = 0
            }
        
        //adds the new paths to the high priority list
            for group in treeNoInt{
                for tupel in group{
                    for bezierPath in tupel.1{
                        dominantPaths.append(bezierPath)
                    }
                }
            }
        
        drawTree(tree: treeNoInt) //draws second tree
        treeNoInt.removeAll()
        intersections = 0;
        
        // checks for paths that will not intersect with the higher priority paths and add them with there restaurants
            for group in thirdTree{
                for tupel in group{
                    if(tupel.1.count == 2){
                        for path in dominantPaths{
                            if( !path.isEmpty && !tupel.1[0].isEmpty &&  !tupel.1[1].isEmpty && (linesCross(segment1: tupel.1[0].cgPath.points(), segment2: path.cgPath.points()) || linesCross(segment1: tupel.1[1].cgPath.points(), segment2: path.cgPath.points()))) {
                                intersections+=1;
                            }
                        }
                    }else if(tupel.1.count > 2){
                        print("intersections of 1 paths exist")
                        for path in dominantPaths{
                            if(!path.isEmpty && !tupel.1[0].isEmpty && (linesCross(segment1: tupel.1[0].cgPath.points(), segment2: path.cgPath.points()))) {
                                intersections+=1;
                            }
                        }
                    }

                }
            if(intersections == 0){
                treeNoInt.append(group)
            }
            intersections = 0
        }
        
        for group in treeNoInt{
            for tupel in group{
                for bezierPath in tupel.1{
                    dominantPaths.append(bezierPath)
                }
            }
        }
        
    drawTree(tree: treeNoInt)
    drawTree(tree: dominanTree)
  
    }
    
    
    @objc func buttonClickedNext(){
        if(setToShow >= 0 && setToShow < 2){
            let allAnnotations = Location.mapViewer.annotations
            Location.mapViewer.removeAnnotations(allAnnotations)
            self.setNeedsDisplay()
            setToShow += 1
        }
    }
    
    @objc func buttonClickedPrev(){
        if(setToShow > 0 && setToShow <= 2){
            let allAnnotations = Location.mapViewer.annotations
            Location.mapViewer.removeAnnotations(allAnnotations)
            self.setNeedsDisplay()
            setToShow -= 1
        }
    }
    
    func createButtons(){
        let buttonNext = UIButton()
        buttonNext.setTitle(">>", for: .normal)
        buttonNext.backgroundColor = .gray
        buttonNext.addTarget(self, action:#selector(self.buttonClickedNext), for: .touchUpInside)
        addSubview(buttonNext)
        buttonNext.frame = CGRect(x: 350, y: 500, width: 40, height: 70)
        
        let buttonPrev = UIButton()
        buttonPrev.setTitle("<<", for: .normal)
        buttonPrev.backgroundColor = .gray
        buttonPrev.addTarget(self, action:#selector(self.buttonClickedPrev), for: .touchUpInside)
        addSubview(buttonPrev)
        buttonPrev.frame = CGRect(x: 0, y: 500, width: 40, height: 70)

    }
    
    /**
        Returns subtrees for the restaurants in one cluster
     */
    func drawSet(restaurantSet: [ViewController.Restaurant]) -> [( Array<ViewController.Restaurant> , [UIBezierPath])]{
        var subtree = [( Array<ViewController.Restaurant>() , [UIBezierPath()])]
        var clusteredRestaurants = restaurantSet
        let firstRestaurant = clusteredRestaurants[0]
        clusteredRestaurants.removeFirst()
        
        if(restaurantSet.count == 1){
            let pathHori = getHorizPath(restaurant: firstRestaurant)
            let pathVerti =  getVertiPath(restaurant: firstRestaurant)
            subtree.append(([restaurantSet[0]],[pathHori,pathVerti]))
        }else{
            let pathHori = getHorizPath(restaurant: firstRestaurant)
            let pathVerti =  getVertiPath(restaurant: firstRestaurant)
            subtree.append(([restaurantSet[0]],[pathHori,pathVerti]))
            
            for singleRestaurant in clusteredRestaurants {
            let newPathVerti = UIBezierPath()
            let restLoc = CGPoint(x: singleRestaurant.x, y:singleRestaurant.y )
            newPathVerti.move(to: restLoc)
            let restCon = CGPoint(x: singleRestaurant.x, y:firstRestaurant.y )
            newPathVerti.addLine(to: restCon)
                if(pathHori == getHorizPath(restaurant: firstRestaurant)){
                subtree.append(([singleRestaurant],[newPathVerti]))
                }else{
                subtree.append(([singleRestaurant],[pathHori,newPathVerti]))
                }
            }
        }
        return subtree
    }
    
    
    /**
     Returns a tree as an array with subarrays of greedy clustered restaurants,with their paths, where the restaurant with the greatest distance to the filter label will have the others in his cluster connected to his horizontal path
     */
    func makeTrees(filteredGroups: [[ViewController.Restaurant]])-> [[( Array<ViewController.Restaurant> , [UIBezierPath])]]{
        
        var tree = [[( Array<ViewController.Restaurant>() , [UIBezierPath()])]]
        let restaurantSet = filteredGroups[0]
        var scan = restaurantSet
        var cg = CGPoint()
        var clusters = [ViewController.Restaurant]() // will contain restauant that are close enough for connection on one branch of the tree
        
        // saving the coordinates for the restaurants filter, so we can check the
        // distance for the tree creation later
        if(scan.count > 0){
            let restaurant = scan[0]
            if(restaurant.cuisine.contains("italian")){
                cg = CGPoint(x: italianFilterXYPort.x, y: italianFilterXYPort.y)
            
            }else if(restaurant.cuisine.contains("asian")){
                cg = CGPoint(x: asiaFilterXYPort.x, y: asiaFilterXYPort.y)
              
            }else if(restaurant.cuisine.contains("mexican")){
                cg = CGPoint(x: mexicanFilterXYPort.x, y: mexicanFilterXYPort.y)
           
            }
        }
    
        
        for _ in 0...scan.count {
            
            if(!scan.isEmpty){
            let oneRestaurant = scan[0]
            clusters.append(oneRestaurant)
            scan.removeFirst()
            
                for secondRestaurant in scan{ //range for restaurants in a cluster
                //london
//                if( pow(oneRestaurant.x - secondRestaurant.x,2)<pow(oneRestaurant.x-cg.x,2) && pow(oneRestaurant.y - secondRestaurant.y,2)<pow(20,2)){
//                    clusters.append(secondRestaurant)
//                }
                //kn
                if( pow(oneRestaurant.x - secondRestaurant.x,2)<pow(oneRestaurant.x-cg.x,2) && pow(oneRestaurant.y - secondRestaurant.y,2)<pow(90,2)){
                    clusters.append(secondRestaurant)
                }
                }
                
                //sort to get  furthest leaf to make others connect to its path segments
            let sortedForXRestaurants = clusters.sorted{ pow($0.x-cg.x,2) > pow($1.x-cg.x,2) }
                    
            tree.append(drawSet(restaurantSet: sortedForXRestaurants))
                
                //remove already included restaurants from further calculations
                    for element in clusters{
                        scan = scan.filter{ $0.x != element.x}
                    }
            
            clusters.removeAll()
            }
        }
        
                return tree
    }
    
    
    
    /**
     Returns the horizontal path for the input restaurant
     */
    func getHorizPath(restaurant: ViewController.Restaurant) -> UIBezierPath{
        let pathHori = UIBezierPath()

        //checks to what filter the line has to connect
        pathHori.move(to: CGPoint(x: restaurant.x, y: restaurant.y))
        if(restaurant.cuisine.contains("italian")){
            pathHori.addLine(to: CGPoint(x: italianFilterXYPort.x, y: restaurant.y))
        }else if(restaurant.cuisine.contains("asian")){
            pathHori.addLine(to: CGPoint(x: asiaFilterXYPort.x, y: restaurant.y))
        }else if(restaurant.cuisine.contains("mexican")){
            pathHori.addLine(to: CGPoint(x: mexicanFilterXYPort.x, y: restaurant.y))
        }

        return pathHori

    }
    
    /**
     Returns the vertical path for the input restaurant
     */
    func getVertiPath(restaurant: ViewController.Restaurant)-> UIBezierPath{
        let pathVerti = UIBezierPath()

        //checks to what filter the line has to connect
        if(restaurant.cuisine.contains("italian")){
            pathVerti.move(to: CGPoint(x: italianFilterXYPort.x, y: restaurant.y))
            pathVerti.addLine(to: italianFilterXYPort)
        }else if(restaurant.cuisine.contains("asian")){
            pathVerti.move(to: CGPoint(x: asiaFilterXYPort.x, y: restaurant.y))
            pathVerti.addLine(to: asiaFilterXYPort)
        }else if(restaurant.cuisine.contains("mexican")){
            pathVerti.move(to: CGPoint(x: mexicanFilterXYPort.x, y: restaurant.y))
            pathVerti.addLine(to: mexicanFilterXYPort)
        }

        return pathVerti
    }


    /**
     Returns false if lines do not cross else true
     */
    func linesCross (segment1 : [CGPoint], segment2: [CGPoint]) -> Bool {
        // calculate the differences between the start and end X/Y positions for each of our points
        let start1 = segment1[0]
        let end1 = segment1[1]
        let start2 = segment2[0]
        let end2 = segment2[1]
        
        let delta1x = end1.x - start1.x
        let delta1y = end1.y - start1.y
        let delta2x = end2.x - start2.x
        let delta2y = end2.y - start2.y

        // create a 2D matrix from our vectors and calculate the determinant
        let determinant = delta1x * delta2y - delta2x * delta1y

        if abs(determinant) < 0.0001 {
            // if the determinant is effectively zero then the lines are parallel/colinear
            return false
        }

        // if the coefficients both lie between 0 and 1 then we have an intersection
        let ab = ((start1.y - start2.y) * delta2x - (start1.x - start2.x) * delta2y) / determinant

        if ab > 0 && ab < 1 {
            let cd = ((start1.y - start2.y) * delta1x - (start1.x - start2.x) * delta1y) / determinant

            if cd > 0 && cd < 1 {
                return true
            }
        }
        // lines don't cross
        return false
    }
}
    


extension CGPath {
    func points() -> [CGPoint]
    {
        var bezierPoints = [CGPoint]()
        forEach(body: { (element: CGPathElement) in
            let numberOfPoints: Int = {
                switch element.type {
                case .moveToPoint, .addLineToPoint: // contains 1 point
                    return 1
                case .addQuadCurveToPoint: // contains 2 points
                    return 2
                case .addCurveToPoint: // contains 3 points
                    return 3
                case .closeSubpath:
                    return 0
                }
            }()
            for index in 0..<numberOfPoints {
                let point = element.points[index]
                bezierPoints.append(point)
            }
        })
        return bezierPoints
    }
    
    func forEach(body: @escaping @convention(block) (CGPathElement) -> Void) {
        typealias Body = @convention(block) (CGPathElement) -> Void
        
        func callback(info: UnsafeMutableRawPointer?, element: UnsafePointer<CGPathElement>) {
            let body = unsafeBitCast(info, to: Body.self)
            body(element.pointee)
        }
        
        let unsafeBody = unsafeBitCast(body, to: UnsafeMutableRawPointer.self)
        apply(info: unsafeBody, function: callback)
    }
}

