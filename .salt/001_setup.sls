{% set cfg = opts['ms_project'] %}
{% set scfg = salt['mc_utils.json_dump'](cfg)%}
{% set php = salt['mc_php.settings']() %}
{% set data = cfg.data %}
{% set pma_ver=data.pma_ver %}

{% set rpw = salt['mc_mysql.settings']().root_passwd %}

prepreqs-{{cfg.name}}:
  pkg.installed:
    - pkgs:
      - unzip
      - xsltproc
      - curl
      - {{ php.packages.mysql }}
      - {{ php.packages.gd }}
      - {{ php.packages.cli }}
      - {{ php.packages.curl }}
      - {{ php.packages.ldap }}
      - {{ php.packages.dev }}
      - {{ php.packages.json }}
      - sqlite3
      - libsqlite3-dev
      - mysql-client
      - apache2-utils
      - autoconf
      - php5-xsl
      - automake
      - build-essential
      - bzip2
      - gettext
      - git
      - groff
      - libbz2-dev
      - libcurl4-openssl-dev
      - libdb-dev
      - libgdbm-dev
      - libreadline-dev
      - libfreetype6-dev
      - libsigc++-2.0-dev
      - libsqlite0-dev
      - libsqlite3-dev
      - libtiff5
      - libtiff5-dev
      - libwebp5
      - libwebp-dev
      - libssl-dev
      - libtool
      - libxml2-dev
      - libxslt1-dev
      - libopenjpeg-dev
      - libopenjpeg2
      - m4
      - man-db
      - pkg-config
      - poppler-utils
      - python-dev
      - python-imaging
      - python-setuptools
      - zlib1g-dev
{{cfg.name}}-short_open_tag:
  file.managed:
    - names: 
      - /etc/php5/cli/conf.d/00_short_open_tag.ini
      - /etc/php5/fpm/conf.d/00_short_open_tag.ini
    - makedirs: true
    - contents: |
                [PHP]
                short_open_tag = On
    - user: www-data
    - group: www-data
    - mode: 775

{{cfg.name}}-htaccess:
  file.managed:
    - name: {{data.htaccess}}
    - source: ''
    - user: www-data
    - group: www-data
    - mode: 770

{% if data.get('http_users', {}) %}
{% for userrow in data.http_users %}
{% for user, passwd in userrow.items() %}
{{cfg.name}}-{{user}}-htaccess:
  webutil.user_exists:
    - name: {{user}}
    - password: {{passwd}}
    - htpasswd_file: {{data.htaccess}}
    - options: m
    - force: true
    - watch:
      - file: {{cfg.name}}-htaccess
{% endfor %}
{% endfor %}
{% endif %}  

{{cfg.name}}-dirs:
  file.directory:
    - makedirs: true
    - user: {{cfg.user}}
    - group: {{cfg.group}}
    - mode: 770
    - watch:
      - pkg: prepreqs-{{cfg.name}}
    - names:
      - {{cfg.project_root}}/lib
      - {{cfg.project_root}}/bin
      - {{cfg.data_root}}/var
      - {{cfg.data_root}}/var/log
      - {{cfg.data_root}}/var/tmp
      - {{cfg.data_root}}/var/run
      - {{cfg.data_root}}/var/private


{% for d in ['lib', 'bin'] %}
{{cfg.name}}-dirs{{d}}:
  file.symlink:
    - target: {{cfg.project_root}}/{{d}}
    - name: {{cfg.data_root}}/{{d}}
    - user: {{cfg.user}}
    - group: {{cfg.group}}
    - watch:
      - file: {{cfg.name}}-dirs
{% endfor %}

{% for d in ['var'] %}
{{cfg.name}}-l-dirs{{d}}:
  file.symlink:
    - name: {{cfg.project_root}}/{{d}}
    - target: {{cfg.data_root}}/{{d}}
    - user: {{cfg.user}}
    - group: {{cfg.group}}
    - watch:
      - file: {{cfg.name}}-dirs
{% endfor %}

{% for d in ['log', 'private', 'tmp'] %}
{{cfg.name}}-l-var-dirs{{d}}:
  file.symlink:
    - name: {{cfg.project_root}}/{{d}}
    - target: {{cfg.data_root}}/var/{{d}}
    - user: {{cfg.user}}
    - group: {{cfg.group}}
    - watch:
      - file: {{cfg.name}}-dirs
{% endfor %}

enketogit:
  mc_git.latest:
    - name: https://github.com/makinacorpus/enketo.git
    - rev: master
    - target: {{cfg.data_root}}/enketo
    - user: {{cfg.user}}

{% for i in data.get('configs', []) %}
config-{{i}}:
  file.managed:
    - source: salt://makina-projects/{{cfg.name}}/files/{{i}}
    - name: {{cfg.data_root}}/enketo/{{i}}
    - template: jinja
    - mode: 750
    - user: {{cfg.user}}
    - group: {{cfg.group}}
    - defaults:
        cfg: |
             {{scfg}}
    - require:
      - mc_git: enketogit
{% endfor %}

enketogitss:
  file.symlink:
    - target: {{cfg.project_root}}/var
    - name: {{cfg.data_root}}/enketo/var
    - require:
      - mc_git: enketogit
enketogits:
  file.symlink:
    - names: 
      - {{cfg.project_root}}/www
      - {{cfg.data_root}}/www
    - target: {{cfg.data_root}}/enketo/public
    - require:
      - mc_git: enketogit

enketo-{{cfg.name}}-dirs:
  file.directory:
    - require:
       - mc_git: enketogit
    - names:
       - {{cfg.data_root}}/enketo/Code_Igniter/application/logs
       - {{cfg.data_root}}/enketo/Code_Igniter/application/cache
    - user: {{cfg.user}}
    - group: {{cfg.group}}
    - mode: 770

{{cfg.name}}-rungit-submodules:
  cmd.run:
    - name: git submodule update --init --recursive
    - cwd: {{cfg.data_root}}/enketo
    - watch:
      - mc_git: enketogit
    - user: {{cfg.user}}
    - use_vt: true

{% macro mysql() %}mysql --host={{data.db_host}} --port={{data.db_port}} --user={{data.db_user}} --password="{{data.db_password}}" "{{data.db_name}}"{% endmacro %}

{{cfg.name}}-enketo-dump:
  cmd.run:
    - name: {{mysql()}} < {{cfg.project_root}}/.salt/enketo.sql
    - unless: |
              echo 'select * from instances;'| {{mysql()}} &&\
              echo 'select * from languages;'| {{mysql()}} &&\
              echo 'select * from surveys;'| {{mysql()}} &&\
              echo 'select * from sessions;'| {{mysql()}} &&\
              echo 'select * from properties;'| {{mysql()}} &&\
    - watch:
      - cmd: {{cfg.name}}-rungit-submodules

