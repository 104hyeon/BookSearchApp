import UIKit
import SnapKit

class ThumbnailCell: UICollectionViewCell {
    static let id = "ThumbnailCell"
    
    private let thumbImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = .white
        imageView.layer.cornerRadius = 40
        imageView.layer.borderWidth = 2.0
        imageView.layer.borderColor = UIColor.gray.cgColor
        imageView.clipsToBounds = true
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    private func configureUI() {
        contentView.addSubview(thumbImageView)
        thumbImageView.snp.makeConstraints {
            $0.width.height.equalTo(80)
            $0.center.equalToSuperview()
        }
    }
    func configure(with bookInfo: BookInfo) {
        if let urlString = bookInfo.thumbnail, let url = URL(string: urlString) {
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
                    self?.thumbImageView.image = image
                }
            }.resume()
        } else {
            thumbImageView.image = nil
        }
    }
}
