import os
import joblib

import streamlit as st
import pandas as pd

from pymongo import MongoClient


client = MongoClient(f"mongodb://{os.getenv('MONGO_USER')}:{os.getenv('MONGO_PASSWORD')}@{os.getenv('MONGO_HOST')}:{os.getenv('MONGO_PORT')}/")
db = client["movie_database"]

movies = pd.DataFrame(list(db.movies.find()))
model = joblib.load('./movie_recommendation_model.pkl')

st.title('Sistema de Recomendação de Filmes')

user_id = st.number_input('Insira o ID do Usuário', min_value=1, step=1)
if st.button('Obter Recomendações'):
    recommendations = []
    for movie_id in movies['movie_id']:
        rating = model.predict(user_id, movie_id).est
        recommendations.append((movie_id, rating))
    recommendations.sort(key=lambda x: x[1], reverse=True)
    top_recommendations = recommendations[:10]

    st.write('Top 10 Filmes Recomendados:')
    for movie_id, rating in top_recommendations:
        movie = movies[movies['movie_id'] == movie_id].iloc[0]
        st.write(f"{movie['title']} (Rating: {rating:.2f})")
