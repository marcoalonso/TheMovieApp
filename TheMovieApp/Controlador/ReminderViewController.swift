//
//  ReminderViewController.swift
//  TheMovieApp
//
//  Created by Marco Alonso Rodriguez on 30/05/23.
//

import UIKit
import UserNotifications

class ReminderViewController: UIViewController {

    @IBOutlet weak var tituloTextField: UITextField!
    @IBOutlet weak var mensajeTextView: UITextView!
    @IBOutlet weak var fechaDatePicker: UIDatePicker!
    
    let notificationCenter = UNUserNotificationCenter.current()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mensajeTextView.delegate = self

        //Pedir permiso al usuario
        notificationCenter.requestAuthorization(options: [.alert, .sound]) { permiso, error in
            if (!permiso) {
                print("Permiso denegado \(permiso)")
                //utilizar el hilo principal
                DispatchQueue.main.async {
                    self.mostrarAlerta(titulo: "ATENCION", mensaje: "Para utilizar esta aplicacion debes activar las notificaciones", textButton: "En otro momento", configButton: true)
                }
            }
        }
    }
    
    //Formatear la fecha
    func formattedDate(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM y HH:mm"
        return formatter.string(from: date)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

    
    func mostrarAlerta(titulo: String, mensaje: String, textButton: String, configButton: Bool) {
        let alerta = UIAlertController(title: titulo, message: mensaje, preferredStyle: .alert)
        let accionAceptar = UIAlertAction(title: textButton, style: .destructive) { _ in
            //Do something
        }
        
        if configButton {
            let accionCofiguracion = UIAlertAction(title: "Ir a configuracion", style: .default) { _ in
                //mandar al usuario a la configuracion del dispositivo
                guard let configuracionURL = URL(string: UIApplication.openSettingsURLString) else { return }
                
                if UIApplication.shared.canOpenURL(configuracionURL) {
                    UIApplication.shared.openURL(configuracionURL)
                }
            }
            alerta.addAction(accionCofiguracion)
        }
        
        
        alerta.addAction(accionAceptar)
        
        present(alerta, animated: true)
    }

    @IBAction func crearButton(_ sender: UIButton) {
        notificationCenter.getNotificationSettings { settings in
            
            //-- ejecutar en el hilo principal, de lo contrario truena la app
            DispatchQueue.main.async {
                guard let titulo = self.tituloTextField.text , titulo != "" else {
                    self.mostrarAlerta(titulo: "Atención", mensaje: "Para crear un recordatorio es necesario escribir un titulo y seleccionar una fecha", textButton: "Aceptar", configButton: false)
                    return
                }
                let mensaje = self.mensajeTextView.text ?? ""
                let fecha = self.fechaDatePicker.date
                
                //validar si hay permiso
                if settings.authorizationStatus == .authorized {
                    let contenido = UNMutableNotificationContent()
                    contenido.title = titulo
                    contenido.body = mensaje
                    contenido.sound = UNNotificationSound(named: UNNotificationSoundName("water.wav"))
                    
                    let dateComponent = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: fecha)
                    
                    //necesitamos un disparador // trigger
                    let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponent, repeats: false)
                    
                    let request = UNNotificationRequest(identifier: "MiNotificacion", content: contenido, trigger: trigger)
                    
                    self.notificationCenter.add(request) { error in
                        //validar si hubo error
                        
                        print("Recordatorio creado: \(fecha)")
                        DispatchQueue.main.async {
                            self.tituloTextField.text = ""
                            self.mensajeTextView.text = ""
                            
                            let alerta = UIAlertController(title: "Recordatorio Agendado", message: "Para : \(self.formattedDate(date: fecha))", preferredStyle: .alert)
                            let accionAceptar = UIAlertAction(title: "Aceptar", style: .default) { _ in
                                //Vibracion
                                let generator = UINotificationFeedbackGenerator()
                                generator.notificationOccurred(.warning)
                                self.dismiss(animated: true)
                                
                            }
                            
                            alerta.addAction(accionAceptar)
                            self.present(alerta, animated: true)
                        }//dispatch
                    }
                    
                } else {
                   print("necesitas habilitar las notificaciones")
                }//settings.authorizationStatus
                
            }//dispatch
            
        }//setting
    }
    

}

extension ReminderViewController: UITextViewDelegate {
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        // El usuario está a punto de comenzar la edición del UITextView
        // Aquí puedes realizar acciones o mostrar elementos adicionales si es necesario
        mensajeTextView.text = ""
        return true
    }

}
