import { APIGatewayProxyHandler } from 'aws-lambda';

export const goodbye: APIGatewayProxyHandler = async (event, context) => {
  return {
    statusCode: 200,
    body: JSON.stringify({
      message: 'Good Bye! Your function executed successfully!',
      input: event,
    }),
  };
}
