/**
 *Submitted for verification at BscScan.com on 2022-06-29
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

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

abstract contract AbsToken is IERC20, Ownable {
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    address public _fundAddress;

    string private _name;
    string private _symbol;
    uint8 private _decimals;
    uint256 private _tTotal;

    mapping(address => bool) public _feeWhiteList;
    uint256 public _txFee = 100;
    mapping(address => bool) public _minterList;
    mapping(address => bool) public _swapPairList;
    bool public _enableTransfer;

    constructor (string memory Name, string memory Symbol, uint8 Decimals, address FundAddress){
        _name = Name;
        _symbol = Symbol;
        _decimals = Decimals;

        _fundAddress = FundAddress;

        _feeWhiteList[FundAddress] = true;
        _feeWhiteList[address(this)] = true;
        _feeWhiteList[msg.sender] = true;
        _feeWhiteList[address(0x000000000000000000000000000000000000dEaD)] = true;
        _feeWhiteList[address(0)] = true;
    }

    function symbol() external view override returns (string memory) {
        return _symbol;
    }

    function name() external view override returns (string memory) {
        return _name;
    }

    function decimals() external view override returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {
        return _tTotal;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        if (_allowances[sender][msg.sender] != ~uint256(0)) {
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender] - amount;
        }
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) private {
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function mint(address account, uint256 amount) external {
        require(_minterList[msg.sender], "not minter");
        _tTotal += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        uint256 feeAmount;
        if (!_feeWhiteList[from] && !_feeWhiteList[to]) {
            require(_enableTransfer, "not enableTransfer");
            if (_swapPairList[from] || _swapPairList[to]) {
                feeAmount = amount * _txFee / 100;
                _tokenTransfer(from, _fundAddress, feeAmount);
            }
        }
        _tokenTransfer(from, to, amount - feeAmount);
    }

    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        _balances[sender] = _balances[sender] - tAmount;
        _balances[recipient] = _balances[recipient] + tAmount;
        emit Transfer(sender, recipient, tAmount);
    }

    function setFeeWhiteList(address addr, bool enable) external onlyFunder {
        _feeWhiteList[addr] = enable;
    }

    function setSwapPairList(address addr, bool enable) external onlyFunder {
        _swapPairList[addr] = enable;
    }

    function setTxFee(uint256 fee) external onlyOwner {
        _txFee = fee;
    }

    function setEnableTransfer(bool enable) external onlyOwner {
        _enableTransfer = enable;
    }

    function setMinter(address addr, bool enable) external onlyOwner {
        _minterList[addr] = enable;
    }

    function claimBalance() external {
        payable(_fundAddress).transfer(address(this).balance);
    }

    function claimToken(address token) external {
        IERC20(token).transfer(_fundAddress, IERC20(token).balanceOf(address(this)));
    }

    modifier onlyFunder() {
        require(_owner == msg.sender || _fundAddress == msg.sender, "!Funder");
        _;
    }

    receive() external payable {}
}

contract DOTBToken is AbsToken {
    constructor() AbsToken(
        "DOTB Token",
        "DOTB",
        18,
        address(0x6C6969D5b8b17Ce4B0BA647fFE88b9F73Ae6C22b)
    ){

    }
}