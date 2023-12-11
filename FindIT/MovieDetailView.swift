import SwiftUI

struct MovieDetailView: View {
    var onBack: () -> Void
    var movie: Movie
    
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
                    // Responsive AsyncImage
                    AsyncImage(url: URL(string: movie.posterPath)) { image in
                        image.resizable()
                    } placeholder: {
                        ProgressView()
                    }
                    .aspectRatio(contentMode: .fit)
                    .frame(width: geometry.size.width * 0.5, height: geometry.size.height * 0.8)
                    .frame(maxWidth: .infinity) // Centers the image
                    
                    Text(movie.title)
                        .font(.title)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.leading)
                    
                    HStack {
                        Text("Release Date: " + movie.releaseDate)
                            .multilineTextAlignment(.leading)
                        Spacer()
                        Text("Rating: ★★★☆☆")
                            .multilineTextAlignment(.trailing)
                    }
                    .font(.subheadline)
                    
                    Text(movie.overview)
                        .font(.body)
                        .multilineTextAlignment(.leading)
                    
                    HStack {
                        Spacer()
                        Button("Back to Content View") {
                            onBack()  // Call the closure when the button is tapped
                        }
                        .padding()
                        .background(Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                }
                .padding()
            }
        }
    }
    
}

struct MovieDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleMovie = Movie(
            title: "Sample Movie",
            overview: "This is a sample movie for preview purposes.",
            releaseDate: "2023-01-01",
            voteAverage: 8.5,
            posterPath: "https://www.themoviedb.org/t/p/original/78lPtwv72eTNqFW9COBYI0dWDJa.jpg"
        )
        MovieDetailView(onBack: {}, movie: sampleMovie)
    }
}
