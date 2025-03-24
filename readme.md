# MMAScoreCard

## Configure git project

Configure current git project with your name `<Your name>` and your email `<Your email>`

```bash
git config user.name "<Your name>"
git config user.email "<Your email>"
```

Check the configuration you already set

```bash
git config user.name
git config user.email
```

And notice how different are from global configurations

```bash
git config --global user.name
git config --global user.email
```

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
