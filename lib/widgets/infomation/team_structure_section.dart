import 'package:campus_motorsport/provider/global/current_user.dart';
import 'package:campus_motorsport/provider/information/offline_information_provider.dart';
import 'package:campus_motorsport/utilities/size_config.dart';
import 'package:campus_motorsport/widgets/general/buttons/cm_text_button.dart';
import 'package:campus_motorsport/widgets/general/cards/simple_card.dart';
import 'package:campus_motorsport/widgets/general/forms/cm_label.dart';
import 'package:campus_motorsport/widgets/general/forms/cm_pdf_picker.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Shows the pdf, admins can replace the current one when online.
class TeamStructureSection extends StatefulWidget {
  const TeamStructureSection({
    this.offlineMode = false,
    Key? key,
  }) : super(key: key);

  final bool offlineMode;

  @override
  _TeamStructureSectionState createState() => _TeamStructureSectionState();
}

class _TeamStructureSectionState extends State<TeamStructureSection> {
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    final dataProvider = context.watch<OfflineInformationProvider>();

    late final bool isAdmin;
    if (dataProvider.offlineMode) {
      isAdmin = false;
    } else {
      isAdmin = context.read<CurrentUser>().user?.isAdmin ?? false;
    }

    if (!isAdmin && dataProvider.teamStructure == null) {
      return Center(
        child: Text('Keine Daten gefunden.'),
      );
    }

    return SimpleCard(
      margin: const EdgeInsets.symmetric(vertical: SizeConfig.basePadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CMLabel(label: 'Organigramm'),
          const SizedBox(
            height: SizeConfig.basePadding,
          ),
          CMPdfPicker(
            savePdf: (_, path) => savePdf(path, dataProvider),
            heroTag: 'teamStructurePdf',
            loading: loading,
            filePath: dataProvider.teamStructure?.localFilePath,
            enabled: !loading && isAdmin,
          ),
        ],
      ),
    );
  }

  Future<void> savePdf(
    String? path,
    OfflineInformationProvider dataProvider,
  ) async {
    setState(() {
      loading = true;
    });
    late final bool success;
    if (path != null) {
      success = await dataProvider.setTeamStructure(path);
    } else {
      success = await dataProvider.deleteTeamStructure();
    }
    if (!success) {
      _showErrorDialog(context);
    }
    setState(() {
      loading = false;
    });
  }

  void _showErrorDialog(BuildContext context) {
    CoolAlert.show(
      context: context,
      type: CoolAlertType.error,
      backgroundColor: Theme.of(context).colorScheme.surface,
      title: 'Speichern fehlgeschlagen.',
      text: '',
      confirmButton: Expanded(
        child: Container(
          margin: const EdgeInsets.symmetric(
            horizontal: SizeConfig.basePadding * 2,
          ),
          child: CMTextButton(
            child: const Text(
              'VERSTANDEN',
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ),
      ),
      loopAnimation: false,
    );
  }
}
