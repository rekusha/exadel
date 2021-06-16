FROM openjdk:8
RUN echo "public class HelloWorld{\
public static void main(String[] args){\
System.out.println("Hello, World!");\
}\
}" > /tmp/HelloWorld.java
WORKDIR /tmp
ENTRYPOINT ["java","HelloWorld"]
