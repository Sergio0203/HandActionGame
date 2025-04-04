
import SwiftUI

struct ContentView: View {
    @StateObject var vm = ContentViewModel()
    var body: some View {
            ZStack {
                //vm.arContainer
                vm.cameraContainer
            
                joints
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
    
    @ViewBuilder
    private var joints: some View {
        ForEach(vm.points, id: \.self) { point in
            Circle()
                .fill(Color.red)
                .frame(width: 10)
                .position(x: point.x, y: point.y)
        }
    }
}



#Preview {
    ContentView()
}
