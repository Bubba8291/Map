//
//  ViewMapAnnotation.swift
//  Map
//
//  Created by Paul Kraft on 23.04.22.
//

#if !os(watchOS)

import MapKit
import SwiftUI

public final class ViewMapAnnotation<Content: View>: MapAnnotation {

    // MARK: Nested Types

    private class Annotation: NSObject, MKAnnotation {

        // MARK: Stored Properties

        let coordinate: CLLocationCoordinate2D
        let title: String?
        let subtitle: String?

        // MARK: Initialization

        init(coordinate: CLLocationCoordinate2D, title: String?, subtitle: String?) {
            self.coordinate = coordinate
            self.title = title
            self.subtitle = subtitle
        }

    }

    // MARK: Static Functions

    public static func registerView(on mapView: MKMapView) {
        mapView.register(MKMapAnnotationView<Content>.self, forAnnotationViewWithReuseIdentifier: reuseIdentifier)
    }

    // MARK: Stored Properties

    public let annotation: MKAnnotation
    let clusteringIdentifier: String?
    private (set) var content: Content
    // The associated view last returned when requested via `view(for:)`
    // Must be a weak reference because the view will also have a reference to
    // this instance
    private weak var associatedView: MKMapAnnotationView<Content>?
    let anchorPoint: CGPoint

    // MARK: Initialization

    public init(
        coordinate: CLLocationCoordinate2D,
        anchorPoint: CGPoint = CGPoint(x: 0.5, y: 0.5),
        title: String? = nil,
        subtitle: String? = nil,
        clusteringIdentifier: String? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.annotation = Annotation(coordinate: coordinate, title: title, subtitle: subtitle)
        self.anchorPoint = anchorPoint
        self.clusteringIdentifier = clusteringIdentifier
        self.content = content()
    }

    public init(
        annotation: MKAnnotation,
        anchorPoint: CGPoint = CGPoint(x: 0.5, y: 0.5),
        clusteringIdentifier: String? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.annotation = annotation
        self.anchorPoint = anchorPoint
        self.clusteringIdentifier = clusteringIdentifier
        self.content = content()
    }

    // MARK: Methods

    public func view(for mapView: MKMapView) -> MKAnnotationView? {
        let view = mapView.dequeueReusableAnnotationView(
            withIdentifier: Self.reuseIdentifier,
            for: annotation
        ) as? MKMapAnnotationView<Content>

        view?.setup(for: self)
        associatedView = view
        return view
    }

    public func updateView(with associatedAnnotation: Any) {
        guard let updatedAnnotation = associatedAnnotation as? ViewMapAnnotation<Content> else { return }
        guard let associatedView else { return }

        content = updatedAnnotation.content
        associatedView.update(for: self)
    }
}

#endif
