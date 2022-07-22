/**
 *Submitted for verification at BscScan.com on 2022-07-22
*/

//SPDX-License-Identifier: MIT
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


interface ISmartChefInitializable {
  function userInfo(address _user) external view returns (uint256, uint256);
  function stakedToken() external view returns (address);
}

interface ISMBPair {
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

interface IMasterChef {
  function userInfo(uint256 _pid, address _user) external view returns (uint256, uint256);
}

interface ISELFVault {
  function userInfo(address _user) external view returns (uint256, uint256, uint256, uint256);
  function getPricePerFullShare() external view returns (uint256);
}

interface IERC20 {
  /**
   * @dev Returns the amount of tokens owned by `account`.
   */
  function balanceOf(address account) external view returns (uint256);
}

contract VotePower is Ownable {
    constructor() {}

    address public constant SELF_TOKEN = 0x7a364484303B38Bce7B0ab60a20DA8F2F4370129; // SELF token.
    address public constant SELF_VAULT = 0xeb4f1307DE7DF263E8e54d083fE7db1e281e710D; // SELF vault.
    address public constant MASTERCHEF = 0x3d03d12F95Bdc4509804f9Bcee4139b7789DC516; // masterchef.
    address public constant SELF_LP = 0x9C6FF656A563Ec9057460D8a400E2AC7c2AE0a1C; // SELF lp.

    function getSELFBalance(address _user) public view returns (uint256) {
        return IERC20(SELF_TOKEN).balanceOf(_user);
    }

    function getSELFVaultBalance(address _user) public view returns (uint256) {
        (uint256 share, , , ) = ISELFVault(SELF_VAULT).userInfo(_user);
        uint256 SELFVaultPricePerFullShare = ISELFVault(SELF_VAULT).getPricePerFullShare();
        return (share * SELFVaultPricePerFullShare) / 1e18;
    }

    function getSELFPoolBalance(address _user) public view returns (uint256) {
        (uint256 amount, ) = IMasterChef(MASTERCHEF).userInfo(0, _user);
        return amount;
    }

    function getSELFBnbLpBalance(address _user) public view returns (uint256) {
        uint256 totalSupplyLP = ISMBPair(SELF_LP).totalSupply();
        (uint256 reserve0, , ) = ISMBPair(SELF_LP).getReserves();
        (uint256 amount, ) = IMasterChef(MASTERCHEF).userInfo(251, _user);
        return (amount * reserve0) / totalSupplyLP;
    }

    function getPoolsBalance(address _user, address[] memory _pools) public view returns (uint256) {
        uint256 total;
        for (uint256 i = 0; i < _pools.length; i++) 
        {
            if(ISmartChefInitializable(_pools[i]).stakedToken() == SELF_TOKEN)
            {
                (uint256 amount, ) = ISmartChefInitializable(_pools[i]).userInfo(_user);
                total += amount;
            }
        }
        return total;
    }

    function getVotingPower(address _user, address[] memory _pools) public view returns (uint256) {
        return
            getSELFBalance(_user) +
            getSELFVaultBalance(_user) +
            getSELFPoolBalance(_user) +
            getSELFBnbLpBalance(_user) +
            getPoolsBalance(_user, _pools);
    }

    function getVotingPowerWithoutPool(address _user) public view returns (uint256) {
        return
            getSELFBalance(_user) +
            getSELFVaultBalance(_user) +
            getSELFPoolBalance(_user) +
            getSELFBnbLpBalance(_user);
    }
}