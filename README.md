# LdapDaemon Gadz.org
[![Build Status](https://travis-ci.org/Zooip/gorg_ldap_daemon.svg?branch=master)](https://travis-ci.org/Zooip/gorg_ldap_daemon)

Receive orders over RabbitMQ to keep LDAP synced with GrAM data
## Setup
After cloning this repository ,install dependencies with `bundle install`

Set the Configuration files `/config/config.yml`, you can use `/config/config.template.yml`as an helper.

## Usage
Just run `/bin/worker` as an executable to start the bot. Logs are printed in STDOUT

To change environment use the environment variable `GORG_LDAP_DAEMON_ENV`. Accepted values are : `development`,`test`,`production`

To stop the bot use CTRL+C or send an interruption signal SINGINT to the process  with `kill -2`

## Behaviour

All received message must be valid with Gadz.org SOA Message Format in order to be processed

This bot subscribes to the following routing keys :
 - `request.ldap.account.update`
 - `request.ldap.account.delete`
 - `request.ldap.group.update`
 - `request.ldap.group.delete`

### `request.ldap.account.update`
Create or update a LDAP account accordingly to data stored in GrAM. This action depends upon GrAM API to retreive data. In case of connection error, it raises a softfail.

It updates :

 - Account informations
 - Account's aliases
 - Account's groups membership :
   - creates group if it doesn't exists
   - registers account in group

Expects to receive the UUID of the GrAM account to synchronize. Here is a valid message data exemple :
```json
{
  "uuid": "a106de25-79ea-41f1-a4d9-38e94b28f8cc"
}
```
### `request.ldap.account.delete`
Delete a LDAP account identified with its UUID.  This action doesn't check GrAM API.

Expects to receive the UUID of the account. Here is a valid message data exemple :
```json
{
  "uuid": "a106de25-79ea-41f1-a4d9-38e94b28f8cc"
}
```
### `request.ldap.group.update`
Create or update a LDAP group accordingly to data provided in the message. This action doesn't check GrAM API.

Expects to receive the CN (`short_name` in GrAM API) and the UUID of the group. You may provide a list of members identified with their UUID. If a member's UUID is not found in LDAP, message is discard and a HardFail is raised.

Here is a valid message data exemple :

```json
{
    "cn": "my_awesome_groupe",
  "uuid": "a106de25-79ea-41f1-a4d9-38e94b28f8cc",
  "members":
      [
           "f28997fa-5411-4940-a055-83ad4f2b75df",
           "d9402daa-bb24-4288-9080-7b9b90226e7e",
           "9d872812-2754-46c1-8ca7-775602eebc86"
      ]
}
```

### `request.ldap.group.delete`
Delete a LDAP group identified woth its `cn` . This action doesn't check GrAM API.

Expects to receive the CN (`short_name` in GrAM API)  of the group. Here is a valid message data exemple :

```json
{
    "cn": "my_awesome_groupe",
}
```

## ToDo
 - Better daemonization mechanism
 - Message payload validation
 - Provide ways to choose log destination (STDOUT or file)
 - Set UUID in LDAP Groups
 - Identify LDAP Groups with UUID and not CN