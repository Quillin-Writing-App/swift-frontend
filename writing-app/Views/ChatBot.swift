//
//  ChatBot.swift
//  writing-app
//
//  Created by yunte lee on 9/2/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        
        VStack {
            HStack {
                Text("Linear Independence Explanation")
                    .frame(alignment: .topLeading)
                    .padding()
                    .font(Font.custom("Inter", size: 30).weight(.light))
                    .foregroundColor(Color(red: 0.94, green: 0.94, blue: 0.92))
            }
            Rectangle()
              .foregroundColor(.clear)
              .frame(width: 767, height: 1)
              .background(Color(red: 0.94, green: 0.94, blue: 0.92))
              .overlay(Rectangle()
              .stroke(.white, lineWidth: 0.50))
            
            Text("Linearly Dependent (Easy Explanation)\n\nA set of vectors (or numbers) is linearly dependent if at least one of them can be made by combining the others.\nThis means you can multiply some of the vectors by numbers, add them together, and get another vector from the same set.\nIf this happens, the set isn’t fully “independent” because at least one vector is just a mix of the others.\n\nExample:\nImagine you have three vectors: A, B, and C.\nIf C can be made using A and B, like this: C=2A+3BC = 2A + 3BC=2A+3B then the set {A, B, C} is linearly dependent.\n\nKey Ideas:\n\n✅ If no vector in the set can be made from the others → Linearly Independent ❌ If at least one vector is just a combination of the others → Linearly Dependent")
              .font(Font.custom("Inter", size: 20).weight(.bold))
              .padding()
              .foregroundColor(Color(red: 0.94, green: 0.94, blue: 0.92))
            
            Rectangle()
              .foregroundColor(.clear)
              .frame(width: 701, height: 1)
              .background(Color(red: 0.67, green: 0.67, blue: 0.67))
              .overlay(
                Rectangle()
                  .stroke(Color(red: 0.67, green: 0.67, blue: 0.67), lineWidth: 0.50)
              )
            Text("Example preset clarifying question 1 ")
              .font(Font.custom("Inter", size: 15).weight(.light))
              .foregroundColor(Color(red: 0.67, green: 0.67, blue: 0.67))
            Rectangle()
              .foregroundColor(.clear)
              .frame(width: 701, height: 1)
              .background(Color(red: 0.67, green: 0.67, blue: 0.67))
              .overlay(
                Rectangle()
                  .stroke(Color(red: 0.67, green: 0.67, blue: 0.67), lineWidth: 0.50)
              )
            Text("Example preset clarifying question 2")
              .font(Font.custom("Inter", size: 15).weight(.light))
              .foregroundColor(Color(red: 0.67, green: 0.67, blue: 0.67))
            Rectangle()
              .foregroundColor(.clear)
              .frame(width: 701, height: 1)
              .background(Color(red: 0.67, green: 0.67, blue: 0.67))
              .overlay(
                Rectangle()
                  .stroke(Color(red: 0.67, green: 0.67, blue: 0.67), lineWidth: 0.50)
              )
            Text("Example preset clarifying question 3")
              .font(Font.custom("Inter", size: 15).weight(.light))
              .foregroundColor(Color(red: 0.67, green: 0.67, blue: 0.67))
            Rectangle()
              .foregroundColor(.clear)
              .frame(width: 701, height: 1)
              .background(Color(red: 0.67, green: 0.67, blue: 0.67))
              .overlay(
                Rectangle()
                  .stroke(Color(red: 0.67, green: 0.67, blue: 0.67), lineWidth: 0.50)
              )
            
            HStack {
                Text("Write any clarifying questions...")
                  .font(Font.custom("Inter", size: 15).weight(.light))
                  .foregroundColor(Color(red: 0.67, green: 0.67, blue: 0.67))
                Spacer()
                Button("CallChat", systemImage: "arrow.up", action: {}) // fillout action here
            }
            .foregroundColor(.clear)
            .frame(width: 701, height: 51)
            .background(Color(red: 0.25, green: 0.25, blue: 0.25))
            .cornerRadius(30)
            .padding()

           
            
        }
        .foregroundColor(.clear)
        .frame(width: 767)
        .background(Color(red: 0.07, green: 0.07, blue: 0.07))
        .cornerRadius(30)
        
        
    }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
