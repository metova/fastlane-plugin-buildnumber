require 'fastlane/action'
require_relative '../helper/buildnumber_helper'

module Fastlane
  module Actions
    class BuildnumberAction < Action
      def self.description
        "Generates unique build numbers for iOS projects."
      end

      def self.authors
        ["Nick Griffith"]
      end

      def self.is_supported?(platform)
        [:ios, :mac].include?(platform)
      end

      def self.details
        "This plugin generates unique build numbers for iOS projects combine a custom epoch to ensure always increasing build number and a decimal version of the githash, which can be reversed to find the commit the build comes from. This plugin elimintes the need to ever make commits to solely update the build number, or use git's tagging/branching to identify where builds come from."
      end

      def self.run(params)
        UI.important("Remember: Turn on preprocessing for your Info.plist.")
        UI.important("Remember: Specify #{Dir.pwd}/FastLaneBuildNumber.h as your Info.plist Preprocessor Prefix File . . . ")
        UI.important("Remember: Specify FastLaneBuildNumber as your build number.")
        UI.message("We recommend adding */FastLaneBuildNumber.h to .gitignore")

        commit = `git rev-parse --short HEAD`
        commitInt = Integer("0x1#{commit}")
        masterCommitDate = `git show -s --format=%ci master` #TODO: Take optional arg specifying branch/tag/commit
        epochTime = DateTime.now() - DateTime.parse(masterCommitDate) #minutes since last commit to master
        epochTimeMinutes = (epochTime * 24 * 60).to_i

        buildNumber = "#{epochTimeMinutes}.#{commitInt}"

        UI.message("Generating preprocesser file at #{Dir.pwd}/FastLaneBuildNumber.h . . . ")
        `touch ./FastLaneBuildNumber.h` #TODO: Let user specify directory/file
        `cat <<EOF > ./FastLaneBuildNumber.h
#define FastLaneBuildNumber "#{buildNumber}"
EOF`
        UI.success(" Success! Build number defined as #{buildNumber}")
      end

      def self.return_value
        # If your method provides a return value, you can describe here what it does
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :xcodeproj,
                                       env_name: "UPDATE_XCODEPROJ_XCODEPROJ",
                                       description: "Path to your Xcode project",
                                       optional: true,
                                       default_value: Dir['*.xcodeproj'].first,
                                       type: String,
                                       verify_block: proc do |value|
                                         UI.user_error!("Please pass the path to the project, not the workspace") unless value.end_with?(".xcodeproj")
                                         UI.user_error!("Could not find Xcode project") unless File.exist?(value)
                                       end)
        ]
      end
    end
  end
end
