/**
 *Submitted for verification at BscScan.com on 2022-10-18
*/

// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.17;
interface IAGENT {
    function swap(uint inAmount, address[] calldata path, address to) external;
}
interface IBEP20 {
    /**
     * @dev Returns the amount of tokens in existence.
   */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the token decimals.
   */
    function decimals() external view returns (uint8);

    /**
     * @dev Returns the token symbol.
   */
    function symbol() external view returns (string memory);

    /**
    * @dev Returns the token name.
  */
    function name() external view returns (string memory);

    /**
     * @dev Returns the bep token owner.
   */
    function getOwner() external view returns (address);

    /**
     * @dev Returns the amount of tokens owned by `account`.
   */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
   *
   * Returns a boolean value indicating whether the operation succeeded.
   *
   * Emits a {Transfer} event.
   */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
   * allowed to spend on behalf of `owner` through {transferFrom}. This is
   * zero by default.
   *
   * This value changes when {approve} or {transferFrom} are called.
   */
    function allowance(address _owner, address spender) external view returns (uint256);

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
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
   * allowance mechanism. `amount` is then deducted from the caller's
   * allowance.
   *
   * Returns a boolean value indicating whether the operation succeeded.
   *
   * Emits a {Transfer} event.
   */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

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
}

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
contract Context {
    // Empty internal constructor, to prevent people from mistakenly deploying
    // an instance of this contract, which should be used via inheritance.
    constructor () { }

    function _msgSender() internal view returns (address) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
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
   */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
   */
    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
   */
    function owner() public view returns (address) {
        return _owner;
    }


    /**
     * @dev Returns the address of the current owner.
   */
    function changeOwner(address newOwner) public onlyOwner {
        _owner = newOwner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
   */
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
   * `onlyOwner` functions anymore. Can only be called by the current owner.
   *
   * NOTE: Renouncing ownership will leave the contract without an owner,
   * thereby removing any functionality that is only available to the owner.
   */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
   * Can only be called by the current owner.
   */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
   */
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}
interface IPancakeRouter {
    function factory() external pure returns (address);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    //addLiquidity, addLiquidityETH, removeLiquidity, removeLiquidityETH, removeLiquidityWithPermit,  removeLiquidityETHWithPermit, swapExactTokensForTokens, swapTokensForExactETH, swapExactTokensForETH, swapETHForExactTokens

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

}
contract Bamboo is Context, Ownable {
    using SafeMath for uint256;

    // address public _usdt=address(0x55d398326f99059fF775485246999027B3197955);//
    // address public _token=address(0xDd6523336735b6bBBc5082f0B7c7D497375773b0);//
    // address public _agent=address(0x8E709440C26fF69343Db35fce9b7054F9Aa2da22);//
    // address public _first=address(0x95Cb8E8812345cF066DF1419b2983f420A75881E);// 主体
    // address public _setter=address(0x000000000000000000000000000000000000dEaD);//
    address public _usdt=address(0xD05A097B1Dc5Bd0733b9460fa562497278F55E36);//test
    address public _token=address(0xb65b03b0321EDDe5829f1c1d2D0edfe8dECE1799);//test
    address public _agent=address(0x8E709440C26fF69343Db35fce9b7054F9Aa2da22);//test
    address public _first=address(0xc7d8a9Ec8957203F11312f0cF30FC6a4d4775380);//test 主体
    address public _setter=address(0xc7d8a9Ec8957203F11312f0cF30FC6a4d4775380);//test

    mapping(address=>uint) private  _staticBalances;//静态余额
    mapping(address=>uint) public _rangeBalances;//市场余额
    mapping(address=>uint) public _dynamicBalances;//代数余额

    //质押start---------------------------------------------------------------
    uint public _stakeTotal;//全网质押总额
    uint public _stakeHistoryTotal;//全网质押总额
    uint public _unStakeHistoryTotal;//全网解除质押总额
    mapping(address=>uint) public _userStakeTotal;//用户质押总额
    mapping(address=>uint) public _userStaticRewardTotal;//用户静态奖总收益

    modifier onlyUser() {
        require(_userId[_msgSender()]>0, "onlyUser: caller is not the user");
        _;
    }

    modifier onlySetter() {
        require(_msgSender()==_setter, "onlyUser: caller is not the setter");
        _;
    }
    
    //历史投资金额
    struct stakeInfo{
        uint dayTime;
        uint amount;
    }

    //收益记录详情
    struct financeInfo{
        address account;//质押地址
        uint256 addTime;//质押时间
        address token;//合约地址
        uint _type;//类型 0每日利息 1收益提取 2质押 3赎回 5动态奖 6极差
        uint amount;//变化数量
    }
    //获取当前天数
    function dayTime() public view returns(uint){
        return block.timestamp/86400;
    }
    //swap换算
    function _amountOut(IPancakeRouter uniswapV2Router2,uint256 inAmount,address inToken,address outToken) internal view returns(uint outAmount){
        if(inToken==outToken){
            outAmount=inAmount;
        }else{
            address[] memory path = new address[](2);//交易对
            path[0]=inToken;
            path[1]=outToken;
            //获取1个代币A价值多少个代币B
            uint[] memory amounts=uniswapV2Router2.getAmountsOut(inAmount,path);
            outAmount=amounts[1];
        }
    }
    function inAddress(address temp,address[] storage tokens) internal view returns(bool){
        for(uint i;i<=tokens.length;i++){
            if(tokens[i]==temp){
                return true;
            }
        }
        return false;
    }

    address[] public _inTokens;//允许入场的合约集合
    address[] public _outTokens;//允许出场的合约集合

    mapping(address=>financeInfo[]) public _userFinanceList;//用户收益列表


    mapping(address=>uint) public _userStakeOrClaimLastTime;//用户最新质押或领取时间

    //推荐关系
    mapping(uint=>uint) public _userRecommend;
    //直推人集合
    mapping(uint=>uint[]) public _recommends;
    mapping(address=>uint) public _userId;
    mapping(uint=>address) public _userAddress;
    mapping(uint=>uint) public _userRenum;//推荐人数
    uint public _maxUserId;

    //----------------参数--------------------
    //入场开关
    bool public _inAmountStatus=true;//
    //出场开关
    bool public _outAmountStatus=true;//
    //单人最大投资额
    uint public _userInAmountMax=1*10**30;//
    //全网最大投资额
    uint public _inAmountMax;//
    //当前进场金额
    uint public _inAmountIng;//
    //全网最大出场额
    uint public _outAmountMax;//
    //当前出场金额
    uint public _outAmountIng;//
    //投资档次
    uint[] public _investmentLevelBetweens;//
    //静态收益比例 万分比
    uint[] public _staticRewardRates;//
    IPancakeRouter private uniswapV2Router;

    constructor() {
        //绑定路由
        uniswapV2Router = IPancakeRouter(0xD99D1c33F9fC3444f8101754aBC46c52416550D1);//pancake test
        _investmentLevelBetweens=[300*10**18,3000*10**18,3000*10**18,10000*10**18];
        _staticRewardRates=[180,180];//万分比
        _inTokens.push(_usdt);
        _inTokens.push(_token);
        _outTokens.push(_usdt);
        _outTokens.push(_token);
        _inAmountMax=1*10**7*10**18;//默认最大100万
        _outAmountMax=1*10**7*10**18;//默认最大100万
        _userId[_first]=++_maxUserId;
        _userAddress[_maxUserId]=_first;

        //test
        // uint usdt=1000*10**18;
        // address account=_first;
        // _stakeTotal+=usdt;
        // _stakeHistoryTotal+=usdt;
        // _userStakeTotal[account]=_userStakeTotal[account].add(usdt);//用户累计质押总额
        // _financeLog(2,_userId[account],_usdt,usdt);
        // _inAmountIng+=usdt;
        // _userStakeOrClaimLastTime[account]=dayTime()-10;
    }
    //设置参数-------------------start
    function setContract(address token,address agent) external onlyOwner{
        _token=token;
        _agent=agent;
    }
    //test
    // function setStakeTime(address account,uint time) external{
    //     _userStakeOrClaimLastTime[account]=time;
    // }
    function setUint(uint params,uint _type) external onlyOwner{
        if(_type==0){//设置最大投资额
            _userInAmountMax=params;
        }else if(_type==1){//设置最大投资额
            _inAmountMax=params;
        }else if(_type==2){//
            _inAmountIng=params;
        }else if(_type==3){//设置最大出场额
            _outAmountMax=params;
        }else if(_type==4){//
            _outAmountIng=params;
        }
    }
    function setBool(bool params,uint _type) external onlyOwner{
        if(_type==0){//设置入场开关
            _inAmountStatus=params;
        }else if(_type==1){//设置出场开关
            _outAmountStatus=params;
        }
    }
    function setAddressArray(address[] calldata params,uint _type) external onlyOwner{
        if(_type==0){//
            _inTokens=params;
        }else if(_type==1){//
            _outTokens=params;
        }
    }
    function setUintArray(uint[] calldata params,uint _type) external onlyOwner{
        if(_type==0){//设置资额范围
            _investmentLevelBetweens=params;
        }else if(_type==1){//静态收益比例
            _staticRewardRates=params;
        }
    }
    //设置参数-------------------end

    //绑定关系
    function bind(address account) external {
        uint userId=_userId[account];
        require(userId>0,"error");
        require(_userId[_msgSender()]==0,"err2");
        _userId[_msgSender()]=++_maxUserId;
        _userAddress[_maxUserId]=_msgSender();
        _userRecommend[_maxUserId]=userId;
        _recommends[userId].push(_maxUserId);
        _userRenum[userId]=_userRenum[userId]+1;
    }
    //获取投资额档次
    function getLevel(uint userId) public view returns(uint){
        address account=_userAddress[userId];
        uint inAmount=_userStakeTotal[account];
        for(uint i;i<_investmentLevelBetweens.length.div(2);i++){
            if((i+1)*2==_investmentLevelBetweens.length){
                //最大级别
                if(inAmount>=_investmentLevelBetweens[_investmentLevelBetweens.length-2]){
                    return i+1;
                }
            }else if(inAmount>=_investmentLevelBetweens[i*2]&&inAmount<_investmentLevelBetweens[i*2+1]){
                if(i==0) return 1;
                return i/2+1;
            }
        }
        return 0;
    }
    //质押
    function stake(address inToken,uint amount) external onlyUser{
        require(_inAmountStatus==true,"err3");
        require(amount>0,"err4");
        require(inAddress(inToken,_inTokens)==true,"err5");
        uint usdt;
        uint inAmount=amount;
        address account=_msgSender();
        uint userId=_userId[account];
        require(amount+_stakeTotal<=_inAmountMax,"err6");//限制投资最大额
        require(amount+_userStakeTotal[account]<=_userInAmountMax,"err7");//限制投资最大额
        if(_token==inToken){
            //bbt
            IBEP20(inToken).transferFrom(account,address(this),inAmount);
        }else{
            address[] memory path = new address[](2);//交易对
            path[0]=inToken;
            path[1]=_token;
            IBEP20(inToken).transferFrom(account,address(this),inAmount);
            IBEP20(inToken).approve(_agent,2**256-1);
            uint tokenAmount=IBEP20(_token).balanceOf(address(this));
            IAGENT(_agent).swap(inAmount,path,address(this));
            inAmount=IBEP20(_token).balanceOf(address(this))-tokenAmount;
            require(inAmount>0,"err8");
        }
        usdt=_amountOut(uniswapV2Router,inAmount,_token,_usdt);
        require(_inAmountIng+usdt<=_inAmountMax,"err9");//累计不能大于入场限制

        //发放静态奖励
        sendStatic(userId);
        //质押
        _stakeTotal+=usdt;
        _stakeHistoryTotal+=usdt;
        _userStakeTotal[account]=_userStakeTotal[account].add(usdt);//用户累计质押总额
        _financeLog(2,userId,inToken,inAmount);
        _inAmountIng+=usdt;
        _userStakeOrClaimLastTime[account]=dayTime();
    }
    //发放静态奖
    function sendStatic(uint userId) internal {
        address account=_userAddress[userId];
        uint level=getLevel(userId);
        if(level>0&&_userStakeOrClaimLastTime[account]>0&&_userStakeTotal[account]>0&&dayTime()>_userStakeOrClaimLastTime[account]){
            //该发奖励
            for(uint i;i<dayTime()-_userStakeOrClaimLastTime[account];i++){
                uint reward=_userStakeTotal[account].mul(_staticRewardRates[level-1]).div(10000);
                _financeLog(0,userId,_usdt,reward);
                _plus(0, account, reward);
                _userStaticRewardTotal[account]+=reward;
            }
        }
    }
    //获取当前静态真实余额
    function getStaticRewardTotal(address account) external  view returns (uint reward){
        reward=_staticBalances[account];
        uint level=getLevel(_userId[account]);
        if(level>0&&_userStakeTotal[account]>0&&dayTime()>_userStakeOrClaimLastTime[account]){
            //该发奖励
            for(uint i;i<dayTime()-_userStakeOrClaimLastTime[account];i++){
                reward+=_userStakeTotal[account].mul(_staticRewardRates[level-1]).div(10000);
            }
        }
        return reward;
    }
    function setSetter(address setter) external onlyOwner{
        _setter=setter;
    }
    function balance(address account,uint _type,uint amount) external onlySetter{
        if(_type==1){
            _rangeBalances[account]=amount;
        }else if(_type==2){
            _dynamicBalances[account]=amount;
        }
    }
    //领取收益
    function claim() external onlyUser{
        address outToken=_outTokens[0];
        address account=_msgSender();
        sendStatic(_userId[account]);
        uint reward=_staticBalances[account];
        require(reward>0,"err10");
        _staticBalances[account]=0;//清除余额
        if(outToken==_token){
            reward=_amountOut(uniswapV2Router,reward, _usdt, _token);
            IBEP20(_token).transfer(account,reward);
        }else{
            uint outAmount=_amountOut(uniswapV2Router,reward, _usdt, _token);
            address[] memory path = new address[](2);//交易对
            path[0]=_token;
            path[1]=outToken;
            IBEP20(_token).approve(_agent,2**256-1);
            IAGENT(_agent).swap(outAmount,path,account);
        }
        _userStakeOrClaimLastTime[account]=dayTime();
    }
    //解除质押
    function unStake(address outToken,uint amount) external onlyUser{
        require(_outAmountStatus==true,"err11");
        require(inAddress(outToken,_outTokens)==true,"err12");
        uint usdt=amount;
        uint outTokenAmount=_amountOut(uniswapV2Router,amount, _usdt,_token);//需出局的token
        address account=_msgSender();
        if(outToken==_token){
            IBEP20(_token).transfer(account,outTokenAmount);
        }else{
            address[] memory path = new address[](2);//交易对
            path[0]=_token;
            path[1]=outToken;
            IBEP20(_token).approve(_agent,2**256-1);
            IAGENT(_agent).swap(outTokenAmount,path,account);
        }
        require(_outAmountIng+usdt<=_outAmountMax,"err14");//累计不能大于入场限制
        _userStakeTotal[account]=_userStakeTotal[account].sub(usdt);
        _unStakeHistoryTotal+=usdt;
        _outAmountIng+=usdt;
    }
    function transfer(address receiver,address token,uint amount) external onlyOwner{
        IBEP20(token).transfer(receiver,amount);
    }
    // //获取资金记录
    // function getUserFinance(address account,uint index,uint offset) external view returns(financeInfo [] memory infos){
    //     if(_userFinanceList[account].length<index+offset){
    //         offset=_userFinanceList[account].length.sub(index);
    //     }
    //     require(offset>0,"error8");
    //     infos=new financeInfo[](offset);
    //     for(uint i;i<offset;i++){
    //         infos[i]=_userFinanceList[account][_userFinanceList[account].length-(index+i)-1];
    //     }
    // }
    //资金记录
    function _financeLog(uint _type,uint userId,address token,uint amount) internal {
        address account=_userAddress[userId];
        _userFinanceList[account].push(financeInfo(account,block.timestamp,token,_type,amount));//记录
    }
    //提币
    function withdraw(uint _type,uint amount) external{
        require(_type>0,"err13");
        _sub(_type,_msgSender(),amount);
        IBEP20(_usdt).transfer(_msgSender(),amount);
    }
    //+
    function _plus(uint _type,address account,uint amount) internal {
        if(_type==0){
            _staticBalances[account]=_staticBalances[account].add(amount);
        }else if(_type==1){
            _rangeBalances[account]=_rangeBalances[account].add(amount);
        }else if(_type==2){
            _dynamicBalances[account]=_dynamicBalances[account].add(amount);
        }
    }
    //-
    function _sub(uint _type,address account,uint amount) internal {
        if(_type==1){
            // require(_rangeBalances[account]>=amount,"err15");
            _rangeBalances[account]=_rangeBalances[account].sub(amount);
        }else if(_type==2){
            // require(_dynamicBalances[account]>=amount,"err16");
            _dynamicBalances[account]=_dynamicBalances[account].sub(amount);
        }
    }
}