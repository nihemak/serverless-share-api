import { APIGatewayProxyHandler } from 'aws-lambda';

export function authorize(event: any, context: any, cb: any) {
  console.log("Auth function invoked");

  if (event.authorizationToken) {
    const principalId = event.authorizationToken;
    const tmp = event.methodArn.split(":");
    const apiGatewayArnTmp = tmp[5].split("/");
    const awsAccountId = tmp[4];
    const region = tmp[3];
    const restApiId = apiGatewayArnTmp[0];
    const stage = apiGatewayArnTmp[1];
    const resourceArn = `arn:aws:execute-api:${region}:${awsAccountId}:${restApiId}/${stage}/*/*`;
    const policy = {
      principalId,
      policyDocument: {
        Version: "2012-10-17",
        Statement: [
          {
            Action: "execute-api:Invoke",
            Effect: "Allow",
            Resource: [resourceArn]
          }
        ]
      }
    };
    cb(null, policy);
  } else {
    console.log("No authorizationToken found in the header.");
    cb("Unauthorized");
  }
}

export const hello: APIGatewayProxyHandler = async (event, context) => {
  return {
    statusCode: 200,
    body: JSON.stringify({
      message: 'Go Serverless Webpack (Typescript) v1.0! Your function executed successfully!',
      input: event,
    }),
  };
}
