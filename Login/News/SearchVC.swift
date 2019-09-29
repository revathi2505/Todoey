//
//  SearchVC.swift
//  GUO Media
//
//  Created by Easyway_Mac2 on 29/07/19.
//  Copyright © 2019 mac. All rights reserved.
//

import UIKit
import AVKit
import IDMPhotoBrowser

class SearchVC: UIViewController {
    
    @IBOutlet var backButton: UIButton!
    @IBOutlet var startDateLabel: UILabel!
    @IBOutlet var endDateLabel: UILabel!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var searchBar: UISearchBar!
    
    private var refreshFooter: YiRefreshFooter?
    
    private let everythingNewsCellId = "EVERYTHING_NEWS"
    
    private var newsResponse: NewsFeed?
    private var timer: Timer?
    
    private var startIndex: Int = 0 {
        willSet {
            if newValue == 0  // setUp for startIndex = 0
            {
                tableView.backgroundView = nil
                refreshFooter?.endRefreshing()
                removePullDownToRefresh()
                alertLabel = ""
                Utils().showProgress()
            }
        }
    }
    
    private var alertLabel: String = "" {
        didSet {
            self.newsResponse = nil
            self.tableView.reloadData()
            self.tableView.setEmptyMessage(alertLabel.localized)
        }
    }
    
    private var keyword: String?
    
    private var commentSender: EverythingNewsCell?
    
    var todayDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: Date())
    }
    
    var startDate: String = ""
    var endDate: String = ""
    
    //MARK: Register Cell
    private func registerCells() {
        tableView.register(UINib(nibName: "EverythingCell", bundle: nil), forCellReuseIdentifier: everythingNewsCellId)
    }
    
    //MARK: Set Navigation Bar
    private func setNavBar() {
        let backTintedImage = UIImage(named: "back_Img")?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
        backButton.setImage(backTintedImage, for: .normal)
        backButton.tintColor = CustomColor.categoryCustomColor_gray
    }
    
    
    @IBAction func backButtonTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setNavBar()
        registerCells()
        
        endDateLabel.text = todayDate
        endDate = String(Date().millisecondsSince1970)
        
        refreshFooter = YiRefreshFooter.init()
        
        searchBar.placeholder = "Search GNews".localized
    
        weak var weakSelf = self
        refreshFooter?.beginRefreshingBlock = {
            
            DispatchQueue.global(qos: .default).async(execute: {
                sleep(1)
                weakSelf?.getNewsResponseBySearch(weakSelf?.keyword ?? "", startValue: weakSelf?.startIndex ?? 0)
            })
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
        self.tabBarController?.tabBar.isHidden = true
        
        searchBar.becomeFirstResponder()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ToPicker" {
            let pickerVc = segue.destination as! DatePickerVC
            pickerVc.onSave = { [weak self] (date, endDate) in
                self?.endDateLabel.text = date
                self?.endDate = endDate
            }
        }
        
        if segue.identifier == "FromPicker" {
            let pickerVc = segue.destination as! DatePickerVC
            pickerVc.onSave = { [weak self] (date, startDate) in
                self?.startDateLabel.textColor = .black
                self?.startDateLabel.text = date
                self?.startDate = startDate
            }
        }
    }
    
    private func onSave(date: String) {
        print("SelectedDate", date)
    }
    
    
    @IBAction func clearData(_ sender: Any) {
        startDateLabel.textColor = UIColor(red: 0.616, green: 0.616, blue: 0.627, alpha: 1.0)
        startDateLabel.text = "Start Date"
        endDateLabel.text = todayDate
        
    }
    
    @IBAction func searchButtonTapped(_ sender: Any) {
        
        if var searchKeyword = searchBar.text {
            searchKeyword = searchKeyword.trimmingCharacters(in: .whitespacesAndNewlines)
            self.keyword = searchKeyword
        }
        
        print("searchString", self.keyword, "startDate", startDate, "endDate", endDate)
        
        if let keyword = self.keyword {
            self.startIndex = 0
            Utils().showProgress()
          getNewsResponseBySearch(keyword, startValue: 0)
        }
        
    }
    
}

//MARK: Search Bar Delegate
extension SearchVC: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        if self.timer != nil {
            self.timer?.invalidate()
            self.timer = nil
        }
        
        guard var searchStr = searchBar.text else { return true}
        searchStr = (searchStr as NSString).replacingCharacters(in: range, with: text)
        
        //self.timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(searchForKeyword), userInfo: searchStr, repeats: false)
        
        return true
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        //searchForKeyword()
    }
    
    
    @objc func searchForKeyword() {
        
        if var searchKeyword = searchBar.text {
            print("UserInfo",keyword)
            searchKeyword = searchKeyword.trimmingCharacters(in: .whitespacesAndNewlines)
            
            if searchKeyword != "" {
                self.startIndex = 0
                self.keyword = searchKeyword
                Utils().showProgress()
                getNewsResponseBySearch(searchKeyword, startValue: 0)
            } else {
                CommonUtility().showToastMessage("Search text should not be null", vc: self)
                searchBar.text = ""
                return
            }
        }
        
        // Use this for character search
        /* if var keyword = self.timer?.userInfo as? String {
         print("UserInfo",keyword)
         keyword = keyword.trimmingCharacters(in: .whitespacesAndNewlines)
         
         if keyword != "" {
         self.startIndex = 0
         getNewsResponseBySearch(keyword, startValue: 0)
         }
         
         } */
        
    }
}

//MARK: Fetch Response
extension SearchVC {
    
    private func getNewsResponseBySearch(_ keyword: String, startValue: Int) {
        
        /* self.keyword = keyword.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
         guard let keyword = self.keyword else { return }
         let searchAPI =  searchUrl +  keyword */
        
        let params = ["searchString": keyword,
                      "startDate": startDate,
                      "endDate": endDate,
                      "toStart": "\(startValue)"]
        
        ConnectionAPI().fetchGenericData(urlString: searchUrl, apiType: .getNewsBySearch, params: params, sBlock: { (data: NewsFeed) in
            Utils.hideProgress()
            
            let response = data
            response.setAppLanguage()
            
            if startValue == 0 {
                
                self.newsResponse = response
                
                if response.latestNewsHeadlines.count == 0 {
                    self.alertLabel = "No data found"
                }
            } else {
                
                self.newsResponse?.addLatestHeadlines(response.latestNewsHeadlines)
            }
            
            if response.latestNewsHeadlines.count < 10 {
                self.removePullDownToRefresh()
            }
            else if response.latestNewsHeadlines.count >= 10 {
                self.addPullDowntoRefresh()
            }
            
            self.startIndex = self.startIndex + 10
            
            self.tableView.reloadData()
            
        }, fBlock: { customErrorMsg, errorCode in
            Utils.hideProgress()
            
            if startValue == 0 {
                self.alertLabel = "No data found"
            } else {
                self.removePullDownToRefresh()
            }
            
        })
        
        
    }
    
    //MARK:REFRESH FOOTER
    
    private func removePullDownToRefresh() {
        if let refreshFooter = refreshFooter {
            refreshFooter.remove_observer()
            refreshFooter.scrollView = nil
            refreshFooter.footerView?.removeFromSuperview()
        }
    }
    
    private func addPullDowntoRefresh() {
        removePullDownToRefresh()
        if let refreshFooter = refreshFooter {
            refreshFooter.scrollView = tableView
            refreshFooter.footer()
        }
    }
}

//MARK: UITableview Delegate and Datasource
extension SearchVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return newsResponse?.latestNewsHeadlines.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: everythingNewsCellId, for: indexPath) as! EverythingNewsCell
        cell.searchKeyword = self.keyword
        cell.newsHeadline = newsResponse?.latestNewsHeadlines[indexPath.row]
        cell.delegate = self
        return cell
    }
    
}

extension SearchVC: EverythingCellDelegate {
    func newsTableCellDidTapMore(_ sender: EverythingNewsCell) {
        
    }
    
    func newsTableCellDidTapViewComments(_ sender: EverythingNewsCell) {
        
    }
    
    func newsPlayButtonAction(_ sender:EverythingNewsCell, customImageVideo:String) {
        if sender.newsHeadline?.isVideo == 1 {
            CommonUtility().playVideoWithUrl(customImageVideo, vc: self)
        } else {
            CommonUtility().openPhotoBrowserWithUrl(customImageVideo, vc: self)
        }
    }
    
    func newsShareButtonAction(_ sender: EverythingNewsCell) {
        
        var guoMediaUrl = URL(string:"https://www.guo.media/")
        
        if let id = sender.newsHeadline?.newsId {
            let urlString =  newsShareURL + String(id)
            guoMediaUrl = URL(string: urlString)
        }
        
        CommonUtility().openActivityControllerWithUrl(guoMediaUrl!, vc: self)
    }
    
    func addCommentTapped(_ sender: EverythingNewsCell) {
        
        guard let headline = sender.newsHeadline else { return }
        commentSender = sender
        
        let presentedViewController = UIStoryboard.init(name: "News", bundle: nil).instantiateViewController(withIdentifier: "COMMENT") as! PopUpCommentVC
        presentedViewController.providesPresentationContextTransitionStyle = true
        presentedViewController.definesPresentationContext = true
        presentedViewController.modalPresentationStyle = UIModalPresentationStyle.overFullScreen;
        presentedViewController.view.backgroundColor = UIColor(white: 0, alpha: 0.5)
        presentedViewController.headline = headline
        presentedViewController.delegate = self
        self.present(presentedViewController, animated: true, completion: nil)
    }
    
    func translateButtonTapped(_ sender: EverythingNewsCell) {
        guard let indexPath = tableView.indexPath(for: sender) else { return }
        newsResponse?.latestNewsHeadlines[indexPath.row].toggleLanguage()
        self.tableView.reloadRows(at: [indexPath], with: .none)
    }
    
    //MARK: Like button action
    func addLikeDisLikeTapped(_ sender: EverythingNewsCell) {
        
        CommonUtility().newsLikeButtonTapped(sender)
        
    }
    
}

extension SearchVC: PopUpCommentDelegate {
    
    func showToast() {
        DispatchQueue.main.async {
            CommonUtility().showToastMessage("Unable to post. Please retry", vc: self)
        }
    }
    
    func insertComment(_ apiType: APIType?) {
        Utils.hideProgress()
        
        guard let sender = commentSender else { return }
        sender.newsHeadline?.increaseCommentCount()
        if let commentCount = sender.newsHeadline?.commentCount {
            DispatchQueue.main.async {
                sender.commentButton.setTitle("\(commentCount)", for: .normal)
                CommonUtility().showToastMessage("Comment added successfully", vc: self)
            }
        }
    }
}

/*
http://localhost:8080/guo-news-services/api/jpa/getNewsByNewsTypeAndLanguage

Headers:

Same Above Haeders

Body:

{
"searchString":"",
"startDate":"1567083622578",
"endDate":"1567674239382",
"toStart":"0",
"recordsToBeReturned":"2"
}

Response:

{
    "result": true,
    "everyThingNewsObject": [
        {
            "id": 72,
            "newsTypeId": {
                "id": "ccp",
                "status": 1
            },
            "language": "e",
            "author": "null",
            "title": "easyway ",
            "description": "easyway ",
            "url": "NULL",
            "urlToImage": "NULL",
            "status": 1,
            "createdDate": 1567083623000,
            "modifiedDate": 1567083638000,
            "expiryDate": 1568379623000,
            "content": "NULL",
            "isTopHeadLine": 0,
            "newsId": 11211,
            "publishedAtDateString": "NULL",
            "publishedAtDateLong": 1567083622578,
            "adminApprovalBy": 1563778152644,
            "approvedDate": 1567083638000,
            "gTranslator": 1,
            "isVideo": 0,
            "customImageOrVideo": "/images/news/hong-kong-protests-at-airport-getty_1567083622567.jpg",
            "chineseAuthor": "NULL",
            "chineseTitle": "NULL",
            "chineseDescription": "NULL",
            "traditionalChineseAuthor": "空",
            "traditionalChineseTitle": "很容易",
            "traditionalChineseDescription": "很容易",
            "isHotNews": 0,
            "userNewsLikeAction": 0,
            "newsLikeCount": 0,
            "newsCommentCount": 1
        },
        {
            "id": 74,
            "newsTypeId": {
                "id": "ccp",
                "status": 1
            },
            "language": "e",
            "author": "null",
            "title": "srinivas sharma",
            "description": "srinivas sharma",
            "url": "NULL",
            "urlToImage": "NULL",
            "status": 1,
            "createdDate": 1567674239000,
            "modifiedDate": 1567674254000,
            "expiryDate": 1568970239000,
            "content": "NULL",
            "isTopHeadLine": 0,
            "newsId": 11212,
            "publishedAtDateString": "NULL",
            "publishedAtDateLong": 1567674239382,
            "adminApprovalBy": 1563778152644,
            "approvedDate": 1567674254000,
            "gTranslator": 1,
            "isVideo": 0,
            "customImageOrVideo": "/images/news/11429364-3x2-700x467_1567674239366.jpg",
            "chineseAuthor": "NULL",
            "chineseTitle": "NULL",
            "chineseDescription": "NULL",
            "traditionalChineseAuthor": "空",
            "traditionalChineseTitle": "沙尼瓦斯夏爾馬",
            "traditionalChineseDescription": "沙尼瓦斯夏爾馬",
            "isHotNews": 0,
            "userNewsLikeAction": 0,
            "newsLikeCount": 0,
            "newsCommentCount": 0
        }
    ],
    "topHeadLineNewsObject": [],
    "Code": "Ok",
    "Description": "Successful"
}
Error Response:(
 with status 500)

{
    "Error": [
        {
            "Code": "SERVICE_ERROR",
            "Message": [
                "Something went wrong,please try again later"
            ],
            "Timestamp": 1568798384838
        }
    ]
}
Bharath, 14:52
Error Response:(
 with status 500)
what hpnd suresh y feeling sad
Sureshnaidu, 14:56
if any error came, user is not satisfied, so our team feel sad
thats' why  i mentioned above picture
Bharath, 14:57
(xmassarcastic)
Sureshnaidu, 14:57
(like)
(like)
(like)
(like)
(like)
Sureshnaidu, 15:09
Team, deployed latest code in 52 server
please check it once
sreenivas, 15:10
okay ....thank you
Sureshnaidu, 15:10
Welcome Bro:)
sreenivas, 11:39
http://52.23.163.20:8080/guo-news-services/api/jpa/admin/adminGetNewsByNewsType?newsTypeId=ccp&toStart=0&recordsToBeReturned=20&operationName=approval
prasanth, 11:36
{
        "id": "cn",
        "name": "CHINA NEWS",
        "displayName": "China News",
        "chineseTraditionalName": "中國新聞"
    }
 */
