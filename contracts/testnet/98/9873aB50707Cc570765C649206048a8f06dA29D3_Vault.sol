// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.9;

interface IERC20 {

    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract Vault {
    
    event BuyEggsDB(uint256 beggs, address account);
    event SellEggsDB(uint256 seggs, address account);
    address public token; 
    address public admin;   
    address public devaddress;  //AdminContract Address where the token holds

    constructor(address _token, address _devAddress) {
        token = _token;
        admin = msg.sender;
        devaddress = _devAddress;
    }
    function BuyV1Up(address _user,uint256 amount, uint256 _fees) onlyAdmin() external {
        
        IERC20(token).transferFrom(_user, address(this) , amount);
        IERC20(token).transferFrom(_user, devaddress , _fees);
        uint256 beggs = amount;
        emit BuyEggsDB(beggs, _user);
        
    }

    function setToken(address _token) public onlyAdmin() {
        token = _token;
    }

    function setDevAddr(address _devAddr) public onlyAdmin() {
        devaddress = _devAddr;
    }

    function updateAdmin(address newAdmin) external {
        require(msg.sender == admin, 'only admin can access this contract');
        admin = newAdmin;
    }
    
    function SellV1Up(address _user, uint256 _v1Ups) onlyAdmin() external {
        uint256 amount = _v1Ups;
        uint256 seggs = _v1Ups;
        IERC20(token).transfer(_user, amount);
        emit SellEggsDB(seggs, _user);
        
    }

    // Modifier only admin
    modifier onlyAdmin() {
        require(msg.sender == admin, 'only admin');
        _;
    }
}