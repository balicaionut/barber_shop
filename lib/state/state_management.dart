import 'package:barber_shop/model/barber_model.dart';
import 'package:barber_shop/model/city_model.dart';
import 'package:barber_shop/model/salon_model.dart';
import 'package:barber_shop/model/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final userLogged = StateProvider((ref) => FirebaseAuth.instance.currentUser);
final userToken = StateProvider((ref) => '');
final forceReload = StateProvider((ref) => false);

final userInformation = StateProvider((ref) => UserModel());

// Stare rezervare
final currentStep = StateProvider((ref) => 1);
final selectedCity = StateProvider((ref) => CityModel());
final selectedSalon = StateProvider((ref) => SalonModel());
final selectedBarber = StateProvider((ref) => BarberModel());
final selectedDate = StateProvider((ref) => DateTime.now());
final selectedTimeSlot = StateProvider((ref) => -1);
final selectedTime = StateProvider((ref) => '');

// Ștergere rezervare
final deleteFlagRefresh = StateProvider((ref) => false);

// Staff
final staffStep = StateProvider((ref) => 1);

