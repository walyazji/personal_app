import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import './widgets/new_transaction.dart';
import './widgets/transaction_list.dart';
import './widgets/chart.dart';
import './models/transaction.dart';

void main() {
  // WidgetsFlutterBinding.ensureInitialized();
  // SystemChrome.setPreferredOrientations(
  //   [
  //     DeviceOrientation.portraitUp,
  //     DeviceOrientation.portraitDown,
  //     // DeviceOrientation.landscapeRight,
  //     // DeviceOrientation.landscapeLeft,
  //   ],
  // );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Personal Expenses',
      theme: ThemeData(
          fontFamily: 'Quicksand',
          textTheme: ThemeData.light().textTheme.copyWith(
                subtitle1: TextStyle(
                    fontFamily: 'OpenSans',
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.white),
                subtitle2: TextStyle(
                    fontFamily: 'OpenSans',
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.purple),
                button: TextStyle(color: Colors.white),
                // bodyLarge: TextStyle(
                //     fontFamily: 'OpenSans',
                //     fontWeight: FontWeight.bold,
                //     fontSize: 18,
                //     color: Colors.grey),
              ),
          appBarTheme: AppBarTheme(
            toolbarTextStyle: ThemeData.light()
                .textTheme
                .copyWith(
                  subtitle1: TextStyle(
                    fontFamily: 'OpenSans',
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                )
                .bodyText2,
            titleTextStyle: ThemeData.light()
                .textTheme
                .copyWith(
                  subtitle2: TextStyle(
                    fontFamily: 'OpenSans',
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                )
                .headline6,
          ),
          colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.purple)
              .copyWith(secondary: Colors.purple)),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  // String titleInput;
  // String amountInput;
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final List<Transaction> _userTransactions = [
    // Transaction(
    //   id: 't1',
    //   title: 'New Shoes',
    //   amount: 69.99,
    //   date: DateTime.now(),
    // ),
    // Transaction(
    //   id: 't2',
    //   title: 'Weekly Groceries',
    //   amount: 16.53,
    //   date: DateTime.now(),
    // ),
  ];

  List<Transaction> get _recentTransactions {
    return _userTransactions.where((tx) {
      return tx.date.isAfter(
        DateTime.now().subtract(
          Duration(days: 7),
        ),
      );
    }).toList();
  }

  void _addNewTransaction(
      String txTitle, double txAmount, DateTime chosenDate) {
    final newTx = Transaction(
      title: txTitle,
      amount: txAmount,
      date: chosenDate,
      id: DateTime.now().toString(),
    );

    setState(() {
      _userTransactions.add(newTx);
    });
  }

  void _startAddNewTransaction(BuildContext ctx) {
    showModalBottomSheet(
      context: ctx,
      builder: (_) {
        return GestureDetector(
          onTap: () {},
          child: NewTransaction(_addNewTransaction),
          behavior: HitTestBehavior.opaque,
        );
      },
    );
  }

  void _deleteTransaction(String id) {
    setState(() {
      _userTransactions.removeWhere((tx) => tx.id == id);
    });
  }

  bool showChart = false;
  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final isLandscape = mq.orientation == Orientation.landscape;

    final PreferredSizeWidget appBar = Platform.isIOS
        ? CupertinoNavigationBar(
            middle: Text(
              'Personal Expenses',
              style: Theme.of(context).textTheme.subtitle1,
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                GestureDetector(
                  child: Icon(CupertinoIcons.add),
                  onTap: () => _startAddNewTransaction(context),
                ),
              ],
            ),
          )
        : AppBar(
            title: Text(
              'Personal Expenses',
              style: Theme.of(context).textTheme.subtitle1,
            ),
            actions: <Widget>[
              IconButton(
                icon: Icon(Icons.add),
                onPressed: () => _startAddNewTransaction(context),
              ),
            ],
          );

    var txListWidget = Container(
      height:
          (mq.size.height - appBar.preferredSize.height - mq.padding.top) * 0.7,
      child: TransactionList(_userTransactions, _deleteTransaction),
    );
    var bodyContent = SafeArea(
      child: SingleChildScrollView(
        child: Column(
          // mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            if (!isLandscape)
              Container(
                height: (mq.size.height -
                        appBar.preferredSize.height -
                        mq.padding.top) *
                    0.3,
                child: Chart(_recentTransactions),
              ),
            if (!isLandscape) txListWidget,
            if (isLandscape)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Show Chart',
                    style: showChart == true
                        ? Theme.of(context).textTheme.subtitle2
                        : TextStyle(
                            fontFamily: 'OpenSans',
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.grey),
                  ),
                  Switch.adaptive(
                    activeColor: Colors.purple,
                    value: showChart,
                    onChanged: (value) {
                      setState(() {
                        showChart = value;
                      });
                    },
                  ),
                ],
              ),
            // if (!isLandscape)
            //   Container(
            //     height: (mq.size.height -
            //             appBar.preferredSize.height -
            //             mq.padding.top) *
            //         0.3,
            //     child: Chart(_recentTransactions),
            //   ),
            // if (!isLandscape) txListWidget,
            // if (isLandscape) txListWidget,
            if (isLandscape)
              showChart == true
                  ? Container(
                      height: (mq.size.height -
                              appBar.preferredSize.height -
                              mq.padding.top) *
                          0.7,
                      child: Chart(_recentTransactions),
                    )
                  : txListWidget,
            if (isLandscape && showChart == true) txListWidget,
          ],
        ),
      ),
    );
    return Platform.isIOS
        ? CupertinoPageScaffold(
            child: bodyContent,
            navigationBar: appBar,
          )
        : Scaffold(
            appBar: appBar,
            body: bodyContent,
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerFloat,
            floatingActionButton: Platform.isIOS
                ? Container()
                : FloatingActionButton(
                    child: Icon(Icons.add),
                    onPressed: () => _startAddNewTransaction(context),
                  ),
          );
  }
}
