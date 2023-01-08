---
title: "Github Tutorial Slim"
date: 2023-01-07T11:46:38Z
draft: false
type: hidden
# weight: 2001
# aliases: ["/first"]
tags: ["git", "github", "version control", "tutorial"]
categories: ["slim"]
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
    image: "git-logo.svg" # image path/url
    alt: "git" # alt text
    caption: "<text>" # display caption under cover
    relative: false # when using page bundles set this to true
    hidden: true # only hide on current single page
editPost:
    URL: "https://github.com/<path_to_repo>/content"
    Text: "Suggest Changes" # edit text
    appendFilePath: true # to append file path to Edit link
---
![github-logo](github-tutorial-slim/github-logo.svg)

___
# Tutorial version + explanation
If you would like a little more explanation regarding the commands in this tutorial then I have a more in-depth tutorial here: [GitHub Tutorial - Full]({{< ref "posts/github-tutorial" >}}).   
If you'd prefer the slimmed down tutorial focusing on code then follow the article below.

___
# Prerequesites
1. Github.com account (Free)

2. Git installed on your local machine (Free).
___
# Create ssh-key pair
Open a terminal and enter the following commands:

3. Navigate to the default ssh directory:
```
cd ~/.ssh
```

4. Create a new key-pair:   
Replace the email portion with your own email address
```
ssh-keygen -t ed25519 -C "hello@darrenk.dev"
```   
> Note: If you are using a legacy system that doesn't support the Ed25519 algorithm, use: `ssh-keygen -t rsa -b 4096 -C "your_email@example.com"`

5. Change the file name to `darrenk_dev_tutorial` when prompted.

6. When prompted enter a passphrase, or leave blank (optional).

7. Copy the `.pub` key to your clipboard:
```
// Mac OS
cat ~/.ssh/darrenk_dev_tutorial.pub | pbcopy
```
```
// Windows OS
type ~/.ssh/darrenk_dev_tutorial.pub | clip
```

8. Goto [https://github.com/settings/keys](https://github.com/settings/keys) or navigate Github.com > profile > settings > SSH & GPG keys.

9. Click on New SSH Key

10. Enter a title - I recommend using the same name as your ssh-key, in our example   
```
darrenk_dev_tutorial
```

11. Paste the `.pub` key into the Key text area (it should end with your email address)

12. Click Add SSH key
___
# Create a public repository
13. Navigate to [https://github.com/new](https://github.com/new)

14. Enter the following details to the form:   
- Repository name = `darrenk_dev_tutorial_repo`
- Description = `Tutorial repository for learning github`
- Public `select the radio button`
- Add a README file `check the check-box`   
- Click on `Create repository`

15. Click the `Code` button and copy the SSH url to your clipboard.

16. In terminal navigate to a directory where you want to save the repository

17. Enter the command (making sure to replace the <REPO> section with your ssh url copied in #15):
```
git clone git@github.com:<REPO>
```
___
# Make changes to the README.md file
18. Open the repo in your code editor

19. Make a change to the README.md file by adding some additional text to the file

20. Enter the following commands:
```
git add README.md
```
```
git commit -m "initial commit" -m "added some more text to README.md file."
```
```
git status
```
You should see that your commit has been published to your local git repo.

___
# Push changes to remote origin on Github.com
21. Check if the remote origin url is correct:
```
git remote -v
```
The output should contain the same ssh url as copied in #15

22. Enter the command to push changes to github.com
```
git push origin main
```
___
# Check if changes have been pushed
23. Check if changes have been pushed by opening the guthub.com repository page and checking the README.md file for the changes.

Well done you've completed this slim tutorial.