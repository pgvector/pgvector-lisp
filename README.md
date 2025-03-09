# pgvector-lisp

[pgvector](https://github.com/pgvector/pgvector) examples for Common Lisp

Supports [Postmodern](https://github.com/marijnh/Postmodern) and [CL-DBI](https://github.com/fukamachi/cl-dbi)

[![Build Status](https://github.com/pgvector/pgvector-lisp/actions/workflows/build.yml/badge.svg)](https://github.com/pgvector/pgvector-lisp/actions)

## Getting Started

Follow the instructions for your database library:

- [Postmodern](#postmodern)
- [CL-DBI](#cl-dbi)

## Postmodern

Enable the extension

```lisp
(load-extension "vector")
```

Create a table

```lisp
(query (:create-table 'items ((id :type bigserial :primary-key t) (embedding :type (vector 3)))))
```

Insert a vector

```lisp
(query (:insert-into 'items :set 'embedding "[1,1,1]"))
```

Get the nearest neighbors

```lisp
(doquery (:limit (:order-by (:select 'id 'embedding :from 'items) (:<-> 'embedding "[1,1,1]")) 5) (id embedding)
    (format t "~A: ~A~%" id embedding))
```

Add an approximate index

```lisp
(query (:create-index 'my-index :on 'items :using hnsw :fields "embedding vector_l2_ops"))
;; or
(query (:create-index 'my-index :on 'items :using ivfflat :fields "embedding vector_l2_ops" :with (:= 'lists 100)))
```

Use `vector_ip_ops` for inner product and `vector_cosine_ops` for cosine distance

See a [full example](postmodern.lisp)

## CL-DBI

Enable the extension

```lisp
(dbi:do-sql *conn* "CREATE EXTENSION IF NOT EXISTS vector")
```

Create a table

```lisp
(dbi:do-sql *conn* "CREATE TABLE items (id bigserial PRIMARY KEY, embedding vector(3))")
```

Insert a vector

```lisp
(dbi:do-sql *conn* "INSERT INTO items (embedding) VALUES (?)" (list "[1,1,1]"))
```

Get the nearest neighbors

```lisp
(dbi:fetch-all (dbi:execute (dbi:prepare *conn* "SELECT * FROM items ORDER BY embedding <-> ? LIMIT 5") (list "[1,1,1]")))
```

Add an approximate index

```lisp
(dbi:do-sql *conn* "CREATE INDEX ON items USING hnsw (embedding vector_l2_ops)")
;; or
(dbi:do-sql *conn* "CREATE INDEX ON items USING ivfflat (embedding vector_l2_ops) WITH (lists = 100)")
```

Use `vector_ip_ops` for inner product and `vector_cosine_ops` for cosine distance

See a [full example](cl-dbi.lisp)

## Contributing

Everyone is encouraged to help improve this project. Here are a few ways you can help:

- [Report bugs](https://github.com/pgvector/pgvector-lisp/issues)
- Fix bugs and [submit pull requests](https://github.com/pgvector/pgvector-lisp/pulls)
- Write, clarify, or fix documentation
- Suggest or add new features

To get started with development:

```sh
git clone https://github.com/pgvector/pgvector-lisp.git
cd pgvector-lisp
createdb pgvector_lisp_test
sbcl --noinform --non-interactive --load postmodern.lisp --load cl-dbi.lisp
```
