import io
import os

import boto3
import pyarrow
import pyarrow.parquet as parquet
import pytest

from main import lambda_handler

SOURCE_BUCKET = "test-source"
TARGET_BUCKET = os.environ["S3_BUCKET_TARGET"]
S3_URL = os.environ["S3_URL"]

client = boto3.client("s3", endpoint_url=S3_URL)
s3 = boto3.resource("s3", endpoint_url=S3_URL)


@pytest.fixture(autouse=True, scope="module")
def setup_buckets():
    s3.create_bucket(Bucket=SOURCE_BUCKET)
    s3.create_bucket(Bucket=TARGET_BUCKET)


def test_lambda():
    clean_buckets()
    source_dict = {
        "asset_id": [11, 12],
        "measure_point_id": [21, 22],
        "timestamp": [31, 32],
        "value": [None, 42],
    }
    source_file_key = "folder/prefix/file.parquet"
    upload_source_parquet(source_dict, source_file_key)
    test_event = {
        "Records": [
            {
                "s3": {
                    "bucket": {"name": SOURCE_BUCKET},
                    "object": {"key": source_file_key},
                }
            }
        ]
    }

    lambda_handler(test_event, context=None)

    output_file = io.BytesIO()
    client.download_fileobj(Bucket=TARGET_BUCKET, Key=source_file_key, Fileobj=output_file)
    assert parquet.read_table(output_file).to_pydict() == {
        "asset_id": [12],
        "measure_point_id": [22],
        "timestamp": [32],
        "value": [42],
    }


def clean_buckets():
    s3.Bucket(SOURCE_BUCKET).objects.delete()
    s3.Bucket(TARGET_BUCKET).objects.delete()


def upload_source_parquet(data_dict, s3_key):
    data_bytes = io.BytesIO()
    parquet.write_table(pyarrow.Table.from_pydict(data_dict), data_bytes)
    data_bytes.seek(0)

    client.put_object(Bucket=SOURCE_BUCKET, Key=s3_key, Body=data_bytes)
