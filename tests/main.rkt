#lang racket

(require rackunit
         "../main.rkt")

(define testbucket "racket-riak-test-bucket")
(define jsonTestValue (hasheq 'x (hasheq 'y '(3 4 5))))
(define strings '("x" "y"))
(define jsons (list (hasheq 'x 1) (hasheq 'x 2)))

(test-exn  "Check that deletion works"
           (λ [ex] (string=? "404" (exn-message ex)))
           (λ [] (let* ([k (put testbucket "TEST" ctype.text)]
                  [x (delete testbucket k)])
             
             (sleep 5) ; This is ugly but we simply have to wait for riak to complete the delete op.
             (get k testbucket))))

(test-true "Check that put actually creates a k/v pair"
           (let* ([newKey (put testbucket "TEST" ctype.text)]
                  [val (get-string newKey testbucket)]) 
             
             (delete testbucket newKey)
             (string=? val "TEST")))

(test-true "Check that put-string actually creates a k/v pair"
           (let* ([newKey (put-string testbucket "TEST1")]
                  [val (get-string newKey testbucket)]) 
             
             (delete testbucket newKey)
             (string=? val "TEST1")))

(test-true "Check that put-json actually creates a k/v pair"
           (let* ([newKey (put-json testbucket jsonTestValue)]
                  [val (get-json newKey testbucket)]) 
             
             (delete testbucket newKey)
             (equal? val jsonTestValue)))

(test-equal? "Test that all strings in a bucket are retrieved properly" 
             (remove* 
              (let ([xstr (put-string "b1" "x")]
                    [ystr (put-string "b1" "y")]
                    [strs (get-all-strings "b1")])
               
               (delete "b1" xstr)
               (delete "b1" ystr)
               strs)             
             strings)
             '())

(test-equal? "Test that all JSONs in a bucket are retrieved properly" 
             (remove* 
              (let ([xstr (put-json "b2" (hasheq 'x 1))]
                    [ystr (put-json "b2" (hasheq 'x 2))]
                    [jsns (get-all-jsons "b2")])
               
               (delete "b2" xstr)
               (delete "b2" ystr)
               jsns)             
             jsons)
             '())

(test-true "Test that all keys in a bucket are retrieved properly"            
           (let ([xstr (put-string "b3" "x")]
                 [ystr (put-string "b3" "y")]
                 [keys (get-all-keys "b3")])
             
             (delete "b3" xstr)
             (delete "b3" ystr)
             (empty? (remove* keys (list xstr ystr)))))
