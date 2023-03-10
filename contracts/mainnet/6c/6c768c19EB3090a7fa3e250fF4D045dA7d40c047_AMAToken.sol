/**
 *Submitted for verification at BscScan.com on 2023-03-10
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

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

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
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


interface IERC20 {
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
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IERC20Metadata is IERC20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
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

interface IUniswapV2Factory {

    // events
    event PairCreated(address indexed token0, address indexed token1, address pair, uint256);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint256) external view returns (address pair);
    function allPairsLength() external view returns (uint256);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}

interface IUniswapV2Router01 {
    
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB, uint256 liquidity);
    
    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external payable returns (uint256 amountToken, uint256 amountETH, uint256 liquidity);
    
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB);
    
    function removeLiquidityETH(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountToken, uint256 amountETH);
    
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint256 amountA, uint256 amountB);
    
    function removeLiquidityETHWithPermit(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint256 amountToken, uint256 amountETH);
    
    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);
    
    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);
    
    function swapExactETHForTokens(uint256 amountOutMin, address[] calldata path, address to, uint256 deadline)
        external
        payable
        returns (uint256[] memory amounts);
        
    function swapTokensForExactETH(uint256 amountOut, uint256 amountInMax, address[] calldata path, address to, uint256 deadline)
        external
        returns (uint256[] memory amounts);
        
    function swapExactTokensForETH(uint256 amountIn, uint256 amountOutMin, address[] calldata path, address to, uint256 deadline)
        external
        returns (uint256[] memory amounts);
        
    function swapETHForExactTokens(uint256 amountOut, address[] calldata path, address to, uint256 deadline)
        external
        payable
        returns (uint256[] memory amounts);

    function quote(uint256 amountA, uint256 reserveA, uint256 reserveB) external pure returns (uint256 amountB);
    
    function getAmountOut(uint256 amountIn, uint256 reserveIn, uint256 reserveOut) external pure returns (uint256 amountOut);
    function getAmountIn(uint256 amountOut, uint256 reserveIn, uint256 reserveOut) external pure returns (uint256 amountIn);
    
    function getAmountsOut(uint256 amountIn, address[] calldata path) external view returns (uint256[] memory amounts);
    function getAmountsIn(uint256 amountOut, address[] calldata path) external view returns (uint256[] memory amounts);
}


interface IUniswapV2Router02 is IUniswapV2Router01 {
    
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountETH);
    
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint256 amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
    
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;
    
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}


// AMA Token interface
interface IAMAToken is IERC20Metadata {

    // today init price
    function getTodayInitPrice() external view returns(uint);

    // Foundation
    function getFoundationClaimableAmt() external view returns(uint);
    function getFoundationClaimedAmt() external view returns(uint);
    function claimFoundation() external;

    // tech
    function getTechClaimableAmt() external view returns(uint);
    function getTechClaimedAmt() external view returns(uint);
    function claimTech() external;

    // amm pair
    function setAmmPair(address pair_, bool hasPair_) external;

    // fee
    function isExcludedFromFees(address acc_) external view returns(bool);
    function excludeFromFees(address acc_, bool bVal_) external;
    function excludeMultipleAccountsFromFees(address[] calldata accounts_, bool bVal_) external;

    // burn
    function burn(uint256 amount_) external;
    function burnFrom(address from_, uint256 amount_) external;
}


// AMA Token
contract AMAToken is Ownable, IAMAToken {
    
    using SafeMath for uint256;

    //////////////////////////////////////////////////////////////////////////////////////

    uint256 constant MAX_UINT256 = ~uint256(0);

    uint256 constant TOKEN_UNIT = 10**18;

    uint256 public constant MAX_SUPPLY = 10**6 * TOKEN_UNIT;            // totalsuppy: 1 million!

    uint256 constant WALLET_BOTTOM_AMT = 10**12;                        // BOTTOM

    uint256 constant TOTAL_INITPOOL_AMT = 100000 * TOKEN_UNIT;          // 10% for init pool
    uint256 constant AMT_PER_LP = 1000 * TOKEN_UNIT;

    uint256 constant FOUNDATION_AMT = 50000 * TOKEN_UNIT;               // 5% for foundation
    uint256 constant FOUNDATION_PER_MONTH = FOUNDATION_AMT / 12;
    uint256 constant TECH_AMT = 50000 * TOKEN_UNIT;                     // 5% for tech
    uint256 constant TECH_PER_MONTH = TECH_AMT / 12;

    uint256 constant IDO_AMT = 40000 * TOKEN_UNIT;                      // 4% for IDO
    uint256 constant DAPP_MININGPOOL_AMT = 740000 * TOKEN_UNIT;         // 74% for Dapp's MiningPool

    uint256 constant OLDAMA_AMT = 20000 * TOKEN_UNIT;                   // 2% for Map old AMA contract

    uint256 private constant SECONDS_PER_MONTH = 24 * 60 * 60 * 30;     // 30 days per a month

    // Direction
    uint256 constant DIRECTION_TRANSFER = 0;
    uint256 constant DIRECTION_BUY = 1;
    uint256 constant DIRECTION_SELL = 2;

    ////////////////////////////////////////////
    // Fees

    uint256 constant FEES_TRANSFER = 3;
    uint256 constant FEES_BUY = 1;
    uint256 constant FEES_SELL = 5;

    //////////////////////////////////////////////////////////////////////////////////////

    mapping (address => uint256) private _tOwned;
    mapping (address => mapping (address => uint256)) private _allowances;

    string private _name = "AMA Token";
    string private _symbol = "AMA";   
    uint8 private _decimals = 18;
    uint256 private _totalSupply;

    mapping(address => bool) private _isExcludedFromFees;

    IUniswapV2Router02 public immutable uniswapV2Router;            // Pancakeswap Router
    address public immutable uniswapV2Pair;                         // AMA/USDT Pair
    mapping(address => bool) public ammPairs;                       // stored all pair address in DEX for diff PublicChain
    IERC20 public usdtToken;                                        // USDT

    uint256 private _lastQuotedPriceTs;
    uint256 private _todayInitPrice;                                // today init price
    address private _initPoolAddr;                                  // The address used to initialize the pool

    uint256 public sellFees = FEES_SELL;

    // FEES
    address private _feeGasAddr;
    address private _feeCommAddr;
    address private _feeLPAddr;

    // foundation & tech
    mapping (address => uint256) private _tClaimed;
    address private _foundationAddr;
    address private _techAddr;
    uint256 public launchTs;

    /////////////////////////////////////////
    
    constructor(address initPoolAddr_, address[] memory initLPs_, address[] memory teamAddrs_, 
                address[] memory feeAddrs_, address[] memory otherAddrs_) {
    
        _initPoolAddr = initPoolAddr_;
        _foundationAddr = teamAddrs_[0];
        _techAddr = teamAddrs_[1];

        _feeCommAddr = feeAddrs_[0];
        _feeLPAddr = feeAddrs_[1];
        _feeGasAddr = feeAddrs_[2];

        /////////////////////////////
        
        usdtToken = IERC20(0x55d398326f99059fF775485246999027B3197955);
        IUniswapV2Router02 uniswapV2Router_ = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);

        uniswapV2Router = uniswapV2Router_;
        address uniswapV2Pair_ = IUniswapV2Factory(uniswapV2Router_.factory()).createPair(address(this), address(usdtToken));
        uniswapV2Pair = uniswapV2Pair_;
        ammPairs[uniswapV2Pair_] = true;

        //////////////////////////////////////////////////

        _isExcludedFromFees[owner()] = true;
        _isExcludedFromFees[address(this)] = true;
        _isExcludedFromFees[_initPoolAddr] = true;
        _isExcludedFromFees[_foundationAddr] = true;
        _isExcludedFromFees[_techAddr] = true;
        _isExcludedFromFees[_feeCommAddr] = true;
        _isExcludedFromFees[_feeLPAddr] = true;
        _isExcludedFromFees[_feeGasAddr] = true;
        _isExcludedFromFees[otherAddrs_[0]] = true;
        _isExcludedFromFees[otherAddrs_[1]] = true;

        ///////////////////////////////////////////////////

        _mintForInitLPs(initLPs_);                  // TOTAL_INITPOOL_AMT
        _mintOthers(otherAddrs_);                   // TOTAL_OTHERS_AMT
        launchTs = block.timestamp;
    }

    receive() external payable {}

    ////////////////////////////

    function getTodayInitPrice() external view override returns(uint) {
        return _todayInitPrice;
    }

    //////////////////////////////

    function isExcludedFromFees(address acc_) public override view returns(bool) {
        return _isExcludedFromFees[acc_];
    }

    function excludeFromFees(address acc_, bool bVal_) public override onlyOwner {
        if ( _isExcludedFromFees[acc_] != bVal_ ) {
            _isExcludedFromFees[acc_] = bVal_;
        }
    }

    function excludeMultipleAccountsFromFees(address[] calldata accounts_, bool bVal_) external override onlyOwner {
        for(uint i = 0; i < accounts_.length; i++) {
            _isExcludedFromFees[accounts_[i]] = bVal_;
        }
    }

    function setAmmPair(address pair_, bool hasPair_) public override onlyOwner{
        ammPairs[pair_] = hasPair_;
    }

    function mapOldAccounts(address oldAMA_, address[] calldata accounts_) public onlyOwner {
        require( oldAMA_ != address(0), "_MOA_01" );
        require( accounts_.length > 0, "_MOA_02" );
        require( _tOwned[owner()] > 0, "_MOA_03" );
        IERC20 oldToken_ = IERC20(oldAMA_);
        for ( uint i = 0; i < accounts_.length; ++i) {
            uint amount_ = oldToken_.balanceOf(accounts_[i]); 
            if ( amount_ > 0 ) {
                require( amount_ > 0 && amount_ <= _tOwned[owner()], "_MOA_04" );
                _pureTransfer(owner(), accounts_[i], amount_, amount_);
            }
        }
    }

    // mint TOTAL_INITPOOL_AMT
    function _mintForInitLPs(address[] memory lps_) private {
        require( lps_.length > 0, "_MLPS_01" );
        require( launchTs == 0, "_MLPS_02" );
        uint initPoolBal_ = TOTAL_INITPOOL_AMT;
        for ( uint i = 0; i < lps_.length; ++i ) {
            _mint(lps_[i], AMT_PER_LP);
            _isExcludedFromFees[lps_[i]] = true;
            initPoolBal_ -= AMT_PER_LP;
        }
        _mint(_initPoolAddr, initPoolBal_);
    }

    /*
        FOUNDATION_AMT，TECH_AMT，IDO_AMT，DAPP_MININGPOOL_AMT, OLDAMA_AMT
    */
    function _mintOthers(address[] memory otherAddrs_) private {
        require( MAX_SUPPLY == (TOTAL_INITPOOL_AMT + FOUNDATION_AMT + TECH_AMT + IDO_AMT + DAPP_MININGPOOL_AMT + OLDAMA_AMT), "_MOTS_01" );
        require( launchTs == 0, "_MOTS_02" );
        _mint(address(this), FOUNDATION_AMT);
        _mint(address(this), TECH_AMT);
        _mint(otherAddrs_[0], IDO_AMT);
        _mint(otherAddrs_[1], DAPP_MININGPOOL_AMT);
        _mint(owner(), OLDAMA_AMT);
    }

    function getFoundationClaimableAmt() public view override returns(uint) {
        return _getClaimableAmt(_foundationAddr, FOUNDATION_AMT, FOUNDATION_PER_MONTH);
    }

    function getFoundationClaimedAmt() public view override returns(uint) {
        return _tClaimed[_foundationAddr];
    }

    function claimFoundation() public override {
        _claim(_foundationAddr, FOUNDATION_AMT, FOUNDATION_PER_MONTH, false);
    }

    function getTechClaimableAmt() public view override returns(uint) {
        return _getClaimableAmt(_techAddr, TECH_AMT, TECH_PER_MONTH);
    }

    function getTechClaimedAmt() public view override returns(uint) {
        return _tClaimed[_techAddr];
    }

    function claimTech() public override {
        _claim(_techAddr, TECH_AMT, TECH_PER_MONTH, false);
    }

    function _getClaimableAmt(address acc_, uint256 totalAmount_, uint256 amtPerMonth_) private view returns(uint amount_) {
        if ( _tClaimed[acc_] < totalAmount_ ) {
            uint _elapsed;
            int _months = int((block.timestamp - launchTs) / SECONDS_PER_MONTH);
            if ( _months < 12) {
                _elapsed = uint(_months) * amtPerMonth_;
            } else {
                _elapsed = totalAmount_;
            }
            amount_ = _elapsed - _tClaimed[acc_];
        }
    }

    function _claim(address acc_, uint256 totalAmount_, uint256 amtPerMonth_, bool silent_) private {
        if ( !silent_ ) {
            require( _tClaimed[acc_] < totalAmount_, "_C_01");
        } else if ( _tClaimed[acc_] >= totalAmount_ ) {
            return;
        }
        uint _elapsed;
        int _months = int((block.timestamp - launchTs) / SECONDS_PER_MONTH);
        if ( _months < 12) {
            _elapsed = uint(_months) * amtPerMonth_;
        } else {
            _elapsed = totalAmount_;
        }
        uint avail_ = _elapsed - _tClaimed[acc_];
        if ( !silent_ ) {
            require( avail_ > 0, "_C_02");
        } else if ( avail_ == 0 ) {
            return;
        }
        _tClaimed[acc_] = _elapsed;
        _pureTransfer(address(this), acc_, avail_, avail_);
    }

    /////////////////////

    function _transfer(address from_, address to_, uint256 amount_) private {

        require( from_ != address(0), "T_01" );
        require( to_ != address(0), "T_02" );
        require( amount_ > 0, "T_03" );
        
        bool bSwap_;
        uint dir_;

        // precheck swap
        {
            if ( ammPairs[from_] ) { // buy
                bSwap_ = true;
                dir_ = DIRECTION_BUY;
            }
            else { 
                if ( ammPairs[to_] ) { // sell
                    if ( IERC20(to_).totalSupply() == 0 ) {
                        require(from_ == _initPoolAddr, "T_04" );
                        bSwap_ = false;
                    }
                    else {
                        bSwap_ = true;
                        dir_ = DIRECTION_SELL;
                    }
                }
            }
        }

        _updateTodayInitPrice();
        
        // transfer amount
        {
            uint tTransferAmt_ = amount_;
            if ( !_isExcludedFromFees[from_] && !_isExcludedFromFees[to_] ) {
                if ( !bSwap_ ) {
                    dir_ = DIRECTION_TRANSFER;
                }
                if ( _tOwned[from_].sub(amount_) < WALLET_BOTTOM_AMT ) {
                    amount_ -= WALLET_BOTTOM_AMT;
                }
                tTransferAmt_ = _takeAllFee(dir_, from_, to_, amount_);
            }
            _pureTransfer(from_, to_, amount_, tTransferAmt_);
            _hitFeesClaimable();
        }
    }

    function _take(address from_, address to_, uint256 tValue_) private {
        _tOwned[to_] = _tOwned[to_].add(tValue_);
        emit Transfer(from_, to_, tValue_);
    }

    //
    function _takeAllFee(uint256 dir_, address from_, address to_, uint256 amount_) private returns(uint tTransferAmt_) {

        uint[] memory fees_ = new uint[](4);
        
        if ( dir_ == DIRECTION_TRANSFER ) {
            fees_[3] = amount_.mul(FEES_TRANSFER).div(100);
            fees_[0] = fees_[3].mul(1).div(3);
            fees_[1] = fees_[0];
            fees_[2] = fees_[0];
        } else {
            if ( ammPairs[from_] ) { // buy
                fees_[3] = amount_.mul(FEES_BUY).div(100);
                fees_[2] = fees_[3];
            }
            else if ( ammPairs[to_] ) { // sell
                _adjustSellFee();
                fees_[3] = amount_.mul(sellFees).div(100);
                fees_[0] = fees_[3].mul(3).div(5);
                fees_[1] = fees_[3].mul(1).div(5);
                fees_[2] = fees_[1];
            }
        }

        // transfer amount
        tTransferAmt_ = amount_.sub(fees_[3]);

        // community
        if (fees_[0] > 0) {
            _take(from_, _feeCommAddr, fees_[0]);
        }

        // LP
        if (fees_[1] > 0) {
            _take(from_, _feeLPAddr, fees_[1]); 
        }

        // GAS
        if (fees_[2] > 0) {
            _take(from_, _feeGasAddr, fees_[2]);
        }
    }

    function _pureTransfer(address from_, address to_, uint256 sendAmount_, uint256 receviedAmount_ ) private {
        _tOwned[from_] = _tOwned[from_].sub(sendAmount_, "_PT_01");
        _tOwned[to_] = _tOwned[to_].add(receviedAmount_);
        emit Transfer(from_, to_, receviedAmount_);
    }

    ///////////////////////////////////////////////////////////////////////

    function _updateTodayInitPrice() private {
        uint today_ = block.timestamp - (block.timestamp + 28800) % 86400;
        if ( _todayInitPrice == 0 || today_ != _lastQuotedPriceTs ) {
            _lastQuotedPriceTs = today_;
            sellFees = FEES_SELL;
            _todayInitPrice = _getPrice();
        }
    }

    function _adjustSellFee() private {
        uint price_ = _getPrice();
        if ( price_ > 0 && price_ < _todayInitPrice ) {
            uint downedAmt_ = _todayInitPrice - price_;
            uint[3] memory rates_ = [uint(30), 20, 10];
            bool found_;
            for ( uint i = 0; i < rates_.length; ++i ) {
                if ( downedAmt_ >= _todayInitPrice.mul(rates_[i]).div(100) ) {
                    sellFees = rates_[i];
                    found_ = true;
                    break;
                }
            }
            if ( !found_ && sellFees != FEES_SELL) {
                sellFees = FEES_SELL;
            }
        }
    }

    function _hitFeesClaimable() private {
        if ( _getClaimableAmt(_foundationAddr, FOUNDATION_AMT, FOUNDATION_PER_MONTH) > 0 ) {
            _claim(_foundationAddr, FOUNDATION_AMT, FOUNDATION_PER_MONTH, true);
        }
        if ( _getClaimableAmt(_techAddr, TECH_AMT, TECH_PER_MONTH) > 0 ) {
            _claim(_techAddr, TECH_AMT, TECH_PER_MONTH, true);
        }
    }

    function _getPrice() private view returns(uint price_) {
        if ( IUniswapV2Pair(uniswapV2Pair).totalSupply() == 0 ) {
            return 0;
        }
        address tA_ = address(usdtToken);
        address tB_ = address(this);
        (address t0_,) = tA_ < tB_ ? (tA_, tB_) : (tB_, tA_);
        (uint rA_, uint rB_,) = IUniswapV2Pair(uniswapV2Pair).getReserves();
        (uint r0_, uint r1_) = t0_ == tA_ ? (rA_, rB_) : (rB_, rA_);
        if ( r1_ > 0 ) {
            price_ = r0_.mul(TOKEN_UNIT).div(r1_);
        }
    }

    ////////////////////////////////////////////////////////////////

    function name() public view override returns (string memory) {
        return _name;
    }

    function symbol() public view override returns (string memory) {
        return _symbol;
    }

    function decimals() public view override returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address acc_) public view override returns (uint256) {
        return _tOwned[acc_];
    }

    function transfer(address to_, uint256 amount_) public override returns (bool) {
        _transfer(_msgSender(), to_, amount_);
        return true;
    }

    function allowance(address owner_, address spender_) public view override returns (uint256) {
        return _allowances[owner_][spender_];
    }

    function approve(address spender_, uint256 amount_) public override returns (bool) {
        _approve(_msgSender(), spender_, amount_);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount_) public override returns (bool) {
        _transfer(sender, recipient, amount_);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount_, "TF_01"));
        return true;
    }

    function increaseAllowance(address spender_, uint256 addedValue_) public virtual returns (bool) {
        _approve(_msgSender(), spender_, _allowances[_msgSender()][spender_].add(addedValue_));
        return true;
    }

    function decreaseAllowance(address spender_, uint256 subtractedValue_) public virtual returns (bool) {
        _approve(_msgSender(), spender_, _allowances[_msgSender()][spender_].sub(subtractedValue_, "DA_01"));
        return true;
    }

    function burn(uint amount_) public override {
        _burn(_msgSender(), amount_);
    }

    function burnFrom(address from_, uint amount_) public override {
        _approve(from_, _msgSender(), _allowances[from_][_msgSender()].sub(amount_, "BF_01"));
        _burn(from_, amount_);
    }

    function _approve(address owner_, address spender_, uint256 amount_) private {
        require(owner_ != address(0), "_APV_01");
        require(spender_ != address(0), "_APV_02");
        _allowances[owner_][spender_] = amount_;
        emit Approval(owner_, spender_, amount_);
    }

   function _mint(address to_, uint amount_) private {
        _totalSupply = _totalSupply.add(amount_);
        _tOwned[to_] = _tOwned[to_].add(amount_);
        emit Transfer(address(0), to_, amount_);
    }

    function _burn(address from_, uint amount_) private {
        _tOwned[from_] = _tOwned[from_].sub(amount_);
        _totalSupply = _totalSupply.sub(amount_);
        emit Transfer(from_, address(0), amount_);
    }
}