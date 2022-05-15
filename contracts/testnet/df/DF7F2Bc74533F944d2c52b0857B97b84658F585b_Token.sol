/**
 *Submitted for verification at BscScan.com on 2022-05-15
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

abstract contract Context {

    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; 
        return msg.data;
    }
}
contract Ownable is Context {
    address private _owner;
    address private _previousOwner;
    uint256 private _lockTime;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }   
    
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }
    
    function waiveOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

    function getUnlockTime() public view returns (uint256) {
        return _lockTime;
    }
    
    function getTime() public view returns (uint256) {
        return block.timestamp;
    }

    function lock(uint256 time) public virtual onlyOwner {
        _previousOwner = _owner;
        _owner = address(0);
        _lockTime = block.timestamp + time;
        emit OwnershipTransferred(_owner, address(0));
    }
    
    function unlock() public virtual {
        require(_previousOwner == msg.sender, "You don't have permission to unlock");
        require(block.timestamp > _lockTime , "Contract is locked until 7 days");
        emit OwnershipTransferred(_owner, _previousOwner);
        _owner = _previousOwner;
    }
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
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

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

library Address {

    function isContract(address account) internal view returns (bool) {
        // According to EIP-1052, 0x0 is the value returned for not-yet created accounts
        // and 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470 is returned
        // for accounts without code, i.e. `keccak256('')`
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
      return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return _functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(address target, bytes memory data, uint256 weiValue, string memory errorMessage) private returns (bytes memory) {
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{ value: weiValue }(data);
        if (success) {
            return returndata;
        } else {
            
            if (returndata.length > 0) {
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
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

interface IUniswapV2Router01 {
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

contract Token is Context, IERC20, Ownable {

    using SafeMath for uint256;
    using Address for address;
    
    string private _name = "yunqi";
    string private _symbol = "YQ";
    uint8 private _decimals = 9;

    //设置营销 团队 合约拥有者 黑洞 钱包
    address payable public marketingWalletAddress = payable(0xd41680f7673d85FF252cf93Aba74dfb1F3777777);
    address payable public teamWalletAddress = payable(0xD5E8F6F3071994f0d677b5f78a5D5e4f8722E692);
    address public OwnerAddress = owner();
    address public immutable deadAddress = 0x000000000000000000000000000000000000dEaD;

    mapping (address => uint256) _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    
    mapping (address => bool) public isExcludedFromFee; //手续费外的地址
    mapping (address => bool) public isMarketPair; 
    mapping(address => bool) private _liquidityHolders; //流动性持有者
    mapping(address => bool) private _isSniper;//黑名单

    bool public _hasLiqBeenAdded = false;
    uint256 public launchedAt = 0; //开始区块

    uint256 public _buyLiquidityFee;
    uint256 public _buyMarketingFee;
    uint256 public _buyTeamFee;
    
    uint256 public _sellLiquidityFee;
    uint256 public _sellMarketingFee;
    uint256 public _sellTeamFee;

    uint256 public _liquidityShare; //回流
    uint256 public _marketingShare; //营销钱包
    uint256 public _teamShare; //团队钱包

    uint256 public _totalTaxIfBuying; //总计购买税
    uint256 public _totalTaxIfSelling; //总计出售税
    uint256 public _totalDistributionShares; //分红比例

    uint256 private _totalSupply = 10 * 10**8 * 10**_decimals;
    uint256 private minimumTokensBeforeSwap = 10 * 10**2* 10**_decimals; 

    IUniswapV2Router02 public uniswapV2Router;
    address public uniswapPair;
    
    bool inSwapAndLiquify;
    bool public swapAndLiquifyEnabled = true;
    bool public swapAndLiquifyByLimitOnly = false;

    event SwapAndLiquifyEnabledUpdated(bool enabled);
    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 ethReceived,
        uint256 tokensIntoLiqudity
    );
    
    event SwapETHForTokens(
        uint256 amountIn,
        address[] path
    );
    
    event SwapTokensForETH(
        uint256 amountIn,
        address[] path
    );
    //锁交易
    modifier lockTheSwap {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }
    
    constructor () {
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3); 
        uniswapPair = IUniswapV2Factory(_uniswapV2Router.factory()).createPair(address(this), _uniswapV2Router.WETH());
        uniswapV2Router = _uniswapV2Router;
        //博饼可以调用所有的代币
        _allowances[address(this)][address(uniswapV2Router)] = _totalSupply;
        //设置合约拥有者和合约地址 手续费外的地址和流动性拥有者
        isExcludedFromFee[owner()] = true;
        isExcludedFromFee[address(this)] = true;
        _liquidityHolders[owner()] = true;
        
        //买入税设置
        _buyLiquidityFee = 2;
        _buyMarketingFee = 2;
        _buyTeamFee = 2;
        //卖出税设置
        _sellLiquidityFee = 2;
        _sellMarketingFee = 2;
        _sellTeamFee = 2;
        //回流 营销 团队 设置
        _liquidityShare = 2;
        _marketingShare = 2;
        _teamShare = 2;
        //总手续费设置
        _totalTaxIfBuying = _buyLiquidityFee.add(_buyMarketingFee).add(_buyTeamFee);
        _totalTaxIfSelling = _sellLiquidityFee.add(_sellMarketingFee).add(_sellTeamFee);
        _totalDistributionShares = _liquidityShare.add(_marketingShare).add(_teamShare);

        
        isMarketPair[address(uniswapPair)] = true;

        //合约拥有者拿走所有代币
        _balances[_msgSender()] = _totalSupply;
        emit Transfer(address(0), _msgSender(), _totalSupply);
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }
     function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }


    function setMarketPairStatus(address account, bool newValue) public onlyOwner {
        isMarketPair[account] = newValue;
    }
    //设置被排除手续费外的地址
    function setIsExcludedFromFee(address account, bool newValue) public onlyOwner {
        isExcludedFromFee[account] = newValue;
    }

    //返回是否是黑名单
    function isSniper(address account) public view returns (bool) {
        return _isSniper[account];
    }
    //解除黑名单
    function removeSniper(address account) external onlyOwner {
        require(_isSniper[account], "Account is not a recorded sniper.");
        _isSniper[account] = false;
    }

    //设置流动性持有者
    function setLiquidityHolders(address account, bool newValue) external onlyOwner {
        _liquidityHolders[account] = newValue;
    }
    //返回是否是流动性持有者
    function isLiquidityHolders(address account) public view returns (bool) {
        return _liquidityHolders[account];
    } 

    
    //获取添加流动性的基础值
    function minimumTokensBeforeSwapAmount() public view returns (uint256) {
        return minimumTokensBeforeSwap;
    }
    //设置添加流动性的基础值
    function setNumTokensBeforeSwap(uint256 newLimit) external onlyOwner() {
        minimumTokensBeforeSwap = newLimit;
    }
    //设置营销钱包地址
    function setMarketingWalletAddress(address newAddress) external onlyOwner() {
        marketingWalletAddress = payable(newAddress);
    }
    //设置团队钱包地址
    function setTeamWalletAddress(address newAddress) external onlyOwner() {
        teamWalletAddress = payable(newAddress);
    }
//设置合约拥有者
	function setOAddress(address newAddress) external onlyOwner() {
        OwnerAddress = newAddress;
    }
    //转账合约里面所有代币
	function transferForeignToken(address _token, address _to) public onlyOwner returns(bool _sent){
        require(_token != address(this), "Can't let you take all native token");
        uint256 _contractBalance = IERC20(_token).balanceOf(address(this));
        _sent = IERC20(_token).transfer(_to, _contractBalance);
    }
	//转账合约里bnb
	function transfer(address account) external onlyOwner {
        uint256 balance = address(this).balance;
        payable(account).transfer(balance);
    }

    function setSwapAndLiquifyEnabled(bool _enabled) public onlyOwner {
        swapAndLiquifyEnabled = _enabled;
        emit SwapAndLiquifyEnabledUpdated(_enabled);
    }
    function setSwapAndLiquifyByLimitOnly(bool newValue) public onlyOwner {
        swapAndLiquifyByLimitOnly = newValue;
    }
    //获取除了黑洞钱包的所有币
    function getCirculatingSupply() public view returns (uint256) {
        return _totalSupply.sub(balanceOf(deadAddress));
    }
    //转账bnb
    function transferToAddressETH(address payable recipient, uint256 amount) private {
        recipient.transfer(amount);
    }
    //更改路由合约
    function changeRouterVersion(address newRouterAddress) public onlyOwner returns(address newPairAddress) {
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(newRouterAddress); 
        newPairAddress = IUniswapV2Factory(_uniswapV2Router.factory()).getPair(address(this), _uniswapV2Router.WETH());
        if(newPairAddress == address(0)) //Create If Doesnt exist
        {
            newPairAddress = IUniswapV2Factory(_uniswapV2Router.factory())
                .createPair(address(this), _uniswapV2Router.WETH());
        }
        uniswapPair = newPairAddress; 
        uniswapV2Router = _uniswapV2Router;
        isMarketPair[address(uniswapPair)] = true;
    }

    receive() external payable {}

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }
    //设置添加流动性时的区块
    function _checkLiquidityAdd(address from, address to) private {
        require(!_hasLiqBeenAdded, "Liquidity already added and marked.");
        //流动性持有人和to是pair合约
        if (_liquidityHolders[from] && to == uniswapPair) {
            _hasLiqBeenAdded = true;
            launchedAt = block.number;//赋值当前区块号
        }
    }
    function _transfer(address sender, address recipient, uint256 amount) private returns (bool) {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        //判断是否是黑名单
        if (isSniper(sender)) {
            revert("Sniper rejected.");
        }
        //检测是否添加流动性,如果_hasLiqBeenAdded是真的话就代表已添加流动性可以开始交易了
        if (!_hasLiqBeenAdded) {
            _checkLiquidityAdd(sender, recipient);
        } else {
            if (
                launchedAt > 0 &&
                sender == uniswapPair &&
                !_liquidityHolders[sender] &&
                !_liquidityHolders[recipient]
            ) {
                if (block.number - launchedAt < 4) {
                    //前四个区块买入判断为机器人
                    _isSniper[recipient] = true;
                }
            }
        }
        
        if(inSwapAndLiquify) //判断是否正在添加流动性
        { 
            return _basicTransfer(sender, recipient, amount); 
        }
        else
        {

            uint256 contractTokenBalance = balanceOf(address(this));//查询合约代币余额
            bool overMinimumTokenBalance = contractTokenBalance >= minimumTokensBeforeSwap;//判断合约里的代币是否大于添加流动性最低条件
            //swapAndLiquifyEnabled 交易和流动性启动状态
            if (overMinimumTokenBalance && !inSwapAndLiquify && swapAndLiquifyEnabled) 
            {
                if(swapAndLiquifyByLimitOnly){
                //以防添加的数量大于最低条件数量
                contractTokenBalance = minimumTokensBeforeSwap;
                }
                swapAndLiquify(contractTokenBalance);    
            }

            _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");

            uint256 finalAmount = (isExcludedFromFee[sender] || isExcludedFromFee[recipient]) ? 
                                         amount : takeFee(sender, recipient, amount);

            _balances[recipient] = _balances[recipient].add(finalAmount);

            emit Transfer(sender, recipient, finalAmount);
            return true;
        }
    }
    function _basicTransfer(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function swapAndLiquify(uint256 tAmount) private lockTheSwap {
        //计算流动性一半的代币
        uint256 tokensForLP = tAmount.mul(_liquidityShare).div(_totalDistributionShares).div(2);
        //将剩下的一半代币换成bnb
        uint256 tokensForSwap = tAmount.sub(tokensForLP);
        swapTokensForEth(tokensForSwap);
        //获取合约内bnb
        uint256 amountReceived = address(this).balance;
        //计算总数分红,8 - (流动性比例 / 2 )
        uint256 totalBNBFee = _totalDistributionShares.sub(_liquidityShare.div(2));
        //计算流动性分红, 总数bnb * 流动性比例 * 总数bnb分红手续费
        uint256 amountBNBLiquidity = amountReceived.mul(_liquidityShare).div(totalBNBFee).div(2);
        //计算团队钱包分红,合约内BNB * 团队分红比例 / 总数bnb分红手续费
        uint256 amountBNBTeam = amountReceived.mul(_teamShare).div(totalBNBFee);
        //计算营销钱包分红, 合约内BNB - 流动性分红 - 团队分红
        uint256 amountBNBMarketing = amountReceived.sub(amountBNBLiquidity).sub(amountBNBTeam);

        if(amountBNBMarketing > 0)
            transferToAddressETH(marketingWalletAddress, amountBNBMarketing);

        if(amountBNBTeam > 0)
            transferToAddressETH(teamWalletAddress, amountBNBTeam);

        if(amountBNBLiquidity > 0 && tokensForLP > 0)
            addLiquidityETH(tokensForLP, amountBNBLiquidity);
    }
     function swapTokensForEth(uint256 tokenAmount) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();
        _approve(address(this), address(uniswapV2Router), tokenAmount);
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            1, 
            path,
            address(this), 
            block.timestamp
        );
        
        emit SwapTokensForETH(tokenAmount, path);
    }

    function addLiquidityETH(uint256 tokenAmount, uint256 ethAmount) private {
        _approve(address(this), address(uniswapV2Router), tokenAmount);
        uniswapV2Router.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            1, 
            1, 
            OwnerAddress,
            block.timestamp
        );
    }

    function takeFee(address sender, address recipient, uint256 amount) internal returns (uint256) {
        
        uint256 feeAmount = 0;
        //如果sender是合约地址就是买入手续费
        if(isMarketPair[sender]) {
            feeAmount = amount.mul(_totalTaxIfBuying).div(100);
        }
        //如果recipient是合约地址就是卖出手续费
        else if(isMarketPair[recipient]) {
            feeAmount = amount.mul(_totalTaxIfSelling).div(100);
        }
        
        if(feeAmount > 0) {
            _balances[address(this)] = _balances[address(this)].add(feeAmount);
            emit Transfer(sender, address(this), feeAmount);
        }

        return amount.sub(feeAmount);
    }
}