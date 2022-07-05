//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import "./interfaces/IERC20.sol";
import "./interfaces/IOrbPool.sol";
import "./interfaces/IOrbFlexiblePool.sol";
import "./interfaces/IIFOPool.sol";
import "./interfaces/IMasterChef.sol";
import "./interfaces/IOrbitalPair.sol";
import "./interfaces/ICosmosInitializable.sol";

contract VotePower is Ownable {
    constructor() {}

    address public constant ORB_TOKEN = 0x42b98A2f73a282D731b0B8F4ACfB6cAF3565496B; // orb token.
    address public constant ORB_POOL = 0xd67a0CE4B1484DBa8dB53349F9b26a3272dB04F5; // orb pool.
    address public IFO_POOL = 0x1B2A2f6ed4A1401E8C73B4c2B6172455ce2f78E8; // ifo pool.
    address public constant MASTERCHEF = 0xd67a0CE4B1484DBa8dB53349F9b26a3272dB04F5; // masterchef.
    address public constant ORB_LP = 0x451a503b59A4DEA428b8eb88D6df27DE8A7fcfe1; // orb lp.
    address public constant ORB_FLEXIBLE_POOL = 0xEF1deb94DB6298a893b294FDfFe505C256E2B6b7; // orb flexible pool.

    event NewIFOPool(address IFO_POOL);

    /**
     * @notice Set Voting Power Contract address
     * @dev Only callable by the contract owner.
     */
    function setIFOPool(address _IFO_POOL) external onlyOwner {
        require(_IFO_POOL != address(0), "Cannot be zero address");
        IFO_POOL = _IFO_POOL;
        emit NewIFOPool(IFO_POOL);
    }
    function getOrbBalance(address _user) public view returns (uint256) {
        return IERC20(ORB_TOKEN).balanceOf(_user);
    }
    function getOrbVaultBalance(address _user) public pure returns (uint256) {
        return 0;
    }
    function getIFOPoolBalancee(address _user) public view returns (uint256) {
        return 0;
    }
    function getOrbPoolBalance(address _user) public view returns (uint256) {
        (uint256 share, , , , , , uint256 userBoostedShare, , ) = IOrbPool(ORB_POOL).userInfo(_user);
        uint256 orbPoolPricePerFullShare = IOrbPool(ORB_POOL).getPricePerFullShare();

        (uint256 shareForFlexiblePool, , , ) = IOrbFlexiblePool(ORB_FLEXIBLE_POOL).userInfo(_user);
        uint256 orbFlexiblePoolPricePerFullShare = IOrbFlexiblePool(ORB_FLEXIBLE_POOL).getPricePerFullShare();

        return
            ((share * orbPoolPricePerFullShare) / 1e18 - userBoostedShare) +
            (shareForFlexiblePool * orbFlexiblePoolPricePerFullShare) /
            1e18;
    }

    function getOrbBnbLpBalance(address _user) public view returns (uint256) {
        uint256 totalSupplyLP = IOrbitalPair(ORB_LP).totalSupply();
        (uint256 reserve0, , ) = IOrbitalPair(ORB_LP).getReserves();
        (uint256 amount, ) = IMasterChef(MASTERCHEF).userInfo(2, _user);
        return (amount * reserve0) / totalSupplyLP;
    }

    function getPoolsBalance(address _user, address[] memory _pools) public view returns (uint256) {
        uint256 total;
        for (uint256 i = 0; i < _pools.length; i++) {
            (uint256 amount, ) = ICosmosInitializable(_pools[i]).userInfo(_user);
            total += amount;
        }
        return total;
    }

    function getVotingPower(address _user, address[] memory _pools) public view returns (uint256) {
        return
            getOrbBalance(_user) +
            getOrbPoolBalance(_user) +
            getOrbBnbLpBalance(_user) +
            getPoolsBalance(_user, _pools);
    }

    function getVotingPowerWithoutPool(address _user) public view returns (uint256) {
        return
            getOrbBalance(_user) +
            getOrbPoolBalance(_user) +
            getOrbBnbLpBalance(_user);
    }
}

// SPDX-License-Identifier: MIT

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
        _setOwner(_msgSender());
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
        _setOwner(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
  /**
   * @dev Returns the amount of tokens owned by `account`.
   */
  function balanceOf(address account) external view returns (uint256);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IOrbPool {
    struct UserInfo {
        uint256 shares; // number of shares for a user.
        uint256 lastDepositedTime; // keep track of deposited time for potential penalty.
        uint256 orbAtLastUserAction; // keep track of orb deposited at the last user action.
        uint256 lastUserActionTime; // keep track of the last user action time.
        uint256 lockStartTime; // lock start time.
        uint256 lockEndTime; // lock end time.
        uint256 userBoostedShare; // boost share, in order to give the user higher reward. The user only enjoys the reward, so the principal needs to be recorded as a debt.
        bool locked; //lock status.
        uint256 lockedAmount; // amount deposited during lock period.
    }

    function userInfo(address user)
        external
        view
        returns (
            uint256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256,
            bool,
            uint256
        );

    function getPricePerFullShare() external view returns (uint256);

    function deposit(uint256 _amount, uint256 _lockDuration) external;

    function withdrawByAmount(uint256 _amount) external;

    function withdraw(uint256 _shares) external;

    function withdrawAll() external;
}

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IOrbFlexiblePool {
  function userInfo(address _user) external view returns (uint256, uint256, uint256, uint256);
  function getPricePerFullShare() external view returns (uint256);
}

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IIFOPool {
  function userInfo(address _user) external view returns (uint256, uint256, uint256, uint256);
  function getPricePerFullShare() external view returns (uint256);
}

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IMasterChef {
  function userInfo(uint256 _pid, address _user) external view returns (uint256, uint256);
}

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IOrbitalPair {
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
    
    function feeAmount() external view returns (uint256);
    
    function controllerFeeShare() external view returns (uint256);

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

    function initialize(address, address) external;
}

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ICosmosInitializable {
  function userInfo(address _user) external view returns (uint256, uint256);
}

// SPDX-License-Identifier: MIT

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