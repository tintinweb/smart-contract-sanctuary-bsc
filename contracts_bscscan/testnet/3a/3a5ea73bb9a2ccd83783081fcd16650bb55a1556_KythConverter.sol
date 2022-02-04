/**
 *Submitted for verification at BscScan.com on 2022-02-04
*/

// File: contracts/swap/interfaces/ISpiderSwapV2Factory.sol



pragma solidity 0.6.12;

interface ISpiderSwapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeToSetter(address) external;
    function PERCENT100() external view returns (uint256);
    function DEADADDRESS() external view returns (address);
    
    function lockFee() external view returns (uint256);
    function sLockFee() external view returns (uint256);
    function pause() external view returns (bool);
    function InoutTaxConverter() external view returns (address);
    function InoutTax() external view returns (uint256);
    function SwapTaxConverter() external view returns (address);
    function swapTax() external view returns (uint256);
    function setRouter(address _router) external ;
    function InOutTotalFee()external view returns (uint256);
    
}

// File: contracts/swap/libraries/SafeMath.sol



pragma solidity 0.6.12;

// a library for performing overflow-safe math, courtesy of DappHub (https://github.com/dapphub/ds-math)

library SafeMathSpiderSwap {
    function add(uint x, uint y) internal pure returns (uint z) {
        require((z = x + y) >= x, 'ds-math-add-overflow');
    }

    function sub(uint x, uint y) internal pure returns (uint z) {
        require((z = x - y) <= x, 'ds-math-sub-underflow');
    }

    function mul(uint x, uint y) internal pure returns (uint z) {
        require(y == 0 || (z = x * y) / y == x, 'ds-math-mul-overflow');
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }
}

// File: contracts/swap/SpiderSwapV2ERC20.sol



pragma solidity 0.6.12;


contract SpiderSwapV2ERC20 {
    using SafeMathSpiderSwap for uint;

    string public constant name = 'SpiderSwapV LP Token';
    string public constant symbol = 'SSLP';
    uint8 public constant decimals = 18;
    uint  public totalSupply;
    mapping(address => uint) public balanceOf;
    mapping(address => mapping(address => uint)) public allowance;

    bytes32 public DOMAIN_SEPARATOR;
    // keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)");
    bytes32 public constant PERMIT_TYPEHASH = 0x6e71edae12b1b97f4d1f60370fef10105fa2faae0126114a169c64845d6126c9;
    mapping(address => uint) public nonces;

    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    constructor() public {
        uint chainId;
        assembly {
            chainId := chainid()
        }
        DOMAIN_SEPARATOR = keccak256(
            abi.encode(
                keccak256('EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)'),
                keccak256(bytes(name)),
                keccak256(bytes('1')),
                chainId,
                address(this)
            )
        );
    }

    function _mint(address to, uint value) internal {
        totalSupply = totalSupply.add(value);
        balanceOf[to] = balanceOf[to].add(value);
        emit Transfer(address(0), to, value);
    }

    function _burn(address from, uint value) internal {
        balanceOf[from] = balanceOf[from].sub(value);
        totalSupply = totalSupply.sub(value);
        emit Transfer(from, address(0), value);
    }

    function _approve(address owner, address spender, uint value) private {
        allowance[owner][spender] = value;
        emit Approval(owner, spender, value);
    }

    function _transfer(address from, address to, uint value) private {
        balanceOf[from] = balanceOf[from].sub(value);
        balanceOf[to] = balanceOf[to].add(value);
        emit Transfer(from, to, value);
    }

    function approve(address spender, uint value) external returns (bool) {
        _approve(msg.sender, spender, value);
        return true;
    }

    function transfer(address to, uint value) public returns (bool) {
        _transfer(msg.sender, to, value);
        return true;
    }

    function transferFrom(address from, address to, uint value) external returns (bool) {
        if (allowance[from][msg.sender] != uint(-1)) {
            allowance[from][msg.sender] = allowance[from][msg.sender].sub(value);
        }
        _transfer(from, to, value);
        return true;
    }

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external {
        require(deadline >= block.timestamp, 'SpiderSwapV2: EXPIRED');
        bytes32 digest = keccak256(
            abi.encodePacked(
                '\x19\x01',
                DOMAIN_SEPARATOR,
                keccak256(abi.encode(PERMIT_TYPEHASH, owner, spender, value, nonces[owner]++, deadline))
            )
        );
        address recoveredAddress = ecrecover(digest, v, r, s);
        require(recoveredAddress != address(0) && recoveredAddress == owner, 'SpiderSwapV2: INVALID_SIGNATURE');
        _approve(owner, spender, value);
    }
}

// File: contracts/swap/libraries/Math.sol



pragma solidity 0.6.12;

// a library for performing various math operations

library Math {
    function min(uint x, uint y) internal pure returns (uint z) {
        z = x < y ? x : y;
    }

    // babylonian method (https://en.wikipedia.org/wiki/Methods_of_computing_square_roots#Babylonian_method)
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
    }
}

// File: contracts/swap/libraries/UQ112x112.sol



pragma solidity 0.6.12;

// a library for handling binary fixed point numbers (https://en.wikipedia.org/wiki/Q_(number_format))

// range: [0, 2**112 - 1]
// resolution: 1 / 2**112

library UQ112x112 {
    uint224 constant Q112 = 2**112;

    // encode a uint112 as a UQ112x112
    function encode(uint112 y) internal pure returns (uint224 z) {
        z = uint224(y) * Q112; // never overflows
    }

    // divide a UQ112x112 by a uint112, returning a UQ112x112
    function uqdiv(uint224 x, uint112 y) internal pure returns (uint224 z) {
        z = x / uint224(y);
    }
}

// File: contracts/swap/interfaces/IERC20.sol



pragma solidity 0.6.12;

interface IERC20 {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);
}

// File: contracts/swap/interfaces/ISpiderSwapV2Router01.sol



pragma solidity 0.6.12;

interface ISpiderSwapV2Router01 {
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

// File: contracts/swap/interfaces/ISpiderSwapV2Callee.sol



pragma solidity 0.6.12;

interface ISpiderSwapV2Callee {
    function spiderSwapV2Call(address sender, uint amount0, uint amount1, bytes calldata data) external;
}

// File: contracts/swap/SpiderSwapV2Pair.sol



pragma solidity 0.6.12;









contract SpiderSwapV2Pair is SpiderSwapV2ERC20 {
    using SafeMathSpiderSwap  for uint;
    using UQ112x112 for uint224;

    uint public constant MINIMUM_LIQUIDITY = 10**3;
    bytes4 private constant SELECTOR = bytes4(keccak256(bytes('transfer(address,uint256)')));

    address public factory;
    address public router;
    address public token0;
    address public token1;

    uint112 private reserve0;           // uses single storage slot, accessible via getReserves
    uint112 private reserve1;           // uses single storage slot, accessible via getReserves
    uint32  private blockTimestampLast; // uses single storage slot, accessible via getReserves

    uint public price0CumulativeLast;
    uint public price1CumulativeLast;
    uint public kLast; // reserve0 * reserve1, as of immediately after the most recent liquidity event

    uint private unlocked = 1;
    modifier lock() {
        require(unlocked == 1, 'SpiderSwapV2: LOCKED');
        unlocked = 0;
        _;
        unlocked = 1;
    }

    function getReserves() public view returns (uint112 _reserve0, uint112 _reserve1, uint32 _blockTimestampLast) {
        _reserve0 = reserve0;
        _reserve1 = reserve1;
        _blockTimestampLast = blockTimestampLast;
    }

    function _safeTransfer(address token, address to, uint value) private {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(SELECTOR, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'SpiderSwapV2: TRANSFER_FAILED');
    }

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

    constructor() public {
        factory = msg.sender;
    }

    // called once by the factory at time of deployment
    function initialize(address _token0, address _token1, address _router) external {
        require(msg.sender == factory, 'SpiderSwapV2: FORBIDDEN'); // sufficient check
        token0 = _token0;
        token1 = _token1;
        router = _router;
    }

    // update reserves and, on the first call per block, price accumulators
    function _update(uint balance0, uint balance1, uint112 _reserve0, uint112 _reserve1) private {
        require(balance0 <= uint112(-1) && balance1 <= uint112(-1), 'SpiderSwapV2: OVERFLOW');
        uint32 blockTimestamp = uint32(block.timestamp % 2**32);
        uint32 timeElapsed = blockTimestamp - blockTimestampLast; // overflow is desired
        if (timeElapsed > 0 && _reserve0 != 0 && _reserve1 != 0) {
            // * never overflows, and + overflow is desired
            price0CumulativeLast += uint(UQ112x112.encode(_reserve1).uqdiv(_reserve0)) * timeElapsed;
            price1CumulativeLast += uint(UQ112x112.encode(_reserve0).uqdiv(_reserve1)) * timeElapsed;
        }
        reserve0 = uint112(balance0);
        reserve1 = uint112(balance1);
        blockTimestampLast = blockTimestamp;
        emit Sync(reserve0, reserve1);
    }

    // if fee is on, mint liquidity equivalent to 1/6th of the growth in sqrt(k)
    function _mintFee(uint112 _reserve0, uint112 _reserve1) private returns (bool feeOn) {
        address feeTo = ISpiderSwapV2Factory(factory).feeTo();
        feeOn = feeTo != address(0);
        uint _kLast = kLast; // gas savings
        if (feeOn) {
            if (_kLast != 0) {
                uint rootK = Math.sqrt(uint(_reserve0).mul(_reserve1));
                uint rootKLast = Math.sqrt(_kLast);
                if (rootK > rootKLast) {
                    uint numerator = totalSupply.mul(rootK.sub(rootKLast));
                    uint denominator = rootK.mul(5).add(rootKLast);
                    uint liquidity = numerator / denominator;
                    if (liquidity > 0) _mint(feeTo, liquidity);
                }
            }
        } else if (_kLast != 0) {
            kLast = 0;
        }
    }

    // this low-level function should be called from a contract which performs important safety checks
    function mint(address to) external lock returns (uint liquidity) {
        (uint112 _reserve0, uint112 _reserve1,) = getReserves(); // gas savings
        uint balance0 = IERC20(token0).balanceOf(address(this));
        uint balance1 = IERC20(token1).balanceOf(address(this));
        uint amount0 = balance0.sub(_reserve0);
        uint amount1 = balance1.sub(_reserve1);

        bool feeOn = _mintFee(_reserve0, _reserve1);
        uint _totalSupply = totalSupply; // gas savings, must be defined here since totalSupply can update in _mintFee
        if (_totalSupply == 0) {
                liquidity = Math.sqrt(amount0.mul(amount1)).sub(MINIMUM_LIQUIDITY);
                _mint(address(0), MINIMUM_LIQUIDITY); // permanently lock the first MINIMUM_LIQUIDITY tokens
        } else {
            liquidity = Math.min(amount0.mul(_totalSupply) / _reserve0, amount1.mul(_totalSupply) / _reserve1);
        }
        require(liquidity > 0, 'SpiderSwapV2: INSUFFICIENT_LIQUIDITY_MINTED');

        if(ISpiderSwapV2Factory(factory).pause()== false){
            if(address(token0) != ISpiderSwapV2Router01(router).WETH()){
                require(balance0 <= (IERC20(token0).totalSupply()).div(2), "Pool max supply reached");
            }
            if(address(token1) != ISpiderSwapV2Router01(router).WETH()){
                require(balance1 <= (IERC20(token1).totalSupply()).div(2), "Pool max supply reached");
            }
            uint256 sLockFee = liquidity.mul(ISpiderSwapV2Factory(factory).sLockFee()).div(ISpiderSwapV2Factory(factory).PERCENT100());
            liquidity = liquidity.sub(liquidity);
            _mint(ISpiderSwapV2Factory(factory).DEADADDRESS(), sLockFee);
        }
        _mint(to, liquidity);
        _update(balance0, balance1, _reserve0, _reserve1);
        if (feeOn) kLast = uint(reserve0).mul(reserve1); // reserve0 and reserve1 are up-to-date
        emit Mint(msg.sender, amount0, amount1);
    }

    // this low-level function should be called from a contract which performs important safety checks
    function burn(address to) external lock returns (uint amount0, uint amount1) {
        (uint112 _reserve0, uint112 _reserve1,) = getReserves(); // gas savings
        address _token0 = token0;                                // gas savings
        address _token1 = token1;                                // gas savings
        uint balance0 = IERC20(_token0).balanceOf(address(this));
        uint balance1 = IERC20(_token1).balanceOf(address(this));
        uint liquidity = balanceOf[address(this)];

        bool feeOn = _mintFee(_reserve0, _reserve1);
        uint _totalSupply = totalSupply; // gas savings, must be defined here since totalSupply can update in _mintFee
        amount0 = liquidity.mul(balance0) / _totalSupply; // using balances ensures pro-rata distribution
        amount1 = liquidity.mul(balance1) / _totalSupply; // using balances ensures pro-rata distribution
        require(amount0 > 0 && amount1 > 0, 'SpiderSwapV2: INSUFFICIENT_LIQUIDITY_BURNED');
        if(ISpiderSwapV2Factory(factory).pause()== false){
            uint256 sLockFee = liquidity.mul(ISpiderSwapV2Factory(factory).sLockFee()).div(ISpiderSwapV2Factory(factory).PERCENT100());
            liquidity = liquidity.sub(liquidity);
            transfer(ISpiderSwapV2Factory(factory).DEADADDRESS(), sLockFee);
        }
        _burn(address(this), liquidity);
        (amount0, amount1) = takeRemoveLiquidityFee(_token0, _token1, amount0, amount1);
        _safeTransfer(_token0, to, amount0);
        _safeTransfer(_token1, to, amount1);
        balance0 = IERC20(_token0).balanceOf(address(this));
        balance1 = IERC20(_token1).balanceOf(address(this));

        _update(balance0, balance1, _reserve0, _reserve1);
        if (feeOn) kLast = uint(reserve0).mul(reserve1); // reserve0 and reserve1 are up-to-date
        emit Burn(msg.sender, amount0, amount1, to);
    }

    // this low-level function should be called from a contract which performs important safety checks
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external lock {
        require(amount0Out > 0 || amount1Out > 0, 'SpiderSwapV2: INSUFFICIENT_OUTPUT_AMOUNT');
        (uint112 _reserve0, uint112 _reserve1,) = getReserves(); // gas savings
        require(amount0Out < _reserve0 && amount1Out < _reserve1, 'SpiderSwapV2: INSUFFICIENT_LIQUIDITY');

        uint balance0;
        uint balance1;
        { // scope for _token{0,1}, avoids stack too deep errors
        address _token0 = token0;
        address _token1 = token1;
        require(to != _token0 && to != _token1, 'SpiderSwapV2: INVALID_TO');
        if (amount0Out > 0) _safeTransfer(_token0, to, amount0Out); // optimistically transfer tokens
        if (amount1Out > 0) _safeTransfer(_token1, to, amount1Out); // optimistically transfer tokens
        if (data.length > 0) ISpiderSwapV2Callee(to).spiderSwapV2Call(msg.sender, amount0Out, amount1Out, data);
        balance0 = IERC20(_token0).balanceOf(address(this));
        balance1 = IERC20(_token1).balanceOf(address(this));
        }
        uint amount0In = balance0 > _reserve0 - amount0Out ? balance0 - (_reserve0 - amount0Out) : 0;
        uint amount1In = balance1 > _reserve1 - amount1Out ? balance1 - (_reserve1 - amount1Out) : 0;
        require(amount0In > 0 || amount1In > 0, 'SpiderSwapV2: INSUFFICIENT_INPUT_AMOUNT');
        { // scope for reserve{0,1}Adjusted, avoids stack too deep errors
        uint balance0Adjusted = balance0.mul(1000).sub(amount0In.mul(3));
        uint balance1Adjusted = balance1.mul(1000).sub(amount1In.mul(3));
        require(balance0Adjusted.mul(balance1Adjusted) >= uint(_reserve0).mul(_reserve1).mul(1000**2), 'SpiderSwapV2: K');
        }

        _update(balance0, balance1, _reserve0, _reserve1);
        emit Swap(msg.sender, amount0In, amount1In, amount0Out, amount1Out, to);
    }

    // force balances to match reserves
    function skim(address to) external lock {
        address _token0 = token0; // gas savings
        address _token1 = token1; // gas savings
        _safeTransfer(_token0, to, IERC20(_token0).balanceOf(address(this)).sub(reserve0));
        _safeTransfer(_token1, to, IERC20(_token1).balanceOf(address(this)).sub(reserve1));
    }

    // force reserves to match balances
    function sync() external lock {
        _update(IERC20(token0).balanceOf(address(this)), IERC20(token1).balanceOf(address(this)), reserve0, reserve1);
    }

   function takeRemoveLiquidityFee(address _token0, address _token1, uint256 _amount0, uint256 _amount1) internal returns(uint256, uint256){
        if(ISpiderSwapV2Factory(factory).pause()== false){

            uint256 PERCENT = ISpiderSwapV2Factory(factory).PERCENT100(); 
            uint256 _totalFees = ISpiderSwapV2Factory(factory).InoutTax();             
            uint256 _totalFees0 = _amount0.mul(_totalFees).div(PERCENT);
            uint256 _totalFees1 = _amount1.mul(_totalFees).div(PERCENT);
            address converter = ISpiderSwapV2Factory(factory).InoutTaxConverter();

            _safeTransfer(_token0, converter,_totalFees0);
            _safeTransfer(_token1, converter, _totalFees1);
           
            _amount0 = _amount0.sub(_totalFees0);
            _amount1 = _amount1.sub(_totalFees1);
            return(_amount0, _amount1);
        }else{
           return(_amount0, _amount1);
       }
    }
}

// File: @openzeppelin/contracts/math/SafeMath.sol

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b > a) return (false, 0);
        return (true, a - b);
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a / b);
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a % b);
    }

    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        return a - b;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: modulo by zero");
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        return a - b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryDiv}.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a % b;
    }
}

// File: contracts/swap/interfaces/ISpiderSwapV2Router02.sol



pragma solidity 0.6.12;


interface ISpiderSwapV2Router02 is ISpiderSwapV2Router01 {
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

// File: contracts/Farm/IBank.sol

pragma solidity 0.6.12;



interface IBank{
    function addReward(uint256 amount) external;
}

// File: contracts/game/IRoulette.sol

pragma solidity 0.6.12;

interface IRoulette{
    function addRound(uint256 amount) external; 

}

// File: contracts/maker/KythConverter.sol

pragma solidity 0.6.12;






// Inout tax kyth converter
contract KythConverter {
    using SafeMath for uint256;

    ISpiderSwapV2Router02 public router;
    IERC20 public kyth;

    // Global recevier address
    address public global;
    address public roulette;
    address public farm;
    // Bank address
    address public kythBank;
    address public usdtxBank;
    address public goldxBank;
    address public btcxBank;
    address public ethxBank;

    uint256 public bankFee = 1000;
    uint256 public globalFee = 7000;
    uint256 public rouletteFee = 500;

    address public feeSetter;

    modifier onlyFeeSetter() {
        require(msg.sender == feeSetter, "Only fee setter");
        _;
    }

    constructor(address _feeSetter) public {
        feeSetter = _feeSetter;
    }

    function configure(
        ISpiderSwapV2Router02 _router,
        IERC20 _kyth,
        address _global,
        address _roulette,
        address _farm,
        address _kythBank,
        address _usdtxBank,
        address _goldxBank,
        address _btcxBank,
        address _ethxBank
    ) external onlyFeeSetter {
        router = _router;
        kyth = _kyth;
        global = _global;
        roulette = _roulette;
        farm = _farm;
        kythBank = _kythBank;
        usdtxBank = _usdtxBank;
        goldxBank = _goldxBank;
        btcxBank = _btcxBank;
        ethxBank = _ethxBank;
    }

    function convert(
        uint256 amountIn,
        address[] calldata path,
        bool _transferFee
    ) external {
        IERC20(path[0]).approve(address(router), amountIn);

        router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            amountIn,
            0,
            path,
            address(this),
            block.timestamp
        );

        if (_transferFee) {
            transferKyth();
        }
    }

    function transferKyth() public {
        uint256 balance = kyth.balanceOf(address(this));
        require(balance > 1e18, "insufficient Balance");

        uint256 PERCENT = bankFee.mul(5) + globalFee + rouletteFee;
        uint256 bankfee = balance.mul(bankFee).div(PERCENT);
        uint256 globalfee = balance.mul(globalFee).div(PERCENT);
        uint256 roulettefee = balance.mul(rouletteFee).div(PERCENT);

        kyth.transfer(global, globalfee);

        _approvetoken(kythBank, balance);
        _approvetoken(usdtxBank, balance);
        _approvetoken(goldxBank, balance);
        _approvetoken(btcxBank, balance);
        _approvetoken(ethxBank, balance);

        IBank(kythBank).addReward(bankfee);
        IBank(usdtxBank).addReward(bankfee);
        IBank(goldxBank).addReward(bankfee);
        IBank(btcxBank).addReward(bankfee);
        IBank(ethxBank).addReward(bankfee);

        //transfer fee roulette
        kyth.transfer(roulette, roulettefee);
    }

    function _approvetoken(address _receiver, uint256 _amount) private {
        if (kyth.allowance(address(this), _receiver) < _amount) {
            kyth.approve(_receiver, _amount);
        }
    }
}

// File: contracts/maker/SwapKythConverter.sol

pragma solidity 0.6.12;






// Swap fee kyth converter
contract SwapKythConverter {
    using SafeMath for uint256;

    ISpiderSwapV2Router02 public router;
    IERC20 public kyth;

    // Global recevier address
    address public global;
    address public roulette;
    address public farm;
    // Bank address
    address public usdtxBank;
    address public goldxBank;
    // Swap fee
    uint256 public farmFee = 900;
    uint256 public USDTxFee = 50;
    uint256 public globalFee = 950;
    uint256 public rouletteFee = 100;
    address public feeSetter;

    modifier onlyFeeSetter() {
        require(msg.sender == feeSetter, "Only fee setter");
        _;
    }

    constructor(address _feeSetter) public {
        feeSetter = _feeSetter;
    }

    function configure(
        ISpiderSwapV2Router02 _router,
        IERC20 _kyth,
        address _global,
        address _roulette,
        address _farm,
        address _usdtxBank,
        address _goldxBank
    ) external onlyFeeSetter {
        router = _router;
        kyth = _kyth;
        global = _global;
        roulette = _roulette;
        farm = _farm;
        usdtxBank = _usdtxBank;
        goldxBank = _goldxBank;
    }

    function convert(
        uint256 amountIn,
        address[] calldata path,
        bool _transferFee
    ) external {
        IERC20(path[0]).approve(address(router), amountIn);
        router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            amountIn,
            0,
            path,
            address(this),
            block.timestamp + 60
        );

        if (_transferFee) {
            transferKyth();
        }
    }

    function transferKyth() public {
        uint256 balance = kyth.balanceOf(address(this));
        require(balance > 1e18, "insufficient Balance");

        uint256 PERCENT = farmFee + globalFee + rouletteFee + USDTxFee;

        uint256 farmfee = balance.mul(farmFee).div(PERCENT);
        uint256 globalfee = balance.mul(globalFee).div(PERCENT);
        uint256 roulettefee = balance.mul(rouletteFee).div(PERCENT);
        uint256 usdtxFee = balance.mul(USDTxFee).div(PERCENT);

        kyth.transfer(global, globalfee);
        kyth.transfer(farm, farmfee);

        _approvetoken(usdtxBank, balance);
        IBank(usdtxBank).addReward(usdtxFee);

        //add roulette
        kyth.transfer(roulette, roulettefee);
    }

    function _approvetoken(address _receiver, uint256 _amount) private {
        if (kyth.allowance(address(this), _receiver) < _amount) {
            kyth.approve(_receiver, _amount);
        }
    }
}

// File: contracts/swap/SpiderSwapV2Factory.sol



pragma solidity 0.6.12;







contract SpiderSwapV2Factory is ISpiderSwapV2Factory {
    uint256 public override constant PERCENT100 = 1000000; 
    address public override constant DEADADDRESS = 0x000000000000000000000000000000000000dEaD;

    address public override feeTo;
    address public override feeToSetter;
    address public router;

    address public override InoutTaxConverter; // In out Tax receiver
    uint256 public override InoutTax = 12500 ; // Inout tax fee 
    address public override SwapTaxConverter; // swap Tax receiver
    uint256 public override swapTax = 2000; // swap tax fee 
    uint256 public override InOutTotalFee = 30000;
    // Up to 4 decimal
    uint256 public override lockFee = 2500; 
    uint256 public override sLockFee = 500;
    bool public override pause = false;

    mapping(address => mapping(address => address)) public override getPair;
    address[] public override allPairs;

    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    constructor(address _feeToSetter) public {
        require(_feeToSetter != address(0x000), "Zero address");
        feeToSetter = _feeToSetter;
        InoutTaxConverter = address(new KythConverter(_feeToSetter));
        SwapTaxConverter = address(new SwapKythConverter(_feeToSetter));
    }

    function allPairsLength() external override view returns (uint) {
        return allPairs.length;
    }

    function pairCodeHash() external pure returns (bytes32) {
        return keccak256(type(SpiderSwapV2Pair).creationCode);
    }

    function createPair(address tokenA, address tokenB) external override returns (address pair) {
        require(tokenA != tokenB, 'SpiderSwapV2: IDENTICAL_ADDRESSES');
        (address token0, address token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        require(token0 != address(0), 'SpiderSwapV2: ZERO_ADDRESS');
        require(getPair[token0][token1] == address(0), 'SpiderSwapV2: PAIR_EXISTS'); // single check is sufficient
        bytes memory bytecode = type(SpiderSwapV2Pair).creationCode;
        bytes32 salt = keccak256(abi.encodePacked(token0, token1));
        assembly {
            pair := create2(0, add(bytecode, 32), mload(bytecode), salt)
        }
        SpiderSwapV2Pair(pair).initialize(token0, token1, router);
        getPair[token0][token1] = pair;
        getPair[token1][token0] = pair; // populate mapping in the reverse direction
        allPairs.push(pair);
        emit PairCreated(token0, token1, pair, allPairs.length);
    }

    function setFeeToSetter(address _feeToSetter) external override {
        require(msg.sender == feeToSetter, 'SpiderSwapV2: FORBIDDEN');
        feeToSetter = _feeToSetter;
    }

    function pauseFee(bool _newStatus) external {
        require(msg.sender == feeToSetter, 'SpiderSwapV2: FORBIDDEN');
        require(_newStatus != pause, 'SpiderSwapV2: INVALID');
        pause = _newStatus;
    }

    function setKythConverter(  
        address _inOutTaxConverter,
        address _swapTaxConverter

    ) public {
        require(msg.sender == feeToSetter, 'SpiderSwapV2: FORBIDDEN');
        require(_inOutTaxConverter != address(0x00), "zero address");
        require(_swapTaxConverter != address(0x00), "zero address");
        InoutTaxConverter = _inOutTaxConverter;
        SwapTaxConverter = _swapTaxConverter;       
    }

    function setRouter(address _router) public override {
        require(tx.origin == feeToSetter, 'SpiderSwapV2: FORBIDDEN');
        router = _router;
    }

}