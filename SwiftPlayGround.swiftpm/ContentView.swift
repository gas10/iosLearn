import SwiftUI

struct ContentView: View {

    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundColor(.accentColor)
            Text(getText())
        }
    }
    
    func getText() -> String {
        let runner = CodeRunner()
        return runner.invoke()
    }
}
