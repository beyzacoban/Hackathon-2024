import firebase_admin
from firebase_admin import credentials, firestore
import pandas as pd

# Firebase Admin SDK'yı başlat
cred = credentials.Certificate('C://Users//USER//OneDrive//Belgeler//projeler//flutterr//Hackathon-2024//serviceAccountKey.json')  # JSON dosyasının yolu
firebase_admin.initialize_app(cred)

# Firestore veritabanına bağlan
db = firestore.client()

# CSV dosyasını oku (delimiter parametresini ekleyin)
data = pd.read_csv('C://Users//USER//OneDrive//Masaüstü//songs_data.csv', delimiter=';')  # CSV dosyasının yolu

# Verileri Firestore'a yükle
for index, row in data.iterrows():
    doc_ref = db.collection('songs').document()  # 'movies' koleksiyon adınız
    doc_ref.set(row.to_dict())

