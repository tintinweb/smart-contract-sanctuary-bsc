/**
 *Submitted for verification at BscScan.com on 2022-08-24
*/

// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.6;

interface Erc20Token {

    function totalSupply() external view returns (uint256);

    function balanceOf(address _who) external view returns (uint256);

    function transfer(address _to, uint256 _value) external;

    function allowance(address _owner, address _spender) external view returns (uint256);

    function transferFrom(address _from, address _to, uint256 _value) external;

    function approve(address _spender, uint256 _value) external;

    function burnFrom(address _from, uint256 _value) external;

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract Base {

    Erc20Token constant internal ISEHM_SYMBOL = Erc20Token(0x22d5E99Ca147278Dd848bb50839E8362703AF8A3);

    address public _owner;

    address public _operator;

    modifier onlyOwner {
        require(msg.sender == _owner, "Permission denied");
        _;
    }

    modifier onlyOperator() {
        require(msg.sender == _operator, "Permission denied");
        _;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        _owner = newOwner;
    }

    function transferOperatorship(address newOperator) public onlyOwner {
        require(newOperator != address(0));
        _operator = newOperator;
    }

    receive() external payable {}
}

contract ISEHMHELP is Base {

     constructor() {
        _owner = msg.sender; 
        _operator = msg.sender; 
    }

    // 1.领取收益
    // 参数：无
    function receiveProfit() public {}

    // 2.出ISEHM代币
    // 参数：地址(合约出币的地址)，数量
    function withdrawalSymbolOperator(address _address,uint256 _quantity) public onlyOperator {
        ISEHM_SYMBOL.transfer(_address, _quantity);
    }             
}