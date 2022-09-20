#!/usr/bin/env python3

import requests
import os
import itertools

def fetch_mods_and_collections():
    mods=os.getenv("MODS").split(" ")
    collections=os.getenv("COLLECTIONS").split(" ")
    
    data = {
            "collections":collections,
            "mods":mods
           }

    return data
    

def pull_collection_items(collection_id):
    mod_ids=[]
    base_url="https://api.steampowered.com/ISteamRemoteStorage/GetCollectionDetails/v1/"
    data= {
            "collectioncount": 1,
            "publishedfileids[0]":collection_id
          }

    r=requests.post(base_url, data=data)
    response=r.json()

    for item in response["response"]["collectiondetails"][0]["children"]:
    	mod_ids.append(item["publishedfileid"])

    return mod_ids

def setup_installation_file(collections, mods):
    file_path="/root/dst/mods/dedicated_server_mods_setup.lua"
    with open(file_path, 'a') as fd:
        for collection in collections:
            fd.write(f"ServerModCollectionSetup(\"{collection}\")\n")
        for mod in mods:
            fd.write(f"ServerModSetup(\"{mod}\")\n")

def setup_world_overrides(mods):
    server_dir=os.getenv("CLUSTER_DIR")
    shard=os.getenv("SHARD")
    file_path=server_dir + f"/{shard}/modoverrides.lua"
    with open(file_path, 'a') as fd:
        fd.write("return {\n")
        for mod in mods:
            fd.write(f"\t[\'workshop-{mod}\'] = {{ enabled = true }},\n")
        fd.write("}")

def merge_mod_lists(*lists):
    return itertools.chain.from_iterable(lists)

if __name__ == "__main__":
    mod_data=fetch_mods_and_collections()
    setup_installation_file(mod_data["collections"], mod_data["mods"])
    collection_mods=[]
    for collection in mod_data["collections"]:
        collection_mods.extend(pull_collection_items(collection))

    full_mod_list=merge_mod_lists(collection_mods, mod_data["mods"])
    setup_world_overrides(full_mod_list)

