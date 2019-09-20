FROM python:3.6.9-buster

RUN pip install 'music21==5.3.0' --force-reinstall

# music21: Certain music21 functions might need these optional packages: matplotlib, numpy, scipy;
#                    if you run into errors, install them by following the instructions at
#                    http://mit.edu/music21/doc/installing/installAdditional.html
RUN pip install matplotlib
RUN pip install numpy
RUN pip install scipy
RUN pip install pygame

RUN pip install clyngor

RUN cd /tmp && \
  wget https://github.com/potassco/clingo/releases/download/v5.3.0/clingo-5.3.0-linux-x86_64.tar.gz && \
  tar -xzf clingo-5.3.0-linux-x86_64.tar.gz && \
  cp clingo-5.3.0-linux-x86_64/clingo /bin/ && \
  rm -r clingo-5.3.0-linux-x86_64.tar.gz clingo-5.3.0-linux-x86_64

WORKDIR /app/haspie
