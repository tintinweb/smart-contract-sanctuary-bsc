//SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "../node_modules/@openzeppelin/contracts/access/Ownable.sol";
import "../node_modules/@openzeppelin/contracts/token/ERC20/IERC20.sol";

error Unauthorized();
error ZeroAddressError();
error TransferFailed();
error IllegalArguments();
error InsufficientBalance();

contract BulkSender is Ownable {
    /**
     * @dev Allows this contrat to recieve Ether/BNB (used for testing purposes)
     */
    receive() external payable {}

    mapping(address => bool) contractOperator;

    /**
     * @dev Modifier which allows only certain addresses to perform contract
     * operations. Add allowed addresses using setContractOperator function.
     */

    modifier onlyOperator() {
        if (contractOperator[msg.sender] != true) revert Unauthorized();
        _;
    }

    /**
     * @dev Sets a target address `operatorAccount`'s operator access.
     * Only available to contract owner
     */

    function setOperator(address operatorAccount, bool value)
        external
        onlyOwner
    {
        if (operatorAccount == address(0)) revert ZeroAddressError();
        contractOperator[operatorAccount] = value;
    }

    /**
     * @dev Transfers a certain `amountInWei` of ETH
     * (BNB if deployed on BSC / AVAX if deployed on Avalanche)
     * to a certain `destinationAddress`
     */

    function sendEtherRewardsSingleDestination(
        address destinationAddress,
        uint256 amountInWei
    ) external payable onlyOperator {
        if (destinationAddress == address(0)) revert ZeroAddressError();
        if (address(this).balance < amountInWei) revert InsufficientBalance();

        (bool sent, bytes memory data) = destinationAddress.call{
            value: amountInWei
        }("");
        if (!sent) revert TransferFailed();
    }

    /**
     * @dev Transfers ETH from this contract's balance
     * (BNB if deployed on BSC / ETH if deployed on Ethereum)
     * to an array of addressses `destinationAddressArray` which takes
     * at maximum 190 addresses to stay below the base-gas fee.
     */

    function sendEtherRewardsMultiDestination(
        address[] calldata destinationAddressArray,
        uint256[] calldata amountsInWei
    ) external payable onlyOperator {
        if (
            destinationAddressArray.length > 100 ||
            destinationAddressArray.length != amountsInWei.length
        ) revert IllegalArguments();

        for (uint256 i = 0; i < destinationAddressArray.length; i++) {
            if (destinationAddressArray[i] == address(0))
                revert ZeroAddressError();
            (bool sent, bytes memory data) = destinationAddressArray[i].call{
                value: amountsInWei[1]
            }("");
            if (!sent) revert TransferFailed();
        }
    }

    /**
     * @dev Transfers a certain `amount` (WEI) of non-native asset
     * this can be any ERC20 compliant token this contract currently owns.
     * The contract address of token  to be transferred is to be supplied
     * through `tokenContractAddress` and the destination address
     * is passed to `destinationAddress`
     */

    function sendErcRewardsSingleDestination(
        address tokenContractAddress,
        address destinationAddress,
        uint256 amountInWei
    ) external payable onlyOperator {
        if (destinationAddress == address(0)) revert ZeroAddressError();
        if (IERC20(tokenContractAddress).balanceOf(address(this)) < amountInWei)
            revert InsufficientBalance();

        bool sent = IERC20(tokenContractAddress).transfer(
            destinationAddress,
            amountInWei
        );

        if (!sent) revert TransferFailed();
    }

    /**
     * @dev Transfers a certain `amount` (WEI) of non-native asset
     * this can be any ERC20 compliant token this contract currently owns.
     * The contract address of token to be transferred is to be supplied
     * through `tokenContractAddress` and the destination addresses are sent
     * in an array `destinationAddressArray` along with their specific amounts
     * in `amountsInWei` array.
     * @notice address[0] is sent amountsInWei[0], address[1] is sent amountsInWei[1]
     * and so on.
     */

    function sendErcRewardsMultiDestination(
        address tokenContractAddress,
        address[] calldata destinationAddressArray,
        uint256[] calldata amountsInWei
    ) external payable onlyOperator {
        if (
            destinationAddressArray.length > 100 ||
            destinationAddressArray.length != amountsInWei.length
        ) revert IllegalArguments();

        if (!doesContractHaveEnoughTokens(tokenContractAddress, amountsInWei))
            revert InsufficientBalance();

        for (uint256 i = 0; i < destinationAddressArray.length; i++) {
            if (destinationAddressArray[i] == address(0))
                revert ZeroAddressError();

            bool sent = IERC20(tokenContractAddress).transfer(
                destinationAddressArray[i],
                amountsInWei[i]
            );

            if (!sent) revert TransferFailed();
        }
    }

    /**     
    * @dev Checks whether the contract has enough ERC20 tokens
    * to issue a transfer. This function returns a bool: true in
    * case the transfer can be made, false in case the transfer can't
    be made.
    * Change function to public if you wish to unit-test this function 
    * or use it externally.
    */

    function doesContractHaveEnoughTokens(
        address tokenContractAddress,
        uint256[] calldata arrayToSum
    ) internal view returns (bool) {
        uint256 sum;
        for (uint256 i = 0; i < arrayToSum.length; i++) {
            sum += arrayToSum[i];
        }
        if (IERC20(tokenContractAddress).balanceOf(address(this)) >= sum)
            return true;
        return false;
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
// OpenZeppelin Contracts v4.4.1 (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

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
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

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