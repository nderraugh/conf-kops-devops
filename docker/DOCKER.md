```
docker build -t quickstart-image .

docker tag quickstart-image gcr.io/$PROJECT/quickstart-image:tag1

docker push gcr.io/$PROJECT/quickstart-image:tag1
```