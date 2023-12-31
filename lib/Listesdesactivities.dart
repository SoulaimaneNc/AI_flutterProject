import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ListActivity extends StatefulWidget {
  const ListActivity({super.key});

  @override
  _ListActivityState createState() => _ListActivityState();
}

class _ListActivityState extends State<ListActivity> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Liste des Activités'),
          backgroundColor: const Color.fromARGB(255, 174, 175, 177),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'All'),
              Tab(text: 'categorie1'),
              Tab(text: 'categorie2'),
            ],
          ),
        ),
        body: ActivityList(),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
            if (_currentIndex == 0) {
              // Navigate to the All tab
              // You can add additional logic here if needed
            } else if (_currentIndex == 1) {
              // Navigate to the Add tab
              Navigator.pushNamed(context, '/addActivity');
            } else if (_currentIndex == 2) {
              // Navigate to the Profile tab
              Navigator.pushNamed(context, '/Profile');
            }
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.list),
              label: 'Listes des Activitées',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.add),
              label: 'Ajout',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_2_rounded),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}

class ActivityList extends StatefulWidget {
  const ActivityList({super.key});

  @override
  ActivityListState createState() => ActivityListState();
}

class ActivityListState extends State<ActivityList> {
  String selectedCategory = 'All';

  @override
  Widget build(BuildContext context) {
    return TabBarView(
      children: [
        buildListView('List for All'),
        buildListView('category 1'),
        buildListView('category 2'),
      ],
    );
  }

  Widget buildListView(String category) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('Activity').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        if (!snapshot.hasData) {
          return const CircularProgressIndicator();
        }

        var activities = snapshot.data!.docs;

        var filteredActivities = activities.where((activity) {
          var activityData = activity.data() as Map<String, dynamic>;
          if (category == 'all') {
            return true;
          } else {
            return activityData['category']==
                category;
          }
        }).toList();

        return ListView.builder(
          itemCount: filteredActivities.length,
          itemBuilder: (context, index) {
            var activity =
                filteredActivities[index].data() as Map<String, dynamic>;

            return Card(
              elevation: 3.0,
              margin: const EdgeInsets.all(8.0),
              child: ListTile(
                title: Text(activity['Title']),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Location: ${activity['lieu']}'),
                    Text('Price: ${activity['prix']}'),
                  ],
                ),
                leading: Image.memory(
                  base64Decode(activity['img']),
                  fit: BoxFit.cover,
                  width: 56.0,
                  height: 56.0,
                ),
                onTap: () {
                  showProductDetails(context, activity);
                },
              ),
            );
          },
        );
      },
    );
  }

  void showProductDetails(BuildContext context, Map<String, dynamic> activity) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(activity['titre']),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Location: ${activity['lieu']}'),
              Text('Category: ${activity['categorie']}'),
              Text('Price: ${activity['prix']}'),
              Text('Number of People: ${activity['nbrPersonnes']}'),
              Image.memory(
                base64Decode(activity['img']),
                fit: BoxFit.cover,
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Filter Activities'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                children: [
                  const Text('Select Category:'),
                  DropdownButton<String>(
                    value: selectedCategory,
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedCategory = newValue!;
                      });
                    },
                    items:
                        ['All', 'categorie1', 'categorie2'].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ],
              );
            },
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Apply Filter'),
            ),
          ],
        );
      },
    );
  }
}
