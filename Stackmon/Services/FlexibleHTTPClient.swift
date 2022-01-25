//
//  FlexibleHTTPClient.swift
//  Stackmon
//
//  Created by Mike Polan on 1/23/22.
//

import AsyncHTTPClient
import Foundation
import SotoCore

struct FlexibleHTTPClient: AWSHTTPClient {
    static let shared = FlexibleHTTPClient()
    private let client: HTTPClient
    
    init() {
        self.client = HTTPClient(eventLoopGroupProvider: .createNew,
                                configuration: .init(certificateVerification: .none))
    }
    
    func execute(request: AWSHTTPRequest, timeout: TimeAmount, on eventLoop: EventLoop, logger: Logger) -> EventLoopFuture<AWSHTTPResponse> {
        return client.execute(request: request, timeout: timeout, on: eventLoop, logger: logger)
    }
    
    func shutdown(queue: DispatchQueue, _ callback: @escaping (Error?) -> Void) {
        client.shutdown(queue: queue, callback)
    }
    
    var eventLoopGroup: EventLoopGroup {
        client.eventLoopGroup
    }
}
