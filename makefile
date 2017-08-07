SHELL := /usr/bin/env bash
# source repository
repo = https://github.com/nicodebo/dream-note
# python package required
python_pck = pandas
# xdg directories
xdg_conf := $(shell echo $${XDG_CONFIG_HOME:-$$HOME/.config})
xdg_data := $(shell echo $${XDG_DATA_HOME:-$$HOME/.local/share})
# dreamnote configuration file
conf_dreamnote = $(xdg_conf)/dreamnote/dreamrc
# python virtual env root directory
# can be overriden by calling makefile like this : make venv_dreamnote=/custom/path/to/venv
venv_dreamnote = $(xdg_data)/dreamnote/venv
# where to install the program in case not using zplug
source_dir = $(shell echo $$HOME/bin)
dr_path=$(source_dir)/dream-note

# user can overide venv_dreamnote variable, default to $XDG_CONFIG_HOME/.local/share/dreamnote/venv
# make conf_dreamnote not overidable
# for the all case user can choose where to install the program default to $HOME/bin
# write the path of $(venv_dreamnote) into the configuration file
all: venv fetch_src

# Retrieve the virtual env path in the configuratin file, install the virtual environment
# and the python packages
venv: copy_conf
	venv_tmp=$$(grep '^venv_root' $(conf_dreamnote) | sed 's/venv_root=//'); \
	python3 -m venv $${venv_tmp}; \
	$${venv_tmp}/bin/pip install $(python_pck)

# copy the configuration file model only if it does not already exists
# and write the path of the virtual environment inside of it
copy_conf: conf_dir_exists
	if [[ ! -f $(conf_dreamnote) ]]; then \
	  cp dreamrc.template $(conf_dreamnote); \
	  sed -i 's,^\(venv_root=\).*,\1$(venv_dreamnote),' $(conf_dreamnote); \
	fi

# fetch source in the source dir
fetch_src: src_dir_exists
	if [[ ! -d $(dr_path) ]]; then \
	  git clone $(repo) $(dr_path); \
	  ln -sf $(dr_path)/dreamnote $(source_dir); \
	else \
	  git -C $(dr_path) pull; \
	fi

# make sure the configuration directory exists
conf_dir_exists:
	mkdir -p $$(tmp_conf_dir=$(conf_dreamnote) && echo $${tmp_conf_dir%/*})

# make sure the source_dir exists
src_dir_exists:
	mkdir -p $(source_dir)
