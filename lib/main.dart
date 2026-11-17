import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const MyApp());
}

// MAIN APPLICATION
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SkyFare',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.teal,
        ),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

// HOME PAGE
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Input controllers
  final TextEditingController weightController =
      TextEditingController();
  final TextEditingController rateController =
      TextEditingController();

  // Ticket class
  String selectedClass = 'Economy';

  // Calculation results
  double excessWeight = 0;
  double excessCharge = 0;
  double serviceTax = 0;
  double totalPayable = 0;

  bool showResults = false;

  // CALCULATE BAGGAGE FEE
  void calculateFee() {
    double? weight =
        double.tryParse(weightController.text.trim());
    double? rate =
        double.tryParse(rateController.text.trim());

    if (weight == null ||
        rate == null ||
        !weight.isFinite ||
        !rate.isFinite ||
        weight < 0 ||
        rate < 0) {
      setState(() {
        showResults = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please enter valid, non-negative numbers '
            'for baggage weight and rate.',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    double allowance =
        selectedClass == 'Economy' ? 20.0 : 40.0;

    double calculatedExcess = weight - allowance;

    if (calculatedExcess < 0) {
      calculatedExcess = 0;
    }

    double calculatedCharge = calculatedExcess * rate;
    double calculatedTax = calculatedCharge * 0.08;
    double calculatedTotal =
        calculatedCharge + calculatedTax;

    setState(() {
      excessWeight = calculatedExcess;
      excessCharge = calculatedCharge;
      serviceTax = calculatedTax;
      totalPayable = calculatedTotal;
      showResults = true;
    });
  }

  // RESET CALCULATOR
  void resetCalculator() {
    setState(() {
      weightController.clear();
      rateController.clear();
      selectedClass = 'Economy';

      excessWeight = 0;
      excessCharge = 0;
      serviceTax = 0;
      totalPayable = 0;
      showResults = false;
    });
  }

  @override
  void dispose() {
    weightController.dispose();
    rateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // APPLICATION TITLE BAR
      appBar: AppBar(
        title: const Text('SkyFare'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),

      // NAVIGATION DRAWER
      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.teal,
              ),
              child: Text(
                'SkyFare Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Home'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.info),
              title: const Text('About'),
              onTap: () {
                Navigator.pop(context);

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AboutPage(),
                  ),
                );
              },
            ),
          ],
        ),
      ),

      // CALCULATOR CONTENT
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Icon(
                Icons.flight_takeoff,
                size: 65,
                color: Colors.teal,
              ),
            ),

            const SizedBox(height: 12),

            const Center(
              child: Text(
                'Excess Baggage Calculator',
                style: TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 8),

            const Center(
              child: Text(
                'Enter your baggage details to estimate your fees.',
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: 30),

            // INPUT 1: BAGGAGE WEIGHT
            const Text(
              'Baggage Weight (kg)',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            TextField(
              controller: weightController,
              keyboardType:
                  const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'e.g. 25',
                prefixIcon: Icon(Icons.luggage),
              ),
              onChanged: (value) {
                setState(() {
                  showResults = false;
                });
              },
            ),

            const SizedBox(height: 25),

            // INPUT 2: TICKET CLASS
            const Text(
              'Ticket Class',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),

            RadioGroup<String>(
              groupValue: selectedClass,
              onChanged: (value) {
                setState(() {
                  selectedClass = value!;
                  showResults = false;
                });
              },
              child: const Column(
                children: [
                  RadioListTile<String>(
                    title: Text('Economy Class'),
                    subtitle: Text('Free allowance: 20 kg'),
                    value: 'Economy',
                  ),
                  RadioListTile<String>(
                    title: Text('Business Class'),
                    subtitle: Text('Free allowance: 40 kg'),
                    value: 'Business',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // INPUT 3: EXCESS BAGGAGE RATE
            const Text(
              'Excess Baggage Rate (RM/kg)',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            TextField(
              controller: rateController,
              keyboardType:
                  const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'e.g. 15',
                prefixIcon: Icon(Icons.payments),
              ),
              onChanged: (value) {
                setState(() {
                  showResults = false;
                });
              },
            ),

            const SizedBox(height: 30),

            // CALCULATE BUTTON
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: calculateFee,
                icon: const Icon(Icons.calculate),
                label: const Text('Calculate Fee'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.all(16),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // RESET BUTTON
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: resetCalculator,
                icon: const Icon(Icons.refresh),
                label: const Text('Reset'),
              ),
            ),

            const SizedBox(height: 25),

            // RESULTS SECTION
            if (showResults)
              Card(
                color: Colors.teal.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Calculation Results',
                        style: TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const Divider(height: 30),

                      Text(
                        'Excess Baggage Weight: '
                        '${excessWeight.toStringAsFixed(2)} kg',
                      ),

                      const SizedBox(height: 12),

                      Text(
                        'Excess Baggage Charge: '
                        'RM ${excessCharge.toStringAsFixed(2)}',
                      ),

                      const SizedBox(height: 12),

                      Text(
                        'Service Tax (8%): '
                        'RM ${serviceTax.toStringAsFixed(2)}',
                      ),

                      const Divider(height: 30),

                      Text(
                        'Total Payable: '
                        'RM ${totalPayable.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal,
                        ),
                      ),

                      if (excessWeight == 0) ...[
                        const SizedBox(height: 15),
                        const Text(
                          'Good news! Your baggage is '
                          'within the free allowance.',
                          style: TextStyle(color: Colors.green),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ABOUT PAGE
class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About SkyFare'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),

            // APPLICATION ICON
            const Icon(
              Icons.flight_takeoff,
              size: 90,
              color: Colors.teal,
            ),

            const SizedBox(height: 15),

            const Text(
              'SkyFare',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'Excess Baggage Fee Calculator',
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 25),

            // APPLICATION DESCRIPTION
            const Card(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  'SkyFare is a mobile application designed '
                  'to estimate excess baggage fees based on '
                  'baggage weight, ticket class, and rate per '
                  'kilogram, including an 8% service tax.',
                  textAlign: TextAlign.center,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // AUTHOR INFORMATION
            const Card(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Developer Information',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    Divider(height: 25),

                    Text('Name: UMI KHADIJAH ABU MUSA'),
                    SizedBox(height: 10),

                    Text('Matric No: 2024433286'),
                    SizedBox(height: 10),

                    Text('Course: CS251 - Netcentric Computing'),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            
            // GITHUB REPOSITORY LINK
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Icon(
                      Icons.code,
                      color: Colors.teal,
                      size: 35,
                    ),

                    const SizedBox(height: 10),

                    const Text(
                      'GitHub Repository',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 10),

                    // CLICKABLE GITHUB LINK
                    TextButton.icon(
                      onPressed: () async {
                        final Uri githubUrl = Uri.parse(
                          'https://github.com/Umi-Kdj/skyfare',
                        );

                        try {
                          final bool opened = await launchUrl(
                            githubUrl,
                            mode: LaunchMode.externalApplication,
                          );

                          if (!opened && context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Could not open GitHub repository.',
                                ),
                              ),
                            );
                          }
                        } catch (error) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Could not open GitHub repository.',
                                ),
                              ),
                            );
                          }
                        }
                      },
                      icon: const Icon(Icons.open_in_new),
                      label: const Text(
                        'github.com/Umi-Kdj/skyfare',
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),

            // COPYRIGHT NOTICE
            const Text(
              '© 2026 SkyFare. All rights reserved.',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
