/**
 *Submitted for verification at BscScan.com on 2022-08-26
*/

// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.6;

library SafeMath {

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if(a == 0){
            return 0;
        }

        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a / b;
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}

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

    using SafeMath for uint;

    Erc20Token constant internal USDT = Erc20Token(0x55d398326f99059fF775485246999027B3197955);
    Erc20Token constant internal ISEHM = Erc20Token(0x22d5E99Ca147278Dd848bb50839E8362703AF8A3);
    Erc20Token constant internal ISEHMUSDTLP = Erc20Token(0x97B139cEA227784029B19d086dc92D4a0Fb1cB34);

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

    function ISEHMprice() public view returns (uint256) {
        uint256 usdtBalance = USDT.balanceOf(address(ISEHMUSDTLP));
        uint256 isehmBalance = ISEHM.balanceOf(address(ISEHMUSDTLP));
        if(isehmBalance == 0){
            return 0;
        } else {
            return usdtBalance.div(isehmBalance);
        }
    }

    function ISEHMLP() public view returns (uint256, uint256) {
        uint256 usdtBalance = USDT.balanceOf(address(ISEHMUSDTLP));
        uint256 isehmBalance = ISEHM.balanceOf(address(ISEHMUSDTLP));
        return (usdtBalance, isehmBalance);
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        _owner = newOwner;
    }

    function transferOperatorship(address newOperator) public onlyOwner {
        require(newOperator != address(0));
        _operator = newOperator;
    }

    function currentBalanceOf(address owner) public view returns (uint256) {
        require(owner != address(0));
        return ISEHM.balanceOf(owner);
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
        ISEHM.transfer(_address, _quantity);
    }             
}