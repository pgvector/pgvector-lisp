(ql:quickload (list :cl-json :dexador :postmodern) :silent t)
(use-package :postmodern)

(connect-toplevel "pgvector_example" (uiop:getenv "USER") "" "localhost")

(load-extension "vector")
(query (:drop-table :if-exists 'documents))
(query (:create-table 'documents ((id :type bigserial :primary-key t) (content :type text) (embedding :type (vector 768)))))
(query (:create-index 'my-index :on 'documents :using gin :fields (:to_tsvector "english" 'content)))

(defun embed (input task-type)
    ; nomic-embed-text uses a task prefix
    ; https://huggingface.co/nomic-ai/nomic-embed-text-v1.5
    (let* ((input (loop for v in input collect (concatenate 'string task-type ": " v)))
           (url "http://localhost:11434/api/embed")
           (data `((input . ,input) (model . "nomic-embed-text")))
           (headers `(("Content-Type" . "application/json")))
           (response (dex:post url :headers headers :content (json:encode-json-to-string data))))
        (cdr (assoc :embeddings (json:decode-json-from-string response)))))

(defun encode-vector (value)
    (json:encode-json-to-string value))

(defvar *input* (list "The dog is barking" "The cat is purring" "The bear is growling"))
(defvar *embeddings* (embed *input* "search_document"))
(loop for content in *input* for embedding in *embeddings* do
    (query (:insert-into 'documents :set 'content content 'embedding (encode-vector embedding))))

(defvar *sql* "WITH semantic_search AS (
    SELECT id, RANK () OVER (ORDER BY embedding <=> $2) AS rank
    FROM documents
    ORDER BY embedding <=> $2
    LIMIT 20
),
keyword_search AS (
    SELECT id, RANK () OVER (ORDER BY ts_rank_cd(to_tsvector('english', content), query) DESC)
    FROM documents, plainto_tsquery('english', $1) query
    WHERE to_tsvector('english', content) @@ query
    ORDER BY ts_rank_cd(to_tsvector('english', content), query) DESC
    LIMIT 20
)
SELECT
    COALESCE(semantic_search.id, keyword_search.id) AS id,
    COALESCE(1.0 / ($3::double precision + semantic_search.rank), 0.0) +
    COALESCE(1.0 / ($3::double precision + keyword_search.rank), 0.0) AS score
FROM semantic_search
FULL OUTER JOIN keyword_search ON semantic_search.id = keyword_search.id
ORDER BY score DESC
LIMIT 5")
(defvar *query* "growling bear")
(defvar *embedding* (car (embed (list *query*) "search_query")))
(defvar *k* 60)
(doquery (*sql* *query* (encode-vector *embedding*) *k*) (id score)
    (format t "document: ~A, RRF score: ~A~%" id score))
