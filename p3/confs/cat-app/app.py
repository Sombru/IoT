from flask import Flask, jsonify
import os

app = Flask(__name__)

VERSION = os.environ.get("APP_VERSION", "v1")

CATS = {
    "v1": {"emoji": "🐱", "sound": "meow"},
    "v2": {"emoji": "😻", "sound": "purr"},
}

@app.route("/")
def index():
    cat = CATS.get(VERSION, CATS["v1"])
    return jsonify({
        "status": "ok",
        "message": VERSION,
        "cat": cat["emoji"],
        "sound": cat["sound"],
    })

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8888)