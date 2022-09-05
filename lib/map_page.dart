import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class MapPage extends StatefulWidget {
  const MapPage({Key? key}) : super(key: key);

  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final  Completer<GoogleMapController> _controller=Completer();
  Circle? circle;
  //for polylines
  List<LatLng> polylineCoordinates = [];
  LatLng currentLocation2=LatLng(10.870992924666764, 106.62228801984124);
  LatLng sourceLocation=LatLng(10.870992924666764, 106.62228801984124);
  LatLng destinationLocation=LatLng(10.876850883461556, 106.6374378648807);
  void getPolyPoint(LatLng pos)async{
    PolylinePoints polylinePoints=PolylinePoints();
    PolylineResult result=await polylinePoints.getRouteBetweenCoordinates(
      "AIzaSyABFQGws_pU_C0wDKZmk-_W1ZxY1fDS13E",
        // PointLatLng(sourceLocation.latitude,sourceLocation.longitude),
        // PointLatLng(destinationLocation.latitude, destinationLocation.longitude),
      PointLatLng(sourceLocation.latitude,sourceLocation.longitude),
      PointLatLng(destinationLocation.latitude, destinationLocation.longitude),
      travelMode: TravelMode.driving
    );
    if(result.points.isNotEmpty){
      result.points.forEach(
              (PointLatLng point) => polylineCoordinates.add(LatLng(point.latitude, point.longitude))
      );
      setState(() {

      });
    }
  }
  //device location
  LocationData? currentLocation;
  void getCurrentLocation() async{
    Location location=Location();
    location.getLocation().then((value) {
      currentLocation=value;
    });
    GoogleMapController googleMapController=await _controller.future;

    //location on change
    location.onLocationChanged.listen((event) {
      currentLocation=event;
      googleMapController.animateCamera(
          CameraUpdate.newCameraPosition(
              CameraPosition(zoom: 14.5,target: LatLng(event.latitude!,event.longitude!))));
      setState(() {
        //
      });
      circle = Circle(
          circleId: const CircleId("car"),
          radius: event.accuracy! *100,
          zIndex: 1,
          strokeColor: Colors.blue,
          center: LatLng(event.latitude!,event.longitude!),
          fillColor: Colors.blue.withAlpha(10));
    });

  }
  //custum marker

  BitmapDescriptor destinationIcon=BitmapDescriptor.defaultMarkerWithHue(
      BitmapDescriptor.hueGreen);
  BitmapDescriptor currentIcon=BitmapDescriptor.defaultMarker;

 void setCustomMarkerIcon(){
      BitmapDescriptor.fromAssetImage(ImageConfiguration.empty, "asset/pin_cource.pngh").then((value){
        destinationIcon=value;
      });BitmapDescriptor.fromAssetImage(ImageConfiguration.empty, "asset/pin_cource.pngh").then((value){
        currentIcon=value;
      });
  }
  Marker? _destination ;
  void _addMarker(LatLng pos) {
    if(_destination==null || _destination?.position != pos){
      setState(() async {
        _destination = Marker(
            markerId: const MarkerId('_source'),
            infoWindow: const InfoWindow(title: 'Điểm đến'),
            icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueGreen),
            position: pos);
        destinationLocation=LatLng( pos.latitude,  pos.longitude);
        //_destination = null;
      });
    }

  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCurrentLocation();
    getPolyPoint(destinationLocation);
  }
  @override
  void dispose() {
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return currentLocation == null?const Center(child: Text("loading....")):GoogleMap(
      myLocationButtonEnabled: true,
      // mapType: MapType.hybrid,
      circles: Set.of((circle != null) ? [circle!] : []),
      onTap: _addMarker,
      initialCameraPosition:  CameraPosition(target: LatLng(currentLocation2!.latitude!,currentLocation2!.longitude!),zoom: 11.5),
      markers: {
         Marker(
         markerId: const MarkerId("destination"),
         infoWindow: const InfoWindow(title: 'Điểm đến'), icon: BitmapDescriptor.defaultMarkerWithHue(
                 BitmapDescriptor.hueGreen),
         position: LatLng(destinationLocation!.latitude!,destinationLocation!.longitude!)
         ),
         Marker(
            markerId: const MarkerId("current"),
             infoWindow: const InfoWindow(title: 'Vị trí của bạn'),
            position: LatLng(currentLocation!.latitude!,currentLocation!.longitude!),
             icon: currentIcon
        ),
      },
      polylines:{
        Polyline(
          polylineId: const PolylineId("route"),
          points: polylineCoordinates,
          color: Colors.deepPurpleAccent,
          width: 6
        )
      },
      onMapCreated: (controller){
        _controller.complete(controller);
      },
    );
  }
}


