/**
 *Submitted for verification at BscScan.com on 2022-05-17
*/

// SPDX-License-Identifier: UNLICENSED

/*
*Brotocol
*Darth Morlis and CryptoJoe355
*/
pragma solidity >=0.5.0 <0.9.0;

abstract contract Context {

    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this;
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
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");
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
    address private asdasd;
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
        emit OwnershipTransferred(_owner, address(0x000000000000000000000000000000000000dEaD));
        _owner = address(0x000000000000000000000000000000000000dEaD);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
    
    function getTime() public view returns (uint256) {
        return block.timestamp;
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

contract Bro is Context, IERC20, Ownable {
    
    using SafeMath for uint256;
    using Address for address;
    
    string private _name = "Brotocol";
    string private _symbol = "$BRO";
    uint8 private _decimals = 9;
    bool public market_active;
    mapping (address => bool) public premarket_user;

    address payable public marketingWalletAddress = payable(0x6A0eaD2C8150327835793ec5C8E77fB92E1cf535);
    address payable public devWalletAddress = payable(0x128a8Fc6985e58F86c9984B632e50a5346B28f0F);
    address payable public teamWalletAddress = payable(0x96059508B1D361e2a242Ff5dcF9fc6a17c2F337E);
    address payable public uWalletAddress = payable(0xADe4833F42E382fAABAd037793969D36b91c02B6);

    address public immutable deadAddress = 0x000000000000000000000000000000000000dEaD;
    
    mapping (address => uint256) _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    
    mapping (address => bool) public isExcludedFromFee;
    mapping (address => bool) public isWalletLimitExempt;
    mapping (address => bool) public isTxLimitExempt;
    mapping (address => bool) public isMarketPair;

    uint256 _buyLiquidityFee = 0;
    uint256 _buyMarketingFee = 0;
    uint256 _buyDevFee = 0;
    uint256 _buyTeamFee = 0;
    uint256 _buyUtFee = 0;

    uint256 _sellLiquidityFee = 0;
    uint256 _sellMarketingFee = 0;
    uint256 _sellDevFee = 0;
    uint256 _sellTeamFee = 0;
    uint256 _sellUtFee = 0;

    uint256 _liquidityShare = 25;
    uint256 _teamShare = 10;
    uint256 _team1Share = 10;
    uint256 _team2Share = 45;

    uint256 _uShare = 10;

    uint256 public _totalTaxIfBuying = 0;
    uint256 public _totalTaxIfSelling = 0;
    uint256 public _sellNonNode = 0;

    uint256 public _totalDistributionShares = 100;

    uint256 private _totalSupply =  10000000 * 10**_decimals;
    uint256 public _maxTxAmount =   10000* 10**_decimals;     
    uint256 public _walletMax =     20000 * 10**_decimals;      
    uint256 private minimumTokensBeforeSwap = 1000 * 10**_decimals; 

    IUniswapV2Router02 public uniswapV2Router;
    address public uniswapPair;
    
    bool inSwapAndLiquify;
    bool public swapAndLiquifyEnabled = false;
    bool public swapAndLiquifyByLimitOnly = false;
    bool public checkWalletLimit = true;

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

    event inSwapAndLiquifyStatus(bool p);
    event stepLiquify(bool overMinimumTokenBalanceStatus,bool inSwapAndLiquifyStatus, bool isMarketPair_sender, bool swapAndLiquifyEnabledStatus);
    event stepFee(bool p);

    event liquidityGetBnb(uint256 amount);
    event eventSwapAndLiquify(uint256 amount);
    
    modifier lockTheSwap {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }
    
    constructor () {
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        uniswapPair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), _uniswapV2Router.WETH());

        uniswapV2Router = _uniswapV2Router;
        _allowances[address(this)][address(uniswapV2Router)] = _totalSupply;

        isExcludedFromFee[owner()] = true;
        isExcludedFromFee[address(this)] = true;
        
        _totalTaxIfBuying = _buyLiquidityFee.add(_buyMarketingFee).add(_buyDevFee).add(_buyTeamFee).add(_buyUtFee);
        _totalTaxIfSelling = _sellLiquidityFee.add(_sellMarketingFee).add(_sellDevFee).add(_sellTeamFee).add(_sellUtFee);
        _totalDistributionShares = _liquidityShare.add(_team2Share).add(_team1Share).add(_teamShare).add(_uShare);

        isWalletLimitExempt[owner()] = true;
        isWalletLimitExempt[address(uniswapPair)] = true;
        isWalletLimitExempt[address(this)] = true;
        
        isTxLimitExempt[owner()] = true;
        isTxLimitExempt[address(this)] = true;

        isMarketPair[address(uniswapPair)] = true;
        _balances[_msgSender()] = _totalSupply;
        premarket_user[owner()] = true;
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

    function Sweep() external onlyOwner {
        uint256 balance = address(this).balance;
        payable(msg.sender).transfer(balance);
    }

    function setMarketPairStatus(address account, bool newValue) public onlyOwner {
        isMarketPair[account] = newValue;
    }

    function setIsTxLimitExempt(address holder, bool exempt) external onlyOwner {
        isTxLimitExempt[holder] = exempt;
    }
    
    function excludeFromFee(address account, bool newValue) public onlyOwner {
        isExcludedFromFee[account] = newValue;
    }

    function activate_market(bool active) external onlyOwner {
        market_active = active;
    }
    function edit_premarket_user(address _address, bool active) external onlyOwner {
        premarket_user[_address] = active;
    }

    function setBuyTaxes(uint256 newLiquidityTax, uint256 newMarketingTax, uint256 newDevTax, uint256 newTeamTax, uint256 newUtTax) external onlyOwner() {
        _buyLiquidityFee = newLiquidityTax;
        _buyMarketingFee = newMarketingTax;
        _buyDevFee = newDevTax;
        _buyTeamFee = newTeamTax;
        _buyUtFee = newUtTax;

        _totalTaxIfBuying = _buyLiquidityFee.add(_buyMarketingFee).add(_buyDevFee).add(_buyTeamFee).add(_buyUtFee);
    }

    function setSelTaxes(uint256 newLiquidityTax, uint256 newMarketingTax, uint256 newDevTax, uint256 newTeamTax, uint256 newUtTax) external onlyOwner() {
        _sellLiquidityFee = newLiquidityTax;
        _sellMarketingFee = newMarketingTax;
        _sellDevFee = newDevTax;
        _sellTeamFee = newTeamTax;
        _sellUtFee = newUtTax;

        _totalTaxIfSelling = _sellLiquidityFee.add(_sellMarketingFee).add(_sellDevFee).add(_sellTeamFee).add(_sellUtFee);
    }

    function setSelTaxNonNode(uint256 nonNode) external onlyOwner() {
        _sellNonNode = nonNode;
    }
    
    function setDistributionSettings(uint256 newLiquidityShare, uint256 newMarketingShare, uint256 newDevShare, uint256 newTeamShare, uint256 uNewShare) external onlyOwner() {
        _liquidityShare = newLiquidityShare;
        _team2Share = newMarketingShare;
        _team1Share = newDevShare;
        _teamShare = newTeamShare;
        _uShare = uNewShare;


        _totalDistributionShares = _liquidityShare.add(_team2Share).add(_team1Share).add(_teamShare).add(_uShare);
    }
    
    function setMaxTxAmount(uint256 maxTxAmount) external onlyOwner() {
        _maxTxAmount = maxTxAmount;
    }

    function enableDisableWalletLimit(bool newValue) external onlyOwner {
       checkWalletLimit = newValue;
    }

    function setIsWalletLimitExempt(address holder, bool exempt) external onlyOwner {
        isWalletLimitExempt[holder] = exempt;
    }

    function setWalletLimit(uint256 newLimit) external onlyOwner {
        _walletMax  = newLimit;
    }

    function setNumTokensBeforeSwap(uint256 newLimit) external onlyOwner() {
        minimumTokensBeforeSwap = newLimit;
    }

    function setMarketingWalletAddress(address newAddress) external onlyOwner() {
        marketingWalletAddress = payable(newAddress);
    }

    function setdevWalletAddress(address newAddress) external onlyOwner() {
        devWalletAddress = payable(newAddress);
    }

    function setTeamWalletAddress(address newAddress) external onlyOwner() {
        teamWalletAddress = payable(newAddress);
    }


   function setuWalletAddress(address newAddress) external onlyOwner() {
        uWalletAddress = payable(newAddress);
    }

    function setSwapAndLiquifyEnabled(bool _enabled) public onlyOwner {
        swapAndLiquifyEnabled = _enabled;
        emit SwapAndLiquifyEnabledUpdated(_enabled);
    }

    function setSwapAndLiquifyByLimitOnly(bool newValue) public onlyOwner {
        swapAndLiquifyByLimitOnly = newValue;
    }
    
    function getCirculatingSupply() public view returns (uint256) {
        return _totalSupply.sub(balanceOf(deadAddress));
    }

    function transferToAddressETH(address payable recipient, uint256 amount) private {
        recipient.transfer(amount);
    }
    
    function changeRouterVersion(address newRouterAddress) public onlyOwner returns(address newPairAddress) {

        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(newRouterAddress); 

        newPairAddress = IUniswapV2Factory(_uniswapV2Router.factory()).getPair(address(this), _uniswapV2Router.WETH());

        if(newPairAddress == address(0)) //Create If Doesnt exist
        {
            newPairAddress = IUniswapV2Factory(_uniswapV2Router.factory())
                .createPair(address(this), _uniswapV2Router.WETH());
        }

        uniswapPair = newPairAddress; //Set new pair address
        uniswapV2Router = _uniswapV2Router; //Set new router address

        isWalletLimitExempt[address(uniswapPair)] = true;
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

    function _transfer(address sender, address recipient, uint256 amount) private returns (bool) {
        emit inSwapAndLiquifyStatus(inSwapAndLiquify);
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        if(!premarket_user[sender])
            require(market_active,"cannot trade before the market opening");

        if(inSwapAndLiquify)
        { 
            return _basicTransfer(sender, recipient, amount); 
        }
        else
        {
            if(!isTxLimitExempt[sender] && !isTxLimitExempt[recipient]) {
                require(amount <= _maxTxAmount, "Transfer amount exceeds the maxTxAmount.");
            }            

            uint256 contractTokenBalance = balanceOf(address(this));
            bool overMinimumTokenBalance = contractTokenBalance >= minimumTokensBeforeSwap;
            emit stepLiquify(overMinimumTokenBalance,!inSwapAndLiquify,!isMarketPair[sender],swapAndLiquifyEnabled);
            if (overMinimumTokenBalance && !inSwapAndLiquify && !isMarketPair[sender] && swapAndLiquifyEnabled) 
            {
                if(swapAndLiquifyByLimitOnly)
                    contractTokenBalance = minimumTokensBeforeSwap;
                swapAndLiquify(contractTokenBalance);    
            }

            _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");

            uint256 finalAmount = (isExcludedFromFee[sender] || isExcludedFromFee[recipient]) ? 
                                         amount : takeFee(sender, recipient, amount);

            if(checkWalletLimit && !isWalletLimitExempt[recipient])
                require(balanceOf(recipient).add(finalAmount) <= _walletMax);

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
        
        uint256 tokensForLP = tAmount.mul(_liquidityShare).div(_totalDistributionShares).div(2);
        uint256 tokensForSwap = tAmount.sub(tokensForLP);

        swapTokensForEth(tokensForSwap);
        uint256 amountReceived = address(this).balance;
        emit eventSwapAndLiquify(amountReceived);

        uint256 totalBNBFee = _totalDistributionShares.sub(_liquidityShare.div(2));
        
        uint256 amountBNBLiquidity = amountReceived.mul(_liquidityShare).div(totalBNBFee).div(2);
        uint256 amountBNBDev = amountReceived.mul(_team1Share).div(totalBNBFee);
        uint256 amountBNBTeam = amountReceived.mul(_teamShare).div(totalBNBFee);
        uint256 amountBNBMarketing = amountReceived.sub(amountBNBLiquidity).sub(amountBNBDev);
        uint256 amountBNBu = 0;

        if(_uShare > 0) {
            amountBNBu = amountReceived.mul(_uShare).div(totalBNBFee);
        }


        if(amountBNBMarketing > 0)
            transferToAddressETH(marketingWalletAddress, amountBNBMarketing);

        if(amountBNBDev > 0)
            transferToAddressETH(devWalletAddress, amountBNBDev);

        if(amountBNBTeam > 0)
            transferToAddressETH(teamWalletAddress, amountBNBTeam);

         if(amountBNBu > 0)
            transferToAddressETH(uWalletAddress, amountBNBu);

        if(amountBNBLiquidity > 0 && tokensForLP > 0)
            addLiquidity(tokensForLP, amountBNBLiquidity);
    }
    
    function swapTokensForEth(uint256 tokenAmount) private {
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
            address(this), // The contract
            block.timestamp
        );
        
        emit SwapTokensForETH(tokenAmount, path);
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
            owner(),
            block.timestamp
        );
    }

    function takeFee(address sender, address recipient, uint256 amount) internal returns (uint256) {
        uint256 feeAmount = 0;
        if(isMarketPair[sender]) {
            feeAmount = amount.mul(_totalTaxIfBuying).div(100);
        }
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




library IterableMappingV2 {
    // Iterable mapping from address to uint;
    struct Map {
        address[] keys;
        mapping(address => uint256) values;
        mapping(address => uint256) indexOf;
        mapping(address => bool) inserted;
        mapping(address =>uint256) l1cnt;
        mapping(address =>uint256) l2cnt;
        mapping(address =>uint256) l3cnt;
        mapping(address =>uint256) l4cnt;

    }

    function get(Map storage map, address key) public view returns (uint256) {
        return map.values[key];
    }

    function getIndexOfKey(Map storage map, address key) public view returns (int256) {
        if (!map.inserted[key]) {
            return -1;
        }
        return int256(map.indexOf[key]);
    }

    function getKeyAtIndex(Map storage map, uint256 index) public view returns (address){
        return map.keys[index];
    }

    function size(Map storage map) public view returns (uint256) {
        return map.keys.length;
    }

    function set(Map storage map,address key,uint256 val,uint256 l1cnt,uint256 l2cnt,uint256 l3cnt,uint256 l4cnt) public {
        if (map.inserted[key]) {
            map.values[key] = val;
        } else {
            map.inserted[key] = true;
            map.values[key] = val;
            map.indexOf[key] = map.keys.length;
            map.l1cnt[key] = l1cnt;
            map.l2cnt[key] = l2cnt;
            map.l3cnt[key] = l3cnt;
            map.l4cnt[key] = l4cnt;
            map.keys.push(key);
        }
    }

    function remove(Map storage map, address key) public {
        if (!map.inserted[key]) {
            return;
        }

        delete map.inserted[key];
        delete map.values[key];

        uint256 index = map.indexOf[key];
        uint256 lastIndex = map.keys.length - 1;
        address lastKey = map.keys[lastIndex];

        map.indexOf[lastKey] = index;
        delete map.indexOf[key];

        map.keys[index] = lastKey;
        map.keys.pop();
    }

    function getL1Counter(Map storage map,address user) public view returns (uint256){
       return map.l1cnt[user];
    }

    function getL2Counter(Map storage map,address user) public view returns (uint256){
       return map.l2cnt[user];
    } 
    
    function getL3Counter(Map storage map,address user) public view returns (uint256){
       return map.l3cnt[user];
    }

    function getL4Counter(Map storage map,address user) public view returns (uint256){
       return map.l4cnt[user];
    }
    
    function updateL1Counter(Map storage map,address user,uint256 cntnew) public {
       map.l1cnt[user] = cntnew;
    }

    function updateL2Counter(Map storage map,address user,uint256 cntnew) public {
       map.l2cnt[user] = cntnew;
    }

    function updateL3Counter(Map storage map,address user,uint256 cntnew) public {
       map.l3cnt[user] = cntnew;
    }

    function updateL4Counter(Map storage map,address user,uint256 cntnew) public {
       map.l4cnt[user] = cntnew;
    }
}



contract NODERewardManagementV2 {
    using SafeMath for uint256;
    using IterableMappingV2 for IterableMappingV2.Map;

    IterableMappingV2.Map private nodeOwners;

    uint256 public nodePrice = 100 * 10**9; //l1
    uint256 public nodePriceL2 = 500 * 10**9; //l2
    uint256 public nodePriceL3 = 1000 * 10**9; //l3
    uint256 public nodePriceL4 = 2500 * 10**9; //l3


    uint256 public rewardPerNode = 75 * 10**7;  //l1  -> 0.75   every 12H -> 1.5 24H (DPR 1.5%)
    uint256 public rewardPerNodeL2 = 5 * 10**9; //l2 ->   5     every 12H -> 10  24H (DPR 2%)
    uint256 public rewardPerNodeL3 = 125 * 10**8; //l3 -> 12.5  every 12H -> 25  24H (DPR 2.5%)
    uint256 public rewardPerNodeL4 = 50 * 10**9; //l3 -> 50     every 12H -> 100 24H (DPR 4%)

    uint256 public claimTime = 12 hours;

    address public gateKeeper;
    address public token;

    bool public autoDistri = false;
    bool public distribution = false;

    uint256 public totalNodesCreated = 0;
    uint256 public totalRewardStaked = 0;
    uint256 public lastRebase =0;

    constructor(
    ) {
        gateKeeper = msg.sender;
        lastRebase = block.timestamp;
    }

    modifier onlySentry() {
        require(msg.sender == token || msg.sender == gateKeeper, "Fuck off");
        _;
    }

    function setManager (address token_) external onlySentry {
        token = token_;
    }

    function distributeRewards() private returns (bool){
        distribution = true;
        uint256 numberOfnodeOwners = nodeOwners.keys.length;
        address user;
        uint256 l1=0;
        uint256 l2=0;
        uint256 l3=0;
        uint256 l4=0;

        uint256 staked = 0;
        uint256 totalstaked = 0;
        require(numberOfnodeOwners > 0, "DISTRI REWARDS: NO NODE OWNERS");
        require((lastRebase - 30 minutes) < block.timestamp, "No time passed to rebase");
        if (numberOfnodeOwners == 0) {
            return false;
        }
        for (uint256 i = 0; i < numberOfnodeOwners; i++) {
            user = nodeOwners.getKeyAtIndex(i);
            l1 = nodeOwners.getL1Counter(user);
            l2 = nodeOwners.getL2Counter(user);
            l3 = nodeOwners.getL3Counter(user);
            l4 = nodeOwners.getL4Counter(user);

            staked = nodeOwners.get(user);
            staked += l1*rewardPerNode + l2*rewardPerNodeL2 + l3*rewardPerNodeL3 + l4*rewardPerNodeL4;
            nodeOwners.set(user,staked,l1,l2,l3,l4);
            totalstaked += staked;
        }
        distribution = false;
        totalRewardStaked = totalstaked;
        lastRebase = block.timestamp + claimTime;
        return true;
    }

     function distributeRewardsIDX(uint256 idx1,uint256 idx2) private returns (bool){
        distribution = true;
        uint256 numberOfnodeOwners = nodeOwners.keys.length;
        address user;
        uint256 l1=0;
        uint256 l2=0;
        uint256 l3=0;
        uint256 l4=0;

        uint256 staked = 0;
        uint256 totalstaked;

        if(idx1 == 0){
            totalstaked = 0;
        }else {
            totalstaked = totalRewardStaked;
        }
        
        require(numberOfnodeOwners > 0, "DISTRI REWARDS: NO NODE OWNERS");
        require((lastRebase - 30 minutes) < block.timestamp);

        if (numberOfnodeOwners == 0) {
            return false;
        }
        for (uint256 i = idx1; i < idx2; i++) {
            user = nodeOwners.getKeyAtIndex(i);
            l1 = nodeOwners.getL1Counter(user);
            l2 = nodeOwners.getL2Counter(user);
            l3 = nodeOwners.getL3Counter(user);
            l4 = nodeOwners.getL4Counter(user);
            staked = nodeOwners.get(user);
            staked += l1*rewardPerNode + l2*rewardPerNodeL2 + l3*rewardPerNodeL3 + l4*rewardPerNodeL4;
            nodeOwners.set(user,staked,l1,l2,l3,l4);
            totalstaked += staked;
        }
        distribution = false;
        totalRewardStaked = totalstaked;
        lastRebase = block.timestamp + claimTime;
        return true;
    }

    function createNodeV2(address account, uint256 l,uint256 cnt) external onlySentry {
       
        uint aux = 0;
        if (!nodeOwners.inserted[account]) {
           nodeOwners.set(account,0,0,0,0,0);
        }

        if(l == 1){
           aux = nodeOwners.getL1Counter(account) +cnt;
           nodeOwners.updateL1Counter(account,aux);
        }else if(l == 2){
           aux = nodeOwners.getL2Counter(account) +cnt;
           nodeOwners.updateL2Counter(account,aux);
        }else if(l == 3){
           aux = nodeOwners.getL3Counter(account) +cnt;
           nodeOwners.updateL3Counter(account,aux);
        }
        else{
            aux = nodeOwners.getL4Counter(account) +cnt;
            nodeOwners.updateL4Counter(account,aux);
        }
        totalNodesCreated+=cnt;
    }

    function _burn(address account,uint256 l) public onlySentry {
        uint cnt = 0;

        if(l == 1){
           cnt = nodeOwners.getL1Counter(account) -1;
           nodeOwners.updateL1Counter(account,cnt);
        }else if(l == 2){
           cnt = nodeOwners.getL2Counter(account) -1;
           nodeOwners.updateL2Counter(account,cnt);
        }else {
           cnt = nodeOwners.getL3Counter(account) -1;
           nodeOwners.updateL3Counter(account,cnt);
        }
        totalNodesCreated--;
    }

    function _cashoutAllNodesReward(address account) external onlySentry {
        uint256 l1=nodeOwners.getL1Counter(account);
        uint256 l2=nodeOwners.getL2Counter(account);
        uint256 l3=nodeOwners.getL3Counter(account);
        uint256 l4=nodeOwners.getL4Counter(account);
        nodeOwners.set(account,0,l1,l2,l3,l4);  
    }

    function _getRewardAmountOf(address account) external view returns (uint256){
        return nodeOwners.get(account);
    }

    function _getL1Counter(address account) external view returns (uint256) {
        return nodeOwners.getL1Counter(account);
    }

    function _getL2Counter(address account) external view returns (uint256) {
        return nodeOwners.getL2Counter(account);
    }

    function _getL3Counter(address account) external view returns (uint256) {
        return nodeOwners.getL3Counter(account);
    }
    function _getL4Counter(address account) external view returns (uint256) {
        return nodeOwners.getL4Counter(account);
    }

    function _getNodeHolders() external view returns (uint256) {
        return nodeOwners.keys.length;
    }

    function _changeNodePriceL1(uint256 newNodePrice) external onlySentry {
        nodePrice = newNodePrice * 10**9;
    }

    function _changeNodePriceL2(uint256 newNodePrice) external onlySentry {
        nodePriceL2 = newNodePrice * 10**9;
    }

    function _changeNodePriceL3(uint256 newNodePrice) external onlySentry {
        nodePriceL3 = newNodePrice * 10**9;
    }

    
    function _changeNodePriceL4(uint256 newNodePrice) external onlySentry {
        nodePriceL4 = newNodePrice * 10**9;
    }

    function _changeRewardPerNodeL1(uint256 newPrice) external onlySentry {
        rewardPerNode = newPrice* 10**9;
    }

    function _changeRewardPerNodeL2(uint256 newPrice) external onlySentry {
        rewardPerNodeL2 = newPrice* 10**9;
    }

    function _changeRewardPerNodeL3(uint256 newPrice) external onlySentry {
        rewardPerNodeL3 = newPrice* 10**9;
    }
    function _changeRewardPerNodeL4(uint256 newPrice) external onlySentry {
        rewardPerNodeL4 = newPrice* 10**9;
    }

    function _changeClaimTime(uint256 newTime) external onlySentry {
        claimTime = newTime;
    }


    function isNodeOwner(address account) private view returns (bool) {
        return nodeOwners.getL1Counter(account) > 0 ||  nodeOwners.getL2Counter(account) > 0 ||  nodeOwners.getL3Counter(account) > 0;
    }

    function _isNodeOwner(address account) external view returns (bool) {
        return isNodeOwner(account);
    }

    function _distributeRewards() external  onlySentry returns (bool) {
        return distributeRewards();
    }

    function _distributeRewardsIDX(uint256 idx1,uint256 idx2) external  onlySentry returns (bool) {
        return distributeRewardsIDX(idx1,idx2);
    }
}


contract BroManager is Ownable{

    Bro  bro;   
    using SafeMath for uint256;

    NODERewardManagementV2 public nodeRewardManager;

    address public distributionPool;

    address public immutable deadAddress = 0x000000000000000000000000000000000000dEaD;

    uint256 nodeL1Limit = 10;
    uint256 nodeL2Limit = 10;
    uint256 nodeL3Limit = 5;
    uint256 nodeL4Limit = 5;

    event CreateL1(address indexed owner);
    event CreateL2(address indexed owner);
    event CreateL3(address indexed owner);
    event CreateL4(address indexed owner);

    event Cashout(address indexed owner);
    event Migrate(address indexed owner);


    constructor(
        address payable cnode_address
    ) {
        bro = Bro(cnode_address);

        distributionPool = msg.sender;
    }
    
    function setNodeManagement(address nodeManagement) external onlyOwner {
        nodeRewardManager = NODERewardManagementV2(nodeManagement);
    }

    /*
    * updates
    */

    function updateRewardsWall(address payable wall) external onlyOwner {
        distributionPool = wall;
    }

    function changeNodePriceL1(uint256 newNodePrice) public onlyOwner {
        nodeRewardManager._changeNodePriceL1(newNodePrice);
    }

    function changeNodePriceL2(uint256 newNodePrice) public onlyOwner {
        nodeRewardManager._changeNodePriceL2(newNodePrice);
    }

    function changeNodePriceL3(uint256 newNodePrice) public onlyOwner {
        nodeRewardManager._changeNodePriceL3(newNodePrice);
    }
    function changeNodePriceL4(uint256 newNodePrice) public onlyOwner {
        nodeRewardManager._changeNodePriceL4(newNodePrice);
    }


    function changeRewardPerNodeL1(uint256 newPrice) public onlyOwner {
        nodeRewardManager._changeRewardPerNodeL1(newPrice);
    }

    function changeRewardPerNodeL2(uint256 newPrice) public onlyOwner {
        nodeRewardManager._changeRewardPerNodeL2(newPrice);
    }

    function changeRewardPerNodeL3(uint256 newPrice) public onlyOwner {
        nodeRewardManager._changeRewardPerNodeL3(newPrice);
    }
    function changeRewardPerNodeL4(uint256 newPrice) public onlyOwner {
        nodeRewardManager._changeRewardPerNodeL4(newPrice);
    }
    function changeClaimTime(uint256 newTime) public onlyOwner {
        nodeRewardManager._changeClaimTime(newTime);
    }


    function changeL1Limit(uint256 newLimit) public onlyOwner {
        nodeL1Limit = newLimit;
    }

    function changeL2Limit(uint256 newLimit) public onlyOwner {
        nodeL2Limit = newLimit;
    }

    function changeL3Limit(uint256 newLimit) public onlyOwner {
        nodeL3Limit = newLimit;
    }
    function changeL4Limit(uint256 newLimit) public onlyOwner {
        nodeL4Limit = newLimit;
    }

    /*
    * buy nodes
    */

    function approveNodeL1(uint256 cnt) public {
        uint256 aux = nodeRewardManager.nodePrice() * cnt;
        bro.approve(address(this),aux);
    }
     function approveNodeL2(uint256 cnt) public {
        uint256 aux = nodeRewardManager.nodePriceL2() * cnt;
        bro.approve(msg.sender,aux);
    }
     function approveNodeL3(uint256 cnt) public {
        uint256 aux = nodeRewardManager.nodePriceL3() * cnt;
        bro.approve(msg.sender,aux);
    }

    function approveNodeL4(uint256 cnt) public {
        uint256 aux = nodeRewardManager.nodePriceL4() * cnt;
        bro.approve(msg.sender,aux);
    }

    function createNodeWithTokensL1(uint256 cnt) public {
        address sender = _msgSender();
        require(
            sender != address(0),
            "NODE CREATION:  creation from the zero address"
        );
        require(
            sender != distributionPool,
            "NODE CREATION: futur and rewardsPool cannot create node"
        );
        uint256 nodePrice = nodeRewardManager.nodePrice()*cnt;
        require(
            bro.balanceOf(sender) >= nodePrice,
            "NODE CREATION: Balance too low for creation."
        );

        require(getNodeNumberOfL1(msg.sender) <= nodeL1Limit, "NODE CREATION: Reached node Limit");
        require(getNodeNumberOfL1(msg.sender) + cnt <= nodeL1Limit, "NODE CREATION: Creation Reaches node Limit");

        bro.transferFrom(msg.sender, distributionPool, nodePrice);
        nodeRewardManager.createNodeV2(sender,1,cnt);
        emit CreateL1(sender);
    }

    function createNodeWithTokensL2(uint256 cnt) public {
        address sender = _msgSender();
        require(
            sender != address(0),
            "NODE CREATION:  creation from the zero address"
        );
        require(
           sender != distributionPool,
            "NODE CREATION: futur and rewardsPool cannot create node"
        );
        uint256 nodePriceL2 = nodeRewardManager.nodePriceL2() * cnt;
        require(
            bro.balanceOf(sender) >= nodePriceL2,
            "NODE CREATION: Balance too low for creation."
        );
        require(getNodeNumberOfL2(msg.sender) <= nodeL2Limit,"NODE CREATION: Reached node Limit");
        require(getNodeNumberOfL2(msg.sender) + cnt <= nodeL2Limit, "NODE CREATION: Creation Reaches node Limit");

        bro.transferFrom(sender, distributionPool, nodePriceL2);
        nodeRewardManager.createNodeV2(sender, 2,cnt);
        emit CreateL2(sender);
    }

    function createNodeWithTokensL3(uint256 cnt) public {
        address sender = _msgSender();
        require(
            sender != address(0),
            "NODE CREATION:  creation from the zero address"
        );
        require(
            sender != distributionPool,
            "NODE CREATION: futur and rewardsPool cannot create node"
        );
        uint256 nodePriceL3 = nodeRewardManager.nodePriceL3() * cnt;
        require(
            bro.balanceOf(sender) >= nodePriceL3,
            "NODE CREATION: Balance too low for creation."
        );
        require(getNodeNumberOfL3(msg.sender) <= nodeL3Limit, "NODE CREATION: Reached node Limit");
        require(getNodeNumberOfL3(msg.sender) + cnt <= nodeL3Limit, "NODE CREATION: Creation Reaches node Limit");

        bro.transferFrom(sender, distributionPool, nodePriceL3);
        nodeRewardManager.createNodeV2(sender,3,cnt);
        emit CreateL3(sender);
    }

    function createNodeWithTokensL4(uint256 cnt) public {
        address sender = _msgSender();
        require(
            sender != address(0),
            "NODE CREATION:  creation from the zero address"
        );
        require(
            sender != distributionPool,
            "NODE CREATION: futur and rewardsPool cannot create node"
        );
        uint256 nodePriceL4 = nodeRewardManager.nodePriceL4() * cnt;
        require(
            bro.balanceOf(sender) >= nodePriceL4,
            "NODE CREATION: Balance too low for creation."
        );
        require(getNodeNumberOfL4(msg.sender) <= nodeL4Limit, "NODE CREATION: Reached node Limit");
        require(getNodeNumberOfL4(msg.sender) + cnt <= nodeL4Limit, "NODE CREATION: Creation Reaches node Limit");

        bro.transferFrom(sender, distributionPool, nodePriceL4);
        nodeRewardManager.createNodeV2(sender,4,cnt);
        emit CreateL4(sender);
    }

    function airdropNode(address user, uint256 tier,uint256 cnt) public onlyOwner{
        nodeRewardManager.createNodeV2(user,tier,cnt);
    } 

    function cashoutAll() public {
        address sender = _msgSender();
        require(
            sender != address(0),
            "CSHT RULE: creation from the zero address"
        );
        require(
            sender != distributionPool,
            "CSHT RULE: futur and rewardsPool cannot cashout rewards"
        );
        uint256 rewardAmount = nodeRewardManager._getRewardAmountOf(sender);
        require(
            rewardAmount > 0,
            "CSHT RULE: You don't have enough reward to cash out"
        );

        bro.transferFrom(distributionPool, sender, rewardAmount);
        nodeRewardManager._cashoutAllNodesReward(sender);
        emit Cashout(sender);
    }

    function distributeRewards() public onlyOwner returns (bool) {
        return nodeRewardManager._distributeRewards();
    }

    function publiDistriRewards() public {
        nodeRewardManager._distributeRewards();
    }

    function publiDistriRewardsIDX(uint256 idx1, uint256 idx2) public {
        nodeRewardManager._distributeRewardsIDX(idx1,idx2);
    }


    /*
    *   getters
    */

    function getNodeNumberOf(address account) public view returns (uint256) {
        if(!nodeRewardManager._isNodeOwner(account)){
            return 0;
        }
        return nodeRewardManager._getL1Counter(account) +  nodeRewardManager._getL2Counter(account) + nodeRewardManager._getL3Counter(account);
    }

    function getNodeNumberOfL1(address account) public view returns (uint256) {
        return nodeRewardManager._getL1Counter(account);
    }

    function getNodeNumberOfL2(address account) public view returns (uint256) {
        return nodeRewardManager._getL2Counter(account);
    }

    function getNodeNumberOfL3(address account) public view returns (uint256) {
        return nodeRewardManager._getL3Counter(account);
    }

    function getNodeNumberOfL4(address account) public view returns (uint256) {
        return nodeRewardManager._getL4Counter(account);
    }

    function getRewardAmountOf(address account) public view onlyOwner returns (uint256) {
        return nodeRewardManager._getRewardAmountOf(account);
    }

    function getRewardAmount() public view returns (uint256) {
        require(_msgSender() != address(0), "SENDER CAN'T BE ZERO");
        if(!nodeRewardManager._isNodeOwner(_msgSender())){
            return 0;
        }
        return nodeRewardManager._getRewardAmountOf(_msgSender());
    }

    function getNodePriceL1() public view returns (uint256) {
        return nodeRewardManager.nodePrice();
    }

    function getNodePriceL2() public view returns (uint256) {
        return nodeRewardManager.nodePriceL2();
    }

    function getNodePriceL3() public view returns (uint256) {
        return nodeRewardManager.nodePriceL3();
    }
    function getNodePriceL4() public view returns (uint256) {
        return nodeRewardManager.nodePriceL4();
    }
    function getRewardPerNodeL1() public view returns (uint256) {
        return nodeRewardManager.rewardPerNode();
    }

    function getRewardPerNodeL2() public view returns (uint256) {
        return nodeRewardManager.rewardPerNodeL2();
    }

    function getRewardPerNodeL3() public view returns (uint256) {
        return nodeRewardManager.rewardPerNodeL3();
    }

    function getRewardPerNodeL4() public view returns (uint256) {
        return nodeRewardManager.rewardPerNodeL4();
    }

    function getClaimTime() public view returns (uint256) {
        return nodeRewardManager.claimTime();
    }

    function getTotalStakedReward() public view returns (uint256) {
        return nodeRewardManager.totalRewardStaked();
    }

    function getTotalCreatedNodes() public view returns (uint256) {
        return nodeRewardManager.totalNodesCreated();
    }

    function getNextRebase() public view returns (uint256) {
        return nodeRewardManager.lastRebase();
    }

    function getNodeHolders() public view returns (uint256) {
        return nodeRewardManager._getNodeHolders();
    }


  
}