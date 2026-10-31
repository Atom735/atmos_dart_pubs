// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: prefer_const_constructors, unused_element, lines_longer_than_80_chars
// Source: dart run tool/generate_workbench_colors.dart
// Keys: 439 (from lib/themes/**/*.json)

import '../color.dart';

/// Typed accessors for VS Code / Cursor workbench colors.
///
/// ## ENG
/// Example: `theme.colors.editor.background` → `VscColor?`.
/// Missing keys are `null`. Use [map] / `[]` for raw lookup.
///
/// ## RU
/// Пример: `theme.colors.editor.background` → `VscColor?`.
/// Нет ключа — `null`. Сырой доступ: [map] / `[]`.
class VscWorkbenchColors {
  /// Wraps a resolved workbench color map.
  const VscWorkbenchColors(this.map);

  /// Underlying merged color map.
  final Map<String, VscColor> map;

  /// Looks up a workbench color by full key.
  VscColor? operator [](String key) => map[key];

  /// `descriptionForeground`.
  VscColor? get descriptionForeground => map['descriptionForeground'];

  /// `disabledForeground`.
  VscColor? get disabledForeground => map['disabledForeground'];

  /// `errorForeground`.
  VscColor? get errorForeground => map['errorForeground'];

  /// `focusBorder`.
  VscColor? get focusBorder => map['focusBorder'];

  /// `foreground`.
  VscColor? get foreground => map['foreground'];

  /// Color group `actionBar`.
  VscWorkbenchActionBarColors get actionBar => VscWorkbenchActionBarColors(map);

  /// Color group `activityBar`.
  VscWorkbenchActivityBarColors get activityBar => VscWorkbenchActivityBarColors(map);

  /// Color group `activityBarBadge`.
  VscWorkbenchActivityBarBadgeColors get activityBarBadge => VscWorkbenchActivityBarBadgeColors(map);

  /// Color group `activityBarTop`.
  VscWorkbenchActivityBarTopColors get activityBarTop => VscWorkbenchActivityBarTopColors(map);

  /// Color group `activityErrorBadge`.
  VscWorkbenchActivityErrorBadgeColors get activityErrorBadge => VscWorkbenchActivityErrorBadgeColors(map);

  /// Color group `activityWarningBadge`.
  VscWorkbenchActivityWarningBadgeColors get activityWarningBadge => VscWorkbenchActivityWarningBadgeColors(map);

  /// Color group `agentStatusIndicator`.
  VscWorkbenchAgentStatusIndicatorColors get agentStatusIndicator => VscWorkbenchAgentStatusIndicatorColors(map);

  /// Color group `agents`.
  VscWorkbenchAgentsColors get agents => VscWorkbenchAgentsColors(map);

  /// Color group `agentsBadge`.
  VscWorkbenchAgentsBadgeColors get agentsBadge => VscWorkbenchAgentsBadgeColors(map);

  /// Color group `agentsChatInput`.
  VscWorkbenchAgentsChatInputColors get agentsChatInput => VscWorkbenchAgentsChatInputColors(map);

  /// Color group `agentsGradient`.
  VscWorkbenchAgentsGradientColors get agentsGradient => VscWorkbenchAgentsGradientColors(map);

  /// Color group `agentsNewSessionButton`.
  VscWorkbenchAgentsNewSessionButtonColors get agentsNewSessionButton => VscWorkbenchAgentsNewSessionButtonColors(map);

  /// Color group `agentsPanel`.
  VscWorkbenchAgentsPanelColors get agentsPanel => VscWorkbenchAgentsPanelColors(map);

  /// Color group `agentsUnreadBadge`.
  VscWorkbenchAgentsUnreadBadgeColors get agentsUnreadBadge => VscWorkbenchAgentsUnreadBadgeColors(map);

  /// Color group `badge`.
  VscWorkbenchBadgeColors get badge => VscWorkbenchBadgeColors(map);

  /// Color group `breadcrumb`.
  VscWorkbenchBreadcrumbColors get breadcrumb => VscWorkbenchBreadcrumbColors(map);

  /// Color group `breadcrumbPicker`.
  VscWorkbenchBreadcrumbPickerColors get breadcrumbPicker => VscWorkbenchBreadcrumbPickerColors(map);

  /// Color group `button`.
  VscWorkbenchButtonColors get button => VscWorkbenchButtonColors(map);

  /// Color group `chart`.
  VscWorkbenchChartColors get chart => VscWorkbenchChartColors(map);

  /// Color group `charts`.
  VscWorkbenchChartsColors get charts => VscWorkbenchChartsColors(map);

  /// Color group `chat`.
  VscWorkbenchChatColors get chat => VscWorkbenchChatColors(map);

  /// Color group `checkbox`.
  VscWorkbenchCheckboxColors get checkbox => VscWorkbenchCheckboxColors(map);

  /// Color group `commandCenter`.
  VscWorkbenchCommandCenterColors get commandCenter => VscWorkbenchCommandCenterColors(map);

  /// Color group `debugExceptionWidget`.
  VscWorkbenchDebugExceptionWidgetColors get debugExceptionWidget => VscWorkbenchDebugExceptionWidgetColors(map);

  /// Color group `debugToolBar`.
  VscWorkbenchDebugToolBarColors get debugToolBar => VscWorkbenchDebugToolBarColors(map);

  /// Color group `diffEditor`.
  VscWorkbenchDiffEditorColors get diffEditor => VscWorkbenchDiffEditorColors(map);

  /// Color group `dropdown`.
  VscWorkbenchDropdownColors get dropdown => VscWorkbenchDropdownColors(map);

  /// Color group `editor`.
  VscWorkbenchEditorColors get editor => VscWorkbenchEditorColors(map);

  /// Color group `editorBracketHighlight`.
  VscWorkbenchEditorBracketHighlightColors get editorBracketHighlight => VscWorkbenchEditorBracketHighlightColors(map);

  /// Color group `editorBracketMatch`.
  VscWorkbenchEditorBracketMatchColors get editorBracketMatch => VscWorkbenchEditorBracketMatchColors(map);

  /// Color group `editorCodeLens`.
  VscWorkbenchEditorCodeLensColors get editorCodeLens => VscWorkbenchEditorCodeLensColors(map);

  /// Color group `editorCommentsWidget`.
  VscWorkbenchEditorCommentsWidgetColors get editorCommentsWidget => VscWorkbenchEditorCommentsWidgetColors(map);

  /// Color group `editorCursor`.
  VscWorkbenchEditorCursorColors get editorCursor => VscWorkbenchEditorCursorColors(map);

  /// Color group `editorError`.
  VscWorkbenchEditorErrorColors get editorError => VscWorkbenchEditorErrorColors(map);

  /// Color group `editorGroup`.
  VscWorkbenchEditorGroupColors get editorGroup => VscWorkbenchEditorGroupColors(map);

  /// Color group `editorGroupHeader`.
  VscWorkbenchEditorGroupHeaderColors get editorGroupHeader => VscWorkbenchEditorGroupHeaderColors(map);

  /// Color group `editorGutter`.
  VscWorkbenchEditorGutterColors get editorGutter => VscWorkbenchEditorGutterColors(map);

  /// Color group `editorHoverWidget`.
  VscWorkbenchEditorHoverWidgetColors get editorHoverWidget => VscWorkbenchEditorHoverWidgetColors(map);

  /// Color group `editorIndentGuide`.
  VscWorkbenchEditorIndentGuideColors get editorIndentGuide => VscWorkbenchEditorIndentGuideColors(map);

  /// Color group `editorInlayHint`.
  VscWorkbenchEditorInlayHintColors get editorInlayHint => VscWorkbenchEditorInlayHintColors(map);

  /// Color group `editorLineNumber`.
  VscWorkbenchEditorLineNumberColors get editorLineNumber => VscWorkbenchEditorLineNumberColors(map);

  /// Color group `editorLink`.
  VscWorkbenchEditorLinkColors get editorLink => VscWorkbenchEditorLinkColors(map);

  /// Color group `editorMarkerNavigation`.
  VscWorkbenchEditorMarkerNavigationColors get editorMarkerNavigation => VscWorkbenchEditorMarkerNavigationColors(map);

  /// Color group `editorMarkerNavigationError`.
  VscWorkbenchEditorMarkerNavigationErrorColors get editorMarkerNavigationError => VscWorkbenchEditorMarkerNavigationErrorColors(map);

  /// Color group `editorMarkerNavigationWarning`.
  VscWorkbenchEditorMarkerNavigationWarningColors get editorMarkerNavigationWarning => VscWorkbenchEditorMarkerNavigationWarningColors(map);

  /// Color group `editorOverviewRuler`.
  VscWorkbenchEditorOverviewRulerColors get editorOverviewRuler => VscWorkbenchEditorOverviewRulerColors(map);

  /// Color group `editorRuler`.
  VscWorkbenchEditorRulerColors get editorRuler => VscWorkbenchEditorRulerColors(map);

  /// Color group `editorStickyScroll`.
  VscWorkbenchEditorStickyScrollColors get editorStickyScroll => VscWorkbenchEditorStickyScrollColors(map);

  /// Color group `editorStickyScrollHover`.
  VscWorkbenchEditorStickyScrollHoverColors get editorStickyScrollHover => VscWorkbenchEditorStickyScrollHoverColors(map);

  /// Color group `editorSuggestWidget`.
  VscWorkbenchEditorSuggestWidgetColors get editorSuggestWidget => VscWorkbenchEditorSuggestWidgetColors(map);

  /// Color group `editorUnnecessaryCode`.
  VscWorkbenchEditorUnnecessaryCodeColors get editorUnnecessaryCode => VscWorkbenchEditorUnnecessaryCodeColors(map);

  /// Color group `editorWarning`.
  VscWorkbenchEditorWarningColors get editorWarning => VscWorkbenchEditorWarningColors(map);

  /// Color group `editorWhitespace`.
  VscWorkbenchEditorWhitespaceColors get editorWhitespace => VscWorkbenchEditorWhitespaceColors(map);

  /// Color group `editorWidget`.
  VscWorkbenchEditorWidgetColors get editorWidget => VscWorkbenchEditorWidgetColors(map);

  /// Color group `extensionButton`.
  VscWorkbenchExtensionButtonColors get extensionButton => VscWorkbenchExtensionButtonColors(map);

  /// Color group `git`.
  VscWorkbenchGitColors get git => VscWorkbenchGitColors(map);

  /// Color group `gitDecoration`.
  VscWorkbenchGitDecorationColors get gitDecoration => VscWorkbenchGitDecorationColors(map);

  /// Color group `gitlens`.
  VscWorkbenchGitlensColors get gitlens => VscWorkbenchGitlensColors(map);

  /// Color group `icon`.
  VscWorkbenchIconColors get icon => VscWorkbenchIconColors(map);

  /// Color group `inlineChat`.
  VscWorkbenchInlineChatColors get inlineChat => VscWorkbenchInlineChatColors(map);

  /// Color group `input`.
  VscWorkbenchInputColors get input => VscWorkbenchInputColors(map);

  /// Color group `inputOption`.
  VscWorkbenchInputOptionColors get inputOption => VscWorkbenchInputOptionColors(map);

  /// Color group `inputValidation`.
  VscWorkbenchInputValidationColors get inputValidation => VscWorkbenchInputValidationColors(map);

  /// Color group `keybindingLabel`.
  VscWorkbenchKeybindingLabelColors get keybindingLabel => VscWorkbenchKeybindingLabelColors(map);

  /// Color group `list`.
  VscWorkbenchListColors get list => VscWorkbenchListColors(map);

  /// Color group `listFilterWidget`.
  VscWorkbenchListFilterWidgetColors get listFilterWidget => VscWorkbenchListFilterWidgetColors(map);

  /// Color group `menu`.
  VscWorkbenchMenuColors get menu => VscWorkbenchMenuColors(map);

  /// Color group `menubar`.
  VscWorkbenchMenubarColors get menubar => VscWorkbenchMenubarColors(map);

  /// Color group `merge`.
  VscWorkbenchMergeColors get merge => VscWorkbenchMergeColors(map);

  /// Color group `minimap`.
  VscWorkbenchMinimapColors get minimap => VscWorkbenchMinimapColors(map);

  /// Color group `minimapGutter`.
  VscWorkbenchMinimapGutterColors get minimapGutter => VscWorkbenchMinimapGutterColors(map);

  /// Color group `minimapSlider`.
  VscWorkbenchMinimapSliderColors get minimapSlider => VscWorkbenchMinimapSliderColors(map);

  /// Color group `notebook`.
  VscWorkbenchNotebookColors get notebook => VscWorkbenchNotebookColors(map);

  /// Color group `notificationCenter`.
  VscWorkbenchNotificationCenterColors get notificationCenter => VscWorkbenchNotificationCenterColors(map);

  /// Color group `notificationCenterHeader`.
  VscWorkbenchNotificationCenterHeaderColors get notificationCenterHeader => VscWorkbenchNotificationCenterHeaderColors(map);

  /// Color group `notificationLink`.
  VscWorkbenchNotificationLinkColors get notificationLink => VscWorkbenchNotificationLinkColors(map);

  /// Color group `notificationToast`.
  VscWorkbenchNotificationToastColors get notificationToast => VscWorkbenchNotificationToastColors(map);

  /// Color group `notifications`.
  VscWorkbenchNotificationsColors get notifications => VscWorkbenchNotificationsColors(map);

  /// Color group `notificationsErrorIcon`.
  VscWorkbenchNotificationsErrorIconColors get notificationsErrorIcon => VscWorkbenchNotificationsErrorIconColors(map);

  /// Color group `notificationsInfoIcon`.
  VscWorkbenchNotificationsInfoIconColors get notificationsInfoIcon => VscWorkbenchNotificationsInfoIconColors(map);

  /// Color group `notificationsWarningIcon`.
  VscWorkbenchNotificationsWarningIconColors get notificationsWarningIcon => VscWorkbenchNotificationsWarningIconColors(map);

  /// Color group `panel`.
  VscWorkbenchPanelColors get panel => VscWorkbenchPanelColors(map);

  /// Color group `panelInput`.
  VscWorkbenchPanelInputColors get panelInput => VscWorkbenchPanelInputColors(map);

  /// Color group `panelSection`.
  VscWorkbenchPanelSectionColors get panelSection => VscWorkbenchPanelSectionColors(map);

  /// Color group `panelSectionHeader`.
  VscWorkbenchPanelSectionHeaderColors get panelSectionHeader => VscWorkbenchPanelSectionHeaderColors(map);

  /// Color group `panelStickyScroll`.
  VscWorkbenchPanelStickyScrollColors get panelStickyScroll => VscWorkbenchPanelStickyScrollColors(map);

  /// Color group `panelTitle`.
  VscWorkbenchPanelTitleColors get panelTitle => VscWorkbenchPanelTitleColors(map);

  /// Color group `peekView`.
  VscWorkbenchPeekViewColors get peekView => VscWorkbenchPeekViewColors(map);

  /// Color group `peekViewEditor`.
  VscWorkbenchPeekViewEditorColors get peekViewEditor => VscWorkbenchPeekViewEditorColors(map);

  /// Color group `peekViewEditorGutter`.
  VscWorkbenchPeekViewEditorGutterColors get peekViewEditorGutter => VscWorkbenchPeekViewEditorGutterColors(map);

  /// Color group `peekViewResult`.
  VscWorkbenchPeekViewResultColors get peekViewResult => VscWorkbenchPeekViewResultColors(map);

  /// Color group `peekViewTitle`.
  VscWorkbenchPeekViewTitleColors get peekViewTitle => VscWorkbenchPeekViewTitleColors(map);

  /// Color group `peekViewTitleDescription`.
  VscWorkbenchPeekViewTitleDescriptionColors get peekViewTitleDescription => VscWorkbenchPeekViewTitleDescriptionColors(map);

  /// Color group `peekViewTitleLabel`.
  VscWorkbenchPeekViewTitleLabelColors get peekViewTitleLabel => VscWorkbenchPeekViewTitleLabelColors(map);

  /// Color group `pickerGroup`.
  VscWorkbenchPickerGroupColors get pickerGroup => VscWorkbenchPickerGroupColors(map);

  /// Color group `ports`.
  VscWorkbenchPortsColors get ports => VscWorkbenchPortsColors(map);

  /// Color group `problemsWarningIcon`.
  VscWorkbenchProblemsWarningIconColors get problemsWarningIcon => VscWorkbenchProblemsWarningIconColors(map);

  /// Color group `progressBar`.
  VscWorkbenchProgressBarColors get progressBar => VscWorkbenchProgressBarColors(map);

  /// Color group `quickInput`.
  VscWorkbenchQuickInputColors get quickInput => VscWorkbenchQuickInputColors(map);

  /// Color group `quickInputList`.
  VscWorkbenchQuickInputListColors get quickInputList => VscWorkbenchQuickInputListColors(map);

  /// Color group `quickInputTitle`.
  VscWorkbenchQuickInputTitleColors get quickInputTitle => VscWorkbenchQuickInputTitleColors(map);

  /// Color group `sash`.
  VscWorkbenchSashColors get sash => VscWorkbenchSashColors(map);

  /// Color group `scrollbar`.
  VscWorkbenchScrollbarColors get scrollbar => VscWorkbenchScrollbarColors(map);

  /// Color group `scrollbarSlider`.
  VscWorkbenchScrollbarSliderColors get scrollbarSlider => VscWorkbenchScrollbarSliderColors(map);

  /// Color group `searchEditor`.
  VscWorkbenchSearchEditorColors get searchEditor => VscWorkbenchSearchEditorColors(map);

  /// Color group `selection`.
  VscWorkbenchSelectionColors get selection => VscWorkbenchSelectionColors(map);

  /// Color group `settings`.
  VscWorkbenchSettingsColors get settings => VscWorkbenchSettingsColors(map);

  /// Color group `sideBar`.
  VscWorkbenchSideBarColors get sideBar => VscWorkbenchSideBarColors(map);

  /// Color group `sideBarSectionHeader`.
  VscWorkbenchSideBarSectionHeaderColors get sideBarSectionHeader => VscWorkbenchSideBarSectionHeaderColors(map);

  /// Color group `sideBarStickyScroll`.
  VscWorkbenchSideBarStickyScrollColors get sideBarStickyScroll => VscWorkbenchSideBarStickyScrollColors(map);

  /// Color group `sideBarTitle`.
  VscWorkbenchSideBarTitleColors get sideBarTitle => VscWorkbenchSideBarTitleColors(map);

  /// Color group `statusBar`.
  VscWorkbenchStatusBarColors get statusBar => VscWorkbenchStatusBarColors(map);

  /// Color group `statusBarItem`.
  VscWorkbenchStatusBarItemColors get statusBarItem => VscWorkbenchStatusBarItemColors(map);

  /// Color group `surface`.
  VscWorkbenchSurfaceColors get surface => VscWorkbenchSurfaceColors(map);

  /// Color group `tab`.
  VscWorkbenchTabColors get tab => VscWorkbenchTabColors(map);

  /// Color group `terminal`.
  VscWorkbenchTerminalColors get terminal => VscWorkbenchTerminalColors(map);

  /// Color group `terminalCursor`.
  VscWorkbenchTerminalCursorColors get terminalCursor => VscWorkbenchTerminalCursorColors(map);

  /// Color group `terminalStickyScroll`.
  VscWorkbenchTerminalStickyScrollColors get terminalStickyScroll => VscWorkbenchTerminalStickyScrollColors(map);

  /// Color group `textBlockQuote`.
  VscWorkbenchTextBlockQuoteColors get textBlockQuote => VscWorkbenchTextBlockQuoteColors(map);

  /// Color group `textCodeBlock`.
  VscWorkbenchTextCodeBlockColors get textCodeBlock => VscWorkbenchTextCodeBlockColors(map);

  /// Color group `textLink`.
  VscWorkbenchTextLinkColors get textLink => VscWorkbenchTextLinkColors(map);

  /// Color group `textPreformat`.
  VscWorkbenchTextPreformatColors get textPreformat => VscWorkbenchTextPreformatColors(map);

  /// Color group `textSeparator`.
  VscWorkbenchTextSeparatorColors get textSeparator => VscWorkbenchTextSeparatorColors(map);

  /// Color group `titleBar`.
  VscWorkbenchTitleBarColors get titleBar => VscWorkbenchTitleBarColors(map);

  /// Color group `toolbar`.
  VscWorkbenchToolbarColors get toolbar => VscWorkbenchToolbarColors(map);

  /// Color group `tree`.
  VscWorkbenchTreeColors get tree => VscWorkbenchTreeColors(map);

  /// Color group `walkThrough`.
  VscWorkbenchWalkThroughColors get walkThrough => VscWorkbenchWalkThroughColors(map);

  /// Color group `welcomePage`.
  VscWorkbenchWelcomePageColors get welcomePage => VscWorkbenchWelcomePageColors(map);

  /// Color group `widget`.
  VscWorkbenchWidgetColors get widget => VscWorkbenchWidgetColors(map);

}

/// Workbench colors under `actionBar.…`.
class VscWorkbenchActionBarColors {
  /// Creates a group view over [map].
  const VscWorkbenchActionBarColors(this.map);

  /// Underlying merged color map.
  final Map<String, VscColor> map;

  /// `actionBar.toggledBackground`.
  VscColor? get toggledBackground => map['actionBar.toggledBackground'];

}

/// Workbench colors under `activityBar.…`.
class VscWorkbenchActivityBarColors {
  /// Creates a group view over [map].
  const VscWorkbenchActivityBarColors(this.map);

  /// Underlying merged color map.
  final Map<String, VscColor> map;

  /// `activityBar.activeBackground`.
  VscColor? get activeBackground => map['activityBar.activeBackground'];

  /// `activityBar.activeBorder`.
  VscColor? get activeBorder => map['activityBar.activeBorder'];

  /// `activityBar.activeFocusBorder`.
  VscColor? get activeFocusBorder => map['activityBar.activeFocusBorder'];

  /// `activityBar.background`.
  VscColor? get background => map['activityBar.background'];

  /// `activityBar.border`.
  VscColor? get border => map['activityBar.border'];

  /// `activityBar.foreground`.
  VscColor? get foreground => map['activityBar.foreground'];

  /// `activityBar.inactiveForeground`.
  VscColor? get inactiveForeground => map['activityBar.inactiveForeground'];

}

/// Workbench colors under `activityBarBadge.…`.
class VscWorkbenchActivityBarBadgeColors {
  /// Creates a group view over [map].
  const VscWorkbenchActivityBarBadgeColors(this.map);

  /// Underlying merged color map.
  final Map<String, VscColor> map;

  /// `activityBarBadge.background`.
  VscColor? get background => map['activityBarBadge.background'];

  /// `activityBarBadge.foreground`.
  VscColor? get foreground => map['activityBarBadge.foreground'];

}

/// Workbench colors under `activityBarTop.…`.
class VscWorkbenchActivityBarTopColors {
  /// Creates a group view over [map].
  const VscWorkbenchActivityBarTopColors(this.map);

  /// Underlying merged color map.
  final Map<String, VscColor> map;

  /// `activityBarTop.activeBorder`.
  VscColor? get activeBorder => map['activityBarTop.activeBorder'];

}

/// Workbench colors under `activityErrorBadge.…`.
class VscWorkbenchActivityErrorBadgeColors {
  /// Creates a group view over [map].
  const VscWorkbenchActivityErrorBadgeColors(this.map);

  /// Underlying merged color map.
  final Map<String, VscColor> map;

  /// `activityErrorBadge.background`.
  VscColor? get background => map['activityErrorBadge.background'];

  /// `activityErrorBadge.foreground`.
  VscColor? get foreground => map['activityErrorBadge.foreground'];

}

/// Workbench colors under `activityWarningBadge.…`.
class VscWorkbenchActivityWarningBadgeColors {
  /// Creates a group view over [map].
  const VscWorkbenchActivityWarningBadgeColors(this.map);

  /// Underlying merged color map.
  final Map<String, VscColor> map;

  /// `activityWarningBadge.background`.
  VscColor? get background => map['activityWarningBadge.background'];

  /// `activityWarningBadge.foreground`.
  VscColor? get foreground => map['activityWarningBadge.foreground'];

}

/// Workbench colors under `agentStatusIndicator.…`.
class VscWorkbenchAgentStatusIndicatorColors {
  /// Creates a group view over [map].
  const VscWorkbenchAgentStatusIndicatorColors(this.map);

  /// Underlying merged color map.
  final Map<String, VscColor> map;

  /// `agentStatusIndicator.background`.
  VscColor? get background => map['agentStatusIndicator.background'];

}

/// Workbench colors under `agents.…`.
class VscWorkbenchAgentsColors {
  /// Creates a group view over [map].
  const VscWorkbenchAgentsColors(this.map);

  /// Underlying merged color map.
  final Map<String, VscColor> map;

  /// `agents.background`.
  VscColor? get background => map['agents.background'];

}

/// Workbench colors under `agentsBadge.…`.
class VscWorkbenchAgentsBadgeColors {
  /// Creates a group view over [map].
  const VscWorkbenchAgentsBadgeColors(this.map);

  /// Underlying merged color map.
  final Map<String, VscColor> map;

  /// `agentsBadge.background`.
  VscColor? get background => map['agentsBadge.background'];

  /// `agentsBadge.foreground`.
  VscColor? get foreground => map['agentsBadge.foreground'];

}

/// Workbench colors under `agentsChatInput.…`.
class VscWorkbenchAgentsChatInputColors {
  /// Creates a group view over [map].
  const VscWorkbenchAgentsChatInputColors(this.map);

  /// Underlying merged color map.
  final Map<String, VscColor> map;

  /// `agentsChatInput.background`.
  VscColor? get background => map['agentsChatInput.background'];

  /// `agentsChatInput.border`.
  VscColor? get border => map['agentsChatInput.border'];

  /// `agentsChatInput.focusBorder`.
  VscColor? get focusBorder => map['agentsChatInput.focusBorder'];

  /// `agentsChatInput.foreground`.
  VscColor? get foreground => map['agentsChatInput.foreground'];

  /// `agentsChatInput.placeholderForeground`.
  VscColor? get placeholderForeground => map['agentsChatInput.placeholderForeground'];

}

/// Workbench colors under `agentsGradient.…`.
class VscWorkbenchAgentsGradientColors {
  /// Creates a group view over [map].
  const VscWorkbenchAgentsGradientColors(this.map);

  /// Underlying merged color map.
  final Map<String, VscColor> map;

  /// `agentsGradient.tintColor`.
  VscColor? get tintColor => map['agentsGradient.tintColor'];

}

/// Workbench colors under `agentsNewSessionButton.…`.
class VscWorkbenchAgentsNewSessionButtonColors {
  /// Creates a group view over [map].
  const VscWorkbenchAgentsNewSessionButtonColors(this.map);

  /// Underlying merged color map.
  final Map<String, VscColor> map;

  /// `agentsNewSessionButton.background`.
  VscColor? get background => map['agentsNewSessionButton.background'];

  /// `agentsNewSessionButton.border`.
  VscColor? get border => map['agentsNewSessionButton.border'];

  /// `agentsNewSessionButton.foreground`.
  VscColor? get foreground => map['agentsNewSessionButton.foreground'];

  /// `agentsNewSessionButton.hoverBackground`.
  VscColor? get hoverBackground => map['agentsNewSessionButton.hoverBackground'];

}

/// Workbench colors under `agentsPanel.…`.
class VscWorkbenchAgentsPanelColors {
  /// Creates a group view over [map].
  const VscWorkbenchAgentsPanelColors(this.map);

  /// Underlying merged color map.
  final Map<String, VscColor> map;

  /// `agentsPanel.background`.
  VscColor? get background => map['agentsPanel.background'];

  /// `agentsPanel.border`.
  VscColor? get border => map['agentsPanel.border'];

  /// `agentsPanel.foreground`.
  VscColor? get foreground => map['agentsPanel.foreground'];

}

/// Workbench colors under `agentsUnreadBadge.…`.
class VscWorkbenchAgentsUnreadBadgeColors {
  /// Creates a group view over [map].
  const VscWorkbenchAgentsUnreadBadgeColors(this.map);

  /// Underlying merged color map.
  final Map<String, VscColor> map;

  /// `agentsUnreadBadge.background`.
  VscColor? get background => map['agentsUnreadBadge.background'];

  /// `agentsUnreadBadge.foreground`.
  VscColor? get foreground => map['agentsUnreadBadge.foreground'];

}

/// Workbench colors under `badge.…`.
class VscWorkbenchBadgeColors {
  /// Creates a group view over [map].
  const VscWorkbenchBadgeColors(this.map);

  /// Underlying merged color map.
  final Map<String, VscColor> map;

  /// `badge.background`.
  VscColor? get background => map['badge.background'];

  /// `badge.foreground`.
  VscColor? get foreground => map['badge.foreground'];

}

/// Workbench colors under `breadcrumb.…`.
class VscWorkbenchBreadcrumbColors {
  /// Creates a group view over [map].
  const VscWorkbenchBreadcrumbColors(this.map);

  /// Underlying merged color map.
  final Map<String, VscColor> map;

  /// `breadcrumb.activeSelectionForeground`.
  VscColor? get activeSelectionForeground => map['breadcrumb.activeSelectionForeground'];

  /// `breadcrumb.background`.
  VscColor? get background => map['breadcrumb.background'];

  /// `breadcrumb.focusForeground`.
  VscColor? get focusForeground => map['breadcrumb.focusForeground'];

  /// `breadcrumb.foreground`.
  VscColor? get foreground => map['breadcrumb.foreground'];

}

/// Workbench colors under `breadcrumbPicker.…`.
class VscWorkbenchBreadcrumbPickerColors {
  /// Creates a group view over [map].
  const VscWorkbenchBreadcrumbPickerColors(this.map);

  /// Underlying merged color map.
  final Map<String, VscColor> map;

  /// `breadcrumbPicker.background`.
  VscColor? get background => map['breadcrumbPicker.background'];

}

/// Workbench colors under `button.…`.
class VscWorkbenchButtonColors {
  /// Creates a group view over [map].
  const VscWorkbenchButtonColors(this.map);

  /// Underlying merged color map.
  final Map<String, VscColor> map;

  /// `button.background`.
  VscColor? get background => map['button.background'];

  /// `button.border`.
  VscColor? get border => map['button.border'];

  /// `button.foreground`.
  VscColor? get foreground => map['button.foreground'];

  /// `button.hoverBackground`.
  VscColor? get hoverBackground => map['button.hoverBackground'];

  /// `button.secondaryBackground`.
  VscColor? get secondaryBackground => map['button.secondaryBackground'];

  /// `button.secondaryBorder`.
  VscColor? get secondaryBorder => map['button.secondaryBorder'];

  /// `button.secondaryForeground`.
  VscColor? get secondaryForeground => map['button.secondaryForeground'];

  /// `button.secondaryHoverBackground`.
  VscColor? get secondaryHoverBackground => map['button.secondaryHoverBackground'];

}

/// Workbench colors under `chart.…`.
class VscWorkbenchChartColors {
  /// Creates a group view over [map].
  const VscWorkbenchChartColors(this.map);

  /// Underlying merged color map.
  final Map<String, VscColor> map;

  /// `chart.axis`.
  VscColor? get axis => map['chart.axis'];

  /// `chart.guide`.
  VscColor? get guide => map['chart.guide'];

  /// `chart.line`.
  VscColor? get line => map['chart.line'];

}

/// Workbench colors under `charts.…`.
class VscWorkbenchChartsColors {
  /// Creates a group view over [map].
  const VscWorkbenchChartsColors(this.map);

  /// Underlying merged color map.
  final Map<String, VscColor> map;

  /// `charts.blue`.
  VscColor? get blue => map['charts.blue'];

  /// `charts.foreground`.
  VscColor? get foreground => map['charts.foreground'];

  /// `charts.green`.
  VscColor? get green => map['charts.green'];

  /// `charts.lines`.
  VscColor? get lines => map['charts.lines'];

  /// `charts.orange`.
  VscColor? get orange => map['charts.orange'];

  /// `charts.purple`.
  VscColor? get purple => map['charts.purple'];

  /// `charts.red`.
  VscColor? get red => map['charts.red'];

  /// `charts.yellow`.
  VscColor? get yellow => map['charts.yellow'];

}

/// Workbench colors under `chat.…`.
class VscWorkbenchChatColors {
  /// Creates a group view over [map].
  const VscWorkbenchChatColors(this.map);

  /// Underlying merged color map.
  final Map<String, VscColor> map;

  /// `chat.editedFileForeground`.
  VscColor? get editedFileForeground => map['chat.editedFileForeground'];

  /// `chat.inputWorkingBorderColor1`.
  VscColor? get inputWorkingBorderColor1 => map['chat.inputWorkingBorderColor1'];

  /// `chat.requestBubbleBackground`.
  VscColor? get requestBubbleBackground => map['chat.requestBubbleBackground'];

  /// `chat.requestBubbleHoverBackground`.
  VscColor? get requestBubbleHoverBackground => map['chat.requestBubbleHoverBackground'];

  /// `chat.slashCommandBackground`.
  VscColor? get slashCommandBackground => map['chat.slashCommandBackground'];

  /// `chat.slashCommandForeground`.
  VscColor? get slashCommandForeground => map['chat.slashCommandForeground'];

  /// `chat.thinkingShimmer`.
  VscColor? get thinkingShimmer => map['chat.thinkingShimmer'];

}

/// Workbench colors under `checkbox.…`.
class VscWorkbenchCheckboxColors {
  /// Creates a group view over [map].
  const VscWorkbenchCheckboxColors(this.map);

  /// Underlying merged color map.
  final Map<String, VscColor> map;

  /// `checkbox.background`.
  VscColor? get background => map['checkbox.background'];

  /// `checkbox.border`.
  VscColor? get border => map['checkbox.border'];

  /// `checkbox.foreground`.
  VscColor? get foreground => map['checkbox.foreground'];

}

/// Workbench colors under `commandCenter.…`.
class VscWorkbenchCommandCenterColors {
  /// Creates a group view over [map].
  const VscWorkbenchCommandCenterColors(this.map);

  /// Underlying merged color map.
  final Map<String, VscColor> map;

  /// `commandCenter.activeBackground`.
  VscColor? get activeBackground => map['commandCenter.activeBackground'];

  /// `commandCenter.activeBorder`.
  VscColor? get activeBorder => map['commandCenter.activeBorder'];

  /// `commandCenter.activeForeground`.
  VscColor? get activeForeground => map['commandCenter.activeForeground'];

  /// `commandCenter.background`.
  VscColor? get background => map['commandCenter.background'];

  /// `commandCenter.border`.
  VscColor? get border => map['commandCenter.border'];

  /// `commandCenter.debuggingBackground`.
  VscColor? get debuggingBackground => map['commandCenter.debuggingBackground'];

  /// `commandCenter.foreground`.
  VscColor? get foreground => map['commandCenter.foreground'];

  /// `commandCenter.inactiveBorder`.
  VscColor? get inactiveBorder => map['commandCenter.inactiveBorder'];

  /// `commandCenter.inactiveForeground`.
  VscColor? get inactiveForeground => map['commandCenter.inactiveForeground'];

}

/// Workbench colors under `debugExceptionWidget.…`.
class VscWorkbenchDebugExceptionWidgetColors {
  /// Creates a group view over [map].
  const VscWorkbenchDebugExceptionWidgetColors(this.map);

  /// Underlying merged color map.
  final Map<String, VscColor> map;

  /// `debugExceptionWidget.background`.
  VscColor? get background => map['debugExceptionWidget.background'];

  /// `debugExceptionWidget.border`.
  VscColor? get border => map['debugExceptionWidget.border'];

}

/// Workbench colors under `debugToolBar.…`.
class VscWorkbenchDebugToolBarColors {
  /// Creates a group view over [map].
  const VscWorkbenchDebugToolBarColors(this.map);

  /// Underlying merged color map.
  final Map<String, VscColor> map;

  /// `debugToolBar.background`.
  VscColor? get background => map['debugToolBar.background'];

}

/// Workbench colors under `diffEditor.…`.
class VscWorkbenchDiffEditorColors {
  /// Creates a group view over [map].
  const VscWorkbenchDiffEditorColors(this.map);

  /// Underlying merged color map.
  final Map<String, VscColor> map;

  /// `diffEditor.diagonalFill`.
  VscColor? get diagonalFill => map['diffEditor.diagonalFill'];

  /// `diffEditor.insertedLineBackground`.
  VscColor? get insertedLineBackground => map['diffEditor.insertedLineBackground'];

  /// `diffEditor.insertedTextBackground`.
  VscColor? get insertedTextBackground => map['diffEditor.insertedTextBackground'];

  /// `diffEditor.removedLineBackground`.
  VscColor? get removedLineBackground => map['diffEditor.removedLineBackground'];

  /// `diffEditor.removedTextBackground`.
  VscColor? get removedTextBackground => map['diffEditor.removedTextBackground'];

  /// `diffEditor.unchangedCodeBackground`.
  VscColor? get unchangedCodeBackground => map['diffEditor.unchangedCodeBackground'];

  /// `diffEditor.unchangedRegionBackground`.
  VscColor? get unchangedRegionBackground => map['diffEditor.unchangedRegionBackground'];

}

/// Workbench colors under `dropdown.…`.
class VscWorkbenchDropdownColors {
  /// Creates a group view over [map].
  const VscWorkbenchDropdownColors(this.map);

  /// Underlying merged color map.
  final Map<String, VscColor> map;

  /// `dropdown.background`.
  VscColor? get background => map['dropdown.background'];

  /// `dropdown.border`.
  VscColor? get border => map['dropdown.border'];

  /// `dropdown.foreground`.
  VscColor? get foreground => map['dropdown.foreground'];

  /// `dropdown.listBackground`.
  VscColor? get listBackground => map['dropdown.listBackground'];

}

/// Workbench colors under `editor.…`.
class VscWorkbenchEditorColors {
  /// Creates a group view over [map].
  const VscWorkbenchEditorColors(this.map);

  /// Underlying merged color map.
  final Map<String, VscColor> map;

  /// `editor.background`.
  VscColor? get background => map['editor.background'];

  /// `editor.findMatchBackground`.
  VscColor? get findMatchBackground => map['editor.findMatchBackground'];

  /// `editor.findMatchHighlightBackground`.
  VscColor? get findMatchHighlightBackground => map['editor.findMatchHighlightBackground'];

  /// `editor.findRangeHighlightBackground`.
  VscColor? get findRangeHighlightBackground => map['editor.findRangeHighlightBackground'];

  /// `editor.foreground`.
  VscColor? get foreground => map['editor.foreground'];

  /// `editor.hoverHighlightBackground`.
  VscColor? get hoverHighlightBackground => map['editor.hoverHighlightBackground'];

  /// `editor.inactiveSelectionBackground`.
  VscColor? get inactiveSelectionBackground => map['editor.inactiveSelectionBackground'];

  /// `editor.lineHighlightBackground`.
  VscColor? get lineHighlightBackground => map['editor.lineHighlightBackground'];

  /// `editor.lineHighlightBorder`.
  VscColor? get lineHighlightBorder => map['editor.lineHighlightBorder'];

  /// `editor.rangeHighlightBackground`.
  VscColor? get rangeHighlightBackground => map['editor.rangeHighlightBackground'];

  /// `editor.selectionBackground`.
  VscColor? get selectionBackground => map['editor.selectionBackground'];

  /// `editor.selectionForeground`.
  VscColor? get selectionForeground => map['editor.selectionForeground'];

  /// `editor.selectionHighlightBackground`.
  VscColor? get selectionHighlightBackground => map['editor.selectionHighlightBackground'];

  /// `editor.snippetFinalTabstopHighlightBorder`.
  VscColor? get snippetFinalTabstopHighlightBorder => map['editor.snippetFinalTabstopHighlightBorder'];

  /// `editor.snippetTabstopHighlightBackground`.
  VscColor? get snippetTabstopHighlightBackground => map['editor.snippetTabstopHighlightBackground'];

  /// `editor.wordHighlightBackground`.
  VscColor? get wordHighlightBackground => map['editor.wordHighlightBackground'];

  /// `editor.wordHighlightStrongBackground`.
  VscColor? get wordHighlightStrongBackground => map['editor.wordHighlightStrongBackground'];

}

/// Workbench colors under `editorBracketHighlight.…`.
class VscWorkbenchEditorBracketHighlightColors {
  /// Creates a group view over [map].
  const VscWorkbenchEditorBracketHighlightColors(this.map);

  /// Underlying merged color map.
  final Map<String, VscColor> map;

  /// `editorBracketHighlight.foreground1`.
  VscColor? get foreground1 => map['editorBracketHighlight.foreground1'];

  /// `editorBracketHighlight.foreground2`.
  VscColor? get foreground2 => map['editorBracketHighlight.foreground2'];

  /// `editorBracketHighlight.foreground3`.
  VscColor? get foreground3 => map['editorBracketHighlight.foreground3'];

  /// `editorBracketHighlight.foreground4`.
  VscColor? get foreground4 => map['editorBracketHighlight.foreground4'];

  /// `editorBracketHighlight.foreground5`.
  VscColor? get foreground5 => map['editorBracketHighlight.foreground5'];

  /// `editorBracketHighlight.foreground6`.
  VscColor? get foreground6 => map['editorBracketHighlight.foreground6'];

  /// Color group `editorBracketHighlight.unexpectedBracket`.
  VscWorkbenchEditorBracketHighlightUnexpectedBracketColors get unexpectedBracket => VscWorkbenchEditorBracketHighlightUnexpectedBracketColors(map);

}

/// Workbench colors under `editorBracketHighlight.unexpectedBracket.…`.
class VscWorkbenchEditorBracketHighlightUnexpectedBracketColors {
  /// Creates a group view over [map].
  const VscWorkbenchEditorBracketHighlightUnexpectedBracketColors(this.map);

  /// Underlying merged color map.
  final Map<String, VscColor> map;

  /// `editorBracketHighlight.unexpectedBracket.foreground`.
  VscColor? get foreground => map['editorBracketHighlight.unexpectedBracket.foreground'];

}

/// Workbench colors under `editorBracketMatch.…`.
class VscWorkbenchEditorBracketMatchColors {
  /// Creates a group view over [map].
  const VscWorkbenchEditorBracketMatchColors(this.map);

  /// Underlying merged color map.
  final Map<String, VscColor> map;

  /// `editorBracketMatch.background`.
  VscColor? get background => map['editorBracketMatch.background'];

  /// `editorBracketMatch.border`.
  VscColor? get border => map['editorBracketMatch.border'];

}

/// Workbench colors under `editorCodeLens.…`.
class VscWorkbenchEditorCodeLensColors {
  /// Creates a group view over [map].
  const VscWorkbenchEditorCodeLensColors(this.map);

  /// Underlying merged color map.
  final Map<String, VscColor> map;

  /// `editorCodeLens.foreground`.
  VscColor? get foreground => map['editorCodeLens.foreground'];

}

/// Workbench colors under `editorCommentsWidget.…`.
class VscWorkbenchEditorCommentsWidgetColors {
  /// Creates a group view over [map].
  const VscWorkbenchEditorCommentsWidgetColors(this.map);

  /// Underlying merged color map.
  final Map<String, VscColor> map;

  /// `editorCommentsWidget.rangeActiveBackground`.
  VscColor? get rangeActiveBackground => map['editorCommentsWidget.rangeActiveBackground'];

  /// `editorCommentsWidget.rangeBackground`.
  VscColor? get rangeBackground => map['editorCommentsWidget.rangeBackground'];

}

/// Workbench colors under `editorCursor.…`.
class VscWorkbenchEditorCursorColors {
  /// Creates a group view over [map].
  const VscWorkbenchEditorCursorColors(this.map);

  /// Underlying merged color map.
  final Map<String, VscColor> map;

  /// `editorCursor.foreground`.
  VscColor? get foreground => map['editorCursor.foreground'];

}

/// Workbench colors under `editorError.…`.
class VscWorkbenchEditorErrorColors {
  /// Creates a group view over [map].
  const VscWorkbenchEditorErrorColors(this.map);

  /// Underlying merged color map.
  final Map<String, VscColor> map;

  /// `editorError.border`.
  VscColor? get border => map['editorError.border'];

  /// `editorError.foreground`.
  VscColor? get foreground => map['editorError.foreground'];

}

/// Workbench colors under `editorGroup.…`.
class VscWorkbenchEditorGroupColors {
  /// Creates a group view over [map].
  const VscWorkbenchEditorGroupColors(this.map);

  /// Underlying merged color map.
  final Map<String, VscColor> map;

  /// `editorGroup.border`.
  VscColor? get border => map['editorGroup.border'];

  /// `editorGroup.dropBackground`.
  VscColor? get dropBackground => map['editorGroup.dropBackground'];

  /// `editorGroup.emptyBackground`.
  VscColor? get emptyBackground => map['editorGroup.emptyBackground'];

}

/// Workbench colors under `editorGroupHeader.…`.
class VscWorkbenchEditorGroupHeaderColors {
  /// Creates a group view over [map].
  const VscWorkbenchEditorGroupHeaderColors(this.map);

  /// Underlying merged color map.
  final Map<String, VscColor> map;

  /// `editorGroupHeader.connectedTabsBackground`.
  VscColor? get connectedTabsBackground => map['editorGroupHeader.connectedTabsBackground'];

  /// `editorGroupHeader.noTabsBackground`.
  VscColor? get noTabsBackground => map['editorGroupHeader.noTabsBackground'];

  /// `editorGroupHeader.tabsBackground`.
  VscColor? get tabsBackground => map['editorGroupHeader.tabsBackground'];

  /// `editorGroupHeader.tabsBorder`.
  VscColor? get tabsBorder => map['editorGroupHeader.tabsBorder'];

}

/// Workbench colors under `editorGutter.…`.
class VscWorkbenchEditorGutterColors {
  /// Creates a group view over [map].
  const VscWorkbenchEditorGutterColors(this.map);

  /// Underlying merged color map.
  final Map<String, VscColor> map;

  /// `editorGutter.addedBackground`.
  VscColor? get addedBackground => map['editorGutter.addedBackground'];

  /// `editorGutter.background`.
  VscColor? get background => map['editorGutter.background'];

  /// `editorGutter.deletedBackground`.
  VscColor? get deletedBackground => map['editorGutter.deletedBackground'];

  /// `editorGutter.modifiedBackground`.
  VscColor? get modifiedBackground => map['editorGutter.modifiedBackground'];

}

/// Workbench colors under `editorHoverWidget.…`.
class VscWorkbenchEditorHoverWidgetColors {
  /// Creates a group view over [map].
  const VscWorkbenchEditorHoverWidgetColors(this.map);

  /// Underlying merged color map.
  final Map<String, VscColor> map;

  /// `editorHoverWidget.background`.
  VscColor? get background => map['editorHoverWidget.background'];

  /// `editorHoverWidget.border`.
  VscColor? get border => map['editorHoverWidget.border'];

  /// `editorHoverWidget.foreground`.
  VscColor? get foreground => map['editorHoverWidget.foreground'];

}

/// Workbench colors under `editorIndentGuide.…`.
class VscWorkbenchEditorIndentGuideColors {
  /// Creates a group view over [map].
  const VscWorkbenchEditorIndentGuideColors(this.map);

  /// Underlying merged color map.
  final Map<String, VscColor> map;

  /// `editorIndentGuide.activeBackground`.
  VscColor? get activeBackground => map['editorIndentGuide.activeBackground'];

  /// `editorIndentGuide.activeBackground1`.
  VscColor? get activeBackground1 => map['editorIndentGuide.activeBackground1'];

  /// `editorIndentGuide.background`.
  VscColor? get background => map['editorIndentGuide.background'];

  /// `editorIndentGuide.background1`.
  VscColor? get background1 => map['editorIndentGuide.background1'];

}

/// Workbench colors under `editorInlayHint.…`.
class VscWorkbenchEditorInlayHintColors {
  /// Creates a group view over [map].
  const VscWorkbenchEditorInlayHintColors(this.map);

  /// Underlying merged color map.
  final Map<String, VscColor> map;

  /// `editorInlayHint.background`.
  VscColor? get background => map['editorInlayHint.background'];

  /// `editorInlayHint.foreground`.
  VscColor? get foreground => map['editorInlayHint.foreground'];

  /// `editorInlayHint.parameterBackground`.
  VscColor? get parameterBackground => map['editorInlayHint.parameterBackground'];

  /// `editorInlayHint.parameterForeground`.
  VscColor? get parameterForeground => map['editorInlayHint.parameterForeground'];

  /// `editorInlayHint.typeBackground`.
  VscColor? get typeBackground => map['editorInlayHint.typeBackground'];

  /// `editorInlayHint.typeForeground`.
  VscColor? get typeForeground => map['editorInlayHint.typeForeground'];

}

/// Workbench colors under `editorLineNumber.…`.
class VscWorkbenchEditorLineNumberColors {
  /// Creates a group view over [map].
  const VscWorkbenchEditorLineNumberColors(this.map);

  /// Underlying merged color map.
  final Map<String, VscColor> map;

  /// `editorLineNumber.activeForeground`.
  VscColor? get activeForeground => map['editorLineNumber.activeForeground'];

  /// `editorLineNumber.foreground`.
  VscColor? get foreground => map['editorLineNumber.foreground'];

}

/// Workbench colors under `editorLink.…`.
class VscWorkbenchEditorLinkColors {
  /// Creates a group view over [map].
  const VscWorkbenchEditorLinkColors(this.map);

  /// Underlying merged color map.
  final Map<String, VscColor> map;

  /// `editorLink.activeForeground`.
  VscColor? get activeForeground => map['editorLink.activeForeground'];

}

/// Workbench colors under `editorMarkerNavigation.…`.
class VscWorkbenchEditorMarkerNavigationColors {
  /// Creates a group view over [map].
  const VscWorkbenchEditorMarkerNavigationColors(this.map);

  /// Underlying merged color map.
  final Map<String, VscColor> map;

  /// `editorMarkerNavigation.background`.
  VscColor? get background => map['editorMarkerNavigation.background'];

}

/// Workbench colors under `editorMarkerNavigationError.…`.
class VscWorkbenchEditorMarkerNavigationErrorColors {
  /// Creates a group view over [map].
  const VscWorkbenchEditorMarkerNavigationErrorColors(this.map);

  /// Underlying merged color map.
  final Map<String, VscColor> map;

  /// `editorMarkerNavigationError.background`.
  VscColor? get background => map['editorMarkerNavigationError.background'];

}

/// Workbench colors under `editorMarkerNavigationWarning.…`.
class VscWorkbenchEditorMarkerNavigationWarningColors {
  /// Creates a group view over [map].
  const VscWorkbenchEditorMarkerNavigationWarningColors(this.map);

  /// Underlying merged color map.
  final Map<String, VscColor> map;

  /// `editorMarkerNavigationWarning.background`.
  VscColor? get background => map['editorMarkerNavigationWarning.background'];

}

/// Workbench colors under `editorOverviewRuler.…`.
class VscWorkbenchEditorOverviewRulerColors {
  /// Creates a group view over [map].
  const VscWorkbenchEditorOverviewRulerColors(this.map);

  /// Underlying merged color map.
  final Map<String, VscColor> map;

  /// `editorOverviewRuler.addedForeground`.
  VscColor? get addedForeground => map['editorOverviewRuler.addedForeground'];

  /// `editorOverviewRuler.border`.
  VscColor? get border => map['editorOverviewRuler.border'];

  /// `editorOverviewRuler.bracketMatchForeground`.
  VscColor? get bracketMatchForeground => map['editorOverviewRuler.bracketMatchForeground'];

  /// `editorOverviewRuler.commonContentForeground`.
  VscColor? get commonContentForeground => map['editorOverviewRuler.commonContentForeground'];

  /// `editorOverviewRuler.currentContentForeground`.
  VscColor? get currentContentForeground => map['editorOverviewRuler.currentContentForeground'];

  /// `editorOverviewRuler.deletedForeground`.
  VscColor? get deletedForeground => map['editorOverviewRuler.deletedForeground'];

  /// `editorOverviewRuler.errorForeground`.
  VscColor? get errorForeground => map['editorOverviewRuler.errorForeground'];

  /// `editorOverviewRuler.findMatchForeground`.
  VscColor? get findMatchForeground => map['editorOverviewRuler.findMatchForeground'];

  /// `editorOverviewRuler.incomingContentForeground`.
  VscColor? get incomingContentForeground => map['editorOverviewRuler.incomingContentForeground'];

  /// `editorOverviewRuler.infoForeground`.
  VscColor? get infoForeground => map['editorOverviewRuler.infoForeground'];

  /// `editorOverviewRuler.modifiedForeground`.
  VscColor? get modifiedForeground => map['editorOverviewRuler.modifiedForeground'];

  /// `editorOverviewRuler.rangeHighlightForeground`.
  VscColor? get rangeHighlightForeground => map['editorOverviewRuler.rangeHighlightForeground'];

  /// `editorOverviewRuler.selectionHighlightForeground`.
  VscColor? get selectionHighlightForeground => map['editorOverviewRuler.selectionHighlightForeground'];

  /// `editorOverviewRuler.warningForeground`.
  VscColor? get warningForeground => map['editorOverviewRuler.warningForeground'];

  /// `editorOverviewRuler.wordHighlightForeground`.
  VscColor? get wordHighlightForeground => map['editorOverviewRuler.wordHighlightForeground'];

  /// `editorOverviewRuler.wordHighlightStrongForeground`.
  VscColor? get wordHighlightStrongForeground => map['editorOverviewRuler.wordHighlightStrongForeground'];

}

/// Workbench colors under `editorRuler.…`.
class VscWorkbenchEditorRulerColors {
  /// Creates a group view over [map].
  const VscWorkbenchEditorRulerColors(this.map);

  /// Underlying merged color map.
  final Map<String, VscColor> map;

  /// `editorRuler.foreground`.
  VscColor? get foreground => map['editorRuler.foreground'];

}

/// Workbench colors under `editorStickyScroll.…`.
class VscWorkbenchEditorStickyScrollColors {
  /// Creates a group view over [map].
  const VscWorkbenchEditorStickyScrollColors(this.map);

  /// Underlying merged color map.
  final Map<String, VscColor> map;

  /// `editorStickyScroll.background`.
  VscColor? get background => map['editorStickyScroll.background'];

  /// `editorStickyScroll.border`.
  VscColor? get border => map['editorStickyScroll.border'];

  /// `editorStickyScroll.shadow`.
  VscColor? get shadow => map['editorStickyScroll.shadow'];

}

/// Workbench colors under `editorStickyScrollHover.…`.
class VscWorkbenchEditorStickyScrollHoverColors {
  /// Creates a group view over [map].
  const VscWorkbenchEditorStickyScrollHoverColors(this.map);

  /// Underlying merged color map.
  final Map<String, VscColor> map;

  /// `editorStickyScrollHover.background`.
  VscColor? get background => map['editorStickyScrollHover.background'];

}

/// Workbench colors under `editorSuggestWidget.…`.
class VscWorkbenchEditorSuggestWidgetColors {
  /// Creates a group view over [map].
  const VscWorkbenchEditorSuggestWidgetColors(this.map);

  /// Underlying merged color map.
  final Map<String, VscColor> map;

  /// `editorSuggestWidget.background`.
  VscColor? get background => map['editorSuggestWidget.background'];

  /// `editorSuggestWidget.border`.
  VscColor? get border => map['editorSuggestWidget.border'];

  /// `editorSuggestWidget.focusOutline`.
  VscColor? get focusOutline => map['editorSuggestWidget.focusOutline'];

  /// `editorSuggestWidget.foreground`.
  VscColor? get foreground => map['editorSuggestWidget.foreground'];

  /// `editorSuggestWidget.highlightForeground`.
  VscColor? get highlightForeground => map['editorSuggestWidget.highlightForeground'];

  /// `editorSuggestWidget.selectedBackground`.
  VscColor? get selectedBackground => map['editorSuggestWidget.selectedBackground'];

  /// `editorSuggestWidget.selectedForeground`.
  VscColor? get selectedForeground => map['editorSuggestWidget.selectedForeground'];

  /// `editorSuggestWidget.selectedIconForeground`.
  VscColor? get selectedIconForeground => map['editorSuggestWidget.selectedIconForeground'];

}

/// Workbench colors under `editorUnnecessaryCode.…`.
class VscWorkbenchEditorUnnecessaryCodeColors {
  /// Creates a group view over [map].
  const VscWorkbenchEditorUnnecessaryCodeColors(this.map);

  /// Underlying merged color map.
  final Map<String, VscColor> map;

  /// `editorUnnecessaryCode.opacity`.
  VscColor? get opacity => map['editorUnnecessaryCode.opacity'];

}

/// Workbench colors under `editorWarning.…`.
class VscWorkbenchEditorWarningColors {
  /// Creates a group view over [map].
  const VscWorkbenchEditorWarningColors(this.map);

  /// Underlying merged color map.
  final Map<String, VscColor> map;

  /// `editorWarning.border`.
  VscColor? get border => map['editorWarning.border'];

  /// `editorWarning.foreground`.
  VscColor? get foreground => map['editorWarning.foreground'];

}

/// Workbench colors under `editorWhitespace.…`.
class VscWorkbenchEditorWhitespaceColors {
  /// Creates a group view over [map].
  const VscWorkbenchEditorWhitespaceColors(this.map);

  /// Underlying merged color map.
  final Map<String, VscColor> map;

  /// `editorWhitespace.foreground`.
  VscColor? get foreground => map['editorWhitespace.foreground'];

}

/// Workbench colors under `editorWidget.…`.
class VscWorkbenchEditorWidgetColors {
  /// Creates a group view over [map].
  const VscWorkbenchEditorWidgetColors(this.map);

  /// Underlying merged color map.
  final Map<String, VscColor> map;

  /// `editorWidget.background`.
  VscColor? get background => map['editorWidget.background'];

  /// `editorWidget.border`.
  VscColor? get border => map['editorWidget.border'];

  /// `editorWidget.foreground`.
  VscColor? get foreground => map['editorWidget.foreground'];

  /// `editorWidget.resizeBorder`.
  VscColor? get resizeBorder => map['editorWidget.resizeBorder'];

}

/// Workbench colors under `extensionButton.…`.
class VscWorkbenchExtensionButtonColors {
  /// Creates a group view over [map].
  const VscWorkbenchExtensionButtonColors(this.map);

  /// Underlying merged color map.
  final Map<String, VscColor> map;

  /// `extensionButton.prominentBackground`.
  VscColor? get prominentBackground => map['extensionButton.prominentBackground'];

  /// `extensionButton.prominentForeground`.
  VscColor? get prominentForeground => map['extensionButton.prominentForeground'];

  /// `extensionButton.prominentHoverBackground`.
  VscColor? get prominentHoverBackground => map['extensionButton.prominentHoverBackground'];

}

/// Workbench colors under `git.…`.
class VscWorkbenchGitColors {
  /// Creates a group view over [map].
  const VscWorkbenchGitColors(this.map);

  /// Underlying merged color map.
  final Map<String, VscColor> map;

  /// Color group `git.blame`.
  VscWorkbenchGitBlameColors get blame => VscWorkbenchGitBlameColors(map);

}

/// Workbench colors under `git.blame.…`.
class VscWorkbenchGitBlameColors {
  /// Creates a group view over [map].
  const VscWorkbenchGitBlameColors(this.map);

  /// Underlying merged color map.
  final Map<String, VscColor> map;

  /// `git.blame.editorDecorationForeground`.
  VscColor? get editorDecorationForeground => map['git.blame.editorDecorationForeground'];

}

/// Workbench colors under `gitDecoration.…`.
class VscWorkbenchGitDecorationColors {
  /// Creates a group view over [map].
  const VscWorkbenchGitDecorationColors(this.map);

  /// Underlying merged color map.
  final Map<String, VscColor> map;

  /// `gitDecoration.addedResourceForeground`.
  VscColor? get addedResourceForeground => map['gitDecoration.addedResourceForeground'];

  /// `gitDecoration.conflictingResourceForeground`.
  VscColor? get conflictingResourceForeground => map['gitDecoration.conflictingResourceForeground'];

  /// `gitDecoration.deletedResourceForeground`.
  VscColor? get deletedResourceForeground => map['gitDecoration.deletedResourceForeground'];

  /// `gitDecoration.ignoredResourceForeground`.
  VscColor? get ignoredResourceForeground => map['gitDecoration.ignoredResourceForeground'];

  /// `gitDecoration.modifiedResourceForeground`.
  VscColor? get modifiedResourceForeground => map['gitDecoration.modifiedResourceForeground'];

  /// `gitDecoration.renamedResourceForeground`.
  VscColor? get renamedResourceForeground => map['gitDecoration.renamedResourceForeground'];

  /// `gitDecoration.stageDeletedResourceForeground`.
  VscColor? get stageDeletedResourceForeground => map['gitDecoration.stageDeletedResourceForeground'];

  /// `gitDecoration.stageModifiedResourceForeground`.
  VscColor? get stageModifiedResourceForeground => map['gitDecoration.stageModifiedResourceForeground'];

  /// `gitDecoration.untrackedResourceForeground`.
  VscColor? get untrackedResourceForeground => map['gitDecoration.untrackedResourceForeground'];

}

/// Workbench colors under `gitlens.…`.
class VscWorkbenchGitlensColors {
  /// Creates a group view over [map].
  const VscWorkbenchGitlensColors(this.map);

  /// Underlying merged color map.
  final Map<String, VscColor> map;

  /// `gitlens.trailingLineForegroundColor`.
  VscColor? get trailingLineForegroundColor => map['gitlens.trailingLineForegroundColor'];

}

/// Workbench colors under `icon.…`.
class VscWorkbenchIconColors {
  /// Creates a group view over [map].
  const VscWorkbenchIconColors(this.map);

  /// Underlying merged color map.
  final Map<String, VscColor> map;

  /// `icon.foreground`.
  VscColor? get foreground => map['icon.foreground'];

}

/// Workbench colors under `inlineChat.…`.
class VscWorkbenchInlineChatColors {
  /// Creates a group view over [map].
  const VscWorkbenchInlineChatColors(this.map);

  /// Underlying merged color map.
  final Map<String, VscColor> map;

  /// `inlineChat.border`.
  VscColor? get border => map['inlineChat.border'];

}

/// Workbench colors under `input.…`.
class VscWorkbenchInputColors {
  /// Creates a group view over [map].
  const VscWorkbenchInputColors(this.map);

  /// Underlying merged color map.
  final Map<String, VscColor> map;

  /// `input.background`.
  VscColor? get background => map['input.background'];

  /// `input.border`.
  VscColor? get border => map['input.border'];

  /// `input.foreground`.
  VscColor? get foreground => map['input.foreground'];

  /// `input.placeholderForeground`.
  VscColor? get placeholderForeground => map['input.placeholderForeground'];

}

/// Workbench colors under `inputOption.…`.
class VscWorkbenchInputOptionColors {
  /// Creates a group view over [map].
  const VscWorkbenchInputOptionColors(this.map);

  /// Underlying merged color map.
  final Map<String, VscColor> map;

  /// `inputOption.activeBackground`.
  VscColor? get activeBackground => map['inputOption.activeBackground'];

  /// `inputOption.activeBorder`.
  VscColor? get activeBorder => map['inputOption.activeBorder'];

  /// `inputOption.activeForeground`.
  VscColor? get activeForeground => map['inputOption.activeForeground'];

}

/// Workbench colors under `inputValidation.…`.
class VscWorkbenchInputValidationColors {
  /// Creates a group view over [map].
  const VscWorkbenchInputValidationColors(this.map);

  /// Underlying merged color map.
  final Map<String, VscColor> map;

  /// `inputValidation.errorBackground`.
  VscColor? get errorBackground => map['inputValidation.errorBackground'];

  /// `inputValidation.errorBorder`.
  VscColor? get errorBorder => map['inputValidation.errorBorder'];

  /// `inputValidation.errorForeground`.
  VscColor? get errorForeground => map['inputValidation.errorForeground'];

  /// `inputValidation.infoBackground`.
  VscColor? get infoBackground => map['inputValidation.infoBackground'];

  /// `inputValidation.infoBorder`.
  VscColor? get infoBorder => map['inputValidation.infoBorder'];

  /// `inputValidation.infoForeground`.
  VscColor? get infoForeground => map['inputValidation.infoForeground'];

  /// `inputValidation.warningBackground`.
  VscColor? get warningBackground => map['inputValidation.warningBackground'];

  /// `inputValidation.warningBorder`.
  VscColor? get warningBorder => map['inputValidation.warningBorder'];

  /// `inputValidation.warningForeground`.
  VscColor? get warningForeground => map['inputValidation.warningForeground'];

}

/// Workbench colors under `keybindingLabel.…`.
class VscWorkbenchKeybindingLabelColors {
  /// Creates a group view over [map].
  const VscWorkbenchKeybindingLabelColors(this.map);

  /// Underlying merged color map.
  final Map<String, VscColor> map;

  /// `keybindingLabel.foreground`.
  VscColor? get foreground => map['keybindingLabel.foreground'];

}

/// Workbench colors under `list.…`.
class VscWorkbenchListColors {
  /// Creates a group view over [map].
  const VscWorkbenchListColors(this.map);

  /// Underlying merged color map.
  final Map<String, VscColor> map;

  /// `list.activeSelectionBackground`.
  VscColor? get activeSelectionBackground => map['list.activeSelectionBackground'];

  /// `list.activeSelectionForeground`.
  VscColor? get activeSelectionForeground => map['list.activeSelectionForeground'];

  /// `list.activeSelectionIconForeground`.
  VscColor? get activeSelectionIconForeground => map['list.activeSelectionIconForeground'];

  /// `list.deemphasizedForeground`.
  VscColor? get deemphasizedForeground => map['list.deemphasizedForeground'];

  /// `list.dropBackground`.
  VscColor? get dropBackground => map['list.dropBackground'];

  /// `list.errorForeground`.
  VscColor? get errorForeground => map['list.errorForeground'];

  /// `list.focusAndSelectionOutline`.
  VscColor? get focusAndSelectionOutline => map['list.focusAndSelectionOutline'];

  /// `list.focusBackground`.
  VscColor? get focusBackground => map['list.focusBackground'];

  /// `list.focusForeground`.
  VscColor? get focusForeground => map['list.focusForeground'];

  /// `list.focusOutline`.
  VscColor? get focusOutline => map['list.focusOutline'];

  /// `list.highlightForeground`.
  VscColor? get highlightForeground => map['list.highlightForeground'];

  /// `list.hoverBackground`.
  VscColor? get hoverBackground => map['list.hoverBackground'];

  /// `list.hoverForeground`.
  VscColor? get hoverForeground => map['list.hoverForeground'];

  /// `list.inactiveSelectionBackground`.
  VscColor? get inactiveSelectionBackground => map['list.inactiveSelectionBackground'];

  /// `list.inactiveSelectionForeground`.
  VscColor? get inactiveSelectionForeground => map['list.inactiveSelectionForeground'];

  /// `list.invalidItemForeground`.
  VscColor? get invalidItemForeground => map['list.invalidItemForeground'];

  /// `list.warningForeground`.
  VscColor? get warningForeground => map['list.warningForeground'];

}

/// Workbench colors under `listFilterWidget.…`.
class VscWorkbenchListFilterWidgetColors {
  /// Creates a group view over [map].
  const VscWorkbenchListFilterWidgetColors(this.map);

  /// Underlying merged color map.
  final Map<String, VscColor> map;

  /// `listFilterWidget.shadow`.
  VscColor? get shadow => map['listFilterWidget.shadow'];

}

/// Workbench colors under `menu.…`.
class VscWorkbenchMenuColors {
  /// Creates a group view over [map].
  const VscWorkbenchMenuColors(this.map);

  /// Underlying merged color map.
  final Map<String, VscColor> map;

  /// `menu.background`.
  VscColor? get background => map['menu.background'];

  /// `menu.border`.
  VscColor? get border => map['menu.border'];

  /// `menu.foreground`.
  VscColor? get foreground => map['menu.foreground'];

  /// `menu.selectionBackground`.
  VscColor? get selectionBackground => map['menu.selectionBackground'];

  /// `menu.selectionBorder`.
  VscColor? get selectionBorder => map['menu.selectionBorder'];

  /// `menu.selectionForeground`.
  VscColor? get selectionForeground => map['menu.selectionForeground'];

  /// `menu.separatorBackground`.
  VscColor? get separatorBackground => map['menu.separatorBackground'];

}

/// Workbench colors under `menubar.…`.
class VscWorkbenchMenubarColors {
  /// Creates a group view over [map].
  const VscWorkbenchMenubarColors(this.map);

  /// Underlying merged color map.
  final Map<String, VscColor> map;

  /// `menubar.selectionBackground`.
  VscColor? get selectionBackground => map['menubar.selectionBackground'];

  /// `menubar.selectionForeground`.
  VscColor? get selectionForeground => map['menubar.selectionForeground'];

}

/// Workbench colors under `merge.…`.
class VscWorkbenchMergeColors {
  /// Creates a group view over [map].
  const VscWorkbenchMergeColors(this.map);

  /// Underlying merged color map.
  final Map<String, VscColor> map;

  /// `merge.border`.
  VscColor? get border => map['merge.border'];

  /// `merge.currentContentBackground`.
  VscColor? get currentContentBackground => map['merge.currentContentBackground'];

  /// `merge.currentHeaderBackground`.
  VscColor? get currentHeaderBackground => map['merge.currentHeaderBackground'];

  /// `merge.incomingContentBackground`.
  VscColor? get incomingContentBackground => map['merge.incomingContentBackground'];

  /// `merge.incomingHeaderBackground`.
  VscColor? get incomingHeaderBackground => map['merge.incomingHeaderBackground'];

}

/// Workbench colors under `minimap.…`.
class VscWorkbenchMinimapColors {
  /// Creates a group view over [map].
  const VscWorkbenchMinimapColors(this.map);

  /// Underlying merged color map.
  final Map<String, VscColor> map;

  /// `minimap.background`.
  VscColor? get background => map['minimap.background'];

  /// `minimap.errorHighlight`.
  VscColor? get errorHighlight => map['minimap.errorHighlight'];

  /// `minimap.findMatchHighlight`.
  VscColor? get findMatchHighlight => map['minimap.findMatchHighlight'];

  /// `minimap.foregroundOpacity`.
  VscColor? get foregroundOpacity => map['minimap.foregroundOpacity'];

  /// `minimap.selectionHighlight`.
  VscColor? get selectionHighlight => map['minimap.selectionHighlight'];

  /// `minimap.selectionOccurrenceHighlight`.
  VscColor? get selectionOccurrenceHighlight => map['minimap.selectionOccurrenceHighlight'];

  /// `minimap.warningHighlight`.
  VscColor? get warningHighlight => map['minimap.warningHighlight'];

}

/// Workbench colors under `minimapGutter.…`.
class VscWorkbenchMinimapGutterColors {
  /// Creates a group view over [map].
  const VscWorkbenchMinimapGutterColors(this.map);

  /// Underlying merged color map.
  final Map<String, VscColor> map;

  /// `minimapGutter.addedBackground`.
  VscColor? get addedBackground => map['minimapGutter.addedBackground'];

  /// `minimapGutter.deletedBackground`.
  VscColor? get deletedBackground => map['minimapGutter.deletedBackground'];

  /// `minimapGutter.modifiedBackground`.
  VscColor? get modifiedBackground => map['minimapGutter.modifiedBackground'];

}

/// Workbench colors under `minimapSlider.…`.
class VscWorkbenchMinimapSliderColors {
  /// Creates a group view over [map].
  const VscWorkbenchMinimapSliderColors(this.map);

  /// Underlying merged color map.
  final Map<String, VscColor> map;

  /// `minimapSlider.activeBackground`.
  VscColor? get activeBackground => map['minimapSlider.activeBackground'];

  /// `minimapSlider.background`.
  VscColor? get background => map['minimapSlider.background'];

  /// `minimapSlider.hoverBackground`.
  VscColor? get hoverBackground => map['minimapSlider.hoverBackground'];

}

/// Workbench colors under `notebook.…`.
class VscWorkbenchNotebookColors {
  /// Creates a group view over [map].
  const VscWorkbenchNotebookColors(this.map);

  /// Underlying merged color map.
  final Map<String, VscColor> map;

  /// `notebook.cellBorderColor`.
  VscColor? get cellBorderColor => map['notebook.cellBorderColor'];

  /// `notebook.cellEditorBackground`.
  VscColor? get cellEditorBackground => map['notebook.cellEditorBackground'];

  /// `notebook.selectedCellBackground`.
  VscColor? get selectedCellBackground => map['notebook.selectedCellBackground'];

}

/// Workbench colors under `notificationCenter.…`.
class VscWorkbenchNotificationCenterColors {
  /// Creates a group view over [map].
  const VscWorkbenchNotificationCenterColors(this.map);

  /// Underlying merged color map.
  final Map<String, VscColor> map;

  /// `notificationCenter.border`.
  VscColor? get border => map['notificationCenter.border'];

}

/// Workbench colors under `notificationCenterHeader.…`.
class VscWorkbenchNotificationCenterHeaderColors {
  /// Creates a group view over [map].
  const VscWorkbenchNotificationCenterHeaderColors(this.map);

  /// Underlying merged color map.
  final Map<String, VscColor> map;

  /// `notificationCenterHeader.background`.
  VscColor? get background => map['notificationCenterHeader.background'];

  /// `notificationCenterHeader.foreground`.
  VscColor? get foreground => map['notificationCenterHeader.foreground'];

}

/// Workbench colors under `notificationLink.…`.
class VscWorkbenchNotificationLinkColors {
  /// Creates a group view over [map].
  const VscWorkbenchNotificationLinkColors(this.map);

  /// Underlying merged color map.
  final Map<String, VscColor> map;

  /// `notificationLink.foreground`.
  VscColor? get foreground => map['notificationLink.foreground'];

}

/// Workbench colors under `notificationToast.…`.
class VscWorkbenchNotificationToastColors {
  /// Creates a group view over [map].
  const VscWorkbenchNotificationToastColors(this.map);

  /// Underlying merged color map.
  final Map<String, VscColor> map;

  /// `notificationToast.border`.
  VscColor? get border => map['notificationToast.border'];

}

/// Workbench colors under `notifications.…`.
class VscWorkbenchNotificationsColors {
  /// Creates a group view over [map].
  const VscWorkbenchNotificationsColors(this.map);

  /// Underlying merged color map.
  final Map<String, VscColor> map;

  /// `notifications.background`.
  VscColor? get background => map['notifications.background'];

  /// `notifications.border`.
  VscColor? get border => map['notifications.border'];

  /// `notifications.foreground`.
  VscColor? get foreground => map['notifications.foreground'];

}

/// Workbench colors under `notificationsErrorIcon.…`.
class VscWorkbenchNotificationsErrorIconColors {
  /// Creates a group view over [map].
  const VscWorkbenchNotificationsErrorIconColors(this.map);

  /// Underlying merged color map.
  final Map<String, VscColor> map;

  /// `notificationsErrorIcon.foreground`.
  VscColor? get foreground => map['notificationsErrorIcon.foreground'];

}

/// Workbench colors under `notificationsInfoIcon.…`.
class VscWorkbenchNotificationsInfoIconColors {
  /// Creates a group view over [map].
  const VscWorkbenchNotificationsInfoIconColors(this.map);

  /// Underlying merged color map.
  final Map<String, VscColor> map;

  /// `notificationsInfoIcon.foreground`.
  VscColor? get foreground => map['notificationsInfoIcon.foreground'];

}

/// Workbench colors under `notificationsWarningIcon.…`.
class VscWorkbenchNotificationsWarningIconColors {
  /// Creates a group view over [map].
  const VscWorkbenchNotificationsWarningIconColors(this.map);

  /// Underlying merged color map.
  final Map<String, VscColor> map;

  /// `notificationsWarningIcon.foreground`.
  VscColor? get foreground => map['notificationsWarningIcon.foreground'];

}

/// Workbench colors under `panel.…`.
class VscWorkbenchPanelColors {
  /// Creates a group view over [map].
  const VscWorkbenchPanelColors(this.map);

  /// Underlying merged color map.
  final Map<String, VscColor> map;

  /// `panel.background`.
  VscColor? get background => map['panel.background'];

  /// `panel.border`.
  VscColor? get border => map['panel.border'];

}

/// Workbench colors under `panelInput.…`.
class VscWorkbenchPanelInputColors {
  /// Creates a group view over [map].
  const VscWorkbenchPanelInputColors(this.map);

  /// Underlying merged color map.
  final Map<String, VscColor> map;

  /// `panelInput.border`.
  VscColor? get border => map['panelInput.border'];

}

/// Workbench colors under `panelSection.…`.
class VscWorkbenchPanelSectionColors {
  /// Creates a group view over [map].
  const VscWorkbenchPanelSectionColors(this.map);

  /// Underlying merged color map.
  final Map<String, VscColor> map;

  /// `panelSection.border`.
  VscColor? get border => map['panelSection.border'];

}

/// Workbench colors under `panelSectionHeader.…`.
class VscWorkbenchPanelSectionHeaderColors {
  /// Creates a group view over [map].
  const VscWorkbenchPanelSectionHeaderColors(this.map);

  /// Underlying merged color map.
  final Map<String, VscColor> map;

  /// `panelSectionHeader.border`.
  VscColor? get border => map['panelSectionHeader.border'];

}

/// Workbench colors under `panelStickyScroll.…`.
class VscWorkbenchPanelStickyScrollColors {
  /// Creates a group view over [map].
  const VscWorkbenchPanelStickyScrollColors(this.map);

  /// Underlying merged color map.
  final Map<String, VscColor> map;

  /// `panelStickyScroll.border`.
  VscColor? get border => map['panelStickyScroll.border'];

  /// `panelStickyScroll.shadow`.
  VscColor? get shadow => map['panelStickyScroll.shadow'];

}

/// Workbench colors under `panelTitle.…`.
class VscWorkbenchPanelTitleColors {
  /// Creates a group view over [map].
  const VscWorkbenchPanelTitleColors(this.map);

  /// Underlying merged color map.
  final Map<String, VscColor> map;

  /// `panelTitle.activeBorder`.
  VscColor? get activeBorder => map['panelTitle.activeBorder'];

  /// `panelTitle.activeForeground`.
  VscColor? get activeForeground => map['panelTitle.activeForeground'];

  /// `panelTitle.inactiveForeground`.
  VscColor? get inactiveForeground => map['panelTitle.inactiveForeground'];

}

/// Workbench colors under `peekView.…`.
class VscWorkbenchPeekViewColors {
  /// Creates a group view over [map].
  const VscWorkbenchPeekViewColors(this.map);

  /// Underlying merged color map.
  final Map<String, VscColor> map;

  /// `peekView.border`.
  VscColor? get border => map['peekView.border'];

}

/// Workbench colors under `peekViewEditor.…`.
class VscWorkbenchPeekViewEditorColors {
  /// Creates a group view over [map].
  const VscWorkbenchPeekViewEditorColors(this.map);

  /// Underlying merged color map.
  final Map<String, VscColor> map;

  /// `peekViewEditor.background`.
  VscColor? get background => map['peekViewEditor.background'];

  /// `peekViewEditor.matchHighlightBackground`.
  VscColor? get matchHighlightBackground => map['peekViewEditor.matchHighlightBackground'];

}

/// Workbench colors under `peekViewEditorGutter.…`.
class VscWorkbenchPeekViewEditorGutterColors {
  /// Creates a group view over [map].
  const VscWorkbenchPeekViewEditorGutterColors(this.map);

  /// Underlying merged color map.
  final Map<String, VscColor> map;

  /// `peekViewEditorGutter.background`.
  VscColor? get background => map['peekViewEditorGutter.background'];

}

/// Workbench colors under `peekViewResult.…`.
class VscWorkbenchPeekViewResultColors {
  /// Creates a group view over [map].
  const VscWorkbenchPeekViewResultColors(this.map);

  /// Underlying merged color map.
  final Map<String, VscColor> map;

  /// `peekViewResult.background`.
  VscColor? get background => map['peekViewResult.background'];

  /// `peekViewResult.fileForeground`.
  VscColor? get fileForeground => map['peekViewResult.fileForeground'];

  /// `peekViewResult.lineForeground`.
  VscColor? get lineForeground => map['peekViewResult.lineForeground'];

  /// `peekViewResult.matchHighlightBackground`.
  VscColor? get matchHighlightBackground => map['peekViewResult.matchHighlightBackground'];

  /// `peekViewResult.selectionBackground`.
  VscColor? get selectionBackground => map['peekViewResult.selectionBackground'];

  /// `peekViewResult.selectionForeground`.
  VscColor? get selectionForeground => map['peekViewResult.selectionForeground'];

}

/// Workbench colors under `peekViewTitle.…`.
class VscWorkbenchPeekViewTitleColors {
  /// Creates a group view over [map].
  const VscWorkbenchPeekViewTitleColors(this.map);

  /// Underlying merged color map.
  final Map<String, VscColor> map;

  /// `peekViewTitle.background`.
  VscColor? get background => map['peekViewTitle.background'];

}

/// Workbench colors under `peekViewTitleDescription.…`.
class VscWorkbenchPeekViewTitleDescriptionColors {
  /// Creates a group view over [map].
  const VscWorkbenchPeekViewTitleDescriptionColors(this.map);

  /// Underlying merged color map.
  final Map<String, VscColor> map;

  /// `peekViewTitleDescription.foreground`.
  VscColor? get foreground => map['peekViewTitleDescription.foreground'];

}

/// Workbench colors under `peekViewTitleLabel.…`.
class VscWorkbenchPeekViewTitleLabelColors {
  /// Creates a group view over [map].
  const VscWorkbenchPeekViewTitleLabelColors(this.map);

  /// Underlying merged color map.
  final Map<String, VscColor> map;

  /// `peekViewTitleLabel.foreground`.
  VscColor? get foreground => map['peekViewTitleLabel.foreground'];

}

/// Workbench colors under `pickerGroup.…`.
class VscWorkbenchPickerGroupColors {
  /// Creates a group view over [map].
  const VscWorkbenchPickerGroupColors(this.map);

  /// Underlying merged color map.
  final Map<String, VscColor> map;

  /// `pickerGroup.border`.
  VscColor? get border => map['pickerGroup.border'];

  /// `pickerGroup.foreground`.
  VscColor? get foreground => map['pickerGroup.foreground'];

}

/// Workbench colors under `ports.…`.
class VscWorkbenchPortsColors {
  /// Creates a group view over [map].
  const VscWorkbenchPortsColors(this.map);

  /// Underlying merged color map.
  final Map<String, VscColor> map;

  /// `ports.iconRunningProcessForeground`.
  VscColor? get iconRunningProcessForeground => map['ports.iconRunningProcessForeground'];

}

/// Workbench colors under `problemsWarningIcon.…`.
class VscWorkbenchProblemsWarningIconColors {
  /// Creates a group view over [map].
  const VscWorkbenchProblemsWarningIconColors(this.map);

  /// Underlying merged color map.
  final Map<String, VscColor> map;

  /// `problemsWarningIcon.foreground`.
  VscColor? get foreground => map['problemsWarningIcon.foreground'];

}

/// Workbench colors under `progressBar.…`.
class VscWorkbenchProgressBarColors {
  /// Creates a group view over [map].
  const VscWorkbenchProgressBarColors(this.map);

  /// Underlying merged color map.
  final Map<String, VscColor> map;

  /// `progressBar.background`.
  VscColor? get background => map['progressBar.background'];

}

/// Workbench colors under `quickInput.…`.
class VscWorkbenchQuickInputColors {
  /// Creates a group view over [map].
  const VscWorkbenchQuickInputColors(this.map);

  /// Underlying merged color map.
  final Map<String, VscColor> map;

  /// `quickInput.background`.
  VscColor? get background => map['quickInput.background'];

  /// `quickInput.foreground`.
  VscColor? get foreground => map['quickInput.foreground'];

}

/// Workbench colors under `quickInputList.…`.
class VscWorkbenchQuickInputListColors {
  /// Creates a group view over [map].
  const VscWorkbenchQuickInputListColors(this.map);

  /// Underlying merged color map.
  final Map<String, VscColor> map;

  /// `quickInputList.focusBackground`.
  VscColor? get focusBackground => map['quickInputList.focusBackground'];

  /// `quickInputList.focusForeground`.
  VscColor? get focusForeground => map['quickInputList.focusForeground'];

  /// `quickInputList.focusHighlightForeground`.
  VscColor? get focusHighlightForeground => map['quickInputList.focusHighlightForeground'];

  /// `quickInputList.focusIconForeground`.
  VscColor? get focusIconForeground => map['quickInputList.focusIconForeground'];

}

/// Workbench colors under `quickInputTitle.…`.
class VscWorkbenchQuickInputTitleColors {
  /// Creates a group view over [map].
  const VscWorkbenchQuickInputTitleColors(this.map);

  /// Underlying merged color map.
  final Map<String, VscColor> map;

  /// `quickInputTitle.background`.
  VscColor? get background => map['quickInputTitle.background'];

}

/// Workbench colors under `sash.…`.
class VscWorkbenchSashColors {
  /// Creates a group view over [map].
  const VscWorkbenchSashColors(this.map);

  /// Underlying merged color map.
  final Map<String, VscColor> map;

  /// `sash.hoverBorder`.
  VscColor? get hoverBorder => map['sash.hoverBorder'];

}

/// Workbench colors under `scrollbar.…`.
class VscWorkbenchScrollbarColors {
  /// Creates a group view over [map].
  const VscWorkbenchScrollbarColors(this.map);

  /// Underlying merged color map.
  final Map<String, VscColor> map;

  /// `scrollbar.shadow`.
  VscColor? get shadow => map['scrollbar.shadow'];

}

/// Workbench colors under `scrollbarSlider.…`.
class VscWorkbenchScrollbarSliderColors {
  /// Creates a group view over [map].
  const VscWorkbenchScrollbarSliderColors(this.map);

  /// Underlying merged color map.
  final Map<String, VscColor> map;

  /// `scrollbarSlider.activeBackground`.
  VscColor? get activeBackground => map['scrollbarSlider.activeBackground'];

  /// `scrollbarSlider.background`.
  VscColor? get background => map['scrollbarSlider.background'];

  /// `scrollbarSlider.hoverBackground`.
  VscColor? get hoverBackground => map['scrollbarSlider.hoverBackground'];

}

/// Workbench colors under `searchEditor.…`.
class VscWorkbenchSearchEditorColors {
  /// Creates a group view over [map].
  const VscWorkbenchSearchEditorColors(this.map);

  /// Underlying merged color map.
  final Map<String, VscColor> map;

  /// `searchEditor.textInputBorder`.
  VscColor? get textInputBorder => map['searchEditor.textInputBorder'];

}

/// Workbench colors under `selection.…`.
class VscWorkbenchSelectionColors {
  /// Creates a group view over [map].
  const VscWorkbenchSelectionColors(this.map);

  /// Underlying merged color map.
  final Map<String, VscColor> map;

  /// `selection.background`.
  VscColor? get background => map['selection.background'];

}

/// Workbench colors under `settings.…`.
class VscWorkbenchSettingsColors {
  /// Creates a group view over [map].
  const VscWorkbenchSettingsColors(this.map);

  /// Underlying merged color map.
  final Map<String, VscColor> map;

  /// `settings.dropdownBackground`.
  VscColor? get dropdownBackground => map['settings.dropdownBackground'];

  /// `settings.dropdownBorder`.
  VscColor? get dropdownBorder => map['settings.dropdownBorder'];

  /// `settings.focusedRowBackground`.
  VscColor? get focusedRowBackground => map['settings.focusedRowBackground'];

  /// `settings.headerForeground`.
  VscColor? get headerForeground => map['settings.headerForeground'];

  /// `settings.modifiedItemIndicator`.
  VscColor? get modifiedItemIndicator => map['settings.modifiedItemIndicator'];

  /// `settings.numberInputBorder`.
  VscColor? get numberInputBorder => map['settings.numberInputBorder'];

  /// `settings.textInputBorder`.
  VscColor? get textInputBorder => map['settings.textInputBorder'];

}

/// Workbench colors under `sideBar.…`.
class VscWorkbenchSideBarColors {
  /// Creates a group view over [map].
  const VscWorkbenchSideBarColors(this.map);

  /// Underlying merged color map.
  final Map<String, VscColor> map;

  /// `sideBar.background`.
  VscColor? get background => map['sideBar.background'];

  /// `sideBar.border`.
  VscColor? get border => map['sideBar.border'];

  /// `sideBar.foreground`.
  VscColor? get foreground => map['sideBar.foreground'];

}

/// Workbench colors under `sideBarSectionHeader.…`.
class VscWorkbenchSideBarSectionHeaderColors {
  /// Creates a group view over [map].
  const VscWorkbenchSideBarSectionHeaderColors(this.map);

  /// Underlying merged color map.
  final Map<String, VscColor> map;

  /// `sideBarSectionHeader.background`.
  VscColor? get background => map['sideBarSectionHeader.background'];

  /// `sideBarSectionHeader.border`.
  VscColor? get border => map['sideBarSectionHeader.border'];

  /// `sideBarSectionHeader.foreground`.
  VscColor? get foreground => map['sideBarSectionHeader.foreground'];

}

/// Workbench colors under `sideBarStickyScroll.…`.
class VscWorkbenchSideBarStickyScrollColors {
  /// Creates a group view over [map].
  const VscWorkbenchSideBarStickyScrollColors(this.map);

  /// Underlying merged color map.
  final Map<String, VscColor> map;

  /// `sideBarStickyScroll.border`.
  VscColor? get border => map['sideBarStickyScroll.border'];

  /// `sideBarStickyScroll.shadow`.
  VscColor? get shadow => map['sideBarStickyScroll.shadow'];

}

/// Workbench colors under `sideBarTitle.…`.
class VscWorkbenchSideBarTitleColors {
  /// Creates a group view over [map].
  const VscWorkbenchSideBarTitleColors(this.map);

  /// Underlying merged color map.
  final Map<String, VscColor> map;

  /// `sideBarTitle.foreground`.
  VscColor? get foreground => map['sideBarTitle.foreground'];

}

/// Workbench colors under `statusBar.…`.
class VscWorkbenchStatusBarColors {
  /// Creates a group view over [map].
  const VscWorkbenchStatusBarColors(this.map);

  /// Underlying merged color map.
  final Map<String, VscColor> map;

  /// `statusBar.background`.
  VscColor? get background => map['statusBar.background'];

  /// `statusBar.border`.
  VscColor? get border => map['statusBar.border'];

  /// `statusBar.debuggingBackground`.
  VscColor? get debuggingBackground => map['statusBar.debuggingBackground'];

  /// `statusBar.debuggingForeground`.
  VscColor? get debuggingForeground => map['statusBar.debuggingForeground'];

  /// `statusBar.focusBorder`.
  VscColor? get focusBorder => map['statusBar.focusBorder'];

  /// `statusBar.foreground`.
  VscColor? get foreground => map['statusBar.foreground'];

  /// `statusBar.inactiveBackground`.
  VscColor? get inactiveBackground => map['statusBar.inactiveBackground'];

  /// `statusBar.noFolderBackground`.
  VscColor? get noFolderBackground => map['statusBar.noFolderBackground'];

  /// `statusBar.noFolderForeground`.
  VscColor? get noFolderForeground => map['statusBar.noFolderForeground'];

}

/// Workbench colors under `statusBarItem.…`.
class VscWorkbenchStatusBarItemColors {
  /// Creates a group view over [map].
  const VscWorkbenchStatusBarItemColors(this.map);

  /// Underlying merged color map.
  final Map<String, VscColor> map;

  /// `statusBarItem.activeBackground`.
  VscColor? get activeBackground => map['statusBarItem.activeBackground'];

  /// `statusBarItem.compactHoverBackground`.
  VscColor? get compactHoverBackground => map['statusBarItem.compactHoverBackground'];

  /// `statusBarItem.errorBackground`.
  VscColor? get errorBackground => map['statusBarItem.errorBackground'];

  /// `statusBarItem.focusBorder`.
  VscColor? get focusBorder => map['statusBarItem.focusBorder'];

  /// `statusBarItem.hoverBackground`.
  VscColor? get hoverBackground => map['statusBarItem.hoverBackground'];

  /// `statusBarItem.prominentBackground`.
  VscColor? get prominentBackground => map['statusBarItem.prominentBackground'];

  /// `statusBarItem.prominentForeground`.
  VscColor? get prominentForeground => map['statusBarItem.prominentForeground'];

  /// `statusBarItem.prominentHoverBackground`.
  VscColor? get prominentHoverBackground => map['statusBarItem.prominentHoverBackground'];

  /// `statusBarItem.prominentHoverForeground`.
  VscColor? get prominentHoverForeground => map['statusBarItem.prominentHoverForeground'];

  /// `statusBarItem.remoteBackground`.
  VscColor? get remoteBackground => map['statusBarItem.remoteBackground'];

  /// `statusBarItem.remoteForeground`.
  VscColor? get remoteForeground => map['statusBarItem.remoteForeground'];

}

/// Workbench colors under `surface.…`.
class VscWorkbenchSurfaceColors {
  /// Creates a group view over [map].
  const VscWorkbenchSurfaceColors(this.map);

  /// Underlying merged color map.
  final Map<String, VscColor> map;

  /// `surface.background`.
  VscColor? get background => map['surface.background'];

  /// `surface.border`.
  VscColor? get border => map['surface.border'];

  /// `surface.foreground`.
  VscColor? get foreground => map['surface.foreground'];

}

/// Workbench colors under `tab.…`.
class VscWorkbenchTabColors {
  /// Creates a group view over [map].
  const VscWorkbenchTabColors(this.map);

  /// Underlying merged color map.
  final Map<String, VscColor> map;

  /// `tab.activeBackground`.
  VscColor? get activeBackground => map['tab.activeBackground'];

  /// `tab.activeBorder`.
  VscColor? get activeBorder => map['tab.activeBorder'];

  /// `tab.activeBorderTop`.
  VscColor? get activeBorderTop => map['tab.activeBorderTop'];

  /// `tab.activeForeground`.
  VscColor? get activeForeground => map['tab.activeForeground'];

  /// `tab.activeModifiedBorder`.
  VscColor? get activeModifiedBorder => map['tab.activeModifiedBorder'];

  /// `tab.border`.
  VscColor? get border => map['tab.border'];

  /// `tab.hoverBackground`.
  VscColor? get hoverBackground => map['tab.hoverBackground'];

  /// `tab.hoverForeground`.
  VscColor? get hoverForeground => map['tab.hoverForeground'];

  /// `tab.inactiveBackground`.
  VscColor? get inactiveBackground => map['tab.inactiveBackground'];

  /// `tab.inactiveForeground`.
  VscColor? get inactiveForeground => map['tab.inactiveForeground'];

  /// `tab.lastPinnedBorder`.
  VscColor? get lastPinnedBorder => map['tab.lastPinnedBorder'];

  /// `tab.selectedBackground`.
  VscColor? get selectedBackground => map['tab.selectedBackground'];

  /// `tab.selectedBorderTop`.
  VscColor? get selectedBorderTop => map['tab.selectedBorderTop'];

  /// `tab.selectedForeground`.
  VscColor? get selectedForeground => map['tab.selectedForeground'];

  /// `tab.unfocusedActiveBackground`.
  VscColor? get unfocusedActiveBackground => map['tab.unfocusedActiveBackground'];

  /// `tab.unfocusedActiveBorder`.
  VscColor? get unfocusedActiveBorder => map['tab.unfocusedActiveBorder'];

  /// `tab.unfocusedActiveBorderTop`.
  VscColor? get unfocusedActiveBorderTop => map['tab.unfocusedActiveBorderTop'];

  /// `tab.unfocusedActiveForeground`.
  VscColor? get unfocusedActiveForeground => map['tab.unfocusedActiveForeground'];

  /// `tab.unfocusedHoverBackground`.
  VscColor? get unfocusedHoverBackground => map['tab.unfocusedHoverBackground'];

  /// `tab.unfocusedHoverBorder`.
  VscColor? get unfocusedHoverBorder => map['tab.unfocusedHoverBorder'];

  /// `tab.unfocusedInactiveBackground`.
  VscColor? get unfocusedInactiveBackground => map['tab.unfocusedInactiveBackground'];

  /// `tab.unfocusedInactiveForeground`.
  VscColor? get unfocusedInactiveForeground => map['tab.unfocusedInactiveForeground'];

}

/// Workbench colors under `terminal.…`.
class VscWorkbenchTerminalColors {
  /// Creates a group view over [map].
  const VscWorkbenchTerminalColors(this.map);

  /// Underlying merged color map.
  final Map<String, VscColor> map;

  /// `terminal.ansiBlack`.
  VscColor? get ansiBlack => map['terminal.ansiBlack'];

  /// `terminal.ansiBlue`.
  VscColor? get ansiBlue => map['terminal.ansiBlue'];

  /// `terminal.ansiBrightBlack`.
  VscColor? get ansiBrightBlack => map['terminal.ansiBrightBlack'];

  /// `terminal.ansiBrightBlue`.
  VscColor? get ansiBrightBlue => map['terminal.ansiBrightBlue'];

  /// `terminal.ansiBrightCyan`.
  VscColor? get ansiBrightCyan => map['terminal.ansiBrightCyan'];

  /// `terminal.ansiBrightGreen`.
  VscColor? get ansiBrightGreen => map['terminal.ansiBrightGreen'];

  /// `terminal.ansiBrightMagenta`.
  VscColor? get ansiBrightMagenta => map['terminal.ansiBrightMagenta'];

  /// `terminal.ansiBrightRed`.
  VscColor? get ansiBrightRed => map['terminal.ansiBrightRed'];

  /// `terminal.ansiBrightWhite`.
  VscColor? get ansiBrightWhite => map['terminal.ansiBrightWhite'];

  /// `terminal.ansiBrightYellow`.
  VscColor? get ansiBrightYellow => map['terminal.ansiBrightYellow'];

  /// `terminal.ansiCyan`.
  VscColor? get ansiCyan => map['terminal.ansiCyan'];

  /// `terminal.ansiGreen`.
  VscColor? get ansiGreen => map['terminal.ansiGreen'];

  /// `terminal.ansiMagenta`.
  VscColor? get ansiMagenta => map['terminal.ansiMagenta'];

  /// `terminal.ansiRed`.
  VscColor? get ansiRed => map['terminal.ansiRed'];

  /// `terminal.ansiWhite`.
  VscColor? get ansiWhite => map['terminal.ansiWhite'];

  /// `terminal.ansiYellow`.
  VscColor? get ansiYellow => map['terminal.ansiYellow'];

  /// `terminal.background`.
  VscColor? get background => map['terminal.background'];

  /// `terminal.border`.
  VscColor? get border => map['terminal.border'];

  /// `terminal.foreground`.
  VscColor? get foreground => map['terminal.foreground'];

  /// `terminal.inactiveSelectionBackground`.
  VscColor? get inactiveSelectionBackground => map['terminal.inactiveSelectionBackground'];

  /// `terminal.selectionBackground`.
  VscColor? get selectionBackground => map['terminal.selectionBackground'];

  /// Color group `terminal.tab`.
  VscWorkbenchTerminalTabColors get tab => VscWorkbenchTerminalTabColors(map);

}

/// Workbench colors under `terminal.tab.…`.
class VscWorkbenchTerminalTabColors {
  /// Creates a group view over [map].
  const VscWorkbenchTerminalTabColors(this.map);

  /// Underlying merged color map.
  final Map<String, VscColor> map;

  /// `terminal.tab.activeBorder`.
  VscColor? get activeBorder => map['terminal.tab.activeBorder'];

}

/// Workbench colors under `terminalCursor.…`.
class VscWorkbenchTerminalCursorColors {
  /// Creates a group view over [map].
  const VscWorkbenchTerminalCursorColors(this.map);

  /// Underlying merged color map.
  final Map<String, VscColor> map;

  /// `terminalCursor.background`.
  VscColor? get background => map['terminalCursor.background'];

  /// `terminalCursor.foreground`.
  VscColor? get foreground => map['terminalCursor.foreground'];

}

/// Workbench colors under `terminalStickyScroll.…`.
class VscWorkbenchTerminalStickyScrollColors {
  /// Creates a group view over [map].
  const VscWorkbenchTerminalStickyScrollColors(this.map);

  /// Underlying merged color map.
  final Map<String, VscColor> map;

  /// `terminalStickyScroll.border`.
  VscColor? get border => map['terminalStickyScroll.border'];

}

/// Workbench colors under `textBlockQuote.…`.
class VscWorkbenchTextBlockQuoteColors {
  /// Creates a group view over [map].
  const VscWorkbenchTextBlockQuoteColors(this.map);

  /// Underlying merged color map.
  final Map<String, VscColor> map;

  /// `textBlockQuote.background`.
  VscColor? get background => map['textBlockQuote.background'];

  /// `textBlockQuote.border`.
  VscColor? get border => map['textBlockQuote.border'];

}

/// Workbench colors under `textCodeBlock.…`.
class VscWorkbenchTextCodeBlockColors {
  /// Creates a group view over [map].
  const VscWorkbenchTextCodeBlockColors(this.map);

  /// Underlying merged color map.
  final Map<String, VscColor> map;

  /// `textCodeBlock.background`.
  VscColor? get background => map['textCodeBlock.background'];

}

/// Workbench colors under `textLink.…`.
class VscWorkbenchTextLinkColors {
  /// Creates a group view over [map].
  const VscWorkbenchTextLinkColors(this.map);

  /// Underlying merged color map.
  final Map<String, VscColor> map;

  /// `textLink.activeForeground`.
  VscColor? get activeForeground => map['textLink.activeForeground'];

  /// `textLink.foreground`.
  VscColor? get foreground => map['textLink.foreground'];

}

/// Workbench colors under `textPreformat.…`.
class VscWorkbenchTextPreformatColors {
  /// Creates a group view over [map].
  const VscWorkbenchTextPreformatColors(this.map);

  /// Underlying merged color map.
  final Map<String, VscColor> map;

  /// `textPreformat.background`.
  VscColor? get background => map['textPreformat.background'];

  /// `textPreformat.foreground`.
  VscColor? get foreground => map['textPreformat.foreground'];

}

/// Workbench colors under `textSeparator.…`.
class VscWorkbenchTextSeparatorColors {
  /// Creates a group view over [map].
  const VscWorkbenchTextSeparatorColors(this.map);

  /// Underlying merged color map.
  final Map<String, VscColor> map;

  /// `textSeparator.foreground`.
  VscColor? get foreground => map['textSeparator.foreground'];

}

/// Workbench colors under `titleBar.…`.
class VscWorkbenchTitleBarColors {
  /// Creates a group view over [map].
  const VscWorkbenchTitleBarColors(this.map);

  /// Underlying merged color map.
  final Map<String, VscColor> map;

  /// `titleBar.activeBackground`.
  VscColor? get activeBackground => map['titleBar.activeBackground'];

  /// `titleBar.activeForeground`.
  VscColor? get activeForeground => map['titleBar.activeForeground'];

  /// `titleBar.border`.
  VscColor? get border => map['titleBar.border'];

  /// `titleBar.inactiveBackground`.
  VscColor? get inactiveBackground => map['titleBar.inactiveBackground'];

  /// `titleBar.inactiveForeground`.
  VscColor? get inactiveForeground => map['titleBar.inactiveForeground'];

}

/// Workbench colors under `toolbar.…`.
class VscWorkbenchToolbarColors {
  /// Creates a group view over [map].
  const VscWorkbenchToolbarColors(this.map);

  /// Underlying merged color map.
  final Map<String, VscColor> map;

  /// `toolbar.activeBackground`.
  VscColor? get activeBackground => map['toolbar.activeBackground'];

  /// `toolbar.hoverBackground`.
  VscColor? get hoverBackground => map['toolbar.hoverBackground'];

}

/// Workbench colors under `tree.…`.
class VscWorkbenchTreeColors {
  /// Creates a group view over [map].
  const VscWorkbenchTreeColors(this.map);

  /// Underlying merged color map.
  final Map<String, VscColor> map;

  /// `tree.inactiveIndentGuidesStroke`.
  VscColor? get inactiveIndentGuidesStroke => map['tree.inactiveIndentGuidesStroke'];

  /// `tree.indentGuidesStroke`.
  VscColor? get indentGuidesStroke => map['tree.indentGuidesStroke'];

}

/// Workbench colors under `walkThrough.…`.
class VscWorkbenchWalkThroughColors {
  /// Creates a group view over [map].
  const VscWorkbenchWalkThroughColors(this.map);

  /// Underlying merged color map.
  final Map<String, VscColor> map;

  /// `walkThrough.embeddedEditorBackground`.
  VscColor? get embeddedEditorBackground => map['walkThrough.embeddedEditorBackground'];

}

/// Workbench colors under `welcomePage.…`.
class VscWorkbenchWelcomePageColors {
  /// Creates a group view over [map].
  const VscWorkbenchWelcomePageColors(this.map);

  /// Underlying merged color map.
  final Map<String, VscColor> map;

  /// `welcomePage.tileBackground`.
  VscColor? get tileBackground => map['welcomePage.tileBackground'];

  /// Color group `welcomePage.progress`.
  VscWorkbenchWelcomePageProgressColors get progress => VscWorkbenchWelcomePageProgressColors(map);

}

/// Workbench colors under `welcomePage.progress.…`.
class VscWorkbenchWelcomePageProgressColors {
  /// Creates a group view over [map].
  const VscWorkbenchWelcomePageProgressColors(this.map);

  /// Underlying merged color map.
  final Map<String, VscColor> map;

  /// `welcomePage.progress.foreground`.
  VscColor? get foreground => map['welcomePage.progress.foreground'];

}

/// Workbench colors under `widget.…`.
class VscWorkbenchWidgetColors {
  /// Creates a group view over [map].
  const VscWorkbenchWidgetColors(this.map);

  /// Underlying merged color map.
  final Map<String, VscColor> map;

  /// `widget.border`.
  VscColor? get border => map['widget.border'];

  /// `widget.shadow`.
  VscColor? get shadow => map['widget.shadow'];
}
