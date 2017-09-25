 
 import UIKit
 import Firebase
 import FirebaseAuth
 import AMScrollingNavbar

 
 class HomeViewController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate  {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.dataSource = self
        self.delegate = self
        self.automaticallyAdjustsScrollViewInsets = false
         let firstViewController = viewControllerList[1] 
         self.setViewControllers([firstViewController], direction: .forward, animated: true, completion: nil)
        // setupView()
    }
    lazy var viewControllerList: [UIViewController] = {
        let homeFeedController = HomeFeedController()
        let navController = ScrollingNavigationController(rootViewController: homeFeedController)
        let profileView = ProfileeViewController(collectionViewLayout: UICollectionViewFlowLayout())
        let profileViewNavController = UINavigationController(rootViewController: profileView)
        let searchController = EventSearchController(collectionViewLayout: UICollectionViewFlowLayout())
        let searchNavController = UINavigationController(rootViewController: searchController)
        
        return [searchNavController,navController,profileViewNavController]
    }()
    
    override init(transitionStyle style: UIPageViewControllerTransitionStyle, navigationOrientation: UIPageViewControllerNavigationOrientation, options: [String : Any]? = nil) {
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal, options: options)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let vcIndex = viewControllerList.index(of: viewController) else{
            return nil
        }
        let previousIndex = vcIndex - 1
        guard previousIndex >= 0 else {
            return nil
        }
        guard viewControllerList.count > previousIndex else{
            return nil
        }
        return viewControllerList[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        guard let vcIndex = viewControllerList.index(of: viewController) else{
            return nil
        }
        let nextIndex = vcIndex + 1
        guard viewControllerList.count != nextIndex else{
            return nil
        }
        guard viewControllerList.count > nextIndex else{
            return nil
        }
        
        return viewControllerList[nextIndex]
        
    }
    
 }
