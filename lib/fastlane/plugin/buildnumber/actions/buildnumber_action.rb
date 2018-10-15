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
        "This plugin generates unique build numbers for projects combined a custom epoch to ensure always increasing build number and a decimal version of the githash, which can be reversed to find the commit the build comes from."
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
        current_commit = `git rev-parse --short HEAD`
        current_commit_decimalized = Integer("0x1#{current_commit}")
        git_commit_date = `git show -s --format=%ci #{params[:git]}`
        time_since_git = DateTime.now - DateTime.parse(git_commit_date) # minutes since specified git commit/tag/branch
        time_since_git_minutes = (time_since_git * 24 * 60).to_i

        return "#{time_since_git_minutes}.#{current_commit_decimalized}"
      end
    end
  end
end
