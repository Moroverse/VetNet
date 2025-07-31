// PatientNavigationTests.swift
// Copyright (c) 2025 Moroverse
// VetNet Patient Navigation Tests

import Testing
import Foundation
import SwiftUIRouting
import FactoryKit
@testable import VetNet

@Suite("Patient Management Navigation Tests")
@MainActor
struct PatientNavigationTests {
    
    // MARK: - PatientFormMode Tests
    
    @Test("PatientFormMode create mode has correct properties")
    func testFormModeCreate() {
        let mode = PatientFormMode.create
        
        #expect(mode.id == "create")
        #expect(mode.title == "New Patient")
        #expect(mode.patient == nil)
    }
    
    @Test("PatientFormMode edit mode has correct properties")
    func testFormModeEdit() {
        let patient = Patient(
            name: "Test Dog",
            species: .dog,
            breed: .dogBeagle,
            birthDate: Date(),
            weight: Measurement(value: 10, unit: .kilograms),
            ownerName: "Test Owner",
            ownerPhoneNumber: "555-1234"
        )
        
        let mode = PatientFormMode.edit(patient)
        
        #expect(mode.id == "edit-\(patient.id.value.uuidString)")
        #expect(mode.title == "Edit Patient")
        #expect(mode.patient == patient)
    }
    
    @Test("PatientFormMode equality comparison works correctly")
    func testFormModeEquality() {
        let patient1 = Patient(
            name: "Dog 1",
            species: .dog,
            breed: .dogBeagle,
            birthDate: Date(),
            weight: Measurement(value: 10, unit: .kilograms),
            ownerName: "Owner 1",
            ownerPhoneNumber: "555-1111"
        )
        
        let patient2 = Patient(
            name: "Dog 2",
            species: .dog,
            breed: .dogLabrador,
            birthDate: Date(),
            weight: Measurement(value: 25, unit: .kilograms),
            ownerName: "Owner 2",
            ownerPhoneNumber: "555-2222"
        )
        
        let createMode1 = PatientFormMode.create
        let createMode2 = PatientFormMode.create
        let editMode1 = PatientFormMode.edit(patient1)
        let editMode2 = PatientFormMode.edit(patient1)
        let editMode3 = PatientFormMode.edit(patient2)
        
        #expect(createMode1 == createMode2)
        #expect(editMode1 == editMode2)
        #expect(editMode1 != editMode3)
        #expect(createMode1 != editMode1)
    }
    
    // MARK: - PatientFormResult Tests
    
    @Test("PatientFormResult created result has correct properties")
    func testFormResultCreated() {
        let patient = Patient(
            name: "New Patient",
            species: .cat,
            breed: .catSiamese,
            birthDate: Date(),
            weight: Measurement(value: 4, unit: .kilograms),
            ownerName: "Test Owner",
            ownerPhoneNumber: "555-0000"
        )
        
        let result = PatientFormResult.created(patient)
        
        #expect(result.isSuccess == true)
        #expect(result.isCancelled == false)
        #expect(result.isError == false)
        #expect(result.error == nil)
        #expect(result.patient == patient)
        #expect(result.successMessage == "Patient created successfully")
    }
    
    @Test("PatientFormResult created with custom message")
    func testFormResultCreatedCustomMessage() {
        let patient = Patient(
            name: "Custom Patient",
            species: .dog,
            breed: .dogPoodle,
            birthDate: Date(),
            weight: Measurement(value: 8, unit: .kilograms),
            ownerName: "Test Owner",
            ownerPhoneNumber: "555-0000"
        )
        
        let customMessage = "Patient successfully registered"
        let result = PatientFormResult.created(patient, message: customMessage)
        
        #expect(result.successMessage == customMessage)
    }
    
    @Test("PatientFormResult updated result has correct properties")
    func testFormResultUpdated() {
        let patient = Patient(
            name: "Updated Patient",
            species: .cat,
            breed: .catPersian,
            birthDate: Date(),
            weight: Measurement(value: 5, unit: .kilograms),
            ownerName: "Test Owner",
            ownerPhoneNumber: "555-0000"
        )
        
        let result = PatientFormResult.updated(patient)
        
        #expect(result.isSuccess == true)
        #expect(result.isCancelled == false)
        #expect(result.isError == false)
        #expect(result.error == nil)
        #expect(result.patient == patient)
        #expect(result.successMessage == "Patient updated successfully")
    }
    
    @Test("PatientFormResult deleted result has correct properties")
    func testFormResultDeleted() {
        let patient = Patient(
            name: "Deleted Patient",
            species: .dog,
            breed: .dogBulldog,
            birthDate: Date(),
            weight: Measurement(value: 20, unit: .kilograms),
            ownerName: "Test Owner",
            ownerPhoneNumber: "555-0000"
        )
        
        let result = PatientFormResult.deleted(patient)
        
        #expect(result.isSuccess == true)
        #expect(result.isCancelled == false)
        #expect(result.isError == false)
        #expect(result.error == nil)
        #expect(result.patient == patient)
        #expect(result.successMessage == "Patient deleted successfully")
    }
    
    @Test("PatientFormResult cancelled result has correct properties")
    func testFormResultCancelled() {
        let result = PatientFormResult.cancelled
        
        #expect(result.isSuccess == false)
        #expect(result.isCancelled == true)
        #expect(result.isError == false)
        #expect(result.error == nil)
        #expect(result.patient == nil)
        #expect(result.successMessage == nil)
    }
    
    @Test("PatientFormResult error result has correct properties")
    func testFormResultError() {
        struct TestError: LocalizedError {
            let errorDescription: String? = "Test error occurred"
        }
        
        let testError = TestError()
        let result = PatientFormResult.error(testError)
        
        #expect(result.isSuccess == false)
        #expect(result.isCancelled == false)
        #expect(result.isError == true)
        #expect(result.error?.localizedDescription == "Test error occurred")
        #expect(result.patient == nil)
        #expect(result.successMessage == nil)
    }
    
    // MARK: - PatientRoute Tests
    
    @Test("PatientRoute patientDetail has correct associated value")
    func testPatientRouteDetail() {
        let patient = Patient(
            name: "Detail Patient",
            species: .dog,
            breed: .dogLabrador,
            birthDate: Date(),
            weight: Measurement(value: 30, unit: .kilograms),
            ownerName: "Test Owner",
            ownerPhoneNumber: "555-0000"
        )
        
        let route = PatientRoute.patientDetail(patient)
        
        if case .patientDetail(let routePatient) = route {
            #expect(routePatient == patient)
        } else {
            #expect(Bool(false), "Route should be patientDetail")
        }
    }
    
    @Test("PatientRoute medicalHistory has correct associated value")
    func testPatientRouteMedicalHistory() {
        let patient = Patient(
            name: "Medical Patient",
            species: .cat,
            breed: .catMaineCoon,
            birthDate: Date(),
            weight: Measurement(value: 7, unit: .kilograms),
            ownerName: "Test Owner",
            ownerPhoneNumber: "555-0000"
        )
        
        let route = PatientRoute.medicalHistory(patient)
        
        if case .medicalHistory(let routePatient) = route {
            #expect(routePatient == patient)
        } else {
            #expect(Bool(false), "Route should be medicalHistory")
        }
    }
    
    @Test("PatientRoute appointmentHistory has correct associated value")
    func testPatientRouteAppointmentHistory() {
        let patient = Patient(
            name: "Appointment Patient",
            species: .dog,
            breed: .dogGoldenRetriever,
            birthDate: Date(),
            weight: Measurement(value: 35, unit: .kilograms),
            ownerName: "Test Owner",
            ownerPhoneNumber: "555-0000"
        )
        
        let route = PatientRoute.appointmentHistory(patient)
        
        if case .appointmentHistory(let routePatient) = route {
            #expect(routePatient == patient)
        } else {
            #expect(Bool(false), "Route should be appointmentHistory")
        }
    }
    
    @Test("PatientRoute equality comparison works correctly")
    func testPatientRouteEquality() {
        let patient1 = Patient(
            name: "Patient 1",
            species: .dog,
            breed: .dogBeagle,
            birthDate: Date(),
            weight: Measurement(value: 12, unit: .kilograms),
            ownerName: "Owner 1",
            ownerPhoneNumber: "555-1111"
        )
        
        let patient2 = Patient(
            name: "Patient 2",
            species: .cat,
            breed: .catSiamese,
            birthDate: Date(),
            weight: Measurement(value: 4, unit: .kilograms),
            ownerName: "Owner 2",
            ownerPhoneNumber: "555-2222"
        )
        
        let detailRoute1 = PatientRoute.patientDetail(patient1)
        let detailRoute2 = PatientRoute.patientDetail(patient1)
        let detailRoute3 = PatientRoute.patientDetail(patient2)
        let medicalRoute1 = PatientRoute.medicalHistory(patient1)
        
        #expect(detailRoute1 == detailRoute2)
        #expect(detailRoute1 != detailRoute3)
        #expect(detailRoute1 != medicalRoute1)
    }
}