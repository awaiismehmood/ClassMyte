import 'package:classmyte/onboarding/terms_and_conditions.dart';
import 'package:flutter/material.dart';

class OnboardingScreen extends StatefulWidget {
  final VoidCallback onFinish;

  const OnboardingScreen({super.key, required this.onFinish});

  @override
  // ignore: library_private_types_in_public_api
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int currentIndex = 0;
  bool isAgreed = false;

  List<Widget> _buildPages(BuildContext context) {
    return [
      _buildOnboardingPage(
        context,
        image: 'assets/pencil_white.png',
        title: 'Welcome to ClassMyte',
        description: 'Manage your students\' data seamlessly.',
      ),
      _buildOnboardingPage(
        context,
        image: 'assets/pencil_white.png',
        title: 'Bulk SMS Messaging',
        description: 'Send bulk SMS to your entire class in seconds.',
      ),
      _buildOnboardingPageWithCheckbox(
        context,
        image: 'assets/pencil_white.png',
        title: 'Stay Organized',
        description: 'Keep track of students\' details all in one place.',
      ),
    ];
  }

  Widget _buildOnboardingPage(BuildContext context,
      {required String image, required String title, required String description}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Image.asset(
          image,
          height: 250,
        ),
        const SizedBox(height: 20),
        Text(
          title,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40.0),
          child: Text(
            description,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }

Widget _buildOnboardingPageWithCheckbox(BuildContext context,
    {required String image, required String title, required String description}) {
  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      Image.asset(
        image,
        height: 250,
      ),
      const SizedBox(height: 20),
      Text(
        title,
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      const SizedBox(height: 12),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40.0),
        child: Text(
          description,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 16,
          ),
        ),
      ),
      const SizedBox(height: 20),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Checkbox(
            value: isAgreed,
            onChanged: (value) {
              setState(() {
                isAgreed = value ?? false;
              });
            },
          ),
          const Text(
              'I agree to the ',

            style: TextStyle(
              fontSize: 14,
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const TermsAndConditionsScreen(),
                ),
              );
            },
            child: const Text(
             'Terms and Conditions',
              style: TextStyle(fontSize: 14, color: Colors.blue,),
            ),
          ),
         
        ],
      ),
    ],
  );
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: _buildPages(context).length,
            onPageChanged: (index) {
              setState(() {
                currentIndex = index;
              });
            },
            itemBuilder: (context, index) {
              return _buildPages(context)[index];
            },
          ),
          Positioned(
            bottom: 30,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: currentIndex > 0
                      ? () => _pageController.previousPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          )
                      : null,
                  child: const Text("Back"),
                ),
                Row(
                  children: List.generate(
                    _buildPages(context).length,
                    (index) => Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4.0),
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color:
                            currentIndex == index ? Colors.blue : Colors.grey,
                      ),
                    ),
                  ),
                ),
                currentIndex == _buildPages(context).length - 1
                    ? ElevatedButton(
                        onPressed: isAgreed
                            ? () {
                                widget.onFinish();
                              }
                            : null,
                        child: const Text('Get Started'),
                      )
                    : TextButton(
                        onPressed: () => _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        ),
                        child: const Text("Next"),
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
