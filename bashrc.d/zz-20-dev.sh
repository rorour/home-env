if [ $(expr "$BASH_SOURCE" : ~/src) = 0 -a -d ~/src/biviosoftware/home-env ]; then
    # Execute user's dot files only
    return
fi

export BIVIO_HTTPD_PORT=${BIVIO_HTTPD_PORT:-$(perl -e 'printf(q{80%02d}, (`id -u` =~ /(\d+)/)[0] * 2 % 100)')}
export BIVIO_IS_2014STYLE=${BIVIO_IS_2014STYLE:-0}

if [ -z "$BIVIO_HOST_NAME" ]; then
    if [ "x$(hostname)" = xapa3.bivio.biz ]; then
        BIVIO_HOST_NAME=dev.bivio.biz
    elif [ ! -z "$(type ifconfig 2>/dev/null)" ]; then
	eval $(ifconfig | perl -ne '/addr:10\.10\.10\.(\d+)/ && print(qq{BIVIO_HOST_NAME=z$1.bivio.biz})')
	if [ -z "$BIVIO_HOST_NAME" ]; then
	    BIVIO_HOST_NAME=$(hostname)
	fi
    fi
    export BIVIO_HOST_NAME
fi

if [ -z "$BIVIO_CFG_DIR" ]; then
    if [ -d /cfg ]; then
        export BIVIO_CFG_DIR=/cfg
    elif [ -d /vagrant ]; then
        export BIVIO_CFG_DIR=/vagrant
    fi
fi

if type bconf &>/dev/null; then
    if [ -z "$BIVIO_DEFAULT_BCONF" ]; then
        for x in Artisans::BConf Bivio::DefaultBConf; do
            if perl -M$x -e 1 2>/dev/null; then
                export BIVIO_DEFAULT_BCONF=$x
                break
            fi
        done
    fi

    if [ ! -z "$BIVIO_DEFAULT_BCONF" ]; then
        eval "$(env BCONF=$BIVIO_DEFAULT_BCONF bivio dev bashrc_b_env_aliases)"
        b_env pet Bivio/PetShop && cd - > /dev/null
    fi
fi

if [ -d ~/.pyenv/bin ]; then
    b_path_insert ~/.pyenv/bin
    if [ 'function' != "$(type -t pyenv)" ]; then
        eval "$(pyenv init -)"
        # pyenv init always inserts shims in the path
        b_path_dedup
    fi
    if [ 'function' != "$(type -t _pyenv_virtualenv_hook)" ]; then
        eval "$(pyenv virtualenv-init -)"
        function _b_pyenv_virtualenv_hook {
            _pyenv_virtualenv_hook
            if [ -z "$VIRTUAL_ENV" ]; then
                b_ps1 $(pyenv global)
            else
                b_ps1 $(basename "$VIRTUAL_ENV")
            fi
        }
        export PROMPT_COMMAND=_b_pyenv_virtualenv_hook
    fi
fi

b_pyenv_global() {
    _b_pyenv_global "$@"
    . ~/.bashrc
}

gcl() {
    local r=$1
    if [ $(expr "$r" : '.*/') = 0 ]; then
	r=$(basename $(pwd))/$r
    fi
    git clone "https://github.com/$r"
}

gco() {
    git commit -am "$@"
}

gpu() {
    git push origin master "$@"
}

gst() {
    git status "$@"
}

gup() {
    git pull "$@"
}

http() {
    python2 -m SimpleHTTPServer $BIVIO_HTTPD_PORT
}

mocha() {
    command mocha "$@" | perl -p -e 's/\e.*?m//g'
}

nup() {
    cvs -n up 2>/dev/null|egrep '^[A-Z] |^\? .*\.(pm|bview|gif|jpg|t|PL|btest|bunit|bconf|msg|css|js|png|psd|pdf|spec|xml|java)$'
}

py2() {
    b_pyenv_global 2.7.8
}

py3() {
    b_pyenv_global 3.4.2
}

up() {
    cvs up -Pd
}

# Avoid "Error: DEPTH_ZERO_SELF_SIGNED_CERT" from Node.js
export NODE_TLS_REJECT_UNAUTHORIZED=0
