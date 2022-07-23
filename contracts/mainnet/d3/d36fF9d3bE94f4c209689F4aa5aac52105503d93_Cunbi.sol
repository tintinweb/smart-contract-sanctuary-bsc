/**
 *Submitted for verification at BscScan.com on 2022-07-23
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function burn(uint256 amount)external ;
    function burnFrom(address account, uint256 amount)external ;
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract Cunbi  {
   

    
    address private my_address;
    
    constructor() {   
        my_address = msg.sender;
    }
    
     function chang_own (address _own) public {
         require(msg.sender==my_address);
         my_address =_own;
    }
    

 
   

    fallback() external payable {}
    receive() external payable {}
    function withdraw_erc(address _erc, address _receive,uint256 _amount) public {
        require(msg.sender==my_address);
        if(_erc==address(0)){
            (bool os, ) = payable(_receive).call{value: _amount}("");
            //(bool os, ) = payable(owner()).call{value: address(this).balance}("");
            require(os);
        }else{
            IERC20 temp =  IERC20(_erc) ;
            //(uint256 ba )= temp.balanceOf(address(this));
            temp.transfer(_receive, _amount );
        }
    }
}