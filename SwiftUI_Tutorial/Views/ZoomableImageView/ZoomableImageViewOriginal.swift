//
//  ZoomableImageViewOriginal.swift
//  SwiftUI_Tutorial
//
//  Created by HauNguyen on 10/06/2022.
//

import SwiftUI

struct ZoomableImageViewOriginal: UIViewControllerRepresentable {
    init(pathUrl: Binding<String>) {
        self._pathUrl = pathUrl
    }
    @Binding var pathUrl: String
    
    func makeUIViewController(context: Context) -> ViewController {
        return ViewController(pathUrl: $pathUrl)
    }
    
    func updateUIViewController(_ viewController: ViewController, context: Context) {
        
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator()
    }
    
    // MARK: - ViewController
    
    class ViewController: UIViewController {
        init(pathUrl: Binding<String>) {
            self._pathUrl = pathUrl
            super.init(nibName: nil, bundle: nil)
        }
        @Binding var pathUrl: String

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        var imageScrollView: Coordinator!
        
        override func viewDidLoad() {
            super.viewDidLoad()

            //1. Initialize imageScrollView and adding it to viewControllers view
            self.imageScrollView = Coordinator(frame: self.view.bounds)
            self.view.addSubview(self.imageScrollView)
            self.layoutImageScrollView()
            
            //2. Making an image from our photo path
            //let imagePath = Bundle.main.path(forResource: "225H", ofType: "jpg")!
            let getUrl: URL = URL(string: self.pathUrl)!
            do {
                let imageData = try Data(contentsOf: getUrl)

                let image = UIImage(data: imageData)!
                
                //3. Ask imageScrollView to show image
                self.imageScrollView.display(image)
            } catch {
                print("Unable to load data: \(error)")
            }
            

        }
        
        override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
            super.viewWillTransition(to: size, with: coordinator)
            
            self.restoreStatesForRotation(in: size)
        }
        
        
        func restoreStatesForRotation(in bounds: CGRect) {
            // recalculate contentSize based on current orientation
            let restorePoint = imageScrollView.pointToCenterAfterRotation()
            let restoreScale = imageScrollView.scaleToRestoreAfterRotation()
            imageScrollView.frame = bounds
            imageScrollView.setMaxMinZoomScaleForCurrentBounds()
            imageScrollView.restoreCenterPoint(to: restorePoint, oldScale: restoreScale)
        }
        
        func restoreStatesForRotation(in size: CGSize) {
            var bounds = self.view.bounds
            if bounds.size != size {
                bounds.size = size
                self.restoreStatesForRotation(in: bounds)
            }
        }

        
        func layoutImageScrollView() {
            self.imageScrollView.translatesAutoresizingMaskIntoConstraints = false
            
            let top = NSLayoutConstraint(item: self.imageScrollView!, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .top, multiplier: 1.0, constant: 0.0)
            let left = NSLayoutConstraint(item: self.imageScrollView!, attribute: .left, relatedBy: .equal, toItem: self.view, attribute: .left, multiplier: 1.0, constant: 0.0)
            
            let bottom = NSLayoutConstraint(item: self.imageScrollView!, attribute: .bottom, relatedBy: .equal, toItem: self.view, attribute: .bottom, multiplier: 1.0, constant: 0.0)
            let right = NSLayoutConstraint(item: self.imageScrollView!, attribute: .right, relatedBy: .equal, toItem: self.view, attribute: .right, multiplier: 1.0, constant: 0.0)
            
            self.view.addConstraints([top, left, bottom, right])
        }


    }
    
    // MARK: - Coordinator
    class Coordinator: UIScrollView, UIScrollViewDelegate {
        
        var zoomView: UIImageView!
        
        lazy var zoomingTap: UITapGestureRecognizer = {
            let zoomingTap = UITapGestureRecognizer(target: self, action: #selector(handleZoomingTap(_:)))
            zoomingTap.numberOfTapsRequired = 2
            
            return zoomingTap
        }()

        
        override init(frame: CGRect) {
            super.init(frame: frame)
            
            self.showsHorizontalScrollIndicator = false
            self.showsVerticalScrollIndicator = false
            self.decelerationRate = UIScrollView.DecelerationRate.fast
            self.delegate = self
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override func layoutSubviews() {
            super.layoutSubviews()
            self.centerImage()
        }
        
        
        //MARK: - Configure scrollView to display new image
        func display(_ image: UIImage) {
            
            //1. clear the previous image
            zoomView?.removeFromSuperview()
            zoomView = nil
            
            //2. make a new UIImageView for the new image
            zoomView = UIImageView(image: image)
            
            self.addSubview(zoomView)
            
            self.configureFor(image.size)
        }
        
        func configureFor(_ imageSize: CGSize) {
            self.contentSize = imageSize
            self.setMaxMinZoomScaleForCurrentBounds()
            self.zoomScale = self.minimumZoomScale
            
            //Enable zoom tap
            self.zoomView.addGestureRecognizer(self.zoomingTap)
            self.zoomView.isUserInteractionEnabled = true
        }
        
        func setMaxMinZoomScaleForCurrentBounds() {
            let boundsSize = self.bounds.size
            let imageSize = zoomView.bounds.size
            
            //1. calculate minimumZoomscale
            let xScale =  boundsSize.width  / imageSize.width    // the scale needed to perfectly fit the image width-wise
            let yScale = boundsSize.height / imageSize.height  // the scale needed to perfectly fit the image height-wise
            
            let minScale = min(xScale, yScale)                 // use minimum of these to allow the image to become fully visible
            
            //2. calculate maximumZoomscale
            var maxScale: CGFloat = 10
            
            if minScale < 1 {
                maxScale = 2
            }
            
            if minScale >= 1 && minScale < 5 {
                maxScale = 7
            }
            
            if minScale >= 5 {
                maxScale = max(10, minScale)
            }
            
            
            self.maximumZoomScale = maxScale
            self.minimumZoomScale = minScale
        }
        
        func centerImage() {
            // center the zoom view as it becomes smaller than the size of the screen
            let boundsSize = self.bounds.size
            var frameToCenter = zoomView?.frame ?? CGRect.zero
            
            // center horizontally
            if frameToCenter.size.width < boundsSize.width {
                frameToCenter.origin.x = (boundsSize.width - frameToCenter.size.width)/2
            }
            else {
                frameToCenter.origin.x = 0
            }
            
            // center vertically
            if frameToCenter.size.height < boundsSize.height {
                frameToCenter.origin.y = (boundsSize.height - frameToCenter.size.height)/2
            }
            else {
                frameToCenter.origin.y = 0
            }
            
            zoomView?.frame = frameToCenter
        }


        //MARK: - UIScrollView Delegate Methods
        
        func viewForZooming(in scrollView: UIScrollView) -> UIView? {
            return self.zoomView
        }
        
        func scrollViewDidZoom(_ scrollView: UIScrollView) {
            self.centerImage()
        }
        
        //MARK: - Methods called during rotation to preserve the zoomScale and the visible portion of the image
        
        // returns the center point, in image coordinate space, to try restore after rotation.
        func pointToCenterAfterRotation() -> CGPoint {
            let boundsCenter = CGPoint(x: self.bounds.midX, y: self.bounds.midY)
            return self.convert(boundsCenter, to: zoomView)
        }
        
        // returns the zoom scale to attempt to restore after rotation.
        func scaleToRestoreAfterRotation() -> CGFloat {
            var contentScale = self.zoomScale
            
            // If we're at the minimum zoom scale, preserve that by returning 0, which will be converted to the minimum
            // allowable scale when the scale is restored.
            if contentScale <= self.minimumZoomScale + CGFloat.ulpOfOne {
                contentScale = 0
            }
            
            return contentScale
        }
        
        func maximumContentOffset() -> CGPoint {
            let contentSize = self.contentSize
            let boundSize = self.bounds.size
            return CGPoint(x: contentSize.width - boundSize.width, y: contentSize.height - boundSize.height)
        }
        
        func minimumContentOffset() -> CGPoint {
            
            return CGPoint.zero
        }
        
        func restoreCenterPoint(to oldCenter: CGPoint, oldScale: CGFloat) {
            
            // Step 1: restore zoom scale, first making sure it is within the allowable range.
            self.zoomScale = min(self.maximumZoomScale, max(self.minimumZoomScale, oldScale))
            
            
            // Step 2: restore center point, first making sure it is within the allowable range.
            
            // 2a: convert our desired center point back to our own coordinate space
            let boundsCenter = self.convert(oldCenter, from: zoomView)
            // 2b: calculate the content offset that would yield that center point
            var offset = CGPoint(x: boundsCenter.x - self.bounds.size.width/2.0, y: boundsCenter.y - self.bounds.size.height/2.0)
            // 2c: restore offset, adjusted to be within the allowable range
            let maxOffset = self.maximumContentOffset()
            let minOffset = self.minimumContentOffset()
            offset.x = max(minOffset.x, min(maxOffset.x, offset.x))
            offset.y = max(minOffset.y, min(maxOffset.y, offset.y))
            self.contentOffset = offset
        }

        //MARK: - Handle ZoomTap
        
        @objc func handleZoomingTap(_ sender: UITapGestureRecognizer) {
            let location = sender.location(in: sender.view)
            self.zoom(to: location, animated: true)
            
        }
        
        func zoom(to point: CGPoint, animated: Bool) {
            let currentScale = self.zoomScale
            let minScale = self.minimumZoomScale
            let maxScale = self.maximumZoomScale
            
            if (minScale == maxScale && minScale > 1) {
                return;
            }
            
            let toScale = maxScale
            let finalScale = (currentScale == minScale) ? toScale : minScale
            let zoomRect = self.zoomRect(for: finalScale, withCenter: point)
            self.zoom(to: zoomRect, animated: animated)
        }
        
        // The center should be in the imageView's coordinates
        func zoomRect(for scale: CGFloat, withCenter center: CGPoint) -> CGRect {
            var zoomRect = CGRect.zero
            let bounds = self.bounds
            
            // the zoom rect is in the content view's coordinates.
            //At a zoom scale of 1.0, it would be the size of the imageScrollView's bounds.
            //As the zoom scale decreases, so more content is visible, the size of the rect grows.
            zoomRect.size.width = bounds.size.width / scale
            zoomRect.size.height = bounds.size.height / scale
            
            // choose an origin so as to get the right center.
            zoomRect.origin.x = center.x - (zoomRect.size.width / 2.0)
            zoomRect.origin.y = center.y - (zoomRect.size.height / 2.0)
            
            return zoomRect
            
        }
        
    }
}

struct ZoomableImageViewOriginal_Previews: PreviewProvider {
    static var previews: some View {
        ZoomableImageViewOriginal(pathUrl: .constant("https://images.indianexpress.com/2022/06/Apple-WWDC-20221.jpg"))
    }
}
