//
//  DraftLessonLearnedListContentView.swift
//  ALNASR
//
//  Created by Amarjith B on 21/07/25.
//

import SwiftUI
import SwiftfulLoadingIndicators

struct DraftLessonLearnedListContentView: View {
    @StateObject private var viewModel = DraftLessonLearnedListViewModel()
    @Environment(\.viewController) private var viewControllerHolder: UIViewController?
    private let updateDraftPublisher = NotificationCenter.default.publisher(for: .UPDATE_DRAFT)
    @State private var deleteLesson: LessonLearned?
    let onNewViolationAdded: (() -> ())?

    var body: some View {
        NavigationView {
            ZStack {
                Color.white
                    .edgesIgnoringSafeArea(.all)
                
                lessonList
                
                if viewModel.isLoading {
                    Color.white.opacity(0.25)
                        .edgesIgnoringSafeArea(.all)
                    VStack {
                        LoadingIndicator(animation: .threeBalls, color: Color.Blue.THEME, size: .medium, speed: .normal)
                    }
                }
            }
            .toast(isPresenting: $viewModel.showToast, duration: Constants.Number.Duration.TOAST) {
                viewModel.toast
            }
            .onAppear {
                viewModel.fetchDraftList()
            }
            .onReceive(updateDraftPublisher, perform: { (output) in
                viewModel.fetchDraftList()
            })
            .navigationBarTitle("lesson_learned_draft".localizedString(), displayMode: .inline)
            .toolbar {
                BackButtonToolBarItem(action: {
                    viewControllerHolder?.dismiss(animated: true, completion: nil)
                })
            }
            .listenToAppNotificationClicks()
        }
        .pickerViewerOverlay(viewerShown: .constant(deleteLesson != nil), title: "delete_draft".localizedString()) {
            VStack {
                LeftAlignedHStack(
                    Text("lesson_delete_confirmation".localizedString())
                        .foregroundColor(Color.Indigo.DARK)
                        .font(.regular(14))
                )
                
                HStack {
                    Button {
                        deleteLesson = nil
                    } label: {
                        Text("cancel".localizedString())
                            .foregroundColor(Color.Grey.DARK_BLUE)
                            .font(.regular(12))
                            .frame(maxWidth: .infinity, minHeight: 35)
                    }
                    .background(Color.Grey.PALE)
                    .cornerRadius(17.5)
                    
                    Spacer()
                    
                    Button {
                        _ = viewModel.deleteViolation(lesson: deleteLesson!)
                        viewModel.fetchDraftList()
                        deleteLesson = nil
                    } label: {
                        Text("continue".localizedString())
                            .foregroundColor(Color.white)
                            .font(.regular(12))
                            .frame(maxWidth: .infinity, minHeight: 35)
                    }
                    .background(Color.Blue.THEME)
                    .cornerRadius(17.5)
                }
                .padding(.top, 10)
                .padding(.bottom, 15)
            }
        }
    }
    
    private var lessonList: some View {
        VStack {
            if viewModel.lessons.count <= 0 {
                "no_lessons_found".localizedString()
                    .viewRetry {
                        viewModel.onRetry()
                    }
                
            } else if let error = viewModel.error {
                error.viewRetry(isError: true) {
                    viewModel.fetchDraftList()
                }
                
                Spacer()
                
            }  else {
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(viewModel.lessons.reversed(), id: \.id) { lesson in
                            DraftLessonLearnedListRowView(
                                lesson: lesson,
                                minusButtonTapped: {
                                    deleteLesson = lesson
                                }
                            )
                            .onTapGesture {
                                viewControllerHolder?.present(style: .overCurrentContext) {
                                    CreateLessonLearnedView(
                                        lesson: nil,
                                        draftLesson: lesson,
                                        onSuccess: ({
                                            viewModel.fetchDraftList()
                                            onNewViolationAdded?()
                                        })
                                    )
                                    .localize()
                                }
                            }
                        }
                    }
                    .padding(.top, 15.5)
                    .padding(.horizontal, 27)
                }
            }
        }
    }
}

struct DraftLessonLearnedListContentView_Previews: PreviewProvider {
    static var previews: some View {
        DraftLessonLearnedListContentView(onNewViolationAdded: nil)
    }
}

