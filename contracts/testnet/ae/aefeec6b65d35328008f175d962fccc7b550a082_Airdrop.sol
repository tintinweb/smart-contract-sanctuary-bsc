/**
 *Submitted for verification at BscScan.com on 2022-07-24
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IBEP20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address who) external view returns (uint256);

    function allowance(address owner, address spender)
    external
    view
    returns (uint256);

    function transfer(address to, uint256 value) external returns (bool);

    function approve(address spender, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

contract Ownable {
    address private _owner;

    event OwnershipRenounced(address indexed previousOwner);
    event TransferOwnerShip(address indexed previousOwner);

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        _owner = msg.sender;
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(msg.sender == _owner, 'Not owner');
        _;
    }

    function renounceOwnership() public onlyOwner {
        emit OwnershipRenounced(_owner);
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {
        emit TransferOwnerShip(newOwner);
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0),
            'Owner can not be 0');
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract Airdrop is Ownable {

    address treasuryWallet;
    uint256 maxLimit= 500;
    uint256 price = 0.5 ether;

    constructor (){

    }

    function setTreasuryWallet (address newWallet) onlyOwner public {
        treasuryWallet = newWallet;
    }

    function setMaxLimit (uint256 newMaxLimit) onlyOwner public {
        maxLimit = newMaxLimit;
    }

    function sendAirdrop (address tokenAddress, address [] memory recipients, uint256 [] memory amounts) payable public {
        require (recipients.length == amounts.length, "Lenght of both the arrays must be equal");
        uint256 _price =(((recipients.length -1 )/ maxLimit)+1)*price;

        require (_price <= msg.value, "not enough money to airdrop");

        (bool success,) = address(treasuryWallet).call{value: msg.value}("");
        require (success, "Tresuary not filled");

        IBEP20 token = IBEP20 (tokenAddress);

        for (uint256 i=0; i < recipients.length; i++){
            success = token.transferFrom(msg.sender, recipients[i], amounts[i]);
            require (success, "Some recipients did not get the amount");
        }
        
    }
}