/**
 *Submitted for verification at BscScan.com on 2022-06-16
*/

pragma solidity ^0.8.14;
// SPDX-License-Identifier: MIT
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
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
     *
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
     *
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
     *
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
     *
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
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
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
     *
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
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}
/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
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
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
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
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

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
    function allowance(address owner, address spender) external view returns (uint256);

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
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

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
interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    // function WOKT() external pure returns (address);
    // function WHT() external pure returns (address);

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

interface IUniswapV2Router02 is IUniswapV2Router01 {
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


contract MGStake is Context,Ownable{
    using SafeMath for uint256;

    uint256 addressMaxId = 0; //最大钱包id
    uint256 public totalHashRate;
    uint256 public totalReward;


    uint256 public MGAllOwn;
    mapping(address => uint256) public lastWithdraw;        //钱包的提币记录
    mapping(address => uint256) public powers;              //钱包拥有算力

    mapping(address => uint256) public balanceOf;              //钱包拥有MG

    mapping(uint256 => uint256) public hashRateRecord;              //总算力变化记录
    uint256 public recordLastBlock;                             //记录算力最后变化区块

    mapping(uint256 => address) public idToAddress;         //编号对应钱包
    mapping(address => uint256) public addressToId;         //钱包对应编号
    mapping(address => address) public invites;             //推荐关系
    mapping(address => uint256) public roles;               //钱包对应身份   1.超级DAO 2.节点
    mapping(uint256 => mapping(address => uint256)) nextBuy;  //限制用户每隔24小时每个类型的矿机只能购买一次,币安链每隔3秒出一个区块
    mapping(uint256 => mapping(uint256 => uint256)) public minerGroup;         //矿机类型对应信息  1.矿机所需u 2.算力 3.每天限购
    uint256 public production = 500 * 10 ** 18;             //每日产币
    address public USDT;                                    //usdt合约地址
    address public MCToken;                                 //mc合约地址
    address public MGToken;                                 //mg合约地址


    uint256 startBlock;  //初始区块
    mapping(uint256=>mapping(uint256 => uint256)) public minerDayDeposit; //当天每个类型质押数

    IUniswapV2Pair public mcPair;
    IUniswapV2Pair public mgPair;
    IUniswapV2Router02 public uniswapV2Router;
    address public deadAddress=0x000000000000000000000000000000000000dEaD;
    address  fundAddress;                       //基金接收钱包
    address  bufferAddress;                     //护盘接收钱包
    address  lpAddress;
    uint256  usdtRatio=90;                      //矿机所需u占%比
    constructor () {
        USDT = address(0x62747217Adcba084c0Fa90494D3d423E5324Ec38);//0x55d398326f99059fF775485246999027B3197955
        MCToken=0xBb6Fc217B432B53FE0c95De7fA637006af7cCbe9;//0xD4cC90Fe52F3139e851cB7d280f31b51966E5276
        MGToken=0xEC14FD301C257a6570a6d4612320131b67Cce1fF;//0x932F9E3F96DfB899a1129a2C4924d07C466F0D81

        mcPair=IUniswapV2Pair(0x028d52Ee59279C8228cFaDbEE19FA3593393c914);//TODO 0xe6c88979B85203195130AdF708621c09942bf470
        mgPair=IUniswapV2Pair(0x7f44ED1EE52A557CCe4370f8ADc532f818ea781a);//TODO 0x3C2b077d526c0f03fb55E9837FF2dEb3898A81B2
        uniswapV2Router=IUniswapV2Router02(0xD99D1c33F9fC3444f8101754aBC46c52416550D1);//TODO 0x10ED43C718714eb63d5aA57B78B54704E256024E


        fundAddress=0x49f61e12FA4eAcc29ea2a5227B7c2e832a956D11;
        bufferAddress=0x49f61e12FA4eAcc29ea2a5227B7c2e832a956D11;
        lpAddress=0x895Dbd83a1a5379d4061E0B76b63EB151aE7B39C;   //0x243D86513b76844245CC177f72127dc852F9a7b7

        IERC20(USDT).approve(address(0xD99D1c33F9fC3444f8101754aBC46c52416550D1),10**30); //0x10ED43C718714eb63d5aA57B78B54704E256024E

        minerGroup[100][1]=100*10**18;
        minerGroup[100][2]=100;
        minerGroup[100][3]=100;

        address topUser=address(0x0EFd5bB7c0d8c538B08bA130f2f9C2D5Fde47fA0); //0x3D5DcF713766c3cE6fd664838a8363B78D4f34C8
        idToAddress[1000]=topUser;
        addressToId[topUser]=1000;
        startBlock=block.number;
    }


    function updateUsdtRatio(uint256 ratio) external onlyOwner returns(bool){
        usdtRatio=ratio;
        return true;
    }

    function updateProduction(uint256 _production) external onlyOwner  returns(bool) {
        production=_production;
        return true;
    }

    function adminMiner(uint256 minerId,uint256 usdt,uint256 hashRate,uint256 dayDeposit) external onlyOwner returns(bool){
        minerGroup[minerId][1]=usdt;
        minerGroup[minerId][2]=hashRate;
        minerGroup[minerId][3]=dayDeposit;
        return true;
    }

    function updateUserRole(address user,uint256 roleId) external onlyOwner returns(bool){
        roles[user]=roleId;
        return true;
    }

    //购买矿机
    function deposit(address referrer,uint256 minerType) external returns (bool) {
        require(referrer!=address(0)&&addressToId[referrer]>0,"Invalid referrer");
        address sender=msg.sender;
        require(sender!=address(0),"Invalid sender");
        uint blockNum=block.number;
        while(startBlock<blockNum.sub(28800)){
            startBlock=startBlock.add(28800);
        }
        require(nextBuy[startBlock][sender] == 0,"Invalid Block Num");
        nextBuy[startBlock][sender]=nextBuy[startBlock][sender].add(1);

        if(addressToId[sender]>0){
            if(invites[sender]!=referrer){
                revert("Invalid referrer");
            }
        }else{
            addressMaxId=addressMaxId.add(1);
            addressToId[sender]=addressMaxId;
            idToAddress[addressMaxId]=sender;
            invites[sender]=referrer;
        }

        (uint256 usdtNum,uint256 hashRate,uint256 _dayDeposit)=_minerType(minerType);
        require(minerDayDeposit[startBlock][minerType]<_dayDeposit,"Invalid unable deposit");
        minerDayDeposit[startBlock][minerType]=minerDayDeposit[startBlock][minerType].add(1);
        uint256 payUsdt=usdtNum.mul(usdtRatio).div(100);
        uint256 payUsdtMc=usdtNum.sub(payUsdt);
        uint256 price=mcPrice();
        uint256 payMc=payUsdtMc.mul(price);

        _dividend(sender,referrer,payUsdt,payMc);
        _grant(sender);
        powers[sender]=powers[sender].add(hashRate);
        totalHashRate=totalHashRate.add(hashRate);
        recordLastBlock=blockNum;
        hashRateRecord[blockNum]=totalHashRate;
        return true;
    }

    function available(address user) public view returns (uint256){
        uint blockNum=block.number;
        uint256 lastBlockNum=lastWithdraw[user];
        uint256 totalMG=blockNum.sub(recordLastBlock).mul(production).div(28800).mul(powers[user]).div(totalHashRate);
        totalMG=totalMG.add(balanceOf[user]);
        uint256 _blockNum=blockNum;
        uint256 mun1=blockNum;
        while(_blockNum>=lastBlockNum){
            uint256 rateRecord=hashRateRecord[_blockNum];
            if(rateRecord!=0){
                totalMG=totalMG.add(mun1.sub(_blockNum).mul(production).div(28800).mul(powers[user]).div(rateRecord));
                mun1=_blockNum;
            }
            _blockNum=_blockNum.sub(1);
        }
        uint256 balance=IERC20(MCToken).balanceOf(address(this));
        if(totalMG>balance){
            return totalMG;
        }
        return balance;
    }




    //提币
    function getReward() public returns (bool){
        address sender=_msgSender();
        uint256 amount=available(sender);
        totalReward=totalReward.add(amount);
        lastWithdraw[sender]=block.number;
        uint256 whAmount=amount.mul(900).div(1000);
        //        矿机产出MG提币扣10%
        //        5%LP按占比分币
        //        5%团队奖励：2%/1%/1%/0.5%/0.5
        IERC20(MGToken).transfer(sender,whAmount);

        uint256 lpAmount=amount.mul(50).div(1000);
        IERC20(MGToken).transfer(lpAddress,lpAmount);

        splitInvite(sender,amount);
        return true;
    }

    function splitInvite(address sender,uint256 amount) internal{
        address invite1=invites[sender];
        if(invite1!=address(0)){
            uint256 fee1=amount.mul(20).div(1000);
            IERC20(MGToken).transfer(sender,fee1);
            address invite2=invites[invite1];
            if(invite2!=address(0)){
                uint256 fee2=amount.mul(10).div(1000);
                IERC20(MGToken).transfer(sender,fee2);
                address invite3=invites[invite2];
                if(invite3!=address(0)){
                    uint256 fee3=amount.mul(10).div(1000);
                    IERC20(MGToken).transfer(sender,fee3);
                    address invite4=invites[invite3];
                    if(invite4!=address(0)){
                        uint256 fee4=amount.mul(5).div(1000);
                        IERC20(MGToken).transfer(sender,fee4);
                        address invite5=invites[invite4];
                        if(invite5!=address(0)){
                            uint256 fee5=amount.mul(5).div(1000);
                            IERC20(MGToken).transfer(sender,fee5);
                        }
                    }
                }
            }
        }
    }

    //分成
    function _dividend(address sender,address referrer,uint256 payUsdt,uint256 payMc) internal returns (bool){
        //10%MC销毁
        IERC20(MCToken).transferFrom(sender,deadAddress,payMc);
        uint256 payAmount=payUsdt;
        //购MG销毁：10%
        uint256 brunMGAmount=payUsdt.mul(10).div(usdtRatio);
        address[] memory path = new address[](2);
        path[0] = USDT;
        path[1] = MGToken;

        uniswapV2Router.swapExactTokensForTokens(brunMGAmount,1,path,deadAddress,block.number.add(100));
        payAmount=payAmount.sub(brunMGAmount);
        //        直推：10%
        //        间推：7%
        //        超级DAO：3%
        //        节点：5%
        //        基金：5%
        //        护盘：50%
        //        购MG销毁：10%
        if(referrer!=address(0)){
            address[] memory _mg = new address[](3);

            // address inviter2;//        间推：7%
            // address superDao;//        超级DAO：3%
            // address node;//        节点：5%

            (_mg[0],_mg[1],_mg[2])=_getInvitess(referrer);
            uint256 daoRatio=3;
            //直推
            uint256 referrerAmount=payUsdt.mul(10).div(usdtRatio);

            payAmount=payAmount.sub(referrerAmount);
            IERC20(USDT).transferFrom(sender,referrer,referrerAmount);

            //间推
            if(_mg[0]!=address(0)){
                uint256 uParent2=payUsdt.mul(7).div(usdtRatio);
                payAmount=payAmount.sub(uParent2);
                IERC20(USDT).transferFrom(sender,_mg[0],uParent2);
            }

            //节点
            if(_mg[2]!=address(0)){
                uint256 uSuper2=payUsdt.mul(5).div(usdtRatio);
                payAmount=payAmount.sub(uSuper2);
                IERC20(USDT).transferFrom(sender,_mg[2],uSuper2);
            }else{
                daoRatio=daoRatio.add(5);
            }

            //超级DAO
            if(_mg[1]!=address(0)){
                uint256 uSuper1=payUsdt.mul(daoRatio).div(usdtRatio);
                payAmount=payAmount.sub(uSuper1);
                IERC20(USDT).transferFrom(sender,_mg[1],uSuper1);
            }

        }

        //护盘
        uint256 u2=payUsdt.mul(50).div(usdtRatio);
        payAmount=payAmount.sub(u2);
        IERC20(USDT).transferFrom(sender,bufferAddress,u2);

        //基金
        IERC20(USDT).transferFrom(sender,fundAddress,payAmount);

        return true;
    }

    function _minerType(uint256 t) private view returns(uint256,uint256,uint256){
        return (minerGroup[t][1],minerGroup[t][2],minerGroup[t][3]);
    }

    function _getInvitess(address user) internal view virtual returns (address,address,address) {

        uint256 roleId=roles[user];
        if(roleId==1){
            return(address(0),user,address(0));
        }

        address parent2;
        address superDao;
        address node;
        parent2=invites[user];
        if(parent2==address(0)){
            return(address(0),address(0),address(0));
        }
        //向上查询节点和超级dao直到查询出超级dao或没有上级
        address _now=parent2;
        while(true){
            address _p=invites[_now];
            if(_p==address(0)){
                break;
            }
            uint256 _roleId=roles[_p];
            if(_roleId==1){
                superDao=_p;
                break;
            }
            if(_roleId==2){
                node=_p;
            }
        }
        return(parent2,superDao,node);
    }

    //结算产币
    function _grant(address user) internal returns (bool){
        uint blockNum=block.number;
        uint256 lastBlockNum=lastWithdraw[user];
        lastWithdraw[user]=blockNum;
        if(lastBlockNum!=0){
            uint256 _blockNum=recordLastBlock;
            uint256 mun1=blockNum;
            uint256 totalMG=blockNum.sub(recordLastBlock).mul(production).div(28800).mul(powers[user]).div(totalHashRate);
            while(_blockNum>=lastBlockNum){
                uint256 rateRecord=hashRateRecord[_blockNum];
                if(rateRecord!=0){
                    totalMG=totalMG.add(mun1.sub(_blockNum).mul(production).div(28800).mul(powers[user]).div(rateRecord));
                    mun1=_blockNum;
                }
                _blockNum=_blockNum.sub(1);
            }
            MGAllOwn=MGAllOwn.add(totalMG);
            uint256 balance=IERC20(MGToken).balanceOf(address(this));
            if(MGAllOwn>balance){
                revert("Invalid balance deficiency");
            }
            balanceOf[user]=balanceOf[user].add(totalMG);

        }
        return true;
    }

    function mcPrice() public view returns(uint256){
        address token0=mcPair.token0();
        uint256 usdtTotal;
        uint256 mcTotal;

        if(token0==USDT){
            ( usdtTotal, mcTotal,)=mcPair.getReserves();
        }else{
            ( mcTotal, usdtTotal,)=mcPair.getReserves();
        }

        return mcTotal.div(usdtTotal);
    }

    function mgPrice() public view returns(uint256){
        address token0=mgPair.token0();
        uint256 usdtTotal;
        uint256 mcTotal;

        if(token0==USDT){
            ( usdtTotal, mcTotal,)=mgPair.getReserves();
        }else{
            ( mcTotal, usdtTotal,)=mgPair.getReserves();
        }

        return mcTotal.div(usdtTotal);
    }

    function withdraw(address token,address to,uint amount) external onlyOwner {
        IERC20(token).transfer(to,amount);
    }
}