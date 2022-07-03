/**
 *Submitted for verification at BscScan.com on 2022-07-03
*/

/**
 *Submitted for verification at BscScan.com on 2022-07-03
*/

/**
 *Submitted for verification at bscscan.com on 2022-07-03
*/

/*! SPDX-License-Identifier: MIT License */

pragma solidity 0.6.8;

interface Imsvpbnbfinance {
    function drawPool() external;
    function pool_last_draw() view external returns(uint40);
}

contract Ownable {
    address payable private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() internal {
        _owner = msg.sender;

        emit OwnershipTransferred(address(0), msg.sender);
    }

    function owner() public view returns(address payable) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    function transferOwnership(address payable _new_owner) public onlyOwner {
        require(_new_owner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, _new_owner);
        _owner = _new_owner;
    }
}

contract ReOwner is Ownable {
    Imsvpbnbfinance public msvpbnbfinance;

    constructor() public {
        msvpbnbfinance = Imsvpbnbfinance(0x494657667dcB24f0FF7034D40B538a0204D5cA05);
    }

    receive() payable external {}

    function drawPool() external onlyOwner {
        require(msvpbnbfinance.pool_last_draw() + 1 days < block.timestamp); 

        msvpbnbfinance.drawPool();
    }

    function withdraw() external onlyOwner {
        owner().transfer(address(this).balance);
    }
}