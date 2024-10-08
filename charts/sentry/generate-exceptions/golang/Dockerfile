# Use the official Go image
FROM golang:1.21-alpine

# Set the working directory
WORKDIR /app

# Copy go.mod and go.sum
COPY go.mod go.sum ./

# Load dependencies
RUN go mod download

# Copy the source code
COPY . .

# Build the application
RUN go build -o main .

# Specify the port to be used by the container
EXPOSE 8080

# Run the application
CMD ["./main"]
