
import UIKit
import SnapKit

class CartViewController: UIViewController {

    var cartItems: [BookInfo] = []
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .white
        tableView.rowHeight = 70
        tableView.separatorStyle = .none
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(BookInfoTableCell.self, forCellReuseIdentifier: BookInfoTableCell.id)
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        setConstraints()
        setupNavigationBar()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        loadCartData()
    }
    
    private func configureUI() {
        view.backgroundColor = .white
        [ tableView ].forEach { view.addSubview($0) }
    }
    
    private func setConstraints() {
        tableView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            $0.leading.trailing.equalToSuperview()
        }
    }
    
    private func loadCartData() {
        self.cartItems = CoreDataManager.shared.fetchBooks()
        tableView.reloadData()
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

    // 셀 개별 삭제
    private func deleteItem(at indexPath: IndexPath) {
        let bookToDelete = cartItems[indexPath.row]
        guard let isbn = bookToDelete.isbn else {
            return
        }
        CoreDataManager.shared.deleteBook(with: isbn)
        
        cartItems.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .automatic)
    }

}

extension CartViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cartItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: BookInfoTableCell.id, for: indexPath) as? BookInfoTableCell else {
            return UITableViewCell()
        }
        let book = cartItems[indexPath.row]
        cell.configure(with: book)

        return cell
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "삭제") { [weak self] (action, view, complicationHandler) in
            self?.deleteItem(at: indexPath)
            complicationHandler(true)
        }
        deleteAction.image = UIImage(systemName: "trash")
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        configuration.performsFirstActionWithFullSwipe = false
        return configuration
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
