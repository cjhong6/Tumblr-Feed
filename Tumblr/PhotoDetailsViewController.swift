//
//  PhotoDetailsViewController.swift
//  Tumblr
//
//  Created by Chengjiu Hong on 2/8/17.
//  Copyright © 2017 Chengjiu Hong. All rights reserved.
//

import UIKit

class PhotoDetailsViewController: UIViewController {
    var post: NSDictionary!
    @IBOutlet weak var photo: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let photos = post["photos"] as? [NSDictionary]{
            //photos returns a array of dictionary
            //Use valueForKeyPath to navigate through multiple nested dictionary keys
            //First element means get the dictionary from the [NSDictionary]
            let imageUrlString = photos[0].value(forKeyPath: "original_size.url") as? String
            if let imageUrl = URL(string: imageUrlString!) {
                self.photo.setImageWith(imageUrl)
            } else {
                print("the image is nil")
            }
        } else {
            print("the photo is null")
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
