(ql:quickload (list :cl-json :dexador :postmodern) :silent t)
(use-package :postmodern)

(connect-toplevel "pgvector_example" (uiop:getenv "USER") "" "localhost")

(load-extension "vector")
(query (:drop-table :if-exists 'documents))
(query (:create-table 'documents ((id :type bigserial :primary-key t) (content :type text) (embedding :type (vector 1536)))))

(defun embed (input)
    (let* ((api-key (uiop:getenv "OPENAI_API_KEY"))
           (url "https://api.openai.com/v1/embeddings")
           (data `((input . ,input) (model . "text-embedding-3-small")))
           (headers `(("Authorization" . ,(concatenate 'string "Bearer " api-key)) ("Content-Type" . "application/json")))
           (response (dex:post url :headers headers :content (json:encode-json-to-string data)))
           (objects (cdr (assoc :data (json:decode-json-from-string response)))))
        (loop for v in objects collect (cdr (assoc :embedding v)))))

(defun encode-vector (value)
    (json:encode-json-to-string value))

(defvar *input* (list "The dog is barking" "The cat is purring" "The bear is growling"))
(defvar *embeddings* (embed *input*))
(loop for content in *input* for embedding in *embeddings* do
    (query (:insert-into 'documents :set 'content content 'embedding (encode-vector embedding))))

(defvar *query* "forest")
(defvar *embedding* (car (embed (list *query*))))
(doquery (:limit (:order-by (:select 'content :from 'documents) (:<=> 'embedding (encode-vector *embedding*))) 5) (content)
    (format t "~A~%" content))
