import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.bottom]);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
   FocusNode? focusNode;

  TextEditingController customerNameController  = TextEditingController();
  TextEditingController bookNumberController = TextEditingController();

   late SharedPreferences sharedPreferences;

  bool isVip = false;
  var bookMoney = 0;
  var customerNumber = 0;
  var vipCustomerNumber  = 0;
  var totalMoney = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          child: Column(
            children: [
              textWidget(text: 'Chương trình bán sách online', weightBox: MediaQuery.of(context).size.width, colorText: Colors.white, colorBox: Colors.green, textAlign: TextAlign.center),
              textWidget(text: 'Thông tin hóa đơn',
                  weightBox: MediaQuery.of(context).size.width,
                  colorText: Colors.black,
                  colorBox: Colors.green, textAlign: TextAlign.left),
              textAndTextFieldWidget(text: "Tên Khách Hàng : ",
                  textController: customerNameController,
                  hintText: "Tên khách hàng",
                  keyboardType: TextInputType.text,
                  focusNode: focusNode),
              textAndTextFieldWidget(text: "Số Lượng Sách : ",
                  textController: bookNumberController,
                  hintText: "Số lượng sách",
                  keyboardType: TextInputType.number,
                  focusNode: focusNode),
              vipCheckBox(),
              textAndTextWidget(
                  titleText: "Thành Tiền : ",
                  contentText: bookMoney.toDouble().toString(),
                  textContentBoxColor: Colors.black26,
                  alignContentText: TextAlign.center),
              buttons(buttonText1: 'Tính TT', buttonText2: 'Tiếp', buttonText3: 'Thống kê',

                  buttonFunction1: (){
                setState(() {
                  bookMoney =  Payment();
                });

              }, buttonFunction2: (){
                if(customerNameController.text != "" ){
                  customerNumber++;
                  if(isVip){
                    vipCustomerNumber++;
                    totalMoney += bookMoney;
                  }
                }
                customerNameController.text = "";
                bookNumberController.text = "";
                setInforToDatabase(customer_total: customerNumber, vip_customer: vipCustomerNumber, total_money: totalMoney);
                  }
                , buttonFunction3: (){
                setState(() {
                  customerNumber = customerNumber;
                  vipCustomerNumber = vipCustomerNumber;
                  totalMoney = totalMoney;
                });
                  }),
              textWidget(text: 'Thông tin thống kê', colorText: Colors.white, colorBox: Colors.green, textAlign: TextAlign.left, weightBox: MediaQuery.of(context).size.width),
              textAndTextWidget(
                  titleText: "Tổng số KH : ",
                  contentText: customerNumber.toString(),
                  textContentBoxColor: Colors.transparent,
                  alignContentText: TextAlign.left
              ),
              textAndTextWidget(
                  titleText: "Tổng số KH là VIP : ",
                  contentText: vipCustomerNumber.toString(),
                  textContentBoxColor: Colors.transparent,
                  alignContentText: TextAlign.left
              ),
              textAndTextWidget(
                  titleText: "Tổng doanh thu : ",
                  contentText: totalMoney.toString(),
                  textContentBoxColor: Colors.transparent,
                  alignContentText: TextAlign.left
              ),
              Container(
                height: 30,
                width: MediaQuery.of(context).size.width,
                color: Colors.green,
              ),

              logOut(),
            ]
          )
        ),
      ),
    );
  }
   clearSharedPreference() async{
    sharedPreferences  = await SharedPreferences.getInstance();
    sharedPreferences.clear();
   }

    setInforToDatabase({@required customer_total,@required vip_customer, @required total_money }) async {
      sharedPreferences = await SharedPreferences.getInstance();
      await sharedPreferences.setInt('customer_total', customer_total);
      await sharedPreferences.setInt('vip_customer', vip_customer);
      await sharedPreferences.setInt('money_total', total_money);
    }

    getInforFromDatabase() async {
      sharedPreferences = await SharedPreferences.getInstance();
      customerNumber = sharedPreferences.getInt('customer_total') ?? 0;
      vipCustomerNumber = sharedPreferences.getInt('vip_customer') ?? 0;
      totalMoney = sharedPreferences.getInt('money_total') ?? 0;
    }

   Payment(){
    if(isVip) {
      return (int.parse(
          bookNumberController.text != "" ? bookNumberController.text : "0"  ) *
          20000 * 0.9).toInt();
    }else{
      return (int.parse(
          bookNumberController.text != "" ? bookNumberController.text : "0") *
          20000).toInt(); //giá sách thường
    }
  }


  logOut(){
    return Container(
      margin: const EdgeInsets.only(top: 10 ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            margin: const EdgeInsets.only(right: 10),
            child: IconButton(
              icon: const Icon(Icons.exit_to_app),
              onPressed: (){
                _showMyDialog();
                print("Log out");
              },
            ),
          )
        ],
      ),
    );
  }

  Future<void> _showMyDialog() async{
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Thông báo'),
          content: SingleChildScrollView(
            child: ListBody(
              children: const <Widget>[
                Text('Bạn có chắc chắn muốn thoát khỏi ứng dụng ?'),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: const Text('Không'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: const Text('Có'),
              onPressed: () {
                clearSharedPreference();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

Widget textWidget({@required text, @required colorText, @required colorBox, @required textAlign, @required weightBox, marginBox}){
  return Container(
    margin: marginBox,
    width: weightBox,
    padding: const EdgeInsets.only(left: 5, top: 5, bottom: 5),
    decoration: BoxDecoration(
      color: colorBox,
    ),
    child: Text(text, textAlign: textAlign,
        style: TextStyle(color: colorText)),
  );
}


Widget textAndTextFieldWidget({@required text, @required textController, @required hintText, @required keyboardType , focusNode}){
  return Container(
    padding: const EdgeInsets.all(10),
    child: Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(text),
        ),
        Expanded(
            flex: 3,
            child: TextField(
                controller: textController,
                keyboardType: keyboardType,
                decoration: InputDecoration(
                  hintText: hintText,
                )
            ))
      ],
    ),
  );
}

vipCheckBox(){
  return Container(
    child: Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Container(),
        ),
        Expanded(
            flex: 3,
            child: CheckboxListTile(
              title: const Text('Khách hàng VIP'),
              value: isVip,
              onChanged: (newValue) {
                setState(() {
                  isVip = newValue!;
                });
              },
      controlAffinity: ListTileControlAffinity.leading,
            ))
      ],
    ),
  );
}
   Widget textAndTextWidget({@required titleText, @required contentText, @required textContentBoxColor, @required alignContentText  })
   {
     return Container(
       padding: const EdgeInsets.only(top: 10, bottom: 10),
       child: Row(
         children: [
           Expanded(
             flex: 2,
             child: Text(titleText),
           ),
           Expanded(
               flex: 3,
               child: Container(
                 padding: const EdgeInsets.only(top: 5, bottom: 5),
                 color: textContentBoxColor,
                 child: Text(contentText,
                   textAlign: alignContentText,
                 ),
               )
           )
         ],
       ),
     );
   }

   buttons(
       {@required buttonText1,
        @required buttonText2,
        @required buttonText3,
        @required buttonFunction1,
        @required buttonFunction2,
        @required buttonFunction3 }) {
     return Container(
       margin: const EdgeInsets.only(right: 5, left: 5, bottom: 10),
       child: Row(
         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
         children: [
            Expanded(
              flex: 1,
                child: GestureDetector(
              onTap: buttonFunction1,
              child: Container(
                padding: const EdgeInsets.only( left: 20, top: 10, bottom: 10),
                color: Colors.grey,
                child: Text(buttonText1, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold),),
              ),
            )),
           Expanded(
               flex: 1,
               child: GestureDetector(

             onTap: buttonFunction2,
             child: Container(
               padding: const EdgeInsets.only( left: 20, top: 10, bottom: 10),
               color: Colors.grey,
               child: Text(buttonText2, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold),),
             ),
                )),
           Expanded(
               flex: 1,
               child: GestureDetector(
             onTap: buttonFunction3,
             child: Container(
               padding: const EdgeInsets.all(10),
               color: Colors.grey,
               child: Text(buttonText3, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold),),
             ),
           )),
         ],
       ),
     );
   }
}