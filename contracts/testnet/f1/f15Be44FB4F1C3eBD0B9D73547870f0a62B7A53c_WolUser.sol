/**
 *Submitted for verification at BscScan.com on 2022-03-11
*/

// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.5.0;
contract WolUser {

    uint public totalSupply = 0;
    string public name = "wolUser";
    string public symbol = "WU";
    uint public decimals = 8;
    address owner;

    mapping(address=>User) public users;         //用户数据

    struct User {
        address oneAddress;
        uint isUsed;
    }

    event UserRegister(address indexed userAddress , address indexed parentAddress);

    constructor(){
        owner = msg.sender;
    }

    modifier checkAuth() {
        uint8 isauth= 0;
        if(msg.sender == owner) {
            isauth = 1;
        } 
        require(isauth == 1 ,'invalid operation');
        _;
    } 

    function userRegister(address _oneAddress) public {      
        require(!isUserExists(msg.sender),"User already register");         
        _userRegister(msg.sender,_oneAddress);
    } 

    function _userRegister(address _userAddress,address _oneAddress) internal {           
        require(isUserExists(_oneAddress) || _oneAddress == address(0x0),"referrer not register");        
        if(_oneAddress == owner) {
            _oneAddress = address(0x0);
        }
        if(!isUserExists(_userAddress)) {
            users[_userAddress] = User(_oneAddress,1);
            emit UserRegister(_userAddress,_oneAddress);    
        }     
    }

    function authUserRegister(address _userAddress,address _oneAddress) public {
        _userRegister(_userAddress,_oneAddress);
    }

    function isUserExists(address _userAddress) public view returns(bool){       
        return (users[_userAddress].isUsed == 1);
    }

    // 获取上级
    function getUp(address _address,uint _type) public view returns (address){
        if(isUserExists(_address)) {
            if(isUserExists(users[_address].oneAddress)) {
                if(_type == 1) {
                    return users[_address].oneAddress;
                }
                if(isUserExists(users[users[_address].oneAddress].oneAddress)) {
                    return users[users[_address].oneAddress].oneAddress;
                }                
            }   
            return address(0x0);        
        } else{
            return address(0x0);
        }        
    } 

}