#import "TDTestScaffold.h"
#import "PGParserFactory.h"
#import "PGParserGenVisitor.h"
#import "PGRootNode.h"
#import "GreedyFailureNestedParser.h"

@interface GreedyFailureNestedParserTest : XCTestCase
@property (nonatomic, retain) PGParserFactory *factory;
@property (nonatomic, retain) PGRootNode *root;
@property (nonatomic, retain) PGParserGenVisitor *visitor;
@property (nonatomic, retain) GreedyFailureNestedParser *parser;
@property (nonatomic, retain) id mock;
@end

@implementation GreedyFailureNestedParserTest

- (void)parser:(PKParser *)p didFailToMatch:(PKAssembly *)a {}

- (void)parser:(PKParser *)p didMatchLcurly:(PKAssembly *)a {}
- (void)parser:(PKParser *)p didMatchRcurly:(PKAssembly *)a {}
- (void)parser:(PKParser *)p didMatchName:(PKAssembly *)a {}
- (void)parser:(PKParser *)p didMatchColon:(PKAssembly *)a {}
- (void)parser:(PKParser *)p didMatchValue:(PKAssembly *)a {}
- (void)parser:(PKParser *)p didMatchComma:(PKAssembly *)a {}
- (void)parser:(PKParser *)p didMatchStructure:(PKAssembly *)a {}
- (void)parser:(PKParser *)p didMatchStructs:(PKAssembly *)a {}

- (void)dealloc {
    self.factory = nil;
    self.root = nil;
    self.visitor = nil;
    self.parser = nil;
    self.mock = nil;
    [super dealloc];
}


- (void)setUp {
    self.factory = [PGParserFactory factory];
    _factory.collectTokenKinds = YES;

    NSError *err = nil;
    NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:@"greedy_failure_nested" ofType:@"grammar"];
    NSString *g = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&err];
    
    err = nil;
    self.root = (id)[_factory ASTFromGrammar:g error:&err];
    _root.grammarName = @"GreedyFailureNested";
    
    self.visitor = [[[PGParserGenVisitor alloc] init] autorelease];
    _visitor.delegatePostMatchCallbacksOn = PGParserFactoryDelegateCallbacksOnAll;
    _visitor.enableAutomaticErrorRecovery = YES;
    _visitor.enableMemoization = NO;
    
    [_root visit:_visitor];
    
#if TD_EMIT
    path = [[NSString stringWithFormat:@"%s/test/GreedyFailureNestedParser.h", getenv("PWD")] stringByExpandingTildeInPath];
    err = nil;
    if (![_visitor.interfaceOutputString writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:&err]) {
        NSLog(@"%@", err);
    }

    path = [[NSString stringWithFormat:@"%s/test/GreedyFailureNestedParser.m", getenv("PWD")] stringByExpandingTildeInPath];
    err = nil;
    if (![_visitor.implementationOutputString writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:&err]) {
        NSLog(@"%@", err);
    }
#endif

    self.mock = [OCMockObject mockForClass:[GreedyFailureNestedParserTest class]];

    self.parser = [[[GreedyFailureNestedParser alloc] initWithDelegate:_mock] autorelease];
    _parser.enableAutomaticErrorRecovery = YES;
    
    // return YES to -respondsToSelector:
    [[[_mock stub] andReturnValue:OCMOCK_VALUE((BOOL){YES})] respondsToSelector:(SEL)OCMOCK_ANY];
}

- (void)tearDown {
    self.factory = nil;
}

- (void)testCompleteStruct {
    
    [[_mock expect] parser:_parser didMatchLcurly:OCMOCK_ANY];
    [[_mock expect] parser:_parser didMatchName:OCMOCK_ANY];
    [[_mock expect] parser:_parser didMatchColon:OCMOCK_ANY];
    [[_mock expect] parser:_parser didMatchValue:OCMOCK_ANY];
    [[_mock expect] parser:_parser didMatchRcurly:OCMOCK_ANY];
    [[_mock expect] parser:_parser didMatchStructure:OCMOCK_ANY];
    [[_mock expect] parser:_parser didMatchStructs:OCMOCK_ANY];

    [[[_mock stub] andDo:^(NSInvocation *invoc) {
        PKAssembly *a = nil;
        [invoc getArgument:&a atIndex:3];
        //NSLog(@"%@", a);
        
        TDTrue(0); // should never reach
        
    }] parser:_parser didFailToMatch:OCMOCK_ANY];

    NSError *err = nil;
    PKAssembly *res = [_parser parseString:@"{'foo':bar}" error:&err];
    TDEqualObjects(TDAssembly(@"[{, 'foo', :, bar, }]{/'foo'/:/bar/}^"), [res description]);
    
    VERIFY();
}

- (void)testIncompleteStruct {
    
    [[_mock expect] parser:_parser didMatchLcurly:OCMOCK_ANY];
    [[_mock expect] parser:_parser didMatchName:OCMOCK_ANY];
    [[_mock expect] parser:_parser didMatchColon:OCMOCK_ANY];
    [[_mock expect] parser:_parser didMatchValue:OCMOCK_ANY];

//    [[_mock expect] parser:_parser didMatchRcurly:OCMOCK_ANY];
//    [[_mock expect] parser:_parser didMatchStructure:OCMOCK_ANY];

    //[[_mock expect] parser:_parser didMatchStructs:OCMOCK_ANY];
    
    [[[_mock stub] andDo:^(NSInvocation *invoc) {
        PKAssembly *a = nil;
        [invoc getArgument:&a atIndex:3];
        //NSLog(@"%@", a);
        
        TDEqualObjects(TDAssembly(@"[{, 'foo', :, bar]{/'foo'/:/bar^"), [a description]);
        
    }] parser:_parser didFailToMatch:OCMOCK_ANY];

    NSError *err = nil;
    PKAssembly *res = [_parser parseString:@"{'foo':bar" error:&err];
    TDEqualObjects(TDAssembly(@"[{, 'foo', :, bar]{/'foo'/:/bar^"), [res description]);
    
    VERIFY();
}

- (void)testIncompleteStruct1 {
    
    [[[_mock stub] andDo:^(NSInvocation *invoc) {
        PKAssembly *a = nil;
        [invoc getArgument:&a atIndex:3];
        //NSLog(@"%@", a);
        
        TDEqualObjects(TDAssembly(@"[{]{^"), [a description]);
        [a pop]; // pop {
        
    }] parser:_parser didMatchLcurly:OCMOCK_ANY];
    
    
    [[[_mock stub] andDo:^(NSInvocation *invoc) {
        PKAssembly *a = nil;
        [invoc getArgument:&a atIndex:3];
        //NSLog(@"%@", a);
        
        TDEqualObjects(TDAssembly(@"['foo']{/'foo'^"), [a description]);
        [a pop]; // pop 'foo'
        
    }] parser:_parser didMatchName:OCMOCK_ANY];
    
    [[[_mock stub] andDo:^(NSInvocation *invoc) {
        PKAssembly *a = nil;
        [invoc getArgument:&a atIndex:3];
        //NSLog(@"%@", a);
        
        TDEqualObjects(TDAssembly(@"[:]{/'foo'/:^"), [a description]);
        [a pop]; // pop :
        
    }] parser:_parser didMatchColon:OCMOCK_ANY];
    
    [[[_mock stub] andDo:^(NSInvocation *invoc) {
        PKAssembly *a = nil;
        [invoc getArgument:&a atIndex:3];
        //NSLog(@"%@", a);
        
        TDEqualObjects(TDAssembly(@"[bar]{/'foo'/:/bar^"), [a description]);
        [a pop]; // pop bar
        
    }] parser:_parser didMatchValue:OCMOCK_ANY];
    
    //[[_mock expect] parser:_parser didMatchStructs:OCMOCK_ANY];
    
    [[[_mock stub] andDo:^(NSInvocation *invoc) {
        PKAssembly *a = nil;
        [invoc getArgument:&a atIndex:3];
        //NSLog(@"%@", a);
        
        TDEqualObjects(TDAssembly(@"[]{/'foo'/:/bar^"), [a description]);
        
    }] parser:_parser didFailToMatch:OCMOCK_ANY];
    
    NSError *err = nil;
    PKAssembly *res = [_parser parseString:@"{'foo':bar" error:&err];
    TDEqualObjects(TDAssembly(@"[]{/'foo'/:/bar^"), [res description]);
    
    VERIFY();
}

//- (void)testIncompleteStruct1_1 {
//    
//    [[[_mock stub] andDo:^(NSInvocation *invoc) {
//        PKAssembly *a = nil;
//        [invoc getArgument:&a atIndex:3];
//        NSLog(@"%@", a);
//        
//        TDEqualObjects(TDAssembly(@"[{]{^"), [a description]);
//        [a pop]; // pop {
//        
//    }] parser:_parser didMatchLcurly:OCMOCK_ANY];
//    
//    
//    [[[_mock stub] andDo:^(NSInvocation *invoc) {
//        PKAssembly *a = nil;
//        [invoc getArgument:&a atIndex:3];
//        NSLog(@"%@", a);
//        
//        TDEqualObjects(TDAssembly(@"['foo']{/'foo'^"), [a description]);
//        [a pop]; // pop 'foo'
//        
//    }] parser:_parser didMatchName:OCMOCK_ANY];
//    
//    [[[_mock stub] andDo:^(NSInvocation *invoc) {
//        PKAssembly *a = nil;
//        [invoc getArgument:&a atIndex:3];
//        NSLog(@"%@", a);
//        
//        TDEqualObjects(TDAssembly(@"[:]{/'foo'/:^"), [a description]);
//        [a pop]; // pop :
//        
//    }] parser:_parser didMatchColon:OCMOCK_ANY];
//    
//    [[[_mock stub] andDo:^(NSInvocation *invoc) {
//        PKAssembly *a = nil;
//        [invoc getArgument:&a atIndex:3];
//        NSLog(@"%@", a);
//        
//        TDEqualObjects(TDAssembly(@"[bar]{/'foo'/:/bar^"), [a description]);
//        [a pop]; // pop bar
//        
//    }] parser:_parser didMatchValue:OCMOCK_ANY];
//    
//    [[[_mock stub] andDo:^(NSInvocation *invoc) {
//        PKAssembly *a = nil;
//        [invoc getArgument:&a atIndex:3];
//        NSLog(@"%@", a);
//        
//        TDEqualObjects(TDAssembly(@"[,]{/'foo'/:/bar/,^"), [a description]);
//        [a pop]; // pop ,
//        
//    }] parser:_parser didMatchComma:OCMOCK_ANY];
//    
//    [[_mock expect] parser:_parser didMatchStructs:OCMOCK_ANY];
//    
//    [[[_mock stub] andDo:^(NSInvocation *invoc) {
//        PKAssembly *a = nil;
//        [invoc getArgument:&a atIndex:3];
//        NSLog(@"%@", a);
//        
//        TDEqualObjects(TDAssembly(@"[]{/'foo'/:/bar/,^"), [a description]);
//        NSLog(@"");
//        
//    }] parser:_parser didFailToMatch:OCMOCK_ANY];
//    
//    NSError *err = nil;
//    PKAssembly *res = [_parser parseString:@"{'foo':bar," error:&err];
//    TDEqualObjects(TDAssembly(@"[]{/'foo'/:/bar/,^"), [res description]);
//    
//    VERIFY();
//}

- (void)testIncompleteStruct2 {
    
    [[[_mock stub] andDo:^(NSInvocation *invoc) {
        PKAssembly *a = nil;
        [invoc getArgument:&a atIndex:3];
        //NSLog(@"%@", a);
        
        TDEqualObjects(TDAssembly(@"[{]{^"), [a description]);
        [a pop]; // pop {
        
    }] parser:_parser didMatchLcurly:OCMOCK_ANY];
    
    
    [[[_mock stub] andDo:^(NSInvocation *invoc) {
        PKAssembly *a = nil;
        [invoc getArgument:&a atIndex:3];
        //NSLog(@"%@", a);
        
        TDEqualObjects(TDAssembly(@"['foo']{/'foo'^"), [a description]);
        [a pop]; // pop 'foo'
        
    }] parser:_parser didMatchName:OCMOCK_ANY];
    
    [[[_mock stub] andDo:^(NSInvocation *invoc) {
        PKAssembly *a = nil;
        [invoc getArgument:&a atIndex:3];
        //NSLog(@"%@", a);
        
        TDEqualObjects(TDAssembly(@"[:]{/'foo'/:^"), [a description]);
        [a pop]; // pop :
        
    }] parser:_parser didMatchColon:OCMOCK_ANY];

    [[[_mock stub] andDo:^(NSInvocation *invoc) {
        PKAssembly *a = nil;
        [invoc getArgument:&a atIndex:3];
        //NSLog(@"%@", a);
        
        TDEqualObjects(TDAssembly(@"[]{/'foo'/:^"), [a description]);
        
    }] parser:_parser didFailToMatch:OCMOCK_ANY];

//    [[_mock expect] parser:_parser didMatchValue:OCMOCK_ANY];

    [[[_mock stub] andDo:^(NSInvocation *invoc) {
        PKAssembly *a = nil;
        [invoc getArgument:&a atIndex:3];
        //NSLog(@"%@", a);
        
        TDEqualObjects(TDAssembly(@"[}]{/'foo'/:/}^"), [a description]);
        [a pop]; // pop }
        
    }] parser:_parser didMatchRcurly:OCMOCK_ANY];
    
    [[[_mock stub] andDo:^(NSInvocation *invoc) {
        PKAssembly *a = nil;
        [invoc getArgument:&a atIndex:3];
        //NSLog(@"%@", a);
        
        TDEqualObjects(TDAssembly(@"[]{/'foo'/:/}^"), [a description]);
        
    }] parser:_parser didMatchStructure:OCMOCK_ANY];
    
    [[_mock expect] parser:_parser didMatchStructs:OCMOCK_ANY];

    NSError *err = nil;
    PKAssembly *res = [_parser parseString:@"{'foo':}" error:&err];
    TDEqualObjects(TDAssembly(@"[]{/'foo'/:/}^"), [res description]);
    
    VERIFY();
}


- (void)testIncompleteStruct3 {
    
    [[[_mock stub] andDo:^(NSInvocation *invoc) {
        PKAssembly *a = nil;
        [invoc getArgument:&a atIndex:3];
        //NSLog(@"%@", a);
        
        TDEqualObjects(TDAssembly(@"[{]{^"), [a description]);
        [a pop]; // pop {
        
    }] parser:_parser didMatchLcurly:OCMOCK_ANY];
    
    
    [[[_mock stub] andDo:^(NSInvocation *invoc) {
        PKAssembly *a = nil;
        [invoc getArgument:&a atIndex:3];
        //NSLog(@"%@", a);
        
        TDEqualObjects(TDAssembly(@"[]{^"), [a description]);
        
    }] parser:_parser didFailToMatch:OCMOCK_ANY];

//    [[_mock expect] parser:_parser didMatchName:OCMOCK_ANY];
    
    [[[_mock stub] andDo:^(NSInvocation *invoc) {
        PKAssembly *a = nil;
        [invoc getArgument:&a atIndex:3];
        //NSLog(@"%@", a);
        
        TDEqualObjects(TDAssembly(@"[:]{/:^"), [a description]);
        [a pop]; // pop :
        
    }] parser:_parser didMatchColon:OCMOCK_ANY];
    
    [[[_mock stub] andDo:^(NSInvocation *invoc) {
        PKAssembly *a = nil;
        [invoc getArgument:&a atIndex:3];
        //NSLog(@"%@", a);
        
        TDEqualObjects(TDAssembly(@"[bar]{/:/bar^"), [a description]);
        [a pop]; // pop bar
        
    }] parser:_parser didMatchValue:OCMOCK_ANY];
    
    [[[_mock stub] andDo:^(NSInvocation *invoc) {
        PKAssembly *a = nil;
        [invoc getArgument:&a atIndex:3];
        //NSLog(@"%@", a);
        
        TDEqualObjects(TDAssembly(@"[}]{/:/bar/}^"), [a description]);
        [a pop]; // pop }
        
    }] parser:_parser didMatchRcurly:OCMOCK_ANY];
    
    [[[_mock stub] andDo:^(NSInvocation *invoc) {
        PKAssembly *a = nil;
        [invoc getArgument:&a atIndex:3];
        //NSLog(@"%@", a);
        
        TDEqualObjects(TDAssembly(@"[]{/:/bar/}^"), [a description]);
        
    }] parser:_parser didMatchStructure:OCMOCK_ANY];
    
    [[_mock expect] parser:_parser didMatchStructs:OCMOCK_ANY];
    
    NSError *err = nil;
    PKAssembly *res = [_parser parseString:@"{:bar}" error:&err];
    TDEqualObjects(TDAssembly(@"[]{/:/bar/}^"), [res description]);
    
    VERIFY();
}

@end
