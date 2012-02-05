// -*- Mode: javascript; character-encoding: utf-8; -*-

var ww_speaking=false;

function speak() {
    document.body.className='speaking';
    ww_speaking=true;
    document.getElementById('MESSAGETEXT').focus();}

function leave() {
    window.location="/leave?SPACE="+ww_space+"&NAME="+
	encodeURIComponent(ww_name);}

function hear() {
    document.body.className='hearing';}

function setupWaiting(){
    var body=document.body;
    // body.onblur=leave;
    if (body.className==='hearing')
	setTimeout(function(){body.className='listening';},
		   30000);}


