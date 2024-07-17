# Proxy C2

### Summary

The code found within each of these files are intended to be compiled and hosted on your own public cloud infrastructure. The design is to take input from you C2 Server, push the commands through the serverless functions(this directory), to the client C2 applications. Upon receipt and execution of the commands the client will return the responses/output back to the proxy(FaaS) back to the C2 Server. This is to provide a more portable way to deploy reuse the same applications without recompiling the clients or server for each engagement.

### Traffic Flow

C2 Server -> Serverless Proxy -> C2 Client

Then

C2 Client -> Serverless Proxy -> C2 Server

## Prerequisites

```
1) Cloud Account
2) Permission to conduct this type of test
3) Some basic cloud familiarity
4) Ability to compile Rust, Go, C# Binaries
5) Signed ROE/SOW
6) A lawyer would be nice too...
```

## Supported Clouds

Since there are a multitude of cloud companies and services, we have chosen to focus on the Big 3 _[GCP,Azure,AWS]_. We have included the proxies in multiple formats to allow operators to quickly deploy onto the services. The initial focus is to deploy these using Go code to, but Python and Powershell code will be added in the future to allow for a greater range of deployment options

###

## License/Notes

### Modification/Multiple Engagements

Additionally, if this is to be used across multiple customers, some modification will be required to not retain sensitive data. Our preference is to create individual instances of this framework **per-customer, per-engagement.**

### Warranties/Warnings
This code is designed to assist authorized Red-Teamers and "White Hats" test organizations within a defined set of Rules of Engagement and Statement of Work. This is not intended to be used within unauthorized or malicious campaigns that may degrade or otherwise harm an individual or business. All code within this project is provided without warranty and without any specific expectation of success. Cyberscythe LLC frequently uploads samples to online AV vendors/analysis programs to aid "Blue-Teams" in detecting this behavior. 