import 'package:flutter/material.dart';

class PageFooter extends StatelessWidget {
  const PageFooter({super.key});

  @override
  Widget build(BuildContext context) {
    double contextWidth = MediaQuery.of(context).size.width;
    // double contextHeight = MediaQuery.of(context).size.height;
    return Container(
      alignment: Alignment.topLeft,
      width: contextWidth,
      height: 200,
      decoration: BoxDecoration(
        color: Colors.grey.shade800,
        boxShadow: const [
          BoxShadow(
            color: Colors.black,
            blurRadius: 5,
            blurStyle: BlurStyle.outer,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Column(
            children: [
              Row(
                children: [
                  Image.asset(
                    'assets/images/netBrokeWhite.png',
                    width: 50,
                    height: 50,
                  ),
                  const Text(
                    "NetBroke 2023-2024",
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
              TextButton.icon(
                icon: const Icon(Icons.location_pin),
                label: const Text(
                    'Ruta 11 Km. 1023, Resistencia, Chaco, Argentina'),
                onPressed: () => {},
              ),
            ],
          ),
        ],
      ),
    );
  }
}
