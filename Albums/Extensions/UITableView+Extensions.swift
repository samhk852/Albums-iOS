//
//  UITableView+Extensions.swift
//  Albums
//
//  Created by TD on 15/3/2023.
//

import UIKit

extension UITableView {
    func setLoading(_ isLoading: Bool) {
        if (isLoading) {
            let activityIndicatorView = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height))
            activityIndicatorView.startAnimating()
            self.backgroundView = activityIndicatorView
        } else {
            restoreBackgroundView()
        }
    }
    
    func setEmpty(_ msg: String) {
        let messageLbl = UILabel(frame: CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height))
        messageLbl.text = msg
        messageLbl.numberOfLines = 0
        messageLbl.textAlignment = .center
        messageLbl.sizeToFit()

        self.backgroundView = messageLbl
        self.separatorStyle = .none
    }

    func restoreBackgroundView() {
        self.backgroundView = nil
        self.separatorStyle = .singleLine
    }
}
