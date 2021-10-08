import 'dart:convert';
import 'dart:developer';

import 'package:carousel_slider/carousel_options.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:provider/provider.dart';
import 'package:spotmies_partner/controllers/post_overview_controller.dart';
import 'package:spotmies_partner/internet_calling/calling.dart';
import 'package:spotmies_partner/maps/maps.dart';
import 'package:spotmies_partner/providers/partnerDetailsProvider.dart';
import 'package:spotmies_partner/reusable_widgets/bottom_options_menu.dart';
import 'package:spotmies_partner/reusable_widgets/date_formates.dart';
import 'package:spotmies_partner/reusable_widgets/elevatedButtonWidget.dart';
import 'package:spotmies_partner/reusable_widgets/profile_pic.dart';
import 'package:spotmies_partner/reusable_widgets/progress_waiter.dart';
import 'package:spotmies_partner/reusable_widgets/text_wid.dart';
import 'package:spotmies_partner/utilities/constants.dart';
import 'package:spotmies_partner/utilities/profile_shimmer.dart';
import 'package:spotmies_partner/utilities/snackbar.dart';
import 'package:timelines/timelines.dart';

class PostOverView extends StatefulWidget {
  final String orderId;
  final Function onclick;
  final String from;
  final Function onBottomSheet;

  PostOverView(
      {@required this.orderId, this.onclick, this.from, this.onBottomSheet});
  @override
  _PostOverViewState createState() => _PostOverViewState();
}

class _PostOverViewState extends StateMVC<PostOverView> {
  PostOverViewController _postOverViewController;
  _PostOverViewState() : super(PostOverViewController()) {
    this._postOverViewController = controller;
  }
  int ordId;
  dynamic d;
  dynamic partnerProfile;
  PartnerDetailsProvider ordersProvider;
  bool showOrderStatusQuestion = false;

  void chatWithPatner(responseData) {
    if (myPid != responseData['pId']) {
      snackbar(context, "you can't make a chat");
      return;
    }
    _postOverViewController.chatWithpatner(responseData);
  }

  @override
  void initState() {
    ordersProvider =
        Provider.of<PartnerDetailsProvider>(context, listen: false);
    try {
      setState(() {
        if (ordersProvider.getOrderById(widget.orderId)['orderState'] < 9 &&
            ordersProvider.getOrderById(widget.orderId)['acceptResponse']
                    ['orderState'] <
                9) {
          showOrderStatusQuestion = true;
        } else {
          showOrderStatusQuestion = false;
        }
      });
    } catch (e) {}
    super.initState();
  }

  isThisOrderCompleted({state = false, responseId = 123}) {
    if (state) {
      _postOverViewController.isOrderCompleted(responseId: responseId);
    }
    showOrderStatusQuestion = false;
    refresh();
  }

  partnerOrderStatus(d) {
    try {
      return d['acceptResponse']['orderState'] > 8
          ? '${orderStateString(ordState: d['acceptResponse']['orderState'])} ${d['orderState'] < 9 ? 'Waiting for user Confirmation' : '👍'}'
          : orderStateString(ordState: d['orderState']);
    } catch (e) {
      return orderStateString(ordState: d['orderState']);
    }
  }

  @override
  Widget build(BuildContext context) {
    final _hight = MediaQuery.of(context).size.height -
        MediaQuery.of(context).padding.top -
        kToolbarHeight;
    final _width = MediaQuery.of(context).size.width;
    return Consumer<PartnerDetailsProvider>(builder: (context, data, child) {
      d = data.getOrderById(widget.orderId);
      dynamic partnerProfile = data.getProfileDetails;
      log("ord $d");
      if (data.ordersLoader) return Center(child: profileShimmer(context));

      List<String> images = List.from(d['media']);
      dynamic fullAddress = jsonDecode(d['address']);

      return Stack(
        children: [
          Scaffold(
            resizeToAvoidBottomInset: true,
            backgroundColor: Colors.grey[50],
            appBar: AppBar(
              backgroundColor:
                  d['orderState'] > 8 ? Colors.green : Colors.white,
              toolbarHeight: widget.from == "incomingOrders"
                  ? _hight * 0.16
                  : _hight * 0.08,
              // elevation: 0,
              leading: IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: Icon(
                  Icons.arrow_back,
                  color: Colors.grey[900],
                ),
              ),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextWid(
                    text: Constants.jobCategories[d['job'].runtimeType == String
                        ? int.parse(d['job'])
                        : d['job']],
                    size: _width * 0.04,
                    color:
                        d['orderState'] > 8 ? Colors.white : Colors.grey[500],
                    lSpace: 1.5,
                    weight: FontWeight.w600,
                  ),
                  SizedBox(
                    height: _hight * 0.007,
                  ),
                  Row(
                    children: [
                      Icon(
                        // _postOverViewController.orderStateIcon(d['ordState']),
                        orderStateIcon(ordState: d['orderState']),
                        color: Colors.indigo[900],
                        size: _width * 0.045,
                      ),
                      SizedBox(
                        width: _width * 0.01,
                      ),
                      Expanded(
                        child: TextWid(
                            text: orderStateString(ordState: d['orderState']),
                            color: d['orderState'] > 8
                                ? Colors.white
                                : Colors.grey[700],
                            weight: FontWeight.w700,
                            size: _width * 0.04),
                      ),
                    ],
                  )
                ],
              ),
              bottom: PreferredSize(
                  child: widget.from == "incomingOrders"
                      ? Container(
                          margin: EdgeInsets.only(bottom: _width * 0.01),
                          height: _hight * 0.06,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              ElevatedButtonWidget(
                                  height: _hight * 0.05,
                                  minWidth: _width * 0.25,
                                  bgColor: Colors.red,
                                  borderSideColor: Colors.grey[200],
                                  borderRadius: 10.0,
                                  buttonName: 'Reject',
                                  textColor: Colors.white,
                                  textSize: _width * 0.04,
                                  leadingIcon: Icon(
                                    Icons.cancel,
                                    color: Colors.white,
                                    size: _width * 0.045,
                                  ),
                                  onClick: () {
                                    if (widget.from == "incomingOrders") {
                                      widget.onclick(
                                          d, partnerProfile['_id'], "reject");
                                      Navigator.pop(context);
                                    }
                                  }),
                              ElevatedButtonWidget(
                                onClick: () {
                                  widget.onclick(
                                      d, partnerProfile['_id'], "accept");
                                  Navigator.pop(context);
                                },
                                height: _hight * 0.05,
                                minWidth: _width * 0.4,
                                bgColor: Colors.green,
                                borderSideColor: Colors.grey[200],
                                borderRadius: 10.0,
                                buttonName: 'Accept',
                                textColor: Colors.white,
                                textSize: _width * 0.04,
                                trailingIcon: Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: _width * 0.045,
                                ),
                              ),
                              ElevatedButtonWidget(
                                onClick: () {
                                  log("bid");
                                  widget.onBottomSheet();
                                  // bidSendingBottomSheet(
                                  //   _hight,
                                  //   _width,
                                  // );
                                },
                                height: _hight * 0.05,
                                minWidth: _width * 0.22,
                                bgColor: Colors.grey[600],
                                borderSideColor: Colors.grey[200],
                                borderRadius: 10.0,
                                buttonName: 'Bid',
                                textColor: Colors.white,
                                textSize: _width * 0.04,
                                trailingIcon: Icon(
                                  Icons.note_alt_rounded,
                                  color: Colors.white,
                                  size: _width * 0.045,
                                ),
                              ),
                            ],
                          ),
                        )
                      : Container(),
                  preferredSize: Size.fromHeight(4.0)),
              actions: [
                IconButton(
                    onPressed: null,
                    icon: Icon(
                      Icons.help,
                      color: Colors.grey[900],
                    )),
                IconButton(
                    onPressed: () {
                      bottomOptionsMenu(context,
                          options: _postOverViewController.options);
                    },
                    icon: Icon(
                      Icons.more_vert,
                      color: Colors.grey[900],
                    )),
              ],
            ),
            body: SingleChildScrollView(
              child: Column(
                children: [
                  Divider(
                    color: Colors.white,
                  ),
                  TextWid(
                    // text: d['acceptResponse']['orderState'] > 8
                    //     ? '${orderStateString(ordState: d['acceptResponse']['orderState'])} ${d['orderState'] < 9 ? 'Waiting for user Confirmation' : '👍'}'
                    //     : orderStateString(ordState: d['orderState']),
                    text: partnerOrderStatus(d),
                    maxlines: 3,
                  ),

                  Divider(
                    color: Colors.white,
                  ),
                  Container(
                    width: _width,
                    color: Colors.white,
                    child: Column(
                      children: [
                        Container(
                          alignment: Alignment.centerLeft,
                          padding:
                              EdgeInsets.only(top: 15, left: 15, right: 15),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              TextWid(
                                text: 'Service Details :',
                                size: _width * 0.055,
                                weight: FontWeight.w600,
                              ),
                            ],
                          ),
                        ),
                        serviceDetailsListTile(
                          _width,
                          _hight,
                          'Issue/Problem',
                          Icons.settings,
                          d['problem'],
                        ),
                        serviceDetailsListTile(
                          _width,
                          _hight,
                          'Schedule',
                          Icons.schedule,
                          getDate(d['schedule']) + "-" + getTime(d['schedule']),
                        ),
                        serviceDetailsListTile(
                            _width,
                            _hight,
                            'Location',
                            Icons.location_on,
                            fullAddress['addressLine'] ??
                                "Unable to get service address", onClick: () {
                          Map<String, double> cords = {
                            "latitude": double.parse(fullAddress['latitude']),
                            "logitude": double.parse(fullAddress['logitude'])
                          };

                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => Maps(
                                    coordinates: cords,
                                    isNavigate: true,
                                  )));
                        }),
                      ],
                    ),
                  ),
                  Divider(
                    color: Colors.white,
                  ),
                  mediaView(_hight, _width, images),

                  Divider(
                    color: Colors.white,
                  ),
                  // warrentyCard(_hight, _width),
                  Divider(
                    color: Colors.white,
                  ),
                  // (d['orderState'] > 6)
                  //     ?
                  Container(
                      color: Colors.white,
                      child: Column(
                        children: [
                          Container(
                            alignment: Alignment.centerLeft,
                            padding:
                                EdgeInsets.only(top: 15, left: 15, right: 15),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                TextWid(
                                  text: 'User Details :',
                                  size: _width * 0.055,
                                  weight: FontWeight.w600,
                                ),
                              ],
                            ),
                          ),
                          userDetails(_hight, _width, context,
                              _postOverViewController, d, chatWithPatner),
                        ],
                      ))
                  // : Container()
                  ,
                  widget.from != "incomingOrders"
                      ? Container(
                          height: 600,
                          padding:
                              EdgeInsets.only(left: 30, bottom: 50, top: 30),
                          // width: _width * 0.7,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              showOrderStatusQuestion
                                  ? Column(
                                      children: [
                                        Container(
                                          alignment: Alignment.centerLeft,
                                          child: TextWid(
                                            text: 'Is this order completed ?',
                                            size: _width * 0.055,
                                            weight: FontWeight.w600,
                                          ),
                                        ),
                                        Container(
                                          margin: EdgeInsets.only(
                                              top: 20, bottom: 40),
                                          height: _hight * 0.06,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            children: [
                                              ElevatedButtonWidget(
                                                height: _hight * 0.05,
                                                minWidth: _width * 0.35,
                                                onClick: () {
                                                  isThisOrderCompleted(
                                                      state: false);
                                                },
                                                bgColor: Colors.white,
                                                borderSideColor:
                                                    Colors.grey[200],
                                                borderRadius: 10.0,
                                                buttonName: 'Not yet',
                                                textSize: _width * 0.04,
                                                leadingIcon: Icon(
                                                  Icons.cancel,
                                                  color: Colors.grey[900],
                                                  size: _width * 0.045,
                                                ),
                                              ),
                                              ElevatedButtonWidget(
                                                height: _hight * 0.05,
                                                minWidth: _width * 0.45,
                                                bgColor: Colors.indigo[900],
                                                borderSideColor:
                                                    Colors.grey[200],
                                                borderRadius: 10.0,
                                                buttonName: 'Completed',
                                                onClick: () {
                                                  isThisOrderCompleted(
                                                      state: true,
                                                      responseId:
                                                          d['acceptResponse']
                                                              ['responseId']);
                                                },
                                                textColor: Colors.white,
                                                textSize: _width * 0.04,
                                                leadingIcon: Icon(
                                                  Icons.check_circle,
                                                  color: Colors.white,
                                                  size: _width * 0.045,
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                      ],
                                    )
                                  : Container(),
                              Container(
                                alignment: Alignment.centerLeft,
                                child: TextWid(
                                  text: 'Service Status :',
                                  size: _width * 0.055,
                                  weight: FontWeight.w600,
                                ),
                              ),
                              Container(
                                  child: _Timeline2(context, orderData: d)),
                            ],
                          ),
                        )
                      : Container(),
                ],
              ),
            ),
          ),
          ProgressWaiter(contextt: context, loaderState: data.orderViewLoader),
        ],
      );
    });
  }

  serviceDetailsListTile(width, hight, title, icon, subtitle,
      {Function onClick}) {
    return ListTile(
        onTap: () {
          if (onClick != null) onClick();
        },
        tileColor: Colors.redAccent,
        leading: Icon(
          icon,
          size: width * 0.045,
        ),
        title: TextWid(
          text: title,
          size: width * 0.045,
          weight: FontWeight.w600,
          color: Colors.grey[900],
          lSpace: 1.5,
        ),
        subtitle: TextWid(
          text: subtitle,
          size: width * 0.04,
          flow: TextOverflow.visible,
          weight: FontWeight.w600,
          color: Colors.grey[600],
          lSpace: 1,
        ),
        trailing: Container(
          width: width * 0.07,
        ));
  }

  mediaView(hight, width, images) {
    return Container(
      // height: hight * 0.22,
      color: Colors.white,
      padding: EdgeInsets.only(bottom: 15),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.only(top: 15, left: 15, right: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextWid(
                  text: 'Media Files :',
                  size: width * 0.055,
                  weight: FontWeight.w600,
                ),
              ],
            ),
          ),
          images.length > 0
              ? Container(
                  height: hight * 0.11,
                  child: ListView.builder(
                      itemCount: images.length,
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (context, index) {
                        return Row(
                          children: [
                            SizedBox(
                              width: width * 0.05,
                            ),
                            Container(
                              child: images[index].contains('jpg')
                                  ? InkWell(
                                      onTap: () {
                                        imageslider(images, hight, width);
                                      },
                                      child: Container(
                                        width: width * 0.11,
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            image: DecorationImage(
                                                image: NetworkImage(
                                                    images[index]))),
                                      ),
                                    )
                                  : images[index].contains('mp4')
                                      ? TextWid(
                                          text: 'Video',
                                        )
                                      : TextWid(text: 'Audio'),
                            ),
                          ],
                        );
                      }),
                )
              : Container(
                  padding: EdgeInsets.only(top: 10),
                  child: TextWid(
                    text: 'No media files found',
                    align: TextAlign.center,
                  ),
                ),
        ],
      ),
    );
  }

  warrentyCard(hight, width) {
    return Container(
      height: hight * 0.2,
      width: width,
      margin: EdgeInsets.only(left: 10, right: 10),
      decoration: BoxDecoration(
          color: Colors.indigo[900],
          border: Border.all(color: Colors.indigo[900]),
          borderRadius: BorderRadius.circular(10)),
      child: Row(
        children: [
          Container(
            // alignment: Alignment.topLeft,
            padding: EdgeInsets.only(top: 15, left: 20, right: 10),
            width: width * 0.5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextWid(
                  text: 'Warranty Card',
                  color: Colors.white,
                  size: width * 0.05,
                  weight: FontWeight.w600,
                ),
                SizedBox(
                  height: hight * 0.02,
                ),
                TextWid(
                  text: 'VALID TILL',
                  color: Colors.indigo[200],
                  size: width * 0.035,
                  weight: FontWeight.w600,
                ),
                TextWid(
                  text: '09 Oct,2021',
                  color: Colors.white,
                  size: width * 0.04,
                  weight: FontWeight.w600,
                ),
                SizedBox(
                  height: hight * 0.045,
                ),
                TextWid(
                  text: 'Claim Warranty >>',
                  color: Colors.white,
                  size: width * 0.045,
                  weight: FontWeight.w600,
                )
              ],
            ),
          ),
          Container(
            width: width * 0.3,
            child: SvgPicture.asset('assets/like.svg'),
          )
        ],
      ),
    );
  }

  // rating() {
  //   showDialog(
  //       context: context,
  //       barrierDismissible: true, // set to false if you want to force a rating
  //       builder: (context) {
  //         return RatingDialog(
  //           icon: Icon(
  //             Icons.rate_review,
  //             size: 100,
  //             color: Colors.blue[800],
  //           ),
  //           // const FlutterLogo(
  //           //   size: 100,
  //           // ), // set your own image/icon widget
  //           title: "Rate Your Technician!",
  //           description: "Express Your Experience By Tapping \nOn Stars",
  //           submitButton: "SUBMIT",
  //           alternativeButton: "Contact us instead?", // optional
  //           positiveComment: "We are so happy to hear :)", // optional
  //           negativeComment: "We're sad to hear :(", // optional
  //           accentColor: Colors.blue[800], // optional
  //           onSubmitPressed: (int rating) {
  //             print("onSubmitPressed: rating = $rating");
  //           },
  //           onAlternativePressed: () {
  //             print("onAlternativePressed: do something");
  //           },
  //         );
  //       });
  // }

  imageslider(List<String> images, double hight, double width) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Colors.transparent,
            insetPadding: EdgeInsets.zero,
            contentPadding: EdgeInsets.zero,
            clipBehavior: Clip.antiAliasWithSaveLayer,
            actions: [
              Container(
                  height: hight * 0.35,
                  width: width * 1,
                  child: CarouselSlider.builder(
                    itemCount: images.length,
                    itemBuilder: (ctx, index, realIdx) {
                      return Container(
                          child: Image.network(images[index]
                              .substring(0, images[index].length - 1)));
                    },
                    options: CarouselOptions(
                      autoPlayInterval: Duration(seconds: 3),
                      autoPlayAnimationDuration: Duration(milliseconds: 800),
                      autoPlay: false,
                      aspectRatio: 2.0,
                      enlargeCenterPage: true,
                    ),
                  ))
            ],
          );
        });
  }
}

userDetails(hight, width, BuildContext context, controller, orderDetails,
    chatWithPatner) {
  return Container(
    height: hight * 0.24,
    child: Column(
      children: [
        Container(
            padding: EdgeInsets.only(left: 30, right: 30, top: 30),
            child: Row(
              // mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ProfilePic(
                  profile: orderDetails['uDetails']['pic'],
                  name: orderDetails['uDetails']['name'],
                  size: hight * 0.05,
                ),
                SizedBox(
                  width: width * 0.07,
                ),
                Container(
                  height: hight * 0.11,
                  width: width * 0.5,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        children: [
                          Row(
                            children: [
                              TextWid(
                                text: toBeginningOfSentenceCase(
                                  orderDetails['uDetails']['name'] ?? 'Unknown',
                                ),
                                size: width * 0.04,
                                weight: FontWeight.w600,
                                color: Colors.grey[900],
                              )
                            ],
                          ),
                          Container(
                            child: Row(
                              // mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                TextWid(
                                  text: '123456789',
                                  size: width * 0.025,
                                  weight: FontWeight.w600,
                                  color: Colors.grey[700],
                                ),
                                TextWid(
                                  // text: pDetails['rate'][0].toString(),
                                  text: '4.5',
                                  size: width * 0.025,
                                  weight: FontWeight.w600,
                                  color: Colors.grey[700],
                                ),
                                Icon(
                                  Icons.star,
                                  color: Colors.amber,
                                  size: width * 0.025,
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                      Container(
                        child: Row(
                          children: [
                            Text(
                              'Telugu | ',
                              style: fonts(width * 0.03, FontWeight.w600,
                                  Colors.grey[900]),
                            ),
                            Text(
                              'English | ',
                              style: fonts(width * 0.03, FontWeight.w600,
                                  Colors.grey[900]),
                            ),
                            Text(
                              'Hindi',
                              style: fonts(width * 0.03, FontWeight.w600,
                                  Colors.grey[900]),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: width * 0.45,
                        child: Row(
                          children: [
                            Icon(
                              Icons.location_pin,
                              size: width * 0.03,
                            ),
                            Text(
                              'Vizag',
                              style: fonts(width * 0.03, FontWeight.w600,
                                  Colors.grey[900]),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )
              ],
            )),
        SizedBox(
          height: hight * 0.01,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            InkWell(
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => MyCalling(
                          ordId: orderDetails['ordId'].toString(),
                          uId: orderDetails['uDetails']['uId'],
                          pId: myPid,
                          isIncoming: false,
                          name: orderDetails['uDetails']['name'].toString(),
                          profile: orderDetails['uDetails']['pic'].toString(),
                          userDeviceToken: orderDetails['uDetails']
                                  ['userDeviceToken']
                              .toString(),
                        )));
              },
              child: Row(
                children: [
                  CircleAvatar(
                    radius: width * 0.06,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.call,
                      color: Colors.grey[900],
                      size: width * 0.05,
                    ),
                  ),
                  SizedBox(
                    height: hight * 0.01,
                  ),
                  TextWid(
                    text: 'Call',
                    size: width * 0.04,
                    weight: FontWeight.w600,
                    color: Colors.grey[900],
                  ),
                ],
              ),
            ),
            InkWell(
              onTap: () {
                chatWithPatner(orderDetails);
              },
              child: Row(
                children: [
                  CircleAvatar(
                    radius: width * 0.06,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.chat_bubble,
                      color: Colors.grey[900],
                      size: width * 0.05,
                    ),
                  ),
                  SizedBox(
                    height: hight * 0.01,
                  ),
                  TextWid(
                    text: 'Message',
                    size: width * 0.04,
                    weight: FontWeight.w600,
                    color: Colors.grey[900],
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

enum _TimelineStatus { request, accept, started, completed, feedback }

const kTileHeight = 90.0;

class _Timeline2 extends StatelessWidget {
  final BuildContext contextt;
  final dynamic orderData;
  _Timeline2(this.contextt, {@required this.orderData});
  isServiceStarted() {
    int schedule = orderData['schedule'].runtimeType == String
        ? int.parse(orderData['schedule'])
        : orderData['schedule'];
    int presentTimestamp = DateTime.now().millisecondsSinceEpoch;
    if (schedule < presentTimestamp) return true;
    if (orderData['orderState'] > 8) return true;
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final _width = MediaQuery.of(contextt).size.width;
    final data = _TimelineStatus.values;
    return Flexible(
      child: Timeline.tileBuilder(
        theme: TimelineThemeData(
          nodePosition: 0,
          connectorTheme: ConnectorThemeData(
            thickness: 3.0,
            space: 20,
            color: Color(0xffd3d3d3),
          ),
          indicatorTheme: IndicatorThemeData(
            size: _width * 0.06,
          ),
        ),
        // padding: EdgeInsets.symmetric(vertical: 5.0),
        builder: TimelineTileBuilder.connected(
          contentsBuilder: (_, index) {
            return TimeLineTitle(
                index, contextt, orderData['orderState'], isServiceStarted());
          },
          connectorBuilder: (_, index, connectorType) {
            var solidLineConnector = SolidLineConnector(
              color: Colors.indigo[700],
              indent: connectorType == ConnectorType.start ? 0 : 2.0,
              endIndent: connectorType == ConnectorType.end ? 0 : 2.0,
            );
            var solidLineConnectorEmpty = SolidLineConnector(
              indent: connectorType == ConnectorType.start ? 0 : 2.0,
              endIndent: connectorType == ConnectorType.end ? 0 : 2.0,
            );
            switch (index) {
              case 0:
                return solidLineConnector;
                break;
              case 1:
                if (orderData['orderState'] > 7) return solidLineConnector;
                return solidLineConnectorEmpty;
              case 2:
                if (orderData['orderState'] > 8) return solidLineConnector;
                return solidLineConnectorEmpty;
              case 3:
                if (orderData['orderState'] > 9) return solidLineConnector;
                return solidLineConnectorEmpty;
              default:
                return solidLineConnectorEmpty;
            }
          },
          indicatorBuilder: (_, index) {
            switch (data[index]) {
              case _TimelineStatus.request:
                return DotIndicator(
                  color: Colors.indigo[900],
                  child: Icon(
                    Icons.work_rounded,
                    color: Colors.grey[300],
                    size: _width * 0.035,
                  ),
                );
              case _TimelineStatus.accept:
                return DotIndicator(
                  color: Colors.indigo[900],
                  child: Icon(
                    Icons.how_to_reg_rounded,
                    size: _width * 0.035,
                    color: Colors.grey[300],
                  ),
                );
              case _TimelineStatus.started:
                return DotIndicator(
                  color: isServiceStarted() ? Colors.indigo[900] : Colors.grey,
                  child: Icon(
                    Icons.build,
                    size: _width * 0.035,
                    color: Colors.grey[300],
                  ),
                );
              case _TimelineStatus.completed:
                return DotIndicator(
                  color: orderData['orderState'] > 8
                      ? Colors.indigo[900]
                      : Colors.grey,
                  child: Icon(
                    Icons.verified_rounded,
                    size: _width * 0.035,
                    color: Colors.grey[300],
                  ),
                );
              case _TimelineStatus.feedback:
                return DotIndicator(
                  color: orderData['orderState'] > 9
                      ? Colors.indigo[900]
                      : Colors.grey,
                  child: Icon(
                    Icons.reviews,
                    size: _width * 0.035,
                    color: Colors.grey[300],
                  ),
                );
              default:
                return DotIndicator(
                  color: Colors.indigo[900],
                  child: Icon(
                    Icons.verified_rounded,
                    size: _width * 0.035,
                    color: Colors.white,
                  ),
                );
            }
          },
          itemExtentBuilder: (_, __) => kTileHeight,
          itemCount: data.length,
        ),
      ),
    );
  }
}

class TimeLineTitle extends StatelessWidget {
  final int index;
  final BuildContext contextt;
  final int orderState;
  final bool orderStarted;
  TimeLineTitle(this.index, this.contextt, this.orderState, this.orderStarted);
  getStatus() {
    switch (index) {
      case 0:
        return "Service Requested";
      case 1:
        return "Order Accepted";
      case 2:
        return "Service Started";
      case 3:
        return "Service Completed";
      case 4:
        return "Feedback";
      default:
        return "Something Went wrong";
        break;
    }
  }

  isCompleted() {
    if (index < 2) return true;
    switch (index) {
      case 2:
        if (orderStarted) return true;
        return false;
      case 3:
        if (orderState > 8) return true;
        return false;
      case 4:
        if (orderState > 9) return true;
        return false;
        break;
      default:
        return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final _width = MediaQuery.of(contextt).size.width;
    return Container(
        padding: EdgeInsets.only(left: _width * 0.03),
        child: TextWid(
          text: getStatus(),
          size: _width * 0.04,
          weight: FontWeight.w600,
          color: isCompleted() ? Colors.grey[850] : Colors.grey[600],
        ));
  }
}