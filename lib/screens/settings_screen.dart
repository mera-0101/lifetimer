import 'package:flutter/material.dart';
import '/global.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  SettingsScreenState createState() => SettingsScreenState();
}

class SettingsScreenState extends State<SettingsScreen> {
  late TextEditingController _yearsController;
  late TextEditingController _monthsController;
  late TextEditingController _daysController;
  late TextEditingController _titleController;
  int _selectedFormat = Globals.formatTime;

  @override
  void initState() {
    super.initState();
    _yearsController = TextEditingController(text: Globals.spendYear.toString());
    _monthsController = TextEditingController(text: Globals.spendMonth.toString());
    _daysController = TextEditingController(text: Globals.spendDay.toString());
    _titleController = TextEditingController(text: Globals.appBarTitle);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      // Android のバックボタンなどで戻る場合にも確認ダイアログを表示する
      onWillPop: () => _showSaveConfirmation(context),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Settings'),
          centerTitle: true,
          backgroundColor: Theme.of(context).primaryColor,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildGoalDateAndSpendTimeSection(),
              const Padding(padding: EdgeInsets.all(5.0)),
              _buildAppSettingsSection(),
              const Padding(padding: EdgeInsets.all(5.0)),
              _buildTimeFormatSection(),
              const SizedBox(height: 32),
              _buildSaveButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGoalDateAndSpendTimeSection() {
    return _buildSectionCard(
      title: 'Goal Date & Spend Time',
      children: [
        const Padding(padding: EdgeInsets.all(5.0),),
        Text("Your Goal Date", style: Theme.of(context).textTheme.titleLarge),
        _buildGoalDateTile(),
        const Padding(padding: EdgeInsets.all(10.0),),
        Text("Spent Your Time", style: Theme.of(context).textTheme.titleLarge),
        _buildNumberInputField(_yearsController, 'Years'),
        _buildNumberInputField(_monthsController, 'Months'),
        _buildNumberInputField(_daysController, 'Days'),
      ],
    );
  }

  Widget _buildAppSettingsSection() {
    return _buildSectionCard(
      title: 'App Settings',
      children: [
        _buildTextInputField(_titleController, 'Title', 'Enter Your Goal', Icons.text_fields),
      ],
    );
  }

  Widget _buildTimeFormatSection() {
    return _buildSectionCard(
      title: 'Time Format',
      children: List.generate(4, (index) => _buildTimeFormatOption(index)),
    );
  }

  Widget _buildSectionCard({required String title, required List<Widget> children}) {
    return Card(
      color: Colors.grey[150],
      elevation: 4.0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const Divider(),
          ...children,
        ]),
      ),
    );
  }

  Widget _buildGoalDateTile() {
    return ListTile(
      leading: const Icon(Icons.calendar_today),
      title: Text(DateFormat('yyyy-MM-dd').format(Globals.eventDate)),
      onTap: () => _selectEventDate(context),
    );
  }

  Widget _buildNumberInputField(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(labelText: label),
      keyboardType: TextInputType.number,
    );
  }

  Widget _buildTextInputField(TextEditingController controller, String label, String hint, IconData icon) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(labelText: label, hintText: hint, icon: Icon(icon)),
    );
  }

  Widget _buildTimeFormatOption(int value) {
    List<String> titles = ['0s', '0m 0s', '0h 0m 0s', '0d 0h 0m 0s'];
    return RadioListTile<int>(
      title: Text(titles[value]),
      value: value,
      groupValue: _selectedFormat,
      onChanged: (newValue) => setState(() => _selectedFormat = newValue!),
    );
  }

  Widget _buildSaveButton() {
    return ElevatedButton(
      onPressed: (){
        _saveSettings();
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Settings saved successfully!')));
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.grey[700],
        padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
      ),
      child: const Text('Save', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    );
  }

  Future<void> _selectEventDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: Globals.eventDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != Globals.eventDate) {
      setState(() => Globals.eventDate = picked);
      Globals.setDate = DateTime.now();
    }
  }

  Future<bool> _showSaveConfirmation(BuildContext context) async {
    final confirmed = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Unsaved Changes'),
        content: const Text('Are you sure you want to leave without saving?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false), // NOを選択した場合はfalseを返す
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true), // YESを選択した場合はtrueを返す
            child: const Text('Yes'),
          ),
        ],
      ),
    );

    // YESが選択された場合はtrue、NOが選択された場合はfalseを返す
    return confirmed ?? false;
  }


  void _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt('eventDate', Globals.eventDate.millisecondsSinceEpoch);
    prefs.setInt('setDate', Globals.setDate.millisecondsSinceEpoch);
    prefs.setInt('spendYear', int.tryParse(_yearsController.text) ?? 0);
    prefs.setInt('spendMonth', int.tryParse(_monthsController.text) ?? 0);
    prefs.setInt('spendDay', int.tryParse(_daysController.text) ?? 0);
    prefs.setString('appBarTitle', _titleController.text);
    prefs.setInt('formatTime', _selectedFormat);
    Globals.spendYear = int.tryParse(_yearsController.text) ?? 0;
    Globals.spendMonth = int.tryParse(_monthsController.text) ?? 0;
    Globals.spendDay = int.tryParse(_daysController.text) ?? 0;
    Globals.appBarTitle = _titleController.text;
    Globals.formatTime = _selectedFormat;
    Globals.changeResult = true;
  }
}
