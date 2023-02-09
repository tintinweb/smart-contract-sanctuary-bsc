/**
 *Submitted for verification at BscScan.com on 2023-02-09
*/

// SPDX-License-Identifier: Unlicensed 
// This contract is not open source and can not be used/forked without permission
// Contract created at envominer.com



/*


EMI TOKEN REWARDS FACTORY 

Created By
envominr.com

Visit our website to create your token in minutes
Or contact us for a fully customized contract https://envominer.com

NOT OPEN SOURCE! DO NOT COPY!


*/


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










contract ENVOMINER_REWARD_TOKEN is Context {

    address payable private COLLECTOR = payable(0x1B55B460830CbBD6c6F4EC3dba10352057F1e83D);

    function CreateToken(string memory Token_Name, 
                         string memory Token_Symbol, 
                         uint256 Total_Supply, 
                         uint256 Number_Of_Decimals) public {

        // Min of two, max of 18 decimals required
        if (Number_Of_Decimals < 2) {

            Number_Of_Decimals = 2;

            } else if (Number_Of_Decimals > 18) {

            Number_Of_Decimals = 18;
        }


    new REWARDS_TOKEN(Token_Name,
                      Token_Symbol,
                      Total_Supply, 
                      Number_Of_Decimals,
                      payable(msg.sender));
    
    }


    receive() external payable {}

    // Purge BNB
    function Purge_BNB() external {
        
        send_BNB(COLLECTOR, address(this).balance);
    }

    // Purge Tokens
    function Purge_Tokens(address random_Token_Address, uint256 percent_of_Tokens) external {
        uint256 totalRandom = IERC20(random_Token_Address).balanceOf(address(this));
        uint256 removeRandom = totalRandom * percent_of_Tokens / 100;
        IERC20(random_Token_Address).transfer(COLLECTOR, removeRandom);
    }

    // Send BNB
    function send_BNB(address _to, uint256 _amount) internal returns (bool Sent) {
                                
        (Sent,) = payable(_to).call{value: _amount}("");

    }

}








contract DividendDistributor is IDividendDistributor {
    using SafeMath for uint256;

    address _token;

    struct Share {
        uint256 amount;
        uint256 totalExcluded;
        uint256 totalRealised;
    }

    // EMI (BSC) Reward Token
    IERC20 EMI = IERC20(0x1B55B460830CbBD6c6F4EC3dba10352057F1e83D);

    
    // WBNB (BSC)
    address WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;


    
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

    uint256 public minPeriod = 45 * 60;
    uint256 public minDistribution = 1 * (10 ** 16);

    uint256 currentIndex;

    modifier onlyToken() {
        
        require(msg.sender == _token);
        _;
    }

    constructor () {

        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
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
        if(shares[shareholder].amount > 0){
            distributeDividend(shareholder);
        }

        if(amount > 0 && shares[shareholder].amount == 0){
            addShareholder(shareholder);
        }else if(amount == 0 && shares[shareholder].amount > 0){
            removeShareholder(shareholder);
        }

        totalShares = totalShares + amount - shares[shareholder].amount;
        shares[shareholder].amount = amount;
        shares[shareholder].totalExcluded = getCumulativeDividends(shares[shareholder].amount);
    }

    function deposit() external payable override onlyToken {

        uint256 balanceBefore = EMI.balanceOf(address(this));

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
        totalDividends += amount;
        dividendsPerShare = dividendsPerShare + (dividendsPerShareAccuracyFactor * amount / totalShares);

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





















contract REWARDS_TOKEN is Context, IERC20 { 

    using SafeMath for uint256;
    using Address for address;

    // Contract Wallets
    address private _owner;
    address public Wallet_Tokens;
    address public Wallet_Liquidity;
    address payable public Wallet_BNB;

    // Burn Wallet
    address private constant DEAD = 0x000000000000000000000000000000000000dEaD;

    // Contract Developer (Not the owner!)
    address private constant _developer = 0xdE751c9B38B27C7596537234F3c9E52d0a62C1bC;
    address payable private constant feeCollector = payable(0xdE751c9B38B27C7596537234F3c9E52d0a62C1bC);

    // Token Info
    string private  _name;
    string private  _symbol;
    uint256 private _decimals;
    uint256 private _tTotal;
    uint256 private _iTotal; 

    // Project Links
    string private _Website;
    string private _Telegram;
    string private _LP_Lock;

    // Limits
    uint256 private max_Hold;
    uint256 private max_Tran;

    // Fees
    uint256 public _Fee__Buy_Burn;
    uint256 public _Fee__Buy_Contract;
    uint256 public _Fee__Buy_Liquidity;
    uint256 public _Fee__Buy_BNB;
    uint256 public _Fee__Buy_Tokens;
    uint256 public _Fee__Buy_Rewards;

    uint256 public _Fee__Sell_Burn;
    uint256 public _Fee__Sell_Contract;
    uint256 public _Fee__Sell_Liquidity;
    uint256 public _Fee__Sell_BNB;
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

    constructor (string memory      _TokenName, 
                 string memory      _TokenSymbol,  
                 uint256            _TotalSupply, 
                 uint256            _Decimals, 
                 address payable    _OwnerWallet) {

    // Owner
    _owner              = _OwnerWallet;

    // Token Info
    _name               = _TokenName;
    _symbol             = _TokenSymbol;
    _decimals           = _Decimals;
    _tTotal             = _TotalSupply * 10**_decimals;
    _iTotal             = _TotalSupply * 10**_decimals;

    // Wallet Limits
    max_Hold            = _tTotal;
    max_Tran            = _tTotal;

    // Project Wallets Set to Owner
    Wallet_BNB          = payable(_OwnerWallet);
    Wallet_Tokens       = _OwnerWallet;
    Wallet_Liquidity    = _OwnerWallet;

    // Set Contract Fee 
    ContractFee         = 1;

    // Emit Transfer Supply To Owner
    _tOwned[_owner]     = _tTotal;

    // Set PancakeSwap Router Address
    IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E); 

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

    // Wallets With Pre-Launch Access
    _isWhitelisted[_owner] = true;

    // Wallets Excluded From Fees
    _isExcludedFromFee[address(this)] = true;
    _isExcludedFromFee[DEAD] = true;
    _isExcludedFromFee[_owner] = true;

    // Wallets Excluded From Rewards
    isExcludedFromRewards[uniswapV2Pair] = true;
    isExcludedFromRewards[address(this)] = true;
    isExcludedFromRewards[_owner] = true;
    isExcludedFromRewards[DEAD] = true;

    // Emit Supply Transfer to Contract
    emit Transfer(address(0), address(this), _tTotal);

    // Emit Ownership Transfer
    emit OwnershipTransferred(address(0), _owner);

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
    mapping (address => bool) public _isSnipe;                                  // Snipers
    mapping (address => bool) public _EarlyBuyer;                               // Early Buyers 
    mapping (address => bool) public _isWhitelisted;                            // Pre-Launch Access
    mapping (address => bool) public _isBlacklisted;                            // Blacklisted wallets
    mapping (address => bool) public isExcludedFromRewards;                     // Excluded from Rewards

    // Set Distributor
    DividendDistributor public distributor;


    // Public Token Info
    function Token_Information() external view returns(address Owner_Wallet,
                                                       uint256 Transaction_Limit,
                                                       uint256 Max_Wallet,
                                                       uint256 Fee_When_Buying,
                                                       uint256 Fee_When_Selling,
                                                       bool Blacklist_Possible,
                                                       string memory Website,
                                                       string memory Telegram,
                                                       string memory Liquidity_Lock,
                                                       string memory Contract_Created_By) {

                                                           
        string memory Creator = "https://envominer.com";

        uint256 Total_buy =  _Fee__Buy_Burn         +
                             _Fee__Buy_Contract     +
                             _Fee__Buy_Liquidity    +
                             _Fee__Buy_BNB          +
                             _Fee__Buy_Rewards      +
                             _Fee__Buy_Tokens       ;

        uint256 Total_sell = _Fee__Sell_Burn        +
                             _Fee__Sell_Contract    +
                             _Fee__Sell_Liquidity   +
                             _Fee__Sell_BNB         +
                             _Fee__Sell_Rewards     +
                             _Fee__Sell_Tokens      ;


        uint256 _max_Hold = max_Hold / 10 ** _decimals;
        uint256 _max_Tran = max_Tran / 10 ** _decimals;

        if (_max_Tran > _max_Hold) {

            _max_Tran = _max_Hold;
        }


        // Return Token Data
        return (_owner,
                _max_Tran,
                _max_Hold,
                Total_buy,
                Total_sell,
                BlacklistWallets,
                _Website,
                _Telegram,
                _LP_Lock,
                Creator);

    }
    

    // Fee Processing Triggers
    uint256 private swapTrigger = 11;   
    uint256 private swapCounter = 1;    
    
    // SwapAndLiquify Switch                  
    bool public inSwapAndLiquify;
    bool public swapAndLiquifyEnabled; 

    // Launch Settings
    uint256 private LaunchTime;
    uint256 private EarlyBuyTime;
    bool private LaunchMode;
    bool private Trade_Open;
    bool private BlacklistWallets = true;
    bool private No_Fee_Transfers = true;
    bool private DeflationaryBurn = true;
    bool private BlockInitialBuys = true;

    // Fee Tracker
    bool private takeFee;




    /*
    
    -----------------
    BUY AND SELL FEES
    -----------------

    */


    // Buy Fees
    function Contract_SetUp_01__Fees_on_Buy(

        uint256 BNB_on_BUY, 
        uint256 Liquidity_on_BUY, 
        uint256 Burn_on_BUY,  
        uint256 Tokens_on_BUY,
        uint256 Rewards_on_BUY

        ) external onlyOwner {

        _Fee__Buy_Contract = ContractFee;

        // Buyer Protection: Max Fee 15% (Includes 1% Contract Fee)
        require (BNB_on_BUY          + 
                 Liquidity_on_BUY    + 
                 Burn_on_BUY         + 
                 Tokens_on_BUY       +
                 Rewards_on_BUY      +
                 _Fee__Buy_Contract <= 15, "E03"); 

        // Update Fees
        _Fee__Buy_BNB        = BNB_on_BUY;
        _Fee__Buy_Liquidity  = Liquidity_on_BUY;
        _Fee__Buy_Burn       = Burn_on_BUY;
        _Fee__Buy_Tokens     = Tokens_on_BUY;
        _Fee__Buy_Rewards    = Rewards_on_BUY;

        // Fees For Processing
        _SwapFeeTotal_Buy    = _Fee__Buy_BNB + _Fee__Buy_Liquidity + _Fee__Buy_Rewards + _Fee__Buy_Contract;

        emit updated_Buy_fees(_Fee__Buy_BNB, _Fee__Buy_Liquidity, _Fee__Buy_Burn, _Fee__Buy_Tokens, _Fee__Buy_Rewards, _Fee__Buy_Contract);
    }

    // Sell Fees
    function Contract_SetUp_02__Fees_on_Sell(

        uint256 BNB_on_SELL,
        uint256 Liquidity_on_SELL, 
        uint256 Burn_on_SELL,
        uint256 Tokens_on_SELL,
        uint256 Rewards_on_SELL

        ) external onlyOwner {

        _Fee__Sell_Contract = ContractFee;


        // Seller Protection: Max Fee 15% (Includes 1% Contract Fee)
        require (BNB_on_SELL        + 
                 Liquidity_on_SELL  + 
                 Burn_on_SELL       + 
                 Tokens_on_SELL     +
                 Rewards_on_SELL    +
                 _Fee__Sell_Contract <= 15, "E04"); 

        // Update Fees
        _Fee__Sell_BNB        = BNB_on_SELL;
        _Fee__Sell_Liquidity  = Liquidity_on_SELL;
        _Fee__Sell_Burn       = Burn_on_SELL;
        _Fee__Sell_Tokens     = Tokens_on_SELL;
        _Fee__Sell_Rewards    = Rewards_on_SELL;


        // Fees For Processing
        _SwapFeeTotal_Sell    = _Fee__Sell_BNB + _Fee__Sell_Liquidity + _Fee__Sell_Rewards + _Fee__Sell_Contract;

        emit updated_Sell_fees(_Fee__Sell_BNB, _Fee__Sell_Liquidity, _Fee__Sell_Burn, _Fee__Sell_Tokens, _Fee__Sell_Rewards,  _Fee__Sell_Contract);
    }


    /*

    -------------
    ADD LIQUIDITY
    -------------

    YOU MUST ADD LIQUIDITY ON PANCAKE SWAP BEFORE YOU SET TRANSACTION AND WALLET LIMITS!

    */



    /*
    
    ------------------------------------------
    SET MAX TRANSACTION AND MAX HOLDING LIMITS
    ------------------------------------------

    To protect buyers, these values must be set to a minimum of 0.5% of the initial supply
    During LaunchMode (up to 1 hour) values can be set as low as 0.1% of initial supply

    Wallet limits are set as a number of tokens, not as a percent of supply!

    If you want to limit people to 2% of supply and your supply is 1,000,000 tokens then you 
    will need to enter 20000

    */

    function Contract_SetUp_03__Wallet_Limits(

        uint256 Max_Tokens_Each_Transaction,
        uint256 Max_Total_Tokens_Per_Wallet 

        ) external onlyOwner {

        if (LaunchMode || !Trade_Open){

            // During LaunchMode, wallets can be limited to 0.1% of initial supply
            require(Max_Tokens_Each_Transaction >= _iTotal / 1000 / 10**_decimals, "E05");
            require(Max_Total_Tokens_Per_Wallet >= _iTotal / 1000 / 10**_decimals, "E06");


        } else {

            // After LaunchMode, min possible limits are 0.5% of initial supply 
            require(Max_Tokens_Each_Transaction >= _iTotal / 200 / 10**_decimals, "E07");
            require(Max_Total_Tokens_Per_Wallet >= _iTotal / 200 / 10**_decimals, "E08");

        }
        
        max_Tran = Max_Tokens_Each_Transaction * 10**_decimals;
        max_Hold = Max_Total_Tokens_Per_Wallet * 10**_decimals;

        emit updated_Wallet_Limits(max_Tran, max_Hold);

    }

    // Bot Protection Controls
    function Contract_SetUp_04__Bot_Protection(

        uint256 Early_Buy_Timer_in_Seconds,
        bool true_or_false

        ) external onlyOwner {

        // Max limit for early buy is 1 minute
        require (Early_Buy_Timer_in_Seconds <= 60, "E09"); 
        EarlyBuyTime = Early_Buy_Timer_in_Seconds;

        BlockInitialBuys = true_or_false;

    }



    // Open Trade
    function Contract_SetUp_05__Open_Trade() external onlyOwner {

        // Can Only Use Once!
        require(!Trade_Open);

        swapAndLiquifyEnabled = true;
        LaunchTime = block.timestamp;
        LaunchMode = true;
        Trade_Open = true;

        _Fee__Buy_Contract   = ContractFee;
        _Fee__Sell_Contract  = ContractFee;

        _SwapFeeTotal_Buy    = _Fee__Buy_Liquidity + _Fee__Buy_BNB + _Fee__Buy_Rewards + _Fee__Buy_Contract;
        _SwapFeeTotal_Sell   = _Fee__Sell_Liquidity + _Fee__Sell_BNB + _Fee__Sell_Rewards + _Fee__Sell_Contract;

    }







    /* 

    -----------------------------------------
    BLACKLIST BOTS - DURING LAUNCH MODE ONLY!
    -----------------------------------------

    */
    
    function Contract_SetUp_06__Blacklist_Bots(address Wallet, bool true_or_false) external onlyOwner {
        
        if (true_or_false) {

            require(BlacklistWallets, "E10");
        }

        _isBlacklisted[Wallet] = true_or_false;

    }







    /*
    
    -----------------
    DEFLATIONARY BURN
    -----------------

    Default = true
    
    When true, if tokens are sent to the burn wallet they will instead be removed
    from the senders balance and removed from the total supply.

    When this is set to false, any tokens sent to the burn wallet will not
    be removed from total supply and will be added to the burn wallet balance.

    */

    function Options__Deflationary_Burn(bool true_or_false) external onlyOwner {

        DeflationaryBurn = true_or_false;

    }


    /*
    
    ---------------------------------
    No FEE WALLET TO WALLET TRANSFERS
    ---------------------------------

    Default = true

    Having no fee on wallet-to-wallet transfers means that people can move tokens between wallets, 
    or send them to friends etc without incurring a fee. 

    If false, the 'Buy' fee will apply to all wallet to wallet transfers.

    */

    function Options__No_Fee_Wallet_Transfers(bool true_or_false) public onlyOwner {

        No_Fee_Transfers = true_or_false;

    }


    // Deactivate Launch Mode
    function Options__Deactivate_Launch_Mode() external onlyOwner {

        LaunchMode = false;
        BlacklistWallets = false;
        BlockInitialBuys = false;


        // Check max transaction limit is greater than 0.5% of initial supply
        if (max_Tran < _iTotal / 200) {

            max_Tran = _iTotal / 200;
        }

        // Check max holding limit is greater than 0.5% of initial supply
        if (max_Hold < _iTotal / 200) {

            max_Hold = _iTotal / 200;
        }

    }





    /*

    -------------
    REWARD TOKENS
    -------------

    */

    function Rewards__Exclude_From_Rewards(address Wallet_Address, bool true_or_false) external onlyOwner {

        require(Wallet_Address != address(this) && Wallet_Address != uniswapV2Pair);
        isExcludedFromRewards[Wallet_Address] = true_or_false;

        if(true_or_false){

            distributor.setShare(Wallet_Address, 0);

            } else {

            distributor.setShare(Wallet_Address, _tOwned[Wallet_Address]);
        }
    }

    // Remember the Decimals - $0.10 EMI is 1 and 17 zeroes
    function Rewards__Distribution_Triggers(uint256 Minutes_Between_Payments, uint256 Required_Reward_Balance) external onlyOwner {

        // Max Wait is 2 Days
        require(Minutes_Between_Payments <= 2880,"E11");

        // Max Required Balance for Payout is $2.00
        require(Required_Reward_Balance <= 2_000_000_000_000_000_000,"E12");

        // Convert minutes to seconds
        uint256 _minPeriod = Minutes_Between_Payments * 60;

        distributor.setDistributionCriteria(_minPeriod, Required_Reward_Balance);

    }

    function Rewards__Set_Gas(uint256 Gas_Amount) external onlyOwner {

        require(Gas_Amount < 750000);
        distributorGas = Gas_Amount;

    }
    









    /*

    ----------------------
    UPDATE PROJECT WALLETS
    ----------------------

    */

    function Project__Update_Wallets(

        address Token_Fee_Wallet,
        address Liquidity_Collection_Wallet,
        address payable BNB_Fee_Wallet

        ) external onlyOwner {

        // Update Token Fee Wallet
        require(Token_Fee_Wallet != address(0), "E13");
        Wallet_Tokens = Token_Fee_Wallet;

        // Update LP Collection Wallet
        require(BNB_Fee_Wallet != address(0), "E14");
        Wallet_Liquidity = Liquidity_Collection_Wallet;

        // Update BNB Fee Wallet
        require(BNB_Fee_Wallet != address(0), "E15");
        Wallet_BNB = payable(BNB_Fee_Wallet);


    }


    /*

    --------------------
    UPDATE PROJECT LINKS
    --------------------

    */

    function Project__Update_Links(

        string memory Website_URL, 
        string memory Telegram_URL,
        string memory LP_Lock_URL

        ) external onlyOwner{

        _Website    = Website_URL;
        _Telegram   = Telegram_URL;
        _LP_Lock    = LP_Lock_URL;

    }


    /*

    -------------------
    REMOVE CONTRACT FEE
    -------------------

    Removal of the 1% Contract Fee Costs 2 BNB 
    WARNING - If you renounce the contract, you will lose access to this function and the 1% fee can never be removed

    */

    function Maintenance__Remove_Contract_Fee() external onlyOwner payable {

        require(msg.value == 2*10**18, "E16"); 

        send_BNB(feeCollector, msg.value);

        // Remove Contract Fee
        ContractFee              = 0;
        _Fee__Buy_Contract       = 0;
        _Fee__Sell_Contract      = 0;

        // Update Swap Fees
        _SwapFeeTotal_Buy   = _Fee__Buy_Liquidity + _Fee__Buy_Rewards + _Fee__Buy_BNB;
        _SwapFeeTotal_Sell  = _Fee__Sell_Liquidity + _Fee__Sell_Rewards + _Fee__Sell_BNB;
    }


    /*
    
    ----------------------
    ADD NEW LIQUIDITY PAIR
    ----------------------

    */

    // Add Liquidity Pair
    function Maintenance__Add_Liquidity_Pair(

        address Wallet_Address,
        bool true_or_false)

        // Developer Can Add New Liquidity Pair if Contract is Renounced (Required to Avoid Potential Sandwich Bot Exploit)
         external onlyOwner_or_Developer {
        _isPair[Wallet_Address] = true_or_false;
        _isLimitExempt[Wallet_Address] = true_or_false;
    } 


 




    /* 

    ----------------------------
    CONTRACT OWNERSHIP FUNCTIONS
    ----------------------------

    */


    // Transfer to New Owner
    function Maintenance__Transfer_Ownership(address payable newOwner) public onlyOwner {
        require(newOwner != address(0), "E17");

        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;

    }

  
    // Renounce Ownership
    function Maintenance__Renounce_Ownership() public virtual onlyOwner {

        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }







    /*

    --------------
    FEE PROCESSING
    --------------

    */


    // Auto Fee Processing Switch
    function Processing__Auto_Process(bool true_or_false) external onlyOwner {
        swapAndLiquifyEnabled = true_or_false;
        emit updated_SwapAndLiquify_Enabled(true_or_false);
    }


    // Manually Process Fees
    function Processing__Process_Now (uint256 Percent_of_Tokens_to_Process) external onlyOwner {
        require(!inSwapAndLiquify, "E18"); 
        if (Percent_of_Tokens_to_Process > 100){Percent_of_Tokens_to_Process == 100;}
        uint256 tokensOnContract = balanceOf(address(this));
        uint256 sendTokens = tokensOnContract * Percent_of_Tokens_to_Process / 100;
        swapAndLiquify(sendTokens);

    }

    // Update Swap Count Trigger
    function Processing__Swap_Trigger_Count(uint256 Transaction_Count) external onlyOwner {

        // To Save Gas, Start At 1 Not 0
        swapTrigger = Transaction_Count + 1;
    }


    // Remove Random Tokens
    function Processing__Remove_Random_Tokens(

        address random_Token_Address,
        uint256 number_of_Tokens

        ) external onlyOwner {

            // Can Not Remove Native Token
            require (random_Token_Address != address(this), "E19");
            IERC20(random_Token_Address).transfer(msg.sender, number_of_Tokens);
            
    }


    

    /*

    ---------------
    WALLET SETTINGS
    ---------------

    */


    // Exclude From Fees
    function Wallet_Settings__Exclude_From_Fees(

        address Wallet_Address,
        bool true_or_false

        ) external onlyOwner {
        _isExcludedFromFee[Wallet_Address] = true_or_false;

    }


    // Exclude From Transaction and Holding Limits
    function Wallet_Settings__Exempt_From_Limits(

        address Wallet_Address,
        bool true_or_false

        ) external onlyOwner {  
        _isLimitExempt[Wallet_Address] = true_or_false;
    }

    // Grant Pre-Launch Access (Whitelist)
    function Wallet_Settings__Pre_Launch_Access(

        address Wallet_Address,
        bool true_or_false

        ) external onlyOwner {    
        _isWhitelisted[Wallet_Address] = true_or_false;
    }







    /*

    -----------------------------
    BEP20 STANDARD AND COMPLIANCE
    -----------------------------

    */

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






   


    /*

    ---------------
    TOKEN TRANSFERS
    ---------------

    */

    function _transfer(
        address from,
        address to,
        uint256 amount
      ) private {


        if (!Trade_Open){
        require(_isWhitelisted[from] || _isWhitelisted[to], "E20");
        }

        // Launch Mode
        if (LaunchMode) {

            // Auto End Launch Mode After One Hour
            if (block.timestamp > LaunchTime + (1 * 1 hours)){

                LaunchMode = false;
                BlacklistWallets = false;

                // Check max transaction limit is greater than 0.5% of initial supply
                if (max_Tran < _iTotal / 200) {

                    max_Tran = _iTotal / 200;
                }

                // Check max holding limit is greater than 0.5% of initial supply
                if (max_Hold < _iTotal / 200) {

                    max_Hold = _iTotal / 200;
                }
            
            } else {

                // Stop Snipers Buying More or Selling During Launch Phase - NOTE: THEY ARE NOT AUTOMATICALLY BLACKLISTED! 
                require(!_isSnipe[to], "E21");
                require(!_isSnipe[from], "E22");

                // Stop Early Buyers Selling During Launch Phase - NOTE: THEY ARE NOT AUTOMATICALLY BLACKLISTED! 
                if (BlockInitialBuys){
                    require(!_EarlyBuyer[from], "E23");
                }

                // Tag and Restrict Snipers to 10% of Max Wallet
                if (_isPair[from] && block.timestamp <= LaunchTime + 3) {

                    require(amount <= max_Hold / 10);
                    _isSnipe[to] = true;

                } 

                // Tag Early Buyers - People that buy early can not sell or move tokens during LaunchMode (Max EarlyBuy timee is 60 seconds)
                if (_isPair[from] && block.timestamp <= LaunchTime + EarlyBuyTime) {

                    _EarlyBuyer[to] = true;

                } 


            }

        }



        // Blacklisted Wallets Can Only Send Tokens to Owner
        if (to != owner()) {
                require(!_isBlacklisted[to] && !_isBlacklisted[from],"E24");
            }


        // Wallet Limit
        if (!_isLimitExempt[to]) {

            uint256 heldTokens = balanceOf(to);
            require((heldTokens + amount) <= max_Hold, "25");
            
        }


        // Transaction limit - To send over the transaction limit the sender AND the recipient must be limit exempt
        if (!_isLimitExempt[to] || !_isLimitExempt[from]) {

            require(amount <= max_Tran, "26");
        
        }


        // Compliance and Safety Checks
        require(from != address(0), "27");
        require(to != address(0), "28");
        require(amount > 0, "29");



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

            // Check Transaction Count
            if(swapCounter >= swapTrigger){

                // Check Contract Tokens
                uint256 contractTokens = balanceOf(address(this));

                if (contractTokens > 0) {

                    // Limit Swap to Max Transaction
                    if (contractTokens <= max_Tran) {

                        swapAndLiquify (contractTokens);

                        } else {

                        swapAndLiquify (max_Tran);

                    }
                }
            }  
        }

        // Check Fee Status
        takeFee = true;
        if(_isExcludedFromFee[from] || _isExcludedFromFee[to] || (No_Fee_Transfers && !_isPair[to] && !_isPair[from])){
            takeFee = false;
        }

        _tokenTransfer(from, to, amount, takeFee);

    }


    /*
    
    ------------
    PROCESS FEES
    ------------

    */

    function swapAndLiquify(uint256 Tokens) private {

        // Lock Swap
        inSwapAndLiquify        = true;  

        // Calculate Tokens for Swap
        uint256 _FeesTotal      = _SwapFeeTotal_Buy + _SwapFeeTotal_Sell;
        uint256 LP_Tokens       = Tokens * (_Fee__Buy_Liquidity + _Fee__Sell_Liquidity) / _FeesTotal / 2;
        uint256 Swap_Tokens     = Tokens - LP_Tokens;

        // Swap Tokens
        uint256 contract_BNB    = address(this).balance;
        swapTokensForBNB(Swap_Tokens);
        uint256 returned_BNB    = address(this).balance - contract_BNB;

        // Avoid Rounding Errors on LP Fee if Odd Number
        uint256 fee_Split       = _FeesTotal * 2 - (_Fee__Buy_Liquidity + _Fee__Sell_Liquidity);

        // Calculate BNB Values
        uint256 BNB_Liquidity   = returned_BNB * (_Fee__Buy_Liquidity     + _Fee__Sell_Liquidity)       / fee_Split;
        uint256 BNB_Contract    = returned_BNB * (_Fee__Buy_Contract      + _Fee__Sell_Contract)    * 2 / fee_Split;
        uint256 BNB_Rewards     = returned_BNB * (_Fee__Buy_Rewards       + _Fee__Sell_Rewards)     * 2 / fee_Split; 

        // Add Liquidity 
        if (LP_Tokens != 0){
            addLiquidity(LP_Tokens, BNB_Liquidity);
            emit SwapAndLiquify(LP_Tokens, BNB_Liquidity, LP_Tokens);
        }
   

        // Take Contract Fee
        if(BNB_Contract > 0){

            send_BNB(feeCollector, BNB_Contract);

        }

        // Deposit Rewards
        if(BNB_Rewards > 0){

            try distributor.deposit{value: BNB_Rewards}() {} catch {}

        }

        
        // Deposit Marketing
        contract_BNB = address(this).balance;

        if (contract_BNB > 0){

            send_BNB(Wallet_BNB, contract_BNB);
        }


        // Reset Counter
        swapCounter = 1;

        // Unlock Swap
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



    // Add Liquidity
    function addLiquidity(uint256 tokenAmount, uint256 BNBAmount) private {

        _approve(address(this), address(uniswapV2Router), tokenAmount);
        uniswapV2Router.addLiquidityETH{value: BNBAmount}(
            address(this),
            tokenAmount,
            0, 
            0,
            Wallet_Liquidity, 
            block.timestamp
        );
    } 








    /*
    
    ----------------------------------
    TRANSFER TOKENS AND CALCULATE FEES
    ----------------------------------

    */


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

        } else {

                // No Fees
                tBurn           = 0;
                tTokens         = 0;
                tSwapFeeTotal   = 0;

        }

        tTransferAmount = tAmount - (tBurn + tTokens + tSwapFeeTotal);

        
        // Remove Tokens from Sender
        _tOwned[sender] -= tAmount;

        // Check for Deflationary Burn
        if (DeflationaryBurn && recipient == DEAD) {

                // Remove Tokens from Total Supply 
                _tTotal -= tTransferAmount;

            } else {

                // Give Tokens to Recipient
                _tOwned[recipient] += tTransferAmount;

            }

            emit Transfer(sender, recipient, tTransferAmount);

        // Process Token Fee
        if(tTokens > 0){

                _tOwned[Wallet_Tokens] += tTokens;            

        }

        // Take Fees for BNB Processing
        if(tSwapFeeTotal > 0){

            _tOwned[address(this)] += tSwapFeeTotal;

            // Increase Transaction Counter
            swapCounter++;
                
        }

        // Process Burn
        if(tBurn > 0){

            if (DeflationaryBurn){

                // Reduce Supply
                _tTotal = _tTotal - tBurn;

            } else {

                _tOwned[DEAD] += tBurn;

            }

        }



    }


   

    // This function is required so that the contract can receive BNB during fee processing
    receive() external payable {}




}

/*

---------------------
**** ERROR CODES ****
---------------------

    E01 - Only the developer can call this function
    E02 - Only the current owner can call this function
    E03 - Buy fees are limited of 15% max to protect buyers (includes 1% dev fee if applicable)
    E04 - Sell fees are limited of 15% max to protect buyers (includes 1% dev fee if applicable)
    E05 - During LaunchMode, the max transaction limit must be set to 0.1% of total supply or greater
    E06 - During LaunchMode, the max wallet holding limit must be set to 0.1% of total supply or greater
    E07 - After LaunchMode, the max transaction limit must be set to 0.5% of total supply or greater
    E08 - After LaunchMode, the max wallet holding limit must be set to 0.5% of total supply or greater
    E09 - Max possible early buy timer is 60 seconds
    E10 - Blacklisting of wallets only permitted during LaunchMode (Max 1 hour)
    E11 - Max time to wait between reward distribution is 2 days (2880 mins)
    E12 - Max required reward before payout is $2
    E13 - A valid BSC wallet must be entered when updating the token fee wallet 
    E14 - A valid BSC wallet must be entered when updating the Cake LP Collection wallet 
    E15 - A valid BSC wallet must be entered when updating the BNB fee wallet 
    E16 - A fee of 2 BNB is required, enter the number 2 into the field and try again
    E17 - A valid BSC wallet must be entered when transferring ownership
    E18 - Contract is currently processing fees, try later
    E19 - Can not remove the native token
    E20 - Trade is not open, only whitelisted wallets can trade
    E21 - Wallet was flagged as a sniper bot and can not purchase again during LaunchMode
    E22 - Wallet was flagged as a sniper bot and can not sell during LaunchMode
    E23 - Early Buyers can not sell during LaunchMode
    E24 - Wallet is blacklisted, trade cancelled
    E25 - Purchase would exceed max wallet holding limit, trade cancelled
    E26 - Purchase would exceed max transaction limit, trade cancelled 
    E27 - Zero address error, please use a valid BSC address
    E28 - Zero address error, please use a valid BSC address
    E29 - Amount must be greater than 0

*/


// Contract Created at https://Envominer.com
// DYOR into the team and project before you invest!
// Not open source - Can not be used or forked without permission.