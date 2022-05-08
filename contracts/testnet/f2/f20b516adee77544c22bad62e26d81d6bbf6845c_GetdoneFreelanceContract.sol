// contracts/GetdoneFreelanceContract.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";


contract GetdoneFreelanceContract is OwnableUpgradeable, PausableUpgradeable, ReentrancyGuardUpgradeable{
    using SafeERC20Upgradeable for IERC20Upgradeable;

    uint256 constant public MILESTONE_STATUS_NEW = 0;
    uint256 constant public MILESTONE_STATUS_CANCELLED = 1;
    uint256 constant public MILESTONE_STATUS_APPROVED = 2;
    uint256 constant public MILESTONE_STATUS_DECLINED = 3;
    uint256 constant public MILESTONE_STATUS_PAID = 4;
    uint256 constant public MILESTONE_STATUS_REQUEST_PAYLESS = 5;
    uint256 constant public MILESTONE_STATUS_DECLINE_PAYLESS = 6;
    uint256 constant public ONE_HUNDRED_PERCENT = 10000; // 100%

    event Erc20WhitelistUpdated(address[] erc20s, bool status);
    event TransactionFeePercentUpdated(uint256 percent);
    event AdminWalletUpdated(address wallet);
    event MilestoneCreated(uint256 contractId, uint256 milestoneId, uint256 orderId, address talent, address customer, uint256 price, address erc20, uint256 status);
    event MilestoneCancelled(uint256 contractId, uint256 milestoneId, address talent, address customer, uint256 price, address erc20, uint256 status);
    event MilestoneApproved(uint256 contractId, uint256 milestoneId, address talent, address customer, uint256 price, address erc20, uint256 status);
    event MilestoneDeclined(uint256 contractId, uint256 milestoneId, address talent, address customer, uint256 price, address erc20, uint256 status);
    event MilestoneRequestPaidLess(uint256 contractId, uint256 milestoneId, address talent, address customer, uint256 price, address erc20, uint256 status);
    event MilestonePaidLessDeclined(uint256 contractId, uint256 milestoneId, address talent, address customer, uint256 price, address erc20, uint256 status);
    event MilestonePaid(uint256 contractId, uint256 milestoneId, address talent, address customer, uint256 price, uint256 amount, uint256 fee, address erc20, uint256 status);
    event MilestonePaidLess(uint256 contractId, uint256 milestoneId, address talent, address customer, uint256 price, uint256 amount, uint256 fee, address erc20, uint256 status);
    event ContractEnded(uint256 contractId, address sender, uint256 refund, address erc20, bool isEndTalent, bool isEndCustomer);
    event ContractEndingDeclined(uint256 contractId, address sender, uint256 refund, address erc20, bool isEndTalent, bool isEndCustomer);
    event ContractForceEnded(uint256 contractId, address sender, uint256 refund, address erc20, bool isEndTalent, bool isEndCustomer);
    event Payout(uint256 contractId, uint256 milestoneId, uint256 amount, uint256 fee, address erc20, address receiver);

    struct Milestone {
        uint256 contractId;
        uint256 milestoneId;
        uint256 orderId;
        address talent;
        address customer;
        uint256 price;
        uint256 payless;
        uint256 paid;
        uint256 refund;
        uint256 status;
    }

    struct ContractInfo {
        uint256 contractId;
        address customer;
        address talent;
        address erc20;
        uint256 price;
        uint256 paid;
        uint256 refund;
        bool isEndTalent;
        bool isEndCustomer;
        bool init;
    }

    // erc20 address => status
    mapping(address => bool) public erc20Whitelist;

    // customer => contractId => milestoneId => Milestone
    mapping(address => mapping(uint256 => mapping(uint256 => Milestone))) public milestones;
    // customer => contractId => milestoneIds[]
    mapping(address => mapping(uint256 => uint256[])) public milestoneIds;
    // customer => contractId => ContractInfo
    mapping(address => mapping(uint256 => ContractInfo)) public contractInfos;
    
    address public adminWallet;
    uint256 public transactionFeePercent;

    function initialize()
        public
        initializer
    {
        __Ownable_init();
        __Pausable_init();
        __ReentrancyGuard_init();

        adminWallet = _msgSender();
        transactionFeePercent = 0;
    }

    modifier inWhitelist(address erc20) {
        require(erc20Whitelist[erc20], "GetdoneFreelanceContract: erc20 must be in whitelist");
        _;
    }
    
    function isEnd(uint256 contractId, address customer)
        internal
        view
        returns (bool)
    {
        return contractInfos[customer][contractId].isEndCustomer || contractInfos[customer][contractId].isEndTalent;
    }

    modifier allowEnd(uint256 contractId, address customer) {
        require((!contractInfos[customer][contractId].isEndCustomer || !contractInfos[customer][contractId].isEndTalent), "GetdoneFreelanceContract: contract has been ended");

        uint256 length = milestoneIds[customer][contractId].length;
        bool allow = true;

        if (length > 0) {
            for (uint256 i = 0; i < length; i++) {
                uint256 milestoneId = milestoneIds[customer][contractId][i];
                Milestone memory milestone = milestones[customer][contractId][milestoneId];

                if (milestone.status == MILESTONE_STATUS_NEW || milestone.status == MILESTONE_STATUS_REQUEST_PAYLESS) {
                    allow = false;
                    break;
                }
            }
        }
        require(allow == true, "GetdoneFreelanceContract: contract does not allow to end");
        _;
    }

    modifier allowDeclineEnding(uint256 contractId, address customer) {
        require((contractInfos[customer][contractId].isEndCustomer && !contractInfos[customer][contractId].isEndTalent), "GetdoneFreelanceContract: contract cannot decline ending");
        require((!contractInfos[customer][contractId].isEndCustomer && contractInfos[customer][contractId].isEndTalent), "GetdoneFreelanceContract: contract cannot decline ending");
        _;
    }

    modifier allowCreate(uint256 contractId, address customer) {
        require(isEnd(contractId, customer) == false, "GetdoneFreelanceContract: contract has been ended");
        _;
    }

    modifier allowCancel(uint256 contractId, uint256 milestoneId, address customer) {
        require(isEnd(contractId, customer) == false, "GetdoneFreelanceContract: contract has been ended");
        
        Milestone memory milestone = milestones[customer][contractId][milestoneId];
        require(milestone.status == MILESTONE_STATUS_NEW, "GetdoneFreelanceContract: Milestone does not allow to cancel");
        _;
    }

    modifier allowApprove(uint256 contractId, uint256 milestoneId, address customer) {
        require(isEnd(contractId, customer) == false, "GetdoneFreelanceContract: contract has been ended");
        
        Milestone memory milestone = milestones[customer][contractId][milestoneId];
        require(milestone.status == MILESTONE_STATUS_NEW, "GetdoneFreelanceContract: Milestone does not allow to approve");
        _;
    }

    modifier allowDecline(uint256 contractId, uint256 milestoneId, address customer) {
        require(isEnd(contractId, customer) == false, "GetdoneFreelanceContract: contract has been ended");
        
        Milestone memory milestone = milestones[customer][contractId][milestoneId];
        require(milestone.status == MILESTONE_STATUS_NEW, "GetdoneFreelanceContract: Milestone does not allow to decline");
        _;
    }

    modifier allowPay(uint256 contractId, uint256 milestoneId, address customer) {
        require(isEnd(contractId, customer) == false, "GetdoneFreelanceContract: contract has been ended");
        
        Milestone memory milestone = milestones[customer][contractId][milestoneId];
        require((milestone.status == MILESTONE_STATUS_APPROVED || milestone.status == MILESTONE_STATUS_DECLINE_PAYLESS), "GetdoneFreelanceContract: Milestone does not allow to pay");
        _;
    }

    modifier allowRequestPayLess(uint256 contractId, uint256 milestoneId, address customer) {
        require(isEnd(contractId, customer) == false, "GetdoneFreelanceContract: contract has been ended");
        
        Milestone memory milestone = milestones[customer][contractId][milestoneId];
        require((milestone.status == MILESTONE_STATUS_APPROVED || milestone.status == MILESTONE_STATUS_DECLINE_PAYLESS), "GetdoneFreelanceContract: Milestone does not allow to pay");
        _;
    }

    modifier allowPayLess(uint256 contractId, uint256 milestoneId, address customer) {
        require(isEnd(contractId, customer) == false, "GetdoneFreelanceContract: contract has been ended");
        
        Milestone memory milestone = milestones[customer][contractId][milestoneId];
        require(milestone.status == MILESTONE_STATUS_REQUEST_PAYLESS, "GetdoneFreelanceContract: Milestone does not allow to pay");
        _;
    }

    modifier allowDeclinePayLess(uint256 contractId, uint256 milestoneId, address customer) {
        require(isEnd(contractId, customer) == false, "GetdoneFreelanceContract: contract has been ended");
        
        Milestone memory milestone = milestones[customer][contractId][milestoneId];
        require(milestone.status == MILESTONE_STATUS_DECLINE_PAYLESS, "GetdoneFreelanceContract: Milestone does not allow to pay");
        _;
    }
    
    function setTransactionFeePercent(uint256 percent)
        public
        onlyOwner
    {
        require(percent <= ONE_HUNDRED_PERCENT, "GetdoneFreelanceContract: percent is invalid");

        transactionFeePercent = percent;

        emit TransactionFeePercentUpdated(percent);
    }

    function setAdminWallet(address wallet)
        public
        onlyOwner
    {
        require(wallet != address(0), "GetdoneFreelanceContract: address is invalid");

        adminWallet = wallet;

        emit AdminWalletUpdated(wallet);
    }
    
    function updateErc20Whitelist(address[] memory erc20s, bool status)
        public
        onlyOwner
    {
        uint256 length = erc20s.length;

        require(length > 0, "GetdoneFreelanceContract: erc20 list is required");

        for (uint256 i = 0; i < length; i++) {
            erc20Whitelist[erc20s[i]] = status;
        }

        emit Erc20WhitelistUpdated(erc20s, status);
    }

    function pause()
        public
        onlyOwner
    {
        _pause();
    }

    function unpause()
        public
        onlyOwner
    {
        _unpause();
    }

    function createMilestone(uint256 contractId, uint256 milestoneId, uint256 orderId, uint256 price, address erc20, address talent) 
        public
        payable
        whenNotPaused
        nonReentrant
        inWhitelist(erc20)
        allowCreate(contractId, _msgSender())
    {
        address customer = _msgSender();

        require(price > 0, "GetdoneFreelanceContract: price must be greater than 0");

        Milestone memory milestone = milestones[customer][contractId][milestoneId];
        ContractInfo memory contractInfo = contractInfos[customer][contractId];

        require(talent != address(0) && talent != customer, "GetdoneFreelanceContract: talent address is invalid");
        if (milestone.milestoneId == milestoneId) {
            require((milestone.status == MILESTONE_STATUS_CANCELLED || milestone.status == MILESTONE_STATUS_DECLINED), "GetdoneFreelanceContract: Can not update milestone");
        }

        if (contractInfo.init == true) {
            require(contractInfo.erc20 == erc20, "GetdoneFreelanceContract: Erc20 can not change");
        }

         if (erc20 == address(0)) {
            require(msg.value == price, "GetdoneFreelanceContract: deposit amount is not enough");
        } else {
            IERC20Upgradeable(erc20).safeTransferFrom(customer, address(this), price);
        }

        milestones[customer][contractId][milestoneId] = Milestone(contractId, milestoneId, orderId, talent, customer, price, 0, 0, 0, MILESTONE_STATUS_NEW);
        milestoneIds[customer][contractId].push(milestoneId);

        if (contractInfo.init == false) {
            contractInfos[customer][contractId] = ContractInfo(contractId, customer, talent, erc20, price, 0, 0, false, false, true);
        } else {
            contractInfos[customer][contractId].price = contractInfo.price + price;
        }
        
        emit MilestoneCreated(contractId, milestoneId, orderId, talent, customer, price, erc20, MILESTONE_STATUS_NEW);
    }

    function approveMilestone(uint256 contractId, uint256 milestoneId, address customer) 
        public
        whenNotPaused
        nonReentrant
        allowApprove(contractId, milestoneId, customer)
    {
        address talent = _msgSender();

        Milestone memory milestone = milestones[customer][contractId][milestoneId];
        ContractInfo memory contractInfo = contractInfos[customer][contractId];

        require(milestone.talent == talent, "GetdoneFreelanceContract: can not change milestone if sender is not a talent");
        
        milestones[customer][contractId][milestoneId].status = MILESTONE_STATUS_APPROVED;

        emit MilestoneApproved(contractId, milestoneId, milestone.talent, milestone.customer, milestone.price, contractInfo.erc20, MILESTONE_STATUS_APPROVED);
    }

    function declineMilestone(uint256 contractId, uint256 milestoneId, address customer) 
        public
        whenNotPaused
        nonReentrant
        allowDecline(contractId, milestoneId, customer)
    {
        address talent = _msgSender();

        Milestone memory milestone = milestones[customer][contractId][milestoneId];
        ContractInfo memory contractInfo = contractInfos[customer][contractId];

        require(milestone.talent == talent, "GetdoneFreelanceContract: can not change milestone if sender is not a talent");
        
        uint256 balance = milestone.price - milestone.paid - milestone.refund;

        require(milestone.customer == customer, "GetdoneFreelanceContract: can not change sale if sender has not made one");
        
        if (balance > 0) {
            if (contractInfo.erc20 == address(0)) {
                payable(milestone.customer).transfer(balance);
            } else {
                IERC20Upgradeable(contractInfo.erc20).safeTransfer(milestone.customer, balance);
            }
            milestones[customer][contractId][milestoneId].price = milestone.price - balance;
        }

        milestones[customer][contractId][milestoneId].status = MILESTONE_STATUS_DECLINED;

        emit MilestoneDeclined(contractId, milestoneId, milestone.talent, milestone.customer, milestone.price, contractInfo.erc20, MILESTONE_STATUS_APPROVED);
    }

    function cancelMilestone(uint256 contractId, uint256 milestoneId) 
        public
        whenNotPaused
        nonReentrant
        allowCancel(contractId, milestoneId, _msgSender())
    {
        address customer = _msgSender();

        Milestone memory milestone = milestones[customer][contractId][milestoneId];
        ContractInfo memory contractInfo = contractInfos[customer][contractId];
        uint256 balance = milestone.price - milestone.paid - milestone.refund;

        require(milestone.customer == customer, "GetdoneFreelanceContract: can not change sale if sender has not made one");
        
        if (balance > 0) {
            if (contractInfo.erc20 == address(0)) {
                payable(milestone.customer).transfer(balance);
            } else {
                IERC20Upgradeable(contractInfo.erc20).safeTransfer(milestone.customer, balance);
            }
            milestones[customer][contractId][milestoneId].refund = milestone.refund + balance;
        }

        milestones[customer][contractId][milestoneId].status = MILESTONE_STATUS_CANCELLED;
        emit MilestoneCancelled(contractId, milestoneId, milestone.talent, customer, milestone.price, contractInfo.erc20, MILESTONE_STATUS_CANCELLED);
    }

    function requestPayLessMilestone(uint256 contractId, uint256 milestoneId, uint256 price) 
        public
        whenNotPaused
        nonReentrant
        allowRequestPayLess(contractId, milestoneId, _msgSender())
    {
        address customer = _msgSender();
        ContractInfo memory contractInfo = contractInfos[customer][contractId];
        
        Milestone memory milestone = milestones[customer][contractId][milestoneId];
        require(milestone.customer == customer, "GetdoneFreelanceContract: can not change milestone if sender is not a talent");

        milestones[customer][contractId][milestoneId].status = MILESTONE_STATUS_REQUEST_PAYLESS;
        milestones[customer][contractId][milestoneId].payless = price;
        emit MilestoneRequestPaidLess(milestone.contractId, milestone.milestoneId, milestone.talent, milestone.customer, price, contractInfo.erc20, MILESTONE_STATUS_REQUEST_PAYLESS);
    }

    function payMilestone(uint256 contractId, uint256 milestoneId, uint256 price) 
        public
        whenNotPaused
        nonReentrant
        allowPay(contractId, milestoneId, _msgSender())
    {
        address customer = _msgSender();

        Milestone memory milestone = milestones[customer][contractId][milestoneId];
        ContractInfo memory contractInfo = contractInfos[customer][contractId];
        uint256 balance = milestone.price - milestone.paid - milestone.refund;

        require(milestone.customer == customer, "GetdoneFreelanceContract: can not change sale if sender has not made one");
        require(price > 0 && balance == price, "GetdoneFreelanceContract: price is invalid");
        _payout(contractId, milestoneId, milestone.talent, price, contractInfo.erc20);
        milestones[customer][contractId][milestoneId].paid = milestone.paid + price;
        contractInfos[customer][contractId].paid = contractInfo.paid + price;
        milestones[customer][contractId][milestoneId].status = MILESTONE_STATUS_PAID;

        uint256 fee = _calculateTransactionFee(price, transactionFeePercent);
        uint256 amount = price - fee;
        emit MilestonePaid(contractId, milestoneId, milestone.talent, customer, price, amount, fee, contractInfo.erc20, MILESTONE_STATUS_PAID);
    }

    function payLessMilestone(uint256 contractId, uint256 milestoneId, uint256 price, address customer) 
        public
        whenNotPaused
        nonReentrant
        allowPayLess(contractId, milestoneId, customer)
    {
        address talent = _msgSender();

        Milestone memory milestone = milestones[customer][contractId][milestoneId];
        ContractInfo memory contractInfo = contractInfos[customer][contractId];
        uint256 balance = milestone.price - milestone.paid - milestone.refund;

        require(milestone.talent == talent, "GetdoneFreelanceContract: can not change milestone if sender is not a talent");
        require(price > 0 && balance >= price, "GetdoneFreelanceContract: price is invalid");

        // pay to talent
        _payout(contractId, milestoneId, milestone.talent, price, contractInfo.erc20);

        // refund to customer
        uint256 remain = balance - price;
        if (remain > 0) {
            if (contractInfo.erc20 == address(0)) {
                payable(milestone.customer).transfer(remain);
            } else {
                IERC20Upgradeable(contractInfo.erc20).safeTransfer(milestone.customer, remain);
            }
            milestones[customer][contractId][milestoneId].refund = milestone.refund + remain;
        }

        milestones[customer][contractId][milestoneId].paid = milestone.paid + price;
        contractInfos[customer][contractId].paid = contractInfo.paid + price;
        milestones[customer][contractId][milestoneId].status = MILESTONE_STATUS_PAID;
        
        uint256 fee = _calculateTransactionFee(price, transactionFeePercent);
        uint256 amount = price - fee;
        uint256 total_amount = price;
        emit MilestonePaidLess(milestone.contractId, milestone.milestoneId, milestone.talent, milestone.customer, total_amount, amount, fee, contractInfo.erc20, MILESTONE_STATUS_PAID);
    }

    function declinePayLessMilestone(uint256 contractId, uint256 milestoneId, address customer) 
        public
        whenNotPaused
        nonReentrant
        allowDeclinePayLess(contractId, milestoneId, customer)
    {
        address talent = _msgSender();
        ContractInfo memory contractInfo = contractInfos[customer][contractId];
        
        Milestone memory milestone = milestones[customer][contractId][milestoneId];
        require(milestone.talent == talent, "GetdoneFreelanceContract: can not change milestone if sender is not a talent");

        milestones[customer][contractId][milestoneId].status = MILESTONE_STATUS_DECLINE_PAYLESS;
        emit MilestonePaidLessDeclined(milestone.contractId, milestone.milestoneId, milestone.talent, milestone.customer, milestone.payless, contractInfo.erc20, MILESTONE_STATUS_DECLINE_PAYLESS);
    }

    function endContract(uint256 contractId, address customer) 
        public
        whenNotPaused
        nonReentrant
        allowEnd(contractId, customer)
    {
        address sender = _msgSender();
        ContractInfo memory contractInfo = contractInfos[customer][contractId];
        uint256 length = milestoneIds[customer][contractId].length;

        require((contractInfo.customer == sender || contractInfo.talent == sender ), "GetdoneFreelanceContract: can not change contract if sender has not made one");

        if(!contractInfo.isEndCustomer && !contractInfo.isEndTalent) {
            if (contractInfo.customer == sender) {
                contractInfos[customer][contractId].isEndCustomer = true;
                emit ContractEnded(contractId, sender, 0, contractInfo.erc20, false, true);
            } else if (contractInfo.talent == sender) {
                contractInfos[customer][contractId].isEndTalent = true;
                emit ContractEnded(contractId, sender, 0, contractInfo.erc20, true, false);
            }
        } else {

            uint256 amountRefund = 0;
            if (length > 0) {
                for (uint256 i = 0; i < length; i++) {
                    uint256 milestoneId = milestoneIds[customer][contractId][i];
                    Milestone memory milestone = milestones[customer][contractId][milestoneId];
                    uint256 balance = milestone.price - milestone.paid - milestone.refund;
                    if (balance > 0) {
                        amountRefund += balance;
                        milestones[customer][milestone.contractId][milestoneId].refund = milestone.refund + balance;
                    }
                }
            }

            uint256 contractBalance = contractInfo.price - contractInfo.paid - contractInfo.refund;
            contractInfos[customer][contractId].isEndCustomer = true;
            contractInfos[customer][contractId].isEndTalent = true;
            if (amountRefund > 0 && amountRefund <= contractBalance) {
                contractInfos[customer][contractId].refund = contractInfo.refund + amountRefund;
                if (contractInfo.erc20 == address(0)) {
                    payable(customer).transfer(amountRefund);
                } else {
                    IERC20Upgradeable(contractInfo.erc20).safeTransfer(customer, amountRefund);
                }
            }
            emit ContractEnded(contractId, sender, amountRefund, contractInfo.erc20, true, true);
        }
    }

    function declineEndContract(uint256 contractId, address customer) 
        public
        whenNotPaused
        nonReentrant
        allowDeclineEnding(contractId, customer)
    {
        address sender = _msgSender();
        ContractInfo memory contractInfo = contractInfos[customer][contractId];

        require((contractInfo.customer == sender || contractInfo.talent == sender ), "GetdoneFreelanceContract: can not change contract if sender has not made one");

        contractInfos[customer][contractId].isEndCustomer = false;
        contractInfos[customer][contractId].isEndTalent = false;

        emit ContractEndingDeclined(contractId, sender, 0, contractInfo.erc20, false, false);
    }

    function forceEndContract(uint256 contractId, address customer) 
        external
        onlyOwner
    {
        require(isEnd(contractId, customer) == false, "GetdoneFreelanceContract: contract has been ended");

        ContractInfo memory contractInfo = contractInfos[customer][contractId];
        uint256 length = milestoneIds[customer][contractId].length;
        uint256 amountRefund = 0;
        if (length > 0) {
            for (uint256 i = 0; i < length; i++) {
                uint256 milestoneId = milestoneIds[customer][contractId][i];
                Milestone memory milestone = milestones[customer][contractId][milestoneId];
                uint256 balance = milestone.price - milestone.paid - milestone.refund;
                if (balance > 0) {
                    amountRefund += balance;
                    milestones[customer][contractId][milestoneId].refund = milestone.refund + balance;
                }
            }
        }

        uint256 contractBalance = contractInfo.price - contractInfo.paid - contractInfo.refund;
        contractInfos[customer][contractId].isEndCustomer = true;
        contractInfos[customer][contractId].isEndTalent = true;
        if (amountRefund > 0 && amountRefund <= contractBalance) {
            contractInfos[customer][contractId].refund = contractInfo.refund + amountRefund;
            if (contractInfo.erc20 == address(0)) {
                payable(adminWallet).transfer(amountRefund);
            } else {
                IERC20Upgradeable(contractInfo.erc20).safeTransfer(adminWallet, amountRefund);
            }
        }
        emit ContractForceEnded(contractId, _msgSender(), amountRefund, contractInfo.erc20, true, true);
    }

    function _payout(uint256 contractId, uint256 milestoneId, address receiver, uint256 price, address erc20)
        internal
    {
        uint256 fee = _calculateTransactionFee(price, transactionFeePercent);

        uint256 amount = price - fee;

        if (erc20 == address(0)) {
            if (fee > 0) {
                payable(adminWallet).transfer(fee);
            }

            if (amount > 0) {
                payable(receiver).transfer(amount);
            }

        } else {
            if (fee > 0) {
                IERC20Upgradeable(erc20).safeTransfer(adminWallet, fee);
            }

            if (amount > 0) {
                IERC20Upgradeable(erc20).safeTransfer(receiver, amount);
            }
        }

        emit Payout(contractId, milestoneId, amount, fee, erc20, receiver);
    }

    function _calculateTransactionFee(uint256 price, uint256 feePercent)
        internal
        pure
        returns (uint256)
    {
        return price * feePercent / ONE_HUNDRED_PERCENT;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/ContextUpgradeable.sol";
import "../proxy/utils/Initializable.sol";

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
abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    function __Ownable_init() internal onlyInitializing {
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal onlyInitializing {
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

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (security/Pausable.sol)

pragma solidity ^0.8.0;

import "../utils/ContextUpgradeable.sol";
import "../proxy/utils/Initializable.sol";

/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract PausableUpgradeable is Initializable, ContextUpgradeable {
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state.
     */
    function __Pausable_init() internal onlyInitializing {
        __Pausable_init_unchained();
    }

    function __Pausable_init_unchained() internal onlyInitializing {
        _paused = false;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
        _;
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;
import "../proxy/utils/Initializable.sol";

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
abstract contract ReentrancyGuardUpgradeable is Initializable {
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

    function __ReentrancyGuard_init() internal onlyInitializing {
        __ReentrancyGuard_init_unchained();
    }

    function __ReentrancyGuard_init_unchained() internal onlyInitializing {
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

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20Upgradeable {
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
// OpenZeppelin Contracts v4.4.1 (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

import "../IERC20Upgradeable.sol";
import "../../../utils/AddressUpgradeable.sol";

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20Upgradeable {
    using AddressUpgradeable for address;

    function safeTransfer(
        IERC20Upgradeable token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20Upgradeable token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IERC20Upgradeable token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20Upgradeable token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20Upgradeable token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20Upgradeable token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;
import "../proxy/utils/Initializable.sol";

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
abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal onlyInitializing {
    }

    function __Context_init_unchained() internal onlyInitializing {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (proxy/utils/Initializable.sol)

pragma solidity ^0.8.0;

import "../../utils/AddressUpgradeable.sol";

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since proxied contracts do not make use of a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {ERC1967Proxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 *
 * [CAUTION]
 * ====
 * Avoid leaving a contract uninitialized.
 *
 * An uninitialized contract can be taken over by an attacker. This applies to both a proxy and its implementation
 * contract, which may impact the proxy. To initialize the implementation contract, you can either invoke the
 * initializer manually, or you can include a constructor to automatically mark it as initialized when it is deployed:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * /// @custom:oz-upgrades-unsafe-allow constructor
 * constructor() initializer {}
 * ```
 * ====
 */
abstract contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     */
    bool private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Modifier to protect an initializer function from being invoked twice.
     */
    modifier initializer() {
        // If the contract is initializing we ignore whether _initialized is set in order to support multiple
        // inheritance patterns, but we only do this in the context of a constructor, because in other contexts the
        // contract may have been reentered.
        require(_initializing ? _isConstructor() : !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }

    /**
     * @dev Modifier to protect an initialization function so that it can only be invoked by functions with the
     * {initializer} modifier, directly or indirectly.
     */
    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    function _isConstructor() private view returns (bool) {
        return !AddressUpgradeable.isContract(address(this));
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (utils/Address.sol)

pragma solidity ^0.8.1;

/**
 * @dev Collection of functions related to the address type
 */
library AddressUpgradeable {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}