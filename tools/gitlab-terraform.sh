terraform init \
    -backend-config="address=https://gitlab.com/api/v4/projects/${GITLAB_PROJECT_ID}/terraform/state/${TF_VAR_app_name}-${TF_VAR_app_namespace}-${TF_VAR_tfenv}" \
    -backend-config="lock_address=https://gitlab.com/api/v4/projects/${GITLAB_PROJECT_ID}/terraform/state/${TF_VAR_app_name}-${TF_VAR_app_namespace}-${TF_VAR_tfenv}/lock" \
    -backend-config="unlock_address=https://gitlab.com/api/v4/projects/${GITLAB_PROJECT_ID}/terraform/state/${TF_VAR_app_name}-${TF_VAR_app_namespace}-${TF_VAR_tfenv}/lock" \
    -backend-config="username=$GITLAB_USERNAME" \
    -backend-config="password=$GITLAB_TOKEN" \
    -backend-config="lock_method=POST" \
    -backend-config="unlock_method=DELETE" \
    -backend-config="retry_wait_min=5"