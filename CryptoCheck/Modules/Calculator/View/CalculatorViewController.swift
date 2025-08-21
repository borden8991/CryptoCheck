//
//  CalculatorViewController.swift
//  CryptoCheck
//
//  Created by Denis Borovoi on 17.08.2025.
//

import UIKit
import SnapKit

final class CalculatorViewController: UIViewController {
    
    // MARK: - Properties
    
    private let viewModel = CalculatorViewModel()
    
    private let tableView = UITableView()
    
    private lazy var amountTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Введите сумму"
        tf.borderStyle = .roundedRect
        tf.keyboardType = .decimalPad
        tf.text = "1"
        
        tf.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 8, height: 44))
        tf.leftViewMode = .always
        
        let button = UIButton(type: .system)
        var config = UIButton.Configuration.plain()
        config.title = "USD"
        config.baseForegroundColor = .secondaryLabel
        config.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 8)
        button.configuration = config
        
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.addTarget(self, action: #selector(currencyButtonTapped), for: .touchUpInside)
        
        tf.rightView = button
        tf.rightViewMode = .always
        
        tf.addTarget(self, action: #selector(amountChanged), for: .editingChanged)
        return tf
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupLayout()
        bindViewModel()
        viewModel.fetchCoins()
    }
    
    // MARK: - Setup
    
    private func setupView() {
        title = "Калькулятор"
        view.backgroundColor = .systemBackground
        
        view.addSubview(amountTextField)
        view.addSubview(tableView)
        
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.separatorInset = .zero
    }
    
    private func setupLayout() {
        amountTextField.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(12)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(44)
        }
        
        tableView.snp.makeConstraints { make in
            make.top.equalTo(amountTextField.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
    }
    
    private func bindViewModel() {
        viewModel.onCoinsUpdated = { [weak self] in
            self?.tableView.reloadData()
        }
        
        viewModel.onError = { error in
            print("Ошибка загрузки: \(error)")
        }
    }
    
    // MARK: - Actions
    
    @objc private func amountChanged() {
        viewModel.inputAmount = Double(amountTextField.text ?? "") ?? 0
    }
    
    @objc private func currencyButtonTapped() {
        print("Выбор валюты пока не реализован")
    }
}

// MARK: - UITableViewDataSource

extension CalculatorViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.numberOfCoins()
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = viewModel.coinDisplayText(at: indexPath.row)
        return cell
    }
}
