require 'osx/cocoa'
require 'lib/cocoa_utils'

OSX.require_framework 'WebKit'


class Safari
  
  attr_reader :document
  
  def initialize(width=1024, height=768)
    OSX.NSApplicationLoad
    
    @window = OSX::NSWindow.alloc.initWithContentRect_styleMask_backing_defer(
      OSX::NSRect.new(0, 0, width, height), 
      OSX::NSBorderlessWindowMask, 
      OSX::NSBackingStoreBuffered, 
      false
    )
    @view = OSX::WebView.alloc.initWithFrame(OSX::NSRect.new(0, 0, width, height))
    
    # @view.mainFrame.frameView.setAllowsScrolling(false)
    
    @delegate = LoadDelegate.alloc.init
    @view.setFrameLoadDelegate(@delegate)

    # Replace the window's content @view with the web @view
    @window.setContentView(@view)
    @view.release
    
    @document = nil
  end
  
  def load_html(html, base_url="http://localhost")
    osx_base_url = OSX::NSURL.alloc.initWithString(base_url)
    @view.mainFrame.loadHTMLString_baseURL(html, osx_base_url)
    
    OSX.CFRunLoopRun #this blocks until the frame loads (see LoadDelegate)

    @view.setNeedsDisplay(true)
    @view.displayIfNeeded
    @view.lockFocus
    @view.unlockFocus
    
    @document = @view.mainFrameDocument.documentElement
  end
end

class LoadDelegate < OSX::NSObject

  def webView_didFinishLoadForFrame(sender, frame)
    OSX.CFRunLoopStop(OSX.CFRunLoopGetCurrent)
  end

  def webView_didFailLoadWithError_forFrame(webview, load_error, frame)
    OSX.CFRunLoopStop(OSX.CFRunLoopGetCurrent)
  end

  def webView_didFailProvisionalLoadWithError_forFrame(webview, load_error, frame)
    OSX.CFRunLoopStop(OSX.CFRunLoopGetCurrent)
  end

end