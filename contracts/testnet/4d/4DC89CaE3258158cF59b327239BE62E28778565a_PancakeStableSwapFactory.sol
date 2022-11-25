// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "@openzeppelin-4.5.0/contracts/access/Ownable.sol";
import "./interfaces/IPancakeStableSwap.sol";
import "./interfaces/IPancakeStableSwapLP.sol";
import "./interfaces/IPancakeStableSwapDeployer.sol";
import "./interfaces/IPancakeStableSwapLPFactory.sol";

contract PancakeStableSwapFactory is Ownable {
    struct StableSwapPairInfo {
        address swapContract;
        address token0;
        address token1;
        address token2;
        address LPContract;
    }

    mapping(address => mapping(address => mapping(address => StableSwapPairInfo))) public stableSwapPairInfo;
    mapping(uint256 => address) public swapPairContract;

    IPancakeStableSwapLPFactory public immutable LPFactory;
    IPancakeStableSwapDeployer public immutable SwapDeployer;
    IPancakeStableSwapDeployer public immutable SwapTriplePoolDeployer;

    address constant ZEROADDRESS = address(0);

    uint256 public constant N_COINS = 2;
    uint256 public pairLength;

    event NewStableSwapPair(address indexed swapContract, address tokenA, address tokenB, address tokenC);

    /**
     * @notice constructor
     * _LPFactory: LP factory
     * _SwapDeployer: Swap deployer
     * _SwapTriplePoolDeployer: Swap deployer
     */
    constructor(
        IPancakeStableSwapLPFactory _LPFactory,
        IPancakeStableSwapDeployer _SwapDeployer,
        IPancakeStableSwapDeployer _SwapTriplePoolDeployer
    ) {
        LPFactory = _LPFactory;
        SwapDeployer = _SwapDeployer;
        SwapTriplePoolDeployer = _SwapTriplePoolDeployer;
    }

    // returns sorted token addresses, used to handle return values from pairs sorted in this order
    function sortTokens(address tokenA, address tokenB) internal pure returns (address token0, address token1) {
        require(tokenA != tokenB, "IDENTICAL_ADDRESSES");
        (token0, token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
    }

    function sortTokens(
        address tokenA,
        address tokenB,
        address tokenC
    )
        internal
        pure
        returns (
            address,
            address,
            address
        )
    {
        require(tokenA != tokenB && tokenA != tokenC && tokenB != tokenC, "IDENTICAL_ADDRESSES");
        address tmp;
        if (tokenA > tokenB) {
            tmp = tokenA;
            tokenA = tokenB;
            tokenB = tmp;
        }
        if (tokenB > tokenC) {
            tmp = tokenB;
            tokenB = tokenC;
            tokenC = tmp;
        }
        if (tokenA > tokenB) {
            tmp = tokenA;
            tokenA = tokenB;
            tokenB = tmp;
        }
        return (tokenA, tokenB, tokenC);
    }

    /**
     * @notice createSwapPair
     * @param _tokenA: Addresses of ERC20 conracts .
     * @param _tokenB: Addresses of ERC20 conracts .
     * @param _A: Amplification coefficient multiplied by n * (n - 1)
     * @param _fee: Fee to charge for exchanges
     * @param _admin_fee: Admin fee
     */
    function createSwapPair(
        address _tokenA,
        address _tokenB,
        uint256 _A,
        uint256 _fee,
        uint256 _admin_fee
    ) external onlyOwner {
        require(_tokenA != ZEROADDRESS && _tokenB != ZEROADDRESS && _tokenA != _tokenB, "Illegal token");
        (address t0, address t1) = sortTokens(_tokenA, _tokenB);
        StableSwapPairInfo storage info = stableSwapPairInfo[t0][t1][ZEROADDRESS];
        require(info.swapContract == ZEROADDRESS, "Pair already exists");
        address LP = LPFactory.createSwapLP(t0, t1, ZEROADDRESS, address(this));
        address swapContract = SwapDeployer.createSwapPair(t0, t1, _A, _fee, _admin_fee, msg.sender, LP);
        IPancakeStableSwapLP(LP).setMinter(swapContract);
        addPairInfoInternal(swapContract, t0, t1, ZEROADDRESS, LP);
    }

    /**
     * @notice createTriplePoolPair
     * @param _tokenA: Addresses of ERC20 conracts .
     * @param _tokenB: Addresses of ERC20 conracts .
     * @param _tokenC: Addresses of ERC20 conracts .
     * @param _A: Amplification coefficient multiplied by n * (n - 1)
     * @param _fee: Fee to charge for exchanges
     * @param _admin_fee: Admin fee
     */
    function createTriplePoolPair(
        address _tokenA,
        address _tokenB,
        address _tokenC,
        uint256 _A,
        uint256 _fee,
        uint256 _admin_fee
    ) external onlyOwner {
        require(
            _tokenA != ZEROADDRESS &&
                _tokenB != ZEROADDRESS &&
                _tokenC != ZEROADDRESS &&
                _tokenA != _tokenB &&
                _tokenA != _tokenC &&
                _tokenB != _tokenC,
            "Illegal token"
        );
        (address t0, address t1, address t2) = sortTokens(_tokenA, _tokenB, _tokenC);
        StableSwapPairInfo storage info = stableSwapPairInfo[t0][t1][t2];
        require(info.swapContract == ZEROADDRESS, "Pair already exists");
        address LP = LPFactory.createSwapLP(t0, t1, t2, address(this));
        address swapContract = SwapTriplePoolDeployer.createSwapPair(t0, t1, t2, _A, _fee, _admin_fee, msg.sender, LP);
        IPancakeStableSwapLP(LP).setMinter(swapContract);
        addPairInfoInternal(swapContract, t0, t1, t2, LP);
    }

    function addPairInfoInternal(
        address _swapContract,
        address _t0,
        address _t1,
        address _t2,
        address _LP
    ) internal {
        StableSwapPairInfo storage info = stableSwapPairInfo[_t0][_t1][_t2];
        require(info.swapContract == ZEROADDRESS, "Pair already exists");
        info.swapContract = _swapContract;
        info.token0 = _t0;
        info.token1 = _t1;
        info.token2 = _t2;
        info.LPContract = _LP;
        swapPairContract[pairLength] = _swapContract;
        pairLength += 1;

        emit NewStableSwapPair(_swapContract, _t0, _t1, _t2);
    }

    // Save pair data manually.
    function addPairInfo(
        address _swapContract,
        address _token0,
        address _token1,
        address _LP
    ) external onlyOwner {
        require(_token0 != ZEROADDRESS && _token1 != ZEROADDRESS && _token0 != _token1, "Illegal token");
        (address t0, address t1) = sortTokens(_token0, _token1);
        IPancakeStableSwap swap = IPancakeStableSwap(_swapContract);
        require(swap.coins(0) == t0 && swap.coins(1) == t1, "Wrong token address");
        require(swap.token() == _LP, "Wrong LP address");
        addPairInfoInternal(_swapContract, t0, t1, ZEROADDRESS, _LP);
    }

    // Save pair data manually.
    function addTriplePoolPairInfo(
        address _swapContract,
        address _token0,
        address _token1,
        address _token2,
        address _LP
    ) external onlyOwner {
        require(
            _token0 != ZEROADDRESS &&
                _token1 != ZEROADDRESS &&
                _token2 != ZEROADDRESS &&
                _token0 != _token1 &&
                _token0 != _token2 &&
                _token1 != _token2,
            "Illegal token"
        );
        (address t0, address t1, address t2) = sortTokens(_token0, _token1, _token2);
        IPancakeStableSwap swap = IPancakeStableSwap(_swapContract);
        require(swap.coins(0) == t0 && swap.coins(1) == t1 && swap.coins(2) == t2, "Wrong token address");
        require(swap.token() == _LP, "Wrong LP address");
        addPairInfoInternal(_swapContract, t0, t1, t2, _LP);
    }

    function getPairInfo(address _tokenA, address _tokenB) external view returns (StableSwapPairInfo memory info) {
        (address t0, address t1) = sortTokens(_tokenA, _tokenB);
        info = stableSwapPairInfo[t0][t1][ZEROADDRESS];
    }

    function getTriplePoolPairInfo(
        address _tokenA,
        address _tokenB,
        address _tokenC
    ) external view returns (StableSwapPairInfo memory info) {
        (address t0, address t1, address t2) = sortTokens(_tokenA, _tokenB, _tokenC);
        info = stableSwapPairInfo[t0][t1][t2];
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

interface IPancakeStableSwap {
    function token() external view returns (address);

    function balances(uint256 i) external view returns (uint256);

    function RATES(uint256 i) external view returns (uint256);

    function coins(uint256 i) external view returns (address);

    function PRECISION_MUL(uint256 i) external view returns (uint256);

    function fee() external view returns (uint256);

    function admin_fee() external view returns (uint256);

    function A() external view returns (uint256);

    function get_D_mem(uint256[2] memory _balances, uint256 amp) external view returns (uint256);

    function get_y(
        uint256 i,
        uint256 j,
        uint256 x,
        uint256[2] memory xp_
    ) external view returns (uint256);

    function calc_withdraw_one_coin(uint256 _token_amount, uint256 i) external view returns (uint256);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

interface IPancakeStableSwapLP {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    function mint(address _to, uint256 _amount) external;

    function burnFrom(address _to, uint256 _amount) external;

    function setMinter(address _newMinter) external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

interface IPancakeStableSwapDeployer {
    function createSwapPair(
        address _tokenA,
        address _tokenB,
        uint256 _A,
        uint256 _fee,
        uint256 _admin_fee,
        address _admin,
        address _LP
    ) external returns (address);

    function createSwapPair(
        address _tokenA,
        address _tokenB,
        address _tokenC,
        uint256 _A,
        uint256 _fee,
        uint256 _admin_fee,
        address _admin,
        address _LP
    ) external returns (address);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

interface IPancakeStableSwapLPFactory {
    function createSwapLP(
        address _tokenA,
        address _tokenB,
        address _tokenC,
        address _minter
    ) external returns (address);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}