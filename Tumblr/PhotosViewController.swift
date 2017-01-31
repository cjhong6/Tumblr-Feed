//
//  PhotosViewController.swift
//  Tumblr
//
//  Created by Chengjiu Hong on 1/30/17.
//  Copyright © 2017 Chengjiu Hong. All rights reserved.
//

import UIKit
import  AFNetworking

class PhotosViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    var posts:[NSDictionary] = []
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.rowHeight = 240
        let url = URL(string:"https://api.tumblr.com/v2/blog/greentype.tumblr.com/posts/photo?api_key=Q6vHoaVm5L1u2ZAW1fqv3Jw48gFzYVg9P0vH0VHl3GVy6quoGV")
        let request = URLRequest(url: url!)
        let session = URLSession(
            configuration: URLSessionConfiguration.default,
            delegate:nil,
            delegateQueue:OperationQueue.main
        )
        
        let task : URLSessionDataTask = session.dataTask(
            with: request as URLRequest,
            completionHandler: { (data, response, error) in
                if let data = data {
                    if let responseDictionary = try! JSONSerialization.jsonObject(
                        with: data, options:[]) as? NSDictionary {
                        //responseDictionary returns a NSDictionary
                        //print("responseDictionary: \(responseDictionary)")
                        let responseFieldDictionary = responseDictionary["response"] as! NSDictionary
                        //responseFieldDictionary returns a NSDictionary
                        //print("responseFieldDictionary: \(responseFieldDictionary)")
                        self.posts = responseFieldDictionary["posts"] as! [NSDictionary]
                        //posts returns an array of NSDictionary
                        //print("post: \(self.posts)")
                        self.tableView.reloadData()
                    }
                }
        });
        task.resume()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return posts.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCell(withIdentifier: "PhotoCell") as! PhotoTableViewCell
        let post = posts[indexPath.row]
        
        if let photos = post["photos"] as? [NSDictionary]{
            //photos returns a array of dictionary
            //Use valueForKeyPath to navigate through multiple nested dictionary keys
            //First element means get the dictionary from the [NSDictionary]
            let imageUrlString = photos[0].value(forKeyPath: "original_size.url") as? String
            if let imageUrl = URL(string: imageUrlString!) {
                cell.postImage.setImageWith(imageUrl)
            } else {
                print("the image is nil")
            }
        } else {
            print("the photo is null")
        }
        return cell
    }

    

}
