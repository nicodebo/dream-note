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
    1.  vim or neovim (required)
    1.  curl (used to download the template) (required)
    1.  unzip (used to extract the template archive) (required)
    1.  perl (used for some text processing tasks) (required)
    1.  TexLive (the typesetting system) (required)
    1.  latexmk (automatically installed with the latest TeXLive) (required)
    1.  xdg-utils (used to open the pdf) (optional)
    1.  git (set up with a name and an email address) (optional)
        It is used for automatic version control of the LaTeX sources
    1.  rubber (used to parse compilation error log) (optional)

    For exemple `pacman -S neovim curl unzip perl texlive-most xdg-utils git
    rubber`

2. Clone this repository and launch the install script:

```bash
cd /tmp
git clone https://github.com/nicodebo/dream-note
cd dream-note
./install ~/bin
```

Where `~/bin` is the directory where I install my custom tool. Change accordingly.

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
<!--* check if the tools are here before doing operation.-->
<!--* check if $EDITOR is equal to vim or nvim. Otherwise just open the file-->
  <!--normaly with $EDITOR, if it is empty put a warning message-->
  <!--or use $EDITOR only if not vim or nvim.-->
<!--* in usage, strip the $0 to only get the last part-->
<!--* remove that perl dependency-->
<!--* Turn the whole project into a python instead of bash ? I should have started-->
  <!--with python instead of having parts with python and parts with bash.-->
<!--* Do you wish to edit the dream anyway ? : make yes the default choice.-->
<!--* README.md :-->
  <!--* add cc 3.0 license ? Not sure since I'm just downloading the template from-->
    <!--the source https://creativecommons.org/licenses/by-nc-sa/3.0/fr/#. No, the-->
    <!--licence is in the latex source. Just add an MIT licence to my project.-->
  <!--* remove latexmk as dependency since it comes with TeXlive-->
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
    <!--link to travisCI just for fun and to learn the process (or maybe docker for-->
    <!--local testing, or maybe both for learning as I don't know much about testing ^^-->
<!--* Add uninstall function-->
<!--* fix mixed indentation-->
<!--* indentation = 4 spaces is more readable than 2. Switch back to 4-->
