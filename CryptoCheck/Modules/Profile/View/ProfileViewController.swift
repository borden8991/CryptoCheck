//
//  ProfileViewController.swift
//  CryptoCheck
//
//  Created by Denis Borovoi on 01.08.2025.
//

import UIKit

final class ProfileViewController: UIViewController {
    
    // MARK: - Properties
    
    private let scrollView = UIScrollView()
    private let stackView = UIStackView()
    private let themeSwitch = UISwitch()
    
    private let viewModel = ProfileViewModel()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Профиль"
        view.backgroundColor = .systemBackground
        setupScrollView()
        setupUI()
        loadSavedTheme()
    }
    
    // MARK: - Setup UI
    
    private func setupScrollView() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 20),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16),
            stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -32)
        ])
    }
    
    private func setupUI() {
        let greetingLabel = UILabel()
        greetingLabel.numberOfLines = 0
        greetingLabel.text = "Привет!\nВойдите, чтобы отслеживать ваши избранные монеты и NFT."
        greetingLabel.font = .systemFont(ofSize: 16)
        stackView.addArrangedSubview(greetingLabel)
        
        let buttonStack = UIStackView()
        buttonStack.axis = .horizontal
        buttonStack.spacing = 10
        buttonStack.distribution = .fillEqually
        
        let loginButton = makeButton(title: "Вход", color: .systemGreen)
        let registerButton = makeButton(title: "Регистрация", color: .systemGray4)
        let calcButton = makeButton(title: "Калькулятор", color: .systemGray4)
        calcButton.addTarget(self, action: #selector(openCalculator), for: .touchUpInside)
        
        buttonStack.addArrangedSubview(loginButton)
        buttonStack.addArrangedSubview(registerButton)
        buttonStack.addArrangedSubview(calcButton)
        stackView.addArrangedSubview(buttonStack)
        
        let alertStack = UIStackView()
        alertStack.axis = .horizontal
        alertStack.spacing = 10
        alertStack.distribution = .fillEqually
        
        let alertCoins = makeButton(title: "Оповещения о монетах", color: .systemGray5)
        let alertNFT = makeButton(title: "Оповещения об NFT", color: .systemGray5)
        
        alertStack.addArrangedSubview(alertCoins)
        alertStack.addArrangedSubview(alertNFT)
        stackView.addArrangedSubview(alertStack)
    
        stackView.addArrangedSubview(makeTitleLabel("Настройки"))
        
        let themeStack = UIStackView(arrangedSubviews: [makeLabel("Тёмная тема"), themeSwitch])
        themeStack.axis = .horizontal
        themeStack.distribution = .equalSpacing
        themeSwitch.addTarget(self, action: #selector(themeSwitchToggled), for: .valueChanged)
        
        stackView.addArrangedSubview(themeStack)
        stackView.addArrangedSubview(makeSwitchRow(title: "Режим цветовой слепоты"))
        stackView.addArrangedSubview(makeInfoRow(title: "Валюта по умолчанию", value: viewModel.defaultCurrency))
        stackView.addArrangedSubview(makeInfoRow(title: "Язык", value: viewModel.defaultLanguage))
        stackView.addArrangedSubview(makeInfoRow(title: "Начальный экран", value: viewModel.defaultHomeTab))
        stackView.addArrangedSubview(makeInfoRow(title: "Значок приложения", value: viewModel.defaultAppIcon))
        stackView.addArrangedSubview(makeTitleLabel("Другие"))
        stackView.addArrangedSubview(makeInfoRow(title: "Версия 0.0.2", value: nil))
    }
    
    private func makeButton(title: String, color: UIColor) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.backgroundColor = color
        button.setTitleColor(.label, for: .normal)
        button.layer.cornerRadius = 8
        button.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        button.heightAnchor.constraint(equalToConstant: 40).isActive = true
        return button
    }
    
    private func makeTitleLabel(_ text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = .boldSystemFont(ofSize: 18)
        return label
    }
    
    private func makeLabel(_ text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = .systemFont(ofSize: 18)
        return label
    }
    
    private func makeSwitchRow(title: String) -> UIView {
        let label = makeLabel(title)
        let toggle = UISwitch()
        toggle.isOn = UserDefaults.standard.bool(forKey: "isColorBlindMode")
        
        if title == "Режим цветовой слепоты" {
            toggle.addTarget(self,
                             action: #selector(colorBlindSwitchToggled(_:)),
                             for: .valueChanged)
        }
        
        let hStack = UIStackView(arrangedSubviews: [label, toggle])
        hStack.axis = .horizontal
        hStack.distribution = .equalSpacing
        return hStack
    }
    
    private func makeInfoRow(title: String, value: String?) -> UIView {
        let label = makeLabel(title)
        let valueLabel = UILabel()
        valueLabel.text = value ?? ""
        valueLabel.textColor = .secondaryLabel
        
        let hStack = UIStackView(arrangedSubviews: [label, valueLabel])
        hStack.axis = .horizontal
        hStack.distribution = .equalSpacing
        return hStack
    }
    
    private func loadSavedTheme() {
        let isDarkMode = UserDefaults.standard.bool(forKey: "isDarkMode")
        themeSwitch.isOn = isDarkMode
    }
    
    // MARK: - Actions
    
    @objc private func openCalculator() {
        let vc = CalculatorViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc private func themeSwitchToggled() {
        let isOn = themeSwitch.isOn
        UserDefaults.standard.set(isOn, forKey: "isDarkMode")
        
        UIApplication.shared.windows.forEach { window in
            window.overrideUserInterfaceStyle = isOn ? .dark : .light
        }
    }
    
    @objc private func colorBlindSwitchToggled(_ sender: UISwitch) {
        UserDefaults.standard.set(sender.isOn, forKey: "isColorBlindMode")
        NotificationCenter.default.post(name: NSNotification.Name("ColorBlindModeChanged"), object: nil)
    }
}
