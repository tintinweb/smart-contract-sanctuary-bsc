// SPDX-License-Identifier: MIT

pragma solidity 0.8.4;
import "@openzeppelin/contracts/access/Ownable.sol";

interface Distribution {
    function addInvestor(address _investor, uint256 _tokensAllotment) external;
}

contract ICO is Ownable {
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

    ICOStage public stage = ICOStage.privateICO;

    constructor(address _pvtDistribution, address _publicDistribution, uint256 _ratePvt, uint256 _goal) {
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

    function batchWhitelistAddr(address[] memory users) external notClosed onlyOwner{
        for (uint i=0;i<users.length;i++){
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

    function goalReached() public view returns (bool){
        return weiRaised>=goal;
    }

    function buyTokens() external payable notClosed {
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
            emit PurchaseSuccess(msg.value, noOfTokens, msg.sender);
        } else if (stage == ICOStage.publicICO) {
            uint256 noOfTokens = ratePub * msg.value;
            require(
                publicSaleICOQuantity >= noOfTokens,
                "Public sale:Insufficient balance"
            );
            publicSaleICOQuantity -= noOfTokens;
            PubVesting.addInvestor(msg.sender, noOfTokens);
            emit PurchaseSuccess(msg.value, noOfTokens, msg.sender);
        }
        weiRaised += msg.value;
    }

    function withdrawFunds(address payable _to) external onlyOwner {
        uint256 amount = address(this).balance;
        (bool success, ) = _to.call{value: amount}("");
        require(success, "call failed");
        emit FundsTransfered(amount, gasleft(), msg.sender);
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