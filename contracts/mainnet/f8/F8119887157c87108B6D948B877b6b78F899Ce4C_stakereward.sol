/**
 *Submitted for verification at BscScan.com on 2022-08-19
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


interface nftcon
{
  function  getAllType(uint _tid) external view returns (bool ret_random,uint256 ret_amounts);

  function safeTransferFrom(
    address _from,
    address _to,
    uint256 _tokenId
  )
    external;

}

library EnumerableSet {
   
    struct Set {
        bytes32[] _values;
        mapping (bytes32 => uint256) _indexes;
    }

    function _add(Set storage set, bytes32 value) private returns (bool) {
        if (!_contains(set, value)) {
            set._values.push(value);
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    function _remove(Set storage set, bytes32 value) private returns (bool) {
        
        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) { // Equivalent to contains(set, value)
            
            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;

    
            bytes32 lastvalue = set._values[lastIndex];

            set._values[toDeleteIndex] = lastvalue;
            // Update the index for the moved value
            set._indexes[lastvalue] = toDeleteIndex + 1; // All indexes are 1-based

            set._values.pop();

            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

    
    function _contains(Set storage set, bytes32 value) private view returns (bool) {
        return set._indexes[value] != 0;
    }

    
    function _length(Set storage set) private view returns (uint256) {
        return set._values.length;
    }

   
    function _at(Set storage set, uint256 index) private view returns (bytes32) {
        require(set._values.length > index, "EnumerableSet: index out of bounds");
        return set._values[index];
    }

    struct Bytes32Set {
        Set _inner;
    }

    
    function add(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _add(set._inner, value);
    }


    function remove(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _remove(set._inner, value);
    }

    
    function contains(Bytes32Set storage set, bytes32 value) internal view returns (bool) {
        return _contains(set._inner, value);
    }

   
    function length(Bytes32Set storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

   
    function at(Bytes32Set storage set, uint256 index) internal view returns (bytes32) {
        return _at(set._inner, index);
    }

    struct AddressSet {
        Set _inner;
    }

    
    function add(AddressSet storage set, address value) internal returns (bool) {
        return _add(set._inner, bytes32(uint256(uint160(value))));
    }


    function remove(AddressSet storage set, address value) internal returns (bool) {
        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }

   
    function contains(AddressSet storage set, address value) internal view returns (bool) {
        return _contains(set._inner, bytes32(uint256(uint160(value))));
    }

   
    function length(AddressSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

   
    function at(AddressSet storage set, uint256 index) internal view returns (address) {
        return address(uint160(uint256(_at(set._inner, index))));
    }

    struct UintSet {
        Set _inner;
    }

    
    function add(UintSet storage set, uint256 value) internal returns (bool) {
        return _add(set._inner, bytes32(value));
    }

    
    function remove(UintSet storage set, uint256 value) internal returns (bool) {
        return _remove(set._inner, bytes32(value));
    }

    
    function contains(UintSet storage set, uint256 value) internal view returns (bool) {
        return _contains(set._inner, bytes32(value));
    }

    
    function length(UintSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

   
    function at(UintSet storage set, uint256 index) internal view returns (uint256) {
        return uint256(_at(set._inner, index));
    }
}


interface lastpbook{
    function _pIDxAddr(address from)
        external view returns(uint256);

    function getPlayerName(address from)
        external view returns (bytes32);

    function getPlayerLaffName(address from)
        external view returns (bytes32);
}

interface uniswap{
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
}

contract stakereward {
    using SafeERC20 for IERC20;
     using SafeMath for uint256;
     using Address for address;
    using EnumerableSet for EnumerableSet.AddressSet;
    
    address public nftToken;
    address public punkplusToken;
    address public punkToken;

    address public swapAddr = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address  usdtToken = 0x55d398326f99059fF775485246999027B3197955; 
    
    address public controller;
	address public gov;
    
    uint256 constant public BASE = 10000;

    uint256[] public _referRewardRate = [1000,900,800,700,600,500,400,300,200,100];     //todo

    uint256 public  DURATION = 1 days;       //todo
    uint256 public _initReward = 8561 * 1e18;
    uint256 public _startTime =  now + 365 days;
    uint256 public _periodFinish = 0;
    uint256 public _rewardRate = 0;
    uint256 public _lastUpdateTime;
    uint256 public _rewardPerTokenStored;
    mapping(address => uint256) public _userRewardPerTokenPaid;
    mapping(address => uint256) public _rewards;
    mapping(address => uint256) public _lastStakedTime;
    mapping(address => uint256) public balanceOf;
    bool public _hasStart = false;
    uint public totalSupply = 0;
    mapping (address => bool) public _hasStake;

    mapping(address => uint) public hasReward;
    mapping(address => uint) public hasaffReward;

    uint256 public  _punkplusrate = 1000;
    
    address public lastplayerbook;
    mapping (bytes32 => bool) public _iscomfirmAddr;
    mapping (bytes32 => address) public _bytes2Addr;
    mapping (address => address) public _lastLaffAddr;

    bytes32 govname;

    EnumerableSet.AddressSet addrProviders;
    mapping(address => bool) public addrExist;

    address[] public route;
    
    constructor(address new_nftToken,address new_punkplusToken,address new_punkToken,bytes32 new_govname,address new_playbookgov,address new_lastplayerbook) public {
        controller = msg.sender;
        gov = msg.sender;
        nftToken = new_nftToken;
        punkplusToken = new_punkplusToken;
        punkToken = new_punkToken;
        govname = new_govname;
        _bytes2Addr[govname] = new_playbookgov;
        lastplayerbook = new_lastplayerbook;
        route =  [punkToken,usdtToken,punkplusToken];
    }
    
    modifier onlyOwner () {
        require(msg.sender == controller || msg.sender == gov, "!controller");
        _;
    }

    modifier updateReward(address account) {
        _rewardPerTokenStored = rewardPerToken();
        _lastUpdateTime = lastTimeRewardApplicable();
        if (account != address(0)) {
            _rewards[account] = earned(account);
            _userRewardPerTokenPaid[account] = _rewardPerTokenStored;
        }
        _;
    }

    function set_initReward(uint256 initamount) public onlyOwner{
        _initReward = initamount;
    }

     function lastTimeRewardApplicable() public view returns (uint256) {
        return Math.min(block.timestamp, _periodFinish);
    }

    function rewardPerToken() public view returns (uint256) {
        if (totalSupply == 0) {
            return _rewardPerTokenStored;
        }
        return
            _rewardPerTokenStored.add(
                lastTimeRewardApplicable()
                    .sub(_lastUpdateTime)
                    .mul(_rewardRate)
                    .mul(1e18)
                    .div(totalSupply)
            );
    }

    function earned(address account) public view returns (uint256) {
        return
            balanceOf[account]
                .mul(rewardPerToken().sub(_userRewardPerTokenPaid[account]))
                .div(1e18)
                .add(_rewards[account]);
    }
    
    function stake(uint256 _tokenid)
        public
        updateReward(msg.sender)
        checkHalve
        checkStart
    {
       require(!_hasStake[msg.sender],"err"); 
       _hasStake[msg.sender] = true;

      nftcon(nftToken).safeTransferFrom(msg.sender,address(this),_tokenid);

      bool israndom;
      uint nftvalue;

      (israndom,nftvalue) = nftcon(nftToken).getAllType(_tokenid);

      IERC20(punkplusToken).safeTransferFrom(msg.sender, address(this), getplusAmounts(_tokenid));

      if(!addrExist[msg.sender])
      {
            addrProviders.add(msg.sender);
            addrExist[msg.sender] = true;
      }

      totalSupply = totalSupply.add(nftvalue);
      balanceOf[msg.sender] = balanceOf[msg.sender].add(nftvalue);
    }

    function getplusAmounts(uint _tokenid) public view returns(uint ret){
        (,uint _nftvalue) = nftcon(nftToken).getAllType(_tokenid);
        uint[] memory plusnum = uniswap(swapAddr).getAmountsOut(_nftvalue,route);
        ret = plusnum[plusnum.length-1].mul(_punkplusrate).div(BASE);

    }

    function getReward() public updateReward(msg.sender) checkHalve checkStart{

        uint256 reward = earned(msg.sender);
        if (reward > 0) {
            _rewards[msg.sender] = 0;

           if(reward>0){
                IERC20(punkplusToken).safeTransfer(msg.sender,reward);
                hasReward[msg.sender] = hasReward[msg.sender].add(reward);
            }

            address curlastAddr;
            address curAddr = msg.sender;
            uint256 affReward;
            for(uint i=0;i<_referRewardRate.length;i++)
            {
                curlastAddr = _lastLaffAddr[curAddr];
                affReward = reward.mul(_referRewardRate[i]).div(BASE);
                if(curlastAddr == address(0))
                {
                    break;
                }
                if(balanceOf[curlastAddr] > 0)
                {
                    IERC20(punkplusToken).safeTransfer(curlastAddr,affReward);
                    hasaffReward[curlastAddr] = hasaffReward[curlastAddr].add(affReward);
                }
                curAddr = curlastAddr;
            }
        }

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

    function setpunkRate(uint new_rate)
        public onlyOwner
    {
        _punkplusrate = new_rate;
    }

    function onERC721Received(
    address _operator,
    address _from,
    uint256 _tokenId,
    bytes calldata _data
  )
    external
    returns(bytes4){
        return 0x150b7a02;
    }

    function comfirm()
        external
    {
        bytes32 lastlaffname = lastpbook(lastplayerbook).getPlayerLaffName(msg.sender);
        bytes32 lastname = lastpbook(lastplayerbook).getPlayerName(msg.sender);

        require(_iscomfirmAddr[lastlaffname] || lastlaffname == govname,"playerbook err");

        if(_iscomfirmAddr[lastlaffname] || lastlaffname == govname)
        {
            _iscomfirmAddr[lastname] = true;
            _bytes2Addr[lastname] = msg.sender;
            _lastLaffAddr[msg.sender] =  _bytes2Addr[lastlaffname];
        }
    }

    function setReferRewardRate(uint256[] memory referRate) public  
        onlyOwner
    {
        _referRewardRate = referRate;
    }

    function addnftRewardAmounts(uint256 amounts) public  
        onlyOwner
    {
        IERC20(punkToken).safeTransferFrom(msg.sender,address(this),amounts);

        uint256 addrCount = addrProviders.length();

        if (addrCount == 0) return;

        uint256 iterations = 0;
        while (iterations < addrCount) {
            address curAddr = addrProviders.at(iterations);
            uint256 reward = balanceOf[curAddr].mul(amounts).div(totalSupply);

            IERC20(punkToken).safeTransfer(curAddr,reward);

            iterations++;
        }
    }

    modifier checkHalve() {
        if (block.timestamp >= _periodFinish) {
            _rewardRate = _initReward.div(DURATION);
            _periodFinish = block.timestamp.add(DURATION);
        }
        _;
    }
    
    modifier checkStart() {
        require(block.timestamp > _startTime, "not start");
        _;
    }
    
    

    // set fix time to start reward
    function startReward(uint256 startTime ,uint rewadnum)
        external
        onlyOwner
        updateReward(address(0))
    {
        require(_hasStart == false, "has started");
        _hasStart = true;
        _startTime = startTime;
        _initReward = rewadnum;
        _rewardRate = _initReward.div(DURATION); 
        
        _lastUpdateTime = _startTime;
        _periodFinish = _startTime.add(DURATION);
    }

}