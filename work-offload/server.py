import os, json, logging, boto3, botocore, flask, time

app = flask.Flask(__name__)

@app.route('/')
def index():
    start_time = time.time()
    result = None
    uri = flask.request.args.get('uri', '')

    if uri:
        result = validate_and_process(uri)

    params = dict(title='work offload example',
                  result=result,
                  uri=uri,
                  processing_time=(time.time() - start_time))
    return flask.render_template('form.html', **params)


def config(name):
    # note: source env.sh before running this module.
    return os.environ[name]


boto_cache = {}
def invoke(fun_name, **args):
    logging.info('invoking {} with args {}'.format(fun_name, args))

    if 'lambda' not in boto_cache:
        boto_cache['lambda'] = boto3.client('lambda', region_name=config('REGION'))

    result = boto_cache['lambda'].invoke(**{'FunctionName': fun_name,
                                            'InvocationType': 'RequestResponse',
                                            'LogType': 'Tail',
                                            'Payload': json.dumps(args)})
    if 200 != result['StatusCode']:
        raise Exception('invocation failed')

    return json.loads(result['Payload'].read())


def validate_and_process(uri):
    output = []
    result = invoke(config('VALIDATOR_FUNCTION'), uri=uri)
    logging.info('result: {}'.format(result))

    if not result['valid']:
        output.append('validator: uri [{}] failed to validate: {}'.format(uri, result['error']))
    else:
        canonical = result['canonical']
        output.append('validator: canonical uri: {}'.format(canonical))

        work_result = invoke(config('EXECUTOR_FUNCTION'), uri=canonical)
        if 'status' in work_result:
            output.append('executor: disposition: {}'.format(work_result['status']))
        else:
            output.append('executor: lambda request failure')

    return '\n'.join(output)


if '__main__' == __name__:
    logging.basicConfig()
    logging.getLogger().setLevel(logging.INFO)
    logging.getLogger('botocore').setLevel(logging.WARN)
    app.run()
