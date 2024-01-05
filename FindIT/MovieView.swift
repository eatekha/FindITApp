import SwiftUI
import WebKit
import SafariServices


//Schema of MovieView
public struct Movie: Codable {
    let title: String
    let overview: String
    let releaseDate: String
    let posterPath: String
    let trailer: String
    let movieLink: String
    let dialogue_start: String
    let backdrop_path: String
    let genres: [String] // Add an array to hold genres
    let rating: Double

    
    enum CodingKeys: String, CodingKey {
        case title
        case overview
        case trailer
        case releaseDate = "release_date"
        case posterPath = "poster_path"
        case movieLink = "movie_link"
        case dialogue_start
        case backdrop_path
        case genres
        case rating
    }
}

struct MovieView: View {
    @ObservedObject var viewModel: MovieViewModel
    var onBack: () -> Void

    var body: some View {
        VStack(spacing: 0) {
                    // Top Navigation Bar
                    HStack {
                        Button(action: {
                            onBack()
                        }) {
                            Image(systemName: "arrow.left")
                                .foregroundColor(.white)
                                .padding()
                        }
                        
                        Spacer()
                        
                        Text(viewModel.movie.title)
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        Button(action: {
                            // Action for menu button
                        }) {
                            Image(systemName: "line.horizontal.3")
                                .foregroundColor(.white)
                                .padding()
                        }
                    }
                    .background(Color(red: 0.1, green: 0.1, blue: 0.15)) // Deep, dark blue color for the navigation bar
                    .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: 2)
            GeometryReader { geometry in
                ScrollView {
                    VStack(alignment: .leading, spacing: 10) {
                        
                        AsyncImage(url: URL(string: viewModel.movie.backdrop_path)) { image in
                            image.resizable()
                        } placeholder: {
                            ProgressView()
                        }
                        .aspectRatio(contentMode: .fill)
                        .frame(width: geometry.size.width, height: 254)
                        .clipped()
                        .overlay(
                            Button(action: {
                                viewModel.openExternalURL(link:
                                    "https://www.youtube.com/v/\(viewModel.movie.trailer)")
                            }) {
                                Image(systemName: "play.circle.fill")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 60, height: 60)
                                    .foregroundColor(.white)
                            }, alignment: .center
                        )
                        
                        
                        HStack(alignment: .top, spacing: 10) {
                            AsyncImage(url: URL(string: viewModel.movie.posterPath)) { image in
                                image.resizable()
                            } placeholder: {
                                ProgressView()
                            }
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 105, height: 200)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .padding(.trailing, 20)
                            
                            VStack(alignment: .leading, spacing: 5) {
                                Text(viewModel.movie.title)
                                    .font(.title)
                                    .fontWeight(.bold)
                                
                                Text("Release Date: " + viewModel.movie.releaseDate)
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                
                                HStack(spacing: 2) {
                                    ForEach(0..<5, id: \.self) { index in
                                        StarView(fillValue: viewModel.starFillValue(for: 2.3, at: index))
                                            .padding(.trailing, index == 4 ? 4 : 0) // Add padding to the last star
                                    }
                                    Text(String(format: "%.1f", viewModel.movie.rating)) // Display the rating value
                                         .font(.subheadline)
                                         .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                                         .foregroundColor(.gray)
                                }
                                .padding(.bottom, 55)


                                HStack {
                                    ForEach(viewModel.movie.genres.prefix(3), id: \.self) { genre in
                                        Button(action: {
                                            // Action to perform when button is tapped
                                        }) {
                                            Text(genre)
                                                .padding(.horizontal, 10) // Add horizontal padding
                                                .padding(.vertical, 5) // Add vertical padding
                                                .foregroundColor(.white)
                                                .background(Color(red: 0.2, green: 0.2, blue: 0.25)) // Slightly lighter shade for the buttons
                                                .cornerRadius(20)
                                        }
                                    }


                                    Spacer() // Spacer after the tag for centering
                                }
                            }
                            .layoutPriority(1)
                        }
                        
                        Text(viewModel.movie.overview)
                            .font(.body)
                            .multilineTextAlignment(.leading)
                            .padding(.bottom, 30)
                        
                        
                        // Centered Button with improved design
                        // HStack for centering the button
                        HStack {
                            Spacer() // Spacer before the button for centering
                            Button("Skip to " + viewModel.movie.dialogue_start) {
                                viewModel.openExternalURL(link: viewModel.movie.movieLink)
                            }
                            .padding(.vertical, 10)
                            .padding(.horizontal, 20)
                            .background(Color(red: 0.2, green: 0.2, blue: 0.25)) // Matching color for other buttons
                            .foregroundColor(.white)
                            .font(.headline) // Makes the font a bit larger and bolder
                            .cornerRadius(10)
                            .shadow(radius: 5) // Adds a subtle shadow for a 3D effect
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.white, lineWidth: 1) // Adds a border to make the button stand out
                            )
                            Spacer() // Spacer after the button for centering
                        }
                    }
                    Button("More  ↓"){
                        
                    } .font(
                            Font.custom("Montserrat", size: 16)
                                .weight(.bold)
                        )
                        .multilineTextAlignment(.center)
                        .foregroundColor(.white)
                    
                        .padding(.top, 60) // Adjust padding as needed
                        .edgesIgnoringSafeArea(.top)
                }
                

            }
            
        }
    }
}
// PreviewProvider for MovieView
struct MovieView_Previews: PreviewProvider {
    static var previews: some View {
        // Sample movie data for preview
        let sample = MovieViewModel.sampleMovie()

        // Initializing the ViewModel with the sample movie
        let viewModel = MovieViewModel(movie: sample)

        // Creating the MovieView with the ViewModel and a mock back action
        MovieView(viewModel: viewModel, onBack: {
            print("Back action triggered")
        })
    }
}

