// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./LERC20.sol";

abstract contract Ownable is Context {
    address private _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    constructor() {
        _transferOwnership(_msgSender());
    }
    function owner() public view virtual returns (address) {
        return _owner;
    }
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
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

abstract contract Pausable is Context {
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state.
     */
    constructor() {
        _paused = false;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
        _;
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}


contract LegioDAO is LERC20, Ownable, Pausable {
    mapping(address => uint256) private _balances;
    uint256 private _totalSupply;// = 1E8 * 1E18;

    address public beneficiaryAddress;
    uint8 public feePercentage = 6;
    mapping(address => bool) public isExcludedFromFee;
    mapping (address => bool) public isBlacklisted;
    mapping (address => bool) public hasBlacklistPermission;

    event TransferFee(address sender, address recipient, uint256 amount);
    event SetFeePercentage(uint8 feePercentage);
    event SetBeneficiaryAddress(address beneficiaryAddress);

    constructor(uint256 totalSupply_, string memory name_, string memory symbol_,
        address admin_, address recoveryAdmin_, uint256 timelockPeriod_, address lossless_,
        address beneficiaryAddress_) LERC20(
        0,
        name_, symbol_,
        admin_,
        recoveryAdmin_,
        timelockPeriod_,
        lossless_)
    {
        _mint(_msgSender(), totalSupply_);

        beneficiaryAddress = beneficiaryAddress_;
        isExcludedFromFee[msg.sender] = true;
        hasBlacklistPermission[msg.sender] = true;
    }

    // --- ERC20 methods ---
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    function totalSupply() external view virtual override returns (uint256) {
        return _totalSupply;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal override whenNotPaused {
        require(sender != address(0), "LERC20: transfer from the zero address");
        require(recipient != address(0), "LERC20: transfer to the zero address");
        require(!isBlacklisted[sender], "LEGIO: transfer from blacklisted address");
        require(!isBlacklisted[recipient], "LEGIO: transfer to blacklisted address");
        require(!isBlacklisted[tx.origin], "LEGIO: transfer called from blacklisted address");

        uint256 senderBalance = _balances[sender];
        
        require(senderBalance >= amount, "LERC20: transfer amount exceeds balance");
        _balances[sender] = senderBalance - amount;

        uint256 receiveAmount = amount;
        if (isExcludedFromFee[sender] || isExcludedFromFee[recipient]) {
            _balances[recipient] += receiveAmount;
        } else {
            uint256 feeAmount = (amount * feePercentage) / 100;
            receiveAmount = amount - feeAmount;
            _balances[beneficiaryAddress] += feeAmount;
            _balances[recipient] += receiveAmount;
            emit TransferFee(sender, beneficiaryAddress, feeAmount);
        }
        emit Transfer(sender, recipient, receiveAmount);
    }

    // --- ERC20 Features: mint, burn, tax ---

    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }

    function _mint(address account, uint256 amount) internal virtual override {
        require(account != address(0), "LERC20: mint to the zero address");

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
    }

    function burn(uint256 amount) public virtual onlyOwner {
        _burn(_msgSender(), amount);
    }

    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "LERC20: burn from the zero address");
        
        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "LERC20: burn amount exceeds balance");
        _balances[account] = accountBalance - amount;
        
        _totalSupply -= amount;
        emit Transfer(account, address(0), amount);
    }

    function setFeePercentage(uint8 feePercentage_) external onlyOwner {
        require(feePercentage_ <= 20, "LEGIO: transaction fee percentage exceeds 20");
        require(feePercentage_ >= 0, "LEGIO: transaction fee percentage equals 0");
        feePercentage = feePercentage_;
        emit SetFeePercentage(feePercentage);
    }

    function setBeneficiaryAddress(address beneficiaryAddress_) external onlyOwner {
        beneficiaryAddress = beneficiaryAddress_;
        emit SetBeneficiaryAddress(beneficiaryAddress);
    }

    function excludeFromFee(address address_, bool isExcluded) external onlyOwner {
        isExcludedFromFee[address_] = isExcluded;
    }

    function setBlacklistPermission(address address_, bool permission) external onlyOwner {
        hasBlacklistPermission[address_] = permission;
    }

    function setBlacklist(address[] calldata addresses, bool isBlacklist) external {
        require(hasBlacklistPermission[msg.sender], "LEGIO: insufficient permission");
        for (uint i=0; i<addresses.length; i++) {
            isBlacklisted[addresses[i]] = isBlacklist;
        }
    }

    // Pause feature

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    // BEP20 method
    function getOwner() external view returns (address) {
        return owner();
    }
}

//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
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

interface ILosslessController {
    function beforeTransfer(address sender, address recipient, uint256 amount) external;

    function beforeTransferFrom(address msgSender, address sender, address recipient, uint256 amount) external;

    function beforeApprove(address sender, address spender, uint256 amount) external;

    function beforeIncreaseAllowance(address msgSender, address spender, uint256 addedValue) external;

    function beforeDecreaseAllowance(address msgSender, address spender, uint256 subtractedValue) external;
}

contract LERC20 is Context, IERC20 {
    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    uint256 private _totalSupply;
    string private _name;
    string private _symbol;

    address public recoveryAdmin;
    address private recoveryAdminCanditate;
    bytes32 private recoveryAdminKeyHash;
    address public admin;
    uint256 public timelockPeriod;
    uint256 public losslessTurnOffTimestamp;
    bool public isLosslessTurnOffProposed;
    bool public isLosslessOn = true;
    ILosslessController public lossless;

    event AdminChanged(address indexed previousAdmin, address indexed newAdmin);
    event RecoveryAdminChangeProposed(address indexed candidate);
    event RecoveryAdminChanged(address indexed previousAdmin, address indexed newAdmin);
    event LosslessTurnOffProposed(uint256 turnOffDate);
    event LosslessTurnedOff();
    event LosslessTurnedOn();

    constructor(uint256 totalSupply_, string memory name_, string memory symbol_, address admin_, address recoveryAdmin_, uint256 timelockPeriod_, address lossless_) {
        _mint(_msgSender(), totalSupply_);
        _name = name_;
        _symbol = symbol_;
        admin = admin_;
        recoveryAdmin = recoveryAdmin_;
        timelockPeriod = timelockPeriod_;
        lossless = ILosslessController(lossless_);
    }

    // --- LOSSLESS modifiers ---

    modifier lssAprove(address spender, uint256 amount) {
        if (isLosslessOn) {
            lossless.beforeApprove(_msgSender(), spender, amount);
        } 
        _;
    }

    modifier lssTransfer(address recipient, uint256 amount) {
        if (isLosslessOn) {
            lossless.beforeTransfer(_msgSender(), recipient, amount);
        } 
        _;
    }

    modifier lssTransferFrom(address sender, address recipient, uint256 amount) {
        if (isLosslessOn) {
            lossless.beforeTransferFrom(_msgSender(), sender, recipient, amount);
        }
        _;
    }

    modifier lssIncreaseAllowance(address spender, uint256 addedValue) {
        if (isLosslessOn) {
            lossless.beforeIncreaseAllowance(_msgSender(), spender, addedValue);
        }
        _;
    }

    modifier lssDecreaseAllowance(address spender, uint256 subtractedValue) {
        if (isLosslessOn) {
            lossless.beforeDecreaseAllowance(_msgSender(), spender, subtractedValue);
        }
        _;
    }

    modifier onlyRecoveryAdmin() {
        require(_msgSender() == recoveryAdmin, "LERC20: Must be recovery admin");
        _;
    }

    // --- LOSSLESS management ---

    function getAdmin() external view returns (address) {
        return admin;
    }

    function transferOutBlacklistedFunds(address[] calldata from) external {
        require(_msgSender() == address(lossless), "LERC20: Only lossless contract");
        for (uint i = 0; i < from.length; i++) {
            _transfer(from[i], address(lossless), balanceOf(from[i]));
        }
    }

    function setLosslessAdmin(address newAdmin) external onlyRecoveryAdmin {
        require(newAdmin != address(0), "LERC20: Cannot be zero address");
        emit AdminChanged(admin, newAdmin);
        admin = newAdmin;
    }

    function transferRecoveryAdminOwnership(address candidate, bytes32 keyHash) external onlyRecoveryAdmin {
        require(candidate != address(0), "LERC20: Cannot be zero address");
        recoveryAdminCanditate = candidate;
        recoveryAdminKeyHash = keyHash;
        emit RecoveryAdminChangeProposed(candidate);
    }

    function acceptRecoveryAdminOwnership(bytes memory key) external {
        require(_msgSender() == recoveryAdminCanditate, "LERC20: Must be canditate");
        require(keccak256(key) == recoveryAdminKeyHash, "LERC20: Invalid key");
        emit RecoveryAdminChanged(recoveryAdmin, recoveryAdminCanditate);
        recoveryAdmin = recoveryAdminCanditate;
    }

    function proposeLosslessTurnOff() external onlyRecoveryAdmin {
        losslessTurnOffTimestamp = block.timestamp + timelockPeriod;
        
        isLosslessTurnOffProposed = true;
        emit LosslessTurnOffProposed(losslessTurnOffTimestamp);
    }

    function executeLosslessTurnOff() external onlyRecoveryAdmin {
        require(isLosslessTurnOffProposed, "LERC20: TurnOff not proposed");
        require(losslessTurnOffTimestamp <= block.timestamp, "LERC20: Time lock in progress");
        isLosslessOn = false;
        isLosslessTurnOffProposed = false;
        emit LosslessTurnedOff();
    }

    function executeLosslessTurnOn() external onlyRecoveryAdmin {
        isLosslessTurnOffProposed = false;
        isLosslessOn = true;
        emit LosslessTurnedOn();
    }

    // --- ERC20 methods ---

    function name() external view virtual returns (string memory) {
        return _name;
    }

    function symbol() external view virtual returns (string memory) {
        return _symbol;
    }

    function decimals() external view virtual returns (uint8) {
        return 18;
    }

    function totalSupply() external view virtual override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) external virtual override lssTransfer(recipient, amount) returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) external view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) external virtual override lssAprove(spender, amount) returns (bool) {
        require((amount == 0) || (_allowances[_msgSender()][spender] == 0), "LERC20: Cannot change non zero allowance");
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) external virtual override lssTransferFrom(sender, recipient, amount) returns (bool) {
        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "LERC20: transfer amount exceeds allowance");
        _approve(sender, _msgSender(), currentAllowance - amount);

        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) external virtual lssIncreaseAllowance(spender, addedValue) returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) external virtual lssDecreaseAllowance(spender, subtractedValue) returns (bool) {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "LERC20: decreased allowance below zero");
        _approve(_msgSender(), spender, currentAllowance - subtractedValue);

        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "LERC20: transfer from the zero address");
        require(recipient != address(0), "LERC20: transfer to the zero address");

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "LERC20: transfer amount exceeds balance");
        _balances[sender] = senderBalance - amount;
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "LERC20: mint to the zero address");

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "LERC20: approve from the zero address");
        require(spender != address(0), "LERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    
}