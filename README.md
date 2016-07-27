# bima-deployment
BImA deployment rake task


### Installation

Add the following lines to your Gemfile

```ruby
group :development do
  gem 'bima-deployment', git: 'https://github.com/jdahlke/bima-deployment.git', branch: 'master'
end
```

### Usage

1. Commit **all** changes you want to deploy. You do not have to push your
   changes to Github.
1. Run `bundle exec rake package[TAG_OR_BRANCH_NAME]` to package your code into a tarball
   archive on S3. Depending on your connection it may take up to 5
   minutes.
1. Copy the URL from the last line of the output.
1. Open AWS OpsWorks and open the application you want to deploy.
1. Paste the new URL into S3 archive URL field.
1. Click deploy.

