## Staging

This payload mirrors our staging environment today. There are two main concepts that I am looking for it to prove:
1) It will determine a solution where every model is scheduled on a GPU (since there is full capacity)
2) It has the logic to be able to determine that the 1 8xH200 node can run both large scale models (2 GPUs each at a minimum which is what we run today)

```
 bx cs workers --cluster d0il5lfw0095epreuhdg
OK
ID                                                       Primary IP      Flavor                State              Status                              Zone        Version                   Operating System
kube-d0il5lfw0095epreuhdg-inferenceus-edgerhc-000037ea   192.168.56.33   bx2.8x32              normal             Ready                               us-east-1   4.17.34_1545_openshift*   RHCOS
kube-d0il5lfw0095epreuhdg-inferenceus-edgerhc-0000380b   192.168.64.31   bx2.8x32              normal             Ready                               us-east-2   4.17.34_1545_openshift*   RHCOS
kube-d0il5lfw0095epreuhdg-inferenceus-edgerhc-00003c09   192.168.72.34   bx2.8x32              normal             Ready                               us-east-3   4.17.34_1545_openshift*   RHCOS
kube-d0il5lfw0095epreuhdg-inferenceus-general-00003bc5   192.168.72.33   bx2.8x32              normal             Ready                               us-east-3   4.17.34_1545_openshift*   RHCOS
kube-d0il5lfw0095epreuhdg-inferenceus-general-00003ded   192.168.64.34   bx2.8x32              normal             Ready                               us-east-2   4.17.34_1545_openshift*   RHCOS
kube-d0il5lfw0095epreuhdg-inferenceus-general-00003ee0   192.168.56.36   bx2.8x32              normal             Ready                               us-east-1   4.17.34_1545_openshift*   RHCOS
kube-d0il5lfw0095epreuhdg-inferenceus-h200rhc-00002fe7   192.168.72.31   gx3d.160x1792.8h200   normal             Ready                               us-east-3   4.17.33_1544_openshift*   RHCOS
kube-d0il5lfw0095epreuhdg-inferenceus-l40rhco-0000305f   192.168.64.28   gx3.24x120.l40s       normal             Ready                               us-east-2   4.17.34_1545_openshift*   RHCOS
kube-d0il5lfw0095epreuhdg-inferenceus-l40rhco-000031e1   192.168.64.29   gx3.24x120.l40s       normal             Ready                               us-east-2   4.17.34_1545_openshift*   RHCOS
kube-d0il5lfw0095epreuhdg-inferenceus-l40rhco-0000326f   192.168.64.30   gx3.24x120.l40s       normal             Ready                               us-east-2   4.17.34_1545_openshift*   RHCOS
kube-d0il5lfw0095epreuhdg-inferenceus-l40rhco-000033d5   192.168.56.30   gx3.24x120.l40s       normal             Ready                               us-east-1   4.17.34_1545_openshift*   RHCOS
kube-d0il5lfw0095epreuhdg-inferenceus-l40rhco-0000340c   192.168.56.31   gx3.24x120.l40s       normal             Ready                               us-east-1   4.17.34_1545_openshift*   RHCOS
kube-d0il5lfw0095epreuhdg-inferenceus-l40rhco-000035b9   192.168.56.32   gx3.24x120.l40s       normal             Ready                               us-east-1   4.17.34_1545_openshift*   RHCOS
```

And below gives an idea on how things are currently scheduled

```
kubectl get pods -n rhibm-models -o wide | grep decode
granite-3-1-8b-starter-decode-c87b74cdf-vwnz5        2/2     Running   0          16d   172.17.30.216   kube-d0il5lfw0095epreuhdg-inferenceus-l40rhco-000035b9   <none>           <none>
llama-3-1-8b-instruct-decode-5df54bb888-csmfj        2/2     Running   0          16d   172.17.4.24     kube-d0il5lfw0095epreuhdg-inferenceus-l40rhco-000033d5   <none>           <none>
llama-3-3-70b-instruct-decode-785f7b4598-rbtv6       2/2     Running   0          16d   172.17.49.127   kube-d0il5lfw0095epreuhdg-inferenceus-h200rhc-00002fe7   <none>           <none>
mistral-7b-instruct-v0-3-decode-68f644b94c-hnxts     2/2     Running   0          16d   172.17.0.216    kube-d0il5lfw0095epreuhdg-inferenceus-l40rhco-0000340c   <none>           <none>
mixtral-8x7b-instruct-v0-1-decode-5c4d4fb775-4d2g6   2/2     Running   0          16d   172.17.49.76    kube-d0il5lfw0095epreuhdg-inferenceus-h200rhc-00002fe7   <none>           <none>
```

I have modified the docker build and main program to model this case: currently the scheduling is off. It says 3 models cannot be scheduled at all (this may be that I need to properly set more parameters but I am not sure what to set for those values). Note the "no feasible allocation!" messages for 3 models when they can be scheduled.

```
Solution: 
c=Interactive; m=granite-3-1-8b-starter; rate=480; tk=1024; sol=1, alloc={acc=L40S; num=2; maxBatch=16; cost=64, val=70.4, servTime=2.5707726, waitTime=72.40845, rho=0.99991876}; slo-itl=40, slo-ttw=500, slo-tps=0 
s=Interactive-mixtral-8x7b-instruct-v0-1; c=Interactive; m=mixtral-8x7b-instruct-v0-1; no feasible allocation! 
s=Interactive-llama-3-3-70b-instruct; c=Interactive; m=llama-3-3-70b-instruct; no feasible allocation! 
c=Interactive; m=mistral-7b-instruct-v0-3; rate=480; tk=1024; sol=1, alloc={acc=L40S; num=4; maxBatch=16; cost=128, val=140.8, servTime=5.1415453, waitTime=144.8169, rho=0.99991876}; slo-itl=40, slo-ttw=500, slo-tps=0 
s=Interactive-llama-3-1-8b-instruct; c=Interactive; m=llama-3-1-8b-instruct; no feasible allocation! 
AllocationByType: 
name=L40S, count=6, limit=6, cost=192 
totalCost=192 
Solver: 
sName=Interactive-mixtral-8x7b-instruct-v0-1, allocDiff={  -> none, 0 -> 0, 0 } 
sName=Interactive-llama-3-3-70b-instruct, allocDiff={  -> none, 0 -> 0, 0 } 
sName=Interactive-mistral-7b-instruct-v0-3, allocDiff={  -> L40S, 0 -> 4, 128 } 
sName=Interactive-llama-3-1-8b-instruct, allocDiff={  -> none, 0 -> 0, 0 } 
sName=Interactive-granite-3-1-8b-starter, allocDiff={  -> L40S, 0 -> 2, 64 } 
Solution time: 0 msec
```

How I have ran experiments:
```
podman build --arch amd64 -f Dockerfile -t tylertestrun
podman run -it --entrypoint bash localhost/tylertestrun:latest
root@cbef3cce4d54:/# /bin/demomain 
Solution: 
c=Interactive; m=mixtral-8x7b-instruct-v0-1; rate=120; tk=1024; sol=1, alloc={acc=8xH200; num=1; maxBatch=32; cost=40, val=44, servTime=2.3485954, waitTime=0, rho=0.9889076}; slo-itl=40, slo-ttw=500, slo-tps=0 
s=Interactive-llama-3-3-70b-instruct; c=Interactive; m=llama-3-3-70b-instruct; no feasible allocation! 
c=Interactive; m=mistral-7b-instruct-v0-3; rate=480; tk=1024; sol=1, alloc={acc=L40S; num=4; maxBatch=16; cost=128, val=140.8, servTime=5.1415453, waitTime=144.8169, rho=0.99991876}; slo-itl=40, slo-ttw=500, slo-tps=0 
s=Interactive-llama-3-1-8b-instruct; c=Interactive; m=llama-3-1-8b-instruct; no feasible allocation! 
c=Interactive; m=granite-3-1-8b-starter; rate=480; tk=1024; sol=1, alloc={acc=L40S; num=2; maxBatch=16; cost=64, val=70.4, servTime=2.5707726, waitTime=72.40845, rho=0.99991876}; slo-itl=40, slo-ttw=500, slo-tps=0 
AllocationByType: 
name=H200, count=8, limit=8, cost=40 
name=L40S, count=6, limit=6, cost=192 
totalCost=232 
Solver: 
sName=Interactive-mixtral-8x7b-instruct-v0-1, allocDiff={  -> 8xH200, 0 -> 1, 40 } 
sName=Interactive-llama-3-3-70b-instruct, allocDiff={  -> none, 0 -> 0, 0 } 
sName=Interactive-mistral-7b-instruct-v0-3, allocDiff={  -> L40S, 0 -> 4, 128 } 
sName=Interactive-llama-3-1-8b-instruct, allocDiff={  -> none, 0 -> 0, 0 } 
sName=Interactive-granite-3-1-8b-starter, allocDiff={  -> L40S, 0 -> 2, 64 } 
Solution time: 0 msec
```