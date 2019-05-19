# medializr
Docker recipe for the ultimate medializr

Edit the .env-file to your liking and edit your traefik.toml with the following to get A+ on ssl labs :)

    [entryPoints.https.tls]
      minVersion = "VersionTLS12"
      cipherSuites = [
        "TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384",
        "TLS_ECDHE_RSA_WITH_CHACHA20_POLY1305",
        "TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256"
      ]

I borrowed lots of things from a lot of different githubprojects/forums when I put together this docker-compose.yml

This is what I am using, go ahead and use it however you want hehe
