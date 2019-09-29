//
//  PopUpCommentVC.swift
//  GUO Media
//
//  Created by Easyway_Mac2 on 24/07/19.
//  Copyright © 2019 mac. All rights reserved.
//

import UIKit

protocol PopUpCommentDelegate: class {
    func insertComment(_ apiType: APIType?)
    func showToast()
}

class PopUpCommentVC: UIViewController {
    
    @IBOutlet var commentView: UIView!
    @IBOutlet var contentView: UIView!
    @IBOutlet var attachmentView1: UIView!
    @IBOutlet var attachmentView2: UIView!
    

    @IBOutlet var commentViewCenterY: NSLayoutConstraint!
    @IBOutlet var contentViewHeight: NSLayoutConstraint!
    @IBOutlet var commentViewBottom: NSLayoutConstraint!
    
    @IBOutlet var commentViewHeight: NSLayoutConstraint!
    
    @IBOutlet var attachmentView1Height: NSLayoutConstraint!
    @IBOutlet var imgAttachment1: UIImageView!
    
    @IBOutlet var attachmentView2Height: NSLayoutConstraint!
    @IBOutlet var imgAttachment2: UIImageView!
    
    @IBOutlet var replyButton: UIButton!
    
    @IBOutlet var headlineTitleLabel: UILabel!
    @IBOutlet var currentDateLabel: UILabel!
    
    @IBOutlet var currentUserName: UILabel!
    @IBOutlet var commentTextView: UITextView!
    @IBOutlet var imageViewDp: UIImageView!
    
    @IBOutlet var galleryButton: UIButton!
    @IBOutlet var videoButton: UIButton!
    
    private var mediaArray: [Media]?
    private var isVideo: Int = 0
    
    private var postCommentCount: Int = 0
    private var commentText: String?

    
    weak var delegate: PopUpCommentDelegate?
    
    var apiType: APIType = .postComment
    
    var comment: Comment? {
        didSet {
            guard let comment = comment else { return }
            
            headlineTitleLabel.text = comment.comment
            currentDateLabel.text = currentDate
            
            if let username =  UserDefaults.standard.value(forKey: "com.applozic.userdefault.DISPLAY_NAME") as? String {
                currentUserName.text =  username
            }
            
            apiType = .postSubComment
            galleryButton.removeFromSuperview()
            videoButton.removeFromSuperview()
        }
    }
    
    var headline: Headline? {
        didSet {
            guard let headline = headline else { return }
            
            headlineTitleLabel.text = headline.isLanguageEnglish ? headline.engTitle : headline.chineseTitle
            
            currentDateLabel.text = currentDate
            if let username =  UserDefaults.standard.value(forKey: "com.applozic.userdefault.DISPLAY_NAME") as? String {
                currentUserName.text =  username
            }
            
        }
    }
    
    var currentDate = { () -> String in
        let date = Date()
        let format = DateFormatter()
        format.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let formattedDate = format.string(from: date)
        return formattedDate
    }()
    
    func convertDateFormater(_ date: String) -> String
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let date = dateFormatter.date(from: date)
        dateFormatter.dateFormat = "dd MMM hh:mm a"
        dateFormatter.amSymbol = "AM"
        dateFormatter.pmSymbol = "PM"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        return  dateFormatter.string(from: date!)
        
    }
    
    //MARK: Keyboard notifications
    
    fileprivate func observeKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector:#selector(keyboardShow) , name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector:#selector(keyboardHide) , name: UIResponder.keyboardDidHideNotification, object: nil)
    }
    
    @objc func keyboardShow(notification:NSNotification) {
        let keyboardSize = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue
        if let keyboardHeight = keyboardSize?.cgRectValue.size.height {
            
            contentViewHeight.priority = .defaultLow
            commentViewBottom.priority = .defaultHigh
            commentViewBottom.constant = keyboardHeight + 10
            commentViewCenterY.priority = .defaultLow
            
            self.contentView.layoutIfNeeded()
            commentView.layoutIfNeeded()

        }
    }
    
    @objc func keyboardHide() {
        
        contentViewHeight.priority = .defaultHigh
        commentViewBottom.priority = .defaultLow
        commentViewCenterY.priority = .defaultHigh
        
        self.contentView.layoutIfNeeded()
        commentView.layoutIfNeeded()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if touches.first?.view?.tag == 1 {
            dismissView()
            super.touchesEnded(touches , with: event)
        }
    }

    //MARK: UIViewController life cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        observeKeyboardNotifications()
        
        hideAttachmentView1()
        hideAttachmentView2()
        disableReplyButton()
        
        imageViewDp.removeFromSuperview()
        
        replyButton.layer.cornerRadius = 15
        replyButton.layoutIfNeeded()
        
        attachmentView1.tag = 0
        attachmentView2.tag = 0
    }

    //MARK: IBActions
    @IBAction func closeButtonClicked(_ sender: UIButton) {
        dismissView()
    }
    
    @IBAction func showGallery(_ sender: UIButton) {
        
        if imgAttachment1.image != nil && imgAttachment2.image != nil {
            CommonUtility().showToastMessage("Max of 2 photos allowed", vc: self)
            return
        }
        
        let alertController = UIAlertController(title: "", message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        
        // create an action
        let firstAction: UIAlertAction = UIAlertAction(title: "Take Photo".localized, style: .default) { action -> Void in
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                self.presentImagePickerController(.camera, mediaType: "")
                
            } else {
                print("Camera is not available")
            }
        }
        
        let secondAction: UIAlertAction = UIAlertAction(title: "Browse Photos".localized, style: .default) { action -> Void in
            self.presentImagePickerController(.photoLibrary, mediaType: "")
        }
        
        let cancelAction = UIAlertAction(title: "Cancel".localized, style: .cancel, handler: {(alert: UIAlertAction!) in
        })
        // add actions
        alertController.addAction(firstAction)
        alertController.addAction(secondAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func videoButtonClicked(_ sender: UIButton) {
        let alertController = UIAlertController(title: "", message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        
        // create an action
        let firstAction: UIAlertAction = UIAlertAction(title: "Record Video".localized, style: .default) { action -> Void in
            
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                self.presentImagePickerController(.camera, mediaType: kUTTypeMovie as String)
                
            } else {
                print("Camera is not available")
            }
            
        }
        
        let secondAction: UIAlertAction = UIAlertAction(title: "Browse Video".localized, style: .default) { action -> Void in
            self.presentImagePickerController(.photoLibrary, mediaType: kUTTypeMovie as String)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel".localized, style: .cancel, handler: {(alert: UIAlertAction!) in
        })
        // add actions
        alertController.addAction(firstAction)
        alertController.addAction(secondAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func dismissAttachmentView(_ sender: UIButton) {
        if sender.tag == 1 {
            if imgAttachment2.image != nil {
                imgAttachment1.image = imgAttachment2.image
                mediaArray?.removeFirst()
                hideAttachmentView2()
            } else {
                mediaArray?.removeAll()
                hideAttachmentView1()
            }
        } else {
            mediaArray?.removeLast()
            hideAttachmentView2()
        }
    }
    
    @IBAction func replyButtonTapped(_ sender: Any) {
        
        Utils().showProgress()
        
        commentText = commentTextView.text
        postCommentCount = 0
        postComment()
    }
    
    private func postComment() {
        
        var parameters: [String: Any]?
        
        guard let commentString = commentText else { return }
        
        // check comment is empty and if true, show toast
        if commentString.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            Utils.hideProgress()
            CommonUtility().showToastMessage("Comment should not be null", vc: self)
            commentTextView.text = ""
            return
        }
        
        if apiType == .postComment {
            guard  let newsId = self.headline?.newsId else { return }
            parameters = ["approvalNewsId": "\(String(describing: newsId))",
                "comment": commentString,
                "socialMediaUserName": userName,
                "isVideo": isVideo]
        } else {
            guard let commentId = self.comment?.commentId else { return }
            parameters = ["commentId": "\(String(describing: commentId))",
                "comment": commentString,
                "socialMediaUserName": userName,
                "isVideo": isVideo]
        }
        
        
        
        self.dismissView()

        MediaUploadService().postCommentByNewsId(withParams: parameters, andType: apiType, andMedia: mediaArray) { result, statusCode  in
            
            if statusCode == 401 {
                self.postCommentCount += 1
                if self.postCommentCount > 1 { return }
                self.retryRequest()
            }
            
            if result && statusCode == 200 {
                _ = self.convertDateFormater(self.currentDate)
                self.delegate?.insertComment(self.apiType)
                return
            } else {
                Utils.hideProgress()
                if self.postCommentCount > 1 || statusCode == 500 {
                    self.delegate?.showToast()
                }
            }
            
            Utils.hideProgress()
        }
    }
    
    private func retryRequest() {
        CustomTabVC().addUserSession() { result in
            if !result { return }
            self.postComment()
        }
    }
}

//MARK: UIScrollview delegate
extension PopUpCommentVC: UIScrollViewDelegate {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.view.endEditing(false)
    }
}

//MARK: UITextview delegate
extension PopUpCommentVC: UITextViewDelegate {
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        var newText = textView.text!
     
        newText.removeAll { (character) -> Bool in
            return character == " " || character == "\n"
        }
        
        let charCount = newText.count + text.count
        
        if charCount > 0 {
            enableReplyButton()
        }
        
        if charCount == 1 && text == "" {
            disableReplyButton()
        }
        
        if charCount > 500 {
            #warning("show toast")
            return false
        }
        
        return true
    }
}

//MARK: UIImage Picker Controller Delegate
extension PopUpCommentVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func presentImagePickerController(_ sourceType: UIImagePickerController.SourceType,mediaType:String) {
        let pickerController = UIImagePickerController()
        pickerController.sourceType = sourceType
        pickerController.videoMaximumDuration = 30
        
        if (mediaType).isEmpty == false {
            pickerController.mediaTypes = [mediaType];
        } else {
            pickerController.allowsEditing = true
        }
        pickerController.delegate = self
        pickerController.modalPresentationStyle = .overFullScreen
        self.present(pickerController, animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        let type = info[UIImagePickerController.InfoKey.mediaType] as? String
        
        if type == kUTTypeMovie as String
        {
            if let selectedVideoUrl:URL = (info[UIImagePickerController.InfoKey.mediaURL] as? URL) {
                
                let asset = AVAsset(url: selectedVideoUrl)
                
                let duration = asset.duration
                let durationTime = CMTimeGetSeconds(duration)
                
                print("durationTime: \(durationTime)")
                
                if durationTime >= picker.videoMaximumDuration {
                 CommonUtility().showToastMessage("The file is too large too upload..The file should be less then 30 sec", vc: self)

                } else {
                    let thumbImg: UIImage? = generateVideoThumbImage(selectedVideoUrl)
                    
                    if let image = thumbImg {
                        image.fixOrientation()
                        isVideo = 1
                        showImageAttachmentWithImage(image, withUrl: selectedVideoUrl)
                    }
                }
            
               
            }
        }
        else
        {
            if let selectedImage = info[.editedImage] as? UIImage {
                isVideo = 0
                showImageAttachmentWithImage(selectedImage, withImage: selectedImage)
            }
        }
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    private func showImageAttachmentWithImage(_ image: UIImage, withImage selectedImage: UIImage? = nil, withUrl videoUrl: URL? = nil) {
        
        if let url = videoUrl {
            mediaArray?.removeAll()
            if let media = Media.init(withVideo: url) {
                mediaArray = [media]
            }
            
            hideAttachmentView2()
            imgAttachment1.image = image
            attachmentView1.tag = 1
            showAttachmentView1()
        }
        
        if let image = selectedImage {
            if attachmentView1.tag == 1 {
                mediaArray?.removeAll()
                imgAttachment1.image = nil
            }

            attachmentView1.tag = 0
            
            if imgAttachment1.image == nil && imgAttachment2.image == nil {
                imgAttachment1.image = image
                showAttachmentView1()
                if let media = Media.init(withImage: image) {
                    mediaArray = [media]
                }
            } else if imgAttachment1.image != nil && imgAttachment2.image == nil {
                imgAttachment2.image = image
                if let media = Media.init(withImage: image) {
                    mediaArray?.append(media)
                }
                showAttachmentView2()
            } else {
                imgAttachment2.image = image
                if let media = Media.init(withImage: image) {
                    mediaArray?[1] = media
                }
            }
        }
    
        print("MediaArray",mediaArray as Any)
       
    }
    
}

extension PopUpCommentVC {
    
    private func dismissView() {
        dismiss(animated: true) {
            self.view.endEditing(true)
        }
    }
    
    
    //MARK: Attachment view
    private func hideAttachmentView1() {
        imgAttachment1.image = nil
        
        attachmentView1Height.constant = 0
        layoutAttachmentView(attachmentView1)
        
        commentViewHeight.constant = 320
        commentView.layoutIfNeeded()
    }
    
    private func showAttachmentView1() {
        attachmentView1Height.constant = 60
        layoutAttachmentView(attachmentView1)
        
        commentViewHeight.constant = 400
        commentView.layoutIfNeeded()
    }
    
    private func hideAttachmentView2() {
        imgAttachment2.image = nil
        
        attachmentView2Height.constant = 0
        layoutAttachmentView(attachmentView2)
    }
    
    private func showAttachmentView2() {
        attachmentView2Height.constant = 60
        layoutAttachmentView(attachmentView2)
    }
    
    private func layoutAttachmentView(_ view: UIView) {
        view.layoutIfNeeded()
        view.layoutSubviews()
    }
    
    
    //MARK: Reply button
    private func disableReplyButton() {
        replyButton.isUserInteractionEnabled = false
        replyButton.setTitleColor(.lightGray, for: .normal)
        replyButton.layer.borderColor = UIColor.lightGray.cgColor
    }
    
    private func enableReplyButton() {
        replyButton.isUserInteractionEnabled = true
        replyButton.setTitleColor(.black, for: .normal)
        replyButton.layer.borderColor = UIColor.black.cgColor
    }
}

