/**
 *Submitted for verification at BscScan.com on 2022-06-17
*/

// SPDX-License-Identifier: GPL-3.0
// File: projects/exchange-protocol/contracts/interfaces/IStoboxCallee.sol


pragma solidity >=0.5.0;

interface IStoboxCallee {
    function stoboxCall(
        address sender,
        uint256 amount0,
        uint256 amount1,
        bytes calldata data
    ) external;
}

// File: projects/exchange-protocol/contracts/interfaces/IERC20.sol


pragma solidity >=0.5.0;

interface IERC20 {
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 value) external returns (bool);

    function transfer(address to, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);
}

// File: projects/exchange-protocol/contracts/libraries/UQ112x112.sol


pragma solidity =0.5.16;

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

// File: projects/exchange-protocol/contracts/libraries/Math.sol


pragma solidity =0.5.16;

// a library for performing various math operations

library Math {
    function min(uint256 x, uint256 y) internal pure returns (uint256 z) {
        z = x < y ? x : y;
    }

    // babylonian method (https://en.wikipedia.org/wiki/Methods_of_computing_square_roots#Babylonian_method)
    function sqrt(uint256 y) internal pure returns (uint256 z) {
        if (y > 3) {
            z = y;
            uint256 x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }
}

// File: projects/exchange-protocol/contracts/libraries/SafeMath.sol


pragma solidity >=0.5.0 <0.7.0;

// a library for performing overflow-safe math, courtesy of DappHub (https://github.com/dapphub/ds-math)

library SafeMath {
    function add(uint256 x, uint256 y) internal pure returns (uint256 z) {
        require((z = x + y) >= x, "ds-math-add-overflow");
    }

    function sub(uint256 x, uint256 y) internal pure returns (uint256 z) {
        require((z = x - y) <= x, "ds-math-sub-underflow");
    }

    function mul(uint256 x, uint256 y) internal pure returns (uint256 z) {
        require(y == 0 || (z = x * y) / y == x, "ds-math-mul-overflow");
    }
}

// File: projects/exchange-protocol/contracts/interfaces/IStoboxERC20.sol


pragma solidity >=0.5.0;

interface IStoboxERC20 {
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

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);

    function PERMIT_TYPEHASH() external pure returns (bytes32);

    function nonces(address owner) external view returns (uint256);

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;
}

// File: projects/exchange-protocol/contracts/DSSwap_ERC20.sol


pragma solidity =0.5.16;



contract DSSwap_ERC20 is IStoboxERC20 {
    using SafeMath for uint256;

    string public constant name = "Stobox LPs";
    string public constant symbol = "STBU-LP";
    uint8 public constant decimals = 18;
    uint256 public totalSupply;
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    bytes32 public DOMAIN_SEPARATOR;
    // keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)");
    bytes32 public constant PERMIT_TYPEHASH = 0x6e71edae12b1b97f4d1f60370fef10105fa2faae0126114a169c64845d6126c9;
    mapping(address => uint256) public nonces;

    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);

    constructor() public {
        uint256 chainId;
        assembly {
            chainId := chainid
        }
        DOMAIN_SEPARATOR = keccak256(
            abi.encode(
                keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"),
                keccak256(bytes(name)),
                keccak256(bytes("1")),
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

    function _approve(
        address owner,
        address spender,
        uint256 value
    ) private {
        allowance[owner][spender] = value;
        emit Approval(owner, spender, value);
    }

    function _transfer(
        address from,
        address to,
        uint256 value
    ) private {
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

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool) {
        if (allowance[from][msg.sender] != uint256(-1)) {
            allowance[from][msg.sender] = allowance[from][msg.sender].sub(value);
        }
        _transfer(from, to, value);
        return true;
    }

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external {
        require(deadline >= block.timestamp, "Stobox: EXPIRED");
        bytes32 digest = keccak256(
            abi.encodePacked(
                "\x19\x01",
                DOMAIN_SEPARATOR,
                keccak256(abi.encode(PERMIT_TYPEHASH, owner, spender, value, nonces[owner]++, deadline))
            )
        );
        address recoveredAddress = ecrecover(digest, v, r, s);
        require(recoveredAddress != address(0) && recoveredAddress == owner, "Stobox: INVALID_SIGNATURE");
        _approve(owner, spender, value);
    }
}

// File: projects/exchange-protocol/contracts/interfaces/IStoboxPair.sol


pragma solidity >=0.5.0;

interface IStoboxPair {
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);

    function liquidityFee() external pure returns (uint256);

    function treasuryFee() external pure returns (uint256);
    
    function burnFee() external pure returns (uint256);

    function isNoFee() external pure returns (bool);

    function name() external pure returns (string memory);

    function symbol() external pure returns (string memory);

    function decimals() external pure returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 value) external returns (bool);

    function transfer(address to, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);

    function PERMIT_TYPEHASH() external pure returns (bytes32);

    function nonces(address owner) external view returns (uint256);

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    event Mint(address indexed sender, uint256 amount0, uint256 amount1);
    event Burn(address indexed sender, uint256 amount0, uint256 amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint256 amount0In,
        uint256 amount1In,
        uint256 amount0Out,
        uint256 amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint256);

    function factory() external view returns (address);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves()
        external
        view
        returns (
            uint112 reserve0,
            uint112 reserve1,
            uint32 blockTimestampLast
        );

    function getTotalFee() external view returns (uint256);

    function getTreasuryBurnFee() external view returns (uint256);

    function price0CumulativeLast() external view returns (uint256);

    function price1CumulativeLast() external view returns (uint256);

    function kLast() external view returns (uint256);

    function mint(address to) external returns (uint256 liquidity);

    function burn(address to) external returns (uint256 amount0, uint256 amount1);

    function swap(
        uint256 amount0Out,
        uint256 amount1Out,
        address to,
        bytes calldata data
    ) external;

    function skim(address to) external;

    function sync() external;

    function initialize(address, address, uint, uint, uint) external;

    function setLiquidityFee(uint256 _liquidityFee) external;

    function setTreasuryFee(uint256 _treasuryFee) external;

    function setBurnFee(uint256 _burnFee) external;
}

// File: projects/exchange-protocol/contracts/interfaces/IStoboxFactory.sol


pragma solidity >=0.5.0;

interface IStoboxFactory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint256);

    function defaultLiquidityFee() external pure returns (uint256);

    function defaultTreasuryFee() external pure returns (uint256);
    
    function defaultBurnFee() external pure returns (uint256);

    function feeTo() external view returns (address);

    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);

    function allPairs(uint256) external view returns (address pair);

    function allPairsLength() external view returns (uint256);

    function createPair(
        address tokenA, 
        address tokenB, 
        address sender, 
        uint256 liquidityFee,
        uint256 treasuryFee,
        uint256 burnFee
    ) external returns (address pair);

    function setFeeTo(address) external;

    function setFeeToSetter(address) external;

    function addSecurityTokenOwner(address) external;

    function removeSecurityTokenOwner(address) external;

    function addAdmin(address) external;

    function removeAdmin(address) external returns(bool);

    function INIT_CODE_PAIR_HASH() external view returns (bytes32);
}

// File: projects/exchange-protocol/contracts/DSSwap_Pair.sol


pragma solidity =0.5.16;








contract DSSwap_Pair is IStoboxPair, DSSwap_ERC20 {
    using SafeMath for uint256;
    using UQ112x112 for uint224;

    uint256 public constant MINIMUM_LIQUIDITY = 10**3;
    bytes4 private constant SELECTOR = bytes4(keccak256(bytes("transfer(address,uint256)")));

    address public factory;
    address public token0;
    address public token1;

    uint112 private reserve0; // uses single storage slot, accessible via getReserves
    uint112 private reserve1; // uses single storage slot, accessible via getReserves
    uint32 private blockTimestampLast; // uses single storage slot, accessible via getReserves

    uint256 public price0CumulativeLast;
    uint256 public price1CumulativeLast;
    uint256 public kLast; // reserve0 * reserve1, as of immediately after the most recent liquidity event

    uint256 public liquidityFee; // default 22
    uint256 public treasuryFee; // default 3
    uint256 public burnFee; // default 2
    bool public isNoFee;

    uint256 private unlocked = 1;
    modifier lock() {
        require(unlocked == 1, "Stobox: LOCKED");
        unlocked = 0;
        _;
        unlocked = 1;
    }

    function getReserves()
        public
        view
        returns (
            uint112 _reserve0,
            uint112 _reserve1,
            uint32 _blockTimestampLast
        )
    {
        _reserve0 = reserve0;
        _reserve1 = reserve1;
        _blockTimestampLast = blockTimestampLast;
    }

    function getTotalFee() public view returns (uint256) {
        return liquidityFee + treasuryFee + burnFee;
    }

    function getTreasuryBurnFee() public view returns(uint256) {
        return treasuryFee + burnFee;
    }

    function _safeTransfer(
        address token,
        address to,
        uint256 value
    ) private {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(SELECTOR, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), "Stobox: TRANSFER_FAILED");
    }

    event Mint(address indexed sender, uint256 amount0, uint256 amount1);
    event Burn(address indexed sender, uint256 amount0, uint256 amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint256 amount0In,
        uint256 amount1In,
        uint256 amount0Out,
        uint256 amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    constructor() public {
        factory = msg.sender;
    }

    // called once by the factory at time of deployment
    function initialize(
        address _token0,
        address _token1,
        uint256 _liquidityFee,
        uint256 _treasuryFee,
        uint256 _burnFee
    ) external {
        require(msg.sender == factory, "Stobox: FORBIDDEN"); // sufficient check
        require(isFeeValid(_liquidityFee, _treasuryFee, _burnFee), "Stobox: INVALID_FEE_AMOUNT");
        token0 = _token0;
        token1 = _token1;
        liquidityFee = _liquidityFee;
        treasuryFee = _treasuryFee;
        burnFee = _burnFee;
        isNoFeeUpdate();
    }

    // update reserves and, on the first call per block, price accumulators
    function _update(
        uint256 balance0,
        uint256 balance1,
        uint112 _reserve0,
        uint112 _reserve1
    ) private {
        require(balance0 <= uint112(-1) && balance1 <= uint112(-1), "Stobox: OVERFLOW");
        uint32 blockTimestamp = uint32(block.timestamp % 2**32);
        uint32 timeElapsed = blockTimestamp - blockTimestampLast; // overflow is desired
        if (timeElapsed > 0 && _reserve0 != 0 && _reserve1 != 0) {
            // * never overflows, and + overflow is desired
            price0CumulativeLast += uint256(UQ112x112.encode(_reserve1).uqdiv(_reserve0)) * timeElapsed;
            price1CumulativeLast += uint256(UQ112x112.encode(_reserve0).uqdiv(_reserve1)) * timeElapsed;
        }
        reserve0 = uint112(balance0);
        reserve1 = uint112(balance1);
        blockTimestampLast = blockTimestamp;
        emit Sync(reserve0, reserve1);
    }

    // if fee is on, mint liquidity equivalent to 8/25 of the growth in sqrt(k)
    function _mintFee(uint112 _reserve0, uint112 _reserve1) private returns (bool feeOn) {
        address feeTo = IStoboxFactory(factory).feeTo();
        uint treasuryBurnFee = getTreasuryBurnFee();
        feeOn = feeTo != address(0) && treasuryBurnFee != 0;
        // feeOn = feeTo != address(0) && !isNoFee;
        uint256 _kLast = kLast; // gas savings
        if (feeOn) {
            if (_kLast != 0) {
                uint256 rootK = Math.sqrt(uint256(_reserve0).mul(_reserve1));
                uint256 rootKLast = Math.sqrt(_kLast);
                if (rootK > rootKLast) {
                    uint256 numerator = totalSupply.mul(rootK.sub(rootKLast));
                    uint256 denominator = rootK.mul(treasuryBurnFee).add(rootKLast);
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
        (uint112 _reserve0, uint112 _reserve1, ) = getReserves(); // gas savings
        uint256 balance0 = IERC20(token0).balanceOf(address(this));
        uint256 balance1 = IERC20(token1).balanceOf(address(this));
        uint256 amount0 = balance0.sub(_reserve0);
        uint256 amount1 = balance1.sub(_reserve1);

        bool feeOn = _mintFee(_reserve0, _reserve1);
        uint256 _totalSupply = totalSupply; // gas savings, must be defined here since totalSupply can update in _mintFee
        if (_totalSupply == 0) {
            liquidity = Math.sqrt(amount0.mul(amount1)).sub(MINIMUM_LIQUIDITY);
            _mint(address(0), MINIMUM_LIQUIDITY); // permanently lock the first MINIMUM_LIQUIDITY tokens
        } else {
            liquidity = Math.min(amount0.mul(_totalSupply) / _reserve0, amount1.mul(_totalSupply) / _reserve1);
        }
        require(liquidity > 0, "Stobox: INSUFFICIENT_LIQUIDITY_MINTED");
        _mint(to, liquidity);

        _update(balance0, balance1, _reserve0, _reserve1);
        if (feeOn) kLast = uint256(reserve0).mul(reserve1); // reserve0 and reserve1 are up-to-date
        emit Mint(msg.sender, amount0, amount1);
    }

    // this low-level function should be called from a contract which performs important safety checks
    function burn(address to) external lock returns (uint256 amount0, uint256 amount1) {
        (uint112 _reserve0, uint112 _reserve1, ) = getReserves(); // gas savings
        address _token0 = token0; // gas savings
        address _token1 = token1; // gas savings
        uint256 balance0 = IERC20(_token0).balanceOf(address(this));
        uint256 balance1 = IERC20(_token1).balanceOf(address(this));
        uint256 liquidity = balanceOf[address(this)];

        bool feeOn = _mintFee(_reserve0, _reserve1);
        uint256 _totalSupply = totalSupply; // gas savings, must be defined here since totalSupply can update in _mintFee
        amount0 = liquidity.mul(balance0) / _totalSupply; // using balances ensures pro-rata distribution
        amount1 = liquidity.mul(balance1) / _totalSupply; // using balances ensures pro-rata distribution
        require(amount0 > 0 && amount1 > 0, "Stobox: INSUFFICIENT_LIQUIDITY_BURNED");
        _burn(address(this), liquidity);
        _safeTransfer(_token0, to, amount0);
        _safeTransfer(_token1, to, amount1);
        balance0 = IERC20(_token0).balanceOf(address(this));
        balance1 = IERC20(_token1).balanceOf(address(this));

        _update(balance0, balance1, _reserve0, _reserve1);
        if (feeOn) kLast = uint256(reserve0).mul(reserve1); // reserve0 and reserve1 are up-to-date
        emit Burn(msg.sender, amount0, amount1, to);
    }

    // this low-level function should be called from a contract which performs important safety checks
    function swap(
        uint256 amount0Out,
        uint256 amount1Out,
        address to,
        bytes calldata data
    ) external lock {
        require(amount0Out > 0 || amount1Out > 0, "Stobox: INSUFFICIENT_OUTPUT_AMOUNT");
        (uint112 _reserve0, uint112 _reserve1, ) = getReserves(); // gas savings
        require(amount0Out < _reserve0 && amount1Out < _reserve1, "Stobox: INSUFFICIENT_LIQUIDITY");

        uint256 balance0;
        uint256 balance1;
        {
            // scope for _token{0,1}, avoids stack too deep errors
            address _token0 = token0;
            address _token1 = token1;
            require(to != _token0 && to != _token1, "Stobox: INVALID_TO");
            if (amount0Out > 0) _safeTransfer(_token0, to, amount0Out); // optimistically transfer tokens
            if (amount1Out > 0) _safeTransfer(_token1, to, amount1Out); // optimistically transfer tokens
            if (data.length > 0) IStoboxCallee(to).stoboxCall(msg.sender, amount0Out, amount1Out, data);
            balance0 = IERC20(_token0).balanceOf(address(this));
            balance1 = IERC20(_token1).balanceOf(address(this));
        }
        uint256 amount0In = balance0 > _reserve0 - amount0Out ? balance0 - (_reserve0 - amount0Out) : 0;
        uint256 amount1In = balance1 > _reserve1 - amount1Out ? balance1 - (_reserve1 - amount1Out) : 0;
        require(amount0In > 0 || amount1In > 0, "Stobox: INSUFFICIENT_INPUT_AMOUNT");
        {
            // scope for reserve{0,1}Adjusted, avoids stack too deep errors
            uint256 balance0Adjusted;
            uint256 balance1Adjusted;
            if (isNoFee) {
                balance0Adjusted = (balance0.mul(10000));
                balance1Adjusted = (balance1.mul(10000));
            } else {
                uint256 totalFee = getTotalFee();
                balance0Adjusted = (balance0.mul(10000).sub(amount0In.mul(totalFee)));
                balance1Adjusted = (balance1.mul(10000).sub(amount1In.mul(totalFee)));
            }
            require(
                balance0Adjusted.mul(balance1Adjusted) >= uint256(_reserve0).mul(_reserve1).mul(10000**2),
                "Stobox: K"
            );
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

    // **** COMMISSION ****
    function isNoFeeUpdate() internal {
        isNoFee = liquidityFee == 0 && treasuryFee == 0 && burnFee == 0;
    }

    function isFeeValid(uint256 _liquidityFee, uint256 _treasuryFee, uint256 _burnFee) internal pure returns (bool) {
        uint totalFee = _liquidityFee + _treasuryFee + _burnFee;
        return totalFee < 10000;
    } 

    function setLiquidityFee(uint256 _liquidityFee) public {
        require(msg.sender == factory, "Stobox: FORBIDDEN");
        require(isFeeValid(_liquidityFee, treasuryFee, burnFee), "Stobox: INVALID_FEE_AMOUNT");
        liquidityFee = _liquidityFee;
        isNoFeeUpdate();
    }

    function setTreasuryFee(uint256 _treasuryFee) public {
        require(msg.sender == factory, "Stobox: FORBIDDEN");
        require(isFeeValid(liquidityFee, _treasuryFee, burnFee), "Stobox: INVALID_FEE_AMOUNT");
        treasuryFee = _treasuryFee;
        isNoFeeUpdate();
    }

    function setBurnFee(uint256 _burnFee) public {
        require(msg.sender == factory, "Stobox: FORBIDDEN");
        require(isFeeValid(liquidityFee, treasuryFee, _burnFee), "Stobox: INVALID_FEE_AMOUNT");
        burnFee = _burnFee;
        isNoFeeUpdate();
    }
}

// File: projects/exchange-protocol/contracts/DSSwap_Factory.sol


pragma solidity =0.5.16;



contract DSSwap_Factory is IStoboxFactory {
    bytes32 public constant INIT_CODE_PAIR_HASH = keccak256(abi.encodePacked(type(DSSwap_Pair).creationCode));

    address public feeTo;
    address public feeToSetter;

    mapping(address => mapping(address => address)) public getPair;
    address[] public allPairs;

    address[] public admins;
    mapping(address => bool) public securityTokenOwner;

    uint256 public defaultLiquidityFee = 22; // 0.22%
    uint256 public defaultTreasuryFee = 3; // 0.03%
    uint256 public defaultBurnFee = 5; // 0.05%

    modifier OnlyAdmin() {
        require(isAdmin(msg.sender), "Stobox: FORBIDDEN");
        _;
    }

    event PairCreated(address indexed token0, address indexed token1, address pair, uint256);

    event FeeChanged(string feeType, address pairAddress, uint256 newValue);

    constructor(address _feeToSetter, address[] memory _admins) public {
        require(_admins.length >= 1, "Stobox: NO_ADMINS_WERE_ADDED");
        feeToSetter = _feeToSetter;
        admins = _admins;
    }

    function allPairsLength() external view returns (uint256) {
        return allPairs.length;
    }

    function createPair(
        address tokenA,
        address tokenB,
        address sender,
        uint256 _liquidityFee,
        uint256 _treasuryFee,
        uint256 _burnFee
    ) external returns (address pair) {
        require(tokenA != tokenB, "Stobox: IDENTICAL_ADDRESSES");
        (address token0, address token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        require(token0 != address(0), "Stobox: ZERO_ADDRESS");
        require(getPair[token0][token1] == address(0), "Stobox: PAIR_EXISTS"); // single check is sufficient
        bytes memory bytecode = type(DSSwap_Pair).creationCode;
        bytes32 salt = keccak256(abi.encodePacked(token0, token1));
        assembly {
            pair := create2(0, add(bytecode, 32), mload(bytecode), salt)
        }
        uint256 liquidityFee = defaultLiquidityFee;
        uint256 treasuryFee = defaultLiquidityFee;
        uint256 burnFee = defaultBurnFee;
        if (isAdmin(sender)) {
            liquidityFee = _liquidityFee;
            treasuryFee = _treasuryFee;
            burnFee = _burnFee;
        } else if (isSecurityTokenOwner(sender)) {
            liquidityFee = 0;
            treasuryFee = 0;
            burnFee = 0;
        }
        IStoboxPair(pair).initialize(token0, token1, liquidityFee, treasuryFee, burnFee);
        getPair[token0][token1] = pair;
        getPair[token1][token0] = pair; // populate mapping in the reverse direction
        allPairs.push(pair);
        emit PairCreated(token0, token1, pair, allPairs.length);
    }

    function setFeeTo(address _feeTo) external {
        require(msg.sender == feeToSetter, "Stobox: FORBIDDEN");
        feeTo = _feeTo;
    }

    function setFeeToSetter(address _feeToSetter) external {
        require(msg.sender == feeToSetter, "Stobox: FORBIDDEN");
        feeToSetter = _feeToSetter;
    }

    // **** SECURITY TOKEN OWNERS ****
    function addSecurityTokenOwner(address _newOwner) external OnlyAdmin {
        require(!isAdmin(_newOwner), "Stobox: ADDRESS_REGISTRED_AS_ADMIN");
        require(!isSecurityTokenOwner(_newOwner), "Stobox: SECURITY_TOKEN_OWNER_ALREADY_EXIST");
        securityTokenOwner[_newOwner] = true;
    }

    function removeSecurityTokenOwner(address _ownerAddress) external OnlyAdmin {
        require(isSecurityTokenOwner(_ownerAddress), "Stobox: INVALID_SECURITY_TOKEN_OWNER_ADDRESS");
        delete securityTokenOwner[_ownerAddress];
    }

    function isSecurityTokenOwner(address _ownerAddress) internal view returns (bool) {
        return securityTokenOwner[_ownerAddress];
    }

    // **** ADMINS ****
    function addAdmin(address _newAdmin) external OnlyAdmin {
        require(!isAdmin(_newAdmin), "Stobox: ADMIN_ALREADY_EXIST");
        admins.push(_newAdmin);
    }

    function removeAdmin(address _adminAddress) external OnlyAdmin returns (bool) {
        require(isAdmin(_adminAddress), "Stobox: INVALID_ADMIN_ADDRESS");
        require(msg.sender != _adminAddress, "Stobox: YOU_CANNOT_REMOVE_YOURSELF");
        require(admins.length > 1, "Stobox: YOU_CANNOT_REMOVE_THE_LAST_ADMIN");
        for (uint256 i = 0; i < admins.length; i++) {
            if (admins[i] == _adminAddress) {
                if (admins.length != (i - 1)) {
                    admins[i] = admins[admins.length - 1];
                }
                admins.pop();
                return true;
            }
        }
        return false;
    }

    function isAdmin(address _adminAddress) internal view returns (bool) {
        for (uint256 i = 0; i < admins.length; i++) {
            if (admins[i] == _adminAddress) return true;
        }
        return false;
    }

    // **** COMMISSION ****
    function setLiquidityFee(address pair, uint256 _liquidityFee) public OnlyAdmin {
        IStoboxPair(pair).setLiquidityFee(_liquidityFee);
        emit FeeChanged("Liquidity", pair, _liquidityFee);
    }

    function setTreasuryFee(address pair, uint256 _treasuryFee) public OnlyAdmin {
        IStoboxPair(pair).setTreasuryFee(_treasuryFee);
        emit FeeChanged("Treasury", pair, _treasuryFee);
    }

    function setBurnFee(address pair, uint256 _burnFee) public OnlyAdmin {
        IStoboxPair(pair).setBurnFee(_burnFee);
        emit FeeChanged("Burn", pair, _burnFee);
    }
}