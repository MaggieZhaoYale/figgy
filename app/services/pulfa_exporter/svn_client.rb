# frozen_string_literal: true
class PulfaExporter
  class SvnClient
    attr_reader :dry_run, :logger, :svn_base, :svn_dir
    def initialize(svn_base:, svn_dir:, dry_run: true, logger: Logger.new(STDOUT)) # XXX false
      @svn_dir = svn_dir
      @svn_base = svn_base
      @dry_run = dry_run
      @logger = logger
    end

    def commit
      svn_exec("commit")
    end

    def create_branch(basename)
      branch = "#{svn_base}/branches/#{basename}-#{today}"
      svn_exec("copy #{svn_base}/trunk #{branch} -m \"#{basename} review #{today}\"")
      svn_exec("sw #{branch}")
      branch
    end

    def switch(basename)
      svn_exec("sw #{svn_base}/#{basename}")
    end

    def update
      svn_exec("update")
    end

    private

      def svn_exec(cmd)
        logger.info "SVN: #{cmd}"
        system("cd #{svn_dir} && svn #{cmd}") unless dry_run
      end

      def today
        Time.zone.today.strftime("%Y-%m-%d")
      end
  end
end
