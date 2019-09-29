//
//  SubCommentsVC.swift
//  GUO Media
//
//  Created by Easyway_Mac2 on 26/07/19.
//  Copyright © 2019 mac. All rights reserved.
//

import UIKit

class SubCommentsVC: UIViewController {

    @IBOutlet var tableView: UITableView!
    
    private let commentCellId = "COMMENT_CELL"
    
    private var commentsFeed: CommentFeed?
    
    var comment: Comment?
    var onDeleteCommentClicked: ((SubCommentsVC) -> Void)?
    
    private func registerCells() {
        tableView.register(UINib(nibName: "CommentCell", bundle: nil), forCellReuseIdentifier: commentCellId)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            if (touch.view == self.view) {
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.registerCells()
        
        if let id = comment?.commentId {
            getCommentsByCommentId(id) { result in
          }
        }
    }

}

extension SubCommentsVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 1 : (commentsFeed?.comments.count ?? 0)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: commentCellId, for: indexPath) as! CommentCell
        
        if indexPath.section == 0
        {
            cell.backgroundColor = UIColor(236, green: 236, blue: 236)
            cell.seperatorView.backgroundColor = .clear
            cell.comment = comment
            cell.menuButton.isHidden = true
            cell.replyCountButton.removeFromSuperview()
            cell.likeView.removeFromSuperview()
            cell.dateLabel.removeFromSuperview()
            
        }
        else // SubComment Cell
        {
            cell.commentButton.isHidden = true
            cell.comment = commentsFeed?.comments[indexPath.row]
            cell.replyCountButton.removeFromSuperview()
            cell.delegate = self
            cell.backgroundColor = .white
            
        }
        
        return cell
        
    }

}

extension SubCommentsVC: CommentCellDelegate, CommentDelegate {
    
    func commentPlayButtonAction(withUrl customImageVideo: String, isVideo: Int) {
        
    }
    
    func commentImageTapped(_ url: String) {
        
    }
   
    func likeButtonTapped(_ sender: CommentCell) {
        CommonUtility().commentLikeButtonTapped(sender, apiType: .likeSubComment)
    }
   
    func menuButtonTapped(_ sender: CommentCell) {
        CommonUtility().commentDelegate = self
        CommonUtility().showMoreOptions(sender, apiType: .deleteSubComment, vc: self)
    }
    
    func deleteCommentForSender(_ sender: CommentCell, status: Bool) {
        
        guard let indexPath = tableView.indexPath(for: sender) else { return }
        
        if status {
            let index = indexPath.row
            self.commentsFeed?.deleteComment(at: index)
            self.tableView.beginUpdates()
            self.tableView.deleteRows(at: [indexPath], with: .fade)
            self.tableView.endUpdates()
            
            
            DispatchQueue.main.async {
                CommonUtility().showToastMessage("Comment has been removed successfully", vc: self)
                self.onDeleteCommentClicked?(self)
            }
        }
    }
}

//MARK: Comments API
extension SubCommentsVC {
    
    private func getCommentsByCommentId(_ id: Int, completion: @escaping ((Bool) -> Void)) {
        
        let commentsAPI: String = getSubCommentsUrl + "\(id)"
        
        Utils().showProgress()
        
        ConnectionAPI().fetchGenericData(urlString: commentsAPI, apiType: .getSubComments, params: nil, sBlock: { (response: CommentFeed) in
            Utils.hideProgress()
            
            self.commentsFeed = response
            
            self.tableView.reloadData()
            
            completion(true)
            
        }, fBlock: { customErrorMsg, errorCode in
            Utils.hideProgress()
            completion(false)
        })
    }
}
