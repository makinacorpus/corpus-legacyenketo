 {% set cfg = opts['ms_project'] %}
{% set scfg = salt['mc_utils.json_dump'](cfg)%}
{% set data = cfg.data %}

{% macro mysql() %}mysql --host={{data.db_host}} --port={{data.db_port}} --user={{data.db_user}} --password="{{data.db_password}}" "{{data.db_name}}"{% endmacro %}

{{cfg.name}}-enketo-dump:
  cmd.run:
    - name: {{mysql()}} < {{cfg.project_root}}/.salt/enketo.sql
    - unless: |
              echo 'select * from instances;'| {{mysql()}} &&\
              echo 'select * from languages;'| {{mysql()}} &&\
              echo 'select * from surveys;'| {{mysql()}} &&\
              echo 'select * from sessions;'| {{mysql()}} &&\
              echo 'select * from properties;'| {{mysql()}}
