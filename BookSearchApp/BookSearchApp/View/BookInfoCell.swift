import UIKit
import SnapKit

class BookInfoCell: UICollectionViewCell {
    static let id = "BookInfoCell"
    
    private let infoView = BookInfoView()
   
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    private func configureUI() {
        contentView.backgroundColor = .white
        [ infoView ].forEach { contentView.addSubview($0) }
        infoView.snp.makeConstraints { $0.edges.equalToSuperview() }
    }
        
    func configure(with bookInfo: BookInfo) {
        self.infoView.configure(with: bookInfo)
    }
}
