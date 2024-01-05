import SwiftUI

struct StarView: View {
    var fillValue: Double
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .foregroundColor(.gray) // Background color for empty part
                Rectangle()
                    .fill(Color.orange) // Color for filled part
                    .frame(width: geometry.size.width * fillValue)
            }
        }
        .mask(
            Image(systemName: "star.fill")
                .resizable()
        )
        .aspectRatio(1, contentMode: .fit)
        .frame(width: 15, height: 15) // Adjust the size of each star
    }
}

