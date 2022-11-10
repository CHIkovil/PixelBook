//
//  LibraryViewController.swift
//  BlackBook
//
//  Created by Nikolas on 03.11.2022.
//

import UIKit
import RxCocoa
import RxSwift
import SnapKit


final class LibraryViewController: UIViewController {
    private enum Constants {
        static let cellIdentifier = "BookCell"
        static let currentViewHeight: CGFloat = 300
        static let contentOffset: CGFloat = 10
    }
    
    private lazy var currentBookView: LibraryCurrentItemView = {
        let view = LibraryCurrentItemView()
        return view
    }()
    
    private lazy var booksTableView: UITableView = {
        let tableView = UITableView()
        tableView.register(LibraryTableViewCell.self, forCellReuseIdentifier: Constants.cellIdentifier)
        tableView.backgroundColor = AppColor.background
        tableView.separatorStyle = .none
        tableView.allowsMultipleSelection = false
        tableView.keyboardDismissMode = .onDrag
        tableView.bounces = false
        tableView.showsVerticalScrollIndicator = false
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.delegate = self
        tableView.dataSource = self
        return tableView
    }()
    
    private var viewModel: LibraryViewModelProtocol!
    private let disposeBag = DisposeBag()
    
    deinit {
       NotificationCenter.default.removeObserver(self)
    }
    
    override func loadView() {
        super.loadView()
        view.backgroundColor = AppColor.background
        view.addSubview(currentBookView)
        view.addSubview(booksTableView)
        
        currentBookView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(view.snp.top)
            $0.height.equalTo(Constants.currentViewHeight)
            $0.width.equalToSuperview()
        }
        
        booksTableView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(currentBookView.snp.bottom).offset(Constants.contentOffset)
            $0.bottom.equalTo(view.snp.bottom)
            $0.width.equalToSuperview()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self,
                                                  selector: #selector(didBecomeActiveNotification(notification:)),
                                                  name: UIApplication.didBecomeActiveNotification,
                                                  object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.viewModel.reloadBooks()
    }
    
    func setup(viewModel: LibraryViewModelProtocol) {
        self.viewModel = viewModel
    }
}

private extension LibraryViewController {
    @objc func didBecomeActiveNotification(notification: Notification){
        viewModel.reloadBooks()
        booksTableView.reloadData()
    }
}

extension LibraryViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        guard let books = viewModel.books else{return 0}
        return books.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.cellIdentifier) as! LibraryTableViewCell
        guard let books = viewModel.books else{return cell}
        cell.setup(model: books[indexPath.item])
        return cell
    }

    func tableView(_: UITableView, heightForRowAt _: IndexPath) -> CGFloat {
        150
    }

    func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel?.selectedBookRelay.accept(indexPath.item)
    }
}
