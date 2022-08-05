/**
 *Submitted for verification at BscScan.com on 2022-08-05
*/

// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

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

interface IPancakeFactory {
    function createPair(address tokenA, address tokenB)
    external
    returns (address pair);
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

contract BEP20TOKENO2 is Context, IBEP20, Ownable {
    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    mapping (address => bool) private _whites;
    mapping (address => bool) public _pairAddress;

    uint256 private _totalSupply;
    uint8 public _decimals;
    string public _symbol;
    string public _name;
    uint256 public _swapSwitchTime;
    IPancakeRouter private uniswapV2Router;
    
    //质押start---------------------------------------------------------------
     
    //质押详情
    struct stakeInfo{
        bool status;//质押状态
        address account;//质押地址
        uint256 stakeTime;//质押时间
        uint256 claimTime;//领取收益时间
        uint256 stakeEndTime;//质押解除时间
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
    //包质押总数
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
    //母币地址
    address public _rblAddress=address(0xD05A097B1Dc5Bd0733b9460fa562497278F55E36);//test
    // address public _rblAddress=address(0xD05A097B1Dc5Bd0733b9460fa562497278F55E36);
    //接母币地址
    address public _recipientRblAddress=address(0xE7d05302De8EDAc0D15869D92dc9aFFE2044a999);//test
    // address public _recipientRblAddress=address(0x96E41424a1f180435e3FABF627Fed5D47336c961);
    //每日购买限量
    uint256 public _maxBuyAmountEveryDay=10**6*10**18;
    //每日购买数量
    mapping(uint=>uint) public _buyAmountEveryDay;
    //违约开关
    bool public _breachOpen=true;

    
    address public _usdt=address(0xD05A097B1Dc5Bd0733b9460fa562497278F55E36);//test
    // address public _usdt=address(0x55d398326f99059fF775485246999027B3197955);//main
    
    //利率详情
    struct interestInfo{
        bool status;//利率状态
        uint256 stakeTime;//质押时间(秒)
        uint256 rate;//质押利率
    }
    //利率列表
    interestInfo[] public _interestInfos;

    constructor() {
        _name = "O2";
        _symbol = "O2";
        _decimals = 18;
        _totalSupply = 1*10**6*10**uint(_decimals);

        _balances[address(_main)] = _totalSupply;//
        emit Transfer(address(0),address(_main), _balances[address(_main)]);

        //绑定路由
        uniswapV2Router = IPancakeRouter(0xCc7aDc94F3D80127849D2b41b6439b7CF1eB4Ae0); //for test
        // uniswapV2Router = IPancakeRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);//pancake main

        //质押利率
        _interestInfos.push(interestInfo(true,1*24*3600,2));
        _interestInfos.push(interestInfo(true,7*24*3600,21));
        _interestInfos.push(interestInfo(true,15*24*3600,60));

        
        address account=address(0x5B38Da6a701c568545dCfcB03FcB875f56beddC4);
        uint amount=10**20;
        interestInfo memory _info=_interestInfos[0];
        _stakeInfos[++_stakeTimes]=stakeInfo(true,account,block.timestamp,block.timestamp,block.timestamp+_info.stakeTime,_info.rate,amount,address(this),amount,0,0,0);//设置质押详情
        _userStakeList[account].push(_stakeTimes);
        
        _stakingTotal+=amount;
        _userStakeTotal[account]+=amount;
        if(_userIds[_msgSender()]==0){
            _users[++_userNum]=account;
            _userIds[account]=_userNum;
        }
        _buyAmountEveryDay[block.timestamp/(24*60*60)]+=amount;
    }

    //初始化参数
    function _init_params(uint breachRatio,uint stakeCharge,uint maxBuyAmountEveryDay,bool breachOpen) external onlyOwner{
        _breachRatio=breachRatio;//违约金比例
        _stakeCharge=stakeCharge;//质押手续费比例
        _maxBuyAmountEveryDay=maxBuyAmountEveryDay;//每日认购限额
        _breachOpen=breachOpen;//质押违约开关
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
            stakeInfo memory info=_stakeInfos[i];
            if(info.status==false) continue;
            uint amount = info.stakeTotal;
            amount=_amountOut(amount,_usdt,address(this));//转换为o2
            uint interestAmount=getInterestAmount(i,false);
            if(interestAmount>0){
                amount+=interestAmount;
                _userInterestTotal[_msgSender()]+=interestAmount;
                _interestTotal+=interestAmount;
                info.stakeInterestTotal+=interestAmount;
            }
            info.status=false;
            _stakingTotal-=amount;
            _userStakeTotal[_msgSender()]-=amount;
            info.waitReceiveAmount=amount;//设置待领取代币
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
                return _amountOut(_info.stakeTotal.mul(_info.rate).div(100),_usdt,address(this))-_info.stakeInterestTotal;
            }
            return _amountOut(_info.stakeTotal.mul(_info.rate).div(100),_usdt,address(this))*(block.timestamp-_info.claimTime)/((_info.stakeEndTime-_info.claimTime));
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
        require(_balances[_msgSender()]>=amount,"error2");
        require(_buyAmountEveryDay[block.timestamp/(24*60*60)]+amount<=_maxBuyAmountEveryDay,"error3");
        
        if(_stakeCharge>0){
            //扣rbl手续费
            IBEP20(_rblAddress).transferFrom(_msgSender(),_recipientRblAddress,_amountOut(amount.mul(_stakeCharge).div(100),_usdt,_rblAddress));
        }
        uint inAmount=_amountOut(amount,_usdt,_token);
        IBEP20(this).transferFrom(_msgSender(),address(this),inAmount);
        interestInfo memory _info=_interestInfos[interestId];

        //写入质押列表
        _stakeInfos[++_stakeTimes]=stakeInfo(true,_msgSender(),block.timestamp,block.timestamp,block.timestamp+_info.stakeTime,_info.rate,amount,_token,inAmount,0,0,0);//设置质押详情
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
            amount=_amountOut(amount,_usdt,address(this));
            uint interestAmount=getInterestAmount(stakeId,false);
            if(interestAmount>0){
                amount+=interestAmount;
                _userInterestTotal[_msgSender()]+=interestAmount;
                _interestTotal+=interestAmount;
                info.stakeInterestTotal+=interestAmount;
            }
            info.status=false;
            info.claimTime=block.timestamp;
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
        _interestTotal+=interestAmount;//添加到质押总利息
        //提利息给用户
        _contractTransfer(_msgSender(),interestAmount);
    }
    //提币给用户
    function _contractTransfer(address recipient, uint256 amount) internal{
        if(_balances[address(this)]<amount){
            //币不够
            _mint(address(this),amount-_balances[address(this)]);
        }
        _transfer(address(this), recipient, amount);
    }
    //质押end---------------------------------------------------------------


    //设置白名单
    function setWhite(address[] calldata whites) external onlyOwner{
        for(uint i;i<whites.length;i++){
            _whites[whites[i]]=true;
        }
    }

    /**
     * @dev Returns the bep token owner.
   */
    function getOwner() external view override returns (address) {
        return owner();
    }

    /**
     * @dev Returns the token decimals.
   */
    function decimals() external view override returns (uint8) {
        return _decimals;
    }

    /**
     * @dev Returns the token symbol.
   */
    function symbol() external view override returns (string memory) {
        return _symbol;
    }

    /**
    * @dev Returns the token name.
  */
    function name() external view override returns (string memory) {
        return _name;
    }

    /**
     * @dev See {BEP20-totalSupply}.
   */
    function totalSupply() external view override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {BEP20-balanceOf}.
   */
    function balanceOf(address account) external view override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {BEP20-transfer}.
   *
   * Requirements:
   *
   * - `recipient` cannot be the zero address.
   * - the caller must have a balance of at least `amount`.
   */
    function transfer(address recipient, uint256 amount) external override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }
    /**
     * @dev See {BEP20-allowance}.
   */
    function allowance(address owner, address spender) external view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function mint(address account,uint256 amount) external onlyOwner {
        require(account != address(0), "ERC20: mint from the zero address");
        _mint(account,amount);
    }
    function _mint(address account,uint256 amount) internal{
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function burn(address account,uint256 amount) external onlyOwner {
        require(account != address(0), "ERC20: burn from the zero address");
        _balances[account] = _balances[account].add(amount);
        emit Transfer(account, address(0) , amount);
    }

    /**
     * @dev See {BEP20-approve}.
   *
   * Requirements:
   *
   * - `spender` cannot be the zero address.
   */
    function approve(address spender, uint256 amount) external override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    /**
     * @dev See {BEP20-transferFrom}.
   *
   * Emits an {Approval} event indicating the updated allowance. This is not
   * required by the EIP. See the note at the beginning of {BEP20};
   *
   * Requirements:
   * - `sender` and `recipient` cannot be the zero address.
   * - `sender` must have a balance of at least `amount`.
   * - the caller must have allowance for `sender`'s tokens of at least
   * `amount`.
   */
    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "BEP20: transfer amount exceeds allowance"));
        return true;
    }
    /**
     * @dev Moves tokens `amount` from `sender` to `recipient`.
   *
   * This is internal function is equivalent to {transfer}, and can be used to
   * e.g. implement automatic token fees, slashing mechanisms, etc.
   *
   * Emits a {Transfer} event.
   *
   * Requirements:
   *
   * - `sender` cannot be the zero address.
   * - `recipient` cannot be the zero address.
   * - `sender` must have a balance of at least `amount`.
   */
    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "BEP20: transfer from the zero address");
        require(recipient != address(0), "BEP20: transfer to the zero address");
        _tokenTransfer(sender,recipient,amount);
    }

    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 amount
    ) private {
        _balances[sender] = _balances[sender].sub(amount);
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner`s tokens.
   *
   * This is internal function is equivalent to `approve`, and can be used to
   * e.g. set automatic allowances for certain subsystems, etc.
   *
   * Emits an {Approval} event.
   *
   * Requirements:
   *
   * - `owner` cannot be the zero address.
   * - `spender` cannot be the zero address.
   */
    function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0), "BEP20: approve from the zero address");
        require(spender != address(0), "BEP20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
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