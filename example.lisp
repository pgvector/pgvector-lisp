(ql:quickload :postmodern)
(use-package :postmodern)

(connect-toplevel "pgvector_lisp_test" (uiop:getenv "USER") "" "localhost")

(query "CREATE EXTENSION IF NOT EXISTS vector")

(query "DROP TABLE IF EXISTS items")

(query "CREATE TABLE items (id bigserial PRIMARY KEY, embedding vector(3))")

(query (:insert-into 'items :set 'embedding "[1,1,1]"))
(query (:insert-rows-into 'items :columns 'embedding :values '(("[2,2,2]") ("[1,1,2]"))))

(register-sql-operators :2+-ary :<-> :<#> :<=>)

(doquery (:limit (:order-by (:select 'id 'embedding :from 'items) (:<-> 'embedding "[1,1,1]")) 5) (id embedding)
    (format t "~A: ~A~%" id embedding))

(query "CREATE INDEX ON items USING hnsw (embedding vector_l2_ops)")
