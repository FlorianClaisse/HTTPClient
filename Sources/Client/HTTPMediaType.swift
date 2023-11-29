//
//  HTTPMediaType.swift
//
//
//  Created by Florian Claisse on 12/11/2023.
//

import Foundation

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

/// A structure that contains all types of data usable in the body of an HTTP request.
public struct HTTPMediaType: Codable, Hashable, RawRepresentable, ExpressibleByStringLiteral, LosslessStringConvertible {
    public typealias RawValue = String
    public typealias StringLiteralType = String
    
    public static let any = HTTPMediaType("*", "*")
    
    public var type: String
    public var subtype: String
    public var parameters: [String: String]
    
    public var rawValue: String {
        get { (["\(type)/\(subtype)"] + parameters.map { "\($0.key)=\($0.value)" }.sorted()).joined(separator: ";") }
        set { self = HTTPMediaType(rawValue: newValue) }
    }
    
    public var description: String { rawValue }
    
    public init(_ type: String, _ subtype: String, parameters: [String : String] = [:]) {
        self.type = type
        self.subtype = subtype
        self.parameters = parameters
    }
    
    public init(rawValue: String) {
        var type = ""
        var index = rawValue.startIndex
        
        while index < rawValue.endIndex, rawValue[index] != "/" {
            type.append(rawValue[index])
            index = rawValue.index(after: index)
        }
        
        if index < rawValue.endIndex {
            index = rawValue.index(after: index)
        }
        
        var subtype = ""
        while index < rawValue.endIndex, rawValue[index] != ";" {
            subtype.append(rawValue[index])
            index = rawValue.index(after: index)
        }
        
        var parameters: [String: String] = [:]
        while index < rawValue.endIndex {
            index = rawValue.index(after: index)
            guard index < rawValue.endIndex else { break }
            
            var key = ""
            while index < rawValue.endIndex, rawValue[index] != ";" {
                key.append(rawValue[index])
                index = rawValue.index(after: index)
            }
            
            var value = ""
            while index < rawValue.endIndex, rawValue[index] != ";" {
                value.append(rawValue[index])
                index = rawValue.index(after: index)
            }
            
            parameters[key] = value.trimmingCharacters(in: [" ", "\""])
        }
        
        self.init(type.isEmpty ? "*" : type, subtype.isEmpty ? "*" : subtype, parameters: parameters)
    }
    
    public init(stringLiteral value: String) {
        self.init(rawValue: value)
    }
    
    public init(_ description: String) {
        self.init(rawValue: description)
    }
    
    public init(from decoder: Decoder) throws {
        try self.init(rawValue: String(from: decoder))
    }
    
    public func encode(to encoder: Encoder) throws {
        try rawValue.encode(to: encoder)
    }
    
    public static func application(_ subtype: Application) -> HTTPMediaType {
        HTTPMediaType("application", subtype.rawValue)
    }
    
    public static func text(_ subtype: Text, charset: String? = nil) -> HTTPMediaType {
        HTTPMediaType("text", subtype.rawValue, parameters: charset.map { ["charset": $0] } ?? [:])
    }
    
    public static func multipart(_ subtype: MultiPart) -> HTTPMediaType {
        HTTPMediaType("multipart", subtype.rawValue)
    }
}

// MARK: - Application Type

extension HTTPMediaType {
    public struct Application: RawRepresentable, ExpressibleByStringLiteral {
        public var rawValue: String
        
        public init(rawValue: String) {
            self.rawValue = rawValue
        }
        
        public init(stringLiteral value: String) {
            self.init(rawValue: value)
        }
        
        public static let json: Application = "json"
        public static let schemaJson: Application = "schema+json"
        public static let schemaInstanceJson: Application = "schema-instance+json"
        public static let xml: Application = "xml"
        public static let octetStream: Application = "octet-stream"
        public static let urlEncoded: Application = "x-www-form-urlencoded"
    }
}

// MARK: - Text type

extension HTTPMediaType {
    public struct Text: RawRepresentable, ExpressibleByStringLiteral {
        public var rawValue: String
        
        public init(rawValue: String) {
            self.rawValue = rawValue
        }
        
        public init(stringLiteral value: String) {
            self.init(rawValue: value)
        }
        
        public static let plain: Text = "plain"
        public static let html: Text = "html"
    }
}

// MARK: - Multi Part Type

extension HTTPMediaType {
    public struct MultiPart: RawRepresentable, ExpressibleByStringLiteral {
        public var rawValue: String
        
        public init(rawValue: String) {
            self.rawValue = rawValue
        }
        
        public init(stringLiteral value: String) {
            self.init(rawValue: value)
        }
        
        public static let formData: MultiPart = "form-data"
        public static let byteranges: MultiPart = "byteranges"
    }
}
