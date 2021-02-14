//
//  AlbumDetailVC.swift
//  Albums
//
//  Created by sam on 15/2/2021.
//

import UIKit
import SDWebImage

class AlbumDetailVC: UIViewController {
    
    private let scrollView: UIScrollView = {
        return UIScrollView()
    }()
    
    private let albumView: AlbumView = {
        return AlbumView()
    }()
    
    var viewModel: AlbumDetailViewModelType!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setup()
    }
    
}

extension AlbumDetailVC {
    func setup() {
        setupViews()
        setupNavItems()
        setupDataSource()
    }
    
    func setupViews() {
        view.backgroundColor = UIColor.systemBackground
        
        view.addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        scrollView.addSubview(albumView)
        albumView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            albumView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            albumView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            albumView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            albumView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            albumView.widthAnchor.constraint(equalTo: view.widthAnchor)
        ])
        
        albumView.layoutIfNeeded()
    }
    
    func setupNavItems() {
        let bookmarkBtn = UIBarButtonItem(image: nil, style: .plain, target: self, action: #selector(bookmark))
        navigationItem.rightBarButtonItems = [bookmarkBtn]
        
        viewModel.bookmarked = { bookmarked in
            bookmarkBtn.image = bookmarked ? UIImage(systemName: "bookmark.fill") : UIImage(systemName: "bookmark")
        }
    }
    
    func setupDataSource() {
        viewModel.icon = { [weak self] url in
            DispatchQueue.main.async { [weak self] in
                self?.albumView.setIcon(url)
            }
        }
        
        viewModel.name = { [weak self] name in
            DispatchQueue.main.async { [weak self] in
                self?.albumView.setName(name)
            }
        }
        
        viewModel.infos = { [weak self] infos in
            DispatchQueue.main.async { [weak self] in
                self?.albumView.setInfos(infos)
            }
        }
        
        viewModel.start(iconSize: albumView.iconSize)
    }
}

extension AlbumDetailVC {
    @objc func bookmark() {
        viewModel.didBookmark?()
    }
}

extension AlbumDetailVC {
    private class AlbumView: UIView {
        let iconIV: UIImageView = {
            let imageView = UIImageView()
            return imageView
        }()
        
        var iconSize: CGSize {
            return iconIV.bounds.size
        }
        
        let nameLbl: UILabel = {
            let label = UILabel()
            label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
            label.textAlignment = .center
            label.numberOfLines = 0
            label.text = " "
            return label
        }()
        
        let stackView: UIStackView = {
            let stackView = UIStackView()
            stackView.axis = .vertical
            stackView.alignment = .fill
            stackView.distribution = .fill
            stackView.spacing = 10
            return stackView
        }()
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            setup()
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        private func setup() {
            addSubview(iconIV)
            iconIV.translatesAutoresizingMaskIntoConstraints = false

            NSLayoutConstraint.activate([
                iconIV.topAnchor.constraint(equalTo: topAnchor, constant: 20),
                iconIV.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
                iconIV.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
                iconIV.heightAnchor.constraint(equalTo: iconIV.widthAnchor)
            ])
            
            addSubview(nameLbl)
            nameLbl.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                nameLbl.topAnchor.constraint(equalTo: iconIV.bottomAnchor, constant: 20),
                nameLbl.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
                nameLbl.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            ])
            
            addSubview(stackView)
            stackView.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                stackView.topAnchor.constraint(equalTo: nameLbl.bottomAnchor, constant: 20),
                stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
                stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
                stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20)
            ])
        }
        
        func setIcon(_ url: URL) {
            iconIV.sd_setImage(with: url)
        }
        
        func setName(_ name: String) {
            nameLbl.text = name
        }
        
        func setInfos(_ infos: [(title: String, desc: String)]) {
            for info in infos {
                let infoView = InfoView()
                infoView.setTitle(info.title)
                infoView.setDesc(info.desc)
                stackView.addArrangedSubview(infoView)
            }
        }
    }
    
    private class InfoView: UIView {
        
        let titleLbl: UILabel = {
            let label = UILabel()
            label.font = UIFont.systemFont(ofSize: 17)
            label.textAlignment = .right
            return label
        }()
        
        let descLbl: UILabel = {
            let label = UILabel()
            label.font = UIFont.systemFont(ofSize: 14)
            label.textAlignment = .left
            label.textColor = UIColor.systemGray
            label.adjustsFontSizeToFitWidth = true
            return label
        }()
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            setup()
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        private func setup() {
            let stackView = UIStackView()
            stackView.axis = .horizontal
            stackView.alignment = .fill
            stackView.distribution = .fillEqually
            stackView.spacing = 12
            
            stackView.addArrangedSubview(titleLbl)
            stackView.addArrangedSubview(descLbl)
            
            addSubview(stackView)
            stackView.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                stackView.topAnchor.constraint(equalTo: topAnchor),
                stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
                stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
                stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
                stackView.heightAnchor.constraint(equalToConstant: 20)
            ])
        }
        
        func setTitle(_ title: String) {
            titleLbl.text = title
        }
        
        func setDesc(_ desc: String) {
            descLbl.text = desc
        }
    }
}
