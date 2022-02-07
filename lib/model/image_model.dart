import 'package:barber_shop/model/user_model.dart';
import 'package:flutter/cupertino.dart';

class ImageModel{
  String image;

  ImageModel({this.image});

  ImageModel.fromJson(Map<String,dynamic> json){
    image = json['image'];
  }

  Map<String,dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['image'] = this.image;
    return data;
  }
}