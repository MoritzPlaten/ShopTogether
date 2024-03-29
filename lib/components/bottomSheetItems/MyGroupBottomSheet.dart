import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopping_app/components/bottomSheetItems/groupBottomSheet/MyGroupBottomSheetDialog.dart';
import 'package:shopping_app/components/group/MyAddGroupWidget.dart';
import 'package:shopping_app/components/memberRequest/MyInMemberRequestWidget.dart';
import 'package:shopping_app/functions/dialog/groupDialog/newGroupDialog.dart';
import 'package:shopping_app/functions/providers/group/MyGroupProvider.dart';
import 'package:shopping_app/functions/services/firestore/MyFirestoreService.dart';
import 'package:shopping_app/functions/services/snackbars/MySnackBarService.dart';
import 'package:shopping_app/objects/requests/MyRequestGroup.dart';

import '../../exceptions/MyCustomException.dart';

class MyGroupBottomSheet {

  static List<Widget> generateBottomSheet(BuildContext context) {

    return [

      const SizedBox(height: 20,),
      Center(
        child: Text(
          "Gruppe hinzufügen",
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),

      const SizedBox(height: 20,),

      Consumer<MyGroupProvider>(
          builder: (BuildContext context, MyGroupProvider myGroupProvider, Widget? child) {

            return Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [

                MyAddGroupWidget(
                  title: "Gruppe erstellen",
                  subtitle: "Hier können Sie Ihre eigene \n Gruppe erstellen!",
                  function: () => newGroupDialog(context),
                ),
                if (myGroupProvider.isShowWidget) ///switchs between the join group button and the enter code to join to a group widget
                  MyInMemberRequestWidget(
                      title: "Gruppe beitreten",
                      onNumbersEntered: (List<String> enteredNumbers) async {

                        String joinedNumbers = enteredNumbers.join('');
                        if (joinedNumbers == '') {

                          Navigator.pop(context);
                          MySnackBarService.showMySnackBar(context, "Bitte geben Sie ihren Code ein!");
                          return;
                        }

                        if (joinedNumbers.length != 6) {

                          Navigator.pop(context);
                          MySnackBarService.showMySnackBar(context, "Bitte geben Sie alle 6 Zahlen ein, damit der Code vollständig ist!");
                          return;
                        }

                        int joinedNumbersAsInt = int.parse(joinedNumbers);

                        try {

                          MyRequestGroup myRequestGroup = await MyFirestoreService.requestService.getInfosAboutSession(joinedNumbersAsInt);
                          bool isUserAleadyInGroup = await MyFirestoreService.groupService.isCurrentUserInGroup(myRequestGroup.groupUUID);
                          
                          if (!isUserAleadyInGroup) { ///when user is not in group and anything is correct, then show the dialog for joining the group

                            MyGroupBottomSheetDialog.showGroupDialog(context, myRequestGroup, joinedNumbersAsInt);
                          } else {///User is already in Group
                            
                            MySnackBarService.showMySnackBar(context, "Sie sind bereits in dieser Gruppe!");
                            Navigator.pop(context);
                          }
                          
                          Provider.of<MyGroupProvider>(context, listen: false).updateShowWidget(false);
                        } on MyCustomException catch(e) {

                          switch(e.keyword) {
                            case "no-requestCode":
                              MySnackBarService.showMySnackBar(context, "Der eingegebene Code existiert nicht!");
                              Navigator.pop(context);
                              break;

                            case "snapshot-not-exists":
                              print(e.message);
                              break;
                          }
                        }
                      },
                  )
                else
                  MyAddGroupWidget(
                    title: "Gruppe beitreten",
                    subtitle: "Treten Sie hier einer \nanderen Gruppe per Code bei!",
                    function: () => Provider.of<MyGroupProvider>(context, listen: false).updateShowWidget(true),
                  ),

              ],
            );
          }
      ),

    ];
  }
}