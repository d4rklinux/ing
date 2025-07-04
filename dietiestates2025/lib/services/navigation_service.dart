
import 'package:flutter/material.dart';

import '../pages/user/user_visits_page.dart';
import '../pages/user/user_offer_page.dart';
import '../pages/user/user_notification_page.dart';
import '../pages/user/user_menu_page.dart';
import '../pages/user/user_home_page.dart';

import '../pages/agent/agent_home_page.dart';
import '../pages/agent/agent_offer_page.dart';
import '../pages/agent/agent_insert_page.dart';
import '../pages/agent/agent_visits_page.dart';
import '../pages/agent/agent_menu_page.dart';


class NavigationService {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  static void navigateTo(Widget page) {
    navigatorKey.currentState?.pushReplacement(
      MaterialPageRoute(builder: (context) => page),
    );
  }

  // Navigazione per utenti normali
  static void navigateToBottomBarPage(int index) {
    switch (index) {
      case 0:
        navigateTo(const UserHomePage());
        break;
      case 1:
        navigateTo(const UserVisitsPage());
        break;
      case 2:
        navigateTo(const UserNotificationPage(query: '',));
        break;
      case 3:
        navigateTo(const UserOfferPage(query: 'Offerta'));
        break;
      case 4:
        navigateTo(const UserMenuPage(query: 'Profilo'));
        break;
    }
  }

  // Navigazione per agenti
  static void navigateToAgentBottomBarPage(int index) {
    switch (index) {
      case 0:
        navigateTo(const AgentHomePage());
        break;
      case 1:
        navigateTo(const AgentVisitsPage());
        break;
      case 2:
        navigateTo(const AgentInsertAddPage());
        break;
      case 3:
        navigateTo(const AgentOfferPage());
        break;
      case 4:
        navigateTo(const AgentMenuPage(query: ''));
        break;
    }
  }
}
