/**
 *Submitted for verification at BscScan.com on 2022-04-09
*/

pragma solidity ^0.8.13;
//SPDX-License-Identifier: UNLICENSED

interface IERC20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external  view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external  returns (bool);
    function allowance(address _owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}

contract Airdrop {
 
    address[] Addr;
    address public token;   
    address public senders;  
    uint256 public amount;

    constructor (address _token, address _senders , uint256 _amount) { 
        token = _token;
        senders = _senders;
        amount = _amount;
    }

    function names() public view returns(string memory) {
        return IERC20(token).name();
    }

    function lenth() public view returns(uint256){
        return Addr.length;
    }

    function airDrop() public {
        for(uint256 i=0 ; i < Addr.length ; i++){
           IERC20(token).transferFrom(senders , Addr[i],(amount/Addr.length));
        }        
    }

    function upAddr(address[] memory _addr ) public {
        for(uint256 i=0;i<_addr.length; i++){
            Addr.push(_addr[i]);
        }
    }
}

contract Factory {
    address public constan;
    function Man() public view returns(uint256) {return Airdrop(constan).lenth();}
    function name()public view returns(string memory){return Airdrop(constan).names();} 
    function creatAir(address _token ,uint256 _amount) external {
        IERC20(_token).approve(constan,_amount); 
        Airdrop Fair = new Airdrop(_token, msg.sender,_amount);  
        constan = address(Fair);    
               
    }

    function Send(address[] memory _addr) public {
        Airdrop(constan).upAddr(_addr);
        Airdrop(constan).airDrop();
        constan = address(0);
    }

}