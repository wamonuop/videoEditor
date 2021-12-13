//
//  CollectionViewCell.swift
//  videEditor
//
//  Created by Hızlıgelıyo on 6.12.2021.
//

import UIKit
import AVFoundation

class CollectionViewCell: UICollectionViewCell {
    static let identfier : String = "stepThreeCollectionViewCell"
    
    var asset : AVAsset? {
        didSet {
            let image = configureAssetImage()
            if let x = image {
                mainImageView.image = x
            }
            else {
                print("didSetError")
            }
        }
    }
    
    let mainImageView : UIImageView = {
       let x = UIImageView()
        x.contentMode = .scaleAspectFit
       return x
    }()
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(mainImageView)
    }
 
 
    
    override func layoutSubviews() {
        super.layoutSubviews()
        mainImageView.frame = CGRect(x: 0, y: 0, width: contentView.frame.width, height: contentView.frame.height)
        contentView.addSubview(mainImageView)
    }
    
    override class func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configureAssetImage() -> UIImage? {
        if let x = asset {
            let imageGenerator = AVAssetImageGenerator(asset: x)

             do {
                 let thumbnailImage = try imageGenerator.copyCGImage(at: CMTimeMake(value: 1, timescale: 60), actualTime: nil)
                 return UIImage(cgImage: thumbnailImage)
             } catch let error {
                 print(error)
             }
             
             return nil
        }
        else {
            print("Error in cell model")
            return nil
        }
    }
    
}
