 
import 'package:freewifi/models/dealdata.dart';
import 'package:freewifi/services/dealservices.dart';

class Dealbloc {
  Stream<List<Dealdata>> get dealDataListView async* {
    yield await DealServices.browse();
  }
}