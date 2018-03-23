 
 import UIKit
 import Firebase
 import FirebaseAuth
 import FaceAware
 
 
 class HomeViewController: UITabBarController,UITabBarControllerDelegate  {
   
    lazy var viewControllerList: [UIViewController] = {
        let homeFeedController = HomeFeedController(collectionViewLayout: UICollectionViewFlowLayout())
        let navController = UINavigationController(rootViewController: homeFeedController)
        navController.tabBarItem.image = UIImage(named: "icons8-home-page-50")?.withRenderingMode(.alwaysOriginal)
        navController.tabBarItem.selectedImage = UIImage(named: "icons8-home-page-filled-50")?.withRenderingMode(.alwaysOriginal)

        //        let navController = ScrollingNavigationController(rootViewController: homeFeedController)

        
        let profileView = ProfileeViewController(collectionViewLayout: UICollectionViewFlowLayout())
        let profileViewNavController = UINavigationController(rootViewController: profileView)
        profileViewNavController.tabBarItem.image = UIImage(named: "icons8-User-50")?.withRenderingMode(.alwaysOriginal)
        profileViewNavController.tabBarItem.selectedImage = UIImage(named: "icons8-User Filled-50")?.withRenderingMode(.alwaysOriginal)

        let searchController = EventSearchController(collectionViewLayout: UICollectionViewFlowLayout())
        let searchNavController = UINavigationController(rootViewController: searchController)
        
        searchNavController.tabBarItem.image =  UIImage(named: "icons8-search-50")?.withRenderingMode(.alwaysOriginal)
        searchNavController.tabBarItem.selectedImage =  UIImage(named: "icons8-search-filled-50")?.withRenderingMode(.alwaysOriginal)

        let notificationView = NotificationsViewController()
        let notificationNavController = UINavigationController(rootViewController: notificationView)
        notificationNavController.tabBarItem.image = UIImage(named: "icons8-Notification-50")?.withRenderingMode(.alwaysOriginal)
        notificationNavController.tabBarItem.selectedImage = UIImage(named: "icons8-Notification Filled-50")?.withRenderingMode(.alwaysOriginal)

        
        return [navController
            ,searchNavController,notificationNavController,profileViewNavController]
    }()

    let appDelegate = UIApplication.shared.delegate as! AppDelegate

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        viewControllers = viewControllerList
        guard let items = tabBar.items else {
            return
        }
        for item in items{
            item.imageInsets = UIEdgeInsets(top: 4, left: 0, bottom: -4, right: 0)
        }
        //will set the defuat index to homeFeedController
    }

 }
 

 

