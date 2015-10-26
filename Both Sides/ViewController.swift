//
//  ViewController.swift
//  Both Sides
//
//  Created by Alberto Banet Masa on 14/10/15.
//  Copyright © 2015 abanet. All rights reserved.
//


import UIKit
import AVFoundation

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

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
   
    
    @IBOutlet weak var btnHacerFoto: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        btnHacerFoto.layer.cornerRadius = 5
        
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
                    self.imagenDerecha.image = self.imagenDerechas(self.imagenNormalizada(image))
                    self.imagenIzquierda.image = self.imagenIzquierdas(self.imagenNormalizada(image))
                }
            })
        }
    }
    
    
    func cargarCamara() {
        //
        captureSession?.stopRunning()
        previewLayer?.removeFromSuperlayer()
        
        captureSession = AVCaptureSession()
        captureSession!.sessionPreset = AVCaptureSessionPresetPhoto
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
                previewLayer!.frame = fotoView.frame
                previewLayer!.videoGravity = AVLayerVideoGravityResizeAspect
                previewLayer!.connection?.videoOrientation = AVCaptureVideoOrientation.Portrait
                fotoView.layer.addSublayer(previewLayer!)
                
                captureSession!.startRunning()
            }
        }

    }
    
    
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
       // fotoView.image = info[UIImagePickerControllerOriginalImage] as? UIImage
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
}

