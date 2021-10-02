# Contributing Guidelines  

This documentation contains a set of guidelines to help you during the contribution process.   
We are happy to welcome all the contributions from anyone willing to improve/add new projects (doesn't matter which language) to this Repository.

Code of Conduct
---------------

### Before contributing please ensure your **pull request** adheres to the following guidelines:

### 🎯 Key Points to Remember:

- Add This Project in Firebase . After Adding the SHA1 and SHA256 keys, download the `google-services.json` file. </br>


- I use a package `encrypt` in that project. Search that in [pub.dev](https://pub.dev/packages/encrypt), to know to generate a secret unique encryption key and under [encryption_maker.dart](https://github.com/SamarpanCoder2002/Generation/blob/main/lib/BackendAndDatabaseManager/global_controller/encrytion_maker.dart) file with replacing `'Encryption Unique Key'`.</br>


- You can generate an API key from `google cloud console` with enable `Maps SDK for Android` API, and add that API key under `AndroidManifest.xml` file with replacing `Google-Map-API-Key`.</br>


- `'SERVER-KEY(Generated from Firebase Project Settings Cloud Messaging)'` under [notification_configuration.dart](https://github.com/SamarpanCoder2002/Generation/blob/main/lib/BackendAndDatabaseManager/general_services/notification_configuration.dart) file will replace by `SERVER-KEY` Generated Manually From Firebase Project Settings -> Cloud Messaging -> Generate New Server Key and use it as `SERVER-KEY`.</br>
       
 
## STEP-1 : Find an issue
  - Take a look at the Existing [Issues](https://github.com/SamarpanCoder2002/Generation/issues) and [Pull Requests](https://github.com/SamarpanCoder2002/Generation/pulls) as yours may be a duplicate  or create your own [Issues!](https://github.com/SamarpanCoder2002/Generation/issues) 

  - If your issue not an existing issue, then you can add new issue under [Issues](https://github.com/SamarpanCoder2002/Generation/issues)
  
  - Wait for the Issue to be assigned to you after which you can start working on it.
 
  
## Step 2 : Fork the Project  
- Fork this Repository. This will create a Local Copy of this Repository on your Github Profile. Keep a reference to the original project in `upstream` remote.  
 ```  
 $ git clone https://github.com/<your-username>/<repo-name>  
 $ cd <repo-name>  
 $ git remote add upstream https://github.com/<upstream-owner>/<repo-name>  
 ```  
 
- If you have already forked the project, update your copy before working.  
 ```  
 $ git remote update  
 $ git checkout <branch-name>  
 $ git rebase upstream/<branch-name>  
 ```  
 
 ## Step 3 : Choose your domain.
- Create a branch  :
 ``` 
 $ git branch <branch-name>
 $ git checkout <branch-name>

  ```
 
- Add your projects to a folder and the folder name should be your project .   
- Add all the files/folders needed.  
- After you've made changes or made your contribution to the project add changes to the branch you've just created by:
 ```
 # To add only a few files to Branch_Name
 $ git add <some files>
 # To add only a few files to Branch_Name
 $ git add <some files>
  ```
  
 
## Step 4 : Commit  
- To commit give a descriptive message for the convenience of reviewer by:  
- Please make an individual commit for each suggestion in a separate pull request.
- Check your spelling and grammar.
- Remove any trailing whitespace.
```
# This message get associated with all files you have changed  
$ git commit -m "message"  
```  

## Step 5 : Work Remotely  
- Now you are ready to your work to the remote repository.  
- When your work is ready and complies with the project conventions, upload your changes to your fork:  
  
 ```  
 # To push your work to your remote repository  
 $ git push -u origin Branch_Name  
 ```
 
 ## Step 6 : Pull Request  
- Go to your repository in browser and click on compare and pull requests. Then add a title and description to your pull request that explains your contribution.  
- Make sure your PR easy to review. That means having a clear description and only touching code that's necessary for your change.
- Check your spelling and grammar.
- Remove any trailing whitespace.

**Note** :
  - New categories, or improvements to the existing categorisation, are always welcome.
  - Being an open source contributor doesn't just mean writing code, either. You can help out by writing documentation, tests, or even giving suggestions. 🏆
  
## Need more help?🤔  
You can refer to the following articles on basics of Git and Github and also contact the Project [Mentor](https://github.com/Kushal997-das/), in case you are stuck:  
- [Forking a Repo](https://help.github.com/en/github/getting-started-with-github/fork-a-repo)  
- [Cloning a Repo](https://help.github.com/en/desktop/contributing-to-projects/creating-an-issue-or-pull-request)  
- [How to create a Pull Request](https://opensource.com/article/19/7/create-pull-request-github)  
- [Getting started with Git and GitHub](https://towardsdatascience.com/getting-started-with-git-and-github-6fcd0f2d4ac6)  
- [Learn GitHub from Scratch](https://www.youtube.com/watch?v=BCQHnlnPusY&list=PLozRqGzj97d02YjR5JVqDwN2K0cAiT7VK)  
  
Tip from us😇
-------------
It always takes time to understand and learn. So, do not worry at all. We know you have got this!💪
