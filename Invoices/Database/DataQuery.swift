//
//  DataQuery.swift
//  Invoices
//
//  Created by Mac Mini on 11/11/16.
//  Copyright © 2016 Armonia. All rights reserved.
//

import Foundation


class DataQuery : NSObject {

    public var context : DataServer

    override init() {
        self.context = DataServer()
        self.context.connect()
    }
    
    init(in context: DataServer) {
        self.context = context // use parent context
    }
    
}


// End
