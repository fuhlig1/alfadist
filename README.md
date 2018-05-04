# Alfadist
Recipes to build ALFA SW (i.e:FairRoot, FairMQ, DDS, etc), These recipes are used with AlfaBuild (Alibuild) to build the software, see below.  

# AliBuild/AlfaBuild

aliBuild is a tool to simplify building and installing ALICE / ALFA software. _(AlfaBuild is identical to AliBuild except that it expect the recipes to be in Alfadist by default)_ The tool itself is available as a standard PyPi package. You can install it via:

`pip install alibuild`

Alternatively you can checkout the github repository and use it from there:

`git clone https://github.com/alisw/alibuild.git`

This will provide you the tool itself. In order to work you will need a set of recipes from a repository called Alfadist

`git clone https://github.com/FairRootGroup/alfadist `

Once you have obtained both repository, you can trigger a build via:

`alfaBuild [-d] -j <jobs> build <package>`


* < package>: is the name of the package you want to build, e.g.:
  * FairRoot
  * FairMQ
  * FairLogger

* -d can be used to have verbose debug output.
* < jobs> is the maximum number of parallel processes to be used for building where possible (defaults to the number of CPUs available if omitted).

# Results of a build

By default (can be changed using the -c option) the installation of your builds can be found in:

`sw/<architecture>/<package-name>/<package-version>-<revision>/`

where:
* < architecture> is the same as the one passed via the -a option.
* < package-name>: is the same as the one passed as an argument.
* < package-version>: is the same as the one found in the related recipe in alfadist.
* < package-revision>: is the number of times you rebuilt the same version of a package, using a different recipe. In general this will be 1.


For a full documentation of the AliBuild/AlfaBuild tool please see [here](https://alisw.github.io/alibuild/)



# Guidelines for commit messages

- Keep the first line of the commit below 50 chars
- Leave the second line empty
- Try to keep the lines after the third below 72 chars
- Use some imperative verb as first word of the first line
- Do not end the first line with a full-stop (i. e. `.`)
- Make sure you squash / cleanup your commits when it makes sense (e.g. if they are really one the fix of the other). Keep history clean.




# Guidelines for contributing recipes

- Keep things simple (but concise).
- Use 2 spaces to indent them.
- Try avoid "fix typo" commits and squash history whenever makes sense.
- Avoid touching $SOURCEDIR. If your recipe needs to compile in source, first copy them to $BUILDIR via:

```
rsync -a $SOURCEDIR ./
```

# Guidelines for handling externals sources

Whenever you need to build a new external, you should consider the following:

  - If a Git / GitHub mirror exists, and no patches are required, use it for the
    package source.
  - If a Git / GitHub repository exists and you need to patch it, fork it, decide a
    fork point, possibly based on a tag or eventually a commit hash, and create a branch
    in your fork called `alice/<fork-point>`. This can be done with:

        git checkout -b alice/<fork-point> <fork-point>

    patches should be applied on such a branch.
  - If no git repository is available, or if mirroring the whole repository is
    not desirable, create a repository with a `master` branch. On the master
    branch import relevant released tarballs, one commit per tarball. Make sure
    you tag the commit with the tag of the tarball. E.g.:

        git clone https://github.com/alisw/mysoft
        curl -O https://mysoftware.com/mysoft-version.tar.gz
        tar xzvf mysoft-version.tar.gz
        rsync -a --delete --exclude '**/.git' mysoft-version/ mysoft/
        cd mysoft
        git add -A .
        git commit -a -m 'Import https://mysoftware.com/mysoft-<version>.tar.gz'
        git tag <version>

    In case you need to add a patch on top of a tarball, create a branch with:

        git checkout -b alice/<version> <version>

    and add your patches on such a branch.
  - Do not create extra branches unless you do need to patch the original sources.

Moreover try to keep the package name (as specified inside the recipe
in the `package` field of the header) and the repository name the same,
including capitalization.
