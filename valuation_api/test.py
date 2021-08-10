import requests

BASE = "http://127.0.0.1:5000/"

#annual_risk_free_rate = 0.07
#risk_free_rate_second = ((annual_risk_free_rate / 365) / 86400)
response = requests.get(BASE + "valuate/1100.0/0/6912000/1300.0/0.00000000221968544")
print(response.json())