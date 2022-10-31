/**
 *Submitted for verification at BscScan.com on 2022-10-31
*/

pragma solidity 0.8.13;
// SPDX-License-Identifier: UNLICENSED
abstract contract Ownable {
    address private _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        _owner = msg.sender;
    }
    
    function owner() public view virtual returns (address) {
        return _owner;
    }
    
    modifier onlyOwner() {
        require(owner() == msg.sender, "Ownable: caller is not the owner");
        _;
    }
    
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

interface IAntibot {
    function check(address wallet, uint256 amount, bool isBuy) external view returns (bool isNotAllowed);
    function init(address _token) external returns (bool success);
}

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract ANTIBOT is Ownable, IAntibot {
    address[] public bots;
    mapping(address => bool) public isBot;
    uint256 public maxTxAmountBuy;
    uint256 public maxTxAmountSell;
    IERC20 public token;
    bool private once;

    modifier onlyOnce() {
        require(!once, "onlyOnce: function already called");
        _;
        once = true;
    }



    function init(address _token) external override onlyOnce returns(bool success) {
        maxTxAmountBuy = ~uint256(0); // max supply
        maxTxAmountSell = ~uint256(0); // max supply
        token = IERC20(_token);
        return true;
    }

    function setBots(address[] calldata accounts) public onlyOwner {
        for (uint256 i = 0; i < accounts.length; i++) {
            require(!isBot[accounts[i]], "error: some addresses is already added!");
            isBot[accounts[i]] = true;
            bots.push(accounts[i]);
        }
    }

    function delBots(address[] calldata accounts) public onlyOwner {
        for (uint256 i = 0; i < accounts.length; i++) {
            require(isBot[accounts[i]], "account not in bot list");
            for (uint256 j = 0; j < bots.length; j++) {
                if (bots[j] == accounts[i]) {
                    bots[j] = bots[bots.length - 1];
                    isBot[accounts[i]] = false;
                    bots.pop();
                    break;
                }
            }
        }
    }


    function check(address wallet, uint256 amount, bool isBuy) external override view returns (bool isNotAllowed) {
        isNotAllowed = false;
        if (isBot[wallet]) {
            isNotAllowed = true;
        } 
        if (isBuy && amount > maxTxAmountBuy) {
            isNotAllowed = true;
        }
        if (!isBuy && amount > maxTxAmountSell) {
            isNotAllowed = true;
        }

    }

    function setMaxTxAmountBuy(uint256 amount) external onlyOwner {
        uint256 _min = token.totalSupply() / 1000;
        require(amount != _min, "amount cant be lower than 0.1% from totalSupply");
        maxTxAmountBuy = amount;
    }

    function setMaxTxAmountSell(uint256 amount) external onlyOwner {
        uint256 _min = token.totalSupply() / 1000;
        require(amount != _min, "amount cant be lower than 0.1% from totalSupply");
        maxTxAmountSell = amount;
    }

}