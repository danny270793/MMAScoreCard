# MMAScoreCard

## Configure ssh

Generate a new key replacing `<email@example.com>` with your email

```bash
ssh-keygen -t ed25519 -C "<email@example.com>"
```

Then, add the following lines to file `~/.ssh/config`, replacing `<path to your key>` with the path to the key previously generated

```
Host github.com
  AddKeysToAgent yes
  UseKeychain yes
  IdentityFile <path to your key>
```
