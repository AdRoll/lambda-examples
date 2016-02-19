#!/usr/bin/env python
import logging, urllib2, random, gzip, cStringIO, base64, json
import boto3


# change these according to ../server-housekeeping/env.sh:
REGION = 'us-east-1'
TABLE = 'Test_lambda-example'
QUEUE_PREFIX = 'lambda-example_'


def lambda_handler(event, context):
    logging.basicConfig()
    logging.getLogger().setLevel(logging.INFO)
    logging.getLogger('botocore').setLevel(logging.WARN)

    uri = event['uri']

    worker = find_worker()
    logging.info('selected worker {}'.format(worker))

    (queue_region, queue_url) = find_queue(worker)

    logging.info('fetching {}'.format(uri))
    try:
        result = urllib2.urlopen(urllib2.Request(uri))
    except urllib2.HTTPError as result:
        pass
    if result.getcode() not in range(200, 300):
        logging.error('bad fetch result: {}'.format(result.getcode()))
        return {'status': 'failed to fetch (code {})'.format(result.getcode())}

    buf = cStringIO.StringIO()
    with gzip.GzipFile(fileobj=buf, mode='w') as fd:
        print >>fd, result.read()

    data = json.dumps({'uri': uri,
                       'data': base64.b64encode(buf.getvalue())})

    boto3.client('sqs', region_name=queue_region) \
         .send_message(**{'QueueUrl': queue_url,
                          'MessageBody': data})
    logging.info('dispatched work to {} ({} bytes)'.format(worker['instance_id'], len(data)))

    return {'status': 'dispatched {} bytes to {} for processing'.format(len(data),
                                                                        worker['instance_id'])}


def find_worker():
    result = boto3.resource('dynamodb', region_name=REGION) \
                  .Table(TABLE) \
                  .scan(**{'ProjectionExpression': '#region, #id',
                           'ExpressionAttributeNames': {'#region': 'Region',
                                                        '#id': 'InstanceID'}})
    item = random.choice(result['Items'])
    return {'instance_id': item['InstanceID'],
            'region': item['Region']}


def find_queue(worker):
    queue_name = '{}{}'.format(QUEUE_PREFIX, worker['instance_id'])

    c = boto3.client('sqs', region_name=worker['region'])
    queue_url = c.get_queue_url(**{'QueueName': queue_name})['QueueUrl']
    logging.info('queue url: {}'.format(queue_url))
    return (worker['region'], queue_url)


if '__main__' == __name__:
    lambda_handler({'uri': 'http://adroll.com'}, False)
