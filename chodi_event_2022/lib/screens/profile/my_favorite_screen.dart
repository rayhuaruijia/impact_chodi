import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chodi_app/models/event.dart';
import 'package:flutter_chodi_app/models/nonprofit_organization.dart';
import 'package:flutter_chodi_app/screens/foryou/event_detail_page.dart';
import 'package:flutter_chodi_app/screens/calendar/event_detail_page2.dart';
import 'package:flutter_chodi_app/screens/foryou/detail_page.dart';
import 'package:quiver/iterables.dart';

// ignore: camel_case_types
class my_favorite_screen extends StatefulWidget {
  const my_favorite_screen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return my_favorite_screenState();
  }
}

// ignore: camel_case_types
class my_favorite_screenState extends State<my_favorite_screen> {
  int typeIndex = 0;

  late Stream userFavorites;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ScrollController _scrollController = ScrollController();

  var favOrgs = [];
  var favEvents = [];

  //Used to build List Widgets
  List<NonProfitOrg> favOrgList = [];
  List<Event> favEventList = [];

  //Was supposed to be used with infinite scrolling pagination
  int lastLoadedFavOrgs = 0;
  int finalLoadedFavOrgs = 0;

  @override
  void initState() {
    super.initState();

    userFavorites = FirebaseFirestore.instance
        .collection("Favorites")
        .doc(_auth.currentUser!.uid)
        .snapshots();

    /*
    userFavorites = FirebaseFirestore.instance
        .collection("EndUsers/" + _auth.currentUser!.uid + "/Favorites")
        .snapshots();
*/
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        //log("Load more");
        _loadMore();
      }
    });
  }

  _loadMore() {
    if (typeIndex == 0) {
    } else {}
  }

  _clearList() {
    favOrgs.clear();
    favOrgList.clear();
    favEvents.clear();
    favEventList.clear();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: userFavorites,
        builder: (context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Container();
          } else {
            _clearList();
            //log(snapshot.data.data().toString());

            for (var i in snapshot.data.data()['Favorite Organizations']) {
              favOrgs.add(i);
            }

            snapshot.data.data()['Favorite Events'].forEach((key, value) {
              //log('Key = $key : Value = $value');

              favEvents.add(['$key', '$value']); //[event id, organization ein]
            });

            //var favOrgsQueryList = partition(favOrgs, 10).toList();
            //var favEventsQueryList = partition(favEvents, 10).toList();

            return Scaffold(
              appBar: AppBar(
                title: const Text('Favorite Communities'),
                centerTitle: true,
                backgroundColor: Colors.grey.shade400,
                elevation: 0,
              ),
              body: Column(
                children: [
                  const SizedBox(height: 20),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        GestureDetector(
                            onTap: () {
                              setState(() {
                                typeIndex = 0;
                              });
                            },
                            child: Container(
                              width: 150,
                              height: 40,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                  color: typeIndex == 0
                                      ? Colors.grey.shade600
                                      : Colors.grey.shade200,
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(20))),
                              child: const Text('Events'),
                            )),
                        GestureDetector(
                            onTap: () {
                              setState(() {
                                typeIndex = 1;
                              });
                            },
                            child: Container(
                              width: 150,
                              height: 40,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                  color: typeIndex == 1
                                      ? Colors.grey.shade600
                                      : Colors.grey.shade200,
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(20))),
                              child: const Text('Organizations'),
                            ))
                      ]),
                  const SizedBox(height: 30),
                  Expanded(
                      child: Container(
                    margin: const EdgeInsets.only(left: 15, right: 15),
                    child: getGridView(),
                  ))
                ],
              ),
            );
          }
        });
  }

  getGridView() {
    switch (typeIndex) {
      case 0:
        return StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection("Events (User)")
                .snapshots(),
            builder: (context, AsyncSnapshot snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Container();
              } else {
                for (var x in snapshot.data!.docs) {
                  for (var y in favEvents) {
                    if (x['eventCode'] == y[0]) {
                      favEventList.add(Event.fromFirestore(x));
                    }
                  }
                }

                return GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                            //横轴元素个数
                            crossAxisCount: 2,
                            //纵轴间距
                            mainAxisSpacing: 20.0,
                            //横轴间距
                            crossAxisSpacing: 20.0,
                            //子组件宽高长度比例
                            childAspectRatio: 0.8),
                    itemBuilder: (context, index) {
                      return buildItemEvent(favEventList[index].name,
                          favEventList[index].imageURL, favEventList[index]);
                    },
                    itemCount: favEventList.length);
              }
            });
      case 1:
        return StreamBuilder(
            stream:
                FirebaseFirestore.instance.collection("Nonprofits").snapshots(),
            builder: (context, AsyncSnapshot snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Container();
              } else {
                for (var i in snapshot.data!.docs) {
                  for (var y in favOrgs) {
                    if (i["EIN"] == y) {
                      favOrgList.add(NonProfitOrg.fromFirestore(i));
                    }
                  }
                }

                return GridView.builder(
                    controller: _scrollController,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                            //横轴元素个数
                            crossAxisCount: 2,
                            //纵轴间距
                            mainAxisSpacing: 20.0,
                            //横轴间距
                            crossAxisSpacing: 20.0,
                            //子组件宽高长度比例
                            childAspectRatio: 0.8),
                    itemBuilder: (context, index) {
                      return buildItemOrg(favOrgList[index].name,
                          favOrgList[index].imageURL!, favOrgList[index]);
                    },
                    itemCount: favOrgList.length);
              }
            });
      default:
    }
  }

  buildItemOrg(String name, String imageURL, NonProfitOrg ngo) {
    return GestureDetector(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return Detail_Page(
              ngoInfo: ngo,
            );
          }));
        },
        child: Container(
          decoration:
              BoxDecoration(border: Border.all(color: Colors.grey.shade400)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 15),
              Container(
                alignment: Alignment.center,
                child: CachedNetworkImage(
                  imageUrl: imageURL,
                  width: 150,
                  height: 150,
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                  child: Container(
                      color: Colors.grey.shade300,
                      alignment: Alignment.center,
                      child: Text(name,
                          style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold)))),
            ],
          ),
        ));
  }

  buildItemEvent(String name, String imageURL, Event event) {
    return GestureDetector(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return event_detail_page(
                ngoEvent: event, ngoName: name, ngoEIN: event.ein);
          }));
        },
        child: Container(
          decoration:
              BoxDecoration(border: Border.all(color: Colors.grey.shade400)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 15),
              Container(
                alignment: Alignment.center,
                child: CachedNetworkImage(
                  imageUrl: imageURL,
                  width: 150,
                  height: 150,
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                  child: Container(
                      color: Colors.grey.shade300,
                      alignment: Alignment.center,
                      child: Text(name,
                          style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold)))),
            ],
          ),
        ));
  }

  buildItem() {
    return GestureDetector(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return event_detail_page2();
          }));
        },
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration:
              BoxDecoration(border: Border.all(color: Colors.grey.shade400)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Adopting/Fostering',
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text('January 1,2022'),
              const SizedBox(height: 8),
              const Text('San Martin,Ca'),
              const SizedBox(height: 15),
              Container(
                  alignment: Alignment.center,
                  child: Image.asset('assets/images/fy.png', width: 120))
            ],
          ),
        ));
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
