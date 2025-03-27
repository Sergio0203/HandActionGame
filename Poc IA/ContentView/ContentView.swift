
import SwiftUI

struct ContentView: View {
    @StateObject var vm = ContentViewModel()
    var body: some View {
            ZStack {
                CameraView(image: $vm.currentFrame, points: $vm.points)
                VStack {
                    predictionLabels
                        .padding(.top, 40)
                    Spacer()
                }
            }
            .ignoresSafeArea()
    }
    
    @ViewBuilder
    private var predictionLabels: some View {
        Text("Movimento da mão direita: \(vm.rightPrediction)")
        Text("Confiança: \(vm.rightPredictionConfidence)")
        
        Text("Mäo esquerda: \(vm.leftPrediction)")
        Text("Confiança: \(vm.leftPredictionConfidence)")
    }
}



#Preview {
    ContentView()
}
