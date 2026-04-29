#!/bin/bash
set -e

echo "Packaging Lambda..."

mkdir -p build
rm -f build/lambda.zip

cd lambda
zip -r ../build/lambda.zip .
cd ..

echo "Lambda package created at build/lambda.zip"