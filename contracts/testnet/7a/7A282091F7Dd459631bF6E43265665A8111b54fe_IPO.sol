// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.7.5;

import './IBEP20.sol';
import '../Libraries/SafeBEP20.sol';
import "../Libraries/SafeERC20.sol";
import '../Libraries/SafeMath.sol';
import '../Modifiers/Ownable.sol';
import "../Modifiers/WorkerTownable.sol";
import '../Modifiers/ReentrancyGuard.sol';

/**
 * Initial Public Offering
 *
 */
contract IPO is ReentrancyGuard, Ownable, WorkerTownable {
  using SafeMath for uint256;
  using SafeBEP20 for IBEP20;
  using SafeERC20 for IERC20;

  // Info of each user.
  struct UserInfo {
    uint256 amountInvestedWhitelist;   // How many tokens the user has invested in whitelist.
    uint256 amountInvestedPublicSale;   // How many tokens the user has invested in public sale.
    uint256 amountToBeClaimed;   // Total amount of tokens to be claimed.
    uint256 amountRemaining;   // Total amount of tokens still remaining to be claimed.
    bool claimed;  // default false
  }

  // The investment token
  address public investmentToken;
  // The project token
  address public projectToken;
  // The timestamp of the whitelist start
  uint256 public startWhitelist;
  // The timestamp of the whitelist end
  uint256 public endWhitelist;
  // The timestamp of the public sale start
  uint256 public startPublicSale;
  // The timestamp of the public sale end
  uint256 public endPublicSale;
  // The timestamp of the claim start
  uint256 public startClaim;
  // The timestamp of the claim end
  uint256 public endClaim;

  //ratio of projectTokens/investmentTokens
  uint256 public ratioNumWhitelist;
  uint256 public ratioDenumWhitelist;
  //max investment per wallet
  uint256 public maxInvestmentWhitelist;
  // total amount of investment tokens need to be raised
  uint256 public raisingAmountWhitelist;
  // total amount of investment tokens that have already raised
  uint256 public investedAmountWhitelist;

  //ratio of projectTokens/investmentTokens
  uint256 public ratioNumPublicSale;
  uint256 public ratioDenumPublicSale;
  //max investment per wallet
  uint256 public maxInvestmentPublicSale;
  // total amount of investment tokens need to be raised
  uint256 public raisingAmountPublicSale;
  // total amount of investment tokens that have already raised
  uint256 public investedAmountPublicSale;

  // total amount of project tokens of lost bonuses
  uint256 public excessProjectTokens;
  // address to burn the excess of project tokens
  address public burnAddress;
  // have been the tokens not sold burned
  bool public excessBurned;

  // address => amount
  mapping (address => UserInfo) public userInfo;
  // participators
  address[] public addressList;
  mapping (address => bool) private whitelist;

  event Invest(address indexed user, uint256 amount);
  event Claim(address indexed user, uint256 amount);

  constructor(
    address _investmentToken,
    address _projectToken,
    uint256 _startWhitelist,
    uint256 _endWhitelist,
    uint256 _startPublicSale,
    uint256 _endPublicSale,
    uint256 _startClaim,
    uint256 _endClaim,
    uint256 _ratioNumWhitelist,
    uint256 _ratioDenumWhitelist,
    uint256 _maxInvestmentWhitelist,
    uint256 _raisingAmountWhitelist,
    uint256 _ratioNumPublicSale,
    uint256 _ratioDenumPublicSale,
    uint256 _maxInvestmentPublicSale,
    uint256 _raisingAmountPublicSale
  ) {
    investmentToken = _investmentToken;
    projectToken = _projectToken;

    startWhitelist = _startWhitelist;
    endWhitelist = _endWhitelist;
    startPublicSale = _startPublicSale;
    endPublicSale = _endPublicSale;
    startClaim = _startClaim;
    endClaim = _endClaim;

    ratioNumWhitelist = _ratioNumWhitelist;
    ratioDenumWhitelist = _ratioDenumWhitelist;
    maxInvestmentWhitelist = _maxInvestmentWhitelist;
    raisingAmountWhitelist = _raisingAmountWhitelist;
    investedAmountWhitelist = 0;

    ratioNumPublicSale = _ratioNumPublicSale;
    ratioDenumPublicSale = _ratioDenumPublicSale;
    maxInvestmentPublicSale = _maxInvestmentPublicSale;
    raisingAmountPublicSale = _raisingAmountPublicSale;
    investedAmountPublicSale = 0;

    excessProjectTokens = 0;
    burnAddress = address(0xa16856c6CeDf2FAc6A926193E634D20f3b266571);
    excessBurned = false;
  }

  function setStartWhitelist(uint256 _startWhitelist) public onlyOwner {
    startWhitelist = _startWhitelist;
  }

  function setEndWhitelist(uint256 _endWhitelist) public onlyOwner {
    endWhitelist = _endWhitelist;
  }

  function setStartPublicSale(uint256 _startPublicSale) public onlyOwner {
    startPublicSale = _startPublicSale;
  }

  function setEndPublicSale(uint256 _endPublicSale) public onlyOwner {
    endPublicSale = _endPublicSale;
  }

  function setStartClaim(uint256 _startClaim) public onlyOwner {
    startClaim = _startClaim;
  }

  function setEndClaim(uint256 _endClaim) public onlyOwner {
    endClaim = _endClaim;
  }

  function setRatioNumWhitelist(uint256 _ratioNumWhitelist) public onlyOwner {
    ratioNumWhitelist = _ratioNumWhitelist;
  }

  function setRatioDenumWhitelist(uint256 _ratioDenumWhitelist) public onlyOwner {
    ratioDenumWhitelist = _ratioDenumWhitelist;
  }

  function setMaxInvestmentWhitelist(uint256 _maxInvestmentWhitelist) public onlyOwner {
    maxInvestmentWhitelist = _maxInvestmentWhitelist;
  }

  function setRaisingAmountWhitelist(uint256 _raisingAmountWhitelist) public onlyOwner {
    raisingAmountWhitelist = _raisingAmountWhitelist;
  }

  function setRatioNumPublicSale(uint256 _ratioNumPublicSale) public onlyOwner {
    ratioNumPublicSale = _ratioNumPublicSale;
  }

  function setRatioDenumPublicSale(uint256 _ratioDenumPublicSale) public onlyOwner {
    ratioDenumPublicSale = _ratioDenumPublicSale;
  }

  function setMaxInvestmentPublicSale(uint256 _maxInvestmentPublicSale) public onlyOwner {
    maxInvestmentPublicSale = _maxInvestmentPublicSale;
  }

  function setRaisingAmountPublicSale(uint256 _raisingAmountPublicSale) public onlyOwner {
    raisingAmountPublicSale = _raisingAmountPublicSale;
  }

  function isWhitelist(address _address) public view returns(bool) {
    return whitelist[_address];
  }

  function setWhitelist(address _address) external onlyWorkerTown {
    whitelist[_address] = !whitelist[_address];
  }

  function setWhitelist(address[] calldata addrs) external onlyWorkerTown {
    for (uint256 i = 0; i < addrs.length; i++) {
      whitelist[addrs[i]] = !whitelist[addrs[i]];
    }
  }

  function availableToInvest(address user) public view returns(uint256) {
    uint256 maxInvestPerUser = 0;
    if(whitelist[user] && block.timestamp > startWhitelist && block.timestamp < endWhitelist)
    {
      maxInvestPerUser = maxInvestmentWhitelist.sub(userInfo[user].amountInvestedWhitelist);
      maxInvestPerUser = maxInvestPerUser < raisingAmountWhitelist.sub(investedAmountWhitelist) ? maxInvestPerUser : raisingAmountWhitelist.sub(investedAmountWhitelist);
    }
    else if(block.timestamp > startPublicSale && block.timestamp < endPublicSale)
    {
      maxInvestPerUser = maxInvestmentPublicSale.sub(userInfo[user].amountInvestedPublicSale);
      maxInvestPerUser = maxInvestPerUser < raisingAmountPublicSale.sub(investedAmountPublicSale) ? maxInvestPerUser : raisingAmountPublicSale.sub(investedAmountPublicSale);
    }
    return maxInvestPerUser;
  }

  function invest(uint256 _amount) public nonReentrant {
    require (_amount > 0, 'need amount > 0');
    require (_amount <= availableToInvest(msg.sender), 'too much amount');

    IBEP20(investmentToken).safeTransferFrom(address(msg.sender), address(this), _amount);

    if (userInfo[msg.sender].amountToBeClaimed == 0)
    {
      addressList.push(address(msg.sender));
    }

    if(whitelist[msg.sender] && block.timestamp > startWhitelist && block.timestamp < endWhitelist)
    {
      userInfo[msg.sender].amountInvestedWhitelist = userInfo[msg.sender].amountInvestedWhitelist.add(_amount);
      userInfo[msg.sender].amountToBeClaimed = userInfo[msg.sender].amountToBeClaimed.add(_amount.mul(ratioNumWhitelist).div(ratioDenumWhitelist));
      userInfo[msg.sender].amountRemaining = userInfo[msg.sender].amountRemaining.add(_amount.mul(ratioNumWhitelist).div(ratioDenumWhitelist));
      investedAmountWhitelist = investedAmountWhitelist.add(_amount);
    }
    else if(block.timestamp > startPublicSale && block.timestamp < endPublicSale)
    {
      userInfo[msg.sender].amountInvestedPublicSale = userInfo[msg.sender].amountInvestedPublicSale.add(_amount);
      userInfo[msg.sender].amountToBeClaimed = userInfo[msg.sender].amountToBeClaimed.add(_amount.mul(ratioNumPublicSale).div(ratioDenumPublicSale));
      userInfo[msg.sender].amountRemaining = userInfo[msg.sender].amountRemaining.add(_amount.mul(ratioNumPublicSale).div(ratioDenumPublicSale));
      investedAmountPublicSale = investedAmountPublicSale.add(_amount);
    }

    emit Invest(msg.sender, _amount);
  }

  function actualBonus() public view returns (uint) {
      if(block.timestamp > endClaim)
      {
        return 20;
      }
      else if(block.timestamp > startClaim.add((endClaim.sub(startClaim)).mul(3).div(4)))
      {
        return 15;
      }
      else if(block.timestamp > startClaim.add((endClaim.sub(startClaim)).div(2)))
      {
        return 10;
      }
      else if(block.timestamp > startClaim.add((endClaim.sub(startClaim)).mul(1).div(4)))
      {
        return 5;
      }
      else
      {
        return 0;
      }
  }

  function availableToClaim(address _user) public view returns ( uint ) {
    uint256 amountToBeClaimed = userInfo[ _user ].amountToBeClaimed;
    uint256 amountRemaining = userInfo[ _user ].amountRemaining;

    if(!userInfo[ _user ].claimed)
    {
      amountToBeClaimed = amountToBeClaimed.mul(actualBonus().add(100)).div(100);
      amountRemaining = amountToBeClaimed;
    }

    uint harvestingAmount = 0;
    if(startClaim>block.timestamp)
    {
      harvestingAmount = amountToBeClaimed;
    }
    else if(endClaim>block.timestamp)
    {
      harvestingAmount = amountToBeClaimed
      .mul(endClaim.sub(block.timestamp))
      .div(endClaim.sub(startClaim));
    }

    return amountRemaining.sub(harvestingAmount);
  }

  function claim(address _user) public nonReentrant {
    require (block.timestamp > startClaim, 'not claim time');
    require (userInfo[_user].amountToBeClaimed > 0, 'have you participated?');
    require (userInfo[_user].amountRemaining > 0, 'you have nothing left');

    uint transferAmount = availableToClaim(_user);
    require (transferAmount > 0, 'nothing to claim');

    if(!userInfo[_user].claimed)
    {
      if(block.timestamp<endClaim)
      {
        uint maxBonusAmount = userInfo[_user].amountToBeClaimed.mul(120).div(100);
        uint actualBonusAmount = userInfo[_user].amountToBeClaimed.mul(actualBonus().add(100)).div(100);
        excessProjectTokens = excessProjectTokens.add(maxBonusAmount.sub(actualBonusAmount));
      }

      userInfo[_user].amountToBeClaimed = userInfo[_user].amountToBeClaimed.mul(actualBonus().add(100)).div(100);
      userInfo[_user].amountRemaining = userInfo[_user].amountToBeClaimed;
      userInfo[_user].claimed = true;
    }

    IERC20(projectToken).safeTransfer(_user, transferAmount);

    userInfo[_user].amountRemaining = userInfo[_user].amountRemaining.sub(transferAmount);

    emit Claim(_user, transferAmount);
  }

  function burnExcessProjectTokens() public onlyWorkerTown {
    burnExcessProjectTokens(excessProjectTokens);
  }

  function burnExcessProjectTokens(uint256 _amount) public onlyWorkerTown {
    if(!excessBurned && block.timestamp > endWhitelist && block.timestamp > endPublicSale)
    {
      uint256 excessWhitelistTokens = raisingAmountWhitelist.sub(investedAmountWhitelist);
      uint256 excessPublicSaleTokens = raisingAmountPublicSale.sub(investedAmountPublicSale);
      excessProjectTokens = excessProjectTokens.add(excessWhitelistTokens).add(excessPublicSaleTokens);
      excessBurned = true;
    }
    require(_amount <= excessProjectTokens, 'not enough excess of project tokens');
    IBEP20(projectToken).safeTransfer(address(burnAddress), _amount);
    excessProjectTokens = excessProjectTokens.sub(_amount);
  }

  function getAddressListLength() external view returns(uint256) {
    return addressList.length;
  }

  function withdrawInvestmentTokens(uint256 _amount) public onlyWorkerTown {
    require (_amount <= IBEP20(investmentToken).balanceOf(address(this)), 'not enough token');
    require (0 < _amount, 'amount must be > 0');
    IBEP20(investmentToken).safeTransfer(address(msg.sender), _amount);
  }

  function withdrawInvestmentTokens() public onlyWorkerTown {
    require (0 < IBEP20(investmentToken).balanceOf(address(this)), 'not enough token');
    IBEP20(investmentToken).safeTransfer(address(msg.sender), IBEP20(investmentToken).balanceOf(address(this)));
  }

  function withdrawOtherTokens(address _token) public onlyWorkerTown {
    require (_token != projectToken, 'you cannot withdraw the project token');
    require (0 <= IBEP20(_token).balanceOf(address(this)), 'not enough token');
    IBEP20(_token).safeTransfer(address(msg.sender), IBEP20(_token).balanceOf(address(this)));
  }

  function withdrawOtherTokens(address _token, uint256 _amount) public onlyWorkerTown {
    require (_token != projectToken, 'you cannot withdraw the project token');
    require (_amount <= IBEP20(_token).balanceOf(address(this)), 'not enough token');
    IBEP20(_token).safeTransfer(address(msg.sender), _amount);
  }
}

// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.7.5;

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

// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.7.5;

import './SafeMath.sol';
import './Address.sol';
import '../Tokens/IBEP20.sol';

/**
 * @title SafeBEP20
 * @dev Wrappers around BEP20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeBEP20 for IBEP20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeBEP20 {
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(
        IBEP20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IBEP20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IBEP20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IBEP20 token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        // solhint-disable-next-line max-line-length
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            'SafeBEP20: approve from non-zero to non-zero allowance'
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IBEP20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IBEP20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(
            value,
            'SafeBEP20: decreased allowance below zero'
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IBEP20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, 'SafeBEP20: low-level call failed');
        if (returndata.length > 0) {
            // Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), 'SafeBEP20: BEP20 operation did not succeed');
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.7.5;

import '../Libraries/SafeMath.sol';
import '../Libraries/Address.sol';
import '../Tokens/IERC20.sol';

library SafeERC20 {
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {

        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.7.5;

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }

    function sqrrt(uint256 a) internal pure returns (uint c) {
        if (a > 3) {
            c = a;
            uint b = add( div( a, 2), 1 );
            while (b < c) {
                c = b;
                b = div( add( div( a, b ), b), 2 );
            }
        } else if (a != 0) {
            c = 1;
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.7.5;

import "./IOwnable.sol";

contract Ownable is IOwnable {

    address internal _owner;
    address internal _newOwner;

    event OwnershipPushed(address indexed previousOwner, address indexed newOwner);
    event OwnershipPulled(address indexed previousOwner, address indexed newOwner);

    constructor () {
        _owner = msg.sender;
        emit OwnershipPushed( address(0), _owner );
    }

    function owner() public view override returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require( _owner == msg.sender, "Ownable: caller is not the owner" );
        _;
    }

    function renounceManagement() public virtual override onlyOwner() {
        emit OwnershipPushed( _owner, address(0) );
        _owner = address(0);
    }

    function pushManagement( address newOwner_ ) public virtual override onlyOwner() {
        require( newOwner_ != address(0), "Ownable: new owner is the zero address");
        emit OwnershipPushed( _owner, newOwner_ );
        _newOwner = newOwner_;
    }

    function pullManagement() public virtual override {
        require( msg.sender == _newOwner, "Ownable: must be new owner to pull");
        emit OwnershipPulled( _owner, _newOwner );
        _owner = _newOwner;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.7.5;

contract WorkerTownable {

    address internal _worker;

    event WorkershipChanged(address indexed previousWorker, address indexed newWorker);

    constructor () {
        _worker = msg.sender;
        emit WorkershipChanged( address(0), _worker );
    }

    function worker() public view returns (address) {
        return _worker;
    }

    modifier onlyWorkerTown() {
        require( _worker == msg.sender, "Workable: caller is not the worker town" );
        _;
    }

    function changeWorkership( address _newWorker ) public virtual onlyWorkerTown() {
        emit WorkershipChanged( _worker, _newWorker );
        _worker = _newWorker;
    }
}

// File: @openzeppelin/contracts/utils/ReentrancyGuard.sol

// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.7.5;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.7.5;

library Address {

    function isContract(address account) internal view returns (bool) {

        uint256 size;
        // solhint-disable-next-line no-inline-assembly
        assembly { size := extcodesize(account) }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return _functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _functionCallWithValue(address target, bytes memory data, uint256 weiValue, string memory errorMessage) private returns (bytes memory) {
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{ value: weiValue }(data);
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                // solhint-disable-next-line no-inline-assembly
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {
        if (success) {
            return returndata;
        } else {
            if (returndata.length > 0) {

                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }

    function addressToString(address _address) internal pure returns(string memory) {
        bytes32 _bytes = bytes32(uint256(_address));
        bytes memory HEX = "0123456789abcdef";
        bytes memory _addr = new bytes(42);

        _addr[0] = '0';
        _addr[1] = 'x';

        for(uint256 i = 0; i < 20; i++) {
            _addr[2+i*2] = HEX[uint8(_bytes[i + 12] >> 4)];
            _addr[3+i*2] = HEX[uint8(_bytes[i + 12] & 0x0f)];
        }

        return string(_addr);

    }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.7.5;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {

    /**
     * @dev Returns the decimals of token.
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

// SPDX-License-Identifier: MIT
pragma solidity ^0.7.5;

interface IOwnable {
    function owner() external view returns (address);

    function renounceManagement() external;

    function pushManagement( address newOwner_ ) external;

    function pullManagement() external;
}