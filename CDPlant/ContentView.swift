//
//  ContentView.swift
//  CDPlant
//
//  Created by David Power on 14/5/21.
//

import SwiftUI
import CoreData

class CoreDataViewModel: ObservableObject {

    let containter: NSPersistentContainer
    @Published var plantEntities: [PlantEntity] = []
    
    init() {
        // Set up Core Data Container
        containter = NSPersistentContainer(name: "DataContainer")
        containter.loadPersistentStores { ( description, error ) in
            if let error = error {
                print("Error loading Core Data. \(error)")
            } else {
                print("Successfully Loaded Core Data.")
            }
        }
        
        // Retrieve Data
        fetchPlants()
    }
    
    func fetchPlants(){
        let request = NSFetchRequest<PlantEntity>(entityName: "PlantEntity")
        
        do {
            plantEntities = try containter.viewContext.fetch(request)
        } catch let error {
            print ("Error fetching. \(error)")
        }
    }
    
    func addPlant(commonName: String, plantType: String) {
        // Link to Core Data Container
        let newPlant = PlantEntity(context: containter.viewContext)
        newPlant.commonName = commonName
        newPlant.plantType = plantType
        newPlant.id = UUID()
        saveData()
    }

    func deletePlant(indexSet: IndexSet) {
        // Find the entity first
        guard let index = indexSet.first else { return }
        
        let entityToModify = plantEntities[index]
        containter.viewContext.delete(entityToModify)
        saveData()
    }
    
    func updatePlant(entity: PlantEntity, commonName: String, plantType: String, id: UUID) {
        
        let currentID = entity.id
        let currentCommonName = entity.commonName
        let currentPlantType = entity.plantType
        
        entity.commonName = currentCommonName ?? "" + "!"
        entity.id = currentID
        entity.plantType = currentPlantType
        
        saveData()

    }
    
    func saveData(){
        do {
            try containter.viewContext.save()
            fetchPlants()
            print("Core Data Saved")
        } catch let error {
            print ("Error saving Core Data. \(error)")
        }
        
    }
    
}

struct ContentView: View {
    
    @StateObject var vm = CoreDataViewModel()
    @State var commonName: String = ""
    @State var plantType: String = ""
    
    var body: some View {
        
        // MARK: Navigation View
        NavigationView{
            
            VStack(spacing: 20) {
                TextField("Common Name:", text: $commonName)
                    .font(.headline)
                    .padding(.leading)
                    .frame(height: 55)
                    .background(Color(#colorLiteral(red: 0.8374180198, green: 0.8374378085, blue: 0.8374271393, alpha: 1)))
                    .cornerRadius(10)
                    .padding(.horizontal)
                
                TextField("Plant Type:", text: $plantType)
                    .font(.headline)
                    .padding(.leading)
                    .frame(height: 55)
                    .background(Color(#colorLiteral(red: 0.8374180198, green: 0.8374378085, blue: 0.8374271393, alpha: 1)))
                    .cornerRadius(10)
                    .padding(.horizontal)
                
                Button(action: {
                    // Escape if fields are empty
                    guard !commonName.isEmpty else { return }
                    guard !plantType.isEmpty else { return }
                    
                    // Add plant to Core Data
                    vm.addPlant(commonName: commonName, plantType: plantType)
                    
                    // Reset view
                    plantType = ""
                    commonName = ""
                    
                    // Dismiss keyboard
                    UIApplication.shared.endEditing()
        
                    
                }, label: {
                    Text("Save")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(height: 55)
                        .frame(maxWidth: .infinity)
                        .background(Color(#colorLiteral(red: 0.8549019694, green: 0.250980407, blue: 0.4784313738, alpha: 1)))
                        .cornerRadius(10)
                        .padding()
                    
                })
                
                Spacer()
                
                List{
                    ForEach(vm.plantEntities) { entity in
                        NavigationLink(
                            destination: plantDetail(item: entity, commonName: entity.commonName ?? "", plantType: entity.plantType ?? "", id: entity.id!),
                            label: {
                                HStack{
                                    Text(entity.commonName ?? "")
                                    Spacer()
                                    Text(entity.plantType ?? "")
                                
                                }
                            })
                        
                    }.onDelete(perform: vm.deletePlant)
                    
                }
                .listStyle(PlainListStyle())
                
                
            }// - VStack
            .navigationTitle("Plant")
            
        } // - Navigation View
        
    }
}

struct plantDetail : View {
    let item: PlantEntity
    
    @Environment(\.presentationMode) var presentationMode
    
    @StateObject var vm = CoreDataViewModel()

    @State var commonName: String = ""
    @State var plantType: String = ""
    @State var id: UUID

    var body: some View {
        VStack {
            TextField("Common Name: ", text: $commonName)
                .font(.headline)
                .padding(.leading)
                .frame(height: 55)
                .background(Color(#colorLiteral(red: 0.8374180198, green: 0.8374378085, blue: 0.8374271393, alpha: 1)))
                .cornerRadius(10)
                .padding(.horizontal)
            
            TextField("Plant Type: ", text: $plantType)
                .font(.headline)
                .padding(.leading)
                .frame(height: 55)
                .background(Color(#colorLiteral(red: 0.8374180198, green: 0.8374378085, blue: 0.8374271393, alpha: 1)))
                .cornerRadius(10)
                .padding(.horizontal)
        }
        .padding()
        .navigationTitle("Plant Detail")
        
        Button(action: {
            vm.updatePlant(entity: item, commonName: commonName, plantType: plantType, id: item.id!)
           
            presentationMode.wrappedValue.dismiss()
        
            
        }, label: {
            Text("Save")
                .font(.headline)
                .foregroundColor(.white)
                .frame(height: 55)
                .frame(maxWidth: .infinity)
                .background(Color(#colorLiteral(red: 0.8549019694, green: 0.250980407, blue: 0.4784313738, alpha: 1)))
                .cornerRadius(10)
                .padding()
            
        })
        
        Spacer()
    }
}

extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
