//
//  EventCell.swift
//  DiceRoller
//
//  Created by Ryley Herrington on 2/24/18.
//  Copyright © 2018 Herrington. All rights reserved.
//

import UIKit
import SnapKit

class EventCell: UITableViewCell {
    
    var event: SubEvent? {
        didSet {
            updateCell()
        }
    }

    let titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = UIFont(name: "HelveticaNeue-Bold", size: 14)
        label.textAlignment = .left
        return label
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        addSubview(titleLabel)

        titleLabel.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(15)
            make.trailing.equalToSuperview()
            make.centerY.equalToSuperview()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    func updateCell() {
        if let event = event {
           titleLabel.text = "  " + event.desc
        }
    }

}
