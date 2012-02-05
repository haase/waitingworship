// -*- Mode: javascript; character-encoding: utf-8; -*-

var ww_speaking=false;
var ww_update=30000;

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
    body.onblur=leave;
    if (body.className==='hearing')
	setTimeout(function(){body.className='listening';},
		   30000);
    ww_timeout=setTimeout(updatefn,ww_update);}

var ww_timeout=false;

function updatefn(){
    if ((ww_speaking)||(!(navigator.onLine))) {
	return;}
    var req=new XMLHttpRequest();
    var uri="https://waitingworship.org/update?SPACE="+ww_space+
	"&SYNC="+ww_sync;
    req.open("GET",uri,true);
    req.withCredentials=true;
    req.onreadystatechange=function () {
	if ((req.readyState == 4) && (req.status == 200)) {
	    var response=JSON.parse(req.responseText);
	    // console.log("Update response=%o",response);
	    ww_sync=response.sync;
	    var ministers=response.ministers;
	    if (ministers!==ww_ministers) setMinisters(ministers);
	    if (response.words) setMessage(response);
	    ww_timeout=setTimeout(updatefn,ww_update);}};
    req.send(null);}

function setMinisters(ministers){
    var div=document.createElement("div");
    div.id="MINISTERLIST";
    var i=ministers.length-1;
    while (i>=0) {
	var minister=ministers[i--];
	var mindiv=document.createElement("div");
	mindiv.innerHTML=minister;
	div.appendChild(mindiv);}
    var cur=document.getElementById("MINISTERLIST");
    cur.parentNode.replaceChild(div,cur);}

function setMessage(message){
    var words=document.getElementById("WORDS");
    words.innerHTML=message.words;
    var minister=document.getElementById("MINISTER");
    minister.innerHTML=message.minister;
    document.body.className='hearing';
    setTimeout(function(){body.className='listening';},
	       30000);}



