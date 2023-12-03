# pgvector-lisp

[pgvector](https://github.com/pgvector/pgvector) examples for Common Lisp

Supports [Postmodern](https://github.com/marijnh/Postmodern)

[![Build Status](https://github.com/pgvector/pgvector-lisp/actions/workflows/build.yml/badge.svg?branch=master)](https://github.com/pgvector/pgvector-lisp/actions)

## Getting Started

Follow the instructions for your database library:

- [Postmodern](#postmodern)

## Postmodern

Enable the extension

```lisp
(query "CREATE EXTENSION IF NOT EXISTS vector")
```

Create a table

```lisp
(query "CREATE TABLE items (id bigserial PRIMARY KEY, embedding vector(3))")
```

Insert a vector

```lisp
(query (:insert-into 'items :set 'embedding "[1,1,1]"))
```

Get the nearest neighbors

```lisp
(register-sql-operators :2+-ary :<-> :<#> :<=>)

(doquery (:limit (:order-by (:select 'id 'embedding :from 'items) (:<-> 'embedding "[1,1,1]")) 5) (id embedding)
    (format t "~A: ~A~%" id embedding))
```

Add an approximate index

```lisp
(query "CREATE INDEX ON items USING ivfflat (embedding vector_l2_ops) WITH (lists = 100)")
;; or
(query "CREATE INDEX ON items USING hnsw (embedding vector_l2_ops)")
```

Use `vector_ip_ops` for inner product and `vector_cosine_ops` for cosine distance

See a [full example](example.lisp)

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
sbcl --non-interactive --load example.lisp
```
