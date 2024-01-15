import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:snippet_coder_utils/FormHelper.dart';

import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:socket_map/pages/google_map_pages.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late IO.Socket socket;
  double? latitude;
  double? longitude;
  static final GlobalKey<FormState> globalKey = GlobalKey<FormState>();
  Future<void> initSocket() async {
    print("call");
    try {
      socket = IO.io("http://192.168.1.101:3700", <String, dynamic>{
        'transports': ['websocket'],
        'autoConnect': true,
      });
      socket.connect();
      socket.onConnect((data) => {print("Connect: ${socket.id}")});
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initSocket();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    socket.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Form(
          key: globalKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FormHelper.inputFieldWidget(

                  context, "Latitude", "latitudre",
                  (onValidate) {
                if (onValidate.isEmpty) {
                  return "*required";
                }
                return null;
              }, (onSaved) {
                latitude = double.parse(onSaved);
              }, borderRadius: 10),
              SizedBox(height: 10,),
              FormHelper.inputFieldWidget(context, "Longtitude", "longtitude",
                  (onValidate) {
                if (onValidate.isEmpty) {
                  return "*required";
                }
                return null;
              }, (onSaved) {
                longitude = double.parse(onSaved);
              }, borderRadius: 10),
              SizedBox(height: 10,),
              FormHelper.submitButton("Send", (){
                if(validate()){
                  var coords={
                    "lat": latitude,
                    "lng": longitude
                  };
                  socket.emit('position-change',
                  jsonEncode(coords));
                  print(coords);

                }

              }),
              SizedBox(height: 10,),
              OutlinedButton(onPressed: (){
                Navigator.push(context, MaterialPageRoute(builder: (_)=>GoogleMapPage()));
              }, child: Text("move"))
            ],
          ),
        ),
      ),
    );
  }
  bool validate(){
    final form =globalKey.currentState;
    if(form!.validate()){
      form.save();
      return true;
    }else{
      return false;
    }

  }
}
