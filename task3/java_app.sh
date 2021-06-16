FROM openjdk:8
RUN touch /tmp/HelloWorld.java
RUN echo "public class HelloWorld{\
public static void main(String[] args){\
System.out.println("Hello, World!");\
}\
}"
WORKDIR /tmp
ENTRYPOINT ["java","HelloWorld"]
