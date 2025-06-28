//
//  VerseModel.swift
//  Werset z Biblii
//
//  Created by Maciej Sołoducha on 28/06/2025.
//

import Foundation

struct VersesModel: Identifiable, Codable {
    var id = UUID()
    let text: String
    let reference: String

    
    private enum CodingKeys: String, CodingKey {
        case text, reference
    }

    init(text: String, reference: String) {
        self.text = text
        self.reference = reference
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.text = try container.decode(String.self, forKey: .text)
        self.reference = try container.decode(String.self, forKey: .reference)
        self.id = UUID() // <- This creates an ID independently of the file.
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(text, forKey: .text)
        try container.encode(reference, forKey: .reference)
    }
}
