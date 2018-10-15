require 'fastlane/action'
require_relative '../helper/buildnumber_helper'

module Fastlane
  module Actions
    class BuildnumberAction < Action
      def self.description
        "Generates unique build numbers for iOS projects"
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

      def self.return_value
        "Returns the generated build number"
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(
            key: :git,
            env_name: "FL_BUILDNUMBER_GIT",
            description: "Git branch, tag, or commit to pull timestamp from for epoch portion of build number",
            optional: true,
            default_value: "master",
            type: String
          )
        ]
      end

      def self.run(params)
        commit = `git rev-parse --short HEAD`
        commitInt = Integer("0x1#{commit}")
        masterCommitDate = `git show -s --format=%ci #{params[:git]}`
        epochTime = DateTime.now() - DateTime.parse(masterCommitDate) #minutes since specified git commit/tag/branch
        epochTimeMinutes = (epochTime * 24 * 60).to_i

        return "#{epochTimeMinutes}.#{commitInt}"

        UI.success(" Success! Build number defined as #{buildNumber}")
      end
    end
  end
end
