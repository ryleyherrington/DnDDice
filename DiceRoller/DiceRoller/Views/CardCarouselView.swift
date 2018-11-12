//
//  CardView.swift
//  DiceRoller
//
//  Created by Herrington, Ryley on 11/2/18.
//  Copyright © 2018 Herrington. All rights reserved.
//

import UIKit

struct CardUI {
    var title: String
    var description: String?
    var image: UIImage?
    var imageUrl: URL?
}

protocol CardTapDelegate: class {
    func cardTapped(_ index: Int)
}

class CardCarouselView: UIStackView {

    weak var delegate: CardTapDelegate?

    private let cardId = "cardCellId"
    private var selectedIndex: IndexPath = IndexPath(item: 0, section: 0)

    private let sources: [CardType]
    private let collectionView: UICollectionView = {
        let layout = CarouselFlowLayout(cellWidth: CardLayoutConstant.width)
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = CardLayoutConstant.minLineSpacing
        layout.minimumInteritemSpacing = CardLayoutConstant.minLineSpacing

        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.showsVerticalScrollIndicator = false
        cv.indicatorStyle = .black
        cv.showsHorizontalScrollIndicator = true
        return cv
    }()

    init(sources: [CardType]) {
        self.sources = sources
        super.init(frame: .zero)
        setupView()
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        self.backgroundColor = UIColor.white

        addArrangedSubview(collectionView)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(CardCell.self, forCellWithReuseIdentifier: cardId)
        collectionView.backgroundColor = UIColor.white
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 20)

        collectionView.snp.makeConstraints { (make) in
            make.height.equalTo(CardLayoutConstant.height + 40) //extra padding at the bottom of the cell for shadow
        }

        collectionView.flashScrollIndicators()
    }
}

extension CardCarouselView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sources.count
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        return CGSize(width: CardLayoutConstant.width,
                      height: CardLayoutConstant.height)
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cardId, for: indexPath) as! CardCell
        guard let source = sources[safe: indexPath.row] else {
            return cell
        }

        cell.delegate = self
        cell.populate(source)

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedCard(at: indexPath)
    }

    func selectedCard(at indexPath: IndexPath) {
        selectedIndex = indexPath
        delegate?.cardTapped(indexPath.row)
    }
}

extension CardCarouselView: CardCellDelegate {
    func tappedCell(_ cell: CardCell) {
        if let indexPath = collectionView.indexPath(for: cell) {
            selectedCard(at: indexPath)
        }
    }
}
