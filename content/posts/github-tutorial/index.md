---
title: "Github Tutorial"
date: 2023-01-02T21:21:20Z
draft: false
weight: 2
# aliases: ["/first"]
tags: ["git", "github", "version control", "public repo", "private repo"]
author: "DarrenK"
# author: ["Me", "You"] # multiple authors
showToc: true
TocOpen: false

hidemeta: false
comments: false
description: "Desc Text."
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

![GitHub-Logo](github-tutorial/github-logo.svg)

___
# Tutorial-slim version
If, like me, you sometime just want the code then I've created a slim version of this tutorial that will consist of mainly commands without explanations. View the slim version here [GitHub Tutorial - Slim]({{< ref "posts/github-tutorial-slim" >}}).   
If you'd prefer the tutorial with explanation, then follow the article below.

___
# What is Github
GitHub is a web-based platform that allows you to host Git repositories online. It is a great tool for collaborating on projects with others and for sharing your work with the world. In this tutorial I will teach you the basics on how to "get-started" using GitHub with Git:

___
# Prerequisites

- GitHub.com account (free)   
Sign up for a GitHub account. You can do this by going to the GitHub website [https://github.com/](https://github.com/) and clicking on the "Sign up" button. Follow the prompts to create your account.

- Git installed on your local machine (free)   
If you haven't already done so, you will need to install Git on your computer. Details on how to install git on Mac OS and Windows are detailed in my blog post here: [Git Tutorial]({{< ref "posts/git-tutorial" >}}).

- Commands will be Mac OS / Linux based, but I will endeavour to include Windows command equivalents where possible. 

___
# Create a new SSH key-pair
1. Open a terminal window / command prompt on your local machine and navigate to the .ssh directory 
```
cd ~/.ssh
```

2. Run the following command to generate a new SSH key (remember to change the email address for your own):
```
ssh-keygen -t ed25519 -C "hello@darrenk.dev"
```
> Note: If you are using a legacy system that doesn't support the Ed25519 algorithm, use: `ssh-keygen -t rsa -b 4096 -C "your_email@example.com"`

3. When prompted to "Enter a file in which to save the key," you could press Enter to accept the default location and file name - I recommend renaming the file and saving it in the default location `~/.ssh/<FILENAME>`. Use a descriptive file name - I'll save our new SSH key-pair as `darrenk_dev_tutorial`
```
darrenk_dev_tutorial
```

4. You will then be prompted to enter a passphrase. This is an optional security measure that adds an additional layer of protection to your SSH key. If you choose to set a passphrase, you will need to enter it each time you use the key. In this tutorial I'll leave the pass phrase blank and just press Enter.

5. Once the key has been generated, you can view it by running the following command:
```
cat ~/.ssh/darrenk_dev_tutorial.pub
```
This will display the public portion of the SSH key, which you will need to add to GitHub.   
You can copy the output to your clipboard manually or by running a command:
```
// Mac OS
cat ~/.ssh/darrenk_dev_tutorial.pub | pbcopy
```

```
// Windows OS
type ~/.ssh/darrenk_dev_tutorial.pub | clip
```

6. Next, log in to your GitHub account and go to the "Settings" page, you can normally find this by clicking on your profile icon in the top right corner of the webpage. Alternatively you can reach this page by navigating to https://github.com/settings/profile when logged into github.com

7. In the "SSH and GPG keys" section (normally found in the left side menu), click the "New SSH key" button. You can normally reach this page by navigating to https://github.com/settings/keys when logged into github.com)
![new-ssh-key](github-tutorial/new-ssh-key.svg)

8. In the "Title" field, give the key a descriptive name - I'd strongly advise to enter the same name as the actual SSH key name as saved to your local machine (darrenk_dev_tutorial in our example) - if you create multiple keys then it will help you keep track of them and where they are being used.

9. In the "Key" field, paste the public portion of the SSH key that you copied in step 5.
![add-new-ssh-key-final](github-tutorial/add-new-ssh-key-final.svg)

10. Click the "Add SSH key" button to add the key to your GitHub account. Github will prompt you to enter your github.com password to save the new key to your authentication keys list.
![add-ssh-key](github-tutorial/ssh-key-authentication-keys.svg)


That's it! You should now be able to use your new SSH key to access your GitHub repositories!



___
# Create a Public Repository
11. If you're still logged into github you can navigate to [https://github.com/new](https://github.com/new).   
Alternatively you can click on your `profile icon` > `Your repositories` > `New`

12. Enter the following details to the form:   
- Repository name = `darrenk_dev_tutorial_repo`
- Description = `Tutorial repository for learning github`
- Public `select the radio button`
- Add a README file `check the check-box`   
- Click on `Create repository`
![github-new-repo](github-tutorial/github-new-repo.svg)

Congratulations! You've just created your first github repository!


___
## Git clone (HTTPS) - public repository
13. Github will take you to the repository splash screen, click on the Code button, select HTTPS and copy the url provided.
![github-clone-http](github-tutorial/github-clone-http.svg)

14. Open your terminal / cmd prompt and navigate to a directory where you want to save your repositories. I'll save the repository inside my users root directory under a subdirectory called `/tutorials`
```
cd ~/tutorials
```

15. Enter the following command to clone the repository (note that you will have to change the <YOUR_REPOSITORY_URL> section to the one copied from your github repository in step #13):
```
git clone https://github.com/<YOUR_REPOSITORY_URL>
```

Let's check the repository has been cloned and downloaded to your local machine.   

On Mac OS enter the `ls` command and on Windows enter the `dir` command - you should see the directory containing the cloned git repository called `darrenk_dev_tutorial_repo`.

You have now cloned the repository from github.com to your local machine, well done!

___
## Make changes to the README.md file

16. Open the cloned repository with your preferred code editor

17. In the `README.md` file make the following changes so the file looks like this:
```
# darrenk_dev_tutorial_repo
Tutorial repository for learning github

# Making my first `git commit`

This section of the document has been added after cloning the repository.   
We will now save the file, use the `git add` command to stage our `README.md` file and then use the `git commit` command to commit our changes to the git repository on our local machine.   
After all of that we will use the `git push` command to send the changes back up to github.com and in doing so merge our copies of the repository to match.
```

18. Save the `README.md` file and then enter the following command:
```
git status
```
![unstagedd](github-tutorial/unstaged.svg)

This tells you that git has noticed a change in the README.md file.   
Now we're ready to commit the changes.
___
## Git commit
19. Enter the following command:
```
git add README.md
```

This will add the `README.md` file to the staging area ready to be committed.

20. Enter the following command:
```
git commit
```
This should open your `git core.editor` allowing you to enter a commit message. Enter a message like the following:
![initial-commit-message](github-tutorial/init-commit.svg)

*Line #1 will be the commit title*   
*Line #3 will be the commit body* 

Alternatively you can enter the commit and message in one line like so (this will not open your default `git core.editor`):
```
git commit -m "My very first commit" -m "This commit includes changes to the README.md file in accordance with the tutorial"
```
The first `-m` flag will represent the `title` and the second `-m` flag will represent the `body` of the commit message.

12. 
- If using your code editor - enter the text and then close the file (no need to save it).   
- If using the command line then type in the message and then press Enter.

___
## Git log
We can check if the commit was successful by using the `git log` command.

13. Enter the following command:
```
git log
```

You will see the output similar to this, although some details will differ from mine to yours:
```
commit 16e162789442cd66437129a669b3f1b93b5595f5 (HEAD -> main)
Author: DarrenK_dev<>
Date:   Tue Jan 3 13:12:27 2023 +0000

    My very first commit
    
    This commit includes changes to the README.md file made in accordance with the tutorial
```


The commit is identified by a unique hash, which in this case is `16e162789442cd66437129a669b3f1b93b5595f5`. This hash is used to uniquely identify the commit and to track the changes made in the commit (yours will be different).

The `HEAD -> main` notation indicates that this commit is the current head commit (most recent commit) in the main branch of the repository. The main branch is usually the default branch in a repository, and it represents the current state of the codebase.

So in summary, this `git log` represents a snapshot of the changes made to a repository, including changes to the README.md file, and it includes a commit message and metadata about the commit.

___
# Git remote origin
By default, when you clone a repository from a remote server, Git creates a remote called `origin` that points to the original repository on the server. This allows you to easily pull, and push changes to and from the original repository. In our tutorial we are using a repository hosted on our github account - so the `remote origin` will be the repository stored on github - but how can we check? We can use the `git remote -v` command.

___
## Git remote -v
14. If you want to view the remote origin `fetch` and `push` locations then we can enter the following command:
```
git remote -v
```

It will output the location for your github repositories, mine look like this:
```
origin	https://github.com/DarrenK-dev/darrenk_dev_tutorial_repo.git (fetch)
origin	https://github.com/DarrenK-dev/darrenk_dev_tutorial_repo.git (push)
```

- The `fetch` origin is the location we will `git pull` from.   
- The `push` origin (you've guessed it) is the location we will `git push` to.

___
## Git push origin master
- We've cloned the repository
- Made changes to the `README.md` file
- Staged the `README.md` file
- Committed the staged file 
- Checked our remote origin location is correct  

15. Now we're ready to `publish` the changes to the remote origin with the `git push` command.

Firstly we can check if our local repo is ahead of our origin by entering the command:
```
git status
```

This will tell us if we're ahead of 'origin/main' - in our tutorial we are ahead by 1 commit because we've only used `git commit` once.
```
On branch main
Your branch is ahead of 'origin/main' by 1 commit.
  (use "git push" to publish your local commits)
nothing to commit, working tree clean
```

16. The output tells us to use `git push` to publish our commits - this command will published to the remote origin on github.com. Enter the following command:
```
git push origin main
```

This command is slightly different to the message of `git push` as I've been explicit about the remote name (`origin`) and branch (`main`). 

As you can see we get an Error!

We get an error because of the way in which we cloned the repository. We used HTTPS to download the repo and therefore our `git remote -v` is set to the `https` url - this will allow anyone to clone (download) the repository but it won't let anyone push (upload) changes to the repo because that would be potentially dangerous. We need to fix this error because we want to use the ssh key we generated at the start of this tutorial to access our github account and publish git push commands to our remote repository on github.com.

___
## Fixing the `git push origin main` bug
We could have avoided this bug in the first place by cloning the repository using the ssh url, but I wanted to teach you how to overcome some mistakes that might have you pulling your hair out. So lets get to the solution.

### Check the current remote origin url
Enter the following command:
```
git remote-v
```
 As you can see we have `origin` followed by `https://.....` - this is the bug we need to fix, somehow we need to tell git on our local machine that we want to change the git remote origin url to the ssh url. 
 
 17. Goto your github.com account and navigate to the repository we're working on. Click on the `Code` button and then select the `ssh` tab.
![github-clone-ssh](github-tutorial/github-clone-ssh.svg)

18. Copy the ssh url to your clipboard - it should start with `git@github.com...`

### Change the remote origin url
19. Enter the following command in terminal to change the git remote origin url, make sure to replace the `<user/repo.git>` portion with the ssh url you copied in #18 (it should be in your clipboard):
```
git remote set-url origin git@github.com:<user/repo.git>
```

### Check the change has saved
20. Check the command worked by entering the following command again:
```
git remote -v
```
You should see that the remote origin url has changed to the `git@github.com...` ssh url we copied in #18.

### Ensure your terminal session is using the correct ssh keys
We need to ensure that we're using the correct ssh key pair to access github.com, this is where naming the key-pairs with a descriptive name becomes helpful if you have multiple keys stored on you local machine.
21. Open a terminal and enter the following command (remembering that I saved my ssh key-pair as darrenk_dev_tutorial - if you used another name then please replace it in the command below):
```
ssh-add ~/.ssh/darrenk_dev_tutorial
```

This will add the ssh key located at `~/.ssh/darrenk_dev_tutorial` to the terminal session and all ssh requests will attempt to use this ssh key.   
If prompted enter your passphrase - this will be saved to the session so you won't have to re-type it every time you make an ssh request.   
   
We can even set a time limit on the session by entering the command:
```
ssh-agent -t 3600
```
This command will save the ssk key for 3600 seconds (1 Hour) - this part is optional.

___
### Push your local changes to the remote origin main branch
22. Push your local commits to git remote origin. Enter the following command:
```
git push origin main
```

This time the command should execute and work!   

Goto github.com and navigate to the repository we're working with, the code we pushed from your local machine should now be on github.com, well done!

___
### Removing the ssh key from the ssh-agent 
23. If you want to remove the ssh key from your terminal session manually then you can enter the following command `ssh-add -d <PATH/TO/SSH/KEY>`, so in our case the command would look line this:
```
ssh-add -d ~/.ssh/darrenk_dev_tutorial
```
___
## Git clone with SSH
If you wanted to avoid the bug we fixed above then you should always clone your own repositories using the ssh url - this will set the correct remote origin url automatically. If you have the correct ssh key-pair then you should be able to pull and **push** changes to your repository without any problems.

___
# Conclusion
So we've completed the following:
- added ssh key-pair to our local machine
- added the `.pub` key to our github.com account
- created a public repository
- cloned the repository to our local machine
- made changes to the README.md file 
- added the README.md file to the staging area
- committed the staged changes to the cloned repository on our local machine
- attempted to push the changes to github.com with an error
- fixed the error by changing the git remote origin url to the ssh url
- added our created ssh key to our terminal session using ssh-agent
- pushed changes to github.com

This has been a basic tutorial but much of what you've learned throughout this tutorial will serve you well for day-to-day life as a software engineer. Version control is a very important component of software engineering and git is the defacto choice for nearly every company. There are more basics to learn like branching, merging, dealing with merge conflicts but I'm sure I'll write an article about these in the future. If you've enjoyed the article then please feel free to share it, and do remember to come back as I will be adding new content around software engineering, devops and the cloud in the future.

Any question you can find me on twitter (fresh account) at [twitter](https://twitter.com/DarrenK_dev).

Thanks for your time, and I hope you enjoyed and learned something (even if it was a refresher).