## aws tools
Include kubectl, aws and eksctl. You need your own credentials file to build this container.

A sample `credentials` file.
```
[default]
aws_access_key_id = xxxx
aws_secret_access_key = xxx
```

```
# copy your credentials
docker build . -t aws
docker run -it aws bash
# get kubectl config
aws eks update-kubeconfig   --region us-west-2   --name lincai20210202
```

# aws SSO usage
Installed tfswitch and yawsso for terraform and aws SSO.

```
aws configure sso
yawsso login
```