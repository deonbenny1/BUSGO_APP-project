import 'package:flutter/material.dart';

void main() {
  runApp(const BusGoApp());
}

/* ---------------- DATA ---------------- */

List<Map<String, dynamic>> users = [
  {"username": "deon", "password": "1234"}
];

String currentUser = "Guest";

List<Map<String, String>> routes = [
  {"from": "Thrissur", "to": "Bangalore"},
  {"from": "Thrissur", "to": "Goa"},
  {"from": "Kochi", "to": "Chennai"},
  {"from": "Bangalore", "to": "Hyderabad"},
  {"from": "Mumbai", "to": "Pune"},
  {"from": "Delhi", "to": "Manali"},
];

List<Map<String, dynamic>> bookings = [];

/* ---------------- GENERATION LOGIC ---------------- */

List<Map<String, dynamic>> generateBuses(String from, String to) {
  List<String> operators = ["KSRTC", "Orange Travels", "RedBus Express", "Royal Travels", "VRL Travels", "GreenLine", "SRS Travels"];
  List<String> times = ["06:00 AM - 12:00 PM", "09:30 AM - 03:30 PM", "01:00 PM - 08:00 PM", "04:00 PM - 11:00 PM", "07:30 PM - 03:30 AM", "10:00 PM - 06:00 AM", "11:30 PM - 07:30 AM"];

  return List.generate(7, (i) => {
    "name": operators[i],
    "from": from,
    "to": to,
    "time": times[i],
    "price": 1550 + (i * 125),
    "rating": (4.0 + (i * 0.1)).toStringAsFixed(1),
  });
}

/* ---------------- APP ---------------- */

class BusGoApp extends StatelessWidget {
  const BusGoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "BusGo Premium",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xffF4F6FA),
        fontFamily: "Arial",
        primaryColor: const Color(0xffD84E55),
      ),
      home: const LoginPage(),
    );
  }
}

/* ---------------- COMMON UI COMPONENTS ---------------- */

Widget premiumCard(Widget child) {
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(22),
      boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 12)],
    ),
    child: child,
  );
}

Widget appButton(String text, VoidCallback onTap, {Color? color}) {
  return Container(
    width: double.infinity,
    height: 55,
    decoration: BoxDecoration(
      color: color ?? const Color(0xffD84E55),
      borderRadius: BorderRadius.circular(30),
    ),
    child: ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent),
      child: Text(text, style: const TextStyle(fontSize: 17, color: Colors.white, fontWeight: FontWeight.bold)),
    ),
  );
}

InputDecoration field(String hint, IconData icon) {
  return InputDecoration(
    prefixIcon: Icon(icon),
    hintText: hint,
    filled: true,
    fillColor: const Color(0xffF7F8FC),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
  );
}

/* ---------------- LOGIN & REGISTER ---------------- */

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final user = TextEditingController();
  final pass = TextEditingController();

  void login() {
    for (var u in users) {
      if (u["username"] == user.text && u["password"] == pass.text) {
        currentUser = user.text;
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomePage()));
        return;
      }
    }
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Invalid Login")));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(22),
        child: Center(
          child: ListView(
            shrinkWrap: true,
            children: [
              const Icon(Icons.directions_bus, size: 85, color: Color(0xffD84E55)),
              const SizedBox(height: 12),
              const Center(child: Text("BusGo", style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold))),
              const SizedBox(height: 32),
              TextField(controller: user, decoration: field("Username", Icons.person)),
              const SizedBox(height: 14),
              TextField(controller: pass, obscureText: true, decoration: field("Password", Icons.lock)),
              const SizedBox(height: 20),
              appButton("Login", login),
              TextButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterPage())),
                child: const Text("Create Account"),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});
  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final user = TextEditingController();
  final pass = TextEditingController();
  void register() {
    users.add({"username": user.text, "password": pass.text});
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Register"), backgroundColor: const Color(0xffD84E55)),
      body: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            TextField(controller: user, decoration: field("Username", Icons.person)),
            const SizedBox(height: 14),
            TextField(controller: pass, obscureText: true, decoration: field("Password", Icons.lock)),
            const SizedBox(height: 20),
            appButton("Register", register)
          ],
        ),
      ),
    );
  }
}

/* ---------------- HOME ---------------- */

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final from = TextEditingController();
  final to = TextEditingController();
  String selectedDateDisplay = "Mon 27 Apr";
  int nav = 0;

  void _openDatePicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        height: MediaQuery.of(context).size.height * 0.75,
        child: Column(
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const Text("Select Date", style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
              IconButton(icon: const Icon(Icons.close, size: 28), onPressed: () => Navigator.pop(context))
            ]),
            Expanded(child: ListView(children: [_buildMonthGrid("April 2026", 30, 2), _buildMonthGrid("May 2026", 31, 4)])),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthGrid(String monthName, int totalDays, int offset) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(padding: const EdgeInsets.symmetric(vertical: 20), child: Text(monthName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
      GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7, mainAxisSpacing: 10, crossAxisSpacing: 10),
        itemCount: totalDays + offset,
        itemBuilder: (context, index) {
          if (index < offset) return const SizedBox();
          int day = index - offset + 1;
          bool isSelected = (monthName == "April 2026" && day == 27);
          return GestureDetector(
            onTap: () {
              setState(() => selectedDateDisplay = "${monthName.substring(0, 3)} $day ${monthName.split(' ')[1]}");
              Navigator.pop(context);
            },
            child: Container(
              decoration: BoxDecoration(color: isSelected ? Colors.black : Colors.transparent, shape: BoxShape.circle),
              child: Center(child: Text("$day", style: TextStyle(color: isSelected ? Colors.white : Colors.black87))),
            ),
          );
        },
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: nav,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xffD84E55),
        onTap: (v) => setState(() => nav = v),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: "Bookings"),
          BottomNavigationBarItem(icon: Icon(Icons.local_offer), label: "Offers"),
          BottomNavigationBarItem(icon: Icon(Icons.help), label: "Help"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(18),
          children: [
            Text("Hello $currentUser 👋", style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
            const SizedBox(height: 22),
            Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
              _topIcon(Icons.directions_bus, "Bus"),
              _topIcon(Icons.train, "Train"),
              _topIcon(Icons.hotel, "Hotels"),
              _topIcon(Icons.flight, "Flight"),
            ]),
            const SizedBox(height: 28),
            const Text("Bus Tickets", style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            premiumCard(Column(children: [
              TextField(controller: from, decoration: field("From", Icons.location_on)),
              const SizedBox(height: 12),
              Stack(alignment: Alignment.centerRight, children: [
                TextField(controller: to, decoration: field("To", Icons.location_on)),
                Positioned(right: 12, child: GestureDetector(
                  onTap: () { String t = from.text; from.text = to.text; to.text = t; },
                  child: const CircleAvatar(backgroundColor: Color(0xffD84E55), child: Icon(Icons.swap_vert, color: Colors.white)),
                ))
              ]),
              const SizedBox(height: 12),
              ListTile(tileColor: const Color(0xffF7F8FC), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), leading: const Icon(Icons.calendar_month), title: Text(selectedDateDisplay), onTap: _openDatePicker),
              const SizedBox(height: 16),
              appButton("Search Buses", () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => SearchPage(from: from.text, to: to.text)));
              })
            ])),
          ],
        ),
      ),
    );
  }

  Widget _topIcon(IconData i, String t) => Column(children: [
        CircleAvatar(radius: 28, backgroundColor: Colors.white, child: Icon(i, color: const Color(0xffD84E55))),
        const SizedBox(height: 6),
        Text(t)
      ]);
}

/* ---------------- SEARCH ---------------- */

class SearchPage extends StatelessWidget {
  final String from;
  final String to;
  const SearchPage({super.key, required this.from, required this.to});

  @override
  Widget build(BuildContext context) {
    bool routeExists = routes.any((r) => r["from"]!.toLowerCase() == from.toLowerCase() && r["to"]!.toLowerCase() == to.toLowerCase());
    List<Map<String, dynamic>> results = routeExists ? generateBuses(from, to) : [];

    return Scaffold(
      appBar: AppBar(title: Text("$from → $to"), backgroundColor: const Color(0xffD84E55)),
      body: results.isEmpty
          ? const Center(child: Text("No buses available for this route"))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: results.length,
              itemBuilder: (_, i) {
                var bus = results[i];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: premiumCard(Column(children: [
                    Row(children: [Text(bus["name"], style: const TextStyle(fontWeight: FontWeight.bold)), const Spacer(), Text("⭐ ${bus["rating"]}")]),
                    const SizedBox(height: 10),
                    Row(children: [Text(bus["time"]), const Spacer(), Text("₹${bus["price"]}", style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold))]),
                    const SizedBox(height: 12),
                    appButton("Book", () { Navigator.push(context, MaterialPageRoute(builder: (_) => SeatPage(bus: bus))); })
                  ])),
                );
              },
            ),
    );
  }
}

/* ---------------- SEAT SELECTION ---------------- */

class SeatPage extends StatefulWidget {
  final Map bus;
  const SeatPage({super.key, required this.bus});
  @override
  State<SeatPage> createState() => _SeatPageState();
}

class _SeatPageState extends State<SeatPage> {
  late List<Map<String, dynamic>> allSeats;
  List<int> selectedIndices = [];

  @override
  void initState() {
    super.initState();
    allSeats = List.generate(40, (i) => {
      "id": i + 1,
      "price": 1500 + (i % 5 * 120),
      "isSold": i % 7 == 0 || i % 11 == 0,
      "isUpper": i >= 20,
    });
  }

  int get totalAmount {
    int sum = selectedIndices.fold(0, (prev, idx) => prev + (allSeats[idx]["price"] as int));
    return sum > 0 ? sum - 150 : 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF4F6FA),
      appBar: AppBar(
        backgroundColor: Colors.white, elevation: 0, foregroundColor: Colors.black,
        title: Text("${widget.bus["from"]} → ${widget.bus["to"]}", style: const TextStyle(fontSize: 16)),
        actions: [
          Container(
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(color: Colors.orange.shade100, borderRadius: BorderRadius.circular(8)),
            child: const Center(child: Text("₹150 OFF", style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 12))),
          )
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 200),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _buildDeck("Lower deck", allSeats.where((s) => !s["isUpper"]).toList())),
                const VerticalDivider(width: 1),
                Expanded(child: _buildDeck("Upper deck", allSeats.where((s) => s["isUpper"]).toList())),
              ],
            ),
          ),
          _buildBottomPanel(),
        ],
      ),
    );
  }

  Widget _buildDeck(String label, List<Map<String, dynamic>> deckSeats) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
          if (label == "Lower deck") const Icon(Icons.settings_input_component, color: Colors.grey),
        ]),
        const SizedBox(height: 20),
        GridView.builder(
          shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
          itemCount: deckSeats.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: 20, crossAxisSpacing: 15, childAspectRatio: 0.8),
          itemBuilder: (context, index) {
            var seat = deckSeats[index];
            int globalIdx = allSeats.indexOf(seat);
            bool isSelected = selectedIndices.contains(globalIdx);
            bool isSold = seat["isSold"];

            return GestureDetector(
              onTap: () { if (!isSold) setState(() => isSelected ? selectedIndices.remove(globalIdx) : selectedIndices.add(globalIdx)); },
              child: Column(children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200), height: 45, width: 35,
                  decoration: BoxDecoration(
                    color: isSold ? Colors.grey.shade300 : (isSelected ? Colors.green : Colors.white),
                    borderRadius: BorderRadius.circular(6), border: Border.all(color: isSelected ? Colors.green : Colors.green.shade700, width: 2),
                  ),
                  child: isSold ? const Icon(Icons.close, size: 14, color: Colors.grey) : null,
                ),
                Text(isSold ? "Sold" : "₹${seat["price"]}", style: const TextStyle(fontSize: 10)),
              ]),
            );
          },
        ),
      ]),
    );
  }

  Widget _buildBottomPanel() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(20)), boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)]),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(widget.bus["name"], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              Text(widget.bus["time"], style: const TextStyle(color: Colors.grey)),
            ]),
            Text("⭐ ${widget.bus["rating"]}", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
          ]),
          const Divider(height: 30),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text("${selectedIndices.length} Seats", style: const TextStyle(color: Colors.grey)),
              Text("₹$totalAmount", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            ]),
            SizedBox(width: 180, child: appButton("Pay Now", () {
              if (selectedIndices.isEmpty) return;
              Navigator.push(context, MaterialPageRoute(builder: (_) => BoardingDroppingPage(
                bus: widget.bus, 
                seats: selectedIndices.map((i) => allSeats[i]["id"] as int).toList(), 
                total: totalAmount
              )));
            })),
          ]),
        ]),
      ),
    );
  }
}

/* ---------------- BOARDING & DROPPING SELECTION ---------------- */

List<Map<String, String>> getBoardingPoints(String city) {
  switch (city) {
    case "Thrissur":
      return [
        {"time": "21:30", "date": "30 Apr", "name": "KODAKARA", "sub": "Kodakara", "tag": ""},
        {"time": "21:40", "date": "30 Apr", "name": "Pudukkad junction", "sub": "Pudukkad junction", "tag": ""},
        {"time": "21:45", "date": "30 Apr", "name": "Thrissur (Palliakkara Toll) Plaza", "sub": "Palliakkara Toll Plaza", "tag": "Popular boarding point"},
        {"time": "21:55", "date": "30 Apr", "name": "Nadathara (Signal)", "sub": "Nadathra (Signal)", "tag": ""},
        {"time": "22:15", "date": "30 Apr", "name": "Thrissur Town", "sub": "Thrissur Town", "tag": "Popular boarding point"},
        {"time": "22:20", "date": "30 Apr", "name": "Mannuthy By pass", "sub": "Mannuthy By Pass", "tag": ""},
      ];
    case "Bangalore":
      return [
        {"time": "05:05", "date": "01 May", "name": "Hosur", "sub": "Hosur Stop", "tag": ""},
        {"time": "05:10", "date": "01 May", "name": "Atthi Belle (Toll Plaza)", "sub": "Atthi Belle", "tag": ""},
        {"time": "05:15", "date": "01 May", "name": "Bommasadra", "sub": "Bommasadra", "tag": ""},
        {"time": "05:30", "date": "01 May", "name": "Electronic City(Toll Plaza)", "sub": "Electonic City", "tag": ""},
        {"time": "05:40", "date": "01 May", "name": "Madiwala (Surya Travels)", "sub": "Madiwala", "tag": "Popular dropping point"},
      ];
    default:
      return [
        {"time": "22:00", "date": "30 Apr", "name": "$city Main Stand", "sub": "Main Entry", "tag": "Popular"},
        {"time": "22:30", "date": "30 Apr", "name": "$city Bypass", "sub": "Bypass Junction", "tag": ""},
      ];
  }
}

class BoardingDroppingPage extends StatefulWidget {
  final Map bus;
  final List<int> seats;
  final int total;

  const BoardingDroppingPage({super.key, required this.bus, required this.seats, required this.total});

  @override
  State<BoardingDroppingPage> createState() => _BoardingDroppingPageState();
}

class _BoardingDroppingPageState extends State<BoardingDroppingPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Map<String, String>? selectedBoarding;
  Map<String, String>? selectedDropping;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Select boarding & dropping points", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Text("${widget.bus['from']} → ${widget.bus['to']}", style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xffD84E55),
          labelColor: Colors.black,
          unselectedLabelColor: Colors.grey,
          tabs: [
            Tab(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [const Text("Boarding points"), Text(widget.bus['from'], style: const TextStyle(fontSize: 10))])),
            Tab(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [const Text("Dropping points"), Text(widget.bus['to'], style: const TextStyle(fontSize: 10))])),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildPointList(getBoardingPoints(widget.bus['from']), true),
                _buildPointList(getBoardingPoints(widget.bus['to']), false),
              ],
            ),
          ),
          _buildStickyFooter(),
        ],
      ),
    );
  }

  Widget _buildPointList(List<Map<String, String>> points, bool isBoarding) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: points.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, i) {
        final item = points[i];
        final isSelected = isBoarding ? selectedBoarding == item : selectedDropping == item;

        return ListTile(
          onTap: () => setState(() => isBoarding ? selectedBoarding = item : selectedDropping = item),
          contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          leading: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(item['time']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Text(item['date']!, style: const TextStyle(fontSize: 10, color: Colors.grey)),
            ],
          ),
          title: Text(item['name']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(item['sub']!, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              if (item['tag']!.isNotEmpty)
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(4)),
                  child: Text(item['tag']!, style: TextStyle(color: Colors.blue.shade800, fontSize: 10, fontWeight: FontWeight.bold)),
                )
            ],
          ),
          trailing: Icon(isSelected ? Icons.radio_button_checked : Icons.radio_button_off, color: isSelected ? const Color(0xffD84E55) : Colors.grey),
        );
      },
    );
  }

  Widget _buildStickyFooter() {
    bool canContinue = selectedBoarding != null && selectedDropping != null;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)]),
      child: appButton(
        canContinue ? "Continue" : "Select Points to Continue",
        canContinue ? () => Navigator.push(context, MaterialPageRoute(builder: (_) => PassengerInfoPage(
          bus: widget.bus,
          seats: widget.seats,
          total: widget.total,
          boarding: selectedBoarding!,
          dropping: selectedDropping!,
        ))) : () {},
      ),
    );
  }
}

/* ---------------- PASSENGER INFORMATION ---------------- */

class PassengerInfoPage extends StatefulWidget {
  final Map bus;
  final List<int> seats;
  final int total;
  final Map<String, String> boarding;
  final Map<String, String> dropping;

  const PassengerInfoPage({super.key, required this.bus, required this.seats, required this.total, required this.boarding, required this.dropping});

  @override
  State<PassengerInfoPage> createState() => _PassengerInfoPageState();
}

class _PassengerInfoPageState extends State<PassengerInfoPage> {
  bool WhatsAppEnabled = true;
  String phone = "+91 9495051653";
  String email = "neetuchittilappilly@gmail.com";
  String stateLocation = "Karnataka";

  List<Map<String, dynamic>> availablePassengers = [
    {"name": "Deon Benny", "desc": "Male, 19 Years", "selected": false},
    {"name": "Neethu Benny", "desc": "Female, 48 Years", "selected": false},
  ];

  int get selectedCount => availablePassengers.where((p) => p["selected"] == true).length;
  String cancellationOption = "Don't add";

  void _addNewPassenger() {
    TextEditingController nameCtrl = TextEditingController();
    TextEditingController ageCtrl = TextEditingController();
    String gender = "Male";

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Add New Passenger"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: "Full Name")),
            TextField(controller: ageCtrl, decoration: const InputDecoration(labelText: "Age"), keyboardType: TextInputType.number),
            DropdownButtonFormField<String>(
              value: gender,
              items: ["Male", "Female", "Other"].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
              onChanged: (v) => gender = v!,
              decoration: const InputDecoration(labelText: "Gender"),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              if (nameCtrl.text.isNotEmpty && ageCtrl.text.isNotEmpty) {
                setState(() {
                  availablePassengers.add({"name": nameCtrl.text, "desc": "$gender, ${ageCtrl.text} Years", "selected": false});
                });
                Navigator.pop(context);
              }
            },
            child: const Text("Add"),
          )
        ],
      ),
    );
  }

  void _editContactDetails() {
    TextEditingController phoneCtrl = TextEditingController(text: phone);
    TextEditingController emailCtrl = TextEditingController(text: email);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 20, right: 20, top: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Edit Contact Details", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            TextField(controller: phoneCtrl, decoration: const InputDecoration(labelText: "Phone Number")),
            TextField(controller: emailCtrl, decoration: const InputDecoration(labelText: "Email Address")),
            const SizedBox(height: 20),
            appButton("Save Changes", () {
              setState(() {
                phone = phoneCtrl.text;
                email = emailCtrl.text;
              });
              Navigator.pop(context);
            }),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _viewBusDetails() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(widget.bus["name"]),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Route: ${widget.bus['from']} to ${widget.bus['to']}"),
            Text("Time: ${widget.bus['time']}"),
            Text("Seats: ${widget.seats.join(', ')}"),
            const Divider(),
            Text("Boarding: ${widget.boarding['name']}"),
            Text("Dropping: ${widget.dropping['name']}"),
          ],
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text("Close"))],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Passenger Information", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Text("${widget.bus['from']} → ${widget.bus['to']}", style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildRouteSummary(),
            _buildSection(
              title: "Contact Details",
              subtitle: "Ticket details will be sent to",
              trailing: "Edit",
              onTrailingTap: _editContactDetails,
              child: Column(
                children: [
                  _infoRow(Icons.phone_outlined, phone),
                  _infoRow(Icons.email_outlined, email),
                  _infoRow(Icons.location_on_outlined, stateLocation),
                  const Divider(),
                  Row(
                    children: [
                      const Icon(Icons.chat, color: Colors.green, size: 20),
                      const SizedBox(width: 10),
                      const Text("WhatsApp communication enabled", style: TextStyle(fontSize: 12)),
                      const Spacer(),
                      Switch(value: WhatsAppEnabled, onChanged: (v) => setState(() => WhatsAppEnabled = v), activeColor: Colors.green),
                    ],
                  )
                ],
              ),
            ),
            _buildSection(
              title: "Passenger details",
              subtitle: "$selectedCount/${widget.seats.length} Selected",
              child: Column(
                children: [
                  OutlinedButton.icon(
                    onPressed: _addNewPassenger,
                    icon: const Icon(Icons.person_add_alt_1),
                    label: const Text("Add new passenger"),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.black,
                      backgroundColor: Colors.red.shade50,
                      minimumSize: const Size(double.infinity, 50),
                      side: BorderSide.none,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                  ),
                  const SizedBox(height: 15),
                  ...availablePassengers.map((p) => _passengerTile(p)).toList(),
                ],
              ),
            ),
            _buildAssuranceCard(
              title: "Free Cancellation",
              price: "₹170 per passenger",
              mainText: "Get 100% refund",
              subText: "on cancellation",
              desc: "Cancel anytime up to 6 hours before bus departure for a 100% refund.",
              icon: Icons.shield,
              options: ["Add Free Cancellation", "Don't add Free Cancellation"],
              groupValue: cancellationOption,
              onChanged: (v) => setState(() => cancellationOption = v!),
            ),
            const SizedBox(height: 120),
          ],
        ),
      ),
      bottomSheet: _buildBottomBar(),
    );
  }

  Widget _buildRouteSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        children: [
          const Text("Surya Connect", style: TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _summaryPoint(widget.boarding['date']!, widget.boarding['time']!, widget.boarding['name']!),
              const Icon(Icons.arrow_forward, color: Colors.grey, size: 16),
              _summaryPoint(widget.dropping['date']!, widget.dropping['time']!, widget.dropping['name']!),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              Chip(label: Text("${widget.seats.length} seat", style: const TextStyle(fontSize: 12)), avatar: const Icon(Icons.chair, size: 14)),
              const Spacer(),
              GestureDetector(
                onTap: _viewBusDetails,
                child: const Text("View details", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, decoration: TextDecoration.underline)),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _summaryPoint(String date, String time, String name) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("$date • $time", style: const TextStyle(fontWeight: FontWeight.bold)),
        Text(name, style: const TextStyle(fontSize: 12, color: Colors.grey, overflow: TextOverflow.ellipsis)),
      ],
    );
  }

  Widget _buildSection({required String title, String? subtitle, String? trailing, VoidCallback? onTrailingTap, required Widget child}) {
    return Container(
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              if (trailing != null) 
                GestureDetector(
                  onTap: onTrailingTap,
                  child: Text(trailing, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, decoration: TextDecoration.underline)),
                ),
            ],
          ),
          if (subtitle != null) Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 15),
          child,
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(children: [Icon(icon, size: 20, color: Colors.grey), const SizedBox(width: 15), Text(text)]),
    );
  }

  Widget _passengerTile(Map<String, dynamic> passenger) {
    return CheckboxListTile(
      value: passenger["selected"],
      onChanged: (v) {
        if (v == true && selectedCount >= widget.seats.length) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("You can only select ${widget.seats.length} passengers")));
          return;
        }
        setState(() => passenger["selected"] = v);
      },
      title: Text(passenger["name"], style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(passenger["desc"]),
      secondary: CircleAvatar(backgroundColor: Colors.blue.shade50, child: const Icon(Icons.person, color: Colors.blue)),
      controlAffinity: ListTileControlAffinity.trailing,
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildAssuranceCard({required String title, required String price, required String mainText, required String subText, required String desc, required IconData icon, required List<String> options, required String groupValue, required Function(String?) onChanged}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text(price, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ]),
              Icon(icon, color: const Color(0xffD84E55), size: 40),
            ],
          ),
          const SizedBox(height: 15),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.green.shade100)),
            child: Column(children: [
              Text(mainText, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green)),
              Text(subText, style: const TextStyle(fontSize: 12, color: Colors.green)),
            ]),
          ),
          ...options.map((opt) => RadioListTile(
            title: Text(opt, style: const TextStyle(fontSize: 14)),
            value: opt,
            groupValue: groupValue,
            onChanged: onChanged,
            dense: true,
          )),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)]),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Amount", style: TextStyle(fontSize: 12, color: Colors.grey)),
              Text("₹${widget.total}", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            ],
          ),
          SizedBox(
            width: 200,
            child: appButton("Pay now", () {
              if (selectedCount < widget.seats.length) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Please select ${widget.seats.length} passengers")));
                return;
              }
              Navigator.push(context, MaterialPageRoute(builder: (_) => PaymentPage(
                bus: widget.bus,
                seats: widget.seats,
                total: widget.total,
                boarding: widget.boarding,
                dropping: widget.dropping,
              )));
            }),
          )
        ],
      ),
    );
  }
}

/* ---------------- OVERHAULED PAYMENT PAGE ---------------- */

class PaymentPage extends StatefulWidget {
  final Map bus;
  final List<int> seats;
  final int total;
  final Map<String, String> boarding;
  final Map<String, String> dropping;

  const PaymentPage({
    super.key,
    required this.bus,
    required this.seats,
    required this.total,
    required this.boarding,
    required this.dropping,
  });

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  void _showInfo(String title, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text("OK"))],
      ),
    );
  }

  void _processPayment() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => SuccessPage(busName: widget.bus["name"], amount: widget.total)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Pay ₹${widget.total}", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Text("Fare breakup", style: TextStyle(fontSize: 12, color: Colors.blue, decoration: TextDecoration.underline)),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.orange)),
            child: const Center(child: Text("07:41", style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold))),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.white,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _headerPoint(widget.boarding['time']!, widget.boarding['name']!),
                      const Icon(Icons.arrow_forward, color: Colors.grey),
                      _headerPoint(widget.dropping['time']!, widget.dropping['name']!),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      Chip(label: Text("${widget.seats.length} seat"), avatar: const Icon(Icons.person, size: 16)),
                      const Spacer(),
                      TextButton(onPressed: () => _showInfo("Booking Details", "Seats: ${widget.seats.join(', ')}"), child: const Text("Booking details")),
                    ],
                  ),
                  Row(
                    children: [
                      _actionBtn(Icons.directions_bus_filled_outlined, "Trip info", () => _showInfo("Trip Info", "Express route via major national highways.")),
                      const SizedBox(width: 10),
                      _actionBtn(Icons.assignment_outlined, "Cancellation policy", () => _showInfo("Cancellation Policy", "100% refund available up to 6 hours before departure.")),
                    ],
                  )
                ],
              ),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              color: Colors.green.shade700,
              child: const Center(child: Text("Exclusive deal applied • ₹177 Saved", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _trustItem(Icons.verified_user_outlined, "Secure\nPayment"),
                  _trustItem(Icons.account_balance_wallet_outlined, "Superfast\nRefunds"),
                  _trustItem(Icons.thumb_up_outlined, "Trusted by\n40Mn+ users"),
                ],
              ),
            ),
            _paymentSection("Preferred Options", [
              _payTile("Google Pay", Icons.radio_button_off),
            ]),
            _paymentSection("UPI", [
              _payTile("Google Pay", Icons.radio_button_off),
              _payTile("Phonepe UPI", Icons.radio_button_off),
              _payTile("Enter UPI ID", Icons.radio_button_off),
            ]),
            _paymentSection("Credit/Debit Card", [
              ListTile(onTap: _processPayment, leading: const Icon(Icons.credit_card), title: const Text("Add credit / debit card"), subtitle: const Text("Visa, Master Card and more"), trailing: const Icon(Icons.chevron_right)),
            ]),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _headerPoint(String time, String city) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(time, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        SizedBox(width: 100, child: Text(city, style: const TextStyle(color: Colors.grey, overflow: TextOverflow.ellipsis))),
      ],
    );
  }

  Widget _actionBtn(IconData icon, String label, VoidCallback onTap) {
    return Expanded(
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 18, color: Colors.black),
        label: Text(label, style: const TextStyle(color: Colors.black, fontSize: 12)),
        style: OutlinedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
      ),
    );
  }

  Widget _trustItem(IconData icon, String text) {
    return Row(children: [Icon(icon, size: 20, color: Colors.green), const SizedBox(width: 5), Text(text, style: const TextStyle(fontSize: 10, color: Colors.grey))]);
  }

  Widget _paymentSection(String title, List<Widget> children) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(padding: const EdgeInsets.all(16), child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold))),
          ...children,
        ],
      ),
    );
  }

  Widget _payTile(String title, IconData icon) {
    return ListTile(
      onTap: _processPayment,
      leading: const CircleAvatar(radius: 15, backgroundColor: Colors.transparent, child: Icon(Icons.payment, size: 20)),
      title: Text(title),
      trailing: Icon(icon, color: Colors.grey),
    );
  }
}

/* ---------------- SUCCESS PAGE ---------------- */

class SuccessPage extends StatelessWidget {
  final String busName;
  final int amount;

  const SuccessPage({super.key, required this.busName, required this.amount});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircleAvatar(radius: 50, backgroundColor: Colors.green, child: Icon(Icons.check, size: 60, color: Colors.white)),
            const SizedBox(height: 24),
            const Text("Payment Successful!", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green)),
            const SizedBox(height: 10),
            Text("Booking confirmed for $busName", style: const TextStyle(fontSize: 16, color: Colors.grey)),
            Text("Amount Paid: ₹$amount", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 40),
            SizedBox(
              width: 200,
              child: appButton("Back to Home", () {
                Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const HomePage()), (r) => false);
              }),
            )
          ],
        ),
      ),
    );
  }
}