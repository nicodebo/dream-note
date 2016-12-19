###############################################################################
#                                  Functions                                  #
###############################################################################

# This function print the "how to use" this program
function usage () {
    cat <<-EOF
	Usage:
	$0 [Option]
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
	
	Informations:
	The dream note is edited as a latex document based on "The Legrand Orange
	Book" (http://www.latextemplates.com/template/the-legrand-orange-book).
	When Initializing [-i <name>] a dream note a dotfile named .dreamrc is
	created in the users home directory. It contains the <name> of the dream
	note and the directory of the dream note. Only one dream note can be
	created. If you want to start over a new dream journal, delete ~/.dreamrc
	and initialize a new dream journal.
	EOF
}

# This function write a dotfile in the user's home directory. It contains the
# path of the dream note.
# $1 - The current directory.
# $2 - Dotfile path.
# $3 - name of the dream note provided by the user
# $4 - name of the dream note path variable
# $5 - name of the dream note name variable
function write_conf() {
    local cur_dir="$1"; shift
    local dotfile_path="$1"; shift
    local dn_name="$1"; shift
    local dn_path_var_name="$1"; shift
    local dn_name_var_name="$1"; shift
    
    cat <<-EOT >> "${dotfile_path}"
	# ${dotfile_path} : dreamnote configuration file
	
	
	# path of the dream note
	${dn_path_var_name}=$cur_dir
	
	# name of the dream note
	${dn_name_var_name}=$dn_name
	EOT
}
#TODO: remplacer >> (append) par > (overwrite) ?

# This function initialize a dream note inside the current directory and create
# a dotfile specifiying the path of the dreamnote.
# $1 - url of the latex template
# $2 - name of the contents drectory
# $3 - The current directory.
# $4 - Dotfile path.
# $5 - name of the dream note provided by the user
# $6 - name of the dream note path variable
# $7 - name of the dream note name variable
function initialize() {
    local url="$1"; shift
    local tex_contents="$1"; shift
    local cur_dir="$1"; shift
    local dotfile_path="$1"; shift
    local dn_name="$1"; shift
    local dn_path_var_name="$1"; shift
    local dn_name_var_name="$1"; shift
    
    if [ -s "$dotfile_path" ]; then
        echo 'a dreamnote already exists !'
    else
        echo 'Initializing dream note…'
        filename=$(basename "$url")
        wget -N "$url"
        unzip "$filename" -d "$dn_name"
        cd "$dn_name"
        firstline=$(grep -n -m 1 -E '^\\(part|chapter|section){' main.tex | cut -d : -f 1)
        lastline=$(grep -n '^\\end{document}' main.tex | cut -d : -f 1)
        let lastline=lastline-1
        sed -i main.tex -re "$firstline,${lastline}d"
        sed -i '/\\\input{structure}/a \\\usepackage{import}' main.tex
        mkdir "$tex_contents" 
        #:> bibliography.bib
        echo "Creating a configuration file ($dotfile_path)…"
        write_conf "$cur_dir" "$dotfile_path" "$dn_name" "$dn_path_var_name" "$dn_name_var_name"
        wget -O .gitignore https://www.gitignore.io/api/latex

        cat <<-EOT >> .gitignore
		
		# added files
		main.pdf
		*.ptc
		EOT

        git init
        git add -A && git commit -m "dream journal initialization"
    fi
}

# This function import a part.tex (ex: 2016.tex) to the main.tex document.
# $1 - Path of the main.tex of dreamnote.
# $2 - Relative path of the part.tex to include in the main.tex of the
# dreamnote.
function import_part_to_main() {
    local maintex_path="$1"; shift
    local part_path="$1"; shift
    
    local filename=$(basename "${part_path}")
    filename="${filename%.*}"
    local dirname=$(dirname "${part_path}")
    dirname="${dirname}/"
    local import_part_cur="\subimport{${dirname}}{${filename}}"
    
    local imported_parts_old=$(grep '^\\subimport{' "$maintex_path") # TODO: compléter la pattern pour éviter
    local imported_parts_new
    
    if [ -z "$imported_parts_old" ]; then
        #echo "empty"
        import_part_cur=$( echo "${import_part_cur}" | sed 's,\\,\\\\\\,' )
        sed -i "/^\\\end{document}/i ${import_part_cur}\n" "$maintex_path"
    else
        #echo "find"
        imported_parts_new="$imported_parts_old"$'\n'"${import_part_cur}"
        imported_parts_new=$( echo "${imported_parts_new}" | sort -u )
        imported_parts_new=$( echo "${imported_parts_new}" | sed 's/\\/\\\\/')
        perl -i -0pe "s#\Q${imported_parts_old}\E#${imported_parts_new}#" "$maintex_path"
    fi
}

# This function import a chapter (ex: 11.tex) to the part document (ex:
# 2016.tex)
# $1 - Path of the part.tex
# $2 - Relative path of the chapter.tex to include in the part.tex
function import_chapt_to_part() {
    local part_path="$1"; shift
    local chapt_path="$1"; shift
    
    local filename=$(basename "${chapt_path}")
    filename="${filename%.*}"
    local dirname=$(dirname "${chapt_path}")
    dirname="${dirname}/"
    local input_chapt_cur="\input{${dirname}${filename}}"
    
    local input_chapt_old=$(grep '^\\input{' "$part_path") # TODO: compléter la pattern pour éviter
    local input_chapt_new
    
    if [ -z "$input_chapt_old" ]; then
        #echo "empty: no chapter found"
        cat <<-EOT >> "${part_path}"
		
		${input_chapt_cur}
		
		EOT
    else
        #echo "find: chapter found"
        input_chapt_new="$input_chapt_old"$'\n'"${input_chapt_cur}"
        input_chapt_new=$( echo "${input_chapt_new}" | sort -u )
        input_chapt_new=$( echo "${input_chapt_new}" | sed 's/\\/\\\\/')
        perl -i -0pe "s#\Q${input_chapt_old}\E#${input_chapt_new}#" "$part_path"
    fi
}

# This function insert a dream section with a date as a title and a subsection
# which represent a dream with a dummy title.
# $1 - Path of the chapter to add a dream.
# $2 - Relative path of the chapter.tex to include in the part.tex
# $3 - day
# $4 - month letter
# $5 - year
# $6 - Name of the dream note
# $7 - Name of the contents directory
function insert_dream() {
    local chapt_path="$1"; shift
    local dream_title="$1"; shift
    local day="$1"; shift
    local month_let="$1"; shift
    local year="$1"; shift
    local dn_path="$1"; shift
    local dn_name="$1"; shift
    
    local section_cur="\section{${day} ${month_let} ${year}}"
    local subsection_cur="\subsection{${dream_title}}"
    local dream_cur="${section_cur}"$'\n'"${subsection_cur}"
    
    local section_old=$(grep '^\\section{' "$chapt_path") # day already filled.
    local section_new
    local sect_cur_pos # Section to insert the current dream above.
    local cur_line
    local sepline='%------------------------------------------------------------------------------'
    local tmp_var
    local sect_below # section below the one to be inserted
    local sect_above # section above the one to be inserted
    
    if [ -z "$section_old" ]; then
        #echo "empty: no dream found"
        echo "$dream_cur" >> "$chapt_path"
        "$EDITOR" "$chapt_path" -c 'normal Go'
    else
        #echo "find: dream found"
        tmp_var=$(cat "$chapt_path" | grep -n "$(echo ${section_cur} | sed 's/\\/\\\\/')")
        #echo "$tmp_var"
        if [ -n "$tmp_var" ]; then
            echo "This dream section already exists !"
            cur_line=$(echo "$tmp_var" | cut -d : -f 1)
            while true; do
                read -p "Do you wish to edit the dream anyway ? [y/n]" yn
                case $yn in
                    [Yy]* ) "$EDITOR" +"$cur_line" "$chapt_path"; break;;
                    [Nn]* ) exit;;
                    * ) echo "Please answer yes or no.";;
                esac
            done
        else
            section_new="$section_old"$'\n'"$section_cur"
            section_new=$( echo "${section_new}" | sort -u )
            section_cur=$( echo "${section_cur}" | sed 's/\\/\\\\/')
            sect_below=$(echo "${section_new}" | grep -A 1 "${section_cur}" | tail -n +2)
            #echo "section below: ${sect_below}"
            sect_above=$(echo "${section_new}" | grep -B 1 "${section_cur}" | head -n -1)
            #echo "section above: $sect_above"
            if [ -n "$sect_above" ] && [ -z "$sect_below" ]; then
                dream_cur="${sepline}"$'\n'"${dream_cur}"
                echo "$dream_cur" >> "$chapt_path"
                "$EDITOR" "$chapt_path" -c 'normal Go'
            elif [ -z "$sect_above" ] && [ -z "$sect_below" ]; then
                echo "Error: Nothing below and nothing above !"
                echo "Please fix $chapt_path"
            else
                dream_cur="${dream_cur}"$'\n'"${sepline}" 
                #echo "$dream_cur"
                dream_cur=$( echo "${dream_cur}" | sed 's,^\\,\\\\\\,' )
                sect_below=$( echo "${sect_below}" | sed 's,\\,\\\\,' )
                while read -r line; do
                    sed -i "/${sect_below}/i $line" "$chapt_path"
                done <<< "$dream_cur"
                cur_line=$(cat "$chapt_path" | grep -n "$section_cur" | cut -d : -f 1)
                let cur_line=cur_line+1
                "$EDITOR" +"$cur_line" "$chapt_path" -c 'normal o'
            fi
        fi
    fi
    snapshot "$dn_path" "$dn_name"
}

# This function append a new dream template to the end of the latex document at
# the current date.
# $1 - Day of today, ex: 11
# $2 - Month today in number, ex: 12
# $3 - Month today in letter, ex: Decembre
# $4 - Year of today, ex: 2016
# $5 - Path of the dream note
# $6 - Name of the dream note
# $7 - Name of the contents directory
function create_part_chapt() {
    local day="$1"; shift
    local month_num="$1"; shift
    local month_let="$1"; shift
    local year="$1"; shift
    local dn_path="$1"; shift
    local dn_name="$1"; shift
    local tex_contents="$1"; shift
    
    local chapt_dir='chapters'
    local chapter_dir="${dn_path}/${dn_name}/${tex_contents}/${year}/${chapt_dir}"
    local part_file="${dn_path}/${dn_name}/${tex_contents}/${year}/${year}.tex"
    local chapt_file="${dn_path}/${dn_name}/${tex_contents}/${year}/${chapt_dir}/${month_num}.tex"
    
    if [ ! -e "$part_file" ] ; then
        mkdir -p "$chapter_dir"
        cat <<-EOT >> "${part_file}"
		%------------------------------------------------------------------------------
		%   PART: Année ${year}
		%------------------------------------------------------------------------------
		
		\part{Année ${year}}
		
		%------------------------------------------------------------------------------
		%   CHAPTERS
		%------------------------------------------------------------------------------
		EOT
        import_part_to_main "${dn_path}/${dn_name}/main.tex" "${tex_contents}/${year}/${year}.tex"
    fi

    if [ ! -e "$chapt_file" ] ; then
        cat <<-EOT >> "${chapt_file}"
		%------------------------------------------------------------------------------
		%   CHAPTER: ${month_let} ${year}
		%------------------------------------------------------------------------------
		
		\chapterimage{chapter_head_2.pdf} % Chapter heading image
		
		\chapter{${month_let} ${year}}\index{${month_let} ${year}}
		
		%------------------------------------------------------------------------------
		%   DREAMS
		%------------------------------------------------------------------------------
		EOT

        import_chapt_to_part "${part_file}" "${chapt_dir}/${month_num}.tex"
    fi

    insert_dream "$chapt_file" "blank title" "$day" "$month_let" "$year" "$dn_path" "$dn_name"
}

# Compile with latexmk and output pdf. Run in one shot mode.
# $1 - Path of the dream note
# $2 - Name of the dream note
function output_pdf() {
    local dn_path="$1"; shift
    local dn_name="$1"; shift
    local main_tex_path="${dn_path}/${dn_name}/main.tex"
    cd "${dn_path}/${dn_name}"
    latexmk -C
    latexmk -pdf -quiet -f -pdflatex="pdflatex -interaction=nonstopmode" main.tex
    local texerror=$(rubber-info --errors main)
    local texwarn=$(rubber-info --warnings main)
    if [ -z "$texerror" ]; then
        xdg-open main.pdf
        echo "################################################################"
        echo "#                          Warnings                            #"
        echo "################################################################"
        echo "$texwarn"
    else
        echo "################################################################"
        echo "#                           Errors                             #"
        echo "################################################################"
        echo "$texerror"
    fi
}

#TODO : faire une variable pour le nom du fichier tex (main)
#TODO : ne pas afficher texwarn si cette variable est vide.

# $1 - Path of the dream note
# $2 - Name of the dream note
function snapshot() {
    #function_body
    local dn_path="$1"; shift
    local dn_name="$1"; shift
    local git_local="${dn_path}/${dn_name}"
    local today_date=$(date +"%Y-%m-%d")
    local new_file=""
    local last_com_mess=""
    local cur_com_mess=""
    local num=0
    local tmp_var=""

    cd "$git_local"
    # get untracked file and modified file in the working directory
    new_file=$(git ls-files --other --modified --exclude-standard)
    last_com_mess=$(git log -1 --pretty=format:'%s')
    if [ -n "$new_file" ]; then
        tmp_var=$(echo "$last_com_mess" | grep "$today_date")
        if [ -n "$tmp_var" ]; then
            num=$(echo "$last_com_mess" | grep -oP '(?<=\()[0-9]*(?=\))')
        fi
        let num++
        cur_com_mess="Mise à jour du ${today_date} ($num)"
        git add --all && git commit -m "${cur_com_mess}"
    fi
}
