// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/interfaces/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

// DYNAMIC DECENTRALIZED SUPPLY CONTROL ALGORITHM
contract DDSCA is Ownable {

    IERC20 public immutable token;

    uint256 public tokenPerBlock;
    uint256 public maxEmissionRate;
    uint256 public emissionStartBlock;
    uint256 public emissionEndBlock = type(uint256).max;
    address public masterchef;

    // Dynamic emissions
    uint256 public topPriceInCents    = 800;  // 8$
    uint256 public bottomPriceInCents = 100;  // 1$

    enum EmissionRate {SLOW, MEDIUM, FAST, FASTEST}
    EmissionRate public ActiveEmissionIndex = EmissionRate.MEDIUM;

    event UpdateDDSCAPriceRange(uint256 topPrice, uint256 bottomPrice);
    event updatedDDSCAMaxEmissionRate(uint256 maxEmissionRate);
    event SetFarmStartBlock(uint256 startBlock);
    event SetFarmEndBlock(uint256 endBlock);

    constructor(IERC20 _tokenAddress, uint256 _tokenPerBlock, uint256 _maxTokenPerBlock, uint256 _startBlock) {
        token = _tokenAddress;
        tokenPerBlock = _tokenPerBlock;
        maxEmissionRate = _maxTokenPerBlock;
        emissionStartBlock = _startBlock;
    }

    // Called externally by bot
    function checkIfUpdateIsNeeded(uint256 priceInCents) public view returns(bool, EmissionRate) {

        EmissionRate _emissionRate;

        bool isOverATH = priceInCents > topPriceInCents;
        // if price is over ATH, set to fastest
        if (isOverATH){
            _emissionRate = EmissionRate.FASTEST;
        } else {
            _emissionRate = getEmissionStage(priceInCents);
        }

        // No changes, no need to update
        if (_emissionRate == ActiveEmissionIndex){
            return(false, _emissionRate);
        }

        // Means its a downward movement, and it changed a stage
        if (_emissionRate < ActiveEmissionIndex){
            return(true, _emissionRate);
        }

        // Check if its a upward movement
        if (_emissionRate > ActiveEmissionIndex){

            uint256 athExtra = 0;
            if (isOverATH){
                athExtra = 1;
            }

            // Check if it moved up by two stages
            if ((uint256(_emissionRate) + athExtra) - uint256(ActiveEmissionIndex) >= 2){
                // price has moved 2 ranges from current, so update
                _emissionRate = EmissionRate(uint256(_emissionRate) + athExtra - 1 );
                return(true, _emissionRate);
            }
        }
        return(false, _emissionRate);

    }

    function updateEmissions(EmissionRate _newEmission) public {
        require(msg.sender ==  masterchef); 
        ActiveEmissionIndex = _newEmission;
        tokenPerBlock = (maxEmissionRate / 4) * (uint256(_newEmission) + 1);
    }

    function getEmissionStage(uint256 currentPriceCents) public view returns (EmissionRate){

        if (currentPriceCents > topPriceInCents){
            return EmissionRate.FASTEST;
        }

        // Prevent function from underflowing when subtracting currentPriceCents - bottomPriceInCents
        if (currentPriceCents < bottomPriceInCents){
            currentPriceCents = bottomPriceInCents;
        }
        uint256 percentageChange = ((currentPriceCents - bottomPriceInCents ) * 1000) / (topPriceInCents - bottomPriceInCents);
        percentageChange = 1000 - percentageChange;

        if (percentageChange <= 250){
            return EmissionRate.FASTEST;
        }
        if (percentageChange <= 500 && percentageChange > 250){
            return EmissionRate.FAST;
        }
        if (percentageChange <= 750 && percentageChange > 500){
            return EmissionRate.MEDIUM;
        }

        return EmissionRate.SLOW;
    }

    function updateDDSCAPriceRange(uint256 _topPrice, uint256 _bottomPrice) external onlyOwner {
        require(_topPrice > _bottomPrice, "top < bottom price");
        topPriceInCents = _topPrice;
        bottomPriceInCents = _bottomPrice;
        emit UpdateDDSCAPriceRange(topPriceInCents, bottomPriceInCents);
    }

    function updateDDSCAMaxEmissionRate(uint256 _maxEmissionRate) external onlyOwner {
        require(_maxEmissionRate > 0, "_maxEmissionRate !> 0");
        require(_maxEmissionRate <= 10 ether, "_maxEmissionRate !");
        maxEmissionRate = _maxEmissionRate;
        emit updatedDDSCAMaxEmissionRate(_maxEmissionRate);
    }

    function _setFarmStartBlock(uint256 _newStartBlock) external {
        require(msg.sender ==  masterchef); 
        require(_newStartBlock > block.number, "must be in the future");
        require(block.number < emissionStartBlock, "farm has already started");
        emissionStartBlock = _newStartBlock;
        emit SetFarmStartBlock(_newStartBlock);
    }

    function setFarmEndBlock(uint256 _newEndBlock) external onlyOwner {
        require(_newEndBlock > block.number, "must be in the future");
        emissionEndBlock = _newEndBlock;
        emit SetFarmEndBlock(_newEndBlock);
    }
    
    function updateMcAddress(address _mcAddress) external onlyOwner {
        masterchef = _mcAddress;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (interfaces/IERC20.sol)

pragma solidity ^0.8.0;

import "../token/ERC20/IERC20.sol";

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

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
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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