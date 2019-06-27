# frozen_string_literal: true
# Subversion client for interacting with local copy of PULFA SVN repository
class PulfaExporter
  class SvnClient
    attr_reader :dry_run, :logger, :svn_base, :svn_dir
    def initialize(svn_base:, svn_dir:, dry_run: false, logger: Logger.new(STDOUT))
      @svn_dir = svn_dir
      @svn_base = svn_base
      @dry_run = dry_run
      @logger = logger
    end

    # commit local changes to the SVN server
    def commit
      svn_exec("commit")
    end

    # create a branch and switch to it
    def create_branch(basename)
      branch = "#{svn_base}/branches/#{basename}-#{today}"
      svn_exec("copy #{svn_base}/trunk #{branch} -m \"#{basename} review #{today}\"")
      svn_exec("sw #{branch}")
      branch
    end

    # switch to a branch
    def switch(basename)
      svn_exec("sw #{svn_base}/#{basename}")
    end

    # fetch changes from the SVN server
    def update
      svn_exec("update")
    end

    private

      # execute a SVN command
      def svn_exec(cmd)
        logger.info "SVN: #{cmd}"
        system("cd #{svn_dir} && svn #{cmd}") unless dry_run
      end

      # today's date, used for timestamping new branches
      def today
        Time.zone.today.strftime("%Y-%m-%d")
      end
  end
end
