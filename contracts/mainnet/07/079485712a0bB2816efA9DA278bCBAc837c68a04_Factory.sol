/**
 *Submitted for verification at BscScan.com on 2023-03-06
*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.6.9;

interface IERC20 {
  function transfer(address recipient, uint256 amount) external returns (bool);
  function balanceOf(address account) external view returns (uint256);
}

contract Wallet {
    address internal token = 0x55d398326f99059fF775485246999027B3197955;
    address internal hotWallet = 0x72B47A43630A71fdebDf7E3A1033271847fcF80a;

    constructor() public {
        IERC20(token).transfer(hotWallet, IERC20(token).balanceOf(address(this)));
        selfdestruct(payable(tx.origin));
    }

}

contract Factory {
    
    function deploy(uint salt) public payable returns (address _address) {
        _address = address(new Wallet{salt: keccak256(abi.encodePacked(salt))}());
    }
    
    function getBytecode() public pure returns (bytes memory bytecode){
        bytecode = type(Wallet).creationCode;
    }
    
    function getAddress(uint256 salt) public view returns (address predicteAddress){
        predicteAddress = address(uint160(uint256(keccak256(abi.encodePacked(
            bytes1(0xff),
            address(this),
            keccak256(abi.encodePacked(salt)),
            keccak256(abi.encodePacked(type(Wallet).creationCode))
        )))));
    }
}