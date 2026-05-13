import handling_data as hd

hd.download_kaggle()
paths = hd.get_dataset_path()
for path in paths:
    hd.insert_lake(path)
