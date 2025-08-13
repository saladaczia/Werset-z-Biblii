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
            NavigationView {
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
                                Image(systemName: "xmark")
                                    .onTapGesture {
                                        vm.onClickedSettings.toggle()
                                    }
                            }
                        }
                    }
    }
}

#Preview {
    SettingView()
        .environmentObject(VersesViewModel())
}
