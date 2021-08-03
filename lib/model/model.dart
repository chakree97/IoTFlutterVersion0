class Message{
  final String? message;
  Message({this.message});

  factory Message.fromJson(Map<String,dynamic> json){
    return Message(
      message: json['message']
    );
  }
}

class IoTParameter{
  final String? temp;
  final String? humidity;
  IoTParameter({this.temp,this.humidity});

  factory IoTParameter.fromJson(Map<String,dynamic> json){
    return IoTParameter(
      temp: json['temp'],
      humidity: json['humidity']
    );
  }
}