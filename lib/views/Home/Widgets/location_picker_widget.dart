import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationPickerWidget extends StatefulWidget {
  final String? initialLocation;
  final String? initialLocationMap;
  final Function(String address, String coordinates) onLocationSelected;

  const LocationPickerWidget({
    super.key,
    this.initialLocation,
    this.initialLocationMap,
    required this.onLocationSelected,
  });

  @override
  State<LocationPickerWidget> createState() => _LocationPickerWidgetState();
}

class _LocationPickerWidgetState extends State<LocationPickerWidget> {
  GoogleMapController? _mapController;
  LatLng _selectedPosition = const LatLng(24.7136, 46.6753); // Riyadh default
  String _selectedAddress = '';
  bool _isLoading = false;
  Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _initializeLocation();
  }

  Future<void> _initializeLocation() async {
    // Try to parse initial coordinates if provided
    if (widget.initialLocationMap != null &&
        widget.initialLocationMap!.isNotEmpty) {
      try {
        String locationMapData = widget.initialLocationMap!;

        // Check if it's a Google Maps link
        if (locationMapData.contains('maps.google.com/maps?q=')) {
          // Extract coordinates from Google Maps link
          final regex = RegExp(r'q=(-?\d+\.?\d*),(-?\d+\.?\d*)');
          final match = regex.firstMatch(locationMapData);
          if (match != null) {
            final lat = double.parse(match.group(1)!);
            final lng = double.parse(match.group(2)!);
            _selectedPosition = LatLng(lat, lng);
            _selectedAddress = widget.initialLocation ?? '';
            _updateMarker();
            return;
          }
        } else {
          // Try to parse as coordinates (fallback for old format)
          final coords = locationMapData.split(',');
          if (coords.length == 2) {
            final lat = double.parse(coords[0].trim());
            final lng = double.parse(coords[1].trim());
            _selectedPosition = LatLng(lat, lng);
            _selectedAddress = widget.initialLocation ?? '';
            _updateMarker();
            return;
          }
        }
      } catch (e) {
        log('Error parsing initial location data: $e');
      }
    }

    // Try to get current location
    await _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isLoading = true);

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showLocationServiceDialog();
        setState(() => _isLoading = false);
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() => _isLoading = false);
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() => _isLoading = false);
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      _selectedPosition = LatLng(position.latitude, position.longitude);
      await _updateAddressFromPosition(_selectedPosition);
      _updateMarker();

      _mapController?.animateCamera(
        CameraUpdate.newLatLng(_selectedPosition),
      );
    } catch (e) {
      log('Error getting current location: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _updateMarker() {
    setState(() {
      _markers = {
        Marker(
          markerId: const MarkerId('selected_location'),
          position: _selectedPosition,
          draggable: true,
          onDragEnd: (LatLng position) {
            _onLocationSelected(position);
          },
        ),
      };
    });
  }

  Future<void> _onLocationSelected(LatLng position) async {
    setState(() {
      _selectedPosition = position;
      _isLoading = true;
    });

    await _updateAddressFromPosition(position);
    _updateMarker();
    setState(() => _isLoading = false);
  }

  Future<void> _updateAddressFromPosition(LatLng position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        final placemark = placemarks.first;
        _selectedAddress = [
          placemark.street,
          placemark.subLocality,
          placemark.locality,
          placemark.administrativeArea,
          placemark.country,
        ].where((element) => element != null && element.isNotEmpty).join(', ');
      }
    } catch (e) {
      log('Error getting address: $e');
      _selectedAddress = '${position.latitude}, ${position.longitude}';
    }
  }

  void _showLocationServiceDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Location Services Disabled'),
        content:
            const Text('Please enable location services to use this feature.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Location'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: _getCurrentLocation,
          ),
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () {
              final googleMapsLink =
                  'https://maps.google.com/maps?q=${_selectedPosition.latitude},${_selectedPosition.longitude}';
              widget.onLocationSelected(_selectedAddress, googleMapsLink);
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _selectedPosition,
              zoom: 15,
            ),
            onMapCreated: (GoogleMapController controller) {
              _mapController = controller;
            },
            onTap: _onLocationSelected,
            markers: _markers,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
          ),
          if (_isLoading)
            Container(
              color: Colors.black26,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Selected Location:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _selectedAddress.isNotEmpty
                        ? _selectedAddress
                        : 'Tap on the map to select a location',
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Maps Link: https://maps.google.com/maps?q=${_selectedPosition.latitude.toStringAsFixed(6)},${_selectedPosition.longitude.toStringAsFixed(6)}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
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
