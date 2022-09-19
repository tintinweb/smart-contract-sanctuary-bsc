/**
 *Submitted for verification at BscScan.com on 2022-09-18
*/

//SPDX-License-Identifier: UNLICENSED                                                                                                                                             

pragma solidity ^0.8;

interface IFilterManager {
    function treasuryAddress() external view returns (address);
    function factoryAddress() external view returns (address);
    function isTokenVerified(address) external view returns (bool);
    function isLiquidityLocked(address, address) external view returns (bool);
}

interface IFilterFactory {
    event PairCreated(address indexed, address indexed, address, uint);
}

interface IFilterPair {
    function initialize(address, address, address) external;
}

interface IERC20 {
    function transfer(address, uint) external returns (bool);
    function balanceOf(address) external view returns (uint);
}

interface IFilterCallee {
    function filterCall(address, uint, uint, bytes calldata) external;
}

library Math {
    function min(uint x, uint y) internal pure returns (uint z) {
        z = x < y ? x : y;
    }

    function sqrt(uint y) internal pure returns (uint z) {
        if (y > 3) {
            z = y;
            uint x = y / 2 + 1;
            
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } 
        
        else if (y != 0) z = 1;
    }
}

library UQ112x112 {
    uint224 constant Q112 = 2**112;

    function encode(uint112 y) internal pure returns (uint224 z) {
        z = uint224(y) * Q112;
    }

    function uqdiv(uint224 x, uint112 y) internal pure returns (uint224 z) {
        z = x / uint224(y);
    }
}

contract FilterERC20 {
    string public constant name = "Filter LPs";
    string public constant symbol = "Filter-LP";
    uint8 public constant decimals = 18;
    uint public totalSupply;

    mapping(address => uint) public balanceOf;
    mapping(address => mapping(address => uint)) public allowance;

    IFilterManager ERC20FilterManager;

    bytes32 public DOMAIN_SEPARATOR;
    bytes32 public constant PERMIT_TYPEHASH = 0x5fae9ec55a1e547936e0e74d606b44cd5f912f9adcd0bba561fea62d570259e9;
    
    mapping(address => uint) public nonces;

    event Approval(address indexed, address indexed, uint);
    event Transfer(address indexed, address indexed, uint);

    constructor() {
        DOMAIN_SEPARATOR = keccak256(
            abi.encode(
                keccak256("EIP712Domain(string name,string version,uint chainId,address verifyingContract)"),
                keccak256(bytes(name)),
                keccak256(bytes("1")),
                97,
                address(this)
            )
        );    
    }

    function _mint(address to, uint value) internal {
        totalSupply += value;
        balanceOf[to] += value;
        emit Transfer(address(0), to, value);
    }

    function _burn(address from, uint value) internal {
        balanceOf[from] -= value;
        totalSupply -= value;
        emit Transfer(from, address(0), value);
    }

    function _approve(address owner, address spender, uint value) private {
        allowance[owner][spender] = value;
        emit Approval(owner, spender, value);
    }

    function _transfer(address from, address to, uint value) private {
        balanceOf[from] -= value;
        balanceOf[to] += value;
        emit Transfer(from, to, value);
    }

    function approve(address spender, uint value) external returns (bool) {
        _approve(msg.sender, spender, value);
        return true;
    }

    function transfer(address to, uint value) external returns (bool) {
        require(!ERC20FilterManager.isLiquidityLocked(msg.sender, address(this)), "FilterPair: LP_TRANSFER_LOCKED");
        _transfer(msg.sender, to, value);
        return true;
    }

    function transferFrom(address from, address to, uint value) external returns (bool) {
        require(!ERC20FilterManager.isLiquidityLocked(from, address(this)), "FilterPair: LP_TRANSFER_LOCKED");

        if (allowance[from][msg.sender] != type(uint).max) allowance[from][msg.sender] -= value;

        _transfer(from, to, value);
        return true;
    }

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external {
        require(deadline >= block.timestamp, "FilterPair: EXPIRED");
        bytes32 digest = keccak256(abi.encodePacked("\x19\x01", DOMAIN_SEPARATOR, keccak256(abi.encode(PERMIT_TYPEHASH, owner, spender, value, nonces[owner]++, deadline))));
        address recoveredAddress = ecrecover(digest, v, r, s);
        require(recoveredAddress != address(0) && recoveredAddress == owner, "FilterPair: INVALID_SIGNATURE");
        _approve(owner, spender, value);
    }
}

contract FilterPair is FilterERC20 {
    using UQ112x112 for uint224;

    uint public constant MINIMUM_LIQUIDITY = 10**3;

    IFilterManager filterManager;

    address public token0;
    address public token1;

    uint112 private reserve0;
    uint112 private reserve1;
    uint32 private blockTimestampLast;

    uint public price0CumulativeLast;
    uint public price1CumulativeLast;
    uint public kLast;

    bool private unlocked = true;

    event Mint(address indexed, uint, uint);
    event Burn(address indexed, uint, uint, address indexed);
    event Swap(address indexed, uint, uint, uint, uint, address indexed);
    event Sync(uint112, uint112);
    
    modifier reentrancyLock() {
        require(unlocked == true, "FilterPair: LOCKED");
        unlocked = false;
        _;
        unlocked = true;
    }

    function getReserves() public view returns (uint112 _reserve0, uint112 _reserve1, uint32 _blockTimestampLast) {
        _reserve0 = reserve0;
        _reserve1 = reserve1;
        _blockTimestampLast = blockTimestampLast;
    }

    function _safeTransfer(address token, address to, uint value) private {
        require(IERC20(token).transfer(to, value), "FilterPair: TRANSFER_FAILED");
    }

    function initialize(address _token0, address _token1, address _managerAddress) external {
        filterManager = IFilterManager(_managerAddress);
        ERC20FilterManager = IFilterManager(_managerAddress);
        require(msg.sender == filterManager.factoryAddress(), "FilterPair: FORBIDDEN");
        token0 = _token0;
        token1 = _token1;        
    }

    function _update(uint balance0, uint balance1, uint112 _reserve0, uint112 _reserve1) private {
        uint32 blockTimestamp = uint32(block.timestamp % 2**32);
        uint32 timeElapsed = blockTimestamp - blockTimestampLast;

        if (timeElapsed > 0 && _reserve0 != 0 && _reserve1 != 0) {
            price0CumulativeLast += uint(UQ112x112.encode(_reserve1).uqdiv(_reserve0)) * timeElapsed;
            price1CumulativeLast += uint(UQ112x112.encode(_reserve0).uqdiv(_reserve1)) * timeElapsed;
        }

        reserve0 = uint112(balance0);
        reserve1 = uint112(balance1);
        blockTimestampLast = blockTimestamp;
        emit Sync(reserve0, reserve1);
    }

    function _mintFee(uint112 _reserve0, uint112 _reserve1) private returns (bool feeOn) {
        feeOn = filterManager.treasuryAddress() != address(0);

        if (feeOn) {
            if (kLast != 0) {
                uint rootK = Math.sqrt(uint(_reserve0) * uint(_reserve1));
                uint rootKLast = Math.sqrt(kLast);

                if (rootK > rootKLast) {
                    uint numerator = totalSupply * (rootK - rootKLast);
                    uint denominator = (rootK * 5) + rootKLast;
                    uint liquidity = numerator / denominator;

                    if (liquidity > 0) _mint(filterManager.treasuryAddress(), liquidity);
                }
            }
        } 
        
        else if (kLast != 0) kLast = 0;
    }

    function mint(address to) external reentrancyLock returns (uint liquidity) {
        (uint112 _reserve0, uint112 _reserve1, ) = getReserves();
        uint balance0 = IERC20(token0).balanceOf(address(this));
        uint balance1 = IERC20(token1).balanceOf(address(this));
        uint amount0 = balance0 - uint(_reserve0);
        uint amount1 = balance1 - uint(_reserve1);

        bool feeOn = _mintFee(_reserve0, _reserve1);
        uint _totalSupply = totalSupply;

        if (_totalSupply == 0) {
            liquidity = Math.sqrt(amount0 * amount1) - MINIMUM_LIQUIDITY;
           _mint(address(0), MINIMUM_LIQUIDITY);
        } 
        
        else liquidity = Math.min((amount0 * _totalSupply) / uint(_reserve0), (amount1 * _totalSupply) / uint(_reserve1));

        require(liquidity > 0, "FilterPair: INSUFFICIENT_LIQUIDITY_MINTED");
        _mint(to, liquidity);
        _update(balance0, balance1, _reserve0, _reserve1);

        if (feeOn) kLast = uint(reserve0) * uint(reserve1);

        emit Mint(msg.sender, amount0, amount1);
    }

    function burn(address to) external reentrancyLock returns (uint amount0, uint amount1) {
        (uint112 _reserve0, uint112 _reserve1, ) = getReserves();
        address _token0 = token0;
        address _token1 = token1;
        uint balance0 = IERC20(_token0).balanceOf(address(this));
        uint balance1 = IERC20(_token1).balanceOf(address(this));
        uint liquidity = balanceOf[address(this)];

        bool feeOn = _mintFee(_reserve0, _reserve1);
        uint _totalSupply = totalSupply;
        amount0 = (liquidity * balance0) / _totalSupply;
        amount1 = (liquidity * balance1) / _totalSupply;

        require(amount0 > 0 && amount1 > 0, "FilterPair: INSUFFICIENT_LIQUIDITY_BURNED");

        _burn(address(this), liquidity);
        _safeTransfer(_token0, to, amount0);
        _safeTransfer(_token1, to, amount1);

        balance0 = IERC20(_token0).balanceOf(address(this));
        balance1 = IERC20(_token1).balanceOf(address(this));

        _update(balance0, balance1, _reserve0, _reserve1);

        if (feeOn) kLast = reserve0 * reserve1;

        emit Burn(msg.sender, amount0, amount1, to);
    }

    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external reentrancyLock {
        require(amount0Out > 0 || amount1Out > 0, "FilterPair: INSUFFICIENT_OUTPUT_AMOUNT");
        (uint112 _reserve0, uint112 _reserve1, ) = getReserves();
        require(amount0Out < uint(_reserve0) && amount1Out < uint(_reserve1), "FilterPair: INSUFFICIENT_LIQUIDITY");

        uint balance0;
        uint balance1;

        {
            address _token0 = token0;
            address _token1 = token1;
            require(to != _token0 && to != _token1, "FilterPair: INVALID_TO");

            if (amount0Out > 0) _safeTransfer(_token0, to, amount0Out);
            if (amount1Out > 0) _safeTransfer(_token1, to, amount1Out);

            if (data.length > 0) IFilterCallee(to).filterCall(msg.sender, amount0Out, amount1Out, data);

            balance0 = IERC20(_token0).balanceOf(address(this));
            balance1 = IERC20(_token1).balanceOf(address(this));
        }

        uint amount0In = balance0 > uint(_reserve0) - amount0Out ? balance0 - (uint(_reserve0) - amount0Out) : 0;
        uint amount1In = balance1 > uint(_reserve1) - amount1Out ? balance1 - (uint(_reserve1) - amount1Out) : 0;
        require(amount0In > 0 || amount1In > 0, "FilterPair: INSUFFICIENT_INPUT_AMOUNT");

        {
            uint balance0Adjusted = (balance0 * 1000) - (amount0In * 2);
            uint balance1Adjusted = (balance1 * 1000) - (amount1In * 2);
            require((balance0Adjusted * balance1Adjusted) >= (uint(_reserve0) * uint(_reserve1)) * (1000**2), "FilterPair: K");
        }

        _update(balance0, balance1, _reserve0, _reserve1);
        emit Swap(msg.sender, amount0In, amount1In, amount0Out, amount1Out, to);
    }

    function skim(address to) external reentrancyLock {
        address _token0 = token0;
        address _token1 = token1;
        _safeTransfer(_token0, to, IERC20(_token0).balanceOf(address(this)) - reserve0);
        _safeTransfer(_token1, to, IERC20(_token1).balanceOf(address(this)) - reserve1);
    }

    function sync() external reentrancyLock {
        _update(IERC20(token0).balanceOf(address(this)), IERC20(token1).balanceOf(address(this)), reserve0, reserve1);
    }
}

contract FilterFactory is IFilterFactory {
    address public managerAddress;
    IFilterManager filterManager;
    
    bytes32 public constant INIT_CODE_PAIR_HASH = keccak256(abi.encodePacked(type(FilterPair).creationCode));

    mapping(address => mapping(address => address)) public getPair;
    address[] public allPairs;

    constructor(address _managerAddress) {
        managerAddress = _managerAddress;
        filterManager = IFilterManager(managerAddress);
    }

    function allPairsLength() external view returns (uint) {
        return allPairs.length;
    }

    function createPair(address tokenA, address tokenB) external returns (address pair) {
        require(filterManager.isTokenVerified(tokenA) && filterManager.isTokenVerified(tokenB), "FilterPair: UNVERIFIED_TOKEN_PAIR");
        require(tokenA != tokenB, "FilterPair: IDENTICAL_ADDRESSES");
        (address token0, address token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        require(token0 != address(0), "FilterPair: ZERO_ADDRESS");
        require(token1 != address(0), "FilterPair: ZERO_ADDRESS");
        require(getPair[token0][token1] == address(0), "FilterPair: PAIR_EXISTS");
        
        bytes memory bytecode = type(FilterPair).creationCode;
        bytes32 salt = keccak256(abi.encodePacked(token0, token1));
        
        assembly {
            pair := create2(0, add(bytecode, 32), mload(bytecode), salt)
        }

        IFilterPair(pair).initialize(token0, token1, managerAddress);
        getPair[token0][token1] = pair;
        getPair[token1][token0] = pair;
        allPairs.push(pair);

        emit PairCreated(token0, token1, pair, allPairs.length);
    }
}