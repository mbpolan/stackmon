//
//  NumericField.swift
//  Stackmon
//
//  Created by Mike Polan on 1/17/22.
//

import Combine
import SwiftUI

// MARK: - View

struct NumericField: View {
    @StateObject private var viewModel: NumericFieldViewModel
    private let value: Binding<Int>
    
    init(value: Binding<Int>) {
        self.value = value
        
        let model = NumericFieldViewModel()
        model.text = String(value.wrappedValue)
        
        _viewModel = StateObject(wrappedValue: model)
    }
    
    var body: some View {
        TextField("", text: $viewModel.text)
            .onReceive(Just(viewModel.text)) { text in
                let numeric = text.filter { "0123456789".contains($0) }
                if numeric != text {
                    viewModel.text = numeric
                }
            }
            .onChange(of: viewModel.text, perform: handleUpdateValue)
    }
    
    private func handleUpdateValue(_ newValue: String) {
        guard let i = Int(newValue) else { return }
        value.wrappedValue = i
    }
}

// MARK: - View Model

fileprivate class NumericFieldViewModel: ObservableObject {
    @Published var text: String = ""
}

// MARK: - Preview

struct NumericField_Preview: PreviewProvider {
    @State static var value: Int = 0
    
    static var previews: some View {
        NumericField(value: $value)
    }
}
