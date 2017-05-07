//
//  ViewController.swift
//  Monge
//
//  Created by 고준용 on 2017. 4. 23..
//  Copyright © 2017년 고준용. All rights reserved.
//

import UIKit
import CoreLocation
import Foundation
import Kanna

class ViewController: UIViewController, CLLocationManagerDelegate {
    @IBOutlet weak var adress: UILabel!
    @IBOutlet weak var information: UILabel!
    @IBOutlet weak var monge: UILabel!
    @IBOutlet weak var location: UILabel!
    @IBOutlet var background: UIView!
    @IBOutlet weak var iconImage: UIImageView!
    @IBOutlet weak var refreshButton: UIButton!
    
    var locationManager:CLLocationManager = CLLocationManager()
    var startLocation: CLLocation!
    
    var array = [String]()
    var cityNames = [String]()
    var monges = [Int]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.\
        
        let apiURI = NSURL(string: "https://search.naver.com/search.naver?where=nexearch&sm=top_hty&fbm=1&ie=utf8&query=%EB%AF%B8%EC%84%B8%EB%A8%BC%EC%A7%80")
        let apidata : Data? = try! Data(contentsOf: apiURI! as URL)
        var i = 0
        array.removeAll()
        cityNames.removeAll()
        monges.removeAll()
        if let doc = Kanna.HTML(html: apidata!, encoding: String.Encoding.utf8) {
            for link in doc.xpath("//div[@class='dust_data']/div[@class='tb_scroll']/table/tbody/tr") {
                array.append(link.text!)
                var listMonge = array[i].components(separatedBy: " ")
                cityNames.append(listMonge[1])
                let convertedString: Int = Int(((listMonge[2]) as NSString).intValue)
                monges.append(convertedString)
                i += 1
            }
        }
    
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
        startLocation = nil
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let latestLocation: AnyObject = locations[locations.count - 1]
        
        convertToAdressWith(coordinate: latestLocation as! CLLocation)
        
        if startLocation == nil {
            startLocation = latestLocation as! CLLocation
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
    }
    
    func convertToAdressWith(coordinate: CLLocation) {
        let geoCoder = CLGeocoder()
        geoCoder.reverseGeocodeLocation(coordinate) { (placemarks, error) -> Void in
            if error != nil {
                return
            }
            
            guard let placemark = placemarks?.first,
                let addList = placemark.addressDictionary?["FormattedAddressLines"] as? [String] else {
                    return
            }
            
            let adrress = addList.joined(separator: " ")
            
            var adrressArr = adrress.components(separatedBy: " ")
            adrressArr[1] = self.findUserLocation(s: adrressArr[1])
            
            for i in 0..<17 {
                if(adrressArr[1] == self.cityNames[i]) {
                    self.monge.text = self.monges[i].description
                    self.location.text = self.cityNames[i]
                    
                    
                    if (self.monges[i] >= 0 && self.monges[i] <= 30) {
                        self.adress.text = "좋음"
                        self.information.text = "아주 좋아요!\n안심하고 외출할 수 있겠어요."
                        self.view.backgroundColor = UIColor(red: 92/255 , green: 169/255, blue: 254/255, alpha: 1)
                        self.iconImage.image = UIImage(named: "good.png")
                        self.refreshButton.tintColor = UIColor(red: 92/255 , green: 169/255, blue: 254/255, alpha: 1)
                    } else if (self.monges[i] > 30 && self.monges[i] <= 80) {
                        self.adress.text = "보통"
                        self.information.text = "적당해요!"
                        self.view.backgroundColor = UIColor(red: 108/255 , green: 190/255, blue: 100/255, alpha: 1)
                        self.iconImage.image = UIImage(named: "main2.png")
                        self.refreshButton.tintColor = UIColor(red: 108/255 , green: 190/255, blue: 100/255, alpha: 1)
                    } else if (self.monges[i] > 80 && self.monges[i] <= 150) {
                        self.adress.text = "안좋음"
                        self.information.text = "조금 좋지 않아요ㅠㅠ"
                        self.view.backgroundColor = UIColor(red: 254/255 , green: 209/255, blue: 78/255, alpha: 1)
                        self.iconImage.image = UIImage(named: "bad.png")
                        self.refreshButton.tintColor = UIColor(red: 254/255 , green: 209/255, blue: 78/255, alpha: 1)
                    } else {
                        self.adress.text = "매우나쁨"
                        self.information.text = "오늘은 집에서 쉬는게 좋겠어요."
                        self.view.backgroundColor = UIColor(red: 187/255 , green: 133/255, blue: 17/255, alpha: 1)
                        self.iconImage.image = UIImage(named: "veryBad.png")
                        self.refreshButton.tintColor = UIColor(red: 187/255 , green: 133/255, blue: 17/255, alpha: 1)
                    }
                }
            }
        }
    }
    
    func UIColorFromRGB(rgbValue: UInt) -> UIColor {
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
    func findUserLocation(s: String) -> String {
        var userLocation = ""
        if (s == "서울특별시") {
            userLocation = "서울"
        } else if(s == "부산광역시") {
            userLocation = "부산"
        } else if(s == "대구광역시") {
            userLocation = "대구"
        } else if(s == "인천광역시") {
            userLocation = "인천"
        } else if(s == "광주광역시") {
            userLocation = "광주"
        } else if(s == "대전광역시") {
            userLocation = "대전"
        } else if(s == "울산광역시") {
            userLocation = "울산"
        } else if(s == "경기도") {
            userLocation = "경기"
        } else if(s == "강원도") {
            userLocation = "강원"
        } else if(s == "충청북도") {
            userLocation = "충북"
        } else if(s == "충청남도") {
            userLocation = "충남"
        } else if(s == "전라북도") {
            userLocation = "전북"
        } else if(s == "전라남도") {
            userLocation = "전남"
        } else if(s == "경상북도") {
            userLocation = "경북"
        } else if(s == "경상남도") {
            userLocation = "경남"
        } else if(s == "제주도") {
            userLocation = "제주"
        } else if(s == "세종특별자치시") {
            userLocation = "세종"
        }
        
        return userLocation
    }
    
    @IBAction func refresh(_ sender: UIButton) {
        viewDidLoad()
    }
    
    
}
