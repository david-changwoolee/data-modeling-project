import os
import kagglehub
import duckdb

root_path = '/root/data'
dataset_path = '/root/data/kaggle'

def get_dataset_path():
    paths= []
    for dataset in os.listdir(dataset_path):
        p=f'{dataset_path}/{dataset}'
        paths.append(p)
    return paths

def download_kaggle():
    with open(f'{root_path}/kaggle-urls', 'r', encoding='utf-8') as file:
        for kaggle in file:
            print("> ---starts downloading data---")
            dataset_name, dataset_url = kaggle.split(',')
            print(f"dataset_name : {dataset_name.strip()}")
            print(f"dataset_url : {dataset_url.strip()}")

            kaggle_name = '/'.join(dataset_url.split('/')[-2:]).strip()
            print(f"kaggle_name : {kaggle_name}")

            path = f'{root_path}/kaggle/{dataset_name}'
            result_path = kagglehub.dataset_download(kaggle_name, output_dir=path)
            print(f"dataset_path : {result_path}")
            print("> ---ends downloading data---")

def insert_lake(path):
    print("> ---starts creating lake---")

    name = path.split('/')[-1]
    print(f"dataset name : {name}")

    files = os.listdir(path)
    csv_file = [csv for csv in files if csv.endswith('.csv')][0]
    print(f"csv_file : {csv_file}")

    create_table_query = f"""
    CREATE TABLE IF NOT EXISTS lake AS
    SELECT * FROM read_csv('{path}/{csv_file}', header=True, auto_detect=True)
    """
    con=duckdb.connect(f'/root/data/duckdb/{name}.db')
    con.execute(create_table_query)
    con.sql('show tables;').show()

    print("> ---ends creating lake---")
