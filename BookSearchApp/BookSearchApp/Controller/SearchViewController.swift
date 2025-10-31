
import UIKit
import SnapKit

class SearchViewController: UIViewController {
    
    private var searchBookList = [BookInfo]()
    private var recentBookList = [BookInfo]()
    private var activeSections: [Section] = []
    private let bookService = BookService()
    // 페이지네이션 상태관리용 변수
    private var currentPage: Int = 1             // 현재 불러온 페이지 번호
    private var isPaginating: Bool = false         // 현재 데이터를 불러오는 중인지 확인(중복 방지)
    private var hasMoreData: Bool = true          // 다음 페이지 데이터가 더 있는지 확인
    private var currentQuery: String?       // 현재 검색된 쿼리
    
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
        collectionView.register(ThumbnailCell.self, forCellWithReuseIdentifier: ThumbnailCell.id)
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
        [ searchBar, collectionView ].forEach { view.addSubview($0) }
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
    // 전체 컬렉션뷰 레이아웃
    private func createLayout() -> UICollectionViewCompositionalLayout {
        let layout = UICollectionViewCompositionalLayout { [weak self] (sectionIndex, enviroment) -> NSCollectionLayoutSection? in
            guard let self = self else { return nil }
            guard let currentSection = self.getSectionType(for: sectionIndex) else { return nil }
            
            switch currentSection {
            case .recentList: return self.recentLayout()
            case .searchList: return self.searchLayout()
            }
        }
        return layout
    }
    
    // "최근 본 책" 레이아웃
    private func recentLayout() ->NSCollectionLayoutSection {
        let itemsize = NSCollectionLayoutSize(
            widthDimension: .absolute(80),
            heightDimension: .absolute(80)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemsize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .absolute(80),
            heightDimension: .absolute(80)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .continuous
        section.interGroupSpacing = 5
        section.contentInsets = .init(top: 10, leading: 10, bottom: 10, trailing: 10)
        
        let headersize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(40))
        let header = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headersize, elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top)
        section.boundarySupplementaryItems = [header]
        return section
    }
    // "검색 결과" 레이아웃
    private func searchLayout() -> NSCollectionLayoutSection {
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
        
        return section
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
    
    // 데이터 로드 후 activeSections에 배열 업데이트
    private func updatedActiveSections() {
        activeSections = []
        
        // 섹션 순서 고정하기
        for sectionCase in Section.allCases {
            switch sectionCase {
            case .recentList:
                if !recentBookList.isEmpty {
                    activeSections.append(.recentList)
                }
            case .searchList:
                if !searchBookList.isEmpty {
                    activeSections.append(.searchList)
                }
            }
        }
    }
    
    // 인덱스에 매핑된 섹션 찾는 함수
    private func getSectionType(for index: Int) -> Section? {
        guard index >= 0, index < activeSections.count else { return nil }
        return activeSections[index]
    }
}

// 서치바 델리게이트 관련
extension SearchViewController: UISearchBarDelegate {
    // 서치바 델리게이트 필수 함수
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        
        guard let query = searchBar.text, !query.isEmpty else { return }
        // 첫 검색 시 상태 초기화
        self.currentPage = 1
        self.hasMoreData = true
        self.currentQuery = query
        self.searchBookList = []
        
        requestSearch(query: query, page: self.currentPage)
    }
    
    private func requestSearch(query: String, page: Int) {
        // 중복 요청 방지
        guard !isPaginating && hasMoreData else { return }
        self.isPaginating = true
        
        bookService.search(query: query, page: page) { [weak self] result in
            defer { self?.isPaginating = false }
            guard let self = self else { return }
            switch result {
            case .success(let bookResponse):
                print("검색 성공. 현재 페이지: \(page), 받아온 책 개수: \(bookResponse.documents.count)")
                // 마지막 데이터 확인하고 10보다 적으면 끝냄
                if bookResponse.documents.count < 10 {
                    self.hasMoreData = false
                }
                // 데이터랑 페이지 추가
                self.searchBookList.append(contentsOf: bookResponse.documents)
                self.currentPage += 1
                
                self.updatedActiveSections()
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

// 컬렉션뷰 델리게이트, 데이터소스 관련
extension SearchViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return activeSections.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let currentSetion = getSectionType(for: section) else { return 0 }
        switch currentSetion {
        case .recentList: return recentBookList.count
        case .searchList: return searchBookList.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let currentSection = getSectionType(for: indexPath.section) else { return UICollectionViewCell() }

        switch currentSection {
        case .recentList:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ThumbnailCell.id, for: indexPath) as? ThumbnailCell else { return UICollectionViewCell() }
            let bookInfo = recentBookList[indexPath.item]
            cell.configure(with: bookInfo)
            return cell
        case .searchList:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BookInfoCell.id, for: indexPath) as? BookInfoCell else { return UICollectionViewCell() }
            let bookInfo = searchBookList[indexPath.item]
            cell.configure(with: bookInfo)
            return cell
        }
    }
    // 헤더뷰 타이틀 지정해주는 함수
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader else {
            return UICollectionReusableView()
        }
        guard let headerView = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind, withReuseIdentifier: SectionHeaderView.id, for: indexPath
        ) as? SectionHeaderView else {
            return UICollectionReusableView()
        }
        guard let currentSection = getSectionType(for: indexPath.section) else {
            return UICollectionReusableView() }
        headerView.configure(with: currentSection.title)
        return headerView
    }
    // 셀 눌렸을 때 실행 될 함수
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let currentSection = getSectionType(for: indexPath.section) else { return }
        let selectedBookInfo: BookInfo
        
        switch currentSection {
        case .searchList:
            selectedBookInfo = searchBookList[indexPath.item]
            if let index = recentBookList.firstIndex(where: { $0.isbn == selectedBookInfo.isbn }) {
                recentBookList.remove(at: index)
            }
            recentBookList.insert(selectedBookInfo, at: 0)
            updatedActiveSections()
            collectionView.reloadData()
        case .recentList:
            selectedBookInfo = recentBookList[indexPath.item]
        }
        
        let modalVC = InfoModalViewController()
        modalVC.modalPresentationStyle = .fullScreen
        
        modalVC.onCartTapped = { bookInfo in
            guard let saveBookData = bookInfo.toSaveBookData() else { return }
            CoreDataManager.shared.saveBook(bookData: saveBookData)
        }
        modalVC.configure(with: selectedBookInfo)
        self.present(modalVC, animated: true, completion: nil)
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let frameHeight = scrollView.frame.size.height
        
        if offsetY > contentHeight - frameHeight {
            guard let query = self.currentQuery, hasMoreData, !isPaginating else { return }
            requestSearch(query: query, page: self.currentPage)
        }
    }
}
