/*
 * Copyright 2016 Google Inc. All rights reserved.
 *
 *
 * Licensed under the Apache License, Version 2.0 (the "License"); you may not use this
 * file except in compliance with the License. You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software distributed under
 * the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF
 * ANY KIND, either express or implied. See the License for the specific language governing
 * permissions and limitations under the License.
 */

import UIKit
import GoogleMaps

var zips = [String]()
var names = [String]()
var addresses = [String]()
var latLonArray = [[Float]]()

let baseUrl = "https://maps.googleapis.com/maps/api/geocode/json?"
let apiKey = "AIzaSyBD0okR4w38IFff-thF-MisTxhK408NoXY"


class ViewController: UIViewController {
    
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

  override func loadView() {

    // Create a GMSCameraPosition that tells the map to display the
    // coordinate of the first facility at zoom 10.
    let camera = GMSCameraPosition.camera(withLatitude: 43.739935, longitude: -79.583983, zoom: 10.0)
    let mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
    
    //set map style
    do {
        // Set the map style by passing the URL of the local file.
        if let styleURL = Bundle.main.url(forResource: "style", withExtension: "json") {
            mapView.mapStyle = try GMSMapStyle(contentsOfFileURL: styleURL)
        } else {
            NSLog("Unable to find style.json")
        }
    } catch {
        NSLog("One or more of the map styles failed to load. \(error)")
    }
    
    self.view = mapView
    
    do {
        if let file = Bundle.main.url(forResource: "subset", withExtension: "json") {
            let data = try Data(contentsOf: file)
            let json = try JSONSerialization.jsonObject(with: data, options: [])
            if let object = json as? [String: Any] {
                // json is a dictionary
                print(object)
            } else if let object = json as? [Any] {
                // json is an array
                
                for o in object {
                    if let dict = o as? NSDictionary{
                        if let address = dict.value(forKey: "Full Address"){
                            
                            addresses.append(address as! String)
                            
                            if let name = dict.value(forKey: "FACILITY NAME"){
                                print("Name: \(name)") //testing
                                names.append(name as! String)
                                
                                if let zip = dict.value(forKey: "Postal Code"){
                                    print ("Zip: \(zip)") //testing
                                    zips.append(zip as! String)
                                    var zipC = ""
                                    let z = zip as! String
                                    zipC.append(z[z.index(after: z.startIndex)])
                                    zipC.append(z[z.index(z.startIndex, offsetBy: 4)])
                                    zipC.append(z[z.index(z.startIndex, offsetBy: 6)])
                                    zipC.append("00")
                                    getLatLngForZip(zipCode: zipC)
                                    print(latLonArray)
                                    
                                }
                            }
                        }
                    
                    }
                    
                }
            } else {
                print("JSON is invalid")
            }
        } else {
            print("no file")
        }
    } catch {
        print(error.localizedDescription)
    }
    
    for (index, latLon) in latLonArray.enumerated(){
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: CLLocationDegrees(latLon[0]), longitude: CLLocationDegrees(latLon[1]))
        marker.title = names[index]
        marker.map = mapView
    }
    
    }
    func getLatLngForZip(zipCode: String) {
        
        let url = NSURL(string: "\(baseUrl)address=\(zipCode)&key=\(apiKey)")
        let data = NSData(contentsOf: url! as URL)
        let json = try! JSONSerialization.jsonObject(with: data! as Data, options: JSONSerialization.ReadingOptions.allowFragments) as! [String: Any]
        if let result = json["results"] as? [[String:Any]] {
           
            if let geometry = result[0]["geometry"] as? [String: Any] {
                if let location = geometry["location"] as? [String:Any] {
                    let latitude = location["lat"] as! Float
                    let longitude = location["lng"] as! Float
                    let pair : [Float] = [latitude, longitude]
                    latLonArray.append(pair)
                }
            }
        }
        
    }

}

