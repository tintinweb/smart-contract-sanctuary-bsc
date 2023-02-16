// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Context.sol";

// Dex Swap 路由接口，实际上接口方法比这里写的还要更多一些，本代币合约里只用到以下方法
interface ISwapRouter {
    //路由的工厂方法，用于创建代币交易对
    function factory() external pure returns (address);
    //将指定数量的代币path[0]兑换为另外一种代币path[path.length-1]，支持手续费滑点
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    //添加代币 tokenA、tokenB 交易对流动性
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
}

interface ISwapFactory {
    //创建代币 tokenA、tokenB 的交易对，也就是常说的 LP，LP 交易对本身也是一种代币
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

//这个合约用于暂存USDT，用于回流和营销钱包，分红
contract TokenDistributor {
    //构造参数传USDT合约地址
    constructor (address token) {
        //将暂存合约的USDT授权给合约创建者，这里的创建者是代币合约，授权数量为最大整数
        IERC20(token).approve(msg.sender, uint(~uint256(0)));
    }
}

//买卖5%滑点，1%销毁，2%LP分红（U到账），2%基金会（U到账）
contract BNGToken is IERC20, Ownable {
    //用于存储每个地址的余额数量
    mapping(address => uint256) private _balances;
    //存储授权数量，资产拥有者 owner => 授权调用方 spender => 授权数量
    mapping(address => mapping(address => uint256)) private _allowances;

    string private _name;//名称
    string private _symbol;//符号
    uint8 private _decimals;//精度

    address public mainPair;//主交易对地址

    mapping(address => bool) private _feeWhiteList;//交易税白名单

    uint256 private constant MAX = ~uint256(0);
    uint256 private _tTotal;//总量

    ISwapRouter public _swapRouter;//dex swap 路由地址
    bool private inSwap;//是否正在交易，用于合约出售代币时加锁
    uint256 public numTokensSellToFund;//合约出售代币的门槛，即达到这个数量时出售代币

    TokenDistributor _tokenDistributor;//USDT 暂存合约，因为 swap 不允许将代币返回给代币合约地址
    address private usdt;

    uint256 private startTradeBlock;//开放交易的区块，用于杀机器人
    mapping(address => bool) private _blackList;//黑名单

    // 黑洞地址
    address private blackHole = 0x000000000000000000000000000000000000dEaD;

    // 基金地址
    address private fundAddress = 0x22e3Fa88519D1DCc623c90717e1392bA08344749;
    // 营销地址
    address private dividendAddress = 0xF354029E45F7Dd162864Fd656069dE4E4b1B01a9;

    // 买入底池比例
    uint256 public _ruLpRate = 200;
    // 买入营销
    uint256 public _ruYxRate = 200;
    // 买入销毁比例
    uint256 public _ruXhRate = 100;

    // 卖出底池比例
    uint256 public _chuLpRate = 200;
    // 卖出销毁比例
    uint256 public _chuXhRate = 100;
    // 卖出营销
    uint256 public _chuYxRate = 200;

    // 转账手续费
    uint256 public _zzFee = 500;

    // 卖出最大数量
    uint256 public _chuMaxNum = 1000000000000000000000;

    // 最大卖出比例99.9%
    uint256 public MAX_RATIO = 9990;

    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor (){
        _name = "Block navigation";
        _symbol = "BNG";
        _decimals = 18;

        //BSC PancakeSwap 路由地址
        // _swapRouter = ISwapRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        // usdt = address(0x55d398326f99059fF775485246999027B3197955);
        _swapRouter = ISwapRouter(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3);
        usdt = address(0x7ef95a0FEE0Dd31b22626fA2e10Ee6A223F8a684);

        //创建交易对
        mainPair = ISwapFactory(_swapRouter.factory()).createPair(address(this), usdt);
        //将合约的资产授权给路由地址
        _allowances[address(this)][address(_swapRouter)] = MAX;
        IERC20(usdt).approve(address(_swapRouter), MAX);

        //总量
        _tTotal = 100000000 * 10 ** _decimals;
        //初始代币转给营销钱包
        _balances[owner()] = _tTotal;
        emit Transfer(address(0), fundAddress, _tTotal);

        //营销地址为手续费白名单
        _feeWhiteList[fundAddress] = true;
        _feeWhiteList[dividendAddress] = true;
        _feeWhiteList[msg.sender] = true;
        _feeWhiteList[address(this)] = true;
        _feeWhiteList[address(_swapRouter)] = true;

        //营销钱包卖出条件
        numTokensSellToFund = 1 * 10 ** 17;

        _tokenDistributor = new TokenDistributor(usdt);
    }

    /**
     * @dev Returns the bep token owner.
   */
    function getOwner() external view returns (address) {
        return owner();
    }

    /**
     * @dev Returns the token decimals.
   */
    function decimals() external view returns (uint8) {
        return _decimals;
    }

    /**
     * @dev Returns the token symbol.
   */
    function symbol() external view returns (string memory) {
        return _symbol;
    }

    /**
    * @dev Returns the token name.
  */
    function name() external view returns (string memory) {
        return _name;
    }

    function totalSupply() external view override returns (uint256) {
        return _tTotal;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    // 设置买入底池比例
    function setRuLpRate(uint256 fee) public onlyOwner{
        _ruLpRate = fee;
    }
    // 设置买入营销比例
    function setRuYxRate(uint256 fee) public onlyOwner{
        _ruYxRate = fee;
    }
    // 设置买入销毁比例
    function setRuXhRate(uint256 fee) public onlyOwner{
        _ruXhRate = fee;
    }
    // 设置卖出底池比例
    function setChuDcRate(uint256 fee) public onlyOwner{
        _chuLpRate = fee;
    }
    // 设置卖出销毁比例
    function setChuXhRate(uint256 fee) public onlyOwner{
        _chuXhRate = fee;
    }
    // 设置卖出营销
    function setChuYxRate(uint256 fee) public onlyOwner{
        _chuYxRate = fee;
    }
    // 设置转账手续费
    function setZzFeeRate(uint256 fee) public onlyOwner{
        _zzFee = fee;
    }
    // 设置基金地址
    function setDFundAddress(address account) public onlyOwner{
        if(fundAddress != account){
            fundAddress = account;
        }
    }

    function setMenkan(uint256 num) public onlyOwner{
        numTokensSellToFund = num;
    }

    // 设置营销地址
    function setDividendAddress(address account) public onlyOwner{
        if(dividendAddress != account){
            dividendAddress = account;
        }
    }

    // 设置销毁地址
    function setBlackHole(address account) public onlyOwner{
        if(blackHole != account){
            blackHole = account;
        }
    }

    // 设置卖出最大数量
    function setChuMaxNum(uint256 num) public onlyOwner{
        _chuMaxNum = num;
    }

    // 设置最大卖出比例
    function setMaxRatio(uint256 _ratio) external onlyOwner {
        require(MAX_RATIO != _ratio, "TOKEN: Repeat Setting");
        MAX_RATIO = _ratio;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        if (_allowances[sender][msg.sender] != MAX) {
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender] - amount;
        }
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "approve from the zero address");
        require(spender != address(0), "approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        require(from != address(0), "Transfer from the zero address");
        require(to != address(0), "Transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");

        //黑名单不允许转出，一般貔貅代码也是这样的逻辑
        require(!_blackList[from], "Transfer from the blackList address");

        bool takeFee = false;
        if (!_feeWhiteList[from] && !_feeWhiteList[to]) {
            takeFee = true;
        }

        //交易扣税，from == mainPair 表示买入，to == mainPair 表示卖出
        if (from == mainPair || to == mainPair) {
            //交易未开启，只允许手续费白名单加池子，加池子即开放交易
            if (0 == startTradeBlock) {
                require(_feeWhiteList[from] || _feeWhiteList[to], "Trade not start");
                startTradeBlock = block.number;
            }

            //不在手续费白名单，需要扣交易税
            if (!_feeWhiteList[from] && !_feeWhiteList[to]) {
                require(amount <= _chuMaxNum, "The number of tokens sold exceeds the limit");
                require(
                (_balances[from] * MAX_RATIO) / 10000 >= amount,
                    "ERC20: transfer amount exceeds balance"
                );
                

                //杀 0、1、2 区块的交易机器人
                if (block.number <= startTradeBlock + 2) {
                    //不能把池子加入黑名单
                    if (to != mainPair) {
                        _blackList[to] = true;
                    }
                }

                //兑换资产到营销钱包
                uint256 contractTokenBalance = balanceOf(address(this));
                bool overMinTokenBalance = contractTokenBalance >= numTokensSellToFund;
                if (
                    overMinTokenBalance &&
                    !inSwap &&
                    from != mainPair
                ) {
                    //卖
                    swapTokenForFund(numTokensSellToFund,_chuLpRate,_chuYxRate);
                }
            }
        }

        _tokenTransfer(from, to, amount, takeFee);
    }

    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 tAmount,
        bool takeFee
    ) private {
        //转出者减少余额
        _balances[sender] = _balances[sender] - tAmount;

        uint256 feeAmount;
        // 买入
        if (takeFee) {
            if(sender == mainPair){
                feeAmount = tAmount * (_ruLpRate + _ruYxRate) / 10000;
                //营销钱包
                _takeTransfer(sender, address(this), feeAmount);
                //销毁
                uint256 burnAmount = tAmount * (_ruXhRate) / 10000;
                _balances[blackHole] = _balances[blackHole] + burnAmount;
                //总手续费
                feeAmount = feeAmount + burnAmount;
            }else if(recipient == mainPair){
                feeAmount = tAmount * (_chuLpRate + _chuYxRate) / 10000;
                //营销钱包
                _takeTransfer(sender, address(this), feeAmount);
                //销毁
                uint256 burnAmount = tAmount * (_chuXhRate) / 10000;
                _balances[blackHole] = _balances[blackHole] + burnAmount;
                //总手续费
                feeAmount = feeAmount + burnAmount;
            }else{
                //销毁
                uint256 burnAmount = tAmount * (_zzFee) / 10000;
                _balances[blackHole] = _balances[blackHole] + burnAmount;
                feeAmount = feeAmount + burnAmount;
            }
            
        }

        //接收者增加余额
        tAmount = tAmount - feeAmount;
        _takeTransfer(sender, recipient, tAmount);
    }

    function swapTokenForFund(uint256 tokenAmount,uint256 fundFee,uint256 dividendFee) private lockTheSwap {

        IERC20 USDT = IERC20(usdt);
        uint256 initialBalance = USDT.balanceOf(address(_tokenDistributor));

        //将代币兑换为USDT
        swapTokensForUsdt(tokenAmount);

        uint256 newBalance = USDT.balanceOf(address(_tokenDistributor)) - initialBalance;
        uint256 totalUsdtFee = fundFee + dividendFee;
        //营销钱包
        USDT.transferFrom(address(_tokenDistributor), fundAddress, newBalance * fundFee / totalUsdtFee);
        USDT.transferFrom(address(_tokenDistributor), dividendAddress, newBalance * dividendFee / totalUsdtFee);
    }

    //添加USDT交易对
    function addLiquidityUsdt(uint256 tokenAmount, uint256 usdtAmount) private {
        _swapRouter.addLiquidity(
            address(this),
            usdt,
            tokenAmount,
            usdtAmount,
            0,
            0,
            fundAddress,
            block.timestamp
        );
    }

    //将代币兑换为USDT
    function swapTokensForUsdt(uint256 tokenAmount) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = usdt;
        _swapRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(_tokenDistributor),
            block.timestamp
        );
    }

    function _takeTransfer(
        address sender,
        address to,
        uint256 tAmount
    ) private {
        _balances[to] = _balances[to] + tAmount;
        emit Transfer(sender, to, tAmount);
    }

    //查看是否手续费白名单
    function isFeeWhiteList(address addr) external view returns (bool){
        return _feeWhiteList[addr];
    }

    //表示能接收主链币
    receive() external payable {}

    //设置交易手续费白名单
    function setFeeWhiteList(address addr, bool enable) external onlyOwner {
        _feeWhiteList[addr] = enable;
    }

    /**
     *
     *  批量设置白名单
     */ 
    function excludeMultipleAccountsFromFee(
        address[] memory accounts,
        bool excluded
    ) public onlyOwner {
        for (uint256 i = 0; i < accounts.length; i++) {
            _feeWhiteList[accounts[i]] = excluded;
        }
    }

    //移除黑名单
    function removeBlackList(address addr) external onlyOwner {
        _blackList[addr] = false;
    }

    //查看是否黑名单
    function isBlackList(address addr) external view returns (bool){
        return _blackList[addr];
    }


    //提取主链币余额
    function claimBalance() public onlyOwner {
        payable(fundAddress).transfer(address(this).balance);
    }

    //提取代币
    function claimToken(address token, uint256 amount) public onlyOwner {
        IERC20(token).transfer(fundAddress, amount);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

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

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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
        require(newOwner != address(0), "Ownable: new owner is the zero address");
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
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

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

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
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}