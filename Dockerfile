# We're using the passenger-ruby image because we'll need it later
# https://github.com/phusion/passenger-docker
FROM phusion/passenger-ruby25:0.9.34
MAINTAINER André Henrique <andre.h.stv@gmail.com>

# Exposing ports for nginx usage
EXPOSE 80
EXPOSE 443

# Exposing port for development
EXPOSE 3000

# Creating ENV vars
ENV INSTALL_PATH /home/app
ENV RAILS_ENV development

# Installing system dependencies
RUN curl -sL https://deb.nodesource.com/setup_8.x | bash -
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list
RUN apt-get update
RUN apt-get install -y tzdata nodejs yarn
RUN apt autoremove -y

# Copying the project files to the INSTALL_PATH
COPY . $INSTALL_PATH

# Changing our work directory to the INSTALL_PATH
WORKDIR $INSTALL_PATH

# Installing bundler
RUN gem install bundler

# Setting up our Ruby on Rails project
RUN bundle install
RUN bin/rails assets:precompile
RUN bin/rails log:clear tmp:clear
RUN /usr/local/rvm/bin/rvm rvmrc warning ignore /home/app/Gemfile

# Giving ownership to the "app" user bacause it's the default user set at the passenger-ruby image
RUN chown -R app:app .

# Starting application
CMD ["sh", "/home/app/script/start_dev"]
