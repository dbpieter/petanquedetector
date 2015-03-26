import numpy as np
import argparse
import cv2

#should be clientside
def resizeImage(image):
	W = 1000.
	height,width,depth = image.shape
	scaleFactor = W/width
	newX,newY = image.shape[1]*scaleFactor, image.shape[0]*scaleFactor
	image = cv2.resize(image,(int(newX),int(newY)))
	return image

def getClosestPairByRadius(circles):
	minRadius = 10000
	closestPair = []
	tr1 = -1
	tr2 = -1
	for i in range(len(circles)):
	   	for j in range(i + 1, len(circles)):
			radius = abs(circles[i][2]-circles[j][2])
			if radius < minRadius:
				minRadius = radius
				closestPair = [circles[i],circles[j]]
				tr1 = i
				tr2 = j
	# if(tr2 > tr1): #sneaky indeces
	# 	circles.pop(tr2)
	# 	circles.pop(tr1) 
	# else:
	# 	circles.pop(tr1)
	# 	circles.pop(tr2)
	return closestPair

def findOthers(closestPair,circles):
 	averageRadiusOfPair = (closestPair[0][2] + closestPair[1][2])/2
 	treshold = 15 #if radius not within 15px bye bye
 	invalid = []
 	#print(averageRadiusOfPair)
 	for i in reversed(xrange(len(circles))):
 		diff = abs(circles[i][2] - averageRadiusOfPair)
 		if diff > treshold:
 			invalid.append(circles[i])
 			invalid.append(circles[i])
 			circles.pop(i)
 	return invalid

def findWinner(smallx,smally,circles):
 	winner = None
 	minSquareDist = 1000000
 	toRemove = -5
 	for k in range(len(circles)):
 		x = circles[k][0]
 		y = circles[k][1]
		print(x)
		print(y)
 		dist = (smallx - x)**2 + (smally - y)**2
		print(dist)
 		if dist < minSquareDist:
 			minSquareDist = dist
 			toRemove = k
	print(circles[toRemove])
 	winner = circles[toRemove]
 	circles.pop(toRemove)
 	return winner


# construct the argument parser and parse the arguments
ap = argparse.ArgumentParser()
ap.add_argument("-i", "--image", required = True, help = "Path to the image")
ap.add_argument("-o", "--output", required = False, help = "Output image location")
ap.add_argument("-x","--smallxcoord",required = False, help ="the x coordinate of the small ball")
ap.add_argument("-y","--smallycoord",required = False, help ="the y coordinate of the small ball")

args = vars(ap.parse_args())

image = cv2.imread(args["image"])
#image = resizeImage(image)
height,width,depth = image.shape
output = image.copy()
image = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)



halfheight = height/2;
halfwidth = width/2;
print(height)
print(width)

clahe = cv2.createCLAHE(clipLimit=2.0, tileGridSize=(8,8))
cl1 = clahe.apply(image)

cl1 = cv2.medianBlur(cl1,5)

# detect circles
circles = cv2.HoughCircles(cl1, cv2.cv.CV_HOUGH_GRADIENT, 1.8, 75)

# ensure at least some circles were found
if circles is not None:
	#convert from numpy array to normal list
	mycircles = circles[0].tolist();
	cst = getClosestPairByRadius(mycircles) #also deletes the pairs from the list
	cst = np.round(cst).astype("int")
	#print(cst)

	invalidz = findOthers(cst,mycircles) 	#also deletes the invalid ones
	invalidz = np.round(invalidz).astype("int")


	winner = findWinner(int(halfwidth),int(halfheight),mycircles)
	mycircles = np.round(mycircles).astype("int")

	winner = np.round(winner).astype("int")

	for c in range(len(mycircles)):
		x = mycircles[c][0]
		y = mycircles[c][1]
		r = mycircles[c][2]
		cv2.circle(output, (x, y), r, (255, 0, 0), 4)
		cv2.rectangle(output, (x - 5, y - 5), (x + 5, y + 5), (0, 128, 255), -1)

	# for c in range(len(cst)):
	# 	x = cst[c][0]
	# 	y = cst[c][1]
	# 	r = cst[c][2]
	# 	cv2.circle(output, (x, y), r, (255, 255, 0), 4)
	# 	cv2.rectangle(output, (x - 5, y - 5), (x + 5, y + 5), (0, 128, 255), -1)

	for c in range(len(invalidz)):
		x = invalidz[c][0]
		y = invalidz[c][1]
		r = invalidz[c][2]
		cv2.circle(output, (x, y), r, (0, 0, 255), 4)
		cv2.rectangle(output, (x - 5, y - 5), (x + 5, y + 5), (0, 128, 255), -1)

	#draw winner ball
	cv2.circle(output, (winner[0], winner[1]), winner[2], (0, 255, 0), 4)

	#cv2.imwrite(args["output"],output)
	# show the output image
	cv2.imshow("output", output)

cv2.imshow("cl1",cl1)
cv2.waitKey(0)