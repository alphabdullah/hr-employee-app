import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../utils/screen_unit_util.dart';
import '../resources/components/primary_button.dart';

/// Screen for picking home location on a map
class AddressPickerScreen extends StatefulWidget {
  final double? initialLatitude;
  final double? initialLongitude;

  const AddressPickerScreen({
    super.key,
    this.initialLatitude,
    this.initialLongitude,
  });

  @override
  State<AddressPickerScreen> createState() => _AddressPickerScreenState();
}

class _AddressPickerScreenState extends State<AddressPickerScreen> {
  final MapController _mapController = MapController();
  LatLng? _selectedLocation;
  bool _isLoadingLocation = false;
  String? _selectedAddress;
  bool _isLoadingAddress = false;

  @override
  void initState() {
    super.initState();
    _initializeLocation();
  }

  Future<void> _initializeLocation() async {
    setState(() {
      _isLoadingLocation = true;
    });

    try {
      LatLng initialLocation;

      // Use provided location or try to get current location
      if (widget.initialLatitude != null && widget.initialLongitude != null) {
        initialLocation = LatLng(widget.initialLatitude!, widget.initialLongitude!);
        _selectedLocation = initialLocation;
        // Get address for initial location
        _getAddressFromCoordinates(widget.initialLatitude!, widget.initialLongitude!);
      } else {
        // Try to get current location
        bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
        if (!serviceEnabled) {
          // Default to London if location services are disabled
          initialLocation = const LatLng(51.5074, -0.1278);
        } else {
          LocationPermission permission = await Geolocator.checkPermission();
          if (permission == LocationPermission.denied) {
            permission = await Geolocator.requestPermission();
          }

          if (permission == LocationPermission.deniedForever ||
              permission == LocationPermission.denied) {
            // Default to London if permission denied
            initialLocation = const LatLng(51.5074, -0.1278);
          } else {
            Position position = await Geolocator.getCurrentPosition(
              desiredAccuracy: LocationAccuracy.high,
            );
            initialLocation = LatLng(position.latitude, position.longitude);
            _selectedLocation = initialLocation;
            // Get address for current location
            _getAddressFromCoordinates(position.latitude, position.longitude);
          }
        }
      }

      // Center map on initial location
      _mapController.move(initialLocation, 15.0);
    } catch (e) {
      // Default to London on error
      const initialLocation = LatLng(51.5074, -0.1278);
      _mapController.move(initialLocation, 15.0);
    } finally {
      setState(() {
        _isLoadingLocation = false;
      });
    }
  }

  void _onMapTap(TapPosition tapPosition, LatLng point) {
    setState(() {
      _selectedLocation = point;
      _selectedAddress = null; // Clear previous address
    });
    _getAddressFromCoordinates(point.latitude, point.longitude);
  }

  Future<void> _getAddressFromCoordinates(double latitude, double longitude) async {
    setState(() {
      _isLoadingAddress = true;
    });

    try {
      // Use Nominatim reverse geocoding API
      final url = 'https://nominatim.openstreetmap.org/reverse?format=json&lat=$latitude&lon=$longitude&zoom=18&addressdetails=1';
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'User-Agent': 'HR Employee App', // Required by Nominatim
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final address = data['display_name'] as String?;
        
        if (mounted) {
          setState(() {
            _selectedAddress = address ?? 'Address not found';
            _isLoadingAddress = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _selectedAddress = 'Unable to fetch address';
            _isLoadingAddress = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _selectedAddress = 'Unable to fetch address';
          _isLoadingAddress = false;
        });
      }
    }
  }

  void _confirmLocation() {
    if (_selectedLocation != null) {
      Navigator.of(context).pop({
        'latitude': _selectedLocation!.latitude,
        'longitude': _selectedLocation!.longitude,
        'address': _selectedAddress,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    ScreenUnitUtil.init(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Mark Your Home Location',
          style: TextStyle(
            fontSize: ScreenUnitUtil.getFontSize(20),
            fontWeight: FontWeight.w600,
          ),
        ),
        elevation: 0,
      ),
      body: Stack(
        children: [
          // Map
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: widget.initialLatitude != null && widget.initialLongitude != null
                  ? LatLng(widget.initialLatitude!, widget.initialLongitude!)
                  : const LatLng(51.5074, -0.1278), // Default to London
              initialZoom: 15.0,
              onTap: _onMapTap,
            ),
            children: [
              // OpenStreetMap tile layer
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.hr.employee.app',
              ),
              // Marker layer
              if (_selectedLocation != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _selectedLocation!,
                      width: 40,
                      height: 40,
                      child: Icon(
                        Icons.location_on,
                        color: Theme.of(context).colorScheme.primary,
                        size: ScreenUnitUtil.getFontSize(40),
                      ),
                    ),
                  ],
                ),
            ],
          ),

          // Instructions overlay
          Positioned(
            top: ScreenUnitUtil.getSpacing(16),
            left: ScreenUnitUtil.getSpacing(16),
            right: ScreenUnitUtil.getSpacing(16),
            child: Container(
              padding: EdgeInsets.all(ScreenUnitUtil.getSpacing(12)),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(ScreenUnitUtil.getSpacing(8)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: ScreenUnitUtil.getFontSize(20),
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  SizedBox(width: ScreenUnitUtil.getSpacing(8)),
                  Expanded(
                    child: Text(
                      'Tap on the map to mark your home location',
                      style: TextStyle(
                        fontSize: ScreenUnitUtil.getFontSize(14),
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Loading indicator
          if (_isLoadingLocation)
            Center(
              child: CircularProgressIndicator(),
            ),

          // Confirm button
          Positioned(
            bottom: ScreenUnitUtil.getSpacing(24),
            left: ScreenUnitUtil.getSpacing(24),
            right: ScreenUnitUtil.getSpacing(24),
            child: PrimaryButton(
              text: 'Confirm Location',
              isLoading: false,
              onPressed: _selectedLocation != null ? _confirmLocation : null,
            ),
          ),

          // Selected address display
          if (_selectedLocation != null)
            Positioned(
              bottom: ScreenUnitUtil.getSpacing(100),
              left: ScreenUnitUtil.getSpacing(24),
              right: ScreenUnitUtil.getSpacing(24),
              child: Container(
                padding: EdgeInsets.all(ScreenUnitUtil.getSpacing(12)),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(ScreenUnitUtil.getSpacing(8)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Selected Location:',
                      style: TextStyle(
                        fontSize: ScreenUnitUtil.getFontSize(12),
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    SizedBox(height: ScreenUnitUtil.getSpacing(4)),
                    if (_isLoadingAddress)
                      Row(
                        children: [
                          SizedBox(
                            width: ScreenUnitUtil.getFontSize(16),
                            height: ScreenUnitUtil.getFontSize(16),
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          ),
                          SizedBox(width: ScreenUnitUtil.getSpacing(8)),
                          Text(
                            'Loading address...',
                            style: TextStyle(
                              fontSize: ScreenUnitUtil.getFontSize(14),
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      )
                    else if (_selectedAddress != null)
                      Text(
                        _selectedAddress!,
                        style: TextStyle(
                          fontSize: ScreenUnitUtil.getFontSize(14),
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onSurface,
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
