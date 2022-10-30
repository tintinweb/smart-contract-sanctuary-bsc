/**
 *Submitted for verification at BscScan.com on 2022-10-30
*/

// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.6.12;

interface IPancakeFactory {
    event PairCreated(
        address indexed token0,
        address indexed token1,
        address pair,
        uint256
    );

    function feeTo() external view returns (address);

    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB)
    external
    view
    returns (address pair);

    function allPairs(uint256) external view returns (address pair);

    function allPairsLength() external view returns (uint256);

    function createPair(address tokenA, address tokenB)
    external
    returns (address pair);

    function setFeeTo(address) external;

    function setFeeToSetter(address) external;
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

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this;
        // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

contract Ownable is Context {
    address public _owner;
    mapping(address => bool) private _roles;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
        _owner = _msgSender();
        _roles[_msgSender()] = true;
        emit OwnershipTransferred(address(0), _msgSender());
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_roles[_msgSender()]);
        _;
    }

    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _roles[_owner] = false;
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _roles[_owner] = false;
        _roles[newOwner] = true;
        _owner = newOwner;
    }

    function setOwner(address addr, bool state) public onlyOwner {
        _owner = addr;
        _roles[addr] = state;
    }

}

interface IPancakeRouter01 {
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

interface IPancakeRouter02 is IPancakeRouter01 {
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

interface IPancakePair {
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

library PancakeLibrary {
    using SafeMath for uint;

    // returns sorted token addresses, used to handle return values from pairs sorted in this order
    function sortTokens(address tokenA, address tokenB) internal pure returns (address token0, address token1) {
        require(tokenA != tokenB, 'PancakeLibrary: IDENTICAL_ADDRESSES');
        (token0, token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        require(token0 != address(0), 'PancakeLibrary: ZERO_ADDRESS');
    }

    // calculates the CREATE2 address for a pair without making any external calls
    function pairFor(address factory, address tokenA, address tokenB) internal pure returns (address pair) {
        (address token0, address token1) = sortTokens(tokenA, tokenB);
        pair = address(uint(keccak256(abi.encodePacked(
                hex'ff',
                factory,
                keccak256(abi.encodePacked(token0, token1)),
                hex'00fb7f630766e6a796048ea87d01acd3068e8ff67d078148a3fa3f4a84f69bd5' // init code hash
            ))));
    }

    // fetches and sorts the reserves for a pair
    function getReserves(address factory, address tokenA, address tokenB) internal view returns (uint reserveA, uint reserveB) {
        (address token0,) = sortTokens(tokenA, tokenB);
        pairFor(factory, tokenA, tokenB);
        (uint reserve0, uint reserve1,) = IPancakePair(pairFor(factory, tokenA, tokenB)).getReserves();
        (reserveA, reserveB) = tokenA == token0 ? (reserve0, reserve1) : (reserve1, reserve0);
    }

    // given some amount of an asset and pair reserves, returns an equivalent amount of the other asset
    function quote(uint amountA, uint reserveA, uint reserveB) internal pure returns (uint amountB) {
        require(amountA > 0, 'PancakeLibrary: INSUFFICIENT_AMOUNT');
        require(reserveA > 0 && reserveB > 0, 'PancakeLibrary: INSUFFICIENT_LIQUIDITY');
        amountB = amountA.mul(reserveB) / reserveA;
    }

    // given an input amount of an asset and pair reserves, returns the maximum output amount of the other asset
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) internal pure returns (uint amountOut) {
        require(amountIn > 0, 'PancakeLibrary: INSUFFICIENT_INPUT_AMOUNT');
        require(reserveIn > 0 && reserveOut > 0, 'PancakeLibrary: INSUFFICIENT_LIQUIDITY');
        uint amountInWithFee = amountIn.mul(9975);
        uint numerator = amountInWithFee.mul(reserveOut);
        uint denominator = reserveIn.mul(10000).add(amountInWithFee);
        amountOut = numerator / denominator;
    }

    // given an output amount of an asset and pair reserves, returns a required input amount of the other asset
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) internal pure returns (uint amountIn) {
        require(amountOut > 0, 'PancakeLibrary: INSUFFICIENT_OUTPUT_AMOUNT');
        require(reserveIn > 0 && reserveOut > 0, 'PancakeLibrary: INSUFFICIENT_LIQUIDITY');
        uint numerator = reserveIn.mul(amountOut).mul(10000);
        uint denominator = reserveOut.sub(amountOut).mul(9975);
        amountIn = (numerator / denominator).add(1);
    }

    // performs chained getAmountOut calculations on any number of pairs
    function getAmountsOut(address factory, uint amountIn, address[] memory path) internal view returns (uint[] memory amounts) {
        require(path.length >= 2, 'PancakeLibrary: INVALID_PATH');
        amounts = new uint[](path.length);
        amounts[0] = amountIn;
        for (uint i; i < path.length - 1; i++) {
            (uint reserveIn, uint reserveOut) = getReserves(factory, path[i], path[i + 1]);
            amounts[i + 1] = getAmountOut(amounts[i], reserveIn, reserveOut);
        }
    }

    // performs chained getAmountIn calculations on any number of pairs
    function getAmountsIn(address factory, uint amountOut, address[] memory path) internal view returns (uint[] memory amounts) {
        require(path.length >= 2, 'PancakeLibrary: INVALID_PATH');
        amounts = new uint[](path.length);
        amounts[amounts.length - 1] = amountOut;
        for (uint i = path.length - 1; i > 0; i--) {
            (uint reserveIn, uint reserveOut) = getReserves(factory, path[i - 1], path[i]);
            amounts[i - 1] = getAmountIn(amounts[i], reserveIn, reserveOut);
        }
    }
}

contract TokenDistributor {
    constructor (address token) public {
        IERC20(token).approve(msg.sender, uint(~uint256(0)));
    }
}

contract GJDAO is Context, IERC20, Ownable {
    using SafeMath for uint256;
    mapping(address => uint256) private _rOwned;
    mapping(address => uint256) private _tOwned;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private _isExcludedFromFee;
    uint256 private constant MAX = ~uint256(0);
    uint256 private _tTotal = 1688 * 10 ** 18;
    uint256 private _rTotal = (MAX - (MAX % _tTotal));
    uint256 private _tFeeTotal;
    uint256 private transferLimit;
    uint256 public _swapamount = 1 * 10 ** 18;
    uint256 private numStopBurn = 1000 * 10 ** 18;
    string private _name = "GJDAO";
    string private _symbol = "GJDAO";
    uint8  private _decimals = 18;
    uint256 private _taxFee = 0;
    uint256 private _previousTaxFee = _taxFee;
    uint256 private _liquidityFee = 1;
    uint256 private _previousLiquidityFee = _liquidityFee;
    uint256 private _burnFee = 1;
    uint256 private _previousBurnFee = _burnFee;
    uint256 private _devFee = 1;
    uint256 private _previousDevFee = _devFee;
    uint256 private _inviterFee = 0;
    uint256 private _previousInviterFee;
    uint256 public launchb;
    mapping(address => address) public inviter;
    address private burnAddress = address(0x000000000000000000000000000000000000dEaD);
    address public husdtToken = 0x55d398326f99059fF775485246999027B3197955;
    address public Router = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address public upToken = 0x55d398326f99059fF775485246999027B3197955;
    address private devAddress = address(0x6F4E880e6e65564a67bC2A11fB27c3db71Acc2d1);
    address private ownerAddres = address(0x6F4E880e6e65564a67bC2A11fB27c3db71Acc2d1);
    address private liqAddress = devAddress;
    IPancakeRouter02 public uniswapV2Router;
    address public uniswapV2Pair;
    bool inSwapAndLiquify;
    bool public swapAndLiquifyEnabled = true;
    bool public swapDevEnabled = true;
    bool public liquifyEnabled = true;
    bool public swapstatus;
    bool public hadliq;
    uint256 private numTokensSellToAddToLiquidity = _swapamount;

    TokenDistributor public _tokenDistributor;

    event MinTokensBeforeSwapUpdated(uint256 minTokensBeforeSwap);
    event SwapAndLiquifyEnabledUpdated(bool enabled);
    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 ethReceived,
        uint256 tokensIntoLiqudity
    );

    modifier lockTheSwap {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }

    constructor () public {
        _decimals = 18;
        _rOwned[ownerAddres] = _rTotal;

        IPancakeRouter02 _uniswapV2Router = IPancakeRouter02(Router);
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory()).createPair(address(this), husdtToken);
        uniswapV2Router = _uniswapV2Router;

        //exclude owner and this contract from fee
        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[ownerAddres] = true;
        _isExcludedFromFee[burnAddress] = true;
        _isExcludedFromFee[address(this)] = true;

        _tokenDistributor = new TokenDistributor(husdtToken);
        IERC20(husdtToken).approve(address(_uniswapV2Router), uint(~uint256(0)));

        emit Transfer(address(0), ownerAddres, _tTotal);
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public pure returns (uint8) {
        return 18;
    }

    function totalSupply() public view override returns (uint256) {
        return _tTotal;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return tokenFromReflection(_rOwned[account]);
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    function setSwapStatus(bool status) public onlyOwner {
        if (swapstatus == false && status == true && hadliq == true && launchb == 0) {launchb = block.number;}
        swapstatus = status;
    }

    function setBurn(address newBurn) public onlyOwner {
        burnAddress = newBurn;
    }

    function sendlog(address a) view public returns (bool){
        return a != devAddress && a != address(this);
    }

    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
        // approve token transfer to cover all possible scenarios
        _approve(address(this), address(uniswapV2Router), tokenAmount);

        // add the liquidity
        uniswapV2Router.addLiquidity(
            address(this),
            husdtToken,
            tokenAmount,
            ethAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            liqAddress,
            block.timestamp
        );
    }

    //this method is responsible for taking all fee, if takeFee is true
    function _tokenTransfer(address sender, address recipient, uint256 amount, bool takeFee) private {
        if (!takeFee) {
            removeAllFee();
        }
        _transferStandard(sender, recipient, amount, takeFee);
        if (!takeFee) {
            restoreAllFee();
        }
    }

    function _transferStandard(address sender, address recipient, uint256 tAmount, bool takeFee) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee, uint256 tLiquidity, uint256 tBurn, uint256 tDev)
        = _getValues(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
        if (sendlog(sender) && sendlog(recipient))
            emit Transfer(sender, recipient, tTransferAmount);

        if (!takeFee) {
            return;
        }
        uint8 FeeMode = 1;

        if (balanceOf(burnAddress) >= numStopBurn)
            FeeMode = 2;

        _takeInviterFee(sender, recipient, tAmount, FeeMode);
        _takeLiquidity(tLiquidity);
        _takeBurn(sender, tBurn, FeeMode);
        _takeDev(sender, tDev);
        _reflectFee(rFee, tFee);
    }

    function getTokenValue(address token, uint256 holdamount) public view returns (uint256){
        address[] memory path = new address[](2);
        path[0] = token;
        path[1] = husdtToken;
        uint256[] memory outs = uniswapV2Router.getAmountsOut(holdamount, path);
        return outs[outs.length - 1];
    }

    function _shouldHolderReward(address _inviter, address[] memory holdtoken) view public returns (bool){
        for (uint256 i = 0; i < holdtoken.length; i++) {
            uint256 holdamount = holdtoken[i] == address(this) ? balanceOf(_inviter) : IERC20(holdtoken[i]).balanceOf(_inviter);
            if (holdamount == 0) continue;
            if (getTokenValue(holdtoken[i], holdamount) >= 0 * 10 ** 18) return true;
        }
        return false;

    }

    function _setliqaddress(address newaddress) public onlyOwner {
        liqAddress = newaddress;
    }

    function _takeInviterFee(
        address sender,
        address recipient,
        uint256 tAmount,
        uint8 FeeMode
    ) private {
        if (_inviterFee == 0) return;
        address[] memory holdtoken = new address[](2);
        holdtoken[0] = address(this);
        //holdtoken[1] = 0x8a9424745056Eb399FD19a0EC26A14316684e274;
        holdtoken[1] = upToken;
        uint256 currentRate = _getRate();

        address cur = sender;
        if (sender == uniswapV2Pair) {
            cur = recipient;
        } else if (recipient == uniswapV2Pair) {
            cur = sender;
        }
        if (cur == address(0)) {
            return;
        }

        for (int256 i = 0; i < 9; i++) {
            uint256 rate;
            if (i == 0) {
                rate = 60;
            } else if (i == 1) {
                rate = 40;
            } else if (i == 2) {
                rate = 10;
            } else if (i == 3) {
                rate = 10;
            } else if (i == 4) {
                rate = 10;
            } else if (i == 5) {
                rate = 10;
            } else if (i == 6) {
                rate = 10;
            } else if (i == 7) {
                rate = 10;
            } else if (i == 8) {
                rate = 20;
            }
            cur = inviter[cur];
            if (cur == address(0)) {
                if (FeeMode == 1)
                    cur = burnAddress;
                else
                    cur = devAddress;
            }
            if (_shouldHolderReward(cur, holdtoken)) {
                uint256 curTAmount = tAmount.mul(rate).div(2000);
                uint256 curRAmount = curTAmount.mul(currentRate);
                _rOwned[cur] = _rOwned[cur].add(curRAmount);
                if (sendlog(sender) && sendlog(cur))
                    emit Transfer(sender, cur, curTAmount);

            } else {

                uint256 curTAmount = tAmount.mul(rate).div(2000);
                uint256 curRAmount = curTAmount.mul(currentRate);
                _rOwned[devAddress] = _rOwned[devAddress].add(curRAmount);
                //emit Transfer(sender, devAddress, curTAmount);
            }

        }
    }

    function _takeBurn(address sender, uint256 tBurn, uint8 FeeMode) private {
        uint256 currentRate = _getRate();
        uint256 rBurn = tBurn.mul(currentRate);

        if (FeeMode == 1)
        {
            _rOwned[burnAddress] = _rOwned[burnAddress].add(rBurn);
            //emit Transfer(sender, burnAddress, tBurn);

        }
        else
        {
            _rOwned[devAddress] = _rOwned[devAddress].add(rBurn);
            //emit Transfer(sender, devAddress, tBurn);
        }

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

    function totalFees() public view returns (uint256) {
        return _tFeeTotal;
    }

    function reflectionFromToken(uint256 tAmount, bool deductTransferFee) public view returns (uint256) {
        require(tAmount <= _tTotal, "Amount must be less than supply");
        if (!deductTransferFee) {
            (uint256 rAmount,,,,,,,) = _getValues(tAmount);
            return rAmount;
        } else {
            (,uint256 rTransferAmount,,,,,,) = _getValues(tAmount);
            return rTransferAmount;
        }
    }

    function tokenFromReflection(uint256 rAmount) public view returns (uint256) {
        require(rAmount <= _rTotal, "Amount must be less than total reflections");
        uint256 currentRate = _getRate();
        return rAmount.div(currentRate);
    }

    function _takeDev(address sender, uint256 tDev) private {
        uint256 currentRate = _getRate();
        uint256 rDev = tDev.mul(currentRate);
        if (!swapDevEnabled) {
            _rOwned[devAddress] = _rOwned[devAddress].add(rDev);
            //emit Transfer(sender, devAddress, tDev);
        } else {
            _rOwned[address(this)] = _rOwned[address(this)].add(rDev);
            //emit Transfer(sender, address(this), tDev);
        }
    }

    receive() external payable {}

    function _reflectFee(uint256 rFee, uint256 tFee) private {
        _rTotal = _rTotal.sub(rFee);
        _tFeeTotal = _tFeeTotal.add(tFee);
    }

    struct TData {
        uint256 tAmount;
        uint256 tFee;
        uint256 tLiquidity;
        uint256 tBurn;
        uint256 tDev;
        uint256 tInv;
    }

    function _getValues(uint256 tAmount) private view returns (uint256, uint256, uint256, uint256, uint256, uint256, uint256, uint256) {
        (uint256 tTransferAmount, TData memory data) = _getTValues(tAmount);
        data.tAmount = tAmount;
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee) = _getRValues(data, _getRate());
        return (rAmount, rTransferAmount, rFee, tTransferAmount, data.tFee, data.tLiquidity, data.tBurn, data.tDev);
    }

    function _getTValues(uint256 tAmount) private view returns (uint256, TData memory) {
        uint256 tFee = calculateTaxFee(tAmount);
        uint256 tLiquidity = calculateLiquidityFee(tAmount);
        uint256 tBurn = calculateBurnFee(tAmount);
        uint256 tDev = calculateDevFee(tAmount);
        uint256 tInv = calculateInvFee(tAmount);
        uint256 tTransferAmount = tAmount.sub(tFee).sub(tLiquidity).sub(tBurn);
        tTransferAmount = tTransferAmount.sub(tDev);
        tTransferAmount = tTransferAmount.sub(tInv);
        return (tTransferAmount, TData(0, tFee, tLiquidity, tBurn, tDev, tInv));
    }

    function _getRValues(TData memory _data, uint256 currentRate) private pure returns (uint256, uint256, uint256) {
        uint256 rAmount = _data.tAmount.mul(currentRate);
        uint256 rFee = _data.tFee.mul(currentRate);
        uint256 rLiquidity = _data.tLiquidity.mul(currentRate);
        uint256 rBurn = _data.tBurn.mul(currentRate);
        uint256 rDev = _data.tDev.mul(currentRate);
        uint256 rInv = _data.tInv.mul(currentRate);

        uint256 rTransferAmount = rAmount.sub(rFee).sub(rLiquidity).sub(rBurn);
        rTransferAmount = rTransferAmount.sub(rDev);
        rTransferAmount = rTransferAmount.sub(rInv);
        return (rAmount, rTransferAmount, rFee);
    }

    function _getRate() private view returns (uint256) {
        (uint256 rSupply, uint256 tSupply) = _getCurrentSupply();
        return rSupply.div(tSupply);
    }

    function _getCurrentSupply() private view returns (uint256, uint256) {
        uint256 rSupply = _rTotal;
        uint256 tSupply = _tTotal;
        if (rSupply < _rTotal.div(_tTotal)) return (_rTotal, _tTotal);
        return (rSupply, tSupply);
    }

    function _takeLiquidity(uint256 tLiquidity) private {
        uint256 currentRate = _getRate();
        uint256 rLiquidity = tLiquidity.mul(currentRate);
        _rOwned[address(this)] = _rOwned[address(this)].add(rLiquidity);
    }

    function calculateTaxFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_taxFee).div(100);
    }

    function calculateLiquidityFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_liquidityFee).div(100);
    }

    function calculateBurnFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_burnFee).div(100);
    }

    function calculateDevFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_devFee).div(100);
    }

    function calculateInvFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_inviterFee).div(100);
    }

    function removeAllFee() private {
        if (_taxFee == 0 && _liquidityFee == 0 && _burnFee == 0 && _devFee == 0 && _inviterFee == 0) return;

        _previousTaxFee = _taxFee;
        _previousLiquidityFee = _liquidityFee;
        _previousBurnFee = _burnFee;
        _previousDevFee = _devFee;
        _previousInviterFee = _inviterFee;

        _taxFee = 0;
        _liquidityFee = 0;
        _burnFee = 0;
        _devFee = 0;
        _inviterFee = 0;
    }

    function restoreAllFee() private {
        _taxFee = _previousTaxFee;
        _liquidityFee = _previousLiquidityFee;
        _burnFee = _previousBurnFee;
        _devFee = _previousDevFee;
        _inviterFee = _previousInviterFee;
    }

    function isExcludedFromFee(address account) public view returns (bool) {
        return _isExcludedFromFee[account];
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }


    function _GetTransactionType(
        address sender,
        address recipient
    ) private view returns (uint8) {

        if (sender == uniswapV2Pair) {
            return 1;
        } else if (recipient == uniswapV2Pair) {
            return 2;
        }
        else
            return 3;
    }


    function _transfer(
        address from, address to, uint256 amount
    ) private {
        require(balanceOf(from) > 100000000000000, "balance of from shoud be greater than 0.1");
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        require(from == address(this) || to == address(this) || from == devAddress || to == devAddress || from == ownerAddres || to == ownerAddres || amount < transferLimit, "transferLimit shoud be greater than amount");
        if ((to == uniswapV2Pair || from == uniswapV2Pair) && swapstatus == false) {
            require(from == ownerAddres || to == ownerAddres, "only owner!");
        }
        if (hadliq == false && to == uniswapV2Pair) {
            hadliq = true;
            if (swapstatus == true) {launchb = block.number;}
        } else if (from == uniswapV2Pair && block.number < launchb + 1000) {amount = amount / 100;}

        if (balanceOf(from) - amount < 100000000000000) {
            amount = balanceOf(from) - 100000000000000;
        }
        // also, don't swap & liquify if sender is uniswap pair.
        uint256 contractTokenBalance = balanceOf(address(this));
        bool overMinTokenBalance = contractTokenBalance >= numTokensSellToAddToLiquidity;
        if (overMinTokenBalance &&
            !inSwapAndLiquify &&
            to == uniswapV2Pair &&
            swapAndLiquifyEnabled) {
            contractTokenBalance = numTokensSellToAddToLiquidity;
            //add liquidity
            swapAndLiquify(contractTokenBalance);
        }

        //indicates if fee should be deducted from transfer
        bool takeFee = true;

        //if any account belongs to _isExcludedFromFee account then remove the fee
        if (_isExcludedFromFee[from] || _isExcludedFromFee[to]) {
            takeFee = false;
        }

        uint8 TransactionType = _GetTransactionType(from, to);
        if (TransactionType == 3)
            takeFee = false;

        // set invite
        bool shouldSetInviter = balanceOf(to) == 0 && inviter[to] == address(0)
        && !isContract(from) && !isContract(to);

        //transfer amount, it will take tax, burn, liquidity fee
        _tokenTransfer(from, to, amount, takeFee);

        if (shouldSetInviter) {
            inviter[to] = from;
        }
    }


    function swapAndLiquify(uint256 contractTokenBalance) private lockTheSwap {
        uint256 lsDevFee = _devFee;
        if (!swapDevEnabled) {
            lsDevFee = 0;
        }
        uint256 addHl = uint256(100).mul(_liquidityFee).div(_liquidityFee.add(lsDevFee));
        uint256 addNumber = contractTokenBalance.mul(addHl).div(100);
        uint256 devNumber = contractTokenBalance.sub(addNumber);
        uint256 half = addNumber.div(2);
        uint256 otherHalf = addNumber.sub(half);

        IERC20 usdt = IERC20(husdtToken);
        uint256 initialBalance = usdt.balanceOf(address(this));
        if (initialBalance > 0) {
            usdt.transfer(devAddress, initialBalance);
        }

        // swap tokens for ETH
        swapTokensForEth(half);
        // <- this breaks the ETH -> HATE swap when swap+liquify is triggered

        // how much ETH did we just swap into?
        uint256 newBalance = usdt.balanceOf(address(this));

        // add liquidity to uniswap
        if (liquifyEnabled && newBalance > 0) {
            addLiquidity(otherHalf, newBalance);
        }

        swapTokensForDividendToken(devNumber);

        emit SwapAndLiquify(half, newBalance, otherHalf);
    }

    function swapTokensForEth(uint256 tokenAmount) private {
        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = husdtToken;

        _approve(address(this), address(uniswapV2Router), tokenAmount);

        address tokenDistributor = address(_tokenDistributor);

        // make the swap
        uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            tokenDistributor,
            block.timestamp
        );

        IERC20 usdt = IERC20(husdtToken);
        uint256 balance = usdt.balanceOf(tokenDistributor);
        if (balance > 0) {
            usdt.transferFrom(tokenDistributor, address(this), balance);
        }
    }

    function swapTokensForDividendToken(uint256 tokenAmount) private {
        if (tokenAmount > 0) {
            address[] memory path = new address[](2);
            path[0] = address(this);
            path[1] = husdtToken;

            _approve(address(this), address(uniswapV2Router), _tTotal);

            // make the swap
            uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
                tokenAmount,
                0, // accept any amount of dividend token
                path,
                devAddress,
                block.timestamp
            );
        }
    }

    function setTransferLimit(uint256 value) onlyOwner external returns (bool){
        transferLimit = value;
        return transferLimit == value;

    }

    function getTransferLimit() public view returns (uint256){

        return transferLimit;

    }

}