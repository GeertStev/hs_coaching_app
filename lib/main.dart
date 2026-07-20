import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hs_coaching_app/core/providers/riverpod_config.dart';
import 'package:hs_coaching_app/features/auth/presentation/auth_gate.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(
    const ProviderScope(
      retry: appProviderRetry,
      observers: [AppProviderObserver()],
      child: MainApp(),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HS Coaching Sketch',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        // Geen M3 "scrolled under"-tint: AppBar behoudt zijn kleur bij scrollen.
        appBarTheme: const AppBarTheme(scrolledUnderElevation: 0),
      ),
      home: const AuthGate(),
    );
  }
}


// ToDo's
// ALGEMEEN
//  Freezed voor andere domain modellen?
//  Gebruikers implementeren
//  Screen control -> scrollen door features

// Screen feature
//  Tags beheren
//
/// SKETCH
///  Selecteren van voorwerp -> wijzigen van kleur en fill
///  Selecteren van voorwerp -> wijzigen van hoekpunten
///  Puck kleur
///  Formaties
///  Gestreepte lijnen
///  Achtergronden beheren
///
/// IMAGE
///  Snackbar blijft op scherm na archive
///
/// CHRONO
///  Lap time
///  Countdown selectiebox
///
/// TABATA
///  Titel voor de set
///  Snelkoppelingen naar standaard sets
///  Elke set heeft x aantal seconden minder (beeptest)
///  Meerdere tabata's koppelen na elkaar? 
///  Moeten deze op club of op scherm niveau worden opgeslagen? Zie ook timer.
///
/// TIMER
///  Inplannen van trainingssessies
///  Sessies worden op club niveau opgeslagen?
///
/*

TRAINING FEATURE
De trainer maakt vooraf aan de training een schema op. Deze worden in een lijst opgeslagen, een training kan gedupliceerd en bewerkt worden.
Voorbeeld van een training:
5 minuten opwarmen: Tabata
10 lengtes half onder, half boven; 10 lengtes onder; 10 lengtes met plankje: Text
10 lengtes beeptest: 25 seconden voor de eerste lengte, volgende lengte 1 seconde minder, eindigend bij 15 seconden voor de laatste lengte. Rust tussen de lengtes van 5 seconden: Tabata
10 minuten tacktiek: Sketch/Image/Text
15 minuten techniek: Text
20 minuten wedstrijd: Team&Game

De trainer start de training en kan daarna doorheen de training navigeren.
Er is een overzicht van de volledige training, de trainer klikt doorheen de training en de juiste module wordt geladen met eventueel de juiste instellingen

*/
///
///
/// GAME
///  Stijl nog wat aanpassen van puntenweergave
///
/// Timer
/// Tags and search

// AI prompt
/*
Je bent een Senior Flutter ontwikkelaar. Je taak is om een bestaande Flutter codebase, die gebruik maakt van Riverpod en Firebase, te schrijven of te refactoren naar een schonere, beter testbare architectuur. 

Context & Architectuur Richtlijnen (Onderwaterhockey Coaching App) 
1) App Doel: Een realtime coaching- tactiek- en schetsbordapp voor onderwaterhockeycoaches. Wijzigingen in de app synchroniseren realtime via Firebase Firestore/Storage naar een apart live-scherm (gedraaid via een web-based Flutter app). 

2) Belangrijke UI Eis: Optimistic UI Updates. Acties moeten direct lokaal in de Riverpod state worden doorgevoerd (state = AsyncData(...)) vóórdat de Firebase write is bevestigd, om UI-haperingen en netwerklatency te elimineren. Bij een netwerkfout vindt er eventueel een rollback plaats.
2.1) Strikte flutter_svg 2.0 regels.
2.2) Strikte Riverpod 3.0 Regels.
Geen Family...Notifier klassen meer: Klassen als FamilyNotifier, FamilyAsyncNotifier en FamilyStreamNotifier zijn verwijderd. Gebruik altijd de standaard basisklassen (Notifier, AsyncNotifier, StreamNotifier).
Constructor-gebaseerde Families: Geef family-argumenten (zoals sketchId) mee via de constructor van de Notifier klasse en sla ze op als instance variables. 
Lege build() methode: De build() methode van een Notifier krijgt geen parameters meer. Raadpleeg de via de constructor opgeslagen variabelen direct in de body. 
Provider syntaxis: Binnen NotifierProvider.family of StreamNotifierProvider.family krijgt de builder-functie geen ref meer mee. De functie accepteert enkel het family-argument (bijv. (sketchId) => JouwNotifier(sketchId) of via de tear-off JouwNotifier.new). Geen valueOrNull: Gebruik op AsyncValue simpelweg .value in plaats van .valueOrNull om de nullable waarde op te halen. 
Command Patroon: Commando's (execute/undo) ontvangen een Ref in plaats van een kale repository, zodat ze rechtstreeks de notifier van de data-stream kunnen aanspreken voor lokale, optimistische updates. 

3) Opdracht: 

*/