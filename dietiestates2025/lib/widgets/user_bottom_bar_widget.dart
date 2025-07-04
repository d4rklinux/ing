import 'package:flutter/material.dart';

class UserBottomBar extends StatefulWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const UserBottomBar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  State<UserBottomBar> createState() => _UserBottomBarState();
}

class _UserBottomBarState extends State<UserBottomBar> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      // Sfondo bianco dietro la linea e la BottomNavigationBar
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Divider(
            height: 1,
            thickness: 1,
            color: Colors.black, // Linea nera
          ),
          BottomNavigationBar(
            currentIndex: widget.selectedIndex,
            onTap: widget.onItemTapped,
            type: BottomNavigationBarType.fixed,
            selectedItemColor: Colors.blue,
            unselectedItemColor: Colors.black,
            backgroundColor: Colors.white,
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Cerca'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.calendar_month), label: 'Visita'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.chat_bubble), label: 'Notifiche'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.monetization_on), label: 'Offerta'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.grid_view), label: 'Profilo'),
            ],
          ),
        ],
      ),
    );
  }

}
