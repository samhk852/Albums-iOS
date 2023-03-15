//
//  AlbumListVC.swift
//  Albums
//
//  Created by sam on 15/2/2021.
//

import UIKit
import SDWebImage
import Combine

class AlbumListVC: UIViewController {
    
    enum Cell: String {
        case album = "AlbumCell"
        
        var reuseIdentifier: String {
            return rawValue
        }
    }
    
    lazy var refreshControl: UIRefreshControl = {
        return UIRefreshControl()
    }()
    
    lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableView.automaticDimension
        tableView.tableFooterView = UIView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(AlbumCell.self, forCellReuseIdentifier: Cell.album.reuseIdentifier)
        return tableView
    }()
    
    var albums: [Album] = []
    
    var viewModel: AlbumViewModelType! = AlbumListViewModel()
    
    private var cancellables: Set<AnyCancellable> = Set()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        navigationItem.title = viewModel.title
        setup()
    }


}

extension AlbumListVC {
    func setup() {
        setupViews()
        setupNavItems()
        setupDataSource()
    }
    
    func setupViews() {
        view.backgroundColor = UIColor.systemBackground
        
        setupSearchBar()
        setupTableView()
    }
    
    func setupSearchBar() {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search albums"
        self.navigationItem.searchController = searchController
        self.definesPresentationContext = true
    }
    
    func setupTableView() {
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        guard viewModel.refreshable else { return }
        
        tableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(didRefresh), for: .valueChanged)
    }
    
    @objc func setupNavItems() {
        let bookmarkedBtn = UIBarButtonItem(image: UIImage(systemName: "bookmark.fill"), style: .plain, target: self, action: #selector(goToBookmarked))
        
        navigationItem.rightBarButtonItems = [bookmarkedBtn]
    }
    
    func setupDataSource() {
        viewModel.albums
            .map{ $0.isLoading }
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] isLoading in
                self?.setLoading(isLoading)
            }).store(in: &cancellables)

        viewModel.albums
            .compactMap{ $0.value }
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] albums in
                self?.albums = albums
                self?.tableView.reloadData()
                self?.setEmpty(albums.count == 0)
            }).store(in: &cancellables)
        
        viewModel.albums
            .compactMap{ $0.error }
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] message in
                self?.show(title: "Error", message: message)
            }).store(in: &cancellables)
        
        viewModel.start()
    }
}

extension AlbumListVC {
    @objc func didRefresh() {
        guard refreshControl.isRefreshing else { return }
        viewModel.didRefresh?()
    }
    
    @objc func goToBookmarked() {
        let vc = BookmarkedAlbumListVC()
        vc.viewModel = BookmarkedAlbumListViewModel()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func openDetail(album: Album) {
        let vc = AlbumDetailVC()
        vc.viewModel = AlbumDetailViewModel(album: album)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func bookmark(indexPath: IndexPath) {
        viewModel.didBookmark?(albums[indexPath.row])
    }
    
    func show(title: String, message: String) {
        let vc = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okayAction = UIAlertAction(title: "okay", style: .default)
        vc.addAction(okayAction)
        present(vc, animated: true, completion: nil)
    }
    
    func setLoading(_ isLoading: Bool) {
        if isLoading {
            tableView.setLoading(true)
        } else {
            refreshControl.endRefreshing()
        }
    }
    
    func setEmpty(_ isEmpty: Bool) {
        if isEmpty {
            tableView.setEmpty("No albums found")
        } else {
            tableView.restoreBackgroundView()
        }
    }
}


extension AlbumListVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return albums.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Cell.album.reuseIdentifier, for: indexPath) as! AlbumCell
        cell.setup(item: albums[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let isBookmakred = viewModel.isBookmarked(id: albums[indexPath.row].collectionID)
        let title: String = isBookmakred ? "Remove Bookmark" : "Add Bookmark"
        let style: UIContextualAction.Style = isBookmakred ? .destructive : .normal
        
        let bookmarkAction = UIContextualAction(style: style, title: title) { [weak self] _, _, completionHandler in
            self?.bookmark(indexPath: indexPath)
            completionHandler(true)
        }
        
        return UISwipeActionsConfiguration(actions: [bookmarkAction])
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        defer { tableView.deselectRow(at: indexPath, animated: true) }
        let album = albums[indexPath.row]
        openDetail(album: album)
    }
}

extension AlbumListVC: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let text = searchController.searchBar.text
        viewModel.didSearch?(text)
    }
}

extension AlbumListVC {
    class AlbumCell: UITableViewCell {
        
        let titleLbl: UILabel = {
            let label = UILabel()
            label.font = UIFont.systemFont(ofSize: 17)
            label.numberOfLines = 0
            return label
        }()
        
        let descLbl: UILabel = {
            let label = UILabel()
            label.font = UIFont.systemFont(ofSize: 14)
            label.textColor = UIColor.systemGray
            label.numberOfLines = 0
            return label
        }()
        
        let iconIV: UIImageView = {
            let imageView = UIImageView()
            return imageView
        }()
        
        override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            super.init(style: style, reuseIdentifier: reuseIdentifier)
            setup()
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        private func setup() {
            let stackView = UIStackView()
            stackView.axis = .vertical
            stackView.alignment = .fill
            stackView.distribution = .fill
            stackView.spacing = 10
            
            stackView.addArrangedSubview(titleLbl)
            stackView.addArrangedSubview(descLbl)
            
            contentView.addSubview(stackView)
            stackView.translatesAutoresizingMaskIntoConstraints = false

            NSLayoutConstraint.activate([
                stackView.topAnchor.constraint(greaterThanOrEqualTo: contentView.topAnchor, constant: 20),
                stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
                stackView.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -20),
                stackView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
            ])
            
            contentView.addSubview(iconIV)
            iconIV.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                iconIV.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
                iconIV.leadingAnchor.constraint(greaterThanOrEqualTo: stackView.trailingAnchor, constant: 16),
                iconIV.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
                iconIV.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),
                iconIV.widthAnchor.constraint(equalToConstant: 100),
                iconIV.heightAnchor.constraint(greaterThanOrEqualToConstant: 100)
            ])
        }
        
        override func prepareForReuse() {
            super.prepareForReuse()
            titleLbl.text = nil
            descLbl.text = nil
            iconIV.image = nil
        }
        
        func setup(item: Album) {
            titleLbl.text = item.collectionName
            descLbl.text = item.artistName
            
            if let url = URL(string: item.artworkUrl100) {
                iconIV.sd_setImage(with: url)
            }
        }
        
    }
}
