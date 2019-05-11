FROM snowyday/barekit:latest
MAINTAINER snowyday

# Libs
RUN apt-get update
RUN apt-get -y install texlive-latex-extra dvipng

# Add limits.conf
RUN echo ''* soft nofile 65536'' >> /etc/security/limits.conf
RUN echo ''* hard nofile 65536'' >> /etc/security/limits.conf

# User
ENV USER user
ENV PASS user

USER $USER
WORKDIR /home/$USER

# Set anaconda version
ENV ANACONDA anaconda3-2019.03
ENV HOME /home/$USER
ENV PATH /home/$USER/.pyenv/bin:/opt/pyenv/shims:$PATH
ENV PYENV_ROOT /home/$USER/.pyenv
ENV PATH $PYENV_ROOT/bin:$PYENV_ROOT/shims:$PATH
ENV DYLD_FALLBACK_LIBRARY_PATH $PYENV_ROOT/versions/$ANACONDA/lib 

# Pyenv
RUN git clone https://github.com/yyuu/pyenv.git ~/.pyenv
RUN git clone git://github.com/yyuu/pyenv-update.git ~/.pyenv/plugins/pyenv-update

# Anaconda
RUN pyenv install $ANACONDA
RUN pyenv global $ANACONDA
RUN conda update --all -y && conda clean --all -y

# Python libs
## conda
RUN conda install -y -c anaconda tensorflow-gpu==1.12.0
RUN conda install -y sas7bdat
RUN conda install -y pytorch torchvision cudatoolkit=9.0 ignite -c pytorch

## pip
RUN pip install tqdm dill lifelines xgboost ipdb parmap gym opencv-python ray lz4 sympy pylatexenc
RUN pip install git+https://github.com/hyperopt/hyperopt.git

## clear
RUN conda clean --all -y

# Jupyter
RUN jupyter notebook --generate-config \
    && echo ''c.NotebookApp.token = \"$PASS\"'' >> $HOME/.jupyter/jupyter_notebook_config.py \
    && echo ''c.NotebookApp.ip = \"0.0.0.0\"'' >> $HOME/.jupyter/jupyter_notebook_config.py

# ENV export
RUN echo "export PYENV_ROOT=/home/$USER/.pyenv" >> ~/.zshrc
RUN echo "export PATH=$PYENV_ROOT/bin:$PYENV_ROOT/shims:\$PATH" >> ~/.zshrc
RUN echo "export DYLD_FALLBACK_LIBRARY_PATH=$PYENV_ROOT/versions/$ANACONDA/lib" >> ~/.zshrc
RUN echo 'eval "$(pyenv init -)"' >> ~/.zshrc

# SSH start
USER root
CMD ["/usr/sbin/sshd", "-D"]
