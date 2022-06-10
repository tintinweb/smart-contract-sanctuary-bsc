// SPDX-License-Identifier: MIT
pragma solidity ~0.8.0;
import "@openzeppelin/contracts/access/Ownable.sol";
interface IBEP20 {
    function totalSupply() external view returns (uint256);

    function decimals() external view returns (uint8);

    function symbol() external view returns (string memory);

    function name() external view returns (string memory);

    function getOwner() external view returns (address);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function allowance(address _owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

contract NDBVesting is Ownable {

    /// Vested tokens originate from this BEP20 token contract 
    IBEP20 public token;

    /// @notice Emitted when tokens are released to the beneficiary
    /// @param amount The number of tokens released
    event Released(uint256 amount);

    /// The beneficiary of the vesting schedule
    address public beneficiary;

    /// Number of tokens vested to `beneficiary`
    uint256 public released;

    /// Period between vesting releases in seconds
    uint256 public period;

    /// Number of payments to be made
    uint256 public installments;

    /// Timestamp of vesting start
    uint256 public startTime;

    /// @param _beneficiary The account that receives vested tokens
    /// @param _token The address of the ERC20 token contract
    /// @param _beneficiary The address that receives vested tokens
    /// @param _period The period in seconds between installments
    /// @param _installments The number of vesting installments
    constructor(address _token, address _beneficiary, uint256 _period, uint256 _installments) {
        beneficiary = _beneficiary;
        token = IBEP20(_token);
        period = _period;
        installments = _installments;
    }

    /// @notice Initialize the vesting contract using tokens approved by `provider`
    /// @param provider Address that provides tokens for vesting
    function initializeFrom(address provider) public onlyOwner {
        uint256 approval = token.allowance(provider, address(this));
        require(approval > 0, "Must initialize with tokens");
        startTime = block.timestamp;
        token.transferFrom(provider, address(this), approval);
    }

    /// @notice Transfer vested tokens to beneficiary.
    function release() external {
        require((msg.sender == owner()) || (msg.sender == beneficiary));
        
        uint256 unreleased = tokensAvailable();
        require(unreleased > 0);

        released = released + unreleased;

        token.transfer(beneficiary, unreleased);

        emit Released(unreleased);
    }

    function balance() public view returns (uint256) {
        return token.balanceOf(address(this));
    }

    function currentInstallment() public view returns (uint256) {
        return (block.timestamp - startTime) / period;
    }

    /// @notice Calculates the amount that has already vested but hasn't been released yet.
    /// @return Number of releasable tokens
    function tokensAvailable() public view returns (uint256) {
        uint256 tokens = balance();

        uint256 curInstallment = currentInstallment();
        if(curInstallment >= installments) {
            return tokens;
        }
        uint256 releasePerInstallment = (tokens + released) / installments;
        uint256 releasable = curInstallment * releasePerInstallment;
        return releasable - released;
    }
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