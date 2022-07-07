/**
 *Submitted for verification at BscScan.com on 2022-07-07
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

interface IPlayerBook {
    function settleRewardNODE( address from,uint256 amount ) external;
}


contract stakereward {
    using SafeERC20 for IERC20;
     using SafeMath for uint256;
     using Address for address;
    
    struct rewardinfo{
        uint endTime;      
        uint  lastUpdate;
        uint  rate;
    }

    struct iteminfo{
        uint _round;
        address _account;
        uint _amount;
        uint _fir;
        uint _price;
        uint _time;
    }

    struct GovSetting {
        uint _type;
        uint _value;
        uint256 _time;
    }
    GovSetting[] public govSetting;

    mapping(address => rewardinfo) public all;
    iteminfo[] public allItems;
    
    address public rewardsToken;
    address public stakeToken;
    uint256 public _periodFinish = 0 days;
    uint256 public curPrice = 100;              //mul        10000                       
    uint256 public leftRewardNum = 100*10**18;
    uint256 public totalRewardNum = 100*10**18;         
    uint public curRoundCount;   
    mapping(address => uint) public whitelist;         

    address public controller;
    address public gov;
    address public gainner;
    
    uint256 constant public BASE = 10000;
    uint256 public fir = 1000;
    uint256 public nodeRate = 3000;
    mapping(address => uint) public hasReward;
    address public inviteADDR;

    constructor(address _inviteADDR,address _gainner,address _rewardsToken,address _stakeToken) public {
        controller = msg.sender;
        gov = msg.sender;
        inviteADDR = _inviteADDR;
        gainner = _gainner;
        rewardsToken = _rewardsToken;
        stakeToken = _stakeToken;
    }
    
    modifier onlyOwner () {
        require(msg.sender == controller || msg.sender == gov, "!controller");
        _;
    }
    
    function stake(uint256 amount)
        external
    {
        require(whitelist[msg.sender] > 0 ,"white list");

        if(whitelist[msg.sender] >= amount)
        {
            whitelist[msg.sender] = whitelist[msg.sender].sub(amount);
        }else{
            uint inviteAmounts = amount.mul(nodeRate).div(BASE);
            IERC20(stakeToken).safeTransferFrom(msg.sender,gainner,amount.sub(inviteAmounts));
            IERC20(stakeToken).safeTransferFrom(msg.sender,inviteADDR,inviteAmounts);
            IPlayerBook(inviteADDR).settleRewardNODE(msg.sender,inviteAmounts);
        }
        
        //left
        uint leftReward = 0;
        uint curendtime = all[msg.sender].endTime;
        uint curlastUpdate = all[msg.sender].lastUpdate;
        uint currate = all[msg.sender].rate;
        if(curendtime>curlastUpdate)
        {
            leftReward = currate.mul(curendtime.sub(curlastUpdate));
        }
        
        uint exchangeNum = amount.mul(BASE).div(curPrice);
        require(exchangeNum <= leftRewardNum, "leftRewardNum err");

        leftRewardNum = leftRewardNum.sub(exchangeNum);
    
        iteminfo memory itemRecord;
        itemRecord._round = curRoundCount;
        itemRecord._account = msg.sender;
        itemRecord._amount = exchangeNum;
        itemRecord._price = curPrice;
        itemRecord._time = block.timestamp;

        //update
        uint firAmounts = exchangeNum.mul(fir).div(BASE);
        IERC20(rewardsToken).safeTransfer(msg.sender,firAmounts);
        exchangeNum = exchangeNum.sub(firAmounts);

        itemRecord._fir = firAmounts;
        allItems.push(itemRecord);

        if(_periodFinish == 0)
        {
            IERC20(rewardsToken).safeTransfer(msg.sender,exchangeNum);
            return;
        }
        leftReward = exchangeNum.add(leftReward);
        all[msg.sender].endTime = _periodFinish.add(block.timestamp);
        all[msg.sender].lastUpdate = block.timestamp;
        all[msg.sender].rate = leftReward.div(_periodFinish);
    }
    
    function lastTimeRewardApplicable(address account) public view returns (uint256) {
        return Math.min(block.timestamp, all[account].endTime);
    }
    
    
    function getRewardNum(address _usr) public view returns(uint ret){
        uint timeNum = lastTimeRewardApplicable(_usr);
        uint usrNum = all[_usr].rate.mul(timeNum.sub(all[_usr].lastUpdate));
        ret = usrNum;
    }
    
    function getBalanceOF(address _usr) public view returns(uint ret){
        uint usrNum = all[_usr].rate.mul(all[_usr].endTime.sub(all[_usr].lastUpdate));
        ret = usrNum;
    }

    function getItemBalanceOF() public view returns(uint ret){
        ret = allItems.length;
    }
    
    function withdraw()
        external 
    {
            if(all[msg.sender].endTime <= all[msg.sender].lastUpdate)
            {
                return;
            }
            uint timeNum = lastTimeRewardApplicable(msg.sender);
            uint usrNum = all[msg.sender].rate.mul(timeNum.sub(all[msg.sender].lastUpdate));
            all[msg.sender].lastUpdate = timeNum;
            
            IERC20(rewardsToken).safeTransfer(msg.sender,usrNum);
            hasReward[msg.sender] = hasReward[msg.sender].add(usrNum);
    }
    
    
    function govWithdrawR(uint256 amount,address rewardtokenAddr)
        public payable onlyOwner
    {
        require(amount > 0, "Cannot withdraw 0");
        IERC20(rewardtokenAddr).safeTransfer(msg.sender,amount);
    }

    function setIvite(address _ivAddr)
        public onlyOwner
    {
        inviteADDR = _ivAddr;
    }
    
    function setController(address _Controller)
        public onlyOwner
    {
        controller = _Controller;
    }

    function setRoundCount(uint _curRoundCount)
        public onlyOwner
    {
        curRoundCount = _curRoundCount;
        GovSetting memory itemRecord;
        itemRecord._type = 0;
        itemRecord._value = _curRoundCount;
        itemRecord._time = block.timestamp;
        govSetting.push(itemRecord);
    }
    
    function setGainner(address _gainner)
        public onlyOwner
    {
        gainner = _gainner;
    }

    function setperiodFinish(uint newperiodFinish)
        public onlyOwner
    {
        _periodFinish = newperiodFinish;

        GovSetting memory itemRecord;
        itemRecord._type = 4;
        itemRecord._value = newperiodFinish;
        itemRecord._time = block.timestamp;
        govSetting.push(itemRecord);
    }
    
    function setcurPrice(uint newcurPrice)
        public onlyOwner
    {
        require(newcurPrice > 0,"err");
        curPrice = newcurPrice;

        GovSetting memory itemRecord;
        itemRecord._type = 2;
        itemRecord._value = newcurPrice;
        itemRecord._time = block.timestamp;
        govSetting.push(itemRecord);
    }
    
    function setleftRewardNum(uint newleftRewardNum)
        public onlyOwner
    {
        require(newleftRewardNum > 0,"err");
        totalRewardNum = newleftRewardNum;
        leftRewardNum = newleftRewardNum;

        GovSetting memory itemRecord;
        itemRecord._type = 1;
        itemRecord._value = newleftRewardNum;
        itemRecord._time = block.timestamp;
        govSetting.push(itemRecord);
    }

    function setfirRATE(uint newfirRATE)
        public onlyOwner
    {
        fir = newfirRATE;

        GovSetting memory itemRecord;
        itemRecord._type = 3;
        itemRecord._value = newfirRATE;
        itemRecord._time = block.timestamp;
        govSetting.push(itemRecord);
    }

    function setNodeRATE(uint newnodeRate)
        public onlyOwner
    {
        nodeRate = newnodeRate;

        GovSetting memory itemRecord;
        itemRecord._type = 5;
        itemRecord._value = newnodeRate;
        itemRecord._time = block.timestamp;
        govSetting.push(itemRecord);
    }

    function getgovSettingBalanceOF() public view returns(uint ret){
        ret = govSetting.length;
    }

    function addWhitelist( address[] calldata newlist,uint[] calldata newnum) external onlyOwner {
        require(newlist.length <= newnum.length,"err");
         for(uint i=0;i<newlist.length;i++){
             whitelist[newlist[i]] = whitelist[newlist[i]].add(newnum[i]);
         }
        
    }
}