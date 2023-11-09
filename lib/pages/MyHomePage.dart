import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopping_app/components/appBar/MyAppBar.dart';
import 'package:shopping_app/components/home/MyFloatingButton.dart';
import 'package:shopping_app/components/home/MyHomeList.dart';
import 'package:shopping_app/components/home/MyHomeNavigationBar.dart';
import 'package:shopping_app/components/settings/MySettingsWidget.dart';
import 'package:shopping_app/functions/providers/items/MyItemsProvider.dart';
import 'package:shopping_app/functions/providers/settings/MySettingsProvider.dart';

import '../functions/others/MyFunctions.dart';

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    ///get status bar height
    double height = MediaQuery.of(context).padding.top;

    return Consumer<MySettingsProvider>(
      builder: (context, MySettingsProvider mySettingsProvider, child) {

        return Consumer<MyItemsProvider>
          (builder: (context, MyItemsProvider myItemsProvider, child) {

          return Scaffold(
            body: Padding(
              padding: EdgeInsets.only(top: height),

              ///set the padding = status bar height
              child: mySettingsProvider.isSettingsPage
                  ? const MySettingsWidget()
                  : MyHomeList(
                isListEmptyWidget: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [

                    Text(
                      "Die Liste ist leer!",
                      style: Theme.of(context).textTheme.bodySmall
                    ),
                    const SizedBox(height: 10,),

                    myItemsProvider.isGroup == true ?

                    ElevatedButton(
                      onPressed: MyFunctions.addGroup,
                      style: Theme.of(context).elevatedButtonTheme.style,
                      child: Padding(
                        padding: const EdgeInsets.only(
                            left: 15, right: 15, top: 5, bottom: 5),
                        child: Text(
                          "Gruppe Hinzufügen",
                          style: Theme.of(context).textTheme.labelSmall
                        ),
                      ),
                    )

                    :
                        const SizedBox(),

                  ],
                ),
              ),
            ),
            bottomNavigationBar:  ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(30.0),
                topRight: Radius.circular(30.0),
              ),
              child: BottomAppBar(
                color: Theme.of(context).bottomAppBarTheme.color,
                child: const MyHomeNavigationBar(),
              ),
            ),

            appBar: mySettingsProvider.isSettingsPage ?
            null : const PreferredSize(
              preferredSize: Size.fromHeight(100),
              child: MyAppBar(),
            ),

            floatingActionButton: mySettingsProvider.isSettingsPage
                ? null
                : MyFloatingButton(
              buttonTitle: myItemsProvider.isGroup ? 'Gruppe' : 'Mitglied',
              iconData: myItemsProvider.isGroup ? Icons.group_add : Icons.person_add,
              function: myItemsProvider.isGroup ? MyFunctions.addGroup : MyFunctions.addUserToGroup,
              isChangeByScroll: true,
            ),
            floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
          );
        });
      },
    );
  }
}
