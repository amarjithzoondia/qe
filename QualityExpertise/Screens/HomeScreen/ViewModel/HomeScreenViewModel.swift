//
//  HomeScreenIconsViewModel.swift
//  ALNASR
//
//  Created by Amarjith B on 04/06/25.
//

import UIKit

class HomeScreenViewModel: BaseViewModel,ObservableObject {
    @Published var user = UserManager().user
    
    private let localRepository = InspectionDBRepository()
    private let localUseCase:InspectionDBUseCase
    
    private let localPreTaskRepository = PreTaskDBRepository()
    private let localPreTaskUseCase: PreTaskDBUseCase
    
    override init() {
        localUseCase = InspectionDBUseCase(repository: localRepository)
        localPreTaskUseCase = PreTaskDBUseCase(repository: localPreTaskRepository)
    }
    
    func logoutUser(completed: @escaping () -> ()) {
        UserRequest
            .logOut
            .makeCall(responseType: CommonResponse.self) { (isLoading) in
                self.showActionsLoader(loading: isLoading)
            } success: { result in
                DispatchQueue.main.async {
                    UserManager.logout()
                    completed()
                }
            } failure: { (error) in
                self.toast = error.toast
            }
    }
    
    func checkRole() {
        DashboardRequest.dashBoardFlag(params: .init(flowType: .newFlow)).makeCall(responseType: DashboardResponse.self) { _ in
        } success: { response in
            UserManager.saveIsGroupAdmin(isGroupAdmin: response.isGroupAdmin ?? false)
            UserManager.shared.notificationUnReadCount = response.notificationCount
            UserManager.shared.pendingActionsCount = response.pendingActionsCount
        } failure: { error in
            self.toast = error.toast
        }

    }
    
    func getInspectionsContentList() {
        self.error = nil
        var updatedTime: String? = nil

        do {
            updatedTime = try localUseCase.getLatestUpdatedTime()?.formattedDateString(format: Constants.DateFormat.REPO_DATE_TIME)
        } catch {
            updatedTime = nil
            self.error = error as? SystemError
        }

        let params = InspectionContentsParams(updatedTime: updatedTime)

        InspectionsRequest.contents(params: params)
            .makeCall(responseType: InspectionContentsResponse.self) { [weak self] isLoading in
                DispatchQueue.main.async {
                    self?.isLoading = isLoading
                }
            } success: { [weak self] response in
                print("\n==============================")
                print("🚀 Fetching Inspection Contents")
                print("==============================")

                do {
                    if !response.contentsList.isEmpty {
                        try self?.localUseCase.saveContents(contents: response)
                        print("✅ Successfully saved \(response.contentsList.count) inspection content(s) locally!")
                    } else {
                        print("📦 No new inspection contents to update — already up-to-date.")
                    }

                    print("\n==============================")
                    print(response.contentsList.isEmpty
                          ? "✅ Local data is up to date."
                          : "🎯 Local inspection database successfully updated.")
                    print("==============================\n")

                } catch {
                    DispatchQueue.main.async {
                        self?.error = error as? SystemError
                        print("❌ Failed to save inspection contents locally: \(error.localizedDescription)")
                    }
                }
            } failure: { [weak self] error in
                DispatchQueue.main.async {
                    self?.error = error
                    print("\n==============================")
                    print("⚠️ Failed to fetch inspection contents:")
                    print("💥 Error → \(error.localizedDescription)")
                    print("==============================\n")
                }
            }
    }


    func getAuditsInspectionForms() {
        var updatedTime: String? = nil

        do {
            updatedTime = try localUseCase.getUpdatedAuditItemsDate()
        } catch {
            self.error = error as? SystemError
            updatedTime = nil
        }

        InspectionsRequest.auditItems(params: .init(updatedTime: updatedTime))
            .makeCall(responseType: AuditsInspectionsListResponse.self) { isLoading in
                self.isLoading = isLoading
            } success: { response in
                print("\n==============================")
                print("🧾 Fetching Audit Inspection Forms")
                print("==============================")
                print("🕓 Server updatedTime: \(response.updatedTime ?? "nil")")
                print("🖥️ Local updatedTime: \(updatedTime ?? "nil")")

                do {
                    if response.updatedTime != updatedTime {
                        try self.localUseCase.saveAuditItems(response)
                        print("✅ Audit items updated locally with latest data!")
                    } else {
                        print("📦 Audit items are already up-to-date — no changes needed.")
                    }

                    print("\n==============================")
                    print(response.updatedTime != updatedTime
                          ? "🎯 Local audit database successfully updated."
                          : "✅ No updates detected — local data is current.")
                    print("==============================\n")

                } catch {
                    self.error = error as? SystemError
                    print("❌ Failed to save audit items locally: \(error.localizedDescription)")
                }

            } failure: { error in
                self.error = error
                print("\n==============================")
                print("⚠️ Failed to fetch audit inspection forms:")
                print("💥 Error → \(error.localizedDescription)")
                print("==============================\n")
            }
    }


    func getPreTaskContentsList() {
        self.error = nil
        var contentsUpdatedTime: String? = nil
        var questionsUpdatedTime: String? = nil
        do {
            contentsUpdatedTime = try localPreTaskUseCase.getLatestContentsUpdatedTime()
            questionsUpdatedTime = try localPreTaskUseCase.getLatestQuestionsUpdatedTime()
        } catch {
            self.error = error as? SystemError
        }
        let params = PreTaskContentsParams(contentsUpdatedTime: contentsUpdatedTime, questionsUpdatedTime: questionsUpdatedTime)

        PreTaskRequest.contents(params: params)
            .makeCall(responseType: PreTaskAPI.TopicsResponse.self) { [weak self] isLoading in
                DispatchQueue.main.async {
                    self?.isLoading = isLoading
                }
            } success: { [weak self] response in
                print("\n==============================")
                print("🚀 Fetching Pre-Task Contents & Questions")
                print("==============================")

                do {
                    // --- Handle Contents ---
                    print("\n📚 Processing Contents ...")
                    
                    try self?.localPreTaskUseCase.savePreTaskContents(response.contents, deletedContentIds: response.deletedContentsId, isContentsEmpty: response.isContentEmpty)
                        print("✅ Successfully saved \(response.contents.count) pre-task content(s) locally!")
                        response.contents.forEach {
                            print("   • \( $0.title ) [⏰ \($0.updatedTime ?? "N/A")]")
                        }
                    

                    // --- Handle Questions ---
                    print("\n📝 Processing Questions ...")
                    
                    try self?.localPreTaskUseCase.savePreTaskQuestions(response.questions, deletedQuestionsIds: response.deletedQuestionsId, isQuestionsEmpty: response.isQuestionEmpty)
                        print("✅ Successfully saved \(response.questions.count) pre-task question(s) locally!")
                        response.questions.forEach {
                            print("   • \( $0.title ) [⏰ \($0.updatedTime ?? "N/A")]")
                        }
                    

                    // --- Summary ---
                    print("\n==============================")
                    if response.contents.isEmpty && response.questions.isEmpty {
                        print("✅ No updates available — local data is up to date.")
                    } else {
                        print("🎯 Local pre-task database successfully updated with new data.")
                    }
                    print("==============================\n")

                } catch {
                    DispatchQueue.main.async {
                        self?.error = error as? SystemError
                        self?.toast = error.toast
                        print("❌ Failed to save pre-task data locally: \(error.localizedDescription)")
                    }
                }
            } failure: { [weak self] error in
                DispatchQueue.main.async {
                    self?.error = error
                    print("\n==============================")
                    print("⚠️ Failed to fetch pre-task contents:")
                    print("💥 Error → \(error.localizedDescription)")
                    print("==============================\n")
                }
            }
    }

    
}
