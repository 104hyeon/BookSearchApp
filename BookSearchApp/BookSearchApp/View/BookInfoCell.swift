import UIKit
import SnapKit

class BookInfoCell: UICollectionViewCell {
    static let id = "BookInfoCell"
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.textAlignment = .left
        label.font = .systemFont(ofSize: 20)
        return label
    }()
    private let authorLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = .white
        label.textColor = .gray
        label.textAlignment = .left
        label.font = .systemFont(ofSize: 15)
        return label
    }()
    private let priceLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.textAlignment = .left
        label.font = .systemFont(ofSize: 15)
        return label
    }()
    private let deleteButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("삭제", for: .normal)
        button.backgroundColor = .systemRed
        button.tintColor = .white
        button.layer.cornerRadius = 8
        button.isHidden = true
        return button
    }()
    private let containerView = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
        setConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    private func configureUI() {
        contentView.backgroundColor = .white
        [
         titleLabel,
         authorLabel,
         priceLabel,
         containerView,
         deleteButton
        ].forEach { contentView.addSubview($0) }
        self.layer.borderWidth = 2.0
        self.layer.borderColor = UIColor.lightGray.cgColor
        self.layer.cornerRadius = 8.0
        self.clipsToBounds = true
    }
        
    private func setConstraints() {
        titleLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().inset(10)
            $0.width.equalTo(200)
        }
        authorLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().inset(220)
            $0.width.equalTo(80)
        }
        priceLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().inset(310)
            $0.width.equalTo(80)
        }
    }
    
    func configure(with bookInfo: BookInfo) {
        self.titleLabel.text = bookInfo.title
        let authors = bookInfo.authors?.joined(separator: ", ")
        self.authorLabel.text = authors
        guard let price = bookInfo.price else { return }
        self.priceLabel.text = "\(price)원"
        
    }

}
