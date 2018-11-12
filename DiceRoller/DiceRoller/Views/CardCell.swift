//
//  CardCell.swift
//  DiceRoller
//
//  Created by Herrington, Ryley on 11/2/18.
//  Copyright © 2018 Herrington. All rights reserved.
//

import UIKit
import SnapKit
import CoreMotion

struct CardLayoutConstant {
    static let height: CGFloat = 378
    static let width: CGFloat = 252
    static let minLineSpacing: CGFloat = 10.0
    static let innerMargin: CGFloat = 10.0
}

struct CardInfo {
    let title: String
    let desc: String
    let color: UIColor
    let textColor: UIColor
}

enum CardType {
    case image(UIImage)
    case url(URL)
    case info(CardInfo)
}

protocol CardCellDelegate{
    func tappedCell(_ cell: CardCell)
}

class CardCell: UICollectionViewCell {

    //Image Cell
    var imageView = UIImageView()

    //Info Cell
    var titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = UIFont(name: "HelveticaNeue-Bold", size: 24)
        label.textAlignment = .center
        return label
    }()

    var descLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = UIFont(name: "HelveticaNeue", size: 18)
        label.textAlignment = .left
        return label
    }()

    var cardType: CardType?
    var delegate: CardCellDelegate?

    private let motionManager = CMMotionManager()
    private weak var shadowView: UIView?
    private var longPressGestureRecognizer: UILongPressGestureRecognizer? = nil
    private var pressed: Bool = false

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    override func prepareForReuse() {
        imageView.removeFromSuperview()
        titleLabel.removeFromSuperview()
        descLabel.removeFromSuperview()
    }

    private func checkCardType() {
        guard let cardType = cardType else { return }

        switch cardType {
        case .image(_):
            setupImageView()
        case .url(_):
            break
        case .info(_):
            setupInfoView()
        }

        configureGestureRecognizer()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        configureShadow()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupImageView() {
        imageView.layer.cornerRadius = 5
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill

        addSubview(imageView)
        imageView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }

    private func setupInfoView() { 
        addSubview(titleLabel)
        addSubview(descLabel)

        titleLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(5)
            make.leading.equalToSuperview().offset(10)
            make.trailing.equalToSuperview().offset(-10)
        }

        descLabel.snp.makeConstraints { (make) in
            make.top.equalTo(titleLabel.snp.bottom).offset(10)
            make.leading.equalToSuperview().offset(10)
            make.trailing.equalToSuperview().offset(-10)
        }
    }

    private func configureShadow() {
        self.shadowView?.removeFromSuperview()
        let shadowView = UIView(frame: CGRect(x: CardLayoutConstant.innerMargin,
                                              y: CardLayoutConstant.innerMargin,
                                              width: bounds.width - (2 * CardLayoutConstant.innerMargin),
                                              height: bounds.height - (2 * CardLayoutConstant.innerMargin)))
        insertSubview(shadowView, at: 0)
        self.shadowView = shadowView

        // Roll/Pitch Dynamic Shadow
        if motionManager.isDeviceMotionAvailable {
            motionManager.deviceMotionUpdateInterval = 0.02
            motionManager.startDeviceMotionUpdates(to: .main, withHandler: { (motion, error) in
                if let motion = motion {
                    let pitch = motion.attitude.pitch * 20 // x-axis
                    let roll = motion.attitude.roll * 20 // y-axis
                    self.applyShadow(width: CGFloat(roll), height: CGFloat(pitch))
                }
            })
        }
    }

    private func applyShadow(width: CGFloat, height: CGFloat) {
        if let shadowView = shadowView {
            let shadowPath = UIBezierPath(roundedRect: shadowView.bounds, cornerRadius: 14.0)
            shadowView.layer.masksToBounds = false
            shadowView.layer.shadowRadius = 8.0
            shadowView.layer.shadowColor = UIColor.black.cgColor
            shadowView.layer.shadowOffset = CGSize(width: width, height: height)
            shadowView.layer.shadowOpacity = 0.35
            shadowView.layer.shadowPath = shadowPath.cgPath
        }
    }

    // MARK: - Gesture Recognizer
    private func configureGestureRecognizer() {
        longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPressGesture(gestureRecognizer:)))
        longPressGestureRecognizer?.minimumPressDuration = 0.1
        addGestureRecognizer(longPressGestureRecognizer!)
    }

    @objc internal func handleLongPressGesture(gestureRecognizer: UILongPressGestureRecognizer) {
        if gestureRecognizer.state == .began {
            handleLongPressBegan()
        } else if gestureRecognizer.state == .ended || gestureRecognizer.state == .cancelled {
            handleLongPressEnded()
        }
    }

    private func handleLongPressBegan() {
        guard !pressed else {
            return
        }

        pressed = true
        UIView.animate(withDuration: 0.5,
                       delay: 0.0,
                       usingSpringWithDamping: 0.8,
                       initialSpringVelocity: 0.2,
                       options: .beginFromCurrentState,
                       animations: {
                        self.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }, completion: nil)
    }

    private func handleLongPressEnded() {
        guard pressed else {
            return
        }

        UIView.animate(withDuration: 0.5,
                       delay: 0.0,
                       usingSpringWithDamping: 0.4,
                       initialSpringVelocity: 0.2,
                       options: .beginFromCurrentState,
                       animations: {
                        self.transform = CGAffineTransform.identity
                        self.delegate?.tappedCell(self)
        }) { (finished) in
            self.pressed = false
        }
    }

    func populate(_ model: CardType) {

        switch model {
        case let .image(image):
            cardType = .image(image)
            checkCardType()
            //imageView.image = image

        case .url(_):
            //TODO: Add async downloading if need be later
            //async download image later
            break

        case let .info(info):
            cardType = .info(info)
            checkCardType()
            titleLabel.text = info.title
            titleLabel.textColor = info.textColor

            descLabel.text = info.desc
            descLabel.textColor = info.textColor

            contentView.backgroundColor = info.color
            contentView.layer.cornerRadius = 5
        }
    }
}
