//****************************************************************************
//Copyright (C) 2005 Adobe Systems, Inc. All Rights Reserved.
//The following is Sample Code and is subject to all restrictions on
//such code as contained in the End User License Agreement accompanying
//this product.
//****************************************************************************

/**
 * MobileSharedObject, Version 1
 * manages Shared Object in a Flash Lite 2 application
 */

class MobileSharedObject {

	//---------------------------------------------- Properties
	private var Prefs:SharedObject;
	private var appName:String;
	private var mySORef:SharedObject;
	private var loaded:Boolean;
	private var readID:Number;
	private var writeID:Number;
	private var textPath:Object;

	//---------------------------------------------- Methods

	/**
	   * constructor method
	   * 
	   */
	public function MobileSharedObject(path:String) {
		setDebug(path);// set the path to the textfield used to show messages
		if (System.capabilities.hasSharedObjects) {// check to make sure handset supports Shared Objects
			SharedObject.addListener("Prefs",loadCompleteSO);// add a listener, because SO might not be immediately available
			Prefs = SharedObject.getLocal("Prefs");// get reference to the SO, or create
			Prefs.path = this;// set local property marking namespace
			this.appName = "mySO";// set local var with appName string
		} else {
			debug("Saving games is not supported on this device, please cancel and choose a different option");// if the device doesn't support Shared Objects, alert the user
		}
	}
	/**
	   * loadCompleteSO method - used as a listener to the Shared Object object, fired once getLocal returns a reference
	   * 
	   * @param mySO- the Shared Object reference returned from getLocal()
	   */
	private function loadCompleteSO(mySO:SharedObject):Void {
		if (mySO.getSize() == 0) {// if the SO is new

			mySO.path.debug("Writing Game data");
			mySO.flush();// immediately write the timestamp to the SO
		} else {// the SO already exists
			emptySO();
			mySO.path.debug("Removing previous Game data");
			mySO.flush();
			mySO.path.debug("Writing game data");

		}
		mySO.path.setMarker();
	}
	/**
	   * setMarker method - used to set a marker alerting that loadCompleteSO has fired and is finished
	   * 
	   */
	private function setMarker():Void {
		loaded = true;
	}
	/**
	   * getMarker method - used by the other methods to see if loadCompleteSO has fired and is finished
	   * 
	   */
	private function getMarker():Boolean {
		return loaded;
	}
	/**
	   * readFromSO method - used to read values from the SO
	   * 
	   * @param name- optional param, represents the name of single var to retrieve from SO
	   * @return String- representing var value(s) from SO
	   */
	private function readFromSO(name:String):String {
		if (getMarker() == true) {// check to see if listener has fired
			clearInterval(readID);// clear the interval if there was one
			var value:String = "";// placeholder for the value from SO
			if (name) {// if just looking for a single var
				value = Prefs.data[name];// get value
			} else {// looking for all vars from SO
				for (var idx in Prefs.data) {// loop
					value += idx + "=" + Prefs.data[idx] + "\n";// retrieve value
				}
			}
			if (Prefs.data.firstTime == undefined) {
				debug("data in your SO:");
				debug(value);// immediately write to textfield
			}
			return value;
		} else if (readID == undefined) {// if loadCompleteSO hasn't fired, set interval
			readID = setInterval(this, "readFromSO", 12, name);// set an interval to call again
		}
	}
	/**
	   * writeData method - used to write a name/value pair to the SO
	   * 
	   * @param name- the name of the name/value pair
	   * @param value- the value of the name/value pair
	   * @return Boolean- whether flush was successful
	   */
	private function writeData(len:String, curword:String, arrcurr:String, curl:String, inform:String, triedl:String):Boolean {
		
		if (getMarker() == true) {// check to see if listener has fired
			clearInterval(writeID);// clear the interval if there was one
			Prefs.data["lgt"] = len;// set the name/value in SO
			Prefs.data["cword"] = curword;// set the name/value in SO
			Prefs.data["arcur"] = arrcurr;// set the name/value in SO
			Prefs.data["curlett"] = curl;
			Prefs.data["informa"] = inform;
			Prefs.data["triedlt"] = triedl;
			var status = Prefs.flush();// write to Shared Object immediately
			
			if (status == true) {// check status of flush()
				return true;// flush() was successful
			} else if (status == "pending") {// if flush() is pending
				// more space needed
				// onStatus fired
				return false;// return false and check the onStatus method
			} else if (status == false) {// if flush() failed
				return false;
			}
		} else if (writeID == undefined) {// if loadCompleteSO hasn't fired, set interval
			writeID = setInterval(this, "writeData", 12, len, curword, arrcurr, curl, inform, triedl);// set an interval to call again
		}
	}
	private function writeHScore(score:String):Boolean {
		
		if (getMarker() == true) {// check to see if listener has fired
			clearInterval(writeID);// clear the interval if there was one
			Prefs.data["sc"] = score;// set the name/value in SO
			
			var status = Prefs.flush();// write to Shared Object immediately
			
			if (status == true) {// check status of flush()
				return true;// flush() was successful
			} else if (status == "pending") {// if flush() is pending
				// more space needed
				// onStatus fired
				return false;// return false and check the onStatus method
			} else if (status == false) {// if flush() failed
				return false;
			}
		} else if (writeID == undefined) {// if loadCompleteSO hasn't fired, set interval
			writeID = setInterval(this, "writeHScore", 12, score);// set an interval to call again
		}
	}
	/**
	   * onStatus method - fired from a flush() return equal to pending, could be a result of more storage space needed
	   * 
	   * @return Boolean- whether flush() ends in success or failure
	   */
	private function onStatus(infoObject:Object):Boolean {// onStatus is fired when flush() returns "pending"
		if (infoObject.code == "SharedObject.Flush.Success") {// if flush() ends in success
			return true;
		} else if (infoObject.code == "SharedObject.Flush.Failed") {// if flush() ends in failure
			return false;
		}
	}
	/**
	   * emptySO method - used to empty the SO, but not delete it from the disk
	   * 
	   */
	private function emptySO():Void {
		for (var idx in Prefs.data) {
			Prefs.data[idx] = null;
			delete Prefs.data[idx];
		}
	}
	/**
	   * removeSO method - used to empty and then delete SO from the disk
	   * 
	   */
	private function removeSO():Void {
		Prefs.clear();
	}
	/**
	   * getSize method - used to retrieve the current size of the SO
	   *
	   * @return Number- number of kb of SO 
	   */
	private function getSize():Number {
		return Prefs.getSize();
	}
	/**
	   * setDebug method - used to set the path to the textfield to write messages to
	   * 
	   * @param name - textfield path
	   */
	private function setDebug(path:String):Void {
		this.textPath = path;
	}
	/**
	   * debug method - used to write strings to a textfield
	   * 
	   * @param message - the string to write to the textfield
	   */
	private function debug(message:String):Void {
		eval(this.textPath).text += message + "\n";
	}
}