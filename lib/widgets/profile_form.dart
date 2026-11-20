import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProfileForm extends ConsumerStatefulWidget {
  const ProfileForm({super.key});

  @override
  State<ProfileForm> createState() => _ProfileFormState();
}

class _ProfileFormState extends State<ProfileForm> {
  final _formKey = GlobalKey<FormState>();
  final _introduction = TextEditingController();
  final _contactDetails = TextEditingController();
  final _experience = TextEditingController();
  final _serviceCategoryIds = TextEditingController();
  final _address = TextEditingController();
  final _serviceRadiusKm = TextEditingController();
  final _autovalidateMode = AutovalidateMode.disabled;
  final _serverErrors = <String, String>{};
  String? _generalError;
  final bool _submitting = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold();
  }
}
