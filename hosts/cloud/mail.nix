{
  config,
  simple-nixos-mailserver,
  ...
}:
{
  imports = [
    simple-nixos-mailserver.nixosModule
  ];

  sops.secrets.mail_password.sopsFile = ./secrets.yaml;
  sops.secrets.sasl_password.sopsFile = ./secrets.yaml;

  mailserver = {
    enable = true;
    fqdn = "mx.andrewjackson.dev";
    domains = [
      "andrewjackson.dev"
      "jksn.uk"
      "a-jackson.co.uk"
    ];
    loginAccounts = {
      "andrew@andrewjackson.dev" = {
        hashedPasswordFile = config.sops.secrets.mail_password.path;
        aliases = [
          "@andrewjackson.dev"
          "@jksn.uk"
        ];
      };
      "andrew@a-jackson.co.uk" = {
        hashedPasswordFile = config.sops.secrets.mail_password.path;
        aliases = [
          "@a-jackson.co.uk"
        ];
      };
    };
    certificateScheme = "acme";
    acmeCertificateName = "andrewjackson.dev";
    localDnsResolver = false;
    mailDirectory = "/mnt/mail/vmail";
    sieveDirectory = "/mnt/mail/sieve";
    dkimKeyDirectory = "/mnt/mail/dkim";
  };

  services = {
    postfix = {
      relayHost = "smtp.sendgrid.net";
      relayPort = 587;
      rootAlias = "andrew@andrewjackson.dev";
      mapFiles.sasl_password = config.sops.secrets.sasl_password.path;
      config = {
        smtp_sasl_auth_enable = "yes";
        smtp_sasl_security_options = "noanonymous";
        smtp_sasl_tls_security_options = "noanonymous";
        smtp_sasl_password_maps = "hash:/etc/postfix/sasl_password";
        smtp_tls_security_level = "encrypt";
        header_size_limit = 4096000;
      };
    };

    roundcube = {
      enable = true;
      # this is the url of the vhost, not necessarily the same as the fqdn of
      # the mailserver
      hostName = "mail.andrewjackson.dev";
      extraConfig = ''
        # starttls needed for authentication, so the fqdn required to match
        # the certificate
        $config['smtp_server'] = "tls://${config.mailserver.fqdn}";
        $config['smtp_user'] = "%u";
        $config['smtp_pass'] = "%p";
      '';
    };

    nginx.virtualHosts."mail.andrewjackson.dev" = {
      enableACME = false;
      useACMEHost = "andrewjackson.dev";
    };
  };

  homelab.restic.daily.paths = [
    "/mnt/mail"
  ];
}
