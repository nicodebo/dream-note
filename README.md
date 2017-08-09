# dreamnote

Write my dream journal with (Neo)vim and compile it into this beautiful [LaTeX
Template](http://www.latextemplates.com/template/the-legrand-orange-book).

## Feature

* Editor automatically opens at the right location of the LaTeX source
* Compile and view your document easily
* Count the number of dreams you have wrote down
* Automatic version control of the source
* Modular organisation of the LaTeX source (1 latex file for each month)

## How to install ?

1.  The script depends on the following tools:
    *  python 3.6
    *  vim or neovim
    *  curl (used to download the template)
    *  unzip (used to extract the template archive)
    *  perl (used for some text processing tasks)
    *  texlive (the typesetting system)
    *  xdg-utils (used to open the pdf)
    *  git (set up with a name and an email address)
    *  rubber (used to parse compilation error log)

    For exemple on archlinux: `pacman -S neovim curl unzip perl texlive-most xdg-utils git
    rubber`

2. Clone this repository and run the makefile:

```bash
cd /tmp
git clone https://github.com/nicodebo/dream-note
cd /dream-note
make
```
The make command will do the following:
* The template configuration file will be copied to `$XDG_CONFIG_HOME/dreamnote/dreamrc`
* A python virtual environment will be created under `$XDG_DATA_HOME/dreamnote/venv`
* This repository will be copied to `$HOME/bin/dream-note`
* A symlink of the `dreamnote` main executable is created under `$HOME/bin`
  (`$HOME/bin` should be in your `$PATH` in order to run `dreamnote` from every
  location)

Note:
* You can change the directory of the virtual environment and the directory
  where the source are installed by invoking `make` in the following manner:
  ```bash
  make venv_dreamnote=/path/to/dreamnote/venv source_dir=/path/to/dreamnote/source
  ```
  and make sure `/path/to/dreamnote/source` is in your `$PATH`
* To update: 
  ```bash
  # go to directory where the source are installed
  cd /path/to/dreamnote/source # or cd $HOME/bin/dream-note if you ran bare make 
  # get the latest dreamnote source 
  git pull
  # to update the virtual environment
  make
  ```
* To change the directory of the virtual environment after the first
  installation change the `venv_root`value of the dreamnote configuration file
  launch make to build the venv.

## How to use

### Help

[//]: # (:r! sed -n 19,43p ~/Documents/Dev/dream-note/dreamnote)

```
Usage:
dreamnote [Option]
A personal tool to create and manage my dream journal

Options:
-h, -help       Display this help message and exit
-i <name>       Initialize a dream note named <name> in the current
                directory
-a              Insert a dream at the current date in the dream note
-A <date>       Insert a dream at a user specified date. <date> must be in
                the YYYY-MM-DD format with YYYY=[0000;9999], MM=[01-12] and
                DD=[01-31].
-c              Compile the main tex file into a pdf with latexmk and the
                pdflatex compiler and open the resulting pdf in the default
                previewer.
-s              Compute and display some dream informations
```

### Example

1. Open a terminal and move to the directory where you want your dream journal source to be located.

2. Initialize an empty dream journal:

    ```bash
    dreamnote -i my_dream_journal
    ```

    The hereabove command will create a folder, named `my_dream_journal`, where
    the contents of the journal will be located (LaTeX source). Some folder
    structuring is done and a first git commit is automatically done (if git is
    available).

3. Write down the dream of the past night:

    ```bash
    dreamnote -a
    ```

    Neovim (or vim) pops up with a section containing today's date and right
    below a subsection filled in with dummy text. Change the text with a nice
    dream title and start typing your dream under the subsection. Add as many
    dream as you want (or remember) by adding new subsection. When finished,
    save and quit the editor and a git commit will be automatically done,
    taking into account the fresh modifications. Note: add a flag to your dream
    titles. (n), (pl), and (l) respectively for normal dream, pre-lucid dream,
    lucid dream. (i.e. \subsection{dream title (l)}) Alternatively, no flag
    represent a normal dream. This is useful if you want to count the number of
    normal, pre-lucid and lucid dream with `dreamnote -s` option.

4. Visualize your dream journal:

    ```
    dreamnote -c
    ```

    This command will compile and display the resulting pdf in your default pdf
    viewer. Errors will be displayed if there is any, as well as warnings.

## Structure of the latex document

The latex document is organized as shown in the following tree:

```
<name> (name of the dream note)
│   main.tex
│
└───contents
    │
    └───part1 (ex: 2016)
        │   part.tex (ex: 2016.tex)
        │
        └───chapters
        │      01.tex
        │      02.tex
        │      ...
        │
        part2
        │
        ...
```

Each year is represented as a folder with the name of the year and contains
a part.tex file which input all the chapter of the corresponding directory.
Each chapter represents a month [01-12] of the year and each one is input in
the part.tex file. At a higher level the main.tex file import each part.tex.
Dreams are written each day (ideally) in chapters file (ex: 01.tex).

<!--## TODO-->

<!--* Add an option to search the dream note for specific dreams containing-->
<!--specific keywords. No, this can be done with the pdf reader.-->
<!--* stat: draw graph of cumulated sum of dream through the time ? by year ?-->
<!--* Add an option to add a package in the preamble and use this function to add-->
<!--the import package.-->
<!--* find recurring dream themes by doing some word count stat ?-->
<!--* write a git commit description that check the newly added dreams (section-->
  <!--and/or subsection)-->
<!--* check if $EDITOR is equal to vim or nvim. Otherwise just open the file-->
  <!--normaly with $EDITOR, if it is empty put a warning message-->
  <!--or use $EDITOR only if not vim or nvim.-->
<!--* in usage, strip the $0 to only get the last part-->
<!--* remove that perl dependency-->
<!--* Do you wish to edit the dream anyway ? : make yes the default choice.-->
<!--* README.md :-->
  <!--* add cc 3.0 license ? Not sure since I'm just downloading the template from-->
   <!--the source https://creativecommons.org/licenses/by-nc-sa/3.0/fr/#. No, the-->
   <!--licence is in the latex source. Just add an MIT licence to my project.-->
  <!--* add python3 dependency and pandas library or better: use only the base-->
   <!--python library-->
  <!--* Add hyperlink to each dependency-->
  <!--* Add a use case for dreamnote -A and dreamnote -s-->
  <!--* Write texlive consistently-->
  <!--* Add a animated gif ?-->
<!--* Tests :-->
  <!--* test if curl, latexmk, xdg-open, unzip are not install, the program work as-->
   <!--expected.-->
  <!--* make some bats tests. It's becomming hazardous to modify without tests and-->
<!--* Add uninstall function-->
<!--* fix mixed indentation-->
<!--* Always check return code of command ? : https://github.com/robbyrussell/oh-my-zsh/wiki/Coding-style-guide-->
