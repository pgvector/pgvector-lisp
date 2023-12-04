(ql:quickload :cl-dbi)

(defvar *conn*
  (dbi:connect :postgres
               :database-name "pgvector_lisp_test"))

(dbi:do-sql *conn* "CREATE EXTENSION IF NOT EXISTS vector")

(dbi:do-sql *conn* "DROP TABLE IF EXISTS items")

(dbi:do-sql *conn* "CREATE TABLE items (id bigserial PRIMARY KEY, embedding vector(3))")

(dbi:do-sql *conn* "INSERT INTO items (embedding) VALUES (?)" (list "[1,1,1]"))
(dbi:do-sql *conn* "INSERT INTO items (embedding) VALUES (?)" (list "[2,2,2]"))
(dbi:do-sql *conn* "INSERT INTO items (embedding) VALUES (?)" (list "[1,1,2]"))

(format t "~a~%" (dbi:fetch-all (dbi:execute (dbi:prepare *conn* "SELECT * FROM items ORDER BY embedding <-> ? LIMIT 5") (list "[1,1,1]"))))

(dbi:do-sql *conn* "CREATE INDEX ON items USING hnsw (embedding vector_l2_ops)")
