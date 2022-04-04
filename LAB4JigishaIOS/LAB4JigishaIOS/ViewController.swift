//
//  ViewController.swift
//  LAB4JigishaIOS
//
//  Created by jigisha Padhiyar on 2022-04-01.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, UITextFieldDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var ImgView: UIImageView!
    @IBOutlet weak var TempLabel: UILabel!
    @IBOutlet weak var LocationLabel: UILabel!
    @IBOutlet weak var SearchTF: UITextField!
    @IBOutlet weak var Conitionlabel: UILabel!
  //  let locationDelegate = MyLocationDelegate()
    override func viewDidLoad() {
        super.viewDidLoad()
        SearchTF.delegate = self
       
        
        locationManager.delegate = self
        
//        let config = UIImage.SymbolConfiguration(paletteColors: [.systemBlue, .systemYellow, .systemTeal])
//        ImgView.preferredSymbolConfiguration = config
//        ImgView.image = UIImage(systemName: "sunrise.fill")
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        print(textField.text ?? "")
        GetWeather(search: textField.text)
        return true
    }
   
    let locationManager = CLLocationManager()
    
    @IBAction func GetCurrent(_ sender: UIButton) {
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
        
    }
    @IBAction func SearchBtn(_ sender: UIButton) {
        SearchTF.endEditing(true)
        GetWeather(search: SearchTF.text)
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("GOT LOCATION")
        
        if let location = locations.last{
            let lattitude = location.coordinate.latitude
            let longitude = location.coordinate.longitude
            print("Lattitude and Lonitude are:\(lattitude),\(longitude)")
            GetWeather(search: "\(lattitude),\(longitude)")
            //print(GetWeather(search: "\(43.6555),\(79.3844)"))
        }
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
    private func GetWeather(search:String?)  {

  
        guard let search = search else {
            return
        }
       //step:1
        let url = getUrl(search: search)
        
        guard let url = url else{
            print("Could not get URL")
            return
        }
        //step2: create urlSession
        let session = URLSession.shared
        //step3: create task for session
        let dataTask = session.dataTask(with:url) { data, response, error in
            print ("Network call complete")
            
            guard error == nil else{
                print("received  error")
                return
            }
            guard let data = data else {
                print("No data found")
                return
            }
            
            if let weather = self.parseJson(data: data){
                print(weather.location.name)
                print(weather.current.temp_c)
                
                DispatchQueue.main.async {
                    self.TempLabel.text = "\(weather.current.temp_c)C"
                    self.LocationLabel.text = "\(weather.location.name)"
                    
                    if (weather.current.condition.code) == 1000 {
                        self.ImgView.image = UIImage(systemName: "sun.max.fill")
                        self.Conitionlabel.text = "\(weather.current.condition.text)"
                        
                      
                    }else if (weather.current.condition.code) == 1003  {
                        self.ImgView.image = UIImage(systemName: "cloud.sun")
                        self.Conitionlabel.text = "\(weather.current.condition.text)"
                    }else if (weather.current.condition.code) == 1006  {
                        self.ImgView.image = UIImage(systemName: "cloud.fill")
                        self.Conitionlabel.text = "\(weather.current.condition.text)"
                    }else if (weather.current.condition.code) == 1009  {
                        self.ImgView.image = UIImage(systemName: "sunset.fill")
                        self.Conitionlabel.text = "\(weather.current.condition.text)"
                    }else if (weather.current.condition.code) == 1135  {
                        self.ImgView.image = UIImage(systemName: "cloud.fog")
                        self.Conitionlabel.text = "\(weather.current.condition.text)"
                    }else if (weather.current.condition.code) == 1183 {
                        self.ImgView.image = UIImage(systemName: "cloud.rain")
                        self.Conitionlabel.text = "\(weather.current.condition.text)"
                    }
                    
                    
                }
                
            }
            
        
        }
        
        //step4: Start the task
        dataTask.resume()
    }
    
    private func parseJson(data: Data)-> WeatherResponse?{
        let decoder = JSONDecoder()
        var weatherResponse: WeatherResponse?
        
        do{
            weatherResponse = try decoder.decode(WeatherResponse.self, from: data)
        }catch{
            print("Error parsing weather")
            print(error)
        }
        
        return weatherResponse
        
    }
  
    private func getUrl(search: String) -> URL? {
        
        let baseUrl = "https://api.weatherapi.com/v1/"
        let currentEndPoint = "current.json"
        let apiKey =  "5bab98457a70408aa09231109220104"
       // let query = "q=London"
        let url = "\(baseUrl)\(currentEndPoint)?key=\(apiKey)&q=\(search)"
        return URL(string:url)
        
    }
}

struct WeatherResponse: Decodable {
    let location: Location
    let current: Weather
}

struct Location: Decodable{
    let name: String
    let lat: Float
    let lon: Float
}

struct Weather: Decodable{
    let temp_c:Float
    let condition:WeatherCondition
    
}
struct WeatherCondition: Decodable{
    let text: String
    let code:Int
}

//class MyLocationDelegate: NSObject, CLLocationManagerDelegate{
//    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        print("GOT LOCATION")
//
//        if let location = locations.last{
//            let lattitude = location.coordinate.latitude
//            let longitude = location.coordinate.longitude
//            print("Lattitude and Lonitude are:\(lattitude), \(longitude)")
//           // self.displayLocation("((),())")
//        }
//    }
//    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
//        print(error)
//    }
    
//}

    /**
     {
         "location": {
             "name": "London",
             "region": "City of London, Greater London",
             "country": "United Kingdom",
             "lat": 51.52,
             "lon": -0.11,
             "tz_id": "Europe/London",
             "localtime_epoch": 1648855404,
             "localtime": "2022-04-02 0:23"
         },
         "current": {
             "last_updated_epoch": 1648850400,
             "last_updated": "2022-04-01 23:00",
             "temp_c": 2.0,
             "temp_f": 35.6,
             "is_day": 0,
             "condition": {
                 "text": "Clear",
                 "icon": "//cdn.weatherapi.com/weather/64x64/night/113.png",
                 "code": 1000
             },
             "wind_mph": 3.8,
             "wind_kph": 6.1,
             "wind_degree": 350,
             "wind_dir": "N",
             "pressure_mb": 1021.0,
             "pressure_in": 30.15,
             "precip_mm": 0.0,
             "precip_in": 0.0,
             "humidity": 80,
             "cloud": 0,
             "feelslike_c": -0.7,
             "feelslike_f": 30.8,
             "vis_km": 10.0,
             "vis_miles": 6.0,
             "uv": 1.0,
             "gust_mph": 8.3,
             "gust_kph": 13.3
         }
     }
     **/

