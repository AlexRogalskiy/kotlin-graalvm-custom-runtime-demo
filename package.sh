#!/usr/bin/env bash
./gradlew shadowJar

docker run --rm --name graal -v $(pwd):/working oracle/graalvm-ce:1.0.0-rc10 \
    /bin/bash -c "native-image --enable-url-protocols=http \
                    -Djava.net.preferIPv4Stack=true \
                    -H:ReflectionConfigurationFiles=/working/reflect.json \
                    --delay-class-initialization-to-runtime=software.amazon.awssdk.awscore.client.builder.AwsDefaultClientBuilder \
                    --delay-class-initialization-to-runtime=software.amazon.awssdk.auth.signer.internal.AbstractAws4Signer \
                    --delay-class-initialization-to-runtime=software.amazon.awssdk.auth.credentials.DefaultCredentialsProvider \
                    --delay-class-initialization-to-runtime=software.amazon.awssdk.utils.IoUtils \
                    --delay-class-initialization-to-runtime=software.amazon.awssdk.utils.internal.SystemSettingUtils \
                    --delay-class-initialization-to-runtime=software.amazon.awssdk.protocols.json.internal.unmarshall.JsonErrorCodeParser \
                    --delay-class-initialization-to-runtime=software.amazon.awssdk.core.internal.http.pipeline.stages.HandleResponseStage \
                    --delay-class-initialization-to-runtime=software.amazon.awssdk.core.internal.http.pipeline.stages.RetryableStage \
                    --delay-class-initialization-to-runtime=software.amazon.awssdk.regions.providers.AwsRegionProviderChain \
                    --delay-class-initialization-to-runtime=software.amazon.awssdk.core.io.ReleasableInputStream \
                    --delay-class-initialization-to-runtime=software.amazon.awssdk.regions.util.HttpResourcesUtils \
                    --delay-class-initialization-to-runtime=software.amazon.awssdk.http.apache.ApacheHttpClient \
                    --delay-class-initialization-to-runtime=software.amazon.awssdk.http.apache.internal.RepeatableInputStreamRequestEntity \
                    --delay-class-initialization-to-runtime=software.amazon.awssdk.http.apache.internal.net.SdkSslSocket \
                    --delay-class-initialization-to-runtime=software.amazon.awssdk.http.apache.internal.net.SdkSocket \
                    --delay-class-initialization-to-runtime=software.amazon.awssdk.core.internal.util.UserAgentUtils \
                    --delay-class-initialization-to-runtime=software.amazon.awssdk.core.interceptor.ExecutionInterceptorChain \
                    --delay-class-initialization-to-runtime=software.amazon.awssdk.core.internal.http.StreamManagingStage \
                    --delay-class-initialization-to-runtime=software.amazon.awssdk.core.internal.http.pipeline.stages.utils.ExceptionReportingUtils \
                    --delay-class-initialization-to-runtime=software.amazon.awssdk.profiles.internal.ProfileFileReader \
                    -H:+ReportUnsupportedElementsAtRuntime --no-server -jar /working/build/libs/kotlin-graalvm-custom-runtime-demo-1.0-all.jar \
                    ; \
                    cp kotlin-graalvm-custom-runtime-demo-1.0-all /working/build/server"

rm -rf build/package
mkdir build/package

cp build/server build/package

cp runtime/bootstrap build/package

zip -j build/package/bundle.zip build/package/bootstrap build/package/server