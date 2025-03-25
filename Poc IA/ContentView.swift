
import SwiftUI

struct ContentView: View {
    @StateObject var vm = ContentViewModel()
    var body: some View {
            ZStack {
                vm.arContainer
                VStack {
                    predictionLabel
                    Spacer()
                }
            }
    }
    @ViewBuilder
    private var predictionLabel: some View {
        Text("Prediction: \(vm.prediction)")
        Text("Confidence: \(vm.predictionConfidence)")
    }
}



#Preview {
    ContentView()
}
