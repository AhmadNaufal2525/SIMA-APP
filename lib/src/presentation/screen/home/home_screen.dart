import 'dart:async';

import 'package:buttons_tabbar/buttons_tabbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:local_session_timeout/local_session_timeout.dart';
import 'package:material_dialogs/material_dialogs.dart';
import 'package:material_dialogs/widgets/buttons/icon_button.dart';
import 'package:material_dialogs/widgets/buttons/icon_outline_button.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sima_app/src/datasource/aset_remote_datasource.dart';
import 'package:sima_app/src/datasource/auth_remote_datasource.dart';
import 'package:sima_app/src/model/peminjaman_response_model.dart';
import 'package:sima_app/src/model/pengembalian_response_model.dart';
import 'package:sima_app/src/presentation/bloc/peminjaman/peminjaman_bloc.dart';
import 'package:sima_app/src/presentation/bloc/pengembalian/pengembalian_bloc.dart';
import 'package:sima_app/src/presentation/router/routes.dart';
import 'package:sima_app/src/presentation/screen/home/widgets/empty_data_widget.dart';
import 'package:sima_app/src/presentation/screen/home/widgets/pengajuan_form_widget.dart';
import 'package:sima_app/src/presentation/screen/home/widgets/pengajuan_peminjaman_widget.dart';
import 'package:sima_app/src/presentation/screen/home/widgets/pengajuan_pengembalian_widget.dart';
import 'package:sima_app/src/presentation/screen/init/initial_screen.dart';
import 'package:sima_app/src/utils/colors.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  final String username;
  final String userId;
  final String token;

  const HomeScreen({
    super.key,
    required this.username,
    required this.userId,
    required this.token,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthRemoteDataSource authDataSource = AuthRemoteDataSource();
  int selectedTabIndex = 0;
  final peminjamanBloc = PeminjamanBloc(
    asetRemoteDataSource: AsetRemoteDataSource(),
  );
  final pengembalianBloc = PengembalianBloc(
    asetRemoteDataSource: AsetRemoteDataSource(),
  );

  final sessionConfig = SessionConfig(
    invalidateSessionForAppLostFocus: const Duration(minutes: 5),
    invalidateSessionForUserInactivity: const Duration(hours: 1),
  );

  @override
  void initState() {
    super.initState();
    sessionConfig.stream.listen((SessionTimeoutState timeoutEvent) {
      if (timeoutEvent == SessionTimeoutState.userInactivityTimeout) {
        Navigator.of(context).pushReplacementNamed(Routes.initScreen);
      } else if (timeoutEvent == SessionTimeoutState.appFocusTimeout) {
        showTimeoutDialog();
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.token.isEmpty) {
      showTimeoutDialog();
    }
  }

  void showTimeoutDialog() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isLoggedIn', false);
    prefs.remove('token');

    Future.delayed(Duration.zero, () {
      Dialogs.materialDialog(
        msg: 'Sesi Anda Telah Berakhir',
        title: 'Silahkan Login Kembali',
        color: Colors.white,
        context: context,
        actions: [
          IconsButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushReplacementNamed(Routes.initScreen);
            },
            text: 'OK',
            iconData: Icons.check_circle,
            color: Colors.green,
            textStyle: const TextStyle(color: Colors.white),
            iconColor: Colors.white,
          ),
        ],
      );
    });
  }

  Future<void> refreshData() async {
    peminjamanBloc.add(
      GetPeminjamanEvent(userId: widget.userId, token: widget.token),
    );
    pengembalianBloc.add(
      GetPengembalianEvent(userId: widget.userId, token: widget.token),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SessionTimeoutManager(
      sessionConfig: sessionConfig,
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => peminjamanBloc
              ..add(
                GetPeminjamanEvent(userId: widget.userId, token: widget.token),
              ),
          ),
          BlocProvider(
            create: (context) => pengembalianBloc
              ..add(
                GetPengembalianEvent(
                    userId: widget.userId, token: widget.token),
              ),
          ),
        ],
        child: Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            elevation: 0,
            backgroundColor: AppColor.primaryColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(15.r),
                bottomRight: Radius.circular(15.r),
              ),
            ),
            toolbarHeight: 120.h,
            titleSpacing: 0,
            title: Padding(
              padding: const EdgeInsets.all(16.0).w,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Halo, ${widget.username} 👋',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(
                        height: 8.h,
                      ),
                      Text(
                        DateFormat("dd MMM, yyyy").format(DateTime.now()),
                        style: TextStyle(fontSize: 16.sp, color: Colors.white),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Image.asset(
                        'assets/images/logo.png',
                        color: Colors.white,
                        width: 100.w,
                        height: 80.h,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          backgroundColor: AppColor.backgroundColor,
          body: SingleChildScrollView(
            child: RefreshIndicator(
              onRefresh: refreshData,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(12.0).w,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            PengajuanFormWidget(
                              username: widget.username,
                              token: widget.token,
                            ),
                            SizedBox(
                              height: 14.h,
                            ),
                            Text(
                              'Tracking Pengajuan',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20.sp,
                              ),
                            ),
                            SizedBox(
                              height: 10.h,
                            ),
                            Text(
                              'Lihat progress pengajuan barang disini',
                              style: TextStyle(
                                fontSize: 14.sp,
                              ),
                            ),
                            SizedBox(
                              height: 16.h,
                            ),
                            DefaultTabController(
                              length: 2,
                              child: Column(
                                children: [
                                  ButtonsTabBar(
                                    radius: 30.r,
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 46.r,
                                    ),
                                    backgroundColor: AppColor.primaryColor,
                                    unselectedBackgroundColor:
                                        const Color(0xffFF9839),
                                    unselectedLabelStyle:
                                        const TextStyle(color: Colors.white),
                                    labelStyle: const TextStyle(
                                      color: Colors.white,
                                    ),
                                    tabs: const [
                                      Tab(
                                        text: "Peminjaman",
                                      ),
                                      Tab(
                                        text: "Pengembalian",
                                      ),
                                    ],
                                    onTap: (index) {
                                      setState(() {
                                        selectedTabIndex = index;
                                      });
                                    },
                                  ),
                                  if (selectedTabIndex == 0)
                                    BlocBuilder<PeminjamanBloc,
                                        PeminjamanState>(
                                      builder: (context, state) {
                                        List<Peminjaman>? peminjaman;
                                        if (state is PeminjamanFailed) {
                                          return const Center(
                                            child: EmptyDataWidget(),
                                          );
                                        } else if (state is PeminjamanSuccess) {
                                          peminjaman = state
                                              .peminjamanResponse.peminjaman!
                                              .toList();
                                          return PengajuanPeminjamanWidget(
                                            pengajuanData: peminjaman,
                                            selectedTabIndex: selectedTabIndex,
                                          );
                                        }
                                        return Center(
                                          child: SpinKitFadingFour(
                                            color: AppColor.primaryColor,
                                            size: 50.0.sp,
                                          ),
                                        );
                                      },
                                    ),
                                  if (selectedTabIndex == 1)
                                    BlocBuilder<PengembalianBloc,
                                        PengembalianState>(
                                      builder: (context, state) {
                                        List<Pengembalian>? pengembalian;
                                        if (state is PengembalianFailed) {
                                          return const Center(
                                            child: EmptyDataWidget(),
                                          );
                                        } else if (state
                                            is PengembalianSuccess) {
                                          pengembalian = state
                                              .pengembalianResponse
                                              .pengembalian!
                                              .toList();
                                          return PengajuanPengembalianWidget(
                                            pengajuanData: pengembalian,
                                            selectedTabIndex: selectedTabIndex,
                                          );
                                        }
                                        return Center(
                                          child: SpinKitFadingFour(
                                            color: AppColor.primaryColor,
                                            size: 50.0.sp,
                                          ),
                                        );
                                      },
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 30.h,
                  ),
                ],
              ),
            ),
          ),
          floatingActionButton: FloatingActionButton(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.r),
            ),
            backgroundColor: AppColor.primaryColor,
            onPressed: () {
              Dialogs.materialDialog(
                msg: 'Anda yakin ingin logout?',
                title: "Logout",
                color: Colors.white,
                context: context,
                actions: [
                  IconsOutlineButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    text: 'Cancel',
                    iconData: Icons.cancel_outlined,
                    textStyle: const TextStyle(color: Colors.grey),
                    iconColor: Colors.grey,
                  ),
                  IconsButton(
                    onPressed: () {
                      authDataSource.signOut(context, widget.token);
                      Future.delayed(const Duration(seconds: 1), () {
                        setState(() {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (BuildContext context) =>
                                  const InitialScreen(),
                            ),
                            (route) => false,
                          );
                        });
                      });
                    },
                    text: 'Logout',
                    iconData: Icons.logout_rounded,
                    color: Colors.red,
                    textStyle: const TextStyle(color: Colors.white),
                    iconColor: Colors.white,
                  ),
                ],
              );
            },
            child: const Icon(
              Icons.logout_rounded,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
