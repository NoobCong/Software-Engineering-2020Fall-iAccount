import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:i_account/bill/models/category_model.dart';
import 'package:i_account/db/db_helper.dart';
import 'package:i_account/router_jump.dart';
import 'package:i_account/widgets/input_textview_dialog_category.dart';
import 'package:i_account/pages/categorypages/category_create_second_income.dart';

class CategoryIncomeSecondPage extends StatefulWidget {
  CategoryIncomeSecondPage(this.categoryName1) : super();
  final categoryName1;
  @override
  _CategoryIncomeSecondPageState createState() =>
      _CategoryIncomeSecondPageState();
}

class _CategoryIncomeSecondPageState extends State<CategoryIncomeSecondPage> {
  List categoryNames = new List();

  Future<List> _loadCategoryNames() async {
    List list = await dbHelp.getCategories(2, widget.categoryName1);
    return list;
  }

  @override
  void initState() {
    _loadCategoryNames().then((value) => setState(() {
          categoryNames = value;
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
          "二级收入分类",
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        actions: [
          IconButton(
              icon: Icon(Icons.looks_two),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => CategoryCreateSecondIncomePage(
                            widget.categoryName1)));
              }),
        ],
      ),
      body: SingleChildScrollView(
        child: ListView.separated(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemBuilder: (context, item) {
            return buildListData(
              context,
              categoryNames[item],
            );
          },
          separatorBuilder: (BuildContext context, int index) => Divider(),
          itemCount: (categoryNames.length == null) ? 0 : categoryNames.length,
        ),
      ),
    );
  }

  Widget buildListData(BuildContext context, String titleItem) {
    return new ListTile(
        onTap: () {
          //Navigator.of(context).push(new MaterialPageRoute(builder: (_) {
          //return BillSearchListCategoryWithtype(titleItem, 2);
          //}));
        },
        onLongPress: () async {
          if (titleItem == '其他收入') {
            showDialog<Null>(
              context: context,
              barrierDismissible: false,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text("提示"),
                  content: SingleChildScrollView(
                    child: ListBody(
                      children: <Widget>[Text("该分类不能删除或编辑！")],
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
          } else {
            showDialog<Null>(
              context: context,
              barrierDismissible: false,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text("提示"),
                  content: SingleChildScrollView(
                    child: ListBody(
                      children: <Widget>[
                        Text("请选择删除或编辑该分类。\n删除分类的同时也会删除相应的流水信息。")
                      ],
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
                        showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (BuildContext context) {
                              return TextViewDialogCategory(
                                confirm: (text)async {
                                    CategoryItem preCategory = await dbHelp.getCategoryid2(titleItem, 2);
                                    await dbHelp.updateCategoryBills(preCategory, text, 2);
                                    preCategory.classification2 = text;
                                    await dbHelp.insertCategory(preCategory, 2);
                                },
                              );
                            });
                      },
                      child: Text("编辑"),
                    ),
                    FlatButton(
                      onPressed: () async {
                        Navigator.of(context).pop();
                        CategoryItem tempItem =
                            new CategoryItem(widget.categoryName1, titleItem);
                        await dbHelp.deleteCategoryBills(tempItem, 2);
                        await dbHelp.deleteCategory(tempItem, 2);
                        Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                                builder: (context) => RouterJump()),
                            ModalRoute.withName('/'));
                        showDialog<Null>(
                          context: context,
                          barrierDismissible: false,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text("提示"),
                              content: SingleChildScrollView(
                                child: ListBody(
                                  children: <Widget>[Text("已经删除该分类！")],
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
          }
        },
        leading: Icon(Icons.category),
        title: new Text(
          titleItem,
          style: TextStyle(fontSize: 18),
        ));
  }
}
