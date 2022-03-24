ARG GO_VERSION=1.18

FROM --platform=$BUILDPLATFORM golang:${GO_VERSION}-alpine as builder

# Set necessary environmet variables needed for our image

ARG TARGETPLATFORM

ENV GO111MODULE=on \
    CGO_ENABLED=0 
#    GOOS=$TARGETOS \
#    GOARCH=$TARGETARCH

# Move to working directory /build
WORKDIR /build

RUN apk add git

# Copy and download dependency using go mod
COPY go.mod .
COPY go.sum .
RUN go mod download

# Copy the code into the container
COPY . .

# Build the application
RUN go build -o tc4400_exporter .

# Move to /dist directory as the place for resulting binary folder
WORKDIR /dist

# Copy binary from build to main folder
RUN cp /build/tc4400_exporter .

# Build a small image
FROM alpine:latest

COPY --from=builder /dist/tc4400_exporter /

# Command to run when starting the container
CMD ["/tc4400_exporter"]