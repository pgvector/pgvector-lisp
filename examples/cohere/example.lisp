(ql:quickload (list :cl-json :dexador :postmodern) :silent t)
(use-package :postmodern)

(register-sql-operators :2+-ary :<~>)

(connect-toplevel "pgvector_example" (uiop:getenv "USER") "" "localhost")

(load-extension "vector")
(query (:drop-table :if-exists 'documents))
(query (:create-table 'documents ((id :type bigserial :primary-key t) (content :type text) (embedding :type (bit 1536)))))

(defun embed (texts input-type)
    (let* ((api-key (uiop:getenv "CO_API_KEY"))
           (url "https://api.cohere.com/v2/embed")
           (data `((texts . ,texts) (model . "embed-v4.0") (input_type . ,input-type) (embedding_types . (ubinary))))
           (headers `(("Authorization" . ,(format nil "Bearer ~A" api-key)) ("Content-Type" . "application/json")))
           (response (dex:post url :headers headers :content (json:encode-json-to-string data)))
           (embeddings (cdr (assoc :ubinary (cdr (assoc :embeddings (json:decode-json-from-string response)))))))
        (loop for v in embeddings collect (format nil "~{~8,'0b~}" v))))

(defvar *input* (list "The dog is barking" "The cat is purring" "The bear is growling"))
(defvar *embeddings* (embed *input* "search_document"))
(loop for content in *input* for embedding in *embeddings* do
    (query (:insert-into 'documents :set 'content content 'embedding embedding)))

(defvar *query* "forest")
(defvar *embedding* (car (embed (list *query*) "search_query")))
(doquery (:limit (:order-by (:select 'content :from 'documents) (:<~> 'embedding *embedding*)) 5) (content)
    (format t "~A~%" content))
