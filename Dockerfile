ARG PROJECT="gitlab.com/magnetic-asia/technology/infrastructure-eks-terraform"
ARG TFSEC_VERSION=v0.39.23

FROM registry.gitlab.com/technology-utilities/kubectl:1.21.6 as kubectl_builder
FROM registry.gitlab.com/gitlab-org/terraform-images/stable:latest as gitlab_bulder

FROM golang:1.15-alpine3.12 AS tfutils_builder

RUN apk add --no-cache make git
WORKDIR /build

RUN git clone https://github.com/jrhouston/tfk8s.git && \
    cd tfk8s && make

FROM registry.gitlab.com/technology-utilities/terraform:1.0.9

ARG PROJECT
ARG TFSEC_VERSION
LABEL project=https://$PROJECT
ENV HELM_VERSION="3.3.1"
ENV HELM_REPOSITORY_CONFIG="/deploy/terraform_repo_eks/provisioning/kubernetes/repositories.yaml"

WORKDIR /deploy

RUN apk --no-cache add --update jq aws-cli bash git vim curl gawk unzip python3 py3-pip go perl make wget
RUN wget -qO- https://get.helm.sh/helm-v$HELM_VERSION-linux-amd64.tar.gz | tar xvz -C /usr/bin/ --strip=1 linux-amd64/helm
RUN wget --progress=dot:mega https://github.com/FiloSottile/mkcert/releases/download/v1.4.1/mkcert-v1.4.1-linux-amd64 -O /usr/bin/mkcert && chmod +x /usr/bin/mkcert
RUN wget --progress=dot:mega https://amazon-eks.s3.us-west-2.amazonaws.com/1.18.9/2020-11-02/bin/linux/amd64/aws-iam-authenticator -O /usr/bin/aws-iam-authenticator && chmod +x /usr/bin/aws-iam-authenticator
RUN wget --progress=dot:mega -O /usr/bin/tfsec https://github.com/tfsec/tfsec/releases/download/${TFSEC_VERSION}/tfsec-linux-amd64 && chmod +x /usr/bin/tfsec

RUN curl -L "$(curl -s https://api.github.com/repos/terraform-docs/terraform-docs/releases/latest | grep -o -E "https://.+?-linux-amd64.tar.gz")" > terraform-docs.tgz && tar xzf terraform-docs.tgz && chmod +x terraform-docs && mv terraform-docs /usr/bin/
RUN curl -L "$(curl -s https://api.github.com/repos/terraform-linters/tflint/releases/latest | grep -o -E "https://.+?_linux_amd64.zip")" > tflint.zip && unzip tflint.zip && rm tflint.zip && mv tflint /usr/bin/
RUN env GO111MODULE=on go get -u github.com/aquasecurity/tfsec/cmd/tfsec
RUN pip3 install --no-cache-dir pre-commit

COPY --from=gitlab_bulder /usr/bin/gitlab-terraform /usr/bin/gitlab-terraform
COPY --from=kubectl_builder /usr/local/bin/kubectl /usr/bin/kubectl
COPY --from=tfutils_builder /build/tfk8s/tfk8s /usr/bin/tfk8s
COPY . ./terraform_repo_eks

RUN helm repo update

# USER deploy
WORKDIR /deploy/terraform_repo_eks
