import 'package:flutter/services.dart';
import 'package:flutterwhatsapp/controllers/size_config.dart';
import 'package:flutterwhatsapp/pages/intl_phone.dart';
import 'package:flutterwhatsapp/services/auth_service.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:flutterwhatsapp/widgets.dart';

// ignore: must_be_immutable
class LoginPage extends StatefulWidget {
  final bool obscureText;
  final TextAlign textAlign;
  final VoidCallback onTap;
  final List<String> countries;
  final String initialValue;
  final String initialCountryCode;
  final bool autoValidate;
  final TextStyle style;
  final bool showDropdownIcon;
  final ValueChanged<PhoneNumber> onChanged;
  final ValueChanged<PhoneNumber> onCountryChanged;
  final FormFieldValidator<String> validator;
  final bool readOnly;
  final FormFieldSetter<PhoneNumber> onSaved;
  final TextEditingController controller;
  final FocusNode focusNode;
  final void Function(String) onSubmitted;
  final TextInputType keyboardType;
  final bool enabled;
  final InputDecoration decoration;
  final List<TextInputFormatter> inputFormatters;
  final Brightness keyboardAppearance;

  final BoxDecoration dropdownDecoration;
  final String searchText;
  final Color countryCodeTextColor;
  final Color dropDownArrowColor;
  final bool autofocus;
  TextInputAction textInputAction;
  LoginPage(
      {Key key,
      this.initialCountryCode,
      this.obscureText = false,
      this.textAlign = TextAlign.left,
      this.onTap,
      this.readOnly = false,
      this.initialValue,
      this.keyboardType = TextInputType.number,
      this.autoValidate = true,
      this.controller,
      this.focusNode,
      this.decoration,
      this.style,
      this.onSubmitted,
      this.validator,
      this.onChanged,
      this.countries,
      this.onCountryChanged,
      this.onSaved,
      this.showDropdownIcon = true,
      this.dropdownDecoration = const BoxDecoration(),
      this.inputFormatters,
      this.enabled = true,
      this.keyboardAppearance = Brightness.light,
      this.searchText = 'Search by Country Name',
      this.countryCodeTextColor,
      this.dropDownArrowColor,
      this.autofocus = false,
      this.textInputAction})
      : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _phoneNumber = TextEditingController();
  bool _isLoading = false;
  GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  dynamic dropdownvalue = 1;
  List<Map<String, dynamic>> _countryList;
  Map<String, dynamic> _selectedCountry;
  List<Map<String, dynamic>> filteredCountries;
  FormFieldValidator<String> validator;

  @override
  void initState() {
    super.initState();
    _countryList = widget.countries == null
        ? countries
        : countries
            .where((country) => widget.countries.contains(country['code']))
            .toList();
    filteredCountries = _countryList;
    _selectedCountry = _countryList.firstWhere(
        (item) => item['code'] == (widget.initialCountryCode ?? 'IN'),
        orElse: () => _countryList.first);

    validator = widget.autoValidate
        ? ((value) => value != null && value.length != 10
            ? 'Invalid Mobile Number'
            : null)
        : widget.validator;
  }

  Future<void> _changeCountry() async {
    filteredCountries = _countryList;
    await showDialog(
      context: context,
      useRootNavigator: false,
      builder: (context) => StatefulBuilder(
        builder: (ctx, setState) => Dialog(
          child: Container(
            padding: EdgeInsets.all(10),
            child: Column(
              children: <Widget>[
                TextField(
                  decoration: InputDecoration(
                    suffixIcon: Icon(Icons.search),
                    labelText: widget.searchText,
                  ),
                  onChanged: (value) {
                    setState(() {
                      filteredCountries = _countryList
                          .where((country) => country['name']
                              .toLowerCase()
                              .contains(value.toLowerCase()))
                          .toList();
                    });
                  },
                ),
                SizedBox(height: 20),
                Expanded(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: filteredCountries.length,
                    itemBuilder: (ctx, index) => Column(
                      children: <Widget>[
                        ListTile(
                          title: Text(
                            filteredCountries[index]['name'],
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                          trailing: Text(
                            '+${filteredCountries[index]['dial_code']}',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                          onTap: () {
                            _selectedCountry = filteredCountries[index];

                            if (widget.onCountryChanged != null) {
                              widget.onCountryChanged(
                                PhoneNumber(
                                  countryISOCode: _selectedCountry['code'],
                                  countryCode:
                                      '+${_selectedCountry['dial_code']}',
                                  number: '',
                                ),
                              );
                            }

                            Navigator.of(context).pop();
                          },
                        ),
                        Divider(thickness: 1),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    SizeConfig().init(context);
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: _isLoading
          ? aAppLoading()
          : Scaffold(
              backgroundColor: Colors.redAccent[100],
              resizeToAvoidBottomInset: false,
              body: SafeArea(
                child: Form(
                  key: _formkey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          color: Colors.red,
                          gradient: LinearGradient(
                            begin: Alignment.bottomLeft,
                            end: Alignment.topRight,
                            colors: [
                              Color(0xff1EE1D72),
                              Color(0xffF14C37),
                            ],
                          ),
                        ),
                        height: 90,
                        width: size.width / 1.5,
                        child: Center(
                          child: Row(
                            children: [
                              Image.asset(
                                "fonts/chaticon.png",
                                height: getProportionateScreenHeight(50),
                                width: getProportionateScreenWidth(50),
                              ),
                              SizedBox(width: 10),
                              Text(
                                "KiyaKonnect",
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: getFontSize(22),
                                    fontFamily: 'Montserrat',
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.fromLTRB(15, 20, 15, 20),
                        child: Text(
                          "Verify your Phone Number",
                          style: TextStyle(
                              fontSize: 20,
                              color: Colors.black,
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          color: Colors.grey[300],
                        ),
                        margin: EdgeInsets.symmetric(horizontal: 10),
                        child: Column(
                          children: [
                            Container(
                              padding: EdgeInsets.fromLTRB(10, 30, 20, 20),
                              child: Row(
                                children: [
                                  Container(
                                    child: _buildFlagsButton(),
                                  ),
                                  Expanded(
                                    child: TextFormField(
                                      validator: validator,
                                      controller: _phoneNumber,
                                      keyboardType: TextInputType.phone,
                                      decoration: InputDecoration(
                                        // border: OutlineInputBorder(
                                        //   borderRadius: BorderRadius.circular(10),
                                        //   borderSide: BorderSide(
                                        //     color: Colors.black,
                                        //     width: 3,
                                        //   ),
                                        // ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(15),
                                          borderSide: BorderSide(
                                            color: Colors.grey,
                                            width: 1,
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(15),
                                          borderSide: BorderSide(
                                            color: Colors.black, //0xffF14C37
                                            width: 1.7,
                                          ),
                                        ),

                                        prefixIconColor: Colors.red,
                                        hintText: "Enter Your Phone Number",
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Container(
                            //   child: Row(
                            //     children: <Widget>[
                            //       _buildFlagsButton(),
                            //       SizedBox(width: 8),
                            //       Expanded(
                            //         child: TextFormField(
                            //           initialValue: widget.initialValue,
                            //           readOnly: widget.readOnly,
                            //           obscureText: widget.obscureText,
                            //           textAlign: widget.textAlign,
                            //           onTap: () {
                            //             if (widget.onTap != null)
                            //               widget.onTap();
                            //           },
                            //           controller: widget.controller,
                            //           focusNode: widget.focusNode,
                            //           onFieldSubmitted: (s) {
                            //             if (widget.onSubmitted != null)
                            //               widget.onSubmitted(s);
                            //           },
                            //           decoration: widget.decoration,
                            //           style: widget.style,
                            //           onSaved: (value) {
                            //             if (widget.onSaved != null)
                            //               widget.onSaved(
                            //                 PhoneNumber(
                            //                   countryISOCode:
                            //                       _selectedCountry['code'],
                            //                   countryCode:
                            //                       '+${_selectedCountry['dial_code']}',
                            //                   number: value,
                            //                 ),
                            //               );
                            //           },
                            //           onChanged: (value) {
                            //             if (widget.onChanged != null)
                            //               widget.onChanged(
                            //                 PhoneNumber(
                            //                   countryISOCode:
                            //                       _selectedCountry['code'],
                            //                   countryCode:
                            //                       '+${_selectedCountry['dial_code']}',
                            //                   number: value,
                            //                 ),
                            //               );
                            //           },
                            //           validator: validator,
                            //           maxLength: _selectedCountry['max_length'],
                            //           keyboardType: widget.keyboardType,
                            //           inputFormatters: widget.inputFormatters,
                            //           enabled: widget.enabled,
                            //           keyboardAppearance:
                            //               widget.keyboardAppearance,
                            //           autofocus: widget.autofocus,
                            //           textInputAction: widget.textInputAction,
                            //         ),
                            //       ),
                            //     ],
                            //   ),
                            // ),
                            Container(
                              padding: EdgeInsets.only(bottom: 10),
                              child: Text(
                                "Send an SMS code to Verify your Number",
                                style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.black,
                                    fontFamily: 'Montserrat',
                                    fontWeight: FontWeight.w600),
                              ),
                            ),
                            GestureDetector(
                                child: Container(
                                  margin: EdgeInsets.only(
                                    left: 30,
                                    right: 30,
                                    bottom: 30,
                                    top: 10,
                                  ),
                                  height: 55,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(15),
                                    ),
                                    // color: Colors.red,
                                    gradient: LinearGradient(
                                      begin: Alignment.bottomLeft,
                                      end: Alignment.topRight,
                                      colors: [
                                        Color(0xff1EE1D72),
                                        Color(0xffF14C37),
                                      ],
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.lock_outlined,
                                        color: Colors.black,
                                      ),
                                      SizedBox(
                                        width: 5,
                                      ),
                                      Text(
                                        'Send Code',
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontFamily: 'Montserrat',
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),
                                onTap: () async {
                                  final phone = _phoneNumber.text.trim();
                                  await context
                                      .read(authenticationServiceProvider)
                                      .signInWithPhone(
                                          phone,
                                          _selectedCountry['dial_code']
                                              .toString(),
                                          context);
                                }),
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.only(top: 20),
                        child: Column(
                          children: [
                            Text(
                              "by Continuing you agree with the",
                              style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[300],
                                  fontFamily: 'Montserrat',
                                  fontWeight: FontWeight.w600),
                            ),
                            Text(
                              "Terms & Conditions • Privacy Policy",
                              style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.red,
                                  fontFamily: 'Montserrat',
                                  fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  DecoratedBox _buildFlagsButton() {
    return DecoratedBox(
      decoration: widget.dropdownDecoration,
      child: InkWell(
        borderRadius: widget.dropdownDecoration.borderRadius as BorderRadius,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              if (widget.showDropdownIcon) ...[
                Icon(
                  Icons.arrow_drop_down,
                  color: widget.dropDownArrowColor,
                ),
                SizedBox(width: 4)
              ],
              // Image.asset(
              //   'assets/flags/${_selectedCountry['code'].toLowerCase()}.png',
              //   width: 32,
              // ),
              SizedBox(width: 8),
              FittedBox(
                child: Text(
                  '+${_selectedCountry['dial_code']}',
                  style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: widget.countryCodeTextColor),
                ),
              ),
              SizedBox(width: 8),
            ],
          ),
        ),
        onTap: _changeCountry,
      ),
    );
  }
}

class PhoneNumber {
  String countryISOCode;
  String countryCode;
  String number;

  PhoneNumber({
    @required this.countryISOCode,
    @required this.countryCode,
    @required this.number,
  });

  String get completeNumber {
    return countryCode + number;
  }
}
