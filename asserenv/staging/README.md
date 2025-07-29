# Optimization results

## Accelerators

Accelerators are the allocatable entities to a vllm server instance (pod). An accelerator may consist of one or more cards (devices or types), so that a large model may fit on multiple cards, or for performance reasons. For example a `2xH200` is an accelerator with two `H200` cards.

Following is some sample (arbitrary) data.

| Accelerator | Type | Multiplicity | Memory (GB) | Cost (c/hr) |
| --- | :---: | :---: | :---: | --- |
| L40S | L40S | 1 | 48 | 32 |
| H200 | H200 | 1 | 141 | 120 |
| 2xH200 | H200 | 2 | 282 | 240 |
| 4xH200 | H200 | 4 | 564 | 480 |

## Availability of accelerator types

| Type | Count |
| --- | --- |
| L40S | 6 |
| H200 | 8 |

## Models

It is assumed that for each model and accelerator pair, benchmarking experiments are conducted to determine

- token generation time as a function of concurrently running requests (batch size), which is assumed to be linear as: `alpha + beta * n` , where `n` is the batch size,  (units in msecs), and
- observed maximum batch size (MBS) at a given request length (number of tokens), beyond which performance deteriorates.

We may also have a `count` of accelerators more than one, accounting for the case of parallelism.

The provided list of model and accelerator pairs are assumed to be the set of feasible combinations.

(Note that we also have a version of a model tuner which estimates the above data dynamically based on observations.)

Following is some sample (arbitrary) data.

| Model | Accelerator | Count | Alpha | Beta | MBS | Tokens |
| --- | :---: | :---: | :---: | :---: | :---: | --- |
| granite-3-1-8b-starter |  |  |  |  |  |  |
|  | L40S | 1 | 6.0 | 0.5 | 24 | 512 |
|  | H200 | 1 | 1.2 | 0.1 | 96 | 512 |
| llama-3-1-8b-instruct |  |  |  |  |  |  |
|  | L40S | 1 | 6.0 | 0.5 | 24 | 512 |
|  | H200 | 1 | 1.2 | 0.1 | 96 | 512 |
| mistral-7b-instruct-v0-3 |  |  |  |  |  |  |
|  | L40S | 1 | 6.0 | 0.5 | 24 | 512 |
|  | H200 | 1 | 1.2 | 0.1 | 96 | 512 |
| llama-3-3-70b-instruct |  |  |  |  |  |  |
|  | 2xH200 | 1 | 6.0 | 0.20 | 64 | 512 |
|  | 4xH200 | 1 | 4.0 | 0.13 | 96 | 512 |
| mixtral-8x7b-instruct-v0-1 |  |  |  |  |  |  |
|  | H200 | 1 | 4.0 | 0.15 | 64 | 512 |
|  | 2xH200 | 1 | 2.67 | 0.05 | 96 | 512 |

## Service classes

The experiment assumes a single class of service `Interactive` with `slo-itl=40` and `slo-ttw=500`, msecs.

## Solution

| Server | Accelerator | numReplicas | MBS | Rate (req/min) | avgTokens |
| --- | :---: | :---: | :---: | :---: | --- |
| granite-3-1-8b-starter | H200 | 1 | 48 | 150 | 1024 |
| llama-3-1-8b-instruct| L40S | 1 | 24 | 120 | 512 |
| mistral-7b-instruct-v0-3 | L40S | 1 | 48 | 90 | 256 |
| llama-3-3-70b-instruct | 4xH200 | 1 | 32 | 120 | 1536 |
| mixtral-8x7b-instruct-v0-1 | H200 | 1 | 32 | 120 | 1024 |

| Type | Used | Count |
| --- | :---: | --- |
| L40S | 2 | 6 |
| H200 | 6 | 8 |

## Logs

```
Solution: 
c=Interactive; m=mixtral-8x7b-instruct-v0-1; rate=120; tk=1024; sol=2, alloc={acc=H200; num=1; maxBatch=32; cost=120, val=132, servTime=5.990156, waitTime=0.08544922, rho=0.9999611}; slo-itl=40, slo-ttw=500, slo-tps=0 
c=Interactive; m=llama-3-3-70b-instruct; rate=120; tk=1536; sol=2, alloc={acc=4xH200; num=1; maxBatch=32; cost=480, val=528, servTime=6.8634706, waitTime=104.65332, rho=0.9999999}; slo-itl=40, slo-ttw=500, slo-tps=0 
c=Interactive; m=mistral-7b-instruct-v0-3; rate=90; tk=256; sol=2, alloc={acc=L40S; num=1; maxBatch=48; cost=32, val=35.2, servTime=8.044555, waitTime=0, rho=0.93743265}; slo-itl=40, slo-ttw=500, slo-tps=0 
c=Interactive; m=llama-3-1-8b-instruct; rate=120; tk=512; sol=2, alloc={acc=L40S; num=1; maxBatch=24; cost=32, val=35.2, servTime=13.268162, waitTime=83.21289, rho=0.9999115}; slo-itl=40, slo-ttw=500, slo-tps=0 
c=Interactive; m=granite-3-1-8b-starter; rate=150; tk=1024; sol=2, alloc={acc=H200; num=1; maxBatch=48; cost=120, val=132, servTime=1.7473118, waitTime=0, rho=0.9785983}; slo-itl=40, slo-ttw=500, slo-tps=0 
AllocationByType: 
name=H200, count=6, limit=8, cost=720 
name=L40S, count=2, limit=6, cost=64 
totalCost=784 
Solver: 
sName=Interactive-granite-3-1-8b-starter, allocDiff={  -> H200, 0 -> 1, 120 } 
sName=Interactive-mixtral-8x7b-instruct-v0-1, allocDiff={  -> H200, 0 -> 1, 120 } 
sName=Interactive-llama-3-3-70b-instruct, allocDiff={  -> 4xH200, 0 -> 1, 480 } 
sName=Interactive-mistral-7b-instruct-v0-3, allocDiff={  -> L40S, 0 -> 1, 32 } 
sName=Interactive-llama-3-1-8b-instruct, allocDiff={  -> L40S, 0 -> 1, 32 } 
Solution time: 0 msec
```
