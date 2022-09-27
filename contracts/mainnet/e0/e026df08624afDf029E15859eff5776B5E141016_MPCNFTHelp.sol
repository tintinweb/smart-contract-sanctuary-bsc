/**
 *Submitted for verification at BscScan.com on 2022-09-27
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

interface ERC20Token {
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

contract MPCNFTHelp {

    // USDT-0x55d398326f99059fF775485246999027B3197955
    // TOP-0xFfF328b88c12C32731ABF193c2A4e0e2561C27dD
    ERC20Token constant internal USDT = ERC20Token(0x55d398326f99059fF775485246999027B3197955);

    address public _owner;

    address public _operator = 0x1D318eB4C5ebb09323a4551308A16Fdce97E7047;

    address public _rechargeAddress;

    constructor() {
        _owner = msg.sender; 
        _rechargeAddress = address(this);
    }

    modifier onlyOwner() {
        require(msg.sender == _owner, "Permission denied");_;
    }

    modifier onlyOperator() {
        require(msg.sender == _operator, "Permission denied");_;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        _owner = newOwner;
    }

    function transferOperatorship(address newOperator) public onlyOwner {
        require(newOperator != address(0));
        _operator = newOperator;
    }

    function transferRechargeship(address newRecharge) public onlyOwner {
        require(newRecharge != address(0));  
        _rechargeAddress = newRecharge;
    }

    receive() external payable {}

    function rechargeUSDT(uint256 quantity) public payable {
        USDT.transferFrom(address(msg.sender), address(this), quantity);
        USDT.transfer(_rechargeAddress, quantity);
    }

    function Withdrawal(uint256 quantity) public {}

    function WithdrawalOperator(address _address,uint256 quantity) public onlyOperator {
        USDT.transfer(_address, quantity);
    }

    function buyTickets(uint256 quantity) public {}

    function sendTickets(uint256 quantity, address toAddress) public {}
    
    function sendIntegral(uint256 quantity, address toAddress) public {}
    
    function lineUp(uint256 quantity) public {}

}