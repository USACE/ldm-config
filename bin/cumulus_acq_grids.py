#!/bin/env python

import os
import sys
import boto3
import botocore
from botocore.exceptions import NoCredentialsError
import argparse
import logging
import logging.handlers
import requests
from urllib.parse import urlparse, urlunparse
from requests.models import CaseInsensitiveDict, Response
from datetime import datetime
from dataclasses import dataclass

@dataclass
class acquirable:
    id: str = None
    name: str = None
    slug: str = None

# Root key
root_key = "cumulus/acquirables"

# Cumulus URL
cumulus_url = {
    "cwbi-data-develop": os.environ.get("CUMULUS_HOST_DEVELOP"),
    "cwbi-data-stable": os.environ.get("CUMULUS_HOST_STABLE")
}

# Create a logging object
logger = logging.getLogger(__name__)
logger.setLevel(logging.DEBUG)
sh = logging.StreamHandler()
rfh = logging.handlers.RotatingFileHandler(
    filename="/home/ldm/var/logs/acq_grids.log",
    maxBytes=500000,
    backupCount=4
)

formatter = formatter = logging.Formatter('%(asctime)s.%(msecs)03d - ' +
        '%(name)10s:%(funcName)20s - %(levelname)-5s - %(message)s',
        '%Y-%m-%dT%H:%M:%S')
sh.setFormatter(formatter)
rfh.setFormatter(formatter)
logger.addHandler(rfh)

# Create the argument parser
parser = argparse.ArgumentParser()
parser.add_argument(
    "-p", "--fqpn", required=True, type=str, action="store", dest="fqpn"
)
parser.add_argument(
    "-a", "--acquire_type", required=True, type=str, action="store", dest="acquire_type"
)
parser.add_argument(
    "-b", "--bucket", required=True, action="append", dest="bucket",
    choices=list(cumulus_url.keys())
)

def get_acquirable_id(host: str, slug: str) -> str:

    _timeout = 2
    _acquirable = acquirable()
    _url = host + "/acquirables"

    try:
        resp = requests.get(url=_url, timeout=_timeout)

        if resp.status_code == 200:
            for acquire in resp.json():
                _acquirable = acquirable(**acquire)
                if _acquirable.slug == slug:
                    return _acquirable.id
    except requests.exceptions.ConnectTimeout as ex:
        logger.error(f"Connection to {host} timed out. connect timeout={_timeout}")

    return _acquirable.id

def notify_acquirablefile(api_url: str, acquirable_id: str, datetime: datetime, key: str, query: str) -> Response:
    dtf = "%Y-%m-%dT%H:%M:%SZ"
    url_parse = urlparse(api_url)
    url = urlunparse((
        url_parse.scheme,
        url_parse.netloc,
        "acquirablefiles",
        "",
        query,
        ""
    ))

    data = {
        "datetime": datetime.strftime(dtf),
        "file": key, 
        "acquirable_id": acquirable_id
    }
    headers = CaseInsensitiveDict()
    headers["content-type"] = "application/json; charset=utf-8"
    headers["accept"] = "application/json"

    with requests.Session() as s:
        s.headers = headers
        return s.post(url=url, json=data, headers=headers)

def main() -> None:
    args = parser.parse_args()

    fqpn = args.fqpn
    filename = os.path.basename(fqpn)
    acquire_type = args.acquire_type
    buckets = args.bucket

    if not os.path.isfile(fqpn):
        logger.warning(f"file '{fqpn}' does not exist.")
        logger.warning("Program exiting!")
        sys.exit()

    # Get the s3 resource and upload the file to the bucket
    aws_s3_endpoint=os.environ.get("AWS_S3_ENDPOINT")
    if aws_s3_endpoint:
        s3 = boto3.resource("s3", endpoint_url=aws_s3_endpoint)
    else:
        s3 = boto3.resource("s3")

    logger.info(f"Start processing file '{filename}' (acquirable {acquire_type})")
    home = os.path.expanduser("~")
    for bucket in buckets:
        logger.info(f"S3 Bucket: {bucket}")
        # Need to get the application key based on the bucket
        dot_appkey = os.path.join(home, f".{bucket}")
        
        # Try to read the dot (.) file for the bucket with an appkey but
        # continue if it fails.
        try:
            with open(dot_appkey, "r") as f: application_key = f.read()
        except FileNotFoundError as ex:
            logger.warning(ex)
            continue

        key = "/".join([root_key, acquire_type, filename])
        try:
            s3.meta.client.upload_file(
                fqpn,
                bucket,
                key
            )
            logger.info(f"S3 upload file: {filename}")
            api_url = cumulus_url[bucket]
            acquirable_id = get_acquirable_id(api_url, acquire_type)
            logger.info(f"Acquirable ID: {acquirable_id} ({acquire_type})")
            if acquirable_id is not None:
                resp = notify_acquirablefile(
                    api_url=api_url,
                    acquirable_id=acquirable_id,
                    datetime=datetime.utcnow(),
                    key=key,
                    query=f"key={application_key}"
                )
                logger.info(f"Response status code: {resp.status_code}")
                logger.debug(f"Respons JSON: {resp.json()}")
            else:
                logger.warning(f"Acquirable ID returned '{acquirable_id}'")
        except botocore.exceptions.ParamValidationError as ex:
            logger.warning(f"Invalid bucket name - {bucket}")
            logger.warning("Program exiting!")
            sys.exit()

if __name__ == "__main__":
    try:
        main()
    except NoCredentialsError as error:
        logger.error(error)
        logger.error("To run this, you must have valid credentials in "
              "a shared credential file or set in environment variables.")