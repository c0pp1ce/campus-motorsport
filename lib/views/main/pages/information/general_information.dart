import 'package:campus_motorsport/provider/global/current_user.dart';
import 'package:campus_motorsport/provider/information/offline_information_provider.dart';
import 'package:campus_motorsport/repositories/cloud_functions.dart';
import 'package:campus_motorsport/utilities/size_config.dart';
import 'package:campus_motorsport/widgets/general/buttons/cm_text_button.dart';
import 'package:campus_motorsport/widgets/general/layout/expanded_appbar.dart';
import 'package:campus_motorsport/widgets/general/layout/expanded_title.dart';
import 'package:campus_motorsport/widgets/general/layout/loading_list.dart';
import 'package:campus_motorsport/widgets/infomation/team_structure_section.dart';
import 'package:campus_motorsport/widgets/infomation/training_grounds_card.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

/// Training grounds and team structure.
class GeneralInformation extends StatefulWidget {
  const GeneralInformation({
    required this.offlineMode,
    Key? key,
  }) : super(key: key);

  final bool offlineMode;

  @override
  _GeneralInformationState createState() => _GeneralInformationState();
}

class _GeneralInformationState extends State<GeneralInformation> {
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    final OfflineInformationProvider dataProvider =
        context.watch<OfflineInformationProvider>();

    return ExpandedAppBar(
      appbarTitle: Text(
        'Allgemeine Informationen',
        style: Theme.of(context).textTheme.headline6,
      ),
      appbarChild: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: SizeConfig.basePadding,
        ),
        child: const Center(
          child: ExpandedTitle(
            title: 'Allgemeine Informationen',
          ),
        ),
      ),
      offsetBeforeTitleShown: 50,
      onRefresh: () async {
        await dataProvider.updateTrainingGrounds(true);
        await dataProvider.getTeamStructure();
      },
      loadingListener: (value) {
        setState(() {
          _loading = value;
        });
      },
      body: _loading ? LoadingList() : _buildBody(dataProvider),
    );
  }

  Widget _buildBody(OfflineInformationProvider dataProvider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: SizeConfig.basePadding),
      child: Column(
        children: [
          _buildTrainingGrounds(dataProvider),
          const SizedBox(
            height: SizeConfig.basePadding * 2,
          ),
          Text(
            'Team-Infos',
            style: Theme.of(context)
                .textTheme
                .headline6
                ?.copyWith(color: Theme.of(context).colorScheme.primary),
            textAlign: context.read<CurrentUser>().user?.isAdmin ?? false
                ? null
                : TextAlign.center,
          ),
          const SizedBox(
            height: SizeConfig.basePadding,
          ),
          TeamStructureSection(),
        ],
      ),
    );
  }

  Widget _buildTrainingGrounds(OfflineInformationProvider dataProvider) {
    final Widget title = Row(
      children: [
        Expanded(
          child: Text(
            'Trainingsgelände',
            style: Theme.of(context)
                .textTheme
                .headline6
                ?.copyWith(color: Theme.of(context).colorScheme.primary),
            textAlign: context.read<CurrentUser>().user?.isAdmin ?? false
                ? null
                : TextAlign.center,
          ),
        ),
        if ((context.watch<CurrentUser>().user?.isAdmin ?? false) &&
            !widget.offlineMode)
          TextButton(
            onPressed: () async {
              setState(() {
                _loading = true;
              });
              await getTrainingGroundsOverview();
              _showDelayInfoDialog();
              await dataProvider.updateTrainingGrounds(true);
              setState(() {
                _loading = false;
              });
            },
            child: Text('AUS WIKI ABRUFEN'),
          ),
      ],
    );

    if (dataProvider.trainingGrounds.isEmpty) {
      return Column(
        children: [
          title,
          const SizedBox(
            height: SizeConfig.basePadding,
          ),
          Text('Keine Daten gefunden.'),
        ],
      );
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        title,
        if ((context.read<CurrentUser>().user?.isAdmin ?? false) &&
            !widget.offlineMode)
          SizedBox(
            width: SizeConfig.screenWidth,
            child: Text(
              'Aktualisiert am ${DateFormat.yMMMMd().format(dataProvider.tgLastUpdate?.toLocal() ?? DateTime.utc(1900).toLocal())}',
            ),
          ),
        const SizedBox(
          height: SizeConfig.basePadding,
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: dataProvider.trainingGrounds.length,
          itemBuilder: (context, index) {
            return TrainingGroundCard(
              trainingGround: dataProvider.trainingGrounds[index],
            );
          },
        ),
      ],
    );
  }

  void _showDelayInfoDialog() {
    CoolAlert.show(
      barrierDismissible: false,
      context: context,
      type: CoolAlertType.info,
      backgroundColor: Theme.of(context).colorScheme.surface,
      title: 'Achtung!',
      text: 'Es kann mehrere Minuten dauern bis die Daten geladen sind.\n\n'
          'Bitte verlasse die Seite erst, wenn die Daten vollständig geladen sind.',
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
