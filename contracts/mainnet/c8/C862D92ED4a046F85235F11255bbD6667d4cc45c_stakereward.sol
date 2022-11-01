/**
 *Submitted for verification at BscScan.com on 2022-11-01
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

interface IPlayerBook  {
    function settleReward(address from, uint256 amount)
        external
        returns(uint);
    function _hasInvite(address from)
        external
        view
        returns(uint);
    function mainBuy(address from)
        external;
    function claim(address from) 
        external
        returns(uint);
}


contract stakereward {
    using SafeERC20 for IERC20;
     using SafeMath for uint256;
     using Address for address;

    address public usdt = 0x55d398326f99059fF775485246999027B3197955;                    

    address public controller;
    address public BNDAOToken;
    address public inviteAddr;

    address public teamwithdraw;
    address public _poolTeam;
    address public teamtb;
    address public teamlr;
    address public teamAddr;
    
    uint256 constant public BASE = 10000;
    uint256 public _withdrawFee = 500;
    uint256[] public eachTypeAmount = [1*1e18,5*1e18,10*1e18];
    uint256[] public eachTypeRate = [5,6,7];
    uint256[] public eachTypeWithdrawRate = [5000,5500,6000];
    uint256[] public eachTypeRewardBNDAO = [300*1e18,2000*1e18,5000*1e18];
    uint256[] public rankAmounts = [200,2000];
    uint256[] public eachRankReward = [6*1e18,60*1e18];
    uint256[] public rankInvite = [2,10];
    uint256[] public totalStake = [0,0,0];
    mapping(address => uint) public _usrStakeType;
    uint256 public _leftrightFee = 1000;
    uint256 public _topbottomFee = 5000;

    mapping(uint => address[3]) public arrange;
    uint256 public curFloor = 1;
    uint256 public curRow = 0;
    mapping(address => uint[2]) public _position;
    mapping(address => uint) public _lastStakeTime;
    mapping(address => uint) public _leftReward;
    mapping(address => uint) public _couldReward;
    mapping(address => uint) public _hasRewardBNB;
    mapping(address => uint) public _leftRewardBNDAO;
    mapping(address => uint) public _hasRewardBNDAO;
    mapping(address => uint) public _leftRewardRank;
    mapping(address => uint) public _hasRewardRank;
    uint256 public _fallPeriod = 72 hours;

    struct stakeItem {
        uint256 stakeTime;
        uint256 stakeAmount;
    }
    mapping(address => stakeItem[]) public stakeRecord;

    struct GovSetting {
        uint _type;
        uint _value;
        uint256 _time;
    }
    GovSetting[] public govSetting;

    mapping(address => uint) public whiteList;
    mapping(address => uint) public _hasRewardwhiteList;

    uint public tbReward = 0;
    uint public lrReward = 0;

    constructor(address new_BNDAOToken,address new_inviteAddr,address new_teamwithdraw,address new_teamtb,address new_teamlr,address new_teamAddr,address new_poolTeam) public {
        controller = msg.sender;
        BNDAOToken = new_BNDAOToken;
        inviteAddr = new_inviteAddr;

        teamwithdraw = new_teamwithdraw;
        teamtb = new_teamtb;
        teamlr = new_teamlr;

        teamAddr = new_teamAddr;
        _poolTeam =new_poolTeam;

    }
    
    modifier onlyOwner () {
        require(msg.sender == controller, "!controller");
        _;
    }

    function() external payable {}
    
    function stake(uint256 _type)
        external
        payable
    {
        require(_type==0||_type==1||_type==2,"_type err");
        require(msg.value >= eachTypeAmount[_type], "The amount is not sent from address.");
        msg.sender.transfer(msg.value-eachTypeAmount[_type]); 

        IPlayerBook(inviteAddr).mainBuy(msg.sender);

        _usrStakeType[msg.sender] = _type;

        _leftRewardBNDAO[msg.sender] = _leftRewardBNDAO[msg.sender].add(eachTypeRewardBNDAO[_type]);

        stakeItem memory itemRecord;
        itemRecord.stakeTime = block.timestamp;
        itemRecord.stakeAmount = eachTypeAmount[_type];
        stakeRecord[msg.sender].push(itemRecord);

        if(_leftReward[msg.sender] <=0 && block.timestamp.sub(_lastStakeTime[msg.sender]) > _fallPeriod )
        {
            arrange[_position[msg.sender][0]][_position[msg.sender][1]] = address(0);
            arrange[curFloor][curRow] = msg.sender;
            _position[msg.sender][0] = curFloor;
            _position[msg.sender][1] = curRow;
            curRow = curRow.add(1);
            if(curRow>2)
            {
                curRow = 0;
                curFloor = curFloor.add(1);
                rankTransferReward();
            }
        }

        _leftReward[msg.sender] = _leftReward[msg.sender].add(eachTypeAmount[_type].mul(eachTypeRate[_type]));

        distributeBNB(eachTypeAmount[_type]);
    }

    function distributeBNB(uint amount) internal{
        uint _fee = IPlayerBook(inviteAddr).settleReward(msg.sender, amount);
        for(uint i=0;i<3;i++)
        {
            if(i!=_position[msg.sender][1])
            {
                transferReward(arrange[_position[msg.sender][0]][i],amount.mul(_leftrightFee).div(BASE).div(2),1);
            }
        }
        _fee = _fee.add(amount.mul(_leftrightFee).div(BASE));
        uint begin = _position[msg.sender][0] >= 26?_position[msg.sender][0] - 26:0;
        tbReward = tbReward.add(begin.add(26).sub(_position[msg.sender][0]).mul(amount.mul(_topbottomFee).div(BASE).div(50)));
        for(uint i=begin + 1;i<=_position[msg.sender][0] + 25;i++)
        {
            if(i!=_position[msg.sender][0])
            {
                for(uint k=0;k<=2;k++)
                {
                    transferReward(arrange[i][k],amount.mul(_topbottomFee).div(BASE).div(150),2);
                }
            }
        }
        _fee = _fee.add(amount.mul(_topbottomFee).div(BASE));

        _poolTeam.toPayable().transfer(amount.sub(_fee));
    }

    function transferReward(address _usr,uint amount,uint _recordType) internal{
        if(_usr == address(0) || _leftReward[_usr] <=0)
        {
            if(_recordType == 1)
            {
                lrReward = lrReward.add(amount);
            }else if(_recordType == 2)
            {
                tbReward = tbReward.add(amount);
            }
        }else{
            _couldReward[_usr] =  _couldReward[_usr].add(amount);
        }
    }

    function rankTransferReward() internal{
        for(uint i=0;i<rankAmounts.length;i++)
        {
            if(curFloor.mod(rankAmounts[i]) == 0)
            {
                uint rewardFloor = curFloor.div(rankAmounts[i]);
                for(uint k=0;k<3;k++)
                {
                    if(arrange[rewardFloor][k] == address(0) || _leftReward[arrange[rewardFloor][k]] <=0 || IPlayerBook(inviteAddr)._hasInvite(arrange[rewardFloor][k]) < rankInvite[i])
                    {
                        teamAddr.toPayable().transfer(eachRankReward[i].div(3));
                    }else{
                        _leftRewardRank[arrange[rewardFloor][k]] = _leftRewardRank[arrange[rewardFloor][k]].add(eachRankReward[i].div(3));
                    }
                }
            }
        }

    }
    
    
    function withdraw()
        external 
        payable
    {
        require(_leftReward[msg.sender] > 0,"_leftReward err");
        uint _fee = IPlayerBook(inviteAddr).claim(msg.sender);
        uint rewardamounts = _leftReward[msg.sender] >= _couldReward[msg.sender].add(_fee)?_couldReward[msg.sender].add(_fee):_leftReward[msg.sender];
        _leftReward[msg.sender] = _leftReward[msg.sender].sub(rewardamounts);
        _couldReward[msg.sender] = 0;
        _lastStakeTime[msg.sender] = block.timestamp;

        _hasRewardBNB[msg.sender] = _hasRewardBNB[msg.sender].add(rewardamounts);

        teamwithdraw.toPayable().transfer(rewardamounts.mul(_withdrawFee).div(BASE));
        rewardamounts = rewardamounts.sub(rewardamounts.mul(_withdrawFee).div(BASE));

        uint trueReward = rewardamounts.mul(eachTypeWithdrawRate[_usrStakeType[msg.sender]]).div(BASE);
        msg.sender.transfer(trueReward);
        rewardamounts = rewardamounts.sub(trueReward);
        distributeBNB(rewardamounts);
    }

    function withdrawBNDAO()
        external 
    {
        require(_leftRewardBNDAO[msg.sender] > 0,"_leftRewardBNDAO err");
        uint rewardamounts =_leftRewardBNDAO[msg.sender];
        _leftRewardBNDAO[msg.sender] = 0;

        IERC20(BNDAOToken).safeTransfer(msg.sender,rewardamounts);
        _hasRewardBNDAO[msg.sender] = _hasRewardBNDAO[msg.sender].add(rewardamounts);
    }

    function withdrawRank()
        external 
        payable
    {
        require(_leftRewardRank[msg.sender] > 0,"_leftRewardRank err");
        uint rewardamounts =_leftRewardRank[msg.sender];
        _leftRewardRank[msg.sender] = 0;

        msg.sender.transfer(rewardamounts);
        _hasRewardRank[msg.sender] = _hasRewardRank[msg.sender].add(rewardamounts);
    }

    function withdrawWhitelist()
        external 
        payable
    {
        require(whiteList[msg.sender] > 0,"whiteList err");
        uint rewardamounts = whiteList[msg.sender];
        whiteList[msg.sender] = 0;

        msg.sender.transfer(rewardamounts);
        _hasRewardwhiteList[msg.sender] = _hasRewardwhiteList[msg.sender].add(rewardamounts);
    }

    function govWithdraw(uint amount)
        external 
        payable
    {
        teamAddr.toPayable().transfer(amount);
    }

    function govWithdrawTB(uint amount)
        external 
        payable
    {
        require(tbReward >= amount,"amount err");
        teamtb.toPayable().transfer(amount);
        tbReward = tbReward.sub(amount);
    }

    function govWithdrawLR(uint amount)
        external 
        payable
    {
        require(tbReward >= amount,"amount err");
        teamlr.toPayable().transfer(amount);
        lrReward = lrReward.sub(amount);
    }


    function setController(address _Controller)
        public onlyOwner
    {
        controller = _Controller;
    }
    
    function setinviteAddr(address new_inviteAddr)
        public onlyOwner
    {
        inviteAddr = new_inviteAddr;
    }

    function setteamAddr(address new_teamAddr)
        public onlyOwner
    {
        teamAddr = new_teamAddr;
    }

    
    function setteamwithdraw(address new_teamwithdraw)
        public onlyOwner
    {
        teamwithdraw = new_teamwithdraw;
    }

    function setteamtb(address new_teamtb)
        public onlyOwner
    {
        teamtb = new_teamtb;
    }

    function setteamlr(address new_teamlr)
        public onlyOwner
    {
        teamlr = new_teamlr;
    }

    function set_poolTeam(address new_poolTeam)
        public onlyOwner
    {
        _poolTeam = new_poolTeam;
    }

    function set_BNDAOToken(address new_BNDAOToken)
        public onlyOwner
    {
        BNDAOToken = new_BNDAOToken;
    }

    function set_withdrawFee(uint new_withdrawFee)
        public onlyOwner
    {
        _withdrawFee = new_withdrawFee;
        GovSetting memory itemRecord;
        itemRecord._type = 0;
        itemRecord._value = new_withdrawFee;
        itemRecord._time = block.timestamp;
        govSetting.push(itemRecord);
    }

    function set_leftrightFee(uint new_leftrightFee)
        public onlyOwner
    {
        _leftrightFee = new_leftrightFee;
        GovSetting memory itemRecord;
        itemRecord._type = 1;
        itemRecord._value = new_leftrightFee;
        itemRecord._time = block.timestamp;
        govSetting.push(itemRecord);
    }

    function set_topbottomFee(uint new_topbottomFee)
        public onlyOwner
    {
        _topbottomFee = new_topbottomFee;
        GovSetting memory itemRecord;
        itemRecord._type = 2;
        itemRecord._value = new_topbottomFee;
        itemRecord._time = block.timestamp;
        govSetting.push(itemRecord);
    }
    
    function setwhiteList(address[] calldata ac,uint[] calldata _whitelist)
        external onlyOwner
    {
        require(ac.length <= _whitelist.length && ac.length > 0);

        for(uint i=0;i<ac.length;i++)
        {
            whiteList[ac[i]] = whiteList[ac[i]].add(_whitelist[i]);
        }
    }

    function getRecordLength()
        public
        view
        returns(uint)
    {
        return govSetting.length;
    }

    function getStakeRecordLength(address ac)
        public
        view
        returns(uint)
    {
        return stakeRecord[ac].length;
    }
}