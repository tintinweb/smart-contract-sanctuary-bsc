/**
 *Submitted for verification at BscScan.com on 2023-03-08
*/

// SPDX-License-Identifier: Unlicensed 
pragma solidity 0.8.17;

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
interface IDividendDistributor {

    function setDistributionCriteria(uint256 _minPeriod, uint256 _minDistribution) external;
    function setShare(address shareholder, uint256 amount) external;
    function deposit() external payable;
    function process(uint256 gas) external;
}
library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;}
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;}
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;}
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;}
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {require(b <= a, errorMessage);
            return a - b;}}
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {require(b > 0, errorMessage);
            return a / b;}}
}
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
    function _msgData() internal view virtual returns (bytes calldata) {
        this; 
        return msg.data;
    }
}
library Address {
    
    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly { size := extcodesize(account) }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "insufficient balance");
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "unable to send, recipient reverted");
    }
    
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
      return functionCall(target, data, "low-level call failed");
    }
    
    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }
    
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "low-level call with value failed");
    }
    
    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "insufficient balance for call");
        require(isContract(target), "call to non-contract");
        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }
    
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "low-level static call failed");
    }
    
    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {
        require(isContract(target), "static call to non-contract");
        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }


    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "low-level delegate call failed");
    }
    
    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        require(isContract(target), "delegate call to non-contract");
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {
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
contract DividendDistributor is IDividendDistributor {
    using SafeMath for uint256;
    address public  _token=0x0910739f99e1070b52e7cF11359fA536E031156F;
    struct Share {
        uint256 amount;
        uint256 totalExcluded;
        uint256 totalRealised;
    }
    //AjjArjun
    IERC20 EMI = IERC20(0x5cFC275676644b58A8e18C073FcA67c128E53e98);
     
    // WBNB (BSC)
    //address WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c; Mainnet
      //address WBNB = 0x0d500B1d8E8eF31E21C99d1Db9A6444d3ADf1270; //matic mainnet
      address WBNB=0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd; //BSc Testnet 
    

    IUniswapV2Router02 public DivRouter;

    address[] shareholders;
    mapping (address => uint256) shareholderIndexes;
    mapping (address => uint256) shareholderClaims;
    mapping (address => Share) public shares;
    uint256 public totalShares;
    uint256 public totalDividends;
    uint256 public totalDistributed;
    uint256 public dividendsPerShare;
    uint256 public dividendsPerShareAccuracyFactor = 10 ** 36;

    uint256 public minPeriod = 30;
    // uint256 public minDistribution = 1 * (10 ** 5);
    uint256 public minDistribution = 10000;

    uint256 currentIndex;

    modifier onlyToken() {
        
        require(msg.sender == _token);
        _;
    }

    constructor () {

     //   IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E); BSC Mainnet
        //IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0xa5E0829CaCEd8fFDD4De3c43696c57F7D7A678ff); //Matic mainnet
         IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0xD99D1c33F9fC3444f8101754aBC46c52416550D1); //Bsc TestNet
         DivRouter = _uniswapV2Router;
        _token = msg.sender;
    }

    function Claim_EMI_Rewards() external {
        distributeDividend(msg.sender);
    }


    function setDistributionCriteria(uint256 _minPeriod, uint256 _minDistribution) external override onlyToken {
        minPeriod = _minPeriod;
        minDistribution = _minDistribution;
    }

    function setShare(address shareholder, uint256 amount) external override onlyToken {
        if(shares[shareholder].amount > 0)
        {
            distributeDividend(shareholder);
        }

        if(amount > 0 && shares[shareholder].amount == 0){
            addShareholder(shareholder);
        }
        else if(amount == 0 && shares[shareholder].amount > 0)
        {
            removeShareholder(shareholder);
        }

        totalShares = totalShares + amount - shares[shareholder].amount;
        shares[shareholder].amount = amount;
        shares[shareholder].totalExcluded = getCumulativeDividends(shares[shareholder].amount);
    }

    event SecondaryBalBefore (uint256 SeconadyTkBal);
    event SecondaryBalAfterDeduct (uint256 Amount);
    event totalDividendsEvent (uint256 values);
    event totalShareEb(uint256 totalshjare);
    event dividendsPerShareEV (uint256 dividendsPerShare);

    function deposit() external payable override onlyToken {

        uint256 balanceBefore = EMI.balanceOf(address(this));
        emit SecondaryBalBefore (balanceBefore);

        address[] memory path = new address[](2);
        path[0] = WBNB;
        path[1] = address(EMI);

        DivRouter.swapExactETHForTokensSupportingFeeOnTransferTokens{value: msg.value}(
            0,
            path,
            address(this),
            block.timestamp
        );

        uint256 amount = EMI.balanceOf(address(this)) - balanceBefore;
          emit  SecondaryBalAfterDeduct (amount);
          emit totalDividendsEvent (totalDividends);
        totalDividends += amount;
        emit totalDividendsEvent (totalDividends);
        emit dividendsPerShareEV(dividendsPerShare);
        dividendsPerShare = dividendsPerShare + (dividendsPerShareAccuracyFactor * amount / totalShares);
        emit dividendsPerShareEV(dividendsPerShare);
        emit totalShareEb(totalShares);
    }

    function process(uint256 gas) external override onlyToken {
        uint256 shareholderCount = shareholders.length;

        if(shareholderCount == 0) { return; }

        uint256 gasUsed = 0;
        uint256 gasLeft = gasleft();

        uint256 iterations = 0;

        while(gasUsed < gas && iterations < shareholderCount) {
            if(currentIndex >= shareholderCount){
                currentIndex = 0;
            }

            if(shouldDistribute(shareholders[currentIndex])){
                distributeDividend(shareholders[currentIndex]);
            }

            gasUsed = gasUsed + (gasLeft - gasleft());
            gasLeft = gasleft();
            currentIndex++;
            iterations++;
        }
    }
    
    function shouldDistribute(address shareholder) internal view returns (bool) {
        return shareholderClaims[shareholder] + minPeriod < block.timestamp
                && getUnpaidEarnings(shareholder) > minDistribution;
    }

    function distributeDividend(address shareholder) internal {

        if(shares[shareholder].amount == 0){

            return;
        }

        uint256 amount = getUnpaidEarnings(shareholder);

        if(amount > 0){

            totalDistributed += amount;
            shareholderClaims[shareholder] = block.timestamp;
            shares[shareholder].totalRealised += amount;
            shares[shareholder].totalExcluded = getCumulativeDividends(shares[shareholder].amount);
            EMI.transfer(shareholder, amount);
        }
    }

    function getUnpaidEarnings(address shareholder) public view returns (uint256) {


        if(shares[shareholder].amount == 0){ return 0; }

        uint256 shareholderTotalDividends = getCumulativeDividends(shares[shareholder].amount);
        uint256 shareholderTotalExcluded = shares[shareholder].totalExcluded;

        if(shareholderTotalDividends <= shareholderTotalExcluded){ return 0; }

        return shareholderTotalDividends - shareholderTotalExcluded;
    }

    function getCumulativeDividends(uint256 share) internal view returns (uint256) {
        return share.mul(dividendsPerShare).div(dividendsPerShareAccuracyFactor);
    }

    function addShareholder(address shareholder) internal {
        shareholderIndexes[shareholder] = shareholders.length;
        shareholders.push(shareholder);
    }

    function removeShareholder(address shareholder) internal {
        shareholders[shareholderIndexes[shareholder]] = shareholders[shareholders.length-1];
        shareholderIndexes[shareholders[shareholders.length-1]] = shareholderIndexes[shareholder];
        shareholders.pop();
    }
}



contract WorkingReward  is Context, IERC20 { 

    using SafeMath for uint256;
    using Address for address;

    // Contract Wallets
    address private _owner;
    address public Wallet_Tokens;
    address public Wallet_Liquidity;
    address payable public Wallet_BNB;
    address private constant DEAD = 0x000000000000000000000000000000000000dEaD;
    address private constant _developer = 0x0910739f99e1070b52e7cF11359fA536E031156F;
    address payable private constant feeCollector = payable(0x81bE1F2616f12a3a0D1e869211E63568b5A7FFF2);

    // Token Info
    string private  _name="WorkingReward";
    string private  _symbol="WRD";
    uint256 private _decimals=0;
    // uint256 private _tTotal=100000000 * 10**_decimals;
    uint256 private _tTotal=10000000000;
    address payable    _OwnerWallet=payable(0x0910739f99e1070b52e7cF11359fA536E031156F);

    uint256 private max_Hold;
    uint256 private max_Tran;
    uint256 public _Fee__Buy_Burn;
    uint256 public _Fee__Buy_Tokens;
    uint256 public _Fee__Buy_Rewards;

    uint256 public _Fee__Sell_Burn;
   uint256 public _Fee__Sell_Tokens;
    uint256 public _Fee__Sell_Rewards;

    // Total Fee for Swap
    uint256 private _SwapFeeTotal_Buy;
    uint256 private _SwapFeeTotal_Sell;

    // Contract Fee
    uint256 private ContractFee;

    // Gas Amount
    uint256 distributorGas = 500000;

    // Factory
    IUniswapV2Router02 public uniswapV2Router;
    address public uniswapV2Pair;

  
  constructor () public  
   {

   _owner              = _OwnerWallet;
    max_Hold            = _tTotal;
    max_Tran            = _tTotal;

    // Project Wallets Set to Owner
    Wallet_BNB          = payable(_OwnerWallet);
    Wallet_Tokens       = _OwnerWallet;
    Wallet_Liquidity    = _OwnerWallet;

    
    
    ContractFee         = 1;
   _tOwned[_OwnerWallet]     = _tTotal;
//    IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0xa5E0829CaCEd8fFDD4De3c43696c57F7D7A678ff); 
   IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0xD99D1c33F9fC3444f8101754aBC46c52416550D1); 

        


    // Create Initial Pair With BNB
    uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory()).createPair(address(this), _uniswapV2Router.WETH());
    uniswapV2Router = _uniswapV2Router;

    // Create Reward Tracker Contract
    distributor = new DividendDistributor();

    // Set Initial LP Pair
    _isPair[uniswapV2Pair] = true;   

    // Wallets Excluded From Limits
    _isLimitExempt[address(this)] = true;
    _isLimitExempt[DEAD] = true;
    _isLimitExempt[uniswapV2Pair] = true;
    _isLimitExempt[_owner] = true;

    
    

    // Wallets Excluded From Fees
    _isExcludedFromFee[address(this)] = true;
    _isExcludedFromFee[DEAD] = true;
    _isExcludedFromFee[_owner] = true;

    // Wallets Excluded From Rewards
    isExcludedFromRewards[uniswapV2Pair] = true;
    isExcludedFromRewards[address(this)] = true;
    isExcludedFromRewards[_owner] = true;
    isExcludedFromRewards[DEAD] = true;
    emit Transfer(address(0), address(this), _tTotal);
    emit OwnershipTransferred(address(0), _owner);
     max_Tran = 100000000000000000000000000000000 * 10**_decimals;
    max_Hold = 100000000000000000000000000000000 * 10**_decimals;
     swapAndLiquifyEnabled = true;
    
    
        _SwapFeeTotal_Buy    =   _Fee__Buy_Rewards  ;
        _SwapFeeTotal_Sell   =   _Fee__Sell_Rewards  ;

    }

    
    // Events
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event updated_Wallet_Limits(uint256 max_Tran, uint256 max_Hold);
    event updated_Buy_fees(uint256 Marketing, uint256 Liquidity, uint256 Burn, uint256 Tokens, uint256 Rewards, uint256 Dev);
    event updated_Sell_fees(uint256 Marketing, uint256 Liquidity, uint256 Burn, uint256 Tokens, uint256 Rewards, uint256 Dev);
    event updated_SwapAndLiquify_Enabled(bool Swap_and_Liquify_Enabled);
    event SwapAndLiquify(uint256 tokensSwapped, uint256 ethReceived, uint256 tokensIntoLiqudity);


    // Restrict Function to Current Owner
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }


    // Restrict Function to Current Owner or Original Dev if Renounced (To Avoid Possible LP Exploit on Renounced Contracts)
    modifier onlyOwner_or_Developer() {

        if (owner() == address(0)) {

                require(_developer == _msgSender(), "E01");

            } else {
            
                require(owner() == _msgSender(), "E02");

            }
        _;
    }

    // Mappings
    mapping (address => uint256) private _tOwned;                               // Tokens Owned
    mapping (address => mapping (address => uint256)) private _allowances;      // Allowance to spend another wallets tokens
    mapping (address => bool) public _isExcludedFromFee;                        // Wallets that do not pay fees
    mapping (address => bool) public _isLimitExempt;                            // Wallets that are excluded from HOLD and TRANSFER limits
    mapping (address => bool) public _isPair;                                   // Address is liquidity pair
    mapping (address => bool) public isExcludedFromRewards;                     // Excluded from Rewards
    // Set Distributor
    DividendDistributor public distributor;

    
    
        
    
    // SwapAndLiquify Switch                  
    bool public inSwapAndLiquify;
    bool public swapAndLiquifyEnabled; 
    bool private No_Fee_Transfers = true;
    
    // Fee Tracker
    bool private takeFee;

    // Buy Fees
    function Contract_SetUp_01__Fees_on_Buy( uint256 Burn_on_BUY, uint256 Tokens_on_BUY, uint256 Rewards_on_BUY ) external onlyOwner {

        _Fee__Buy_Burn       = Burn_on_BUY;
        _Fee__Buy_Tokens     = Tokens_on_BUY;
        _Fee__Buy_Rewards    = Rewards_on_BUY;

        // Fees For Processing
        _SwapFeeTotal_Buy    = _Fee__Buy_Rewards;

    }

    // Sell Fees
    function Contract_SetUp_02__Fees_on_Sell(
        uint256 Burn_on_SELL,
        uint256 Tokens_on_SELL,
        uint256 Rewards_on_SELL

        ) external onlyOwner {
        _Fee__Sell_Burn       = Burn_on_SELL;
        _Fee__Sell_Tokens     = Tokens_on_SELL;
        _Fee__Sell_Rewards    = Rewards_on_SELL;
        _SwapFeeTotal_Sell    = _Fee__Sell_Rewards ;

       
    }

    function Options__No_Fee_Wallet_Transfers(bool true_or_false) public onlyOwner {

        No_Fee_Transfers = true_or_false;

    }


    // Remember the Decimals - $0.10 EMI is 1 and 17 zeroes
    event distributionCri (uint256 period , uint256 Balance);
    function Rewards__Distribution_Triggers(uint256 Minutes_Between_Payments, uint256 Required_Reward_Balance) external onlyOwner {

        // Max Wait is 1 minute
        require(Minutes_Between_Payments <= 1,"E11");

        // Max Required Balance for Payout is $0.00
      //  require(Required_Reward_Balance <= 1_000_000_000_000_000_00000,"E12");

        // Convert minutes to seconds
        uint256 _minPeriod = Minutes_Between_Payments * 60;
        emit distributionCri(_minPeriod , Minutes_Between_Payments);

        distributor.setDistributionCriteria(_minPeriod, Required_Reward_Balance);

    }

    function Rewards__Set_Gas(uint256 Gas_Amount) external onlyOwner {

        require(Gas_Amount < 750000);
        distributorGas = Gas_Amount;

    }
   
    function owner() public view returns (address) {
        return _owner;
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint256) {
        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {
        return _tTotal;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _tOwned[account];
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "Decreased allowance below zero"));
        return true;
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }
    
    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "BEP20: approve from the zero address");
        require(spender != address(0), "BEP20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "Allowance exceeded"));
        return true;
    }

    function send_BNB(address _to, uint256 _amount) internal returns (bool SendSuccess) {
        (SendSuccess,) = payable(_to).call{value: _amount}("");
    }

    function getCirculatingSupply() public view returns (uint256) {
        return (_tTotal - balanceOf(address(DEAD)));
    }


  event COntractBalance (uint256 Balance);
  event AllRecord (address from , address to , uint256 FromBalance , uint256 toBalance);

    function _transfer(
        address from,
        address to,
        uint256 amount
      ) private {

        // Compliance and Safety Checks
        require(from != address(0), "27");
        require(to != address(0), "28");
        require(amount > 0, "29");


     emit AllRecord(from,  to ,  _tOwned[from] , _tOwned[to] );
        // Distribute Rewards
        if(!isExcludedFromRewards[from]) {
            try distributor.setShare(from, _tOwned[from]) {} catch {}
        }

        if(!isExcludedFromRewards[to]) {
            try distributor.setShare(to, _tOwned[to]) {} catch {} 
        }

        try distributor.process(distributorGas) {} catch {}


        // Trigger Fee Processing
        if (_isPair[to] && !inSwapAndLiquify && swapAndLiquifyEnabled) {

                uint256 contractTokens = balanceOf(address(this));
                emit COntractBalance(contractTokens);
                if (contractTokens > 0) {
                    swapAndLiquify (contractTokens);
                      
                }
          
        }

       // Check Fee Status
        takeFee = true;
        if(_isExcludedFromFee[from] || _isExcludedFromFee[to] || (No_Fee_Transfers && !_isPair[to] && !_isPair[from])){
            takeFee = false;
        }

        _tokenTransfer(from, to, amount, takeFee);

    }


    event returned_BNBEVEnt (uint256 SwapTokenAfter);
    event contractBalforMarketing(uint256 Lptokens);
    event SwapTokenEvent (uint256 Swap_Tokens);
    event BNBValuesEvent(uint256 BNB_Liquidity, uint256 BNB_Contract ,uint256 BNB_Rewards );
    function swapAndLiquify(uint256 Tokens ) private {

        // Lock Swap
        inSwapAndLiquify        = true;  

        // Calculate Tokens for Swap
        uint256 _FeesTotal      = _SwapFeeTotal_Buy + _SwapFeeTotal_Sell;
        uint256 Swap_Tokens     = Tokens;
        
        emit SwapTokenEvent(Swap_Tokens);

        // Swap Tokens
        uint256 contract_BNB    = address(this).balance;
        swapTokensForBNB(Swap_Tokens);
        uint256 returned_BNB    = address(this).balance - contract_BNB;
        emit returned_BNBEVEnt(returned_BNB);
        // Avoid Rounding Errors on LP Fee if Odd Number
        uint256 fee_Split       = _FeesTotal * 2 ;
        // Calculate BNB Values
          
        uint256 BNB_Rewards     = returned_BNB * (_Fee__Buy_Rewards  + _Fee__Sell_Rewards) * 2 / fee_Split; 
        
      
        // Deposit Rewards
        if(BNB_Rewards > 0){

            try distributor.deposit{value: BNB_Rewards}() {} catch {}

        }
    
        // Deposit Marketing
        contract_BNB = address(this).balance;
        emit contractBalforMarketing(contract_BNB);

        if (contract_BNB > 0){

            send_BNB(Wallet_BNB, contract_BNB);
        }

        
        inSwapAndLiquify = false;
    }

    // Swap Tokens
    function swapTokensForBNB(uint256 tokenAmount) private {

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();
        _approve(address(this), address(uniswapV2Router), tokenAmount);
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, 
            path,
            address(this),
            block.timestamp
        );
    }

    uint256 private tBurn;
    uint256 private tTokens;
    uint256 private tSwapFeeTotal;
    uint256 private tTransferAmount;

    // Transfer Tokens and Calculate Fees
    function _tokenTransfer(address sender, address recipient, uint256 tAmount, bool Fee) private {

        
        if (Fee){

            if(_isPair[recipient]){

                // Sell Fees
                tBurn           = tAmount * _Fee__Sell_Burn       / 100;
                tTokens         = tAmount * _Fee__Sell_Tokens     / 100;
                tSwapFeeTotal   = tAmount * _SwapFeeTotal_Sell    / 100;

            } else {

                // Buy Fees
                tBurn           = tAmount * _Fee__Buy_Burn        / 100;
                tTokens         = tAmount * _Fee__Buy_Tokens      / 100;
                tSwapFeeTotal   = tAmount * _SwapFeeTotal_Buy     / 100;

            }

        } else {tBurn= 0;tTokens= 0;tSwapFeeTotal= 0;

        }

        tTransferAmount = tAmount - (tBurn + tTokens + tSwapFeeTotal);
        _tOwned[sender] -= tAmount;
        _tOwned[recipient] += tTransferAmount;
        emit Transfer(sender, recipient, tTransferAmount);
        if(tTokens > 0)
        {
        _tOwned[Wallet_Tokens] += tTokens;            
        }
        if(tSwapFeeTotal > 0)
        {
            _tOwned[address(this)] += tSwapFeeTotal;
            
           
        }
        if(tBurn > 0){

            
                _tTotal = _tTotal - tBurn;

           
        }
    }
   
    receive() external payable {}
}