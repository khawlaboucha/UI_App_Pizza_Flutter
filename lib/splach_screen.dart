

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SplachScreen extends StatelessWidget {
  const SplachScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration:const BoxDecoration(
          image:DecorationImage(
            image: AssetImage('assets/back-pizza-s2.jpg'),
            fit: BoxFit.cover
          )),
         child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 5,sigmaY: 5),
          child: Center(
            child: Text(
              'Pizza House',
                  textAlign: TextAlign.center,
              style: GoogleFonts.actor(fontSize: 35,color: Colors.white),
            ),
          ),),
      ),

    );
  }
}
