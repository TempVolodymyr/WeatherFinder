import UIKit
import CoreLocation

class WeatherScreenViewController: UIViewController {

    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!

    // TODO: resolve variable searchController initialization issue
    private var searchController: UISearchController?
    private let gradientLayer = Colors.gradientLayer
    private let geolocation = Geolocation()
    private var cityWeatherData: WeatherDataModel? = nil {
        willSet {
            if newValue == nil {
                tableView.reloadData()
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupSearchController()
        refresh()
        setupTableView()
        setupGeolocation()
        NotificationCenter.default.addObserver(self, selector: #selector(setupGeolocation),
                                               name: UIScene.didActivateNotification, object: nil)
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        gradientLayer.frame = CGRect(origin: gradientLayer.frame.origin, size: size)
    }

    private func setupSearchController() {
        searchController = UISearchController(searchResultsController: nil)
        searchController?.obscuresBackgroundDuringPresentation = false
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        searchController?.searchBar.placeholder = "Search for city".localized
    }

    private func refresh() {
        view.backgroundColor = .clear
        gradientLayer.frame = view.frame
        view.layer.insertSublayer(gradientLayer, at: 0)
    }

    private func setupTableView() {
        let nib = UINib(nibName: "CityWeatherTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "weatherCell")
    }

    @objc private func setupGeolocation() {
        geolocation.delegate = self
        cityWeatherData = nil
        geolocation.checkAuthorizationStatus()
    }

    @IBAction private func updateLocation(_ sender: UIBarButtonItem) {
        setupGeolocation()
    }
}

// MARK: - Extension Geolocation Delegate
extension WeatherScreenViewController: GeolocationDelegate {

    func authorizationStatusSetup(state: CurrentAutorizationStatus) {
        cityWeatherData = nil
        switch state {
        case .geolocationAllowed:
            tableView.restoreTableView(separatorStyle: .none)
        case .geolocationDenied:
            tableView.setPlaceholder(kind: .geolocationDenied)
        case .geolocationOff:
            tableView.setPlaceholder(kind: .geolocationOff)
        }
    }

    func locationRecieved(coordinates: CLLocationCoordinate2D) {
        tableView.setPlaceholder(kind: .loadingData)
        NetworkManager.shared.getWeatherByCoordinates(coords: coordinates) {  [weak self] (result) in
            switch result {
            case .success(let model):
                    print(model)
                    self?.tableView.restoreTableView(separatorStyle: .none)
                    self?.cityWeatherData = model
                    self?.tableView.reloadData()
            case .failure(let error):
                print( error)
            }
        }
    }
}

// MARK: - Extension TableView Datasource
extension WeatherScreenViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard cityWeatherData != nil else { return 0 }
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "weatherCell", for: indexPath) as? CityWeatherTableViewCell else {
            return UITableViewCell.init()
        }

        if let weatherData = cityWeatherData {
            cell.updateWeatherData(model: weatherData)
        }
        return cell
    }
}
