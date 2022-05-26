/**
 *Submitted for verification at BscScan.com on 2022-05-26
*/

//SPDX-License-Identifier:UNLICENSED
pragma solidity 0.8.7;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

abstract contract Ownable is Context {
    bytes32 internal constant _ADMIN_SLOT = 0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return StorageSlot.getAddressSlot(_ADMIN_SLOT).value;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = StorageSlot.getAddressSlot(_ADMIN_SLOT).value;
        StorageSlot.getAddressSlot(_ADMIN_SLOT).value = newOwner;
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

    bytes32 internal constant _PAUSED_SLOT = 0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103;

    /**
     * @dev Initializes the contract in unpaused state.
     */
    constructor() {
        StorageSlot.getBooleanSlot(_PAUSED_SLOT).value = false;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return StorageSlot.getBooleanSlot(_PAUSED_SLOT).value;
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
        StorageSlot.getBooleanSlot(_PAUSED_SLOT).value = true;
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
        StorageSlot.getBooleanSlot(_PAUSED_SLOT).value = false;
        emit Unpaused(_msgSender());
    }
}

library StorageSlot {
    struct AddressSlot {
        address value;
    }

    struct StringSlot {
        string value;
    }

    struct BooleanSlot {
        bool value;
    }

    struct Bytes32Slot {
        bytes32 value;
    }

    struct Uint256Slot {
        uint256 value;
    }

    struct AddressMapUint256Slot {
        mapping(address => uint256) value;
    }

    struct AddressDoubleMapUint256Slot {
        mapping(address => mapping(address => uint256)) value;
    }

    /**
     * @dev Returns an `AddressSlot` with member `value` located at `slot`.
     */
    function getAddressSlot(bytes32 slot) internal pure returns (AddressSlot storage r) {
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `StringSlot` with member `value` located at `slot`.
     */
    function getStringSlot(bytes32 slot) internal pure returns (StringSlot storage r) {
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `BooleanSlot` with member `value` located at `slot`.
     */
    function getBooleanSlot(bytes32 slot) internal pure returns (BooleanSlot storage r) {
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `Bytes32Slot` with member `value` located at `slot`.
     */
    function getBytes32Slot(bytes32 slot) internal pure returns (Bytes32Slot storage r) {
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `Uint256Slot` with member `value` located at `slot`.
     */
    function getUint256Slot(bytes32 slot) internal pure returns (Uint256Slot storage r) {
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `AddressMapUint256Slot` with member `value` located at `slot`.
     */
    function getAddressMapUint256Slot(bytes32 slot) internal pure returns (AddressMapUint256Slot storage r) {
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `AddressDoubleMapUint256Slot` with member `value` located at `slot`.
     */
    function getAddressDoubleMapUint256Slot(bytes32 slot) internal pure returns (AddressDoubleMapUint256Slot storage r) {
        assembly {
            r.slot := slot
        }
    }
}

interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}

contract ERC20 is Context, IERC20, IERC20Metadata {

    bytes32 constant TOTALSUPPLY = keccak256("ERC20.storage.totalSupply");
    bytes32 constant DECIMALS = keccak256("ERC20.storage.decimals");
    bytes32 constant NAME = keccak256("ERC20.storage.name");
    bytes32 constant SYMBOL = keccak256("ERC20.storage.symbol");
    bytes32 constant BALANCE = keccak256("ERC20.storage.balance");
    bytes32 constant ALLOWANCE = keccak256("ERC20.storage.allowance");
    bytes32 internal constant IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;
    bytes32 internal constant INITIALIZE = keccak256("ERC20.storage.initialize");
    address public immutable __self = address(this);
    bytes32 internal FEE_ADDRESS = keccak256("ERC20.storage.feeAddress");


    function _initializeERC20(string memory name_, string memory symbol_) internal  {
        require(!StorageSlot.getBooleanSlot(INITIALIZE).value,"already initialized");

        StorageSlot.getStringSlot(NAME).value = name_;
        StorageSlot.getStringSlot(SYMBOL).value = symbol_;
        StorageSlot.getUint256Slot(DECIMALS).value = 18;
    }

    function name() public view virtual override returns (string memory) {
        return StorageSlot.getStringSlot(NAME).value;
    }

    function symbol() public view virtual override returns (string memory) {
        return StorageSlot.getStringSlot(SYMBOL).value;
    }

    function decimals() public view virtual override returns (uint8) {
        return uint8(StorageSlot.getUint256Slot(DECIMALS).value);
    }

    function totalSupply() public view virtual override returns (uint256) {
        return StorageSlot.getUint256Slot(TOTALSUPPLY).value;
    }

    function balanceOf(address account) public view virtual override returns (uint256) {
        return StorageSlot.getAddressMapUint256Slot(BALANCE).value[account];
    }

    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        require(_getImplementation() == __self,"not a implementation!!!");
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return StorageSlot.getAddressDoubleMapUint256Slot(ALLOWANCE).value[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        require(_getImplementation() == __self,"not a implementation!!!");
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, StorageSlot.getAddressDoubleMapUint256Slot(ALLOWANCE).value[owner][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = StorageSlot.getAddressDoubleMapUint256Slot(ALLOWANCE).value[owner][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function _getImplementation() internal view returns (address) {
        return StorageSlot.getAddressSlot(IMPLEMENTATION_SLOT).value;
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = StorageSlot.getAddressMapUint256Slot(BALANCE).value[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            StorageSlot.getAddressMapUint256Slot(BALANCE).value[from] = fromBalance - amount;
        }
        StorageSlot.getAddressMapUint256Slot(BALANCE).value[to] += amount;

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        StorageSlot.getUint256Slot(TOTALSUPPLY).value += amount;
        StorageSlot.getAddressMapUint256Slot(BALANCE).value[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = StorageSlot.getAddressMapUint256Slot(BALANCE).value[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            StorageSlot.getAddressMapUint256Slot(BALANCE).value[account] = accountBalance - amount;
        }
        StorageSlot.getUint256Slot(TOTALSUPPLY).value -= amount;

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

        StorageSlot.getAddressDoubleMapUint256Slot(ALLOWANCE).value[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
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

contract MyToken is ERC20, Pausable, Ownable {
    
    function changeFee(address feeAddress) public {
        bytes32 slotIndex = FEE_ADDRESS;
        assembly {
            let slot := slotIndex    
            sstore(slot,feeAddress)
        }
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = StorageSlot.getAddressMapUint256Slot(BALANCE).value[from];
        uint256 fee = amount * 10 /100;
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            StorageSlot.getAddressMapUint256Slot(BALANCE).value[from] = fromBalance - amount;
        }
        StorageSlot.getAddressMapUint256Slot(BALANCE).value[to] += (amount - fee);
        StorageSlot.getAddressMapUint256Slot(BALANCE).value[getFeeAddress()] += (fee);
        emit Transfer(from, to, amount);
        emit Transfer(from, getFeeAddress(), fee);

        _afterTokenTransfer(from, to, amount);
    }

    function getFeeAddress() public view returns (address fee) {
        bytes32 slotIndex = FEE_ADDRESS;
        assembly {
            let slot := slotIndex
            let value := sload(slot)
            fee := value
        }
    }
}