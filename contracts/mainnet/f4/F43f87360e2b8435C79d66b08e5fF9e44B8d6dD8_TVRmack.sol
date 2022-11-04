/**
 *Submitted for verification at BscScan.com on 2022-11-04
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface  TVR{
    function _timeermake() external;
    function getbnb2(address payable to,uint ao) external;

}

contract TVRmack {

    address public tvrcon;  
    address payable public sender; 
    uint public moy =1e17;

    constructor(address sen){ 
        tvrcon = sen; 
        sender = payable(msg.sender);
    }

    event Receive(address ad,uint val);
    receive() external payable{
        emit Receive(msg.sender,msg.value);
    }

   modifier issender(){
       require( sender == msg.sender, "no sder");
        _;
    }

    function  getbalance() public view returns(uint){
      return  address(this).balance;                    
    }

    function set_moy(uint mo)public issender{
        moy =mo;
    }
    function gogo()public{
        TVR macc = TVR(tvrcon);
        macc._timeermake();
        set_tanf();
    }
    
    function set_tanf()private {
        TVR macc = TVR(tvrcon);
        uint nower = getbalance();
        if(nower < moy){
           macc.getbnb2(payable(this),moy-nower);
        }  
    }

}