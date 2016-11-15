# bima-deployment

BImA deployment rake task


### Installation

Add this to your Gemfile:

```ruby
group :development, :test do
  gem 'bima-deployment', git: 'https://github.com/jdahlke/bima-deployment.git', tag: '2.0.3'
end
```

### Rails generator `bima_deployment:install`

By invoking

```sh
$ bundle exec rails g bima_deployment:install NAME
```

you generate a `config/deployment.yml` file via the Rails generator process.

#### Mandatory arguments

`NAME` is used for OpsWorks stack and app names in different ways:

* Stack names will be `NAME (Staging)` for development and staging environments,
  `NAME (Production)` for the production environment.
* App names will be `name_develop` and `name_staging` for development and staging
  environments respectively, `name` for the production environment.

#### Options

* `--notification` can be either `true` or `false` to specify whether you want
   to be notified after a successful deployment to production environments.
   Default: `true`.
* `--slack` provides the URI to your Slack Incoming WebHook.
* `--strategy` should be either `opsworks/git` or `opsworks/s3` to specify your
  deployment strategy. Default: `opsworks/s3`.

#### Example

```sh
$ bundle exec rails g bima_deployment:install MyApp \
        --slack=https://hooks.slack.com/services/URI/to/my/webhook \
        --strategy=opsworks/git
```


### Usage

1. Run `bundle exec rake deploy[TAG_OR_BRANCH_NAME]` to deploy your code to AWS.
   As the `opsworks/s3` strategy requires uploading a sizable file to S3 first,
   this process can take a while.
1. Get a cup of tea (or coffee) and watch your code being deployed to AWS for you.


### Rake tasks

**Note:** Credentials for AWS related operations are automagically loaded from `~/.aws/credentials`.
The rake taks will try to read credentials from a profile `[bima]`. If it fails, it will fallback to `[default]`.

#### `deploy[git_ref]`

Invokes `deploy:development[git_ref]`.

**Note:** If git_tag is not provided, this will deploy the currently checked out revision (HEAD), not master.

#### `deploy:development[git_ref]`

Deploys `git_ref` of your repository to your AWS OpsWorks development stack.

#### `deploy:production[git_ref]`

Deploys `git_ref` of your repository to your AWS OpsWorks production stack.

#### `deploy:staging[git_ref]`

Deploys `git_ref` of your repository to your AWS OpsWorks staging stack.

#### `package[git_ref]`

Creates a working copy of `git_ref` of your repository in `tmp/package` and
packs it into a `.tbz2` file in `tmp/releases`. Uploads the release file for `git_ref` to S3.
Cleans up the `tmp/package` and `tmp/releases` folders.


