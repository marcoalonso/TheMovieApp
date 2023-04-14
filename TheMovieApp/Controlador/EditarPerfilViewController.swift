//
//  EditarPerfilViewController.swift
//  TheMovieApp
//
//  Created by Marco Alonso Rodriguez on 08/04/23.
//

import UIKit
import CoreData
import PhotosUI


class EditarPerfilViewController: UIViewController {

    
    @IBOutlet weak var profileUser: UIImageView!
    @IBOutlet weak var nameOfUser: UITextField!
    @IBOutlet weak var genresUser: UITextView!
    
    
    var accessOfUser: Bool = false
    
    var dataUser : Usuario?
    let contexto = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()

    requestUserPermission()
       setupUI()
    }
    
    private func setupUI(){
        let gestura = UITapGestureRecognizer(target: self, action: #selector(clickImagen))
        gestura.numberOfTapsRequired = 1
        gestura.numberOfTouchesRequired = 1
        profileUser.addGestureRecognizer(gestura)
        profileUser.isUserInteractionEnabled = true
        
        if let dataPhoto = dataUser?.foto {
            profileUser.image = UIImage(data: dataPhoto)
            nameOfUser.text = dataUser?.nombre
            genresUser.text = dataUser?.generos
        }
        
        profileUser.layer.cornerRadius = 45
        profileUser.layer.masksToBounds = true
        
    }
    
    private func requestUserPermission(){
        // Request permission to access photo library
        PHPhotoLibrary.requestAuthorization(for: .readWrite) { [unowned self] (status) in
            DispatchQueue.main.async { [unowned self] in
                showUI(for: status)
            }
        }
    }
    
    func showUI(for status: PHAuthorizationStatus) {
        
        switch status {
        case .authorized:
//            showFullAccessUI()
            accessOfUser = true

        case .limited:
//            showLimittedAccessUI()
            print("Acceso limitado")
            accessOfUser = true

        case .restricted:
//            showRestrictedAccessUI()
            print("Restingido")

        case .denied:
//            showAccessDeniedUI()
            accessOfUser = false

        case .notDetermined:
            print("No determinado")

        @unknown default:
            break
        }
    }
    
    @objc func clickImagen(){
        if accessOfUser {
            let vc = UIImagePickerController()
            vc.delegate = self
            vc.allowsEditing = true
            
            let alerta = UIAlertController(title: "Seleccionar Foto", message: "Elige desde donde quieres escoger la foto", preferredStyle: .alert)
            let camara = UIAlertAction(title: "Camara", style: .cancel) { _ in
                //Do something
                vc.sourceType = .camera
                self.present(vc, animated: true)
            }
            let photos = UIAlertAction(title: "Fotos", style: .default) { _ in
                //Do something
                vc.sourceType = .photoLibrary
                self.present(vc, animated: true)
            }
            let cancelar = UIAlertAction(title: "Cancelar", style: .default)
            alerta.addAction(photos)
            alerta.addAction(camara)
            alerta.addAction(cancelar)
            present(alerta, animated: true)
            
        } else {
            let alerta = UIAlertController(title: "Atención", message: "Para poder seleccionar una foto necesitamos tu permiso para acceder a la galeria de fotos", preferredStyle: .alert)
            let aceptar = UIAlertAction(title: "Otogar Permiso", style: .default) { _ in
                self.gotoAppPrivacySettings()
            }
            
            let despues = UIAlertAction(title: "Omitir", style: .destructive) { _ in
                //Do something
            }
            
            alerta.addAction(aceptar)
            alerta.addAction(despues)
            
            present(alerta, animated: true)
        }
        
    }
    
    private func gotoAppPrivacySettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString),
            UIApplication.shared.canOpenURL(url) else {
                assertionFailure("Not able to open App privacy settings")
                return
        }

        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func mostrarAlerta(titulo: String, mensaje: String) {
        let alerta = UIAlertController(title: titulo, message: mensaje, preferredStyle: .alert)
        let accionAceptar = UIAlertAction(title: "OK", style: .default) { _ in
            //Do something
        }
        alerta.addAction(accionAceptar)
        present(alerta, animated: true)
    }
    
    // MARK:  Actions
    
    @IBAction func cancelarButton(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
    
    @IBAction func saveButton(_ sender: UIButton) {
        if nameOfUser.text != "" {
            
            if dataUser == nil {
                let newUser = Usuario(context: contexto)
                newUser.nombre = nameOfUser.text
                newUser.generos = genresUser.text
                newUser.foto = self.profileUser.image?.pngData()
            } else {
                dataUser?.nombre = nameOfUser.text
                dataUser?.generos = genresUser.text
                dataUser?.foto = self.profileUser.image?.pngData()
            }
            
            do {
                try contexto.save()
                print("Guardado en core data!")
                self.dismiss(animated: true)
                
            } catch {
                print("Debug: error al guardar contacto \(error.localizedDescription)")
            }
            
        } else {
            mostrarAlerta(titulo: "Atención", mensaje: "Escribe tu nombre para guardar tus datos y si quieres puedes cambiar tu foto de perfil tocando la imagen.")
        }
        
    }
    
}

extension EditarPerfilViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let imagenSeleccionada = info[UIImagePickerController.InfoKey(rawValue: "UIImagePickerControllerEditedImage")] as? UIImage {
            profileUser.image = imagenSeleccionada
        }
        picker.dismiss(animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}
