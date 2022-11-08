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
        static let tableCornerRadius: CGFloat = 10
    }
    
    private lazy var booksTableView: UITableView = {
        let tableView = UITableView()
        tableView.register(BookTableViewCell.self, forCellReuseIdentifier: Constants.cellIdentifier)
        tableView.backgroundColor = AppColor.background
        tableView.clipsToBounds = true
        tableView.layer.cornerRadius = Constants.tableCornerRadius
        tableView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
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
    
    private var selectedBookRelay = BehaviorRelay<Int?>(value: nil)
    private var viewModel: LibraryViewModelProtocol!
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.viewDidLoad()
    }
    
    func setup(viewModel: LibraryViewModelProtocol) {
        self.viewModel = viewModel
        
        selectedBookRelay
            .subscribe(onNext: { [weak self] index in
                guard let index = index else {return}
                self?.viewModel.selectedBook(index: index)
            })
            .disposed(by: disposeBag)
        
        viewModel.stateDriver
            .drive(onNext: { [weak self] _ in
                self?.addUI()
            }).disposed(by: disposeBag)
    }
}

private extension LibraryViewController {
    func addUI() {
        view.backgroundColor = AppColor.background
        view.addSubview(booksTableView)
        
        booksTableView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(view.snp.centerY)
            $0.bottom.equalTo(view.snp.bottom)
            $0.width.equalToSuperview()
        }
    }
}

extension LibraryViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        viewModel.books.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.cellIdentifier) as! BookTableViewCell
        cell.setup(model: viewModel.books[indexPath.item])
        return cell
    }

    func tableView(_: UITableView, heightForRowAt _: IndexPath) -> CGFloat {
        150
    }

    func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedBookRelay.accept(indexPath.item)
    }
}
