import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';
import 'package:node_chat_app/controller/chat_controller.dart';
import 'package:node_chat_app/model/message.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class chatScreen extends StatefulWidget {
  const chatScreen({super.key});
  
  @override
  State<chatScreen> createState() => _chatScreenState();
}

class _chatScreenState extends State<chatScreen> {
  TextEditingController textControler = TextEditingController();
   late IO.Socket socket;
    ChatController chatContro = ChatController();
 @override
  void initState() {
    // TODO: implement initState
   
   
  socket = IO.io('http://192.168.1.9:4000',
      IO.OptionBuilder()
       .setTransports(['websocket']).build());
    // socket.connect();
    
    socket.onConnect((_) {
     print('connection');
     
    });

    //When an event recieved from server, data is added to the stream
    
    socket.onDisconnect((_) => print('disconnect'));

    setUpSocketListener();
    super.initState();
    
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          Expanded(flex: 9,child: Obx(
            ()=> ListView.builder(
              
              itemCount: chatContro.chatMessage.length,
              itemBuilder: (context, index) {
               
                var currentItem = chatContro.chatMessage[index];
                
                
              return messageItem(sentByMe: currentItem.sentByMe==socket.id
              ,message: currentItem.bodyMessage
              ,timeSent: currentItem.timeSent,
              );
            },
            ),
          )
          ),
          Expanded(
          
            child: Container(
            
            color: Colors.blue,
            child: TextField(
              cursorColor: Colors.amber,
              controller: textControler,
               style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  
                  hintText: "nhập gì đó đi.....",
                  hintStyle: TextStyle(color: Colors.white),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                    borderRadius: BorderRadius.circular(10)
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                    borderRadius: BorderRadius.circular(10)
                  ),
                  suffixIcon: Container(
                    margin: EdgeInsets.only(right: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.amber
                    ),
                    child: IconButton(
                      onPressed: (){
                        sendMessage(textControler.text);
                       
                        textControler.text="";
                      },
                      icon: Icon(
                        Icons.send,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
            ),)),
        ],
      ),
    );
  }
  void setUpSocketListener(){
    socket.on('message-receive',(data) {
      print("msgchat-receive:$data");
      chatContro.chatMessage.add(message.fromJson(data));
    });
  }
  void sendMessage(String text) {
    FocusManager.instance.primaryFocus?.unfocus();
    final DateTime now = DateTime.now();
    final DateFormat formatter = DateFormat('dd-MM');
    String date= formatter.format(now);
    var messageJson = {
      "bodyMessage":text,
      "sentByMe": socket.id,
      "timeSent": date 
    };
    print("msgchat:$messageJson");
    socket.emit('message',messageJson);
    chatContro.chatMessage.add(message.fromJson(messageJson));
    print("msgchat:${chatContro.chatMessage.length}");
  }
}

class messageItem extends StatelessWidget {
  const messageItem({super.key,required this.sentByMe,required this.message,required this.timeSent});
  final bool sentByMe;
  final String message;
  final String timeSent;
  @override
  Widget build(BuildContext context) {
    return Align(
        alignment: sentByMe?Alignment.centerRight:Alignment.centerLeft,
        child:Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: sentByMe?Colors.blue:Colors.white,
          ),
          padding: EdgeInsets.symmetric(vertical: 5,horizontal: 15),
          margin: EdgeInsets.symmetric(vertical:3,horizontal: 10),
          
          child: Row(
            mainAxisSize: MainAxisSize.min,
            textBaseline: TextBaseline.alphabetic,
            children: [

                Text(message,style: TextStyle(fontSize: 16),),
                SizedBox(width: 10,),
                Text(timeSent,style: TextStyle(fontSize: 10,color: Colors.white ),textAlign: sentByMe?TextAlign.right:TextAlign.left,)
             
            ],
          ),
        ),

    );
  }
  
}

 