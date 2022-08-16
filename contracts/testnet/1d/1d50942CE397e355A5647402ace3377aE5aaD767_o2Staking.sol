/**
 *Submitted for verification at BscScan.com on 2022-08-16
*/

// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

interface IBEP20 {

    function mint(address account,uint256 amount) external;
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
    constructor () {}

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

interface IPancakePair{
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
}

contract o2Staking is Context, Ownable {
    using SafeMath for uint256;

    IPancakeRouter private uniswapV2Router;

    modifier serperOwner() {
        require(owner() == _msgSender() || _o2 == _msgSender(), "O2: caller is not the super owner");
        _;
    }

    //质押start---------------------------------------------------------------

    //质押详情
    struct stakeInfo{
        bool status;//质押状态
        address account;//质押地址
        uint256 stakeTime;//质押时间
        uint256 claimTime;//领取收益时间
        uint256 stakeEndTime;//质押结束时间
        uint256 unStakeTime;//质押解除时间
        uint256 rate;//利率 百分比
        uint256 stakeTotal;//质押数量
        address stakeToken;//质押对应代币合约
        uint256 stakeTokenTotal;//质押对应代币数量
        uint256 stakeInterestTotal;//累计利息收益
        uint256 stakeBreachAmount;//违约金
        uint256 waitReceiveAmount;//待领取代币
    }
    //质押列表
    mapping(uint256 => stakeInfo) public _stakeInfos;
    //获取用户质押列表
    mapping(address => uint256[]) public _userStakeList;
    //累计质押总比数
    uint256 public _stakeTimes;

    //该用户质押总额
    mapping(address => uint256) public _userStakeTotal;
    //用户累计收益
    mapping(address => uint256) public _userInterestTotal;
    //质押用户列表(索引)
    mapping(uint256 => address) public _users;
    //质押用户列表
    mapping(address => uint256) public _userIds;
    //质押用户总数
    uint256 public _userNum;
    //接币地址
    // address public _main=address(0x5d510632e322A864CA42abE9fe52Aea73E930928);
    address public _main=address(0x6AeED229BF1f8674ee70530e112D59095A8B6a6D);

    //全网总质押
    uint256 public _stakingTotal=0;
    //全网累计收益
    uint256 public _interestTotal;
    //违约金比例
    uint256 public _breachRatio=35;
    //质押手续费比例
    uint256 public _stakeCharge=5;
    // address public _recipientRblAddress=address(0x96E41424a1f180435e3FABF627Fed5D47336c961);//main
    //每日购买限量
    uint256 public _maxBuyAmountEveryDay=10**6*10**18;
    //每日购买数量
    mapping(uint=>uint) public _buyAmountEveryDay;
    //违约开关
    bool public _breachOpen=true;

    address public _usdt=address(0xD05A097B1Dc5Bd0733b9460fa562497278F55E36);//test usdt
    address public _o2=address(0x75ed02F8a5E9d80E804266De07D4287fF69b8e28);//test o2
    address public _rbl=address(0xD05A097B1Dc5Bd0733b9460fa562497278F55E36);//test 母币
    address public _recipientRblAddress=address(0xE7d05302De8EDAc0D15869D92dc9aFFE2044a999);//test 接母币地址
    // address public _usdt=address(0x55d398326f99059fF775485246999027B3197955);//main
    // address public _o2=address(0xD05A097B1Dc5Bd0733b9460fa562497278F55E36);//main o2合约
    // address public _rbl=address(0xD05A097B1Dc5Bd0733b9460fa562497278F55E36);//main rbl合约
    // address public _recipientRblAddress=address(0x96E41424a1f180435e3FABF627Fed5D47336c961);//main 接母币地址

    //利率详情
    struct interestInfo{
        bool status;//利率状态
        uint256 stakeTime;//质押时间(秒)
        uint256 rate;//质押利率
    }
    //领取收益详情
    struct claimInfo{
        uint256 amount;//领取数量
        uint256 claimTime;//领取时间
    }
    mapping(address=>claimInfo[]) public _userClaimInfos;//用户收益列表
    //利率列表
    interestInfo[] public _interestInfos;

    constructor() {
        //绑定路由
        uniswapV2Router = IPancakeRouter(0xD99D1c33F9fC3444f8101754aBC46c52416550D1); //for test pancake
        // uniswapV2Router = IPancakeRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);//pancake main

        //质押利率
        _interestInfos.push(interestInfo(true,1*24*3600,2));
        _interestInfos.push(interestInfo(true,7*24*3600,21));
        _interestInfos.push(interestInfo(true,15*24*3600,60));

        //测试
        // address account=address(0x5B38Da6a701c568545dCfcB03FcB875f56beddC4);
        // uint amount=10**20;
        // interestInfo memory _info=_interestInfos[0];
        // _stakeInfos[++_stakeTimes]=stakeInfo(true,account,block.timestamp,block.timestamp,block.timestamp+_info.stakeTime,0,_info.rate,amount,_o2,amount,0,0,0);//设置质押详情
        // _userStakeList[account].push(_stakeTimes);

        // _stakingTotal+=amount;
        // _userStakeTotal[account]+=amount;
        // if(_userIds[_msgSender()]==0){
        //     _users[++_userNum]=account;
        //     _userIds[account]=_userNum;
        // }
        // _buyAmountEveryDay[block.timestamp/(24*60*60)]+=amount;
    }

    //初始化参数
    function _init_params(uint breachRatio,uint stakeCharge,uint maxBuyAmountEveryDay,bool breachOpen) external onlyOwner{
        _breachRatio=breachRatio;//违约金比例
        _stakeCharge=stakeCharge;//质押手续费比例
        _maxBuyAmountEveryDay=maxBuyAmountEveryDay;//每日认购限额
        _breachOpen=breachOpen;//质押违约开关
    }

    //设置合约参数
    function setContracts(address usdt,address o2,address rbl,address recipientRblAddress) external onlyOwner{
        _usdt=usdt;
        _o2=o2;
        _rbl=rbl;
        _recipientRblAddress=recipientRblAddress;
    }

    function withdrawUsdt(uint amount) external serperOwner{
        IBEP20(_usdt).transfer(_msgSender(),amount);
    }

    //初始化质押收益参数
    function setInterestInfos(uint256[] memory params) public onlyOwner{
        if(_interestInfos.length>0){
            delete _interestInfos;
        }
        for(uint i;i<params.length;i++){
            if(i%2==0){
                _interestInfos.push(interestInfo(true,params[i],params[i+1]));
            }
        }
    }
    //赎回所有质押并待领取
    function unStakeAll() external onlyOwner{
        require(_stakeTimes>0);
        for(uint i=1;i<=_stakeTimes;i++){
            stakeInfo storage info=_stakeInfos[i];
            if(info.status==false) continue;
            uint amount=_amountOut(info.stakeTotal,_usdt,_o2);//转换为o2
            uint interestAmount=getInterestAmount(i,false);
            if(interestAmount>0){
                amount=amount.add(interestAmount);
                _userInterestTotal[_msgSender()]+=interestAmount;
                _interestTotal+=interestAmount;
                info.stakeInterestTotal+=interestAmount;
                _userClaimInfos[_msgSender()].push(claimInfo(interestAmount,block.timestamp));
            }
            info.status=false;
            info.unStakeTime=block.timestamp;
            info.waitReceiveAmount=amount;//设置待领取代币
            _stakingTotal-=amount;
            _userStakeTotal[_msgSender()]-=amount;
        }
    }
    //获取线性利息
    function getInterestAmount(uint stakeId,bool _type) public view returns (uint){
        stakeInfo memory _info=_stakeInfos[stakeId];
        if(_info.status==false) return 0;//已解除质押
        if(_type==true){
            //显示u
            if(block.timestamp>=_info.stakeEndTime){
                //计算剩余
                return _info.stakeTotal.mul(_info.rate).div(100)-_info.stakeInterestTotal;
            }
            return _info.stakeTotal.mul(_info.rate).div(100)*(block.timestamp-_info.claimTime)/((_info.stakeEndTime-_info.claimTime));
        }else{
            if(block.timestamp>=_info.stakeEndTime){
                //计算剩余
                return _amountOut(_info.stakeTotal.mul(_info.rate).div(100),_usdt,_o2)-_info.stakeInterestTotal;
            }
            return _amountOut(_info.stakeTotal.mul(_info.rate).div(100),_usdt,_o2)*(block.timestamp-_info.claimTime)/((_info.stakeEndTime-_info.claimTime));
        }
    }
    //获取用户可提现的线性利息
    function getUserInterestAmount(address account,bool _type) public view returns (uint amount){
        if(_userStakeList[account].length<=0) return 0;
        for(uint i;i<_userStakeList[account].length;i++){
            amount+=getInterestAmount(_userStakeList[account][i],_type);
        }
    }
    //获取质押列表以及详情
    function getStakes(address account,uint256 index,uint256 offset) external view returns(stakeInfo [] memory infos){
        if(_userStakeList[account].length<index+offset){
            offset=_userStakeList[account].length-index;
        }
        infos=new stakeInfo[](offset);
        for(uint i;i<offset;i++){
            stakeInfo memory info=_stakeInfos[_userStakeList[account][index+i]];
            infos[i]=info;
        }
    }
    //获取收益列表以及详情
    function getClaims(address account,uint256 index,uint256 offset) external view returns(claimInfo [] memory infos){
        if(_userClaimInfos[account].length<index+offset){
            offset=_userClaimInfos[account].length-index;
        }
        infos=new claimInfo[](offset);
        for(uint i;i<offset;i++){
            infos[i]=_userClaimInfos[account][index+i];
        }
    }
    //获取用户质押数量
    function userStakeNum(address account) external view returns (uint256){
        return _userStakeList[account].length;
    }
    //swap换算
    function _amountOut(uint256 inAmount,address inToken,address outToken) public view returns(uint outAmount){
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
    //质押
    function stake(uint256 amount,address _token,uint256 interestId) public{
        //amount为usdt
        require(amount>0,"error1");
        require(_buyAmountEveryDay[block.timestamp/(24*60*60)]+amount<=_maxBuyAmountEveryDay,"error2");

        if(_stakeCharge>0){
            //扣rbl手续费
            IBEP20(_rbl).transferFrom(_msgSender(),_recipientRblAddress,_amountOut(amount.mul(_stakeCharge).div(100),_usdt,_rbl));
        }
        uint inAmount=_amountOut(amount,_usdt,_token);
        IBEP20(_token).transferFrom(_msgSender(),address(this),inAmount);
        interestInfo memory _info=_interestInfos[interestId];

        //写入质押列表
        _stakeInfos[++_stakeTimes]=stakeInfo(true,_msgSender(),block.timestamp,block.timestamp,block.timestamp+_info.stakeTime,0,_info.rate,amount,_token,inAmount,0,0,0);//设置质押详情
        _userStakeList[_msgSender()].push(_stakeTimes);

        _stakingTotal+=amount;
        _userStakeTotal[_msgSender()]+=amount;
        if(_userIds[_msgSender()]==0){
            _users[++_userNum]=_msgSender();
            _userIds[_msgSender()]=_userNum;
        }
        _buyAmountEveryDay[block.timestamp/(24*60*60)]+=amount;
    }
    //取出
    function unStake(uint256 stakeId) external{
        stakeInfo storage info=_stakeInfos[stakeId];
        require(info.account==_msgSender(),"error");
        if(info.status==false&&info.waitReceiveAmount>0){
            //提币给用户
            _contractTransfer(_msgSender(),info.waitReceiveAmount);
            info.waitReceiveAmount=0;
        }else{
            require(info.status==true,"error2");
            uint amount = info.stakeTotal;
            if(_breachOpen==true&&block.timestamp<info.stakeEndTime&&_breachRatio>0){
                //扣除违约金
                info.stakeBreachAmount=amount.mul(_breachRatio).div(100);
                amount=amount.mul(100-_breachRatio).div(100);
            }
            amount=_amountOut(amount,_usdt,_o2);
            uint interestAmount=getInterestAmount(stakeId,false);
            if(interestAmount>0){
                amount+=interestAmount;
                _userInterestTotal[_msgSender()]+=interestAmount;
                _interestTotal+=interestAmount;
                info.stakeInterestTotal+=interestAmount;
                _userClaimInfos[_msgSender()].push(claimInfo(interestAmount,block.timestamp));
            }
            info.status=false;
            info.claimTime=block.timestamp;
            info.unStakeTime=block.timestamp;
            _stakingTotal-=amount;
            _userStakeTotal[_msgSender()]-=amount;
            //提币给用户
            _contractTransfer(_msgSender(),amount);
        }
    }
    //提取利息
    function claim(uint256 stakeId) external{
        stakeInfo storage info=_stakeInfos[stakeId];
        require(info.account==_msgSender(),"error");
        require(info.status==true,"error2");
        uint interestAmount=getInterestAmount(stakeId,false);
        require(interestAmount>0,"error3");
        info.claimTime=block.timestamp;
        info.stakeInterestTotal+=interestAmount;//添加到当前累计收益
        _userClaimInfos[_msgSender()].push(claimInfo(interestAmount,block.timestamp));
        _interestTotal+=interestAmount;//添加到质押总利息
        //提利息给用户
        _contractTransfer(_msgSender(),interestAmount);
    }
    //提币给用户
    function _contractTransfer(address recipient, uint256 amount) internal{
        uint surplus=IBEP20(_o2).balanceOf(address(this));
        if(surplus<amount){
            //币不够
            IBEP20(_o2).mint(address(this),amount-surplus);
        }
        IBEP20(_o2).transfer(recipient, amount);
    }

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity){
        (amountA,amountB,liquidity) = uniswapV2Router.addLiquidity(tokenA,tokenB,amountADesired,amountBDesired,amountAMin,amountBMin,to,deadline);
    }

    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity){
        (amountToken, amountETH, liquidity) = uniswapV2Router.addLiquidityETH(token,amountTokenDesired,amountTokenMin,amountETHMin,to,deadline);
    }

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB){
        (amountA, amountB)=uniswapV2Router.removeLiquidity(tokenA,tokenB,liquidity,amountAMin,amountBMin,to,deadline);
    }

    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH){
        (amountToken, amountETH)=uniswapV2Router.removeLiquidityETH(token,liquidity,amountTokenMin,amountETHMin,to,deadline);
    }

    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB){
        (amountA, amountB)=uniswapV2Router.removeLiquidityWithPermit(tokenA,tokenB,liquidity,amountAMin,amountBMin,to,deadline,approveMax,v,r,s);
    }

    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH){
        (amountToken, amountETH)=uniswapV2Router.removeLiquidityETHWithPermit(token,liquidity,amountTokenMin,amountETHMin,to,deadline,approveMax,v,r,s);
    }

    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts){
        (amounts)=uniswapV2Router.swapExactTokensForTokens(amountIn,amountOutMin,path,to,deadline);
    }

    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts){
        (amounts)=uniswapV2Router.swapTokensForExactTokens(amountOut,amountInMax,path,to,deadline);
    }

    function swapExactETHForTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable returns (uint[] memory amounts){
        (amounts)=uniswapV2Router.swapExactETHForTokens(amountOutMin,path,to,deadline);
    }

    function swapTokensForExactETH(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts){
        (amounts)=uniswapV2Router.swapTokensForExactETH(amountOut,amountInMax,path,to,deadline);
    }

    function swapExactTokensForETH(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts){
        (amounts)=uniswapV2Router.swapExactTokensForETH(amountIn,amountOutMin,path,to,deadline);
    }

    function swapETHForExactTokens(
        uint amountOut,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable returns (uint[] memory amounts){
        (amounts)=uniswapV2Router.swapETHForExactTokens(amountOut,path,to,deadline);
    }

}