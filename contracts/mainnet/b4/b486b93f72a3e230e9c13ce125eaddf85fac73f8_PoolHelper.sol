pragma solidity 0.8.9;

import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./interfaces/IAutoBSW.sol";


interface ISmartChef{

    struct UserInfo {
        uint256 amount;
        uint256 rewardDebt;
    }

    struct PoolInfo {
        IERC20 lpToken;           // Address of LP token contract.
        uint256 allocPoint;       // How many allocation points assigned to this pool. BSWs to distribute per block.
        uint256 lastRewardBlock;  // Last block number that BSWs distribution occurs.
        uint256 accBSWPerShare;   // Accumulated BSWs per share, times 1e12. See below.
    }

    function biswap() external view returns(IERC20);
    function rewardToken() external view returns(IERC20);
    function rewardPerBlock() external view returns(uint);
    function userInfo(address) external view returns(UserInfo memory);
    function startBlock() external view returns(uint);
    function bonusEndBlock() external view returns(uint);
    function limitAmount() external view returns(uint);
    function minStakeHolderPool() external view returns(uint);
}

contract PoolHelper is Ownable {
    struct Pool{
        IERC20Metadata stakeToken;
        IERC20 rewardToken;
        uint rewardPerBlock;
        uint userBalance;
        string stakeTokenName;
        bool ended;
    }

    struct PoolsList{
        address addressPool;
        bool prod;
    }

    struct UserInfo{
        uint bswBalance;
        uint holderPoolBalance;
    }

    PoolsList[] public poolsList;
    IAutoBSW public autoBSW;

    function setAutoBSW(address _autoBSW) external onlyOwner {
        require(_autoBSW != address(0), "text");
        autoBSW = IAutoBSW(_autoBSW);
    }

    function setPool(PoolsList calldata newPool) external onlyOwner {
        poolsList.push(newPool);
    }

    //@dev Take holderPool balance
    function _getHolderPoolAmount(address _user) internal view returns(uint holderPoolAmount){
        holderPoolAmount = autoBSW.balanceOf() * autoBSW.userInfo(_user).shares / autoBSW.totalShares();
    }

    function changePool(uint index, PoolsList calldata newPool) external onlyOwner {
        require(index < poolsList.length, "index out of bound");
        poolsList[index] = newPool;
    }

    function goProd(uint index, bool inProd) external onlyOwner {
        require(index < poolsList.length, "index out of bound");
        poolsList[index].prod = inProd;
    }

    function getPools(address user) external view returns(PoolsList[] memory _poolsList, Pool[] memory pools, UserInfo memory userInfo){
        _poolsList = poolsList;
        pools = new Pool[](_poolsList.length);
        for(uint i = 0; i < _poolsList.length; i++){
            ISmartChef currentContract = ISmartChef(_poolsList[i].addressPool);
            pools[i].stakeToken = IERC20Metadata(address(currentContract.biswap()));
            pools[i].stakeTokenName = IERC20Metadata(address(currentContract.biswap())).name();
            pools[i].ended = currentContract.bonusEndBlock() < block.number;
            pools[i].rewardToken = currentContract.rewardToken();
            pools[i].rewardPerBlock = currentContract.rewardPerBlock();
            pools[i].userBalance = currentContract.userInfo(user).amount;
        }
        return(_poolsList, pools, userInfo);
    }

    function renounceOwnership() public override onlyOwner {
        revert("FUCKOFF: function not available");
    }


}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
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

// SPDX-License-Identifier: Unlicensed
pragma solidity >= 0.6.12;
pragma experimental ABIEncoderV2;

interface IAutoBSW {
    function balanceOf() external view returns(uint);
    function totalShares() external view returns(uint);

    struct UserInfo {
        uint shares; // number of shares for a user
        uint lastDepositedTime; // keeps track of deposited time for potential penalty
        uint BswAtLastUserAction; // keeps track of Bsw deposited at the last user action
        uint lastUserActionTime; // keeps track of the last user action time
    }

    function userInfo(address user) external view returns (UserInfo memory);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
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

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

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
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
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