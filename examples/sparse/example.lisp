(ql:quickload (list :cl-json :dexador :postmodern) :silent t)
(use-package :postmodern)

(connect-toplevel "pgvector_example" (uiop:getenv "USER") "" "localhost")

(load-extension "vector")
(query (:drop-table :if-exists 'documents))
(query (:create-table 'documents ((id :type bigserial :primary-key t) (content :type text) (embedding :type (sparsevec 30522)))))

(defun embed (inputs)
    (let* ((url "http://localhost:3000/embed_sparse")
           (data `((inputs . ,inputs)))
           (headers `(("Content-Type" . "application/json")))
           (response (dex:post url :headers headers :content (json:encode-json-alist-to-string data)))
           (embeddings (json:decode-json-from-string response)))
        (loop for e in embeddings collect
            (loop for v in e collect (list (cdr (assoc :index v)) (cdr (assoc :value v)))))))

(defun encode-sparsevec (elements dim)
    (let ((elements (loop for (i v) in elements collect (format nil "~A:~A" (+ i 1) v))))
        (format nil "{~{~A~^,~}}/~A" elements dim)))

(defvar *input* (list "The dog is barking" "The cat is purring" "The bear is growling"))
(defvar *embeddings* (embed *input*))
(loop for content in *input* for embedding in *embeddings* do
    (query (:insert-into 'documents :set 'content content 'embedding (encode-sparsevec embedding 30522))))

(defvar *query* "forest")
(defvar *embedding* (car (embed (list *query*))))
(doquery (:limit (:order-by (:select 'content :from 'documents) (:<#> 'embedding (encode-sparsevec *embedding* 30522))) 5) (content)
    (format t "~A~%" content))
