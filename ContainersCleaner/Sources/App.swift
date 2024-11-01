import SwiftUI

@main
struct App: SwiftUI.App {
    @State private var viewModel = CleanerViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(viewModel)
        }
        .commands {
            CommandGroup(replacing: .newItem) {
                Button("Find") {
                    viewModel.searchPresented = true
                }
                .keyboardShortcut("f")

                Divider()

                Button("Move to Trash") {
                    _ = try? viewModel.selectedFolders.map(viewModel.moveToTrash(_:))
                }
                .keyboardShortcut(.delete)
                .disabled(viewModel.selectedFolders.isEmpty)
            }
        }
    }
}
