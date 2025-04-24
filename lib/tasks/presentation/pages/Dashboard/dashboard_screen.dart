
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:time_management/components/custom_app_bar.dart';
import 'package:time_management/utils/color_palette.dart';

import '../../../../utils/util.dart';
import '../../bloc/tasks_bloc.dart';


class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<StatefulWidget> createState() => _DashboardScreenState();

}

class _DashboardScreenState extends State<DashboardScreen> {
  int touchedIndex = 0;

  double completedPercent =0;
  double pendingPercent =0;
  String selectedrange= 'Select time';
  bool isLoading = false;
  final List<String> timeRanges = ['Month', 'Year'];
  late Widget pendingIcon;
  late Widget completedIcon;

  @override
  void initState(){
    super.initState();
    pendingIcon = SvgPicture.asset(
      'assets/svgs/task.svg',
      width: 40,
      height: 40,
    );

    completedIcon = SvgPicture.asset(
      'assets/svgs/task_checked.svg',
      width: 40,
      height: 40,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getTaskState();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: kWhiteColor,
        appBar: const CustomAppBar(title: 'Dashboard'),
        body: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () => FocusScope.of(context).unfocus(),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: BlocConsumer<TasksBloc, TasksState>(
              listener: (context, state) {
                if (state is UpdateTaskFailure) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    getSnackBar(state.error, kRed),
                  );
                }
                if (state is UpdateTaskSuccess) {
                  Navigator.pop(context);
                }
              },
              builder: (context, state) {
                return SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,

                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Task summary",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          PopupMenuButton<int>(
                            onSelected: (value) {
                              setState(() {
                                if(value ==0)
                                {
                                  selectedrange = 'Month';
                                }
                                else
                                {
                                  selectedrange= 'Year';
                                }
                              });

                              getTaskState();
                            },
                            itemBuilder: (BuildContext context) => [
                              PopupMenuItem<int>(
                                value: 0,
                                child: Text('Month'),
                              ),
                              PopupMenuItem<int>(
                                value: 1,
                                child: Text('Year'),
                              ),
                            ],
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                border: Border.all(color: Colors.grey),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    selectedrange.isEmpty ? 'Select Time' : selectedrange,
                                    style: TextStyle(fontSize: 14, color: Colors.black),
                                  ),
                                  Icon(Icons.arrow_drop_down),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16,),
                      AspectRatio(
                        aspectRatio: 1.3,
                        child: PieChart(
                          PieChartData(
                            pieTouchData: PieTouchData(
                              touchCallback: (FlTouchEvent event, pieTouchResponse) {
                                setState(() {
                                  if (!event.isInterestedForInteractions ||
                                      pieTouchResponse == null ||
                                      pieTouchResponse.touchedSection == null) {
                                    touchedIndex = -1;
                                    return;
                                  }
                                  touchedIndex =
                                      pieTouchResponse.touchedSection!.touchedSectionIndex;
                                });
                              },
                            ),
                            borderData: FlBorderData(
                              show: false,
                            ),
                            sectionsSpace: 0,
                            centerSpaceRadius: 0,
                            sections: showingSections(),

                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Column(
                          children: [
                            Text(
                              'Completed: ${completedPercent.toStringAsFixed(1)}%',
                              style: TextStyle(fontSize: 18, color: Colors.green),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Pending: ${pendingPercent.toStringAsFixed(1)}%',
                              style: TextStyle(fontSize: 18, color: Colors.blue),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Future<void> getTaskState() async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) {
        print("❌ UID is null.");
        return;
      }
      DateTime now = DateTime.now();
      DateTime startDate;
      DateTime endDate;

      switch (selectedrange) {
        case 'Month':
          startDate = DateTime(now.year, now.month, 1); // Ngày đầu tháng
          endDate = DateTime(now.year, now.month + 1, 0, 23, 59, 59); // Ngày cuối tháng
          break;
        case 'Year':
          startDate = DateTime(now.year, 1, 1); // Ngày đầu năm
          endDate = DateTime(now.year, 12, 31, 23, 59, 59); // Ngày cuối năm
          break;
        default:
          startDate = now;
          endDate = now;
      }

      final taskSnapshot = await FirebaseFirestore.instance
          .collection('tasks')
          .where('createById', isEqualTo: uid)
          .where('startDateTime', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('startDateTime', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .get();

      final allTasks = taskSnapshot.docs;

      final completedTask = allTasks.where((task) => task['completed'] == true).length;
      final pendingTask = allTasks.length - completedTask;

      double newCompleted = 0;
      double newPending = 0;
      if (allTasks.isNotEmpty) {
        newCompleted = (completedTask / allTasks.length) * 100;
        newPending = (pendingTask / allTasks.length) * 100;
      }

      if (mounted) {
        setState(() {
          completedPercent = newCompleted;
          pendingPercent = newPending;
          isLoading = false;
        });
      }
    } catch (e, stack) {
      print("🔥 Lỗi trong getTaskState(): $e");
      print(stack);
    }
  }
  List<PieChartSectionData> showingSections() {
    // Kiểm tra nếu không có dữ liệu hoặc dữ liệu bị lỗi (NaN)
    final hasData = completedPercent + pendingPercent > 0;

    if (!hasData) {
      return [
        PieChartSectionData(
          color: Colors.grey.shade300,
          value: 1,
          title: '0.0%',
          radius: 100,
          titleStyle: const TextStyle(
            fontSize: 18,
            color: Colors.green,
            fontWeight: FontWeight.bold,
          ),
        ),
      ];
    }

    return [
      PieChartSectionData(
        color: Colors.blue,
        value: pendingPercent.isNaN ? 0 : pendingPercent,
        title: '${pendingPercent.toStringAsFixed(1)}%',
        radius: touchedIndex == 0 ? 110.0 : 100.0,
        titleStyle: TextStyle(
          fontSize: touchedIndex == 0 ? 20.0 : 16.0,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          shadows: const [Shadow(color: Colors.black, blurRadius: 2)],
        ),
      ),
      PieChartSectionData(
        color: Colors.yellow,
        value: completedPercent.isNaN ? 0 : completedPercent,
        title: '${completedPercent.toStringAsFixed(1)}%',
        radius: touchedIndex == 1 ? 110.0 : 100.0,
        titleStyle: TextStyle(
          fontSize: touchedIndex == 1 ? 20.0 : 16.0,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          shadows: const [Shadow(color: Colors.black, blurRadius: 2)],
        ),
      ),
    ];
  }
}
class _Badge extends StatelessWidget {
  const _Badge(
      this.svgAsset, {
        required this.size,
        required this.borderColor,
      });
  final String svgAsset;
  final double size;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: PieChart.defaultDuration,
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(
          color: borderColor,
          width: 2,
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: .5),
            offset: const Offset(3, 3),
            blurRadius: 3,
          ),
        ],
      ),
      padding: EdgeInsets.all(size * .15),
      child: Center(
        child: SvgPicture.asset(
          svgAsset,
        ),
      ),
    );
  }
}
