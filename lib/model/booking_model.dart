import 'package:cloud_firestore/cloud_firestore.dart';

class BookingModel {
  String docId,
      barberId,
      barberName,
      cityBook,
      customerName,
      customerPhone,
      salonAddress,
      salonId,
      salonName,
      time;
  bool done;
  int slot, timeStamp;

  DocumentReference reference;

  BookingModel(
      {this.docId,
      this.barberId,
      this.barberName,
      this.cityBook,
      this.customerName,
      this.customerPhone,
      this.salonAddress,
      this.salonId,
      this.salonName,
      this.time,
      this.done,
      this.slot,
      this.timeStamp});

  BookingModel.fromJson(Map<String, dynamic> json) {
    barberId = json['barberId'];
    barberName = json['barberName'];
    cityBook = json['cityBook'];
    customerName = json['customerName'];
    customerPhone = json['customerPhone'];
    salonAddress = json['salonAddress'];
    salonName = json['salonName'];
    salonId = json['salonId'];
    time = json['time'];
    done = json['done'] as bool;
    slot = int.parse(json['slot'] == null ? '-1' : json['slot'].toString());
    timeStamp = int.parse(
        json['timeStamp'] == null ? '0' : json['timeStamp'].toString());
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['barberId'] = this.barberId;
    data['barberName'] = this.barberName;
    data['cityBook'] = this.cityBook;
    data['customerName'] = this.customerName;
    data['customerPhone'] = this.customerPhone;
    data['salonAddress'] = this.salonAddress;
    data['salonName'] = this.salonName;
    data['salonId'] = this.salonId;
    data['time'] = this.time;
    data['done'] = this.done;
    data['slot'] = this.slot;
    data['timeStamp'] = this.timeStamp;
    return data;
  }
}
