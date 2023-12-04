(ql:quickload :cl-dbi)

(defvar *db*
  (dbi:connect :postgres
               :database-name "pgvector_lisp_test"))

(dbi:do-sql *db* "CREATE EXTENSION IF NOT EXISTS vector")

(dbi:do-sql *db* "DROP TABLE IF EXISTS items")

(dbi:do-sql *db* "CREATE TABLE items (id bigserial PRIMARY KEY, embedding vector(3))")

(dbi:do-sql *db* "INSERT INTO items (embedding) VALUES (?)" (list "[1,1,1]"))
(dbi:do-sql *db* "INSERT INTO items (embedding) VALUES (?)" (list "[2,2,2]"))
(dbi:do-sql *db* "INSERT INTO items (embedding) VALUES (?)" (list "[1,1,2]"))

(format t "~a~%" (dbi:fetch-all (dbi:execute (dbi:prepare *db* "SELECT * FROM items ORDER BY embedding <-> ? LIMIT 5") (list "[1,1,1]"))))

(dbi:do-sql *db* "CREATE INDEX ON items USING hnsw (embedding vector_l2_ops)")
