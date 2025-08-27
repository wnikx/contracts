# Makefile for generating Go code from .proto files

# === Settings ===
PROTOC      ?= protoc
PROTO_DIR   ?= proto
OUT_DIR     ?= gen/go
OPENAPI_DIR ?= gen/openapi

# Рекурсивно собираем все .proto
PROTOS := $(shell find $(PROTO_DIR) -name '*.proto')

.PHONY: default generate gen tools clean tree

# Если не указана команда — выполнить генерацию
default: generate

# Алиас
gen: generate

# Генерация кода
generate:
	@mkdir -p $(OUT_DIR)
	@mkdir -p $(OPENAPI_DIR)
	$(PROTOC) -I $(PROTO_DIR) \
		-I $(shell go env GOPATH)/pkg/mod/github.com/grpc-ecosystem/grpc-gateway@v1.16.0/third_party/googleapis \
		$(PROTOS) \
		--go_out=$(OUT_DIR) --go_opt=paths=source_relative \
		--go-grpc_out=$(OUT_DIR) --go-grpc_opt=paths=source_relative \
		--grpc-gateway_out=$(OUT_DIR) --grpc-gateway_opt=paths=source_relative \
		--openapiv2_out=$(OPENAPI_DIR) --openapiv2_opt=logtostderr=true
	@echo "✓ Generated Go code into $(OUT_DIR)"
	@echo "✓ Generated OpenAPI spec into $(OPENAPI_DIR)"

# Установка необходимых плагинов (один раз)
tools:
	@which $(PROTOC) >/dev/null || (echo "❌ protoc not found. Install from https://github.com/protocolbuffers/protobuf/releases"; exit 1)
	@go install google.golang.org/protobuf/cmd/protoc-gen-go@latest
	@go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest
	@go install github.com/grpc-ecosystem/grpc-gateway/v2/protoc-gen-grpc-gateway@latest
	@go install github.com/grpc-ecosystem/grpc-gateway/v2/protoc-gen-openapiv2@latest
	@echo "✓ Tools ready"

# Очистка артефактов генерации
clean:
	@rm -rf $(OUT_DIR)
	@echo "✓ Cleaned $(OUT_DIR)"

# Быстрый просмотр структуры
tree:
	@echo "Proto dir: $(PROTO_DIR)"
	@echo "Out dir:   $(OUT_DIR)"
	@echo "Protos:"
	@printf "  %s\n" $(PROTOS)
