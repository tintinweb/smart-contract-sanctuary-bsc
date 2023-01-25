/**
 *Submitted for verification at BscScan.com on 2023-01-25
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    constructor() {
        _transferOwnership(_msgSender());
    }
    function owner() public view virtual returns (address) {
        return _owner;
    }
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

interface IMinter {
    function totalSupply() external view returns (uint256);
}

interface IStaker {
    function deposit() external payable returns(bool success);
}

interface IDistributor {
    function establishTokenDebt(uint tokenId) external;
}

contract EternalLabsStakerProxy is Ownable {

    address public MINTER = 0xE4cE0E5b3B70B5132807CE725eC93d6eE33B5Eca;
    address public DISTRIBUTOR = 0x9F56910342901Df65deB482256e8ec2d099E6771;
    address public STAKER = 0xc626D5aEa14c84061dC2FE6719E20767De354304; 

    uint public TOKEN_PRICE = 99000000000000000;
    
    constructor () {}   

    function setMinter(address minter) public onlyOwner {
        MINTER = minter;
    }

    function setStaker(address staker) public onlyOwner {
        STAKER = staker;
    }

    function setDistributor(address distributor) public onlyOwner {
        DISTRIBUTOR = distributor;
    }

    function setTokenPrice(uint price) public onlyOwner {
        TOKEN_PRICE = price;
    }

    function deposit() external payable returns(bool success){
        require(msg.sender == MINTER, "EL: not allowed");
        uint tokensMinted = msg.value/TOKEN_PRICE;
        uint lastTokenId = IMinter(MINTER).totalSupply();
        for (uint i = lastTokenId + 1; i <= (lastTokenId + tokensMinted); i++) 
        {
            IDistributor(DISTRIBUTOR).establishTokenDebt(i);
        }
        require(IStaker(STAKER).deposit{value: msg.value}(), "EL: Staking Failure");
        return(true);
    }
    
}