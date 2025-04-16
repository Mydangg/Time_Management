import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:time_management/components/custom_app_bar.dart';
import 'package:time_management/schedule/alarm_notification.dart';
import 'package:time_management/tasks/presentation/bloc/tasks_bloc.dart';
import 'package:time_management/components/build_text_field.dart';
import 'package:time_management/tasks/presentation/widget/task_item_view.dart';
import 'package:time_management/utils/color_palette.dart';
import 'package:time_management/utils/util.dart';
import 'package:time_management/Login_Signup/Screen/login.dart';
import 'package:time_management/Login_with_Google/google_auth.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../components/widgets.dart';
import '../../../routes/pages.dart';
import '../../../utils/font_sizes.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  late AlarmNotification_Service alarmNotification =
      AlarmNotification_Service();
  TextEditingController searchController = TextEditingController();
  int selectedIndex = 0;

  @override
  void initState() {
    context.read<TasksBloc>().add(FetchTaskEvent());
    _loadUserName();
    context.read<TasksBloc>().add(FetchTaskEvent());
    super.initState();
  }

  String? username;

  void _loadUserName() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();
      setState(() {
        username = doc.data()?['name'] ?? 'User';
      });
    }
  }

  //Hàm chuyển trang
  void _onItemTapped(int index) {
    setState(() {
      selectedIndex = index;
    });

    //Đây là cái để chuyển trang
    switch (index) {
      case 0:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const TasksScreen()),
        );
        break;
      //     case 1:
      //       Navigator.push(context, MaterialPageRoute(builder: (_) => const Page2()));
      //       break;
      //     case 2:
      //       Navigator.push(context, MaterialPageRoute(builder: (_) => const Page3()));
      //       break;
      //     case 3:
      //       Navigator.push(context, MaterialPageRoute(builder: (_) => const Page4()));
      //       break
    }
  }

  //Thông báo xác nhận
  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text("Xác nhận"),
            content: const Text("Bạn có chắc muốn đăng xuất không?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context), // Huỷ
                child: const Text("Huỷ"),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Đóng dialog
                  _logout(); // Xử lý logout
                },
                child: const Text("Đăng xuất"),
              ),
            ],
          ),
    );
  }

  //Hàm logout
  // xử lý đăng xuất ở đây (xoá token, điều hướng về login...)
  void _logout() async {
    await FirebaseAuth.instance.signOut();
    // await FirebaseServices().googleSignOut();
    // await AuthServices().signOut();

    //Điều hướng về login
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    ); // điều hướng
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(statusBarColor: Colors.transparent),
      child: ScaffoldMessenger(
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: CustomAppBar(
            title: 'Xin chào ${username ?? ''} !',
            showBackArrow: true,
            onBackTap: () async {
              _showLogoutDialog();
            },
            actionWidgets: [
              Padding(
                padding: const EdgeInsets.only(
                  right: 16.0,
                ), // Đảm bảo có khoảng cách hợp lý
                child: PopupMenuButton<int>(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  elevation: 1,
                  onSelected: (value) {
                    switch (value) {
                      case 0:
                        context.read<TasksBloc>().add(
                          SortTaskEvent(sortOption: 0),
                        );
                        break;
                      case 1:
                        context.read<TasksBloc>().add(
                          SortTaskEvent(sortOption: 1),
                        );
                        break;
                      case 2:
                        context.read<TasksBloc>().add(
                          SortTaskEvent(sortOption: 2),
                        );
                        break;
                    }
                  },
                  itemBuilder: (BuildContext context) {
                    return [
                      PopupMenuItem<int>(
                        value: 0,
                        child: Row(
                          children: [
                            SvgPicture.asset(
                              'assets/svgs/calender.svg',
                              width: 15,
                            ),
                            const SizedBox(width: 10),
                            buildText(
                              'Sort by date',
                              kBlackColor,
                              textSmall,
                              FontWeight.normal,
                              TextAlign.start,
                              TextOverflow.clip,
                            ),
                          ],
                        ),
                      ),
                      PopupMenuItem<int>(
                        value: 1,
                        child: Row(
                          children: [
                            SvgPicture.asset(
                              'assets/svgs/task_checked.svg',
                              width: 15,
                            ),
                            const SizedBox(width: 10),
                            buildText(
                              'Completed tasks',
                              kBlackColor,
                              textSmall,
                              FontWeight.normal,
                              TextAlign.start,
                              TextOverflow.clip,
                            ),
                          ],
                        ),
                      ),
                      PopupMenuItem<int>(
                        value: 2,
                        child: Row(
                          children: [
                            SvgPicture.asset('assets/svgs/task.svg', width: 15),
                            const SizedBox(width: 10),
                            buildText(
                              'Pending tasks',
                              kBlackColor,
                              textSmall,
                              FontWeight.normal,
                              TextAlign.start,
                              TextOverflow.clip,
                            ),
                          ],
                        ),
                      ),
                    ];
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(right: 20),
                    child: SvgPicture.asset('assets/svgs/filter.svg'),
                  ),
                ),
              ),
            ],
          ),

          body: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => FocusScope.of(context).unfocus(),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: BlocConsumer<TasksBloc, TasksState>(
                listener: (context, state) {
                  if (state is LoadTaskFailure) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(getSnackBar(state.error, kRed));
                  }

                  if (state is AddTaskFailure || state is UpdateTaskFailure) {
                    context.read<TasksBloc>().add(FetchTaskEvent());
                  }
                },
                builder: (context, state) {
                  if (state is TasksLoading) {
                    return const Center(child: CupertinoActivityIndicator());
                  }

                  if (state is LoadTaskFailure) {
                    return Center(
                      child: buildText(
                        state.error,
                        kBlackColor,
                        textMedium,
                        FontWeight.normal,
                        TextAlign.center,
                        TextOverflow.clip,
                      ),
                    );
                  }

                  if (state is FetchTasksSuccess) {
                    return state.tasks.isNotEmpty || state.isSearching
                        ? Column(
                          children: [
                            BuildTextField(
                              hint: "Search recent task",
                              controller: searchController,
                              inputType: TextInputType.text,
                              prefixIcon: const Icon(
                                Icons.search,
                                color: kGrey2,
                              ),
                              fillColor: kWhiteColor,
                              onChange: (value) {
                                context.read<TasksBloc>().add(
                                  SearchTaskEvent(keywords: value),
                                );
                              },
                            ),
                            const SizedBox(height: 20),
                            Expanded(
                              child: ListView.separated(
                                shrinkWrap: true,
                                itemCount: state.tasks.length,
                                itemBuilder: (context, index) {
                                  return TaskItemView(
                                    taskModel: state.tasks[index],
                                  );
                                },
                                separatorBuilder: (
                                  BuildContext context,
                                  int index,
                                ) {
                                  return const Divider(color: kGrey3);
                                },
                              ),
                            ),
                          ],
                        )
                        : Center(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SvgPicture.asset(
                                'assets/svgs/tasks.svg',
                                height: size.height * .20,
                                width: size.width,
                              ),
                              const SizedBox(height: 50),
                              buildText(
                                'Schedule your tasks',
                                kBlackColor,
                                textBold,
                                FontWeight.w600,
                                TextAlign.center,
                                TextOverflow.clip,
                              ),
                              buildText(
                                'Manage your task schedule easily\nand efficiently',
                                kBlackColor.withOpacity(.5),
                                textSmall,
                                FontWeight.normal,
                                TextAlign.center,
                                TextOverflow.clip,
                              ),
                            ],
                          ),
                        );
                  }
                  return Container();
                },
              ),
            ),
          ),
          floatingActionButton: FloatingActionButton(
            child: const Icon(Icons.add_circle, color: Colors.blue),
            onPressed: () {
              Navigator.pushNamed(context, Pages.createNewTask);
            },
          ),

          bottomNavigationBar: Material(
            elevation: 10,
            color: Colors.white,
            child: BottomNavigationBar(
              backgroundColor: Colors.white,
              elevation: 0,
              currentIndex: selectedIndex,
              onTap: _onItemTapped, //Gọi hàm để chuyển trang
              selectedItemColor: Colors.blue[800],
              unselectedItemColor: Colors.blue[200],
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: 'Trang chủ',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.calendar_month),
                  label: 'Lịch',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person),
                  label: 'Cá nhân',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.chat_bubble),
                  label: 'AI Chat',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
