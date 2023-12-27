import Foundation
import Alamofire


class WhisperManager {
    static let shared = WhisperManager()
    private let apiKey = ProcessInfo.processInfo.environment["WHISPER_API_KEY"] ?? "defaultHost"
    
    func transcribeAudio(fileURL: URL, completion: @escaping (Result<String, Error>) -> Void) {
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(apiKey)"
        ]
        
        let url = "https://api.openai.com/v1/audio/transcriptions"
        
        AF.upload(multipartFormData: { multipartFormData in
            multipartFormData.append(fileURL, withName: "file")
            multipartFormData.append("whisper-1".data(using: .utf8)!, withName: "model")
        }, to: url, headers: headers)
        .response { response in
            switch response.result {
            case .success(let responseData):
                if let data = responseData {
                    processResponseData(data) { result in
                        switch result {
                        case .success(let text):
                            completion(.success(text)) // Call the completion handler with the text
                        case .failure(let error):
                            print("Error: \(error)")
                            completion(.failure(error)) // Call the completion handler with the error
                        }
                    }
                } else {
                    print("No data received in response")
                    completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "No data in response"])))
                }
            case .failure(let error):
                print("Error during upload: \(error)")
                completion(.failure(error)) // Call the completion handler with the error
            }
        }
    }
}

struct TranscriptionResponse: Decodable {
    let transcription: String?
}

func processResponseData(_ data: Data, completion: @escaping (Result<String, Error>) -> Void) {
    if let responseString = String(data: data, encoding: .utf8) {
        do {
            // Locate the start of the JSON substring
            guard let jsonStartIndex = responseString.firstIndex(of: "{") else {
                throw NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "JSON string not found"])
            }
            let jsonPart = String(responseString[jsonStartIndex...])
            
            // Convert the JSON string to Data
            guard let jsonData = jsonPart.data(using: .utf8) else {
                throw NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid JSON string"])
            }
            
            // Parse the JSON data
            if let jsonResponse = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] {
                // Check if the key "text" exists and is a String
                if let textValue = jsonResponse["text"] as? String {
                    completion(.success(textValue))
                } else {
                    // If key "text" is not found, return the entire JSON string
                    completion(.success(jsonPart))
                }
            } else {
                throw NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Error parsing JSON"])
            }
        } catch {
            completion(.failure(error))
        }
    } else {
        completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Unable to create string from data"])))
    }
}

