require 'set'
require 'git_heroes/ext/time'
require 'git_heroes/ext/octokit'
require 'active_support/all' # for #beginning_of_week
require 'csv'
require 'working_hours'


class GitHeroes::Engine
  POINTS = { pull: 1, comment: 1, merge: 2 }
  
  def initialize(client:nil, org:nil, weeks:nil)
    @client       = client
    @organisation = org

    # output/calculated fields
    @data         = {}
    @users        = Set.new
    @durations    = []

    @end_time     = Time.now.beginning_of_week
    week_count    = weeks
    @weeks        = (1..week_count).map { |idx| @end_time - idx.weeks }
    @start_time   = @weeks.last
  end


  def run
    page = 1
    while true
      repositories = @client.organization_repositories(@organisation, page:page)
      break if repositories.empty?
      repositories.each do |repository|
        each_pull_request(repository) do |pull_request, get_options|
          process_pull_request(pull_request, get_options)
        end
      end
      page += 1
    end
  end


  def export(path)
    CSV.open(path, 'w') do |csv|
      weeks = @weeks.sort.reverse
      weeks_keys = weeks.map { |w| w.week_key }
      header = %w(login) + weeks.map { |w| w.strftime('%Y.%W (%b %d)') }
      csv << header
      @users.each do |user|
        row = [user]
        weeks_keys.each do |weeks_keys|
          row << @data[user][weeks_keys]
        end
        csv << row
      end
    end
  end

  def export_durations(path)
    CSV.open(path, 'w') do |csv|
      csv << %w(login week duration)
      @durations.each do |login, timestamp, duration|
        week = timestamp.beginning_of_week
        csv << [
          login,
          week.strftime('%Y.%W (%b %d)'),
          duration / 86400
        ]
      end
    end
  end


  private


  def process_pull_request(pull_request, get_options)
    non_self_comments = 0
    ttl = pull_request.merged_at? ? nil : 1.day

    each_comment(pull_request, get_options) do |comment|
      next if comment.body =~ /Code Climate/
      next if comment.user.login == pull_request.user.login
      give_points(:comment, comment.user.login, comment.created_at)
      non_self_comments += 1
    end

    merger = pull_request.merged_by
    self_merge = (merger && merger.login == pull_request.user.login)

    if (non_self_comments > 0) || !self_merge
      give_points(:pull,  pull_request.user.login, pull_request.created_at) 
    end

    if pull_request.merged_by && !self_merge
      give_points(:merge, pull_request.merged_by.login, pull_request.merged_at)
    end

    if pull_request.merged_at
      record_duration(
        pull_request.created_at.working_time_until(pull_request.merged_at), 
        pull_request.user.login, 
        pull_request.merged_at)
    end
  end


  def give_points(kind, user, timestamp)
    return unless @start_time < timestamp && timestamp < @end_time
    week_key = timestamp.week_key
    @users.add user
    @data[user] ||= {}
    @data[user][week_key] ||= 0
    @data[user][week_key] += POINTS[kind]
  end

  def record_duration(duration, user, timestamp)
    return unless @start_time < timestamp && timestamp < @end_time
    @durations << [user, timestamp, duration]
  end


  def each_comment(pull_request, get_options)
    # comments on PR itself
    uri = pull_request.rels[:comments].href
    @client.request(:get, uri, get_options).each do |comment|
      yield comment
    end

    # comments on diff (unsupported by Octokit)
    uri = "https://api.github.com/repos/#{pull_request.base.repo.full_name}/pulls/#{pull_request.number}/comments"
    @client.request(:get, uri, get_options).each do |comment|
      yield comment
    end
  end


  def each_pull_request(repository)
    [:open, :closed].each do |status|
      page = 1
      while true
        pull_requests = @client.pull_requests(repository.full_name, state: status.to_s, per_page: 20, page: page)
        break if pull_requests.empty?
        break if pull_requests.all? { |pr| pr.created_at < @start_time }
        page += 1

        pull_requests.each do |pull_request|
          # skip unmerged closed PRs
          next if pull_request.closed_at? && !pull_request.merged_at?
          # skip too old PRs
          next if pull_request.created_at < @start_time

          get_options = {}
          if pull_request.merged_at? || pull_request.closed_at?
            # old, cacheable forever
            get_options[:headers] = { 'X-Force-Cache' => '1' }
          end

          begin
            pull_request = @client.request(:get, pull_request.rels[:self].href, get_options)
          rescue Octokit::InternalServerError => e
            $stderr.puts "skipping PR #{pull_request.inspect}"
            next
          end

          yield pull_request, get_options
        end
      end
    end
  end
end
