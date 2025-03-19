
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';


class AuthServices{
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String> signUpUser (
      {required String email, 
      required String password, 
      required String name}) async {
    String res ="Some error Occurred";
    try{

      if(email.isNotEmpty || password.isNotEmpty || name.isNotEmpty){
        UserCredential credential = await _auth.createUserWithEmailAndPassword(
          email: email, 
          password: password
        );
        await _firestore.collection("users").doc(credential.user!.uid).set({
          'name' :name,
          'email':email,
          'uid': credential.user!.uid,
        });
        res = "success";
      }

    } catch(e){
       return e.toString();
    }
    return res;
  }
  Future<String> loginUser({
      required String email, 
      required String password,
  }) async {
    String res ="Some error Occurred";
    try{
      if(email.isNotEmpty || password.isNotEmpty){
        await _auth.signInWithEmailAndPassword(
          email: email, password: password);
           res = "success";
      }else{
        res= "Please enter all the field";
      }
    }catch(e){
      return e.toString();
    }
    return res;
  }

  Future<void> signOut() async{
    await _auth.signOut();
  }
}


// class AuthServicews {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final FirebaseAuth _auth = FirebaseAuth.instance;

//   Future<String> signUpUser({
//     required String email,
//     required String password,
//     required String name,
//   }) async {
//     String res = "Some error Occurred";
//     try {
//       // Tạo tài khoản người dùng mới bằng email và mật khẩu
//       UserCredential credential = await _auth.createUserWithEmailAndPassword(
//         email: email,
//         password: password,
//       );

//       // Lưu thông tin người dùng vào Firestore
//       await _firestore.collection("users").doc(credential.user!.uid).set({
//         'name': name,
//         'email': email,
//         'uid': credential.user!.uid,
//       });

//       // Đặt lại giá trị res thành "success" nếu không có lỗi
//       res = "success";
//     } catch (e) {
//       // Cập nhật giá trị res với chi tiết lỗi
//       res = e.toString();
//     }
//     return res;
//   }
// }
