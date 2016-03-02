//
//  DetailViewController.swift
//  maps
//
//  Created by Preksha Koirala on 3/1/16.
//  Copyright © 2016 Preksha Koirala. All rights reserved.import



import UIKit

class DetailViewController: UIViewController{
    
   
    @IBOutlet weak var titleView: UITextView!
    
    @IBOutlet weak var subtitleView: UITextView!
    
    @IBOutlet weak var locationcoordView: UITextView!
    
    @IBOutlet weak var placeIdView: UITextView!
    
    
    
@IBOutlet weak var Button: UIButton!
    
    var detaillocation = mapLocation()
    
    
    
    
    
    @IBAction func actionButton(sender: AnyObject) {
        
        
        titleView.text = detaillocation.title
        subtitleView.text = String(detaillocation.coordinate.latitude) + " " + String(detaillocation.coordinate.longitude)
        locationcoordView.text = String(detaillocation.coordinate.latitude) + " " + String(detaillocation.coordinate.longitude)
        placeIdView.text = detaillocation.placeId
        print (detaillocation.title)
        titleView.text = "hi"
        titleView.text = detaillocation.title
        
        
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
}