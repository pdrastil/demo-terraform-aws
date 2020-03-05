# Ansible Role: Demo web application

Installs Docker demo web application on RedHat/CentOS servers.

## Requirements

None

## Role Variables

Available variables are listed below, along with default values (see [defaults/main.yml](./defaults/main.yml))

```yml
app_version: master
```

The version of the deployed application.

## Dependencies

None.

## Example Playbook

Including an example of how to use your role (for instance, with variables
passed in as parameters) is always nice for users too:

```yml
- hosts: all
  roles:
    - webapp
```

## License

MIT / BSD

## Author Information

This role was created in 2020 by Petr Drastil.
