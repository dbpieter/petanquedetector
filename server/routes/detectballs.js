var express = require('express');
var router = express.Router();
var app = require('../app');
var util = require('util')
var exec = require('child_process').exec

router.post('/upload/', function(req,res){
	if(req.files){
		console.log(req.files)
		if(!req.files.image){
			res.status(204).send('no image uploaded')
		} else{
			exec('./detectballz.sh --image ./uploads/'+req.files.image.name+' --output ./processeduploads/'+req.files.image.name +" -x 0 -y 0",
			function(error,stdout,stderr){
				console.log('stdout:'+stdout)
				console.log('stderr:'+stderr)
				if(error !== null){
					res.status(500).send(req.files.image.name)
					console.log('detect error :'+error)
				}
				else {
					res.send(req.files.image.name)
				}
			})
		}
	}
})

module.exports = router
