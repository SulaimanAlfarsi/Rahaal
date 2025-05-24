import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class GoogleMapPrebuiltPackagePage extends StatefulWidget {
  final List<Map<String, double>> coordinates;

  const GoogleMapPrebuiltPackagePage({
    Key? key,
    required this.coordinates,
  }) : super(key: key);

  @override
  _GoogleMapPrebuiltPackagePageState createState() => _GoogleMapPrebuiltPackagePageState();
}

class _GoogleMapPrebuiltPackagePageState extends State<GoogleMapPrebuiltPackagePage> {
  late GoogleMapController _mapController;
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};
  LatLng? _currentLocation;
  String? _estimatedTotalTime;
  String? _totalDistance;

  @override
  void initState() {
    super.initState();
    _initializeLocationAndRoute();
    _addMarkers();
  }

  Future<void> _initializeLocationAndRoute() async {
    bool hasPermission = await _checkAndRequestPermission();
    if (!hasPermission) return;

    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

    setState(() {
      _currentLocation = LatLng(position.latitude, position.longitude);
      _addCurrentLocationMarker();
      _calculateRoute();
    });
  }

  Future<bool> _checkAndRequestPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return false;
    }

    if (permission == LocationPermission.deniedForever) return false;

    return true;
  }

  void _addCurrentLocationMarker() {
    if (_currentLocation != null) {
      _markers.add(
        Marker(
          markerId: const MarkerId('currentLocation'),
          position: _currentLocation!,
          infoWindow: const InfoWindow(title: 'Your Location'),
        ),
      );
    }
  }

  void _addMarkers() {
    for (var coord in widget.coordinates) {
      final marker = Marker(
        markerId: MarkerId('${coord['latitude']},${coord['longitude']}'),
        position: LatLng(coord['latitude']!, coord['longitude']!),
        infoWindow: InfoWindow(title: 'Attraction Site'),
      );
      _markers.add(marker);
    }
  }

  Future<void> _calculateRoute() async {
    if (_currentLocation == null) return;

    List<LatLng> polylineCoordinates = [];
    int totalTimeSeconds = 0;
    double totalDistanceMeters = 0;

    LatLng lastPosition = _currentLocation!;
    for (var coord in widget.coordinates) {
      final destination = LatLng(coord['latitude']!, coord['longitude']!);
      final routeData = await _fetchRouteData(lastPosition, destination);

      if (routeData != null) {
        polylineCoordinates.addAll(routeData['polyline']);
        totalTimeSeconds += (routeData['duration'] as int);
        totalDistanceMeters += routeData['distance'];
      }

      lastPosition = destination;
    }

    int totalMinutes = totalTimeSeconds ~/ 60;
    int hours = totalMinutes ~/ 60;
    int minutes = totalMinutes % 60;

    String formattedTime = hours > 0 ? "$hours hrs ${minutes.toString().padLeft(2, '0')} mins" : "$minutes mins";

    setState(() {
      _estimatedTotalTime = formattedTime;
      _totalDistance = "${(totalDistanceMeters / 1000).toStringAsFixed(2)} km";
      _polylines.clear();
      _polylines.add(
        Polyline(
          polylineId: const PolylineId('route'),
          points: polylineCoordinates,
          color: Colors.blue,
          width: 5,
        ),
      );
    });

    _mapController.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(
            _currentLocation!.latitude < lastPosition.latitude ? _currentLocation!.latitude : lastPosition.latitude,
            _currentLocation!.longitude < lastPosition.longitude ? _currentLocation!.longitude : lastPosition.longitude,
          ),
          northeast: LatLng(
            _currentLocation!.latitude > lastPosition.latitude ? _currentLocation!.latitude : lastPosition.latitude,
            _currentLocation!.longitude > lastPosition.longitude ? _currentLocation!.longitude : lastPosition.longitude,
          ),
        ),
        50.0,
      ),
    );
  }

  Future<Map<String, dynamic>?> _fetchRouteData(LatLng origin, LatLng destination) async {
    final apiKey = 'AIzaSyCKHBzKuREDSb9A76zDMLNPAh7oTP1miew';
    final url = 'https://maps.googleapis.com/maps/api/directions/json?origin=${origin.latitude},${origin.longitude}&destination=${destination.latitude},${destination.longitude}&key=$apiKey';

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['status'] == 'OK') {
        var polylineEncoded = data['routes'][0]['overview_polyline']['points'];
        var polylineCoordinates = _decodePolyline(polylineEncoded);

        var duration = data['routes'][0]['legs'][0]['duration']['value'];
        var distance = data['routes'][0]['legs'][0]['distance']['value'];

        return {
          'polyline': polylineCoordinates,
          'duration': duration,
          'distance': distance,
        };
      }
    }
    return null;
  }

  List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> polyline = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lng += dlng;

      polyline.add(LatLng(lat / 1E5, lng / 1E5));
    }
    return polyline;
  }

  void _openInGoogleMaps() {
    String origin = '${_currentLocation!.latitude},${_currentLocation!.longitude}';
    String destination = '${widget.coordinates.last['latitude']},${widget.coordinates.last['longitude']}';

    List<String> waypoints = widget.coordinates
        .sublist(0, widget.coordinates.length - 1)
        .map((coord) => '${coord['latitude']},${coord['longitude']}')
        .toList();

    String waypointsString = waypoints.join('|');

    final url =
        'https://www.google.com/maps/dir/?api=1&origin=$origin&destination=$destination&waypoints=$waypointsString&travelmode=driving';

    launch(url);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pre-built Package Route'),
      ),
      body: Column(
        children: [
          if (_estimatedTotalTime != null && _totalDistance != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Estimated Time: $_estimatedTotalTime | Distance: $_totalDistance',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          Expanded(
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _currentLocation ?? LatLng(0, 0),
                zoom: 12,
              ),
              markers: _markers,
              polylines: _polylines,
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              onMapCreated: (GoogleMapController controller) {
                _mapController = controller;
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: _openInGoogleMaps,
              child: const Text('Open in Google Maps'),
            ),
          ),
        ],
      ),
    );
  }
}
