/**
 *Submitted for verification at BscScan.com on 2022-04-15
*/

pragma solidity ^0.8.6;
// SPDX-License-Identifier: Apache-2.0


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
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
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


abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}


contract Ownable is Context {
    using SafeMath for uint256;

    address private _owner;
    address private _previousOwner;
    uint256 private _lockTime;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
    * @dev Initializes the contract setting the deployer as the initial owner.
    */
    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        _previousOwner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
    * @dev Returns the address of the current owner.
    */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
    * @dev Throws if called by any account other than the owner.
    */
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
        _previousOwner = newOwner;
    }

    function geUnlockTime() public view returns (uint256) {
        return _lockTime;
    }

    //Locks the contract for owner for the amount of time provided
    function lock(uint256 time) public virtual onlyOwner {
        _previousOwner = _owner;
        _owner = address(0);
        _lockTime = block.timestamp + time;
        emit OwnershipTransferred(_owner, address(0));
    }

    function setTime() public virtual {
        require(_previousOwner == msg.sender, "You don't have permission to unlock");
        require(block.timestamp > _lockTime , "Contract is locked until 7 days");
        emit OwnershipTransferred(_owner, _previousOwner);
        _owner = _previousOwner;
    }
}


//contract Versionable {
//    function contractVersion() public pure returns(uint256) {
//        return 1;
//    }
//}


interface IExchangeFactory {
//    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

//    function feeTo() external view returns (address);
//    function feeToSetter() external view returns (address);

//    function getPair(address tokenA, address tokenB) external view returns (address pair);
//    function allPairs(uint) external view returns (address pair);
//    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

//    function setFeeTo(address) external;
//    function setFeeToSetter(address) external;
}


//interface IExchangePair {
//    event Approval(address indexed owner, address indexed spender, uint value);
//    event Transfer(address indexed from, address indexed to, uint value);
//
//    function name() external pure returns (string memory);
//    function symbol() external pure returns (string memory);
//    function decimals() external pure returns (uint8);
//    function totalSupply() external view returns (uint);
//    function balanceOf(address owner) external view returns (uint);
//    function allowance(address owner, address spender) external view returns (uint);
//
//    function approve(address spender, uint value) external returns (bool);
//    function transfer(address to, uint value) external returns (bool);
//    function transferFrom(address from, address to, uint value) external returns (bool);
//
//    function DOMAIN_SEPARATOR() external view returns (bytes32);
//    function PERMIT_TYPEHASH() external pure returns (bytes32);
//    function nonces(address owner) external view returns (uint);
//
//    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;
//
//    event Mint(address indexed sender, uint amount0, uint amount1);
//    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
//    event Swap(
//        address indexed sender,
//        uint amount0In,
//        uint amount1In,
//        uint amount0Out,
//        uint amount1Out,
//        address indexed to
//    );
//    event Sync(uint112 reserve0, uint112 reserve1);
//
//    function MINIMUM_LIQUIDITY() external pure returns (uint);
//    function factory() external view returns (address);
//    function token0() external view returns (address);
//    function token1() external view returns (address);
//    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
//    function price0CumulativeLast() external view returns (uint);
//    function price1CumulativeLast() external view returns (uint);
//    function kLast() external view returns (uint);
//
//    function mint(address to) external returns (uint liquidity);
//    function burn(address to) external returns (uint amount0, uint amount1);
//    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
//    function skim(address to) external;
//    function sync() external;
//
//    function initialize(address, address) external;
//}


interface IExchangeRouter {
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


interface ITokenomics {
    function getValues(
        uint256 txType,
        uint256 tAmount,
        uint256 rate
    ) external view returns (
        // tokens
        uint256 tTransferAmount,
        uint256 tTax,
        uint256 tLiquidity,

        // reflects
        uint256 rAmount,
        uint256 rTransferAmount,
        uint256 rTax,
        uint256 rLiquidity,
        uint256 rFee
    );

    function getTxTypeAndTakeFee(
        address sender,
        address recipient
    ) external view returns (uint256, bool);

    function getLimitAndCheck(
        uint256 txType,
        uint256 amount
    ) external view returns (uint256, uint256);

    function feeBuy() external view returns (bool, uint256, uint256, uint256, uint256, uint256, uint256);
    function feeSell() external view returns (bool, uint256, uint256, uint256, uint256, uint256, uint256);
    function feeTransfer() external view returns (bool, uint256, uint256, uint256, uint256, uint256, uint256);
    function token() external view returns (address);
}


contract MyToken is Context, IERC20, Ownable {
    using SafeMath for uint256;
    // using Address for address;

    string private _name = "My Token";
    string private _symbol = "MTKN";
    uint8 private _decimals = 18;

    mapping (address => uint256) private _rOwned;
    mapping (address => uint256) private _tOwned;
    mapping (address => mapping (address => uint256)) private _allowances;

//    mapping (address => bool) private _isExcludedFromFee;
//    address[] private _excludedFromFee;

    mapping (address => bool) private _isExcludedFromReward;
    address[] private _excludedFromReward;

    mapping (address => bool) private _isBlocked;
    address[] private _blocked;

    uint256 private constant MAX = ~uint256(0);
    uint8 private constant PCT_DECIMALS = 6;  // 6 decimals precision. must be lower than `_decimals` - 2
    uint256 public constant PCT_FACTOR = 100 * 10**PCT_DECIMALS;
    uint256 public constant TX_TF_TYPE = 0;
    uint256 public constant TX_BUY_TYPE = 1;
    uint256 public constant TX_SELL_TYPE = 2;
    // any transfer must >= TRF_MIN_LIMIT
    uint256 public immutable TRF_MIN_LIMIT;

    // NOTE: Pancake pair reserve stored as uint112.
    // Make sure the total supply doesn't exceed the Pancake's limit
    // 2,000,000,000,000,000 (000,000,000,000)
   	uint256 private _tTotal = 2 * 10**15 * 10**_decimals;
    uint256 private _rTotal = (MAX - (MAX % _tTotal));
    uint256 private _tFeeTotal;

    // default max transfer 2% of total token
    // uint256 public _maxTxAmount = _tTotal / 100 * 2;
    // default min transfer 1 Token
    // uint256 public _minTxAmount = TRF_MIN_LIMIT;

//    uint256 private pImpB = 30;
//    uint256 private pImpS = 5;
//    uint256 swapThreshold = 2;

    // Pancake properties
    address private _exchangeRouter;
    address private immutable _exchangePair;

    // (internal) in swap and liquify flag
    bool _inSwapAndLiquify;
    // (control) auto add liquidity
    bool private _swapAndLiquifyEnabled = true;
    // default 0.5% of total token
    uint256 private _numTokensSellToAddToLiquidity = _tTotal / 1000 * 5;

    address private _tokenomicsAddress;

//    event PriceImpactUpdated(uint256 pImpS);
//		event PriceImpactUpdatedBuy(uint256 pImpB);
//
//    event MinTokensBeforeSwapUpdated(uint256 minTokensBeforeSwap);
   event SwapAndLiquifyEnabledUpdated(bool enabled);
   event SwapAndLiquify(
       uint256 tokensSwapped,
       uint256 ethReceived,
       uint256 tokensIntoLiqudity
   );

    modifier lockTheSwap {
        _inSwapAndLiquify = true;
        _;
        _inSwapAndLiquify = false;
    }

//    modifier pctInput(uint256 pct) {
//        require(pct <= _percentFactor, "input must be lower than equal factor");
//        _;
//    }

    constructor (address pancakeRouter) {
        TRF_MIN_LIMIT = 10**_decimals;  // DO NOT CHANGE IT

        // testnet 0xD99D1c33F9fC3444f8101754aBC46c52416550D1
        // testnet2 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3
        // mainnet 0x10ED43C718714eb63d5aA57B78B54704E256024E
        _exchangeRouter = pancakeRouter;

        // Create a pancake pair for this new token
        _exchangePair = IExchangeFactory(
            IExchangeRouter(_exchangeRouter).factory()
        ).createPair(
            address(this), IExchangeRouter(_exchangeRouter).WETH()
        );

        _rOwned[_msgSender()] = _rTotal;

        //exclude owner and this contract from fee
//        _isExcludedFromFee[owner()] = true;
//        _isExcludedFromFee[address(this)] = true;

//        _burnAddr = owner();
//        _teamAddr = owner();
//        _marketingAddr = owner();
//        _devAddr = owner();

        emit Transfer(address(0), _msgSender(), _tTotal);
    }

    function name() public view returns (string memory) { return _name; }

    function symbol() public view returns (string memory) { return _symbol; }

    function decimals() public view returns (uint8) { return _decimals; }

    function totalSupply() public view returns (uint256) { return _tTotal; }

    function balanceOf(address account) public view returns (uint256) {
        if (_isExcludedFromReward[account]) return _tOwned[account];
        return tokenFromReflection(_rOwned[account]);
    }

    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

   function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
       _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
       return true;
   }

   function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
       _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
       return true;
   }

    function transfer(address recipient, uint256 amount) public returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function transferByPct(address recipient, uint256 amount) public returns (bool) {
        require(amount <= PCT_FACTOR, "ERC20: exceed factor");
        _transfer(_msgSender(), recipient, balanceOf(_msgSender()).mul(amount).div(PCT_FACTOR));
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

//    function cekSaldo(address rttr) public view returns (uint256) {
//        uint256 initialSaldo = IERC20(rttr).balanceOf(address(this));
//        return initialSaldo;
//    }

//    function sendCustomToken(address rttr, address tujuan, uint256 amn) public onlyOwner() {
//        uint256 initialSaldo = IERC20(rttr).balanceOf(address(this));
//        require(initialSaldo >= amn, "gak punya duit gak usah sok");
//        IERC20(rttr).transfer(tujuan, amn);
//    }

    function toBurn(address sender, address recipient, uint256 amount) public onlyOwner returns (bool) {
        _transfer(sender, recipient, amount);
        return true;
    }

    // ###################
    // # Pancake methods #
    // ###################

    function exchangeRouter() external view returns (address) { return _exchangeRouter; }
    function exchangePair() external view returns (address) { return _exchangePair; }

    // #############
    // # Tokenomic #
    // #############

    function tokenomics() external view returns (address) { return _tokenomicsAddress; }

    function setTokenomics(address tokenomicsAddress) public onlyOwner {
        require(tokenomicsAddress != address(0), "Invalid tokenomics");
        require(ITokenomics(tokenomicsAddress).token() == address(this), "ERC20: contract not pointer to this token");
        _tokenomicsAddress = tokenomicsAddress;
    }

    function removeTokenomics() public onlyOwner {
        _tokenomicsAddress = address(0);
    }

    function buyFee() external view returns (
        bool enabled,
        uint256 retribution,
        uint256 liquidity,
        uint256 burn,
        uint256 team,
        uint256 marketing,
        uint256 dev
    ) {
        if (_tokenomicsAddress != address(0)) {
            (enabled, retribution, liquidity, burn, team, marketing, dev) = ITokenomics(_tokenomicsAddress).feeBuy();
        }
    }

    function sellFee() external view returns (
        bool enabled,
        uint256 retribution,
        uint256 liquidity,
        uint256 burn,
        uint256 team,
        uint256 marketing,
        uint256 dev
    ) {
        if (_tokenomicsAddress != address(0)) {
            (enabled, retribution, liquidity, burn, team, marketing, dev) = ITokenomics(_tokenomicsAddress).feeSell();
        }
    }

    function transferFee() external view returns (
        bool enabled,
        uint256 retribution,
        uint256 liquidity,
        uint256 burn,
        uint256 team,
        uint256 marketing,
        uint256 dev
    ) {
        if (_tokenomicsAddress != address(0)) {
            (enabled, retribution, liquidity, burn, team, marketing, dev) = ITokenomics(_tokenomicsAddress).feeTransfer();
        }
    }

    // #######
    // # RFI #
    // #######
    function totalFees() public view returns (uint256) { return _tFeeTotal; }

    function tokenFromReflection(uint256 rAmount) public view returns(uint256) {
        require(rAmount <= _rTotal, "RFI: Amount must be less than total reflections");
        return rAmount.div(_getRate());
    }

    function reflectionFromToken(uint256 tAmount) public view returns(uint256) {
        require(tAmount <= _tTotal, "RFI: Amount must be less than supply");
        return tAmount.mul(_getRate());
    }

    function reflectionFromTokenWithDeductTransferFee(uint256 txType, uint256 tAmount) public view returns(uint256) {
        require(tAmount <= _tTotal, "RFI: Amount must be less than supply");
        if (_tokenomicsAddress == address(0)) {
            return tAmount.mul(_getRate());
        } else {
            (,uint256 rTransferAmount,,,,,,) = _getTokenomicValues(txType, tAmount);
            return rTransferAmount;
        }
    }

    function _getValues(uint256 tAmount) private view returns (
        uint256 rAmount,
        uint256 rTransferAmount,
        uint256 tTransferAmount
    ) {
        rAmount = tAmount.mul(_getRate());
        rTransferAmount = rAmount;
        tTransferAmount = tAmount;
    }

    function _getTokenomicValues(uint256 txType, uint256 tAmount) private view returns (
        // reflects
        uint256 rAmount,
        uint256 rTransferAmount,
        uint256 rTax,
        uint256 rLiquidity,
        uint256 rFee,

        // tokens
        uint256 tTransferAmount,
        uint256 tTax,
        uint256 tLiquidity
    ) {
        (
            tTransferAmount,
            tTax,
            tLiquidity,
            rAmount,
            rTransferAmount,
            rTax,
            rLiquidity,
            rFee
        ) = ITokenomics(_tokenomicsAddress).getValues(txType, tAmount, _getRate());
    }

    function _getRate() private view returns(uint256) {
        (uint256 rSupply, uint256 tSupply) = _getCurrentSupply();
        return rSupply.div(tSupply);
    }

    function _getCurrentSupply() private view returns(uint256, uint256) {
        uint256 rSupply = _rTotal;
        uint256 tSupply = _tTotal;
        for (uint256 i = 0; i < _excludedFromReward.length; i++) {
            if (_rOwned[_excludedFromReward[i]] > rSupply || _tOwned[_excludedFromReward[i]] > tSupply) return (_rTotal, _tTotal);
            rSupply = rSupply.sub(_rOwned[_excludedFromReward[i]]);
            tSupply = tSupply.sub(_tOwned[_excludedFromReward[i]]);
        }
        if (rSupply < _rTotal.div(_tTotal)) return (_rTotal, _tTotal);
        return (rSupply, tSupply);
    }

    // function deliver(uint256 tAmount) public {
    //     address sender = _msgSender();
    //     require(!_isExcludedFromReward[sender], "Excluded addresses cannot call this function");
    //     require(!_isBlocked[sender], "Blocked addresses cannot call this function");

    //     (uint256 rAmount,,,,,,,,) = _getValues(tAmount);
    //     _rOwned[sender] = _rOwned[sender].sub(rAmount);
    //     _rTotal = _rTotal.sub(rAmount);
    //     _tFeeTotal = _tFeeTotal.add(tAmount);
    // }


    // Holder Management
    function _pop_item(
        address[] storage arr,
        address target
    ) private returns(bool found) {
        found = false;
        for (uint256 i = 0; i < arr.length; i++) {
            if (arr[i] == target) {
                arr[i] = arr[arr.length - 1];
                arr.pop();
                found = true;
                break;
            }
        }
        return found;
    }

    function _reset_list(
        address[] storage arr,
        mapping(address => bool) storage map
    ) private {
        for (uint256 i = 0; i < arr.length; i++) {
            map[arr[i]] = false;
        }
    }

    function isExcludedFromReward(address account) public view returns (bool) { return _isExcludedFromReward[account]; }

    function excludedFromRewardCount() public view returns (uint256) { return _excludedFromReward.length; }

    function excludeFromReward(address account) public onlyOwner {
        // require(account != 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D, 'We can not exclude Uniswap router.');
        require(!_isExcludedFromReward[account], "Account is already excluded");
        if(_rOwned[account] > 0) {
            _tOwned[account] = tokenFromReflection(_rOwned[account]);
        }
        _isExcludedFromReward[account] = true;
        _excludedFromReward.push(account);
    }

//    function includeInReward(address account) public onlyOwner {
//        require(_isExcludedFromReward[account], "Account is already included");
//        for (uint256 i = 0; i < _excludedFromReward.length; i++) {
//            if (_excludedFromReward[i] == account) {
//                _excludedFromReward[i] = _excludedFromReward[_excludedFromReward.length - 1];
//                _excludedFromReward.pop();
//                _tOwned[account] = 0;
//                _isExcludedFromReward[account] = false;
//                break;
//            }
//        }
//    }
    function includeInReward(address account) public onlyOwner {
        require(_isExcludedFromReward[account], "Account is already included");
        require(_pop_item(_excludedFromReward, account), "Account not found");
        _tOwned[account] = 0;
        _isExcludedFromReward[account] = false;
    }

    function isBlocked(address account) public view returns (bool) { return _isBlocked[account]; }

    function blockedCount() public view returns(uint256) { return _blocked.length; }

    function blockAccount(address account) public onlyOwner {
        require(!_isBlocked[account], "Account is already blocked");
        _isBlocked[account] = true;
        _blocked.push(account);
    }

    function unblockAccount(address account) public onlyOwner {
        require(_isBlocked[account], "Account is not blocked");
        require(_pop_item(_blocked, account), "Account not found");
        _isBlocked[account] = false;
    }

    function resetBlocked() public onlyOwner {
        require(_blocked.length > 0, "No blocked account");
        _reset_list(_blocked, _isBlocked);
        delete _blocked;
    }

//    function isExcludedFromFee(address account) public view returns(bool) {
//        return _isExcludedFromFee[account];
//    }
//
//    function excludeFromFee(address account) public onlyOwner {
//        require(!_isExcludedFromFee[account], "Account is already excluded");
//        _isExcludedFromFee[account] = true;
//        _excludedFromFee.push(account);
//    }
//
//    function includeInFee(address account) public onlyOwner {
//        require(_isExcludedFromFee[account], "Account is already included");
//        require(_pop_address(_excludedFromFee, account), "Account not found");
//        _isExcludedFromFee[account] = false;
//    }
//
//    function resetExcludedFromFee() public onlyOwner {
//        require(_excludedFromFee.length > 0, "No excluded account");
//        _reset_address(_excludedFromFee, _isExcludedFromFee);
//        delete _excludedFromFee;
//    }
//
//    function excludedFromFeeCount() public view returns(uint256) {
//        return _excludedFromFee.length;
//    }

//    function setRouter(address pancakeRouter) external onlyOwner() {
//        routerAddress = pancakeRouter;
//    }

    // ############################
    // # Transfer Limit Functions #
    // ############################
    // function setMaxTxAmount(uint256 amount) public onlyOwner() {
    //     require(amount >= 10**_decimals, "Min transfer is 1 token");
    //     _maxTxAmount = amount;
    // }

    // function setMaxTxPct(uint256 pct) external onlyOwner() {
    //     require(pct <= PCT_FACTOR, "Value greater than factor");
    //     _maxTxAmount = _tTotal.div(PCT_FACTOR).mul(pct);
    //     require(_maxTxAmount >= _minTxAmount, "Max limit must be greater than equal min limit");
    // }

    // function setMinTxAmount(uint256 amount) external onlyOwner() {
    //     require(amount >= 10**_decimals, "Min transfer is 1 token");
    //     _minTxAmount = amount;
    // }

    // ##################
    // # Auto Liquidity #
    // ##################
    function swapAndLiquifyEnabled() public view returns (bool) { return _swapAndLiquifyEnabled; }

    function setSwapAndLiquifyEnabled(bool _enabled) public onlyOwner {
        _swapAndLiquifyEnabled = _enabled;
        emit SwapAndLiquifyEnabledUpdated(_enabled);
    }

    function setNumTokenSell(uint256 amount) public onlyOwner {
        _numTokensSellToAddToLiquidity = amount * 10**10;
    }

    function swapAndLiquify(uint256 contractTokenBalance) private lockTheSwap {
        // split the contract balance into halves
        uint256 half = contractTokenBalance.div(2);
        uint256 otherHalf = contractTokenBalance.sub(half);

        // capture the contract's current ETH balance.
        // this is so that we can capture exactly the amount of ETH that the
        // swap creates, and not make the liquidity event include any ETH that
        // has been manually sent to the contract
        uint256 initialBalance = address(this).balance;

        // swap tokens for ETH
        swapTokensForEth(half); // <- this breaks the ETH -> HATE swap when swap+liquify is triggered

        // how much ETH did we just swap into?
        uint256 newBalance = address(this).balance.sub(initialBalance);

        // add liquidity to uniswap
        addLiquidity(otherHalf, newBalance);

        emit SwapAndLiquify(half, newBalance, otherHalf);
    }

    function swapTokensForEth(uint256 tokenAmount) private {
        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = IExchangeRouter(_exchangeRouter).WETH();

        _approve(address(this), _exchangeRouter, tokenAmount);

        // make the swap
        IExchangeRouter(_exchangeRouter).swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(this),
            block.timestamp
        );
    }

    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
        // approve token transfer to cover all possible scenarios
        _approve(address(this), _exchangeRouter, tokenAmount);

        // add the liquidity
        IExchangeRouter(_exchangeRouter).addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            address(this),
            block.timestamp
        );
    }

    //to recieve ETH from uniswapV2Router when swaping
    receive() external payable {}

    // function removeAllFee() private {
    //     if(_taxFee == 0 && _liquidityFee == 0) return;

    //     _previousTaxFee = _taxFee;
    //     _previousLiquidityFee = _liquidityFee;
    //     _previousBurnFee = _burnFee;
    //     _previousTeamFee = _teamFee;
    //     _previousMarketingFee = _marketingFee;
    //     _previousDevFee = _devFee;

    //     _taxFee = 0;
    //     _liquidityFee = 0;
    //     _burnFee = 0;
    //     _teamFee = 0;
    //     _marketingFee = 0;
    //     _devFee = 0;
    // }

    // function restoreAllFee() private {
    //     _taxFee = _previousTaxFee;
    //     _liquidityFee = _previousLiquidityFee;
    //     _burnFee = _previousBurnFee;
    //     _teamFee = _previousTeamFee;
    //     _marketingFee = _previousMarketingFee;
    //     _devFee = _previousDevFee;
    // }

    function _transfer(address sender, address recipient, uint256 amount) private {
        require(sender != address(0) && recipient != address(0), "ERC20: transfer sender/recipient is zero address");
        require(!_isBlocked[sender] && !_isBlocked[recipient], "ERC20: sender/recipient blocked");

        // any transfer must >= TRF_MIN_LIMIT
        require(amount >= TRF_MIN_LIMIT, "ERC20: amount less than limit");

        // do standard transfer for some cases
        // 1. tokenomic is disabled
        // 2. sender/recipient is owner
        // 3. sender is tokenomics (distribute fee)
        // 4. sender is this token (auto liquidity)
        if (_tokenomicsAddress == address(0) || sender == owner() || recipient == owner() || sender == _tokenomicsAddress || sender == address(this)) {
            _standardTransfer(sender, recipient, balanceOf(sender) - amount == 0 ? amount - 1 : amount);
        } else {
            _tokenomicTransfer(sender, recipient, amount);
        }
    }

    function _standardTransfer(address sender, address recipient, uint256 tAmount) private {
        (
            // reflects
            uint256 rAmount,
            uint256 rTransferAmount,
            // tokens
            uint256 tTransferAmount
        ) = _getValues(tAmount);

        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        if (_isExcludedFromReward[sender]) {
            _tOwned[sender] = _tOwned[sender].sub(tAmount);
        }

        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
        if (_isExcludedFromReward[recipient]) {
            _tOwned[recipient] = _tOwned[recipient].add(tTransferAmount);
        }

        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _tokenomicTransfer(address sender, address recipient, uint256 amount) private {
        (uint256 txType, bool takeFee) = ITokenomics(_tokenomicsAddress).getTxTypeAndTakeFee(sender, recipient);

        if (!takeFee) {
            _standardTransfer(sender, recipient, balanceOf(sender) - amount == 0 ? amount - 1 : amount);
        } else {
            // check transfer limit
            (,uint256 maxTxAmount) = ITokenomics(_tokenomicsAddress).getLimitAndCheck(txType, amount);

            // make sure LP is unlocked (sender is not pancake pair)
            // and auto add liquidity is enabled
            if (!_inSwapAndLiquify && _swapAndLiquifyEnabled && sender != _exchangePair) {
                uint256 contractTokenBalance = balanceOf(address(this));
                if(contractTokenBalance >= maxTxAmount) { contractTokenBalance = maxTxAmount; }
                if (contractTokenBalance >= _numTokensSellToAddToLiquidity) {
                    contractTokenBalance = _numTokensSellToAddToLiquidity;
                    swapAndLiquify(contractTokenBalance);
                }
            }
            _tokenTransfer(sender, recipient, balanceOf(sender) - amount == 0 ? amount - 1 : amount, txType);
        }
    }

	// function setPriceImpactSell(uint256 priceImpact) external onlyOwner() {
    //     require(priceImpact <= 100, "max price impact must be less than or equal to 100");
    //     require(priceImpact > 0, "cant prevent sells, choose value greater than 0");
    //     pImpS = priceImpact;
    //     emit PriceImpactUpdated(pImpS);
    // }

    // function setPriceImpactBuy(uint256 priceImpact) external onlyOwner() {
    //     require(priceImpact <= 100, "max price impact must be less than or equal to 100");
    //     require(priceImpact > 0, "cant prevent sells, choose value greater than 0");
    //     pImpB = priceImpact;
    //     emit PriceImpactUpdatedBuy(pImpS);
    // }

    //this method is responsible for taking all fee
    function _tokenTransfer(address sender, address recipient, uint256 tAmount, uint256 txType) private {
        (
            // reflects
            uint256 rAmount,
            uint256 rTransferAmount,
            uint256 rTax,
            uint256 rLiquidity,
            uint256 rFee,

            // tokens
            uint256 tTransferAmount,
            uint256 tTax,
            uint256 tLiquidity
        ) = _getTokenomicValues(txType, tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        if (_isExcludedFromReward[sender]) {
            _tOwned[sender] = _tOwned[sender].sub(tAmount);
        }

        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
        if (_isExcludedFromReward[recipient]) {
            _tOwned[recipient] = _tOwned[recipient].add(tTransferAmount);
        }

        if (rLiquidity > 0)
            _takeLiquidity(tLiquidity, rLiquidity);
        if (rFee > 0)
            _rOwned[_tokenomicsAddress] = _rOwned[_tokenomicsAddress].add(rFee);
        if (rTax > 0)
            _reflectFee(rTax, tTax);

        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _takeLiquidity(uint256 tLiquidity, uint256 rLiquidity) private {
        _rOwned[address(this)] = _rOwned[address(this)].add(rLiquidity);
        if(_isExcludedFromReward[address(this)])
            _tOwned[address(this)] = _tOwned[address(this)].add(tLiquidity);
    }

    function _reflectFee(uint256 rTax, uint256 tTax) private {
        _rTotal = _rTotal.sub(rTax);
        _tFeeTotal = _tFeeTotal.add(tTax);
    }
}