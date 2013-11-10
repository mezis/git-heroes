# We need to access #request, since #get is borken
# (passes headers in the query string)
class Octokit::Client
  public :request
end
