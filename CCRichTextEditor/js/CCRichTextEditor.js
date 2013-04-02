
////show keyboard, if touch is in the div
//document.addEventListener('touchend', function(e) { // Listen for touch end on the document
//                          // Get the touch and coordinates
//                          var touch = e.changedTouches.item(0);
//                          var touchX = touch.clientX;
//                          var touchY = touch.clientY;
//                          
//                          // Get the rect for the content
//                          var contentDIVRect = document.getElementById('content').getClientRects()[0];
//                          
//                          //alert("left:" + contentDIVRect.left + " bottom:" +contentDIVRect.bottom
//                          //	+ "touchX:" + touchX + "touchY:" + touchY);
//                          
//                          // Make sure we don't block touches to the content div
//                          if (touchX > contentDIVRect.left && touchY < contentDIVRect.bottom) {
//                          return;
//                          }
//                          
//                          // If the touch is out of the content div then simply give the div focus
//                          document.getElementById('content').focus();
//                          console.log("touched");
//                          }, false);
//
//
//if (!window.WebKitMutationObserver) {    //ios6 有，ios5没有
//  var timer;
//  document.addEventListener('DOMSubtreeModified', function(e) {
//    clearTimeout(timer);
//    timer = setTimeout(function () {
//      //callback scroll view
//
//      fire('DOMSubtreeModified');
//    }, 50);
//  }, false);
//}

function PhotoMetaData(src, width, height) {
	this.src = src;
	this.width = width;
	this.height = height;
};

function CCRichTextEditor() {
  var instance = this;
  var kPhotoClassName = "photo";
	var kAudioClassName = "audio";
	this.photos = new Array();    //p[src]= [{photoMetaData}];
	this.audioFileIndex = 0;
  
  /*
   *  在当前range插入节点, 否则在结尾插入
   */
  this.insertNodeAtCurrentRange = function(node) {
    var sel = window.getSelection();
    var range = null;
    if (sel.rangeCount) {
      range = sel.getRangeAt(0);
      range.deleteContents();
      range.insertNode(node);
      sel.removeAllRanges();
      range = range.cloneRange();
      range.selectNode(node);
      range.collapse(false);
      sel.addRange(range);
    }
    else {
      var contentDIV = document.getElementById('content');
      contentDIV.appendChild(node);
      range = document.createRange();
      range.selectNode(node);
      range.collapse(false);
      sel.addRange(range);
    }
    return range;
  };
  
  /*
   *  在当前range插入指定图片
   */
  this.insertSingleImage = function() {
		if (0 == arguments.length || 2 == arguments.length || 
				3 == arguments.length || 4 < arguments.length)
			return;

		var key = arguments[0];
		var src, w, h;
		if (4 == arguments.length) {
			src = arguments[1];
			w = arguments[2];
			h = arguments[3];
		}

		var photo = instance.photos[key];
		if (photo) {
			src = photo.src;
			w = photo.width;
			h = photo.height;
		}
	
    //alert(key + " " + src + " " + w +  " " + h);
		var scale = 1;
		var kMaxWidth = 384.0; //(768 / 2)
		if (w > kMaxWidth) {
		  scale = kMaxWidth / w;
		}

    //alert(key + " " + src + " " + w +  " " + h);
    var imgNode = document.createElement("IMG");
		imgNode.setAttribute("id", key);
		imgNode.setAttribute("class", kPhotoClassName);
		imgNode.setAttribute("src", src);
		imgNode.setAttribute("width", w * scale);
		imgNode.setAttribute("height", h * scale);
		instance.insertNodeAtCurrentRange(imgNode);
  };
 
  /*
   *  在contentDiv结尾插入代表声音文件的图片
   */
  this.insertSingleAudioFile = function(index){
    var imgNode = document.createElement("IMG");
    imgNode.setAttribute("id", "audio" + index);
    imgNode.setAttribute("src", "audioFileMark.png");
    imgNode.setAttribute("width", 96);
    imgNode.setAttribute("height", 96);
    
    instance.insertNodeAtCurrentRange(imgNode);
  }
  
  /*
   *  在UIWebView编辑状态时获取光标的坐标
   */
  this.getCaretPosition = function () {
    instance.stopMonitoring = true;

    var sel = window.getSelection();
    var range = sel.getRangeAt(0);
    var rects, rect;
    var hasFakeNode = false;
    try {
      if (sel.focusNode.nodeType != 3) {      //text == 3
        var newNode = document.createTextNode("-");
        
        if (sel.focusNode.querySelector('br')) {
          range.insertNode(newNode);
          rects = range.getClientRects();
          rect = rects[0];
          hasFakeNode = true;
        }
        else {
          rects = range.getClientRects();
          if (!rects.length) {                //插入图片后，获取的rects为空数组
            range.insertNode(newNode);
            rects = range.getClientRects();
            hasFakeNode = true;
          }
          rect = rects[0];
        }
      }
      else {
        rects = range.getClientRects();
        rect = rects[0];
      }
      
      var offsetY = rect.top + rect.height;
      if (hasFakeNode)
        range.deleteContents();
      
      instance.stopMonitoring = false;
 
      return offsetY;
    }
    catch (e) {
      alert(e);
    }
  };
  
  /*
   *  移动Img节点
   */
  this.moveImageAtTo = function(x, y, newX, newY) {
    // Get our required variables
    var element = document.elementFromPoint(x, y);
    if (element.tagName.toString() != "IMG") {
      // Attempt to move an image which doesn't exist at the point
      return;
    }
    
    var caretRange = document.caretRangeFromPoint(newX, newY);
    
    // Save the image source so we know this later when we need to re-insert it
    var imageSrc = element.src;
    
    // Set the selection to the range of the image, so we can delete it
    var selection = window.getSelection();
    var nodeRange = document.createRange();
    nodeRange.selectNode(element);
    selection.removeAllRanges();
    selection.addRange(nodeRange);
    
    // Delete the image
    document.execCommand('delete');
    
    // Set the selection to the caret range, so we can then add the image
    selection = window.getSelection();
    selection.removeAllRanges();
    selection.addRange(caretRange);
    instance.insertNodeAtCurrentRange(element);
  };
  
  /*
   *  在当前range插入节点
   *
   *  box:  top, right, bottom, left, width, height
   */
  this.clientRectOfElementFromPoint = function(x, y) {
    var rects = document.elementFromPoint(x, y).getClientRects();
    var rect = rects[0];
    if (rect) {
      return ("" + rect.top + "," + rect.right + "," + rect.bottom + "," +
              rect.left + "," + rect.width + "," + rect.height + "");
    }
    else {
      return "0"
    }
  };
  
  /*
   *  判断(x, y)点处的dom元素是否为音频文件img, true则返回index，false则放回-1
   */
  this.audioFileIndexAtPoint = function(x, y) {
    var elem = document.elementFromPoint(x, y);
    var isImg = (elem.tagName == "IMG") ? true: false;
    if (isImg) {
      var id = elem.getAttribute("class");
      if (id == kAudioClassName) {
        var index = id.substr(5);  //audioN
        return index;
      }
    }
    return -1;
  }
  
	/*
	 * 监听Dom的状态改变，更新image和audio
	 */
  this.stopMonitoringDomModified = false;  //native bridge的实现有ifame的改变dom
  this.hookDomModifiedEvent = function () {
  //if (!window.WebKitMutationObserver) {    //ios6 有，ios5没有
//    var timer;
//    document.addEventListener('DOMSubtreeModified', function(e) {
//      alert(e.target);
//      clearTimeout(timer);
//      timer = setTimeout(function () {
//        fire('DOMSubtreeModified');
//      }, 5000);
//    }, false);
   try {
    var timer;
    document.addEventListener('DOMSubtreeModified', function(e) {
			if (instance.stopMonitoring) return;
      clearTimeout(timer);
			timer = setTimeout(function() {
				//handle photos
				var photoElements = document.getElementsByClassName(kPhotoClassName);
				var key, src, w, h, i=0;
				var photo, photoElement;
				var photos = new Array();
				var jsonArray = new Array();
				while(photoElement = photoElements[i++]) {
					key = photoElement.getAttribute("id");
					photo = photos[key];
					if (!photo) {
						src = photoElement.getAttribute("src");
						w = photoElement.getAttribute("width");
						h = photoElement.getAttribute("height");
						photo = new PhotoMetaData(src, w, h);
						photos[key] = photo;

						jsonArray.push({"key":key, "value":src});
					}
				}
				instance.photos = photos;
				instance.stopMonitoring = true;
				NativeBridge.call("updatePictureData:", jsonArray);
				instance.stopMonitoring = false;
				//var audioElements = document.getElementsByClassName(kAudioClassName);
//                         fire('DOMSubtreeModified');
			}, 50);  //对于连续的变化，仅在稳定后，才处理
		}, false);
	 }
	 catch (e) {
		 alert(e);
	 }
  };

	this.hookDomModifiedEvent();
  // 重写构造函数
  CCRichTextEditor = function () {
    return instance;
  };
}
