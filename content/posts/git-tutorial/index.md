---
title: "Git Tutorial"
date: 2023-01-02T13:44:40Z
draft: false

weight: 1
# aliases: ["/first"]
tags: ["git", "version control"]
author: "DarrenK"
# author: ["Me", "You"] # multiple authors
showToc: true
TocOpen: false

hidemeta: false
comments: false
description: "Tutorial on git setup and basic usage."
canonicalURL: "https://canonical.url/to/page"
disableHLJS: true # to disable highlightjs
disableShare: false
disableHLJS: false
hideSummary: false
searchHidden: true
ShowReadingTime: true
ShowBreadCrumbs: true
ShowPostNavLinks: true
ShowWordCount: true
ShowRssButtonInSectionTermList: true
UseHugoToc: true
cover:
    image: "" # image path/url
    alt: "git" # alt text
    caption: "<text>" # display caption under cover
    relative: false # when using page bundles set this to true
    hidden: true # only hide on current single page
editPost:
    URL: "https://github.com/<path_to_repo>/content"
    Text: "Suggest Changes" # edit text
    appendFilePath: true # to append file path to Edit link
---

# Git
![git](git-tutorial/git-logo.svg)

## What is Git?

Git is a version control system that allows you to keep track of the changes you make to files and helps you collaborate with others on projects. Here is a basic tutorial on how to install and use Git.

___
# Installation
## Mac OS installation

> Personal tip: if you are running Mac OS then use Homebrew to manage your packages. It will do most of the hard work for you when it comes to package management for Mac OS.

### Install with Homebrew (Mac OS)
You can install Git using the Homebrew package manager. To do this, you need to have Homebrew installed on your system. If you don't have Homebrew, you can install it by following the instructions on the Homebrew website (https://brew.sh/).

Once you have Homebrew installed, you can install Git by running the following command in your terminal:

```
brew install git
```

This will download and install the latest version of Git, and you should be ready to start using it.

### Install without a package manager
You can install Git on your Mac by downloading the latest version from the official Git website (https://git-scm.com/download/mac) and following the installation instructions.

___
## Windows installation

> Personal tip: if you are running Windows OS then use Chocolatey to manage your packages. It will do most of the hard work for you when it comes to package management for Windows OS.

### With Chocolatey (Windows)
You can install Git using the Chocolatey package manager. To do this, you need to have Chocolatey installed on your system. If you don't have Chocolatey, you can install it by following the instructions on the Chocolatey website (https://chocolatey.org/install).

Once you have Chocolatey installed, you can install Git by running the following command in your command prompt:

```
choco install git
```

This will download and install the latest version of Git, and you should be ready to start using it.

### Install without a package manager
You can install Git on your Mac by downloading the latest version from the official Git website (https://git-scm.com/download/windows) and following the installation instructions.
___
## Create a new git repository

Create a new repository (project) in Git. You can do this by navigating to the directory where you want to store your project and running the git init command. 
```
git init
```
This will create a new subdirectory called ".git" which will store all the necessary files for your repository.
___
### Add some project files

While in the same directory create two files called:   
- `index.html`
- `about.html`

Open `index.html` with your preferred code editor and enter the following code:
```
<!DOCTYPE html>
<html>
  <body>
    <h1>Index.html</h1>
  </body>
</html>
```

Open `about.html` with your preferred code editor and enter the following code:
```
<!DOCTYPE html>
<html>
  <body>
    <h1>About.html</h1>
  </body>
</html>
```

Now we have a couple of files we can use in our tutorial on git.

___
# Set your default code editor for git

Next we'll configure our default code editor for git, this will be useful when running the `git commit` command in the next section.   
> *Technically were configuring the `git core.editor` globally*


Enter the following command into terminal:
## Visual Studio Code
```
git config --global core.editor "code --wait"
```
- *Note that you need to include the `--wait` flag so that Git waits for the editor to close before returning*

## Sublime Text
```
git config --global core.editor "subl -n -w"
```
- *Note that you need to include the -n flag to open a new window and the -w flag to wait for the file to be closed before returning.*

## Atom
```
git config --global core.editor atom
```
- *Note that we don't require any type of "wait" flag for atom.*

Now when you enter the command `git commit` later in this tutorial it will automatically open your configured code editor to enter the commit message / details. *Remember there are other code editors you can use, I've just outlined the most popular GUI editors. If you want other editors then just perform a quick google search and you should find the correct details on how set them as the git `core.editor`*

___
# Add files to your git repository. 

You can do this by using the git add command followed by the name of the file you want to add. For example, `git add index.html` will add the file "index.html" to your repository. You can also use the `git add .` command to add all the files in your current directory and its subdirectories to your repository - this isn't good practice though, as you should try to keep your commits small and on topic (ie related commits - don't change an api function and the css color of the ui in the same commit as they are unrelated - make separate commits).   

Lets add the index.html file to our git repository (remember we're entering this command while in the same directory):
```
git add index.html
```

## Check if files are staged in the git repository

To check if we have staged the file into our git repo, we can run the following command:
```
git status
```

...git will output the current status of the repo (*repo is short for repository*) and if done correctly then you should see two sections   
- `Changes to be committed`
- `Untracked files`
![git-status](git-tutorial/git-status.svg)

This show that we have added the `index.html` file to be tracked by git and the `about.html` is currently untracked (meaning nothing will happen to that file throughout the git process).

Now we are ready to commit the staged `index.html` file to the git repository. Enter the following command:
```
git commit
```

This will open your configure `git core.editor` and ask you to enter the commit message for your changes.

In the opened file enter the "title" of the commit on the first line (line #1 of screen-shot).   
Make sure you then leave a blank line and enter a short description about the commit below, something like this (line #3 on screen-shot):
![git-status](git-tutorial/git-commit-message.svg)

## Check the commit has worked

To check if our `git commit` has worked we can use the following command:
```
git log
```

This will output the `git log` for the commits we have performed, the output should read something like this:
```
commit ebdbb50a8e72f74390928d198a9b0103ec566adf (HEAD -> master)
Author: DarrenK_dev <#################################>
Date:   Mon Jan 2 20:20:16 2023 +0000

    Initial commit of index.html
    
    The file contains only HTML boilerplate code.
``` 

We can also run the `git status` command again:
![git-status](git-tutorial/untracked-only.svg)

...as you can see the `index.html` file does not appear.

You can repeat the process for the `about.html` file to practice. Once you've committed it then continue to the next step.


# Branches

Git branches are an essential feature of the Git version control system. They allow you to work on multiple versions of a repository at the same time, without affecting the main development branch. In this part of the tutorial, we will learn how to create, switch, and merge branches in Git.   
By default when you create a git repository you'll start with a `master` branch only.

## Creating a branch

To create a new branch in Git, you can use the git branch command. For example, to create a new branch called feature, you can use the following command:
```
git branch feature
```

This will create a new branch called `feature`, but it will not switch to it. To switch to the new branch, you can use the git checkout command. For example:
```
git checkout feature
```

Alternatively, you can create and switch to a new branch in a single command using the git checkout -b option. For example:
```
git checkout -b feature
```

This will create a new branch called feature and switch to it.

## Switching Between Branches

To switch between branches in Git, you can use the `git checkout` command. For example, to switch from the `feature` branch to the `master` branch, you can use the following command:
```
git checkout master
```

This will switch to the `master` branch, and you will see the changes in your working directory reflect the changes in the `master` branch.

## Merging Branches

To merge one branch into another in Git, you can use the `git merge` command. For example, to merge the `feature` branch into the `master` branch, you can use the following command:
```
git checkout master
git merge feature
```

This will merge the `feature` branch into the `master` branch, and you will see the changes from the `feature` branch reflected in the `master` branch.

## Deleting a Branch

To delete a branch in Git, you can use the `git branch -d` command. For example, to delete the `feature` branch, you can use the following command:
```
git branch -d feature
```

This will delete the `feature` branch, but it will **not delete the commits associated with the branch**.   
If you want to delete the commits associated with the branch, you can use the git branch -D command instead. For example:
```
git branch -D feature
```

This will delete the feature branch and all of the commits associated with it. **Be careful when using this command, as it cannot be undone.**

# Git Merge Conflicts
Git merge conflicts can occur when you try to merge two branches that have conflicting changes. When this happens, Git will not be able to automatically merge the branches, and you will need to resolve the conflicts manually. In this part of the tutorial, we will learn how to resolve merge conflicts in Git.

## Detecting Merge Conflicts
To detect merge conflicts in Git, you can use the `git merge` command. For example, suppose you have made changes to the `feature` branch and the `master` branch, and you want to merge the `feature` branch into the `master` branch. You can use the following command to do this:
```
git checkout master
git merge feature
```

If there are no conflicts between the two branches, Git will automatically merge the changes and create a new commit. However, if there are conflicting changes, Git will not be able to merge the branches automatically, and you will see a message like this:
```
Auto-merging index.html
CONFLICT (content): Merge conflict in index.html
Automatic merge failed; fix conflicts and then commit the result.
```

This message indicates that a merge conflict has occurred, and you will need to resolve the conflict **manually**.

## Resolving Merge Conflicts
To resolve merge conflicts in Git, you will need to edit the files that contain the conflicting changes and choose which changes to keep manually. When you open a file with a merge conflict, you will see something like this:
```
<<<<<<< HEAD
<h1>Index Page<h1>
=======
<h1>Home Page<h1>
>>>>>>> feature
```

The lines between <<<<<<< and ======= indicate the conflicting changes on the master branch, and the lines between ======= and >>>>>>> indicate the conflicting changes on the feature branch. As you can see the `<h1></h1>` tag has been changed on both branches to different values - this has created the merge conflict.

To resolve the conflict, you will need to edit the file and remove the conflict markers and choose which changes to keep. For example, you might edit the file like this:
```
<h1>Home Page<h1>
```

So we manually deleted the other code and left `<h1>Home Page</h1>`.

Once you have resolved the conflict, you can mark it as resolved using the git add command. For example:
```
git add index.html
```

This will stage the file and mark the conflict as resolved.

## Finishing the Merge
Once you have resolved all of the merge conflicts, you can finish the merge by committing the changes. To do this, use the `git commit` command. For example:
```
git commit -m "Resolved merge conflicts"
```

In this commit I have entered the commit message with the command using the `-m` flag. This will add the commit message without opening our `core.editor` to input the commit message.

# Avoiding Merge Conflicts
There are several ways you can avoid merge conflicts in Git:

- Keep your branches up to date: If you regularly merge changes from the main development branch into your feature branches, you will be less likely to encounter conflicts when you merge your branches back into the main branch.

- Communicate with your team: If you are working on a team, make sure to communicate with your team members about the changes you are making. This will help you avoid making conflicting changes to the same files.

- Use a branching strategy: There are several branching strategies you can use to minimize the chances of merge conflicts. For example, you can use the Gitflow workflow, which involves creating a dedicated `develop` branch for integration and a separate release branch for final testing and deployment.

- Use a merge tool: There are several merge tools you can use to help resolve merge conflicts. These tools typically provide a graphical interface that allows you to easily compare the conflicting changes and choose which ones to keep.

By following these guidelines, you can minimize the chances of encountering merge conflicts in Git and make it easier to resolve conflicts when they do occur.

### Final word on merge conflicts
Merge conflicts are a common occurrence in version control systems, and it is important to understand how to handle them effectively. By following the steps outlined in this tutorial, you should be able to resolve merge conflicts smoothly and continue working on your project with minimal disruption. Many developers use GUI tools to help manage git merges and it can reduce the level of seeming complexity by using something more visual to deal with them.

# Conclusion
In this tutorial, we learned how to setup a git repository, create branches, switch branches, delete branches (with caution) while also learning how to detect and resolve merge conflicts in Git. This is only a basic tutorial on "getting-started" with git and there are many more benefits and workflows offered by git - maybe I will write a more in-depth tutorial in the future but until then I hope the content found in this article has been of use to you.

If you've found the content interesting then please feel free to share the article with your friends and peers.