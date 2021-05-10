import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_cab/constance/global.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebaseStorage;

import 'package:my_cab/helpers&widgets/helpers/Language/appLocalizations.dart';
import 'package:my_cab/helpers&widgets/widgets/customButton.dart';
import 'package:my_cab/helpers&widgets/widgets/customText.dart';
import 'package:my_cab/helpers&widgets/widgets/loading.dart';
import 'package:my_cab/helpers&widgets/widgets/textField.dart';
import 'package:my_cab/services/userServices.dart';

class ProfileEdit extends StatefulWidget {
  @override
  _ProfileEditState createState() => _ProfileEditState();
}

class _ProfileEditState extends State<ProfileEdit> {
  UserServices userServices = new UserServices();
  FirebaseAuth _auth = FirebaseAuth.instance;
 String profilePicture = '';
  String imageUrl = '';
  final userNameController = TextEditingController();
  final emailController = TextEditingController();
  final genderController = TextEditingController();
  final phoneNumberController = TextEditingController();
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final formKey = GlobalKey<FormState>();
 

  List<String> genders = ['Male', 'Female'];
  String gender = "";
  PickedFile imageToUpload;
  ImagePicker _picker = new ImagePicker();
  bool loading = false;
  @override
  void initState() {
    super.initState();
    getCurrentUserDetails();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: appBar(),
      body: Stack(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.vertical,
            physics: BouncingScrollPhysics(),
            primary: false,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Form(
                key: formKey,
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: () => showImageDialog(),
                      child: CircleAvatar(
                        radius: 60,
                        child: userImage(),
                      ),
                    ),
                    LoginTextField(
                      validator: (v) {
                        if (v.isEmpty) return 'Full names cannot be empty';
                      },
                      hint: 'Full Names',
                      // align: TextAlign.center,
                      controller: userNameController,
                      iconOne: Icon(Icons.person),
                    ),
                    LoginTextField(
                      textInputType: TextInputType.numberWithOptions(),
                      validator: (v) {
                        if (v.isEmpty) return 'Phone Number cannot be empty';
                        // if (v.length < 10) return 'Phone number length is to short';
                        // if (v.length > 10) return 'Phone number length is to long';
                      },
                      hint: 'Phone Number',
                      controller: phoneNumberController,
                      iconOne: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Container(
                            alignment: Alignment.centerLeft,
                            child: CustomText(text: '+234', textAlign: TextAlign.center, size: 13, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    LoginTextField(
                      validator: (v) {
                        if (v.isEmpty) return 'Full names cannot be empty';
                      },
                      hint: 'Email Address',
                      // align: TextAlign.center,
                      controller: emailController,
                      iconOne: Icon(Icons.alternate_email),
                    ),
                    Container(
                      child: Container(
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(30.0), color: Colors.grey[200]),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2),
                          child: DropdownButtonHideUnderline(
                              child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: DropdownButton(
                                onTap: () => print('object'),
                                value: gender.isNotEmpty ? gender : null,
                                hint: Text('Select Gender'),
                                onChanged: (val) {
                                  setState(() {
                                    gender = val;
                                  });
                                },
                                items: genders
                                    .map((e) => DropdownMenuItem(
                                          child: Text(e),
                                          value: e,
                                          onTap: () {
                                            setState(() {
                                              gender = e;
                                            });
                                          },
                                        ))
                                    .toList()),
                          )),
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    CustomFlatButton(
                      callback: () => updateData(),
                      radius: 30,
                      icon: Icons.update,
                      text: 'Update Data',
                      color: blue,
                    )
                  ],
                ),
              ),
            ),
          ),
          Visibility(
              visible: loading == true,
              child: Loading(
                text: 'Please wait...',
              ))
        ],
      ),
    );
  }

  Widget appBar() {
    return AppBar(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      automaticallyImplyLeading: false,
      title: Row(
        children: <Widget>[
          SizedBox(
            height: AppBar().preferredSize.height,
            width: AppBar().preferredSize.height + 40,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                alignment: Alignment.centerLeft,
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop(imageUrl);
                  },
                  child: Icon(
                    Icons.arrow_back,
                    color: Theme.of(context).textTheme.title.color,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Text(
              AppLocalizations.of('Settings'),
              style: Theme.of(context).textTheme.title.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.title.color,
                  ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(
            height: AppBar().preferredSize.height,
            width: AppBar().preferredSize.height + 40,
          ),
        ],
      ),
    );
  }

  getCurrentUserDetails() async {
    await userServices.getUserById(_auth.currentUser.uid).then((value) {
      print(value.email);
      setState(() {
        gender = value.gender ?? '';
        phoneNumberController.text = value.phoneNumber;
        emailController.text = value.email;
        genderController.text = value.gender;
        userNameController.text = value.names;
        profilePicture = value.profilePicture ?? '';
      });
    });
  }

  updateData() async {
    if (formKey.currentState.validate()) {
      try {
        setState(() {
          loading = true;
        });
        String imageName = imageToUpload.path + DateTime.now().microsecondsSinceEpoch.toString();
        firebaseStorage.TaskSnapshot snapshot =
            await firebaseStorage.FirebaseStorage.instance.ref().child('ProfilePictures/$imageName').putFile(File(imageToUpload.path)); //path to the image
        imageUrl = await snapshot.ref.getDownloadURL();
        await userServices
            .updateUser(_auth.currentUser.uid, emailController.text, gender, phoneNumberController.text, userNameController.text, imageUrl ?? profilePicture)
            .then((value) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: CustomText(
                  text: 'Data Updated Successfully',
                  textAlign: TextAlign.center,
                  color: Colors.green,
                ))));
        setState(() {
          loading = false;
        });
      } catch (e) {
        print(e.toString());
      }
    }
  }

  userImage() {
    return ClipOval(
      child: imageToUpload == null ? Icon(Icons.image) : Image.file(File(imageToUpload.path), fit: BoxFit.cover, height: 120, width: 120),
    );
  }

  selectProfileImage(Future<PickedFile> pickImage) async {
    PickedFile selectedProfileImage = await pickImage;
    setState(() {
      imageToUpload = selectedProfileImage;
    });
  }

  showImageDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9.0)),
            child: FittedBox(
              fit: BoxFit.fitHeight,
              child: Container(
                  padding: EdgeInsets.symmetric(vertical: 30),
                  width: MediaQuery.of(context).size.width,
                  // height: 200,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CustomText(
                        text: 'How would you like to upload your plan?',
                        size: 22,
                        fontWeight: FontWeight.w600,
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(
                        height: 45,
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            GestureDetector(
                              onTap: () {
                                selectProfileImage(_picker.getImage(source: ImageSource.camera));
                                Navigator.pop(context);
                              },
                              child: Container(
                                decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(9)), color: grey[200]),
                                height: 100,
                                width: 100,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.camera, size: 25),
                                    SizedBox(height: 10),
                                    CustomText(text: 'Camera', size: 17, overflow: TextOverflow.visible),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(width: 50),
                            GestureDetector(
                              onTap: () {
                                selectProfileImage(_picker.getImage(source: ImageSource.gallery));
                                Navigator.pop(context);
                              },
                              child: Container(
                                decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(9)), color: grey[200]),
                                height: 100,
                                width: 100,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.storage, size: 25),
                                    SizedBox(height: 10),
                                    CustomText(text: 'Gallery', size: 17, overflow: TextOverflow.visible),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  )),
            ),
          );
        });
  }
}
