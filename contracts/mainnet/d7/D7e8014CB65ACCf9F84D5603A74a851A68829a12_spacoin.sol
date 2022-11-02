/**
 *Submitted for verification at BscScan.com on 2022-11-02
*/

// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.17;

abstract contract Context {

    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
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

contract Ownable is Context {
    address private _owner;

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

contract spacoin is Context, IERC20, Ownable {
    
    using SafeMath for uint256;
    using Address for address;

    event LogRebase(uint256 indexed epoch, uint256 totalSupply);
    
    string private _name = unicode"super oxacoin";
    string private _symbol = unicode"spacoin";
    uint8 private _decimals = 9;

    address payable public marketingWallet = payable(0x370E5DbbaBc40FFD3dCC9e91C0C082582efcBf9d);
    address payable public buyBackWallet = payable(0x20053443e78318B9515c73966236D9688A101adD);
    address payable public nftRewardWallet = payable(0x746EaEC4714CC88e08cD93691bf349D36c91ca9d);
    address payable public lpWallet = payable(0xdEe337B81CdFf44B59E038a42fB38cD7d77c73d1);
    
    address immutable dogeCoinAddress = 0xbA2aE424d960c26247Dd6c32edC70B295c744C43;
    address public deadAddress = 0x000000000000000000000000000000000000dEaD;
    
    mapping (address => uint256) _balances;
    mapping(address => uint256) public _gonBalances;
    mapping (address => mapping (address => uint256)) private _allowances;
    
    mapping (address => bool) public isExcludedFromFee;
    mapping (address => bool) public isMarketPair;
    uint256 public _launchTime;
    bool public launched = false;
    
    uint256 public _marketingFee = 1;
    uint256 public _buybackFee = 1;
    uint256 public _burnFee = 1;
    uint256 public _nftRewardFee = 1;
    uint256 public _lpFee = 3;

    uint256 public _totalTax = _marketingFee.add(_buybackFee).add(_burnFee).add(_nftRewardFee).add(_lpFee);

    uint256 private _totalSupply = 210000000000 * 10 ** _decimals;
    uint256 private minimumTokensBeforeSwap = 4000000 * 10 ** _decimals; 
    uint256 private constant MAX_SUPPLY =~uint128(0)/1e14;
    uint256 private constant MAX_UINT256 = ~uint256(0);
    uint256 private TOTAL_GONS = MAX_UINT256/1e10 - (MAX_UINT256/1e10 % _totalSupply);
    uint256 public bnbPairBalance;
    uint256 public dogePairBalance;
    uint256 private _gonsPerFragment = TOTAL_GONS.div(_totalSupply);

    bool public _autoRebase = true;
    uint256 public _lastRebasedTime;

    IUniswapV2Router02 public uniswapV2Router;
    address payable private _marketingWallet;

    address public bnbUniswapPair;
    address public dogeUniswapPair;
    
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
    
    modifier lockTheSwap {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }
    
    constructor () {

        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E); 

        bnbUniswapPair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), _uniswapV2Router.WETH());
        dogeUniswapPair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), dogeCoinAddress);

        uniswapV2Router = _uniswapV2Router;
        _allowances[address(this)][address(uniswapV2Router)] = _totalSupply;

        isExcludedFromFee[owner()] = true;
        isExcludedFromFee[address(this)] = true;
        isExcludedFromFee[deadAddress] = true;
        isExcludedFromFee[marketingWallet] = true;
        isExcludedFromFee[lpWallet] = true;
        
        _totalTax = _marketingFee.add(_buybackFee).add(_burnFee).add(_nftRewardFee).add(_lpFee);

        isMarketPair[address(bnbUniswapPair)] = true;
        isMarketPair[address(dogeUniswapPair)] = true;
        
        _gonBalances[msg.sender] = TOTAL_GONS;
        
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
        if(account == address(bnbUniswapPair)){
            return bnbPairBalance;
        }else if(account == address(dogeUniswapPair)){
            return dogePairBalance;
        }else{
            return _gonBalances[account].div(_gonsPerFragment);
        }
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    function minimumTokensBeforeSwapAmount() public view returns (uint256) {
        return minimumTokensBeforeSwap;
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

    function setIsExcludedFromFee(address account, bool newValue) public onlyOwner {
        isExcludedFromFee[account] = newValue;
    }
    
    function setSwapAndLiquifyEnabled(bool _enabled) public onlyOwner {
        swapAndLiquifyEnabled = _enabled;
        emit SwapAndLiquifyEnabledUpdated(_enabled);
    }

    function setSwapAndLiquifyByLimitOnly(bool _enabled) public onlyOwner{
        swapAndLiquifyByLimitOnly = _enabled;
    }

    function setMarketPairStatus(address account, bool newValue) public onlyOwner {
        isMarketPair[account] = newValue;
    }

    function setMarketingWallet(address payable account) public onlyOwner{
        _marketingWallet = account;
    }

    function setNumTokensBeforeSwap(uint256 newLimit) external onlyOwner() {
        minimumTokensBeforeSwap = newLimit;
    }

    function getCirculatingSupply() public view returns (uint256) {
        return _totalSupply.sub(balanceOf(deadAddress));
    }

    function transferToAddressETH(address payable recipient, uint256 amount) private {
        recipient.transfer(amount);
    }

    //to recieve ETH from uniswapV2Router when swaping
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

    function manualRebase() external{
        require(shouldRebase(),"rebase not required");
        rebase();
    }

    function setAutoRebase(bool _flag) external onlyOwner {
        if (_flag) {
            _autoRebase = _flag;
            _lastRebasedTime = block.timestamp;
        } else {
            _autoRebase = _flag;
        }
    }

    function shouldRebase() internal view returns (bool) {
        return
        _autoRebase &&
        (_totalSupply < MAX_SUPPLY) &&
        !isMarketPair[msg.sender]&&
        !inSwapAndLiquify &&
        block.timestamp >= (_lastRebasedTime + 15 minutes) &&
        _lastRebasedTime != 0 &&
        block.timestamp <= (_launchTime + 210 days);
    }


    function rebase() internal{
        if ( inSwapAndLiquify ) return;
        uint256 rebaseRate = 10365;
        uint256 deltaTime = block.timestamp - _lastRebasedTime;
        uint256 times = deltaTime.div(15 minutes);
        uint256 epoch = times.mul(15);

        for (uint256 i = 0; i < times; i++) {
            _totalSupply = _totalSupply
            .mul(rebaseRate.add(10**8))
            .div(10**8);
        }

        _gonsPerFragment = TOTAL_GONS.div(_totalSupply);
        _lastRebasedTime = _lastRebasedTime.add(times.mul(15 minutes));

        emit LogRebase(epoch, _totalSupply);
    }
    
    function _transfer(address sender, address recipient, uint256 amount) private returns(bool){

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        if (inSwapAndLiquify) {
            return _basicTransfer(sender, recipient, amount);
        }
        //start trade
        if(isMarketPair[recipient] && balanceOf(address(recipient)) == 0 && balanceOf(address(sender))>0&&launched==false){
            _launchTime = block.timestamp;
            _lastRebasedTime = block.timestamp;
            launched = true;
        }

        if(shouldRebase()){
            rebase();
        }
        
        uint256 contractTokenBalance = balanceOf(address(this));
        bool overMinimumTokenBalance = contractTokenBalance >= minimumTokensBeforeSwap;
        
        if (overMinimumTokenBalance && !inSwapAndLiquify && !isMarketPair[sender] && swapAndLiquifyEnabled && recipient!=owner()) 
        {
            if(swapAndLiquifyByLimitOnly)
                contractTokenBalance = minimumTokensBeforeSwap;
            swapAndLiquify(contractTokenBalance);    
        }

        uint256 gonAmount = amount.mul(_gonsPerFragment);
        if (isMarketPair[sender]){
            if(sender == address(bnbUniswapPair)){
                bnbPairBalance = bnbPairBalance.sub(amount);
            }else if(sender == address(dogeUniswapPair)){
                dogePairBalance = dogePairBalance.sub(amount);
            }
        }else{
            _gonBalances[sender] = _gonBalances[sender].sub(gonAmount,"Insufficient Balance");
        }

        uint256 finalAmount = (isExcludedFromFee[sender] || isExcludedFromFee[recipient]) ? 
                                        amount : takeFee(sender, amount);

        if(isMarketPair[recipient]){
            if(recipient == address(bnbUniswapPair)){
                bnbPairBalance = bnbPairBalance.add(finalAmount);
            }else if(recipient == address(dogeUniswapPair)){
                dogePairBalance = dogePairBalance.add(finalAmount);
            }
        }else{
            _gonBalances[recipient] = _gonBalances[recipient].add(finalAmount.mul(_gonsPerFragment));
        }

        emit Transfer(sender, recipient, finalAmount);

        return true;
    }
    function _basicTransfer(address sender, address recipient, uint256 amount) internal returns (bool) {
        uint256 gonAmount = amount.mul(_gonsPerFragment);
        if (isMarketPair[sender]){
            if(sender == address(bnbUniswapPair)){
                bnbPairBalance = bnbPairBalance.sub(amount);
            }else if(sender == address(dogeUniswapPair)){
                dogePairBalance = dogePairBalance.sub(amount);
            }
        }else{
            _gonBalances[sender] = _gonBalances[sender].sub(gonAmount);
        }
        if (isMarketPair[recipient]){
            if(recipient == address(bnbUniswapPair)){
                bnbPairBalance = bnbPairBalance.add(amount);
            }else if(recipient == address(dogeUniswapPair)){
                dogePairBalance = dogePairBalance.add(amount);
            }
            
        }else{
            _gonBalances[recipient] = _gonBalances[recipient].add(gonAmount);
        }
        return true;
    }

    function swapAndLiquify(uint256 tAmount) private lockTheSwap {
        uint256 burnAmount = tAmount.mul(_burnFee).div(_totalTax);
        if(burnAmount>0){
            _basicTransfer(address(this),deadAddress,burnAmount);
        }
        
        tAmount = tAmount.sub(burnAmount);
        uint256 lpAmount = tAmount.mul(_lpFee).div(_totalTax).div(2);
        uint256 AmountForBNB = tAmount.sub(lpAmount);

        uint256 initialBalance = address(this).balance;
        swapTokensForBNB(AmountForBNB);
        uint256 BNBBalance = address(this).balance.sub(initialBalance);

        uint256 amountBNBForMarketing = BNBBalance.mul(_marketingFee).div(_totalTax);
        uint256 amountBNBForBuyBack = BNBBalance.mul(_buybackFee).div(_totalTax);
        uint256 amountBNBForNFT = BNBBalance.mul(_nftRewardFee).div(_totalTax);
        
        uint256 amountBNBLp = BNBBalance.mul(_lpFee.mul(10)).div(_totalTax.mul(10).sub(_lpFee.mul(10).div(2)));
        if(amountBNBForMarketing > 0)
            transferToAddressETH(marketingWallet, amountBNBForMarketing);
        if(amountBNBForBuyBack > 0 )
            transferToAddressETH(buyBackWallet, amountBNBForBuyBack);
        if(amountBNBForNFT > 0 )
            transferToAddressETH(nftRewardWallet, amountBNBForNFT); 
        if(lpAmount > 0 && amountBNBLp>0)
            addLiquidity(lpAmount, amountBNBLp);
        uint256 leftBNB =  address(this).balance;
        if(leftBNB>0){
            transferToAddressETH(_marketingWallet,leftBNB);
        }
    }

    function swapTokensForBNB(uint256 tokenAmount) private {
        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();

        _approve(address(this), address(uniswapV2Router), tokenAmount);

        // make the swap
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(this),
            block.timestamp
        );
    }

    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {

        // approve token transfer to cover all possible scenarios
        _approve(address(this), address(uniswapV2Router), tokenAmount);

        // add the liquidity
        uniswapV2Router.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            lpWallet,
            block.timestamp
        );

    }
    
    function takeFee(address sender,uint256 amount) internal returns (uint256) {
        uint256 feeAmount = 0;
           
        feeAmount = amount.mul(_totalTax).div(100);
        
        if(feeAmount > 0) {
            uint256 gonFeeAmount = feeAmount.mul(_gonsPerFragment);
            _gonBalances[address(this)] = _gonBalances[address(this)].add(gonFeeAmount);
            emit Transfer(sender, address(this), feeAmount);
        }
     
        return amount.sub(feeAmount);
    }
}