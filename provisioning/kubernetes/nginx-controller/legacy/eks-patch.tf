resource "kubernetes_manifest" "eks_nginx_controller_patch" {
  provider = kubernetes-alpha

  manifest = {
    "spec" = {
      "template" : {
        "spec" : {
          "containers" : [{
            "name" : "kube-proxy",
            "command" : [
              "kube-proxy",
              "--hostname-override=$(NODE_NAME)",
              "--v=2",
              "--config=/var/lib/kube-proxy-config/config"
            ],
            "env" : [{
              "name" : "NODE_NAME",
              "valueFrom" : {
                "fieldRef" : {
                  "apiVersion" : "v1",
                  "fieldPath" : "spec.nodeName"
                }
              }
            }]
          }]
        }
      }
    }
  }
}