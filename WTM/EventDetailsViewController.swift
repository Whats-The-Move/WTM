import UIKit

class EventDetailsViewController: UIViewController {
    var eventLoad: EventLoad

    init(eventLoad: EventLoad) {
        self.eventLoad = eventLoad
        super.init(nibName: nil, bundle: nil)
        // Additional setup if needed
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        print(eventLoad.creator)
        // Setup UI and use eventLoad as needed
    }
}
