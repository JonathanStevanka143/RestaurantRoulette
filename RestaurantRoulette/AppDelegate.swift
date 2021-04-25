//
//  AppDelegate.swift
//  RestaurantRoulette
//
//  Created by Mac User on 2021-01-13.
//

import UIKit
import CoreData

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        
        //MARK: CREATE DEFAULT FILTER OPTIONS
        self.createDefaultFilterOptions()
        
        //MARK: CREATE DEFAULT CATEGORY OPTIONS
        self.createDefaultCategories()
                
        return true
    }
    
    func createDefaultFilterOptions(){
        
        //create a model context
        let moc = persistentContainer.viewContext
        
        //create a fetched results controller
        var fetchedResultsController: NSFetchedResultsController<FilterSettings>?
        
        //prepare the request for the local data
        let request = NSFetchRequest<FilterSettings>(entityName: "FilterSettings")
        
        //set a sort descriptor for how we retreive the keys
        request.sortDescriptors = [NSSortDescriptor(key: "distance", ascending: false)]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest:
                                                                            request, managedObjectContext: moc, sectionNameKeyPath: nil, cacheName: nil)
        do {
            try fetchedResultsController?.performFetch()
            
            if fetchedResultsController?.fetchedObjects?.isEmpty == true {
                
                let filterSettings = FilterSettings(context: moc)
                filterSettings.isBelowPriceRange = true
                filterSettings.priceRangeLevel = 4
                filterSettings.distance = 15
                filterSettings.isDistanceInKM = true
                
                
                //save the currentContext so that our changes are persisteddx
                self.saveContext()
            }else {
                //do nothing as we dont need to set up the default keys
            }
        }catch {
            print("fetch request failed")
        }
        
    }
    
    
    
    
    func createDefaultCategories(){
        
        //create a model context
        let moc = persistentContainer.viewContext
        
        //create a fetched results controller
        var fetchedResultsController: NSFetchedResultsController<Categories>?
        
        //prepare the request for the local data
        let request = NSFetchRequest<Categories>(entityName: "Categories")
        
        //set a sort descriptor for how we retreive the keys
        request.sortDescriptors = [NSSortDescriptor(key: "categoryAlias", ascending: true)]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest:
                                                                            request, managedObjectContext: moc, sectionNameKeyPath: nil, cacheName: nil)
        do {
            try fetchedResultsController?.performFetch()
            
            if fetchedResultsController?.fetchedObjects?.isEmpty == true {
                
                //american
                //need to figure out what to do for the 'american' one
                
                //australian
                let australianCategory = Categories(context: moc)
                australianCategory.categoryTitle = "Australian"
                australianCategory.categoryAlias = "australian"
                australianCategory.isCategoryChecked = true
                
                //brazilian
                let brazilianCategory = Categories(context: moc)
                brazilianCategory.categoryTitle = "Brazilian"
                brazilianCategory.categoryAlias = "brazilian"
                brazilianCategory.isCategoryChecked = true
                
                //austrian
                let austrianCategory = Categories(context: moc)
                austrianCategory.categoryTitle = "Austrian"
                austrianCategory.categoryAlias = "austrian"
                austrianCategory.isCategoryChecked = true
                
                //bbq
                let bbqCategory = Categories(context: moc)
                bbqCategory.categoryTitle = "Barbeque"
                bbqCategory.categoryAlias = "bbq"
                bbqCategory.isCategoryChecked = true
                
                //breakfast_brunch
                let breakfast_brunchCategory = Categories(context: moc)
                breakfast_brunchCategory.categoryTitle = "Breakfast & Brunch"
                breakfast_brunchCategory.categoryAlias = "breakfast_brunch"
                breakfast_brunchCategory.isCategoryChecked = true
                
                //british
                let britishCategory = Categories(context: moc)
                britishCategory.categoryTitle = "British"
                britishCategory.categoryAlias = "british"
                britishCategory.isCategoryChecked = true
                
                //bulgarian
                let bulgarianCategory = Categories(context: moc)
                bulgarianCategory.categoryTitle = "Bulgarian"
                bulgarianCategory.categoryAlias = "bulgarian"
                bulgarianCategory.isCategoryChecked = true
                
                //buffets
                let buffetsCategory = Categories(context: moc)
                buffetsCategory.categoryTitle = "Buffets"
                buffetsCategory.categoryAlias = "buffets"
                buffetsCategory.isCategoryChecked = true
                
                //burgers
                let burgersCategory = Categories(context: moc)
                burgersCategory.categoryTitle = "Burgers"
                burgersCategory.categoryAlias = "burgers"
                burgersCategory.isCategoryChecked = true
                
                //burmese
                let burmeseCategory = Categories(context: moc)
                burmeseCategory.categoryTitle = "Burmese"
                burmeseCategory.categoryAlias = "burmese"
                burmeseCategory.isCategoryChecked = true
                
                //cajun
                let cajunCategory = Categories(context: moc)
                cajunCategory.categoryTitle = "Cajun/Creole"
                cajunCategory.categoryAlias = "cajun"
                cajunCategory.isCategoryChecked = true
                
                //chinese
                let chineseCategory = Categories(context: moc)
                chineseCategory.categoryTitle = "Chinese"
                chineseCategory.categoryAlias = "chinese"
                chineseCategory.isCategoryChecked = true
                
                //cambodian
                let cambodianCategory = Categories(context: moc)
                cambodianCategory.categoryTitle = "Cambodian"
                cambodianCategory.categoryAlias = "cambodian"
                cambodianCategory.isCategoryChecked = true
                
                //catalan
                let catalanCategory = Categories(context: moc)
                catalanCategory.categoryTitle = "Catalan"
                catalanCategory.categoryAlias = "catalan"
                catalanCategory.isCategoryChecked = true
                
                //comfort Food
                let comfortfoodCategory = Categories(context: moc)
                comfortfoodCategory.categoryTitle = "Comfort Food"
                comfortfoodCategory.categoryAlias = "comfortfood"
                comfortfoodCategory.isCategoryChecked = true
                
                //cuban
                let cubanCategory = Categories(context: moc)
                cubanCategory.categoryTitle = "Cuban"
                cubanCategory.categoryAlias = "cuban"
                cubanCategory.isCategoryChecked = true
                
                //czech
                let czechCategory = Categories(context: moc)
                czechCategory.categoryTitle = "Czech"
                czechCategory.categoryAlias = "czech"
                czechCategory.isCategoryChecked = true
                
                //diners
                let dinersCategory = Categories(context: moc)
                dinersCategory.categoryTitle = "Diners"
                dinersCategory.categoryAlias = "diners"
                dinersCategory.isCategoryChecked = true
                
                //ethiopian
                let ethiopianCategory = Categories(context: moc)
                ethiopianCategory.categoryTitle = "Ethiopian"
                ethiopianCategory.categoryAlias = "ethiopian"
                ethiopianCategory.isCategoryChecked = true
                
                //filipino
                let filipinoCategory = Categories(context: moc)
                filipinoCategory.categoryTitle = "Filipino"
                filipinoCategory.categoryAlias = "filipino"
                filipinoCategory.isCategoryChecked = true
                
                //fishnchips
                let fishnchipsCategory = Categories(context: moc)
                fishnchipsCategory.categoryTitle = "Fish & Chips"
                fishnchipsCategory.categoryAlias = "fishnchips"
                fishnchipsCategory.isCategoryChecked = true
                
                //french
                let frenchCategory = Categories(context: moc)
                frenchCategory.categoryTitle = "French"
                frenchCategory.categoryAlias = "french"
                frenchCategory.isCategoryChecked = true
                
                //gastropubs
                let gastropubsCategory = Categories(context: moc)
                gastropubsCategory.categoryTitle = "Gastropubs"
                gastropubsCategory.categoryAlias = "gastropubs"
                gastropubsCategory.isCategoryChecked = true
                
                //georgian
                let georgianCategory = Categories(context: moc)
                georgianCategory.categoryTitle = "Georgian"
                georgianCategory.categoryAlias = "georgian"
                georgianCategory.isCategoryChecked = true
                
                //german
                let germanCategory = Categories(context: moc)
                germanCategory.categoryTitle = "German"
                germanCategory.categoryAlias = "german"
                germanCategory.isCategoryChecked = true
                
                //greek
                let greekCategory = Categories(context: moc)
                greekCategory.categoryTitle = "Greek"
                greekCategory.categoryAlias = "greek"
                greekCategory.isCategoryChecked = true
                
                //guamanian
                let guamanianCategory = Categories(context: moc)
                guamanianCategory.categoryTitle = "Guamanian"
                guamanianCategory.categoryAlias = "guamanian"
                guamanianCategory.isCategoryChecked = true
                
                //halal
                let halalCategory = Categories(context: moc)
                halalCategory.categoryTitle = "Halal"
                halalCategory.categoryAlias = "halal"
                halalCategory.isCategoryChecked = true
                
                //hawaiian
                let hawaiianCategory = Categories(context: moc)
                hawaiianCategory.categoryTitle = "Hawaiian"
                hawaiianCategory.categoryAlias = "hawaiian"
                hawaiianCategory.isCategoryChecked = true
                
                //himalayan
                let himalayanCategory = Categories(context: moc)
                himalayanCategory.categoryTitle = "Himalayan/Nepalese"
                himalayanCategory.categoryAlias = "himalayan"
                himalayanCategory.isCategoryChecked = true
                
                //honduran
                let honduranCategory = Categories(context: moc)
                honduranCategory.categoryTitle = "Honduran"
                honduranCategory.categoryAlias = "honduran"
                honduranCategory.isCategoryChecked = true
                
                //hungarian
                let hungarianCategory = Categories(context: moc)
                hungarianCategory.categoryTitle = "Hungarian"
                hungarianCategory.categoryAlias = "hungarian"
                hungarianCategory.isCategoryChecked = true
                
                //iberian
                let iberianCategory = Categories(context: moc)
                iberianCategory.categoryTitle = "Iberian"
                iberianCategory.categoryAlias = "iberian"
                iberianCategory.isCategoryChecked = true
                
                //italian
                let italianCategory = Categories(context: moc)
                italianCategory.categoryTitle = "Italian"
                italianCategory.categoryAlias = "italian"
                italianCategory.isCategoryChecked = true
                
                //indian
                let indianCategory = Categories(context: moc)
                indianCategory.categoryTitle = "Indian"
                indianCategory.categoryAlias = "indpak"
                indianCategory.isCategoryChecked = true
                
                //indonesian
                let indonesianCategory = Categories(context: moc)
                indonesianCategory.categoryTitle = "Indonesian"
                indonesianCategory.categoryAlias = "indonesian"
                indonesianCategory.isCategoryChecked = true
                
                //irish
                let irishCategory = Categories(context: moc)
                irishCategory.categoryTitle = "Irish"
                irishCategory.categoryAlias = "irish"
                irishCategory.isCategoryChecked = true
                
                //japanese
                let japaneseCategory = Categories(context: moc)
                japaneseCategory.categoryTitle = "Japanese"
                japaneseCategory.categoryAlias = "japanese"
                japaneseCategory.isCategoryChecked = true
                
                //korean
                let koreanCategory = Categories(context: moc)
                koreanCategory.categoryTitle = "Korean"
                koreanCategory.categoryAlias = "korean"
                koreanCategory.isCategoryChecked = true
                
                //kosher
                let kosherCategory = Categories(context: moc)
                kosherCategory.categoryTitle = "Kosher"
                kosherCategory.categoryAlias = "kosher"
                kosherCategory.isCategoryChecked = true
                
                //laotian
                let laotianCategory = Categories(context: moc)
                laotianCategory.categoryTitle = "Laotian"
                laotianCategory.categoryAlias = "laotian"
                laotianCategory.isCategoryChecked = true
                
                //latin
                let latinCategory = Categories(context: moc)
                latinCategory.categoryTitle = "Latin American"
                latinCategory.categoryAlias = "latin"
                latinCategory.isCategoryChecked = true
                
                //raw_food
                let raw_foodCategory = Categories(context: moc)
                raw_foodCategory.categoryTitle = "Live/Raw Food"
                raw_foodCategory.categoryAlias = "raw_food"
                raw_foodCategory.isCategoryChecked = true
                
                //malaysian
                let malaysianCategory = Categories(context: moc)
                malaysianCategory.categoryTitle = "Malaysian"
                malaysianCategory.categoryAlias = "malaysian"
                malaysianCategory.isCategoryChecked = true
                
                //mediterranean
                let mediterraneanCategory = Categories(context: moc)
                mediterraneanCategory.categoryTitle = "Mediterranean"
                mediterraneanCategory.categoryAlias = "mediterranean"
                mediterraneanCategory.isCategoryChecked = true
                
                //mexican
                let mexicanCategory = Categories(context: moc)
                mexicanCategory.categoryTitle = "Mexican"
                mexicanCategory.categoryAlias = "mexican"
                mexicanCategory.isCategoryChecked = true
                
                //mideastern
                let mideasternCategory = Categories(context: moc)
                mideasternCategory.categoryTitle = "Middle Eastern"
                mideasternCategory.categoryAlias = "mideastern"
                mideasternCategory.isCategoryChecked = true
                
                //modern_european
                let modern_europeanCategory = Categories(context: moc)
                modern_europeanCategory.categoryTitle = "Modern European"
                modern_europeanCategory.categoryAlias = "modern_european"
                modern_europeanCategory.isCategoryChecked = true
                
                //mongolian
                let mongolianCategory = Categories(context: moc)
                mongolianCategory.categoryTitle = "Mongolian"
                mongolianCategory.categoryAlias = "mongolian"
                mongolianCategory.isCategoryChecked = true
                
                //moroccan
                let moroccanCategory = Categories(context: moc)
                moroccanCategory.categoryTitle = "Moroccan"
                moroccanCategory.categoryAlias = "moroccan"
                moroccanCategory.isCategoryChecked = true
                
                //nicaraguan
                let nicaraguanCategory = Categories(context: moc)
                nicaraguanCategory.categoryTitle = "Nicaraguan"
                nicaraguanCategory.categoryAlias = "nicaraguan"
                nicaraguanCategory.isCategoryChecked = true
                
                //pakistani
                let pakistaniCategory = Categories(context: moc)
                pakistaniCategory.categoryTitle = "Pakistani"
                pakistaniCategory.categoryAlias = "pakistani"
                pakistaniCategory.isCategoryChecked = true
                
                //persian
                let persianCategory = Categories(context: moc)
                persianCategory.categoryTitle = "Persian/Iranian"
                persianCategory.categoryAlias = "persian"
                persianCategory.isCategoryChecked = true
                
                //peruvian
                let peruvianCategory = Categories(context: moc)
                peruvianCategory.categoryTitle = "Peruvian"
                peruvianCategory.categoryAlias = "peruvian"
                peruvianCategory.isCategoryChecked = true
                
                //pizza
                let pizzaCategory = Categories(context: moc)
                pizzaCategory.categoryTitle = "Pizza"
                pizzaCategory.categoryAlias = "pizza"
                pizzaCategory.isCategoryChecked = true
                
                //polish
                let polishCategory = Categories(context: moc)
                polishCategory.categoryTitle = "Polish"
                polishCategory.categoryAlias = "polish"
                polishCategory.isCategoryChecked = true
                
                //polynesian
                let polynesianCategory = Categories(context: moc)
                polynesianCategory.categoryTitle = "Polynesian"
                polynesianCategory.categoryAlias = "polynesian"
                polynesianCategory.isCategoryChecked = true
                
                //portuguese
                let portugueseCategory = Categories(context: moc)
                portugueseCategory.categoryTitle = "Portuguese"
                portugueseCategory.categoryAlias = "portuguese"
                portugueseCategory.isCategoryChecked = true
                
                //russian
                let russianCategory = Categories(context: moc)
                russianCategory.categoryTitle = "Russian"
                russianCategory.categoryAlias = "russian"
                russianCategory.isCategoryChecked = true
                
                //sandwiches
                let sandwichesCategory = Categories(context: moc)
                sandwichesCategory.categoryTitle = "Sandwiches"
                sandwichesCategory.categoryAlias = "sandwiches"
                sandwichesCategory.isCategoryChecked = true
                
                //scandinavian
                let scandinavianCategory = Categories(context: moc)
                scandinavianCategory.categoryTitle = "Scandinavian"
                scandinavianCategory.categoryAlias = "scandinavian"
                scandinavianCategory.isCategoryChecked = true
                
                //scottish
                let scottishCategory = Categories(context: moc)
                scottishCategory.categoryTitle = "Scottish"
                scottishCategory.categoryAlias = "scottish"
                scottishCategory.isCategoryChecked = true
                
                //seafood
                let seafoodCategory = Categories(context: moc)
                seafoodCategory.categoryTitle = "Seafood"
                seafoodCategory.categoryAlias = "seafood"
                seafoodCategory.isCategoryChecked = true
                
                //singaporean
                let singaporeanCategory = Categories(context: moc)
                singaporeanCategory.categoryTitle = "Singaporean"
                singaporeanCategory.categoryAlias = "singaporean"
                singaporeanCategory.isCategoryChecked = true
                
                //slovakian
                let slovakianCategory = Categories(context: moc)
                slovakianCategory.categoryTitle = "Slovakian"
                slovakianCategory.categoryAlias = "slovakian"
                slovakianCategory.isCategoryChecked = true
                
                //somali
                let somaliCategory = Categories(context: moc)
                somaliCategory.categoryTitle = "Somali"
                somaliCategory.categoryAlias = "somali"
                somaliCategory.isCategoryChecked = true
                
                //soulfood
                let soulfoodCategory = Categories(context: moc)
                soulfoodCategory.categoryTitle = "Soul Food"
                soulfoodCategory.categoryAlias = "soulfood"
                soulfoodCategory.isCategoryChecked = true
                
                //soup
                let soupCategory = Categories(context: moc)
                soupCategory.categoryTitle = "Soup"
                soupCategory.categoryAlias = "soup"
                soupCategory.isCategoryChecked = true
                
                //southern
                let southernCategory = Categories(context: moc)
                southernCategory.categoryTitle = "Southern"
                southernCategory.categoryAlias = "southern"
                southernCategory.isCategoryChecked = true
                
                //spanish
                let spanishCategory = Categories(context: moc)
                spanishCategory.categoryTitle = "Spanish"
                spanishCategory.categoryAlias = "spanish"
                spanishCategory.isCategoryChecked = true
                
                //srilankan
                let srilankanCategory = Categories(context: moc)
                srilankanCategory.categoryTitle = "Sri Lankan"
                srilankanCategory.categoryAlias = "srilankan"
                srilankanCategory.isCategoryChecked = true
                
                //steak
                let steakCategory = Categories(context: moc)
                steakCategory.categoryTitle = "Steakhouses"
                steakCategory.categoryAlias = "steak"
                steakCategory.isCategoryChecked = true
                
                //sushi
                let sushiCategory = Categories(context: moc)
                sushiCategory.categoryTitle = "Sushi Bars"
                sushiCategory.categoryAlias = "sushi"
                sushiCategory.isCategoryChecked = true
                
                //syrian
                let syrianCategory = Categories(context: moc)
                syrianCategory.categoryTitle = "Syrian"
                syrianCategory.categoryAlias = "syrian"
                syrianCategory.isCategoryChecked = true
                
                //taiwanese
                let taiwaneseCategory = Categories(context: moc)
                taiwaneseCategory.categoryTitle = "Taiwanese"
                taiwaneseCategory.categoryAlias = "taiwanese"
                taiwaneseCategory.isCategoryChecked = true
                
                //tapas
                let tapasCategory = Categories(context: moc)
                tapasCategory.categoryTitle = "Tapas Bars"
                tapasCategory.categoryAlias = "tapas"
                tapasCategory.isCategoryChecked = true
                
                //tex-mex
                let tex_mexCategory = Categories(context: moc)
                tex_mexCategory.categoryTitle = "Tex-Mex"
                tex_mexCategory.categoryAlias = "tex-mex"
                tex_mexCategory.isCategoryChecked = true
                
                //thai
                let thaiCategory = Categories(context: moc)
                thaiCategory.categoryTitle = "Thai"
                thaiCategory.categoryAlias = "thai"
                thaiCategory.isCategoryChecked = true
                
                //turkish
                let turkishCategory = Categories(context: moc)
                turkishCategory.categoryTitle = "Turkish"
                turkishCategory.categoryAlias = "turkish"
                turkishCategory.isCategoryChecked = true
                
                //ukrainian
                let ukrainianCategory = Categories(context: moc)
                ukrainianCategory.categoryTitle = "Ukrainian"
                ukrainianCategory.categoryAlias = "ukrainian"
                ukrainianCategory.isCategoryChecked = true
                
                //uzbek
                let uzbekCategory = Categories(context: moc)
                uzbekCategory.categoryTitle = "Uzbek"
                uzbekCategory.categoryAlias = "uzbek"
                uzbekCategory.isCategoryChecked = true
                
                //vegan
                let veganCategory = Categories(context: moc)
                veganCategory.categoryTitle = "Vegan"
                veganCategory.categoryAlias = "vegan"
                veganCategory.isCategoryChecked = true
                
                //vegetarian
                let vegetarianCategory = Categories(context: moc)
                vegetarianCategory.categoryTitle = "Vegetarian"
                vegetarianCategory.categoryAlias = "vegetarian"
                vegetarianCategory.isCategoryChecked = true
                
                //vietnamese
                let vietnameseCategory = Categories(context: moc)
                vietnameseCategory.categoryTitle = "Vietnamese"
                vietnameseCategory.categoryAlias = "vietnamese"
                vietnameseCategory.isCategoryChecked = true
                
                //save the currentContext so that our changes are persisteddx
                self.saveContext()
            }else {
                //do nothing as we dont need to set up the default keys
                
            }
        }catch {
            print("fetch request failed")
        }
        
    }
    
    

    // MARK: UISceneSession Lifecycle
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

    // MARK: - Core Data stack
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "RestaurantRoulette")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
//                Er("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

}

