import 'package:flutter/material.dart';
import 'package:flutter_project/utils/sized_box.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../constants/constant.dart';
import '../../l10n.dart';
import '../../models/user/learn_topic.dart';
import '../../models/user/test_preparation.dart';
import '../../models/user/user.dart';
import '../../providers/auth_provider.dart';
import '../../providers/language_provider.dart';
import '../../services/user_service.dart';
import '../../widgets/select_date.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({Key? key}) : super(key: key);

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  User? user;

  final _nameController = TextEditingController();
  final _studyScheduleController = TextEditingController();
  String emailAddress = '';
  String phoneNumber = '';
  String birthday = '';
  String country = '';
  String level = '';
  String imageUrl = '';
  List<LearnTopic> chosenTopics = [];
  List<TestPreparation> chosenTestPreparations = [];

  bool _isInitiated = false;
  bool _isLoading = true;

  late Locale currentLocale;

  @override
  void initState() {
    super.initState();
    currentLocale = context.read<LanguageProvider>().currentLocale;
    context.read<LanguageProvider>().addListener(() {
      setState(() {
        currentLocale = context.read<LanguageProvider>().currentLocale;
      });
    });
  }

  void _loadUserProfile(AuthProvider authProvider) async {
    final String token = authProvider.token?.access?.token as String;
    final result = await UserService.getUserInformation(token);

    _nameController.text = result?.name ?? '';
    emailAddress = result?.email ?? '';
    phoneNumber = result?.phone ?? '';
    birthday = result?.birthday ?? '';
    country = result?.country ?? '';
    level = result?.level ?? '';
    _studyScheduleController.text = result?.studySchedule ?? '';

    chosenTopics = result?.learnTopics ?? [];
    chosenTestPreparations = result?.testPreparations ?? [];

    setState(() {
      user = result;
      _isInitiated = true;
      _isLoading = false;
    });
  }

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        imageUrl = pickedFile.path;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    if (!_isInitiated) {
      _loadUserProfile(authProvider);
    }

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
        leading: BackButton(
          color: Theme.of(context).colorScheme.secondary,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          AppLocalizations(currentLocale).translate('profile')!,
          style: Theme.of(context).textTheme.displayMedium,
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Align(
                    alignment: Alignment.center,
                    child: Stack(
                      children: [
                        Container(
                          width: 108,
                          height: 108,
                          clipBehavior: Clip.hardEdge,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                          ),
                          child: Image.network(
                            authProvider.currentUser.avatar ?? '',
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.person_rounded),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: () {
                              _pickImage();
                            },
                            child: CircleAvatar(
                              backgroundColor:
                                  Theme.of(context).colorScheme.tertiary,
                              radius: 18,
                              child: const Icon(
                                Icons.camera_alt,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  sizedBox,
                  Text(
                    AppLocalizations(currentLocale).translate('name')!,
                    style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(context).colorScheme.tertiary,
                    ),
                  ),
                  subSizedBox,
                  TextField(
                    controller: _nameController,
                    autocorrect: false,
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 4,
                        horizontal: 8,
                      ),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey, width: 2),
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                    ),
                  ),
                  sizedBox,
                  Text(
                    'Email',
                    style: TextStyle(
                        fontSize: 16,
                        color: Theme.of(context).colorScheme.tertiary),
                  ),
                  subSizedBox,
                  Text(emailAddress),
                  sizedBox,
                  Text(
                    AppLocalizations(currentLocale).translate('phone')!,
                    style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(context).colorScheme.tertiary,
                    ),
                  ),
                  subSizedBox,
                  Text(phoneNumber),
                  sizedBox,
                  Text(
                    'Country',
                    style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(context).colorScheme.tertiary,
                    ),
                  ),
                  subSizedBox,
                  Text(
                    'Country',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[900],
                    ),
                  ),
                  const SizedBox(height: 4),
                  DropdownButtonFormField(
                    isExpanded: true,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 4,
                        horizontal: 8,
                      ),
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      border: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey, width: 2),
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                    ),
                    value: countries[country],
                    items: countries.values
                        .map((e) => DropdownMenuItem(
                              value: e,
                              child: Text(e, overflow: TextOverflow.ellipsis),
                            ))
                        .toList(),
                    onChanged: (value) {
                      final chosenCountry = countries.keys.firstWhere(
                        (element) => countries[element] == value,
                        orElse: () => 'US',
                      );
                      setState(() {
                        country = chosenCountry;
                      });
                    },
                  ),
                  sizedBox,
                  Text(
                    'Birthday',
                    style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(context).colorScheme.tertiary,
                    ),
                  ),
                  subSizedBox,
                  SelectDate(
                    initialValue: birthday,
                    onChanged: (newValue) {
                      setState(() {
                        birthday = newValue;
                      });
                    },
                  ),
                  Text(
                    'Study Schedule',
                    style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(context).colorScheme.tertiary,
                    ),
                  ),
                  subSizedBox,
                  TextField(
                    controller: _studyScheduleController,
                    autocorrect: false,
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 4,
                        horizontal: 8,
                      ),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey, width: 2),
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                    ),
                  ),
                  sizedBox,
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: TextButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                      backgroundColor: Theme.of(context).colorScheme.secondary,
                    ),
                    child: Text(
                      'SAVE',
                      style: TextStyle(
                        fontSize: 18,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  )
                ],
              ),
            ),
    );
  }
}
