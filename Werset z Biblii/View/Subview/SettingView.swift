//
//  SettingView.swift
//  Werset z Biblii
//
//  Created by Maciej Sołoducha on 28/06/2025.
//

import SwiftUI

struct SettingView: View {
    
    // ViewModel
    @EnvironmentObject private var vm: VersesViewModel
    
    var body: some View {
            NavigationStack {
                        List {
                            Section(header: Text("WYGLĄD")) {
                                NavigationLink {
                                    ThemesView()
                                } label: {
                                    HStack {
                                        Image(systemName: "paintpalette")
                                            .foregroundColor(.accentColor)
                                        Text("Wybór motywu")
                                    }
                                }
                                
                                .contentShape(Rectangle())
                            }
                            
                            Section(header: Text("WIDGETY")) {
                                NavigationLink {
                                    WidgetGuideView()
                                } label: {
                                    Label("Werset na ekranie głównym", systemImage: "square.grid.2x2")
                                }
                            }

                            Section(header: Text("POWIADOMIENIA")) {
                                NavigationLink {
                                    RemindersView()
                                } label: {
                                    HStack {
                                        Image(systemName: "bell")
                                            .foregroundColor(.accentColor)
                                        Text("Codzienne powiadomienie")
                                    }
                                }
                                
                                .contentShape(Rectangle())
                            }
                        }
                        .listStyle(InsetGroupedListStyle())
                        .navigationTitle("Ustawienia")
                        .toolbar {
                            ToolbarItem(placement: .topBarLeading) {
                                Button("Zamknij", systemImage: "xmark") {
                                    vm.onClickedSettings = false
                                }
                                .labelStyle(.iconOnly)
                            }
                        }
                    }
    }
}

#Preview {
    SettingView()
        .environmentObject(VersesViewModel())
        .environmentObject(ReminderStore())
}
