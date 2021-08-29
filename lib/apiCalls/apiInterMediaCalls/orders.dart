import 'dart:convert';
import 'package:spotmies_partner/apiCalls/apiCalling.dart';
import 'package:spotmies_partner/apiCalls/apiUrl.dart';
import 'package:spotmies_partner/apiCalls/testController.dart';
import 'package:spotmies_partner/localDB/localStore.dart';


final controller = TestController();
  var orders;
  final queryParameters = {
    'showOnly': 'inComingOrders',
    'extractData': 'true',
    'ordState': 'req'
  };

incomingOrders() async {
    var response =
        await Server().getMethodParems(API.incomingorders, queryParameters);
    orders = jsonDecode(response);
    controller.getData();
    localOrdersStore(orders);
  }