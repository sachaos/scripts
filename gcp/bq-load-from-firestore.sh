#!/bin/bash
#
# Load data to BigQuery from Firestore Collection

PROJECT_ID=${PROJECT_ID:?is required}
BUCKET_NAME=${BUCKET_NAME:?is required}
COLLECTION_ID=${COLLECTION_ID:?is required}
TABLE=${TABLE:?is required}

LOCATION_ID=$( gcloud app describe --project $PROJECT_ID --format json | jq -r .locationId )

gsutil mb -p $PROJECT_ID -l $LOCATION_ID gs://${BUCKET_NAME}/

gcloud firestore export gs://${BUCKET_NAME}/ --collection-ids=${COLLECTION_ID} --project $PROJECT_ID

OUTPUT_URI_PREFIX=$(gcloud firestore operations list --project $PROJECT_ID --format json | jq -r ".[-1].response.outputUriPrefix")

bq load \
   --project_id $PROJECT_ID \
   --source_format=DATASTORE_BACKUP \
   $TABLE \
   $OUTPUT_URI_PREFIX/all_namespaces/kind_${COLLECTION_ID}/all_namespaces_kind_${COLLECTION_ID}.export_metadata

