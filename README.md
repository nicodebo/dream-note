# dream note

## Aim

This personal command line tool aims at managing and maintaining my dream note
more easily. It is organized as a diary where every day, dreams of the past
night can be wrote down. The document is written based on the following latex
book template [The Legrand Orange
Book](http://www.latextemplates.com/template/the-legrand-orange-book). The
script basically help organize and sort the dream inside folder, chapter and
part. Thus, instead of having a very long monolithic latex file, text is cut
down into many parts for more convenience and easier management.

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
Dreams are written each day (idealy) in chapters file (ex: 01.tex).

## How to use

```
./dreamnote { [-h] | [-v] | [-i <name>] | [-a] }
A personal tool to create and manage my dream note

Options:
-h, --help      Display this help message and exit
-v, --version   Display script version and exit
-i <name>       Initialize a dream note named <name> in the current
                directory
-a              Insert a dream at the current date in the dream note

Informations:
The dream note is edited as a latex document based on "The Legrand Orange
Book" (http://www.latextemplates.com/template/the-legrand-orange-book).
When Initializing [-i <name>] a dream note a dotfile named .dreamrc is
created in the users home directory. It contains the <name> of the dream
note and the directory of the dream note. Only one dream note can be
created.
```

## TODO

* Automatic version control of the dream note using git
* Add an option to insert a dream at a user specified date.
* Add an option to compile and open the pdf
* Add an option to search the dream note for specific dreams containing
specific keywords.
* Open vim right after inserting a dream section to directly write down the
dream.
* Add an option to output statistic about the dreams (total number of dreams,
histogram by months, ...)