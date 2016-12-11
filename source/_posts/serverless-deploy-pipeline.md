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



   
Notes:

 - All steps have to be idempotent.
 - using the preinstalled node/npm install from node env
 - the lambda stuff in the template repo should be moved to its folder / template  
 - lambdas sometimes seem to be run in parallel which should not happen in a pipeline env
Next steps:

 - Make the deploy pipeline code testable
 - multi account pipeline
 - website bucket should be created by the main template
 - the deployed lambdas are not versioned yet
 - js code: fix global chdirs
 
 - advantage of two pipelines: meta pipeline breakage does not break the app pipeline 
    