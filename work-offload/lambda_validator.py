#!/usr/bin/env python
import logging
import urlparse

domain_whitelist = ['adroll.com',
                    'google.com',
                    'facebook.com']


def is_subdomain(a, b):
    # return true if a is a subdomain of b
    return a == b or a.endswith('.' + b)


def validate(uri):
    logging.info('validating uri: {}'.format(uri))
    scheme, netloc, path, params, query, fragment = urlparse.urlparse(uri)

    if not netloc:
        if '/' in path:
            netloc, path = path.split('/', 1)
        else:
            netloc, path = path, ''

    if '.' not in netloc:
        return False, 'bad domain'

    if not any(is_subdomain(netloc, whitelisted)
               for whitelisted in domain_whitelist):
        logging.info('not whitelisted: {}'.format(netloc))
        return False, 'domain is not whitelisted'

    c = '{scheme}://{netloc}{path}{params}{query}'.format(
        scheme=scheme or 'http',
        netloc=netloc,
        path=path or '/',
        params=';' + params if params else '',
        query='?' + query if query else ''
    )
    return c, None


def lambda_handler(event, context):
    logging.basicConfig()
    logging.getLogger().setLevel(logging.INFO)
    logging.info('got event: {}'.format(event))

    result = {'valid': False}
    canonical, error = validate(event['uri'])
    if not canonical:
        logging.info('uri is invalid')
        result['error'] = error
    else:
        logging.info('valid uri: {}'.format(canonical))
        result['canonical'] = canonical
        result['valid'] = True
    return result
