import NoticeObserveKit
import PlaygroundSupport

PlaygroundPage.current.needsIndefiniteExecution = true

extension Notice.Names {
    static let sample = Notice.Name<String>(name: "sample-notification")
}

NotificationCenter.default.nok.observe(name: .sample) { value in
    print(value)
    PlaygroundPage.current.finishExecution()
}

NotificationCenter.default.nok.post(name: .sample, with: "This is sample notification!")


