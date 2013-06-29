#lang racket

(require net/url
         net/head
         json)

(provide put
         put-string
         put-json
         get
         get-string
         get-json
         get-all-strings
         get-all-jsons
         get-all-keys
         delete
         
         ctype.text
         ctype.json)

(define host "localhost")
(define port "8098")

(define str string-append)

(define ctype.text "text/plain")
(define ctype.json "application/json")

(define put (case-lambda 
        [(bucket data ctype) (last (string-split 
                              (extract-field "Location" 
                               (purify-port 
                                (post-impure-port 
                                 (string->url 
                                  (str "http://" host ":" port "/riak/" bucket))
                                 (string->bytes/utf-8 data)
                                 (list (str "Content-Type: " ctype))))) "/"))]
        
        [(bucket data key ctype) (raise "Not implemented yet!")]))

(define put-string (case-lambda
        [(bucket data) (put bucket data ctype.text)]
        [(bucket data key) (put bucket data key ctype.text)]))

(define put-json (case-lambda
        [(bucket data) (put bucket (jsexpr->string data) ctype.json)]
        [(bucket data key) (put bucket (jsexpr->string data) key ctype.json)]))

(define [get key [bucket "bucket"]]
  (let* ([response (get-impure-port (string->url 
                  (str "http://" host ":" port "/riak/" bucket "/" key)))]
         [header (purify-port response)]
         [status (substring header 9 12)])
    (match status
      ["200" response]
      [else (raise (make-exn status (current-continuation-marks)))])))

(define [get-string key [bucket "bucket"]]
  (port->string (get key bucket)))

(define [get-json key [bucket "bucket"]]
  (read-json (get key bucket)))

(define [delete bucket key]
  (delete-pure-port (string->url 
                  (str "http://" host ":" port "/buckets/" bucket "/keys/" key))))

(define [get-all-strings bucket] 
  (read-json (post-pure-port 
              (string->url 
                  (str "http://" host ":" port "/mapred"))
              (string->bytes/utf-8 
                   (str "{\"inputs\":\"" bucket 
                        "\", \"query\":[{\"map\":{\"language\":\"javascript\",\"source\":\"function(v) { return [v.values[0].data]; }\"}}]}"))
              (list (str "Content-Type: " ctype.json)))))

(define [get-all-jsons bucket]
  (map string->jsexpr (get-all-strings bucket)))

(define [get-all-keys bucket]
  (hash-ref (read-json (get-pure-port (string->url 
                  (str "http://" host ":" port "/buckets/" bucket "/keys?keys=true")))) 'keys))
