import io
import os

import boto3

import pyarrow
import pyarrow.parquet as parquet

S3_URL = os.environ.get("S3_URL")
TARGET_BUCKET = os.environ["S3_BUCKET_TARGET"]
client = boto3.client("s3", endpoint_url=S3_URL)


def lambda_handler(event, context):
    source_bucket = event["Records"][0]["s3"]["bucket"]["name"]
    source_file_key = event["Records"][0]["s3"]["object"]["key"]

    in_memory_file = io.BytesIO()
    client.download_fileobj(Bucket=source_bucket, Key=source_file_key, Fileobj=in_memory_file)

    client.put_object(
        Bucket=TARGET_BUCKET,
        Key=source_file_key,
        Body=filter_parquet(in_memory_file),
    )

    return {"statusCode": 200, "body": "success"}


def filter_parquet(input_file_data):
    """
    This method takes a binary input parquet file and removes null
    values.

    :param input_file_data: binary input parquet file
    :return: filtered output file
    """
    filtered_batches = []

    for batch in parquet.read_table(input_file_data).to_batches(max_chunksize=1):
        # more efficient might be a larget chunksize. Then we construct
        # a filter mask (from a batch pydict). As a PoC this is OK.
        if batch.to_pydict()["value"][0] is not None:
            filtered_batches.append(batch)

    filtered_parquet_data = io.BytesIO()
    parquet.write_table(pyarrow.Table.from_batches(filtered_batches), filtered_parquet_data)

    filtered_parquet_data.seek(0)
    return filtered_parquet_data
