//
//  UserSingleton.swift
//  SnapchatClone
//
//  Created by Sarthak Goel on 02/07/23.
//

import Foundation

class UserSingleton {
    static let sharedUserInfo = UserSingleton()
    
    var email = ""
    var username = ""
    
    private init(email: String = "", username: String = "") {
        self.email = email
        self.username = username
    }
}
