{%- from 'nvm/map.jinja' import nvm with context -%}
{%- set install_path = salt['pillar.get']('nvm:install_path', '/usr/local/nvm') -%}

nvm_packages:
  pkg.installed:
    - names:
      - {{ nvm.gcc }}
      - {{ nvm.c_p_p }}
      - {{ nvm.build }}
      - {{ nvm.libssl }}

## Get NVM
https://github.com/creationix/nvm.git:
  git.latest:
    - rev: master
    - target: {{ install_path }}
    - require:
      - pkg: nvm_packages
    # - force: True

nvm_profile:
  file.blockreplace:
    - name: /etc/profile
    - marker_start: "#> Saltstack Managed Configuration START <#"
    - marker_end: "#> Saltstack Managed Configuration END <#"
    - append_if_not_found: true
    - content: |
        if [ -f "{{ install_path }}/nvm.sh" ]; then
          source {{ install_path }}/nvm.sh
        fi

{% if salt['pillar.get']('nvm:node_version') %}
{% set node_version = salt['pillar.get']('nvm:node_version') %}

nvm_install_node:
  cmd.run:
    - name: nvm install {{ node_version }}; nvm alias default {{ node_version }}
    - unless: if [ "$(nvm current)" == "{{ node_version }}" ]; then echo true; fi;

{% endif %}
