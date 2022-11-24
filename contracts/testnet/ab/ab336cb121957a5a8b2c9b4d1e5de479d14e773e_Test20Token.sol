/**
 *Submitted for verification at BscScan.com on 2022-11-24
*/

// SPDX-License-Identifier: MIT
pragma solidity >=0.4.23 <0.6.0;

interface IBEP20 {  
    
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address _owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
  
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract Ownable {
    address public owner;

    event onOwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    constructor() public {
        owner = msg.sender;
    }
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
    function transferOwnership(address _newOwner) public onlyOwner {
        require(_newOwner != address(0));
        emit onOwnershipTransferred(owner, _newOwner);
        owner = _newOwner;
    }
}

contract Test20Token is Ownable {        
   
    IBEP20 public busd;     
    address private _wallet;
      
     event Deposit(address user, uint256 amount);
   

    constructor(address wallet,address _busdContract) public {        
               
        _wallet = wallet;
         busd =IBEP20(_busdContract);
    }
    
    function buyTokens(uint256 _busd) external {
        busd.allowance(address(this),msg.sender);		
		_deposit(_busd);		
        emit Deposit(msg.sender,_busd);
    }

    function _deposit(uint256 _amount) private {        
            busd.transferFrom(msg.sender, address(this),_amount);   
			busd.approve(msg.sender,_amount);  
			
    }       
   
}