
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
////    if (!window.WebKitMutationObserver) {    //ios6 有，ios5没有
////      var timer;
////      document.addEventListener('DOMAttrModified', function(e) {
////        clearTimeout(timer);
////        timer = setTimeout(function () {
////          //callback scroll view
////
////          fire('DOMSubtreeModified');
////        }, 50);
////      }, false);
////    }

function insertNodeAtCurrentRange(node) {
    var sel = window.getSelection();
    var range = sel.getRangeAt(0);
    range.deleteContents();
    range.insertNode(node);
    sel.removeAllRanges();
    range = range.cloneRange();
    range.selectNode(node);
    range.collapse(false);
    sel.addRange(range);
    return range;
}

function insertSingleImage(src, width, height) {
  var scale = 1;
	var kMaxWidth = 384.0; //(768 / 2)
  if (width > kMaxWidth) {
    scale = kMaxWidth / width;
  }
  
	var imgNode = document.createElement("IMG");
	imgNode.setAttribute("src", src);
	imgNode.setAttribute("width", width * scale);
	imgNode.setAttribute("height", height * scale);
	insertNodeAtCurrentRange(imgNode);
};

function getCaretPosition() {
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
    
    return offsetY;
  }
  catch (e) {
    alert(e);
  }
};

function moveImageAtTo(x, y, newX, newY) {
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
  
  insertNodeAtCurrentRange(element);
};

//box:  top, right, bottom, left, width, height
function clientRectOfElementFromPoint(x, y) {
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

