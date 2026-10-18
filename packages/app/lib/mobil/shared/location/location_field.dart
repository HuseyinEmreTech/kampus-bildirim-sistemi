import 'dart:async';

import 'package:flutter/material.dart';

import '../error_text.dart';
import 'location_source.dart';

/// Form içinde konum alanı (USR 01): "Konumumu al" ile GPS; izin yoksa ya da
/// konum alınamazsa bina listesi. Hiçbiri seçilmezse form gönderilmez.
class LocationField extends FormField<LocationChoice> {
  LocationField({
    super.key,
    required LocationProvider gps,
    required BuildingsSource buildings,
  }) : super(
         validator: (choice) => choice == null
             ? 'Konum seçin: konumunuzu alın ya da bina seçin'
             : null,
         builder: (field) =>
             _LocationFieldView(field: field, gps: gps, buildings: buildings),
       );
}

class _LocationFieldView extends StatefulWidget {
  const _LocationFieldView({
    required this.field,
    required this.gps,
    required this.buildings,
  });

  final FormFieldState<LocationChoice> field;
  final LocationProvider gps;
  final BuildingsSource buildings;

  @override
  State<_LocationFieldView> createState() => _LocationFieldViewState();
}

class _LocationFieldViewState extends State<_LocationFieldView> {
  /// GPS neden kullanılamadı (bina listesinin üstünde gösterilir).
  String? _gpsProblem;

  /// `null`: bina listesi istenmedi; sonra yükleniyor, yüklendi ya da hata.
  BuildingsResult? _buildings;
  bool _showBuildings = false;

  Future<void> _useGps() async {
    final result = await widget.gps.current();
    if (!mounted) return;
    switch (result) {
      case GpsFix(:final latitude, :final longitude):
        widget.field.didChange(
          GpsChoice(latitude: latitude, longitude: longitude),
        );
      case GpsDenied():
        _showBuildingList('Konum izni verilmedi; bina seçin');
      case GpsUnavailable():
        _showBuildingList('Konum alınamadı; bina seçin');
    }
  }

  void _showBuildingList([String? gpsProblem]) {
    setState(() {
      _gpsProblem = gpsProblem;
      _showBuildings = true;
      _buildings = null;
    });
    unawaited(_loadBuildings());
  }

  Future<void> _loadBuildings() async {
    final result = await widget.buildings.fetch();
    if (!mounted) return;
    setState(() => _buildings = result);
  }

  @override
  Widget build(BuildContext context) {
    final choice = widget.field.value;
    final error = widget.field.errorText;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (choice is GpsChoice)
          const ListTile(
            leading: Icon(Icons.check_circle),
            title: Text('Konum alındı'),
          )
        else
          Wrap(
            spacing: 8,
            children: [
              OutlinedButton.icon(
                onPressed: _useGps,
                icon: const Icon(Icons.my_location),
                label: const Text('Konumumu al'),
              ),
              if (!_showBuildings)
                TextButton(
                  onPressed: _showBuildingList,
                  child: const Text('Bina listesinden seç'),
                ),
            ],
          ),
        if (_gpsProblem case final problem? when choice is! GpsChoice)
          Text(problem),
        if (_showBuildings && choice is! GpsChoice) _buildBuildingPicker(),
        if (error != null) ErrorText(error),
      ],
    );
  }

  Widget _buildBuildingPicker() {
    return switch (_buildings) {
      null => const LinearProgressIndicator(),
      // Büyük yazıda düğme alt satıra iner.
      BuildingsFailed() => Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          const Text('Bina listesi yüklenemedi'),
          TextButton(
            onPressed: _showBuildingList,
            child: const Text('Tekrar dene'),
          ),
        ],
      ),
      BuildingsLoaded(:final buildings) => DropdownButton<Building>(
        hint: const Text('Bina seçin'),
        isExpanded: true,
        value: switch (widget.field.value) {
          BuildingChoice(:final building) => building,
          GpsChoice() || null => null,
        },
        onChanged: (building) {
          if (building == null) return;
          widget.field.didChange(BuildingChoice(building));
        },
        items: [
          for (final building in buildings)
            DropdownMenuItem(value: building, child: Text(building.name)),
        ],
      ),
    };
  }
}
