require 'fastlane/action'
require_relative '../helper/common_fastfile_helper'

module Fastlane
  module Actions
    class CommonGitlabFastfileAction < Action
      def self.run(params)
        require 'fileutils'
        require 'gitlab'

        begin
          if not file = params[:file] then raise StandardError.new "Cannot import due to missing 'file' value. Please provide the path to your file from ios-lib-scripts." end
          if not version = params[:version] then raise StandardError.new "Cannot import due to missing 'version' value. Please provide the [branch | tag | commit] for '#{file}'" end
          if not repository = params[:repository] || ENV['GITLAB_FASTFILES_REPOSITORY'] then raise StandardError.new "Cannot import due to missing 'repository' value. Please provide the Gitlab project ID or name or set 'GITLAB_FASTFILES_REPOSITORY' variable" end
        
          import_filename = "#{version.gsub(/[^0-9a-zA-Z-]/i, '_')}/#{file}"
          import_relative_path = "#{FastlaneCore::FastlaneFolder.path}imports/#{import_filename}"
          import_path = File.expand_path(import_relative_path)
          puts "Requested by: #{Thread.current.backtrace.find { |e| e.end_with?("in `parsing_binding'") }.gsub(/:\d*:in `parsing_binding'/i, '')}"
          puts " Downloading: #{file} [#{version}] from #{repository}"
          content = Gitlab.repo_file_contents(repository, file, version) 
          FileUtils.mkdir_p File.dirname(import_path)
          File.write(import_path, content)
          puts "    Saved in: #{import_relative_path}"          
          import_path
        rescue StandardError => e
          UI.important "Please check:
- if you have 'GITLAB_API_ENDPOINT' set, usually 'https://gitlab.com/api/v4'
- if you have 'GITLAB_API_PRIVATE_TOKEN' set, usually you can use 'https://gitlab.com/-/profile/personal_access_tokens' to set up one
- if you have 'GITLAB_FASTFILES_REPOSITORY' set with a Gitlab project ID or name, e.g. 'group/subgroup/repository'
Consider adding them to your .bash_profile, .zshrc or other shell configuration file"
          UI.user_error!("[common_fastfile] Download failure with:\n#{e}")
        end
      end

      def self.description
        "Gets the requested file, saves it into ./fastlane/imports and return the path"
      end

      def self.authors
        ["Pawel Szymanski"]
      end

      def self.return_value
        "The path to a file within ./fastlane/imports with requested common fastfile"
      end

      def self.details
        # Optional:
        "Gets the requested file, saves it into ./fastlane/imports and return the path"
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :file,
                               description: "Path to the file within repository",
                                  optional: false,
                                 is_string: true,
                                      type: String),
          FastlaneCore::ConfigItem.new(key: :version,
                               description: "Version of the file [branch, tag, commit]",
                                  optional: false,
                                 is_string: true,
                                      type: String),
          FastlaneCore::ConfigItem.new(key: :repository,
                               description: "Gitlab repository ID, e.g. 26259886 or group/subgroup/repository",
                                  optional: true,
                                 is_string: true,
                                      type: String),
        ]
      end

      def self.is_supported?(platform)
        true
      end
    end
  end
end
