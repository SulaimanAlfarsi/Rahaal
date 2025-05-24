import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:url_launcher/url_launcher.dart';

class GoogleMapsPage extends StatefulWidget {
  final double latitude;
  final double longitude;

  const GoogleMapsPage({
    Key? key,
    required this.latitude,
    required this.longitude,
  }) : super(key: key);

  @override
  _GoogleMapsPageState createState() => _GoogleMapsPageState();
}

class _GoogleMapsPageState extends State<GoogleMapsPage> {
  late GoogleMapController _mapController;
  final Location _location = Location();
  LatLng? _currentLocation;
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};
  String? _distance;
  String? _duration;
  final String _apiKey = 'AIzaSyCKHBzKuREDSb9A76zDMLNPAh7oTP1miew';

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  // Fetch the current location
  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await _location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await _location.requestService();
        if (!serviceEnabled) return;
      }

      PermissionStatus permissionGranted = await _location.hasPermission();
      if (permissionGranted == PermissionStatus.denied) {
        permissionGranted = await _location.requestPermission();
        if (permissionGranted != PermissionStatus.granted) return;
      }

      final locationData = await _location.getLocation();
      setState(() {
        _currentLocation = LatLng(
          locationData.latitude!,
          locationData.longitude!,
        );
        _addMarkers();
        _getRoute();
      });
    } catch (e) {
      print('Error fetching location: $e');
    }
  }

  // Add markers for both current and destination locations
  void _addMarkers() {
    if (_currentLocation != null) {
      _markers.add(
        Marker(
          markerId: MarkerId('currentLocation'),
          position: _currentLocation!,
          infoWindow: InfoWindow(title: 'Your Location'),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        ),
      );
    }

    _markers.add(
      Marker(
        markerId: MarkerId('destination'),
        position: LatLng(widget.latitude, widget.longitude),
        infoWindow: InfoWindow(title: 'Attraction Location'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      ),
    );
  }

  // Fetch and display route polyline and information
  Future<void> _getRoute() async {
    if (_currentLocation == null) return;

    final origin = "${_currentLocation!.latitude},${_currentLocation!.longitude}";
    final destination = "${widget.latitude},${widget.longitude}";

    final url =
        'https://maps.googleapis.com/maps/api/directions/json?origin=$origin&destination=$destination&key=$_apiKey';

    print('Fetching route from URL: $url'); // Log URL for debugging

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['routes'] != null && data['routes'].isNotEmpty) {
        final route = data['routes'][0]['overview_polyline']['points'];
        final legs = data['routes'][0]['legs'][0];

        setState(() {
          // Convert distance to kilometers if needed
          final distanceMeters = legs['distance']['value'];
          _distance = '${(distanceMeters / 1000).toStringAsFixed(1)} km'; // Convert meters to kilometers
          _duration = legs['duration']['text'];
        });

        _addPolyline(route);
      } else {
        print('No routes found in the response');
      }
    } else {
      print('Failed to fetch route: ${response.statusCode} ${response.body}');
    }
  }

  // Decode polyline string into a list of LatLng points
  List<LatLng> _decodePolyline(String polyline) {
    List<LatLng> points = [];
    int index = 0, len = polyline.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = polyline.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = polyline.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lng += dlng;

      points.add(LatLng(lat / 1e5, lng / 1e5));
    }
    return points;
  }

  // Add polyline to map
  void _addPolyline(String encodedPolyline) {
    final polylinePoints = _decodePolyline(encodedPolyline);
    setState(() {
      _polylines.add(
        Polyline(
          polylineId: PolylineId("route"),
          points: polylinePoints,
          color: Colors.blue,
          width: 5,
        ),
      );
    });
  }

  // Open navigation route within the app
  Future<void> _startNavigation() async {
    if (_currentLocation == null) return;

    final String url =
        'https://www.google.com/maps/dir/?api=1&origin=${_currentLocation!.latitude},${_currentLocation!.longitude}&destination=${widget.latitude},${widget.longitude}&travelmode=driving';

    if (await canLaunch(url)) {
      await launch(url);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not launch Google Maps')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Google Map'),
        actions: [
          IconButton(
            icon: const Icon(Icons.directions),
            onPressed: _startNavigation,
          ),
        ],
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: LatLng(widget.latitude, widget.longitude),
              zoom: 14,
            ),
            markers: _markers,
            polylines: _polylines,
            myLocationEnabled: true,
            onMapCreated: (GoogleMapController controller) {
              _mapController = controller;
            },
          ),
          Positioned(
            top: 20,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Column(
                children: [
                  if (_distance != null && _duration != null)
                    Text(
                      'Distance: $_distance | Duration: $_duration',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
