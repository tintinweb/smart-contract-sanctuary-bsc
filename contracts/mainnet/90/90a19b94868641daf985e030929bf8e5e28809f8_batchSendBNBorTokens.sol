/**
 *Submitted for verification at BscScan.com on 2022-08-03
*/

//SPDX-License-Identifier: MIT 
pragma solidity 0.8.4; 
 
interface IERC20 { 
 function totalSupply() external view returns (uint); 
 function balanceOf(address account) external view returns (uint); 
 function transfer(address recipient, uint amount) external returns (bool); 
 function allowance(address owner, address spender) external view returns (uint); 
 function approve(address spender, uint amount) external returns (bool); 
 function transferFrom(address sender, address recipient, uint amount) external returns (bool); 
 event Transfer(address indexed from, address indexed to, uint value); 
 event Approval(address indexed owner, address indexed spender, uint value); 
} 
 
contract batchSendBNBorTokens { 
 
    function depositBNBonMultiACC(address[] memory _addresses, uint _value) public payable { // require you to send the exact value of all summed transfers 
        require(msg.value == _addresses.length*_value, 'err0'); 
        for (uint i = 0; i < _addresses.length; i++) { 
            payable(_addresses[i]).transfer(_value); 
        } 
    } 
 
    function depositERC20onMultiACC(address[] memory _addresses, uint _value, address _token) public { 
        IERC20(_token).approve(address(this), _value*_addresses.length); 
        IERC20(_token).transferFrom(msg.sender, address(this), _value*_addresses.length); //Interact (Check - Effect - Interact) 
        for (uint i = 0; i < _addresses.length; i++) { 
            IERC20(_token).transfer(_addresses[i], _value); 
        } 
    } 
}