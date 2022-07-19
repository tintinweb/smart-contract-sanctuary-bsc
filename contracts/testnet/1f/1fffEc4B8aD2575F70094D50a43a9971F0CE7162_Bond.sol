// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./bankCommon.sol";
import "./uniswapCommon.sol";
interface IBEP20Treasury{
    function addLiquidityByPay(uint256 payAmount) external;
}
//Bond
contract Bond is BankCommon,UniswapCommon{
    //Bond详情
    struct bondInfo{
        uint256 bondTime;//bond时间
        uint256 bondTotal;//bond数量
        uint256 bondPrice;//bond花费(usdt)
    }
    using SafeMath for uint256;
    uint256 public _buyMin=1*10**18;//购买最小值
    uint256 public _buyMax=10000*10**18;//购买最大值
    uint16 public _discount=10000;//折扣10000为原价 考虑到可能不止精确到百分位
    uint8[4] _distribution=[50,10,10,30];//入金分配 国库、金库、vc、资金池
    mapping(address=>bondInfo []) _orders; //订单列表

    //
    constructor () {
        _orders[0x5B38Da6a701c568545dCfcB03FcB875f56beddC4].push(bondInfo(block.timestamp,1000000000000000000000,100000000000000000000));
    }
    //获取订单列表以及详情
    function getOrders(address account,uint256 index,uint256 offset) external view returns(bondInfo [] memory infos){
        if(_orders[account].length<index+offset){
            offset=_orders[account].length-index;
        }
        infos=new bondInfo[](offset);
        for(uint i;i<offset;i++){
            bondInfo memory info=_orders[account][index+i];
            infos[i]=info;
        }
    }
    //获取用户订单数量
    function getUsrOrderNum(address account) external view returns(uint256){
        return _orders[account].length;
    }

    //设置初始参数
    function _init_params(uint256 buyMin,uint256 buyMax, uint16 discount,uint8[4] calldata distribution) external onlyOwner{
        _buyMin=buyMin;
        _buyMax=buyMax;
        require(discount>0&&discount<=100);
        _discount=discount;
        require(distribution[0]+distribution[1]+distribution[2]+distribution[3]<=100);
        _distribution=distribution;
    }
    //获取当前折扣价格
    function getPrice(uint256 amount) public view returns(uint256 transferAmount){
        require(amount>0);
        require(_buyMin>0&&_buyMin<=amount);
        require(_buyMax>0&&_buyMax>=amount);

        address[] memory path = new address[](2);//交易对
        address _dol=Super(_super)._contract("dol");
        address _pay=Super(_super)._contract("pay");
        path[0]=_dol;
        path[1]=_pay;
        //获取需要付u的数量
        uint[] memory amounts=uniswapV2Router.getAmountsOut(amount,path);
        transferAmount = amounts[1].mul(_discount).div(10000);
    }
    //通过bond购买dol
    function bondToken(uint256 amount) external {
        require(amount>0);
        require(_buyMin>0&&_buyMin<=amount);
        require(_buyMax>0&&_buyMax>=amount);

        uint256 transferAmount = getPrice(amount);
        address _dol=Super(_super)._contract("dol");
        address _pay=Super(_super)._contract("pay");
        address _treasury=Super(_super)._contract("treasury");
        address _vault=Super(_super)._contract("vault");
        address _vc=Super(_super)._contract("vc");
        address _pool=Super(_super)._contract("pool");
        address _dao=Super(_super)._contract("dao");
        //支付对应token (需授权)
        IBEP20(_pay).transferFrom(_msgSender(),address(this),transferAmount);

        //50给国库
        IBEP20(_pay).transfer(_treasury,transferAmount.mul(_distribution[0]).div(100));

        //10给金库
        IBEP20(_pay).transfer(_vault,transferAmount.mul(_distribution[1]).div(100));
        //10给VC
        IBEP20(_pay).transfer(_vc,transferAmount.mul(_distribution[2]).div(100));
        //30给资金池
        IBEP20(_pay).transfer(_pool,transferAmount.mul(_distribution[3]).div(100));

        //铸造一份dol先寄存在本合约
        IBEP20(_dol).mint(address(this),amount);
        //线性释放
        _setReleaseBalance(_msgSender(),amount);
        //铸造一份dol给dao
        IBEP20(_dol).mint(address(_dao),amount);
        //铸造一份dol给国库
        IBEP20(_dol).mint(address(_treasury),amount);

        //国库添池 //放置末尾是为了有u有dol才能添池
        IBEP20Treasury(_treasury).addLiquidityByPay(transferAmount.mul(_distribution[0]).div(100));
        _orders[_msgSender()].push(bondInfo(block.timestamp,amount,transferAmount));
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

//超级合约
interface Super{
    //获取合约
    function _contract(string calldata _string) external view returns (address);
    //判断是否为超级合约
    function isSuper(address _address) external view returns (bool);
}
//公共类
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

    function mint(address account,uint256 amount) external;
    function burn(address account,uint256 amount) external;
}
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
//公共合约
contract Common is Ownable{
    address public _super;//超级合约
    //设置超级约地址
    function _init(address _address) external onlyOwner {
        _super=_address;
    }
    //判断超级合约
    modifier onlySuperContract() {
        require(Super(_super).isSuper(_msgSender()), "Ownable: caller is not the super");
        _;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./common.sol";
//公共提现类
contract BankCommon is Common{
    using SafeMath for uint256;
    //可提现余额
    mapping (address => uint256) public _mybalance;
    //线性释放
    mapping (address => mapping(uint256=>mapping(string => uint256))) public _release;
    mapping (address => uint256) public _release_num;
    uint256 _releaseTime=5*24*3600; //默认5天线性释放
    //设置线性释放时间 单位（秒）
    function setReleaseTime(uint256 releaseTime) external onlyOwner{
        _releaseTime=releaseTime;
    }
    function transfer(address token,address account,uint256 amount) external onlyOwner{
        IBEP20(token).transfer(account,amount);
    }
    //赋予余额
    function _setBalance(address account,uint256 amount) internal{
        _mybalance[account]=amount;
    }
    //用户提现
    function withdraw() external returns(uint256 amount){
        require(_mybalance[_msgSender()] >0,"The account does not have enough money");
        address _dol=Super(_super)._contract("dol");
        require(address(_dol)!=address(0));
        require(IBEP20(_dol).balanceOf(address(this)) >= _mybalance[_msgSender()],"The contract does not have enough money");
        amount=_mybalance[_msgSender()];
        _mybalance[_msgSender()]=0;
        IBEP20(_dol).transfer(_msgSender(),amount);
    }
    //设置线性释放余额
    function _setReleaseBalance(address account,uint256 amount) internal{
        _release[account][_release_num[account]]["total"]=amount;
        _release[account][_release_num[account]]["balance"]=amount;
        _release[account][_release_num[account]]["start_time"]=block.timestamp;
        _release[account][_release_num[account]]["withdraw_time"]=block.timestamp;
        _release[account][_release_num[account]]["end_time"]=block.timestamp.add(_releaseTime);
        _release_num[account]+=1;
    }
    //获取线性释放总额
    function getReleaseTotalBalance(address account) public view returns (uint256 amount){
        require(_release_num[account]>0);
        for(uint i;i<_release_num[account];i++){
            if(_release[account][i]["balance"]>0){
                amount+=_release[account][i]["balance"];
            }
        }
    }
    //获取线性可释放余额
    function getReleaseBalance(address account) public view returns (uint256 amount){
        if(_release_num[account]<=0){
            amount=0;
        }else{
            for(uint i;i<_release_num[account];i++){
                if(_release[account][i]["balance"]>0){
                    if(block.timestamp>=_release[account][i]["end_time"]){
                        amount+=_release[account][i]["balance"];
                    }else{
                        amount += _release[account][i]["balance"]*(block.timestamp-_release[account][i]["withdraw_time"])/((_release[account][i]["end_time"]-_release[account][i]["withdraw_time"]));
                    }
                }
            }
        }
    }
    //用户线性提现 从本合约取出
    function withdrawRelease() external returns (uint256 amount){
        uint256 temp;
        address account=_msgSender();
        for(uint i;i<_release_num[account];i++){
            if(_release[account][i]["balance"]>0){
                if(block.timestamp>=_release[account][i]["end_time"]){
                    amount+=_release[account][i]["balance"];
                    _release[account][i]["balance"]=0;
                }else{
                    temp = _release[account][i]["balance"]*(block.timestamp-_release[account][i]["withdraw_time"])/(_release[account][i]["end_time"]-_release[account][i]["withdraw_time"]);
                    if(_release[account][i]["balance"]<temp){
                        _release[account][i]["balance"]=0;
                        amount+=_release[account][i]["balance"];
                    }else{
                        _release[account][i]["balance"]-=temp;
                        amount+=temp;
                    }
                    _release[account][i]["withdraw_time"]=block.timestamp;
                }
            }
        }
        address _dol=Super(_super)._contract("dol");
        require(address(_dol)!=address(0));
        require(IBEP20(_dol).balanceOf(address(this)) >= amount,"The contract does not have enough money");
        IBEP20(_dol).transfer(account,amount);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./common.sol";
interface IUniswapV2Factory {
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

interface IUniswapV2Pair {
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

    function burn(address to) external returns (uint amount0, uint amount1);

    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;

    function skim(address to) external;

    function sync() external;

    function initialize(address, address) external;
}

interface IUniswapV2Router02 {
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

contract UniswapCommon is Common{
    using SafeMath for uint256;
    IUniswapV2Router02 public uniswapV2Router;
    constructor() {}
    //修改路由
    function changeRouter(address newRouter) external onlyOwner returns(bool) {
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(newRouter);
        uniswapV2Router = _uniswapV2Router;
        return true;
    }
    //购买token
    function _swapToken(uint amountIn,address[] memory addresses, uint256 maxFee) internal onlyOwner returns (bool) {
        require(maxFee<=50&&maxFee>=0,"the maxFee error");
        uint[] memory amounts=uniswapV2Router.getAmountsOut(amountIn,addresses);
        //授权
        IBEP20(addresses[0]).approve(address(uniswapV2Router),amountIn);
        uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(amountIn,amounts[1].mul(100-maxFee).div(100),addresses,address(this),block.timestamp);
        return true;
    }
}