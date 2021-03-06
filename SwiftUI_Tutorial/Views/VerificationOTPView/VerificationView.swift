//
//  VerificationView.swift
//  SwiftUI_Tutorial
//
//  Created by Hau Nguyen on 23/12/2021.
//

import SwiftUI

struct VerificationView: View {
    @State var code : [String] = []
    
    var body : some View{
        
        VStack{
            
            Spacer()
            
            Text("Enter Verification Code").font(.title)
            
            HStack(spacing: 20){
                
                ForEach(code,id: \.self){i in
                    
                    Text(i).font(.title).fontWeight(.semibold)
                }
                
            }.padding(.vertical)
            
            Spacer()
            
            CustomNumberPad(codes: $code)
            
        }
        .preferredColorScheme(.dark)
        .animation(.spring())
    }
}

struct type : Identifiable {
    
    var id : Int
    var row : [row]
}

struct row : Identifiable {
    
    var id : Int
    var value : String
}


var datas = [
    
    type(id: 0, row: [row(id: 0, value: " 1"),row(id: 1, value: "2"),row(id: 2, value: "3")]),
    type(id: 1, row: [row(id: 0, value: "4"),row(id: 1, value: "5"),row(id: 2, value: "6")]),
    type(id: 2, row: [row(id: 0, value: "7"),row(id: 1, value: "8"),row(id: 2, value: "9")]),
    type(id: 3, row: [row(id: 0, value: "delete.left.fill"),row(id: 1, value: "0")])
]

struct SectionedTextField: View {
    @State private var numberOfCells: Int = 8
    @State private var currentlySelectedCell = 0

    var body: some View {
        HStack {
            ForEach(0 ..< self.numberOfCells) { index in
                CharacterInputCell(currentlySelectedCell: self.$currentlySelectedCell, index: index)
            }
        }
    }
}


struct CharacterInputCell: View {
    @State private var textValue: String = ""
    @Binding var currentlySelectedCell: Int

    var index: Int

    var responder: Bool {
        return index == currentlySelectedCell
    }

    var body: some View {
        CustomTextField(text: $textValue, currentlySelectedCell: $currentlySelectedCell, isFirstResponder: responder)
            .frame(height: 20)
            .frame(maxWidth: .infinity, alignment: .center)
            .padding([.trailing, .leading], 10)
            .padding([.vertical], 15)
            .lineLimit(1)
            .multilineTextAlignment(.center)
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(Color.red.opacity(0.5), lineWidth: 2)
            )
    }
}

struct CustomTextField: UIViewRepresentable {

    class Coordinator: NSObject, UITextFieldDelegate {

        @Binding var text: String
        @Binding var currentlySelectedCell: Int

        var didBecomeFirstResponder = false

        init(text: Binding<String>, currentlySelectedCell: Binding<Int>) {
            _text = text
            _currentlySelectedCell = currentlySelectedCell
        }

        func textFieldDidChangeSelection(_ textField: UITextField) {
            DispatchQueue.main.async {
                self.text = textField.text ?? ""
            }
        }

        func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
            let currentText = textField.text ?? ""

            guard let stringRange = Range(range, in: currentText) else { return false }

            let updatedText = currentText.replacingCharacters(in: stringRange, with: string)

            if updatedText.count <= 1 {
                self.currentlySelectedCell += 1
            }

            return updatedText.count <= 1
        }
    }

    @Binding var text: String
    @Binding var currentlySelectedCell: Int
    var isFirstResponder: Bool = false

    func makeUIView(context: UIViewRepresentableContext<CustomTextField>) -> UITextField {
        let textField = UITextField(frame: .zero)
        textField.delegate = context.coordinator
        textField.textAlignment = .center
        textField.keyboardType = .decimalPad
        return textField
    }

    func makeCoordinator() -> CustomTextField.Coordinator {
        return Coordinator(text: $text, currentlySelectedCell: $currentlySelectedCell)
    }

    func updateUIView(_ uiView: UITextField, context: UIViewRepresentableContext<CustomTextField>) {
        uiView.text = text
        if isFirstResponder && !context.coordinator.didBecomeFirstResponder  {
            uiView.becomeFirstResponder()
            context.coordinator.didBecomeFirstResponder = true
        }
    }
}


//struct VerificationView_Previews: PreviewProvider {
//    static var previews: some View {
//        VerificationView()
//    }
//}


struct SectionedTextField_Previews: PreviewProvider {
    static var previews: some View {
        SectionedTextField()
    }
}
