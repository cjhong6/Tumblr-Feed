//
//  PhotosViewController.swift
//  Tumblr
//
//  Created by Chengjiu Hong on 1/30/17.
//  Copyright © 2017 Chengjiu Hong. All rights reserved.
//

import UIKit
import  AFNetworking

class PhotosViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,UIScrollViewDelegate {
    var posts:[NSDictionary] = []
    var refreshControl: UIRefreshControl!
    @IBOutlet weak var tableView: UITableView!
    var isMoreDataLoading = false
    var loadingMoreView:InfiniteScrollActivityView?
    let CellIdentifer = "PhotoCell", HeaderViewIdentifier = "TableViewHeaderView"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initialize a UIRefreshControl
        refreshControl = UIRefreshControl()
        //Bind the action
        refreshControl.addTarget(self, action: #selector(PhotosViewController.refreshControlAction(_:)), for: UIControlEvents.valueChanged)
        // add refresh control to table view
        tableView.insertSubview(refreshControl, at: 0)

        tableView.delegate = self
        tableView.dataSource = self
        
        //tableView.register(UITableViewCell.self, forCellReuseIdentifier: CellIdentifer)
        tableView.register(UITableViewHeaderFooterView.self, forHeaderFooterViewReuseIdentifier: HeaderViewIdentifier)
        
        makeAPICall()
        
        // Set up Infinite Scroll loading indicator
        let frame = CGRect(x: 0, y: tableView.contentSize.height, width: tableView.bounds.size.width, height: InfiniteScrollActivityView.defaultHeight)
        loadingMoreView = InfiniteScrollActivityView(frame: frame)
        loadingMoreView!.isHidden = true
        tableView.addSubview(loadingMoreView!)
        
        var insets = tableView.contentInset
        insets.bottom += InfiniteScrollActivityView.defaultHeight
        tableView.contentInset = insets
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //how many section
    func numberOfSections(in tableView: UITableView) -> Int {
        return posts.count
    }
    
    //how many row in the section
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return 1
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCell(withIdentifier: "PhotoCell") as! PhotoTableViewCell
        let post = posts[indexPath.section]

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
    
    //set the header height
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 45
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    //transit to other view controller1
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let cell = sender as! PhotoTableViewCell
        let indexpath = tableView.indexPath(for: cell)
        let post = posts[(indexpath?.row)!]
        let photoDetailsViewController = segue.destination as! PhotoDetailsViewController
        photoDetailsViewController.post = post
        
    }
    
    func makeAPICall(){
          // ... Create the NSURLRequest (myRequest) ...
        let url = URL(string:"https://api.tumblr.com/v2/blog/humansofnewyork.tumblr.com/posts/photo?api_key=Q6vHoaVm5L1u2ZAW1fqv3Jw48gFzYVg9P0vH0VHl3GVy6quoGV")
        let request = URLRequest(url: url!)
        
         // Configure session so that completion handler is executed on main UI thread
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
                        let responseFieldDictionary = responseDictionary["response"] as! NSDictionary
                        self.posts = responseFieldDictionary["posts"] as! [NSDictionary]
                        self.tableView.reloadData()
                    }
                }
                //update flag
                self.isMoreDataLoading = false;
                //stop the loading indicator
                self.loadingMoreView?.stopAnimating()
        });
        task.resume()
    }
    
    // Makes a network request to get updated data
    // Updates the tableView with the new data
    // Hides the RefreshControl
    func refreshControlAction(_ refreshControl: UIRefreshControl) {
            makeAPICall()
            // Reload the tableView now that there is new data
            tableView.reloadData()
            // Tell the refreshControl to stop spinning
            refreshControl.endRefreshing()
        }
    
    //infite scroll
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // Calculate the position of one screen length before the bottom of the results
        let scrollViewContentHeight = tableView.contentSize.height
        let scrollOffsetThreshold = scrollViewContentHeight - tableView.bounds.size.height
        // When the user has scrolled past the threshold, start requesting
        if(scrollView.contentOffset.y > scrollOffsetThreshold && tableView.isDragging){
            // Update position of loadingMoreView, and start loading indicator
            let frame = CGRect(x: 0, y: tableView.contentSize.height, width: tableView.bounds.size.width, height: InfiniteScrollActivityView.defaultHeight)
            loadingMoreView?.frame = frame
            loadingMoreView!.startAnimating()
            
            makeAPICall()
        }
    }
    
    //set the header
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: 320, height: 50))
        headerView.backgroundColor = UIColor(white: 1, alpha: 0.9)
        
        let profileView = UIImageView(frame: CGRect(x: 10, y: 10, width: 30, height: 30))
        profileView.clipsToBounds = true
        profileView.layer.cornerRadius = 15;
        profileView.layer.borderColor = UIColor(white: 0.7, alpha: 0.8).cgColor
        profileView.layer.borderWidth = 1;
        
        // Set the avatar
        profileView.setImageWith(NSURL(string:"https://api.tumblr.com/v2/blog/humansofnewyork.tumblr.com/avatar")! as URL)
        headerView.addSubview(profileView)
        
        
        // Add a UILabel for the date here
        // Use the section number to get the right URL
        let post = posts[section]
        let date = post["date"]
        let label = UILabel(frame: CGRect(x: 40, y: 0, width: 320, height: 50))
        label.text = date as! String?
        headerView.addSubview(label)
        
        return headerView
    }
}
