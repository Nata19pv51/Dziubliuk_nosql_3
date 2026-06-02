# Налаштування середовища
* Python (версії __3.9__ або вище)
* Запустити Neo4j локально через Docker командою:
```
docker-compose up -d
```

# Завантаження даних
1. Завантажте архів ml-1m.zip з [MovieLens1M](https://airlock-on-edge.woolf.university/?url=https%3A%2F%2Fgrouplens.org%2Fdatasets%2Fmovielens%2F1m%2F&resourceId=ccd4f73a-3400-4c08-b845-66d1744766d8&studentId=25a66737-2e5c-4a83-b2b1-596bb6c49c0a&token=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc1ZlcmlmaWVkIjp0cnVlLCJvcmciOnsiZ3JvdXBzIjpbXSwiaWQiOiIyODU2YWNkMy1jMWUxLTQyMWMtOTg5ZS1jN2RkYmQzMmIyZjIifSwia2luZCI6Im9hdXRoIiwic2NvcGUiOiIqIiwiaXNzIjoidXJuOldvb2xmVW5pdmVyc2l0eTpzZXJ2ZXIvc2VydmljZS9hY2Nlc3MiLCJpZCI6IjI1YTY2NzM3LTJlNWMtNGE4My1iMmIxLTU5NmJiNmM0OWMwYSIsImlhdCI6MTc4MDM4NDI2N30.D9vVTSTCfwpLbDnDqFoV3eIFeVZ3xxF5COxKQvdYDOE) і розпакуйте його. Він буде містити 3 .dat файли. Самі файли не комітьте.
2. Запустіть convert.py файл. Отримаєте 3 .csv файли у папці import.

# Частина 1
1. Які сутності стали вузлами, а які — ребрами? Чому?
**Відповідь.** 

2. Оцінка користувача за фільм — це ребро (User)-[:RATED]->(Movie) чи окремий вузол (Rating)? Аргументуйте своє рішення. Це не риторичне запитання: в обох підходів є реальні trade-off-и. 
**Відповідь.** Тут можна робити і як окремий вузол, так і як ребро, для даного завдання на мою думку логічнішим є саме властивість ребра. Так, один користувач може декілька разів оцінити один і той самий фільм, але в такому випадку буде створено декілька ребер від користувача до фільму. Маючи багато вузлів, граф стає громіздким, його важче візуалізувати. Крім цього щоб отримати базову інформацію, базі доведеться робити більше стрибків по графу, що уповільнює роботу. Робити окреми вузол Rating є сенс, якщо у майбутньому ми знаємо, що до нього будуть додаватися властивості.

3. Чому жанри фільму вигідніше зберігати як окремі вузли (Genre), а не як список у властивості вузла Movie?
**Відповідь.** Проаналізувавши завдання і запити до бази перед створенням графа, я дійшла висновку про те, що жанр буде буде фігурувати в деяких запитах. Оскільки в одного фільму може бути декілька жанрів, то тут вже виникає зв'язок 1 до багатьох. Саме тому доцільніше виокремити жанр як окрему сутність (вузол). Так запити до жанрів будуть легшими і швидшими.

Створення вузла User:
![alt text](image.png)

Створення вузлів Movie та Genre:
![alt text](image-2.png)

Створення індексів і constraints:
![alt text](image-1.png)
![alt text](image-8.png)

Створення ребер:
![alt text](image-3.png)

Перевірка результатів:
![alt text](image-4.png)
![alt text](image-5.png)
![alt text](image-6.png)
![alt text](image-7.png)