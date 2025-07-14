//
//  VerseModel.swift
//  Werset z Biblii
//
//  Created by Maciej Sołoducha on 28/06/2025.
//

import Foundation

struct VersesModel: Identifiable, Codable {
    var id = UUID()
    let date: String
    let message: String
    let verse: String
    let reference: String

    
    private enum CodingKeys: String, CodingKey {
        case date, message, verse, reference
    }

    init(date: String, message: String, verse: String, reference: String) {
        self.date = date
        self.message = message
        self.verse = verse
        self.reference = reference
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.date = try container.decode(String.self, forKey: .date)
        self.message = try container.decode(String.self, forKey: .message)
        self.verse = try container.decode(String.self, forKey: .verse)
        self.reference = try container.decode(String.self, forKey: .reference)
        self.id = UUID() // <- This creates an ID independently of the file.
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(date, forKey: .date)
        try container.encode(message, forKey: .message)
        try container.encode(verse, forKey: .verse)
        try container.encode(reference, forKey: .reference)
    }
}
