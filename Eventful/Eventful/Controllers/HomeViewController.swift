 
 import UIKit
 import Firebase
 import FirebaseAuth
 import AMScrollingNavbar
 
 
 class HomeViewController: UIViewController  {
    
    fileprivate var pageController:UIPageViewController!
    fileprivate var topCollectionView:UICollectionView!
    lazy var viewControllerList: [UIViewController] = {
        let homeFeedController = HomeFeedController()
        let navController = UINavigationController(rootViewController: homeFeedController)
//        let navController = ScrollingNavigationController(rootViewController: homeFeedController)

        
        let profileView = ProfileeViewController(collectionViewLayout: UICollectionViewFlowLayout())
        let profileViewNavController = UINavigationController(rootViewController: profileView)
        
        let searchController = EventSearchController(collectionViewLayout: UICollectionViewFlowLayout())
        let searchNavController = UINavigationController(rootViewController: searchController)
        
        return [searchNavController,navController,profileViewNavController]
    }()
    fileprivate var selectedTopIndex:Int!

    let topImages: [UIImage] = {
        return [#imageLiteral(resourceName: "night"), #imageLiteral(resourceName: "home"), #imageLiteral(resourceName: "summer")]
    }()
    let topCell = "topCell"

    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureViews()
    }
    
    fileprivate func configureViews() {
        self.selectedTopIndex = 1
        self.view.backgroundColor = .white
        self.automaticallyAdjustsScrollViewInsets = false
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        self.topCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        self.topCollectionView.translatesAutoresizingMaskIntoConstraints = false
        self.topCollectionView.dataSource = self
        self.topCollectionView.delegate = self
        self.topCollectionView.backgroundColor = .white
        self.topCollectionView.register(ImageCollectionViewCell.self, forCellWithReuseIdentifier: topCell)
        self.view.addSubview(self.topCollectionView)
        NSLayoutConstraint.activateViewConstraints(self.topCollectionView, inSuperView: self.view, withLeading: 0.0, trailing: 0.0, top: nil, bottom: nil, width: nil, height: 50.0)
        _ = NSLayoutConstraint.activateVerticalSpacingConstraint(withFirstView: self.topLayoutGuide, secondView: self.topCollectionView, andSeparation: 0.0)
        
        self.pageController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        self.pageController.dataSource = self
        self.pageController.delegate = self
        let firstViewController = viewControllerList[1]
        self.pageController.setViewControllers([firstViewController], direction: .forward, animated: true, completion: nil)
        self.addChildViewController(self.pageController)
        self.view.addSubview(self.pageController.view)
        self.pageController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activateViewConstraints(self.pageController.view, inSuperView: self.view, withLeading: 0.0, trailing: 0.0, top: nil, bottom: nil)
        _ = NSLayoutConstraint.activateVerticalSpacingConstraint(withFirstView: self.topCollectionView, secondView: self.pageController.view, andSeparation: 0.0)
        _ = NSLayoutConstraint.activateVerticalSpacingConstraint(withFirstView: self.pageController.view, secondView: self.bottomLayoutGuide, andSeparation: 0.0)
        self.pageController.didMove(toParentViewController: self)
    }
    
    fileprivate func performActionOnTopItemSelect(at index:Int) {
        let current = IndexPath(item: index, section: 0)
        var indexPaths:[IndexPath] = [current]
            if self.selectedTopIndex == index {
                return
            }
            else {
                let old = IndexPath(item: self.selectedTopIndex!, section: 0)
                indexPaths.append(old)
                self.selectedTopIndex = index
            }

        self.topCollectionView.performBatchUpdates({
            self.topCollectionView.reloadItems(at: indexPaths)
        }, completion: nil)
    }
 }
 
 extension HomeViewController: UIPageViewControllerDataSource {
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
        debugPrint("##### Home previousIndex Index: \(previousIndex)")
        //going left
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
        debugPrint("##### Home nextIndex Index: \(nextIndex)")
        //going right
        return viewControllerList[nextIndex]
    }
 }
 
 extension HomeViewController: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        let pageContentViewController = pageViewController.viewControllers![0]
        let current = self.viewControllerList.index(of: pageContentViewController)
        self.performActionOnTopItemSelect(at: current!)
    }
 }
 
 // MARK: - UICollectionViewDelegateFlowLayout
 extension HomeViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if self.selectedTopIndex != indexPath.item {
            let viewController = viewControllerList[indexPath.item]
            var direction:UIPageViewControllerNavigationDirection = .reverse
            if self.selectedTopIndex < indexPath.item {
                direction = .forward
            }
            self.pageController.setViewControllers([viewController], direction: direction, animated: true, completion: nil)
            self.performActionOnTopItemSelect(at: indexPath.item)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 44.0, height: collectionView.bounds.size.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(0.0, 30.0, 0.0, 30.0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return (collectionView.bounds.size.width - 192.0)/2
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 15.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return .zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return .zero
    }
 }
 
 // MARK: - UICollectionViewDataSource
 extension HomeViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: topCell, for: indexPath) as! ImageCollectionViewCell
        cell.imageView.image = self.topImages[indexPath.row]
        var selected = false
        if self.selectedTopIndex != nil && self.selectedTopIndex == indexPath.item {
            selected = true
        }
        cell.imageView.tintColor = selected ? UIColor.logoColor : UIColor.white
        cell.bottomBar.backgroundColor = selected ? UIColor.logoColor : UIColor.clear
        return cell
    }
 }
 
 

