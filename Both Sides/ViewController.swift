//
//  ViewController.swift
//  Both Sides
//
//  Created by Alberto Banet Masa on 14/10/15.
//  Copyright © 2015 abanet. All rights reserved.
//


import UIKit
import AVFoundation
import Social
import GoogleMobileAds


class ViewController: UIViewController {

    let red: CGFloat = 0.0
    let green: CGFloat = 0.0
    let blue: CGFloat = 0.0
    let brushWidth: CGFloat = 10.0
    
    var captureSession: AVCaptureSession?
    var stillImageOutput: AVCaptureStillImageOutput?
    var previewLayer: AVCaptureVideoPreviewLayer?
    var camaraUsada = AVCaptureDevicePosition.Front
    
    
    @IBOutlet weak var imagenIzquierda: UIImageView!
    @IBOutlet weak var imagenDerecha: UIImageView!
    

    @IBOutlet weak var imgUser: UIImageView!
    @IBOutlet weak var fotoView: UIView!
    var vistaImagenGrande: UIImageView?
    var imagenGrandeVisualizadaDerecha = true
   
    
    @IBOutlet weak var btnHacerFoto: UIButton!
    
    
    @IBOutlet weak var btnFaceDerecha: UIButton!
    @IBOutlet weak var btnTwitterDerecha: UIButton!
    @IBOutlet weak var btnFaceIzquierda: UIButton!
    @IBOutlet weak var btnTwitterIzquierda: UIButton!
    
    @IBOutlet weak var btnGuardarIzquierda: UIButton!
    @IBOutlet weak var btnGuardarDerecha: UIButton!
    
    @IBOutlet var bannerView: GADBannerView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // botones de compartir en redes deshabilitados hasta que no haya foto que compartir
        btnFaceDerecha.enabled = false
        btnFaceIzquierda.enabled = false
        btnTwitterDerecha.enabled = false
        btnTwitterIzquierda.enabled = false
        btnGuardarIzquierda.enabled = false
        btnGuardarDerecha.enabled = false
        
        btnHacerFoto.layer.cornerRadius = 5
        let tapImagenDerecha = UITapGestureRecognizer()
        let tapImagenIzquierda = UITapGestureRecognizer()
        
        
        imagenIzquierda.userInteractionEnabled = true
        imagenDerecha.userInteractionEnabled = true
        imagenIzquierda.layer.cornerRadius = CGRectGetWidth(imagenIzquierda.frame) / 16.0
        imagenIzquierda.layer.masksToBounds = true
        imagenDerecha.layer.cornerRadius = CGRectGetWidth(imagenDerecha.frame) / 16.0
        imagenDerecha.layer.masksToBounds = true
        
        
        tapImagenDerecha.addTarget(self, action: "imagenDerechaPulsada")
        tapImagenIzquierda.addTarget(self, action: "imagenIzquierdaPulsada")
        
        
        imagenDerecha.addGestureRecognizer(tapImagenDerecha)
        imagenIzquierda.addGestureRecognizer(tapImagenIzquierda)
        
        // Cargamos el banner de anuncios
        bannerView.adUnitID = "ca-app-pub-3455028088714350/6436362222"
        bannerView.rootViewController = self
        bannerView.loadRequest(GADRequest())
        
       
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
    }

    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        cargarCamara()
        previewLayer!.frame = fotoView.bounds
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func hacerFoto(sender: UIButton) {
        if let videoConnection = stillImageOutput!.connectionWithMediaType(AVMediaTypeVideo) {
            videoConnection.videoOrientation = AVCaptureVideoOrientation.Portrait
            stillImageOutput?.captureStillImageAsynchronouslyFromConnection(videoConnection, completionHandler: {(sampleBuffer, error) in
                if (sampleBuffer != nil) {
                    let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(sampleBuffer)
                    let dataProvider = CGDataProviderCreateWithCFData(imageData)
                    let cgImageRef = CGImageCreateWithJPEGDataProvider(dataProvider, nil, true, CGColorRenderingIntent.RenderingIntentDefault)
                    
                    let image = UIImage(CGImage: cgImageRef!, scale: 1.0, orientation: UIImageOrientation.Right)
                    if self.camaraUsada == AVCaptureDevicePosition.Back {
                    self.imagenDerecha.image = self.imagenDerechas(self.imagenNormalizada(image))
                    self.imagenIzquierda.image = self.imagenIzquierdas(self.imagenNormalizada(image))
                    } else {
                        self.imagenDerecha.image = self.imagenIzquierdas(self.imagenNormalizada(image))
                        self.imagenIzquierda.image = self.imagenDerechas(self.imagenNormalizada(image))
                    }
                    // habilitamos botones para compartir
                    self.btnFaceDerecha.enabled = true
                    self.btnFaceIzquierda.enabled = true
                    self.btnTwitterDerecha.enabled = true
                    self.btnTwitterIzquierda.enabled = true
                    self.btnGuardarIzquierda.enabled = true
                    self.btnGuardarDerecha.enabled = true
                }
            })
        }
    }
    
    
    func cargarCamara() {
        //
        captureSession?.stopRunning()
        previewLayer?.removeFromSuperlayer()
        
        captureSession = AVCaptureSession()
        captureSession!.sessionPreset = AVCaptureSessionPresetMedium //AVCaptureSessionPresetPhoto
        let camara = camaraConPosicion(camaraUsada)
        //let backCamera = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        
        //Preparamos para aceptar la entrada del dispositivo
        
        var error: NSError?
        var input: AVCaptureDeviceInput!
        do {
            input = try AVCaptureDeviceInput(device: camara)
        } catch let error1 as NSError {
            error = error1
            input = nil
        }
        
        if error == nil && captureSession!.canAddInput(input) {
            captureSession!.addInput(input)
            
            stillImageOutput = AVCaptureStillImageOutput()
            stillImageOutput!.outputSettings = [AVVideoCodecKey: AVVideoCodecJPEG]
            if captureSession!.canAddOutput(stillImageOutput) {
                captureSession!.addOutput(stillImageOutput)
                
                previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
                previewLayer!.frame = fotoView.bounds
                previewLayer!.videoGravity = AVLayerVideoGravityResizeAspect
                previewLayer!.connection?.videoOrientation = AVCaptureVideoOrientation.Portrait
                fotoView.layer.addSublayer(previewLayer!)
                
                captureSession!.startRunning()
            }
        }

    }
    
    
    // MARK: función para especificar la cámara
    func camaraConPosicion(posicion: AVCaptureDevicePosition)-> AVCaptureDevice {
        let dispositivos = AVCaptureDevice.devicesWithMediaType(AVMediaTypeVideo)
        for dispositivo in dispositivos {
            if dispositivo.position == posicion {
                return dispositivo as! AVCaptureDevice
            }
        }
        return AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
    }
    
    // MARK: Tratamiento de imágenes
    
    // Crea una imagen con el lado izquierdo de la foto original
    func imagenIzquierdas(imagenOriginal: UIImage) -> UIImage {
        let newWidth = (imagenOriginal.size.width / 2)
        
        // Recortamos la parte izquierda de la foto
        let cropRectIzquierda: CGRect = CGRectMake(0.0, 0.0, newWidth, imagenOriginal.size.height)
        let tempImage: CGImageRef = CGImageCreateWithImageInRect(imagenOriginal.CGImage, cropRectIzquierda)!
        let newImagenIzquierda: UIImage = UIImage(CGImage: tempImage)
        
        let ciimage: CIImage = CIImage(CGImage: newImagenIzquierda.CGImage!)
        let rotadaAux = ciimage.imageByApplyingTransform(CGAffineTransformMakeScale(-1, 1))
        let imagenRotada = UIImage(CIImage: rotadaAux)        
      
        return juntarImagenes(newImagenIzquierda, imagen2: imagenRotada)!
    }
    
    // Crea una imagen con el lado derecho de la foto original
    func imagenDerechas(imagenOriginal: UIImage) -> UIImage {
        let newWidth = (imagenOriginal.size.width / 2)
        
        // Recortamos la parte derecha de la fotografía
        let cropRectDerecha: CGRect = CGRectMake(newWidth, 0.0, newWidth, imagenOriginal.size.height)
        let tempImage: CGImageRef = CGImageCreateWithImageInRect(imagenOriginal.CGImage, cropRectDerecha)!
        let newImagenDerecha: UIImage = UIImage(CGImage: tempImage)
        
        let ciimage: CIImage = CIImage(CGImage: newImagenDerecha.CGImage!)
        let rotadaAux = ciimage.imageByApplyingTransform(CGAffineTransformMakeScale(-1, 1))
        let imagenRotada = UIImage(CIImage: rotadaAux)
        
        return juntarImagenes(imagenRotada, imagen2: newImagenDerecha)!
    }
    
    // Ponemos la foto en posición vertical (móvil en vertical)
    func imagenNormalizada (imagen: UIImage) -> UIImage {
        if(imagen.imageOrientation == UIImageOrientation.Up) {
            return imagen
        }
        UIGraphicsBeginImageContextWithOptions(imagen.size, false, imagen.scale)
        imagen.drawInRect(CGRectMake(0, 0, imagen.size.width, imagen.size.height))
        let imagenNormalizada = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return imagenNormalizada
    }
    
    
    
    // Función que junta las dos imágenes en una
    // Se asume que el tamaño de las dos imágenes es igual
    func juntarImagenes(imagen1: UIImage, imagen2: UIImage) -> UIImage? {
        if !identicasDimensiones(imagen1, imagen2: imagen2) {
            return nil
        } else {
            let size = CGSizeMake(imagen1.size.width * 2, imagen1.size.height)
            UIGraphicsBeginImageContext(size)
            imagen1.drawInRect(CGRectMake(0,0,imagen1.size.width, imagen1.size.height))
            imagen2.drawInRect(CGRectMake(imagen2.size.width, 0, imagen2.size.width, imagen2.size.height))
            let imagenFinal = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return imagenFinal
        }
    }
    
    
    func identicasDimensiones(imagen1: UIImage, imagen2: UIImage) -> Bool {
        return imagen1.size.width == imagen2.size.width && imagen1.size.height == imagen2.size.height ? true : false
    }
    
    // MARK: Darle la vuelta a la cámara
    
    @IBAction func voltearCamara(sender: AnyObject) {
        if camaraUsada == AVCaptureDevicePosition.Front {
            camaraUsada = AVCaptureDevicePosition.Back
        } else {
            camaraUsada = AVCaptureDevicePosition.Front
        }
        cargarCamara()
    }
    
    // MARK: Touch sobre las imágenes
    // 
    func imagenDerechaPulsada() {
        // Abrimos una vista con la imagen en grande
        imagenGrandeVisualizadaDerecha = true
        self.visualizarImagenGrande(imagenDerecha.image!)
    }
    
    func imagenIzquierdaPulsada() {
        imagenGrandeVisualizadaDerecha = false
        self.visualizarImagenGrande(imagenIzquierda.image!)
    }
    
    func imagenGrandePulsada() {
        print("imagen Grande Pulsada")
        vistaImagenGrande!.removeFromSuperview()
        for v in view.subviews {
            if v is UIVisualEffectView {
                v.removeFromSuperview()
            }
        }
        self.view.backgroundColor = UIColor.lightGrayColor() // no sé pq al volver pierde el gris de la vista principal (se ve pero transparente)
    }
    
    // MARK: Swipe sobre las imágenes
    func imagenGrandeSwiped(sender: UISwipeGestureRecognizer) {
        UIView.animateWithDuration(0.3, delay: 0.0, options: .CurveEaseOut, animations: {
            if sender.direction == .Left {
                self.vistaImagenGrande!.center.x = -(self.view.bounds.size.width / 2)
            } else {
                self.vistaImagenGrande!.center.x = self.view.bounds.size.width
            }
            self.vistaImagenGrande!.alpha = 0.0
            }, completion: {
                (value: Bool) in
                self.imagenGrandePulsada()
                if self.imagenGrandeVisualizadaDerecha {
                    self.visualizarImagenGrande(self.imagenIzquierda.image!)
                    self.imagenGrandeVisualizadaDerecha = false
                } else {
                    self.visualizarImagenGrande(self.imagenDerecha.image!)
                    self.imagenGrandeVisualizadaDerecha = true
                }
        })
    }
    
    func visualizarImagenGrande(imagen: UIImage){
        print("imagen pulsada tamaño: \(imagen.size.width), \(imagen.size.height)")
        vistaImagenGrande = UIImageView(frame: CGRect(x: 30, y: 30, width: self.view.bounds.size.width - 60, height: self.view.bounds.size.height - 60))
        
        // gestos para la imagen grande
        vistaImagenGrande!.userInteractionEnabled = true
        let tapImagenGrande = UITapGestureRecognizer()
        tapImagenGrande.addTarget(self, action: "imagenGrandePulsada")
        vistaImagenGrande!.addGestureRecognizer(tapImagenGrande)
        
        let swipeImagenGrandeDerecha = UISwipeGestureRecognizer()
        swipeImagenGrandeDerecha.direction = .Right
        swipeImagenGrandeDerecha.addTarget(self, action: "imagenGrandeSwiped:")
        vistaImagenGrande!.addGestureRecognizer(swipeImagenGrandeDerecha)
        
        let swipeImagenGrandeIzquierda = UISwipeGestureRecognizer()
        swipeImagenGrandeIzquierda.direction = .Left
        swipeImagenGrandeIzquierda.addTarget(self, action: "imagenGrandeSwiped:")
        vistaImagenGrande!.addGestureRecognizer(swipeImagenGrandeIzquierda)
        
        vistaImagenGrande!.layer.cornerRadius = 10.0
        vistaImagenGrande!.clipsToBounds = true
        vistaImagenGrande!.layer.borderColor = UIColor.blackColor().CGColor
        vistaImagenGrande!.layer.borderWidth = 1.0
        vistaImagenGrande!.alpha = 0.0
        
        insertBlurView(self.view, style: .Dark)
        vistaImagenGrande!.image = imagen
        vistaImagenGrande!.contentMode = .ScaleAspectFill
        self.view.addSubview(vistaImagenGrande!)
        UIView.animateWithDuration(0.5, animations: {
            self.vistaImagenGrande!.alpha = 1.0
        })
        
        // Insertamos el nombre de la app
        let etiqueta = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 30))
        vistaImagenGrande!.addSubview(etiqueta)
        etiqueta.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint (item: etiqueta, attribute: .CenterX, relatedBy: .Equal, toItem: vistaImagenGrande!, attribute: .CenterX, multiplier: 1.0, constant: 0).active = true
        NSLayoutConstraint(item: etiqueta, attribute: .BottomMargin, relatedBy: .Equal, toItem: vistaImagenGrande!, attribute: .Bottom, multiplier: 1.0, constant: -30.0).active = true
        etiqueta.textColor = UIColor.whiteColor()
        etiqueta.font = UIFont(name: "Avenir New", size: 22.0)
        etiqueta.text = "BothSides App"
        
        
        // La centramos en el centro de la pantalla
//        vistaImagenGrande?.translatesAutoresizingMaskIntoConstraints = false
//
//        NSLayoutConstraint(item: vistaImagenGrande!, attribute: .CenterX, relatedBy: .Equal, toItem: self.view, attribute: .CenterX, multiplier: 1.0, constant: 0.0).active = true
//        NSLayoutConstraint(item: vistaImagenGrande!, attribute: .CenterY, relatedBy: .Equal, toItem: self.view, attribute: .CenterY, multiplier: 1.0, constant: 0.0).active = true

    }
    
    func insertBlurView(view: UIView, style: UIBlurEffectStyle) -> UIVisualEffectView {
        view.backgroundColor = UIColor.clearColor()
        let blurEffect = UIBlurEffect(style: style)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        self.view.insertSubview(blurEffectView, belowSubview: vistaImagenGrande!)
        return blurEffectView
    }
    
    
    
    // MARK: Compartir con Facebook
    @IBAction func compartirFacebookImagenDerecha(sender: AnyObject) {
        compartirFacebookImagen(imagenDerecha.image!)

    }
    
    @IBAction func compartirFacebookImagenIzquierda(sender: AnyObject) {
        compartirFacebookImagen(imagenIzquierda.image!)
        
    }
    
    func compartirFacebookImagen(imagen: UIImage) {
        if SLComposeViewController.isAvailableForServiceType(SLServiceTypeFacebook) {
            let fbShare:SLComposeViewController = SLComposeViewController(forServiceType: SLServiceTypeFacebook)
            fbShare.addImage(mergeImagenEtiqueta(imagen))
            fbShare.setInitialText("BothSides App!")
            self.presentViewController(fbShare, animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: "Accounts", message: "Please login to a Facebook account to share.", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    // MARK: Compartir en Twitter
    
    @IBAction func compartirTwitterDerecha(sender: AnyObject) {
        compartirTwitterImagen(imagenDerecha.image!)
    }
    
    @IBAction func compartirTwitterIzquierda(sender: AnyObject) {
        compartirTwitterImagen(imagenIzquierda.image!)
    }
    
    
    @IBAction func guardarImagenDerecha(sender: AnyObject) {
        UIImageWriteToSavedPhotosAlbum(mergeImagenEtiqueta(imagenDerecha.image!), self, "image:didFinishSavingWithError:contextInfo:", nil)
        let alert = UIAlertController(title: "Saved!", message: "Your image has been save to your photo album.", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    
    @IBAction func guardarImagenIzquierda(sender: AnyObject) {
        UIImageWriteToSavedPhotosAlbum(mergeImagenEtiqueta(imagenIzquierda.image!), self, "image:didFinishSavingWithError:contextInfo:", nil)
        let alert = UIAlertController(title: "Saved!", message: "Your image has been save to your photo album.", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func image(image: UIImage, didFinishSavingWithError error: NSError?, contextInfo:UnsafePointer<Void>) {
        print("Image saved")
    }
    
    func compartirTwitterImagen(imagen: UIImage) {
        if SLComposeViewController.isAvailableForServiceType(SLServiceTypeTwitter){
            let twitterSheet:SLComposeViewController = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
            twitterSheet.setInitialText("BothSides App")
            twitterSheet.addImage(mergeImagenEtiqueta(imagen))
            self.presentViewController(twitterSheet, animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: "Accounts", message: "Please login to a Twitter account to share.", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    // MARK: Merge de imagen con etiqueta
    func mergeImagenEtiqueta(imagen: UIImage) -> UIImage {
        // etiqueta blanca
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 120, height: 25))
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor.whiteColor()
        label.font = UIFont(name: "Avenir New", size: 22.0)
        label.text = "BothSides App"
        
        // etiqueta negra
        let labelNegra = UILabel(frame: CGRect(x: 0, y: 0, width: 120, height: 25))
        labelNegra.translatesAutoresizingMaskIntoConstraints = false
        labelNegra.textColor = UIColor.blackColor()
        labelNegra.font = UIFont(name: "Avenir New", size: 22.0)
        labelNegra.text = "BothSides App"
        
        
        
        let vistaImagen: UIImageView = UIImageView(image: imagen)
        let size = imagen.size
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        vistaImagen.layer.renderInContext(UIGraphicsGetCurrentContext()!)
        let xCentro = imagen.size.width - label.bounds.size.width
        let yBotton = imagen.size.height - label.bounds.size.height
        label.drawTextInRect(CGRect(x:xCentro, y:yBotton, width:120, height:25))
        labelNegra.drawTextInRect(CGRect(x: xCentro, y: yBotton - label.bounds.size.height, width: 120, height: 25))
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    
    
}

