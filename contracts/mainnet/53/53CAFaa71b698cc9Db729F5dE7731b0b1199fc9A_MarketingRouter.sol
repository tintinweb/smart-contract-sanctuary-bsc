/**
 *Submitted for verification at BscScan.com on 2022-11-06
*/

/*
 * _____                     _       __          __        _     _
 * |  __ \                   | |      \ \        / /       | |   | |
 * | |__) | __ ___  ___  __ _| | ___   \ \  /\  / /__  _ __| | __| |
 * |  ___/ '__/ _ \/ __|/ _` | |/ _ \   \ \/  \/ / _ \| '__| |/ _` |
 * | |   | | |  __/\__ \ (_| | |  __/    \  /\  / (_) | |  | | (_| |
 * |_|   |_|  \___||___/\__,_|_|\___|     \/  \/ \___/|_|  |_|\__,_|
 *
 * Token generated on https://presale.world
 *
 * SPDX-License-Identifier: MIT
*/

pragma solidity ^0.8.15;

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

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}

interface IBuyAndBurn {
    function swapEthForTokensAndBurn() external payable;
}

contract MarketingRouter is Ownable, ReentrancyGuard {
    IBuyAndBurn private _buyAndBurn;
    address payable private _marketingWallet;

    uint256 private _burnBps = 0;
    bool private _shortCircuitEnabled = false;

    constructor(address buyAndBurn, address payable marketingWallet) {
        _buyAndBurn = IBuyAndBurn(buyAndBurn);
        _marketingWallet = payable(marketingWallet);
    }

    fallback() payable external {
        _distributeIncomingETH(msg.value);
    }

    receive() payable external {
        _distributeIncomingETH(msg.value);
    }

    function distributeIncomingETH() external payable {
        _distributeIncomingETH(msg.value);
    }

    function _distributeIncomingETH(uint256 incomingETH) private nonReentrant {
        require(incomingETH > 0, "AMOUNT_IS_ZERO");

        uint256 marketingAmount = incomingETH;
        uint256 burnAmount = 0;
        if (_burnBps > 0 && address(_buyAndBurn) != address(0)) {
            burnAmount = (marketingAmount * _burnBps) / 10_000;
            marketingAmount = marketingAmount - burnAmount;
        }

        if (marketingAmount > 0) {
            (bool success, ) = _marketingWallet.call{value: marketingAmount}("");
            require(success, "MARKETING_WITHDRAWAL_FAILURE");
        }

        if (burnAmount > 0) {
            _buyAndBurn.swapEthForTokensAndBurn{value: burnAmount}();
        }
    }

    function getBurnBps() external view returns (uint256) {
        return _burnBps;
    }

    function updateBurnBps(uint256 newBurnBps) external onlyOwner {
        require(newBurnBps <= 10_000);
        _burnBps = newBurnBps;
    }

    function getBurnAndBurnAddress() external view returns (address) {
        return address(_buyAndBurn);
    }

    function updateBuyAndBurnAddress(address newBuyAndBurn) external onlyOwner {
        _buyAndBurn = IBuyAndBurn(newBuyAndBurn);
    }

    function getMarketingWallet() external view returns (address) {
        return address(_marketingWallet);
    }

    function updateMarketingWallet(address payable newMarketingWallet) external onlyOwner {
        _marketingWallet = payable(newMarketingWallet);
    }

    function getShortCircuitEnabled() external view returns (bool) {
        return _shortCircuitEnabled;
    }

    function toggleShortCircuit(bool shortCircuit) external onlyOwner {
        _shortCircuitEnabled = shortCircuit;
    }

    function withdrawExcess() external onlyOwner nonReentrant {
        require(_shortCircuitEnabled, "SHORT_CIRCUIT_DISABLED");
        uint256 currentBalance = address(this).balance;

        (bool success, ) = payable(msg.sender).call{value: currentBalance}("");
        require(success, "WITHDRAW_EXCESS_FAILED");
    }
}