//
//  AlertVC.swift
//  MP4
//
//  Created by Oti Oritsejafor on 9/18/20.
//  Copyright © 2020 Magloboid. All rights reserved.
//

import Foundation
import UIKit
import IQKeyboardManagerSwift

class AlertViewController: UIViewController {
    
    // MARK: Properties
    let containerView = UIView()
    let messageLabel: UILabel = {
        var lbl = UILabel()
        lbl.textAlignment = .center
        lbl.textColor = .secondaryLabel
        lbl.font = UIFont.systemFont(ofSize: 16)
        return lbl
    }()
    
    let titleLabel: UILabel = {
        var lbl = UILabel()
        lbl.textAlignment = .center
        lbl.textColor = .label
        lbl.font = UIFont.boldSystemFont(ofSize: 20)
        return lbl
    }()
    
    let actionButton: UIButton = {
        var btn = UIButton()
        btn.layer.cornerRadius = 10
        btn.titleLabel?.textColor = .white
        btn.titleLabel?.font = UIFont.preferredFont(forTextStyle: .headline)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.backgroundColor = .systemPink
        
        return btn
    }()
    
    let inputField: UITextField = {
        var txtField = UITextField()
        txtField.translatesAutoresizingMaskIntoConstraints = false
        txtField.layer.cornerRadius = 10
        txtField.layer.borderColor = UIColor.systemGray4.cgColor
        
        txtField.textColor = .label
        txtField.tintColor = .label
        txtField.textAlignment = .center
        txtField.font = UIFont.boldSystemFont(ofSize: 20)//UIFont.preferredFont(forTextStyle: .title2)
        txtField.backgroundColor = .systemGray5//.tertiarySystemBackground
        txtField.keyboardType = .numberPad
        //txtField.color
        
        txtField.text = "170"
        
        return txtField
    }()
    
    var alertTitle: String?
    var message: String?
    var buttonTitle: String?
    
    //MARK: Lifecycle
    init(title: String, message: String, buttonTitle: String) {
        super.init(nibName: nil, bundle: nil)
        self.alertTitle = title
        self.message = message
        self.buttonTitle = buttonTitle
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.75)
        IQKeyboardManager.shared.keyboardDistanceFromTextField = 150
        configureContainerView()
        configureTitleLabel()
        configureActionButtion()
        configureMessageLabel()
        configureInputField()
    }
    
    
    func configureContainerView() {
        view.addSubview(containerView)
        containerView.layer.cornerRadius = 16
        containerView.backgroundColor = .systemBackground
        containerView.layer.borderWidth = 2
        containerView.layer.borderColor = UIColor.white.cgColor
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.centerY(inView: view)
        containerView.centerX(inView: view)
        containerView.setDimensions(height: 260, width: 280)
        //containerView.cen
    }
    
    func configureTitleLabel() {
        containerView.addSubview(titleLabel)
        titleLabel.text = alertTitle ?? "Something went wrong"
        titleLabel.textColor = .label
        titleLabel.anchor(top: containerView.topAnchor, left: containerView.leftAnchor, right: containerView.rightAnchor, paddingTop: 20, paddingLeft: 20, paddingRight: 20, height: 28)
    }
    
    func configureActionButtion() {
        containerView.addSubview(actionButton)
        actionButton.setTitle(buttonTitle ?? "Ok", for: .normal)
        actionButton.addTarget(self, action: #selector(dismissVC), for: .touchUpInside)
        
        actionButton.anchor(left: containerView.leftAnchor, bottom: containerView.bottomAnchor, right: containerView.rightAnchor,  paddingLeft: 20, paddingBottom: 20, paddingRight: 20, height: 44)
    }
    
    func configureInputField() {
        containerView.addSubview(inputField)
        inputField.delegate = self
        inputField.centerY(inView: containerView, constant: 10)
        inputField.anchor(left: containerView.leftAnchor, right: containerView.rightAnchor, paddingLeft: 20, paddingRight: 20)
        inputField.setHeight(height: 40)
    }
    
    func configureMessageLabel() {
        containerView.addSubview(messageLabel)
        messageLabel.text = message ?? "Unable to complete request"
        messageLabel.numberOfLines = 3
        
        messageLabel.anchor(top: titleLabel.bottomAnchor, left: containerView.leftAnchor,  right: containerView.rightAnchor, paddingTop: 8, paddingLeft: 20, paddingRight: 20)
    }
    
    @objc func dismissVC() {
        let enteredNumber = Int(inputField.text!)
        UserDefaults.standard.set(enteredNumber, forKey: "Weight")
        UserDefaults.standard.set(true, forKey: "Onboarded")
        //print("Weight is \(number)")
        dismiss(animated: true, completion: nil)
    }
    
}

extension AlertViewController: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        print("Finished editing")
    }
}
