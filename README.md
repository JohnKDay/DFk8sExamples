# Deepfactor Instrumentation of pods using different Kubernetes constructs

## Table of Contents
* [Construct](#Construct)
* [Requirements](#Requirements)
* [Deployment](#Deployment)
* [Results](#Results)
* [CleanUp](#CleanUp)
-------------------------------
<br><br>

### Construct

Workloads on Kubernetes are deployed using Pods. According to the Kubernetes
documentation, "Pods are the smallest deployable units of computing that you can
create and manage in Kubernetes".
 
Applications/workloads can be deployed via 4 different constructs by using their
respective YAML decalarations :
* [Pod](https://kubernetes.io/docs/concepts/workloads/pods/)
* [Deployments](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/)
* [StatefulSet](https://kubernetes.io/docs/concepts/workloads/controllers/statefulset/)
* [DaemonSet](https://kubernetes.io/docs/concepts/workloads/controllers/daemonset/) 
 
 
Aside from Pod YAML declaration, all other constructs can deploy multiple
replicas(by launching multiple pods) and manage them. For example, in the case of
'Statefulsets' and 'Deployments', one can set the **`replicas`**  key in the YAML
to have multiple pods. In the case of 'DaemonSet', a Pod will be deployed on each worker
node in the cluster.
 
Pod anti-affinity is one of the policies that can also be used to ensure that the
Pods are deployed on different nodes in the k8s cluster.
 
Each of the declarations can also include the use of a [PVC](https://kubernetes.io/docs/concepts/storage/persistent-volumes/#persistentvolumeclaims) (Persistent Volume Claim) using a
storage class or a default storage class available for the cluster.
In this demo case, the Longhorn [StorageClass](https://kubernetes.io/docs/concepts/storage/storage-classes/) is used as the default storageclass.
This allows for the creation of `ReadWriteOnce` as well as `ReadWriteMany`, which is
required for multiple pods to read/write to the volumes as needed by both the
DaemonSet and DeploymentSet. 

<br><br>  

### Requirements
To run a full test the following is required of the Kubernetes cluster:
* Running K8s version 1.18 (tested)
* DeepFactor webhook deployed to cluster
* Multiple worker nodes
* A default StorageClass that can create volumes with **`ReadWriteMany`** access
mode  
<br><br>

### Deployment

1. Clone repository from github.  
`git clone https://github.com/johnkday/DF-instrument-examples`
2. Change directory into **glibc** directory.   
`cd glibc`
3. Replace the **`<Your Token Here>`** in each of the `.yaml` files with
your own DeepFactor Run Token.  
`kubectl apply -f .`
4. Apply all of the workloads to the cluster.  
`kubectl apply -f .`
5. Watch the cluster deploy.  
`watch kubectl get all,pvc`
<br><br>

### Results
The pod `Init` to instrument with DeepFactor should occur for every pod and then
run appropriately by its intended design and should look something like:
<br>
```
NAME                                     READY   STATUS    RESTARTS   AGE
pod/daemon-counter-7z6zl                 1/1     Running   0          5m51s
pod/daemon-counter-w7kf9                 1/1     Running   0          5m51s
pod/deployment-counter-ff7b5c554-2b5sj   1/1     Running   0          5m51s
pod/deployment-counter-ff7b5c554-4mq7k   1/1     Running   0          5m51s
pod/pod-counter                          1/1     Running   0          5m51s
pod/statefulset-counter-0                1/1     Running   0          5m50s
pod/statefulset-counter-1                1/1     Running   0          4m37s

NAME                            DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR   AGE
daemonset.apps/daemon-counter   2         2         2       2            2           <none>          5m51s

NAME                                 READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/deployment-counter   2/2     2            2           5m51s

NAME                                           DESIRED   CURRENT   READY   AGE
replicaset.apps/deployment-counter-ff7b5c554   2         2         2       5m51s

NAME                                   READY   AGE
statefulset.apps/statefulset-counter   2/2     5m51s

NAME                                                              STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS   AGE
persistentvolumeclaim/daemon-counter                              Bound    pvc-b7b2ade7-97aa-41f0-9282-53b955c69c97   50Mi       RWX            longhorn       5m51s
persistentvolumeclaim/deployment-counter                          Bound    pvc-14cde128-169c-42f2-b673-6b1d839ce7b5   50Mi       RWX            longhorn       5m51s
persistentvolumeclaim/pod-counter                                 Bound    pvc-c3968da4-06fe-497e-97da-2e37284e0977   50Mi       RWX            longhorn       5m51s
persistentvolumeclaim/statefulset-counter-statefulset-counter-0   Bound    pvc-7bd089ba-73af-4e85-8e62-9cbab660a228   50Mi       RWO            longhorn       5m51s
persistentvolumeclaim/statefulset-counter-statefulset-counter-1   Bound    pvc-ed286011-8190-41cb-8674-aa9ac6b13737   50Mi       RWO            longhorn       4m37s
```
<br>
All of the DeepFactor alerts in the portal should be the same:

![Main Dashboard](images/DeepFactorK8sYAMLs.png "Main Dashboard")

<br><br>

![Pod](images/DeepFactorK8sYAMLs-Pod.png "Pod")

<br><br>

![Deployment](images/DeepFactorK8sYAMLs-Deployment.png "Deployment")

<br><br>

![StatefulSet](images/DeepFactorK8sYAMLs-StatefulSet.png "StatefulSet")

<br><br>

![DaemonSet](images/DeepFactorK8sYAMLs-DaemonSet.png)

<br><br>

### CleanUp
<br>
1. Delete the setup using the command:  
`kubectl delete -f .`
2. StatefulSet volumes will not delete when they become unbound and therefore
must have an explict call to delete them
`kubectl get pvc -o name | xargs kubectl delete`
