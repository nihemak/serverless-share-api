import { APIGatewayProxyHandler } from 'aws-lambda';
import { greeting } from "./common/greeting";

export const goodbye: APIGatewayProxyHandler = async (event, context) => {
  return {
    statusCode: 200,
    body: JSON.stringify({
      message: greeting('Good Bye'),
      input: event,
    }),
  };
}
