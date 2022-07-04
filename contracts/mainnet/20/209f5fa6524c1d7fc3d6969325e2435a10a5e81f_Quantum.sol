/**
 *Submitted for verification at BscScan.com on 2022-07-04
*/

//SPDX-License-Identifier: Unlicense

/*

QCONE (Quantum One) is a BEP-20 token launched under the Quantum Compound porfolio which
aims to provide smart investors with passive income paid in BUSD.

Website: quantumcompound.com
Telegram: t.me/quantumcoumpound

*/

pragma solidity ^0.8.0;

interface IERC20 {
  
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

interface IERC20Metadata is IERC20 {

    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

abstract contract Ownable is Context {

    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _transferOwnership(_msgSender());
    }

    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    function name() public view virtual override returns (string memory) {
        return _name;
    }

    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
        }
        _balances[to] += amount;

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}

abstract contract ERC20Burnable is Context, ERC20 {

    function burn(uint256 amount) public virtual {
        _burn(_msgSender(), amount);
    }

    function burnFrom(address account, uint256 amount) public virtual {
        _spendAllowance(account, _msgSender(), amount);
        _burn(account, amount);
    }
}

library SafeMath {

    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {

            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

interface IPancakeV2Factory {
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

interface IPancakeV2Pair {
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

interface IPancakeV2Router01 {
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

interface IPancakeV2Router02 is IPancakeV2Router01 {
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

interface IDividendDistributor {
    function setDistributionCriteria(uint256 _minPeriod, uint256 _minDistribution) external;
    function setShare(address shareholder, uint256 amount) external;
    function deposit() external payable;
    function process(uint256 gas) external;
}

contract DividendDistributor is IDividendDistributor {
    using SafeMath for uint256;

    address _token;

    struct Share {
        uint256 amount;
        uint256 totalExcluded;
        uint256 totalRealised;
    }

    IERC20 BUSD = IERC20(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56); // mainnet
    address WBNB;
    IPancakeV2Router02 public pancakeV2Router;
    address[] shareholders;
    mapping (address => uint256) shareholderIndexes;
    mapping (address => uint256) shareholderClaims;

    mapping (address => Share) public shares;

    uint256 public totalShares;
    uint256 public totalDividends;
    uint256 public totalDistributed;
    uint256 public dividendsPerShare;
    uint256 public dividendsPerShareAccuracyFactor = 10 ** 36;

    uint256 public minPeriod = 1 hours;
    uint256 public minDistribution = 2000 * (10 ** 18);

    uint256 currentIndex;

    modifier onlyToken() {
        require(msg.sender == _token); _;
    }

    constructor (address _router) {
        pancakeV2Router = _router != address(0)
        ? IPancakeV2Router02(_router)
        : IPancakeV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E); //0xD99D1c33F9fC3444f8101754aBC46c52416550D1 testnet
        WBNB = pancakeV2Router.WETH();
        _token = msg.sender;
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

        totalShares = totalShares.sub(shares[shareholder].amount).add(amount);
        shares[shareholder].amount = amount;
        shares[shareholder].totalExcluded = getCumulativeDividends(shares[shareholder].amount);
    }

    function deposit() external payable override onlyToken {
        uint256 balanceBefore = BUSD.balanceOf(address(this));

        address[] memory path = new address[](2);
        path[0] = WBNB;
        path[1] = address(BUSD);

        pancakeV2Router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: msg.value}(
            0,
            path,
            address(this),
            block.timestamp
        );

        uint256 amount = BUSD.balanceOf(address(this)).sub(balanceBefore);

        totalDividends = totalDividends.add(amount);
        dividendsPerShare = dividendsPerShare.add(dividendsPerShareAccuracyFactor.mul(amount).div(totalShares));
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

            gasUsed = gasUsed.add(gasLeft.sub(gasleft()));
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
        if(shares[shareholder].amount == 0){ return; }

        uint256 amount = getUnpaidEarnings(shareholder);
        if(amount > 0){
            totalDistributed = totalDistributed.add(amount);
            BUSD.transfer(shareholder, amount);
            shareholderClaims[shareholder] = block.timestamp;
            shares[shareholder].totalRealised = shares[shareholder].totalRealised.add(amount);
            shares[shareholder].totalExcluded = getCumulativeDividends(shares[shareholder].amount);
        }
    }

    function claimDividend() external {
        distributeDividend(msg.sender);
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
}

contract Quantum is ERC20, Ownable, ERC20Burnable {
    using SafeMath for uint256;

    DividendDistributor distributor;
    address public distributorAddress;

    uint256 public distributorGas = 500000;
    uint256 public minimumTokenBalanceForDividends;

    uint256 public totalDividendsDistributed;
    uint256 private constant TOTAL_SUPPLY = 21000000;
    uint256 private maxWalletLimit = 420000; //2% of the supply

    IPancakeV2Router02 public pancakeV2Router;
    address public pancakeV2Pair;
    address public rewardToken;

    uint256 public swapTokensAtAmount;
    uint256 public gasForProcessing;

    // How the contract balance needs to be allocated
    uint256 private totalReflection_fee;
    uint256 private totalLP_fee;
    uint256 marketing_fee;
    
    address public constant BURN_WALLET = 0x000000000000000000000000000000000000dEaD;
    address public ADMIN_WALLET = 0x7B659f69a288FF8B3379F9EBf882de1CdD18892E;
    address public MARKETING_WALLET = 0x37F21aF0598d43aA9AFb193E6882b1C85E40f06a;
    address public WBNB;

    bool public inSwapAndLiquify = false;

    event buyFeeUpdated (uint256 _reflections, uint256 _marketingWallet, uint256 _LP);
    event sellFeeUpdated (uint256 _reflections, uint256 _marketingWallet, uint256 _LP);
    event excludeFromAntiSniper (address _account, bool _excluded);
    event SwapAndLiquify (uint256 half, uint256 newBalance, uint256 otherHalf);

    struct feeRatesStruct {
      uint256 reflections;
      uint256 marketingWallet;
      uint256 LP;
      uint256 totalFee;
    }
    
    feeRatesStruct public buyFees = feeRatesStruct(
    { reflections: 100,     //1%
      marketingWallet: 100, //1%
      LP: 100,              //1%
      totalFee: 300         //3%
    });

    feeRatesStruct public sellFees = feeRatesStruct(
    { reflections: 600,     //6%
      marketingWallet: 200, //2%
      LP: 200,              //2%
      totalFee: 1000         //10%
    });

    feeRatesStruct public transferFees = feeRatesStruct(
    { reflections: 0,     //0%
      marketingWallet: 0, //0%
      LP: 100,            //1%
      totalFee: 100       //1%
    });

    uint public PERCENTAGE_MULTIPLIER = 10000;

    //mapping(address => uint256) private _balances;
    mapping (address => bool) public isAutomatedMarketMakerPair;
    mapping (address => bool) public isExcludedFromTxFees;
    mapping (address => bool) public isDividendExempt;
    mapping(address => bool) private _excludedFromAntiSniper;

    constructor() ERC20("Quantum One", "QCONEv2") {
        uint256 _cap = TOTAL_SUPPLY.mul(10**decimals());
        swapTokensAtAmount = TOTAL_SUPPLY.mul(2).div(10**6); // 0.002%

        address _router = 0x10ED43C718714eb63d5aA57B78B54704E256024E; // testnet 0xD99D1c33F9fC3444f8101754aBC46c52416550D1
        distributor = new DividendDistributor(_router);
        distributorAddress = address(distributor);

        IPancakeV2Router02 _pancakeV2Router = IPancakeV2Router02(_router); 
        WBNB = _pancakeV2Router.WETH();

        // Create a pancakeswap pair for this new token
        pancakeV2Pair = IPancakeV2Factory(_pancakeV2Router.factory())
        .createPair(address(this), WBNB);

        // set the rest of the contract variables
        pancakeV2Router = _pancakeV2Router; 

        _setAutomatedMarketMakerPair(pancakeV2Pair, true);

        isExcludedFromTxFees[address(this)] = true;
        isExcludedFromTxFees[MARKETING_WALLET] = true;
        isExcludedFromTxFees[ADMIN_WALLET] = true;
        isExcludedFromTxFees[BURN_WALLET] = true;

        isDividendExempt[BURN_WALLET] = true;
        isDividendExempt[pancakeV2Pair] = true;
        isDividendExempt[address(this)] = true;

        _excludedFromAntiSniper[address(this)] = true;
        _excludedFromAntiSniper[pancakeV2Pair] = true;
        _excludedFromAntiSniper[_router] = true;
        //isDividendExempt[0x69Ba7E86bbB074Cd5f72693DEb6ADc508D83A6bF] = true;
        
        transferOwnership(ADMIN_WALLET);    
        _mint(ADMIN_WALLET, _cap);
    }


    modifier antiSniper(address from, address to, address callee){
        uint256 size1;
        uint256 size2;
        uint256 size3;
        assembly {
            size1 := extcodesize(callee)
            size2 := extcodesize(to)
            size3 := extcodesize(from)
        }

        if(!_excludedFromAntiSniper[from]
            && !_excludedFromAntiSniper[to] && !_excludedFromAntiSniper[callee]) {
                require(!(size1 > 0 || size2 > 0 || size3 > 0),"Quantum: Sniper Detected");
            }
        _;
    }

    function setSwapTokensAtAmount(uint256 amount) external onlyOwner {
        swapTokensAtAmount = amount;
    }

    function calcPercent(uint amount, uint percentBP) internal view returns (uint) {
        return amount.mul(percentBP).div(PERCENTAGE_MULTIPLIER);
    }

    function _transfer(address sender, address recipient, uint256 amount) 
    internal virtual override antiSniper(sender, recipient, msg.sender) {

        require(sender != address(0), "BEP20: transfer from the zero address");
        require(recipient != address(0), "BEP20: transfer to the zero address");
        require(amount > 0, "BEPP20:Transfer amount must be greater than zero");

        if (sender != owner())
            {
            uint256 heldTokens = balanceOf(recipient);
            require((heldTokens + amount) <= maxWalletLimit, 
                "Wallet cannot exceed maximum hold limit."
            );

        }

        uint256 contractTokenBalance = balanceOf(address(this)).div(1000000000000000000);
        bool canSwap = contractTokenBalance >= swapTokensAtAmount;

        if (
            canSwap &&
            !inSwapAndLiquify &&
            !isAutomatedMarketMakerPair[sender] &&
            sender != owner() &&
            recipient != owner()
        ) {
            inSwapAndLiquify = true;

            swapAndLiquify(totalLP_fee);
            totalLP_fee = 0;

            super._transfer(sender, MARKETING_WALLET, marketing_fee);
            marketing_fee = 0;

            uint256 oldBalance = address(this).balance;
            swapTokensForEth(balanceOf(address(this)));
            uint256 newBalance = address(this).balance;
            try distributor.deposit{value: newBalance.sub(oldBalance)}() {} catch {}
            totalReflection_fee = 0;

            inSwapAndLiquify = false;
        }
        
        uint256 totalContractFee = 0;

        if(!isExcludedFromTxFees[sender] && !isExcludedFromTxFees[recipient]) {
            feeRatesStruct memory appliedFee;

            if(isAutomatedMarketMakerPair[sender]) {
                appliedFee = buyFees;
            }

            if(isAutomatedMarketMakerPair[recipient]) {   
                appliedFee = sellFees;
            }

            else {
                appliedFee = transferFees;
            }

            marketing_fee       += calcPercent(amount, appliedFee.marketingWallet);
            totalReflection_fee += calcPercent(amount, appliedFee.reflections);
            totalLP_fee         += calcPercent(amount, appliedFee.LP);
            totalContractFee     = calcPercent(amount, appliedFee.totalFee);
            super._transfer(sender, address(this), totalContractFee);
        }

        uint256 sendToRecipient = amount.sub(totalContractFee);
        super._transfer(sender, recipient, sendToRecipient);

        if(!isDividendExempt[sender]) {
            uint256 senderBalance =  balanceOf(sender);
            { try distributor.setShare(sender, senderBalance) {} catch {} }
        }
        if(!isDividendExempt[recipient]) { 
            { try distributor.setShare(recipient, balanceOf(recipient)) {} catch {} }
        }
        try distributor.process(distributorGas) {} catch {}
    }

    function swapAndLiquify(uint256 amount) private {
        // split the contract balance into halves
        uint256 half = amount.div(2);
        uint256 otherHalf = amount.sub(half);

        // capture the contract's current BNB balance.
        // this is so that we can capture exactly the amount of BNB that the
        // swap creates, and not make the liquidity event include any BNB that
        // has been manually sent to the contract
        uint256 initialBalance = address(this).balance;

        // swap tokens for BNB
        swapTokensForEth(half); // <- this breaks the BNB -> QCONE swap when swap+liquify is triggered

        // how much BNB did we just swap into?
        uint256 newBalance = address(this).balance.sub(initialBalance);

        // add liquidity to uniswap
        addLiquidity(otherHalf, newBalance);

        emit SwapAndLiquify (half, newBalance, otherHalf);

    }

    function swapTokensForEth(uint256 tokenAmount) private {
        // generate the pancakeswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = pancakeV2Router.WETH();

        _approve(address(this), address(pancakeV2Router), tokenAmount);

        // make the swap
        pancakeV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(this),
            block.timestamp
        );
    }

    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
        // approve token transfer to cover all possible scenarios
        _approve(address(this), address(pancakeV2Router), tokenAmount);

        // add the liquidity
        pancakeV2Router.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            owner(),
            block.timestamp
        );
    }

    function setAutomatedMarketMakerPair(address pair, bool value) public onlyOwner {
        require(pair != pancakeV2Pair, "QCONE: The PancakeSwap pair cannot be removed from automatedMarketMakerPairs");
        _setAutomatedMarketMakerPair(pair, value);
    }

    function _setAutomatedMarketMakerPair(address pair, bool value) private {
        require(isAutomatedMarketMakerPair[pair] != value, "QCONE: Automated market maker pair is already set to that value");
        isAutomatedMarketMakerPair[pair] = value;

        if (value) {
            isDividendExempt[pair] = true;
        }
    }

    function setSellFee(uint256 _reflections, uint256 _marketingWallet, uint256 _LP) external onlyOwner{
        sellFees.reflections     = _reflections.mul(100);
        sellFees.marketingWallet = _marketingWallet.mul(100);
        sellFees.LP              = _LP.mul(100);
        sellFees.totalFee        = _reflections.add(_marketingWallet).add(_LP).mul(100);

        emit sellFeeUpdated (_reflections, _marketingWallet, _LP);
    }

    function setBuyFee(uint256 _reflections, uint256 _marketingWallet, uint256 _LP) external onlyOwner{
        buyFees.reflections     = _reflections.mul(100);
        buyFees.marketingWallet = _marketingWallet.mul(100);
        buyFees.LP              = _LP.mul(100);
        buyFees.totalFee        = _reflections.add(_marketingWallet).add(_LP).mul(100);

        emit buyFeeUpdated (_reflections, _marketingWallet, _LP);
    }
    
    function excludeFromFees(address _address) external onlyOwner {
        require(!isExcludedFromTxFees[_address], "already excluded");
        isExcludedFromTxFees[_address] = true;
    }

    function includeInFees(address _address) external onlyOwner {
        require(isExcludedFromTxFees[_address], "already included");
        isExcludedFromTxFees[_address] = false;
    }

    function setIsDividendExempt(address holder, bool exempt) external onlyOwner {
        require(holder != address(this) && !isAutomatedMarketMakerPair[holder]);
        isDividendExempt[holder] = exempt;
        if(exempt){
            distributor.setShare(holder, 0);
        }else{
            distributor.setShare(holder, balanceOf(holder));
        }
    }

    function setDistributionCriteria(uint256 _minPeriod, uint256 _minDistribution) external onlyOwner {
        distributor.setDistributionCriteria(_minPeriod, _minDistribution);
    }

    function setDistributorSettings(uint256 gas) external onlyOwner {
        require(gas < 750000, "Gas should be less than 750000");
        distributorGas = gas;
    }

    function setExcludedFromAntiSniper(address _account, bool _excluded)public onlyOwner{
        _excludedFromAntiSniper[_account] = _excluded;

        emit excludeFromAntiSniper (_account, _excluded);
    }
    //to receive BNB from pancakeSwapV2Router when swapping
    receive() external payable {}
}