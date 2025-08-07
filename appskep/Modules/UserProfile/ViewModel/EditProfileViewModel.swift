//
//  EditProfileViewModel.swift
//  appskep
//
//  Created by irfan wahendra on 07/08/25.
//

import Foundation

@MainActor
class EditProfileViewModel: ObservableObject {
    @Published var name = ""
    @Published var email = ""  // Added missing field
    @Published var phoneNumber = ""
    @Published var birthDate = Date()
    @Published var gender = ""
    @Published var institution = ""
    @Published var profession = ""
    @Published var address = ""
    @Published var city = ""
    @Published var province = ""
    @Published var role = ""  // Added missing field
    
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var isUpdateSuccessful = false
    
    func loadCurrentUserData(_ user: UserModel?) {
        guard let user = user else { return }
        
        name = user.name
        email = user.email  // Load email
        phoneNumber = user.phoneNumber
        gender = user.gender
        institution = user.educationalInstitution
        profession = user.profession
        address = user.address
        city = user.city
        province = user.province
        role = user.role  // Load role
        
        // Parse date of birth
        if !user.dateOfBirth.isEmpty {
            birthDate = parseDate(user.dateOfBirth) ?? Date()
        }
    }
    
    func updateProfile() async {
        isLoading = true
        isUpdateSuccessful = false
        errorMessage = nil
        
        // Create update request with only non-empty fields
        let request = UpdateProfileRequest(
            name: name.isEmpty ? nil : name,
            email: email.isEmpty ? nil : email,  // Include email
            phoneNumber: phoneNumber.isEmpty ? nil : phoneNumber,
            dateOfBirth: formatDateForAPI(birthDate),
            gender: gender.isEmpty ? nil : gender,
            institution: institution.isEmpty ? nil : institution,
            profession: profession.isEmpty ? nil : profession,
            address: address.isEmpty ? nil : address,
            province: province.isEmpty ? nil : province,
            city: city.isEmpty ? nil : city,
            role: role.isEmpty ? nil : role  // Include role
        )
        
        do {
            let bodyData = try JSONEncoder().encode(request)
            
            let response: UpdateProfileResponse = try await APIService.shared.performRequest(
                endpoint: .updateProfile,
                method: .PUT,
                body: bodyData,
                responseType: UpdateProfileResponse.self
            )
            
            if response.success, let updatedUser = response.data {
                // Update AuthManager with new user data
                AuthManager.shared.updateUserData(updatedUser)
                isUpdateSuccessful = true
            } else {
                errorMessage = response.message
            }
        } catch {
            errorMessage = "Gagal memperbarui profil: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    func clearError() {
        errorMessage = nil
    }
    
    private func parseDate(_ dateString: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.date(from: dateString)
    }
    
    private func formatDateForAPI(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
}
