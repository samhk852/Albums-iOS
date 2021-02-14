//
//  BookmarkedAlbumListVC.swift
//  Albums
//
//  Created by sam on 15/2/2021.
//

import UIKit

class BookmarkedAlbumListVC: AlbumListVC {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
}

extension BookmarkedAlbumListVC {
    override func setupNavItems() {
    
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        return nil
    }
}
