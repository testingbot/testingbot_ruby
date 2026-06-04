module TestingBot
  module Resources
    # Endpoints under /jobs.
    module Jobs
      # Poll the status/result of an asynchronous job (e.g. a Codeless Lab run).
      def get_job(job_id)
        get("/jobs/#{escape(job_id)}")
      end
    end
  end
end
