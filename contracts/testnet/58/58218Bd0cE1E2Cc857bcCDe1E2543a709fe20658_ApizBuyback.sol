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
// OpenZeppelin Contracts (last updated v4.8.0) (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;

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
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }

    function _nonReentrantBefore() private {
        // On the first call to nonReentrant, _status will be _NOT_ENTERED
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;
    }

    function _nonReentrantAfter() private {
        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
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
pragma solidity 0.8.17;

import "./interfaces/INFT.sol";
import "./interfaces/IToken.sol";
import "./pancake-swap/libraries/TransferHelper.sol";

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract ApizBuyback is Ownable, ReentrancyGuard {
    uint256 public constant DENOMINATOR = 100;
    uint32 public constant DEPOSIT_DURATION = 18 * (30 days);

    address public immutable USDT;
    address public immutable APIZ;

    INFT public nft;
    uint256 public unfreezedAmount;
    PaymentConfiguration public paymentConfig;

    bool public fakeTimestampListen;
    uint256 public fakeTimestamp;

    mapping(address => uint256) public alreadySold;
    mapping(uint256 => DepositInfo) public deposits; // tokenID -> deposit

    struct PaymentConfiguration {
        uint8 percent;
        uint256 pricePerOneToken;
    }

    struct DepositInfo {
        uint256 amount;
        uint32 end;
        PaymentConfiguration configuration;
    }

    /// @param _addresses - an array with following addresses [apiz, usdt, owner]
    constructor(
        PaymentConfiguration memory _paymentConfig,
        address[3] memory _addresses
    ) {
        require(
            _paymentConfig.pricePerOneToken > 0 && _paymentConfig.percent > 0,
            "ApizBuyback: wrong initial configuration"
        );
        require(
            _addresses[0] != address(0) &&
                _addresses[1] != address(0) &&
                _addresses[2] != address(0),
            "ApizBuyback: wrong addresses"
        );

        paymentConfig = _paymentConfig;
        APIZ = _addresses[0];
        USDT = _addresses[1];

        _transferOwnership(_addresses[2]);
    }

    function setTimestamp(bool status, uint256 currentTime) external {
        fakeTimestampListen = status;
        fakeTimestamp = currentTime;
    }

    function setNFT(address _nft) external onlyOwner {
        require(
            _nft != address(0) && address(nft) == address(0),
            "ApizBuyback: wrong value"
        );
        nft = INFT(_nft);
    }

    function changePercent(uint8 _perc) external onlyOwner {
        require(_perc > 0, "ApizBuyback: wrong value");
        paymentConfig.percent = _perc;
    }

    function changePrice(uint256 _price) external onlyOwner {
        require(_price > 0, "ApizBuyback: wrong value");
        paymentConfig.pricePerOneToken = _price;
    }

    function createDeposit(uint256 amount) external nonReentrant {
        require(
            amount > 0 &&
                amount + alreadySold[_msgSender()] <=
                IToken(APIZ).getPurchasedOnCrowdsaleAmount(_msgSender()),
            "ApizBuyback: wrong amount"
        );
        require(address(nft) != address(0), "ApizBuyback: not initialized");

        uint256 tokenId = nft.mint(_msgSender());
        deposits[tokenId] = DepositInfo(
            amount,
            uint32(_getTime()) + DEPOSIT_DURATION,
            paymentConfig
        );
        alreadySold[_msgSender()] += amount;

        TransferHelper.safeTransferFrom(
            APIZ,
            _msgSender(),
            address(this),
            amount
        );
    }

    function claimUsdt(uint256 tokenId) external nonReentrant {
        require(
            nft.ownerOf(tokenId) == _msgSender(),
            "ApizBuyback: not yours NFT"
        );
        require(
            deposits[tokenId].amount > 0 &&
                deposits[tokenId].end <= _getTime(),
            "ApizBuyback: wrong deposit params"
        );

        unfreezedAmount += deposits[tokenId].amount;

        uint256 outputAmount = (((deposits[tokenId].amount *
            deposits[tokenId].configuration.pricePerOneToken) / 10**6) *
            deposits[tokenId].configuration.percent) / DENOMINATOR;

        delete (deposits[tokenId]);

        nft.burn(tokenId);
        TransferHelper.safeTransfer(USDT, _msgSender(), outputAmount);
    }

    function claimTokens(address _token) external onlyOwner nonReentrant {
        require(_token != address(0), "ApizBuyback: wrong token address");
        uint256 amount;
        if (_token == APIZ) {
            require(
                unfreezedAmount > 0,
                "ApizBuyback: no available APIZ tokens"
            );
            amount = unfreezedAmount;
            unfreezedAmount = 0;
        } else {
            amount = INFT(_token).balanceOf(address(this));
            require(amount > 0, "ApizBuyback: no available tokens");
        }
        TransferHelper.safeTransfer(_token, _msgSender(), amount);
    }

    function getAvailableTokensToDeposit(address user)
        external
        view
        returns (uint256)
    {
        uint256 available = (IToken(APIZ).getPurchasedOnCrowdsaleAmount(user) -
            alreadySold[user]);
        return
            available > INFT(APIZ).balanceOf(user)
                ? INFT(APIZ).balanceOf(user)
                : available;
    }

    function getStat(uint256[] memory tokenIds)
        external
        view
        returns (
            uint256[] memory amountsInDeposit,
            uint256[] memory usdtToReceive,
            uint32[] memory depositEnds
        )
    {
        amountsInDeposit = new uint256[](tokenIds.length);
        usdtToReceive = new uint256[](tokenIds.length);
        depositEnds = new uint32[](tokenIds.length);
        for (uint256 i; i < tokenIds.length; i++) {
            amountsInDeposit[i] = deposits[tokenIds[i]].amount;
            usdtToReceive[i] = _getAmountToReceive(tokenIds[i]);
            depositEnds[i] = deposits[tokenIds[i]].end;
        }
    }

    function _getAmountToReceive(uint256 tokenId)
        private
        view
        returns (uint256)
    {
        return
            (((deposits[tokenId].amount *
                deposits[tokenId].configuration.pricePerOneToken) / 10**6) *
                deposits[tokenId].configuration.percent) / DENOMINATOR;
    }

    function _getTime() private view returns(uint256){
        if(fakeTimestampListen) return fakeTimestamp;
        else return block.timestamp;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

interface INFT {
    function mint(address user) external returns (uint256);

    function burn(uint256 tokenId) external;

    function ownerOf(uint256 tokenId) external view returns (address owner);

    function balanceOf(address owner) external view returns (uint256);
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

interface IToken {
    function getPurchasedOnCrowdsaleAmount(address user)
        external
        view
        returns (uint256);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

// helper methods for interacting with ERC20 tokens and sending ETH that do not consistently return true/false
library TransferHelper {
    function safeApprove(
        address token,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('approve(address,uint256)')));
        (bool success, bytes memory data) =
            token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "TransferHelper::safeApprove: approve failed"
        );
    }

    function safeTransfer(
        address token,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) =
            token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "TransferHelper::safeTransfer: transfer failed"
        );
    }

    function safeTransferFrom(
        address token,
        address from,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) =
            token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "TransferHelper::transferFrom: transferFrom failed"
        );
    }

    function safeTransferETH(address to, uint256 value) internal {
        (bool success, ) = to.call{value: value}(new bytes(0));
        require(
            success,
            "TransferHelper::safeTransferETH: ETH transfer failed"
        );
    }
}