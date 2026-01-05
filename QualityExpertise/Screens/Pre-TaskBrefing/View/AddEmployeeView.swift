//
//  AddInjuredPersonView.swift
//  QualityExpertise
//
//  Created by Amarjith B on 24/10/25.
//

import SwiftUI
import Combine

struct AddInjuredPersonView: View {
    @Environment(\.viewController) private var viewControllerHolder: UIViewController?
    @Environment(\.presentationMode) private var presentationMode

    // MARK: - Bindings
    @Binding var employeeCode: String
    @Binding var employeeName: String
    @Binding var employeeCompany: String
    @Binding var employeeProfession: String
    @Binding var attendentedEmployees: [Employee]
    @Binding var manualEmployees: [Employee]
    @Binding var bulkEmployees: [Employee]
    var isViewOnly: Bool
    @ObservedObject var viewModel: CreatePreTaskViewModel
    @Binding var groupData: GroupData?

    // MARK: - Local State
    @State private var isDropDownShowing = false
    @State private var isSelectionInProgress = false
    @State private var debouncedEmployeeCode: String = ""

    // debounce worker
    @State private var debounceTask: DispatchWorkItem?

    var body: some View {
        VStack(spacing: 10) {
            Text("attendes".localizedString())
                .foregroundColor(Color.Blue.THEME)
                .font(.extraBold(14))
                .leftAlign()
                .padding(.bottom, 10)

            if !attendentedEmployees.isEmpty {
                employeeDetailsView
            }

            if !isViewOnly {
                employeeForm
            }
        }
        .onChange(of: employeeCode) { newValue in
            handleDebounce(newValue)
        }
        .onChange(of: manualEmployees) { _ in
            attendentedEmployees = manualEmployees + bulkEmployees
        }
        .onChange(of: bulkEmployees) { _ in
            attendentedEmployees = manualEmployees + bulkEmployees
        }
    }
}

// MARK: - Components
extension AddInjuredPersonView {

    private var employeeDetailsView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 0) {

                // Header
                HStack {
                    Group {
                        Text("employee_code".localizedString()).bold().frame(width: 150, alignment: .leading)
                        Text("employee_name".localizedString()).bold().frame(width: 150, alignment: .leading)
                        Text("company_name".localizedString()).bold().frame(width: 150, alignment: .leading)
                        Text("profession".localizedString()).bold().frame(width: isViewOnly ? 150 : 300, alignment: .leading)
                    }
                    .font(.regular(12))
                    .foregroundColor(.white)
                }
                .padding(10)
                .background(Color.Blue.THEME)

                Divider()

                LazyVStack(alignment: .leading, spacing: 0) {
                    ForEach(attendentedEmployees.indices, id: \.self) { index in
                        let emp = attendentedEmployees[index]
                        HStack {
                            Group {
                                Text(displayText(emp.employeeCode)).frame(width: 150, alignment: .leading)
                                Text(displayText(emp.employeeName)).frame(width: 150, alignment: .leading)
                                Text(displayText(emp.companyName)).frame(width: 150, alignment: .leading)
                                Text(displayText(emp.profession)).frame(width: 150, alignment: .leading)
                            }
                            .font(.regular(12))
                            .foregroundColor(.black)

                            if !isViewOnly {
                                Button {
                                    bulkEmployees.removeAll { $0.id == emp.id }
                                    manualEmployees.removeAll { $0.employeeCode == emp.employeeCode }
                                } label: {
                                    Image(IC.ACTIONS.MINUS)
                                }
                                .frame(width: 100)
                            }
                        }
                        .padding(8)
                        Divider()
                    }
                }
            }
        }
    }

    private var employeeForm: some View {
        Group {
            
            ThemeTextEditorView(text: $employeeCode,
                                title: "employee_code".localizedString().uppercased(),
                                disabled: false,
                                keyboardType: .default,
                                isMandatoryField: false,
                                limit: nil,
                                placeholderColor: nil,
                                isTitleCapital: false)

            if isDropDownShowing {
                employeeDropdown
            }

            ThemeTextEditorView(text: $employeeName,
                                title: "employee_name".localizedString().uppercased(),
                                disabled: false,
                                keyboardType: .default,
                                isMandatoryField: false,
                                limit: nil,
                                placeholderColor: nil,
                                isTitleCapital: false)

            ThemeTextEditorView(text: $employeeCompany,
                                title: "company_name".localizedString().uppercased(),
                                disabled: false,
                                keyboardType: .default,
                                isMandatoryField: false,
                                limit: nil,
                                placeholderColor: nil,
                                isTitleCapital: false)

            ThemeTextEditorView(text: $employeeProfession,
                                title: "profession".localizedString().uppercased(),
                                disabled: false,
                                keyboardType: .default,
                                isMandatoryField: false,
                                limit: nil,
                                placeholderColor: nil,
                                isTitleCapital: false)

            formButtons.padding(.vertical, 10)
        }
    }

    private var employeeDropdown: some View {
        let filtered = viewModel.employees.filter {
            ($0.employeeCode ?? "").lowercased().contains(debouncedEmployeeCode.lowercased())
        }

        return Group {
            if !filtered.isEmpty {
                ScrollView(.vertical) {
                    VStack(spacing: 0) {
                        ForEach(filtered, id: \.employeeCode) { employee in
                            let isSelected = manualEmployees.contains { $0.employeeCode == employee.employeeCode }

                            employeeScrollViewRow(employee: employee, isSelected: isSelected)
                                .onTapGesture {
                                    if isSelected {
                                        viewModel.toast = Toast.alert(
                                            title: "alert".localizedString(),
                                            subTitle: "employee_already_added".localizedString()
                                        )
                                    } else {
                                        selectEmployee(employee)
                                    }
                                }
                        }
                    }
                }
                .frame(height: 300)
            } else if !debouncedEmployeeCode.isEmpty {
                Text("no_matching_employee_found".localizedString())
                    .foregroundColor(.gray)
                    .font(.regular(12))
                    .padding(.vertical, 10)
            }
        }
    }

    private var formButtons: some View {
        HStack(spacing: 10) {
            Button { addEmployee() } label: {
                HStack {
                    Image(IC.ACTIONS.PLUS).foregroundColor(Color.Green.DARK_GREEN)
                    Text("add_employee".localizedString())
                        .foregroundColor(Color.Blue.THEME)
                        .font(.regular(12))
                    Spacer()
                }
            }

            Spacer()

            if let groupData {
                Button {
                    viewControllerHolder?.present(style: .overCurrentContext) {
                        BulkUploadEmployeeView(groupData: groupData, employees: $bulkEmployees)
                            .localize()
                    }
                } label: {
                    HStack {
                        Image(IC.ACTIONS.PLUS).foregroundColor(Color.Green.DARK_GREEN)
                        Text("bulk_upload_employees".localizedString())
                            .foregroundColor(Color.Blue.THEME)
                            .font(.regular(12))
                    }
                }
            }
        }
    }

    private func employeeScrollViewRow(employee: Employee, isSelected: Bool) -> some View {
        VStack(spacing: 0) {
            HStack(spacing: 10) {
                Image(isSelected ? IC.ACTIONS.CHECKBOX_ON : IC.ACTIONS.CHECKBOX_OFF)
                    .resizable()
                    .frame(width: 48, height: 48)
                    .padding(.leading, 8)

                VStack(alignment: .leading, spacing: 10) {
                    Text(employee.employeeName)
                        .font(.medium(14))
                        .foregroundColor(Color.Blue.DARK_BLUE_GREY)

                    Text(employee.companyName ?? Constants.NOTHING)
                        .font(.regular(13))
                        .foregroundColor(Color.Grey.SLATE)

                    Text(employee.profession ?? Constants.NOTHING)
                        .font(.regular(13))
                        .foregroundColor(Color.Grey.SLATE)
                }

                Spacer()

                Text(employee.employeeCode ?? Constants.NOTHING)
                    .font(.regular(13))
                    .foregroundColor(Color.Grey.SLATE)
            }
            .padding(.vertical, 12)

            Divider().frame(height: 0.5)
        }
    }

    // MARK: - Logic
    private func selectEmployee(_ employee: Employee) {
        isSelectionInProgress = true

        employeeCode = employee.employeeCode ?? "-"
        employeeName = employee.employeeName
        employeeCompany = employee.companyName ?? "-"
        employeeProfession = employee.profession ?? "-"

        isDropDownShowing = false
    }

    private func addEmployee() {
        guard !employeeName.isEmpty,
              !employeeCode.isEmpty,
              !employeeCompany.isEmpty,
              !employeeProfession.isEmpty
        else {
            viewModel.toast = Toast.alert(
                title: "alert".localizedString(),
                subTitle: "all_mandatory_fields_required".localizedString()
            )
            return
        }

        let emp = Employee(
            id: -1,
            employeeCode: employeeCode,
            employeeName: employeeName,
            companyName: employeeCompany,
            profession: employeeProfession
        )

        manualEmployees.append(emp)
        resetEmployeeFields()

        viewModel.toast = Toast.alert(
            title: "success".localizedString(),
            subTitle: "employee_added".localizedString(),
            isSuccess: true
        )
    }

    private func resetEmployeeFields() {
        employeeCode = ""
        employeeName = ""
        employeeCompany = ""
        employeeProfession = ""
    }

    private func displayText(_ value: String?) -> String {
        let trimmed = value?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        return trimmed.isEmpty ? Constants.HYPHEN : trimmed.uppercased()
    }

    // MARK: - Debounce Handler
    private func handleDebounce(_ newValue: String) {
        debounceTask?.cancel()

        let task = DispatchWorkItem {
            debouncedEmployeeCode = newValue

            if isSelectionInProgress {
                isSelectionInProgress = false
            } else {
                isDropDownShowing = !newValue.isEmpty
            }
        }

        debounceTask = task
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: task)
    }
}
