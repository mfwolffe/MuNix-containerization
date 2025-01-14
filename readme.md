# MuNix w. Flake Setup Notes
### (for posterity of course | @mfwolffe on gh)

**what the hell is MuNix??**
It's nothing, lol. It's what I'm calling my MusicCPR containerization efforts to save on i) syllables, and ii) keystrokes.
**Why these "efforts"?**
Just my excuse to tinker at a deeper level w/ nix honestly. 


This approach, contrary to the others explored, actually uses Docker (!?). This may seem counterintuitive given that Docker perf on codespaces was not acceptable. The benefits of this approach over the pure nix solutions are theoretically:
  1. Total isolation to guard against edge failues from things like host OS, architecture, sys libraries, etc. (AFAIK it is not possible to have a single conf for machines w/ diff underlying architectures)
  1. Nix eliminates nondetermism potentially introduced from docker image build
  1. Base image is debian-slim; I'm not sure what Dr. Stewart used in his exploration of codespaces/how it compares to this image, but there's improvement there potentially.
  1. Not sure how likely, but someone may already use Nix in a way that is incompatible with how I approach the pure-nix solutions (I'm not a nix expert, so idk!)


## Notes
  * I did not realize most of the docker image stuff was handled honestly. I spent some time getting a dockerfile configured that did way too much; check out the current one to see how simple. 

  * I did not realize I'd need to use compose due to how we run the backend, but I want to get a successful spinup from just the flake first, so that is the current goal.

  * Linter got upset by `devcontainer.json` structure; needed to update. see Errors below.

##### Experimental Features (**TODO**)
To use flakes you have to enable it in conf.nix (or is it nix.conf?, it's been a minute), and I'm not sure yet if I will need to have to add instructions to dockerfile to get that configuration file made etc.

##### Finding Flake Hashes
  1. Head to the [nixpkgs gh repo](https://github.com/NixOS/nixpkgs)
  1. search for the commit with `<pkgname> <version>`, e.g., for Python 3.12.3 I would search: `python312 3.12.3`
  1. You want the direct (**not** merge) commit, of the **update commit**, *which will maybe probably have a message like:*
    * `python312: 3.12.2 -> 3.12.3` 
  1. copy the commit hash, then grab the sha256 from the diff to `../default.nix` and pop them into your flake

**TODO** I'd like to see if the `nix-search` (`nix-search-cli` on the AUR) is any use in speeding this process up, 

### Errors

Build in container failed, 
```bash
...
[2025-01-14T04:59:03.738Z] Command failed: /opt/visual-studio-code/code /home/mfwolffe/.vscode/extensions/ms-vscode-remote.remote-containers-0.394.0/dist/spec-node/devContainersSpecCLI.js up --user-data-folder /home/mfwolffe/.config/Code/User/globalStorage/ms-vscode-remote.remote-containers/data --container-session-data-folder /tmp/devcontainers-d4863c06-72ea-4dde-8138-f3bba8be4ec11736830740892 --workspace-folder /home/mfwolffe/Documents/MuNix --workspace-mount-consistency cached --gpu-availability detect --id-label devcontainer.local_folder=/home/mfwolffe/Documents/MuNix --id-label devcontainer.config_file=/home/mfwolffe/Documents/MuNix/.devcontainer/devcontainer.json --log-level debug --log-format json --config /home/mfwolffe/Documents/MuNix/.devcontainer/devcontainer.json --default-user-env-probe loginInteractiveShell --mount type=volume,source=vscode,target=/vscode,external=true --skip-post-create --update-remote-user-uid-default on --mount-workspace-git-root --include-configuration --include-merged-configuration
[2025-01-14T04:59:03.738Z] Exit code 1
...
```
I again, rather foolishly have decided to write a configuration file from scratch (this time `devcontainer.json`) instead of extending the example in the repo.

See 39abd4d for the changes.



#### VSCode thinks I'm not in `docker` group
iirc vscode should not be ran as root so that is not the fix.

I am definitely in the `docker` group, as confirmed by all of the following:

```bash
lslogins mfwolffe
groups mfwolffe
cat /etc/group | grep docker # losing my mind lol
```

It may be how I was launching (w/ `rofi` - usually I launch from shell)?

##### Resolved by launching vscode from shell
(requires code command in path)

#### Legacy builder
On building docker image I got:

(I have never had to configure docker images myself so, spare me. This was from old, more complex Dockerfile)

```bash
DEPRECATED: The legacy builder is deprecated and will be removed in a future release.
            Install the buildx component to build images with BuildKit:
            https://docs.docker.com/go/buildx/

Sending build context to Docker daemon  3.072kB
Step 1/8 : FROM debian:slim
manifest for debian:slim not found: manifest unknown: manifest unknown
```

Given that buildkit env var needs to be set I put it in a build script. Running the build script still had many errors, ultimately reduced to:

```bash
ERROR: BuildKit is enabled but the buildx component is missing or broken.
       Install the buildx component to build images with BuildKit:
       https://docs.docker.com/go/buildx/
```

I forgot to install the buildx plugin:
`paru docker-buildx` (or w/ever pkg mngr)

### `devcontainer.json` structure
extensions property has to be nested in customizations / vscode / extensions /

*old:*
```json
...
"extensions": [
  "ms-python.python",
  "ms-vscode-remote.remote-containers",
  "arrterian.nix-env-selector"
],
"settings": {
  "nixEnvSelector.nixFile": "${workspaceRoot}/flake.nix"
},
...

```

*corrected:*
```json
...
  "customizations": {
    "vscode": {
      "extensions": [
        "ms-python.python",
        "ms-vscode-remote.remote-containers",
        "arrterian.nix-env-selector"
      ],
      "settings": {
        "nixEnvSelector.nixFile": "${workspaceRoot}/flake.nix"
      },
    }
  },
...
```


