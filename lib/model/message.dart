class message{
  String bodyMessage;
  String sentByMe;
  String timeSent;
   message({required this.bodyMessage,required this.sentByMe,required this.timeSent});
  factory message.fromJson(Map<String,dynamic> json){
    return message(bodyMessage: json['bodyMessage'], sentByMe: json['sentByMe'],timeSent: json['timeSent']);
  }
 

}