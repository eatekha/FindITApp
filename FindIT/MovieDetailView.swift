import SwiftUI
import WebKit
import SafariServices


// WebView for YouTube videos
struct WebView: UIViewRepresentable {
    var videoID: String

    func makeUIView(context: Context) -> WKWebView {
        WKWebView()
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        guard let youtubeURL = URL(string: "https://www.youtube.com/embed/\(videoID)") else { return }
        uiView.scrollView.isScrollEnabled = false
        uiView.load(URLRequest(url: youtubeURL))
    }
}

// MovieDetailView with YouTube views
struct MovieDetailView: View {
    var onBack: () -> Void
    var movie: Movie
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
                    // Image and movie details
                    AsyncImage(url: URL(string: movie.posterPath)) { image in
                        image.resizable()
                    } placeholder: {
                        ProgressView()
                    }
                    .aspectRatio(contentMode: .fit)
                    .frame(width: geometry.size.width * 0.5, height: geometry.size.height * 0.8)
                    .frame(maxWidth: .infinity)

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

                    // YouTube video view
                    WebView(videoID: movie.trailer)
                        .frame(height: 500)
                        .frame(maxWidth: .infinity)
                        .cornerRadius(12)
                        .padding()

                    // Back button
                    HStack {
                        Button("Skip to " + movie.dialogue_start) {
                            openExternalURL()
                        }
                        .padding()
                        .background(Color.yellow)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        Spacer() // Another spacer after the button to ensure it stays centered
                    }
                    
                    // Back button
                    HStack {
                        Spacer()
                        Button("Back to Content View") {
                            print("Button tapped")

                            onBack()
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
    private func openExternalURL() {
        guard let url = URL(string: movie.movieLink) else {
                print("Invalid URL")
                return
            }
            DispatchQueue.main.async {
                UIApplication.shared.open(url)
            }
        }
}





// Preview of MovieDetailView
struct MovieDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleMovie = Movie(
            title: "Sample Movie",
            overview: "This is a sample movie for preview purposes.",
            releaseDate: "2023-01-01",
            posterPath: "https://www.themoviedb.org/t/p/original/78lPtwv72eTNqFW9COBYI0dWDJa.jpg",
            trailer: "eOrNdBpGMv8",
            movieLink: "https://google.com",
            dialogue_start: "00:56:46"
        )

        

        MovieDetailView(onBack: {}, movie: sampleMovie)
    }
}
