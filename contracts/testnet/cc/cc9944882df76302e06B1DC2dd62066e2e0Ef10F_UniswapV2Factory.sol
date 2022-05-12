/**
 *Submitted for verification at BscScan.com on 2022-05-12
*/

// File: contracts/interfaces/IUniswapV2Factory.sol

pragma solidity >=0.6.6;

interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint256 aFactor, uint256);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);
    function sFee() external view returns (uint256);
    function pFee() external view returns (uint256);

    function getPair(address tokenA, address tokenB, uint256 aFactor) external view returns (address pair);
    function getBestK(address tokenA, address tokenB) external view returns (uint256 bestK);
    function getBestPair(address _tokenA, address _tokenB) external view returns (address bestPair);
    function isPair(address) external view returns (bool isPair);
    function allPairs(uint256) external view returns (address pair);
    function allPairsLength() external view returns (uint256);

    function createPair(address tokenA, address tokenB, uint256 aFactor) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
    function setSwapFee(uint256) external;
    function setPlatformFee(uint256) external;
    function updateBestK(uint256 _aFactor) external;
}

// File: contracts/interfaces/IUniswapV2Pair.sol

pragma solidity >=0.6.6;

interface IUniswapV2Pair {
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint256);
    function balanceOf(address owner) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 value) external returns (bool);
    function transfer(address to, uint256 value) external returns (bool);
    function transferFrom(address from, address to, uint256 value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint256);

    function MINIMUM_LIQUIDITY() external pure returns (uint256);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function aFactor() external view returns (uint256);
    function price0CumulativeLast() external view returns (uint256);
    function price1CumulativeLast() external view returns (uint256);
    function kLast() external view returns (uint256);
    function getReserves() external view returns (uint256 _reserve0, uint256 _reserve1, uint32 _blockTimestampLast);
    function getPairInfo()
        external
        view
        returns (
            uint256 _reserve0,
            uint256 _reserve1,
            uint256 _aReserve0,
            uint256 _aReserve1,
            uint256 _aFactor
        );

    function permit(address owner, address spender, uint256 value, uint256 deadline, uint8 v, bytes32 r, bytes32 s) external;

    event Mint(address indexed sender, uint256 amount0, uint256 amount1);
    event Burn(address indexed sender, uint256 amount0, uint256 amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint256 reserve0, uint256 reserve1, uint256 aReserve0, uint256 aReserve1);

    function mint(address to) external returns (uint256 liquidity);
    function burn(address to) external returns (uint256 amount0, uint256 amount1);
    function swap(uint256 amount0Out, uint256 amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;
    function updateFactor(uint256 _aFactor) external;

    function initialize(address, address, uint256) external;
}

// File: contracts/interfaces/IUniswapV2ERC20.sol

pragma solidity >=0.6.6;

interface IUniswapV2ERC20 {
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);
}

// File: contracts/libraries/SafeMath.sol

pragma solidity >=0.6.6;

// a library for performing overflow-safe math, courtesy of DappHub (https://github.com/dapphub/ds-math)

library SafeMath {
    function add(uint x, uint y) internal pure returns (uint z) {
        require((z = x + y) >= x, 'ds-math-add-overflow');
    }

    function sub(uint x, uint y) internal pure returns (uint z) {
        require((z = x - y) <= x, 'ds-math-sub-underflow');
    }

    function mul(uint x, uint y) internal pure returns (uint z) {
        require(y == 0 || (z = x * y) / y == x, 'ds-math-mul-overflow');
    }
}

// File: contracts/UniswapV2ERC20.sol

pragma solidity >=0.6.6;


contract UniswapV2ERC20 is IUniswapV2ERC20 {
    using SafeMath for uint;

    string public constant name = 'Uniswap V2';
    string public constant symbol = 'UNI-V2';
    uint8 public constant decimals = 18;
    uint256  public totalSupply;
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    bytes32 public DOMAIN_SEPARATOR;
    // keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)");
    bytes32 public constant PERMIT_TYPEHASH = 0x6e71edae12b1b97f4d1f60370fef10105fa2faae0126114a169c64845d6126c9;
    mapping(address => uint256) public nonces;

    constructor() public {
        uint256 chainId;
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

    function _mint(address to, uint256 value) internal {
        totalSupply = totalSupply.add(value);
        balanceOf[to] = balanceOf[to].add(value);
        emit Transfer(address(0), to, value);
    }

    function _burn(address from, uint256 value) internal {
        balanceOf[from] = balanceOf[from].sub(value);
        totalSupply = totalSupply.sub(value);
        emit Transfer(from, address(0), value);
    }

    function _approve(address owner, address spender, uint256 value) private {
        allowance[owner][spender] = value;
        emit Approval(owner, spender, value);
    }

    function _transfer(address from, address to, uint256 value) private {
        balanceOf[from] = balanceOf[from].sub(value);
        balanceOf[to] = balanceOf[to].add(value);
        emit Transfer(from, to, value);
    }

    function approve(address spender, uint256 value) external returns (bool) {
        _approve(msg.sender, spender, value);
        return true;
    }

    function transfer(address to, uint256 value) external returns (bool) {
        _transfer(msg.sender, to, value);
        return true;
    }

    function transferFrom(address from, address to, uint256 value) external returns (bool) {
        if (allowance[from][msg.sender] != uint256(-1)) {
            allowance[from][msg.sender] = allowance[from][msg.sender].sub(value);
        }
        _transfer(from, to, value);
        return true;
    }

    function permit(address owner, address spender, uint256 value, uint256 deadline, uint8 v, bytes32 r, bytes32 s) external {
        require(deadline >= block.timestamp, 'UniswapV2: EXPIRED');
        bytes32 digest = keccak256(
            abi.encodePacked(
                '\x19\x01',
                DOMAIN_SEPARATOR,
                keccak256(abi.encode(PERMIT_TYPEHASH, owner, spender, value, nonces[owner]++, deadline))
            )
        );
        address recoveredAddress = ecrecover(digest, v, r, s);
        require(recoveredAddress != address(0) && recoveredAddress == owner, 'UniswapV2: INVALID_SIGNATURE');
        _approve(owner, spender, value);
    }
}

// File: @openzeppelin/contracts/math/Math.sol

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

/**
 * @dev Standard math utilities missing in the Solidity language.
 */
library Math {
    /**
     * @dev Returns the largest of two numbers.
     */
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    /**
     * @dev Returns the smallest of two numbers.
     */
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    /**
     * @dev Returns the average of two numbers. The result is rounded towards
     * zero.
     */
    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b) / 2 can overflow, so we distribute
        return (a / 2) + (b / 2) + ((a % 2 + b % 2) / 2);
    }
}

// File: contracts/libraries/UQ112x112.sol

pragma solidity >=0.6.6;

// a library for handling binary fixed point numbers (https://en.wikipedia.org/wiki/Q_(number_format))

// range: [0, 2**112 - 1]
// resolution: 1 / 2**112

library UQ112x112 {
    uint224 constant Q112 = 2**112;

    // encode a uint256 as a UQ112x112
    function encode(uint256 y) internal pure returns (uint224 z) {
        z = uint224(y) * Q112; // never overflows
    }

    // divide a UQ112x112 by a uint256, returning a UQ112x112
    function uqdiv(uint224 x, uint256 y) internal pure returns (uint224 z) {
        z = x / uint224(y);
    }
}

// File: contracts/libraries/Math2.sol

pragma solidity >=0.6.6;

// a library for performing various math operations

library Math2 {
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

// File: @openzeppelin/contracts/token/erc20/IERC20.sol

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// File: contracts/interfaces/IUniswapV2Callee.sol

pragma solidity >=0.6.6;

interface IUniswapV2Callee {
    function uniswapV2Call(address sender, uint amount0, uint amount1, bytes calldata data) external;
}

// File: contracts/UniswapV2Pair.sol

pragma solidity >=0.6.6;








contract UniswapV2Pair is UniswapV2ERC20 {
    using SafeMath  for uint;
    using SafeMath for uint256;
    using UQ112x112 for uint224;

    uint256 public constant MINIMUM_LIQUIDITY = 10**3;
    bytes4 private constant SELECTOR = bytes4(keccak256(bytes('transfer(address,uint256)')));

    address public factory;
    address public token0;
    address public token1;

    uint256 public aFactor;
    uint256 private reserve0;           // uses single storage slot, accessible via getReserves
    uint256 private reserve1;           // uses single storage slot, accessible via getReserves
    uint256 private aReserve0;           // uses single storage slot
    uint256 private aReserve1;           // uses single storage slot
    uint32  private blockTimestampLast; // uses single storage slot, accessible via getReserves

    uint256 public price0CumulativeLast;
    uint256 public price1CumulativeLast;
    uint256 public kLast; // reserve0 * reserve1, as of immediately after the most recent liquidity event

    uint256 private unlocked = 1;
    modifier lock() {
        require(unlocked == 1, 'UniswapV2: LOCKED');
        unlocked = 0;
        _;
        unlocked = 1;
    }

    function getReserves() public view returns (uint256 _reserve0, uint256 _reserve1, uint32 _blockTimestampLast) {
        _reserve0 = reserve0;
        _reserve1 = reserve1;
        _blockTimestampLast = blockTimestampLast;
    }

    function getPairInfo()
        public
        view
        returns (
            uint256 _reserve0,
            uint256 _reserve1,
            uint256 _aReserve0,
            uint256 _aReserve1,
            uint256 _aFactor
        )
    {
        // gas saving to read reserve data
        _reserve0 = reserve0;
        _reserve1 = reserve1;
        _aFactor = aFactor;
        _aReserve0 = aReserve0;
        _aReserve1 = aReserve1;
        if (_aFactor == 10000) {
            _aReserve0 = _reserve0;
            _aReserve1 = _reserve1;
        }
    }

    function getFee() internal view returns (uint256 _fee) {
        _fee = uint256(1000).sub(IUniswapV2Factory(factory).sFee());
    }

    function _safeTransfer(address token, address to, uint256 value) private {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(SELECTOR, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'UniswapV2: TRANSFER_FAILED');
    }

    event Mint(address indexed sender, uint256 amount0, uint256 amount1);
    event Burn(address indexed sender, uint256 amount0, uint256 amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint256 reserve0, uint256 reserve1, uint256 aReserve0, uint256 aReserve1);

    constructor() public {
        factory = msg.sender;
    }

    // called once by the factory at time of deployment
    function initialize(address _token0, address _token1, uint256 _aFactor) external {
        require(msg.sender == factory, 'UniswapV2: FORBIDDEN'); // sufficient check
        token0 = _token0;
        token1 = _token1;
        aFactor = _aFactor;
    }

    // update reserves and, on the first call per block, price accumulators
    function _update(uint256 balance0, uint256 balance1, uint256 _reserve0, uint256 _reserve1, uint256 _aReserve0, uint256 _aReserve1) private {
        require(balance0 <= uint256(-1) && balance1 <= uint256(-1), 'UniswapV2: OVERFLOW');
        uint32 blockTimestamp = uint32(block.timestamp % 2**32);
        uint32 timeElapsed = blockTimestamp - blockTimestampLast; // overflow is desired
        if (timeElapsed > 0 && _reserve0 != 0 && _reserve1 != 0) {
            // * never overflows, and + overflow is desired
            price0CumulativeLast += uint256(UQ112x112.encode(_reserve1).uqdiv(_reserve0)) * timeElapsed;
            price1CumulativeLast += uint256(UQ112x112.encode(_reserve0).uqdiv(_reserve1)) * timeElapsed;
        }
        reserve0 = uint256(balance0);
        reserve1 = uint256(balance1);
        aReserve0 = reserve0;
        aReserve1 = reserve1;
        if(aFactor > 10000){
            assert(_aReserve0 >= balance0 && _aReserve1 >= balance1);
            aReserve0 = _aReserve0;
            aReserve1 = _aReserve1;
        }
        address bestPair = IUniswapV2Factory(factory).getBestPair(token0, token1);
        if(bestPair == address(0)) {
            IUniswapV2Factory(factory).updateBestK(aFactor);
        }
        if(bestPair != address(0) && IUniswapV2Pair(bestPair).kLast() < uint256(reserve0).mul(reserve1)){
            IUniswapV2Factory(factory).updateBestK(aFactor);
        }
        
        blockTimestampLast = blockTimestamp;
        emit Sync(reserve0, reserve1, aReserve0, aReserve1);
    }

    // if fee is on, mint liquidity equivalent to 1/6th of the growth in sqrt(k)
    function _mintFee(uint256 _reserve0, uint256 _reserve1) private returns (bool feeOn) {
        address feeTo = IUniswapV2Factory(factory).feeTo();
        feeOn = feeTo != address(0);
        uint256 pFee = IUniswapV2Factory(factory).pFee();
        uint256 _kLast = kLast; // gas savings
        if (feeOn) {
            if (_kLast != 0) {
                uint256 rootK = Math2.sqrt(uint256(_reserve0).mul(_reserve1));
                uint256 rootKLast = Math2.sqrt(_kLast);
                if (rootK > rootKLast) {
                    uint256 numerator = totalSupply.mul(rootK.sub(rootKLast));
                    uint256 denominator = rootK.mul(pFee).add(rootKLast);
                    uint256 liquidity = numerator / denominator;
                    if (liquidity > 0) _mint(feeTo, liquidity);
                }
            }
        } else if (_kLast != 0) {
            kLast = 0;
        }
    }

    // this low-level function should be called from a contract which performs important safety checks
    function mint(address to) external lock returns (uint256 liquidity) {
        (uint256 _reserve0, uint256 _reserve1,) = getReserves(); // gas savings
        uint256 balance0 = IERC20(token0).balanceOf(address(this));
        uint256 balance1 = IERC20(token1).balanceOf(address(this));
        uint256 amount0 = balance0.sub(_reserve0);
        uint256 amount1 = balance1.sub(_reserve1);
        uint256 _aReserve0;
        uint256 _aReserve1;

        bool feeOn = _mintFee(_reserve0, _reserve1);
        uint256 _totalSupply = totalSupply; // gas savings, must be defined here since totalSupply can update in _mintFee
        if (_totalSupply == 0) {
            if(aFactor > 10000){
                _aReserve0 = uint256(balance0.mul(aFactor) / (10000));
                _aReserve1 = uint256(balance1.mul(aFactor) / (10000));
            }
            liquidity = Math2.sqrt(amount0.mul(amount1)).sub(MINIMUM_LIQUIDITY);
           _mint(address(0), MINIMUM_LIQUIDITY); // permanently lock the first MINIMUM_LIQUIDITY tokens
        } else {
            liquidity = Math.min(amount0.mul(_totalSupply) / _reserve0, amount1.mul(_totalSupply) / _reserve1);
            if(aFactor > 10000){
                uint256 a = liquidity.add(_totalSupply);
                _aReserve0 = uint256(Math.max(aReserve0.mul(a) / (_totalSupply), balance0));
                _aReserve1 = uint256(Math.max(aReserve1.mul(a) / (_totalSupply), balance1));
            }
        }
        require(liquidity > 0, 'UniswapV2: INSUFFICIENT_LIQUIDITY_MINTED');
        _mint(to, liquidity);

        _update(balance0, balance1, _reserve0, _reserve1, _aReserve0, _aReserve1);
        if (feeOn) kLast = uint256(reserve0).mul(reserve1); // reserve0 and reserve1 are up-to-date
        emit Mint(msg.sender, amount0, amount1);
    }

    // this low-level function should be called from a contract which performs important safety checks
    function burn(address to) external lock returns (uint256 amount0, uint256 amount1) {
        (uint256 _reserve0, uint256 _reserve1,) = getReserves(); // gas savings
        address _token0 = token0;                                // gas savings
        address _token1 = token1;                                // gas savings
        uint256 balance0 = IERC20(_token0).balanceOf(address(this));
        uint256 balance1 = IERC20(_token1).balanceOf(address(this));
        uint256 liquidity = balanceOf[address(this)];

        bool feeOn = _mintFee(_reserve0, _reserve1);
        uint256 _totalSupply = totalSupply; // gas savings, must be defined here since totalSupply can update in _mintFee
        amount0 = liquidity.mul(balance0) / _totalSupply; // using balances ensures pro-rata distribution
        amount1 = liquidity.mul(balance1) / _totalSupply; // using balances ensures pro-rata distribution
        require(amount0 > 0 && amount1 > 0, 'UniswapV2: INSUFFICIENT_LIQUIDITY_BURNED');
        _burn(address(this), liquidity);
        _safeTransfer(_token0, to, amount0);
        _safeTransfer(_token1, to, amount1);
        balance0 = IERC20(_token0).balanceOf(address(this));
        balance1 = IERC20(_token1).balanceOf(address(this));

        uint256 _aReserve0;
        uint256 _aReserve1;
        if (aFactor > 10000) {
            uint256 b = Math.min(
                balance0.mul(_totalSupply) / (_reserve0),
                balance1.mul(_totalSupply) / (_reserve1)
            );
            _aReserve0 = uint256(Math.max(aReserve0.mul(b) / (_totalSupply), balance0));
            _aReserve1 = uint256(Math.max(aReserve1.mul(b) / (_totalSupply), balance1));
        }

        _update(balance0, balance1, _reserve0, _reserve1, _aReserve0, _aReserve1);
        if (feeOn) kLast = uint256(reserve0).mul(reserve1); // reserve0 and reserve1 are up-to-date
        emit Burn(msg.sender, amount0, amount1, to);
    }

    // this low-level function should be called from a contract which performs important safety checks
    function swap(uint256 amount0Out, uint256 amount1Out, address to, bytes calldata data) external lock {
        require(amount0Out > 0 || amount1Out > 0, 'UniswapV2: INSUFFICIENT_OUTPUT_AMOUNT');
        uint256[4] memory _reserves;
        (_reserves[0], _reserves[1], _reserves[2], _reserves[3], ) = getPairInfo(); // gas savings
        require(amount0Out < _reserves[0] && amount1Out < _reserves[1], 'UniswapV2: INSUFFICIENT_LIQUIDITY');

        uint256[2] memory balance;
        //uint256 balance1;
        uint256[2] memory aReserve;
        //uint256 _aReserve1 = aReserve1;
        { // scope for _token{0,1}, avoids stack too deep errors
            address _token0 = token0;
            address _token1 = token1;
            require(to != _token0 && to != _token1, 'UniswapV2: INVALID_TO');
            if (amount0Out > 0) _safeTransfer(_token0, to, amount0Out); // optimistically transfer tokens
            if (amount1Out > 0) _safeTransfer(_token1, to, amount1Out); // optimistically transfer tokens
            if (data.length > 0) IUniswapV2Callee(to).uniswapV2Call(msg.sender, amount0Out, amount1Out, data);
            balance[0] = IERC20(_token0).balanceOf(address(this));
            balance[1] = IERC20(_token1).balanceOf(address(this));
            if (aFactor > 10000) {
                aReserve[0] = uint256(aReserve0.add(balance[0]).sub(_reserves[0]));
                aReserve[1] = uint256(aReserve1.add(balance[1]).sub(_reserves[1]));
            }
        }
        uint256 amount0In = balance[0] > _reserves[0] - amount0Out ? balance[0] - (_reserves[0] - amount0Out) : 0;
        uint256 amount1In = balance[1] > _reserves[1] - amount1Out ? balance[1] - (_reserves[1] - amount1Out) : 0;
        require(amount0In > 0 || amount1In > 0, 'UniswapV2: INSUFFICIENT_INPUT_AMOUNT');
        { // scope for reserve{0,1}Adjusted, avoids stack too deep errors
        uint256 fee = getFee();
        uint256 balance0Adjusted = aFactor > 10000 ? aReserve[0].mul(1000).sub(amount0In.mul(3)) : balance[0].mul(1000).sub(amount0In.mul(fee));
        uint256 balance1Adjusted = aFactor > 10000 ? aReserve[1].mul(1000).sub(amount1In.mul(3)) : balance[1].mul(1000).sub(amount1In.mul(fee));
        uint256 balancesBeforeAdjusted = aFactor > 10000 ? uint256(_reserves[2]).mul(_reserves[3]).mul(1000**2) : uint256(_reserves[0]).mul(_reserves[1]).mul(1000**2);
        require(balance0Adjusted.mul(balance1Adjusted) >= balancesBeforeAdjusted, 'UniswapV2: K');
        }

        _update(balance[0], balance[1], _reserves[0], _reserves[1], aReserve[0], aReserve[1]);
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
        (uint256 _reserve0, uint256 _reserve1,) = getReserves();
        uint256 balance0 = IERC20(token0).balanceOf(address(this));
        uint256 balance1 = IERC20(token1).balanceOf(address(this));
        uint256 _aReserve0;
        uint256 _aReserve1;
        if(aFactor > 10000){
            uint256 _totalSupply = totalSupply;
            uint256 b = Math.min(
                balance0.mul(_totalSupply) / _reserve0,
                balance1.mul(_totalSupply) / _reserve1
            );
            _aReserve0 = Math.max(aReserve0.mul(b) / (_totalSupply), balance0);
            _aReserve1 = Math.max(aReserve1.mul(b) / (_totalSupply), balance1);
        }
        _update(balance0, balance1, _reserve0, _reserve1, _aReserve0, _aReserve1);
    }
}

// File: contracts/UniswapV2Factory.sol

pragma solidity >=0.6.6;


contract UniswapV2Factory is IUniswapV2Factory {
    address public override feeTo;
    address public override feeToSetter;
    uint256 public override pFee = 5;
    uint256 public override sFee = 997;
    address public dev;
    bool public toggled = true;
    bytes32 public constant INIT_CODE_PAIR_HASH = keccak256(abi.encodePacked(type(UniswapV2Pair).creationCode));

    mapping(address => mapping(address => mapping(uint256 => address))) public override getPair;
    mapping(address => mapping(address => uint256)) public override getBestK;
    mapping(address => bool) public override isPair;
    address[] public override allPairs;

    event PairCreated(address indexed token0, address indexed token1, address pair, uint256 aFactor, uint256);

    constructor(address _feeToSetter) public {
        feeToSetter = _feeToSetter;
        dev = msg.sender;
    }

    function allPairsLength() external view override returns (uint256) {
        return allPairs.length;
    }

    //front end call
    function getBestPair(address _tokenA, address _tokenB) external override view returns (address) {
        uint256 bestK = getBestK[_tokenA][_tokenB];
        if(bestK == 0){
            return address(0);
        }
        return getPair[_tokenA][_tokenB][bestK];
    }

    function createPair(address tokenA, address tokenB, uint256 aFactor) external override returns (address pair) {
        if(toggled){
            require(msg.sender == dev, 'UniswapV2: FORBIDDEN');
        }
        require(tokenA != tokenB, 'UniswapV2: IDENTICAL_ADDRESSES');
        (address token0, address token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        require(token0 != address(0), 'UniswapV2: ZERO_ADDRESS');
        require(aFactor >= 10000, "Invalid factor");
        require(getPair[token0][token1][aFactor] == address(0), 'UniswapV2: PAIR_EXISTS'); // single check is sufficient
        bytes memory bytecode = type(UniswapV2Pair).creationCode;
        bytes32 salt = keccak256(abi.encodePacked(token0, token1, aFactor));
        assembly {
            pair := create2(0, add(bytecode, 32), mload(bytecode), salt)
        }
        IUniswapV2Pair(pair).initialize(token0, token1, aFactor);
        getPair[token0][token1][aFactor] = pair;
        getPair[token1][token0][aFactor] = pair; // populate mapping in the reverse direction
        isPair[pair] = true;
        allPairs.push(pair);
        emit PairCreated(token0, token1, pair, aFactor, allPairs.length);
    }

    // update best K
    function updateBestK(uint256 _aFactor) external override {
        require(isPair[msg.sender], 'UniswapV2: FORBIDDEN');
        address _tokenA = IUniswapV2Pair(msg.sender).token0();
        address _tokenB = IUniswapV2Pair(msg.sender).token1();
        require(_aFactor >= 10000, "Invalid factor");
        getBestK[_tokenA][_tokenB] = _aFactor;
        getBestK[_tokenB][_tokenA] = _aFactor;
    }

    function setFeeTo(address _feeTo) external override {
        require(msg.sender == feeToSetter, 'UniswapV2: FORBIDDEN');
        feeTo = _feeTo;
    }

    function setFeeToSetter(address _feeToSetter) external override {
        require(msg.sender == feeToSetter, 'UniswapV2: FORBIDDEN');
        feeToSetter = _feeToSetter;
    }

    function setPlatformFee(uint256 _platformFee) external override {
        require(msg.sender == feeToSetter, 'UniswapV2: FORBIDDEN');
        pFee = _platformFee;
    }

    function setSwapFee(uint256 _swapFee) external override {
        require(msg.sender == dev, 'UniswapV2: FORBIDDEN');
        require(_swapFee <= 1000, 'UniswapV2: INVALID_FEE');
        sFee = _swapFee;
    }

    function toggle() external {
        require(msg.sender == dev, 'UniswapV2: FORBIDDEN');
        toggled = !toggled;
    }

    function setDev(address _dev) external {
        require(msg.sender == dev, 'UniswapV2: FORBIDDEN');
        dev = _dev;
    }
}