Using Ansible to render the templates. Very crude example, could do with some polish, but resolves the issues with Kustomize without needing Helm.

```
ansible-playbook -i inventory.yml render.yml
```
