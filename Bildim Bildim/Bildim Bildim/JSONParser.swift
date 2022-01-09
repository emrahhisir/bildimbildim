////
////  Example.swift
////  Bildim Bildim
////
////  Created by Emrah Hisir on 10/10/14.
////  Copyright (c) 2014 Emrah Hisir. All rights reserved.
////
//
//import Foundation
//
//func parseCategory(blog: AnyObject) -> Category? {
//    let mkBlog = curry {id, name, desc, imagePath, color, active, parentCat, subcats in Category(id: id, name: name, desc: desc, imagePath: icon, color: color, active: actflg, parentCat: parent_category_id, subcats: sub_category_ids, questions: nil) }
//    
//    return asDict(blog) >>>= {
//        mkBlog <*> int($0,"id")
//            <*> string($0,"name")
//            <*> bool($0,"needspassword")
//            <*> (string($0, "url") >>>= toURL)
//    }
//}
//
//func parseJSON() {
//    let blogs = dictionary(parsedJSON, "blogs") >>>= {
//        array($0, "blog") >>>= {
//            join($0.map(parseBlog))
//        }
//    }
//    println("posts: \(blogs)")
//}
//
//extension Blog : Printable {
//    var description : String {
//        return "Blog { id = \(id), name = \(name), needsPassword = \(needsPassword), url = \(url)"
//    }
//}
//
//func toURL(urlString: String) -> NSURL {
//    return NSURL(string: urlString)
//}
//
//
//func asDict(x: AnyObject) -> [String:AnyObject]? {
//    return x as? [String:AnyObject]
//}
//
//
//func join<A>(elements: [A?]) -> [A]? {
//    var result : [A] = []
//    for element in elements {
//        if let x = element {
//            result += [x]
//        } else {
//            return nil
//        }
//    }
//    return result
//}
//
//
//
//infix operator  <*> { associativity left precedence 150 }
//func <*><A, B>(l: (A -> B)?, r: A?) -> B? {
//    println("func <*>: \(l), \(r), \(A.self), \(B.self)")
//    if let l1 = l {
//        if let r1 = r {
//            return l1(r1)
//        }
//    }
//    return nil
//}
//
//func flatten<A>(x: A??) -> A? {
//    println("func flatten: \(x)")
//    if let y = x { return y }
//    return nil
//}
//
//func array(input: [String:AnyObject], key: String) ->  [AnyObject]? {
//    let maybeAny : AnyObject? = input[key]
//    return maybeAny >>>= { $0 as? [AnyObject] }
//}
//
//func dictionary(input: [String:AnyObject], key: String) ->  [String:AnyObject]? {
//    return input[key] >>>= {
//        println("func dictionary: \($0)")
//        return $0 as? [String:AnyObject]
//    }
//}
//
//func string(input: [String:AnyObject], key: String) -> String? {
//    return input[key] >>>= { $0 as? String }
//}
//
//func number(input: [NSObject:AnyObject], key: String) -> NSNumber? {
//    return input[key] >>>= { $0 as? NSNumber }
//}
//
//func int(input: [NSObject:AnyObject], key: String) -> Int? {
//    return number(input,key).map { $0.integerValue }
//}
//
//func bool(input: [NSObject:AnyObject], key: String) -> Bool? {
//    return number(input,key).map { $0.boolValue }
//}
//
//
//func curry<A,B,R>(f: (A,B) -> R) -> A -> B -> R {
//    return { a in { b in f(a,b) } }
//}
//
//func curry<A,B,C,R>(f: (A,B,C) -> R) -> A -> B -> C -> R {
//    return { a in { b in {c in f(a,b,c) } } }
//}
//
//func curry<A,B,C,D,R>(f: (A,B,C,D) -> R) -> A -> B -> C -> D -> R {
//    return { a in { b in { c in { d in f(a,b,c,d) } } } }
//}
//
//infix operator  >>>= {}
//
//func >>>= <A,B> (optional : A?, f : A -> B?) -> B? {
//    println("func >>>=: \(optional), \(f)")
//    return flatten(optional.map(f))
//}