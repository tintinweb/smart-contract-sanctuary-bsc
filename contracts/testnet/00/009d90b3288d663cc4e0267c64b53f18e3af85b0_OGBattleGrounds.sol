/**
 *Submitted for verification at BscScan.com on 2022-10-21
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.6.12;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
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
        // solhint-disable-next-line no-inline-assembly
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

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain`call` is an unsafe replacement for a function call: use this
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

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return _verifyCallResult(success, returndata, errorMessage);
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

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
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

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) private pure returns (bytes memory) {
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
}

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
        // solhint-disable-next-line max-line-length
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

    //    function safeDecreaseAllowance(
    //        IERC20 token,
    //        address spender,
    //        uint256 value
    //    ) internal {
    //    unchecked {
    //        uint256 oldAllowance = token.allowance(address(this), spender);
    //        require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
    //        uint256 newAllowance = oldAllowance - value;
    //        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    //    }
    //    }

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
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

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
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

contract Ownable is Context {
    address private _owner;
    address private _previousOwner;
    uint256 private _lockTime;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
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
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

    function getUnlockTime() public view returns (uint256) {
        return _lockTime;
    }

    function getTime() public view returns (uint256) {
        return now;
    }

    function lock(uint256 time) public virtual onlyOwner {
        _previousOwner = _owner;
        _owner = address(0);
        _lockTime = now + time;
        emit OwnershipTransferred(_owner, address(0));
    }

    function unlock() public virtual {
        require(_previousOwner == msg.sender, "no permission");
        require(now > _lockTime , "not expired");
        emit OwnershipTransferred(_owner, _previousOwner);
        _owner = _previousOwner;
    }
}

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

    constructor() public {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and make it call a
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

/**
 * @dev list of operator identities to manage contract
 */
contract OGOperators is Ownable {

    // @dev Operator Address => Authorized or not
    mapping (address => bool) private operators_;

    // MODIFIERS
    // ========================================================================
    modifier onlyOperator() {
        require(operators_[msg.sender], "Not operator");
        _;
    }
    modifier onlyOwnerOrOperator() {
        require((msg.sender == owner()) || operators_[msg.sender], "Not owner or operator");
        _;
    }

    // EVENT
    // ========================================================================
    event EnrollOperatorAddress(address operator);
    event DisableOperatorAddress(address operator);

    // FUNCTIONS
    // ========================================================================
    /**
     * @notice Enroll new operator addresses
     * @dev Only callable by owner
     * @param _operatorAddress: address of the operator
     */
    function enrollOperatorAddress(address _operatorAddress) external onlyOwnerOrOperator {
        require(_operatorAddress != address(0), "Cannot be zero address");
        require(!operators_[_operatorAddress], "Already registered");
        operators_[_operatorAddress] = true;
        emit EnrollOperatorAddress(_operatorAddress);
    }

    /**
     * @notice Disable a operator addresses
     * @dev Only callable by owner
     * @param _operatorAddress: address of the operator
     */
    function disableOperatorAddress(address _operatorAddress) external onlyOwnerOrOperator {
        require(_operatorAddress != address(0), "Cannot be zero address");
        require(operators_[_operatorAddress], "Already disabled");
        operators_[_operatorAddress] = false;
        emit DisableOperatorAddress(_operatorAddress);
    }

    /**
     * @notice Get operator availability
     * @param _operatorAddress: address of the operator
     */
    function getOperatorEnable(address _operatorAddress) public view returns (bool) {
        return operators_[_operatorAddress];
    }

}

/**
 * @dev OGPlayerBook Interface
 */
interface IOGPlayerBook {
    function getPlayerIDXAddr(address _plyrAddr) external view returns (uint256);
    function getAgtInfoXPlayerID(uint256 _plyrID) external view returns (uint256, address);
}

/**
 * @dev OGPlayerBank Interface
 */
interface IOGPlayerBank {

    function diviesDeposit(address playerAddr, address tokenAddr, uint256 advisorFee, uint256 marketingFee, uint256 devFee, uint256 upperLv1Fee, uint256 upperLv2Fee, uint256 upperLv3Fee) external;

    function transferToPlayerBalance(address playerAddr, address tokenAddr, uint256 amount) external returns (uint256);

    function playerBalanceOf(address playerAddr, address tokenAddr) external view returns (uint256);

    function chargePlayerBalance(address playerAddr, address tokenAddr, uint256 amount) external;
}

/**
 * @dev OGAgentBook Interface
 */
interface IOGAgentBook {
    
    function logAgentIncome(address _tokenAddr, uint256 _agentID, uint256 _amount) external;

    function logAgentLoss(address _tokenAddr, uint256 _agentID, uint256 _amount) external;
}

/**
 * @dev OGBattleGrounds Data Structs
 */
library OGBGDatasets {

    struct Player {
        uint256 pbid;   
        address addr;   
        uint256 lrnd;   
        uint256 spet;   
        uint256 reve;   
    }

    // PlayerID -> RoundID -> PlayerRounds
    struct PlayerRounds {
        
        uint256[] team_tikt;                        

        uint256 spet;                               
        uint256 reve;                               
    }

    struct Round {
        uint256 reve;                               
        uint256 divi;                               
        uint256 tmid;                               
        uint256 sum_tikt;                           
        bool[] team_fall;                           
        uint256[] team_tikt;                        
        uint256 tsend;                              
        bool ended;                                 
        uint256 tiktp0;                             
        uint256 tiktp1;                             
    }

}

contract OGBattleGrounds is ReentrancyGuard, OGOperators {

    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    using Address for address;

    string constant public name = "Octopus Game Official";
    string constant public symbol = "OGO";

    address public plyrBookAddr_ = address(0x0);
    IOGPlayerBook private plyrBook_;

    address public agtBookAddr_ = address(0x0);
    IOGAgentBook private agtBook_;

    address public plyrBankAddr_ = address(0x0);
    IOGPlayerBank private plyrBank_;

    address public tokenAddr_ = address(0x0);

    bool public activated_ = false;

    uint256 public advisorFee_ = 50;
    uint256 public marketingFee_ = 600;
    uint256 public devFee_ = 400;
    uint256 public inviterFee_ = 150;
    uint256 public upperLv1Fee_ = 5000;
    uint256 public upperLv2Fee_ = 3500;
    uint256 public upperLv3Fee_ = 1500;


    uint256 public rID_;

    
    mapping (address => uint256) public pIDxAddr_;
    mapping (uint256 => OGBGDatasets.Player) public plyr_;
    mapping (uint256 => mapping (uint256 => OGBGDatasets.PlayerRounds)) public plyrRnds_;
    mapping (uint256 => OGBGDatasets.Round) public round_;

    event onActivatedUpdated(bool enabled);

    event onNewRound
    (
        uint256 indexed roundID,    
        uint256 teamCount,          
        uint256 ticketPrice,        
        uint256 timeStamp           
    );

    event onFallTeam
    (
        uint256 indexed roundID,    
        uint256 indexed teamID,     
        uint256 ticketVotes,        
        uint256 timeStamp           
    );

    event onRoundEnd
    (
        uint256 indexed roundID,    
        uint256 ticketTotal,        
        uint256 ticketValid,        
        uint256 pot,                
        uint256 tiktp0,             
        uint256 tiktp1,             
        uint256 timeStamp          
    );

    event onBuyTickets
    (
        uint256 indexed playerID,   
        uint256 indexed roundID,    
        uint256 indexed teamID,     
        uint256 amount,             
        uint256 votes,              
        uint256 timeStamp        
    );

    event onSellTickets
    (
        uint256 indexed playerID,   
        uint256 indexed roundID,    
        uint256 ticketValid,        
        uint256 amount,             
        uint256 timeStamp          
    );

    modifier isActivated() {
        require(activated_ == true, "Game is paused");
        _;
    }

    modifier notContract() {
        require(!address(_msgSender()).isContract(), "Contract not allowed");
        require(msg.sender == tx.origin, "Proxy contract not allowed");
        _;
    }

    constructor()
    public
    {
        activated_ = false;
        rID_ = 0;
    }

    function startNewRound(uint256 _teamCount, uint256 _tiktp0) external isActivated onlyOwnerOrOperator nonReentrant returns (uint256) {
        require((rID_ == 0) || (round_[rID_].ended), "Previous round hasnt ended");
        require(_teamCount > 1 && _teamCount <= 100, "Only supports 2-100 teams");
        require(_tiktp0 > 0, "Ticket price is 0");
        uint256 _rID = rID_;
        rID_++;
        _rID++;
        round_[_rID].reve = 0;
        round_[_rID].divi = 0;
        round_[_rID].tmid = _teamCount;
        round_[_rID].tiktp0 = _tiktp0;
        round_[_rID].team_fall = new bool[](_teamCount);
        round_[_rID].team_tikt = new uint256[](_teamCount);
        emit onNewRound(_rID, _teamCount, _tiktp0, now);
        return _rID;
    }

    function fallOneTeam(uint256 _teamIndex) external isActivated onlyOwnerOrOperator nonReentrant {
        require((rID_ > 0) && (!round_[rID_].ended), "Round has ended");
        require((_teamIndex >= 0) && (_teamIndex < round_[rID_].tmid), "Team doesnt exist");
        require(!round_[rID_].team_fall[_teamIndex], "Team already fall");
        round_[rID_].team_fall[_teamIndex] = true;
        emit onFallTeam(rID_, _teamIndex, round_[rID_].team_tikt[_teamIndex], now);
    }

    function endRound() external isActivated onlyOwnerOrOperator nonReentrant {
        require((rID_ > 0) || (!round_[rID_].ended), "Round has ended");
        round_[rID_].ended = true;
        round_[rID_].tsend = now;
        uint256 validTickets = _calcRoundValidTickets(rID_);
        if (validTickets > 0) {
            round_[rID_].tiktp1 = (round_[rID_].reve.sub(round_[rID_].divi)).div(validTickets);
        } else {
            round_[rID_].tiktp1 = round_[rID_].tiktp0;
        }
        emit onRoundEnd(rID_, round_[rID_].sum_tikt, validTickets, round_[rID_].reve, round_[rID_].tiktp0, round_[rID_].tiktp1, now);
    }

    function buyTickets(uint256 _teamIndex, uint256 _votes) external isActivated notContract nonReentrant {
        require((rID_ > 0) && (!round_[rID_].ended), "Round has ended");
        require((_teamIndex >= 0) && (_teamIndex < round_[rID_].tmid), "Team doesnt exist");
        require(!round_[rID_].team_fall[_teamIndex], "Team already fall");
        require(_votes > 0 && _votes <= 10000, "Buy 1-10000 tickets");

        uint256 _plyrID = _checkPlayerInfo(_msgSender());
        OGBGDatasets.Player memory player = plyr_[_plyrID];

        uint256 tollAmount = _votes.mul(_calcRoundCurrentPrice());
        require(tollAmount > 0 && tollAmount >= round_[rID_].tiktp0, "Ticket price error");
        require( (IERC20(tokenAddr_).allowance(player.addr, address(this)) >= tollAmount) && IERC20(tokenAddr_).balanceOf(player.addr) >= tollAmount, "Insufficient allowance");
        IERC20(tokenAddr_).safeTransferFrom(player.addr, address(this), tollAmount);
        uint256 totalFee = _takeFees(tollAmount);

        uint256 agtID = 1;
        address agtAddr = address(0x0);
        (agtID, agtAddr) = plyrBook_.getAgtInfoXPlayerID(player.pbid);
        agtBook_.logAgentIncome(tokenAddr_, agtID, tollAmount);

        plyr_[_plyrID].lrnd = rID_;
        if (plyrRnds_[player.pbid][rID_].spet == 0) {
            plyrRnds_[player.pbid][rID_].team_tikt = new uint256[](round_[rID_].tmid);
        }
        plyr_[_plyrID].spet = plyr_[_plyrID].spet.add(tollAmount);
        plyrRnds_[player.pbid][rID_].spet = plyrRnds_[player.pbid][rID_].spet.add(tollAmount);
        plyrRnds_[player.pbid][rID_].team_tikt[_teamIndex] = plyrRnds_[player.pbid][rID_].team_tikt[_teamIndex].add(_votes);

        round_[rID_].reve = round_[rID_].reve.add(tollAmount);
        round_[rID_].divi = round_[rID_].divi.add(totalFee);
        round_[rID_].sum_tikt = round_[rID_].sum_tikt.add(_votes);
        round_[rID_].team_tikt[_teamIndex] = round_[rID_].team_tikt[_teamIndex].add(_votes);

        emit onBuyTickets(player.pbid, rID_, _teamIndex, tollAmount, _votes, now);
    }

    function balanceBuyTickets(uint256 _teamIndex, uint256 _votes) external isActivated notContract nonReentrant {
        require((rID_ > 0) && (!round_[rID_].ended), "Round has ended");
        require((_teamIndex >= 0) && (_teamIndex < round_[rID_].tmid), "Team doesnt exist");
        require(!round_[rID_].team_fall[_teamIndex], "Team already fall");
        require(_votes > 0 && _votes <= 10000, "Buy 1-10000 tickets");

        uint256 _plyrID = _checkPlayerInfo(_msgSender());
        OGBGDatasets.Player memory player = plyr_[_plyrID];

        uint256 tollAmount = _votes.mul(_calcRoundCurrentPrice());
        require(tollAmount > 0 && tollAmount >= round_[rID_].tiktp0, "Ticket price error");
        
        require(plyrBank_.playerBalanceOf(player.addr, tokenAddr_) >= tollAmount, "Insufficient balance");
        
        plyrBank_.chargePlayerBalance(player.addr, tokenAddr_, tollAmount);
        
        uint256 totalFee = _takeFees(tollAmount);

        uint256 agtID = 1;
        address agtAddr = address(0x0);
        (agtID, agtAddr) = plyrBook_.getAgtInfoXPlayerID(player.pbid);
        agtBook_.logAgentIncome(tokenAddr_, agtID, tollAmount);

        plyr_[_plyrID].lrnd = rID_;
        if (plyrRnds_[player.pbid][rID_].spet == 0) {
            plyrRnds_[player.pbid][rID_].team_tikt = new uint256[](round_[rID_].tmid);
        }
        plyr_[_plyrID].spet = plyr_[_plyrID].spet.add(tollAmount);
        plyrRnds_[player.pbid][rID_].spet = plyrRnds_[player.pbid][rID_].spet.add(tollAmount);
        plyrRnds_[player.pbid][rID_].team_tikt[_teamIndex] = plyrRnds_[player.pbid][rID_].team_tikt[_teamIndex].add(_votes);

        round_[rID_].reve = round_[rID_].reve.add(tollAmount);
        round_[rID_].divi = round_[rID_].divi.add(totalFee);
        round_[rID_].sum_tikt = round_[rID_].sum_tikt.add(_votes);
        round_[rID_].team_tikt[_teamIndex] = round_[rID_].team_tikt[_teamIndex].add(_votes);

        emit onBuyTickets(player.pbid, rID_, _teamIndex, tollAmount, _votes, now);
    }

    function sellTickets(uint256 _rID) external isActivated notContract nonReentrant returns (uint256, uint256, uint256) {
        require((_rID > 0) && (round_[_rID].ended), "Round not over yet");

        uint256 _plyrID = _checkPlayerInfo(_msgSender());
        OGBGDatasets.Player memory player = plyr_[_plyrID];
        require(plyrRnds_[player.pbid][_rID].reve == 0, "Tickets have been sold before");
        uint256 validTickets = _calcRoundPlayerValidTickets(_rID, player.pbid);
        require(validTickets > 0, "You dont have valid tickets");
        uint256 reveAmount = validTickets.mul(round_[_rID].tiktp1);
        
        plyrRnds_[player.pbid][_rID].reve = reveAmount;
        player.reve = player.reve.add(reveAmount);
        
        IERC20(tokenAddr_).safeTransfer(plyrBankAddr_, reveAmount);
        
        uint256 totalBalance = plyrBank_.transferToPlayerBalance(player.addr, tokenAddr_, reveAmount);
        
        emit onSellTickets(player.pbid, _rID, validTickets, reveAmount, now);
        return (validTickets, reveAmount, totalBalance);
    }

    
    function _checkPlayerInfo(address _plyrAddr) private returns (uint256) {
        uint256 _plyrID = plyrBook_.getPlayerIDXAddr(_plyrAddr);
        require(_plyrID > 0, "Please register first");
        if (pIDxAddr_[_plyrAddr] != _plyrID) {
            pIDxAddr_[_plyrAddr] = _plyrID;
            plyr_[_plyrID].pbid = _plyrID;
            plyr_[_plyrID].addr = _plyrAddr;
        }
        return _plyrID;
    }

    
    function _takeFees(uint256 _amount) private returns (uint256) {
        
        
        uint256 totalFee = _calcPercentFee(_amount, advisorFee_.add(marketingFee_).add(devFee_).add(inviterFee_));
        
        IERC20(tokenAddr_).safeIncreaseAllowance(plyrBankAddr_, totalFee);
        
        uint256 inviterFeeAmount = _calcPercentFee(_amount, inviterFee_);
        plyrBank_.diviesDeposit(
            _msgSender(),
            tokenAddr_,
            _calcPercentFee(_amount, advisorFee_),
            _calcPercentFee(_amount, marketingFee_),
            _calcPercentFee(_amount, devFee_),
            inviterFeeAmount.div(10000).mul(upperLv1Fee_),
            inviterFeeAmount.div(10000).mul(upperLv2Fee_),
            inviterFeeAmount.div(10000).mul(upperLv3Fee_)
        );
        return totalFee;
    }

    
    function _calcPercentFee(uint256 _amount, uint256 _fee) private pure returns (uint256) {
        return _amount.mul(_fee).div(10000);
    }

    
    function _calcRoundValidTickets(uint256 _rID) private view returns (uint256) {
        uint256 validTickets = 0;
        for (uint256 i = 0; i < round_[_rID].tmid; i++) {
            if (!round_[_rID].team_fall[i]) {
                validTickets = validTickets.add(round_[_rID].team_tikt[i]);
            }
        }
        return validTickets;
    }

    
    function _calcRoundPlayerValidTickets(uint256 _rID, uint256 _playerID) private view returns (uint256) {
        uint256 validTickets = 0;
        for (uint256 i = 0; i < round_[_rID].tmid; i++) {
            if (!round_[_rID].team_fall[i]) {
                validTickets = validTickets.add(plyrRnds_[_playerID][_rID].team_tikt[i]);
            }
        }
        return validTickets;
    }

    
    function _calcRoundCurrentPrice() private view returns (uint256) {
        uint256 validTickets = _calcRoundValidTickets(rID_);
        if (validTickets > 0) {
            return round_[rID_].reve.div(validTickets);
        } else {
            return round_[rID_].tiktp0;
        }
    }

    
    function _calcRoundSellPrice() private view returns (uint256) {
        uint256 validTickets = _calcRoundValidTickets(rID_);
        if (validTickets > 0) {
            return (round_[rID_].reve.sub(round_[rID_].divi)).div(validTickets);
        } else {
            return round_[rID_].tiktp0;
        }
    }

    function getRoundCurrentPrice() external view returns (uint256, uint256) {
        return (_calcRoundCurrentPrice(), _calcRoundSellPrice());
    }

    
    function getRoundFallStatus(uint256 _rID) external view returns (uint256[] memory) {
        require(round_[_rID].tmid > 0, "No team involved");
        uint256[] memory fallStatus = new uint256[](round_[_rID].tmid);
        for (uint256 i = 0; i < round_[_rID].tmid; i++) {
            if (!round_[_rID].team_fall[i]) {
                fallStatus[i] = 0;
            } else {
                fallStatus[i] = 1;
            }
        }
        return fallStatus;
    }

    
    function getRoundVoteStatus(uint256 _rID) external view returns (uint256[] memory) {
        require(round_[_rID].tmid > 0, "No team involved");
        uint256[] memory voteStatus = new uint256[](round_[_rID].tmid);
        for (uint256 i = 0; i < round_[_rID].tmid; i++) {
            voteStatus[i] = round_[_rID].team_tikt[i];
        }
        return voteStatus;
    }

    
    function getPlayerRoundVoteStatus(uint256 _rID, uint256 _playerID) external view returns (uint256[] memory) {
        require(round_[_rID].tmid > 0, "No team involved");
        uint256[] memory voteStatus = new uint256[](round_[_rID].tmid);
        for (uint256 i = 0; i < round_[_rID].tmid; i++) {
            voteStatus[i] = plyrRnds_[_playerID][_rID].team_tikt[i];
        }
        return voteStatus;
    }

    function setPlayerBookAddr(address _plyrBookAddress) external onlyOwner {
        require(_plyrBookAddress != address(0x0), "Illegal address");
        plyrBookAddr_ = _plyrBookAddress;
        plyrBook_ = IOGPlayerBook(plyrBookAddr_);
    }

    function setAgentBookAddr(address _agtBookAddress) external onlyOwner {
        require(_agtBookAddress != address(0x0), "Illegal address");
        agtBookAddr_ = _agtBookAddress;
        agtBook_ = IOGAgentBook(agtBookAddr_);
    }

    function setPlayerBankAddr(address _plyrBankAddress) external onlyOwner {
        require(_plyrBankAddress != address(0x0), "Illegal address");
        plyrBankAddr_ = _plyrBankAddress;
        plyrBank_ = IOGPlayerBank(plyrBankAddr_);
    }

    function setToken(address _tokenAddress) external onlyOwner {
        require(_tokenAddress != address(0x0), "Cant be 0x0");
        tokenAddr_ = _tokenAddress;
    }

    function setActivated(bool _enabled) external onlyOwnerOrOperator {
        require(tokenAddr_ != address(0x0), "Token addr is 0x0");
        require(plyrBookAddr_ != address(0x0), "PlayerBook addr is 0x0");
        require(plyrBankAddr_ != address(0x0), "PlayerBank addr is 0x0");
        require(agtBookAddr_ != address(0x0), "AgentBank addr is 0x0");
        activated_ = _enabled;
        emit onActivatedUpdated(_enabled);
    }

    function setFeePercent(uint256 _advisorFee, uint256 _marketingFee, uint256 _devFee, uint256 _inviterFee) external onlyOwner {
        require(
            (_advisorFee + _marketingFee + _devFee + _inviterFee) <= 2000,
            "Cannot exceed 20%(<=2000)"
        );
        advisorFee_ = _advisorFee;
        marketingFee_ = _marketingFee;
        devFee_ = _devFee;
        inviterFee_ = _inviterFee;
    }

    function setUpperFeePercent(uint256 _upper1Fee, uint256 _upper2Fee, uint256 _upper3Fee) external onlyOwner {
        require(
            (_upper1Fee + _upper2Fee + _upper3Fee) == 10000,
            "Must equal 10000"
        );
        upperLv1Fee_ = _upper1Fee;
        upperLv2Fee_ = _upper2Fee;
        upperLv3Fee_ = _upper3Fee;
    }

}