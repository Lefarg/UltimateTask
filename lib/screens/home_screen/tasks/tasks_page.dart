import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:ultimate_task/misc/constants.dart';
import 'package:ultimate_task/misc/show_alert_dialog.dart';
import 'package:ultimate_task/screens/home_screen/models/task.dart';
import 'package:ultimate_task/screens/home_screen/tasks/add_task_page.dart';
import 'package:ultimate_task/service/auth.dart';
import 'package:ultimate_task/service/database.dart';
import 'package:uuid/uuid.dart';

extension ColorExtension on String {
  toColor() {
    var hexColor = this.replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF" + hexColor;
    }
    if (hexColor.length == 8) {
      return Color(int.parse("0x$hexColor"));
    }
  }
}

class TasksPage extends StatelessWidget {
  Future<void> _signOut(BuildContext context) async {
    try {
      final auth = Provider.of<AuthBase>(context, listen: false);
      await auth.signOut();
    } catch (e) {
      print(e.toString());
    }
  }

  //TODO дизайн showAlertDialog
  Future<void> _confirmSignOut(BuildContext context, String user) async {
    final didRequestSignOut = await showAlertDialog(
      context,
      title: 'Logout',
      content: 'Вы действительно хотите выйти из учетной записи "$user"?',
      cancelActionText: 'Отмена',
      defaultActionText: 'Выход',
    );
    if (didRequestSignOut == true) {
      _signOut(context);
    }
  }

  // Future<void> _createTask(BuildContext context) async {
  //   final database = Provider.of<Database>(context, listen: false);

  //   await database.createTask(
  //     Task(
  //       memo: "testing1",
  //       id: Uuid().v4(),
  //       color: '84FFFF',
  //       outOfDate: true,
  //       creationDate: Timestamp.fromDate(DateTime.now()),
  //       doingDate: Timestamp.fromDate(DateTime.now()),
  //       isDeleted: true,
  //       lastEditDate: Timestamp.fromDate(DateTime.now()),
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthBase>(context, listen: false);

    return Scaffold(
      backgroundColor: Color(myBackgroundColor),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Color(myBackgroundColor),
        title: Text(
          'Ultimate Task',
          style: GoogleFonts.alice(
            textStyle: TextStyle(color: Colors.black, fontSize: 22),
          ),
        ),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.logout,
              color: Colors.black,
            ),
            onPressed: () => _confirmSignOut(context, auth.currentUser.email),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(myBlueColor),
        child: Icon(Icons.add),
        onPressed: () => AddTaskPage.show(context),
      ),
      body: _buildContexts(context),
    );
  }

  Widget _buildContexts(BuildContext context) {
    final database = Provider.of<Database>(context, listen: false);
    return StreamBuilder<List<Task>>(
      stream: database.tasksStream(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final tasks = snapshot.data;
          final children = tasks.map((e) => Text(e.memo)).toList();
          return ListView(children: children);
        }
        if (snapshot.hasError) {
          return Center(child: Text('StreamBuilder Error'));
        }
        return Center(child: CircularProgressIndicator());
      },
    );
  }
}
