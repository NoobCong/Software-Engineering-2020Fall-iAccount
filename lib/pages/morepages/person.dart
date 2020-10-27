import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:i_account/pages/personpages/person_create.dart';
import 'package:i_account/pages/tabs.dart';
import 'package:i_account/pages/personpages/bill_search_person.dart';
import 'package:i_account/db/db_helper_demo.dart';

class PersonPage extends StatefulWidget {
  @override
  _PersonPageState createState() => _PersonPageState();
}

class _PersonPageState extends State<PersonPage> {
  List personNames = new List();

  Future<List> _loadPersonNames() async {
    List list = await dbAccount.getMember();
    List listTemp = new List();
    list.forEach((element) {
      listTemp.add(element.member);
    });
    print(personNames.length);
    return listTemp;
  }


  @override
  void initState() {
    _loadPersonNames().then((value) => setState(() {
          personNames = value;
        }));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.black,
        ),
        title: Text(
          "成员",
          style: TextStyle(color: Colors.black),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.add,
              size: 25.0,
              color: Colors.black,
            ),
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => AccountCreatePage()));
            },
          ),
        ],
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child:ListView.separated(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemBuilder: (context, item) {
            return buildListData(context, personNames[item],);
          },
          separatorBuilder: (BuildContext context, int index) =>
              Divider(),
          itemCount: (personNames.length == null)
              ? 0
              : personNames.length,
        ),
      ),
    );
  }

  Widget buildListData(
      BuildContext context, String titleItem) {
    return new ListTile(
      onTap: () {
        Navigator.of(context).push(new MaterialPageRoute(builder: (_) {
          return BillSearchListPerson(titleItem);
        }));
      },
      onLongPress: () async {
        showDialog<Null>(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("提示"),
              content: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[Text("是否删除该成员？")],
                ),
              ),
              actions: <Widget>[
                FlatButton(
                  onPressed: () async {
                    Navigator.of(context).pop();
                  },
                  child: Text("取消"),
                ),
                FlatButton(
                  onPressed: () async {
                    Navigator.of(context).pop();
                    await dbAccount.deleteAccount(titleItem);
                    Navigator.pushAndRemoveUntil(context,
                        MaterialPageRoute(builder: (BuildContext context) {
                      return Tabs();
                    }), (route) => route == null);
                    showDialog<Null>(
                      context: context,
                      barrierDismissible: false,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text("提示"),
                          content: SingleChildScrollView(
                            child: ListBody(
                              children: <Widget>[Text("已经删除该成员！")],
                            ),
                          ),
                          actions: <Widget>[
                            FlatButton(
                              onPressed: () async {
                                Navigator.of(context).pop();
                              },
                              child: Text("确定"),
                            ),
                          ],
                        );
                      },
                    ).then((val) {
                      print(val);
                    });
                  },
                  child: Text("确定"),
                ),
              ],
            );
          },
        ).then((val) {
          print(val);
        });
      },
      leading: Icon(Icons.person),
      title: new Text(
        titleItem,
        style: TextStyle(fontSize: 18),
      ),
      trailing: new Icon(Icons.keyboard_arrow_right),
    );
  }
}