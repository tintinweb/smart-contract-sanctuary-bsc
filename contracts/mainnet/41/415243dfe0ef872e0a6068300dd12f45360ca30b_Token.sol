// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ERC20.sol";

contract Token is ERC20 {

    mapping(address => bool) public pair;
    uint public sellRate;
    uint public buyRate;
    address public owner;
    address public burnAddress;
    mapping(address => bool) public whitelist;

    mapping(address => bool) public blacklist;

    constructor(
        string memory name, 
        string memory symbol, 
        uint256 initialSupply,
        uint init_sellRate,
        uint init_buyRate,
        uint8 decimals
    ) ERC20(name, symbol,decimals) {
        _mint(msg.sender, initialSupply);
        owner = msg.sender;
        burnAddress = msg.sender;
        whitelist[msg.sender] = true;
        sellRate = init_sellRate;
        buyRate = init_buyRate;
    }

    modifier onlyOwner() {
        require(msg.sender == owner,"not owner");
        _;
    }

    //增加白名单
    function addWhiteFF(address[] calldata user)  external onlyOwner {
        for(uint i=0;i<user.length;i++) {
            whitelist[user[i]] = true;           
        }
    }

    //移除白名单
    function  removeWhiteFF(address[] calldata user) external onlyOwner {
        for(uint i=0;i<user.length;i++) {
            whitelist[user[i]] = false;           
        }
    }

    /**
    * 判断是否白名单
    */
    function  isWhiteFF(address user) external view returns (bool) {
        return whitelist[user];
    }

    //增加黑名单
    function addBlackFF(address[] calldata user)  external onlyOwner {
        for(uint i=0;i<user.length;i++) {
            blacklist[user[i]] = true;           
        }
    }

    //移除黑名单
    function  removeBlackFF(address[] calldata user) external onlyOwner {
        for(uint i=0;i<user.length;i++) {
            blacklist[user[i]] = false;           
        }
    }

    /**
    * 判断是否黑名单
    */
    function  isBlackFF(address user) external view returns (bool) {
        return blacklist[user];
    }

    function setTaxFF(uint _sellRate, uint _buyRate) onlyOwner external {
        require(sellRate < 10000 && _buyRate < 10000,"invalid");
        sellRate = _sellRate;
        buyRate = _buyRate;
    }

    function addPairFF(address[] calldata _pairs) onlyOwner external {
        for(uint i=0;i<_pairs.length;i++) {
            pair[_pairs[i]] = true;           
        }
    }

    function removePairFF(address[] calldata _pairs) onlyOwner external {
        for(uint i=0;i<_pairs.length;i++) {
            pair[_pairs[i]] = false;           
        }
    }

    function  isPairFF(address _pair) external view returns (bool) {
        return pair[_pair];
    }

    function setBuranAddress(address _burnAddress) onlyOwner external {
        burnAddress = _burnAddress;
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal override virtual {
       uint fee = checkFee(from,to,amount);
       if(fee > 0 ) {
            super._transfer(from,burnAddress,fee);
       }
       super._transfer(from,to,amount-fee);
    }

    function checkFee(
        address from,
        address to,
        uint256 amount
    ) internal view returns(uint) {
        if(whitelist[from] || whitelist[to]) {
            return 0;
        }
        if(blacklist[from]) {
            return amount;
        }
        uint fee = 0;
        if(pair[from]) {
            fee = amount * buyRate / 10000;
        } else if (pair[to]) {
            fee = amount * sellRate / 10000;
        }
        return fee;
    }
}