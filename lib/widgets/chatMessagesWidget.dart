import 'package:group_chat_application/widgets/messageBubbleWidget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatMessages extends StatelessWidget {
  const ChatMessages({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authenticatedUser = FirebaseAuth.instance.currentUser!;

    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('chat')
            .orderBy(
                'createdAt',
                  descending: true
            )
            .snapshots(),
        builder: (ctx, chatSnapshot) {
          if(chatSnapshot.connectionState == ConnectionState.waiting){
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if(!chatSnapshot.hasData || chatSnapshot.data!.docs.isEmpty){
            return const Center(child: Text('Start chatting'));
          }

          if(chatSnapshot.hasError){
            return const Center(child: Text('Someting Went wrong'));
          }

          final loadedMessages = chatSnapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.only(
              bottom: 40,
              left: 15,
              right: 15
            ),
            reverse: true,
            itemCount: loadedMessages.length,
            itemBuilder: (ctx, index) {
              final chatMessage = loadedMessages[index].data();
              final nextChatMessage = index+1 < loadedMessages.length
                  ? loadedMessages[index+1].data()
                  : null;

              final currentMessageUserId = chatMessage['userId'];
              final nextMessageUserId = nextChatMessage!=null
                  ? nextChatMessage['userId']
                  : null;

              final nextUserIsSame = nextMessageUserId == currentMessageUserId;

              if(nextUserIsSame){
                return MessageBubbleWidget.next(
                    message: chatMessage['text'],
                    isMe: authenticatedUser.uid == currentMessageUserId
                );
              }
              else{
                return MessageBubbleWidget.first(
                    userImage: chatMessage['userImage'],
                    username: chatMessage['username'],
                    message: chatMessage['text'],
                    isMe: authenticatedUser.uid == currentMessageUserId
                );
              }

            }
          );
        },
    );


  }
}
