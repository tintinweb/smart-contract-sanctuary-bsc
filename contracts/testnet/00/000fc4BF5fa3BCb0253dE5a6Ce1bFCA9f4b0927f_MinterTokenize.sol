// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.7.0 <0.9.0;
import "./RealEstateToken.sol";
import "./Launchpad.sol";
// import "./StakePool.sol";

import "./libs/Ownable.sol";

contract MinterTokenize is Ownable {
    IBEP20 private _MEY;
    address private _meyWallet;
    constructor(IBEP20 meyToken, address mMeyWallet){
        _MEY = meyToken;
        _meyWallet = mMeyWallet;
    }

    function mintToken(
        string memory mName,
        string memory mSymbol,
        uint256 mTotalSupply
        ) public returns (RealEstateToken) {
        RealEstateToken token = new RealEstateToken(
            mName,
            mSymbol,
            mTotalSupply,
            18,
            address(this)
        );
        token.transferOwnership(_msgSender()); // setup owner
        token.grantRole(0x00, _meyWallet); // setup role
        return token;
    }

    function mintLaunchpad(
        IBEP20 token,
        uint256 openTime,
        uint256 endTime,
        uint256 minBuy,
        uint256 maxBuy,
        uint256 minSpend,
        uint256 mAmount, // số lượng bán
        address beneficiary // chủ sở hữu bds
    ) public returns (Launchpad) {
        Launchpad lp = new Launchpad(
            _MEY,
            token,
            beneficiary,
            openTime,
            endTime,
            minBuy,
            maxBuy,
            minSpend,
            _meyWallet
        );
        lp.transferOwnership(_msgSender()); // setup owner
        lp.grantRole(0x00, _meyWallet); // setup role

        // chuyển token vào pool
        token.transfer(address(lp), mAmount);
        return lp;
    }

    // function mintStakePool(IBEP20 token, uint256 openTime, uint256 endTime, uint16 apr, uint256 poolReward) public returns(StakePool){
    //     StakePool sp = new StakePool(token, openTime, endTime, apr, poolReward);
    //     sp.transferOwnership(_msgSender()); // setup owner
    //     sp.grantRole(0x00, _meyWallet); // setup role
    //     return sp;
    // }

    function setMey(IBEP20 mMEY) public onlyOwner {
        _MEY = mMEY;
    }

    function setMeyWallet(address mMeyWallet) public onlyOwner {
        _meyWallet = mMeyWallet;
    }

    function withdrawFunds(IBEP20 token, address beneficiary) public onlyOwner {
        token.transfer(beneficiary, token.balanceOf(address(this)));
    }

}

// SPDX-License-Identifier: UNLICENSED

pragma solidity >=0.7.0 <0.9.0;

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
library SafeMath {
  /**
   * @dev Returns the addition of two unsigned integers, reverting on
   * overflow.
   *
   * Counterpart to Solidity's `+` operator.
   *
   * Requirements:
   * - Addition cannot overflow.
   */
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a, "SafeMath: addition overflow");

    return c;
  }

  /**
   * @dev Returns the subtraction of two unsigned integers, reverting on
   * overflow (when the result is negative).
   *
   * Counterpart to Solidity's `-` operator.
   *
   * Requirements:
   * - Subtraction cannot overflow.
   */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    return sub(a, b, "SafeMath: subtraction overflow");
  }

  /**
   * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
   * overflow (when the result is negative).
   *
   * Counterpart to Solidity's `-` operator.
   *
   * Requirements:
   * - Subtraction cannot overflow.
   */
  function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    require(b <= a, errorMessage);
    uint256 c = a - b;

    return c;
  }

  /**
   * @dev Returns the multiplication of two unsigned integers, reverting on
   * overflow.
   *
   * Counterpart to Solidity's `*` operator.
   *
   * Requirements:
   * - Multiplication cannot overflow.
   */
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
    // benefit is lost if 'b' is also tested.
    // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
    if (a == 0) {
      return 0;
    }

    uint256 c = a * b;
    require(c / a == b, "SafeMath: multiplication overflow");

    return c;
  }

  /**
   * @dev Returns the integer division of two unsigned integers. Reverts on
   * division by zero. The result is rounded towards zero.
   *
   * Counterpart to Solidity's `/` operator. Note: this function uses a
   * `revert` opcode (which leaves remaining gas untouched) while Solidity
   * uses an invalid opcode to revert (consuming all remaining gas).
   *
   * Requirements:
   * - The divisor cannot be zero.
   */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    return div(a, b, "SafeMath: division by zero");
  }

  /**
   * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
   * division by zero. The result is rounded towards zero.
   *
   * Counterpart to Solidity's `/` operator. Note: this function uses a
   * `revert` opcode (which leaves remaining gas untouched) while Solidity
   * uses an invalid opcode to revert (consuming all remaining gas).
   *
   * Requirements:
   * - The divisor cannot be zero.
   */
  function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    // Solidity only automatically asserts when dividing by 0
    require(b > 0, errorMessage);
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold

    return c;
  }

  /**
   * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
   * Reverts when dividing by zero.
   *
   * Counterpart to Solidity's `%` operator. This function uses a `revert`
   * opcode (which leaves remaining gas untouched) while Solidity uses an
   * invalid opcode to revert (consuming all remaining gas).
   *
   * Requirements:
   * - The divisor cannot be zero.
   */
  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    return mod(a, b, "SafeMath: modulo by zero");
  }

  /**
   * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
   * Reverts with custom message when dividing by zero.
   *
   * Counterpart to Solidity's `%` operator. This function uses a `revert`
   * opcode (which leaves remaining gas untouched) while Solidity uses an
   * invalid opcode to revert (consuming all remaining gas).
   *
   * Requirements:
   * - The divisor cannot be zero.
   */
  function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    require(b != 0, errorMessage);
    return a % b;
  }
}

// SPDX-License-Identifier: UNLICENSED

pragma solidity >=0.7.0 <0.9.0;

import "./Context.sol";
import "./AccessControl.sol";

contract Ownable is Context, AccessControl {
  address private _owner;
  bool private _isPaused = false;

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  /**
   * @dev Initializes the contract setting the deployer as the initial owner.
   */
  constructor ()  {
    address msgSender = _msgSender();
    _owner = msgSender;
    emit OwnershipTransferred(address(0), msgSender);
  }

  /**
   * @dev Returns the address of the current owner.
   */
  function owner() public view returns (address) {
    return _owner;
  }

  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(_owner == _msgSender(), "Ownable: caller is not the owner");
    _;
  }

  modifier paused() {
    require(_isPaused == false, "Ownable: contract paused");
    _;
  }

  function pause() public virtual onlyOwner{
    _isPaused = true;
  }

  function unpause() public virtual onlyOwner{
    _isPaused = false;
  }

  function setOwner(address newOwner)  public onlyRole(DEFAULT_ADMIN_ROLE){
      _transferOwnership(newOwner);
  }

  function renounceOwnership() public virtual onlyOwner {
    emit OwnershipTransferred(_owner, address(0));
    _owner = address(0);
  }

  function transferOwnership(address newOwner) public virtual onlyOwner {
    _transferOwnership(newOwner);
  }

  function _transferOwnership(address newOwner) internal virtual {
    require(newOwner != address(0), "Ownable: new owner is the zero address");
    emit OwnershipTransferred(_owner, newOwner);
    _owner = newOwner;
  }
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.7.0 <0.9.0;

import "./Ownable.sol";
import "./IBEP20.sol";
import "./AccessControl.sol";


contract Liquify is Ownable{
  constructor(){
    _grantRole(DEFAULT_ADMIN_ROLE, _msgSender());
  }

  receive() external payable {}

  function withdrawFunds(uint256 amount) external onlyRole(DEFAULT_ADMIN_ROLE) {
    payable(owner()).transfer(amount);
  }
  
  function withdrawTokens(address _tokenContract, uint256 _amount) external onlyRole(DEFAULT_ADMIN_ROLE) {
    IBEP20(_tokenContract).transfer(owner(), _amount);
  }
}

// SPDX-License-Identifier: UNLICENSED

pragma solidity >=0.7.0 <0.9.0;

interface IBEP20 {
  /**
   * @dev Returns the amount of tokens in existence.
   */
  function totalSupply() external view returns (uint256);

  /**
   * @dev Returns the token decimals.
   */
  function decimals() external view returns (uint8);

  /**
   * @dev Returns the token symbol.
   */
  function symbol() external view returns (string memory);

  /**
   * @dev Returns the token name.
   */
  function name() external view returns (string memory);

  /**
   * @dev Returns the bep token owner.
   */
  function getOwner() external view returns (address);

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
  function allowance(address _owner, address spender) external view returns (uint256);

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
  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

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

// SPDX-License-Identifier: UNLICENSED

pragma solidity >=0.7.0 <0.9.0;

contract Context {
  constructor ()  { }

  function _msgSender() internal view virtual returns (address ) {
    return msg.sender;
  }

  function _msgData() internal view virtual returns (bytes memory) {
    this; 
    return msg.data;
  }
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.4.22 <0.9.0;

abstract contract AccessControl{
    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    struct RoleData {
        mapping(address => bool) members;
    }

    mapping(bytes32 => RoleData) private _roles;

    modifier onlyRole(bytes32 role) {
      require(hasRole(role, msg.sender), "AccessControl: Restricted to members.");
      _;
    }


    function hasRole(bytes32 role, address account) public view virtual returns (bool) {
      return _roles[role].members[account];
    }

    function grantRole(bytes32 role, address account) public virtual onlyRole(DEFAULT_ADMIN_ROLE) {
      _grantRole(role, account);
    }

    function revokeRole(bytes32 role, address account) public virtual onlyRole(DEFAULT_ADMIN_ROLE) {
      _revokeRole(role, account);
    }

    function renounceRole(bytes32 role, address account) public virtual {
        require(account == msg.sender, "AccessControl: can only renounce roles for self");
        _revokeRole(role, account);
    }

    function _grantRole(bytes32 role, address account) internal virtual {
      if (!hasRole(role, account)) {
        _roles[role].members[account] = true;
      }
    }

    function _revokeRole(bytes32 role, address account) internal virtual {
      if (hasRole(role, account)) {
        _roles[role].members[account] = false;
      }
    }
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.7.0 <0.9.0;

import "./libs/Liquify.sol";
import "./libs/IBEP20.sol";
import "./libs/SafeMath.sol";

contract RealEstateToken is IBEP20, Ownable, Liquify {
    using SafeMath for uint256;

    mapping(address => uint256) private _balances;
    mapping(address => uint256) private _balanceLocks;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 internal _totalSupply;
    uint8 internal _decimals;
    string internal _symbol;
    string internal _name;
    string internal _baseUri;

    constructor(
        string memory mName,
        string memory mSymbol,
        uint256 mTotalSupply,
        uint8 mDecimals,
        address beneficiary
    ) {
        _name = mName;
        _symbol = mSymbol;
        _totalSupply = mTotalSupply;
        _decimals = mDecimals;
        _balances[beneficiary] = mTotalSupply;
        
        emit Transfer(address(0), beneficiary, _totalSupply);
    }

    function getOwner() external view override returns (address) {
        return owner();
    }

    function decimals() external view override returns (uint8) {
        return _decimals;
    }

    function symbol() external view override returns (string memory) {
        return _symbol;
    }

    function name() external view override returns (string memory) {
        return _name;
    }

    function totalSupply() external view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account)
        external
        view
        override
        returns (uint256)
    {
        return _balances[account].add(_balanceLocks[account]);
    }

    function balanceLockOf(address account) external view returns (uint256) {
        return _balanceLocks[account];
    }

    function transfer(address recipient, uint256 amount)
        external
        override
        returns (bool)
    {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender)
        external
        view
        override
        returns (uint256)
    {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount)
        external
        override
        returns (bool)
    {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(
            sender,
            _msgSender(),
            _allowances[sender][_msgSender()].sub(
                amount,
                "BEP20: transfer amount exceeds allowance"
            )
        );
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue)
        public
        returns (bool)
    {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender].add(addedValue)
        );
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        returns (bool)
    {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender].sub(
                subtractedValue,
                "BEP20: decreased allowance below zero"
            )
        );
        return true;
    }

    function mint(uint256 amount) public onlyRole(DEFAULT_ADMIN_ROLE) returns (bool) {
        _mint(_msgSender(), amount);
        return true;
    }

    function burn(address account, uint256 amount) public onlyRole(DEFAULT_ADMIN_ROLE) returns (bool) {
        _burn(account, amount);
        return true;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal paused {
        require(sender != address(0), "BEP20: transfer from the zero address");
        require(recipient != address(0), "BEP20: transfer to the zero address");

        _balances[sender] = _balances[sender].sub(
            amount,
            "BEP20: transfer amount exceeds balance"
        );
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "BEP20: mint to the zero address");

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal {
        require(account != address(0), "BEP20: burn from the zero address");

        _balances[account] = _balances[account].sub(
            amount,
            "BEP20: burn amount exceeds balance"
        );
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal {
        require(owner != address(0), "BEP20: approve from the zero address");
        require(spender != address(0), "BEP20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function lockAmount(address account, uint256 amount) public onlyOwner {
        _balances[account] = _balances[account].sub(
            amount,
            "BEP20: lock amount exceeds balance"
        );
        _balanceLocks[account] = _balanceLocks[account].add(amount);
    }

    function unlockAmount(address account, uint256 amount) public onlyOwner {
        _balanceLocks[account] = _balanceLocks[account].sub(
            amount,
            "BEP20: unlock amount exceeds balance"
        );
        _balances[account] = _balances[account].add(amount);
    }

    function baseUri() public view onlyOwner returns (string memory) {
        return _baseUri;
    }

    function setBaseUri(string memory nbaseUri) public onlyOwner {
        _baseUri = nbaseUri;
    }
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.4.22 <0.9.0;

import "./libs/Liquify.sol";
import "./libs/IBEP20.sol";

contract Launchpad is Liquify {
    // EVENT
    event Bought(address from, address to, uint256 amount, uint256 amountStablecoin);
    event Spended(address account, uint256 amount);

    struct Description {
        uint256 openTime;
        uint256 endTime;
        uint256 minBuy;
        uint256 maxBuy;
        uint256 minSpend; // số mey sẽ tiêu
        uint8 totalSpended; // tô
        uint8 maxWhitelist;
        uint256 totalSelled;
        uint256 timeOpenPreSale; // thời gian mở bán trước
    }

    // var
    IBEP20 private _token;
    mapping(address => uint256) private _stablecoinSupportRate;
    mapping(address => bool) private _whitelists;
    IBEP20 private _MEY; // meytoken
    Description private _description;
    address private _meyWallet; // ví nhận $

    //var: public
    address public beneficiary; // ví chủ bất động sản

    constructor(
        IBEP20 mMEY,
        IBEP20 token,
        address mBeneficiary,  // chủ bất động sản
        uint256 openTime,
        uint256 endTime,
        uint256 minBuy,
        uint256 maxBuy,
        uint256 minSpend,
        address meyWallet  // ví meychain
    ) {
        _MEY = mMEY;
        _token = token;
        _description.openTime = openTime;
        _description.endTime = endTime;
        _description.minBuy = minBuy;
        _description.maxBuy = maxBuy;
        _description.minSpend = minSpend;
        _description.maxWhitelist = 40;
        _description.timeOpenPreSale = 259200;

        _meyWallet = meyWallet;

        beneficiary = mBeneficiary;
    }

    // tiêu mey
    function spendMey() public paused {
        // check time spend
        require(_description.openTime > block.timestamp || _description.totalSpended < _description.maxWhitelist, "Launchpad: add whitelist has ended");
        require(
            !_whitelists[_msgSender()],
            "Launchpad: you are already on the whitelist"
        );

        uint256 amount = _description.minSpend;
        _MEY.transferFrom(_msgSender(), _meyWallet, amount); // gửi vào tài khoản meychain
        //  thêm whitelist
        _whitelists[_msgSender()] = true;
        _description.totalSpended =  _description.totalSpended + 1; 
        emit Spended(_msgSender(), amount);
    }

    // mua usdt
    function buy(uint256 amount, address stablecoinSupport) public paused {
        require(
            _stablecoinSupportRate[stablecoinSupport] != 0,
            "Launchpad: stablecoin is not supporting"
        );

        require(_description.minBuy <= amount && amount <= _description.maxBuy, "Launchpad: Invalid amount");

        uint256 milis = block.timestamp;
        require(_description.endTime >= milis, "Launchpad: sale is ended");

        // check time
        if (_description.openTime > milis) {
            // chưa đến giờ mở bán chính thức
            // kiểm tra đến giờ mở bán trước chưa
            require(
                _description.openTime - _description.timeOpenPreSale <= milis &&
                    _whitelists[_msgSender()],
                "Launchpad: not yet open for sale"
            );
        }
        require(
            _token.balanceOf(address(this)) >=
                _description.totalSelled + amount,
            "Launchpad: sold out"
        );

        // trade amount => stablecoinSupport
        uint256 amountStablecoin = _stablecoinSupportRate[stablecoinSupport] *
            amount;

        // chuyển stablecoin vào ví meychain
        IBEP20(stablecoinSupport).transferFrom(
            _msgSender(),
            _meyWallet,
            amountStablecoin
        );

        uint256 tokenAmount = amount * 1e18;

        _token.transfer(_msgSender(), tokenAmount);  // gửi token cho người dùng
        _description.totalSelled = _description.totalSelled + tokenAmount; // tổng đã bán 

        emit Bought(_msgSender(), beneficiary, tokenAmount, amountStablecoin);
    }

    // get description
    function description() public view returns (Description memory) {
        return _description;
    }

    function whitelistOf(address wallet) public view returns (bool) {
        return _whitelists[wallet];
    }

    // ADMIN option
    function setDescription(Description memory mDescription) public onlyOwner {
        _description = mDescription;
    }

    function setMinBuy(uint256 min) public onlyOwner {
        _description.minBuy = min;
    }

    function setMaxBuy(uint256 max) public onlyOwner {
        _description.maxBuy = max;
    }

    function setOpenTime(uint256 mOpentime) public onlyOwner {
        _description.openTime = mOpentime;
    }

    function setEndTime(uint256 mEndtime) public onlyOwner {
        _description.endTime = mEndtime;
    }

    function setMinSpend(uint256 mMinSpend) public onlyOwner {
        _description.minSpend = mMinSpend;
    }
    
    function setMaxWhitelist(uint8 mMaxWhitelist) public onlyOwner {
        _description.maxWhitelist = mMaxWhitelist;
    }

      function setTimeOpenPreSale(uint256 mTimeOpenPreSale) public onlyOwner {
        _description.timeOpenPreSale = mTimeOpenPreSale;
    }


    function setMey(IBEP20 mMEY) public onlyOwner {
        _MEY = mMEY;
    }

    function addStablecointSupport(address token, uint256 rate)
        public
        onlyOwner
    {
        _stablecoinSupportRate[token] = rate;
    }

    function removeStablecointSupport(address token) public onlyOwner {
        _stablecoinSupportRate[token] = 0;
    }
}