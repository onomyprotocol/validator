* create "data" folder
```
mkdir -p data/prometheus
mkdir -p data/grafana
mkdir -p data/alertmanager
```

* add permissions
```
chmod a+rwx -R data
```

* run compose
```
docker-compose up -d
```