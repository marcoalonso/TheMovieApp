//
//  OnboardingViewController.swift
//  TheMovieApp
//
//  Created by Marco Alonso Rodriguez on 07/04/23.
//

import UIKit

struct Slide {
    let texto: String
    let imagen: UIImage
}

class OnboardingViewController: UIViewController {
    
    
    
    @IBOutlet weak var instruccionesText: UITextView!
    @IBOutlet weak var indicatorPagecontrol: UIPageControl!
    @IBOutlet weak var tutorialImagen: UIImageView!
    
    var slides: [Slide] = [
        Slide(texto: "En la parte de abajo encontrarás las secciones de la aplicación. Donde podrás navegar fácilmente a cada una de ellas", imagen: UIImage(named: "1")!),
        Slide(texto: "Esta es una de las secciones más importantes ya que te permite buscar miles de películas diferentes que han sido mostradas en cines en diferentes años y épocas.", imagen: UIImage(named: "2")!),
        Slide(texto: "Desliza hacia la izquierda para ver más películas recientes o proximas a estrenarse en cines, tambien puedes seleccionar alguna de tu interés para ver una vista detallada de la misma", imagen: UIImage(named: "3")!),
        Slide(texto: "Tenemos una sección de cientos de películas populares que has sido publicadas en cines a lo largo de los años, echa un vistazo, te aseguro que encontrarás mas de alguna que hayas visto.", imagen: UIImage(named: "4")!),
        Slide(texto: "Escribe el nombre de la película de tu interés y dale click al boton de buscar", imagen: UIImage(named: "5")!),
        Slide(texto: "Aqui podrás ver los resultados de tu búsqueda o algún mensaje si es que no se encontró la pelicula que buscabas. Recuerda que puedes ver los diferentes tráilers seleccionadno una pelicula.", imagen: UIImage(named: "6")!),
        ]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupSlides()
        
    }
    
    func setupSlides(){
        tutorialImagen.isUserInteractionEnabled = true
        indicatorPagecontrol.addTarget(self, action: #selector(swipePageControl(_:)), for: .valueChanged)
        tutorialImagen.addGestureRecognizer(createSwipeGestureRecognizer(for: .left))
        tutorialImagen.addGestureRecognizer(createSwipeGestureRecognizer(for: .right))
        tutorialImagen.image = slides[indicatorPagecontrol.currentPage].imagen
        instruccionesText.text = slides[indicatorPagecontrol.currentPage].texto
    }
    
    private func createSwipeGestureRecognizer(for direction: UISwipeGestureRecognizer.Direction) -> UISwipeGestureRecognizer {
        // Initialize Swipe Gesture Recognizer
        let swipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(didSwipe(_:)))

        // Configure Swipe Gesture Recognizer
        swipeGestureRecognizer.direction = direction

        return swipeGestureRecognizer
    }
    
    @objc private func didSwipe(_ sender: UISwipeGestureRecognizer) {
        switch sender.direction {
        case .up:
            print("Up")
        case .down:
            print("down")
        case .left:
            print("left") //avanza siguiente pagina
            
            //si es 2, no hacer nada
            if (indicatorPagecontrol.currentPage >= 0) && (indicatorPagecontrol.currentPage <= slides.count-1) {
                indicatorPagecontrol.currentPage += 1
                print(slides[indicatorPagecontrol.currentPage])
                //FondoOnboView.backgroundColor = slides[OnboPageControll.currentPage].color
//                OnboImagen.image = slides[OnboPageControll.currentPage].imagen
//                OnboLabel.text = slides[OnboPageControll.currentPage].texto
            }
            //si es mayor de 0 deslizar a la derecha +1
            
            
        case .right:
            print("right") //retrocede pagina anterior
            
            if (indicatorPagecontrol.currentPage <= slides.count-1) && (indicatorPagecontrol.currentPage >= 0) {
                indicatorPagecontrol.currentPage -= 1
                print(slides[indicatorPagecontrol.currentPage])
                //FondoOnboView.backgroundColor = slides[OnboPageControll.currentPage].color
//                OnboImagen.image = slides[OnboPageControll.currentPage].imagen
//                OnboLabel.text = slides[OnboPageControll.currentPage].texto
            }
            
            
        default:
            break
        }
        
        UIView.animate(withDuration: 1.2) {
            
            self.tutorialImagen.image = self.slides[self.indicatorPagecontrol.currentPage].imagen
            self.instruccionesText.text = self.slides[self.indicatorPagecontrol.currentPage].texto
        }
    }
    
    @objc func swipePageControl(_ sender: UIPageControl) {
        let indice = sender.currentPage
        print(indice)
        
        self.tutorialImagen.image = self.slides[self.indicatorPagecontrol.currentPage].imagen
        self.instruccionesText.text = self.slides[self.indicatorPagecontrol.currentPage].texto
    }
   
   
    @IBAction func iniciarButton(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
    
}
