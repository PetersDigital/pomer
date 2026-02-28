import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pomer/features/settings/models/settings_state.dart';
import 'package:pomer/features/settings/providers/settings_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(settingsNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: settingsAsync.when(
        data: (settings) => ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            _buildPresetSection(context, ref, settings),
            const Divider(),
            _buildDurationsSection(context, ref, settings),
            const Divider(),
            _buildTogglesSection(context, ref, settings),
            const Divider(),
            _buildAppearanceSection(context, ref, settings),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }

  Widget _buildPresetSection(
    BuildContext context,
    WidgetRef ref,
    SettingsState settings,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Timer Preset',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.primary,
              ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<TimerPreset>(
          initialValue: settings.selectedPreset,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
          items: TimerPreset.values.map((preset) {
            return DropdownMenuItem(
              value: preset,
              child: Text(preset.label),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              ref.read(settingsNotifierProvider.notifier).applyPreset(value);
            }
          },
        ),
      ],
    );
  }

  Widget _buildDurationsSection(
    BuildContext context,
    WidgetRef ref,
    SettingsState settings,
  ) {
    final isCustom = settings.selectedPreset == TimerPreset.custom;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Durations (minutes)',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.primary,
              ),
        ),
        const SizedBox(height: 16),
        _DurationSlider(
          label: 'Focus',
          value: settings.focusDuration,
          min: 1,
          max: 120,
          enabled: isCustom,
          onChanged: (val) {
            ref.read(settingsNotifierProvider.notifier).updateDurations(
                  focus: val,
                  shortBreak: settings.shortBreakDuration,
                  longBreak: settings.longBreakDuration,
                  preset: settings.selectedPreset,
                );
          },
        ),
        _DurationSlider(
          label: 'Short Break',
          value: settings.shortBreakDuration,
          min: 1,
          max: 30,
          enabled: isCustom,
          onChanged: (val) {
            ref.read(settingsNotifierProvider.notifier).updateDurations(
                  focus: settings.focusDuration,
                  shortBreak: val,
                  longBreak: settings.longBreakDuration,
                  preset: settings.selectedPreset,
                );
          },
        ),
        _DurationSlider(
          label: 'Long Break',
          value: settings.longBreakDuration,
          min: 1,
          max: 60,
          enabled: isCustom,
          onChanged: (val) {
            ref.read(settingsNotifierProvider.notifier).updateDurations(
                  focus: settings.focusDuration,
                  shortBreak: settings.shortBreakDuration,
                  longBreak: val,
                  preset: settings.selectedPreset,
                );
          },
        ),
      ],
    );
  }

  Widget _buildTogglesSection(
    BuildContext context,
    WidgetRef ref,
    SettingsState settings,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Automation & Display',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.primary,
              ),
        ),
        SwitchListTile(
          title: const Text('Auto-start Breaks'),
          value: settings.autoStartBreaks,
          onChanged: (val) {
            ref
                .read(settingsNotifierProvider.notifier)
                .toggleAutoStartBreaks(val);
          },
        ),
        SwitchListTile(
          title: const Text('Auto-start Pomodoros'),
          value: settings.autoStartPomodoros,
          onChanged: (val) {
            ref
                .read(settingsNotifierProvider.notifier)
                .toggleAutoStartPomodoros(val);
          },
        ),
        SwitchListTile(
          title: const Text('Keep Screen On'),
          value: settings.keepScreenOn,
          onChanged: (val) {
            ref.read(settingsNotifierProvider.notifier).toggleKeepScreenOn(val);
          },
        ),
      ],
    );
  }

  Widget _buildAppearanceSection(
    BuildContext context,
    WidgetRef ref,
    SettingsState settings,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Appearance',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.primary,
              ),
        ),
        ListTile(
          title: const Text('Theme'),
          trailing: DropdownButton<ThemeMode>(
            value: settings.themeMode,
            items: const [
              DropdownMenuItem(
                value: ThemeMode.system,
                child: Text('System'),
              ),
              DropdownMenuItem(
                value: ThemeMode.light,
                child: Text('Light'),
              ),
              DropdownMenuItem(
                value: ThemeMode.dark,
                child: Text('Dark'),
              ),
            ],
            onChanged: (mode) {
              if (mode != null) {
                ref.read(settingsNotifierProvider.notifier).setThemeMode(mode);
              }
            },
          ),
        ),
      ],
    );
  }
}

class _DurationSlider extends StatelessWidget {
  const _DurationSlider({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.enabled,
    required this.onChanged,
  });

  final String label;
  final int value;
  final int min;
  final int max;
  final bool enabled;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 100,
          child: Text(label),
        ),
        Expanded(
          child: Slider(
            value: value.toDouble(),
            min: min.toDouble(),
            max: max.toDouble(),
            divisions: max - min,
            label: value.toString(),
            onChanged: enabled ? (val) => onChanged(val.toInt()) : null,
          ),
        ),
        SizedBox(
          width: 40,
          child: Text(
            '$value m',
            textAlign: TextAlign.right,
            style: TextStyle(
              color: enabled
                  ? Theme.of(context).colorScheme.onSurface
                  : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
        ),
      ],
    );
  }
}
