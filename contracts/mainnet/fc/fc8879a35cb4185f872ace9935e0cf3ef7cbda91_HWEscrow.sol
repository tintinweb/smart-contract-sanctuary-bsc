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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Counters.sol)

pragma solidity ^0.8.0;

/**
 * @title Counters
 * @author Matt Condon (@shrugs)
 * @dev Provides counters that can only be incremented, decremented or reset. This can be used e.g. to track the number
 * of elements in a mapping, issuing ERC721 ids, or counting request ids.
 *
 * Include with `using Counters for Counters.Counter;`
 */
library Counters {
    struct Counter {
        // This variable should never be directly accessed by users of the library: interactions must be restricted to
        // the library's function. As of Solidity v0.5.2, this cannot be enforced, though there is a proposal to add
        // this feature: see https://github.com/ethereum/solidity/issues/4637
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {
        return counter._value;
    }

    function increment(Counter storage counter) internal {
        unchecked {
            counter._value += 1;
        }
    }

    function decrement(Counter storage counter) internal {
        uint256 value = counter._value;
        require(value > 0, "Counter: decrement overflow");
        unchecked {
            counter._value = value - 1;
        }
    }

    function reset(Counter storage counter) internal {
        counter._value = 0;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./interfaces/IHWRegistry.sol";
import "./interfaces/IHWRegistry.sol";
import "./interfaces/IUniswapV2Router01.sol";
import "./interfaces/IPool.sol";
import "./utils/SigUtils.sol";

/// @title HonestWork Escrow Contract
/// @author @takez0_o, @ReddKidd
/// @notice Escrow contract for HonestWork
/// @dev Facilitates deals between creators and recruiters
contract HWEscrow is Ownable, ReentrancyGuard, SigUtils {
    using Counters for Counters.Counter;

    enum Status {
        OfferInitiated,
        JobCompleted,
        JobCancelled
    }
    struct Deal {
        address recruiter;
        address creator;
        address paymentToken;
        uint256 totalPayment;
        uint256 successFee;
        uint256 claimedAmount;
        uint256 claimableAmount;
        uint256 jobId;
        Status status;
        uint128[] recruiterRating;
        uint128[] creatorRating;
    }

    uint128 immutable PRECISION = 1e2;

    Counters.Counter public dealIds;
    IHWRegistry public registry;
    IUniswapV2Router01 public router;
    IERC20 public stableCoin;
    IPool public pool;
    uint64 public extraPaymentLimit;
    uint128 public honestWorkSuccessFee;
    bool public nativePaymentAllowed;
    uint256 public totalCollectedSuccessFee;

    mapping(uint256 => uint256) public additionalPaymentLimit;
    mapping(uint256 => Deal) public dealsMapping;

    constructor(
        address _registry,
        address _pool,
        address _stableCoin,
        address _router
    ) Ownable() {
        honestWorkSuccessFee = 5;
        registry = IHWRegistry(_registry);
        pool = IPool(_pool);
        stableCoin = IERC20(_stableCoin);
        router = IUniswapV2Router01(_router);
    }

    //-----------------//
    //  admin methods  //
    //-----------------//

    /**
     * @dev value is expressed as a percentage.
     */
    function changeSuccessFee(uint128 _fee) external onlyOwner {
        honestWorkSuccessFee = _fee;
        emit FeeChanged(_fee);
    }

    function changeRegistry(IHWRegistry _registry) external onlyOwner {
        registry = _registry;
    }

    function claimSuccessFee(
        uint256 _dealId,
        address _feeCollector
    ) external onlyOwner {
        uint256 successFee = dealsMapping[_dealId].successFee;

        if (dealsMapping[_dealId].paymentToken != address(0)) {
            IERC20 paymentToken = IERC20(dealsMapping[_dealId].paymentToken);
            paymentToken.transfer(_feeCollector, successFee);
        } else {
            (bool payment, ) = payable(_feeCollector).call{value: successFee}(
                ""
            );
            require(payment, "payment failed");
        }
        totalCollectedSuccessFee += successFee;
        dealsMapping[_dealId].successFee = 0;
        emit FeeClaimed(_dealId, dealsMapping[_dealId].successFee);
    }

    function claimTotalSuccessFee(address _feeCollector) external onlyOwner {
        for (uint256 i = 1; i <= dealIds.current(); i++) {
            uint256 successFee = dealsMapping[i].successFee;
            if (successFee > 0) {
                if (dealsMapping[i].paymentToken == address(0)) {
                    (bool payment, ) = payable(_feeCollector).call{
                        value: successFee
                    }("");
                    require(payment, "payment failed");
                } else {
                    IERC20 paymentToken = IERC20(dealsMapping[i].paymentToken);
                    paymentToken.transfer(_feeCollector, successFee);
                }
                dealsMapping[i].successFee = 0;
            }
        }
        emit TotalFeeClaimed(_feeCollector);
    }

    function changeExtraPaymentLimit(uint64 _limit) external onlyOwner {
        extraPaymentLimit = _limit;
        emit ExtraLimitChanged(_limit);
    }

    function allowNativePayment(bool _bool) external onlyOwner {
        nativePaymentAllowed = _bool;
    }

    function setStableCoin(address _stableCoin) external onlyOwner {
        stableCoin = IERC20(_stableCoin);
    }

    function setRouter(address _router) external onlyOwner {
        router = IUniswapV2Router01(_router);
    }

    function setPool(address _pool) external onlyOwner {
        pool = IPool(_pool);
    }

    //--------------------//
    //  mutative methods  //
    //--------------------//

    function createDealSignature(
        address _recruiter,
        address _creator,
        address _paymentToken,
        uint256 _totalPayment,
        uint256 _downPayment,
        uint256 _recruiterNFTId,
        uint256 _jobId,
        bytes memory _signature
    ) external payable returns (uint256) {
        (bytes32 r, bytes32 s, uint8 v) = SigUtils.splitSignature(_signature);
        return
            createDeal(
                _recruiter,
                _creator,
                _paymentToken,
                _totalPayment,
                _downPayment,
                _recruiterNFTId,
                _jobId,
                v,
                r,
                s
            );
    }

    function createDeal(
        address _recruiter,
        address _creator,
        address _paymentToken,
        uint256 _totalPayment,
        uint256 _downPayment,
        uint256 _recruiterNFTId,
        uint256 _jobId,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public payable returns (uint256) {
        require(_recruiter != address(0), "recruiter address cannot be 0");
        require(_creator != address(0), "creator address cannot be 0");
        require(_totalPayment > 0, "total payment cannot be 0");
        require(
            _creator != _recruiter,
            "creator and recruiter cannot be the same address"
        );

        if (_paymentToken == address(0)) {
            require(nativePaymentAllowed, "native payment is not allowed");
        }

        bytes32 signedMessage = getEthSignedMessageHash(
            getMessageHash(
                _recruiter,
                _creator,
                _paymentToken,
                _totalPayment,
                _downPayment,
                _jobId
            )
        );

        require(
            recoverSigner(signedMessage, v, r, s) == _creator,
            "invalid signature, creator needs to sign the deal paramers first"
        );

        require(
            registry.isAllowedAmount(_paymentToken, _totalPayment),
            "the token you are trying to pay with is either not whitelisted or you are exceeding the allowed amount"
        );
        dealIds.increment();
        uint128[] memory arr1;
        uint128[] memory arr2;
        dealsMapping[dealIds.current()] = Deal(
            _recruiter,
            _creator,
            _paymentToken,
            _totalPayment,
            0,
            0,
            0,
            _jobId,
            Status.OfferInitiated,
            arr1,
            arr2
        );
        if (_paymentToken == address(0)) {
            require(
                msg.value >= _totalPayment,
                "employer should deposit the payment"
            );
        } else {
            IERC20 paymentToken = IERC20(_paymentToken);
            paymentToken.transferFrom(
                msg.sender,
                address(this),
                (_totalPayment)
            );
        }
        emit OfferCreated(_recruiter, _creator, _totalPayment, _paymentToken);

        if (_downPayment != 0) {
            unlockPayment(dealIds.current(), _downPayment, 0, _recruiterNFTId);
        }
        return dealIds.current();
    }

    function unlockPayment(
        uint256 _dealId,
        uint256 _paymentAmount,
        uint128 _rating,
        uint256 _recruiterNFT
    ) public {
        Deal storage currentDeal = dealsMapping[_dealId];
        require(
            currentDeal.status == Status.OfferInitiated,
            "deal is either completed or cancelled"
        );
        require(
            _rating >= 0 && _rating <= 10,
            "rating must be between 0 and 10"
        );
        require(
            currentDeal.recruiter == msg.sender,
            "only recruiter can unlock payments"
        );

        currentDeal.claimableAmount += _paymentAmount;
        address _paymentToken = currentDeal.paymentToken;

        require(
            currentDeal.totalPayment >=
                currentDeal.claimableAmount + currentDeal.claimedAmount,
            "can not go above total payment, use additional payment function pls"
        );
        if (_rating != 0) {
            currentDeal.creatorRating.push(_rating * PRECISION);
        }

        uint256 grossRev = (
            _paymentToken == address(0)
                ? getEthPrice(_paymentAmount)
                : _paymentAmount
        );

        registry.setNFTGrossRevenue(_recruiterNFT, grossRev);

        emit GrossRevenueUpdated(_recruiterNFT, grossRev);
        emit PaymentUnlocked(_dealId, currentDeal.recruiter, _paymentAmount);
    }

    function withdrawPayment(uint256 _dealId) external {
        Deal storage currentDeal = dealsMapping[_dealId];
        require(
            currentDeal.status == Status.OfferInitiated,
            "job should be active"
        );
        require(
            currentDeal.recruiter == msg.sender,
            "only recruiter can withdraw payments"
        );
        address _paymentToken = currentDeal.paymentToken;
        uint256 amountToBeWithdrawn = currentDeal.totalPayment -
            currentDeal.claimedAmount -
            currentDeal.claimableAmount;
        if (_paymentToken == address(0)) {
            (bool payment, ) = payable(currentDeal.recruiter).call{
                value: amountToBeWithdrawn
            }("");
            require(payment, "Failed to send payment");
        } else {
            IERC20 paymentToken = IERC20(_paymentToken);
            paymentToken.transfer(msg.sender, (amountToBeWithdrawn));
        }

        currentDeal.status = Status.JobCancelled;
        emit PaymentWithdrawn(_dealId, currentDeal.status);
    }

    function claimPayment(
        uint256 _dealId,
        uint256 _withdrawAmount,
        uint128 _rating,
        uint256 _creatorNFT
    ) external {
        Deal storage currentDeal = dealsMapping[_dealId];
        require(
            currentDeal.status == Status.OfferInitiated,
            "deal is either completed or cancelled"
        );
        require(
            _rating >= 0 && _rating <= 10,
            "rating must be between 0 and 10"
        );
        require(
            currentDeal.creator == msg.sender,
            "only creator can receive payments"
        );
        require(
            currentDeal.claimableAmount >= _withdrawAmount,
            "desired payment is not available yet"
        );

        address _paymentToken = currentDeal.paymentToken;
        currentDeal.claimedAmount += _withdrawAmount;
        currentDeal.claimableAmount -= _withdrawAmount;
        currentDeal.recruiterRating.push(_rating * PRECISION);
        currentDeal.successFee +=
            (_withdrawAmount * honestWorkSuccessFee) /
            PRECISION;
        if (_paymentToken == address(0)) {
            (bool payment, ) = payable(currentDeal.creator).call{
                value: (_withdrawAmount * (PRECISION - honestWorkSuccessFee)) /
                    PRECISION
            }("");
            require(payment, "Failed to send payment");
        } else {
            IERC20 paymentToken = IERC20(_paymentToken);

            paymentToken.transfer(
                msg.sender,
                ((_withdrawAmount * (PRECISION - honestWorkSuccessFee)) /
                    PRECISION)
            );
        }
        uint256 grossRev = (
            _paymentToken == address(0)
                ? getEthPrice(_withdrawAmount)
                : _withdrawAmount
        );
        registry.setNFTGrossRevenue(_creatorNFT, grossRev);
        if (currentDeal.claimedAmount >= currentDeal.totalPayment) {
            currentDeal.status = Status.JobCompleted;
        }
        emit GrossRevenueUpdated(_creatorNFT, grossRev);
        emit PaymentClaimed(_dealId, currentDeal.creator, _withdrawAmount);
    }

    /**
     * @dev recruiter immediately unlocks an additional amount for the creator to claim
     */
    function additionalPayment(
        uint256 _dealId,
        uint256 _payment,
        uint256 _recruiterNFT,
        uint128 _rating
    ) external payable {
        Deal storage currentDeal = dealsMapping[_dealId];
        require(
            currentDeal.status == Status.OfferInitiated,
            "deal is either completed or cancelled"
        );
        require(
            _rating >= 0 && _rating <= 10,
            "rating must be between 0 and 10"
        );
        require(
            additionalPaymentLimit[_dealId] <= extraPaymentLimit,
            "you can not make more than 3 additional payments"
        );
        require(
            currentDeal.status == Status.OfferInitiated,
            "job should be active"
        );
        require(
            currentDeal.recruiter == msg.sender,
            "only recruiter can add payments"
        );

        address _paymentToken = currentDeal.paymentToken;
        if (_paymentToken == address(0)) {
            require(
                msg.value >= _payment,
                "recruiter should deposit the additional payment"
            );
            currentDeal.claimableAmount += _payment;
            currentDeal.totalPayment += _payment;
        } else {
            IERC20 paymentToken = IERC20(_paymentToken);
            paymentToken.transferFrom(msg.sender, address(this), _payment);
            currentDeal.claimableAmount += _payment;
            currentDeal.totalPayment += _payment;
        }

        uint256 grossRev = (
            _paymentToken == address(0) ? getEthPrice(_payment) : _payment
        );
        registry.setNFTGrossRevenue(_recruiterNFT, grossRev);

        additionalPaymentLimit[_dealId]++;
        currentDeal.creatorRating.push(_rating * PRECISION);

        emit GrossRevenueUpdated(_recruiterNFT, grossRev);
        emit AdditionalPayment(_dealId, currentDeal.recruiter, _payment);
    }

    //----------------//
    //  view methods  //
    //----------------//

    function getDeal(uint256 _dealId) public view returns (Deal memory) {
        return dealsMapping[_dealId];
    }

    function getPrecision() external pure returns (uint256) {
        return PRECISION;
    }

    function getAvgCreatorRating(
        uint256 _dealId
    ) public view returns (uint256) {
        uint256 sum;
        for (
            uint256 i = 0;
            i < dealsMapping[_dealId].creatorRating.length;
            i++
        ) {
            sum += dealsMapping[_dealId].creatorRating[i];
        }
        return (sum / dealsMapping[_dealId].creatorRating.length);
    }

    function getAvgRecruiterRating(
        uint256 _dealId
    ) public view returns (uint256) {
        uint256 sum;
        for (
            uint256 i = 0;
            i < dealsMapping[_dealId].recruiterRating.length;
            i++
        ) {
            sum += dealsMapping[_dealId].recruiterRating[i];
        }
        return (sum / dealsMapping[_dealId].recruiterRating.length);
    }

    function getAggregatedRating(
        address _address
    ) public view returns (uint256) {
        uint256 gross_amount = 0;
        uint256 gross_rating = 0;
        uint256[] memory deal_ids = getDealsOf(_address);
        for (uint256 i = 0; i < deal_ids.length; i++) {
            Deal memory deal = getDeal(deal_ids[i]);
            if (
                _address == deal.recruiter && deal.recruiterRating.length != 0
            ) {
                gross_rating +=
                    getAvgRecruiterRating(deal_ids[i]) *
                    deal.claimedAmount;
                gross_amount += deal.claimedAmount;
            } else if (
                _address == deal.creator && deal.creatorRating.length != 0
            ) {
                gross_rating +=
                    getAvgCreatorRating(deal_ids[i]) *
                    (deal.claimedAmount + deal.claimableAmount);
                gross_amount += (deal.claimedAmount + deal.claimableAmount);
            }
        }
        if (gross_amount == 0) {
            return 0;
        } else {
            return gross_rating / gross_amount;
        }
    }

    function getTotalSuccessFee() external view returns (uint256) {
        uint256 totalSuccessFee;
        for (uint256 i = 1; i <= dealIds.current(); i++) {
            totalSuccessFee += dealsMapping[i].successFee;
        }
        return totalSuccessFee;
    }

    function getAdditionalPaymentLimit(
        uint256 _dealId
    ) external view returns (uint256) {
        return additionalPaymentLimit[_dealId];
    }

    function getDealsOf(
        address _address
    ) public view returns (uint256[] memory) {
        uint256[] memory deals = new uint256[](getDealsCount(_address));
        uint256 arrayLocation = 0;
        for (uint256 i = 0; i <= dealIds.current(); i++) {
            if (
                dealsMapping[i].creator == _address ||
                dealsMapping[i].recruiter == _address
            ) {
                deals[arrayLocation] = i;
                arrayLocation++;
            }
        }
        return deals;
    }

    function getAllDeals() public view returns (Deal[] memory) {
        Deal[] memory deals = new Deal[](dealIds.current());
        for (uint256 i = 0; i < dealIds.current(); i++) {
            deals[i] = dealsMapping[i];
        }
        return deals;
    }

    function getEthPrice(uint256 _amount) internal view returns (uint256) {
        uint256 reserve1;
        uint256 reserve2;
        (reserve1, reserve2, ) = pool.getReserves();
        return router.quote(_amount, reserve1, reserve2);
    }

    function getDealsCount(address _address) internal view returns (uint256) {
        uint256 count;
        for (uint256 i = 0; i <= dealIds.current(); i++) {
            if (
                dealsMapping[i].creator == _address ||
                dealsMapping[i].recruiter == _address
            ) {
                count++;
            }
        }
        return count;
    }

    event OfferCreated(
        address indexed _recruiter,
        address indexed _creator,
        uint256 indexed _totalPayment,
        address _paymentToken
    );
    event PaymentUnlocked(
        uint256 _dealId,
        address indexed _recruiter,
        uint256 indexed _unlockedAmount
    );
    event PaymentClaimed(
        uint256 indexed _dealId,
        address indexed _creator,
        uint256 indexed _paymentReceived
    );
    event AdditionalPayment(
        uint256 indexed _dealId,
        address indexed _recruiter,
        uint256 indexed _payment
    );
    event PaymentWithdrawn(uint256 indexed _dealId, Status status);
    event FeeChanged(uint256 _newSuccessFee);
    event FeeClaimed(uint256 indexed _dealId, uint256 _amount);
    event ExtraLimitChanged(uint256 _newPaymentLimit);
    event TotalFeeClaimed(address _collector);
    event GrossRevenueUpdated(uint256 indexed _tokenId, uint256 _grossRevenue);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

interface IHWRegistry {
    struct Whitelist {
        address token;
        uint256 maxAllowed;
    }

    //-----------------//
    //  admin methods  //
    //-----------------//

    function addToWhitelist(address _address, uint256 _maxAllowed) external;

    function removeFromWhitelist(address _address) external;

    function updateWhitelist(address _address, uint256 _maxAllowed) external;

    function setHWEscrow(address _address) external;

    //--------------------//
    //  mutative methods  //
    //--------------------//

    function setNFTGrossRevenue(uint256 _id, uint256 _amount) external;

    //----------------//
    //  view methods  //
    //----------------//

    function isWhitelisted(address _address) external view returns (bool);

    function getWhitelist() external view returns (Whitelist[] memory);

    function getNFTGrossRevenue(uint256 _id) external view returns (uint256);

    function isAllowedAmount(
        address _address,
        uint256 _amount
    ) external view returns (bool);

    function counter() external view returns (uint256);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

interface IPool {
    function getReserves()
        external
        view
        returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);

    function price0CumulativeLast() external view returns (uint);

    function price1CumulativeLast() external view returns (uint);
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.2;

interface IUniswapV2Router01 {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);

    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    )
        external
        payable
        returns (uint amountToken, uint amountETH, uint liquidity);

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);

    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);

    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint amountA, uint amountB);

    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint amountToken, uint amountETH);

    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);

    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);

    function swapExactETHForTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable returns (uint[] memory amounts);

    function swapTokensForExactETH(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);

    function swapExactTokensForETH(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);

    function swapETHForExactTokens(
        uint amountOut,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable returns (uint[] memory amounts);

    function quote(
        uint amountA,
        uint reserveA,
        uint reserveB
    ) external pure returns (uint amountB);

    function getAmountOut(
        uint amountIn,
        uint reserveIn,
        uint reserveOut
    ) external pure returns (uint amountOut);

    function getAmountIn(
        uint amountOut,
        uint reserveIn,
        uint reserveOut
    ) external pure returns (uint amountIn);

    function getAmountsOut(
        uint amountIn,
        address[] calldata path
    ) external view returns (uint[] memory amounts);

    function getAmountsIn(
        uint amountOut,
        address[] calldata path
    ) external view returns (uint[] memory amounts);
}

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);

    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract SigUtils {
    function splitSignature(
        bytes memory sig
    ) public pure returns (bytes32 r, bytes32 s, uint8 v) {
        require(sig.length == 65, "invalid signature length");

        assembly {
            /*
            First 32 bytes stores the length of the signature

            add(sig, 32) = pointer of sig + 32
            effectively, skips first 32 bytes of signature

            mload(p) loads next 32 bytes starting at the memory address p into memory
            */

            // first 32 bytes, after the length prefix
            r := mload(add(sig, 32))
            // second 32 bytes
            s := mload(add(sig, 64))
            // final byte (first byte of the next 32 bytes)
            v := byte(0, mload(add(sig, 96)))
        }

        // implicitly return (r, s, v)
    }

    function getMessageHash(
        address _recruiter,
        address _creator,
        address _paymentToken,
        uint256 _totalPayment,
        uint256 _downPayment,
        uint256 _jobId
    ) public pure returns (bytes32) {
        return
            keccak256(
                abi.encodePacked(
                    _recruiter,
                    _creator,
                    _paymentToken,
                    _totalPayment,
                    _downPayment,
                    _jobId
                )
            );
    }

    function getEthSignedMessageHash(
        bytes32 _messageHash
    ) public pure returns (bytes32) {
        /*  
        Signature is produced by signing a keccak256 hash with the following format:
        "\x19Ethereum Signed Message\n" + len(msg) + msg
        */
        return
            keccak256(
                abi.encodePacked(
                    "\x19Ethereum Signed Message:\n32",
                    _messageHash
                )
            );
    }

    function recoverSigner(
        bytes32 _ethSignedMessageHash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public pure returns (address) {
        return ecrecover(_ethSignedMessageHash, v, r, s);
    }
}