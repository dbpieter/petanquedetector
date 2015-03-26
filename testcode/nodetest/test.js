var cv = require('opencv');

// cv.readImage('./files/mona.png', function(err, im) {
//   if (err) throw err;
//   if (im.width() < 1 || im.height() < 1) throw new Error('Image has no size');

//   img_hsv = im.copy();
//   img_gray = im.copy();

//   img_hsv.convertHSVscale();
//   img_gray.convertGrayscale();

//   im.save('./tmp/nor.png');
//   img_hsv.save('./tmp/hsv.png');
//   img_gray.save('./tmp/gray.png');

//   img_crop = im.crop(50,50,250,250);
//   img_crop.save('./tmp/crop.png');

//   console.log('Image saved to ./tmp/{crop|nor|hsv|gray}.png');

// });

var win = new cv.NamedWindow('Video',1);
cv.readImage('./files/ballz4lrg.jpg', function (err, im){
  if (err) throw err;
  if (im.width() < 1 || im.height() < 1) throw new Error('Image has no size');

  var img_gray = im.copy();
  img_gray.convertGrayscale();
  img_gray.applyCLAHE(2.0);
  img_gray.medianBlur(5);

  var circles = img_gray.houghCircles(1.8,75);
  //console.log(circles);

  for(var i = 0; i < circles.length; i++){
  	var c = circles[i];
  	//img_gray.ellipse(c[0],c[1],c[2],c[2],{thickness: 10});
  	//im.ellipse({"center": {"x":c[0],"y":c[1]},"axes": {"width":c[2],"height":c[2]},"thickness":2,"color":[0,255,255]})
  	drawCircle(im,c,[0,255,255]);
  }

  var closestPair = getClosestPairByRadius(circles);
  drawCircle(im,closestPair.first,[255,255,0]);
  drawCircle(im,closestPair.second,[255,255,0]);

  var others = findOthers(closestPair,circles);
  for(var i = 0; i < others.length; i++){
  	drawCircle(im,others[i],[255,0,255]);
  }

  win.show(im);
  win.blockingWaitKey();

});


function findOthers(closestPair,circles){
	var actualMatches = circles.slice(); //make copy

	var index = actualMatches.indexOf(closestPair.first);
	if(i > -1) actualMatches.splice(index,1);
	index = actualMatches.indexOf(closestPair.second);
	if(i > -1) actualMatches.splice(index,1);

	var averageRadiusOfPair = (closestPair.first[2] + closestPair.second[2])/2;
	var treshold = 15; //pixels
	for(var i = actualMatches.length-1; i >=  0; i--){
		var diff = Math.abs(actualMatches[i][2] - averageRadiusOfPair);
		//console.log(diff);
		if(diff > treshold){
			
			actualMatches.splice(i,1);
		}
		else{
			console.log(diff);
		}
	}
	return actualMatches;
}

function drawCircle(image,circle,color){
	image.ellipse({"center": {"x":circle[0],"y":circle[1]},"axes": {"width":circle[2],"height":circle[2]},"thickness":2,"color":color});
}

function getClosestPairByRadius(circles) {
	var minRadius = Number.MAX_VALUE;
	var closestPair = {};
	for(var i = 0; i < circles.length; i++){
		for(var j = i + 1; i < circles.length; i++){
			var radiusDiff = Math.abs(circles[i][2]-circles[j][i]);
			if(radiusDiff < minRadius){
				minRadius = radiusDiff;
				closestPair = {first: circles[i], second: circles[j]};
			}
		}
	}
	return closestPair;
}
