import os
import sys

try:
    import firebase_admin
    from firebase_admin import credentials, firestore
except Exception as e:
    print('Missing firebase_admin package:', e)
    sys.exit(1)

SERVICE_ACCOUNT_PATH = os.path.join(os.getcwd(), 'firebase-service-account.json')

if not os.path.exists(SERVICE_ACCOUNT_PATH):
    print('Missing service account file:', SERVICE_ACCOUNT_PATH)
    sys.exit(1)

cred = credentials.Certificate(SERVICE_ACCOUNT_PATH)
firebase_admin.initialize_app(cred)

db = firestore.client()
doc_id = 'Medical|all|Firebase Test Item'
data = {
    'category': 'Medical',
    'language': 'all',
    'title': 'Firebase Test Item',
    'content': 'This item was created to verify Firebase connectivity.',
    'link': 'https://firebase.google.com',
    'unique_id': docId,
}

db.collection('content_items').document(doc_id).set(data)
print('✅ Firebase seed completed.')
