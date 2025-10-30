
import UIKit
import SnapKit

class InfoModalViewController: UIViewController {
    
    var bookInfo: BookInfo?
    var onCartTapped: ((BookInfo) -> Void)?
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = .boldSystemFont(ofSize: 25)
        label.textAlignment = .center
        return label
    }()
    private let authorLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = .white
        label.textColor = .gray
        label.font = .systemFont(ofSize: 18)
        return label
    }()
    private let thumbnailIV: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 5
        imageView.layer.shadowColor = UIColor.black.cgColor
        imageView.layer.shadowOpacity = 0.5
        imageView.layer.shadowOffset = CGSize(width: 0, height: 5)
        imageView.clipsToBounds = false
        imageView.backgroundColor = .lightGray
        return imageView
    }()
    private let priceLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = .systemFont(ofSize: 20)
        return label
    }()
    private let contentsLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 15)
        return label
    }()
    private lazy var cartButton: UIButton = {
        let button = UIButton()
        button.setTitle("담기", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .blue
        button.layer.cornerRadius = 20
        button.addTarget(self, action: #selector(cartTapped), for: .touchUpInside)
        return button
    }()
    private lazy var dismissButton: UIButton = {
        let button = UIButton()
        button.setTitle("X", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .gray
        button.layer.cornerRadius = 20
        button.addTarget(self, action: #selector(dismissTapped), for: .touchUpInside)
        return button
    }()
    private lazy var buttonStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [dismissButton, cartButton])
        stackView.axis = .horizontal
        stackView.spacing = 15
        stackView.distribution = .fill
        return stackView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        setConstraints()
        updateUI()
    }
    
    private func configureUI() {
        view.backgroundColor = .white
        [ scrollView, buttonStackView ].forEach { view.addSubview($0) }
        scrollView.addSubview(contentView)
        [
            titleLabel, authorLabel, thumbnailIV,priceLabel, contentsLabel
        ].forEach { contentView.addSubview($0) }
    }
    
    private func setConstraints() {
        buttonStackView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(10)
            $0.height.equalTo(70)
        }
        dismissButton.snp.makeConstraints {
            $0.width.equalTo(90)
            $0.height.equalToSuperview()
        }
        cartButton.snp.makeConstraints {
            $0.height.equalToSuperview()
        }
        scrollView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(buttonStackView.snp.top).offset(-10)
        }
        contentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalTo(scrollView.snp.width)
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().inset(20)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(300)
        }
        authorLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(8)
            $0.centerX.equalToSuperview()
        }
        thumbnailIV.snp.makeConstraints {
            $0.top.equalTo(authorLabel.snp.bottom).offset(10)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(220)
            $0.height.equalTo(350)
        }
        priceLabel.snp.makeConstraints {
            $0.top.equalTo(thumbnailIV.snp.bottom).offset(10)
            $0.centerX.equalToSuperview()
        }
        contentsLabel.snp.makeConstraints {
            $0.top.equalTo(priceLabel.snp.bottom).offset(10)
            $0.leading.trailing.equalToSuperview().inset(30)
            $0.bottom.equalToSuperview().inset(30)
        }
    }
    // 책 검색 데이터 받으면 UI에 업데이트 하는 함수
    private func updateUI() {
        guard let data = bookInfo else { return }
    
        titleLabel.text = data.title
        authorLabel.text = data.authors?.joined(separator: ", ")
        priceLabel.text = "\(data.price ?? 0)원"
        contentsLabel.text = data.contents
        // 썸네일URL 이미지뷰에 이미지로 넣기
        if let urlString = data.thumbnail, let url = URL(string: urlString) {
            URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
                if let error = error {
                    print("이미지 다운로드 실패: \(error.localizedDescription)")
                    return
                }
                guard let data = data, let image = UIImage(data: data) else {
                    print("유효한 이미지 데이터가 없습니다.")
                    return
                }
                DispatchQueue.main.async {
                    self?.thumbnailIV.image = image
                }
            }.resume()
        } else {
            thumbnailIV.image = nil
        }
    }
    // "담기" 버튼 누르면 실행될 함수
    @objc
    private func cartTapped() {
        guard let bookToCart = self.bookInfo else { return }
        self.onCartTapped?(bookToCart)
        let alert = UIAlertController(
            title: "책 담기 완료", message: "담은 책 보기에서 확인 가능합니다.", preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "확인", style: .default) { [weak self] _ in
             self?.dismiss(animated: true)
        }
        alert.addAction(alertAction)
        self.present(alert, animated: true, completion: nil)
    }
    // "x" 버튼 누르면 실행될 함수
    @objc
    private func dismissTapped() {
        self.dismiss(animated: true)
    }
    // 메인에서 호출할 함수
    func configure(with info: BookInfo) {
        self.bookInfo = info
        if isViewLoaded {
            updateUI()
        }
    }
}
