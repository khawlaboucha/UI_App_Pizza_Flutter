import 'dart:core';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:pizza_app_animation/consts.dart';
import 'package:pizza_app_animation/models/pizza_model.dart';
import 'package:animated_digit/animated_digit.dart';
import 'package:pizza_app_animation/models/topping_model.dart';

class PizzaPage extends StatefulWidget {
  const PizzaPage({Key? key}) : super(key: key);
  @override

  @override
  State<PizzaPage> createState() => _PizzaPageState();
}

class _PizzaPageState extends State<PizzaPage> with TickerProviderStateMixin {
  int currentPizza = 0;
  int selectedSize = 0;
  int total = 1;
  List<String> sizeOptions = ['S', 'M', 'L'];

  PageController? toppingController;
  double viewPortFractionTopping = 0.25;
  double? pageOffsetTopping = 2;

  PageController? pizzaController;
  double viewPortFractionPizza = 0.9;
  double? pageOffsetPizza = 0;

  double plateAngle = 0.0;

  AnimationController? titleController;
  List<Topping> selectedTopping = [];
  final _notifierToping = ValueNotifier(false);
  @override
  void initState() {

    // TODO: implement initState
    toppingController = PageController(
        initialPage: 2, viewportFraction: viewPortFractionTopping)
      ..addListener(() {
        setState(() {
          pageOffsetTopping = toppingController!.page;
        });
      });
    pizzaController =
    PageController(initialPage: 0, viewportFraction: viewPortFractionPizza)
      ..addListener(() {
        setState(() {
          pageOffsetPizza = pizzaController!.page;
        });
      });
    titleController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 200));
    animationTopping = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    super.initState();
  }

  late final Animation<Offset> _offsetTitle = Tween<Offset>(
      begin: const Offset(0, 0.5), end: const Offset(0, 0))
      .animate(CurvedAnimation(parent: titleController!, curve: Curves.linear));
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    toppingController!.dispose();
    pizzaController!.dispose();
    titleController!.dispose();
    animationTopping!.dispose();
  }

  final List<Animation> _listAnimation = [];
  AnimationController? animationTopping;
  _buildToppingAnimation() {
    _listAnimation.clear();
    for (var i = 0; i < 12; i++) {
      var begin = 0.0;
      var end = 0.0;
      begin = Random().nextDouble();
      end = Random().nextDouble();
      while (begin > end) {
        begin = Random().nextDouble();
        end = Random().nextDouble();
      }
      _listAnimation.add(CurvedAnimation(
          parent: animationTopping!,
          curve: Interval(begin, end, curve: Curves.decelerate)));
    }
  }

  BoxConstraints? pizzaContraints;
  Widget _buildAddedTopping() {
    List<Widget> toppingWidget = [];
    if (selectedTopping.isNotEmpty) {
      for (var i = 0; i < selectedTopping.length; i++) {
        Topping topping = selectedTopping[i];
        final image = Image.asset(topping.onPizza, width: 30, height: 30);
        for (var j = 0; j < topping.offset.length; j++) {
          final animation = _listAnimation[j];
          final position = topping.offset[j];
          final positionX = position.dx;
          final positionY = position.dy;
          if (selectedTopping.length - 1 == i) {
            double fromX = 0.0, fromY = 0.0;
            if (j < 1) {
              fromX = -pizzaContraints!.maxWidth * (1 - animation.value);
            } else if (j < 2) {
              fromX = pizzaContraints!.maxWidth * (1 - animation.value);
            } else if (j < 4) {
              fromY = -pizzaContraints!.maxHeight * (1 - animation.value);
            } else {
              fromY = pizzaContraints!.maxHeight * (1 - animation.value);
            }
            var opaity = animation.value;
            if (animation.value > 0) {
              toppingWidget.add(Opacity(
                opacity: opaity,
                child: Transform(
                  transform: Matrix4.identity()
                    ..translate(
                        fromX + pizzaContraints!.maxWidth / 2 * positionX,
                        fromY + pizzaContraints!.maxWidth / 2 * positionY),
                  child: image,
                ),
              ));
            }
          }
          toppingWidget.add(Transform(
            transform: Matrix4.identity()
              ..translate(pizzaContraints!.maxWidth / 2 * positionX,
                  pizzaContraints!.maxWidth / 2 * positionY),
            child: image,
          ));
        }
      }
      return Stack(children: toppingWidget);
    } else {
      return SizedBox.fromSize();
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        backgroundColor:white,
        elevation: 0,
        centerTitle: true,
        leading: Icon(
          Icons.arrow_back_rounded,
          color: black.withOpacity(0.5),
        ),
        title: AnimatedSwitcher(
          duration: const Duration(milliseconds: 100),
          transitionBuilder: (child, animation) {
            return SlideTransition(position: _offsetTitle, child: child);
          },
          child: Column(
            children: [
              Text(
                dataPizza[currentPizza].name,
                style: font.copyWith(
                    fontSize: 24, fontWeight: FontWeight.bold, color: black),
              ),
              Text(
                dataPizza[currentPizza].desc,
                overflow: TextOverflow.clip,
                style:
                font.copyWith(fontSize: 14, ),
              )
            ],
          ),
        ),
        actions: [
          Icon(
            Icons.favorite_outline_rounded,
            color: black.withOpacity(0.5),
          ),
          //const SizedBox(width: 20)
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          SizedBox(
            width: size.width,
            height: 360,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Transform.rotate(
                  angle: plateAngle * pi / 180,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      const Bassileat(),
                      const PizzaPlate(),
                      Positioned(
                        bottom: 20,
                        child: ClipPath(
                          clipper: CustomClip(),
                          child: Container(
                            width: 170,
                            height: 30,
                            color: white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                PageView.builder(
                  controller: pizzaController,
                  onPageChanged: (value) {
                    setState(() {
                      currentPizza = value % dataPizza.length;
                      titleController!.forward(from: 0);
                      selectedTopping = [];
                      total = 1;
                    });
                  },
                  itemBuilder: (context, index) {
                    double pizzaAngle = 0.0;
                    if (pizzaController!.position.haveDimensions) {
                      pizzaAngle =
                          index.toDouble() - (pizzaController!.page ?? 0);
                      pizzaAngle = (pizzaAngle * 180).clamp(-360, 360);
                    } else {
                      pizzaAngle = index.toDouble() - (1);
                      pizzaAngle = (pizzaAngle * 180).clamp(-360, 360);
                    }
                    plateAngle = (pizzaAngle / 6) - 30;
                    return Transform.rotate(
                      angle: pizzaAngle * pi / 180,
                      child: Center(
                        child: Transform.scale(
                          scale: pizzaAngle != 0 ? 0.9 : 1,
                          child: DragTarget<Topping>(
                            onAccept: (data) {
                              if (selectedTopping.length < 3) {
                                setState(() {
                                  selectedTopping.add(data);
                                });
                                _notifierToping.value = false;
                                _buildToppingAnimation();
                                animationTopping!.forward(from: 0.0);
                              }
                            },
                            onLeave: (data) {
                              _notifierToping.value = false;
                            },
                            onWillAccept: (data) {
                              _notifierToping.value = false;
                              for (Topping element in selectedTopping) {
                                if (element.compare(data!)) {
                                  return false;
                                }
                              }
                              return true;
                            },
                            builder: (context, candidateData, rejectedData) {
                              return AnimatedContainer(
                                width: selectedSize == 0
                                    ? 240
                                    : selectedSize == 1
                                    ? 260
                                    : 280,
                                height: selectedSize == 0
                                    ? 240
                                    : selectedSize == 1
                                    ? 260
                                    : 280,
                                duration: const Duration(milliseconds: 100),
                                child: LayoutBuilder(
                                  builder: (context, constraints) {
                                    pizzaContraints = constraints;
                                    return Image.asset(
                                        'assets/pizza/${dataPizza[index % dataPizza.length].image}');
                                  },
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    );
                  },
                ),
                Positioned(
                  left: 30,
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        if (total > 1) {
                          total--;
                        }
                      });
                    },
                    child: const QuantityButton(
                      icon: Icon(Icons.remove),
                    ),
                  ),
                ),
                Positioned(
                  right: 30,
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        total++;
                      });
                    },
                    child: const QuantityButton(
                      icon: Icon(Icons.add),
                    ),
                  ),
                ),
                AnimatedBuilder(
                  animation: animationTopping!,
                  builder: (context, child) {
                    return _buildAddedTopping();
                  },
                )
              ],
            ),
          ),
          const SizedBox(height: 10),
          AnimatedDigitWidget(
            value: dataPizza[currentPizza].price[selectedSize] * total,
            prefix: '\$',
            textStyle: font.copyWith(
                fontSize: 28, fontWeight: FontWeight.bold, color: black),
            fractionDigits: 2,
          ),
          const SizedBox(height: 20),
          SizeOptionList(
            sizeOptions: sizeOptions,
            selectedSize: selectedSize,
            newSize: (p0) {
              setState(() {
                selectedSize = p0;
              });
            },
          ),
          const SizedBox(height: 20),
          Text(
            '${selectedTopping.length}/3',
            style: font.copyWith(fontSize: 18, color: black.withOpacity(0.6)),
          ),
          SizedBox(
            height: 200,
            width: size.width,
            child: Stack(
              alignment: Alignment.center,
              children: [
                PageView.builder(
                  controller: toppingController,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: EdgeInsets.only(
                          bottom: (pageOffsetTopping! - index).abs() * 40),
                      child: ToppingItem(
                          topping: toppings[index % toppings.length]),
                    );
                  },
                ),
                Positioned(
                  bottom: 20,
                  child: ClipPath(
                    clipper: CustomClip(),
                    child: Container(
                      height: 35,
                      width: 350,
                      color: black.withOpacity(0.35),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 15),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: brown,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.shopping_cart, color: white),
                        //const SizedBox(width: 10),
                        Text(
                          'Add to Cart',
                          style: font.copyWith(
                              color: white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16),
                        )
                      ],
                    ),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}

class ToppingItem extends StatelessWidget {
  const ToppingItem({
    super.key,required this.topping,
  });
final Topping topping;
  @override
  Widget build(BuildContext context) {
    final child= Center(
      child: Image.asset(topping.onList,
        width: 100,height: 70,
      ),
    );
    return Draggable(
      data:topping,
      feedback:child ,
      child:child,
    );
  }
}

class QuantityButton extends StatelessWidget {
  const QuantityButton({
    super.key,required this.icon,
  });
  final Icon icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
        decoration:BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            offset: const Offset(0,3),
            blurRadius: 2,
            spreadRadius: 1),
            const BoxShadow(
              color: Colors.white,
              offset: Offset(0, -3),
              blurRadius: 2,
              spreadRadius: 1),
          ]
        ),
        child: icon);
  }
}

class Bassileat extends StatelessWidget {
  const Bassileat({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
            right:60,
            top: 40,
            width: 20,
            child: Image.asset('assets/bassil/bassil (6).png')),
        Positioned(
            left:100,
            top: 10,
            width: 10,
            child: Image.asset('assets/bassil/bassil (6).png')),
        Positioned(
            left:40,
            top: 50,
            width: 40,
            child: Image.asset('assets/bassil/bassil (7).png')),
        Positioned(
            left:40,
            top:230,
            width: 10,
            child: Image.asset('assets/bassil/bassil (1).png')),
        Positioned(
            left:65,
            bottom:30,
            width: 30,
            child: Image.asset('assets/bassil/bassil (4).png')),
        Positioned(
            right:90,
            bottom:40,
            width: 10,
            child: Image.asset('assets/bassil/bassil (2).png')),
        Positioned(
            right:40,
            bottom:15,
            width: 30,
            child: Image.asset('assets/bassil/bassil (5).png')),
        Positioned(
            right:20,
            bottom:200,
            width: 10,
            child: Image.asset('assets/bassil/bassil (3).png')),
      ],
    );
  }
}

class PizzaPlate extends StatelessWidget {
  const PizzaPlate({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      width: 300,
      decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.6),
                offset: const Offset(0, 20),
                spreadRadius: 1,
                blurRadius: 15
            )
          ],
          shape: BoxShape.circle,
          image: const DecorationImage(image: AssetImage('assets/pizza-plate.png'),
              fit: BoxFit.cover)
      ),
    );
  }
}

class SizeOptionList extends StatelessWidget {
  const SizeOptionList({
    super.key,
    required this.sizeOptions,
    required this.selectedSize,
    required this.newSize,

  });

  final List<String> sizeOptions;
  final int selectedSize;
  final Function(int)newSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.3),
          offset: const Offset(0,3),
          blurRadius: 2,
          spreadRadius: 1),
        const BoxShadow(
          color: Colors.white,
          offset: Offset(0, -3),
          blurRadius: 2,
          spreadRadius: 1
        ),
      ]),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children:List.generate(sizeOptions.length, (index) =>
            GestureDetector(
              onTap: (){
                newSize(index);
              },
                child: SizeOptionItems(selectedSize: selectedSize==index, sizeOptions: sizeOptions[index]))),
                     ),
    );
  }
}

class SizeOptionItems extends StatelessWidget {
  const SizeOptionItems({
    super.key,
    required this.selectedSize,
    required this.sizeOptions,
  });

  final bool selectedSize;
  final String sizeOptions;

  @override
  Widget build(BuildContext context) {
    return Container(
                 width: 56,height: 56,
                 decoration: BoxDecoration(
                     shape: BoxShape.circle,
                     color: selectedSize ? Colors.yellow :Colors.white
                 ),
                 child: Center(
                   child: Text(
                   sizeOptions,
                   style:font.copyWith(
                   fontSize: 18,
                   fontWeight: FontWeight.bold,
                   color:selectedSize
                   ?Colors.black :Colors.black.withOpacity(0.5)
                    ),
                 ),),
               );
  }
}
 class CustomClip extends CustomClipper<Path>{
  @override
  Path getClip(Size size){
    Path path=Path();
    path.lineTo(0, 0);
    path.quadraticBezierTo(size.width/2,size.height*2,size.width, 0);
    path.lineTo(size.width, 0);
    path.quadraticBezierTo(size.width/2,2*size.height-(size.width/40),0, 0);
    path.close();
    return path;
  }
  @override
   bool shouldReclip(CustomClipper<Path>oldClipper)=>true;
}
