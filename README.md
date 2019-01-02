This is a sample that uses multiple CloudFormation Stacks in the serverless framework.
Share API Gateway and Custom Authorizer on multiple stacks.
It can avoid the limit of 200 resources of CloudFormation Stack.

```
.
├── setup.sh        ... Build a confirmation environment.
├── buildspec.yml   ... For CodeBuild. Do serverless deploy.
├── api-gateway     ... API Gateway stack. Share API Gateway and Custom Authorizer.
├── service-hello   ... Lambda stack. Use API Gateway and Custom Authorizer.
└── service-goodbye ... Lambda stack. Use API Gateway and Custom Authorizer.
```

Build a confirmation environment.

```bash
$ ./setup.sh
```

serverless framework - API Gateway - Share API Gateway and API Resources  
https://serverless.com/framework/docs/providers/aws/events/apigateway/#share-api-gateway-and-api-resources

serverless framework - API Gateway - Share Authorizer  
https://serverless.com/framework/docs/providers/aws/events/apigateway/#share-authorizer

Sharing API Gateway and Authorizer  
http://blog.maxieduncan.co.nz/aws/2018/06/23/sharing-api-gateway-and-authorizer

Splitting your Serverless Framework API on AWS  
https://www.gorillastack.com/news/splitting-your-serverless-framework-api-on-aws/
