# Quick guide - Objective-C

This guide is for using Alchemic with Objective-C sources.

Table of Contents



## Install via Carthage [![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

1. Add to your **Cartfile**:  
     `github "drekka/Alchemic" "master"`
2. Build dependencies:  
     `carthage update`
3. Drag and drop the following frameworks into your project:
    * **<project-root>/Carthage/Build/iOS/Alchemic.framework**
    * **<project-root>/Carthage/Build/iOS/StoryTeller.framework**
    * **<project-root>/Carthage/Build/iOS/PEGKit.framework**
4. Ensure  the above frameworks are added to a build phase that copies them to the **Framworks** Destination. Check out the [carthage documentation](https://github.com/Carthage/Carthage) for the details of doing this. 

# Starting Alchemic
 
Nothing to do! Magic happens! 

Ok, I hate magic in software too. Alchemic will automatically start itself on a background thread.
 
# Tasks

This list is by no means complete. But it gives a good indicative summary of how you can use Alchemic in your application.
 
# Registering

## Singleton instances

```objectivec
@implementation MyClass
AcRegister()
@end
```

MyClass will be created on application startup and managed as a singleton by Alchemic. 

## Singletons created by a method

```objectivec
@implementation MyClass
 
AcMethod(SomeOtherClass , createSomeOtherClassWithMyClass:, 
    AcArg(MyClass, AcName(@"MyClass"))
-(SomeOtherClass *) createSomeOtherClassWithMyClass:(MyClass *) myClass {
	// Create it
	return otherClass;
}
@end
```

MyClass will be instantiated and managed as a singleton. SomeOtherClass will then be instantiated using the createSomeOtherClassWithMyClass: method and also managed as a singleton. 

## Naming factories

```objectivec
@implementation MyClass
AcRegister(AcFactory, AcWithName(@"Thing factory"))
@end
```

Every time a MyClass instance is required or requested, a new one will be created and returned.

## Custom initialisers

```objectivec
@implementation MyClass
AcInitializer(initWithObjects:, AcArg(NSArray, AcProtocol(MyProtocol)))
-(instancetype) initWithObects:(NSArray<id<MyProtocol>> *objects {
    self = ...
    return self;
}
@end
```

MyClass will be registered as a factory, using the initWithObjects: method to create each instance. The objects argument will be an array sourced from Alchemic managed objects which conform to the MyProtocol protocol.
 
# Injections

## Simple object

```objectivec
@implementation MyClass {
    MyOtherClass *_otherThing;
}
 AcInject(_otherThing)
@end
```

Simplest form of injecting a value. The injected value will be found by searching the model for MyOtherClass objects. It is assumed that only one will be found and Alchemic will throw an error if there is zero or more than one.  

## A generaliased reference with a specific type

```objectivec
@implementation MyClass {
    id<MyProtocol> _otherThing;
}
 AcInject(_otherThing, AcClass(MyOtherClass))
@end
```

This example shows how Alchemic can locate a specific object based on it's class (MyOtherClass) and inject into a more generic variable.

## An array of all objects with a protocol

```objectivec
@implementation MyClass {
    NSArray<id<MyProtocol>> *_things;
}
 AcInject(_things, AcProtocol(MyProtocol))
@end
```

Locates all objects in Alchemic that conform to the MyProtocol protocol and injects them as an array.

# Other tasks
  
## Register a override object in a unit test

```objectivec 
@implementation MySystemTests
AcMethod(MyClass, createOverride, AcPrimary)
-(MyClass *) createOverride {
   // Create the override
   return override;
}
@end
```
 
Shows how you can use ALchemic registered methods in a unit test to generate objects and use them as overrides for objects in the application code. Mainly useful for substituting in dummy or fake instances for testing purposes. Could even be used to inject [OCMock](http://ocmock.org) objects.
 
## Self injecting in non-managed classes

```objectivec
-(instancetype) initWithFrame:(CGRect) aFrame {
    self = [super initWithFrame:aFrame];
    if (self) {
        AcInjectDependencies(self);
    }
    return self;
}
```

The instance to have dependencies injected is not being created by Alchemic so after creating it, inject values.

## Getting a object in code

```objectivec
-(void) someMethod {
    MyClass *myClass = AcGet(MyClass, AcName(@"My instance"));
}
```

## Using a factory initializer with custom arguments

```objectivec
AcInitializer(initWithText:, AcFactory, AcWithName(@"createSomething"), AcArg(NSString, AcValue(@"Default message")
-(instancetype) initWithText:(NSString *) message {
    // ...
}
```

```objectivec
-(void) someMethod {
    MyObj *myObj = AcInvoke(AcName(@"createSomething"), @"Overriding message text");
}
```

Declaring a factory method and them calling it manually from other code. Notice that when calling the method there is no requirement to know what class it belongs to.