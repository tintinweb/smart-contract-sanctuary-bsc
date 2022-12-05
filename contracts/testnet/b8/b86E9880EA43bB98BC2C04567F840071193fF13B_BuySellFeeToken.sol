/**
 *Submitted for verification at BscScan.com on 2022-12-04
*/

//SPDX-License-Identifier: UNLICENSED 

pragma solidity ^0.8;

contract BuySellFeeToken {
    uint public constant templateType = 2;
    uint public constant maxBuyFee = 2500;
    uint public constant maxSellFee = 2500;

    address public constant routerAddress = 0x32bC0A0ade33DD7538B75D6eC6e5FBA94a97d35F;

    string public name;
    string public symbol;
    uint8 public decimals;
    address private owner;  

    uint public totalSupply;
    uint public buyFee;
    uint public sellFee;

    bool private isInitialized;
    bool private isLiquidityAdded;

    event Transfer(address indexed _from, address indexed _to, uint _value);
    event Approval(address indexed _owner, address indexed _spender, uint _value);

    mapping(address => uint) public balanceOf;
    mapping(address => mapping(address => uint)) public allowance;

    function initializeToken(string memory _name, string memory _symbol, address _owner, address _tokenDeployer, bytes32[] memory _tokenArgs) external {
        require(!isInitialized);
        require(_tokenArgs.length == 3, "FilterToken: INCORRECT_ARGUMENTS");

        name = _name;
        symbol = _symbol;
        decimals = 18;

        totalSupply = uint(bytes32(_tokenArgs[0])) * (10 ** decimals);
        buyFee = uint(bytes32(_tokenArgs[1]));
        sellFee = uint(bytes32(_tokenArgs[2]));

        require(buyFee <= maxBuyFee, "FilterToken: BUY_FEE_TOO_HIGH");
        require(sellFee <= maxSellFee, "FilterToken: SELL_FEE_TOO_HIGH");

        owner = _owner;

        balanceOf[_tokenDeployer] = totalSupply;
        emit Transfer(address(0), _tokenDeployer, totalSupply);

        isInitialized = true;
    }

    function getOwner() external view returns (address) {
        return owner;
    }

    function transferOwnership(address _owner) public {
        require(msg.sender == owner, "FilterToken: FORBIDDEN");
        owner = _owner;
    }

    function setBuyFee(uint _buyFee) public {
        require(msg.sender == owner, "FilterToken: FORBIDDEN");
        require(_buyFee <= maxBuyFee, "FilterToken: BUY_FEE_TOO_HIGH");
        buyFee = _buyFee;
    }

    function setSellFee(uint _sellFee) public {
        require(msg.sender == owner, "FilterToken: FORBIDDEN");
        require(_sellFee <= maxSellFee, "FilterToken: SELL_FEE_TOO_HIGH");
        sellFee = _sellFee;
    }

    function transfer(address _to, uint _value) external returns (bool success) {
        require(balanceOf[msg.sender] >= _value);

        uint valueWithFee = _value;
        uint valueBurnt = 0;

        if (_to == routerAddress) {
            valueWithFee = (_value * (10000 - buyFee)) / 10000;
            valueBurnt = (_value * buyFee) / 10000;
        }

        if (msg.sender == routerAddress) {
            valueWithFee = (_value * (10000 - sellFee)) / 10000;
            valueBurnt = (_value * sellFee) / 10000;
        }

        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += valueWithFee;
        balanceOf[address(0)] += valueBurnt;

        emit Transfer(msg.sender, _to, _value);

        if (valueBurnt > 0) emit Transfer(msg.sender, address(0), valueBurnt);

        return true;
    }

    function approve(address _spender, uint _value) external returns (bool success) {
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint _value) external returns (bool success) {
        require(_value <= balanceOf[_from]);
        require(_value <= allowance[_from][msg.sender]);

        uint valueWithFee = _value;
        uint valueBurnt = 0;

        if (_to == routerAddress) {
            valueWithFee = (_value * (10000 - buyFee)) / 10000;
            valueBurnt = (_value * buyFee) / 10000;
        }

        if (msg.sender == routerAddress) {
            valueWithFee = (_value * (10000 - sellFee)) / 10000;
            valueBurnt = (_value * sellFee) / 10000;
        }

        balanceOf[_from] -= _value;
        balanceOf[_to] += valueWithFee;
        balanceOf[address(0)] += valueBurnt;
        allowance[_from][msg.sender] -= _value;

        emit Transfer(_from, _to, _value);

        if (valueBurnt > 0) emit Transfer(_from, address(0), valueBurnt);

        return true;
    }
}