// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "./IMiningPool.sol";
import "./IContracts_TITIMITI.sol";
import "./IMining.sol";
import "./IStaking.sol";

contract Staking is IStaking{
    IContracts_TITIMITI Contr;
    IERC20 MITI;
    IMiningPool MP;
    IMining M;
    //MPN=>address=>totalstake
    mapping (uint256 => mapping(address => uint)) public stakes;
    //MPN=>address=>blockTimestamps
    mapping (uint256 =>mapping(address => uint)) public blockTimestamps;
     //MPN=>address=>locked
    mapping (uint256 =>mapping(address => bool)) public locked;
    //MPN=>address=>ID_NFTO
    mapping (uint256 => mapping (address=>uint256)) public Address_S_ID_NFTO;
     uint256 public _decimals_ =1000000;

    uint public totalStaked;
    uint256 Min_Staking = 1000000;
    uint constant public rewardInterval = 10 minutes;

    //MPN=>ID_NFTO=>total stake
    mapping (uint256 => mapping (uint256=>uint)) public TotalStakeNFTO;
    //MPN=>total stake
    mapping (uint256=>uint) public MPNtotalStaked;

    constructor() {
        Contr=IContracts_TITIMITI(0xe3697B78FC93F5aE90BB655133c2264373c5bc3A);
    }

    function stake(uint _value,uint256 ID_NFTO,uint256 MPN_) public {
        require(M.getTrueMiningPoolNum(MPN_)==true);
        address sender= msg.sender;
        uint256 T = MP.getblockTimestamps(MPN_);
        uint256 T_true = block.timestamp-T;
        require(T_true<=M.getTimeMP() && T_true>=M.getOneday());
        uint256 MITID=_value*_decimals_;
        require(MITID>=Min_Staking);
        require(MITI.balanceOf(sender) >= MITID);
        require(MITI.transferFrom(sender, address(this), MITID));

        address Adr_NFTO = M.getMPN_NFTO_True(MPN_, ID_NFTO);
        require(ID_NFTO==M.getMining_take_NFTO(Adr_NFTO));

        stakes[MPN_][sender] += MITID;

        blockTimestamps[MPN_][sender] = block.timestamp;
        locked[MPN_][sender] = true;

        totalStaked += MITID;

        TotalStakeNFTO[MPN_][ID_NFTO]+= MITID;
        MPNtotalStaked[MPN_]+= MITID;
        Address_S_ID_NFTO[MPN_][sender]=ID_NFTO;
    }

    function unstake(uint256 MPN_) public {
        address sender=msg.sender;
        uint256 T = MP.getblockTimestamps(MPN_);
        uint256 T_true = block.timestamp-T;
        require(T_true>=M.getTimeMP());
        require(!locked[MPN_][sender]);
        uint256 BalanceS= stakes[MPN_][sender];
        require(MITI.transfer(sender, BalanceS));
        stakes[MPN_][sender] -= BalanceS;
        totalStaked -= BalanceS;
        MPNtotalStaked[MPN_]-= BalanceS;
        uint256 ID_NFTO = Address_S_ID_NFTO[MPN_][sender];
        TotalStakeNFTO[MPN_][ID_NFTO]-= BalanceS;
        Address_S_ID_NFTO[MPN_][sender]=0;
    }

    function claimReward(uint256 MPN_) public {
        address sender = msg.sender;
        require(locked[MPN_][msg.sender]);
        require(block.timestamp >= blockTimestamps[MPN_][msg.sender] + rewardInterval);
        uint256 ID_NFTO = Address_S_ID_NFTO[MPN_][sender];
        uint Payout = GetPayout(MPN_,sender,ID_NFTO);
        require(MITI.transfer(msg.sender, Payout));
        blockTimestamps[MPN_][msg.sender] = block.timestamp;
    }

    function updateStake(uint _value,uint256 MPN_) public {
        address sender = msg.sender;
         uint256 MITID=_value*_decimals_;
        uint256 ID_NFTO = Address_S_ID_NFTO[MPN_][sender];
        require(locked[MPN_][msg.sender]);
        require(MITI.transferFrom(msg.sender, address(this), MITID));
        stakes[MPN_][msg.sender] += MITID;
        totalStaked += MITID;
        TotalStakeNFTO[MPN_][ID_NFTO]+= MITID;
        MPNtotalStaked[MPN_]+= MITID;
    }

    function getStake(uint256 MPN_,address _address) public view returns (uint) {
        return stakes[MPN_][_address];
    }

    function getTotalStaked() public virtual override view returns (uint) {
        return totalStaked;
    }
    function getTotalStakeNFTO(uint256 MPN_,uint256 ID_NFTO)public virtual override view returns (uint){
        return TotalStakeNFTO[ MPN_][ID_NFTO];
    }
    function getMPNtotalStaked(uint256 _MPN) public virtual override view returns (uint){
        return MPNtotalStaked[_MPN];
    }

    function GetclaimDAY (uint256 MPN_,address _address) public view returns (uint) {
        uint TIME_Stake = block.timestamp -blockTimestamps[MPN_][_address];
        uint _Getclaim = TIME_Stake/rewardInterval;
        return _Getclaim;
    }
    
    function GetPayout (uint256 MPN_,address _address,uint256 ID_NFTO) public view returns (uint) {
        uint _GetclaimDAY = GetclaimDAY(MPN_,_address);
        uint256 Procent = M.getProcent(MPN_, ID_NFTO);
        uint256 BalanceMP = MP.getStakers(MPN_)/100*Procent;
        uint256 BalanceS = (MITI.balanceOf(address(this))-totalStaked)/100*Procent;

        uint256 ProcentS = stakes[MPN_][_address]/(TotalStakeNFTO[MPN_][ID_NFTO]/100);
        uint256 out = (BalanceMP+BalanceS)/100*ProcentS;
        uint256 Payout = out/30*_GetclaimDAY;
        return Payout;
    }
    function  update()  public virtual override{
        MP=IMiningPool(address(Contr.getMiningPool()));
        M=IMining(address(Contr.getMining()));
        MITI=IERC20(address(Contr.getMiticoin()));
  } 
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

interface IStaking {
    function getTotalStaked() external view returns (uint);
    function getTotalStakeNFTO(uint256 MPN_,uint256 ID_NFTO)external view returns (uint);
    function getMPNtotalStaked(uint256 _MPN) external view returns (uint);
    function  update() external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

interface IContracts_TITIMITI {
    function getZoomLoupe() external view returns (address);
    function getMining() external view returns (address);
    function getLandLord() external view returns (address);
    function getFundNFTA() external view returns (address);
    function getBurn() external view returns (address);
    function getStock() external view returns (address);
    function getTeam() external view returns (address);
    function getCashback() external view returns (address);
    function getRsearchers() external view returns (address);
    function getDev() external view returns (address);
    function getMiningPool() external view returns (address);
    function getTitifund() external view returns (address);
    function getMINT_GNFT() external view returns (address);
    function getMiticoin() external view returns (address);
    function getDetails() external view returns (address);
    function getdis() external view returns (address);
    function getBasic_info() external view returns (address);
    function getCollections() external view returns (address);
    function getNFTO() external view returns (address);
    function getNFTA() external view returns (address);
    function getSkillUP() external view returns (address);
    function getTake() external view returns (address);
    function getTrue_chest() external view returns (address);
    function getPrice() external view returns (address);
    function getInvest() external view returns (address);
    function getSaleMITI() external view returns (address);
    function getStaking() external view returns (address);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

interface IMining {
    function getTrueMiningPoolNum(uint256 _MiningPoolNum) external view returns (bool);
    function Set_TrueMiningPoolNum () external;
    function getTimeMP ()external view returns (uint);
    function getOneday () external view returns (uint);
    function getProcent (uint256 _MPN,uint256 ID_NFTO) external view returns (uint256);
    function getMPN_NFTO_True (uint256 _MPN,uint256 ID_NFTO) external view returns (address);
    function getMining_take_NFTO(address _address) external view returns (uint256);
    function  update() external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

interface IMiningPool {
    function getSumm_MiningPool(uint256 _MiningPoolNum) external view returns (uint256);
    function getSale(uint256 _MiningPoolNum) external view returns (uint256);
    function getMiners(uint256 _MiningPoolNum) external view returns (uint256);
    function getZoomLoupe(uint256 _MiningPoolNum) external view returns (uint256);
    function getStakers(uint256 _MiningPoolNum) external view returns (uint256);
    function getMiningPoolNum() external view returns (uint256);
    function getblockTimestamps(uint256 _MPN)external view returns (uint);
    function  update()  external;
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
    function transferFrom(address from,address to,uint256 amount) external returns (bool);
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