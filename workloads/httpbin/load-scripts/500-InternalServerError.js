import http from "k6/http";

export default function() {
    let response = http.get("http://httpbin.aspendemo.org/status/500");
};
