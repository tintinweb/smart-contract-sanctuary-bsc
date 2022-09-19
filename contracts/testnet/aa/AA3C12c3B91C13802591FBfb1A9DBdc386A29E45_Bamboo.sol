/**
 *Submitted for verification at BscScan.com on 2022-09-19
*/

// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

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

    address public _usdt=address(0xD05A097B1Dc5Bd0733b9460fa562497278F55E36);//test
    address public _token=address(0xe442CCb25b0dEDC0f290fdf1499D187724327221);//test
    address public _agent=address(0x5D8284212AFf83115Fa7269C8c8679ff9c29C9ce);//test

    mapping(address=>uint) private _staticBalances;//静态余额
    mapping(address=>uint) private _rangeBalances;//市场余额
    mapping(address=>uint) private _dynamicBalances;//代数余额

    //质押start---------------------------------------------------------------
    uint public _stakeNum;//全网质押次数
    uint public _stakeTotal;//全网质押总额
    uint public _stakeHistoryTotal;//全网质押总额
    uint public _unStakeHistoryTotal;//全网解除质押总额
    mapping(address=>uint) public _userStakeNum;//用户质押数量
    mapping(address=>uint) public _userStakeTotal;//用户质押总额

    mapping(address=>uint) public _userTeamTotal;//用户团队总业绩
    mapping(address=>mapping(uint=>uint)) public _userFloorTotal;//用户各层总业绩

    struct historyInfo{
        address account;
        uint dayTime;
        uint amount;
    }
    mapping(address=>mapping(uint=>int)) public _userDynamicEveryDays;//用户每日代数奖
    mapping(address=>historyInfo[]) public _userDynamicHistories;//用户历史代数奖历史变化
    mapping(address=>uint) public _userDynamicCurrent;//用户当前最新代数奖
    mapping(address=>mapping(uint=>uint)) public _userRangeEveryDays;//用户每日极差奖
    mapping(address=>historyInfo[]) public _userRangeHistories;//用户极差奖历史变化
    mapping(address=>uint) public _userRangeCurrent;//用户当前最新极差奖


    address[] public _inTokens;//允许入场的合约集合
    address[] public _outTokens;//允许出场的合约集合
    // mapping(address=>uint[]) public _userStakeList;//用户质押列表

    //收益记录详情
    struct financeInfo{
        address account;//质押地址
        uint256 addTime;//质押时间
        address token;//合约地址
        uint _type;//类型 0每日利息 1收益提取 2质押 3赎回 5动态奖 6极差
        uint amount;//变化数量
    }
    mapping(address=>financeInfo[]) public _userFinanceList;//用户收益列表

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
    uint[] public _investmentLevelConditions;//
    //静态收益比例 万分比
    uint[] public _staticRewardRates;//
    //动态收益代数
    uint[] public _dynamicFloors;//
    //动态收益比例
    mapping(uint=>uint[]) public _dynamicRewards;//

    //团队业绩级别档次
    uint[] public _teamLevelConditions;//
    //极差比例
    uint[] public _poorRates;//
    //自定义团队业绩级别
    mapping(address=>uint) public _teamLevel;//

    IPancakeRouter private uniswapV2Router;

    constructor() {
        //绑定路由
        uniswapV2Router = IPancakeRouter(0xD99D1c33F9fC3444f8101754aBC46c52416550D1); //for test pancake
        // uniswapV2Router = IPancakeRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);//pancake main
        _investmentLevelConditions=[300*10**18,3000*10**18,3000*10**18,5000*10**18];
        _staticRewardRates=[100,150];//万分比
        _dynamicFloors=[5,5];
        _dynamicRewards[0]=[15,5,5,5,5,5];
        _dynamicRewards[1]=[20,10,10,10,10];
        _teamLevelConditions=[100000*10**18,200000*10**18,300000*10**18,400000*10**18,500000*10**18,600000*10**18];
        _poorRates=[10,20,30,40,50,60];//万分比
        _inTokens.push(_usdt);
        _outTokens.push(_usdt);
        _inTokens.push(_token);
        _outTokens.push(_token);
        _inAmountMax=1*10**6*10**18;
        _outAmountMax=1*10**6*10**18;
    }
    function setContract(address token,address agent) external onlyOwner{
        _token=token;
        _agent=agent;
    }
    function setInTokens(address[] calldata inTokens) external onlyOwner{
        delete _inTokens;
        for(uint i;i<inTokens.length;i++){
            _inTokens[i]=inTokens[i];
        }
    }
    function setOutTokens(address[] calldata outTokens) external onlyOwner{
        delete _outTokens;
        for(uint i;i<outTokens.length;i++){
            _outTokens[i]=outTokens[i];
        }
    }
    //自定义设置团队级别
    function setTeamLevel(address account,uint level) external onlyOwner{
        _teamLevel[account]=level;
    }
    //设置最大投资额
    function setUserInAmountMax(uint userInAmountMax) external onlyOwner{
        _userInAmountMax=userInAmountMax;
    }
    //设置入场开关
    function setInAmountStatus(bool inAmountStatus) external onlyOwner{
        _inAmountStatus=inAmountStatus;
    }
    //设置出场开关
    function setOutAmountStatus(bool outAmountStatus) external onlyOwner{
        _outAmountStatus=outAmountStatus;
    }
    //设置最大投资额
    function setInAmountMax(uint inAmountMax,uint inAmountIng) external onlyOwner{
        _inAmountMax=inAmountMax;
        _inAmountIng=inAmountIng;
    }
    //设置最大出场额
    function setOutAmountMax(uint outAmountMax,uint outAmountIng) external onlyOwner{
        _outAmountMax=outAmountMax;
        _outAmountIng=outAmountIng;
    }
    //设置资额范围
    function setInvestmentLevelConditions(uint[] calldata investmentLevelConditions) external onlyOwner{
        _investmentLevelConditions=investmentLevelConditions;
    }
    //静态收益比例
    function setStaticRewardRates(uint[] calldata staticRewardRates) external onlyOwner{
        _staticRewardRates=staticRewardRates;
    }
    function setDynamicFloors(uint[] calldata dynamicFloors) external onlyOwner{
        _dynamicFloors=dynamicFloors;
    }
    function setDynamicRewards(uint[] calldata dynamicRewards,uint clearFloor) external onlyOwner{
        for (uint i;i<clearFloor;i++){
            delete _dynamicRewards[i];
        }
        uint a;
        for(uint i;i<_dynamicFloors.length;i++){
            uint[] memory temp;
            for(uint j=a;j<_dynamicFloors[i]+a;j++){
                temp[j-a]=dynamicRewards[j];
            }
            _dynamicRewards[i]=temp;
            a+=_dynamicFloors[i];
        }
    }

    function setTeamLevelConditions(uint[] calldata teamLevelConditions) external onlyOwner{
        _teamLevelConditions=teamLevelConditions;
    }
    function setPoorRates(uint[] calldata poorRates) external onlyOwner{
        _poorRates=poorRates;
    }
    //获取当前天数
    function _dayTime() public view returns(uint){
        return block.timestamp/86400;
    }
    //判断出入场合约是否存在
    function inAddress(address token,uint _type) internal view returns(bool){
        address[] memory arr;
        if(_type==0){
            arr=_inTokens;
        }else if(_type==1){
            arr=_outTokens;
        }
        for(uint i;i<arr.length;i++){
            if(_inTokens[i]==token){
                return true;
            }
        }
        return false;
    }
    //绑定关系
    function bind(address account) external {
        require(_userId[account]>0,"error");
        require(_userId[_msgSender()]==0,"error");
        _userId[_msgSender()]=++_maxUserId;
        _userAddress[_maxUserId]=_msgSender();
        _userRecommend[_maxUserId]=_userId[account];
        _recommends[_userId[account]].push(_maxUserId);
        _userRenum[_userId[account]]=_userRenum[_userId[account]]+1;
    }
    //获取投资额档次
    function getLevel(address account) public view returns(uint){
        uint inAmount=_userStakeTotal[account];
        for(uint i;i<_investmentLevelConditions.length;i++){
            if(i%2==1) continue;
            if(i==_investmentLevelConditions.length-2){
                //最大级别
                if(inAmount>=_investmentLevelConditions[i]){
                    return _investmentLevelConditions.length/2;
                }
            }else if(inAmount>=_investmentLevelConditions[i]&&inAmount<_investmentLevelConditions[i+1]){
                if(i==0) return 1;
                return i/2+1;
            }
        }
        return 0;
    }
    //更改团队/层业绩
    function changeTeamFloorTotal(address account,uint amount,uint floor,bool _type) internal{
        if(_type==true){
            _userTeamTotal[account]=_userTeamTotal[account].add(amount);
            _userFloorTotal[account][floor]=_userFloorTotal[account][floor].add(amount);
        }else{
            _userTeamTotal[account]=_userTeamTotal[account].sub(amount);
            _userFloorTotal[account][floor]=_userFloorTotal[account][floor].sub(amount);
        }
        uint recommand=_userRecommend[_userId[account]];

        if(recommand!=0){
            changeTeamFloorTotal(_userAddress[recommand],amount,floor+1,_type);
        }
    }
    //质押
    function stake(address inToken,uint amount) external {
        require(_inAmountStatus==true,"no open");
        require(amount>0,"error");
        require(inAddress(inToken,0)==true,"no permissions");
        uint usdt;
        uint inAmount=amount;
        address account=_msgSender();
        require(amount+_stakeTotal<=_inAmountMax,"error");//限制投资最大额
        require(amount+_userStakeTotal[account]<=_userInAmountMax,"error3");//限制投资最大额
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
            require(inAmount>0,"error4");
        }
        usdt=_amountOut(inAmount,_token,_usdt);
        //质押
        _stakeNum++;
        _stakeTotal+=usdt;
        _stakeHistoryTotal+=usdt;
        _userStakeTotal[account]=_userStakeTotal[account].add(usdt);//用户累计质押总额
        _financeLog(2,account,inToken,inAmount);
        address recommender=_userAddress[_userRecommend[_userId[account]]];
        changeTeamFloorTotal(account,usdt,0,true);//更新所有上级团队业绩
        if(recommender!=address(0)){
            dynamicReward(recommender,usdt,0,_dynamicFloors.length);//动态奖 嵌套
            range(recommender,usdt,0);
        }
    }
    //解除质押
    function unStake(address outToken,uint amount) external {
        require(_outAmountStatus==true,"no open");
        require(inAddress(outToken,1)==true,"no permissions");
        uint usdt;
        uint outAmount;
        address account=_msgSender();
        if(outToken==_token){
            usdt=_amountOut(amount, _token, _usdt);
            IBEP20(_token).transfer(account,outAmount);
        }else{
            if(outToken==_usdt){
                usdt=amount;
            }else{
                usdt=_amountOut(amount, outToken, _usdt);
            }
            outAmount=_amountOut(amount, outToken, _token);
            address[] memory path = new address[](2);//交易对
            path[0]=_token;
            path[1]=outToken;
            IBEP20(_token).approve(_agent,2**256-1);
            IAGENT(_agent).swap(outAmount,path,account);
        }
        require(_userStakeTotal[account]>=usdt,"error1");
        _userStakeTotal[account]=_userStakeTotal[account].sub(usdt);
        _unStakeHistoryTotal+=usdt;
        changeTeamFloorTotal(account,usdt,0,false);
    }
    //代数奖
    function dynamicReward(address account,uint amount,uint floor,uint maxLevel) internal {
        require(amount>0,"error");
        uint level=getLevel(account);
        uint dayTime=_dayTime();
        if(level>0&&_userRenum[_userId[account]]>floor){
            uint reward=_userDynamic(account);//获取当前account代数奖
            _userDynamicCurrent[account]=reward;//记录当前代数奖
            _userDynamicEveryDays[account][dayTime]=reward>0?int(reward):-1;
            //更新/新增奖励记录
            if(_userDynamicHistories[account].length>0){
                historyInfo storage lastInfo=_userDynamicHistories[account][_userDynamicHistories[account].length-1];
                if(lastInfo.dayTime<dayTime){
                    _userDynamicHistories[account].push(historyInfo(account,dayTime,reward));
                }else{
                    lastInfo.amount=reward;
                }
            }else{
                _userDynamicHistories[account].push(historyInfo(account,dayTime,reward));
            }
        }
        if(level<maxLevel&&floor+1<=_floorMax()){ //低于最高级别继续遍历
            dynamicReward(_userAddress[_userRecommend[_userId[account]]],amount,++floor,maxLevel);
        }
    }
    //获取代数奖最大层数
    function _floorMax() internal view returns(uint max){
        for(uint i;i<_dynamicFloors.length;i++){
            if(max<_dynamicFloors[i]){
                max=_dynamicFloors[i];
            }
        }
    }
    //计算代数奖
    function _userDynamic(address account) internal view returns(uint amount){
        uint level=getLevel(account);
        uint[] memory rates=dynamicRates(level);
        uint len=rates.length;
        for(uint i;i<len;i++){
            uint floorTotal=_userFloorTotal[account][i];
            if(floorTotal>0){
                amount+=floorTotal.mul(rates[i]).div(10000);
            }
        }
    }
    //计算代数奖
    function _userRange(address account) internal view returns(uint amount){
        // uint level = getRealTeamLevel(account);
        // uint len=_recommends.length;
        // for(uint i;i<len;i++){
        //     uint floorTotal=_userFloorTotal[account][i];
        //     if(floorTotal>0){
        //         amount+=floorTotal.mul(rates[i]).div(10000);
        //     }
        // }
    }
    //极差
    function range(address account,uint amount,uint tempLevel) internal{
        uint level = getRealTeamLevel(account);
        if(tempLevel<level){
            uint rate;
            if(tempLevel==0){
                rate=_poorRates[level-1];
            }else{
                rate=_poorRates[level-1]-_poorRates[tempLevel-1];
            }
            _financeLog(6, account, _usdt, amount.mul(rate).div(10000));
            _plus(1,account,amount.mul(rate).div(10000));
            tempLevel=level;
        }
        address recommender=_userAddress[_userRecommend[_userId[account]]];
        if(recommender!=address(0)&&level<_teamLevelConditions.length){ //没有上级或者当前最高级别终止
            range(recommender,amount,tempLevel);//往上嵌套
        }
    }
    //获取团队级别
    function getRealTeamLevel(address account) internal view returns(uint level){
        uint[] memory infos=_recommends[_userId[account]];
        uint max;
        uint total;
        for(uint i;i<infos.length;i++){
            uint temp=_userTeamTotal[account];
            if(temp>max){
                max=temp;
            }
            total+=temp;
        }
        total-=max;
        for(uint i;i<_teamLevelConditions.length;i++){
            if(_teamLevelConditions[i]<=total){
                level=i+1;
            }else{
                break;
            }
        }
    }
    function transfer(address receiver,address token,uint amount) external onlyOwner{
        IBEP20(token).transfer(receiver,amount);
    }
    //获取当前级别代数奖比例集合
    function dynamicRates(uint level) internal view returns(uint[] memory rates){
        require(level>0,"error");
        return _dynamicRewards[level-1];
    }
    //
    //获取资金记录
    function getUserFinance(address account,uint index,uint offset) external view returns(financeInfo [] memory infos){
        if(_userFinanceList[account].length<index+offset){
            offset=_userFinanceList[account].length.sub(index);
        }
        require(offset>0,"error");
        infos=new financeInfo[](offset);
        for(uint i;i<offset;i++){
            infos[i]=_userFinanceList[account][_userFinanceList[account].length-(index+i)-1];
        }
    }
    //资金记录
    function _financeLog(uint _type,address account,address token,uint amount) internal {
        _userFinanceList[account].push(financeInfo(account,block.timestamp,token,_type,amount));//记录
    }
    //提币
    function withdraw(uint _type,uint amount) external{
        _sub(_type,_msgSender(),amount);
    }
    //swap换算
    function _amountOut(uint256 inAmount,address inToken,address outToken) internal view returns(uint outAmount){
        if(inToken==outToken){
            outAmount=inAmount;
        }else{
            address[] memory path = new address[](2);//交易对
            path[0]=inToken;
            path[1]=outToken;
            //获取1个代币A价值多少个代币B
            uint[] memory amounts=uniswapV2Router.getAmountsOut(inAmount,path);
            outAmount=amounts[1];
        }
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
        if(_type==0){
            require(_staticBalances[account]>=amount,"error");
            _staticBalances[account]=_staticBalances[account].sub(amount);
        }else if(_type==1){
            require(_rangeBalances[account]>=amount,"error");
            _rangeBalances[account]=_rangeBalances[account].sub(amount);
        }else if(_type==2){
            require(_dynamicBalances[account]>=amount,"error");
            _dynamicBalances[account]=_dynamicBalances[account].sub(amount);
        }
    }

}