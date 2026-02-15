//
//  DeepLinkRouter.swift
//  Returnal
//
//  Created by Andre Veltens on 01.12.25.
//

import Foundation
internal import Combine

class DeepLinkRouter: ObservableObject {
    @Published var targetUUID: UUID? = nil
}
