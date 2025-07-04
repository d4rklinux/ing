import 'package:flutter/material.dart';

class AgentBottomBar extends StatefulWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const AgentBottomBar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  State<AgentBottomBar> createState() => _AgentBottomBarState();
}

class _AgentBottomBarState extends State<AgentBottomBar> {
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
                  icon: Icon(Icons.calendar_month), label: 'Visite'),
              BottomNavigationBarItem(icon: Icon(Icons.add), label: 'Immobile'),
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
