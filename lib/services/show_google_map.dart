import 'package:google_maps_flutter/google_maps_flutter.dart';

showMapSection(
    {required double latitude,
    required double longitude,
    dynamic onDragStopped}) {
  final Marker marker = Marker(
      markerId: const MarkerId('locate'),
      zIndex: 1.0,
      draggable: !(onDragStopped == null),
      onDragEnd: onDragStopped,
      position: LatLng(latitude, longitude));

  return GoogleMap(
    mapType: MapType.hybrid,
    markers: {marker},
    myLocationButtonEnabled: !(onDragStopped == null),
    myLocationEnabled: !(onDragStopped == null),
    initialCameraPosition: CameraPosition(
      target: LatLng(latitude, longitude),
      zoom: 18.4746,
    ),
  );
}
