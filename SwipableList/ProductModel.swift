import Foundation

struct Product: Hashable {
    let id: UUID
    let name: String
    let price: Double
    let description: String
    
    init(name: String, 
         price: Double,
         description: String) {
        self.id = UUID()
        self.name = name
        self.price = price
        self.description = description
    }
}
