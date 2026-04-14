# frozen_string_literal: true

module DomniqApp
  class PoParser
    # All 648 English default strings from branding.ts
    # Keys match the left side, values match the right side
    DEFAULT_STRINGS = {
      "App Name" => "DOMNiQ",
      "App Tagline" => "Creative HQ",
      "Domniq HQ App" => "Domniq HQ App",
      "Get Started" => "Get Started",
      "Log In" => "Log In",
      "Login and register first to access all of the exciting features." => "Join our community to access member-only features and updates.",
      "Public Profile" => "Public Profile",
      "Onboarding Slide 1 Title" => "Connect",
      "Onboarding Slide 1 Description" => "Join a vibrant community blended with people who share your interests.",
      "Onboarding Slide 2 Title" => "Discover",
      "Onboarding Slide 2 Description" => "Find answers, interesting discussions, and topics that matter to you.",
      "Onboarding Slide 3 Title" => "Engage",
      "Onboarding Slide 3 Description" => "Participate in discussions, share your knowledge, and help others.",
      "SoftwareInfo Platform Name" => "Discourse",
      "Platform Foundation and Licensing" => "Platform Foundation and Licensing",
      "Troubleshoot Platform Unreachable Title" => "Platform Unreachable",
      "Troubleshoot Platform Unreachable Description" => "The forum could not be reached. Please check your connection or try again later.",
      "Photo Access Required" => "Photo Access Required",
      "You have been logged out" => "You have been logged out",
      "Warning" => "Warning",
      "This feature not available yet" => "This feature not available yet",
      "Store Update Check" => "Store Update Check",
      "Dock Menu Required" => "Dock Menu Required",
      "Quick Settings" => "Quick Settings",
      "Toggle dark mode" => "Toggle dark mode",
      "Choose a color palette" => "Choose a color palette",
      "Dock Menu" => "Dock Menu",
      "Bottom bar orientation" => "Bottom bar orientation",
      "Home" => "Home",
      "Explore" => "Explore",
      "Chat" => "Chat",
      "Messages" => "Messages",
      "Notifications" => "Notifications",
      "Groups" => "Groups",
      "Community Hub" => "Community Hub",
      "Profile" => "Profile",
      "Activity" => "Activity",
      "Badges" => "Badges",
      "Bio" => "About Me",
      "Follow" => "Connect",
      "Message" => "Message",
      "Recent Activity" => "Recent Activity",
      "User Information" => "Member Details",
      "View Public Profile" => "View Member Page",
      "Set Status" => "Set Status",
      "Edit Profile" => "Edit Profile",
      "Saved Drafts" => "Saved Drafts",
      "My Activity" => "My Activity",
      "My Bookmarks" => "My Bookmarks",
      "Password & Security" => "Password & Security",
      "Blocked Connections" => "Blocked Connections",
      "Preferences & Settings" => "Preferences & Settings",
      "About App" => "About App",
      "Contact Us" => "Contact Us",
      "Log Out" => "Log Out",
      "Delete Account" => "Delete Account",
      "Are you sure you want to log out?" => "Are you sure you want to log out?",
      "Request Account Deletion" => "Request Account Deletion",
      "Delete My Account" => "Delete My Account",
      "Manage account deletion options" => "Manage account deletion options",
      "Permanent Account Deletion" => "Permanent Account Deletion",
      "DPN MEDIA WORKS" => "DPN MEDIA WORKS",
      "We Design, We Produce, We Network" => "We Design, We Produce, We Network",
      "Premium UI and System Architecture" => "App Developed By | DPN MEDIA WORKS",
      "DEVELOPED BY" => "ENGINEERED BY",
      "BUILD INFORMATION" => "VERSIONING & CREDITS",
      "Software Information" => "Opensource Acknowledgement",
      "Information about the application" => "Application Details & Information",
      "App Version" => "Core Version",
      "Check For Update" => "System Check",
      "Preferences" => "Customization",
      "Privacy Policy" => "Data Privacy",
      "Terms of Service" => "Terms of Use",
      "PERMISSIONS USED BY THE APP" => "SYSTEM PERMISSIONS",
      "Cancel" => "Cancel",
      "Continue" => "Proceed",
      "Done" => "Finished",
      "Delete" => "Remove",
      "Discard" => "Discard",
      "Edit" => "Refine",
      "Save as Draft" => "Keep for Later",
      "REPLY" => "REPLY",
      "POST" => "PUBLISH",
      "Send" => "Submit",
      "Hubs" => "Hubs",
      "All Hubs" => "All Hubs",
      "Poll" => "Poll",
      "Categories" => "Categories",
      "My Drafts" => "My Drafts",
      "Live Chat" => "Channels",
      "New Post" => "New Post",
      "Edit Post" => "Edit Post",
      "New Message" => "New Message",
      "Search" => "Search",
      "Color Style" => "Color Style",
      "Dark Mode" => "Dark Mode",
      "Live Events" => "Live Events",
      "Coming Soon" => "Coming Soon",
      "Leaderboard Stories" => "Leaderboard Stories",
      "Top 10 This Week" => "Top 10 This Week",
      "Playground" => "Playground",
      "Available Options" => "Available Options",
      "Community" => "Community",
      "Features & About" => "Features & About",
      "Leaderboard" => "Leaderboard",
      "Top Contributors" => "Top Contributors",
      "Overview" => "Overview",
      "About this space" => "About this space",
      "Settings" => "Settings",
      "App Configuration" => "App Configuration",
      "Appearance" => "Appearance",
      "Change icon appearance" => "Change icon appearance",
      "Control feed content display" => "Control feed content display",
      "Choose your reply experience" => "Choose your reply experience",
      "Feed Style" => "Feed Style",
      "Post Style" => "Post Style",
      "Icon Style" => "Icon Style",
      "Device Permissions" => "Device Permissions",
      "Camera, microphone & media" => "Camera, microphone & media",
      "Alerts & notification sounds" => "Alerts & notification sounds",
      "Support" => "Support",
      "Help & Info" => "Help & Info",
      "App Guide" => "App Guide",
      "Learn how the app works" => "Learn how the app works",
      "App Developer" => "App Developer",
      "Get in Touch" => "Get in Touch",
      "Admin Dashboard" => "Admin Dashboard",
      "Site Management" => "Site Management",
      "Site Stats" => "Site Stats",
      "Analytics & metrics" => "Analytics & metrics",
      "Users" => "Users",
      "Manage members" => "Manage members",
      "Flags & review queue" => "Flags & review queue",
      "FAQ & Guidelines" => "FAQ & Guidelines",
      "Frequently asked questions" => "Frequently asked questions",
      "Review our policy" => "Review our policy",
      "Review our terms" => "Review our terms",
      "Topics" => "Topics",
      "Likes" => "Likes",
      "Replies" => "Replies",
      "Reply" => "Reply",
      "Post" => "Post",
      "Admin" => "Admin",
      "Moderator" => "Moderator",
      "Staff" => "Staff",
      "Success" => "Success",
      "Error" => "Error",
      "OK" => "OK",
      "Back" => "Back",
      "Next" => "Next",
      "Loading..." => "Loading...",
      "No Notifications available" => "No Notifications available",
      "Mark All as Read" => "Mark All as Read",
      "Push Notifications" => "Push Notifications",
      "Server Unreachable" => "Server Unreachable",
      "No Connection" => "No Connection",
    }.freeze

    def self.generate_default_po
      header = <<~PO
        # Domniq Mobile App - English Defaults
        # Generated from branding.ts
        # Translate the msgstr values to your target language.
        #
        msgid ""
        msgstr ""
        "Content-Type: text/plain; charset=UTF-8\\n"
        "Language: en\\n"

      PO

      entries = DEFAULT_STRINGS.map do |key, value|
        escaped_key = key.to_s.gsub('"', '\\"').gsub("\n", "\\n")
        escaped_value = value.to_s.gsub('"', '\\"').gsub("\n", "\\n")
        "msgid \"#{escaped_key}\"\nmsgstr \"#{escaped_value}\"\n"
      end

      header + entries.join("\n")
    end

    def self.parse(po_content)
      strings = {}
      current_msgid = nil

      po_content.each_line do |line|
        line = line.strip

        if line.start_with?("msgid ")
          current_msgid = extract_string(line.sub("msgid ", ""))
        elsif line.start_with?("msgstr ") && current_msgid && current_msgid != ""
          msgstr = extract_string(line.sub("msgstr ", ""))
          strings[current_msgid] = msgstr if msgstr.present?
          current_msgid = nil
        end
      end

      strings
    end

    def self.extract_string(quoted)
      quoted.strip.gsub(/\A"|"\z/, "").gsub('\\"', '"').gsub("\\n", "\n")
    end
  end
end
