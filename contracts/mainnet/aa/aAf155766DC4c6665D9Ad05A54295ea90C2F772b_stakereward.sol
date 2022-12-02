/**
 *Submitted for verification at BscScan.com on 2022-12-02
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

interface IPancakePair {
    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
}

interface IPancakeRouter01 {
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
     function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
}

interface PlayerBook {
    function mainBuy(address Code)
        external;
    function addrExist(address Code)
        external view returns(bool);
    function blackList(address Code)
        external view returns(bool);
}

contract stakereward {
    using SafeERC20 for IERC20;
     using SafeMath for uint256;
     using Address for address;

    address public usdt = 0x55d398326f99059fF775485246999027B3197955;
    address public _uniswapV2Router = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address public lpToken;
    address public ticketToken = 0x55d398326f99059fF775485246999027B3197955;
    address public controller;
    address public inviteAddr;
    address public teamAddr;

    uint256 public DURATION; 
    uint256 public BASE = 10000;
    uint256 public rewardRate;
    uint256 public inviteFee = 4400;
    uint256 public ticketRate = 300;

    struct stakeItem {
        uint256 stakeType;
        uint256 stakeTime;
        uint256 state;
        bool _stakeTotal;
        uint256 setListTime;
        bool _restake;
        uint256 hasStake;
    }
    stakeItem[] public stakeRecord;

    uint[] public stakeLevel = [500*1e13,1000*1e13,3000*1e13,5000*1e13,10000*1e13,20000*1e13,50000*1e13];

    mapping(address => uint) public usrLastLevel;
    mapping(address => uint) public usrHaveStake;
    mapping(address => uint[2]) public usrPosition;
    mapping(address => uint[]) public usrPositionRecord;
    struct usrItem {
        address account;
        uint256 lastUpdateTime;
        uint256 endUpdateTime;
        uint256 trueEndUpdateTime;
        uint256 rewards;
        uint256 hasRewards;
    }
    mapping(uint => usrItem) public stakeInfo;

    struct invItem {
        address account;
        uint256 invTime;
        uint256 rewards;
        uint256 did;
    }
    invItem[] public invRecord;

    mapping(address => uint) public inviteRewardList;
    mapping(address => uint) public hasInviteReward;
    uint public levelUpCount = 1;
    mapping(uint => bool) public inviteRewardCheck;

    constructor(address new_teamAddr,address new_lpToken,address new_ticketToken,address new_inviteAddr,uint256 new_DURATION,uint256 new_rewardRate,uint256 new_levelUpCount) {
        controller = msg.sender;
        teamAddr = new_teamAddr;
        lpToken = new_lpToken;
        ticketToken = new_ticketToken;
        inviteAddr = new_inviteAddr;
        DURATION = new_DURATION;
        rewardRate = new_rewardRate;
        levelUpCount = new_levelUpCount;

        //init
        stakeItem memory itemRecord;
        stakeRecord.push(itemRecord);
    }
    
    modifier onlyOwner () {
        require(msg.sender == controller, "!controller");
        _;
    }

    modifier updateReward(address account) {
        if(usrPosition[account][0] != 0 && stakeInfo[usrPosition[account][0]].endUpdateTime <= block.timestamp)
        {
            usrPosition[account][0] = 0;
            usrHaveStake[account] = usrHaveStake[account].sub(1);
        }
        if(usrPosition[account][1] != 0 &&stakeInfo[usrPosition[account][1]].endUpdateTime <= block.timestamp)
        {
            usrPosition[account][1] = 0;
            usrHaveStake[account] = usrHaveStake[account].sub(1);
        }
        _;
    }

    function stakeTotalLength()
        public
        view
        returns(uint)
    {
        return stakeRecord.length - 1;
        
    }


    function invRecordLength()
        public
        view
        returns(uint)
    {
        return invRecord.length;
        
    }


    function usrPositionRecordLength(address _account)
        public
        view
        returns(uint)
    {
        return usrPositionRecord[_account].length;
        
    }

    function getLPAmount(uint256 _type)
        public
        view
        returns(uint)
    {
        (uint256 reserve0, uint256 reserve1,) = IPancakePair(lpToken).getReserves();
        uint256 _reserve = IPancakePair(lpToken).token0() == usdt?reserve0:reserve1;
        uint256 _totalSupply = IPancakePair(lpToken).totalSupply();
        return stakeLevel[_type].mul(_totalSupply.div(2)).div(_reserve);
    }

    function getticketAmount(uint256 _type)
        public
        view
        returns(uint)
    {
        uint256[] memory valueAmount;
        address[] memory callbackpath = new address[](2);
            callbackpath[0] = usdt;
            callbackpath[1] =  ticketToken;
        valueAmount = IPancakeRouter01(_uniswapV2Router).getAmountsOut(stakeLevel[_type], callbackpath);
        return valueAmount[1];
    }
    
    function stake(uint256 _type)
        public
    {
        require(PlayerBook(inviteAddr).addrExist(msg.sender),"PlayerBook err");
        require(_type <= usrLastLevel[msg.sender],"Level err");
        require(usrHaveStake[msg.sender] < 2,"usrHaveStake err");

        uint lpAmounts = getLPAmount(_type).mul(3).div(10);
        uint ticketAmounts = getticketAmount(_type).mul(ticketRate).div(BASE);
        IERC20(lpToken).safeTransferFrom(msg.sender, address(this),lpAmounts);
        IERC20(ticketToken).safeTransferFrom(msg.sender, address(this),ticketAmounts);

        PlayerBook(inviteAddr).mainBuy(msg.sender);

        uint _pos = stakeTotalLength().add(1);

        stakeItem memory itemRecord;
        itemRecord.stakeTime = block.timestamp;
        itemRecord.stakeType = _type;
        itemRecord.state = 1;
        itemRecord.hasStake = itemRecord.hasStake.add(lpAmounts);
        stakeRecord.push(itemRecord);

        if(usrPosition[msg.sender][0] == 0)
        {
            usrPosition[msg.sender][0] = _pos;
        }else{
            usrPosition[msg.sender][1] = _pos;
        }
        usrPositionRecord[msg.sender].push(_pos);

        if(usrPositionRecord[msg.sender].length.mod(levelUpCount) == 0)
        {
            if(usrLastLevel[msg.sender] < 6)
            {
                usrLastLevel[msg.sender] += 2;
            }
        }

        stakeInfo[_pos].account = msg.sender;
        stakeInfo[_pos].lastUpdateTime = block.timestamp;
        stakeInfo[_pos].endUpdateTime = block.timestamp.add(DURATION);
        stakeInfo[_pos].trueEndUpdateTime = block.timestamp.add(DURATION);
        stakeInfo[_pos].rewards = getLPAmount(_type).mul(rewardRate).div(BASE);
        
        usrHaveStake[msg.sender] = usrHaveStake[msg.sender] + 1;
        
    }

    function stakeTotal(uint256 _id)
        external
    {
        require(stakeRecord[_id]._stakeTotal,"white err");
        require(stakeRecord[_id].state == 1,"already stake");

        uint lpAmounts = getLPAmount(stakeRecord[_id].stakeType).mul(7).div(10);
        IERC20(lpToken).safeTransferFrom(msg.sender, address(this),lpAmounts);
        stakeRecord[_id].hasStake = stakeRecord[_id].hasStake.add(lpAmounts);

        stakeRecord[_id].state = 2;
    }

    function setRestake(uint256 _id,uint256 _type)
        external
        updateReward(msg.sender)
    {
        require(!stakeRecord[_id]._restake,"already Restake");
        stake(_type);
        stakeRecord[_id]._restake = true;
    }
    
    
    function withdraw(uint256 _id)
        external 
    {
        require(!PlayerBook(inviteAddr).blackList(msg.sender),"V7 err");
        require(stakeInfo[_id].account == msg.sender,"account err");
        require(stakeRecord[_id].stakeTime.add(DURATION) <= block.timestamp,"DURATION err");
        require(stakeRecord[_id].state == 2,"state err");
        require(stakeRecord[_id]._restake,"_restake err");

        stakeRecord[_id].state = 3;

        uint withdrawAmount = stakeRecord[_id].hasStake;
        IERC20(lpToken).safeTransfer(msg.sender,withdrawAmount.mul(98).div(100));
        IERC20(lpToken).safeTransfer(teamAddr,withdrawAmount.mul(2).div(100));
    }

    function getRewardAmounts(uint256 _id)
        public
        view
        returns(uint) 
    {
        if(stakeInfo[_id].trueEndUpdateTime <= stakeInfo[_id].lastUpdateTime)
        {
            return 0;
        }

        uint timeCount = stakeInfo[_id].trueEndUpdateTime <= block.timestamp?stakeInfo[_id].trueEndUpdateTime:block.timestamp;
        uint rewardAmt = stakeInfo[_id].rewards.mul(timeCount.sub(stakeInfo[_id].lastUpdateTime)).div(DURATION);
        return rewardAmt;
    }

    function getReward(uint256 _id)
        external 
    {
        require(!PlayerBook(inviteAddr).blackList(msg.sender),"V7 err");
        require(stakeInfo[_id].account == msg.sender,"account err");
        require(stakeInfo[_id].trueEndUpdateTime > stakeInfo[_id].lastUpdateTime,"UpdateTime err");

        uint timeCount = stakeInfo[_id].trueEndUpdateTime <= block.timestamp?stakeInfo[_id].trueEndUpdateTime:block.timestamp;
        uint rewardAmt = stakeInfo[_id].rewards.mul(timeCount.sub(stakeInfo[_id].lastUpdateTime)).div(DURATION);
        stakeInfo[_id].lastUpdateTime = timeCount;
        stakeInfo[_id].hasRewards = rewardAmt;

        IERC20(lpToken).safeTransfer(msg.sender,rewardAmt.mul(98).div(100));
        IERC20(lpToken).safeTransfer(teamAddr,rewardAmt.mul(2).div(100));

        invItem memory itemRecord;
        itemRecord.account = msg.sender;
        itemRecord.invTime = block.timestamp;
        itemRecord.rewards = rewardAmt;
        itemRecord.did = invRecord.length;
        invRecord.push(itemRecord);

    }

    function getInviteReward()
        external 
    {
        require(inviteRewardList[msg.sender] > 0,"amount zero err");

        uint rewardAmt = inviteRewardList[msg.sender];
        inviteRewardList[msg.sender] = 0;
        hasInviteReward[msg.sender] = hasInviteReward[msg.sender].add(rewardAmt);

        IERC20(lpToken).safeTransfer(msg.sender,rewardAmt.mul(98).div(100));
        IERC20(lpToken).safeTransfer(teamAddr,rewardAmt.mul(2).div(100));
    }

    function getK(uint256 _usdtAmount)
        external view returns(uint)
    {
        (uint256 reserve0, uint256 reserve1,) = IPancakePair(lpToken).getReserves();
        return IPancakePair(lpToken).token0() == usdt?_usdtAmount.mul(reserve1).div(reserve0):_usdtAmount.mul(reserve0).div(reserve1);
    }

    function getLP(uint256 _usdtAmount,uint256 _tokenAmount)
        external 
    {

        address tknAddr = IPancakePair(lpToken).token0() == usdt?IPancakePair(lpToken).token1():IPancakePair(lpToken).token0();
        uint usdtBefore = IERC20(usdt).balanceOf(address(this));
        uint tokenBefore = IERC20(tknAddr).balanceOf(address(this));
        IERC20(usdt).safeTransferFrom(msg.sender, address(this),_usdtAmount);
        IERC20(tknAddr).safeTransferFrom(msg.sender, address(this),_tokenAmount);
        uint usdtAfter = IERC20(usdt).balanceOf(address(this)).sub(usdtBefore);
        uint tokenAfter = IERC20(tknAddr).balanceOf(address(this)).sub(tokenBefore);
        IERC20(usdt).safeApprove(_uniswapV2Router,0);
        IERC20(tknAddr).safeApprove(_uniswapV2Router,0);
        IERC20(usdt).safeApprove(_uniswapV2Router,usdtAfter);
        IERC20(tknAddr).safeApprove(_uniswapV2Router,tokenAfter);
        IPancakeRouter01(_uniswapV2Router).addLiquidity(
            usdt,
            tknAddr,
            usdtAfter,
            tokenAfter,
            0,
            0,
            msg.sender,
            block.timestamp.add(1800)
        );

        uint usdtRuturn = IERC20(usdt).balanceOf(address(this)).sub(usdtBefore);
        uint tokenRuturn = IERC20(tknAddr).balanceOf(address(this)).sub(tokenBefore);
        IERC20(usdt).safeTransfer(msg.sender,usdtRuturn);
        IERC20(tknAddr).safeTransfer(msg.sender,tokenRuturn);
    }

    function removeLP(uint256 _lpAmount)
        external 
    {
        IERC20(lpToken).safeTransferFrom(msg.sender, address(this),_lpAmount);
        address tknAddr = IPancakePair(lpToken).token0() == usdt?IPancakePair(lpToken).token1():IPancakePair(lpToken).token0();
        IERC20(lpToken).safeApprove(_uniswapV2Router,0);
        IERC20(lpToken).safeApprove(_uniswapV2Router,_lpAmount);
        IPancakeRouter01(_uniswapV2Router).removeLiquidity(
            usdt,
            tknAddr,
            _lpAmount,
            0,
            0,
            msg.sender,
            block.timestamp.add(1800)
        );
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

    function setteamAddr(address new_teamAddr)
        public onlyOwner
    {
        teamAddr = new_teamAddr;
    }

    function setinviteAddr(address new_inviteAddr)
        public onlyOwner
    {
        inviteAddr = new_inviteAddr;
    }

    function setticketToken(address new_ticketToken)
        public onlyOwner
    {
        ticketToken = new_ticketToken;
    }

    function setlpToken(address new_lpToken)
        public onlyOwner
    {
        lpToken = new_lpToken;
    }

    function setrewardRate(uint new_rewardRate)
        public onlyOwner
    {
        rewardRate = new_rewardRate;
    }

    function setinviteFee(uint new_inviteFee)
        public onlyOwner
    {
        inviteFee = new_inviteFee;
    }

    function setticketRate(uint new_ticketRate)
        public onlyOwner
    {
        require(new_ticketRate <= 10000, "err");
        ticketRate = new_ticketRate;
    }
    
    
    function setwhiteList(uint[] calldata _id)
        external onlyOwner
    {
        for(uint i=0;i<_id.length;i++)
        {
            require(!stakeRecord[_id[i]]._stakeTotal, "err");
            stakeRecord[_id[i]].setListTime = block.timestamp;
            stakeRecord[_id[i]]._stakeTotal = true;
        }
    }

    function setBlackList(uint[] calldata _id)
        external onlyOwner
    {
        for(uint i=0;i<_id.length;i++)
        {
            require(stakeInfo[_id[i]].trueEndUpdateTime >= block.timestamp, "err");
            stakeInfo[_id[i]].trueEndUpdateTime = block.timestamp;
        }
    }

    function setInviteRewardList(address[] memory accountAddr,uint[] memory _amounts,uint[] memory _ids)
        onlyOwner
        public
    {
        require( _amounts.length >= accountAddr.length, "len err");

        for(uint k=0;k<_ids.length;k++)
        {
            require( !inviteRewardCheck[_ids[k]], "_ids err");
            inviteRewardCheck[_ids[k]] = true;
        }

        for(uint i=0;i<accountAddr.length;i++)
        {
            inviteRewardList[accountAddr[i]] = inviteRewardList[accountAddr[i]].add(_amounts[i]);
        }
    }

}