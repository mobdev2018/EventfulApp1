//
//  CommentInputAccessoryView.swift
//  Eventful
//
//  Created by Shawn Miller on 1/5/18.
//  Copyright © 2018 Make School. All rights reserved.
//

import UIKit
protocol CommentInputAccessoryViewDelegate:NSObjectProtocol {
    func handleSubmit(for comment: String?)
    func changeList(change: Bool)
    func reloadUsersList()
}

class CommentInputAccessoryView: UIView, UITextViewDelegate {
    weak var delegate: CommentInputAccessoryViewDelegate?
    
    var searchResults = [String]()
    
    fileprivate var hasSpeicalChar = false
    fileprivate var searchString = ""
    fileprivate var userNames = Users.sharedInstance.getUsersNames()
    
   fileprivate let submitButton: UIButton = {
        let submitButton = UIButton(type: .system)
        submitButton.setTitle("Submit", for: .normal)
        submitButton.setTitleColor(.black, for: .normal)
        submitButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        submitButton.addTarget(self, action: #selector(handleSubmit), for: .touchUpInside)
        //submitButton.isEnabled = false
        return submitButton
    }()
    
    lazy var commentTextView: CommentInputTextView = {
        let textView = CommentInputTextView()
        textView.delegate = self
        textView.isScrollEnabled = false
        textView.backgroundColor = .white
        textView.font = UIFont.boldSystemFont(ofSize: 15)
        textView.textContainer.lineBreakMode = .byWordWrapping
        return textView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        //1
        autoresizingMask = .flexibleHeight
        addSubview(submitButton)
        submitButton.anchor(top: topAnchor, left: nil, bottom: bottomAnchor, right:rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 12, width: 50, height: 0)
        addSubview(commentTextView)
        //3
        if #available(iOS 11.0, *){
                    commentTextView.anchor(top: topAnchor, left: leftAnchor, bottom: safeAreaLayoutGuide.bottomAnchor, right: submitButton.leftAnchor, paddingTop: 8, paddingLeft: 8, paddingBottom: 8, paddingRight: 0, width: 0, height: 0)
        }else{
            //fallback on earlier versions
        }

        setupLineSeparatorView()

    }
    // 2
    override var intrinsicContentSize: CGSize {
        return .zero
    }
    
    fileprivate func setupLineSeparatorView(){
        let lineSeparatorView = UIView()
        lineSeparatorView.backgroundColor = UIColor.rgb(red: 230, green: 230, blue: 230)
        addSubview(lineSeparatorView)
        lineSeparatorView.anchor(top:topAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0.5)
    }
    
    @objc func handleSubmit(){
        guard let commentText = commentTextView.text else{
            return
        }
        delegate?.handleSubmit(for: commentText)
    }
    
    @objc func textFieldDidChange(_ textField: UITextView) {
        let isCommentValid = commentTextView.text?.count ?? 0 > 0
        if isCommentValid {
            submitButton.isEnabled = true
        }else{
            submitButton.isEnabled = false
        }
    }
    func clearCommentTextField(){
        commentTextView.text = nil
        commentTextView.showPlaceholderLabel()
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        // When user hits backspace on keyboard
        if (range.length == 1 && text.length == 0){
            if (self.searchString.count > 0){
                self.searchThroughArray(searchText: self.searchString)
                self.searchString.removeLast()
            }else{
                delegate?.changeList(change: false)
            }
        }else if (text == "@"){ // When @ sign detected in string it will populate the users list
            self.hasSpeicalChar = true
            self.searchResults = userNames
            delegate?.changeList(change: true)
        }else if (text == " "){ // When space detected users list will be gone
            self.searchString = ""
            self.hasSpeicalChar = false
            // Refreshes the users list based on the search results
            delegate?.changeList(change: false)
        }else{
            if (self.hasSpeicalChar == true){
                self.searchString.append(text)
                // characters after @ sign are being sent to search the user name
                self.searchThroughArray(searchText: self.searchString)
            }else{
                self.hasSpeicalChar = false
                self.searchString = ""
            }
        }
        return true
    }
    
    func searchThroughArray(searchText : String){
        // Function returns filtered list of users
        self.searchResults = userNames.filter { item in
            return item.lowercased().contains(searchText.lowercased())
        }
        delegate?.reloadUsersList()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
