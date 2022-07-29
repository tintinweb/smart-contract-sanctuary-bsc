/**
 *Submitted for verification at BscScan.com on 2022-07-29
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;

interface IERC20 {
    function decimals() external view returns (uint8);

    function symbol() external view returns (string memory);

    function name() external view returns (string memory);

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

abstract contract Ownable {
    address internal _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = msg.sender;
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == msg.sender, "!owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "new is 0");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

abstract contract AbsPreSale is Ownable {
    uint256 private _qty = 50000000000000000000000;
    uint256 private _soldAmount;
    uint256 private _minAmount = 100000000000000000000;
    uint256 private _maxAmount = 500000000000000000000;

    address public _cashAddress;

    mapping(address => uint256) private _saleAmount;

    address[] public _userList;
    uint256 private _amountUnit;
    uint256 private _endTime;
    bool private _pauseBuy = false;

    constructor(address CashAddress){
        _cashAddress = CashAddress;
        uint256 amountUnit = 10 ** 18;
        _qty = 10000 * amountUnit;
        _minAmount = amountUnit;
        _maxAmount = 3 * amountUnit;

        _amountUnit = amountUnit;
        _endTime = block.timestamp + 864000;
    }

    function buy() external payable {
        require(!_pauseBuy, "pauseBuy");
        address account = msg.sender;
        uint256 value = msg.value / _amountUnit * _amountUnit;
        uint256 amount = value;

        uint256 remain = _qty - _soldAmount;
        require(remain > 0, "sold out");

        if (remain > amount) {
            require(_saleAmount[account] + amount >= _minAmount, "lt min");
        } else {
            uint256 returnValue = value - remain;
            account.call{value : returnValue}("");
            amount = remain;
        }

        require(_saleAmount[account] + amount <= _maxAmount, "gt max");

        if (0 == _saleAmount[account]) {
            _userList.push(account);
        }

        _saleAmount[account] += amount;
        _soldAmount += amount;

        _cashAddress.call{value : amount}("");
    }

    function getUserList(uint256 start, uint256 length) external view returns (uint256 returnLen, address[] memory returnUsers, uint256[] memory amount){
        if (0 == length) {
            length = _userList.length;
        }
        returnLen = length;

        returnUsers = new address[](length);
        amount = new uint256[](length);

        uint256 index = 0;
        for (uint256 i = start; i < start + length; ++i) {
            if (i >= _userList.length)
                return (index, returnUsers, amount);
            address user = _userList[i];
            returnUsers[index] = user;
            amount[index] = _saleAmount[user];
            ++index;
        }
    }

    function getUserListLength() external view returns (uint256){
        return _userList.length;
    }

    function getSaleInfo() external view returns (uint256, uint256, uint256, uint256, uint256, uint256, uint256,bool) {
        return (_qty, _soldAmount, _minAmount, _maxAmount, _amountUnit,_endTime,block.timestamp,_pauseBuy);
    }

    function getUserInfo(address account) external view returns (uint256 buyAmount, uint256 balance) {
        buyAmount = _saleAmount[account];
        balance = account.balance;
    }

    receive() external payable {}

    function setQty(uint256 qty) external onlyOwner {
        _qty = qty * _amountUnit;
    }

    function setMin(uint256 min) external onlyOwner {
        _minAmount = min * _amountUnit;
    }

    function setMax(uint256 max) external onlyOwner {
        _maxAmount = max * _amountUnit;
    }

    function setAmountUnit(uint256 amountUnit) external onlyOwner {
        _amountUnit = amountUnit;
    }

    function claimBalance(uint256 amount, address to) external onlyOwner {
        address payable addr = payable(to);
        addr.transfer(amount);
    }

    function claimToken(address erc20Address, uint256 amount, address to) external onlyOwner{
        IERC20 erc20 = IERC20(erc20Address);
        erc20.transfer(to, amount);
    }

    function setEndTime(uint256 endTime) external onlyOwner {
        _endTime = endTime;
    }

    function setPauseBuy(bool pause) external onlyOwner {
        _pauseBuy = pause;
    }
}

contract QMPPreSale is AbsPreSale {
    constructor() AbsPreSale(
        address(0x1af735D4F697DE46a313269eF85483D2b3D5E112)
    ){

    }
}