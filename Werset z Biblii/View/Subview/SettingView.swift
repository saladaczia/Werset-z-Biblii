//
//  SettingView.swift
//  Werset z Biblii
//
//  Created by Maciej Sołoducha on 28/06/2025.
//

import SwiftUI

struct SettingView: View {
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            Rectangle().fill(.white)
            Text("SettingView")
            VStack {
                HStack {
                    Image(systemName: "xmark.circle.fill")
                        .resizable()
                        .frame(width: 30, height: 30)
                        .padding(20)
                        .onTapGesture {
                            dismiss()
                        }
                    Spacer()
                }
                Spacer()
            }
        }
        .ignoresSafeArea()
    }
}

#Preview {
    SettingView()
}
