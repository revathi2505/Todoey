//
//  ViewCommentsVC.swift
//  GUO Media
//
//  Created by apple on 7/24/19.
//  Copyright © 2019 mac. All rights reserved.
//

import UIKit

class NewsDetailVC: UIViewController {

    @IBOutlet var backButton: UIButton!
    @IBOutlet var newsTableView: UITableView!
    
    private let commentCellId = "COMMENT_CELL"
    private let newsDetailCellId = "NEWSDETAIL_CELL"
    
    private var backTintedImage = UIImage(named: "back_Img")?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
    
    private var commentsFeed: CommentFeed?
    
    var headline: Headline?
    var parentEverythingCell: EverythingNewsCell?
    
    private var postLikeCount: Int = 0
    private var likeSender: NewsDetailCell?
    
    private func setNavigationBar() {
        backButton.setImage(backTintedImage, for: .normal)
        backButton.tintColor = CustomColor.categoryCustomColor_gray
    }
    
    @IBAction func backAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }

    private func registerCells() {
        newsTableView.register(UINib(nibName: "CommentCell", bundle: nil), forCellReuseIdentifier: commentCellId)
        newsTableView.register(UINib(nibName: "NewsDetailCell", bundle: nil), forCellReuseIdentifier: newsDetailCellId)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setNavigationBar()
        self.registerCells()
        
        if let id = headline?.newsId {
            getCommentsByNewsId(id) { result in
            }
        }
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: animated)
        
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
    }
    

}

extension NewsDetailVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 1 : (commentsFeed?.comments.count ?? 0)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            let cell =  newsTableView.dequeueReusableCell(withIdentifier: newsDetailCellId, for: indexPath) as! NewsDetailCell
            cell.delegate = self
            cell.headline = headline
            return cell
        } else {
            let cell =  newsTableView.dequeueReusableCell(withIdentifier: commentCellId, for: indexPath) as! CommentCell
            cell.comment = commentsFeed?.comments[indexPath.row]
            
            cell.subCommentButtonTap = subCommentButtonTapped(_:)
            
            cell.viewReplyButtonTap = viewReplyButtonTapped(_:)
            
            cell.delegate = self
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

extension NewsDetailVC: NewsDetailCellDelegate, PopUpCommentDelegate {
    
    
    func newsPlayButtonAction(_ sender: NewsDetailCell, customImageVideo: String) {
        
        if sender.headline?.isVideo == 1 {
            CommonUtility().playVideoWithUrl(customImageVideo, vc: self)
        } else {
            CommonUtility().openPhotoBrowserWithUrl(customImageVideo, vc: self)
        }
    }
    
    func newsShareButtonAction(_ sender: NewsDetailCell) {
        var guoMediaUrl = URL(string:"https://www.guo.media/")
        
        if let id = sender.headline?.newsId {
            let urlString =  newsShareURL + String(id)
            guoMediaUrl = URL(string: urlString)
        }
        
        CommonUtility().openActivityControllerWithUrl(guoMediaUrl!, vc: self)

    }
    
    // Show comment pop up
    func addCommentTapped(_ sender: NewsDetailCell) {
        
        guard let headline = headline else { return }
        
        let popUpCommentVc = UIStoryboard.init(name: "News", bundle: nil).instantiateViewController(withIdentifier: "COMMENT") as! PopUpCommentVC
        popUpCommentVc.providesPresentationContextTransitionStyle = true
        popUpCommentVc.definesPresentationContext = true
        popUpCommentVc.modalPresentationStyle = UIModalPresentationStyle.overFullScreen;
        popUpCommentVc.view.backgroundColor = UIColor(white: 0, alpha: 0.5)
        popUpCommentVc.delegate = self
        popUpCommentVc.headline = headline
        self.present(popUpCommentVc, animated: true, completion: nil)
    }
    
    //Like Button Tapped
    func likeButtonTapped(_ sender: NewsDetailCell) {
        postLikeCount = 0
        likeSender = sender
        
        postLike()
    }
    
    private func postLike() {
        
        guard let sender = likeSender, let newsId = sender.headline?.newsId else { return }
        
        let likeStatus =  (self.headline?.likeStatus == 0) ? 1 : 0
        
        let params = ["approvalNewsId": "\(newsId)",
            "isLikeStatus": "\(likeStatus)"]
       
        ConnectionAPI().callNewsWebServicePost(urlString: likeNewsUrl, apiType: .likeNews, params: params, sBlock: { result, statusCode in
            
            if result && statusCode == 200 {
                
                DispatchQueue.main.async {
                    
                    self.headline?.toggleLikeStatus()
                    
                    let likeStatus = self.headline?.likeStatus
                    
                    let likeButtonImage: UIImage = (likeStatus == 0) ? #imageLiteral(resourceName: "heart") : #imageLiteral(resourceName: "heart_rf")
                    sender.likeButton.setImage(likeButtonImage, for: .normal)
                    self.parentEverythingCell?.likeButton.setImage(likeButtonImage, for: .normal)
                    
                    guard let likeCount = self.headline?.likeCount else { return }
                    sender.likeButton.setTitle("\(likeCount)", for: .normal)
                    self.parentEverythingCell?.likeButton.setTitle("\(likeCount)", for: .normal)
                }

            }
            
            if statusCode == 401 {
                self.postLikeCount += 1
                if self.postLikeCount > 1 { return }
                self.retryRequest()
            }
            
        }) { customErrorMsg, errorCode in
            
        }
    }
    
    private func retryRequest() {
        CustomTabVC().addUserSession() { result in
            if !result { return }
            self.postLike()
        }
    }
    
    func insertComment(_ apiType: APIType?) {
        
        if apiType == .postComment {
            if let id = headline?.newsId {
                getCommentsByNewsId(id) { result in
                    
                    if !result {
                        #warning("Insert manually")
                        return
                    }
                    
                    DispatchQueue.main.async {
                        
                        if let newsDetailCell = self.newsTableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? NewsDetailCell {
                            self.headline?.increaseCommentCount()
                            if let commentCount = self.headline?.commentCount {
                                newsDetailCell.commentButton.setTitle("\(commentCount)", for: .normal)
                                self.parentEverythingCell?.commentButton.setTitle("\(commentCount)", for: .normal)
                            }
                        }
                        
                        CommonUtility().showToastMessage("Comment added successfully", vc: self)
                    }
                    
                }
            }
        } else {
            if let id = headline?.newsId {
                getCommentsByNewsId(id) { result in
                    
                    if !result {
                        #warning("Insert manually")
                        return
                    }
                    
                    DispatchQueue.main.async {
                        CommonUtility().showToastMessage("Comment added successfully", vc: self)
                    } 
                }
            }
            
            
        }

     
        
        /* self.commentsFeed?.appendNewComment(comment)
         self.newsTableView.beginUpdates()
         self.newsTableView.insertRows(at: [IndexPath(row: 0, section: 1)], with: .top)
         self.newsTableView.endUpdates() */
        

    }

    func showToast() {
        DispatchQueue.main.async {
            CommonUtility().showToastMessage("Unable to post. Please retry", vc: self)
        }
    }
    
    
}

extension NewsDetailVC: CommentCellDelegate, CommentDelegate {
    
    func commentImageTapped(_ url: String) {
        CommonUtility().openPhotoBrowserWithUrl(url, vc: self)
    }
    
    func commentPlayButtonAction(withUrl customImageVideo: String, isVideo: Int) {
        if isVideo == 1 {
            CommonUtility().playVideoWithUrl(customImageVideo, vc: self)
        } else {
            CommonUtility().openPhotoBrowserWithUrl(customImageVideo, vc: self)
        }
        
    }

    func viewReplyButtonTapped(_ sender: CommentCell) {

        let subCommentsVC = UIStoryboard.init(name: "Library", bundle: nil).instantiateViewController(withIdentifier: "SUBCOMMENT") as! SubCommentsVC
        subCommentsVC.comment = sender.comment
        subCommentsVC.providesPresentationContextTransitionStyle = true
        subCommentsVC.definesPresentationContext = true
        subCommentsVC.modalPresentationStyle = UIModalPresentationStyle.overFullScreen;
        subCommentsVC.view.backgroundColor = UIColor(white: 0, alpha: 0.5)
        
        subCommentsVC.onDeleteCommentClicked = { (subCommentView) in
            if let id = self.headline?.newsId {
                self.getCommentsByNewsId(id) { result in
                }
            }
        }
        
        self.present(subCommentsVC, animated: true, completion: nil)
        
    }
    
    func subCommentButtonTapped(_ sender: CommentCell) {
        guard let comment = sender.comment else { return }
        let popUpCommentVc = UIStoryboard.init(name: "News", bundle: nil).instantiateViewController(withIdentifier: "COMMENT") as! PopUpCommentVC
        popUpCommentVc.providesPresentationContextTransitionStyle = true
        popUpCommentVc.definesPresentationContext = true
        popUpCommentVc.modalPresentationStyle = UIModalPresentationStyle.overFullScreen;
        popUpCommentVc.view.backgroundColor = UIColor(white: 0, alpha: 0.5)
        popUpCommentVc.delegate = self
        popUpCommentVc.comment = comment
        self.present(popUpCommentVc, animated: true, completion: nil)
    }

    func likeButtonTapped(_ sender: CommentCell) {
        CommonUtility().commentLikeButtonTapped(sender, apiType: .likeComment)
    }
    
    func menuButtonTapped(_ sender: CommentCell) {
        CommonUtility().showMoreOptions(sender, apiType: .deleteComment, vc: self)
    }
    
    func deleteCommentForSender(_ sender: CommentCell, status: Bool) {
        
        guard let indexPath = newsTableView.indexPath(for: sender) else { return }
        
        if status {
            let index = indexPath.row
            self.commentsFeed?.deleteComment(at: index)
            self.newsTableView.beginUpdates()
            self.newsTableView.deleteRows(at: [indexPath], with: .fade)
            self.newsTableView.endUpdates()
            
            DispatchQueue.main.async {
                
                CommonUtility().showToastMessage("Comment has been removed successfully", vc: self)
                
                if let newsDetailCell = self.newsTableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? NewsDetailCell {
                    self.headline?.decreaseCommentCount()
                    if let commentCount = self.headline?.commentCount {
                        newsDetailCell.commentButton.setTitle("\(commentCount)", for: .normal)
                        self.parentEverythingCell?.commentButton.setTitle("\(commentCount)", for: .normal)
                    }
                }
                
            }
        }
    }
    
}

//MARK: Comments API
extension NewsDetailVC {
    private func getCommentsByNewsId(_ id: Int, completion: @escaping ((Bool) -> Void)) {

        let commentsAPI: String = getCommentsUrl + "\(id)"
        
        Utils().showProgress()
        
        ConnectionAPI().fetchGenericData(urlString: commentsAPI, apiType: .getComments, params: nil, sBlock: { (response: CommentFeed) in
            Utils.hideProgress()

            self.commentsFeed = response
            
            self.newsTableView.reloadSections(IndexSet(integer: 1), with: .automatic)
            
            completion(true)
            
        }, fBlock: { customErrorMsg, errorCode in
            Utils.hideProgress()
            completion(false)
        })
    }
}
