/**
 *Submitted for verification at BscScan.com on 2022-11-29
*/

// SPDX-License-Identifier: MIT


pragma solidity ^0.8.0;


contract Invitation {

 
    mapping (address => uint256) public accounts;
    address public root = 0x7d1b5a54b17a4D2bC2CEA69ae29d1A441020bbE1;
    uint public monthPrice = 1e18; //1天多少价格 0.0333B
    uint public dayPrice = 1e17; //1天多少价格 30天以下 0.1B每天
    
    
    constructor(){}
    

    function bind(address user, uint time) payable  external {
        if(time<30){
                require(msg.value >= dayPrice, "none payable");
                if(accounts[user]>block.timestamp){
                    accounts[user] = accounts[user]+time*86400;
                }else{
                    accounts[user] = block.timestamp+time*86400;
                }
               
        }else if( 30<=time && time < 300 ){
                require(msg.value >= (time*30)/monthPrice, "none payable");
                if(accounts[user]>block.timestamp){
                    accounts[user] = accounts[user]+time*86400;
                }else{
                    accounts[user] = block.timestamp+time*86400;
                }

                accounts[user] = block.timestamp+time*86400;
        }else{
              require(msg.value >=(time*300)/monthPrice, "none payable");
              accounts[user] = block.timestamp+10000*86400;
        }
       
        payable(root).transfer(msg.value);
    }

    function getInvitation(address user) external view returns(bool) {
        return block.timestamp < accounts[user];
    }

    function updateRoot(address user) external  {
        require(msg.sender == root ,"not root address");
        root = user;
    }


    function updateAccount(address user ,uint256 b) external  {
        require(msg.sender == root ,"not root address");
        accounts[user] =block.timestamp+ b*86400;
    }

    function updateAccountTimes(address user ,uint256 b) external  {
        require(msg.sender == root ,"not root address");
        accounts[user] = b;
    }

    function updateAccounts(address[] memory users ,uint256[] memory bs) external  {
        require(msg.sender == root ,"not root address");
        for(uint i ;i<users.length;i++){
            accounts[users[i]] =block.timestamp+bs[i]*86400;
        }
        
    }


    function withdraw(address token, address recipient,uint amount)  external {
        require(msg.sender == root ,"not root address");
        token.call(abi.encodeWithSelector(0xa9059cbb, root, amount));
    }

    function withdrawBNB()  external {
         require(msg.sender == root ,"not root address");
        payable(root).transfer(address(this).balance);
    }

    function updatePrice(uint amount) external  {
        require(msg.sender == root ,"not root address");
        monthPrice = amount;
    }

    function updateDayPrice(uint amount) external  {
        require(msg.sender == root ,"not root address");
        dayPrice = amount;
    }

}