//
//  CityWeatherTableViewCell.swift
//  WeatherFinder
//
//  Created by Victor Pelivan on 01.10.2020.
//  Copyright © 2020 Viktor Pelivan. All rights reserved.
//

import UIKit

final class CityWeatherTableViewCell: UITableViewCell {
    
    @IBOutlet private weak var cityLabel: UILabel!
    @IBOutlet private weak var temperatureLabel: UILabel!
    @IBOutlet private weak var feelsLikeLabel: UILabel!
    @IBOutlet private weak var weatherConditionLabel: UILabel!
    @IBOutlet private weak var weatherStatusImageView: UIImageView!
    @IBOutlet private weak var pressureLabel: UILabel!
    @IBOutlet private weak var humidityLabel: UILabel!
    @IBOutlet private weak var windSpeedLabel: UILabel!
    @IBOutlet private weak var maximumCurrentTemperatureLabel: UILabel!
    @IBOutlet private weak var minimumCurrentTemperatureLabel: UILabel!
    @IBOutlet private weak var imageActivityIndicator: UIActivityIndicatorView!
    
    override func awakeFromNib() {
        toggleActivityIndicator(visible: true)
    }
    
    func updateWeatherData(model: WeatherDataModel) {
        
        let currentTemperature = model.mainWeatherInfo?.temperature
        let feelsLikeTemperature = model.mainWeatherInfo?.feelsLike
        let pressure = model.mainWeatherInfo?.pressure
        let humidity = model.mainWeatherInfo?.humidity
        let windSpeed = model.windSpeed?.speed
        let maximumCurrentTemperature = model.mainWeatherInfo?.temperatureMaximum
        let minimumCurrentTemperature = model.mainWeatherInfo?.temperatureMinimum
        
        cityLabel.text = model.nameOfCity
        temperatureLabel.text = getInterpolatedStringLoalized("%.f˚C", currentTemperature)
        feelsLikeLabel.text = getInterpolatedStringLoalized("Feels Like: %.f˚C", feelsLikeTemperature)
        pressureLabel.text = getInterpolatedStringLoalized("Pressure: %d mm", pressure)
        humidityLabel.text = getInterpolatedStringLoalized("Humidity: %d %%", humidity)
        windSpeedLabel.text = getInterpolatedStringLoalized("Wind Speed: %.f m/s", windSpeed)
        maximumCurrentTemperatureLabel.text = getInterpolatedStringLoalized("Maximum Current Temperature: %.f˚C",
                                                                            maximumCurrentTemperature)
        minimumCurrentTemperatureLabel.text = getInterpolatedStringLoalized("Minimum Current Temperature: %.f˚C",
                                                                            minimumCurrentTemperature)
        if model.weatherCondition.isEmpty == false {
            let weatherCondition = model.weatherCondition[0]?.description
            let iconId = model.weatherCondition[0]?.icon
            
            weatherConditionLabel.text = weatherCondition?.capitalized ?? "No Value".localized
            updateWeatherImage(iconId: iconId)
        }
    }
    
    private func getInterpolatedStringLoalized<T>(_ format: String, _ interpolationValue: T?) -> String {
        if let interpolationValue = interpolationValue {
            return String(format: format.localized, interpolationValue as! CVarArg)
        }
        return "No value".localized
    }
    
    private func updateWeatherImage(iconId: String?) {
        guard let iconId = iconId else {
            weatherStatusImageView.image = UIImage(named: "NoImage")
            return
        }
        
        NetworkManager.shared.getWeatherImage(iconId: iconId) { (weatherImage) in
            guard let weatherImage = weatherImage else {
                self.weatherStatusImageView.image = UIImage(named: "NoImage")
                return
            }
            self.toggleActivityIndicator(visible: false)
            self.weatherStatusImageView.image = weatherImage
        }
    }
    
    private func toggleActivityIndicator(visible: Bool) {
        imageActivityIndicator.isHidden = visible
        imageActivityIndicator.isHidden ?
            imageActivityIndicator.stopAnimating() : imageActivityIndicator.startAnimating()
    }
}