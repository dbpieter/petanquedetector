var express = require('express')
var multer = require('multer')
var app = express()
var util = require('util')
var exec = require('child_process').exec

app.use(
	multer({
		dest: './uploads/',
	}))

app.get('/',function(req,res){
	res.send('it\'s alive !')
})

app.post('/upload/', function(req,res){
	if(req.files){
		console.log(req.files)
		if(!req.files.image){
			res.status(204) 
			res.send('no image uploaded')
		} else{
			var ok = doIt(req.files.image)
			if(!ok){
				res.send('could not detect petanque ballz')
			}
			else{
				res.send(req.files.name)
			}
		}
	}
})

var doIt = function(image){
	console.log('lalalas')
	exec('./detectballz.sh --image ./uploads/'+image.name+' --output ./processeduploads/'+image.name +"-x 0 -y 0",
		function(error,stdout,stderr){
			console.log('stdout:'+stdout)
			console.log('stderr:'+stderr)
			if(error !== null){
				console.log('exec error: '+error)
				return false;
			}
			return true;
		})
}

var server = app.listen(80, function(){
	console.log('server listening on port '+server.address().port)
})