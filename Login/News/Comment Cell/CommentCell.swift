//
//  CommentCell.swift
//  GUO Media
//
//  Created by Easyway_Mac2 on 25/07/19.
//  Copyright © 2019 mac. All rights reserved.
//

import UIKit
import SDWebImage

protocol CommentCellDelegate: class {
    func likeButtonTapped(_ sender: CommentCell)
    func menuButtonTapped(_ sender: CommentCell)
    func commentPlayButtonAction(withUrl customImageVideo: String, isVideo: Int)
    func commentImageTapped(_ url: String)
}

class CommentCell: UITableViewCell {

    @IBOutlet var imageViewDP: UIImageView!
    @IBOutlet var userNameLabel: UILabel!
    @IBOutlet var commentTextView: UITextView!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var likeButton: UIButton!
    @IBOutlet var commentButton: UIButton!
    @IBOutlet var seperatorView: UIView!
    @IBOutlet var menuButton: UIButton!
    @IBOutlet var likeView: UIView!
    
    @IBOutlet var commentLabelTrailng: NSLayoutConstraint!
    @IBOutlet var userNameLabelHeight: NSLayoutConstraint!
    @IBOutlet var mainView: UIView!
    
    
    @IBOutlet var imgAttachment1: UIImageView!
    @IBOutlet var imgAttachment1Height: NSLayoutConstraint!
    @IBOutlet var imgAttachmentTop: NSLayoutConstraint!
    @IBOutlet var imgAttachmentBottom: NSLayoutConstraint!
    @IBOutlet var playButton: UIButton!
    
    @IBOutlet var imgAttachment2: UIImageView!
    @IBOutlet var imgAttachment2Height: NSLayoutConstraint!
    
    @IBOutlet var replyCountButton: UIButton!
    @IBOutlet var replyCountButtonHeight: NSLayoutConstraint!
    @IBOutlet var replyCountButtonTop: NSLayoutConstraint!
    
    private var firstAttachment: String = ""
    private var secondAttachment: String = ""
    
    weak var delegate: CommentCellDelegate?
    
    var subCommentButtonTap: ((CommentCell) -> Void)?
    var viewReplyButtonTap: ((CommentCell) -> Void)?
    
    var comment: Comment? {
        didSet {
            guard let comment = comment else { return }
            
            if let userId = comment.userId {
                if userInfoId == "\(userId)" {
                    menuButton.isHidden = false
                } else {
                    menuButton.isHidden = true
                }
            }
            
            if let comment = comment.comment {
                commentTextView.text = comment
            }
            
            if let userName = comment.userName {
                userNameLabel.text = " " + userName
                showUserName()
            } else {
                hideUserName()
            }
            
            likeButton.setTitle("\(comment.likeCount)", for: .normal)
            
            if let subCommentCount = comment.subCommentCount {
                commentButton.setTitle("\(subCommentCount)", for: .normal)
                
                if subCommentCount > 0 {
                    let replyString = subCommentCount == 1 ? "reply" : "replies"
                    replyCountButton.setTitle("View \(subCommentCount) \(replyString)", for: .normal)
                    showReplyCountButton()
                } else {
                    hideReplyCountButton()
                }
            }
            
            
            
            let likeButtonImage: UIImage = (comment.likeStatus == 0) ? #imageLiteral(resourceName: "heart") : #imageLiteral(resourceName: "heart_rf")
            likeButton.setImage(likeButtonImage, for: .normal)
            
            if let createdDate = comment.createdDate {
                dateLabel.text = createdDate
            }
            
            if var firstAttachment = comment.firstAttachment {
                if firstAttachment.caseInsensitiveCompare("null") == .orderedSame {
                    hideAttachments()
                } else {
                    firstAttachment = newsVideoUrl + firstAttachment
                    firstAttachment = firstAttachment.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
                    self.firstAttachment = firstAttachment
                    
                    guard let isVideo = comment.isVideo else { return }
                    
                    playButton.isHidden = false
                    
                    if isVideo == 1 {
                        playButton.setImage(UIImage(named: "ic_play_video"), for: .normal)
                        /* thumbnailThread.async {
                         let thumbnail = createThumbnailOfVideoFromRemoteUrl(firstAttachment)
                         DispatchQueue.main.async {
                         self.imgAttachment1.image = thumbnail
                         }
                         
                         }*/
                        
                        
                        guard let assetUrl = URL(string: firstAttachment) else { return }
                        AVAsset(url: assetUrl).generateThumbnailFromUrl(firstAttachment) { [weak self] (image) in
                            DispatchQueue.main.async {
                                guard let image = image else { return }
                                self?.imgAttachment1.image = image
                            }
                        }
                        
                        hideAttachment2()
                    } else {
                        playButton.setImage(nil, for: .normal)
                        setImageFromUrl(firstAttachment, for: imgAttachment1)
                    }
                    
                    showAttachment1()
                }
            }
            
            if var secondAttachment = comment.secondAttachment {
                if secondAttachment.caseInsensitiveCompare("null") == .orderedSame {
                    hideAttachment2()
                } else {
                    secondAttachment = newsVideoUrl + secondAttachment
                    secondAttachment = secondAttachment.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
                    self.secondAttachment = secondAttachment
                    setImageFromUrl(secondAttachment, for: imgAttachment2)
                    
                    showAttachment2()
                }
            }
        }
    }
    
    private func setImageFromUrl(_ imageUrl: String, for imgView: UIImageView) {
        imgView.sd_setImage(with: URL(string: imageUrl)) { (image, error, cache, urls) in
            if (error != nil) {
                print("Commment SDerror", error as Any)
                
                imgView.image = UIImage(named: "everythingNoImage")
            } else {
                imgView.image = image
            }
        }
    }
    
    private func addTapGesture() {
        let tapGesture = UITapGestureRecognizer()
        tapGesture.addTarget(self, action: #selector(self.imageTapped(gestureRecgonizer:)))
        imgAttachment1.addGestureRecognizer(tapGesture)
        imgAttachment2.addGestureRecognizer(tapGesture)
    }

    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        hideAttachments()
        imageViewDP.removeFromSuperview()
        addTapGesture()
        
        imgAttachment1.image = UIImage(named: "default-postImg")
        imgAttachment2.image = UIImage(named: "default-postImg")
        
        // Comment the following lines to show subcomments and add subcomment
        //commentButton.removeFromSuperview()
        //hideReplyCountButton()
    }

    override func prepareForReuse() {
        hideReplyCountButton()
        playButton.isHidden = true
        imgAttachment1.image = UIImage(named: "default-postImg")
        imgAttachment2.image = UIImage(named: "default-postImg")
    }
    
    
    @IBAction func likeButtonClicked(_ sender: UIButton) {
        delegate?.likeButtonTapped(self)
    }
    
    @IBAction func commentButtonClicked(_ sender: UIButton) {
        subCommentButtonTap?(self)
    }
    @IBAction func menuButtonTapped(_ sender: Any) {
        delegate?.menuButtonTapped(self)
    }
    
    @IBAction func viewReplyButtonTapped(_ sender: UIButton) {
        viewReplyButtonTap?(self)
    }
    
    @IBAction func playButtonTapped(_ sender: UIButton) {
        guard var customImageVideo = comment?.firstAttachment, let isVideo = comment?.isVideo else { return }
        customImageVideo =   newsVideoUrl + customImageVideo
        customImageVideo = customImageVideo.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        delegate?.commentPlayButtonAction(withUrl: customImageVideo, isVideo: isVideo)
    }
   
    
    @objc func imageTapped(gestureRecgonizer: UITapGestureRecognizer) {
        
        let tag = gestureRecgonizer.view?.tag
        if tag == 1 {
            delegate?.commentImageTapped(firstAttachment)
        } else {
            delegate?.commentImageTapped(secondAttachment)
        }
    }
    
}

//MARK: Animate Views
extension CommentCell {
    
    private func showUserName() {
        userNameLabelHeight.constant = 30
        commentLabelTrailng.constant = 8
        mainView.layoutIfNeeded()
    }
    
    private func hideUserName() {
        userNameLabelHeight.constant = 0
        commentLabelTrailng.constant = 56
        mainView.layoutIfNeeded()
    }
    
    private func showAttachment1() {
        imgAttachment1Height.constant = 70
        imgAttachmentTop.constant = 8
        imgAttachmentBottom.constant = 8
        imgAttachment1.layoutIfNeeded()
    }
    
    private func hideAttachment1() {
        imgAttachment1.image = nil
        
        imgAttachment1Height.constant = 0
        imgAttachmentTop.constant = 0
        imgAttachmentBottom.constant = 0
        imgAttachment1.layoutIfNeeded()
    }
    
    private func showAttachment2() {
        imgAttachment2Height.constant = 70
        imgAttachment2.layoutIfNeeded()
    }
    
    private func hideAttachment2() {
        imgAttachment2.image = nil
        imgAttachment2Height.constant = 0
        imgAttachment2.layoutIfNeeded()
    }
    
    private func hideAttachments() {
        hideAttachment1()
        hideAttachment2()
    }
    
    private func showReplyCountButton() {
        replyCountButtonHeight.constant = 25
        replyCountButtonTop.constant = 8
        replyCountButton.layoutIfNeeded()
        replyCountButton.isHidden = false
    }
    
    func hideReplyCountButton() {
        replyCountButtonHeight.constant = 0
        replyCountButtonTop.constant = 0
        replyCountButton.layoutIfNeeded()
        replyCountButton.isHidden = true
    }
}
