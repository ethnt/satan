{ region ? "us-east-2", ... }: {
  route53HostedZones = {
    route-53-satan-computer = {
      name = "satan.computer.";
      comment = "Hosted zone for satan.computer";
    };
  };

  route53RecordSets = {
    route-53-satan-computer-wildcard-domain = { resources, ... }: {
      zoneId = resources.route53HostedZones.route-53-satan-computer;
      domainName = "*.satan.computer.";
      ttl = 300;
      recordValues = [ "161.35.142.17" ];
      recordType = "A";
    };
  };

  ec2KeyPairs = { ec2-key-pairs-satan = { inherit region; }; };

  ec2SecurityGroups = {
    ec2-security-groups-allow-ssh = {
      inherit region;
      description = "Security group that allows SSH";
      rules = [{
        fromPort = 22;
        toPort = 22;
        sourceIp = "0.0.0.0/0";
      }];
    };
  };

  s3buckets = {
    satan-barbossa-backup = {
      inherit region;
      name = "satan-barbossa-backup";
      versioning = "Suspended";
      policy = ''
        {
          "Version": "2012-10-17",
          "Statement": [
            {
              "Sid": "testing",
              "Effect": "Allow",
              "Principal": "*",
              "Action": "s3:GetObject",
              "Resource": "arn:aws:s3:::s3-test-bucket/*"
            }
          ]
        }
      '';
      lifeCycle = ''
        {
          "Rules": [
             {
               "Status": "Enabled",
               "Prefix": "",
               "Transitions": [
                 {
                   "Days": 30,
                   "StorageClass": "GLACIER"
                 }
               ],
               "ID": "Glacier",
               "AbortIncompleteMultipartUpload":
                 {
                   "DaysAfterInitiation": 7
                 }
             }
          ]
        }
      '';
    };
  };
}
