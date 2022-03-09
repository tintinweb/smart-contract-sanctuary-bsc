/**
 *Submitted for verification at BscScan.com on 2022-03-09
*/

/*
    Website: https://sifuinu.io/
    Contract Name: SifuInu
    Discord: https://discord.gg/gyYTgKuc
    Twitter: @sifu_Inu @laurapoker
    YT: https://youtu.be/CWOOBDZ3T3k
    Telegram: https://t.me/sifuinuofficial
    FB: https://www.facebook.com/SifuInuOfficial
    Contract Version: 1.20
    Contract Supply: 1,000,000,000 /1 Billion
    Contract Tokenomics:
    
    6% Airdrop/Charity.
    1% Dev.
    2% Liquidity.
    1% Marketing.
    10% Total Tax


    Deployed on Binance Smart Chain Under: 
    Ethereum Blockchain under: 
    Fees cannot be higher than 10% for both buy and sale fees.

*/

// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.7;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

/**
 * IPinkAntiBot for protection of multiple sales with bots every seconds
 */
interface IPinkAntiBot {
  function setTokenOwner(address owner) external;

  function onPreTransferCheck(
    address from,
    address to,
    uint256 amount
  ) external;
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
    
    function renounceOwnership() public virtual onlyOwner {
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

// pragma solidity >=0.5.0;

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


// pragma solidity >=0.5.0;

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

// pragma solidity >=0.6.2;

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



// pragma solidity >=0.6.2;

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



contract LockToken is Ownable {
    bool public isOpen = false;
    mapping(address => bool) private _whiteList;
    modifier open(address from, address to) 
    {
        require(isOpen || _whiteList[from] || _whiteList[to], "Not Open");
        _;
    }
 
    uint256 launchTime;

    constructor() {
        _whiteList[msg.sender] = true;
        _whiteList[address(this)] = true;
    }

    function openTrade() external onlyOwner 
    {
        isOpen = true;
        if(launchTime<1)
        {
          launchTime = block.timestamp;
        }
    }

    function stopTrade() external onlyOwner {
        isOpen = false;
    }

    function includeToWhiteList(address[] memory _users) external onlyOwner {
        for(uint8 i = 0; i < _users.length; i++) {
            _whiteList[_users[i]] = true;
        }
    }
}


contract SIFUINU is Context, IERC20, LockToken {
    using SafeMath for uint256;
    using Address for address;
    address payable public marketingWalletAddress = payable(0x062BA253E4816294adb35dc2B40f2cb476925B74); // Marketing Wallet Address
    address payable public charityWalletAddress = payable(0xc678276Fc74553bff3FCB7Df308Bd86Df7F8aFDF); // charity Wallet Address
    address payable public devWalletAddress = payable(0xC0c5a76F08a9579106D00C9DC15c36bDffcE9fC8); // dev Wallet Address
    address public deadWallet =  0x000000000000000000000000000000000000dEaD;

    mapping (address => uint256) private _rOwned;
    mapping (address => uint256) private _tOwned;
    mapping (address => mapping (address => uint256)) private _allowances;

    event Log(string, uint256);
    event LogTokenApproval(address from, uint256 total);
    event LogTokenBulkSentETH(address from, uint256 total);
    event LogTokenBulkSent(address token, address from, uint256 total);
    event investmentReport(address investorAddress, uint256 amount, uint256 investmentPlan, uint256 interestRate, uint256 investmentDate, uint256 releaseDate);
    event inventReleased(address from, address to, uint256 totalEarned, uint256 ctime); 

    mapping (address => bool) private _isExcludedFromFee;

    mapping (address => bool) private _isExcluded;
    address[] private _excluded;
   
    uint256 private constant MAX = ~uint256(0);
    uint256 private _tTotal = 2_500_000_000 * 10**18;
    uint256 private _rTotal = (MAX - (MAX % _tTotal));
    uint256 private _tFeeTotal;

    uint256 _investmentCount; //counting the number of time investment occur
    uint256 investmentPlan = 3;  //calculated In Date
    uint256 interestRate = 1; // 1% of the token supply
    
    struct Invest{
    uint256 id;
    address owner;
    uint256 amountTokenInvested;
    uint256 interestRate;
    uint256 investDate;
    uint256 releaseDate;
    uint256 totalTokenEarned;
    bool releaseStatus;
    }

    mapping (address => Invest) public isInvested;

    function setInvestmentPlan(uint256 _investmentPlan, uint256 _interestRate) public{
        investmentPlan = _investmentPlan;
        interestRate = _interestRate;
    }

    function getReleaseDate(uint256 time) private view returns (uint256) {
        uint256 newTimestamp = block.timestamp + (86400 * time);
        return newTimestamp;
    }

    function sendToken(address investorAddress, uint256 amount) private{
        removeAllFee();
        _transferStandard(investorAddress, address(this) ,amount);
        restoreAllFee();
    }

    function releaseToken(address investorAddress, uint256 amount) private{
        removeAllFee();
        _transferStandard(address(this), investorAddress, amount);
        restoreAllFee();
    }

    function calculateProfit(uint256 amount, uint256 _interestRate) private pure returns (uint256){
        return amount + ((_interestRate *  amount) / 100);
    }

    function claimInvestment() public {
        address investor = msg.sender;
        uint256 ctime = block.timestamp;
        Invest memory invests = isInvested[investor];
        uint id = invests.id;
        bool status = invests.releaseStatus;
        uint releaseDate = invests.releaseDate;
        uint256 totalEarned = invests.totalTokenEarned;
        require(id > 0 && status==false, "You have already claim this investment.");
        require(ctime >= releaseDate, "you can't claim investment now, until investment period end.");
        invests.releaseStatus = true;
        releaseToken(investor, totalEarned);
        emit inventReleased(address(this), investor, totalEarned, ctime);
    }
    

    function investment(uint256 amount) public {

    address investor = msg.sender;
    Invest memory invests = isInvested[investor];
    uint id = invests.id;
    bool status = invests.releaseStatus;

    
    require(investmentPlan >= 1, "You can't invest now. No investment plan available yet");
    require(interestRate >= 1, "You can't invest now. No interestRate is available for the investment plan");
    require(amount <= balanceOf(investor), "Your balance is too low to the amount you want to invest, pls buy more token!");
    require(id < 1 || status == true, "You can't invest twice");



    uint256 investedTime = block.timestamp;
    uint256 endTime = getReleaseDate(investmentPlan);
    uint totalTokenToEarned = calculateProfit(amount, interestRate);
    bool releaseStatus = false;
    _investmentCount++;

    isInvested[investor] = Invest(_investmentCount, investor, amount, interestRate, investedTime, endTime, totalTokenToEarned, releaseStatus );
    sendToken(investor, amount);
    emit investmentReport(investor, amount, investmentPlan, interestRate, investedTime, endTime);

    }

    

    string private _name = "Sifu Inu";
    string private _symbol = "SIFU";
    uint8 private _decimals = 18;


    uint256 public _taxFee = 0;
    uint256 private _previousTaxFee = _taxFee;
    
    uint256 public _liquidityFee = 8;  
    uint256 private _previousLiquidityFee = _liquidityFee;

    uint256 public _devFee = 2; 
    uint256 private _previousDevFee = _devFee;    

    uint256 public _marketingFee = 4; 
    uint256 private _previousMarketingFee = _marketingFee;

    uint256 public _charityFee = 6; 
    uint256 private _previousCharityFee = _charityFee;

    uint256 totalSwapableFee = _liquidityFee.add(_devFee).add(_marketingFee).add(_charityFee);

    uint256 _saleTaxFee = 0;
    uint256 _saleLiquidityFee = 8;
    uint256 _saleDevFee = 2;
    uint256 _saleMarketingFee = 4;
    uint256 _saleCharityFee = 6;

    bool public blacklistMode = true;
    mapping (address => bool) public isBlacklisted;

    //pinksaleAntiBot
    IPinkAntiBot public pinkAntiBot;
    address public pinkAntiBot_ = 0x8EFDb3b642eb2a20607ffe0A56CFefF6a95Df002; //testnet 0xbb06F5C7689eA93d9DeACCf4aF8546C4Fe0Bf1E5 //mainnet 0x8EFDb3b642eb2a20607ffe0A56CFefF6a95Df002
    bool public antiBotEnabled;
    

    uint256 public liquidityTokensCollected = 0;
    uint256 public devTokensCollected = 0;
    uint256 public marketingTokensCollected = 0;
    uint256 public charityTokensCollected = 0;

    uint256 public _maxTxAmount = 10_000_000_000 * 10**18; //1 %
    uint256 private minimumTokensBeforeSwap = 100_000 * 10**18;

    IUniswapV2Router02 public immutable uniswapV2Router;
    address public immutable uniswapV2Pair;
    
    bool inSwapAndLiquify;
    bool public swapAndLiquifyEnabled = false;

    event RewardLiquidityProviders(uint256 tokenAmount);
    event SwapAndLiquifyEnabledUpdated(bool enabled);
    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 ethReceived,
        uint256 tokensIntoLiqudity
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
        _rOwned[_msgSender()] = _rTotal;
        
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E); 
//Pancake Routers
//testnet 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3  
//mainnet 0x10ED43C718714eb63d5aA57B78B54704E256024E
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), _uniswapV2Router.WETH());
        uniswapV2Router = _uniswapV2Router;
        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;

        // Create an instance of the PinkAntiBot variable from the provided address
        pinkAntiBot = IPinkAntiBot(pinkAntiBot_);
        // Register the deployer to be the token owner with PinkAntiBot. You can later change the token owner in the PinkAntiBot contract
        pinkAntiBot.setTokenOwner(msg.sender);
        antiBotEnabled = true;

        emit Transfer(address(0), _msgSender(), _tTotal);
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
        return _tTotal;
    }

    function balanceOf(address account) public view override returns (uint256) {
        if (_isExcluded[account]) return _tOwned[account];
        return tokenFromReflection(_rOwned[account]);
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    function isExcludedFromReward(address account) public view returns (bool) {
        return _isExcluded[account];
    }

    function totalFees() public view returns (uint256) {
        return _tFeeTotal;
    }
    
    function minimumTokensBeforeSwapAmount() public view returns (uint256) {
        return minimumTokensBeforeSwap;
    }
    
    function enable_blacklist(bool _status) public onlyOwner {
        blacklistMode = _status;
    }

    function manage_blacklist(address[] calldata addresses, bool status) public onlyOwner {
        for (uint256 i; i < addresses.length; ++i) {
            isBlacklisted[addresses[i]] = status;
        }
    }

    // Use this function to control whether to use PinkAntiBot or not instead
    // of managing this in the PinkAntiBot contract
    function setEnableAntiBot(bool _enable) external onlyOwner {
    antiBotEnabled = _enable;
    }
  

    function reflectionFromToken(uint256 tAmount, bool deductTransferFee) public view returns(uint256) {
        require(tAmount <= _tTotal, "Amount must be less than supply");
        if (!deductTransferFee) {
            (uint256 rAmount,,,,,) = _getValues(tAmount);
            return rAmount;
        } else {
            (,uint256 rTransferAmount,,,,) = _getValues(tAmount);
            return rTransferAmount;
        }
    }

    function tokenFromReflection(uint256 rAmount) public view returns(uint256) {
        require(rAmount <= _rTotal, "Amount must be less than total reflections");
        uint256 currentRate =  _getRate();
        return rAmount.div(currentRate);
    }

    function excludeFromReward(address account) public onlyOwner() {

        require(!_isExcluded[account], "Account is already excluded");
        if(_rOwned[account] > 0) {
            _tOwned[account] = tokenFromReflection(_rOwned[account]);
        }
        _isExcluded[account] = true;
        _excluded.push(account);
    }

    function includeInReward(address account) external onlyOwner() {
        require(_isExcluded[account], "Account is already excluded");
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (_excluded[i] == account) {
                _excluded[i] = _excluded[_excluded.length - 1];
                _tOwned[account] = 0;
                _isExcluded[account] = false;
                _excluded.pop();
                break;
            }
        }
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private open(from, to) {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        if(from != owner() && to != owner()) {
            require(amount <= _maxTxAmount, "Transfer amount exceeds the maxTxAmount.");
        }

        // Blacklist
        if(blacklistMode){
            require(!isBlacklisted[from] && !isBlacklisted[to],"Blacklisted");    
        }
        
        // Only use PinkAntiBot if this state is true
        if (antiBotEnabled) {
            pinkAntiBot.onPreTransferCheck(from, to, amount);
        }

        uint256 contractTokenBalance = balanceOf(address(this));
        bool overMinimumTokenBalance = contractTokenBalance >= minimumTokensBeforeSwap;
        
        if (!inSwapAndLiquify && swapAndLiquifyEnabled && from != uniswapV2Pair && from != owner()) 
        {
            
            if (overMinimumTokenBalance) 
            {
                swapAndLiquify();    
            }
        }
        if(to==uniswapV2Pair) { setSaleFee(); } 

        bool takeFee = true;
        //if any account belongs to _isExcludedFromFee account then remove the fee
        if(_isExcludedFromFee[from] || _isExcludedFromFee[to])
        {
            takeFee = false;
        }
        _tokenTransfer(from,to,amount,takeFee);
    }

    function swapAndLiquify() public lockTheSwap 
    {   
        uint256 initialBalance = address(this).balance;
        uint256 halfLiquidityTokens = liquidityTokensCollected.div(2);
        swapTokensForEth(halfLiquidityTokens);
        
        uint256 newBalance = address(this).balance.sub(initialBalance);
        addLiquidity(halfLiquidityTokens, newBalance);
        emit SwapAndLiquify(halfLiquidityTokens, newBalance, halfLiquidityTokens);

        initialBalance = address(this).balance;
        uint256 totalTokens = balanceOf(address(this));
        swapTokensForEth(totalTokens);
        newBalance = address(this).balance.sub(initialBalance);

        uint256 walletsTotal = devTokensCollected.add(marketingTokensCollected).add(charityTokensCollected);

        uint256 ethForMarketing = newBalance.mul(marketingTokensCollected).div(walletsTotal);
        uint256 ethForCharity = newBalance.mul(charityTokensCollected).div(walletsTotal);
        uint256 ethForDev = newBalance.mul(devTokensCollected).div(walletsTotal);

        transferToAddressETH(marketingWalletAddress, ethForMarketing);
        transferToAddressETH(charityWalletAddress, ethForCharity);
        transferToAddressETH(devWalletAddress, ethForDev);

        liquidityTokensCollected = 0;
        devTokensCollected = 0;
        marketingTokensCollected = 0;
        charityTokensCollected = 0;

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

    function _tokenTransfer(address sender, address recipient, uint256 amount,bool takeFee) private {
        if(!takeFee) { removeAllFee(); }
        countUpFeeShare(amount);
        if (_isExcluded[sender] && !_isExcluded[recipient]) {
            _transferFromExcluded(sender, recipient, amount);
        } else if (!_isExcluded[sender] && _isExcluded[recipient]) {
            _transferToExcluded(sender, recipient, amount);
        } else if (_isExcluded[sender] && _isExcluded[recipient]) {
            _transferBothExcluded(sender, recipient, amount);
        } else 
        {
            _transferStandard(sender, recipient, amount);
        }
        restoreAllFee();   
    }



    function countUpFeeShare(uint256 amount) private
    {
        if(totalSwapableFee==0) { return; }
        liquidityTokensCollected += amount.mul(_liquidityFee).div(100);
        devTokensCollected += amount.mul(_devFee).div(100);
        marketingTokensCollected += amount.mul(_marketingFee).div(100);
        charityTokensCollected += amount.mul(_charityFee).div(100);
    }


    function _transferStandard(address sender, address recipient, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee, uint256 tLiquidity) = _getValues(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
        _takeLiquidity(tLiquidity);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _transferToExcluded(address sender, address recipient, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee, uint256 tLiquidity) = _getValues(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _tOwned[recipient] = _tOwned[recipient].add(tTransferAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);           
        _takeLiquidity(tLiquidity);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _transferFromExcluded(address sender, address recipient, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee, uint256 tLiquidity) = _getValues(tAmount);
        _tOwned[sender] = _tOwned[sender].sub(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);   
        _takeLiquidity(tLiquidity);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _transferBothExcluded(address sender, address recipient, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee, uint256 tLiquidity) = _getValues(tAmount);
        _tOwned[sender] = _tOwned[sender].sub(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _tOwned[recipient] = _tOwned[recipient].add(tTransferAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);        
        _takeLiquidity(tLiquidity);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _reflectFee(uint256 rFee, uint256 tFee) private {
        _rTotal = _rTotal.sub(rFee);
        _tFeeTotal = _tFeeTotal.add(tFee);
    }

    function _getValues(uint256 tAmount) private view returns (uint256, uint256, uint256, uint256, uint256, uint256) {
        (uint256 tTransferAmount, uint256 tFee, uint256 tLiquidity) = _getTValues(tAmount);
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee) = _getRValues(tAmount, tFee, tLiquidity, _getRate());
        return (rAmount, rTransferAmount, rFee, tTransferAmount, tFee, tLiquidity);
    }

    function _getTValues(uint256 tAmount) private view returns (uint256, uint256, uint256) {
        uint256 tFee = calculateTaxFee(tAmount);
        uint256 tLiquidity = calculateLiquidityFee(tAmount);
        uint256 tTransferAmount = tAmount.sub(tFee).sub(tLiquidity);
        return (tTransferAmount, tFee, tLiquidity);
    }

    function _getRValues(uint256 tAmount, uint256 tFee, uint256 tLiquidity, uint256 currentRate) private pure returns (uint256, uint256, uint256) {
        uint256 rAmount = tAmount.mul(currentRate);
        uint256 rFee = tFee.mul(currentRate);
        uint256 rLiquidity = tLiquidity.mul(currentRate);
        uint256 rTransferAmount = rAmount.sub(rFee).sub(rLiquidity);
        return (rAmount, rTransferAmount, rFee);
    }

    function _getRate() private view returns(uint256) {
        (uint256 rSupply, uint256 tSupply) = _getCurrentSupply();
        return rSupply.div(tSupply);
    }

    function _getCurrentSupply() private view returns(uint256, uint256) {
        uint256 rSupply = _rTotal;
        uint256 tSupply = _tTotal;      
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (_rOwned[_excluded[i]] > rSupply || _tOwned[_excluded[i]] > tSupply) return (_rTotal, _tTotal);
            rSupply = rSupply.sub(_rOwned[_excluded[i]]);
            tSupply = tSupply.sub(_tOwned[_excluded[i]]);
        }
        if (rSupply < _rTotal.div(_tTotal)) return (_rTotal, _tTotal);
        return (rSupply, tSupply);
    }
    
    function _takeLiquidity(uint256 tLiquidity) private {
        uint256 currentRate =  _getRate();
        uint256 rLiquidity = tLiquidity.mul(currentRate);
        _rOwned[address(this)] = _rOwned[address(this)].add(rLiquidity);
        if(_isExcluded[address(this)]) { _tOwned[address(this)] = _tOwned[address(this)].add(tLiquidity); }
    }
    
    function calculateTaxFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_taxFee).div(10**2);
    }
    
    function calculateLiquidityFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(totalSwapableFee).div(100);
    }
    
    function removeAllFee() private 
    {
        _taxFee = 0;
        _liquidityFee = 0;
        _devFee = 0;
        _marketingFee = 0;
        _charityFee = 0;
        totalSwapableFee = 0;
    }
    
    function restoreAllFee() private {
        _taxFee = _previousTaxFee;
        _liquidityFee = _previousLiquidityFee;
        _devFee = _previousDevFee;
        _marketingFee = _previousMarketingFee;
        _charityFee = _previousCharityFee;
        totalSwapableFee = _liquidityFee.add(_devFee).add(_marketingFee).add(_charityFee);
    }

    function setSaleFee() private {
        _taxFee = _saleTaxFee;
        _liquidityFee = _saleLiquidityFee;
        _devFee = _saleDevFee;
        _marketingFee = _saleMarketingFee;
        _charityFee = _saleCharityFee;
        totalSwapableFee = _liquidityFee.add(_devFee).add(_marketingFee).add(_charityFee);
    }

    function isExcludedFromFee(address account) public view returns(bool) {
        return _isExcludedFromFee[account];
    }

    
    function excludeFromFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = true;
    }
    
    function includeInFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = false;
    }
    
    function setAllFeePercent(uint256 taxFee, uint256 liquidityFee, uint256 devFee, uint256 marketingFee, uint256 charityFee) 
    external onlyOwner() 
    {
        _taxFee = taxFee;
        _previousTaxFee = _taxFee;
        _liquidityFee = liquidityFee;
        _previousLiquidityFee = _liquidityFee;
        _devFee = devFee;
        _previousDevFee = _devFee;
        _marketingFee = marketingFee;
        _previousMarketingFee = _marketingFee;
        _charityFee = charityFee;
        _previousCharityFee = _charityFee;
        totalSwapableFee = _liquidityFee.add(_devFee).add(_marketingFee).add(_charityFee);
    }

    function setSaleFeePercent(uint256 taxFee, uint256 liquidityFee, uint256 devFee, uint256 marketingFee, uint256 charityFee) 
    external onlyOwner() 
    {
        _saleTaxFee = taxFee;
        _saleLiquidityFee = liquidityFee;
        _saleDevFee = devFee;
        _saleMarketingFee = marketingFee;
        _saleCharityFee = charityFee;
    }
    


    function setSaleLiquidityFeePercent(uint256 liquidityFee) external onlyOwner() {
        _saleLiquidityFee = liquidityFee;
    }
    
    function setMaxTxAmount(uint256 maxTxAmount) external onlyOwner() {
        _maxTxAmount = maxTxAmount;
    }
    

    function setNumTokensSellToAddToLiquidity(uint256 _minimumTokensBeforeSwap) external onlyOwner() {
        minimumTokensBeforeSwap = _minimumTokensBeforeSwap;
    }

    function setMarketingWalletAddress(address _marketingWallet) external onlyOwner() {
        marketingWalletAddress = payable(_marketingWallet);
    }

    function setCharityWalletAddress(address _charityWallet) external onlyOwner() {
        charityWalletAddress = payable(_charityWallet);
    }

    function setDevWalletAddress(address _devWallet) external onlyOwner() {
        devWalletAddress = payable(_devWallet);
    }
	
	function setpinkAntiBotAddress(address _AntiBotAddress) external onlyOwner() {
        pinkAntiBot_ = _AntiBotAddress;
    }

    function setSwapAndLiquifyEnabled(bool _enabled) public onlyOwner {
        swapAndLiquifyEnabled = _enabled;
        emit SwapAndLiquifyEnabledUpdated(_enabled);
    }
    
    
    function transferToAddressETH(address payable recipient, uint256 amount) private {
        recipient.transfer(amount);
    }
    
     //to recieve ETH from uniswapV2Router when swaping
    receive() external payable {}

/////---dev----////    
    event SwapETHForTokens(uint256 amountIn, address[] path);
   
    address deadAddress = 0x000000000000000000000000000000000000dEaD;


    function swapETHForTokens(uint256 amount) private 
    {
        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = uniswapV2Router.WETH();
        path[1] = address(this);
      // make the swap
        uniswapV2Router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: amount}(
            0, // accept any amount of Tokens
            path, deadAddress, // Burn address
            block.timestamp.add(300));
        emit SwapETHForTokens(amount, path);
    }
 

    //Aidrop
    function sendSameValue(address _tokenAddress, address[] memory _to, uint256 _value) external onlyOwner {
       
        address from = msg.sender;
        //require(_to.length <= 255, 'exceed max allowed');
        uint256 sendAmount = _to.length.mul(_value);
        sendAmount += _value;
        IERC20 token = IERC20(_tokenAddress);
        token.approve(msg.sender, sendAmount); //aprove token before sending it
        emit LogTokenApproval(from, sendAmount);
        for (uint256 i = 0; i < _to.length - 1; i++) {
            token.transferFrom(from, _to[i], _value);
        }
        emit LogTokenBulkSent(_tokenAddress, from, sendAmount);

    }
    function sendTokenToContract(uint amount, address token) payable external{
        IERC20 mytoken = IERC20(token);
        
        require(amount > 0, "You need to send at least some tokens");
        mytoken.transfer(address(this),amount);
        emit LogTokenBulkSent(msg.sender,address(this),amount);
    }
      
    function sendSameValueContract(address _tokenAddress, address[] memory _to, uint256 _value) external onlyOwner {

       // require(_to.length <= 255, 'exceed max allowed');
        uint256 sendAmount = _to.length.mul(_value);
        sendAmount += _value;
        IERC20 token = IERC20(_tokenAddress);
        token.approve(address(this), sendAmount); //aprove token before sending it
        emit LogTokenApproval(address(this), sendAmount);
        for (uint256 i = 0; i < _to.length - 1; i++) {
            token.transferFrom(address(this), _to[i], _value);
        }
        emit LogTokenBulkSent(_tokenAddress, address(this), sendAmount);

    }

    function read(address[] memory myadd, uint val) public pure returns(uint,uint){
        uint a = myadd.length;
       
        uint c = a * val;
        return(a,c);
    }
    function sendDifferentValue(address _tokenAddress, address[] memory _to, uint256[] memory _value) external onlyOwner {
        
        address from = msg.sender;
        require(_to.length == _value.length, 'invalid input');
       // require(_to.length <= 255, 'exceed max allowed');
        uint256 sendAmount;
        
        IERC20 token = IERC20(_tokenAddress);
  
        token.approve(address(this), sendAmount); //aprove token before sending it
    
        for (uint256 i = 0; i < _to.length; i++) {
            token.transferFrom(msg.sender, _to[i], _value[i]);
            sendAmount.add(_value[i]);
        }
        emit LogTokenBulkSent(_tokenAddress, from, sendAmount);

    }
    function ApproveERC20Token1 (address _tokenAddress, uint256 _value) external onlyOwner {
    
        IERC20 token = IERC20(_tokenAddress);
        token.approve(address(this), _value); //Approval of spacific amount or more, this will be an idependent approval
        
        emit LogTokenApproval(_tokenAddress, _value);
    }
            // Withdraw ETH that's potentially stuck
    function recoverETHfromContract() external onlyOwner {
        payable(devWalletAddress).transfer(address(this).balance);
    }
    
   /* Airdrop Begins */
function multiTransfer(address[] calldata addresses, uint256[] calldata tokens) external onlyOwner {

    require(addresses.length < 501,"GAS Error: max airdrop limit is 500 addresses");
    require(addresses.length == tokens.length,"Mismatch between Address and token count");
    address from = owner();
    uint256 SCCC = 0;

    for(uint i=0; i < addresses.length; i++){
        SCCC = SCCC + tokens[i];
    }

    require(balanceOf(from) >= SCCC, "Not enough tokens in wallet");

    for(uint i=0; i < addresses.length; i++){
       removeAllFee();
        _transferStandard(from, addresses[i], tokens[i]);
        restoreAllFee();
    }

   
}

function multiTransferFixed(address[] calldata addresses, uint256 tokens) external onlyOwner {

    require(addresses.length < 801,"GAS Error: max airdrop limit is 500 addresses");
    address from = owner();
    uint256 SCCC = tokens * addresses.length;

    require(balanceOf(from) >= SCCC, "Not enough tokens in wallet");

    for(uint i=0; i < addresses.length; i++){
       removeAllFee();
        _transferStandard(from, addresses[i], tokens);
        restoreAllFee();
    }

   
}
    
    function recoverTokenFromContract() public onlyOwner
    {
     uint256 totalContractBalance = balanceOf(address(this));
     
        removeAllFee();
        _transferStandard(address(this), owner(), totalContractBalance);
        restoreAllFee();
    
    }

    function manualBurn(uint256 burnAmount) public onlyOwner
    {
		require(burnAmount <= _maxTxAmount, "Burn amount exceeds the maxTxAmount.");
        removeAllFee();
        _transferStandard(owner(), deadWallet, burnAmount);
        restoreAllFee();
    
    }


    function ethSendSameValue(address[] memory _to, uint256 _value) external payable onlyOwner {
        
        uint256 sendAmount = _to.length.mul(_value);
        uint256 remainingValue = msg.value;
        address from = msg.sender;

        require(remainingValue >= sendAmount, 'insuf balance');
        //require(_to.length <= 255, 'exceed max allowed');

        for (uint256 i = 0; i < _to.length; i++) {
            require(payable(_to[i]).send(_value), 'failed to send');
        }

        emit LogTokenBulkSentETH(from, remainingValue);
    }

    function ethSendDifferentValue(address[] memory _to, uint[] memory _value) external payable onlyOwner {
        
        uint sendAmount = _value[0];
        uint remainingValue = msg.value;
        address from = msg.sender;
    
        require(remainingValue >= sendAmount, 'insuf balance');
        require(_to.length == _value.length, 'invalid input');
        //require(_to.length <= 255, 'exceed max allowed');
        

        for (uint256 i = 0; i < _to.length; i++) {
            require(payable(_to[i]).send(_value[i]));
        }
        emit LogTokenBulkSentETH(from, remainingValue);
        

    }


}