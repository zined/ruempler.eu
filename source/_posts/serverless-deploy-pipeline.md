---
title: "Serverless everything: One-click serverless deployment pipeline for a serverless app"
date: 2016-12-01
---

A blueprint for serverless applications.

## Problem statement

- build a deploy pipeline for a sample serverless web app consisting of only AWS components (except for Github).
- codified and automated and can be provisioned with a one-click CloudFormation template which bootstraps everything.
- use Lambda for the build steps, and it will utilize the Serverless framework to deploy the actual app.
- the example is minimalistic in order to focus on the "red tape"


- Time to market is more important than ever today. Prototypes ...
- a good boilerplate template to start a new app  
- comes with a rudimentary deploy pipeline ( to have a codified deployment from the beginning on)

## Why

 - less complexity through fewer services
 - everything is codified, no snowflake knowledge
 


## Bootstrapping

The inception point for our app will be a one-click CloudFormation template. What does one-click mean? It means that you click on the link, fill in some parameters and then the bootstrapping of your app will be started. Everything is codified, no manual (and undocumented) resource handling. No "works on my machine". 

It will:

 - Install a Deployment pipeline with the following steps:
   1. Checkout the Source
   2. Deploy the basic infrastructure, e.g. a S3 bucket, a Cloudfront CDN, and a certificate and a Route53 record. We will use the newly added CloudFormation step for this
   3. A Lambda function which installs the Serverless framework and and deploys the serverless app found in the repo
   
Ok, step by step.

This project actually consists of two


   
Notes:

 - All steps have to be idempotent.
 - This example has no staging/testing steps, You could easily add a test environment to the steps (see aws blog) 
 - Nothing has to be executed from the developers' machines (works on my machine)
 - Deployment of the pipeline itself and the app are separated: the pipeline could update itself into a broken state
 - Updating the deploy pipeline is currently a separate step (muenchhausen)
 - No hardcoded access keys
 - currently running with root access
 - to save time, we will create the infrastructure in CFN, not in serverless framework, so we lower the risk to run into Lambda maximum execution time
 - Its an experiment. Let's see how far we can go by using AWS technologies exclusively
 - Make use of Lambda caching
 - Stuff like downloading nodejs could be outsourced to another pipeline step and become an artifact
 - using the preinstalled node/npm install from node env
 - inline lambda looks a bit ugly, but it has the advantage that the pipeline logic is in one file and not scattered across ZIP files in S3 buckets. YMMV
 - we could save time by using prebundled Lambda functions which do not need to "npm install", this might also lead to fewer lines of code because we could use more libraries, e.g. for mime type detection 
 - the JS code is more a spike/POC and not high quality
 - it actually consists of two pipelines
 
 - if you don't trust me, you can role your own meta-pipeline
 - the lambda stuff in the template repo should be moved to its folder / template  
 - serverless framework in meta pipeline is just used for deploying the lambda (convenience)
 
Next steps:

 - Make the deploy pipeline code testable
    