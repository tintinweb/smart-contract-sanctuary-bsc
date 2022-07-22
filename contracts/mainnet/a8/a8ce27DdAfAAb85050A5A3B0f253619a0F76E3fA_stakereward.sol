/**
 *Submitted for verification at BscScan.com on 2022-07-22
*/

pragma solidity >= 0.5.0 < 0.6.0;

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
    function isContract(address account) internal view returns (bool) {
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly { codehash := extcodehash(account) }
        return (codehash != 0x0 && codehash != accountHash);
    }
    function toPayable(address account) internal pure returns (address payable) {
        return address(uint160(account));
    }
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        // solhint-disable-next-line avoid-call-value
        (bool success, ) = recipient.call.value(amount)("");
        require(success, "Address: unable to send value, recipient may have reverted");
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


interface tokenCon
{
  function mint(address to, uint256 amount) external;
}

interface IPowerStrategy {
    function addPwr(uint amount) external;
}

interface uniswap{
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
}

contract stakereward {
    using SafeERC20 for IERC20;
     using SafeMath for uint256;
     using Address for address;
    
    address public usdbToken;
    address public bccToken;
    
    address public controller;
	address public gov;
	
    struct accountInfo{
        uint lastUpdate;
        uint balanceBCC;
        uint balanceUSDB;
        uint leftReward;
    }
    
    uint256 constant public _periodFinish = 1 days;
    uint256 constant public BASE = 10000;

    mapping(address => accountInfo) accounts;
    mapping(address => uint) public endTime;
    mapping(address => uint) public rate;
    mapping(address => uint) public hasReward;

    uint256 public  _powerrate;
    address public pwrCtrl;
    address public swapAddr = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address[] public routeBCC;
    address[] public routeUSDB;
    uint public desNum = 200*1e18;
    uint public lockperiod;
    
    constructor(address _usdbToken,address _bccToken,uint new_powerrate,uint _lockperiod) public {
        controller = msg.sender;
        gov = msg.sender;
        usdbToken = _usdbToken;
        bccToken = _bccToken;
        _powerrate = new_powerrate;
        routeBCC = [_usdbToken,_bccToken];
        routeUSDB = [_bccToken,_usdbToken];
        lockperiod = _lockperiod;
    }
    
    modifier onlyOwner () {
        require(msg.sender == controller || msg.sender == gov, "!controller");
        _;
    }
    
    function stake(uint256 amount)
        public
    {
        require(amount >= 0, "cant stake 0");
        amount= amount.mul(desNum);
        uint[] memory tokennum = uniswap(swapAddr).getAmountsOut(amount,routeBCC);
        uint bccAmounts = tokennum[tokennum.length-1];
        
        IERC20(usdbToken).safeTransferFrom(msg.sender, address(this), amount);
        IERC20(bccToken).safeTransferFrom(msg.sender, address(this), bccAmounts);

        accounts[msg.sender].leftReward = getRewardNum(msg.sender);
        accounts[msg.sender].lastUpdate = block.timestamp;
        accounts[msg.sender].balanceBCC = accounts[msg.sender].balanceBCC.add(bccAmounts);
        accounts[msg.sender].balanceUSDB = accounts[msg.sender].balanceUSDB.add(amount);

        endTime[msg.sender] = block.timestamp.add(lockperiod);
        uint[] memory bccnum = uniswap(swapAddr).getAmountsOut(accounts[msg.sender].balanceUSDB.mul(2),routeBCC);
        uint rateAmounts = bccnum[bccnum.length-1];
        rate[msg.sender] = rateAmounts.mul(_powerrate).div(100).div(_periodFinish);

        IPowerStrategy(pwrCtrl).addPwr(amount.mul(2));
    }

    function getStakeBCC(uint256 amount) public view returns(uint ret){
        amount= amount.mul(desNum);
        uint[] memory tokennum = uniswap(swapAddr).getAmountsOut(amount,routeBCC);
        ret = tokennum[tokennum.length-1];
    }
    
    
    function getRewardNum(address _usr) public view returns(uint ret){
        uint _timeinfo = 0;
        if(accounts[_usr].lastUpdate > 0 && accounts[_usr].lastUpdate <= block.timestamp)
        {
            _timeinfo = block.timestamp.sub(accounts[_usr].lastUpdate);
        }
        ret = rate[_usr].mul(_timeinfo).add(accounts[_usr].leftReward);
    }
    
    function getBalanceOFBCC(address _usr) public view returns(uint ret){
        
        ret = accounts[_usr].balanceBCC;
    }

    function getBalanceOFUSDB(address _usr) public view returns(uint ret){
        
        ret = accounts[_usr].balanceUSDB;
    }
    
    function withdraw(uint256 amount)
        public 
    {
        require(endTime[msg.sender] <= block.timestamp,"err");
        require(accounts[msg.sender].balanceUSDB >= amount,"amount err");

        accounts[msg.sender].leftReward = getRewardNum(msg.sender);
        accounts[msg.sender].lastUpdate = block.timestamp;
        uint bccamunts = accounts[msg.sender].balanceBCC.mul(amount).div(accounts[msg.sender].balanceUSDB);
        accounts[msg.sender].balanceUSDB = accounts[msg.sender].balanceUSDB.sub(amount);
        accounts[msg.sender].balanceBCC = accounts[msg.sender].balanceBCC.sub(bccamunts);
        
        IERC20(usdbToken).safeTransfer(msg.sender,amount);
        IERC20(bccToken).safeTransfer(msg.sender,bccamunts);

        uint[] memory bccnum = uniswap(swapAddr).getAmountsOut(accounts[msg.sender].balanceUSDB.mul(2),routeBCC);
        uint rateAmounts = bccnum[bccnum.length-1];
        rate[msg.sender] = rateAmounts.mul(_powerrate).div(100).div(_periodFinish);
        
    }

    function getReward() public {
        uint rewardAmounts = getRewardNum(msg.sender);

        accounts[msg.sender].leftReward = 0;
        accounts[msg.sender].lastUpdate = block.timestamp;

        tokenCon(bccToken).mint(address(this),rewardAmounts);
        IERC20(bccToken).safeTransfer(msg.sender,rewardAmounts);
    }
    
    function govWithdraw(address ercToken,uint256 amount)
        public onlyOwner
    {
        require(amount > 0, "Cannot withdraw 0");
        IERC20(ercToken).safeTransfer(msg.sender,amount);
    }
    
    function setController(address _Controller)
        public onlyOwner
    {
        controller = _Controller;
    }

    function setPowerrate(uint256 new_powerrate)
        public onlyOwner
    {
        _powerrate = new_powerrate;
    }

    function set_pwr_address(address _pwrCtrl)public onlyOwner{
        pwrCtrl = _pwrCtrl;
    }

    function setDesNum( uint _desNum) external onlyOwner {
        desNum = _desNum;
    }
}