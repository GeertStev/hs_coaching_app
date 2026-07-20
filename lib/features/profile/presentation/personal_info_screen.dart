import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hs_coaching_app/features/auth/domain/app_user.dart';
import 'package:hs_coaching_app/features/auth/presentation/auth_error_messages.dart';
import 'package:hs_coaching_app/features/profile/presentation/profile_controller.dart';
import 'package:intl/intl.dart';

/// Formulier voor persoonlijke gegevens (adres, contact, geboortedatum,
/// geslacht) en noodcontacten.
class PersonalInfoScreen extends ConsumerStatefulWidget {
  const PersonalInfoScreen({super.key, required this.user});

  final AppUser user;

  @override
  ConsumerState<PersonalInfoScreen> createState() =>
      _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends ConsumerState<PersonalInfoScreen> {
  final _formKey = GlobalKey<FormState>();

  late final PersonalInfo _initial = widget.user.personalInfo.isNotEmpty
      ? widget.user.personalInfo.first
      : PersonalInfo(email: widget.user.email ?? '');

  late final _street = TextEditingController(text: _initial.street);
  late final _number = TextEditingController(text: _initial.number);
  late final _zipCode = TextEditingController(text: _initial.zipCode);
  late final _city = TextEditingController(text: _initial.city);
  late final _country = TextEditingController(text: _initial.country);
  late final _phone = TextEditingController(text: _initial.phoneNumber);
  late final _email = TextEditingController(text: _initial.email);
  late DateTime? _birthday = _initial.birthday;
  late String? _gender = _initial.gender;
  late List<EmergencyContact> _emergencyContacts = [
    ..._initial.emergencyContacts,
  ];

  static const _genders = ['M', 'V', 'X'];

  @override
  void dispose() {
    _street.dispose();
    _number.dispose();
    _zipCode.dispose();
    _city.dispose();
    _country.dispose();
    _phone.dispose();
    _email.dispose();
    super.dispose();
  }

  Future<void> _pickBirthday() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthday ?? DateTime(now.year - 20),
      firstDate: DateTime(1920),
      lastDate: now,
    );
    if (picked != null) setState(() => _birthday = picked);
  }

  Future<void> _editEmergencyContact({EmergencyContact? existing}) async {
    final result = await showDialog<EmergencyContact>(
      context: context,
      builder: (context) => _EmergencyContactDialog(contact: existing),
    );
    if (result == null) return;
    setState(() {
      if (existing != null) {
        final index = _emergencyContacts.indexOf(existing);
        _emergencyContacts[index] = result;
      } else {
        _emergencyContacts = [..._emergencyContacts, result];
      }
    });
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    String? clean(TextEditingController c) =>
        c.text.trim().isEmpty ? null : c.text.trim();

    final updated = _initial.copyWith(
      street: clean(_street),
      number: clean(_number),
      zipCode: clean(_zipCode),
      city: clean(_city),
      country: clean(_country),
      phoneNumber: clean(_phone),
      email: _email.text.trim(),
      birthday: _birthday,
      gender: _gender,
      emergencyContacts: _emergencyContacts,
    );
    // Eerste item vervangen (of toevoegen); overige items blijven staan.
    final list = [...widget.user.personalInfo];
    if (list.isEmpty) {
      list.add(updated);
    } else {
      list[0] = updated;
    }
    final ok = await ref
        .read(profileControllerProvider.notifier)
        .setPersonalInfo(list);
    if (!mounted) return;
    if (ok) {
      Navigator.of(context).pop();
    } else {
      final error = ref.read(profileControllerProvider).error;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(authErrorMessage(error ?? ''))));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isBusy = ref.watch(profileControllerProvider).isLoading;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Persoonlijke gegevens'),
        actions: [
          TextButton(
            onPressed: isBusy ? null : _save,
            child: const Text('Opslaan'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text('Contact', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            TextFormField(
              controller: _email,
              decoration: const InputDecoration(labelText: 'E-mailadres'),
              keyboardType: TextInputType.emailAddress,
              validator: AuthValidators.email,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _phone,
              decoration: const InputDecoration(labelText: 'Telefoonnummer'),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 24),
            Text('Adres', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: TextFormField(
                    controller: _street,
                    decoration: const InputDecoration(labelText: 'Straat'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _number,
                    decoration: const InputDecoration(labelText: 'Nr.'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _zipCode,
                    decoration: const InputDecoration(labelText: 'Postcode'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: _city,
                    decoration: const InputDecoration(labelText: 'Gemeente'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _country,
              decoration: const InputDecoration(labelText: 'Land'),
            ),
            const SizedBox(height: 24),
            Text('Persoonlijk', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.cake_outlined),
              title: const Text('Geboortedatum'),
              subtitle: Text(
                _birthday != null
                    ? DateFormat('d MMMM yyyy').format(_birthday!)
                    : 'Niet ingevuld',
              ),
              trailing: const Icon(Icons.edit_outlined),
              onTap: _pickBirthday,
            ),
            DropdownButtonFormField<String>(
              initialValue: _genders.contains(_gender) ? _gender : null,
              decoration: const InputDecoration(labelText: 'Geslacht'),
              items: const [
                DropdownMenuItem(value: 'M', child: Text('Man')),
                DropdownMenuItem(value: 'V', child: Text('Vrouw')),
                DropdownMenuItem(value: 'X', child: Text('X')),
              ],
              onChanged: (value) => setState(() => _gender = value),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Noodcontacten',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  tooltip: 'Noodcontact toevoegen',
                  onPressed: () => _editEmergencyContact(),
                ),
              ],
            ),
            if (_emergencyContacts.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text('Nog geen noodcontacten toegevoegd.'),
              ),
            for (final contact in _emergencyContacts)
              Card(
                child: ListTile(
                  leading: const Icon(Icons.emergency_outlined),
                  title: Text('${contact.firstName} ${contact.lastName}'),
                  subtitle: Text(contact.phoneNumber),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit_outlined),
                        onPressed: () =>
                            _editEmergencyContact(existing: contact),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () => setState(
                          () => _emergencyContacts = [..._emergencyContacts]
                            ..remove(contact),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _EmergencyContactDialog extends StatefulWidget {
  const _EmergencyContactDialog({this.contact});

  final EmergencyContact? contact;

  @override
  State<_EmergencyContactDialog> createState() =>
      _EmergencyContactDialogState();
}

class _EmergencyContactDialogState extends State<_EmergencyContactDialog> {
  final _formKey = GlobalKey<FormState>();
  late final _firstName = TextEditingController(
    text: widget.contact?.firstName,
  );
  late final _lastName = TextEditingController(text: widget.contact?.lastName);
  late final _phone = TextEditingController(text: widget.contact?.phoneNumber);

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _phone.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.contact == null
            ? 'Noodcontact toevoegen'
            : 'Noodcontact bewerken',
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _firstName,
              decoration: const InputDecoration(labelText: 'Voornaam'),
              validator: (v) =>
                  AuthValidators.requiredField(v, label: 'een voornaam'),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _lastName,
              decoration: const InputDecoration(labelText: 'Achternaam'),
              validator: (v) =>
                  AuthValidators.requiredField(v, label: 'een achternaam'),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _phone,
              decoration: const InputDecoration(labelText: 'Telefoonnummer'),
              validator: (v) =>
                  AuthValidators.requiredField(v, label: 'een telefoonnummer'),
              keyboardType: TextInputType.phone,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Annuleren'),
        ),
        FilledButton(
          onPressed: () {
            if (_formKey.currentState?.validate() ?? false) {
              Navigator.of(context).pop(
                EmergencyContact(
                  firstName: _firstName.text.trim(),
                  lastName: _lastName.text.trim(),
                  phoneNumber: _phone.text.trim(),
                ),
              );
            }
          },
          child: const Text('Opslaan'),
        ),
      ],
    );
  }
}
