import firebase_admin
from firebase_admin import credentials, firestore
import pandas as pd

# Firebase Admin SDK'yı başlat
cred = credentials.Certificate('C://Users//USER//OneDrive//Belgeler//projeler//flutterr//Hackathon-2024//serviceAccountKey.json')  # JSON dosyasının yolu
firebase_admin.initialize_app(cred)

# Firestore veritabanına bağlan
db = firestore.client()

# 'books' koleksiyonundaki mevcut verileri sil
def delete_collection(collection_ref, batch_size=10):
    docs = collection_ref.limit(batch_size).stream()
    deleted_count = 0
    for doc in docs:
        doc.reference.delete()
        deleted_count += 1
    return deleted_count

# 'books' koleksiyonunu al
books_collection = db.collection('books')

# Mevcut verileri sil
while True:
    deleted = delete_collection(books_collection)
    if deleted == 0:
        break  # Eğer silinecek belge kalmadıysa döngüyü kır

# CSV dosyasını oku (doğru kodlama ile)
data = pd.read_csv('C://Users//USER//OneDrive//Masaüstü//books_data.csv', delimiter=',', encoding='ISO-8859-9')  # CSV dosyasının yolu

# Verileri Firestore'a yükle
for index, row in data.iterrows():
    doc_ref = books_collection.document()  # 'books' koleksiyon adınız
    doc_ref.set(row.to_dict())
