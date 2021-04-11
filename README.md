### Import GPG keys for SOPS

```
ssh -i keys/satan root@barbossa "cat /etc/ssh/ssh_host_rsa_key" | ssh-to-pgp -private-key | gpg --import --quiet
ssh-to-pgp -private-key -i ./keys/satan | gpg --import --quiet
```
