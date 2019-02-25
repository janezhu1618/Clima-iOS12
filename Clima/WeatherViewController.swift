//
//  ViewController.swift
//  WeatherApp
//
//  Created by Angela Yu on 23/08/2015.
//  Copyright (c) 2015 London App Brewery. All rights reserved.
//

import UIKit
import CoreLocation
import Alamofire
import SwiftyJSON

class WeatherViewController: UIViewController {
    
    //Constants
    private let WEATHER_URL = "http://api.openweathermap.org/data/2.5/weather"
    private let APP_ID = "f56a8905e633c24251b044b6af51d48a"

    //TODO: Declare instance variables here
    private let locationManager = CLLocationManager()
    private let weatherDataModel = WeatherDataModel()
    
    //Pre-linked IBOutlets
    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    
    
    //MARK: - Networking
    private func getWeatherData(url: String, parameters: [String : String]) {
        Alamofire.request(url, method: .get, parameters: parameters).responseJSON { (response) in
            if response.result.isSuccess {
                let weatherJSON : JSON = JSON(response.result.value!)
                self.updateWeatherData(json: weatherJSON)
            } else {
                print("Error - \(String(describing: response.result.error))")
                self.cityLabel.text = "Connection Issues"
            }
        }
    }

    private func updateWeatherData(json: JSON) {
        //check jsononlineeditor.org
        if let tempResult = json["main"]["temp"].double {
        weatherDataModel.temperature = Int(tempResult)
        weatherDataModel.city = json["name"].stringValue
        weatherDataModel.condition = json["weather"][0]["id"].intValue
        weatherDataModel.weatherIconName = weatherDataModel.updateWeatherIcon(condition: weatherDataModel.condition)
            updateUIWithWeatherData()
        } else {
            cityLabel.text = "Weather Unavailable"
        }
    }

    
    private func updateUIWithWeatherData() {
        cityLabel.text = weatherDataModel.city
        temperatureLabel.text = "\(weatherDataModel.temperature.description)°"
        weatherIcon.image = UIImage(named: weatherDataModel.weatherIconName)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "changeCityName" {
            let destinationVC = segue.destination as! ChangeCityViewController
            destinationVC.delegate = self
        }
    }
    
    
    
    
}


extension WeatherViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let lastLocation = locations.last {
            if lastLocation.horizontalAccuracy > 0 {
                locationManager.stopUpdatingLocation()
                locationManager.delegate = nil
                let latitude = String(lastLocation.coordinate.latitude)
                let longitude = String(lastLocation.coordinate.longitude)
                let params: [String : String] = ["lat" : latitude, "lon" : longitude, "appid" : APP_ID, "units" : "imperial" ]
                getWeatherData(url: WEATHER_URL, parameters: params)
            }
        }
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
        cityLabel.text = "Location Unavailable"
    }
}

extension WeatherViewController: ChangeCityViewControllerDelegate {
    func userEnteredANewCityName(city: String) {
        //q for query
        let params: [String : String] = ["q" : city, "appid" : APP_ID,  "units" : "imperial" ]
        getWeatherData(url: WEATHER_URL, parameters: params)
    }
}
