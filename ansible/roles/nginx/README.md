# Ansible Role: Nginx

**Note:** Please consider using the official [NGINX Ansible role](https://github.com/nginxinc/ansible-role-nginx) from NGINX, Inc.

Installs Nginx on RedHat/CentOS or Debian/Ubuntu servers.

This role installs and configures the latest version of Nginx from the Nginx yum repository (on RedHat-based systems) or apt (on Debian-based systems). You will likely need to do extra setup work after this role has installed Nginx, like adding your own [virtualhost].conf file inside `/etc/nginx/conf.d/`, describing the location and options to use for your particular website.

## Requirements

None.

## Role Variables

Available variables are listed below, along with default values (see `defaults/main.yml`):

```yml
nginx_vhosts: []
```

A list of vhost definitions (server blocks) for Nginx virtual hosts. Each entry will create a separate config file named by `server_name`. If left empty, you will need to supply your own virtual host configuration. See the commented example in `defaults/main.yml` for available server options. If you have a large number of customizations required for your server definition(s), you're likely better off managing the vhost configuration file yourself, leaving this variable set to `[]`.

```yml
nginx_vhosts:
- listen: "443 ssl http2"
  server_name: example.com
  server_redirect_name: www.example.com
  root: /var/www/example.com
  filename: example.com.conf
  state: present
  extra_parameters: |
    location ~ \.php$ {
        fastcgi_split_path_info ^(.+\.php)(/.+)$;
        fastcgi_pass unix:/var/run/php5-fpm.sock;
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        include fastcgi_params;
    }
    ssl_certificate     /etc/ssl/certs/ssl-cert-snakeoil.pem;
    ssl_certificate_key /etc/ssl/private/ssl-cert-snakeoil.key;
    ssl_protocols       TLSv1.1 TLSv1.2;
    ssl_ciphers         HIGH:!aNULL:!MD5;
```

An example of a fully-populated nginx_vhosts entry, using a `|` to declare a block of syntax for the `extra_parameters`.

Please take note of the indentation in the above block. The first line should be a normal 2-space indent. All other lines should be indented normally relative to that line. In the generated file, the entire block will be 4-space indented. This style will ensure the config file is indented correctly.

```yml
- listen: 80
  server_name: "example.com www.example.com"
  return: "301 https://example.com$request_uri"
  filename: example.com.80.conf
```

An example of a secondary vhost which will redirect to the one shown above.

*Note: The `filename` defaults to the first domain in `server_name`, if you have two vhosts with the same domain, eg. a redirect, you need to manually set the `filename` so the second one doesn't override the first one*

```yml
nginx_remove_default_vhost: false
```

Whether to remove the 'default' virtualhost configuration supplied by Nginx. Useful if you want the base `/` URL to be directed at one of your own virtual hosts configured in a separate .conf file.

```yml
nginx_upstreams: []
```

If you are configuring Nginx as a load balancer, you can define one or more upstream sets using this variable. In addition to defining at least one upstream, you would need to configure one of your server blocks to proxy requests through the defined upstream (e.g. `proxy_pass http://myapp1;`). See the commented example in `defaults/main.yml` for more information.

```yml
nginx_user: nginx
```

The user under which Nginx will run. Defaults to `nginx` for RedHat and `www-data` for Debian.

```yml
nginx_worker_processes: "{{ ansible_processor_vcpus | default(ansible_processor_count) }}"
nginx_worker_connections: "1024"
nginx_multi_accept: "off"
```

`nginx_worker_processes` should be set to the number of cores present on your machine (if the default is incorrect, find this number with `grep processor /proc/cpuinfo | wc -l`). `nginx_worker_connections` is the number of connections per process. Set this higher to handle more simultaneous connections (and remember that a connection will be used for as long as the keepalive timeout duration for every client!). You can set `nginx_multi_accept` to `on` if you want Nginx to accept all connections immediately.

```yml
nginx_error_log: "/var/log/nginx/error.log warn"
nginx_access_log: "/var/log/nginx/access.log main buffer=16k"
```

Configuration of the default error and access logs. Set to `off` to disable a log entirely.

```yml
nginx_sendfile: "on"
nginx_tcp_nopush: "on"
nginx_tcp_nodelay: "on"
```

TCP connection options. See [this blog post](https://t37.net/nginx-optimization-understanding-sendfile-tcp_nodelay-and-tcp_nopush.html) for more information on these directives.

```yml
nginx_keepalive_timeout: "65"
nginx_keepalive_requests: "100"
```

Nginx keepalive settings. Timeout should be set higher (10s+) if you have more polling-style traffic (AJAX-powered sites especially), or lower (<10s) if you have a site where most users visit a few pages and don't send any further requests.

```yml
nginx_server_tokens: "on"
```

Nginx server_tokens settings. Controls whether nginx responds with it's version in HTTP headers. Set to `"off"` to disable.

```yml
nginx_client_max_body_size: "64m"
```

This value determines the largest file upload possible, as uploads are passed through Nginx before hitting a backend like `php-fpm`. If you get an error like `client intended to send too large body`, it means this value is set too low.

```yml
nginx_server_names_hash_bucket_size: "64"
```

If you have many server names, or have very long server names, you might get an Nginx error on startup requiring this value to be increased.

```yml
nginx_proxy_cache_path: ""
```

Set as the `proxy_cache_path` directive in the `nginx.conf` file. By default, this will not be configured (if left as an empty string), but if you wish to use Nginx as a reverse proxy, you can set this to a valid value (e.g. `"/var/cache/nginx keys_zone=cache:32m"`) to use Nginx's cache (further proxy configuration can be done in individual server configurations).

```yml
nginx_extra_http_options: ""
```

Extra lines to be inserted in the top-level `http` block in `nginx.conf`. The value should be defined literally (as you would insert it directly in the `nginx.conf`, adhering to the Nginx configuration syntax - such as `;` for line termination, etc.), for example:

```yml
nginx_extra_http_options: |
    proxy_buffering    off;
    proxy_set_header   X-Real-IP $remote_addr;
    proxy_set_header   X-Scheme $scheme;
    proxy_set_header   X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header   Host $http_host;
```

See the template in `templates/nginx.conf.j2` for more details on the placement.

```yml
nginx_extra_conf_options: ""
```

Extra lines to be inserted in the top of `nginx.conf`. The value should be defined literally (as you would insert it directly in the `nginx.conf`, adhering to the Nginx configuration syntax - such as `;` for line termination, etc.), for example:

```yml
nginx_extra_conf_options: |
    worker_rlimit_nofile 8192;
```

See the template in `templates/nginx.conf.j2` for more details on the placement.

```yml
nginx_log_format: |-
    '$remote_addr - $remote_user [$time_local] "$request" '
    '$status $body_bytes_sent "$http_referer" '
    '"$http_user_agent" "$http_x_forwarded_for"'
```

Configures Nginx's [`log_format`](http://nginx.org/en/docs/http/ngx_http_log_module.html#log_format). options.

## Dependencies

None.

## Example Playbook

```yml
- hosts: server
    roles:
    - nginx
```

## License

MIT / BSD

## Author Information

This role was created in 2014 by [Jeff Geerling](https://www.jeffgeerling.com/), author of [Ansible for DevOps](https://www.ansiblefordevops.com/).

The role was modified for demo purposes in 2020 by Petr Drastil.
