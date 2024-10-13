# ----------------------------------------------
# ビルド用環境
# ----------------------------------------------
    FROM golang:1.17.7-alpine AS builder

    WORKDIR /app
    
    COPY go.mod go.sum ./
    RUN go mod download
    
    COPY . .
    RUN go build -o main /app/api/main.go
    
    # ----------------------------------------------
    # 本番環境
    # ----------------------------------------------
    FROM alpine:3.13 AS prod
    
    RUN apk --no-cache add ca-certificates
    
    WORKDIR /app
    
    COPY --from=builder /app/main .
    
    EXPOSE 8080
    
    CMD [ "/app/main" ]
    
    # ----------------------------------------------
    # 開発環境（ホットリロード対応）
    # ----------------------------------------------
    FROM golang:1.17.7-alpine AS dev
    
    WORKDIR /app
    
    RUN apk update && apk add alpine-sdk jq mysql mysql-client
    
    RUN go get github.com/cosmtrek/air@v1.27.3

    
    COPY . .
    
    CMD ["air"]
    