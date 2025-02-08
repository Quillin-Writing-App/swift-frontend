
import SwiftUI

struct ContentView: View {
  var body: some View {
    ZStack() {
      Group {
        Rectangle()
          .foregroundColor(.clear)
          .frame(width: 834, height: 73)
          .background(Color(red: 0.25, green: 0.25, blue: 0.25))
          .offset(x: 0, y: -560.50)
        ZStack() {

        }
        .frame(width: 19, height: 24.48)
        .offset(x: 386.50, y: -550.99)
        ZStack() {

        }
        .frame(width: 20, height: 25.46)
        .offset(x: 345, y: -550.50)
        ZStack() {

        }
        .frame(width: 24, height: 25)
        .offset(x: 53, y: -550.50)
        ZStack() {

        }
        .frame(width: 26, height: 26)
        .offset(x: 6, y: -550)
        ZStack() {

        }
        .frame(width: 27, height: 27)
        .offset(x: 299.50, y: -550.50)
        ZStack() {

        }
        .frame(width: 18, height: 19.58)
        .offset(x: -301, y: -550.50)
        ZStack() {

        }
        .frame(width: 18, height: 19.58)
        .offset(x: -341, y: -550.50)
        ZStack() {

        }
        .frame(width: 20, height: 22)
        .offset(x: -385, y: -549)
        Rectangle()
          .foregroundColor(.clear)
          .frame(width: 834, height: 1121)
          .background(Color(red: 0.16, green: 0.16, blue: 0.16))
          .offset(x: 1, y: 36.50)
      };Group {
        ZStack() {

        }
        .frame(width: 25, height: 24)
        .offset(x: -41.50, y: -550)
      }
    }
    .frame(width: 834, height: 1194)
    .background(.white);
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
