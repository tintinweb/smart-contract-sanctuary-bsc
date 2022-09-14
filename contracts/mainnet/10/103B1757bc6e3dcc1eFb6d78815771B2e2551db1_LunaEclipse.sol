/**
 *Submitted for verification at BscScan.com on 2022-09-14
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

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
  
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;  //hash address of empty contract

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

interface IDividendDistributor {
    function setDistributionCriteria(uint256 _minPeriod, uint256 _minDistribution) external;
    function setShare(address shareholder, uint256 amount) external;
    function deposit() external payable;
    function process(uint256 gas) external;
    function claimDividend(address holder) external;
    function setNormalDistribution(bool value) external;
    function setRLock(address _user, bool _status) external;
}

contract DividendDistributor is IDividendDistributor {

    using SafeMath for uint256;

    address _token;

    struct Share {
        uint256 amount;
        uint256 totalExcluded;
        uint256 totalRealised;
    }

    IUniswapV2Router02 router;

    IERC20 RewardToken = IERC20(0x156ab3346823B651294766e23e6Cf87254d68962);   //LUNC
    //Testnet 
    // IERC20 RewardToken = IERC20(0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7);

    address[] shareholders;
    mapping (address => uint256) shareholderIndexes;
    mapping (address => uint256) shareholderClaims;
    mapping (address => Share) public shares;
    mapping (address => bool) public Rlock;

    uint256 public totalShares;
    uint256 public totalDividends;
    uint256 public totalDistributed;
    uint256 public dividendsPerShare;
    uint256 public dividendsPerShareAccuracyFactor = 10 ** 36;

    uint256 public minPeriod = 86400;
    uint256 public minDistribution = 1 * (10 ** 6);

    bool public normalDistribution;

    uint256 currentIndex;

    bool initialized;
    modifier initialization() {
        require(!initialized);
        _;
        initialized = true;
    }

    modifier onlyToken() {
        require(msg.sender == _token); _;
    }

    constructor (address _router) {
        router = _router != address(0) ? IUniswapV2Router02(_router) : IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        _token = msg.sender;
    }

    function setNormalDistribution(bool _r) external override onlyToken {
        normalDistribution = _r;
    }

    function setRLock(address _adr, bool _status) external override onlyToken {
        Rlock[_adr] = _status;
    }

    function setDistributionCriteria(uint256 newMinPeriod, uint256 newMinDistribution) external override onlyToken {
        minPeriod = newMinPeriod;
        minDistribution = newMinDistribution;
    }

    function setShare(address shareholder, uint256 amount) external override onlyToken {

        if(normalDistribution) {
            if(shares[shareholder].amount > 0) {
                distributeDividend(shareholder);
            }
        }

        if(amount > 0 && shares[shareholder].amount == 0){
            addShareholder(shareholder);
        }else if(amount == 0 && shares[shareholder].amount > 0){
            removeShareholder(shareholder);
        }

        totalShares = totalShares.sub(shares[shareholder].amount).add(amount);
        shares[shareholder].amount = amount;
        shares[shareholder].totalExcluded = getCumulativeDividends(shares[shareholder].amount);
    }

    function deposit() external payable override onlyToken {

        uint256 balanceBefore = RewardToken.balanceOf(address(this));

        address[] memory path = new address[](2);
        path[0] = router.WETH();
        path[1] = address(RewardToken);

        router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: msg.value}(
            0,
            path,
            address(this),
            block.timestamp
        );

        uint256 amount = RewardToken.balanceOf(address(this)).sub(balanceBefore);
        totalDividends = totalDividends.add(amount);
        dividendsPerShare = dividendsPerShare.add(dividendsPerShareAccuracyFactor.mul(amount).div(totalShares));
    }

    function process(uint256 gas) external override onlyToken {
        uint256 shareholderCount = shareholders.length;

        if(shareholderCount == 0) { return; }

        uint256 iterations = 0;
        uint256 gasUsed = 0;
        uint256 gasLeft = gasleft();

        while(gasUsed < gas && iterations < shareholderCount) {

            if(currentIndex >= shareholderCount){ currentIndex = 0; }

            if(shouldDistribute(shareholders[currentIndex])){
                distributeDividend(shareholders[currentIndex]);
            }

            gasUsed = gasUsed.add(gasLeft.sub(gasleft()));
            gasLeft = gasleft();
            currentIndex++;
            iterations++;
        }
    }
    
    function shouldDistribute(address shareholder) internal view returns (bool) {
        return shareholderClaims[shareholder] + minPeriod < block.timestamp
                && getUnpaidEarnings(shareholder) > minDistribution
                && !Rlock[shareholder];
    }

    function distributeDividend(address shareholder) internal {
        if(shares[shareholder].amount == 0){ return; }

        uint256 amount = getUnpaidEarnings(shareholder);
        if(amount > 0){
            totalDistributed = totalDistributed.add(amount);
            RewardToken.transfer(shareholder, amount);
            shareholderClaims[shareholder] = block.timestamp;
            shares[shareholder].totalRealised = shares[shareholder].totalRealised.add(amount);
            shares[shareholder].totalExcluded = getCumulativeDividends(shares[shareholder].amount);
        }

    }

    function getUnpaidEarnings(address shareholder) public view returns (uint256) {
        if(shares[shareholder].amount == 0){ return 0; }

        uint256 shareholderTotalDividends = getCumulativeDividends(shares[shareholder].amount);
        uint256 shareholderTotalExcluded = shares[shareholder].totalExcluded;

        if(shareholderTotalDividends <= shareholderTotalExcluded){ return 0; }

        return shareholderTotalDividends.sub(shareholderTotalExcluded);
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
    
    function claimDividend(address holder) external override {
        distributeDividend(holder);
    }

    function withdraw(address dToken,address _recipient,uint _value) external onlyToken {
        IERC20(dToken).transfer(_recipient,_value);
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
    
    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }

    function renouncedOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0x000000000000000000000000000000000000dEaD));
        _owner = address(0x000000000000000000000000000000000000dEaD);
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

contract LunaEclipse is Context, IERC20, Ownable {
    
    using SafeMath for uint256;
    using Address for address;
    
    string private _name = "Luna Eclipse";
    string private _symbol = "ECLPS";
    uint8 private _decimals = 6;

    address public marketingWallet = 0xfa9d755d10d136E6fd64eEd6EFe2B16140303dec;
    address public developerWallet = 0x0eF67Ff65203C2a5e1A973922527db65B800A51B;
    address public liquidityReciever;

    uint256 public minHoldingForReward = 2000000 * 10**_decimals;  

    address public constant deadAddress = 0x000000000000000000000000000000000000dEaD;
    address public constant zeroAddress = 0x0000000000000000000000000000000000000000;
    
    mapping (address => uint256) _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    
    mapping (address => bool) public isExcludedFromFee;
    mapping (address => bool) public isMarketPair;
    mapping (address => bool) public isWalletLimitExempt;
    mapping (address => bool) public isTxLimitExempt;
    mapping (address => bool) public isDividendExempt;
    mapping (address => bool) public blacklisted;
    mapping (address => bool) public allowTransfer;
    mapping (address => bool) public allowedReward;

    uint256 _buyLiquidityFee = 10;
    uint256 _buyMarketingFee = 50;
    uint256 _buyDeveloperFee = 30;
    uint256 _buyRewardFee = 30;
    
    uint256 _sellLiquidityFee = 10;
    uint256 _sellMarketingFee = 50;
    uint256 _sellDeveloperFee = 30;
    uint256 _sellRewardFee = 30;

    uint256 totalBuy;
    uint256 totalSell;

    uint256 denominator = 1000;

    uint256 private _totalSupply = 10_000_000_000 * 10**_decimals;   

    uint256 public minimumTokensBeforeSwap = 100000 * 10**_decimals;

    uint256 public _maxTxAmount =  _totalSupply.mul(5).div(denominator);     //0.5%
    uint256 public _walletMax = _totalSupply.mul(10).div(denominator);    //1%

    bool public EnableTxLimit = true;
    bool public checkWalletLimit = true;

    bool public initalDistribution;
    bool public triggered;
    uint public launchTime;

    IUniswapV2Router02 public uniswapV2Router;
    address public uniswapPair;

    DividendDistributor public dividendDistributor;
    uint256 distributorGas = 300000;
    
    bool inSwapAndLiquify;
    bool public swapAndLiquifyEnabled = true;

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

        //testnet => 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3
        //mainnet => 0x10ED43C718714eb63d5aA57B78B54704E256024E
        
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E); 

        uniswapPair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), _uniswapV2Router.WETH());

        uniswapV2Router = _uniswapV2Router;

        _allowances[address(this)][address(uniswapV2Router)] = ~uint256(0);

        dividendDistributor = new DividendDistributor(address(0x10ED43C718714eb63d5aA57B78B54704E256024E));

        liquidityReciever = msg.sender;

        isExcludedFromFee[address(this)] = true;
        isExcludedFromFee[msg.sender] = true;
        isExcludedFromFee[marketingWallet] = true;
        isExcludedFromFee[developerWallet] = true;

        isWalletLimitExempt[msg.sender] = true;
        isWalletLimitExempt[address(uniswapPair)] = true;
        isWalletLimitExempt[address(this)] = true;
        
        isTxLimitExempt[msg.sender] = true;
        isTxLimitExempt[address(this)] = true;

        isDividendExempt[address(uniswapPair)] = true;
        isDividendExempt[msg.sender] = true;
        isDividendExempt[address(this)] = true;
        isDividendExempt[deadAddress] = true;
        isDividendExempt[zeroAddress] = true;

        isMarketPair[address(uniswapPair)] = true;

        totalBuy = _buyLiquidityFee.add(_buyMarketingFee).add(_buyDeveloperFee).add(_buyRewardFee);
        totalSell = _sellLiquidityFee.add(_sellMarketingFee).add(_sellDeveloperFee).add(_sellRewardFee);

        _balances[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    /*====================================
    |               Getters              |
    ====================================*/

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
    
    function getCirculatingSupply() public view returns (uint256) {
        return _totalSupply.sub(balanceOf(deadAddress)).sub(balanceOf(zeroAddress));
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

    function _transfer(address sender, address recipient, uint256 amount) private returns (bool) {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        require(!blacklisted[sender] && !blacklisted[recipient],"Error: Blacklist Bots/Contracts not Allowed!!");
        require(initalDistribution || allowTransfer[msg.sender] || isOwner() ,"Trade is Currently Paused!!");
        
        if((block.timestamp > launchTime + 15 minutes) && !triggered && (launchTime != 0) ){
            _maxTxAmount =  _totalSupply.mul(10).div(denominator);     //1%
            _walletMax = _totalSupply.mul(20).div(denominator);    //2%
            triggered = true;
        }
        
        if(inSwapAndLiquify)
        { 
            return _basicTransfer(sender, recipient, amount); 
        }
        else
        {  
            if(!isTxLimitExempt[sender] && !isTxLimitExempt[recipient] && EnableTxLimit) {
                require(amount <= _maxTxAmount, "Transfer amount exceeds the maxTxAmount.");
            } 

            uint256 contractTokenBalance = balanceOf(address(this));
            bool overMinimumTokenBalance = contractTokenBalance >= minimumTokensBeforeSwap;
            
            if (overMinimumTokenBalance && !inSwapAndLiquify && !isMarketPair[sender] && swapAndLiquifyEnabled) 
            {
                swapAndLiquify();
            }

            _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");

            uint256 finalAmount = shouldTakeFee(sender,recipient) ? amount : takeFee(sender, recipient, amount);

            if(checkWalletLimit && !isWalletLimitExempt[recipient]) {
                require(balanceOf(recipient).add(finalAmount) <= _walletMax,"Max Wallet Limit Exceeded!!");
            }

            _balances[recipient] = _balances[recipient].add(finalAmount);

            rewardChecker(sender,_balances[sender],recipient,_balances[recipient]);

             // Dividend tracker
            if(!isDividendExempt[sender] && allowedReward[sender]) {
                try dividendDistributor.setShare(sender, _balances[sender]) {} catch {}
            }

            if(!isDividendExempt[recipient] && allowedReward[recipient]) {
                try dividendDistributor.setShare(recipient, _balances[recipient]) {} catch {} 
            }

            try dividendDistributor.process(distributorGas) {} catch {}

            emit Transfer(sender, recipient, finalAmount);
            return true;
        }
    }

    function rewardChecker(address _sender,uint _senderBalance,address _Recp,uint _RecpBalance) internal {
        if(_senderBalance >= minHoldingForReward) {
            allowedReward[_sender] = true;
            dividendDistributor.setRLock(_sender,false);
        }
        if(_RecpBalance >= minHoldingForReward) {
            allowedReward[_Recp] = true;
            dividendDistributor.setRLock(_Recp,false);
        }   
        if(_senderBalance < minHoldingForReward){
            allowedReward[_sender] = false;
            dividendDistributor.setRLock(_sender,true);
        }
        if(_RecpBalance < minHoldingForReward){
            allowedReward[_Recp] = false;
            dividendDistributor.setRLock(_Recp,true);
        }
    }

    function _basicTransfer(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function swapAndLiquify() private lockTheSwap {

        uint256 contractBalance = balanceOf(address(this));

        if(contractBalance == 0) return;

        uint256 totalShares = totalBuy.add(totalSell);
        uint256 _liquidityShare = _buyLiquidityFee.add(_sellLiquidityFee);
        uint256 _MarketingShare = _buyMarketingFee.add(_sellMarketingFee);
        uint256 _DeveloperShare = _buyDeveloperFee.add(_sellDeveloperFee);

        uint256 tokensForLP = contractBalance.mul(_liquidityShare).div(totalShares).div(2);
        uint256 tokensForSwap = contractBalance.sub(tokensForLP);

        uint256 initialBalance = address(this).balance;
        swapTokensForEth(tokensForSwap);
        uint256 amountReceived = address(this).balance.sub(initialBalance);

        uint256 totalBNBFee = totalShares.sub(_liquidityShare.div(2));
        
        uint256 amountBNBLiquidity = amountReceived.mul(_liquidityShare).div(totalBNBFee).div(2);
        uint256 amountBNBMarketing = amountReceived.mul(_MarketingShare).div(totalBNBFee);
        uint256 amountBNBDeveloper = amountReceived.mul(_DeveloperShare).div(totalBNBFee);
        uint256 amountBNBReward = amountReceived.sub(amountBNBLiquidity).sub(amountBNBMarketing).sub(amountBNBDeveloper);

        if(amountBNBMarketing > 0)
            transferToAddressETH(marketingWallet, amountBNBMarketing);

        if(amountBNBDeveloper > 0)
            transferToAddressETH(developerWallet, amountBNBDeveloper);

        if(amountBNBReward > 0) {
            try dividendDistributor.deposit{value: amountBNBReward}() {} catch {}
        }

        if(amountBNBLiquidity > 0 && tokensForLP > 0)
            addLiquidity(tokensForLP, amountBNBLiquidity);
    }

    function transferToAddressETH(address recipient, uint256 amount) private {
        payable(recipient).transfer(amount);
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
            liquidityReciever,
            block.timestamp
        );
    }

    function shouldTakeFee(address sender, address recipient) internal view returns (bool) {
        if(isExcludedFromFee[sender] || isExcludedFromFee[recipient]) {
            return true;
        }
        else if (isMarketPair[sender] || isMarketPair[recipient]) {
            return false;
        }
        else {
            return false;
        }
    }

    function takeFee(address sender, address recipient, uint256 amount) internal returns (uint256) {
        
        uint feeAmount;

        unchecked {

            if(isMarketPair[sender]) {
                feeAmount = amount.mul(totalBuy).div(denominator);
            }
            else if(isMarketPair[recipient]) {
                feeAmount = amount.mul(totalSell).div(denominator);
            }     

            if(feeAmount > 0) {
                _balances[address(this)] = _balances[address(this)].add(feeAmount);
                emit Transfer(sender, address(this), feeAmount);
            }

            return amount.sub(feeAmount);
        }
        
    }

    /*====================================
    |               Setters              |
    ====================================*/

    //To Block Bots to trade
    function blacklistBot(address _adr,bool _status) public onlyOwner {
        require(Address.isContract(_adr),"Error: BlackList Applicable For Bot/Contracts!!");
        blacklisted[_adr] = _status;
    }

    //To Rescue Stucked Balance
    function rescueFunds() public onlyOwner { 
        (bool os,) = payable(msg.sender).call{value: address(this).balance}("");
        require(os,"Transaction Failed!!");
    }

    //To Rescue Stucked Tokens
    function rescueTokens(IERC20 adr,address recipient,uint amount) public onlyOwner {
        adr.transfer(recipient,amount);
    }

    function openTrade(bool _status,bool _lt) public onlyOwner {
        initalDistribution = _status;
        if(_lt){
            launchTime = block.timestamp;
        }
    }

    function setWhitelistTransfer(address _adr, bool _status) public onlyOwner {
        allowTransfer[_adr] = _status;
    }

    function enableTxLimit(bool _status) public onlyOwner {
        EnableTxLimit = _status;
    }

    function enableWalletLimit(bool _status) public onlyOwner {
        checkWalletLimit = _status;
    }

    function setBuyFee(uint _newLP , uint _newMarket , uint _newDeveloper) public onlyOwner {     
        _buyLiquidityFee = _newLP;
        _buyMarketingFee = _newMarket;
        _buyDeveloperFee = _newDeveloper;
        totalBuy = _buyLiquidityFee.add(_buyMarketingFee).add(_buyDeveloperFee);
    }

    function setSellFee(uint _newLP , uint _newMarket , uint _newDeveloper) public onlyOwner {        
        _sellLiquidityFee = _newLP;
        _sellMarketingFee = _newMarket;
        _sellDeveloperFee = _newDeveloper;
        totalSell = _sellLiquidityFee.add(_sellMarketingFee).add(_sellDeveloperFee);
    }

    function setWallets(address _market,address _developer,address _liquidityRec) public onlyOwner {
        marketingWallet = _market;
        developerWallet = _developer;
        liquidityReciever = _liquidityRec;
    }

    function setExcludeFromFee(address _adr,bool _status) public onlyOwner {
        require(isExcludedFromFee[_adr] != _status,"Not Changed!!");
        isExcludedFromFee[_adr] = _status;
    }

    function ExcludeWalletLimit(address _adr,bool _status) public onlyOwner {
        require(isWalletLimitExempt[_adr] != _status,"Not Changed!!");
        isWalletLimitExempt[_adr] = _status;
    }

    function ExcludeTxLimit(address _adr,bool _status) public onlyOwner {
        require(isTxLimitExempt[_adr] != _status,"Not Changed!!");
        isTxLimitExempt[_adr] = _status;
    }

    function setNumTokensBeforeSwap(uint256 newLimit) external onlyOwner() {
        minimumTokensBeforeSwap = newLimit;
    }

    function setMaxWalletLimit(uint256 newLimit) external onlyOwner() {
        _walletMax = newLimit;
    }

    function setTxLimit(uint256 newLimit) external onlyOwner() {
        _maxTxAmount = newLimit;
    }

    function setSwapAndLiquifyEnabled(bool _enabled) public onlyOwner {
        swapAndLiquifyEnabled = _enabled;
        emit SwapAndLiquifyEnabledUpdated(_enabled);
    }

    function setMarketPair(address _pair, bool _status) public onlyOwner {
        isMarketPair[_pair] = _status;
        isDividendExempt[address(_pair)] = _status;
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

        isMarketPair[address(uniswapPair)] = true;
        isDividendExempt[address(uniswapPair)] = true;
    }

    function setMinReward(uint _tokenValue) public onlyOwner {
        minHoldingForReward = _tokenValue;
    }

    function rescueDividend(address token,address _recipient,uint _value) public onlyOwner {
		dividendDistributor.withdraw(token,_recipient,_value);
	}

    function changeIsDividendExempt(address holder, bool exempt) external onlyOwner {
        require(holder != address(this) && holder != uniswapPair);
        isDividendExempt[holder] = exempt;
        
        if(exempt){
            dividendDistributor.setShare(holder, 0);
        }
        else{
            dividendDistributor.setShare(holder, _balances[holder]);
        }
    }

    function changeDistributionCriteria(uint256 newinPeriod, uint256 newMinDistribution) external onlyOwner {
        dividendDistributor.setDistributionCriteria(newinPeriod, newMinDistribution);
    }

    function setNormalDistribution(bool _status) public onlyOwner {
        dividendDistributor.setNormalDistribution(_status);
    }

    function changeDistributorSettings(uint256 gas) external onlyOwner {
        require(gas < 750000);
        distributorGas = gas;
    }

}