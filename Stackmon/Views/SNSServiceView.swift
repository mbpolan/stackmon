//
//  SNSServiceView.swift
//  Stackmon
//
//  Created by Mike Polan on 1/9/22.
//

import SotoSNS
import SwiftUI

// MARK: - View

struct SNSServiceView: View {
    @EnvironmentObject private var appState: AppState
    @ObservedObject private var viewModel: SNSServiceViewModel = SNSServiceViewModel()
    let view: AWSService
    
    var body: some View {
        Group {
            switch view {
            case .sns(let component):
                switch component {
                case .topics:
                    SNSTopicsView()
                case .subscriptions:
                    SNSSubscriptionsView()
                default:
                    Text("Select a component to view")
                        .foregroundColor(Color.secondary)
                        .centered(.all)
                }
            default:
                EmptyView()
            }
        }
        .navigationTitle("Simple Notification Service (SNS)")
        .sheet(isPresented: $viewModel.sheetShown, onDismiss: handleCloseSheet) {
            switch viewModel.sheet {
            case .error(let error):
                ErrorSheetView(error: error, onDismiss: handleCloseSheet)
            default:
                Text("An unknown error has occured")
            }
        }
    }
    
    private func handleCloseSheet() {
        viewModel.sheet = .none
    }
}

// MARK: - View Model

fileprivate class SNSServiceViewModel: ObservableObject {
    @Published var sheet: Sheet = .none {
        didSet {
            switch sheet {
            case .none:
                sheetShown = false
            default:
                sheetShown = true
            }
        }
    }
    @Published var sheetShown: Bool = false
    
    enum Sheet {
        case none
        case error(_ error: Error)
    }
}

// MARK: - Preview

struct SNSServiceView_Preview: PreviewProvider {
    static var previews: some View {
        SNSServiceView(view: .sns(component: .subscriptions))
    }
}
