import json
import os
import urllib.error
import urllib.request

import psycopg
from flask import Flask, Response, jsonify, request
from prometheus_client import CONTENT_TYPE_LATEST, Counter, Gauge, generate_latest

REQUESTS = Counter(
    "iploc_requests_total",
    "Total /iploc requests",
)
CACHED_IPS = Gauge(
    "iploc_cached_ips",
    "Number of IPs stored in Postgres cache",
)

app = Flask(__name__)
_ready = False


def get_conn():
    return psycopg.connect(os.environ["DATABASE_URL"])


def ensure_schema():
    global _ready
    if _ready:
        return
    with get_conn() as conn:
        conn.execute(
            "CREATE TABLE IF NOT EXISTS ip_cache ("
            "ip TEXT PRIMARY KEY, "
            "country TEXT NOT NULL)"
        )
        conn.commit()
    _ready = True


def refresh_cached_ips():
    with get_conn() as conn:
        row = conn.execute("SELECT COUNT(*) FROM ip_cache").fetchone()
    CACHED_IPS.set(row[0] if row else 0)


def lookup_cache(ip: str):
    with get_conn() as conn:
        row = conn.execute(
            "SELECT country FROM ip_cache WHERE ip = %s", (ip,)
        ).fetchone()
    return row[0] if row else None


def store_cache(ip: str, country: str):
    with get_conn() as conn:
        conn.execute(
            "INSERT INTO ip_cache (ip, country) VALUES (%s, %s) "
            "ON CONFLICT (ip) DO NOTHING",
            (ip, country),
        )
        conn.commit()


def fetch_country(ip: str) -> str:
    url = f"http://ip-api.com/json/{ip}?fields=status,country,message"
    with urllib.request.urlopen(url, timeout=5) as resp:
        data = json.loads(resp.read().decode())
    if data.get("status") != "success":
        raise ValueError(data.get("message", "geo lookup failed"))
    return data["country"]


@app.get("/health")
def health():
    return jsonify(status="ok")


@app.get("/metrics")
def metrics():
    return Response(generate_latest(), mimetype=CONTENT_TYPE_LATEST)


@app.get("/iploc")
def iploc():
    REQUESTS.inc()
    ip = request.args.get("ip", "").strip()
    if not ip:
        return jsonify(error="missing ip"), 400

    try:
        ensure_schema()
        cached = lookup_cache(ip)
        if cached:
            refresh_cached_ips()
            return jsonify(ip=ip, country=cached)

        country = fetch_country(ip)
        store_cache(ip, country)
        refresh_cached_ips()
        return jsonify(ip=ip, country=country)
    except (psycopg.Error, urllib.error.URLError, TimeoutError, ValueError, KeyError) as exc:
        return jsonify(error=str(exc)), 502
