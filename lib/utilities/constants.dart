import 'package:flutter/material.dart';

class Constants {
  static var jobCategories = [
    "Ac/Refrigirator Service",
    "Computer/Laptop Service",
    "Tv Repair",
    "Development",
    "Tutor",
    "Beauty",
    "Photographer",
    "Driver",
    "Events",
    "Electrician",
    "Carpenter",
    "Plumber",
    "Interior Design",
    "Design",
    "CC Tv Installation",
    "Catering",
  ];
}

orderStateString({ordState = 0}) {
  int orderState =
      ordState.runtimeType == String ? int.parse(ordState) : ordState;
  switch (orderState) {
    case 0:
      return "Service Request by User";
    case 1:
      return "There is no partner available for this Service please try again later";
    case 2:
      return "User updated the Service";
    case 3:
      return "Service cancelled by User";
    case 4:
      return "Service cancelled by You";
    case 5:
      return "Something went wrong";
    case 6:
      return "There is not value for this string";
    case 7:
      return "Service reshedule by the User";
    case 8:
      return "Service is Ongoing";
    case 9:
      return "Service completed successfully ";
    case 10:
      return "Service successfully completed and feedback given by User";

    default:
      return "Something went wrong";
  }
}

orderStateIcon({ordState = 0}) {
  int orderState =
      ordState.runtimeType == String ? int.parse(ordState) : ordState;
  switch (orderState) {
    case 0:
      return Icons.pending_actions;
      break;
    case 1:
      return Icons.stop_circle;
      break;
    case 2:
      return Icons.update;
      break;
    case 8:
      return Icons.run_circle_rounded;
      break;
    case 9:
    case 10:
      return Icons.verified_rounded;
      break;
    case 3:
      return Icons.cancel;
      break;
    default:
      return Icons.search;
  }
}