(ql:quickload :postmodern)
(use-package :postmodern)

(connect-toplevel "pgvector_lisp_test" (uiop:getenv "USER") "" "localhost")

(load-extension "vector")

(query (:drop-table :if-exists 'items))

(query (:create-table 'items ((id :type bigserial :primary-key t) (embedding :type vector\(3\)))))

(query (:insert-into 'items :set 'embedding "[1,1,1]"))
(query (:insert-rows-into 'items :columns 'embedding :values '(("[2,2,2]") ("[1,1,2]"))))

(doquery (:limit (:order-by (:select 'id 'embedding :from 'items) (:<-> 'embedding "[1,1,1]")) 5) (id embedding)
    (format t "~A: ~A~%" id embedding))

(query (:create-index 'my-index :on 'items :using hnsw :fields "embedding vector_l2_ops"))
