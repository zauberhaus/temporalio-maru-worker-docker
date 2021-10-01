#/bin/sh

VERSION=`cat version.txt`
REPO=https://github.com/temporalio/maru.git
ARCHS="arm64 armv6 armv7 s390x ppc64le amd64 386"
PROG=temporal-bench

mkdir -p ./dist

if [ ! -d ./src ]; then
    git clone $REPO src 
    cd src 
    echo "Checkout tag $VERSION" 
    if [ "$VERSION" != "main" ] && [ ! -z "$VERSION" ] ; then git checkout tags/${VERSION} -b ${VERSION} ; fi
else
    cd src    
fi

cd worker
export GOFLAGS="-mod=readonly"
go mod download

FLAGS="-w -s"
export CGO_ENABLED=0
export GOOS=linux
export GO386=softfloat

for arch in $ARCHS ; do
    if expr "$arch" : "armv6$" 1>/dev/null; then
        export GOARCH=arm 
        export GOARM=6
    elif expr "$arch" : "armv7$" 1>/dev/null; then
        export GOARCH=arm
        export GOARM=7
    else 
        export GOARCH=$arch
    fi

    echo "Build $PROG.$arch $VERSION" 
    go build -o ../../build/$PROG.$arch -ldflags "$FLAGS" ./cmd/*.go
done