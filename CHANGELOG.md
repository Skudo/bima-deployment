# Changelog

#### 2.0.5
- add config for deployment.migrate true / false (for Opsworks deployment)

#### 2.0.4
- remove deployment initializer
- fix bug where AWS Opsworks deployment fails
- exit with error, when git reference is invalid

#### 2.0.3
- bugfix for missing `config` files

#### 2.0.2
- bugfix for building packages not cleaning up properly
- bugfix for missing `config/deployment.yml` file
- deployments automagically invoke database migrations

#### 2.0.1
- bugfix for projects without a `config/deployment.yml` file yet

#### 2.0.0
- minimum supported `aws-sdk` version now is 2.4.0 (was: 2.0.0)
- added `deploy` rake tasks
- added Slack notification after successful deployments
- added `bima_deployment:install` generator for Rails

#### 1.1.0
- changed API: `BimaDeployment.included` and `.excluded`

#### 1.0.2, 1.0.3
- bugfix for ignored initializer `deployment.rb`

#### 1.0.1
- bugfix for app with `client/` folder

#### 1.0.0
- initial
