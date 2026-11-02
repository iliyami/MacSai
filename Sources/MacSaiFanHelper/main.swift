import Foundation

// Root LaunchDaemon registered by the menu-bar app through SMAppService only
// after the user opts in to fan control. See FanHelperService for the safety
// rules.
FanHelperService.shared.run()
