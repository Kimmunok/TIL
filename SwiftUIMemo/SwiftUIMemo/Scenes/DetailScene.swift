//
//  DetailScene.swift
//  SwiftUIMemo
//
//  Created by 김문옥 on 2020/07/19.
//  Copyright © 2020 MunokKim. All rights reserved.
//

import SwiftUI

struct DetailScene: View {
    @ObservedObject var memo: Memo
    
    @EnvironmentObject var store: MemoStore
    @EnvironmentObject var formatter: DateFormatter
    
    @State private var isShowEditSheet = false
    
    var body: some View {
        VStack {
            ScrollView {
                VStack {
                    HStack {
                        Text(self.memo.content)
                            .padding()
                        
                        Spacer()
                    }
                    
                    Text("\(self.memo.insertDate, formatter: formatter)")
                        .padding()
                        .font(.footnote)
                        .foregroundColor(Color(.secondaryLabel))
                }
            }
        }
        .navigationBarTitle("메모 보기")
        .navigationBarItems(
            trailing: Button(
                action: {
                    self.isShowEditSheet.toggle()
            },
                label: {
                    Image(systemName: "square.and.pencil")
            }
            )
                .padding()
                .sheet(
                    isPresented: $isShowEditSheet,
                    content: {
                        ComposeScene(showComposer: self.$isShowEditSheet, memo: self.memo)
                            .environmentObject(self.store)
                            .environmentObject(KeyboardObserver())
                }
            )
        )
    }
}

struct DetailScene_Previews: PreviewProvider {
    static var previews: some View {
        DetailScene(memo: Memo(content: "SwiftUI"))
            .environmentObject(MemoStore())
            .environmentObject(DateFormatter.memoDateFormatter)
    }
}
