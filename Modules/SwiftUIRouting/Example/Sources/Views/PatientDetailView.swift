import SwiftUI
import SwiftUIRouting

struct PatientDetailView: View {
    @State private var viewModel: PatientDetailViewModel
    
    init(patient: Patient, repository: PatientRepository, router: PatientRouter) {
        self._viewModel = State(initialValue: PatientDetailViewModel(patientId: patient.id, repository: repository, router: router))
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                patientInfoCard
                
                medicalInfoCard
                
                actionButtons
            }
            .padding()
        }
        .navigationTitle(viewModel.patient.name)
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Edit") {
                    Task {
                        await viewModel.editPatient()
                    }
                }
            }
        }
        .overlay {
            if viewModel.isLoading {
                ProgressView()
                    .padding()
                    .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
            }
        }
    }
    
    private var patientInfoCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Patient Information", systemImage: "person.fill")
                .font(.headline)
            
            Divider()
            
            InfoRow(label: "Name", value: viewModel.patient.name)
            InfoRow(label: "Age", value: viewModel.ageDescription)
            InfoRow(label: "MRN", value: viewModel.patient.medicalRecordNumber)
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
    
    private var medicalInfoCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Medical Information", systemImage: "heart.text.square.fill")
                .font(.headline)
            
            Divider()
            
            InfoRow(label: "Condition", value: viewModel.patient.condition)
            InfoRow(label: "Last Visit", value: viewModel.formattedLastVisit)
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
    
    private var actionButtons: some View {
        VStack(spacing: 12) {
            Button {
                Task {
                    await viewModel.scheduleAppointment()
                }
            } label: {
                Label("Schedule Appointment", systemImage: "calendar.badge.plus")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            
            Button {
                Task {
                    await viewModel.exportMedicalRecord()
                }
            } label: {
                Label("Export Medical Record", systemImage: "doc.text")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
        }
        .disabled(viewModel.isLoading)
    }
    
}

struct InfoRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.medium)
        }
    }
}

#Preview {
    NavigationStack {
        PatientDetailView(
            patient: Patient.preview,
            repository: PatientRepository(),
            router: PatientRouter()
        )
    }
}