//
//  SectionData.swift
//  Shave Me
//
//  Created by NoorAli on 1/17/17.
//  Copyright © 2017 NoorAli. All rights reserved.
//

class SectionData <T> {
    let title: String
    var models : [T]
    
    var numberOfItems: Int {
        return models.count
    }
    
    subscript(index: Int) -> T {
        return models[index]
    }
    
    func append(model: T) {
        self.models.append(model)
    }
    
    init(title: String, models: [T]) {
        self.title = title
        self.models  = models
    }
    
    init(title: String, model: T) {
        self.title = title
        self.models  = []
        self.append(model: model)
    }
    
    static func getModel(models: [SectionData]?, byTitle: String?) -> SectionData? {
        
        guard let models = models, let byTitle = byTitle else {
            return nil
        }
        
        for item in models {
            if item.title == byTitle {
                return item
            }
        }
        
        return nil
    }
}
