import http from "k6/http";

export let options = {
  vus: 5,
  stages: [
      { duration: "5m", target: 50 }
  ]
};

export default function() {
    let response = http.get("http://httpbin.aspendemo.org/status/200");
};
