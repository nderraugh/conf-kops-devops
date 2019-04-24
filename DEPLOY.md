sbt orkestraJVM/Docker/publishLocal

docker tag orkestra:0.1.0-SNAPSHOT gcr.io/$PROJECT/orkestra:0.1.0

docker push gcr.io/$PROJECT/orkestra:0.1.0


kubectl apply -f ./kubernetes/

open http://127.0.0.1:8001/api/v1/namespaces/orkestra/services/orkestra:http/proxy/#/jobs/deployfrontend