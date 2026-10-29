import Foundation
import WidgetKit

extension VersesViewModel {
    func syncWidget() {
        guard let store = UserDefaults(suiteName: WidgetPreferences.group) else { return }
        let preferences = widgetPreferences
        guard WidgetPreferences.read(store: store) != preferences || store.data(forKey: WidgetPreferences.key) == nil,
              let data = try? JSONEncoder().encode(preferences) else { return }
        store.set(data, forKey: WidgetPreferences.key)
        WidgetCenter.shared.reloadTimelines(ofKind: WidgetPreferences.kind)
    }
}
