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
    
    
    var event: Event? {
        didSet {
            updateCell()
        }
    }
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.font = UIFont(name: "HelveticaNeue-Bold", size: 18)
        label.textAlignment = .left
        return label
    }()
    
    fileprivate var tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.allowsSelection = false
        tv.backgroundColor = UIColor.clear
        tv.isScrollEnabled = false
        return tv
    }()

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "subEventCell")
    
        self.addSubview(titleLabel)
        self.addSubview(tableView)
        
        titleLabel.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(10)
            make.right.equalToSuperview()
            make.top.equalToSuperview().offset(5)
            make.height.greaterThanOrEqualTo(44)
        }
        
        tableView.snp.makeConstraints { (make) in
            make.right.equalToSuperview()
            make.left.equalToSuperview().offset(30)
            make.top.equalTo(titleLabel.snp.bottom).offset(5)
            make.bottom.equalToSuperview().offset(-5)
        }

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func updateCell() {
        titleLabel.text = event?.name
        
        if let count = event?.subEvents.count {
            let height = 44 * count
            tableView.snp.remakeConstraints { (make) in
                make.right.equalToSuperview()
                make.left.equalToSuperview().offset(30)
                make.top.equalTo(titleLabel.snp.bottom).offset(5)
                make.bottom.equalToSuperview()
                make.height.equalTo(height)
            }
            tableView.reloadData()
        } else {
            tableView.isHidden = true
        }
    }
}
extension EventCell: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let subEvent = event?.subEvents[indexPath.row] {
            print("subevent \(subEvent)")
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let count = event?.subEvents.count{
            return count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "subEventCell", for: indexPath)

        if let subEvent = event?.subEvents[indexPath.row] {
            cell.textLabel?.text = subEvent.desc
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1.0
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView(frame: CGRect(x: 0, y: 0, width: self.frame.size.width, height: 1) )
    }
}
