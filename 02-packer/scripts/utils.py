import urllib, urllib.request

def get_token():
    url = "http://169.254.169.254/latest/api/token"
    headers = {"X-aws-ec2-metadata-token-ttl-seconds": "60"}

    req = urllib.request.Request(url, headers=headers, method="PUT")

    try:
        response = urllib.request.urlopen(req)
        token = response.read().decode()
        return token
    except urllib.error.HTTPError as e:
        print(f"HTTPError: {e.code} - {e.reason}")
    except urllib.error.URLError as e:
        print(f"URLError: {e.reason}")

def get_instance_id(token):
    url = "http://169.254.169.254/latest/meta-data/instance-id"
    headers = {"X-aws-ec2-metadata-token": token}

    req = urllib.request.Request(url, headers=headers)

    try:
        response = urllib.request.urlopen(req)
        instance_id = response.read().decode()
        return instance_id
    except urllib.error.HTTPError as e:
        print(f"HTTPError: {e.code} - {e.reason}")
    except urllib.error.URLError as e:
        print(f"URLError: {e.reason}")
