/**
 * PayTrack Event Processor Lambda
 * Consumes messages from the SQS queue and writes processed events to DynamoDB.
 */

const { DynamoDBClient, PutItemCommand } = require("@aws-sdk/client-dynamodb");

const ddb = new DynamoDBClient({});
const TABLE_NAME = process.env.DYNAMODB_TABLE;

exports.handler = async (event) => {
  console.log("Received event:", JSON.stringify(event, null, 2));

  const results = [];

  for (const record of event.Records) {
    const body = JSON.parse(record.body);
    console.log("Processing message:", body);

    const params = {
      TableName: TABLE_NAME,
      Item: {
        PK: { S: `EVENT#${body.id || Date.now()}` },
        SK: { S: `PROCESSED#${new Date().toISOString()}` },
        payload: { S: JSON.stringify(body) },
        processedAt: { S: new Date().toISOString() },
      },
    };

    try {
      await ddb.send(new PutItemCommand(params));
      results.push({ messageId: record.messageId, status: "ok" });
    } catch (err) {
      console.error("Failed to write to DynamoDB:", err);
      results.push({ messageId: record.messageId, status: "error", error: err.message });
    }
  }

  return { batchItemFailures: results.filter((r) => r.status === "error").map((r) => ({ itemIdentifier: r.messageId })) };
};
