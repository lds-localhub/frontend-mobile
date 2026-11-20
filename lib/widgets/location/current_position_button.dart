import 'package:geolocator/geolocator.dart';
import 'package:material_ui/material_ui.dart';

import 'package:localhub/data/locations.dart';
import 'package:localhub/utils/errors.dart';
import 'package:localhub/widgets/location/location_permission_sheet.dart';

const _positionUnavailable =
    'Não foi possível obter a posição. Introduza o endereço.';

/// «Usar a minha posição atual»: pede a permissão, obtém a posição uma única
/// vez e preenche o campo do endereço ([controller]) com a morada, que continua
/// editável.
///
/// Os erros vão para [onError], para o ecrã os mostrar junto ao campo; `null`
/// quando um novo pedido começa.
class CurrentPositionButton extends StatefulWidget {
  const CurrentPositionButton({
    super.key,
    required this.controller,
    required this.onError,
    this.enabled = true,
  });

  final TextEditingController controller;
  final ValueChanged<String?> onError;
  final bool enabled;

  @override
  State<CurrentPositionButton> createState() => _CurrentPositionButtonState();
}

class _CurrentPositionButtonState extends State<CurrentPositionButton> {
  bool _loading = false;

  // `false` quando a permissão é recusada (também para sempre)
  Future<bool> _hasPermission() async {
    try {
      var permission = await Geolocator.checkPermission();
      // A janela da aplicação só aparece enquanto o sistema ainda pode perguntar
      if (permission == LocationPermission.denied) {
        if (!mounted || !await LocationPermissionSheet.show(context)) {
          return false;
        }
        permission = await Geolocator.requestPermission();
      }
      return permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always;
    } catch (_) {
      return false;
    }
  }

  // `null` quando a posição não pode ser obtida: localização desligada ou o
  // dispositivo não respondeu
  Future<Position?> _getPosition() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        return null;
      }
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 20),
        ),
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> _handlePressed() async {
    widget.onError(null);
    // A permissão vem antes do indicador de carregamento: com a janela aberta
    // ainda não se está a obter nada
    if (!await _hasPermission()) {
      if (mounted) {
        widget.onError(_positionUnavailable);
      }
      return;
    }
    if (!mounted) {
      return;
    }
    setState(() => _loading = true);
    try {
      final position = await _getPosition();
      if (!mounted) {
        return;
      }
      if (position == null) {
        widget.onError(_positionUnavailable);
        return;
      }
      final address = await reverseGeocode(
        latitude: position.latitude,
        longitude: position.longitude,
      );
      if (mounted) {
        widget.controller.text = address;
      }
    } catch (e) {
      // 400 (posição sem morada) e 503 trazem o `detail`; sem rede, a mensagem geral
      if (mounted) {
        widget.onError(getErrorMessage(e));
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: TextButton.icon(
        onPressed: widget.enabled && !_loading ? _handlePressed : null,
        icon: _loading
            ? const SizedBox.square(
                dimension: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.my_location),
        label: const Text('Usar a minha posição atual'),
      ),
    );
  }
}
