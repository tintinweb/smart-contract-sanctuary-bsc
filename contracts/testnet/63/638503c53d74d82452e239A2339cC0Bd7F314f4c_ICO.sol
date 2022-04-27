// SPDX-License-Identifier: MIT

pragma solidity 0.8.4;
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

interface Distribution {
    function addInvestor(address _investor, uint256 _tokensAllotment) external;

    function removeInvestor(address _investor) external;
}

contract ICO is Ownable, ReentrancyGuard {
    Distribution private PvtVesting;
    Distribution private PubVesting;
    address payable public admin;
    uint256 public privateSaleICOQuantity = 200 * 10**18;
    // uint256 public publicSaleICOQuantity = 54444444444 * 10**18;
    uint256 public publicSaleICOQuantity = 1000 * 10**18;
    uint256 public weiRaised;
    uint256 public goal;
    uint256 ratePvt;
    uint256 ratePub;
    bool public closed = false;
    event PurchaseSuccess(
        uint256 amountPaid,
        uint256 TokensAllocated,
        address indexed Sender
    );
    event FundsTransfered(uint256 amount, uint256 gas, address indexed _to);
    event StageChange(address indexed owner, ICOStage stageNo);
    event ChangeRate(address indexed owner, uint256 updateRate, ICOStage stage);

    enum ICOStage {
        privateICO,
        publicICO
    }

    modifier notClosed() {
        require(!closed, "ICO is Closed");
        _;
    }

    mapping(address => bool) private whitelistPvt;
    mapping(address => uint256) private privateSaleDeposit;
    mapping(address => uint256) private publicSaleDeposit;

    ICOStage public stage = ICOStage.privateICO;

    constructor(
        address _pvtDistribution,
        address _publicDistribution,
        uint256 _ratePvt,
        uint256 _goal
    ) {
        admin = payable(msg.sender);
        PvtVesting = Distribution(_pvtDistribution);
        PubVesting = Distribution(_publicDistribution);
        ratePvt = _ratePvt;
        ratePub = 3333333;
        goal = _goal;
    }

    function whitelistAddr(address _addr) external notClosed onlyOwner {
        whitelistPvt[_addr] = true;
    }

    function batchWhitelistAddr(address[] memory users)
        external
        notClosed
        onlyOwner
    {
        for (uint256 i = 0; i < users.length; i++) {
            whitelistPvt[users[i]] = true;
        }
    }

    function closeICO() external notClosed onlyOwner {
        closed = true;
    }

    function changeStage(ICOStage _stage) external notClosed onlyOwner {
        if (_stage == ICOStage.privateICO) {
            stage = ICOStage.privateICO;
        } else if (_stage == ICOStage.publicICO) {
            stage = ICOStage.publicICO;
        }
        emit StageChange(msg.sender, _stage);
    }

    function changeRate(uint256 newRate, ICOStage _stage) external onlyOwner {
        if (_stage == ICOStage.privateICO) {
            ratePvt = newRate;
        } else if (_stage == ICOStage.publicICO) {
            ratePub = newRate;
        }
        emit ChangeRate(msg.sender, newRate, _stage);
    }

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function getRate() public view returns (uint256) {
        if (stage == ICOStage.privateICO) {
            return ratePvt;
        }
        return ratePub;
    }

    function checkWhitelist(address _investor) public view returns (bool) {
        return whitelistPvt[_investor];
    }

    function goalReached() public view returns (bool) {
        return weiRaised >= goal;
    }

    function buyTokens() external payable notClosed nonReentrant {
        if (stage == ICOStage.privateICO) {
            require(
                whitelistPvt[msg.sender],
                "Address not authorized to participate in Private Sale"
            );
            uint256 noOfTokens = ratePvt * msg.value;
            require(
                privateSaleICOQuantity >= noOfTokens,
                "Private sale:Insufficient balance"
            );
            privateSaleICOQuantity -= noOfTokens;
            PvtVesting.addInvestor(msg.sender, noOfTokens);
            if (privateSaleICOQuantity == 0) {
                stage = ICOStage.publicICO;
            }
            privateSaleDeposit[msg.sender] += msg.value;
            emit PurchaseSuccess(msg.value, noOfTokens, msg.sender);
        } else if (stage == ICOStage.publicICO) {
            uint256 noOfTokens = ratePub * msg.value;
            require(
                publicSaleICOQuantity >= noOfTokens,
                "Public sale:Insufficient balance"
            );
            publicSaleICOQuantity -= noOfTokens;
            PubVesting.addInvestor(msg.sender, noOfTokens);
            publicSaleDeposit[msg.sender] += msg.value;
            emit PurchaseSuccess(msg.value, noOfTokens, msg.sender);
        }
        weiRaised += msg.value;
    }

    function withdrawFunds(address payable _to)
        external
        onlyOwner
        nonReentrant
    {
        uint256 amount = address(this).balance;
        (bool success, ) = _to.call{value: amount}("");
        require(success, "call failed");
        emit FundsTransfered(amount, gasleft(), msg.sender);
    }

    function buyBack() external nonReentrant {
        if (stage == ICOStage.privateICO) {
            require(
                privateSaleDeposit[msg.sender] > 0,
                "Not participated in Private Sale"
            );
            uint256 payment = privateSaleDeposit[msg.sender];
            weiRaised -= payment;
            uint256 noOfTokens = ratePvt * payment;
            privateSaleICOQuantity += noOfTokens;
            (bool success, ) = msg.sender.call{value: payment}("");
            require(success, "unable to transfer-money back");
            PvtVesting.removeInvestor(msg.sender);
            emit FundsTransfered(payment, gasleft(), msg.sender);
        } else if (stage == ICOStage.publicICO) {
            require(
                publicSaleDeposit[msg.sender] > 0,
                "Not participated in Public Sale"
            );
            uint256 payment = privateSaleDeposit[msg.sender];
            weiRaised -= payment;
            uint256 noOfTokens = ratePub * payment;
            publicSaleICOQuantity += noOfTokens;
            (bool success, ) = msg.sender.call{value: payment}("");
            require(success, "unable to transfer-money back");
            PubVesting.removeInvestor(msg.sender);
            emit FundsTransfered(payment, gasleft(), msg.sender);
        }
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
// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

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