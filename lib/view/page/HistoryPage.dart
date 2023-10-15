import 'package:fluent_ui/fluent_ui.dart';

class HistoryPage extends StatefulWidget {
  final List<String> history;

  const HistoryPage(this.history, {super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  String selectedContact = '';

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: widget.history.length,
        itemBuilder: (context, index) {
          final contact = widget.history[index];
          return ListTile.selectable(
            title: Text(contact),
            selected: selectedContact == contact,
            onSelectionChange: (v) => setState(() => selectedContact = contact),
          );
        });
  }
}
