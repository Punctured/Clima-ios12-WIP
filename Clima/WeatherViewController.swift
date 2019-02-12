//
//  ViewController.swift
//  WeatherApp
//
//  Created by Jeff Kim on 07/02/2019.
//  Copyright (c) 2015 London App Brewery. All rights reserved.
//  test

import UIKit
import CoreLocation
import Alamofire
import SwiftyJSON

class WeatherViewController: UIViewController, CLLocationManagerDelegate, ChangeCityDelegate {
    
    //Constants
    let WEATHER_URL = "https://api.openweathermap.org/data/2.5/weather"
    let APP_ID = "0a497e24a398e9207931b048835f5cc1"
   
    //switch to toggle fahrenheit & celsius mode
    @IBAction func `switch`(_ sender: UISwitch) {
        //separate variables for later use. Why is it finicky? no idea
        let celsiusTemp = weatherDataModel.temperature
        let fahrenheitTemp = temperatureInFahrenheit(temperature: weatherDataModel.temperature)
        //if the switch is on (turning off), change to fahrenheit mode.
        if sender.isOn {
                temperatureLabel.text = "\(fahrenheitTemp)°"
                print("label says \(fahrenheitTemp)")
                print("internal value is \(weatherDataModel.temperature) C")
        }
        //if the switch is off (turning on), change to celsius mode.
        else if sender.isOn == false {
                temperatureLabel.text = "\(celsiusTemp)°"
                print("internal value is \(celsiusTemp) C")
                print("label says \(celsiusTemp)")
        }
    }
    
    //Declare instance variables here
    let locationManager = CLLocationManager()
    let weatherDataModel = WeatherDataModel()
 
    
    
    //Pre-linked IBOutlets
    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var faren: UISwitch!


    @IBOutlet weak var button: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        //Set up the location manager here.
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
    }

    
    //method for converting celsius to fahrenheit.
    func temperatureInFahrenheit(temperature: Int) -> Int {
        let fahrenheitTemperature = temperature * 9 / 5 + 32
        return fahrenheitTemperature
    }
    
    
    //MARK: - Networking
    //Write the getWeatherData method here:

    func getWeatherData(url: String, parameters: [String: String]) {
        
        AF.request(url, method: .get, parameters: parameters).responseJSON {
            response in
            if response.result.isSuccess {
                
                print("Success! Got the weather data")
                let weatherJSON : JSON = JSON(response.result.value!)
            
                print(weatherJSON)
                
                self.updateWeatherData(json: weatherJSON)
                
            }
            else {
                print("Error \(String(describing: response.result.error))")
                self.cityLabel.text = "Connection Issues"
            }
        }
        
    }
    
    
    //MARK: - JSON Parsing
    /***************************************************************/
    
    //Write the updateWeatherData method here:
    
    func updateWeatherData(json : JSON) {
    
        let tempResult = json["main"]["temp"].doubleValue
        
        //if the switch is on, calculate the temperature assuming celsius mode.
        if faren.isOn == true {
            weatherDataModel.temperature = Int(tempResult - 273.15)
            temperatureLabel.text = "\(weatherDataModel.temperature)"
            print("label says \(weatherDataModel.temperature)")
            print("internal value is \(weatherDataModel.temperature) C")
        } else {
            //otherwise, convert to fahrenheit first before updating the label.
            weatherDataModel.temperature = Int(tempResult - 273.15)
        let fahrenheitTemp = temperatureInFahrenheit(temperature: weatherDataModel.temperature)
        temperatureLabel.text = "\(fahrenheitTemp)"
            print("label says \(fahrenheitTemp)")
            print("internal value is \(weatherDataModel.temperature) C")
        }
            weatherDataModel.city = json["name"].stringValue
            weatherDataModel.condition = json["weather"][0]["id"].intValue
            weatherDataModel.weatherIconName = weatherDataModel.updateWeatherIcon(condition: weatherDataModel.condition)
            updateUIWithWeatherData()
        }
    
    //MARK: - UI Updates
    /***************************************************************/
    
    
    //Write the updateUIWithWeatherData method here:
    
    func updateUIWithWeatherData() {
        cityLabel.text = weatherDataModel.city
        //temporarily commented out updating label
       // temperatureLabel.text = "\(weatherDataModel.temperature)"
        weatherIcon.image = UIImage(named: weatherDataModel.weatherIconName)
    }
    
    
    //MARK: - Location Manager Delegate Methods
    /***************************************************************/
    
    //Write the didUpdateLocations method here:
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[locations.count - 1]
        if location.horizontalAccuracy > 0 {
            self.locationManager.stopUpdatingLocation()
            print("longitude = \(location.coordinate.longitude), latitude = \(location.coordinate.latitude)")
            let latitude = String(location.coordinate.latitude)
            let longitude = String(location.coordinate.longitude)
            let params : [String : String] = ["lat" : latitude, "lon" : longitude, "appid" : APP_ID]
            getWeatherData(url: WEATHER_URL, parameters: params)
        }
    }
    
    //Write the didFailWithError method here:
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
        cityLabel.text = "Location Unavailable"
    }
    
    //MARK: - Change City Delegate methods
    /***************************************************************/
    
    //Write the userEnteredANewCityName Delegate method here:
    
    func userEnteredANewCityName(city: String) {
        let params : [String : String] = ["q" : city, "appid" : APP_ID]
        getWeatherData(url: WEATHER_URL, parameters: params)
    }
    
    //Write the PrepareForSegue Method here
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "changeCityName" {
            //calls the change city menu up
            let destinationVC = segue.destination as! ChangeCityViewController
            destinationVC.delegate = self
        }
    }
}











