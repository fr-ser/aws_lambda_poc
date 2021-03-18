import io

import pyarrow
import pyarrow.parquet as parquet

from main import filter_parquet


def test_filter():
    source_parquet_data = io.BytesIO()
    pyarrow_table = pyarrow.Table.from_pydict(
        {
            "asset_id": [11, 12],
            "measure_point_id": [21, 22],
            "timestamp": [31, 32],
            "value": [None, 42],
        },
    )
    parquet.write_table(pyarrow_table, source_parquet_data)

    filtered_parquet = filter_parquet(source_parquet_data)
    filtered_dict = parquet.read_table(filtered_parquet).to_pydict()

    assert filtered_dict == {
        "asset_id": [12],
        "measure_point_id": [22],
        "timestamp": [32],
        "value": [42],
    }
