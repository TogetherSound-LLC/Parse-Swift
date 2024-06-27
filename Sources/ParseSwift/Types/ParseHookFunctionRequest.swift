//
//  ParseHookRequest.swift
//  ParseSwift
//
//  Created by Corey Baker on 6/14/22.
//  Copyright © 2022 Network Reconnaissance Lab. All rights reserved.
//

import Foundation

/**
 A type that can decode requests when `ParseHookFunctionable` functions are called.
 - requires: `.usePrimaryKey` has to be available. It is recommended to only
 use the primary key in server-side applications where the key is kept secure and not
 exposed to the public.
 */
public struct ParseHookFunctionRequest<U: ParseCloudUser, P: ParseHookParametable & Sendable>: ParseHookRequestable {
    public typealias UsertType = U
    public var primaryKey: Bool?
    public var user: U?
    public var installationId: String?
    public var ipAddress: String?
    public var headers: [String: String]?
    /// The name of Parse Hook Function.
    public var functionName: String?
    /**
     The `ParseHookParametable` object containing the parameters passed
     to the function.
     */
    public var parameters: P
    var log: AnyCodable?
    var context: AnyCodable?

    enum CodingKeys: String, CodingKey {
        case primaryKey = "master"
        case parameters = "params"
        case ipAddress = "ip"
        case user, installationId, functionName,
             headers, log, context
    }
}

extension ParseHookFunctionRequest {

    /**
     Get the log using any type that conforms to `Codable`.
     - returns: The sound casted to the inferred type.
     - throws: An error of type `ParseError`.
     */
    public func getLog<V>() throws -> V where V: Codable {
        guard let log = log?.value as? V else {
            throw ParseError(code: .otherCause,
                             message: "Cannot be casted to the inferred type")
        }
        return log
    }

    /**
     Get the context using any type that conforms to `Codable`.
     - returns: The sound casted to the inferred type.
     - throws: An error of type `ParseError`.
     */
    public func getContext<V>() throws -> V where V: Codable {
        guard let context = context?.value as? V else {
            throw ParseError(code: .otherCause,
                             message: "Cannot be casted to the inferred type")
        }
        return context
    }

}
