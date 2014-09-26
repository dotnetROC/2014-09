# Pre-requisites that we need to take care of
Import-Module BetterCredentials, Posh-Git, ModuleBuilder, Xml -Force
Import-Module C:\Users\JBennett\SkyDrive\WindowsPowerShell\Presentations\Git\DemoMagic.psm1 -Force
Initialize-Git -Credential (Get-Credential jaykul -Domain github -GenericCredentials -Store) 

Set-Prompt -Fancy


# An introduction to source control with git:
# There are basically two scenarios where you want to get started with source control: you either have code already, or you're starting with existing code. In either case, it's the same for git:

# Let's make an empty folder and start working in it.
mkdir ~\Projects\DemoSept2014
cd ~\Projects\DemoSept2014

# In a distributed source control system, we don't have a "repository" in one place and our actual code somewhere else, we basically just turn this folder full of code into our repository:
git init

# You should notice that the prompt is already indicating that I'm in the "master" branch
# Branching and forking are core features in git, so I like to keep track of where I am...
# Let's get some content in here
# Invoke-WebRequest "http://www.initializr.com/builder?boot-hero&jquerymin&h5bp-iecond&h5bp-chromeframe&h5bp-analytics&h5bp-favicon&h5bp-appletouchicons&modernizrrespond&izr-emptyscript&boot-css&boot-scripts" -OutFile Initializr.zip
Expand-Archive ~\Downloads\Initializr.zip .
mv .\initializr\* .
rm .\Initializr.zip
ls

# At this point, you'll notice my prompt is showing file counts: new files, modified files, removed files
# The reason I point this out is because these new files aren't being tracked yet:
git status

# Let's add all of that (I'll say more about this in a second)
git add *
# Did you notice that it's gone from 6 to 19? When we did git add *, it was recursive, so it added all the files in subdirectories.
git status
# If we just commit, we'll get prompted for a commit message
git commit
# And we can check our history, there's nothing much yet ;-)
git log

# Let's copy the index file to add a new file
cp index.html about.html
git add *
git status

# Let me digress for a second, and show you something interesting about git:
cp index.html members.html
# I want you to see in my prompt that there are two sets of numbers right now...
# The reason is that in a git code folder there are two possible states for edited files
git status

# You can see that some changes are ready to be commited, we say they're staged
# While other changes are not staged.  You'll see this again as we go along.
# In the meantime, lets get these files committed separately
git commit -m "Add a page about us"
git add *
# I want them in separate commits, so even though I've already created both files, I'm going to commit them separately:
git commit -m "Add a page where we can list our members"
git status

# Now, let's fix the content on our index page. What's in it?
ii .\index.html

# Without getting too off-track, a quick and easy way to change a file:
# We'll get around to the content parts later, for now, let's just fix up the big stuff
${C:index.html} = ${C:index.html} -replace "Project name", "Visual Developers of Upstate New York" -replace "Hello, world!", "VDUNY" -replace "<p>This is a template.*</p>", "<p>The Visual Developers of Upstate New York is a group of developers, programmers, designers, and system architects in upstate New York, mostly in and around the Rochester area.</p>"

# Notice I didn't have to check anything out, or lock it or anything, it's changed.
# At this point, I can choose to add the file, or discard it, ...
git status

# Or even commit while -a adding all changes at once:
git commit -a -m "First draft of the index page"

# Of course, at this point, nobody can actually contribute to my project, because it's just here on my disk.

# Let's take a look at the history:
git log

# That's pretty simple.  Let's see if we can tell who changed what, when.
# We should be able to see the title edit, since it was a separate commit:
git blame .\index.html


# Git will be happy to serve up your repository from your local machine using git deamon:
# [alias]
#    serve = !git daemon --reuseaddr --verbose --base-path=. --export-all ./.git
git serve

# But more than likely you'll want to configure a remote repository, and use git push
# So let's create a repository on github...
New-GitHubRepo -Organization VDUNY -Name vduny.github.io -Description "The new VDUNY website"

# We can track that repository as a remote. I'll use the special "origin" name:
# I always use ssh for github for authentication reasons:
git remote add origin git@github.com:VDUNY/vduny.github.io.git

# Now we can finally send changes in our current branch up to our remote
git push origin master
# By default each branch tracks a specific remote, or else "origin" -- so in future commits I can leave that off

# Create a branch. Note that I could specify a commit to branch from (even an old commit)
git branch aboutus
# Now we'll switch to it.  Note that I could have used checkout with -b to create the branch...
git checkout aboutus

# Let's make that Learn More link go somewhere
${C:index.html} = ${C:index.html} -replace ">Learn more"," href='about.html'>Learn more"

# And let's turn the about page into something cleaner:
Invoke-DemoMagic about.html

# Ok, I just noticed a problem, the project name and copyright are wrong.
# I don't want to fix that on this branch, so let's just switch back to master
git checkout master
# Did you notice the warning that I have two modified files? Ooops
git checkout aboutus
# Let's just stash that for a minute
git stash 
# and go fix the project and copyright for everything:
git checkout master
foreach($file in "about.html", "index.html") {
    Set-Content $file ((Get-Content $file) -replace "Project name","Visual Developers of Upstate New York" -replace "Company 2014", "Joel Bennett 2014")
}
git commit -a -m "Fix the Header and copyright"

# ok, now, where were we ...
git checkout aboutus
git stash pop

# I forget what I did to index...
git diff index.html
# go ahead and commit that stuff
git add index.html
git commit -m "Add a link to the about page"
# And then commit the about page
git commit -a -m "Wrote the about page"
# Ok, I'm basically done with this about stuff, I need to put these back on master
# two choices: 1) merge
git checkout master
git merge aboutus
# Let me show you what that looks like in SourceTree

# Personally, I don't like having all those little branches...
# So let's go back in time to before that merge
git reset --hard HEAD~1
git checkout aboutus
# And we'll do a rebase instead:
git rebase master
# Now look what that looks like ...
# Now we can do our merge and it'll look like magic!
git checkout master
git merge aboutus
# Finally, we can send those changes up to the public
git push
# And we can clean up that branch, since we never pushed it anywhere
git branch aboutus --delete