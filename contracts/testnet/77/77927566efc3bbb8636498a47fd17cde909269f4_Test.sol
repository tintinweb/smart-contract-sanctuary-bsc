/**
 *Submitted for verification at BscScan.com on 2022-08-11
*/

// SPDX-License-Identifier: Unlicensed

/*

GEN LOCK - Auto Liquidity Locker

*/

pragma solidity 0.8.15;






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
    function token0() external view returns (address); 
    function token1() external view returns (address); 
    function owner() external view returns (address); 
    function name() external view returns (string calldata); 
    function symbol() external view returns (string calldata);

}







contract Test is Ownable  {








    // Get the owner wallet from the CA
    function get_Token1 (address PanCake) external view returns (address){
        return BEP20(PanCake).token0();
    }

    // Get the owner wallet from the CA
    function get_Token2 (address PanCake) external view returns (address){
        return BEP20(PanCake).token1();
    }




    // Get the owner wallet from the CA
    function get_Owner (address Token_CA) external view returns (address){
        return BEP20(Token_CA).owner();
    }
    // Get the token name from the CA
    function get_Name (address Token_CA) external view returns (string memory){
        return BEP20(Token_CA).name();
    }
    // Get the token name from the CA
    function get_Symbol (address Token_CA) external view returns (string memory){
        return BEP20(Token_CA).symbol();
    }


     receive() external payable {}

}