import UIKit
import SnapKit

class BookInfoView: UIView {
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.textAlignment = .left
        label.font = .systemFont(ofSize: 20)
        label.isUserInteractionEnabled = false
        return label
    }()
    private let authorLabel: UILabel = {
        let label = UILabel()
        label.textColor = .gray
        label.textAlignment = .left
        label.font = .systemFont(ofSize: 15)
        label.isUserInteractionEnabled = false
        return label
    }()
    private let priceLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.textAlignment = .left
        label.font = .systemFont(ofSize: 15)
        label.isUserInteractionEnabled = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
        setConstraints()
        self.isUserInteractionEnabled = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private func configureUI() {
        [
         titleLabel,
         authorLabel,
         priceLabel
        ].forEach { addSubview($0) }
        
        self.layer.borderWidth = 2.0
        self.layer.borderColor = UIColor.lightGray.cgColor
        self.layer.cornerRadius = 8.0
        self.clipsToBounds = true
    }
        
    private func setConstraints() {
        titleLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().inset(20)
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

    
