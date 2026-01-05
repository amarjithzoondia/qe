//
//  HomeScreenIconsView.swift
//  ALNASR
//
//  Created by Amarjith B on 03/06/25.
//

import SwiftUI

struct HomeScreenIconsView: View {
    @Environment(\.viewController) private var viewControllerHolder: UIViewController?
    @Binding var showToast: Bool
    var isGuest = UserManager.getCheckOutUser()?.isGuestUser
    
    var body: some View {
        VStack(spacing: 17) {
            Text("project_based_modules".localizedString())
                .font(.medium(17))
                .foregroundColor(Color.black)
            
            Group {
                // Row 1
                HStack(spacing: 16) {
                    DashboardButton(
                        imageName: IC.HOMESCREEN.SEARCH,
                        title: "audits_and_inspections".localizedString(),
                        backgroundColor: Color.Blue.LIGHT_BLUE,
                        destination: nil as EmptyView?
                    )
                    .onTapGesture {
                        viewControllerHolder?.present(style: .overCurrentContext) {
                            InspectionsListView()
                                .localize()
                        }
                    }
                    
                    DashboardButton(
                        imageName: IC.HOMESCREEN.PIPE,
                        title: "incidents".localizedString(),
                        backgroundColor: Color.Pink.LIGHT,
                        destination: nil as EmptyView?
                    )
                    .onTapGesture {
                        viewControllerHolder?.present(style: .overCurrentContext) {
                            IncidentListView()
                                .localize()
                        }
                    }
                }
                
                // Row 2
                HStack(spacing: 16) {
                    DashboardButton(
                        imageName: IC.HOMESCREEN.TELESCOPE,
                        title: "observation".localizedString(),
                        backgroundColor: Color.Orange.LIGHT_ORANGE,
                        destination: nil as EmptyView?
                    )
                    .onTapGesture {
                        viewControllerHolder?.present(style: .overCurrentContext) {
                            NFObservationListContentView()
                                .localize()
                        }
                    }
                    
                    ZStack {
                        DashboardButton(
                            imageName: IC.HOMESCREEN.HELMET,
                            title: "permit_to_work".localizedString(),
                            backgroundColor: Color.Yellow.LIGHT_YELLOW,
                            destination: EmptyView()
                        )
                        .disabled(true)
                        
                        Color.clear
                            .contentShape(Rectangle())
                            .onTapGesture {
                                withAnimation {
                                    showToast = true
                                }
                            }
                    }
                }
                
                // Row 3
                HStack(spacing: 16) {
                    DashboardButton(
                        imageName: IC.HOMESCREEN.LIST,
                        title: "pre_task_briefing".localizedString(),
                        backgroundColor: Color.Violet.LIGHT_VIOLET,
                        destination: nil as EmptyView?
                    )
                    .onTapGesture {
                        viewControllerHolder?.present(style: .overCurrentContext) {
                            PreTaskListView()
                                .localize()
                        }
                    }
                    
                    DashboardButton(
                        imageName: IC.HOMESCREEN.TOOLBOX,
                        title: "toolbox_talk".localizedString(),
                        backgroundColor: Color.Blue.LIGHT_BLUE,
                        destination: nil as EmptyView?
                    )
                    .onTapGesture {
                        viewControllerHolder?.present(style: .overCurrentContext) {
                            ToolBoxListView()
                                .localize()
                        }
                    }
                }
                
                // Row 4
                HStack(spacing: 16) {
                    DashboardButton(
                        imageName: IC.HOMESCREEN.SECURITY,
                        title: "violation".localizedString(),
                        backgroundColor: Color.Pink.LIGHT,
                        destination: nil as EmptyView?
                    )
                    .onTapGesture {
                        viewControllerHolder?.present(style: .overCurrentContext) {
                            ViolationListView()
                                .localize()
                        }
                    }
                    
                    DashboardButton(
                        imageName: IC.HOMESCREEN.LESSON_LEARNED,
                        title: "lesson_learned_title".localizedString(),
                        backgroundColor: Color.Orange.ORANGE_CREAM,
                        destination: nil as EmptyView?
                    )
                    .onTapGesture {
                        viewControllerHolder?.present(style: .overCurrentContext) {
                            LessonLearnedListView()
                                .localize()
                        }
                    }
                }
            }
            
            Spacer()
        }
        .padding(.horizontal, 24)
    }
}

#Preview {
    HomeScreenIconsView(showToast: .constant(false))
}
