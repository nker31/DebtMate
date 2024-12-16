//
//  SettingViewController.swift
//  DebtMate
//
//  Created by Nathat Kuanthanom on 12/6/24.
//

import UIKit

class SettingViewController: UIViewController {
    // MARK: - Varibles
    var viewModel: SettingViewModelProtocol
    
    // MARK: - UI Components
    var settingTableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.register(SwitchTableViewCell.self, forCellReuseIdentifier: SwitchTableViewCell.identifier)
        tableView.register(AccountTableViewCell.self, forCellReuseIdentifier: AccountTableViewCell.identifier)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    // MARK: - Initializer
    init(viewModel: SettingViewModelProtocol = SettingViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavigationBar()
        settingTableView.dataSource = self
        settingTableView.delegate = self
        viewModel.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        reloadAccountCell()
    }
    
    // MARK: - UI Setup
    func setupUI() {
        view.backgroundColor = .systemBackground
    
        view.addSubview(settingTableView)
        
        NSLayoutConstraint.activate([
            settingTableView.topAnchor.constraint(equalTo: view.topAnchor),
            settingTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            settingTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            settingTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
    
    func setupNavigationBar() {
        title = String(localized: "setting_screen_title")
    }
    
    private func reloadAccountCell() {
        let accountCellIndexPath = IndexPath(row: 0, section: 0)
        settingTableView.reloadRows(at: [accountCellIndexPath], with: .none)
    }
    
    func showNotificationSettingsAlert() {
        let alert = UIAlertController(title: String(localized: "notification_permission_denied_title"),
                                      message: String(localized: "notification_permission_denied_message"),
                                      preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: String(localized: "alert_cancel_button"), style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: String(localized: "alert_go_to_settings_button"), style: .default, handler: { [weak self] _ in
            self?.navigateToSystemSettings()
        }))
        
        present(alert, animated: true, completion: nil)
    }
    
    func displayPrivacyPolicy() {
        let privacyPolicyVC = PrivacyPolicyViewController()
        privacyPolicyVC.modalPresentationStyle = .formSheet
        present(privacyPolicyVC, animated: true)
    }
    
    // MARK: - Selectors
    @objc func switchChanged(_ sender: UISwitch) {
        viewModel.toggleNotificationSetting(isEnabled: sender.isOn) { isEnabled in
            sender.isOn = isEnabled
        }
    }
}

// MARK: - UITableViewDelegate & UITableViewDataSource
extension SettingViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.settingSection.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return viewModel.settingSection[section].title
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.settingSection[section].rows.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
           let cell = tableView.dequeueReusableCell(withIdentifier: AccountTableViewCell.identifier, for: indexPath) as! AccountTableViewCell
            let userData = viewModel.getCurrentUserData()
            cell.accessoryType = .disclosureIndicator 
            cell.configCell(userFullname: userData.name, imageURL: userData.imageURL)
            return cell
        case 1:
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: SwitchTableViewCell.identifier, for: indexPath) as! SwitchTableViewCell
                cell.textLabel?.text = viewModel.settingSection[indexPath.section].rows[indexPath.row]
                cell.toggleSwitch.addTarget(self, action: #selector(switchChanged(_:)), for: .touchUpInside)
                cell.toggleSwitch.isOn = viewModel.isNotificationEnabled
                cell.textLabel?.textColor = .label
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
                cell.textLabel?.text = viewModel.settingSection[indexPath.section].rows[indexPath.row]
                cell.textLabel?.textColor = .label
                return cell
            }
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            cell.textLabel?.text = viewModel.settingSection[indexPath.section].rows[indexPath.row]
            cell.textLabel?.textColor = .label
            cell.accessoryType = .none
            return cell
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            cell.textLabel?.text = viewModel.settingSection[indexPath.section].rows[indexPath.row]
            cell.textLabel?.textColor = .red
            cell.accessoryType = .none
            return cell
        default:
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch indexPath.section {
        case 0:
            let accountViewController = AccountDetailViewController()
            navigationController?.pushViewController(accountViewController, animated: true)
        case 1:
            if indexPath.row == 1 {
                navigateToSystemSettings()
            }
        case 2:
            if indexPath.row == 0 {
                displayPrivacyPolicy()
            } else {
                print("SettingViewController: tap contact us")
            }
        case 3:
            viewModel.signOut()
        default:
            break
        }
    }
}

extension SettingViewController: SettingViewModelDelegate {
    func didSettingNotifactionPermissionDenied() {
        showNotificationSettingsAlert()
    }
    
    func showAlert(title: String, message: String) {
        presentAlert(title: title, message: message)
    }
    
    func didSignOut() {
        let loginViewController = UINavigationController(rootViewController: LoginViewController())
        setRootViewController(loginViewController)
    }
}
