//
//  MoreViewController.swift
//  TheMovieApp
//
//  Created by Marco Alonso Rodriguez on 29/05/23.
//

import UIKit
import MessageUI
import SafariServices

struct Action {
    let name: String
    let action: String
    let icon: String
}

class MoreViewController: UIViewController {
    
    var actions: [Action] = [
    Action(name: "Hacer una sugerencia", action: "sugerencia", icon: "slider.vertical.3"),
    Action(name: "Califica la aplicación", action: "califica", icon: "star.leadinghalf.filled"),
    Action(name: "Crear un recordatorio", action: "recordatorio", icon: "bell.badge"),
    Action(name: "Conocer más sobre nosotros", action: "seguir", icon: "hand.thumbsup"),
//    Action(name: "Ir a configuracion", action: "configuracion", icon: "slider.vertical.3"),
    Action(name: "Desarrollador", action: "developer", icon: "person")
    ]
    
    @IBOutlet weak var darkModeSwitch: UISwitch!
    @IBOutlet weak var compartirButton: UIButton!
    @IBOutlet weak var moreActionsTableview: UITableView!
    
    
    

    override func viewDidLoad() {
        super.viewDidLoad()

        moreActionsTableview.delegate = self
        moreActionsTableview.dataSource = self
        
        let isDarkModeEnabled = UserDefaults.standard.bool(forKey: "darkModeEnabled")
        darkModeSwitch.isOn = isDarkModeEnabled
        darkModeSwitch.addTarget(self, action: #selector(switchValueChanged(_:)), for: .valueChanged)
    }
    
    @objc func switchValueChanged(_ sender: UISwitch) {
        
        if sender.isOn {
            print("Debug: true darkMode")

            UserDefaults.standard.set(sender.isOn, forKey: "darkModeEnabled")
        } else {
            print("Debug: false darkMode")
            UserDefaults.standard.set(sender.isOn, forKey: "darkModeEnabled")
        }
        
        if let appDelegate = UIApplication.shared.windows.first {
            if sender.isOn {
                appDelegate.overrideUserInterfaceStyle = .dark
            } else {
                appDelegate.overrideUserInterfaceStyle = .light
            }
        }
        
    }
    
    @IBAction func backButton(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    @IBAction func shareButton(_ sender: UIButton) {
        compartir()
    }
    
    
}

// MARK: - Enviar Email Protocol
extension MoreViewController: MFMailComposeViewControllerDelegate {
    func showMail(){
        if !MFMailComposeViewController.canSendMail() {
            print("No esta configurada ninguna cuenta de correo")
        } else {
            //Si se pueda enviar
            let composeVC = MFMailComposeViewController()
            composeVC.mailComposeDelegate = self
            
            //Configurar el cueroo del correo
            composeVC.setToRecipients(["marcoalonsoiosdeveloper@gmail.com"])
            composeVC.setSubject("Quiero hacer una sugerencia")
            composeVC.setMessageBody("Me gustaría ...", isHTML: false)
            self.present(composeVC, animated: true)
        }
    }
    
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        if error != nil {
            controller.dismiss(animated: true)
            return
        }
        
        switch result {
        case .cancelled:
            print("Cancelado")
            DispatchQueue.main.async {
                
                self.mostrarMSJUsuario(msj: "Tu correo ah sido cancelado")
            }
            
        case .saved:
            print("saved")
            DispatchQueue.main.async {
                self.mostrarMSJUsuario(msj: "Tu correo se guardó en borradores")
            }
        case .sent:
            print("sent")
            DispatchQueue.main.async {
                self.mostrarMSJUsuario(msj: "Tu correo ah sido enviado")
            }
        case .failed:
            mostrarMSJUsuario(msj: "Ocurrió un error inesperado")
        }
        
        controller.dismiss(animated: true)
    }
    
    func mostrarMSJUsuario(msj: String){
        let alerta = UIAlertController(title: "Atención", message: msj, preferredStyle: .alert)
        let accionAceptar = UIAlertAction(title: "Aceptar", style: .default, handler: nil)
        alerta.addAction(accionAceptar)
        present(alerta, animated: true, completion: nil)
    }
    
    
}

extension MoreViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        actions.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80.0
    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        cell.textLabel?.text = actions[indexPath.row].name
        cell.imageView?.image = UIImage(systemName: actions[indexPath.row].icon)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //Vibracion
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        
        tableView.deselectRow(at: indexPath, animated: true)
        print(actions[indexPath.row].name)
        
        switch actions[indexPath.row].action {
        case "sugerencia":
            print("sugerencia")
            showMail()
            
        case "califica":
            califica()
            
        case "recordatorio":
            goReminders()
            
        case "seguir":
            showRedes()
            
        case "developer":
            showDeveloper()
            
        case "configuracion":
            goSettings()
           
        default:
            print("Default")
        }
    }
    
    private func goReminders(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "ReminderViewController") as! ReminderViewController
        vc.modalPresentationStyle = .automatic
        self.present(vc, animated: true)
    }
    
    private func showRedes(){
        guard let url = URL(string: "https://mobilestudio.mx/") else { return }
        let vcSS = SFSafariViewController(url: url)
        present(vcSS, animated: true)
    }
    private func showDeveloper(){
        guard let url = URL(string: "https://github.com/marcoalonso") else { return }
        let vcSS = SFSafariViewController(url: url)
        present(vcSS, animated: true)
    }
    
    private func califica(){
        if let calificaURL = URL(string: "itms-apps://itunes.apple.com/app/6447369429?action=write-review") {
            let appCalifica : UIApplication = UIApplication.shared
            if appCalifica.canOpenURL(calificaURL) {
                appCalifica.open(calificaURL)
            }
        }
    }
    
    private func compartir(){
        let elementosCompartir: [Any] = ["https://apps.apple.com/us/app/movieverse-world/id6447369429"]
        
        let activityViewController = UIActivityViewController(activityItems: elementosCompartir, applicationActivities: nil)

        if let popoverController = activityViewController.popoverPresentationController {
            popoverController.sourceView = compartirButton
            popoverController.sourceRect = compartirButton.bounds
            popoverController.permittedArrowDirections = .any
        }

        present(activityViewController, animated: true, completion: nil)
    }
    
    private func goSettings() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "SettingsViewController") as! SettingsViewController
        self.present(vc, animated: true)
    }
    
    
}
