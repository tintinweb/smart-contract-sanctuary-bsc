/**
 *Submitted for verification at BscScan.com on 2022-11-25
*/

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

library SafeERC20 {
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        callOptionalReturn(
            token,
            abi.encodeWithSelector(token.transfer.selector, to, value)
        );
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        callOptionalReturn(
            token,
            abi.encodeWithSelector(token.transferFrom.selector, from, to, value)
        );
    }

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
        callOptionalReturn(
            token,
            abi.encodeWithSelector(token.approve.selector, spender, value)
        );
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance =
            token.allowance(address(this), spender).add(value);
        callOptionalReturn(
            token,
            abi.encodeWithSelector(
                token.approve.selector,
                spender,
                newAllowance
            )
        );
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance =
            token.allowance(address(this), spender).sub(
                value,
                "SafeERC20: decreased allowance below zero"
            );
        callOptionalReturn(
            token,
            abi.encodeWithSelector(
                token.approve.selector,
                spender,
                newAllowance
            )
        );
    }

    function callOptionalReturn(IERC20 token, bytes memory data) private {
        require(address(token).isContract(), "SafeERC20: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");

        if (returndata.length > 0) {
            // Return data is optional
            // solhint-disable-next-line max-line-length
            require(
                abi.decode(returndata, (bool)),
                "SafeERC20: ERC20 operation did not succeed"
            );
        }
    }
}

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
     *
     * _Available since v2.4.0._
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
     *
     * _Available since v2.4.0._
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
     *
     * _Available since v2.4.0._
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

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

library Math {
    /**
     * @dev Returns the largest of two numbers.
     */
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    /**
     * @dev Returns the smallest of two numbers.
     */
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    /**
     * @dev Returns the average of two numbers. The result is rounded towards
     * zero.
     */
    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b) / 2 can overflow, so we distribute
        return (a / 2) + (b / 2) + ((a % 2 + b % 2) / 2);
    }
}


interface PlayerBook {
     function settleReward(address from, uint256 amount) 
        external;
}

contract stakereward {
    using SafeERC20 for IERC20;
     using SafeMath for uint256;
     using Address for address;

    address public stakeToken;
    address public controller;
    address public inviteAddr;
    address public winnerAddr;
    address public team1Addr;
    address public team2Addr;

    uint256[32] public _priceID = [10*1e18,10*1e18,10*1e18,10*1e18,10*1e18,10*1e18,10*1e18,10*1e18,10*1e18,10*1e18,
                                   10*1e18,10*1e18,10*1e18,10*1e18,10*1e18,10*1e18,10*1e18,10*1e18,10*1e18,10*1e18,
                                   10*1e18,10*1e18,10*1e18,10*1e18,10*1e18,10*1e18,10*1e18,10*1e18,10*1e18,10*1e18,10*1e18,10*1e18];

    uint256[32] public _priceInit = _priceID;

    uint256[32] public _rewardPerTokenStored;
    mapping(address => uint256[32]) public _userRewardPerTokenPaid;
    mapping(address => uint256) public _rewards;
    mapping(address => uint) public hasReward;

    uint256[32]  _totalSupply;
    mapping(address => uint256[32])  _balances;

    bool public _lock = true;

    uint public countsToReward = 100;
    uint256[32] public _stakeTotal;
    uint public increasePrice = 20*1e8;
    uint public BASE = 10000;

    uint public inviteFee = 1000;
    uint public winnerFee = 5000;
    uint public team1Fee = 500;
    uint public team2Fee = 500;

    mapping(address => uint) public whiteList;
    mapping(address => uint) public hasRewardwhiteList;

    bool public _couuldStake=false;

    uint public curPeriod = 0;
    uint[2] public curID = [0,0];
    mapping(uint => mapping(uint => uint))  _totalSupplyPeriod;
    mapping(uint => bool) public hasStart;

    constructor(address new_stakeToken,address new_inviteAddr,address new_winnerAddr,address new_team1Addr,address new_team2Addr) {
        controller = msg.sender;

        stakeToken = new_stakeToken;
        inviteAddr = new_inviteAddr;
        winnerAddr = new_winnerAddr;
        team1Addr = new_team1Addr;
        team2Addr = new_team2Addr;
    }
    
    modifier onlyOwner () {
        require(msg.sender == controller, "!controller");
        _;
    }

    modifier onlyLock () {
        require(_lock, "_lock!");
        _lock = false;
        _;
        _lock = true;
    }

    modifier updateReward(address account) {
        if (account != address(0)) {
            _rewards[account] = earned(account);
            for(uint i = 0;i<32;i++)
            {
                _userRewardPerTokenPaid[account][i] = _rewardPerTokenStored[i];
            }
        }
        _;
    }

    function earned(address account) public view returns (uint256) {
        uint rtn = 0;
        for(uint i = 0;i<32;i++)
        {
            rtn = rtn.add(balanceOf(account,i).mul(_rewardPerTokenStored[i].sub(_userRewardPerTokenPaid[account][i])));
        }
        return rtn.add(_rewards[account]);
    }


    function balanceOf(address account,uint _id) public view returns (uint256) {
        return _balances[account][_id];
    }

    function totalSupply(uint _id) public view returns (uint256) {
        return _totalSupply[_id];
    }

    function stake(uint _id)
        external 
        onlyLock
        updateReward(msg.sender)
    {
        require(_couuldStake, "_couuldStake err!");
        require(curPeriod > 0, "curPeriod err!");
        require(_id == curID[0] || _id == curID[1], "_id err!");

        uint sendPrice = _priceID[_id];
        uint totalFee = 0;

        IERC20(stakeToken).safeTransferFrom(msg.sender,address(this),sendPrice);
        _priceID[_id] = _priceID[_id].add(increasePrice);

        IERC20(stakeToken).safeTransfer(inviteAddr, sendPrice.mul(inviteFee).div(BASE));
        PlayerBook(inviteAddr).settleReward(msg.sender,sendPrice.mul(inviteFee).div(BASE));
        IERC20(stakeToken).safeTransfer(winnerAddr, sendPrice.mul(winnerFee).div(BASE));
        IERC20(stakeToken).safeTransfer(team1Addr, sendPrice.mul(team1Fee).div(BASE));
        IERC20(stakeToken).safeTransfer(team2Addr, sendPrice.mul(team2Fee).div(BASE));
        totalFee = sendPrice.mul(inviteFee.add(winnerFee).add(team1Fee).add(team2Fee)).div(BASE);

        _stakeTotal[_id] = _stakeTotal[_id].add(sendPrice.sub(totalFee));

        _totalSupply[_id] = _totalSupply[_id].add(1);
        _balances[msg.sender][_id] = _balances[msg.sender][_id].add(1);

        _totalSupplyPeriod[curPeriod][_id] = _totalSupplyPeriod[curPeriod][_id].add(1);

        if(_totalSupplyPeriod[curPeriod][_id].mod(countsToReward) == 0)
        {
            _rewardPerTokenStored[_id] = _rewardPerTokenStored[_id].add(_stakeTotal[_id].div( _totalSupply[_id]));
            _stakeTotal[_id] = 0;
        }
    }

    function withdraw()
        external 
        updateReward(msg.sender)
    {
        uint rewardAmt = earned(msg.sender);
        if(rewardAmt > 0)
        {
            _rewards[msg.sender] = 0;

            IERC20(stakeToken).safeTransfer(msg.sender, rewardAmt);
            hasReward[msg.sender] = hasReward[msg.sender].add(rewardAmt);
        }
    }

    function withdrawWhiteList()
        external 
    {
        uint rtnAmt = whiteList[msg.sender];
        require(rtnAmt > 0,"amount zero");
        whiteList[msg.sender] = 0;
        hasRewardwhiteList[msg.sender] = hasRewardwhiteList[msg.sender].add(rtnAmt);
        IERC20(stakeToken).safeTransfer(msg.sender, rtnAmt);
    }


    function govWithdraw(address tokenAddr,uint amount)
        external 
        onlyOwner
    {
        IERC20(tokenAddr).safeTransfer(msg.sender,amount);
    }


    function setController(address _Controller)
        public onlyOwner
    {
        controller = _Controller;
    }

    function setstakeToken(address new_stakeToken)
        public onlyOwner
    {
        stakeToken = new_stakeToken;
    }

    function setinviteAddr(address new_inviteAddr)
        public onlyOwner
    {
        inviteAddr = new_inviteAddr;
    }
    
    function setwinnerAddr(address new_winnerAddr)
        public onlyOwner
    {
        winnerAddr = new_winnerAddr;
    }

    function setteam1Addr(address new_team1Addr)
        public onlyOwner
    {
        team1Addr = new_team1Addr;
    }

    function setteam2Addr(address new_team2Addr)
        public onlyOwner
    {
        team2Addr = new_team2Addr;
    }
    
    function setincreasePrice(uint new_increasePrice)
        public onlyOwner
    {
        increasePrice = new_increasePrice;
    }

    function setinviteFee(uint new_inviteFee)
        public onlyOwner
    {
        inviteFee = new_inviteFee;
    }

    function setteam1Fee(uint new_team1Fee)
        public onlyOwner
    {
        team1Fee = new_team1Fee;
    }

    function setwinnerFee(uint new_winnerFee)
        public onlyOwner
    {
        winnerFee = new_winnerFee;
    }

    function setteam2Fee(uint new_team2Fee)
        public onlyOwner
    {
        team2Fee = new_team2Fee;
    }

    function set_couuldStake(bool new_couuldStake)
        public onlyOwner
    {
        _couuldStake = new_couuldStake;
    }

    function set_countsToReward(uint new_countsToReward)
        public onlyOwner
    {
        countsToReward = new_countsToReward;
    }
    
    function setwhiteList(address[] memory accountAddr,uint[] memory _amounts)
        external onlyOwner
    {
        require( _amounts.length >= accountAddr.length, "len err");

        for(uint i=0;i<accountAddr.length;i++)
        {
            whiteList[accountAddr[i]] = whiteList[accountAddr[i]].add(_amounts[i]);
        }
    }

    function startAnotherRound(uint _round,uint team1,uint team2,uint roundPrice)
        public onlyOwner
    {
        require(_round == curPeriod,"_round err");
        require(!hasStart[curPeriod],"hasStart err");
        hasStart[curPeriod] = true;
        _couuldStake = true;

        curPeriod += 1;
        _stakeTotal[curID[0]] = 0;
        _stakeTotal[curID[1]] = 0;
        curID[0] = team1;
        curID[1] = team2;

        _priceID[team1] = roundPrice;
        _priceID[team2] = roundPrice;
    }
}