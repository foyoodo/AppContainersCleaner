import SwiftUI

public struct ContentView: View {
    @Environment(CleanerViewModel.self) var viewModel

    @State private var searchText: String = ""

    public var body: some View {
        @Bindable var viewModel = viewModel

        List(viewModel.folders, id: \.self, selection: $viewModel.selectedFolders) { folder in
            HStack {
                Image(nsImage: folder.icon)

                VStack(alignment: .leading) {
                    Text(folder.name)

                    Text(folder.metadata.identifier)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            .contextMenu {
                Button("Show in Finder") {
                    viewModel.showInFinder(folder)
                }

                Divider()

                Button("Move to Trash") {
                    try? viewModel.moveToTrash(folder)
                }
            }
        }
        .searchable(text: $searchText, isPresented: $viewModel.searchPresented)
        .onChange(of: searchText) {
            viewModel.search(searchText)
        }
        .onAppear {
            try? viewModel.scan()
        }
    }
}
