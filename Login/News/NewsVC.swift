
// If newsresponse latest news is empty or nil then tableview headerview is set to nil
// Breaking news is called in view will appear "update localization" method. Don't call this in view did load
//

import UIKit
import AVKit
import IDMPhotoBrowser
import MarqueeLabel

class NewsVC: UIViewController {
    @IBOutlet var headerView: UIView!
    @IBOutlet var menuButton: UIButton!
    @IBOutlet var categoryCollectionView: UICollectionView!
    
    @IBOutlet var newsTableView: UITableView!
    @IBOutlet var newsTitlelabel: UILabel!
    
    //Top News
    @IBOutlet var newsHeaderView: UIView!
    @IBOutlet var topNewsContainerView: UIView!
    
    @IBOutlet var scrollingLabel: MarqueeLabel!
    
    
    private let topNewsSegue = "ShowTopNews"
    private var topNewsVC: TopNewsVC!
    
    //Cell Id
    private let categoryCellId = "CATEGORY"
    private let everythingNewsCellId = "EVERYTHING_NEWS"
    
    private var refreshFooter: YiRefreshFooter?
    private var language: String {
        get {
            if let languageStr = UserDefaults.standard.value(forKey: "AppleLanguages1") as? String {
                return (languageStr == "zh-Hant") ? "c" : "e"
            } else {
                return "e"
            }
        }
    }
    
    //Navigation bar
    private var changeLanguagePopup: ChangeLanguagePopup?
    private var popUp: KLCPopup?
    private var menuTintedImage = UIImage(named: "menu")?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
    
    //Breaking news
    @IBOutlet var breakingNewsContainerView: UIView!
    private let breakingNewsSegue = "ShowBreakingNews"
    private var breakingNewsVC: BreakingNewsVC!
    
    //News category
    private var categoryArray: [String] = [ "CHINA NEWS", "CCP NEWS", "WORLD NEWS"]
    private var categoryIdArray: [String] = ["cn", "ccp", "inn"]

    private var selectedCategoryId: String = "cn" {
        willSet {
            startIndex = 0
            callNewsAPI(newsTypeId: newValue, toStart: 0)
        }
    }
    private var startIndex: Int = 0 {
        willSet {
            if newValue == 0  // setUp for startIndex = 0
            {
                newsTableView.backgroundView = nil
                refreshFooter?.endRefreshing()
                removePullDownToRefresh()
                newsTableView.tableHeaderView = nil
                alertLabel = ""
                Utils().showProgress()
                isFetchedLatestNews = true
            }
        }
    }

    private var heightAtIndexPath = NSMutableDictionary()
    private var selectedRowIndexPath: IndexPath?
    
    private var newsResponse:NewsFeed?
    private var isFetchedLatestNews: Bool = true
    private var isDataFetched:Bool = false
    
    private var alertLabel: String = "" {
        didSet {
            newsResponse = nil
            newsTableView.reloadData()
            newsTableView.setEmptyMessage(alertLabel.localized)
        }
    }
    
    var reloadView:Bool = false // used in breaking news vc
    var headingLabel : UILabel?
    var pageControl : UIPageControl?
    
    private var commentSender: EverythingNewsCell?
    
    //MARK: FETCH NEWS
    private func callNewsAPI(newsTypeId: String, toStart: Int) {
       
        let params = ["newsTypeId": newsTypeId,
                      "toStart": "\(toStart)"]
        
        ConnectionAPI().fetchGenericData(urlString: getNewsUrl, apiType: .getNews, params: params, sBlock: { (data: NewsFeed) in
            Utils.hideProgress()
         
            let response = data
            response.setAppLanguage()
            
            if toStart == 0 {
                self.newsResponse = response
                
                if response.latestNewsHeadlines.count == 0 {
                    self.isFetchedLatestNews = false
                }
                
                if response.topHeadlines.count == 0 { 
                    self.newsTableView.tableHeaderView = nil
                } else {
                    self.newsTableView.tableHeaderView = self.newsHeaderView
                    self.topNewsVC.topNewsHeadlines = response.topHeadlines
                }
                
                if response.topHeadlines.count == 0 && response.latestNewsHeadlines.count == 0 {
                    self.alertLabel = "Unable to retrieve data, please retry after sometime"
                }
            
            }
   
            if self.isFetchedLatestNews == false {
            
                self.newsResponse?.addLatestHeadlines(response.topHeadlines)
                
                if response.topHeadlines.count < 10 {
                    self.removePullDownToRefresh()
                }
                else if response.topHeadlines.count >= 10 {
                    self.addPullDowntoRefresh()
                }
                
            } else {
                if toStart != 0 {
                    self.newsResponse?.addLatestHeadlines(response.latestNewsHeadlines)
                }
        
                if response.latestNewsHeadlines.count < 10 {
                    self.removePullDownToRefresh()
                }
                else if response.latestNewsHeadlines.count >= 10
                {
                    self.addPullDowntoRefresh()
                }
            }

            self.startIndex = self.startIndex + 10
    
            self.newsTableView.reloadData()
    
        }, fBlock: { customErrorMsg, errorCode in
            Utils.hideProgress()
            if toStart == 0 {
                self.alertLabel = "Unable to retrieve data, please retry after sometime"
            } else {
                self.removePullDownToRefresh()
            }
        })
    }

    
    //MARK: SETUP VIEW
    private func setUpViews(){
        let tabBarHeight:CGFloat = self.tabBarController?.tabBar.frame.size.height ?? 68
        self.tabBarController?.tabBar.isHidden = true
        
        if #available(iOS 11.0, *) {
            newsTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: tabBarHeight).isActive = true
        } else {
            newsTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: tabBarHeight).isActive = true
        }
        
        reloadView = false
    }
    
    private func setNotifications() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name("Update_news_screen"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateLocalisation), name: NSNotification.Name(rawValue: "Update_news_screen"), object: nil)
    }
    
    private func setNavigationBar() {
        newsTitlelabel.text = "GNews".localized
        //menuButton.setImage(menuTintedImage, for: .normal)
        //menuButton.tintColor = CustomColor.categoryCustomColor_red
    }
  
    //MARK: IBAction
    
    @IBAction func searchButtonTapped(_ sender: UIButton) {
        
        reloadView = true
        
        let vc = UIStoryboard.init(name: "Library", bundle: Bundle.main).instantiateViewController(withIdentifier: "SEARCH") as? SearchVC
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
    @IBAction func changeLanguagePopup(_ sender: UIBarButtonItem) {
        
        changeLanguagePopup = (UIStoryboard.init(name: "Main_Monika", bundle: Bundle.main).instantiateViewController(withIdentifier: "ChangeLanguagePopup") as? ChangeLanguagePopup)!
        
        let layout: KLCPopupLayout = KLCPopupLayoutMake(.center, .center)
        popUp = KLCPopup(contentView: changeLanguagePopup?.view, showType: .bounceIn, dismissType: .bounceOut, maskType: .dimmed, dismissOnBackgroundTouch: true, dismissOnContentTouch: false)
        
        popUp?.show(with: layout)
        
    }
    
    @IBAction func revealSlidingMenu(_ sender: Any) {
        self.frostedViewController.view.endEditing(true)
        self.frostedViewController.presentMenuViewController()
    }
    
    @objc func updateLocalisation() {
        setNavigationBar()
        
        self.categoryCollectionView.reloadData()
    
        //----- If parent view controller is LibraryVC then set the selected category to 0th index ----
        if selectedCategoryId == "ccp"  {
            selectedCategoryId = "cn"
            categoryCollectionView.reloadData()
        } else {
            newsResponse?.setAppLanguage()
            self.topNewsVC.topNewsHeadlines = newsResponse?.topHeadlines
            newsTableView.reloadData()
        }
        
        self.callBreakingNewsAPI()
    }
    
    
    //MARK: REFRESH FOOTER
    
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
            refreshFooter.scrollView = newsTableView
            refreshFooter.footer()
        }
    }
    
    //MARK: Register Cells
    
    private func registerCells() {
        newsTableView.register(UINib(nibName: "EverythingCell", bundle: nil), forCellReuseIdentifier: everythingNewsCellId)
    }
    
    
    //MARK:VIEWCONTROLLER LIFE CYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollingLabel.marqueeType = .MLContinuous
        scrollingLabel.animationDelay = 3.0
        scrollingLabel.rate = 60
        /*var gradientColor = CAGradientLayer();
        gradientColor.colors = [UIColor.red.cgColor,UIColor(red: 123.0/255.0, green: 0/255.0, blue: 0/255.0, alpha: 1.0)];
        gradientColor.frame = scrollingLabel.frame;
        gradientColor.startPoint = CGPoint(x: 0.0, y: 0.5);
        gradientColor.endPoint = CGPoint(x:1.0, y:0.5);
        scrollingLabel.layer.addSublayer(gradientColor);*/
        scrollingLabel.backgroundColor = UIColor(red: 223.0/255.0, green: 65.0/255.0, blue: 57.0/255.0, alpha: 1.0);
        scrollingLabel.fadeLength = 0.0
        scrollingLabel.leadingBuffer = 10.0
        scrollingLabel.trailingBuffer = 20.0
        scrollingLabel.textAlignment = .left
        
        setUpViews()
        setNavigationBar()
        setNotifications()
        
        registerCells()
        
        refreshFooter = YiRefreshFooter.init()
        
        selectedCategoryId = "cn"
       
        weak var weakSelf = self
        refreshFooter?.beginRefreshingBlock = {
            
            DispatchQueue.global(qos: .default).async(execute: {
                sleep(1)
                weakSelf?.callNewsAPI(newsTypeId:weakSelf?.selectedCategoryId ?? "cn" , toStart:weakSelf?.startIndex ?? 0)
            })
        }
        headerView.backgroundColor = UIColor(red: 35.0/255.0, green: 33.0/255.0, blue: 33.0/255.0, alpha: 1.0);
        
        /*let colorsArray = [UIColor(red: 71.0/255.0, green: 71.0/255.0, blue: 71.0/255.0, alpha: 1.0).cgColor,UIColor(red: 25.0/255.0, green: 19.0/255.0, blue: 19.0/255.0, alpha: 1.0).cgColor]
        let gradientColor = CAGradientLayer();
        gradientColor.colors = colorsArray;
        gradientColor.frame = headerView.bounds;
        headerView.layer.addSublayer(gradientColor);
        gradientColor.startPoint = CGPoint(x: 0.0, y: 0.5);
        gradientColor.endPoint = CGPoint(x:1.0, y:0.5);*/
        headerView.backgroundColor = UIColor(red: 35.0/255.0, green: 33.0/255.0, blue: 32.0/255.0, alpha: 1.0);
 
    }
    
    override func viewWillAppear(_ animated: Bool) {

        
        if !(reloadView){
            updateLocalisation()
        } else {
            reloadView = !reloadView
        }

        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if !(reloadView) {
            removePullDownToRefresh()
        }
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
}


//MARK:COLLECTION VIEW
extension NewsVC:UICollectionViewDelegate, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return categoryArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell : UICollectionViewCell  = categoryCollectionView.dequeueReusableCell(withReuseIdentifier: categoryCellId, for: indexPath)
        
        let categoryId = categoryIdArray[indexPath.item]
        let categoryName:UILabel = cell.contentView.viewWithTag(1) as! UILabel
        categoryName.text = categoryArray[indexPath.row].localized
        categoryName.font = language == "e" ? CustomFont.categoryLabelFont : CustomFont.categoryLabelCnFont
        
        if let underlineView:UIView = cell.contentView.viewWithTag(2) {
            underlineView.backgroundColor = (categoryId == selectedCategoryId) ? UIColor(red: 122.0/255.0, green: 41.0/255.0, blue: 40.0/255.0, alpha: 1.0) : .clear
            categoryName.textColor = (categoryId == selectedCategoryId) ? CustomColor.categoryCustomColor_red : CustomColor.categoryCustomColor_gray
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        /*return CGSize(width: (categoryCollectionView.frame.width -  10)/3.0, height: categoryCollectionView.frame.height)*/
        return CGSize(width:self.view.bounds.size.width / 3 , height: categoryCollectionView.frame.height);
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        selectedCategoryId = categoryIdArray[indexPath.item]
        
        let vc = UIStoryboard.init(name: "News", bundle: Bundle.main).instantiateViewController(withIdentifier: "LIBRARY") as? LibraryVC
        
        if selectedCategoryId == "ccp" {
            vc?.categoryArray = ["MILES EXPOSES","PEOPLE REVEALED","CENSORED"]
            vc?.categoryIdArray = ["cme","cpr","ccn"]
            
            self.navigationController?.pushViewController(vc!, animated: true)
        }

        categoryCollectionView.reloadData()
    }
    
}

//MARK:-  Top News

extension NewsVC {
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        newsTableView.tableHeaderView?.frame.size = CGSize(width: newsTableView.frame.width, height: view.frame.height * 0.3)
    }
}

//MARK:- TABLEVIEW
extension NewsVC:UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate {
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let pageNum = scrollView.contentOffset.x / scrollView.bounds.size.width
        pageControl?.currentPage = Int(pageNum)
        
        switch pageNum {
        case 0:
            headingLabel?.text = "China's Mysterious Billionare, Guo Wengui | China Uncensored"
        case 1:
            headingLabel?.text = "China launches three new satellites"

        case 2:
            headingLabel?.text = "Beijing set to exit list of world's top 200 most-polluted cities"

        case 3:
            headingLabel?.text = "China to boost pork output as swine fever drives up prices"

        case 4:
            headingLabel?.text = "China calls for continuation of Afghan peace talks"

        default:
            break
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view : UIView = Bundle.main.loadNibNamed("NewsHeaderView", owner: nil, options: nil)?[0] as! UIView
        let scroll = view.viewWithTag(987) as! UIScrollView
        headingLabel = view.viewWithTag(985) as? UILabel
        pageControl = view.viewWithTag(986) as? UIPageControl

        let scrollViewWidth = scroll.bounds.size.width
        let scrollViewHeight = scroll.bounds.size.height
        
        let img1 = UIImageView(frame: CGRect(x: 0, y: 0, width: scrollViewWidth, height: scrollViewHeight))
        img1.image = UIImage.init(named: "1")
        
        let img2 = UIImageView(frame: CGRect(x: scrollViewWidth, y: 0, width: scrollViewWidth, height: scrollViewHeight))
        img2.image = UIImage.init(named: "2")
        
        let img3 = UIImageView(frame: CGRect(x: scrollViewWidth * 2, y: 0, width: scrollViewWidth, height: scrollViewHeight))
        img3.image = UIImage.init(named: "3")
        
        let img4 = UIImageView(frame: CGRect(x: scrollViewWidth * 3, y: 0, width: scrollViewWidth, height: scrollViewHeight))
        img4.image = UIImage.init(named: "4")
        
        let img5 = UIImageView(frame: CGRect(x: scrollViewWidth * 4, y: 0, width: scrollViewWidth, height: scrollViewHeight))
        img5.image = UIImage.init(named: "5")
        
        scroll.addSubview(img1)
        scroll.addSubview(img2)
        scroll.addSubview(img3)
        scroll.addSubview(img4)
        scroll.addSubview(img5)
        
        scroll.contentSize = CGSize.init(width: scrollViewWidth * 5, height: scrollViewHeight)
        scroll.delegate = self
        return view;
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return self.newsTableView.tableHeaderView == nil ? 350 : 0
    }
   
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let latestNewsCount = newsResponse?.latestNewsHeadlines.count ?? 0
        return latestNewsCount
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = newsTableView.dequeueReusableCell(withIdentifier: everythingNewsCellId, for: indexPath) as! EverythingNewsCell
        cell.newsHeadline = newsResponse?.latestNewsHeadlines[indexPath.row]
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        newsResponse?.latestNewsHeadlines[indexPath.row].togglePosition()
        selectedRowIndexPath = indexPath
        newsTableView.reloadRows(at: [indexPath], with: .none)
    }
   
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let height = NSNumber(value: Float(cell.frame.size.height))
        heightAtIndexPath.setObject(height, forKey: indexPath as NSCopying)
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {

        if selectedRowIndexPath != nil {
            selectedRowIndexPath = nil
            return UITableView.automaticDimension
        } else {
            if let height = heightAtIndexPath.object(forKey: indexPath) as? NSNumber {
                return CGFloat(height.floatValue)
            } else {
                return UITableView.automaticDimension
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return UITableView.automaticDimension
    }
}

//MARK: Tableview prefetch delegate

extension NewsVC: UITableViewDataSourcePrefetching {
    
       func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
           print("prefetchRowsAt \(indexPaths)")
          
       }
       
       func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
           print("cancelPrefetchingForRowsAt \(indexPaths)")
           
       }
    
}


//MARK:- Everything Cell Delegate

extension NewsVC: EverythingCellDelegate {
    
    func newsTableCellDidTapMore(_ sender: EverythingNewsCell) {
        
        if let url = sender.newsHeadline?.url {
            
            reloadView = true
            
            if url.caseInsensitiveCompare("null") != .orderedSame {
                CommonUtility().openWebViewWithUrl(url, vc: self)
            } else {
                if let id = sender.newsHeadline?.newsId {
                    let url = newsShareURL + String(id)
                    CommonUtility().openWebViewWithUrl(url, vc: self)
                }
            }
        }
    }
    
    func newsPlayButtonAction(_ sender: EverythingNewsCell, customImageVideo: String) {
        
        reloadView = true
        
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
    
    func newsTableCellDidTapViewComments(_ sender: EverythingNewsCell) {
        guard let headline = sender.newsHeadline else { return }
        
        let vc = UIStoryboard.init(name: "Library", bundle: Bundle.main).instantiateViewController(withIdentifier: "VIEWCOMMENTS") as? NewsDetailVC
        vc?.headline = headline
        vc?.parentEverythingCell = sender
        reloadView = true
        self.navigationController?.pushViewController(vc!, animated: true)
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
        reloadView = true
        self.present(presentedViewController, animated: true, completion: nil)
    }
    
    func translateButtonTapped(_ sender: EverythingNewsCell) {
        guard let indexPath = newsTableView.indexPath(for: sender) else { return }
        newsResponse?.latestNewsHeadlines[indexPath.row].toggleLanguage()
        self.newsTableView.reloadRows(at: [indexPath], with: .none)
    }
    
    //MARK: Like button action
    func addLikeDisLikeTapped(_ sender: EverythingNewsCell) {
        
        CommonUtility().newsLikeButtonTapped(sender)
    }
    
   
}

extension NewsVC: PopUpCommentDelegate {
    
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

//MARK: BREAKING NEWS

extension NewsVC {
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == breakingNewsSegue {
            if let breakingNewsVC = segue.destination as? BreakingNewsVC {
                self.breakingNewsVC = breakingNewsVC
                breakingNewsVC.parentNewsVC = self
            }
        }
        
        if segue.identifier == topNewsSegue {
            if let topNewsVC = segue.destination as? TopNewsVC {
                self.topNewsVC = topNewsVC
                topNewsVC.parentNewsVC = self
            }
        }
    }
    
    private func callBreakingNewsAPI() {
        
       // breakingNewsVC.alertLabel = ""
        
        let params = ["newsTypeId": "abr"]
        
        ConnectionAPI().fetchGenericData(urlString: getNewsUrl, apiType: .getBreakingNews, params: params, sBlock: { (data: NewsFeed) in
            
            let response = data
            response.setAppLanguage()
            
            if response.latestNewsHeadlines.isEmpty {
                //self.breakingNewsVC.alertLabel = "No Breaking News at this moment"
                self.scrollingLabel.text = "No Breaking News at this moment".localized
            } else {
                let scrollingNews = response.appendNews()
                //print("scrollingNews", scrollingNews)
                self.scrollingLabel.text = scrollingNews
                //self.breakingNewsVC.breakingNewsHeadlines = response.latestNewsHeadlines
            }
    
        }, fBlock: { customErrorMsg, errorCode in
            //self.breakingNewsVC.alertLabel = "No Breaking News at this moment"
            self.scrollingLabel.text = "No Breaking News at this moment".localized
        })
    }
}


