import SwiftUI
import SwiftUIRouting

struct PatientListView: View {
    @Bindable var viewModel: PatientListViewModel
    
    var body: some View {
        List {
            if viewModel.isLoading {
                ProgressView("Loading patients...")
                    .frame(maxWidth: .infinity, alignment: .center)
                    .listRowSeparator(.hidden)
            } else if viewModel.filteredPatients.isEmpty {
                ContentUnavailableView(
                    "No Patients",
                    systemImage: "person.2.slash",
                    description: Text(viewModel.searchText.isEmpty ? "Add a patient to get started" : "No patients match your search")
                )
                .listRowSeparator(.hidden)
            } else {
                ForEach(viewModel.filteredPatients) { patient in
                    PatientRowView(patient: patient)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            viewModel.navigateToPatient(patient)
                        }
                }
                .onDelete(perform: viewModel.deletePatients)
            }
        }
        .searchable(text: $viewModel.searchText, prompt: "Search patients")
        .navigationTitle("Patients")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    Task {
                        await viewModel.addNewPatient()
                    }
                } label: {
                    Label("Add Patient", systemImage: "plus")
                }
            }
        }
        .refreshable {
            viewModel.loadPatients()
        }
    }
}

struct PatientRowView: View {
    let patient: Patient
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(patient.name)
                    .font(.headline)
                    .foregroundStyle(.primary)
                
                Text("MRN: \(patient.medicalRecordNumber)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                Text(patient.condition)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text("\(patient.age) yrs")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    NavigationStack {
        PatientListView(
            viewModel: PatientListViewModel(
                repository: PatientRepository(),
                router: PatientRouter()
            )
        )
    }
}