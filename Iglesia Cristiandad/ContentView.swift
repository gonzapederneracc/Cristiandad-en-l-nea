import SwiftUI
import AVKit

// 📌 Modelo de video
struct Video: Identifiable, Codable {
    let id: UUID = UUID() // Se genera automáticamente
    let title: String
    let thumbnail: String
    let streamURL: String

    private enum CodingKeys: String, CodingKey {
        case title, thumbnail, streamURL
    }
}

// 📌 Modelo del JSON completo
struct StreamData: Codable {
    let backgroundImage: String
    let banners: [String] // Nueva propiedad para los banners promocionales
    let videos: [Video]
}

// 📌 Hacemos que una URL sea identificable
struct IdentifiableURL: Identifiable {
    let id = UUID()
    let url: URL
}

struct ContentView: View {
    @State private var streamData: StreamData?
    @State private var selectedVideo: IdentifiableURL?
    @State private var currentBannerIndex = 0
    @State private var timer: Timer?

    let bannerAutoScrollInterval: TimeInterval = 5.0 // Intervalo para el deslizamiento automático

    var body: some View {
        ZStack {
            // 📌 Imagen de fondo con degradado
            if let data = streamData {
                AsyncImage(url: URL(string: data.backgroundImage)) { image in
                    image.resizable().scaledToFill()
                } placeholder: {
                    Color.black
                }
                .edgesIgnoringSafeArea(.all)
                .overlay(
                    LinearGradient(gradient: Gradient(colors: [Color.black.opacity(0.5), Color.clear]),
                                   startPoint: .bottom,
                                   endPoint: .top)
                )

                VStack {
                    // 📌 Carrusel de banners promocionales
                    if let banners = streamData?.banners {
                        TabView(selection: $currentBannerIndex) {
                            ForEach(banners.indices, id: \.self) { index in
                                AsyncImage(url: URL(string: banners[index])) { image in
                                    image.resizable().scaledToFill()
                                } placeholder: {
                                    Color.gray
                                }
                                .frame(height: 300)
                                .cornerRadius(15)
                                .padding(.horizontal)
                                .tag(index) // Marcamos el índice para permitir la navegación
                            }
                        }
                        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
                        .frame(height: 300)
                        .onAppear {
                            startAutoScroll()
                        }
                        .onDisappear {
                            stopAutoScroll()
                        }
                    }

                    // 📌 Grid con los videos
                    ScrollView {
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 300))], spacing: 20) {
                            ForEach(data.videos) { video in
                                Button(action: {
                                    if let encodedURL = video.streamURL.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
                                       let url = URL(string: encodedURL) {
                                        selectedVideo = IdentifiableURL(url: url)
                                    }
                                }) {
                                    ZStack(alignment: .bottomLeading) {
                                        AsyncImage(url: URL(string: video.thumbnail)) { image in
                                            image.resizable().scaledToFill()
                                        } placeholder: {
                                            Color.gray
                                        }
                                        .frame(width: 350, height: 200)
                                        .cornerRadius(10)

                                        // Fondo oscuro detrás del título
                                        Rectangle()
                                            .fill(Color.black.opacity(0.6))
                                            .frame(height: 50)
                                            .overlay(
                                                Text(video.title)
                                                    .foregroundColor(.white)
                                                    .font(.headline)
                                                    .padding(.leading, 10),
                                                alignment: .leading
                                            )
                                    }
                                }
                            }
                        }
                        .padding()
                    }
                }
            } else {
                ProgressView("Cargando contenido...")
            }
        }
        .onAppear {
            loadStreamData()
        }
        .fullScreenCover(item: $selectedVideo) { video in
            VideoPlayerView(url: video.url)
                .edgesIgnoringSafeArea(.all) // Asegura pantalla completa
        }
    }

    // 📌 Cargar JSON de Cloudflare Pages
    func loadStreamData() {
        guard let url = URL(string: "https://tvappdata.cristiandad.com.ar/tvos-dynamic-data.json") else { return }

        URLSession.shared.dataTask(with: url) { data, _, error in
            if let data = data {
                if let decodedData = try? JSONDecoder().decode(StreamData.self, from: data) {
                    DispatchQueue.main.async {
                        self.streamData = decodedData
                    }
                }
            }
        }.resume()
    }

    // 📌 Iniciar el deslizamiento automático de banners
    func startAutoScroll() {
        timer = Timer.scheduledTimer(withTimeInterval: bannerAutoScrollInterval, repeats: true) { _ in
            if let banners = streamData?.banners, !banners.isEmpty {
                currentBannerIndex = (currentBannerIndex + 1) % banners.count
            }
        }
    }

    // 📌 Detener el deslizamiento automático de banners
    func stopAutoScroll() {
        timer?.invalidate()
        timer = nil
    }
}
