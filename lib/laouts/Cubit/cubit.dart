import 'dart:io';

import 'package:chat/laouts/Cubit/states.dart';
import 'package:chat/laouts/NewPosts/NewPosts.dart';
import 'package:chat/laouts/chat/Chat.dart';
import 'package:chat/laouts/feeds/feeds.dart';
import 'package:chat/laouts/settings/Sett.dart';
import 'package:chat/laouts/users/Userss.dart';
import 'package:chat/modulo/PostModel.dart';
import 'package:chat/modulo/usersmoder.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import '../../constant.dart';

class SociallCubit extends Cubit<SocialStates> {
  SociallCubit() : super(SocialInitialStates());

  static SociallCubit get(context) => BlocProvider.of(context);
  List<Map<String, dynamic>> elements = [];
  UsersModel? UU;

  void getUsers() {
    emit(SocialGetUserLoadingStates());
    FirebaseFirestore.instance.collection('users').doc(uId).get().then((value) {
      UU = UsersModel.fromJson(value.data() as Map<String, dynamic>);
      print(
        value.data().toString(),
      );
      emit(
        SocialGetUserSuccessStates(),
      );
    }).catchError((onError) {
      print("error" + onError.toString());
      emit(SocialGetUserErrorStates(onError.toString()));
    });
  }

  int currrentIndex = 0;
  List<String> titles = [
    'Home',
    'Chat',
    'Post',
    'Users',
    'Settings',
  ];
  List<Widget> list = [
    const FeedsScreen(),
    const ChatScreen(),
    const NewPosts(),
    const UsersScreen(),
    const SettingScreen(),
  ];

  void ChangeBottomNav(int index) {
    if (index == 2) {
      emit(SocialNewPostStates());
    } else {
      currrentIndex = index;
      emit(SocialChangeBottomNavStates());
    }
  }

  var imageProfile;
  final Picker = ImagePicker();

  getImageProfile(ImageSource sre) async {
    final Pac = await Picker.pickImage(source: sre);
    emit(SocialImagePickedProfileSuccessStates());
    if (Pac != null) {
      imageProfile = File(Pac.path);
    } else {
      emit(SocialImagePickedProfileErrorStates());
      print('no image selected');
    }
  }

  var imageCover;

  getImageCover(ImageSource sre) async {
    final Pac = await Picker.pickImage(source: sre);
    emit(SocialImagePickedCoverSuccessStates());
    if (Pac != null) {
      imageCover = File(Pac.path);
    } else {
      emit(SocialImagePickedCoverErrorStates());
      print('no imageCovered Selected');
    }
  }

  String? PrifileImageUrl;
  String? CoverImageUrl;

  void uploadProfileImage() {
    emit(SocialUploadImageProfileLoadingStates());
    firebase_storage.FirebaseStorage.instance
        .ref()
        .child('users/${Uri.file(imageProfile!.path).pathSegments.last}')
        .putFile(imageProfile)
        .then((value) {
      value.ref.getDownloadURL().then((value) {
        print(value);
        emit(SocialUploadImageProfileSuccessStates());
        PrifileImageUrl = value;
      }).catchError((onError) {
        print("errrrrrrrrrrrrrrrooooooor" + onError.toString());
        emit(SocialUploadImageProfileErrorStates());
      });
    }).catchError((onError) {
      print("error" + onError.toString());
      emit(SocialUploadImageProfileErrorStates());
    });
  }

  void uploadCoverImage() {
    emit(SocialUploadImageCoverLoadingStates());
    firebase_storage.FirebaseStorage.instance
        .ref()
        .child('users/${Uri.file(imageCover!.path).pathSegments.last}')
        .putFile(imageCover)
        .then((value) {
      value.ref.getDownloadURL().then((value) {
        print(value);
        emit(SocialUploadImageCoverSuccessStates());
        CoverImageUrl = value;
      }).catchError((onError) {
        print("errrrrrrrrrrrrrrrooooooor" + onError.toString());
        emit(SocialUploadImageCoverErrorStates());
      });
    }).catchError((onError) {
      print("error" + onError.toString());
      emit(SocialUploadImageCoverErrorStates());
    });
  }

  void UpdateUser({
    required String name,
    required String phone,
    required String bio,
  }) {
    {
      emit(SocialUpdateUserLoadingStates());
      UsersModel UserModelUpdate = UsersModel(
        name: name,
        phone: phone,
        Bio: bio,
        email: UU!.email,
        uId: UU!.uId,
        Cover: CoverImageUrl ?? UU!.Cover,
        ImageProfile: PrifileImageUrl ?? UU!.ImageProfile,
        isEmailVerifaed: false,
      );
      FirebaseFirestore.instance
          .collection('users')
          .doc(uId)
          .update(UserModelUpdate.toMap())
          .then((value) {
        getUsers();
      }).catchError((onError) {
        print(onError.toString());
      });
    }
  }

  var PostImagee;

  getImagePost(ImageSource sre) async {
    final Pac = await Picker.pickImage(source: sre);
    emit(SocialImagePickedCoverSuccessStates());
    if (Pac != null) {
      PostImagee = File(Pac.path);
    } else {
      emit(SocialImagePickedCoverErrorStates());
      print('no PostImageed Selected');
    }
  }

  void uploadImagePost({
    required String text,
    required String dateTime,
  }) {
    emit(SocialPostLoadingStates());
    firebase_storage.FirebaseStorage.instance
        .ref()
        .child('posts/${Uri.file(PostImagee!.path).pathSegments.last}')
        .putFile(PostImagee)
        .then((value) {
      value.ref.getDownloadURL().then((value) {
        print(value);
        CreatePost(
          text: text,
          dateTime: dateTime,
          PostImage: value,
        );
        emit(SocialPostSuccessStates());
      }).catchError((onError) {
        print("errrrrrrrrrrrrrrrooooooor" + onError.toString());
        emit(SocialPostErrorStates());
      });
    }).catchError((onError) {
      print("error" + onError.toString());
      emit(SocialPostErrorStates());
    });
  }

  void CreatePost({
    required String text,
    required String dateTime,
    String? PostImage,
  }) {
    {
      emit(SocialPostLoadingStates());
      PostModel PostModelUser = PostModel(
          name: UU!.name,
          uId: UU!.uId,
          text: text,
          Image: UU!.ImageProfile,
          dateTime: dateTime,
          PostImage: PostImage ?? "");
      FirebaseFirestore.instance
          .collection('posts')
          .add(PostModelUser.toMap())
          .then((value) {
        emit(SocialPostSuccessStates());
      }).catchError((onError) {
        emit(SocialPostErrorStates());
        print(onError.toString());
      });
    }
  }

  List<PostModel> PP = [];
  List<String> Likes = [];
  List<int> LikeLength = [];
  List<bool> isLiked = [];

  void CloseImage() {
    PostImagee = null;
    emit(SocialImageCloseStates());
  }

  void getPosts() {
    emit(SocialGetPostsLoadingStates());
    FirebaseFirestore.instance.collection('posts').get().then((value) {
      value.docs.forEach((element) {
        element.reference.collection('likes').get().then((value) {
          emit(SocialGetLikeSuccessState());
          LikeLength.add(value.docs.length);
        }).catchError((onError) {
          emit(SocialPostLikeErrorState());
        });
        PP.add(PostModel.fromJson(element.data()));
        Likes.add(element.id);

        //print(element.id);
        //print(PP[0].text);
      });
      emit(SocialGetPostsSuccessStates());
    }).catchError((onError) {
      print("error" + onError.toString());
      emit(SocialGetPostsErrorStates(onError.toString()));
    });
  }

  void getLikes() {
    FirebaseFirestore.instance.collection('posts').get().then((value) {
      value.docs.forEach((element) {
        element.reference.collection('likes').doc(UU!.uId).get().then((value) {
          emit(SocialGetLikeSuccessState());
          isLiked.add(value.get('like'));
          print(isLiked);
          print("dmaf;pmpa" + value.data().toString());
        }).catchError((onError) {});
      });
    }).catchError((onError) {});
  }

  bool isLikedd = false;

  void getLikes2(String PostId) {
    FirebaseFirestore.instance
        .collection('posts')
        .doc(PostId)
        .collection('likes')
        .doc(UU!.uId)
        .get()
        .then((value) {
      emit(SocialGetLikeSuccessState());
      print(value.data());
      isLikedd = value.get('like');
    }).catchError((onError) {
      emit(SocialPostLikeErrorState());
    });
  }

  void LikePost(String PostId) {
    FirebaseFirestore.instance
        .collection('posts')
        .doc(PostId)
        .collection('likes')
        .doc(UU!.uId)
        .set({
      'like': true,
    }).then((value) {
      emit(SocialPostLikeSuccessState());
    }).catchError((onError) {
      emit(SocialPostLikeErrorState());
    });
  }

  void disLike(String PostId) {
    FirebaseFirestore.instance
        .collection('posts')
        .doc(PostId)
        .collection('likes')
        .doc(UU!.uId)
        .set({
      'like': false,
    }).then((value) {
      emit(SocialPostLikeSuccessState());
    }).catchError((onError) {
      emit(SocialPostLikeErrorState());
    });
  }
}
