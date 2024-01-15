import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
class GoogleMapPage extends StatefulWidget {
  const GoogleMapPage({super.key});

  @override
  State<GoogleMapPage> createState() => _GoogleMapPageState();
}

class _GoogleMapPageState extends State<GoogleMapPage> {
 late IO.Socket socket;
 late Map<MarkerId,Marker>_markers;
 Completer <GoogleMapController>_controller=Completer();
 static const CameraPosition _cameraPosition=
     CameraPosition(target: LatLng(23.728510323149315, 90.41367093887409),
     zoom: 14);
 

@override
  void initState() {
    // TODO: implement initState
    super.initState();
    _markers=<MarkerId,Marker>{};
    _markers.clear();
    initSocket();
  }
  Future <void> initSocket()async{
  try{
    socket = IO.io("http://192.168.1.101:3700", <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': true,
    });
    socket.connect();
    socket.on("position-change", (data)async {
      var latLng=jsonDecode(data);
      final GoogleMapController controller=
          await _controller.future;
      controller.animateCamera(
        CameraUpdate.newCameraPosition(
            CameraPosition(target: LatLng(
                latLng["lat"],
                latLng["lng"]
            ),zoom: 19)
        )

      );
      var image=
    await  BitmapDescriptor.fromAssetImage(
      ImageConfiguration(),
      "images/marker.png");
      Marker marker=Marker(markerId: MarkerId ("ID"),
      icon: image,position: LatLng(
      latLng["lat"],
      latLng["lng"],
      ) );
      setState(() {
        _markers[MarkerId("ID")]=marker;
      });
    });
  }catch(e){
    print("${e.toString()}");
    
  }
  
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GoogleMap(
        initialCameraPosition: _cameraPosition,
        mapType: MapType.normal,
        onMapCreated: (GoogleMapController conroller){

          _controller.complete(conroller);
        },
        markers: Set<Marker>.of(_markers.values),
      ),

    );
  }
}
