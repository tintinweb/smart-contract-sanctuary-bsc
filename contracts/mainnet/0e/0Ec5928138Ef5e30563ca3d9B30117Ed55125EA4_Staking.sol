/**
 *Submitted for verification at BscScan.com on 2022-07-11
*/

// SPDX-License-Identifier: MIT
pragma solidity =0.8.0;

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
}

library Counters {
    struct Counter {
        // This variable should never be directly accessed by users of the library: interactions must be restricted to
        // the library's function. As of Solidity v0.5.2, this cannot be enforced, though there is a proposal to add
        // this feature: see https://github.com/ethereum/solidity/issues/4637
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {
        return counter._value;
    }

    function increment(Counter storage counter) internal {
        unchecked {
            counter._value += 1;
        }
    }

    function decrement(Counter storage counter) internal {
        uint256 value = counter._value;
        require(value > 0, "Counter: decrement overflow");
        unchecked {
            counter._value = value - 1;
        }
    }

    function reset(Counter storage counter) internal {
        counter._value = 0;
    }
}

interface IPancakePair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);

    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}

interface IPancakeFactory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}

interface IPancakeRouter01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

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
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

interface IPancakeRouter02 is IPancakeRouter01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
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

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _setOwner(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

contract HasNoEther is Ownable {

  /**
   * @dev Transfer all Ether held by the contract to the owner.
   */
  function reclaimEther() external onlyOwner {
     address _owner  = owner();
     payable(_owner).transfer(address(this).balance);
  }
  
  function reclaimTokenByAmount(address tokenAddress,uint amount) external onlyOwner {
     require(tokenAddress != address(0),'tokenAddress can not a Zero address');
     IERC20 token = IERC20(tokenAddress);
     address _owner  = owner();
     token.transfer(_owner,amount);
  }

  function reclaimToken(address tokenAddress) external onlyOwner {
     require(tokenAddress != address(0),'tokenAddress can not a Zero address');
     IERC20 token = IERC20(tokenAddress);
     address _owner  = owner();
     token.transfer(_owner,token.balanceOf(address(this)));
  }
}

interface IFootBall {
    function lotteryBirth(address _owner) external;
    function _tokenIdCounter() external view returns(uint);
}

contract Staking is HasNoEther{

    using SafeMath for uint256;
    using Counters for Counters.Counter;
    Counters.Counter public _stakingCounter;
    Counters.Counter public _randomCounter;

    uint256 public limitTime = 7 days;
    uint256 public rewardTime = 1 days;
    uint256 public limitAmount = 500 * 1e18;
    uint256 public limitLottery = 10;
    address public _token = 0xaD04AC36791d923DeB082dA4f91Ab71675dD18fB;
    address public _wbnb = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address public _router = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address public _usdt = 0x55d398326f99059fF775485246999027B3197955;
    address public _nft = 0xFa7C948d914782DB158cdF96f22B0ce50DFC1047;
    uint256 public _openRate = 80;
    uint256 public _pageSize = 10;

    struct Stake{
        address _owner;
        uint256 _usdtAmount;
        uint256 _tokenAmount;
        uint256 _lastRewardTime;
        uint256 _stakingTime;
        bool _valid;
    }

    mapping(uint256 => Stake) public stakes;
    
    mapping(address=>uint256[]) public userStakingList;

    event LotteryEvent(address indexed sender,bool[] result);

    event ExitStakingEvent(address indexed sender,uint256 indexed id);

    event StakingEvent(address indexed sender,uint256 indexed id,uint256 amount);

    function setRate(uint256 _rate) external onlyOwner{
        _openRate = _rate;
    }

    function canExit(uint256 _id) external view returns(bool _exit) {
        Stake memory stake = stakes[_id];
        return stake._valid && stake._stakingTime.add(limitTime) < block.timestamp;
    }

    function datas(uint page) external view returns(uint256[] memory,uint256 next,bool flag){
        uint256[] memory userIds = userStakingList[msg.sender];
         uint256[] memory ids;
        if(userIds.length > 0){
            uint256 prePage = page.sub(1);
            uint256 start = prePage.mul(_pageSize);
            uint256 end = page.mul(_pageSize).sub(1);
            if(userIds.length>0 && end >= userIds.length ){
                end = userIds.length-1;
            }
            ids = new uint256[](end.sub(start).add(1));
            uint256 index;
            for(uint i = start;i<=end;i++){
                ids[index] = userIds[i];
                index += 1;
            }
            flag = true;
            next = page+1;
            if(prePage.mul(_pageSize).add(ids.length) >= userIds.length){
                flag = false;
                next = 0;
            }
        }
        return (ids,next,flag);
    }

    function exitStaking(uint256 _id) external {
        Stake storage stake = stakes[_id];
        require(stake._owner == msg.sender,'STAKING: not owner of you');
        require(stake._valid,'STAKING: Has been exit');
        uint256 _duration = block.timestamp - stake._stakingTime;
        require(_duration > limitTime,'STAKING: Time not yet');
        stake._valid = false;
        stake._owner = address(0);
        stakes[_id] = stake;
        uint256 _tokenAmount = stake._tokenAmount;
        IERC20(_token).transfer(msg.sender,_tokenAmount);
        emit ExitStakingEvent(msg.sender,_id);
    }

    function staking(uint256 _count) external {
        require(_count>0,'STAKING:invalid staking count');
        uint amount = _count.mul(limitAmount);
        uint256 _tokenAmount = getTokenAmount(amount);
        require(IERC20(_token).balanceOf(msg.sender)>_tokenAmount,'STAKING: MELI is not enough');
        IERC20(_token).transferFrom(msg.sender,address(this),_tokenAmount);
        uint256 _id = _stakingCounter.current()+1;
        _stakingCounter.increment();
        userStakingList[msg.sender].push(_id);
        Stake memory stake = Stake(msg.sender,amount,_tokenAmount,block.timestamp,block.timestamp,true);
        stakes[_id] = stake;
        emit StakingEvent(msg.sender,_id,amount);
    }

    function lottery(uint256[] calldata _ids) external {
        uint256 drawable = 0;
        uint256 _pending = 0;
        uint256 _use = 0;
        Stake storage stake;
        for(uint i=0;i<_ids.length;i++){
            stake = stakes[_ids[i]];
            if(stake._owner == msg.sender){
                _pending = pending(_ids[i]);
                if(drawable.add(_pending) > limitLottery){
                    _use = limitLottery.sub(drawable);
                    drawable = limitLottery;
                    if(_use > 0){
                       uint256 _last = stake._lastRewardTime;
                       stake._lastRewardTime = _last.add(_use.mul(rewardTime));
                    }
                    break;
                }
                drawable += _pending;
                stake._lastRewardTime = block.timestamp;
            }
        }
        require(drawable > 0,'STAKING:lottery error');
        bool[] memory result;
        if(drawable > 0){
            result = new bool[](drawable);
            for(uint i=0;i< drawable; i++){
                result[i] = _receive();
            }
        }
        emit LotteryEvent(msg.sender,result);
    }

    function _receive() internal returns(bool) {
        uint randNonce = _randomCounter.current();
        uint _random = uint(keccak256(abi.encodePacked(block.timestamp, msg.sender, randNonce))) % 100;
        _randomCounter.increment();
        bool flag = _random <= _openRate;
        if(flag){
            IFootBall(_nft).lotteryBirth(msg.sender);
        }
        return flag;
    }

    function drawableCount() external view returns(uint256 count){
        uint256[] memory userIds = userStakingList[msg.sender];
        for(uint256 i=0; i<userIds.length; i++){
            count += pending(userIds[i]);
        }
        return count;
    }

    function pending(uint256 _id) internal view returns(uint256 drawable) {
        Stake memory stake = stakes[_id];
        if (stake._valid && stake._lastRewardTime < block.timestamp) {
            uint256 _mul = stake._usdtAmount.div(limitAmount);
            uint256 remainSecond = block.timestamp - stake._lastRewardTime;
            uint256 remainDays = remainSecond / rewardTime;
            drawable = remainDays.mul(_mul);
        }
        return drawable;
    }

    function getTokenAmount (uint256 amount) public view returns(uint256) {
        uint256 amount1 = _getPrice(_usdt,_wbnb,amount);
        return _getPrice(_wbnb,_token,amount1);
    }

    function _getPrice(
        address t0,address t1,uint256 amount)
        internal 
        view 
        returns (uint256)  
    {
        address pair = IPancakeFactory(IPancakeRouter02(_router).factory()).getPair(t0, t1);    
        (uint256 r0,uint256 r1,) = IPancakePair(pair).getReserves();
        (uint256 reserve0, uint256 reserve1) = (IPancakePair(pair).token0() == t0) ? (r0, r1) : (r1, r0); 
        return  IPancakeRouter02(_router).getAmountOut(amount, reserve0, reserve1);
    }

}