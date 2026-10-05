import SwiftUI
import MacCleanKit

struct SimilarImagesView: View {
    @Environment(AppState.self) private var appState
    @State private var isScanning = false

    var body: some View {
        VStack(spacing: 8) {
            Spacer()
            Image(systemName: "photo.on.rectangle.angled")
                .font(.system(size: 32))
                .foregroundStyle(.tertiary)
            Text(L10n.tr("相似图片查找器正在开发中...", "Similar Images finder is under development...", "Поиск похожих изображений в разработке..."))
                .font(.system(size: 13))
                .foregroundStyle(.secondary)
            Text(L10n.tr("此功能将使用 Vision 框架来扫描相册中视觉上相似的图片。", "This feature will use the Vision framework to scan for visually similar photos.", "Эта функция будет использовать фреймворк Vision для поиска визуально похожих фотографий."))
                .font(.system(size: 11))
                .foregroundStyle(.secondary.opacity(0.8))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
}
