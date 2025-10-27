
import UIKit
import SnapKit

class TabBarController: UITabBarController {
    
    let searchVC = SearchViewController()
    let cartVC = CartViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
    }
    
    init() {
        super.init(nibName: nil, bundle: nil)
        
        searchVC.tabBarItem = UITabBarItem(
            title: "검색 하기",
            image:  UIImage(systemName: "magnifyingglass"),
            tag: 0
        )
        cartVC.tabBarItem = UITabBarItem(
            title: "담은 책 보기",
            image: UIImage(systemName: "cart"),
            tag: 1
        )
        
        let tabs = [searchVC, cartVC]
        self.setViewControllers(tabs, animated: false)

    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
