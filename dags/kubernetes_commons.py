from airflow.contrib.kubernetes.volume import Volume
from airflow.contrib.kubernetes.volume_mount import VolumeMount

# Default affinity for tasks running in k8s cluster
my_affinity = {
    "nodeAffinity": {
        "requiredDuringSchedulingIgnoredDuringExecution": {
            "nodeSelectorTerms": [{
                    "matchExpressions": [{
                            "key": "dedicated",
                            "operator": "In",
                            "values": ["test"]
                        }]
                }]
        }
    }
}

# Default tolerations for tasks running in k8s cluster
my_tolerations = [
    {
        "effect": "NoExecute",
        "key": "dedicated",
        "operator": "Equal",
        "value": "test"
    }
]

# Default resources for tasks running in k8s cluster
my_resources = {
    'limit_cpu': '500m',
    'limit_memory': '512Mi',
    'request_cpu': '500m',
    'request_memory': '512Mi'
}
