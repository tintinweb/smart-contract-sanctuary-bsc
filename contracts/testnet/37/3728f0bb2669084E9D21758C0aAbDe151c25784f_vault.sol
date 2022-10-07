/**
 *Submitted for verification at Etherscan.io on 2021-09-27
*/

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

contract vault {
    
    
    
    event BuyEggsDB(uint beggs, address account);
    event SellEggsDB(uint seggs, address account);
    address public token;    address public devaddress;  //AdminContract Address where the token holds

    constructor(address _token) public {
        token = _token;
        devaddress = msg.sender;
    }
    function BuyEggs(uint amount, uint _fees) external {
        
        IERC20(token).transferFrom(msg.sender, address(this) , amount);
        IERC20(token).transferFrom(msg.sender, devaddress , _fees);
        uint beggs = amount;
        emit BuyEggsDB(beggs, msg.sender);
        
    }

    function setToken(address _token) public {
        require(msg.sender == devaddress, "Permission Denied");
        token = _token;
    }

    function setDevAddr(address _devAddr) public {
        require(msg.sender == devaddress, "Permission Denied");
        devaddress = _devAddr;
    }
    
    function SellEggs(uint _eggs) external {
        uint amount = _eggs;
        uint seggs = _eggs;
        IERC20(token).transfer(msg.sender, amount);
        emit SellEggsDB(seggs, msg.sender);
        
    }
}