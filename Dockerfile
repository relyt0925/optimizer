# Use a multi-stage build
FROM golang:1.23-bookworm AS builder

# Install the lpsolve package
RUN apt-get update && apt-get install -y liblpsolve55-dev

WORKDIR /app
COPY . .

# Set CGO flags for lpsolve package
ENV CGO_CFLAGS="-I/usr/include/lpsolve"
ENV CGO_LDFLAGS="-llpsolve55 -lm -ldl -lcolamd"

# Build all main.go files in cmd directory
RUN go build -o bin/demomain demos/main/main.go


# Create the final image
FROM debian:bookworm-slim
RUN apt-get update && apt-get install -y liblpsolve55-dev
COPY --from=builder /app/bin /bin
COPY --from=builder /app/rhaienvironments /etc/rhaienvironments
RUN ls /etc/rhaienvironments/staging


# Expose the port the API will listen on
EXPOSE 8080

# Command to run the binary when the container starts
CMD ["optimizer"]