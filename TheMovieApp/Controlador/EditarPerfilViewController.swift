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
    @IBOutlet weak var genresUser: UITextField!
    
    var accessOfUser: Bool = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

    requestUserPermission()
       setupUI()
    }
    
    private func setupUI(){
        //agregar una gestura a la imagen
        let gestura = UITapGestureRecognizer(target: self, action: #selector(clickImagen))
        gestura.numberOfTapsRequired = 1
        gestura.numberOfTouchesRequired = 1
        profileUser.addGestureRecognizer(gestura)
        profileUser.isUserInteractionEnabled = true
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
            
            let alerta = UIAlertController(title: "Seleccionar Foto", message: "Elige desde donde quieres escoger la foto", preferredStyle: .actionSheet)
            let camara = UIAlertAction(title: "Camara", style: .default) { _ in
                //Do something
                vc.sourceType = .camera
                self.present(vc, animated: true)
            }
            let photos = UIAlertAction(title: "Fotos", style: .default) { _ in
                //Do something
                vc.sourceType = .photoLibrary
                self.present(vc, animated: true)
            }
            let cancelar = UIAlertAction(title: "Cancelar", style: .destructive)
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
    
    // MARK:  Action
    @IBAction func saveButton(_ sender: UIBarButtonItem) {
        dismiss(animated: true)
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
