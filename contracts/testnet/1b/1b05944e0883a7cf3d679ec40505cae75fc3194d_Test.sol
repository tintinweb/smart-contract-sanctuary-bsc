/**
 *Submitted for verification at BscScan.com on 2022-08-11
*/

// SPDX-License-Identifier: Unlicensed

/*

GEN LOCK - Auto Liquidity Locker

*/

pragma solidity 0.8.15;



interface IERC20 {
    
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function getOwner(address account) external view returns (address);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

}




abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; 
        return msg.data;
    }
}


abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    constructor () {
        _owner = 0xD05895EDF847e1712721Cc9e0427Aa26289A6Bc5;
        emit OwnershipTransferred(address(0), _owner);
    }
    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }




    
}




    
    
   
    


interface BEP20 {
    function owner() external view returns (address); //doesn't work
    function name() external view returns (string calldata); //works
    function ownerOf(uint256 tokenId) external view returns (address); //works
}

contract Test is Ownable  {
    //doesn't work
    function getOwner1 (address Token_CA) external view returns (address){
        return BEP20(Token_CA).owner();
    }
    //works
    function getOwner2 (address Token_CA) external view returns (string memory){
        return BEP20(Token_CA).name();
    }


     receive() external payable {}

}