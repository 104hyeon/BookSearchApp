
import UIKit
import SnapKit

class CartViewController: UIViewController {

    var cartItems: [BookInfo] = []
    
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .white
        collectionView.register(BookInfoCell.self, forCellWithReuseIdentifier: BookInfoCell.id)
        return collectionView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        setConstraints()
        setupNavigationBar()
        setupNotification()
        loadCartData()
    }
    
    private func configureUI() {
        view.backgroundColor = .white
        [ collectionView ].forEach { view.addSubview($0) }
    }
    
    private func setConstraints() {
        collectionView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            $0.horizontalEdges.equalTo(view.safeAreaLayoutGuide.snp.horizontalEdges)
        }
    }
    
    private func loadCartData() {
        CoreDataManager.shared.fetchBooks()
        self.cartItems = CoreDataManager.shared.cartItems ?? []
        collectionView.reloadData()
    }
    
    private func setupNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(handelCartUpdate), name: .cartUpdated, object: nil)
    }
    
    @objc
    private func handelCartUpdate() {
        DispatchQueue.main.async {
            self.loadCartData()
        }
    }
    // 상단 내비게이션바 설정
    private func setupNavigationBar() {
        navigationItem.title = "담은 책 보기"
        
        let deleteAllButton = UIBarButtonItem(title: "전체 삭제", style: .plain, target: self, action: #selector(deleteAllTapped))
        navigationItem.leftBarButtonItem = deleteAllButton
        
        let addButton = UIBarButtonItem(title: "추가", style: .plain, target: self, action: #selector(addTapped))
        navigationItem.rightBarButtonItem = addButton
    }
    // 전체 삭제 액션
    @objc
    private func deleteAllTapped() {
        self.makeAlert(title: "전체 삭제", message: "모든 데이터가 사라집니다. 삭제 하시겠습니까?" , cancleAction: { _ in },
                       checkAction: { [weak self] _ in
            CoreDataManager.shared.deleteAll()
            self?.loadCartData()
        })
    }
    // 추가 버튼 액션
    @objc
    private func addTapped() {
        self.tabBarController?.selectedIndex = 0
    }
    // 컬렉션뷰 레이아웃 설정
    private func createLayout() -> UICollectionViewLayout {
        let itemsize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalHeight(1.0)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemsize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(60)
        )
        
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        
        
        section.interGroupSpacing = 5
        section.contentInsets = .init(top: 10, leading: 10, bottom: 10, trailing: 10)
        let configuration = UICollectionViewCompositionalLayoutConfiguration()
        let layout = UICollectionViewCompositionalLayout(section: section, configuration: configuration)
        
        return layout
    }
    // 셀 개별 삭제
    private func deleteItem(at indexPath: IndexPath) {
        let bookToDelete = cartItems[indexPath.item]
        guard let isbn = bookToDelete.isbn else {
            return
        }
        CoreDataManager.shared.deleteBook(with: isbn)
        
        cartItems.remove(at: indexPath.item)
        collectionView.deleteItems(at: [indexPath])
    }

}

extension CartViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cartItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BookInfoCell.id, for: indexPath) as? BookInfoCell else {
            return UICollectionViewCell()
        }
        let book = cartItems[indexPath.item]
        cell.configure(with: book)
        
        return cell
    }
}

extension CartViewController {
    func makeAlert(title: String,
                   message: String,
                   cancleAction: ((UIAlertAction) -> Void)? = nil,
                   checkAction: ((UIAlertAction) -> Void)? = nil,
                   completion: (() -> Void)? = nil) {
        let alretVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let cancleAction = UIAlertAction(title: "취소", style: .default, handler: cancleAction)
        alretVC.addAction(cancleAction)
        let checkAction = UIAlertAction(title: "확인", style: .default, handler: checkAction)
        alretVC.addAction(checkAction)
        
        self.present(alretVC, animated: true)
    }
}
