Idea behind this iteration:

Two things building off the previous modeling of our environment

1) I am now trying to model the fact that we have accelerator nodes spread across availability zones
2) I am based off understanding of your PR Asser trying to ensure I model the fact that every model (can work on if this is necessary or not) can go from it's minimum size to really consuming an entire node (you will see for example granite-3-1-8b-starter can be assigned to a l40, 1 h200, 2 h200s, all the way up to 8 h200s,). Mixtral 8x7b since it's estimated to need 100+ gigs of total GPU memory can go to 1 h200 all the way to 8 h200s (and the system can choose for that to be multiple replicas or just 1 replica for one model).

I am doing some sampling generating data..... right now and then will look more closely at actually figuring out a way to get these values from what we will have available in our system (we should be able to get any value: we can have a whole history (note for foerver but for enough time of chats coming in and get analytics on the rate/number of tokens/anything else we need)). But right now what I am just checking to validate is that does this still make sense to you this going from one availability zone to 3 availability zones and then additionally dynamically stating hey technically in my accelerator spot when I have a node that has 8 accelerators I can have multipliticy 1 to 8 and I want to let the "brains" (this scheduler optimizer) know it has all options on the table to make the best decision. TBD on how still to adjust batch size, and the other parameters I will need to adjust as we state all the splits.


Results look promising:
```
Solution: 
c=Interactive; m=granite-3-1-8b-starter; rate=10; tk=1024; sol=10, alloc={acc=us-east-2/gx3.24x120.l40s/l40s/1; num=1; maxBatch=32; cost=32, val=35.2, servTime=2.0813124, waitTime=0, rho=0.2976938}; slo-itl=10, slo-ttw=500, slo-tps=0 
c=Interactive; m=mixtral-8x7b-instruct-v0-1; rate=10; tk=1024; sol=8, alloc={acc=us-east-3/gx3d.160x1792.8h200/h200/1; num=1; maxBatch=32; cost=40, val=44, servTime=2.0813124, waitTime=0, rho=0.2976938}; slo-itl=10, slo-ttw=500, slo-tps=0 
AllocationByType: 
name=l40s, count=1, limit=6, cost=32 
name=h200, count=1, limit=8, cost=40 
totalCost=72 
Solver: 
sName=Interactive/mixtral-8x7b-instruct-v0-1, allocDiff={  -> us-east-3/gx3d.160x1792.8h200/h200/1, 0 -> 1, 40 } 
sName=Interactive/granite-3-1-8b-starter, allocDiff={  -> us-east-2/gx3.24x120.l40s/l40s/1, 0 -> 1, 32 } 
Solution time: 0 msec
```


```
{
  "allocations": {
    "Interactive/granite-3-1-8b-starter": {
      "accelerator": "us-east-2/gx3.24x120.l40s/l40s/1",
      "numReplicas": 1,
      "maxBatch": 32,
      "cost": 32,
      "itlAverage": 2.0813124,
      "waitAverage": 0,
      "load": {
        "arrivalRate": 10,
        "avgLength": 1024,
        "arrivalCOV": 0,
        "serviceCOV": 0
      }
    },
    "Interactive/mixtral-8x7b-instruct-v0-1": {
      "accelerator": "us-east-3/gx3d.160x1792.8h200/h200/1",
      "numReplicas": 1,
      "maxBatch": 32,
      "cost": 40,
      "itlAverage": 2.0813124,
      "waitAverage": 0,
      "load": {
        "arrivalRate": 10,
        "avgLength": 1024,
        "arrivalCOV": 0,
        "serviceCOV": 0
      }
    }
  }
}
```