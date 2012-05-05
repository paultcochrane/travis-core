module Travis
  module Api
    module Json
      module Http
        class Repository
          include Formats

          attr_reader :repository, :options

          def initialize(repository, options = {})
            @repository = repository
            @options = options.symbolize_keys.slice(*::Build.matrix_keys_for(options))
          end

          def data
            {
              'id' => repository.id,
              'slug' => repository.slug,
              'description' => repository.description,
              'public_key' => repository.key.public_key,
              'last_build_id' => repository.last_build_id,
              'last_build_number' => repository.last_build_number,
              'last_build_status' => repository.last_build_status,
              'last_build_result' => repository.last_build_status(options),
              'last_build_duration' => repository.last_build_duration,
              'last_build_language' => repository.last_build_language,
              'last_build_started_at' => format_date(repository.last_build_started_at),
              'last_build_finished_at' => format_date(repository.last_build_finished_at),
              'branch_summary' => branch_summary_data(repository)
            }
          end

          def branch_summary_data(repository)
            repository.last_finished_builds_by_branches.map do |build|
              {
                'build_id' => build.id,
                'commit' => build.commit.commit,
                'branch' => build.commit.branch,
                'message' => build.commit.message,
                'status' => build.status,
                'finished_at' => format_date(build.finished_at),
                'started_at' => format_date(build.started_at)
              }
            end
          end
        end
      end
    end
  end
end
