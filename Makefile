PWSH = pwsh

.PHONY: build
build: build-deps
	cabal build -j

.PHONY: build-deps
build-deps:
	cabal build -j --only-dependencies

.PHONY: test
test: test-doctest test-original test-hdbc-postgresql test-relational-record

.PHONY: build-doctest
build-doctest: build
	cabal build -j postgresql-pure:test:doctest

.PHONY: test-doctest
test-doctest: build-doctest
	cabal test -j postgresql-pure:test:doctest

.PHONY: build-original
build-original: build
	cabal build -j postgresql-pure:test:original

.PHONY: test-original
test-original: build-original
	cabal test -j postgresql-pure:test:original

.PHONY: build-hdbc-postgresql
build-hdbc-postgresql: build
	cabal build -j postgresql-pure:test:hdbc-postgresql

.PHONY: test-hdbc-postgresql
test-hdbc-postgresql: build-hdbc-postgresql
	cabal test -j postgresql-pure:test:hdbc-postgresql

.PHONY: build-relational-record
build-relational-record: build
	cabal build -j postgresql-pure:test:relational-record

.PHONY: test-relational-record
test-relational-record: build-relational-record
	cabal test -j postgresql-pure:test:relational-record

.PHONY: build-requests-per-second
build-requests-per-second: build
	cabal build -j postgresql-pure:bench:requests-per-second

.PHONY: bench-requests-per-second
bench-requests-per-second: build-requests-per-second
	cabal bench -j postgresql-pure:bench:requests-per-second

.PHONY: build-requests-per-second-constant
build-requests-per-second-constant: build
	cabal build -j postgresql-pure:bench:requests-per-second-constant

.PHONY: bench-requests-per-second-constant
bench-requests-per-second-constant: build-requests-per-second-constant
	cabal bench -j postgresql-pure:bench:requests-per-second-constant

.PHONY: init-test-asset
init-test-asset:
	psql -Upostgres -f test-asset/create-tables.sql
	psql -Upostgres -f test-asset/insert.sql

.PHONY: format
format:
	$(PWSH) -Command "& { Get-ChildItem -Filter '*.hs' -Recurse src, test, test-doctest, test-relational-record, benchmark | Where-Object { $$_.Directory -notlike '*\src\Database\PostgreSQL\Simple\Time\Internal' } | ForEach-Object { stack exec -- stylish-haskell -i $$_.FullName } }"
	stylish-haskell -i Setup.hs

.PHONY: lint
lint:
	hlint\
		src/Database/PostgreSQL/Pure.hs\
		src/Database/PostgreSQL/Pure\
		src/Database/HDBC\
		test-original\
		test-doctest\
		test-relational-record\
		benchmark

pages-path=../postgresql-pure-pages

.PHONY: doc
doc:
	$(PWSH) -Command "& {\
		Remove-Item -Recurse $(pages-path)\*;\
		stack --stack-yaml stack-nightly.yaml haddock --haddock-arguments '--odir $(pages-path)';\
		$$revision = $$(git rev-parse HEAD);\
		Push-Location $(pages-path);\
		git add .;\
		git commit -m $$revision;\
		Pop-Location\
	}"

.PHONY: push-doc
push-doc:
	$(PWSH) -Command "& {\
		Push-Location $(pages-path);\
		git push;\
		Pop-Location\
	}"

.PHONY: targets
targets:
	$(PWSH) -Command "& { Get-Content .\Makefile | Where-Object { $$_ -like '.PHONY*' } | ForEach-Object { $$_.Substring(8) } }"

.PHONY: clean
clean:
	cabal clean
	$(PWSH) -Command "& { Remove-Item src\Database\PostgreSQL\Pure\Internal\Builder.hs, src\Database\PostgreSQL\Pure\Internal\Parser.hs, src\Database\PostgreSQL\Pure\Internal\Length.hs }"
