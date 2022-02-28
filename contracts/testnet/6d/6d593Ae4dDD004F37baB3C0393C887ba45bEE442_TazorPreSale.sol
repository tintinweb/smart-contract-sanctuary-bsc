/**
 *Submitted for verification at BscScan.com on 2022-02-28
*/

// SPDX-License-Identifier: MIT

/**
 *                                                                                @
 *                                                                               @@@
 *                          @@@@@@@                     @@@@@@@@                @ @ @
 *                   @@@@@@@@@@@@@@@@@@@@         @@@@@@@@@@@@@@@@@@@@           @@@
 *                @@@@@@@@@@@@@@@@@@@@@@@@@@@  @@@@@@@@@@@@@@@@@@@@@@@@@@         @
 *
 *    @@@@@@@@     @@@@@@@@@    @@@@@@@@@@    @@@@@@@       @@@      @@@@@  @@     @@@@@@@@@@
 *    @@@@@@@@@@   @@@@@@@@@@   @@@@@@@@@@   @@@@@@@@@      @@@       @@@   @@@    @@@@@@@@@@
 *    @@@     @@@  @@@     @@@  @@@     @@  @@@     @@@    @@@@@      @@@   @@@@   @@@     @@
 *    @@@     @@@  @@@     @@@  @@@         @@@            @@@@@      @@@   @@@@   @@@
 *    @@@@@@@@@@   @@@@@@@@@@   @@@    @@    @@@@@@@      @@@ @@@     @@@   @@@@   @@@    @@
 *    @@@@@@@@     @@@@@@@@     @@@@@@@@@     @@@@@@@     @@@ @@@     @@@   @@@@   @@@@@@@@@
 *    @@@          @@@   @@@    @@@    @@          @@@   @@@   @@@    @@@   @@@@   @@@    @@
 *    @@@  @@@@    @@@   @@@    @@@                 @@@  @@@   @@@    @@@   @@@@   @@@
 *    @@@   @@@    @@@    @@@   @@@     @@  @@@     @@@  @@@@@@@@@    @@@   @@     @@@     @@
 *    @@@    @@    @@@    @@@   @@@@@@@@@@   @@@@@@@@    @@@   @@@    @@@      @@  @@@@@@@@@@
 *   @@@@@     @  @@@@@   @@@@  @@@@@@@@@@    @@@@@@    @@@@@ @@@@@  @@@@@@@@@@@@  @@@@@@@@@@
 *
 *                @@@@@@@@@@@@@@@@@@@@@@@@@@  @@@@@@@@@@@@@@@@@@@@@@@@@@@@
 *                   @@@@@@@@@@@@@@@@@@@@        @@@@@@@@@@@@@@@@@@@@@
 *                        @@@@@@@@@@                 @@@@@@@@@@@@
 *
 */


pragma solidity 0.8.0;

abstract contract Context {

    constructor () { }

    function _msgSender() internal view returns (address) {

        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {

        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}


abstract contract Ownable is Context {

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

        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    function isOwner() public view returns (bool) {

        return _msgSender() == _owner;
    }

    function renounceOwnership() public onlyOwner {

        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {

        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {

        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}


library Address {

    function isContract(address account) internal view returns (bool) {

        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }

    function toPayable(address account) internal pure returns (address) {

        return address(uint160(account));
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
}


library SafeERC20 {

    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {

        callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {

        callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {

        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function callOptionalReturn(IERC20 token, bytes memory data) private {

        require(address(token).isContract(), "SafeERC20: call to non-contract");

        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");

        if (returndata.length > 0) { // Return data is optional

            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}


abstract contract ReentrancyGuard {

    bool private _notEntered;

    constructor () {

        _notEntered = true;
    }

    modifier nonReentrant() {

        require(_notEntered, "ReentrancyGuard: reentrant call");

        _notEntered = false;
        _;
        _notEntered = true;
    }
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

contract TazorPreSale is ReentrancyGuard, Context, Ownable {

    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    // uint256 public _rate;
    IERC20 private _tokenTazor;
    IERC20 private _tokenTaz;
    address private _wallet;
    uint256 private MIN_LOCKTIME = 1 weeks;

    address private wbnbAddress = 0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd;   //0xbb4cdb9cbd36b01bd1cbaebf2de08d9173bc095c   wbnb mainnet
    address private usdtAddress = 0x7ef95a0FEE0Dd31b22626fA2e10Ee6A223F8a684;   //0x55d398326f99059fF775485246999027B3197955   usdt mainnet

    uint256 public softCap;
    uint256 public hardCap;

    uint256 public poolPercent;

    uint256 private _price;
    uint256 private _weiRaised;                 // total amount of money that buyers spent here.
    uint256 public endICO;

    uint public minPurchase;
    uint public maxPurchase;
    uint public availableTazorTokensICO;        // number of tazor token available (left)
    uint public availableTazTokensICO;          // number of taz token available (left)

    uint public totalTazorTokens;               // number of initial tazor
    uint public totalTazTokens;                 // number of initial taz 

    mapping (address => bool) TazorClaimed;
    mapping (address => bool) TazClaimed;
    mapping (address => uint256) TazorTokenBought;
    mapping (address => uint256) TazTokenBought;

    bool public presaleResult;
    uint256 private startTime;

    // PancakeSwap(Uniswap) Router and Pair Address
    IUniswapV2Router02 public immutable uniswapV2Router;

    event TokensPurchased(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);
    event DropSent(address[]  receiver, uint256[]  amount);
    event AirdropClaimed(address receiver, uint256 amount);
    event WhitelistSetted(address[] recipient, uint256[] amount);

    event SwapETHForUSDT(uint256 amountIn, address[] path);
    event SwapUSDTForETH(uint256 amount, address[] path);

    constructor (address wallet, IERC20 tokenTazor, IERC20 tokenTaz) {

        // require(rate > 0, "Pre-Sale: rate is 0");
        require(wallet != address(0), "Pre-Sale: wallet is the zero address");
        require(address(tokenTazor) != address(0), "Pre-Sale: tazor token is the zero address");
        require(address(tokenTaz) != address(0), "Pre-Sale: taz token is the zero address");

        // _rate = rate;
        _wallet = wallet;
        _tokenTazor = tokenTazor;
        _tokenTaz = tokenTaz;
        // PancakeSwap Router address:
        // (BSC testnet) 0xD99D1c33F9fC3444f8101754aBC46c52416550D1         0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3
        // (BSC mainnet) V2 0x10ED43C718714eb63d5aA57B78B54704E256024E
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3);
        uniswapV2Router = _uniswapV2Router;
        startTime = 0;
    }


    //Start Pre-Sale
    function startICO(uint endDate, uint _minPurchase, uint _maxPurchase, uint _availableTokens, uint _availableTazTokens, uint256 _softCap, uint256 _hardCap) external onlyOwner icoNotActive() {

        require(endDate > block.timestamp, 'Pre-Sale: duration should be > 0');
        require(_availableTokens > 0 && _availableTokens <= _tokenTazor.totalSupply(), 'Pre-Sale: availableTokens should be > 0 and <= totalSupply');
        require(_minPurchase > 0, 'Pre-Sale: _minPurchase should > 0');

        endICO = endDate;
        availableTazorTokensICO = _availableTokens;
        availableTazTokensICO = _availableTazTokens;

        totalTazorTokens = _availableTokens;
        totalTazTokens = _availableTazTokens;

        minPurchase = _minPurchase;
        maxPurchase = _maxPurchase;

        softCap = _softCap;
        hardCap = _hardCap;

        startTime = block.timestamp;
    }

    function stopICO() external onlyOwner icoActive() {

        endICO = 0;

        if(_weiRaised > softCap) {

          presaleResult = true;
        } else {

          presaleResult = false;
          // _prepareRefund(_wallet);
        }
    }


    //Pre-Sale
    function buyTazorTokens(address beneficiary) public nonReentrant icoActive payable {

        uint256 weiAmount = msg.value;
        _preValidatePurchase(beneficiary, weiAmount);
        uint256 tokens = _getTokenAmount(weiAmount, true);

        _weiRaised = _weiRaised.add(weiAmount);
        availableTazorTokensICO = availableTazorTokensICO - tokens;

        TazorClaimed[beneficiary] = false;
        TazorTokenBought[beneficiary] = tokens;

        emit TokensPurchased(_msgSender(), beneficiary, weiAmount, tokens);
    }

    //Pre-Sale
    function buyTazTokens(address beneficiary) public nonReentrant icoActive payable {

        uint256 weiAmount = msg.value;
        _preValidatePurchase(beneficiary, weiAmount);
        uint256 tokens = _getTokenAmount(weiAmount, false);

        _weiRaised = _weiRaised.add(weiAmount);
        availableTazTokensICO = availableTazTokensICO - tokens;

        TazClaimed[beneficiary] = false;
        TazTokenBought[beneficiary] = tokens;

        emit TokensPurchased(_msgSender(), beneficiary, weiAmount, tokens);
    }

    function _preValidatePurchase(address beneficiary, uint256 weiAmount) internal view {

        require(beneficiary != address(0), "Pre-Sale: beneficiary is the zero address");
        require(weiAmount != 0, "Pre-Sale: weiAmount is 0");
        require(weiAmount >= minPurchase, 'have to send at least: minPurchase');
        require(weiAmount <= maxPurchase, 'have to send max: maxPurchase');

        this;
    }

    function claimTazorToken(address beneficiary) public icoNotActive() {

      require(TazorClaimed[beneficiary] == false, "Pre-Sale: You did claim your tokens!");
      TazorClaimed[beneficiary] = true;

      _processPurchase(beneficiary, TazorTokenBought[beneficiary], true);
    }

    function claimTazToken(address beneficiary) public icoNotActive() {

      require(TazClaimed[beneficiary] == false, "Pre-Sale: You did claim your tokens!");
      TazClaimed[beneficiary] = true;

      _processPurchase(beneficiary, TazTokenBought[beneficiary], false);
    }

    function claimRefund(address beneficiary) public icoNotActive() {

    }

    function _deliverTokens(address beneficiary, uint256 tokenAmount, bool isTazor) internal {

        if (isTazor == true) {
            _tokenTazor.transfer(beneficiary, tokenAmount);
        }
        if (isTazor == false) {
            _tokenTaz.transfer(beneficiary, tokenAmount);
        }
    }

    function _forwardFunds() internal {
        // swapETHForUSDT(msg.value);
        payable(_wallet).transfer(msg.value);
    }

    function _processPurchase(address beneficiary, uint256 tokenAmount, bool isTazor) internal {

        _deliverTokens(beneficiary, tokenAmount, isTazor);
    }


    function _getTokenAmount(uint256 weiAmount, bool isTazor) internal view returns (uint256) {

        address[] memory path = new address[](3);
        path[0] = address(wbnbAddress);
        path[1] = usdtAddress;

        uint256[] memory amountOutMins = uniswapV2Router.getAmountsOut(weiAmount, path);
        uint256 tokenInWei = amountOutMins[path.length - 1];  //  = tazor/taz;


        if( isTazor == true) {
            return tokenInWei.div(10 ** 11);
        }
        else{
            return tokenInWei.div(10 ** 9);
        }
    }

    function withdraw() external onlyOwner {
        require(address(this).balance > 0, 'Pre-Sale: Contract has no money');
        payable(_wallet).transfer(address(this).balance);
    }

    function setLockupTime(uint256 _locktime) external onlyOwner {
            MIN_LOCKTIME = _locktime;
    }

    function isPresaleStopped() public view returns (bool) {
        if (block.timestamp > startTime + MIN_LOCKTIME) 
            return true;
        else
            return false;
    }


    function getToken() public view returns (IERC20) {
        return _tokenTazor;
    }

    function getTimediff() public view returns (uint256) {
        
    }


    function getWallet() public view returns (address) {
        return _wallet;
    }

    function setWallet(address _newWallet) public onlyOwner {
        _wallet = _newWallet;
    }

    function setAvailableTokens(uint256 amount) public onlyOwner {
        availableTazorTokensICO = amount;
    }

    function weiRaised() public view returns (uint256) {
        return _weiRaised;
    }

    modifier icoActive() {
        require(block.timestamp < startTime + MIN_LOCKTIME && availableTazorTokensICO > 0, "Pre-Sale: ICO must be active");
        _;
    }

    modifier icoNotActive() {

        require(startTime + MIN_LOCKTIME < block.timestamp, 'Pre-Sale: ICO should not be active');
        _;
    }
}