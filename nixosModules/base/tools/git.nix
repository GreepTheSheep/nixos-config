{ config, lib, ... }:

{
  options.nixos = {
    base.tools.git = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        example = true;
        description = "Enable Git.";
      };
    };
  };

  config = lib.mkIf config.nixos.base.tools.git.enable {
    programs.git = {
      enable = true;

      config = {
        init.defaultBranch = "main";

        alias = {
          c = "commit";
          ca = "commit -a";
          caa = "commit -a --amend";

          ch = "checkout";
          chb = "checkout -b";
          chpr = "!sh -c 'git fetch origin pull/$1/head:pr/$1 && git checkout pr/$1' -";

          r = "rebase";
          rc = "rebase --continue";
          ri = "rebase -i";

          a = "add";
          b = "branch";
          d = "diff";
          dc = "diff --cached";
          s = "status";

          st = "stash";
          stp = "stash pop";

          p = "push";
          pu = "pull";

          f = "fetch";

          uu = "!git fetch upstream && git rebase upstream/$(git branch --quiet | grep '*' | cut -c 3-)";

          l = "log --pretty=oneline --abbrev-commit --graph";
        };

        pull.ff = "only"; # Only allow fast-forward merges
        merge = {
          ff = false;
          conflictStyle = "zdiff3";
        };
        push = {
          autoSetupRemote = true;
          followTags = true;
        };
        fetch = {
          prune = true;
          pruneTags = true;
          all = true;
        };
        rerere = {
          enabled = true;
          autoupdate = true;
        };
        commit.gpgSign = true;
        tag = {
          gpgSign = true;
          sort = "version:refname";
        };
        diff = {
          algorithm = "histogram";
          colorMoved = "plain";
          renames = true;
          mnemonicPrefix = true;
        };
        branch.sort = "-committerdate";
        column.ui = "auto";
        credential.helper = "store";
      };

      lfs.enable = true;
    };
  };
}