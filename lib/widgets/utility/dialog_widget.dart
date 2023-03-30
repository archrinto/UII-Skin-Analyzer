import 'package:flutter/material.dart';

Widget buildActionButton(BuildContext context, String text) {
  return SizedBox(
    width: (MediaQuery.of(context).size.width - 32) / 2 - 50,
    height: 45,
    child: Center(
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 16,
          color: Colors.blue,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
  );
}

//* https://medium.flutterdevs.com/animate-dialogs-in-flutter-b7cac136e1d3 (Scale Dialog)
Future buildDialog({
  required BuildContext context,
  required String title,
  required Widget content,
  required List<Widget> actionButton,
}) {
  return showGeneralDialog(
    context: context,
    pageBuilder: (ctx, animation1, animation2) {
      return Container();
    },
    transitionBuilder: (ctx, animation1, animation2, child) {
      var curve = Curves.easeInOut.transform(animation1.value);
      return Transform.scale(
        scale: curve,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          actionsPadding: EdgeInsets.zero,
          title: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  textAlign: TextAlign.center,
                ),
              ),
              const Divider(
                color: Colors.grey,
              ),
            ],
          ),
          content: content,
          actions: <Widget>[
            Column(
              children: [
                const Divider(
                  color: Colors.grey,
                  height: 1,
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: actionButton,
                ),
              ],
            ),
          ],
        ),
      );
    },
    transitionDuration: const Duration(milliseconds: 300),
  );
}
