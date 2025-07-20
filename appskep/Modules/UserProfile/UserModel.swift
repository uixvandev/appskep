//
//  UserModel.swift
//  appskep
//
//  Created by irfan wahendra on 13/07/25.
//

import Foundation

struct UserModel: Codable, Identifiable {
  let id: Int
      let name: String
      let email: String
      let role: String
      let phoneNumber: String
      let dateOfBirth: String
      let gender: String
      let educationalInstitution: String
      let profession: String
      let address: String
      let province: String
      let city: String
      let createdAt: String
      let updatedAt: String
      
      enum CodingKeys: String, CodingKey {
          case id, name, email, role, gender, profession, address, province, city
          case phoneNumber = "phone_number"
          case dateOfBirth = "date_of_birth"
          case educationalInstitution = "educational_institution"
          case createdAt = "created_at"
          case updatedAt = "updated_at"
      }
}
