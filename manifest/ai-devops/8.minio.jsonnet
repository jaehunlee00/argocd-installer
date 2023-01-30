function (    
    is_offline="false",
    private_registry="172.22.6.2:5000",    
    custom_domain_name="tmaxcloud.org",    
    tmax_client_secret="tmax_client_secret",
    hyperauth_url="172.23.4.105",
    hyperauth_realm="tmax",
    console_subdomain="console",    
    gatekeeper_log_level="info",    
    gatekeeper_version="v1.0.2"
)

local target_registry = if is_offline == "false" then "" else private_registry + "/";
[
    {
        "apiVersion": "apps/v1",
        "kind": "Deployment",
        "metadata": {
            "labels": {
            "app": "minio",
            "app.kubernetes.io/component": "minio",
            "app.kubernetes.io/name": "minio"
            },
            "name": "minio",
            "namespace": "kubeflow"
        },
        "spec": {
            "selector": {
            "matchLabels": {
                "app": "minio",
                "app.kubernetes.io/component": "minio",
                "app.kubernetes.io/name": "minio"
            }
            },
            "strategy": {
            "type": "Recreate"
            },
            "template": {
            "metadata": {
                "annotations": {
                "sidecar.istio.io/inject": "false"
                },
                "labels": {
                "app": "minio",
                "app.kubernetes.io/component": "minio",
                "app.kubernetes.io/name": "minio"
                }
            },
            "spec": {
                "containers": [
                {
                    "args": [
                    "server",
                    "/data"
                    ],
                    "env": [
                    {
                        "name": "MINIO_ACCESS_KEY",
                        "valueFrom": {
                        "secretKeyRef": {
                            "key": "accesskey",
                            "name": "mlpipeline-minio-artifact"
                        }
                        }
                    },
                    {
                        "name": "MINIO_SECRET_KEY",
                        "valueFrom": {
                        "secretKeyRef": {
                            "key": "secretkey",
                            "name": "mlpipeline-minio-artifact"
                        }
                        }
                    }
                    ],
                    "image": std.join("", [target_registry, "docker.io/minio/minio:RELEASE.2023-01-20T02-05-44Z"]),
                    "name": "minio",
                    "ports": [
                    {
                        "containerPort": 9000
                    }
                    ],
                    "volumeMounts": [
                    {
                        "mountPath": "/data",
                        "name": "data",
                        "subPath": "minio"
                    }
                    ]
                }
                ],
                "volumes": [
                {
                    "name": "data",
                    "persistentVolumeClaim": {
                    "claimName": "minio-pvc"
                    }
                }
                ]
            }
            }
        }
    }
]    