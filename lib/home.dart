import 'package:flutter/material.dart';
import 'package:connectivity/connectivity.dart';
import 'package:http/http.dart' as http;
import 'package:iot/model/model.dart';
import 'package:iot/signin.dart';
import 'dart:convert';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

class Home extends StatefulWidget {
  final String? email;
  const Home({ Key? key ,this.email}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool _LED1 = false;
  bool _LED2 = false;
  bool _LED3 = false;
  bool _LED4 = false;
  String led1 = "Off";
  String led2 = "Off";
  String led3 = "Off";
  String led4 = "Off";
  Timer? _interval;
  final Connectivity _connectivity = Connectivity();
  IoTParameter _ioTParameter = IoTParameter();
  bool Connected = false;
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  Future? _future;

  @override
  void initState(){
    super.initState();
    initConnectivity();
    setUpTimedFetch();
  }

  @override
  void dispose(){
    super.dispose();
    _interval!.cancel();
  }

  setUpTimedFetch() {
    _interval = Timer.periodic(Duration(milliseconds: 5000), (timer) {
      setState(() {
        _future = getWeather();
      });
    });
  }

  Future <String> getUrl() async{
    String url = 'http://104.198.132.47:8080/getData?email=';
    SharedPreferences preferences = await _prefs;
    String? emailprefs = await preferences.getString('email');
    url += emailprefs!;
    return url;
  }

  Future<void> SignOut() async{
    SharedPreferences preferences = await _prefs;
    await preferences.remove('email');
  }

  Future<void> DOControl(bool ch1,bool ch2,bool ch3,bool ch4) async{
    SharedPreferences preferences = await _prefs;
    String url = 'http://104.198.132.47:8080/DoControl?email=';
    url += await preferences.getString('email')!;
    url += '&DO1=$ch1&DO2=$ch2&DO3=$ch3&DO4=$ch4';
    print(url);
    final response = await http.get(Uri.parse(
      url)
    );

  }

  Future <IoTParameter> getWeather() async{   
    final String url = await getUrl();
    print(url);
    final response = await http.get(Uri.parse(
      url)
    );
    if(response.statusCode == 200){
      var json = jsonDecode(response.body);
      _ioTParameter = IoTParameter.fromJson(json);
    }
    print(_ioTParameter.temp);
    print(_ioTParameter.humidity);
    return _ioTParameter;
  }

  Future<String> initConnectivity() async {
    ConnectivityResult result = ConnectivityResult.none;
     try {
      result = await _connectivity.checkConnectivity();
    } catch (e) {
      print(e.toString());
    }
    if (!mounted) {
      return Future.value(null);
    }

    return _updateConnectionStatus(result);
  }

  Future<String> _updateConnectionStatus(ConnectivityResult result) async {
    switch (result) {
      case ConnectivityResult.wifi:
      case ConnectivityResult.mobile:
        setState(() {
          Connected = true;
        });
        return 'Connected';
        break;
      case ConnectivityResult.none:
        setState(() {
          Connected = false;
        });
        return 'Lost Connect';
        break;
      default:
        setState(() {
          Connected = false;
        });
        return 'Failed to get connectivity.';
        break;
    }
  }

  Widget AfterConnect(double Width,double Height){
    return FutureBuilder(
      future: _future,
      builder: (context,snapshot){
        return Container(
          width: Width,
          height: Height,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                SizedBox(
                  height: Height/45,
                ),
                Text('Weather Monitoring',style: TextStyle(fontSize: 20),),
                SizedBox(height: Height/45,),
                Wrap(
                  spacing: Width*0.02,
                  children: [
                    Container(
                      height: Height*0.15,
                      width: Width*0.42,
                      decoration: BoxDecoration(
                        color: Color(0xFF3E54D3),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(Width/30),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Temperature(°C)",style: TextStyle(fontSize: 16),),
                            Expanded(child: SizedBox(height: Height/1000,)),
                            Row(
                              children: [
                                Image.asset('img/temperature.png',width: 30,),
                                Expanded(child: SizedBox(width: Width/1000,)),
                                Text((_ioTParameter.temp == null)?"0.0":_ioTParameter.temp!,style: TextStyle(fontSize: 24),),
                              ],
                            )
                           ],
                        ),
                      ),
                    ),
                    Container(
                      height: Height*0.15,
                      width: Width*0.42,
                      decoration: BoxDecoration(            
                        color: Color(0xFF4F80E2),
                        borderRadius: BorderRadius.circular(8.0)
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(Width/30),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Humidity(%)",style: TextStyle(fontSize: 16),),
                            Expanded(child: SizedBox(height: Height/1000,)),
                            Row(
                              children: [
                                Image.asset('img/humidity.png',width: 30,),
                                Expanded(child: SizedBox(width: Width/1000,)),
                                Text((_ioTParameter.humidity == null)?"0.0":_ioTParameter.humidity!,style: TextStyle(fontSize: 24),),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: Height/30,),
                Text('LED Controls',style: TextStyle(fontSize: 20),),
                SizedBox(height: Height/30,),
                SwitchListTile(
                  title: Text('Status LED1'),
                  subtitle: Text("$led1"),
                  value: _LED1,
                  onChanged: (bool value){
                    setState(() {
                      _LED1 = value;
                      DOControl(_LED1,_LED2,_LED3,_LED4);
                      if(value == true){
                        led1 = "On";
                      }
                      else{
                        led1 = "Off";
                      }
                    });
                  },
                  secondary: Container(
                    width: 60.0,
                    height: 40.0,
                    decoration: BoxDecoration(
                      color: Color(0xFF5F236B),
                      borderRadius: BorderRadius.circular(4.0)
                    ),
                    child: Icon(Icons.lightbulb_outline),
                  ),
                ),
                SizedBox(height: Height/30,),
                SwitchListTile(
                  title: Text('Status LED2'),
                  subtitle: Text("$led2"),
                  value: _LED2,
                  onChanged: (bool value){
                    setState(() {
                      _LED2 = value;
                      DOControl(_LED1,_LED2,_LED3,_LED4);
                      if(value == true){
                        led2 = "On";
                      }
                      else{
                        led2 = "Off";
                      }
                    });
                  },
                  secondary: Container(
                    width: 60.0,
                    height: 40.0,
                    decoration: BoxDecoration(
                      color: Color(0xFFBE375F),
                      borderRadius: BorderRadius.circular(4.0)
                    ),
                    child: Icon(Icons.lightbulb_outline),
                  ),
                ),
                SizedBox(height: Height/30,),
                SwitchListTile(
                  title: Text('Status LED3'),
                  subtitle: Text("$led3"),
                  value: _LED3,
                  onChanged: (bool value){
                    setState(() {
                      _LED3 = value;
                      DOControl(_LED1,_LED2,_LED3,_LED4);
                      if(value == true){
                        led3 = "On";
                      }
                      else{
                        led3 = "Off";
                      }
                    });
                  },
                  secondary: Container(
                    width: 60.0,
                    height: 40.0,
                    decoration: BoxDecoration(
                      color: Color(0xFFED8554),
                      borderRadius: BorderRadius.circular(4.0)
                    ),
                    child: Icon(Icons.lightbulb_outline),
                  ),
                ),
                SizedBox(height: Height/30,),
                SwitchListTile(
                  title: Text('Status LED4'),
                  subtitle: Text("$led4"),
                  value: _LED4,
                  onChanged: (bool value){
                    setState(() {
                      _LED4 = value;
                      DOControl(_LED1,_LED2,_LED3,_LED4);
                      if(value == true){
                        led4 = "On";
                      }
                      else{
                        led4 = "Off";
                      }
                    });
                  },
                  secondary: Container(
                    width: 60.0,
                    height: 40.0,
                    decoration: BoxDecoration(
                      color: Colors.amber,
                      borderRadius: BorderRadius.circular(4.0)
                    ),
                    child: Icon(Icons.lightbulb_outline),
                  ),
                )
            ],
          ),
        );
      }
    );
  }
  

  @override
  Widget build(BuildContext context) {
    final Width = MediaQuery.of(context).size.width;
    final Height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        actionsIconTheme: IconThemeData(
          color: Colors.white
        ),
        title: Text('IoT Demo'),
        actions: [
          IconButton(onPressed: (){
            SignOut();
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (BuildContext context)=>SignIn()),
              (route) => false);
          }, 
          icon: Icon(Icons.exit_to_app))
        ],
      ),
      drawer: Drawer(
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              decoration: BoxDecoration(
                color: Colors.orangeAccent
              ),
              accountEmail: Text('${widget.email}',style: TextStyle(color: Colors.white),),
              accountName: null,
              currentAccountPicture: null,
            ),
            ListTile(
              leading: Icon(Icons.home),
              title: Text('Home'),
              onTap: (){
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.bar_chart),
              title: Text('Chart (Coming soon...)'),
            )
          ],
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: Width/15,vertical: Height/60),
        child: ListView(
          scrollDirection: Axis.vertical,
          children: [
            Card(
              child: ListTile(
                title: Text('Internet Connection'),
                trailing: CircleAvatar(
                  backgroundColor: Connected ?(Color(0xFF00D100)):(Colors.red),
                  maxRadius: 8.0,
                )
              ),
            ),
            FutureBuilder(
              future: initConnectivity(),
              builder: (BuildContext context,AsyncSnapshot snapshot){
                if(snapshot.hasData){
                  switch(snapshot.data){
                    case ("Connected"):
                      return AfterConnect(Width, Height);
                    case ("Lost Connect"):
                      return Container(
                        width: Width,
                        height: Height*0.8,
                        child: Center(
                          child: Column(
                            children: [
                              CircularProgressIndicator(
                                color: Colors.greenAccent,
                              ),
                              SizedBox(height: Height*0.02,),
                              Text('Please Connect Your Internet',style: TextStyle(fontSize: 16),)
                            ],
                          ),
                        )
                      );
                    default:
                      return CircularProgressIndicator();
                  }
                }
                else{
                  return CircularProgressIndicator();
                }
              }
            ),
          ],
        ),
      ),
    );
  }
}