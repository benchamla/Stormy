//
//  ViewController.swift
//  Stormy
//
//  Created by ben on 19/11/2014.
//  Copyright (c) 2014 Ben Chamla. All rights reserved.
//

import UIKit
import Foundation

class ViewController: UIViewController {

    @IBOutlet weak var iconView: UIImageView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var humidityLabel: UILabel!
    @IBOutlet weak var rainLabel: UILabel!
    @IBOutlet weak var summaryLabel: UILabel!
    @IBOutlet weak var refreshButton: UIButton!
    @IBOutlet weak var refreshActivityIndictor: UIActivityIndicatorView!
    
    private let apiKey = "1dc195d852e4217c5e103af54b30bc34"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        refreshActivityIndictor.hidden = true
        getCurrentWeatherData()
        
    }

    func getCurrentWeatherData() -> Void {
        
        let baseURL = NSURL(string: "https://api.forecast.io/forecast/\(apiKey)/")
        let forecastURL = NSURL(string: "37.8267,-122.423", relativeToURL: baseURL)
        
        
        
        
        let sharedSession = NSURLSession.sharedSession()
        let downloadTask: NSURLSessionDownloadTask = sharedSession.downloadTaskWithURL(forecastURL!, completionHandler: { (location: NSURL!, response: NSURLResponse!, error: NSError!) -> Void in
            
            if (error == nil) {
                let dataObject = NSData(contentsOfURL: location)
                let weatherDictionary: NSDictionary = NSJSONSerialization.JSONObjectWithData(dataObject!, options: nil, error: nil) as NSDictionary
                
                let currentWeather = Current(weatherDictionary: weatherDictionary)
                
                
                func faraToCelcius(fara: Double) -> Double
                {
                    return (fara - 32.0)/1.8
                }
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.temperatureLabel.text = NSString(format: "%.01f", faraToCelcius(currentWeather.temperature))
                    self.iconView.image = currentWeather.icon!
                    self.timeLabel.text = "At \(currentWeather.currentTime!) it is:"
                    self.humidityLabel.text = "\(currentWeather.humidity)"
                    self.rainLabel.text = "\(currentWeather.precipProbability)"
                    self.summaryLabel.text = "\(currentWeather.summary)"
                    //Stop refresh animation
                    self.refreshActivityIndictor.stopAnimating()
                    self.refreshActivityIndictor.hidden = true
                    self.refreshButton.hidden = false
                    
                })
                
            }else {
                let networkIssueController = UIAlertController(title: "Error!", message: "Unable to load data. YourConnectivity sucks", preferredStyle: .Alert)
                self.presentViewController(networkIssueController, animated: true, completion: nil)
                let okButton = UIAlertAction(title: "OK", style: .Default, handler: nil)
                networkIssueController.addAction(okButton)
                
                let cancelButton = UIAlertAction(title: "Cancel", style: .Default, handler: nil)
                networkIssueController.addAction(cancelButton)
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    //Stop refresh animation
                    self.refreshActivityIndictor.stopAnimating()
                    self.refreshActivityIndictor.hidden = true
                    self.refreshButton.hidden = false
                })
                

            }
            
        })
        
        downloadTask.resume()
    }

    
    @IBAction func refresh() {
        refreshButton.hidden = true
        refreshActivityIndictor.hidden = false
        getCurrentWeatherData()
    }
    
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

