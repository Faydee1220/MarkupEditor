//
//  LinkToolbar.swift
//  MarkupEditor
//
//  Created by Steven Harris on 4/7/21.
//

import SwiftUI

struct LinkToolbar: View {
    @Binding var showToolbar: Bool
    @Binding private var selectedWebView: MarkupWKWebView?
    @ObservedObject private var selectionState: SelectionState
    private var markupUIDelegate: MarkupUIDelegate?
    private var initialHref: String?
    // The href is the state for the toolbar
    @State private var href: String
    // The previewed value holds on to what has been previewed, to
    // avoid doing the insert/modify unnecessarily
    @State private var previewedHref: String
    // The "arg" equivalent is to pass to insertLink
    private var argHRef: String? { href.isEmpty ? nil : href }
    
    var body: some View {
        HStack(alignment: .bottom) {
            ToolbarTextField(
                label: "Link URL",
                placeholder: "Enter URL",
                text: $href,
                commitHandler: { save() },
                validationHandler: { href.isValidURL })
            Divider()
            HStack(alignment: .bottom) {
                ToolbarTextButton(title: "Save", action: { self.save() }, width: 80)
                ToolbarTextButton(title: "Cancel", action: { self.cancel() }, width: 80)
            }
        }
        .onChange(of: selectionState.href, perform: { value in
            href = selectionState.href ?? ""
            previewedHref = href
        })
        .padding([.leading, .trailing], 8)
        .padding([.top], 2)
        .fixedSize(horizontal: false, vertical: true)
        .frame(idealHeight: 54, maxHeight: 54)
        Divider()
    }
    
    public init(selectionState: SelectionState, selectedWebView: Binding<MarkupWKWebView?>, markupUIDelegate: MarkupUIDelegate? = nil, showToolbar: Binding<Bool>) {
        self.selectionState = selectionState
        _selectedWebView = selectedWebView
        self.markupUIDelegate = markupUIDelegate
        _showToolbar = showToolbar
        initialHref = selectionState.href
        _previewedHref = State(initialValue: selectionState.href ?? "")
        _href = State(initialValue: selectionState.href ?? "")
    }
    
    private func previewed() -> Bool {
        // Return whether what we are seeing on the screen is the same as is in the toolbar
        return href == previewedHref
    }
    
    private func insertOrModify(handler: (()->Void)? = nil) {
        guard !previewed() else {
            handler?()
            return
        }
        if previewedHref.isEmpty && !href.isEmpty {
            selectedWebView?.insertLink(argHRef) {
                previewedHref = href
                handler?()
            }
        } else {
            selectedWebView?.insertLink(argHRef) {
                previewedHref = href
                handler?()
            }
        }
        
    }
    
    private func save() {
        // Save href it is hasn't been previewed, and then close
        insertOrModify() {
            // TODO: The animation causes problems in UIKit. Need to figure it out
            showToolbar.toggle()
            //withAnimation { showImageToolbar.toggle() }
        }
    }
    
    private func cancel() {
        // Restore href to its initial value, put things back the way they were, and then close
        href = initialHref ?? ""
        insertOrModify() {
            // TODO: The animation causes problems in UIKit. Need to figure it out
            showToolbar.toggle()
            //withAnimation { showImageToolbar.toggle() }
        }
    }
    
}

struct LinkToolbar_Previews: PreviewProvider {
    static var previews: some View {
        LinkToolbar(selectionState: SelectionState(), selectedWebView: .constant(nil), showToolbar: .constant(true))
    }
}
