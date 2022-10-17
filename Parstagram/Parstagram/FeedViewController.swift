//
//  FeedViewController.swift
//  Parstagram
//
//  Created by Sammy Torres II on 10/6/22.
//

import UIKit
import Parse
import AlamofireImage
import MessageInputBar

class FeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MessageInputBarDelegate {
    
    @IBOutlet var tableView: UITableView!
    
    //create an instance for message input bar
    let commentBar = MessageInputBar()
    var showsCommentBar = false
    
    // array of posts
    var posts = [PFObject]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // to display something differet then 'New Message' on app
        commentBar.inputTextView.placeholder = "Add a comment..."
        commentBar.sendButton.title = "Post"
        commentBar.delegate = self
        
        tableView.delegate = self
        tableView.dataSource = self
        
        //this will dismis the keyboard
        tableView.keyboardDismissMode = .interactive
        
        //helps with hiding 'New Message' function
        let center = NotificationCenter.default
        center.addObserver(self, selector: #selector(keyboardWillBeHidden(note:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    //this function will dismiss 'New Message' after dismissing the keyboard]
    @objc func keyboardWillBeHidden(note: Notification){
        // this clears the text field after it's dismissed
        commentBar.inputTextView.text = nil
        //this helps toggle back and forth
        showsCommentBar = false
        becomeFirstResponder()
    }
    
    override var inputAccessoryView: UIView? {
        return commentBar
    }
    
    override var canBecomeFirstResponder: Bool {
        return showsCommentBar
    }
    
    // This refreshes the table view after the post is created
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // creating query
        let query = PFQuery(className: "Posts")
        // this fetches the actual object
        query.includeKeys(["author", "comments", "comments.author"])
        // set up limits
        query.limit = 30
        // query
        query.order(byDescending: "createdAt")
        // get the query
        query.findObjectsInBackground { posts, error in
            if (posts != nil) {
                self.posts = posts! // store the data
                self.tableView.reloadData() // reload the table view with data
            }
        }
    }
    
    func messageInputBar(_ inputBar: MessageInputBar, didPressSendButtonWith text: String) {
        // Create the comment
        
        // Clear and dismiss the input bar
        commentBar.inputTextView.text = nil
        showsCommentBar = false
        becomeFirstResponder()
        commentBar.inputTextView.resignFirstResponder()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let post = posts[section]
        let comments = (post["comments"] as? [PFObject]) ?? [] // the ?? is saying if the comments is blank or nil then put [] or blank for it
        
        return comments.count + 2
    }
    
    // this allows to have multiple comments
    func numberOfSections(in tableView: UITableView) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let post = posts[indexPath.section]
        let comments = (post["comments"] as? [PFObject]) ?? []
        
        // determines what type of cell to return
        if (indexPath.row == 0) { // the post is always at row 0 so if it's a post it will return a post
            let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell") as! PostCell
           
            let user = post["author"] as! PFUser
            cell.usernameLabel.text = user.username
            
            cell.captionLabel.text = post["caption"] as! String
            
            // grab image URL
            let imageFile = post["image"] as! PFFileObject
            let urlString = imageFile.url!
            let url = URL(string: urlString)!
            
            cell.photoView.af.setImage(withURL: url)
            
            return cell
        }
        else if indexPath.row <= comments.count { // this returns comments
            let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell") as! CommentCell
            
            // this gets the comment out
            let comment = comments[indexPath.row - 1]
            cell.commentLabel.text = comment["text"] as? String
            let user = comment["author"] as! PFUser
            cell.nameLabel.text = user.username
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "AddCommentCell")!
            
            return cell
        }

    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let post = posts[indexPath.section]
        // comment object
        let comments = (post["comments"] as? [PFObject]) ?? []
        
        if (indexPath.row == comments.count + 1) {
            showsCommentBar = true
            becomeFirstResponder()
            // raise the keyboard
            commentBar.inputTextView.becomeFirstResponder()
        }
        
//        comment["text"] = "This is a random comment"
//        comment["post"] = post
//        comment["author"] = PFUser.current()!
//
//        post.add(comment, forKey: "comments")
//
//        // saves the post
//        post.saveInBackground{ (success, error) in
//            if (success) {
//                print("Comment saved!")
//            }
//            else {
//                print("Error saving comment!")
//            }
//        }
    }
    
    @IBAction func onLogoutButton(_ sender: Any) {
        // this logs out current user
        PFUser.logOut()
        
        // this switches back to login screen
        let main = UIStoryboard(name: "Main", bundle: nil)
        let loginViewController = main.instantiateViewController(withIdentifier: "LoginViewController")
        
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let delegate = windowScene.delegate as? SceneDelegate else { return }
        
        delegate.window?.rootViewController = loginViewController
    }
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
