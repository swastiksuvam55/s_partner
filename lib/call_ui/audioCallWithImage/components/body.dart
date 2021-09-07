import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spotmies_partner/call_ui/components/rounded_button.dart';
import 'package:spotmies_partner/providers/chat_provider.dart';

import '../constants.dart';
import '../size.config.dart';

class CallingUi extends StatefulWidget {
  CallingUi(
      {@required this.isInComingScreen,
      this.image = "",
      this.name = "unknown",
      this.onAccept,
      this.onHangUp,
      this.onMic,
      this.onReject,
      this.onSpeaker});
  final bool isInComingScreen;
  final String image;
  final String name;
  final VoidCallback onAccept;
  final VoidCallback onReject;
  final VoidCallback onHangUp;
  final VoidCallback onMic;
  final VoidCallback onSpeaker;

  @override
  _CallingUiState createState() => _CallingUiState();
}

class _CallingUiState extends State<CallingUi> {
  ChatProvider chatProvider;
 String screenType = '';
   callStatus(state) {
    switch (state) {
      case 0:
        return "connecting...";
      case 1:
        return "Calling...";
      case 2:
        return "Ringing...";
      case 3:
        return "Connected";
      case 6:
        return "Terminated....";
        break;
      default:
        return "connecting...";
    }
  }

    changeScreen(screenName) {
    setState(() {
      screenType = screenName;
    });
  }

  
  @override
  initState() {
    setState(() {
      screenType = widget.isInComingScreen ? "incoming" : "outgoing";
    });
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      body: Consumer<ChatProvider>(builder: (context, data, child) {
        return Stack(
          fit: StackFit.expand,
          children: [
            Uri.parse(widget.image).isAbsolute //need to put url validator
                ? Image.network(
                    widget.image,
                    fit: BoxFit.cover,
                  )
                : Image.asset(
                    "assets/images/full_image.png",
                    fit: BoxFit.cover,
                  ),
            DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.name,
                      style: Theme.of(context)
                          .textTheme
                          .headline3
                          .copyWith(color: Colors.white),
                    ),
                    VerticalSpacing(of: 10),
                    Text(
                      screenType == "outgoing"
                          ? "Duration ${data.duration}   ${callStatus(data.getCallStatus)}"
                              .toUpperCase()
                          : "INCOMING CALL.....",
                      style: TextStyle(color: Colors.white60),
                    ),
                    Spacer(),
                    Visibility(
                      visible: screenType == "outgoing",
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          RoundedButton(
                            press: () {
                              widget.onMic();
                            },
                            color: Colors.white,
                            iconColor: Colors.black,
                            iconSrc: "assets/icons/Icon Mic.svg",
                          ),
                          RoundedButton(
                            press: () {
                              widget.onHangUp();
                               Navigator.pop(context);
                            },
                            color: kRedColor,
                            iconColor: Colors.white,
                            iconSrc: "assets/icons/call_end.svg",
                          ),
                          RoundedButton(
                            press: () {
                              widget.onSpeaker();
                            },
                            color: Colors.white,
                            iconColor: Colors.black,
                            iconSrc: "assets/icons/Icon Volume.svg",
                          ),
                        ],
                      ),
                    ),
                    Visibility(
                      visible: screenType == "incoming",
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          RoundedButton(
                            press: () {
                              changeScreen("outgoing");
                              widget.onAccept();
                            },
                            color: Colors.green,
                            iconColor: Colors.white,
                            iconSrc: "assets/icons/call_accept.svg",
                          ),
                          RoundedButton(
                            press: () {
                              widget.onReject();
                              Navigator.pop(context);
                            },
                            color: Colors.red,
                            iconColor: Colors.white,
                            iconSrc: "assets/icons/call_end.svg",
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            )
          ],
        );
      }),
    );
  }
}
