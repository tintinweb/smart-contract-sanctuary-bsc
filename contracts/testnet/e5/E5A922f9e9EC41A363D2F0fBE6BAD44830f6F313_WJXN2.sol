// SPDX-License-Identifier: MIT

pragma solidity 0.8.11;

import "./lib/BEP20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "./JaxProtection.sol";


interface IJaxPlanet {

  struct Colony {
    uint128 level;
    uint128 transaction_tax;
    bytes32 _policy_hash;
    string _policy_link;
  }

  function ubi_tax_wallet() external view returns (address);
  function ubi_tax() external view returns (uint);
  function jaxcorp_dao_wallet() external view returns (address);
  function getMotherColonyAddress(address) external view returns(address);
  function getColony(address addr) external view returns(Colony memory);
  function getUserColonyAddress(address user) external view returns(address);
}

interface IJaxAdmin {
  
  function userIsAdmin (address _user) external view returns (bool);
  function userIsAjaxPrime (address _user) external view returns (bool);

  function jaxSwap() external view returns (address);
  function jaxPlanet() external view returns (address);

  function system_status() external view returns (uint);

  function blacklist(address _user) external view returns (bool);
  function fee_freelist(address _user) external view returns (bool);
} 

/**
* @title WJXN2
* @dev Implementation of WJXN with mint function and 8 decimals.
*/
contract WJXN2 is BEP20, JaxProtection {
  
  using SafeERC20 for IERC20;

  IJaxAdmin public jaxAdmin;
  IERC20 wjxn = IERC20(0xBC04b1cEEE41760CBd84d3D58Db57a13c95B8107);
  address[] public gateKeepers;

  // transaction fee
  uint public transaction_fee = 0;
  uint public transaction_fee_cap = 0;

  uint public referral_fee = 0;
  uint public referrer_amount_threshold = 0;
  uint public cashback = 0; // Cashback has 8 decimals

  bool public fee_disabled = false;

  struct Colony {
    uint128 level;
    uint128 transaction_tax;
    bytes32 _policy_hash;
    string _policy_link;
  }

  address public tx_fee_wallet;
  
  mapping (address => address) public referrers;

  struct GateKeeper {
    uint mintLimit;
  }

  mapping (address => GateKeeper) gateKeeperInfo;

  event Set_Jax_Admin(address jax_admin);
  event Set_Gate_Keepers(address[] gate_keepers);
  event Set_Mint_Limit(address gateKeeper, uint mintLimit);
  event Set_Transaction_Fee(uint transaction_fee, uint trasnaction_fee_cap, address transaction_fee_wallet);
  event Set_Referral_Fee(uint referral_fee, uint referral_amount_threshold);
  event Set_Cashback(uint cashback_percent);
  event Disable_Fees(bool flag);

  /**
    * @dev Sets the value of the `cap`. This value is immutable, it can only be
    * set once during construction.
    */
    
  constructor ()
      BEP20("Wrapped JAXNET 2", "WJXN-2")
  {
      _setupDecimals(8);
      tx_fee_wallet = msg.sender;
  }

  modifier onlyJaxAdmin() {
    require(msg.sender == address(jaxAdmin), "Only JaxAdmin Contract");
    _;
  }

  modifier onlyAjaxPrime() {
    require(jaxAdmin.userIsAjaxPrime(msg.sender) || msg.sender == owner(), "Only AjaxPrime can perform this operation.");
    _;
  }

  modifier onlyGateKeeper(address account) {
    uint cnt = gateKeepers.length;
    uint index = 0;
    for(; index < cnt; index += 1) {
      if(gateKeepers[index] == account)
        break;
    }
    require(index < cnt, "Only GateKeeper can perform this action");
    _;
  }

  
  modifier notFrozen() {
    require(jaxAdmin.system_status() > 0, "Transactions have been frozen.");
    _;
  }

  function setJaxAdmin(address newJaxAdmin) external onlyOwner {
    jaxAdmin = IJaxAdmin(newJaxAdmin);  
    emit Set_Jax_Admin(newJaxAdmin);
  }

  function setGateKeepers(address[] calldata newGateKeepers) external onlyAjaxPrime runProtection {
    uint cnt = newGateKeepers.length;
    delete gateKeepers;
    for(uint index = 0; index < cnt; index += 1) {
      gateKeepers.push(newGateKeepers[index]);
    }
    emit Set_Gate_Keepers(newGateKeepers);
  }

  function setMintLimit(address gateKeeper, uint mintLimit) external onlyAjaxPrime onlyGateKeeper(gateKeeper) runProtection {
    GateKeeper storage info = gateKeeperInfo[gateKeeper];
    info.mintLimit = mintLimit;
    emit Set_Mint_Limit(gateKeeper, mintLimit);
  }

  function setTransactionFee(uint txFee, uint txFeeCap, address wallet) external onlyJaxAdmin {
      require(txFee <= 1e8 * 3 / 100 , "Tx Fee percent can't be more than 3.");
      require(wallet != address(0x0), "Only non-zero address");
      transaction_fee = txFee;
      transaction_fee_cap = txFeeCap;
      tx_fee_wallet = wallet;
      emit Set_Transaction_Fee(txFee, txFeeCap, wallet);
  }

  /**
    * @dev Set referral fee and minimum amount that can set sender as referrer
    */
  function setReferralFee(uint newReferralFee, uint newReferrerAmountThreshold) external onlyJaxAdmin {
      require(newReferralFee <= 1e8 * 50 / 100 , "Referral Fee percent can't be more than 50.");
      referral_fee = newReferralFee;
      referrer_amount_threshold = newReferrerAmountThreshold;
      emit Set_Referral_Fee(newReferralFee, newReferrerAmountThreshold);
  }

  /**
    * @dev Set cashback
    */
  function setCashback(uint newCashback) external onlyJaxAdmin {
      require(newCashback <= 1e8 * 30 / 100 , "Cashback percent can't be more than 30.");
      cashback = newCashback; // Cashback has 8 decimals
      emit Set_Cashback(newCashback);
  }

  function transfer(address recipient, uint amount) public override(BEP20) notFrozen returns (bool) {
    _transfer(msg.sender, recipient, amount);
    return true;
  } 

  function transferFrom(address sender, address recipient, uint amount) public override(BEP20) notFrozen returns (bool) {
    _transfer(sender, recipient, amount);
    uint currentAllowance = allowance(sender, msg.sender);
    require(currentAllowance >= amount, "BEP20: transfer amount exceeds allowance");
    _approve(sender, msg.sender, currentAllowance - amount);
    return true;
  } 

  function _transfer(address sender, address recipient, uint amount) internal override(BEP20) {
    require(!jaxAdmin.blacklist(sender), "sender is blacklisted");
    require(!jaxAdmin.blacklist(recipient), "recipient is blacklisted");
    if(amount == 0) return;
    if(jaxAdmin.fee_freelist(msg.sender) || jaxAdmin.fee_freelist(recipient) || fee_disabled) {
        return super._transfer(sender, recipient, amount);
    }
    if(referrers[sender] == address(0)) {
        referrers[sender] = address(0xdEaD);
    }

    // Calculation of transaction fee
    uint tx_fee_amount = amount * transaction_fee / 1e8;

    if(tx_fee_amount > transaction_fee_cap) {
        tx_fee_amount = transaction_fee_cap;
    }
    
    address referrer = referrers[recipient];
    uint totalreferral_fees = 0;
    uint maxreferral_fee = tx_fee_amount * referral_fee;

    IJaxPlanet jaxPlanet = IJaxPlanet(jaxAdmin.jaxPlanet());
    
    // Calculation of UBI amount       
    uint ubi_tax_amount = amount * jaxPlanet.ubi_tax() / 1e8;

    address colony_address = jaxPlanet.getUserColonyAddress(recipient);

    if(colony_address == address(0)) {
        colony_address = jaxPlanet.getMotherColonyAddress(recipient);
    }
    
    // Transfer transaction tax to colonies.
    // immediate colony will get 50% of transaction tax, mother of that colony will get 25% ... mother of 4th colony will get 3.125%
    // 3.125% of transaction tax will go to JaxCorp Dao public key address.
    uint tx_tax_amount = amount * jaxPlanet.getColony(colony_address).transaction_tax / 1e8;     // Calculate transaction tax amount
   
    // Transfer tokens to recipient. recipient will pay the fees.
    require( amount > (tx_fee_amount + ubi_tax_amount + tx_tax_amount), "Total fee is greater than the transfer amount");
    super._transfer(sender, recipient, amount - tx_fee_amount - ubi_tax_amount - tx_tax_amount);

    // Transfer transaction fee to transaction fee wallet
    // Sender will get cashback.
    if( tx_fee_amount > 0){
        uint cashback_amount = (tx_fee_amount * cashback / 1e8);
        if(cashback_amount > 0)
          super._transfer(sender, sender, cashback_amount);
        
        // Transfer referral fees to referrers (70% to first referrer, each 10% to other referrers)
        if( maxreferral_fee > 0 && referrer != address(0xdEaD) && referrer != address(0)){

            super._transfer(sender, referrer, 70 * maxreferral_fee / 1e8 / 100);
            referrer = referrers[referrer];
            totalreferral_fees += 70 * maxreferral_fee / 1e8 / 100;
            if( referrer != address(0xdEaD) && referrer != address(0)){
                super._transfer(sender, referrer, 10 * maxreferral_fee / 1e8 / 100);
                referrer = referrers[referrer];
                totalreferral_fees += 10 * maxreferral_fee / 1e8 / 100;
                if( referrer != address(0xdEaD) && referrer != address(0)){
                    super._transfer(sender, referrer, 10 * maxreferral_fee / 1e8 / 100);
                    referrer = referrers[referrer];
                    totalreferral_fees += 10 * maxreferral_fee / 1e8 / 100;
                    if( referrer != address(0xdEaD) && referrer != address(0)){
                        super._transfer(sender, referrer, 10 * maxreferral_fee / 1e8 / 100);
                        referrer = referrers[referrer];
                        totalreferral_fees += 10 * maxreferral_fee / 1e8 / 100;
                    }
                }
            }
        }
        super._transfer(sender, tx_fee_wallet, tx_fee_amount - totalreferral_fees - cashback_amount);
    }
    
    if(ubi_tax_amount > 0){
        super._transfer(sender, jaxPlanet.ubi_tax_wallet(), ubi_tax_amount);  // ubi tax
    }
     
    // transferTransactionTax(mother_colony_addresses[recipient], tx_tax_amount, 1);          
    // Transfer tax to colonies and jaxCorp Dao
    // Optimize transferTransactionTax by using loop instead of recursive function

    if( tx_tax_amount > 0 ){
        uint level = 1;
        uint tx_tax_temp = tx_tax_amount;
        
        // Level is limited to 5
        while( colony_address != address(0) && level++ <= 5 ){
            super._transfer(sender, colony_address, tx_tax_temp / 2);
            colony_address = jaxPlanet.getMotherColonyAddress(colony_address);
            tx_tax_temp = tx_tax_temp / 2;            
        }

        // transfer remain tx_tax to jaxcorpDao
        super._transfer(sender, jaxPlanet.jaxcorp_dao_wallet(), tx_tax_temp);
    }


    // set referrers as first sender when transferred amount exceeds the certain limit.
    // recipient mustn't be sender's referrer, recipient couldn't be referrer itself
    if( recipient != sender  && amount >= referrer_amount_threshold  && referrers[recipient] == address(0)) {
        referrers[recipient] = sender;

    }
  }

  function mint(address account, uint amount) external notFrozen onlyGateKeeper(msg.sender) {
    require(!jaxAdmin.blacklist(account), "account is blacklisted");
    GateKeeper storage gateKeeper = gateKeeperInfo[msg.sender];
    require(gateKeeper.mintLimit >= amount, "Mint amount exceeds limit");
    super._mint(account, amount);
    gateKeeper.mintLimit -= amount;
  }

  function swapWjxnToWjxn2(uint amountIn) external {
    wjxn.safeTransferFrom(msg.sender, address(this), amountIn);
    super._mint(msg.sender, amountIn * (10 ** decimals()));
  }

  function swapWjxn2ToWjxn(uint amountOut) external {
    super._burn(msg.sender, amountOut * (10 ** decimals()));
    wjxn.safeTransfer(msg.sender, amountOut);
  }

  function disableFees(bool flag) external onlyAjaxPrime runProtection {
    fee_disabled = flag;
    emit Disable_Fees(flag);
  }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.11;

import "@openzeppelin/contracts/access/Ownable.sol";

import "./IBEP20.sol";

contract BEP20 is Ownable, IBEP20 {
    mapping (address => uint256) private _balances;

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
// OpenZeppelin Contracts v4.4.0 (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";
import "../../../utils/Address.sol";

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.0 (proxy/utils/Initializable.sol)

pragma solidity ^0.8.0;

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since a proxied contract can't have a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {ERC1967Proxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 *
 * [CAUTION]
 * ====
 * Avoid leaving a contract uninitialized.
 *
 * An uninitialized contract can be taken over by an attacker. This applies to both a proxy and its implementation
 * contract, which may impact the proxy. To initialize the implementation contract, you can either invoke the
 * initializer manually, or you can include a constructor to automatically mark it as initialized when it is deployed:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * /// @custom:oz-upgrades-unsafe-allow constructor
 * constructor() initializer {}
 * ```
 * ====
 */
abstract contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     */
    bool private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Modifier to protect an initializer function from being invoked twice.
     */
    modifier initializer() {
        require(_initializing || !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.11;

contract JaxProtection {

    struct RunProtection {
        bytes32 data_hash;
        uint64 request_timestamp;
        address sender;
        bool executed;
    }

    mapping(bytes4 => RunProtection) run_protection_info;

    event Request_Update(bytes4 sig, bytes data);

    modifier runProtection() {
        RunProtection storage protection = run_protection_info[msg.sig];
        bytes32 data_hash = keccak256(msg.data);
        if(data_hash != protection.data_hash || protection.sender != msg.sender) {
        protection.sender = msg.sender;
        protection.data_hash = keccak256(msg.data);
            protection.request_timestamp = uint64(block.timestamp);
            protection.executed = false;
            emit Request_Update(msg.sig, msg.data);
            return;
        }
        require(protection.executed == false, "Already executed");
        require(block.timestamp >= uint(protection.request_timestamp) + 5 minutes, "Running is Locked");
        _;
        protection.executed = true;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.0 (access/Ownable.sol)

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
// OpenZeppelin Contracts v4.4.0 (utils/Context.sol)

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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.0 (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
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
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

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
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.0 (utils/Address.sol)

pragma solidity ^0.8.0;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}