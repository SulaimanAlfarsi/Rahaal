import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class UserGoogleMapPage extends StatefulWidget {
  final double latitude;
  final double longitude;

  const UserGoogleMapPage({
    Key? key,
    required this.latitude,
    required this.longitude,
  }) : super(key: key);

  @override
  _UserGoogleMapPageState createState() => _UserGoogleMapPageState();
}

class _UserGoogleMapPageState extends State<UserGoogleMapPage> {
  late GoogleMapController _mapController;
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};
  LatLng? _currentLocation;
  String? _estimatedTime;
  String? _distance;

  @override
  void initState() {
    super.initState();
    _initializeLocationAndRoute();
    _addAttractionMarker();
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  Future<void> _initializeLocationAndRoute() async {
    bool hasPermission = await _checkAndRequestPermission();
    if (!hasPermission) return;

    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

    setState(() {
      _currentLocation = LatLng(position.latitude, position.longitude);
      _addCurrentLocationMarker();
      _fetchRouteData();
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

  void _addAttractionMarker() {
    _markers.add(
      Marker(
        markerId: const MarkerId('attraction'),
        position: LatLng(widget.latitude, widget.longitude),
        infoWindow: const InfoWindow(title: 'Attraction Location'),
      ),
    );
  }

  Future<void> _fetchRouteData() async {
    if (_currentLocation == null) return;

    final origin = '${_currentLocation!.latitude},${_currentLocation!.longitude}';
    final destination = '${widget.latitude},${widget.longitude}';
    final apiKey = 'AIzaSyCKHBzKuREDSb9A76zDMLNPAh7oTP1miew';
    final url = 'https://maps.googleapis.com/maps/api/directions/json?origin=$origin&destination=$destination&key=$apiKey&mode=driving';

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      if (data['status'] == 'OK') {
        var route = data['routes'][0];
        var overviewPolyline = route['overview_polyline']['points'];
        var duration = route['legs'][0]['duration']['text'];
        var distanceMeters = route['legs'][0]['distance']['value'];

        // Convert meters to kilometers
        double distanceKm = distanceMeters / 1000;
        _distance = "${distanceKm.toStringAsFixed(2)} km";

        // Decode the encoded polyline into a list of LatLng points
        List<LatLng> polylineCoordinates = _decodePolyline(overviewPolyline);

        setState(() {
          _estimatedTime = duration;
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
                _currentLocation!.latitude < widget.latitude
                    ? _currentLocation!.latitude
                    : widget.latitude,
                _currentLocation!.longitude < widget.longitude
                    ? _currentLocation!.longitude
                    : widget.longitude,
              ),
              northeast: LatLng(
                _currentLocation!.latitude > widget.latitude
                    ? _currentLocation!.latitude
                    : widget.latitude,
                _currentLocation!.longitude > widget.longitude
                    ? _currentLocation!.longitude
                    : widget.longitude,
              ),
            ),
            50.0,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${data['status']}')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to fetch route')),
      );
    }
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
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      polyline.add(LatLng(lat / 1E5, lng / 1E5));
    }

    return polyline;
  }

  void _openGoogleMapsForNavigation() async {
    final googleMapsUrl = 'https://www.google.com/maps/dir/?api=1&origin=${_currentLocation!.latitude},${_currentLocation!.longitude}&destination=${widget.latitude},${widget.longitude}&travelmode=driving';
    if (await canLaunch(googleMapsUrl)) {
      await launch(googleMapsUrl);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not launch Google Maps')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Attraction Route'),
        actions: [
          IconButton(
            icon: Icon(Icons.directions),
            onPressed: _openGoogleMapsForNavigation,
          ),
        ],
      ),
      body: Column(
        children: [
          if (_estimatedTime != null && _distance != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Estimated Time: $_estimatedTime | Distance: $_distance',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          Expanded(
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: LatLng(widget.latitude, widget.longitude),
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
              onPressed: _openGoogleMapsForNavigation,
              child: const Text('Start Route in Google Maps'),
            ),
          ),
        ],
      ),
    );
  }
}
