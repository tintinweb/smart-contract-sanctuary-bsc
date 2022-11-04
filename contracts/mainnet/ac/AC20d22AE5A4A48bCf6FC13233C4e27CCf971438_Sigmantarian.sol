// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

interface IERC721 {
  function init(address _Sigmantarian) external;

  function safeMint(address to) external returns (uint256);
}

interface IPool {
  function Update(uint256 _amount) external;

  function deposit(
    uint256 _amount,
    uint8 _per,
    uint256 _id,
    address _user
  ) external;

  function init(address _Sigmantarian) external;
}

contract Sigmantarian {
  using SafeERC20 for IERC20;
  IERC20 public BUSD;
  IERC721 public TOKEN;
  IPool public Pool;

  bool public Locked;
  uint256 public Ids;
  address public Owner;
  uint8 public PoolPer;

  struct user {
    uint8 Plan;
    /**
    
        Id: user id
        ref: ref id
     */
    uint256 Id;
    uint256 ref;
    /**
    
        UserAddress
        partnersCount
     */
    address UserAddress;
    uint256 partnersCount;
  }

  mapping(uint256 => user) public User;
  mapping(address => uint256) public UserId;

  struct gold {
    uint256 TotalWithdraw;
  }

  struct platinum {
    uint256 TokenId;
    uint256 TotalWithdraw;
  }

  struct diamond {
    uint256 Invest;
    uint256 RewardPerDay;
    uint256 TotalWithdraw;
  }

  mapping(uint256 => gold) public Gold;
  mapping(uint256 => platinum) public Platinum;
  mapping(uint256 => diamond) public Diamond;

  struct plan {
    uint8 Pool;
    uint8 Upline;
    uint8 Referral;
    uint104 PlanInvestment;
  }

  mapping(uint8 => plan) public Plan;
  mapping(uint8 => uint104) public PlanInvestment;

  /********************************************************
                        Constructor
    ********************************************************/

  constructor(
    address _BUSD,
    address _TOKEN,
    address _Pool,
    address[] memory _address
  ) {
    BUSD = IERC20(_BUSD);
    TOKEN = IERC721(_TOKEN);
    Pool = IPool(_Pool);
    Owner = msg.sender;

    Pool.init(address(this));
    TOKEN.init(address(this));

    // Pool, Upline, Referral, PlanInvestment;
    Plan[1] = plan(20, 40, 40, 25 * 10**18);
    Plan[2] = plan(20, 40, 40, 50 * 10**18);
    Plan[3] = plan(60, 20, 20, 100 * 10**18);

    PlanInvestment[1] = 100 * 10**18;
    PlanInvestment[2] = 200 * 10**18;
    PlanInvestment[3] = 300 * 10**18;
    PlanInvestment[4] = 400 * 10**18;
    PlanInvestment[5] = 500 * 10**18;
    PlanInvestment[6] = 600 * 10**18;
    PlanInvestment[7] = 700 * 10**18;
    PlanInvestment[8] = 800 * 10**18;
    PlanInvestment[9] = 900 * 10**18;
    PlanInvestment[10] = 1000 * 10**18;

    PoolPer = 45;

    Ids++;
    User[Ids].Id = Ids;
    User[Ids].Plan = 3;
    User[Ids].ref = 1;
    User[Ids].UserAddress = Owner;
    User[Ids].partnersCount++;

    UserId[Owner] = Ids;

    Diamond[Ids].Invest = 1000 * 10**18;
    Diamond[Ids].RewardPerDay = 4.5 * 10**18;

    Pool.deposit(PlanInvestment[10], PoolPer, Ids, Owner);

    for (uint256 i = 0; i < _address.length; i++) {
      uint256 _Ids = Ids;
      Ids++;
      User[Ids].Id = Ids;
      User[Ids].Plan = 3;
      User[Ids].ref = _Ids;
      User[Ids].UserAddress = _address[i];
      User[_Ids].partnersCount++;

      UserId[_address[i]] = Ids;

      Diamond[Ids].Invest = 1000 * 10**18;
      Diamond[Ids].RewardPerDay = 4.5 * 10**18;

      Pool.deposit(PlanInvestment[10], PoolPer, Ids, _address[i]);
    }
  }

  /********************************************************
                        Modifiers
    ********************************************************/

  modifier onlyOwner() {
    require(msg.sender == Owner, "onlyOwner");
    _;
  }

  modifier onlyUnlocked() {
    require(!Locked || msg.sender == Owner, "Locked");
    _;
  }

  /********************************************************
                        Functions
    ********************************************************/

  function registration(uint256 _ref, address _user) public onlyUnlocked {
    require(!isUserExists(_user), "User exists");
    if (!isUserExists(User[_ref].UserAddress)) _ref = 1;

    uint104 _PlanInvestment = Plan[1].PlanInvestment;
    BUSD.safeTransferFrom(msg.sender, address(this), _PlanInvestment);

    Ids++;
    user storage U = User[Ids];
    U.Id = Ids;
    U.Plan = 1;
    U.ref = _ref;
    U.UserAddress = _user;

    UserId[_user] = Ids;
    User[_ref].partnersCount++;

    directReferrer(_PlanInvestment, U.Plan, _ref);
    uplineReferrer(_PlanInvestment, U.Plan, _ref);
    updatePool(Percentage(_PlanInvestment, Plan[U.Plan].Pool));

    emit registered(_ref, Ids, U.Plan);
  }

  function upgradePlatinum(uint256 _id) public onlyUnlocked {
    require(isUserExists(User[_id].UserAddress), "User not exists");

    user storage U = User[_id];

    require(U.Plan == 1, "Please upgrade Diamond");

    uint104 _PlanInvestment = Plan[2].PlanInvestment;
    BUSD.safeTransferFrom(msg.sender, address(this), _PlanInvestment);

    U.Plan = 2;

    uint256 _tokenId = TOKEN.safeMint(U.UserAddress);
    Platinum[_id].TokenId = _tokenId;

    directReferrer(_PlanInvestment, U.Plan, U.ref);
    uplineReferrer(_PlanInvestment, U.Plan, U.ref);
    updatePool(Percentage(_PlanInvestment, Plan[2].Pool));

    emit upgraded(U.ref, _id, U.Plan);
  }

  function upgradeDiamond(uint256 _id, uint8 _selectPlanInvestment) public onlyUnlocked {
    require(isUserExists(User[_id].UserAddress), "User not exists");
    require(_selectPlanInvestment > 0, "Please select Investment");
    require(_selectPlanInvestment <= 10, "Please select Investment");

    user storage U = User[_id];
    uint104 _PlanInvestment = PlanInvestment[_selectPlanInvestment];

    require(U.Plan > 1, "Please upgrade Platinum");
    require(Diamond[_id].Invest < _PlanInvestment, "please select PlanInvestment");

    uint8 _PoolPer = PoolPer - uint8(block.timestamp % 3);

    BUSD.safeTransferFrom(msg.sender, address(this), _PlanInvestment);
    Pool.deposit(_PlanInvestment, _PoolPer, Ids, User[_id].UserAddress);

    if (U.Plan < 3) U.Plan = 3;

    uint256 _amount = Percentage(_PlanInvestment, Plan[3].Pool);
    Diamond[_id].Invest = _PlanInvestment;
    Diamond[_id].RewardPerDay = (_amount * _PoolPer) / 10000;

    directReferrer(_PlanInvestment, U.Plan, U.ref);
    uplineReferrer(_PlanInvestment, U.Plan, U.ref);
    updatePool(_amount);

    emit upgraded(U.ref, _id, U.Plan);
    emit passiveInvestment(_id, _PlanInvestment, U.Plan);
  }

  function directReferrer(
    uint104 _amount,
    uint8 _plan,
    uint256 _ref
  ) private {
    uint256 _per = Percentage(_amount, Plan[_plan].Referral);
    BUSD.safeTransfer(User[_ref].UserAddress, _per);

    if (_plan == 1) Gold[_ref].TotalWithdraw += _per;
    if (_plan == 2) Platinum[_ref].TotalWithdraw += _per;
    if (_plan == 3) Diamond[_ref].TotalWithdraw += _per;

    emit directRefAmount(_ref, _per, _plan);
  }

  function uplineReferrer(
    uint104 _amount,
    uint8 _plan,
    uint256 _ref
  ) private {
    Pool.Update(Percentage(_amount, 5));
    BUSD.safeTransfer(address(Pool), Percentage(_amount, 5));

    uint256 _peramount = Percentage(_amount, Plan[_plan].Upline - 5);
    uint256 _per = Percentage(_peramount, 10);

    uint256 j;
    while (j < 10) {
      if (User[_ref].Plan >= _plan || j < 2) {
        BUSD.safeTransfer(User[_ref].UserAddress, _per);

        if (_plan == 1) Gold[_ref].TotalWithdraw += _per;
        if (_plan == 2) Platinum[_ref].TotalWithdraw += _per;
        if (_plan == 3) Diamond[_ref].TotalWithdraw += _per;

        emit uplineRefAmount(_ref, _per, _plan);

        j++;
      }
      _ref = User[_ref].ref;
    }
  }

  function updatePool(uint256 _amount) private {
    BUSD.safeTransfer(address(Pool), _amount);
    emit poolUpdate(_amount);
  }

  /********************************************************
                        Updates Functions
    ********************************************************/

  function updateLocked() public onlyOwner {
    Locked = !Locked;
  }

  function updatePoolPer(uint8 _PoolPer) public onlyOwner {
    PoolPer = _PoolPer;
  }

  function updateSlot(
    uint8 _index,
    uint8 _pool,
    uint8 _upline,
    uint8 _referral,
    uint8 _amount
  ) public onlyOwner {
    require(3 >= _index && _index > 0, "Out of bound");
    require(_amount > 0, "Add some amount");
    Plan[_index] = plan(_pool, _upline, _referral, _amount * 10**18);
  }

  function withdrawLostTokens(address tokenAddress) public onlyOwner {
    if (tokenAddress == address(0)) {
      (bool sent, ) = payable(Owner).call{ value: address(this).balance }("");
      require(sent, "Failed to send Ether");
    } else {
      IERC20(tokenAddress).transfer(Owner, IERC20(tokenAddress).balanceOf(address(this)));
    }
  }

  function updateBUSDAddress(address _BUSD) external onlyOwner {
    BUSD = IERC20(_BUSD);
  }

  function updateTOKENAddress(address _TOKEN) external onlyOwner {
    TOKEN = IERC721(_TOKEN);
  }

  function updatePoolAddress(address _Pool) external onlyOwner {
    Pool = IPool(_Pool);
  }

  function updateOwnerAddress(address _Owner) external onlyOwner {
    Owner = _Owner;
  }

  /********************************************************
                        Reusable Functions
    ********************************************************/

  function isUserExists(address _user) public view returns (bool) {
    return (UserId[_user] != 0);
  }

  function Percentage(uint256 amount, uint8 number) internal pure returns (uint256) {
    uint256 _Percentage = amount * 1e18;
    _Percentage = (_Percentage * number) / 100;
    _Percentage = _Percentage / 1e18;

    return _Percentage;
  }

  /********************************************************
                        Events
    ********************************************************/

  event poolUpdate(uint256 _per);
  event upgraded(uint256 _ref, uint256 _user, uint8 _plan);
  event registered(uint256 _ref, uint256 _user, uint8 _plan);
  event directRefAmount(uint256 _ref, uint256 _per, uint8 _plan);
  event uplineRefAmount(uint256 _ref, uint256 _per, uint8 _plan);
  event passiveInvestment(uint256 _user, uint256 _invest, uint8 _plan);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";
import "../extensions/draft-IERC20Permit.sol";
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

    function safePermit(
        IERC20Permit token,
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal {
        uint256 nonceBefore = token.nonces(owner);
        token.permit(owner, spender, value, deadline, v, r, s);
        uint256 nonceAfter = token.nonces(owner);
        require(nonceAfter == nonceBefore + 1, "SafeERC20: permit did not succeed");
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
// OpenZeppelin Contracts (last updated v4.7.0) (utils/Address.sol)

pragma solidity ^0.8.1;

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
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
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
                /// @solidity memory-safe-assembly
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
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
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/draft-IERC20Permit.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 Permit extension allowing approvals to be made via signatures, as defined in
 * https://eips.ethereum.org/EIPS/eip-2612[EIP-2612].
 *
 * Adds the {permit} method, which can be used to change an account's ERC20 allowance (see {IERC20-allowance}) by
 * presenting a message signed by the account. By not relying on {IERC20-approve}, the token holder account doesn't
 * need to send a transaction, and thus is not required to hold Ether at all.
 */
interface IERC20Permit {
    /**
     * @dev Sets `value` as the allowance of `spender` over ``owner``'s tokens,
     * given ``owner``'s signed approval.
     *
     * IMPORTANT: The same issues {IERC20-approve} has related to transaction
     * ordering also apply here.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `deadline` must be a timestamp in the future.
     * - `v`, `r` and `s` must be a valid `secp256k1` signature from `owner`
     * over the EIP712-formatted function arguments.
     * - the signature must use ``owner``'s current nonce (see {nonces}).
     *
     * For more information on the signature format, see the
     * https://eips.ethereum.org/EIPS/eip-2612#specification[relevant EIP
     * section].
     */
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    /**
     * @dev Returns the current nonce for `owner`. This value must be
     * included whenever a signature is generated for {permit}.
     *
     * Every successful call to {permit} increases ``owner``'s nonce by one. This
     * prevents a signature from being used multiple times.
     */
    function nonces(address owner) external view returns (uint256);

    /**
     * @dev Returns the domain separator used in the encoding of the signature for {permit}, as defined by {EIP712}.
     */
    // solhint-disable-next-line func-name-mixedcase
    function DOMAIN_SEPARATOR() external view returns (bytes32);
}