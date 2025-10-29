import UIKit
import SnapKit

class BookInfoTableCell: UITableViewCell {
    
    static let id = "BookInfoTableCell"
    
    private let infoView = BookInfoView()
   
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureUI() {
        [ infoView ].forEach { contentView.addSubview($0) }
        infoView.snp.makeConstraints {
            $0.top.bottom.equalToSuperview().inset(5)
            $0.leading.trailing.equalToSuperview().inset(10)
        }
        self.isUserInteractionEnabled = true
        self.selectionStyle = .default
  
    }
    func configure(with bookInfo: BookInfo) {
        self.infoView.configure(with: bookInfo)
    }
    
}
