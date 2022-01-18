//
//  ErrorSheetView.swift
//  Stackmon
//
//  Created by Mike Polan on 1/18/22.
//

import SwiftUI
import SotoCore

// MARK: - View

struct ErrorSheetView: View {
    let error: Error
    let onDismiss: () -> Void
    
    var body: some View {
        VStack {
            Text(title)
                .bold()
            
            Text(description)
                .padding()
            
            Button("OK", action: onDismiss)
        }
        .padding()
        .frame(width: 400)
    }
    
    var title: String {
        if error is AWSErrorType {
            return "AWS Service Error"
        } else {
            return "Unknown Error"
        }
    }
    
    var description: String {
        if let awsError = error as? AWSErrorType {
            let message = awsError.message ?? "No message"
            return "\(awsError.errorCode): \(message)"
        } else {
            return error.localizedDescription
        }
    }
}

// MARK: - Preview

struct ErrorSheetView_Preview: PreviewProvider {
    enum MockError: Error {
        case whatever
    }
    
    static var previews: some View {
        ErrorSheetView(error: MockError.whatever,
                       onDismiss: { })
            .previewDisplayName("AWS Error")
    }
}
