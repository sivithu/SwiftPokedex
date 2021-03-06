//
//  FavorisViewController.swift
//  pokedexAPI
//
//  Created by Vithursan Sivakumaran on 10/02/2019.
//  Copyright © 2019 Tvn. All rights reserved.
//

import UIKit
import AVFoundation

class FavorisViewController: UIViewController {
    var pokemons: [Pokemon]!
    var player: AVAudioPlayer = AVAudioPlayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if(GlobalVar.check) {
            alertInfo()
        }
        setBackground()
        setupBarButton()
        collectionViewSetup()
        doubleTap()
        longPressure()
        helpButton()
    }
    
    func setBackground(){
        let backgroundImage = UIImageView(frame: UIScreen.main.bounds)
        backgroundImage.image = UIImage(named: "background")
        backgroundImage.contentMode =  UIView.ContentMode.scaleAspectFill
        self.view.insertSubview(backgroundImage, at: 0)
    }
    
    func setupBarButton() {
        self.navigationItem.title = "Favoris"
    }
    
    func collectionViewSetup() {
        self.FavCollectionView.delegate = self
        self.FavCollectionView.dataSource = self
        self.FavCollectionView.register(UINib(nibName: "FavCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: FavorisViewController.pokemonCellId)
    }
    
    func longPressure() {
        let lpgr = UILongPressGestureRecognizer(target: self, action: #selector(self.handleLongPress(gesture:)))
        lpgr.minimumPressDuration = 1.0
        FavCollectionView.addGestureRecognizer(lpgr)
    }
    
    func doubleTap() {
        let tgr = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(gesture:)))
        tgr.numberOfTouchesRequired = 2
        FavCollectionView.addGestureRecognizer(tgr)
    }
    
    func alertInfo() {
        let alert = UIAlertController(title: "Comment ça marche", message: "Modifier : Appuyez avec deux doigts pour modifier le nom d'un pokémon\n\nSupprimer : Rester appuyez au moins une seconde sur un pokémon afin de le supprimer", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "J'ai compris", style: .default, handler: nil))
        self.present(alert, animated: true)
        GlobalVar.check = false
    }
    
    @objc func alertHelper() {
        alertInfo()
    }
    
    class func newInstance(pokemon: [Pokemon]) ->
        FavorisViewController {
        let pdvc = FavorisViewController()
        pdvc.pokemons = pokemon
        return pdvc
    }
    
    @objc func handleTap(gesture: UITapGestureRecognizer!) {
        
        let p = gesture.location(in: self.FavCollectionView)
        
        if let indexPath = self.FavCollectionView.indexPathForItem(at: p) {
            let alert = UIAlertController(title: "Modifier \(self.pokemons[indexPath.row].name) ?", message: "Voulez-vous modifier le nom de \(self.pokemons[indexPath.row].name) de vos favoris ?", preferredStyle: .alert)
            
            alert.addTextField(configurationHandler: { (textfield) in
                textfield.placeholder = "Change name"
            })
            let ok = UIAlertAction(title: "Oui", style: .default, handler: { (action) -> Void in
                let addText = alert.textFields![0] as UITextField
                if (addText.text != "") {
                    //self.pokemons[indexPath.row].name = addText.text!
                    PokemonServices.default.update(pokemon: Pokemon(id: self.pokemons[indexPath.row].id, name: addText.text!, sprite: self.pokemons[indexPath.row].sprite, types: self.pokemons[indexPath.row].types))
                }
                self.pokemons[indexPath.row].name = addText.text!
                self.updatePokemonSound()
                self.FavCollectionView.reloadData()
            })
            let cancel = UIAlertAction(title: "Non", style: .default, handler: { (action) -> Void in
                
            })
            
            alert.addAction(ok)
            alert.addAction(cancel)
            self.present(alert, animated: true)
        } else {
            print("no index path")
        }
    }

    @IBOutlet var FavCollectionView: UICollectionView!
    
    @objc func handleLongPress(gesture: UILongPressGestureRecognizer!) {
        let p = gesture.location(in: self.FavCollectionView)
        
        if let indexPath = self.FavCollectionView.indexPathForItem(at: p) {
            //PokemonServices.default.delete(id: self.pokemons[indexPath.row].id)
            let alert = UIAlertController(title: "Supprimer \(self.pokemons[indexPath.row].name) ?", message: "Voulez-vous supprimer \(self.pokemons[indexPath.row].name) de vos favoris ?", preferredStyle: .alert)
            let ok = UIAlertAction(title: "Oui", style: .default, handler: { (action) -> Void in
                PokemonServices.default.delete(id: self.pokemons[indexPath.row].id)
                self.pokemons.remove(at: indexPath.row)
                self.FavCollectionView.reloadData()
            })
            let cancel = UIAlertAction(title: "Non", style: .default, handler: { (action) -> Void in
            })
            alert.addAction(ok)
            alert.addAction(cancel)
            self.present(alert, animated: true)
        } else {
            print("no index path")
        }
    }
    
    func helpButton() {
        let button = UIBarButtonItem(title: "ⓘ", style: .plain, target: self, action: #selector(alertHelper))
        let foregroundColor = UIColor(red: 0/255, green: 122/255, blue: 255/255, alpha: 1)
        button.setTitleTextAttributes([
            NSAttributedString.Key.font: UIFont(name: "MarkerFelt-Thin", size: 24.0)!,
            NSAttributedString.Key.foregroundColor: foregroundColor], for: .normal)
        navigationItem.rightBarButtonItem = button
    }
    
    func selectSound() {
        do{
            let audioPath = Bundle.main.path(forResource: "selectsound", ofType: "mp3")
            try player = AVAudioPlayer(contentsOf: NSURL(fileURLWithPath: audioPath!) as URL)
        }
        catch {
            
        }
        player.volume = 0.7
        player.play()
    }
    
    func updatePokemonSound() {
        do{
            let audioPath = Bundle.main.path(forResource: "pokecenter", ofType: "mp3")
            try player = AVAudioPlayer(contentsOf: NSURL(fileURLWithPath: audioPath!) as URL)
        }
        catch {
            player.stop()
        }
        player.volume = 0.7
        player.play()
    }
    
}



extension FavorisViewController: UICollectionViewDelegate {
    
}

extension FavorisViewController: UICollectionViewDataSource {
    public static let pokemonCellId = "POKEMONFAV_CELL_ID"
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.pokemons.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FavorisViewController.pokemonCellId, for: indexPath) as! FavCollectionViewCell
        let imageURL = URL(string: self.pokemons[indexPath.row].sprite)
        let imageData = try! Data(contentsOf: imageURL!)
        cell.image.image = UIImage(data: imageData)
        cell.name.text = "\(self.pokemons[indexPath.row].name)"
        cell.id.text = "#\(self.pokemons[indexPath.row].id)"
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let idChoosen = self.pokemons[indexPath.row].id
        let nameChoose = self.pokemons[indexPath.row].name
        let imageChoosen = self.pokemons[indexPath.row].sprite
        let typesChoosen = self.pokemons[indexPath.row].types
        selectSound()
        let next = PokeDetailViewController.newInstance(pokemon: Pokemon(id: idChoosen, name: nameChoose, sprite: imageChoosen, types: typesChoosen), evolution: 0)
        self.navigationController?.pushViewController(next, animated: true)
        
    }
}

