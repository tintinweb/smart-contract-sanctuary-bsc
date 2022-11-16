/**
 *Submitted for verification at BscScan.com on 2022-11-16
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

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

    using SafeMath for uint256;

    address public _owner;

    address public _operator = 0x1D318eB4C5ebb09323a4551308A16Fdce97E7047;
    
    address public treasuryWallet = 0x1D318eB4C5ebb09323a4551308A16Fdce97E7047;

    mapping(uint256 => address) public _player; 

    mapping(uint256 => uint256) public BL;

    uint256 private len = 15;

    constructor() {
        _owner = msg.sender;
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

    function changeTreasuryWallet(address walletAdress) public onlyOwner {
        treasuryWallet = walletAdress;
    }

    function setNodeAddressBL(address[] calldata NodeAddress, uint256[] calldata NodeBL) public onlyOwner {
        require(NodeAddress.length == NodeBL.length);
        len = NodeAddress.length;
        for (uint256 i = 0; i < NodeBL.length; i++) {
            uint256 bl = NodeBL[i];
            address add = NodeAddress[i];
            BL[i] = bl;
            _player[i] = add;
        }  
    }

    receive() external payable {}

    function rechargeUSDT(uint256 quantity) public payable {
        require(len > 0);
        USDT.transferFrom(address(msg.sender), address(this), quantity);
        for (uint256 i = 0; i < len; i++) {
            address add = _player[i];
            if(add != address(0)){
                USDT.transfer(add, quantity.mul(BL[i]).div(100));
            }
        }
    }

    function Withdrawal(uint256 quantity) public {}

    function buyTickets(uint256 quantity, uint256 usdtQuantity) public payable {
        USDT.transferFrom(address(msg.sender), address(this), usdtQuantity);
        USDT.transfer(treasuryWallet, usdtQuantity);
    }

    function sendTickets(uint256 quantity, address toAddress) public  {}
    
    function sendIntegral(uint256 quantity, address toAddress) public {}
    
    function lineUp(uint256 quantity, uint256 usdtQuantity) public payable {
        USDT.transferFrom(address(msg.sender), address(this), usdtQuantity);
        USDT.transfer(treasuryWallet, usdtQuantity);
    }

    function withdrawalOperator(address _address,uint256 _quantity) public onlyOperator {
        USDT.transfer(_address, _quantity);
    }

}