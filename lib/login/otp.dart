import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:provider/provider.dart';
import 'package:spotmies_partner/controllers/login_controller.dart';
import 'package:spotmies_partner/providers/partnerDetailsProvider.dart';
import 'package:spotmies_partner/providers/theme_provider.dart';
import 'package:spotmies_partner/providers/timer_provider.dart';
import 'package:spotmies_partner/reusable_widgets/elevatedButtonWidget.dart';
import 'package:spotmies_partner/reusable_widgets/progress_waiter.dart';
import 'package:spotmies_partner/reusable_widgets/text_wid.dart';
import 'package:pinput/pinput.dart';
import 'package:spotmies_partner/utilities/app_config.dart';

class OTPScreen extends StatefulWidget {
  final String phone;
  final String verificationId;
  OTPScreen(this.phone, this.verificationId);
  @override
  _OTPScreenState createState() => _OTPScreenState();
}

class _OTPScreenState extends StateMVC<OTPScreen> {
  LoginPageController? _loginPageController = LoginPageController();
  // _OTPScreenState() : super(LoginPageController()) {
  //   this._loginPageController = controller;
  // }

  TimeProvider? timerProvider;
  PartnerDetailsProvider? partnerProvider;
  Timer? _timer;
  int? pinlength;

  final TextEditingController _pinPutController = TextEditingController();
  final FocusNode _pinPutFocusNode = FocusNode();
  final BoxDecoration pinPutDecoration = BoxDecoration(
    color: SpotmiesTheme.primaryVariant,
    borderRadius: BorderRadius.circular(10.0),
    border: Border.all(
      color: SpotmiesTheme.background,
    ),
  );
  startTimer() {
    _timer = new Timer.periodic(Duration(seconds: 1), (timer) {
      timerProvider!.updateTime();
      if (timerProvider!.countDown < 2) timer.cancel();
    });
  }

  @override
  void initState() {
    _timer?.cancel();
    timerProvider = Provider.of<TimeProvider>(context, listen: false);
    partnerProvider =
        Provider.of<PartnerDetailsProvider>(context, listen: false);

    super.initState();
    startTimer();
  }

  @override
  void dispose() {
    _timer!.cancel();
    super.dispose();
  }

  void resendOtp() {
    timerProvider!.resetTimer();
    // _verifyPhone();

    _loginPageController!.verifyPhone(context, timerProvider!, partnerProvider!,
        navigate: false);
    startTimer();
  }

  @override
  Widget build(BuildContext context) {
    final _hight = MediaQuery.of(context).size.height -
        MediaQuery.of(context).padding.top -
        kToolbarHeight;
    final _width = MediaQuery.of(context).size.width;
    // startTimer();
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: SpotmiesTheme.background,
      key: _loginPageController!.scaffoldkey,
      body: Consumer<TimeProvider>(builder: (context, data, child) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Stack(children: [
              AbsorbPointer(
                absorbing: data.getLoader,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Container(
                      height: _hight * 0.5,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.greenAccent[400],
                            radius: 50,
                            child: Center(
                                child: Icon(
                              Icons.security,
                              color: Colors.white,
                              size: 40,
                            )),
                          ),
                          SizedBox(
                            height: _hight * 0.06,
                          ),
                          Container(
                            width: _width,
                            child: TextWid(
                              text: 'Verification',
                              weight: FontWeight.bold,
                              align: TextAlign.center,
                              size: _width * 0.075,
                              color: SpotmiesTheme.primary,
                            ),
                          ),
                          SizedBox(
                            height: _hight * 0.02,
                          ),
                          Container(
                            width: _width,
                            child: TextWid(
                              text: 'You will get an OTP via SMS',
                              weight: FontWeight.bold,
                              align: TextAlign.center,
                              size: _width * 0.04,
                              color: SpotmiesTheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      height: _hight * 0.24,
                      child: Column(
                        children: [
                          Container(
                            padding: EdgeInsets.only(left: _width * 0.04),
                            width: _width,
                            child: TextWid(
                              text:
                                  'Please enter the one-time password sent to your phone number +91-${widget.phone} to verify your account',
                              weight: FontWeight.bold,
                              align: TextAlign.center,
                              flow: TextOverflow.visible,
                              size: _width * 0.04,
                              color: Colors.blueGrey[200]!,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: Pinput(
                              inputFormatters: <TextInputFormatter>[
                                FilteringTextInputFormatter.allow(
                                    RegExp(r'[0-9]')),
                              ],
                              length: 6,
                              defaultPinTheme: PinTheme(
                                width: 48,
                                height: 60,
                                textStyle: fonts(height(context) * 0.02,
                                    FontWeight.bold, Colors.black),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                      width: 2, color: Colors.grey.shade600),
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(8)),
                                ),
                              ),
                              // textStyle: fonts(_width * 0.045, FontWeight.w600,
                              //     SpotmiesTheme.primary),
                              // eachFieldWidth: _width * 0.1,
                              // eachFieldHeight: _hight * 0.08,
                              focusNode: _pinPutFocusNode,
                              controller: _pinPutController,
                              // decoration: pinPutDecoration,
                              // decoration: pinPutDecoration,
                              // decoration: pinPutDecoration,
                              pinAnimationType: PinAnimationType.fade,
                              onChanged: (pin) {
                                data.setOtp(pin.toString());
                              },
                              onCompleted: (pin) {
                                _loginPageController!.loginUserWithOtp(pin,
                                    context, partnerProvider!, timerProvider!);
                                setState(() {
                                  pinlength = pin.length;
                                });
                              },
                              onSubmitted: (pin) {
                                _loginPageController!.loginUserWithOtp(pin,
                                    context, partnerProvider!, timerProvider!);
                                setState(() {
                                  pinlength = pin.length;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (pinlength == 6 && data.countDown > 2)
                      SizedBox(
                        height: _hight * 0.25,
                      ),
                    if (pinlength != 6)
                      data.countDown > 1
                          ? Container(
                              height: _hight * 0.3,
                              child: CircularPercentIndicator(
                                  radius: width(context) * 0.075,
                                  lineWidth: 1.5,
                                  animation: true,
                                  animationDuration: 99999,
                                  progressColor: SpotmiesTheme.primaryVariant,
                                  percent: 1.0,
                                  backgroundColor: SpotmiesTheme.primary,
                                  center: Text(
                                    '${data.countDown}',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: width(context) * 0.04,
                                        color: SpotmiesTheme.primary),
                                  )),
                            )
                          : Container(
                              width: _width * 0.45,
                              child: ElevatedButtonWidget(
                                onClick: resendOtp,
                                height: _hight * 0.07,
                                minWidth: _width * 0.045,
                                buttonName: "Resend OTP?",
                                bgColor: Colors.transparent,
                                borderSideColor: Colors.transparent,
                                textSize: _width * 0.037,
                                textColor: SpotmiesTheme.primary,
                              ),
                            ),
                    if (pinlength == 6)
                      Container(
                        padding: EdgeInsets.only(
                            top: data.countDown > 2 ? 0 : _hight * 0.15),
                        child: ElevatedButtonWidget(
                          onClick: () {
                            _loginPageController!.loginUserWithOtp(data.getOtp,
                                context, partnerProvider!, timerProvider!);
                          },
                          height: _hight * 0.06,
                          textStyle: FontWeight.w600,
                          minWidth: _width * 0.45,
                          buttonName: "Submit",
                          bgColor: SpotmiesTheme.background,
                          borderSideColor: Colors.transparent,
                          textSize: _width * 0.045,
                          borderRadius: 10,
                          elevation: 1,
                          textColor: SpotmiesTheme.primary,
                          trailingIcon: Icon(
                            Icons.arrow_forward,
                            size: 20,
                            color: SpotmiesTheme.tertiary,
                          ),
                        ),
                      )
                  ],
                ),
              ),
              ProgressWaiter(
                contextt: context,
                loaderState: data.getLoader,
                loadingName: data.getLoading,
              ),
            ]),
          ],
        );
      }),
    );
  }
}
