//
//  UpdateProfileModel.swift
//  appskep
//
//  Created by irfan wahendra on 07/08/25.
//

import Foundation

struct UpdateProfileRequest: Codable {
    let name: String?
    let email: String?  // Added missing field
    let phone_number: String?
    let date_of_birth: String?
    let gender: String?
    let educational_institution: String?
    let profession: String?
    let address: String?
    let province: String?
    let city: String?
    let role: String?  // Added missing field
    
    init(name: String? = nil,
         email: String? = nil,
         phoneNumber: String? = nil,
         dateOfBirth: String? = nil,
         gender: String? = nil,
         institution: String? = nil,
         profession: String? = nil,
         address: String? = nil,
         province: String? = nil,
         city: String? = nil,
         role: String? = nil) {
        self.name = name
        self.email = email
        self.phone_number = phoneNumber
        self.date_of_birth = dateOfBirth
        self.gender = gender
        self.educational_institution = institution
        self.profession = profession
        self.address = address
        self.province = province
        self.city = city
        self.role = role
    }
}

struct UpdateProfileResponse: Codable {
    let success: Bool
    let message: String
    let data: UserModel?
}
