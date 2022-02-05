// SPDX-License-Identifier: MIT

pragma solidity 0.8.11;

import "./lib/BEP20.sol";
import "./interface/IERC20.sol";

contract GAMERE is BEP20 {
  
    IERC20 public JAXRE;
    
    uint public rolling_reserve_rate = 5e6;
    uint public withdrawal_fee_rate;
    uint public tx_fee_rate;

    address public tx_fee_wallet;
    address public gate_keeper;
    address public banker;

    struct Operator{
        uint operator_rate;
        uint merchant_rate;
        address merchant;
    }

    address[] public operator_list;
    mapping(address => Operator) public operator_info;
    mapping(address => address) public merchant_to_operator;

    struct Merchant {
        uint[] releaseDates;
        uint[] releaseAmounts;
        uint releasedIndex;
    }

    mapping (address => Merchant ) merchant_info;

    enum BurnStatus { Init, Processed }

    struct BurnInfo {
        uint amount;
        address account;
        BurnStatus status;
    }

    mapping (uint => BurnInfo) burn_info;

    event Set_Rolling_Reserve_Rate(uint rate);
    event Set_Withdrawal_Fee_Rate(uint rate);
    event Set_Tx_Fee_Rate(uint rate);
    event Set_Merchant(address operator, address merchant, uint merchant_rate);
    event Set_Gate_Keeper(address gate_keeper);
    event Set_Banker(address banker);
    event Add_Operators(address[] operators);
    event Remove_Operator(address operator);
    event Harvest(address merchant);

    constructor (
        string memory name,
        string memory symbol,
        uint8 decimals,
        address _JAXRE
    )
        BEP20(name, symbol)
    {
        _setupDecimals(decimals);
        JAXRE = IERC20(_JAXRE);
    }

    function _mint(address account, uint256 amount) internal override {
        require(msg.sender == gate_keeper, "Only Gatekeeper");
        JAXRE.transferFrom(account, address(this), amount);
        address operator_address = merchant_to_operator[account];
        require(operator_address != address(0) || account == banker, "Invalid account");
        
        uint operator_amount;
        uint merchant_amount;
        uint rolling_reserve_amount = rolling_reserve_rate * amount / 1e8;

        if(operator_address != address(0)) {
            Operator memory operator = operator_info[operator_address];
            operator_amount = operator.operator_rate * amount / 1e8;
            merchant_amount = operator.merchant_rate * amount / 1e8;
        }
    
        super._mint(account, amount - merchant_amount - rolling_reserve_amount);
        if(operator_amount > 0)
            super._mint(tx_fee_wallet, operator_amount);
        if(merchant_amount - operator_amount > 0)
            super._mint(operator_address, merchant_amount - operator_amount);

        uint currentDate = block.timestamp / 3600 / 24;
        Merchant storage merchant = merchant_info[account];
        uint release_length = merchant.releaseDates.length;
        if(release_length == 0) {
            merchant.releaseAmounts.push(0);
            merchant.releaseDates.push(0);
            release_length += 1;
        }
        if(merchant.releaseDates[release_length - 1] == currentDate) {
            merchant.releaseAmounts[release_length - 1] += rolling_reserve_amount;
        } else {
            merchant.releaseDates.push(currentDate);
            merchant.releaseAmounts.push(rolling_reserve_amount);
        }
    }

    function burn(uint amount) public override(BEP20) {
        JAXRE.transfer(msg.sender, amount);
        _burn(msg.sender, amount);
    }

    function burn_to_banker(uint amount, uint message_hash) public {
        BurnInfo storage burnInfo = burn_info[message_hash];
        require(burnInfo.account != address(0), "duplicated message hash");
        burnInfo.account = msg.sender;
        burnInfo.amount = amount;
        _burn(msg.sender, amount);
    }

    function process_burn(uint message_hash) public {
        require(msg.sender == banker, "Only banker");
        BurnInfo storage burnInfo = burn_info[message_hash];
        require(burnInfo.status == BurnStatus.Init, "Already processed");
        uint withdrawal_fee_amount = withdrawal_fee_rate * burnInfo.amount / 1e8;
        JAXRE.transfer(msg.sender, burnInfo.amount-withdrawal_fee_amount);
        super._transfer(msg.sender, tx_fee_wallet, withdrawal_fee_amount);
        burnInfo.status = BurnStatus.Processed;
    }

    function set_rolling_reserve_rate(uint rate) external onlyOwner {
        rolling_reserve_rate = rate;
        emit Set_Rolling_Reserve_Rate(rate);
    }

    function set_withdrawal_fee_rate(uint rate) external onlyOwner {
        withdrawal_fee_rate = rate;
        emit Set_Withdrawal_Fee_Rate(rate);
    }

    function set_tx_fee_rate(uint rate) external onlyOwner {
        tx_fee_rate = rate;
        emit Set_Tx_Fee_Rate(rate);
    }

    function set_gate_keeper(address _gate_keeper) external onlyOwner {
        gate_keeper = _gate_keeper;
        emit Set_Gate_Keeper(_gate_keeper);
    }

    function set_banker(address _banker) external onlyOwner {
        banker = _banker;
        emit Set_Banker(_banker);
    }

    function add_operators(address[] calldata operators) external onlyOwner {
        for(uint i; i < operators.length; i += 1) {
            require(operator_info[operators[i]].operator_rate == 0, "Operator already exists");
            operator_list.push(operators[i]);
            operator_info[operators[i]].operator_rate = 5e6;
            operator_info[operators[i]].merchant_rate = 7e6;
        }
        emit Add_Operators(operators);
    }

    function remove_operator(address operator_address) external onlyOwner {
        for(uint i; i < operator_list.length; i += 1) {
            if(operator_list[i] == operator_address) {
                operator_list[i] = operator_list[operator_list.length - 1];
                operator_list.pop();
                delete operator_info[operator_address];
                emit Remove_Operator(operator_address);
            }
        }
    }

    function set_merchant(address merchant, uint merchant_rate) external {
        Operator storage operator = operator_info[msg.sender];
        require(operator.operator_rate > 0, "Only operator");
        require(operator.merchant_rate == 0, "Merchant is already set");
        require(merchant_rate >= 7e6, "Less than minimum merchant rate - 7%");
        operator.merchant = merchant;
        merchant_to_operator[merchant] = msg.sender;
        operator.merchant_rate = merchant_rate;
        emit Set_Merchant(msg.sender, merchant, merchant_rate);
    }


    function _transfer(address sender, address recipient, uint amount) internal override(BEP20) {
        uint tx_fee_amount = tx_fee_rate * amount / 1e8;
        super._transfer(sender, recipient, amount - tx_fee_amount);
        super._transfer(sender, recipient, tx_fee_amount);
    }

    function harvest() external {
        Merchant storage merchant = merchant_info[msg.sender];
        uint currentDate = block.timestamp / 3600 / 24;
        uint release_length = merchant.releaseDates.length;
        uint i = merchant.releasedIndex + 1;
        for(; i < release_length; i ++) {
            if(merchant.releaseDates[i] > currentDate)
                break;
        }
        require(merchant.releasedIndex + 1 < i, "Nothing to harvest");
        uint releasedAmount = merchant.releaseAmounts[merchant.releasedIndex];
        uint pendingAmount = merchant.releaseAmounts[i - 1] - releasedAmount;
        JAXRE.transfer(msg.sender, pendingAmount);
        merchant.releasedIndex = i - 1;
        emit Harvest(msg.sender);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.11;

import "@openzeppelin/contracts/access/Ownable.sol";

import "./IBEP20.sol";

contract BEP20 is Ownable, IBEP20 {
    mapping (address => uint256) _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

   constructor (string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
        _decimals = 18;
    }

   function name() public view override returns (string memory) {
        return _name;
    }

    function symbol() public view override returns (string memory) {
        return _symbol;
    }

   function decimals() public view override returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

   function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

   function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "BEP20: transfer amount exceeds allowance");
        _approve(sender, _msgSender(), currentAllowance - amount);

        return true;
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "BEP20: decreased allowance below zero");
        _approve(_msgSender(), spender, currentAllowance - subtractedValue);

        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "BEP20: transfer from the zero address");
        require(recipient != address(0), "BEP20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "BEP20: transfer amount exceeds balance");
        _balances[sender] = senderBalance - amount;
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);
    }

    function mint(address account, uint256 amount) public {
        _mint(account, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "BEP20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
    }

    function burn(uint256 amount) public virtual {
        _burn(_msgSender(), amount);
    }

    function burnFrom(address account, uint256 amount) public virtual {
      uint256 currentAllowance = allowance(account, _msgSender());
      require(currentAllowance >= amount, "BEP20: burn amount exceeds allowance");
      _approve(account, _msgSender(), currentAllowance - amount);
      _burn(account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "BEP20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "BEP20: burn amount exceeds balance");
        _balances[account] = accountBalance - amount;
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "BEP20: approve from the zero address");
        require(spender != address(0), "BEP20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _setupDecimals(uint8 decimals_) internal {
        _decimals = decimals_;
    }

   function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.11;

/**
 * @dev Interface of the BEP standard.
 */
interface IERC20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function getOwner() external view returns (address);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
    function allowance(address _owner, address spender) external view returns (uint256);
    function mint(address account, uint256 amount) external;
    function burnFrom(address account, uint256 amount) external;
    
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

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
        return _owner;
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
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.11;

/**
 * @dev Interface of the BEP standard.
 */
interface IBEP20 {

    /**
     * @dev Returns the token name.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the token symbol.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the token decimals.
     */
    function decimals() external view returns (uint8);

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

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
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address _owner, address spender) external view returns (uint256);

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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}