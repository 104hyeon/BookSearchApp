
import UIKit
import SnapKit

class SearchViewController: UIViewController {
    
    private var bookInfoList = [BookInfo]()
    private let bookService = BookService()
    
    
    private let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "책 제목을 검색하세요"
        searchBar.backgroundImage = UIImage()
        return searchBar
    }()
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .white
        collectionView.register(BookInfoCell.self, forCellWithReuseIdentifier: BookInfoCell.id)
        collectionView.register(
            SectionHeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: SectionHeaderView.id)
        return collectionView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        configureUI()
        setConstraints()
    }
    
    private func configureUI() {
        view.backgroundColor = .white
        [
            searchBar,
            collectionView
        ].forEach { view.addSubview($0) }
        
    }
    
    private func setConstraints() {
        searchBar.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        collectionView.snp.makeConstraints {
            $0.top.equalTo(searchBar.snp.bottom).offset(10)
            $0.bottom.equalToSuperview().inset(85)
            $0.horizontalEdges.equalTo(view.safeAreaLayoutGuide.snp.horizontalEdges)
        }
    }
    
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
        
        
        let headersize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(40))
        let header = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headersize, elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top)
        section.boundarySupplementaryItems = [header]
        
        let configuration = UICollectionViewCompositionalLayoutConfiguration()
        let layout = UICollectionViewCompositionalLayout(section: section, configuration: configuration)
        
        return layout
    }
}
// 서치바 델리게이트 관련
extension SearchViewController: UISearchBarDelegate {
    // 서치바 델리게이트 필수 함수
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        
        guard let query = searchBar.text, !query.isEmpty else { return }
        bookService.search(query: query) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let bookResponse):
                print("검색 성공. 받아온 책 개수: \(bookResponse.documents.count)")
                self.bookInfoList = bookResponse.documents
                self.collectionView.reloadData()
            case .failure(let error):
                if let networkError = error as? NetworkError {
                    print("책 검색 실패: \(networkError.errorTitle)")
                } else {
                    print("책 검색 실패: 알 수 없는 에러 (\(error.localizedDescription))")
                }
            }
        }
    }
}

// 섹션 별 타이틀
enum Section: Int, CaseIterable {
    case recentList
    case searchList
    
    var title: String {
        switch self {
        case .recentList: return "최근 본 책"
        case .searchList: return "검색 기록"
        }
    }
}

extension SearchViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return bookInfoList.isEmpty ? 0 : 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        bookInfoList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BookInfoCell.id, for: indexPath) as? BookInfoCell else {
            return UICollectionViewCell()
        }
        cell.configure(with: bookInfoList[indexPath.row])
        return cell
    }
    // 헤더뷰 인덱스 별로 타이틀 지정
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader else {
            return UICollectionReusableView()
        }
        guard let headerView = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: SectionHeaderView.id,
            for: indexPath
        ) as? SectionHeaderView else { return UICollectionReusableView() }
        
        let searchListSection = Section.allCases.first(where: { $0 == .searchList })
        
        if let title = searchListSection?.title {
            headerView.configure(with: title)
        }
        
        return headerView
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let seletedBookInfo = bookInfoList[indexPath.row]
        let modalVC = InfoModalViewController()
        modalVC.modalPresentationStyle = .fullScreen
        
        modalVC.onCartTapped = { bookInfo in
            guard let saveBookData = bookInfo.toSaveBookData() else { return }
            
            CoreDataManager.shared.saveBook(bookData: saveBookData)
            
        }
        modalVC.configure(with: seletedBookInfo)
        print("모달 뷰 present시도")
        self.present(modalVC, animated: true, completion: nil)
        print("모달뷰 present 완료")
        
    }
}


