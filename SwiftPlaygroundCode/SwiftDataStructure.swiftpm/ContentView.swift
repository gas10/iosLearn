import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundColor(.accentColor)
            Text(getOutput())
        }
    }
    
    func getOutput() -> String {
        let runner = Runner()
        return runner.test()
    }
}
