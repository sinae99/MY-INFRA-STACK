import json
from unittest.mock import MagicMock, patch

import app as geoapi


def test_health():
    client = geoapi.app.test_client()
    r = client.get("/health")
    assert r.status_code == 200
    assert r.get_json() == {"status": "ok"}


def test_iploc_missing_ip():
    client = geoapi.app.test_client()
    r = client.get("/iploc")
    assert r.status_code == 400
    assert "error" in r.get_json()


def test_metrics():
    client = geoapi.app.test_client()
    r = client.get("/metrics")
    assert r.status_code == 200
    body = r.data
    assert b"iploc_requests_total" in body
    assert b"iploc_cached_ips" in body
    assert b"iploc_request_duration_seconds" not in body
    assert b"iploc_db_duration_seconds" not in body
    assert b"iploc_geo_duration_seconds" not in body


@patch.object(geoapi, "ensure_schema")
@patch.object(geoapi, "lookup_cache", return_value="United States")
@patch.object(geoapi, "refresh_cached_ips")
def test_iploc_cache_hit(_refresh, _lookup, _schema):
    client = geoapi.app.test_client()
    r = client.get("/iploc?ip=8.8.8.8")
    assert r.status_code == 200
    assert r.get_json() == {"ip": "8.8.8.8", "country": "United States"}


@patch.object(geoapi, "ensure_schema")
@patch.object(geoapi, "lookup_cache", return_value=None)
@patch.object(geoapi, "store_cache")
@patch.object(geoapi, "fetch_country", return_value="Germany")
@patch.object(geoapi, "refresh_cached_ips")
def test_iploc_cache_miss(_refresh, _fetch, _store, _lookup, _schema):
    client = geoapi.app.test_client()
    r = client.get("/iploc?ip=1.1.1.1")
    assert r.status_code == 200
    assert r.get_json() == {"ip": "1.1.1.1", "country": "Germany"}
    _store.assert_called_once_with("1.1.1.1", "Germany")



def test_fetch_country_parses_json():
    payload = json.dumps({"status": "success", "country": "France"}).encode()
    mock_resp = MagicMock()
    mock_resp.read.return_value = payload
    mock_resp.__enter__.return_value = mock_resp
    mock_resp.__exit__.return_value = False
    with patch("urllib.request.urlopen", return_value=mock_resp):
        assert geoapi.fetch_country("9.9.9.9") == "France"
