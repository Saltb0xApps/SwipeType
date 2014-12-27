//
//  Pastie.m
//  Paste
//
//  Created by Akhil Tolani on 7/5/10.
//  Copyright 2010 Saltb0xApps. All rights reserved.
//

#import "Pastie.h"

#define kHeaderBoundary @"_xuzz_productions_paste_"

@implementation Pastie
@synthesize delegate;

+ (NSDictionary *)languages {
    return [NSDictionary dictionaryWithObjectsAndKeys:
            [NSNumber numberWithInt:2],  @"ActionScript",
            [NSNumber numberWithInt:13], @"Bash (shell)",
            [NSNumber numberWithInt:20], @"C#",
            [NSNumber numberWithInt:7],  @"C/C++",
            [NSNumber numberWithInt:8],  @"CSS",
            [NSNumber numberWithInt:5],  @"Diff",
            [NSNumber numberWithInt:21], @"Go",
            [NSNumber numberWithInt:12], @"HTML (ERB / Rails)",
            [NSNumber numberWithInt:11], @"HTML / XML",
            [NSNumber numberWithInt:9],  @"Java",
            [NSNumber numberWithInt:10], @"JavaScript",
            [NSNumber numberWithInt:1],  @"Objective-C/C++",
            [NSNumber numberWithInt:18], @"Perl",
            [NSNumber numberWithInt:15], @"PHP",
            [NSNumber numberWithInt:6],  @"Plain Text",
            [NSNumber numberWithInt:16], @"Python", 
            [NSNumber numberWithInt:3],  @"Ruby", 
            [NSNumber numberWithInt:4],  @"Ruby on Rails", 
            [NSNumber numberWithInt:14], @"SQL", 
            [NSNumber numberWithInt:19], @"YAML",nil];
}
- (NSString *)stringByConvertingHTMLToPlainTextFromString:(NSString *)string {
    
	// Pool
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
	// Character sets
	NSCharacterSet *stopCharacters = [NSCharacterSet characterSetWithCharactersInString:[NSString stringWithFormat:@"< \t\n\r%C%C%C%C", (unsigned short)0x0085, (unsigned short)0x000C,(unsigned short) 0x2028,(unsigned short) 0x2029]];
	NSCharacterSet *newLineAndWhitespaceCharacters = [NSCharacterSet characterSetWithCharactersInString:[NSString stringWithFormat:@" \t\n\r%C%C%C%C", (unsigned short)0x0085,(unsigned short) 0x000C, (unsigned short)0x2028, (unsigned short)0x2029]];
	NSCharacterSet *tagNameCharacters = [NSCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"]; /**/
    
	// Scan and find all tags
	NSMutableString *result = [[NSMutableString alloc] initWithCapacity:string.length];
	NSScanner *scanner = [[NSScanner alloc] initWithString:string];
	[scanner setCharactersToBeSkipped:nil];
	[scanner setCaseSensitive:YES];
	NSString *str = nil, *tagName = nil;
	BOOL dontReplaceTagWithSpace = NO;
	do {
        
		// Scan up to the start of a tag or whitespace
		if ([scanner scanUpToCharactersFromSet:stopCharacters intoString:&str]) {
			[result appendString:str];
			str = nil; // reset
		}
        
		// Check if we've stopped at a tag/comment or whitespace
		if ([scanner scanString:@"<" intoString:NULL]) {
            
			// Stopped at a comment or tag
			if ([scanner scanString:@"!--" intoString:NULL]) {
                
				// Comment
				[scanner scanUpToString:@"-->" intoString:NULL]; 
				[scanner scanString:@"-->" intoString:NULL];
                
			} else {
                
				// Tag - remove and replace with space unless it's
				// a closing inline tag then dont replace with a space
				if ([scanner scanString:@"/" intoString:NULL]) {
                    
					// Closing tag - replace with space unless it's inline
					tagName = nil; dontReplaceTagWithSpace = NO;
					if ([scanner scanCharactersFromSet:tagNameCharacters intoString:&tagName]) {
						tagName = [tagName lowercaseString];
						dontReplaceTagWithSpace = ([tagName isEqualToString:@"a"] ||
												   [tagName isEqualToString:@"b"] ||
												   [tagName isEqualToString:@"i"] ||
												   [tagName isEqualToString:@"q"] ||
												   [tagName isEqualToString:@"span"] ||
												   [tagName isEqualToString:@"em"] ||
												   [tagName isEqualToString:@"strong"] ||
												   [tagName isEqualToString:@"cite"] ||
												   [tagName isEqualToString:@"abbr"] ||
												   [tagName isEqualToString:@"acronym"] ||
												   [tagName isEqualToString:@"label"]);
					}
                    
					// Replace tag with string unless it was an inline
					if (!dontReplaceTagWithSpace && result.length > 0 && ![scanner isAtEnd]) [result appendString:@" "];
                    
				}
                
				// Scan past tag
				[scanner scanUpToString:@">" intoString:NULL];
				[scanner scanString:@">" intoString:NULL];
                
			}
            
		} else {
            
			// Stopped at whitespace - replace all whitespace and newlines with a space
			if ([scanner scanCharactersFromSet:newLineAndWhitespaceCharacters intoString:NULL]) {
				if (result.length > 0 && ![scanner isAtEnd]) [result appendString:@" "]; // Dont append space to beginning or end of result
			}
            
		}
        
	} while (![scanner isAtEnd]);
    
	// Cleanup
	[scanner release];
    
	// Drain
	[pool drain];
    
	// Return
	return result;
    
}

- (void)beginSubmissionWithText:(NSString *)text makePrivate:(BOOL)private language:(NSInteger)language {
    
    NSString *textString = [text stringByReplacingOccurrencesOfString:@"<br>" withString:@"\r"];
	NSString *finalString = [[NSString alloc] initWithString:[self stringByConvertingHTMLToPlainTextFromString:textString]];
    
	NSMutableDictionary *post_dict = [NSMutableDictionary dictionary];
	[post_dict setObject:finalString forKey:@"paste[body]"];
	[post_dict setObject:@"burger" forKey:@"paste[authorization]"];
	[post_dict setObject:private ? @"1" : @"0" forKey:@"paste[restricted]"];
	[post_dict setObject:[NSString stringWithFormat:@"%d", language] forKey:@"paste[parser_id]"];
	
	NSMutableData *post_data = [NSMutableData data];
	for (NSString *key in [post_dict allKeys]) {
		[post_data appendData:[[NSString stringWithFormat:@"--%@\r\n", kHeaderBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
		[post_data appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", key] dataUsingEncoding:NSUTF8StringEncoding]];
		[post_data appendData:[[post_dict valueForKey:key] dataUsingEncoding:NSUTF8StringEncoding]];
		[post_data appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
	}
	[post_data appendData:[[NSString stringWithFormat:@"--%@--\r\n", kHeaderBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
	
	
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://pastie.org/pastes"]];
	NSString *content_type = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", kHeaderBoundary];
	[request addValue:content_type forHTTPHeaderField:@"Content-Type"];
	[request setHTTPMethod:@"POST"];
	[request setHTTPBody:post_data];
	
	[NSURLConnection connectionWithRequest:request delegate:self];
}

- (void)beginSubmissionWithText:(NSString *)text makePrivate:(BOOL)private {
    [self beginSubmissionWithText:text makePrivate:NO language:6];
}

- (void)beginSubmissionWithText:(NSString *)text {
    [self beginSubmissionWithText:text makePrivate:NO];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	if ([delegate respondsToSelector:@selector(submissionFailedWithError:)])
		[delegate submissionFailedWithError:nil];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
	if ([delegate respondsToSelector:@selector(submissionCompletedWithURL:)])
		[delegate submissionCompletedWithURL:[response URL]];
}

@end
 