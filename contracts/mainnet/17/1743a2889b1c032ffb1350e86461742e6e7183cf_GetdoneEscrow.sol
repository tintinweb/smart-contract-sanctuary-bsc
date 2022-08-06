// contracts/GetdoneEscrow.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";


contract GetdoneEscrow is OwnableUpgradeable, PausableUpgradeable, ReentrancyGuardUpgradeable{
    using SafeERC20Upgradeable for IERC20Upgradeable;

    uint256 constant public MERCHANT_ID_GETDONE = 1;

    uint256 constant public CONTRACT_STATUS_NEW = 0;
    uint256 constant public CONTRACT_STATUS_PROCESSING = 1;
    uint256 constant public CONTRACT_STATUS_ENDED = 2;
    uint256 constant public CONTRACT_STATUS_WITHDRAWN = 3;

    uint256 constant public MILESTONE_STATUS_NEW = 0;
    uint256 constant public MILESTONE_STATUS_CREATED = 1;
    uint256 constant public MILESTONE_STATUS_APPROVED = 2;
    uint256 constant public MILESTONE_STATUS_DECLINED = 3;
    uint256 constant public MILESTONE_STATUS_PAID = 4;
    uint256 constant public MILESTONE_STATUS_REQUEST_PAYLESS = 5;
    uint256 constant public MILESTONE_STATUS_DECLINE_PAYLESS = 6;
    uint256 constant public ONE_HUNDRED_PERCENT = 10000; // 100%

    event Erc20WhitelistUpdated(uint256 merchantId, address[] erc20s, bool status);
    event ApplistUpdated(uint256 merchantId, uint256[] appIds, address admin, address treasury);
    event TransactionFeePercentUpdated(uint256 merchantId, uint256 appId, uint256 percent);
    event MerchantUpdated(uint256 merchantId, address admin, address treasury);
    event MilestoneCreated(uint256 merchantId, uint256 appId, uint256 contractId, uint256 milestoneId, uint256 orderId, address talent, address customer, uint256 price, uint256 contractPay, address erc20, uint256 status);
    event MilestoneCancelled(uint256 merchantId, uint256 appId, uint256 contractId, uint256 milestoneId, address talent, address customer, uint256 price, address erc20, uint256 status);
    event MilestoneApproved(uint256 merchantId, uint256 appId, uint256 contractId, uint256 milestoneId, address talent, address customer, uint256 price, address erc20, uint256 status);
    event MilestoneDeclined(uint256 merchantId, uint256 appId, uint256 contractId, uint256 milestoneId, address talent, address customer, uint256 price, address erc20, uint256 status);
    event MilestoneRequestPaidLess(uint256 merchantId, uint256 appId, uint256 contractId, uint256 milestoneId, address talent, address customer, uint256 price, address erc20, uint256 status);
    event MilestonePaidLessDeclined(uint256 merchantId, uint256 appId, uint256 contractId, uint256 milestoneId, address talent, address customer, uint256 price, address erc20, uint256 status);
    event MilestonePaid(uint256 merchantId, uint256 appId, uint256 contractId, uint256 milestoneId, address talent, address customer, uint256 price, uint256 amount, uint256 fee, address erc20, uint256 status);
    event MilestonePaidLess(uint256 merchantId, uint256 appId, uint256 contractId, uint256 milestoneId, address talent, address customer, uint256 price, uint256 amount, uint256 fee, address erc20, uint256 status);
    event ContractDeposited(uint256 merchantId, uint256 appId, uint256 contractId, uint256 orderId, address customer, uint256 price, address erc20);
    event ContractReceived(uint256 merchantId, uint256 appId, uint256 contractId, address sender, uint256 price, address erc20);
    event ContractPay(uint256 merchantId, uint256 appId, uint256 contractId, address customer, uint256 price, address erc20);
    event ContractEnded(uint256 merchantId, uint256 appId, uint256 contractId, address sender, uint256 refund, address erc20, bool isEndTalent, bool isEndCustomer);
    event ContractEndingDeclined(uint256 merchantId, uint256 appId, uint256 contractId, address sender, uint256 refund, address erc20, bool isEndTalent, bool isEndCustomer);
    event ContractDisputationCreated(uint256 merchantId, uint256 appId, uint256 contractId, address sender, address owner, bool isTalentVoted, bool isCustomerVoted, uint256 expireAt);
    event ContractDisputationVoted(uint256 merchantId, uint256 appId, uint256 contractId, address sender, address owner, bool isTalentVoted, bool isCustomerVoted, uint256 expireAt);
    event ContractDisputationProcessed(uint256 merchantId, uint256 appId, uint256 contractId, address sender, uint256 amount, address erc20, bool isTalentVoted, bool isCustomerVoted, uint256 expireAt);
    event ContractWithdrawn(uint256 merchantId, uint256 appId, uint256 contractId, address customer, uint256 refund, address erc20);
    event Payout(uint256 merchantId, uint256 appId, uint256 contractId, uint256 milestoneId, uint256 amount, uint256 fee, address erc20, address receiver);

    uint256 public minDisputationTime;

    struct Milestone {
        uint256 milestoneId;
        uint256 orderId;
        uint256 price;
        uint256 payless;
        uint256 paid;
        uint256 refund;
        uint256 status;
    }

    struct MilestoneClientInput {
        uint256 milestoneId;
        address talent;
        uint256 price;
        address erc20;
        uint256 orderId;
    }
    struct MilestoneTalentInput {
        uint256 milestoneId;
        address customer;
        uint256 price;
    }
    struct ContractDepositInput {
        uint256 price;
        address erc20;
        address talent;
        uint256 orderId;
    }

    struct ContractInfo {
        uint256 merchantId;
        uint256 appId;
        uint256 contractId;
        address customer;
        address talent;
        address erc20;
        uint256 price;
        uint256 deposit;
        uint256 paid;
        uint256 refund;
        uint256 status;
        uint256[] milestoneIds;
        bool isEndTalent;
        bool isEndCustomer;
        bool init;
    }

    struct ContractDisputation {
        uint256 contractId;
        bool isTalentVoted;
        bool isCustomerVoted;
        bool isProcessed;
        uint256 expireAt;
        address owner;
    }

    struct AdminWallet {
        address admin;
        address treasury;
    }

    // merchantId => AdminWallet
    mapping(uint256 => AdminWallet) public merchants;
    // merchantId => appId => AdminWallet
    mapping(uint256 => mapping(uint256 => AdminWallet)) public apps;
    // merchantId => appId => feeInPercent
    mapping(uint256 => mapping(uint256 => uint256)) public appFees;
    // merchantId => erc20Address => status
    mapping(uint256 => mapping(address => bool)) public erc20Whitelist;

    // merchantId => appId => customer => contractId => milestoneId => Milestone
    mapping(uint256 => mapping(uint256 => mapping(address => mapping(uint256 => mapping(uint256 => Milestone))))) public milestones;
    // merchantId => appId =>  customer => contractId => ContractInfo
    mapping(uint256 => mapping(uint256 => mapping(address => mapping(uint256 => ContractInfo)))) public contractInfos;

    // merchantId => appId => customer => contractId => ContractDisputation
    mapping(uint256 => mapping(uint256 => mapping(address => mapping(uint256 => ContractDisputation)))) public contractDisputations;
    
    address public defaultAdminWallet;

    function initialize()
        public
        initializer
    {
        __Ownable_init();
        __Pausable_init();
        __ReentrancyGuard_init();

        defaultAdminWallet = _msgSender();

        merchants[MERCHANT_ID_GETDONE].admin = defaultAdminWallet;
        merchants[MERCHANT_ID_GETDONE].treasury = defaultAdminWallet;
        minDisputationTime = 7 days;
    }


    function isEnd(uint256 merchantId, uint256 appId, uint256 contractId, address customer)
        internal
        view
        returns (bool)
    {
        return contractInfos[merchantId][appId][customer][contractId].isEndCustomer || contractInfos[merchantId][appId][customer][contractId].isEndTalent;
    }

    function isDisputation(uint256 merchantId, uint256 appId, uint256 contractId, address customer)
        internal
        view
        returns (bool)
    {
        return contractDisputations[merchantId][appId][customer][contractId].isCustomerVoted || contractDisputations[merchantId][appId][customer][contractId].isTalentVoted;
    }

    function validMerchant(uint256 merchantId) internal view returns (bool) {
        return merchants[merchantId].admin != address(0);
    }

    function validApp(uint256 merchantId, uint256 appId) internal view returns (bool) {
        return validMerchant(merchantId) && apps[merchantId][appId].admin != address(0);
    }

    function adminWallet(uint256 merchantId, uint256 appId) internal view returns(address) {
        return appId != 0 && apps[merchantId][appId].admin != address(0) ? apps[merchantId][appId].admin : merchants[merchantId].admin;
    }

    function treasuryWallet(uint256 merchantId, uint256 appId) internal view returns(address) {
        return appId != 0 && apps[merchantId][appId].treasury != address(0) ? apps[merchantId][appId].treasury : merchants[merchantId].treasury;
    }

    function setTransactionFeePercent(uint256 merchantId, uint256 appId, uint256 percent)
        public
    {
        require(adminWallet(merchantId, appId) == _msgSender(), "GetdoneEscrow: caller is not the admin");
        require(percent <= ONE_HUNDRED_PERCENT, "GetdoneEscrow: percent is invalid");
        require(validMerchant(merchantId), "GetdoneEscrow: Merchant is invalid");
        require(validApp(merchantId, appId), "GetdoneEscrow: App is invalid");

        appFees[merchantId][appId] = percent;

        emit TransactionFeePercentUpdated(merchantId, appId, percent);
    }

    function updateMerchant(uint256 merchantId, address admin, address treasury)
        public
        onlyOwner
    {
        require((admin != address(0) && treasury != address(0)), "GetdoneEscrow: address is invalid");

        merchants[merchantId].admin = admin;
        merchants[merchantId].treasury = treasury;

        emit MerchantUpdated(merchantId, admin, treasury);
    }

    function updateApp(uint256 merchantId, uint256[] memory appIds, address admin, address treasury)
        public
    {
        require(adminWallet(merchantId, 0) == _msgSender(), "GetdoneEscrow: caller is not the admin");
        require(validMerchant(merchantId), "GetdoneEscrow: Merchant is invalid");

        uint256 length = appIds.length;

        require(length > 0, "GetdoneEscrow: App list is required");

        for (uint256 i = 0; i < length; i++) {
            apps[merchantId][appIds[i]].admin = admin;
            apps[merchantId][appIds[i]].treasury = treasury;
        }
        emit ApplistUpdated(merchantId, appIds, admin, treasury);
    }
    
    function updateErc20Whitelist(uint256 merchantId, address[] memory erc20s, bool status)
        public
    {
        require(adminWallet(merchantId, 0) == _msgSender(), "GetdoneEscrow: caller is not the admin");
        require(validMerchant(merchantId), "GetdoneEscrow: Merchant is invalid");

        uint256 length = erc20s.length;

        require(length > 0, "GetdoneEscrow: erc20 list is required");

        for (uint256 i = 0; i < length; i++) {
            erc20Whitelist[merchantId][erc20s[i]] = status;
        }

        emit Erc20WhitelistUpdated(merchantId, erc20s, status);
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

    function updateMilestoneBalance(uint256 merchantId, uint256 appId, address customer, uint256 contractId) 
        internal
        returns (uint256)
    {
        uint256 amountRefund;
        ContractInfo memory contractInfo = contractInfos[merchantId][appId][customer][contractId];
        uint256 length = contractInfo.milestoneIds.length;
        if (length > 0) {
            for (uint256 i = 0; i < length; i++) {
                uint256 milestoneId = contractInfo.milestoneIds[i];
                Milestone storage milestone = milestones[contractInfo.merchantId][contractInfo.appId][contractInfo.customer][contractInfo.contractId][milestoneId];
                uint256 balance = milestone.price - milestone.paid - milestone.refund;
                if (balance > 0) {
                    amountRefund += balance;
                    milestone.refund = milestone.refund + balance;
                }
            }
        }
        return amountRefund;
    }

    function createMilestone(uint256 merchantId, uint256 appId, uint256 contractId, MilestoneClientInput memory input) 
        public
        payable
        whenNotPaused
        nonReentrant
    {
        require(erc20Whitelist[merchantId][input.erc20], "GetdoneEscrow: erc20 must be in whitelist");
        require(validApp(merchantId, appId), "GetdoneEscrow: App is invalid");
        require(isEnd(merchantId, appId, contractId, _msgSender()) == false, "GetdoneEscrow: contract has been ended");
        require(isDisputation(merchantId, appId, contractId, _msgSender()) == false, "GetdoneEscrow: contract has disputation");
        require(input.price > 0, "GetdoneEscrow: price must be greater than 0");

        Milestone storage milestone = milestones[merchantId][appId][_msgSender()][contractId][input.milestoneId];
        ContractInfo storage contractInfo = contractInfos[merchantId][appId][_msgSender()][contractId];

        require(input.talent != address(0) && input.talent != _msgSender(), "GetdoneEscrow: talent address is invalid");
        if (milestone.milestoneId == input.milestoneId) {
            require((milestone.status == MILESTONE_STATUS_DECLINED), "GetdoneEscrow: Can not update milestone");
        }

        if (contractInfo.init == true) {
            require(contractInfo.erc20 == input.erc20, "GetdoneEscrow: Erc20 can not change");
            require(contractInfo.customer == _msgSender(), "GetdoneEscrow: can not change sale if sender has not made one");
        }

        uint256 amountPay = contractInfo.init == true && contractInfo.deposit > 0 ? (contractInfo.deposit >= input.price ? 0 : input.price - contractInfo.deposit) : input.price;
        
        if (amountPay > 0) {
            if (input.erc20 == address(0)) {
                require(msg.value == amountPay, "GetdoneEscrow: deposit amount is not enough");
            } else {
                uint256 a = amountPay;
                address erc20 = input.erc20;
                IERC20Upgradeable(erc20).safeTransferFrom(_msgSender(), address(this), a);
            }
        }

        uint256 amountContractPay = contractInfo.init == true && contractInfo.deposit > 0 ? (contractInfo.deposit >= input.price ? input.price : contractInfo.deposit) : 0;

        if (contractInfo.init == false) {
            contractInfo.merchantId = merchantId;
            contractInfo.appId = appId;
            contractInfo.contractId = contractId;
            contractInfo.customer = _msgSender();
            contractInfo.talent = input.talent;
            contractInfo.erc20 = input.erc20;
            contractInfo.price = input.price;
            contractInfo.deposit = 0;
            contractInfo.paid = 0;
            contractInfo.refund = 0;
            contractInfo.isEndTalent = false;
            contractInfo.isEndCustomer = false;
            contractInfo.init = true;
            contractInfo.status = CONTRACT_STATUS_PROCESSING;
            contractInfo.milestoneIds.push(input.milestoneId);
        } else {
            contractInfo.status = CONTRACT_STATUS_PROCESSING;
            if (milestone.milestoneId == 0) {
                contractInfo.milestoneIds.push(input.milestoneId);
            }
            contractInfo.price = contractInfo.price + input.price;
            if (contractInfo.talent == address(0)) {
                contractInfo.talent = input.talent;
            }
            if (amountContractPay > 0) {
                contractInfo.deposit = contractInfo.deposit - amountContractPay;
            }
        }

        milestone.milestoneId = input.milestoneId;
        milestone.orderId = input.orderId;
        milestone.price = input.price;
        milestone.payless = 0;
        milestone.paid = 0;
        milestone.refund = 0;
        milestone.status = MILESTONE_STATUS_CREATED;

        emit MilestoneCreated(merchantId, appId, contractInfo.contractId, milestone.milestoneId, milestone.orderId, contractInfo.talent, contractInfo.customer, amountPay, amountContractPay, contractInfo.erc20, milestone.status);
    }
    
    function approveMilestone(uint256 merchantId, uint256 appId, uint256 contractId, bool isAccept, MilestoneTalentInput memory input) 
        public
        whenNotPaused
        nonReentrant
    {
        address talent = _msgSender();
        require(validApp(merchantId, appId), "GetdoneEscrow: App is invalid");
        require(isEnd(merchantId, appId, contractId, input.customer) == false, "GetdoneEscrow: contract has been ended");
        require(isDisputation(merchantId, appId, contractId, input.customer) == false, "GetdoneEscrow: contract has disputation");
        

        Milestone storage milestone = milestones[merchantId][appId][input.customer][contractId][input.milestoneId];
        ContractInfo memory contractInfo = contractInfos[merchantId][appId][input.customer][contractId];
        require(milestone.status == MILESTONE_STATUS_CREATED, "GetdoneEscrow: Milestone does not allow to approve");
        require(contractInfo.talent == talent, "GetdoneEscrow: can not change milestone if sender is not a talent");
        
        if (isAccept) {
            milestone.status = MILESTONE_STATUS_APPROVED;
            emit MilestoneApproved(contractInfo.merchantId, contractInfo.appId, contractInfo.contractId, milestone.milestoneId, contractInfo.talent, contractInfo.customer, milestone.price, contractInfo.erc20, MILESTONE_STATUS_APPROVED);
        } else { 
            uint256 balance = milestone.price - milestone.paid - milestone.refund;

            if (balance > 0) {
                milestone.price = milestone.price - balance;
                contractInfo.deposit = contractInfo.deposit + balance;
                contractInfo.price = contractInfo.price - balance;
                emit ContractReceived(merchantId, appId, contractId, talent, balance, contractInfo.erc20);
            }

            milestone.status = MILESTONE_STATUS_DECLINED;

            emit MilestoneDeclined(contractInfo.merchantId, contractInfo.appId, contractInfo.contractId, milestone.milestoneId, contractInfo.talent, contractInfo.customer, milestone.price, contractInfo.erc20, MILESTONE_STATUS_APPROVED);
        }
    }

    function requestPayLessMilestone(uint256 merchantId, uint256 appId, uint256 contractId, MilestoneClientInput memory input) 
        public
        whenNotPaused
        nonReentrant
    {
        address customer = _msgSender();
        require(validApp(merchantId, appId), "GetdoneEscrow: App is invalid");
        require(isEnd(merchantId, appId, contractId, _msgSender()) == false, "GetdoneEscrow: contract has been ended");
        require(isDisputation(merchantId, appId, contractId, customer) == false, "GetdoneEscrow: contract has disputation");
        
        ContractInfo memory contractInfo = contractInfos[merchantId][appId][customer][contractId];
        Milestone storage milestone = milestones[merchantId][appId][customer][contractId][input.milestoneId];
        require((milestone.status == MILESTONE_STATUS_APPROVED || milestone.status == MILESTONE_STATUS_DECLINE_PAYLESS), "GetdoneEscrow: Milestone does not allow to pay");
        uint256 balance = milestone.price - milestone.paid - milestone.refund;

        require(contractInfo.customer == customer, "GetdoneEscrow: can not change milestone if sender is not a talent");
        require(input.price > 0 && balance > input.price, "GetdoneEscrow: price is invalid");

        milestone.status = MILESTONE_STATUS_REQUEST_PAYLESS;
        milestone.payless = input.price;
        emit MilestoneRequestPaidLess(merchantId, appId, contractId, input.milestoneId, contractInfo.talent, contractInfo.customer, milestone.payless, contractInfo.erc20, milestone.status);
    }

    function payMilestone(uint256 merchantId, uint256 appId, uint256 contractId, MilestoneClientInput memory input) 
        public
        whenNotPaused
        nonReentrant
    {
        address customer = _msgSender();
        uint256 fee = appFees[merchantId][appId];

        require(validApp(merchantId, appId), "GetdoneEscrow: App is invalid");
        require(isEnd(merchantId, appId, contractId, customer) == false, "GetdoneEscrow: contract has been ended");
        require(isDisputation(merchantId, appId, contractId, customer) == false, "GetdoneEscrow: contract has disputation");

        ContractInfo storage contractInfo = contractInfos[merchantId][appId][customer][contractId];
        Milestone storage milestone = milestones[merchantId][appId][customer][contractId][input.milestoneId];
        require((milestone.status == MILESTONE_STATUS_APPROVED || milestone.status == MILESTONE_STATUS_DECLINE_PAYLESS), "GetdoneEscrow: Milestone does not allow to pay");
        
        uint256 balance = milestone.price - milestone.paid - milestone.refund;

        require(contractInfo.customer == customer, "GetdoneEscrow: can not change sale if sender has not made one");
        require(input.price > 0 && balance == input.price, "GetdoneEscrow: price is invalid");

        _payout(merchantId, appId, contractInfo.contractId, milestone.milestoneId, contractInfo.talent, balance, contractInfo.erc20);

        milestone.paid = milestone.paid + balance;
        contractInfo.paid = contractInfo.paid + balance;
        milestone.status = MILESTONE_STATUS_PAID;

        uint256 feeAmount = balance * fee / ONE_HUNDRED_PERCENT;
        uint256 amount = balance - feeAmount;
        emit MilestonePaid(contractInfo.merchantId, contractInfo.appId, contractInfo.contractId, milestone.milestoneId, contractInfo.talent, customer, balance, amount, feeAmount, contractInfo.erc20, MILESTONE_STATUS_PAID);
    }

    function approvePayLessMilestone(uint256 merchantId, uint256 appId, uint256 contractId, bool isAccept, MilestoneTalentInput memory input) 
        public
        whenNotPaused
        nonReentrant
    {
        uint256 fee = appFees[merchantId][appId];
        address talent = _msgSender();
        require(validApp(merchantId, appId), "GetdoneEscrow: App is invalid");
        require(isEnd(merchantId, appId, contractId, input.customer) == false, "GetdoneEscrow: contract has been ended");
        require(isDisputation(merchantId, appId, contractId, input.customer) == false, "GetdoneEscrow: contract has disputation");
        
        ContractInfo storage contractInfo = contractInfos[merchantId][appId][input.customer][contractId];
        Milestone storage milestone = milestones[merchantId][appId][input.customer][contractId][input.milestoneId];
        require(milestone.status == MILESTONE_STATUS_REQUEST_PAYLESS, "GetdoneEscrow: Milestone does not allow to pay");
        require(contractInfo.talent == talent, "GetdoneEscrow: can not change milestone if sender is not a talent");

        if (isAccept) {
            uint256 balance = milestone.price - milestone.paid - milestone.refund;
            require(input.price > 0 && milestone.payless == input.price, "GetdoneEscrow: price is invalid");

            // pay to talent
            _payout(merchantId, appId, contractId, milestone.milestoneId, contractInfo.talent, milestone.payless, contractInfo.erc20);

            milestone.paid = milestone.paid + milestone.payless;
            contractInfo.paid = contractInfo.paid + milestone.payless;
            milestone.status = MILESTONE_STATUS_PAID;

            // refund to customer
            uint256 refund = balance - milestone.payless;
            if (refund > 0) {
                milestone.refund = milestone.refund + refund;
                contractInfo.deposit = contractInfo.deposit + refund;
                contractInfo.price = contractInfo.price - refund;
            }
            
            uint256 feeAmount = milestone.payless * fee / ONE_HUNDRED_PERCENT;
            emit MilestonePaidLess(contractInfo.merchantId, contractInfo.appId, contractInfo.contractId, milestone.milestoneId, contractInfo.talent, contractInfo.customer, milestone.payless, milestone.payless - feeAmount, feeAmount, contractInfo.erc20, MILESTONE_STATUS_PAID);
            if (refund > 0) {
                emit ContractReceived(contractInfo.merchantId, contractInfo.appId, contractInfo.contractId, contractInfo.talent, refund, contractInfo.erc20);
            }
        } else{
            milestone.status = MILESTONE_STATUS_DECLINE_PAYLESS;
            emit MilestonePaidLessDeclined(contractInfo.merchantId, contractInfo.appId, contractInfo.contractId, milestone.milestoneId, contractInfo.talent, contractInfo.customer, milestone.payless, contractInfo.erc20, MILESTONE_STATUS_DECLINE_PAYLESS);
        }
        
    }

    function endContract(uint256 merchantId, uint256 appId, uint256 contractId, address customer) 
        public
        whenNotPaused
        nonReentrant
    {
        address sender = _msgSender();
        ContractInfo storage contractInfo = contractInfos[merchantId][appId][customer][contractId];

        require((contractInfo.customer == sender || contractInfo.talent == sender ), "GetdoneEscrow: can not change contract if sender has not made one");

        require(isDisputation(merchantId, appId, contractId, customer) == false, "GetdoneEscrow: contract has disputation");
        require(validApp(merchantId, appId), "GetdoneEscrow: App is invalid");
        require((!contractInfo.isEndCustomer || !contractInfo.isEndTalent), "GetdoneEscrow: contract cannot end");
        
        uint256 length = contractInfo.milestoneIds.length;
        bool allow = true;

        if (length > 0) {
            for (uint256 i = 0; i < length; i++) {
                uint256 milestoneId = contractInfo.milestoneIds[i];
                Milestone memory milestone = milestones[merchantId][appId][customer][contractId][milestoneId];
                if (milestone.status == MILESTONE_STATUS_CREATED || milestone.status == MILESTONE_STATUS_REQUEST_PAYLESS) {
                    allow = false;
                    break;
                }
            }
        }
        require(allow == true, "GetdoneEscrow: contract does not allow to end");

        bool isTalent = contractInfo.talent == sender;
        bool isCustomer = contractInfo.customer == sender;

        if(!contractInfo.isEndCustomer && !contractInfo.isEndTalent) {
            if (isCustomer) {
                contractInfo.isEndCustomer = true;
                emit ContractEnded(contractInfo.merchantId, contractInfo.appId, contractInfo.contractId, sender, 0, contractInfo.erc20, false, true);
            } else if (isTalent) {
                contractInfo.isEndTalent = true;
                emit ContractEnded(contractInfo.merchantId, contractInfo.appId, contractInfo.contractId, sender, 0, contractInfo.erc20, true, false);
            }
        } else {
            require(((isTalent && !contractInfo.isEndTalent ) || (isCustomer && !contractInfo.isEndCustomer )), "GetdoneEscrow: Contract is already end");
            uint256 amountRefund = contractInfo.deposit;
            uint256 contractBalance = contractInfo.deposit + contractInfo.price - contractInfo.paid - contractInfo.refund;
            amountRefund = amountRefund + updateMilestoneBalance(contractInfo.merchantId, contractInfo.appId, contractInfo.customer, contractInfo.contractId);

            contractInfo.isEndCustomer = true;
            contractInfo.isEndTalent = true;
            contractInfo.deposit = 0;
            contractInfo.status = CONTRACT_STATUS_ENDED;
            if (amountRefund > 0 && amountRefund <= contractBalance) {
                contractInfo.refund = contractInfo.refund + amountRefund;
                if (contractInfo.erc20 == address(0)) {
                    payable(customer).transfer(amountRefund);
                } else {
                    IERC20Upgradeable(contractInfo.erc20).safeTransfer(customer, amountRefund);
                }
            }
            emit ContractEnded(contractInfo.merchantId, contractInfo.appId, contractInfo.contractId, sender, amountRefund, contractInfo.erc20, true, true);
        }
    }

    function declineEndContract(uint256 merchantId, uint256 appId, uint256 contractId, address customer) 
        public
        whenNotPaused
        nonReentrant
    {
        require(validApp(merchantId, appId), "GetdoneEscrow: App is invalid");
        require(isDisputation(merchantId, appId, contractId, customer) == false, "GetdoneEscrow: contract has disputation");
        
        address sender = _msgSender();
        ContractInfo storage contractInfo = contractInfos[merchantId][appId][customer][contractId];
        require((contractInfo.isEndCustomer && !contractInfo.isEndTalent), "GetdoneEscrow: contract cannot decline ending");
        require((!contractInfo.isEndCustomer && contractInfo.isEndTalent), "GetdoneEscrow: contract cannot decline ending");
        require((contractInfo.customer == sender || contractInfo.talent == sender ), "GetdoneEscrow: can not change contract if sender has not made one");

        contractInfo.isEndCustomer = false;
        contractInfo.isEndTalent = false;

        emit ContractEndingDeclined(merchantId, appId, contractId, sender, 0, contractInfo.erc20, false, false);
    }

    function depositContract(uint256 merchantId, uint256 appId, uint256 contractId, ContractDepositInput memory input) 
        public
        payable
        whenNotPaused
        nonReentrant
    {
        address customer = _msgSender();
        require(erc20Whitelist[merchantId][input.erc20], "GetdoneEscrow: erc20 must be in whitelist");
        require(validApp(merchantId, appId), "GetdoneEscrow: App is invalid");
        require(isEnd(merchantId, appId, contractId, customer) == false, "GetdoneEscrow: contract has been ended");
        require(isDisputation(merchantId, appId, contractId, customer) == false, "GetdoneEscrow: contract has disputation");
        require(input.price > 0, "GetdoneEscrow: price must be greater than 0");

        ContractInfo storage contractInfo = contractInfos[merchantId][appId][customer][contractId];

        if (contractInfo.init == true) {
            require(contractInfo.erc20 == input.erc20, "GetdoneEscrow: Erc20 can not change");
            require(contractInfo.customer == customer, "GetdoneEscrow: Cannot deposit contract");
        }

        if (input.erc20 == address(0)) {
            require(msg.value == input.price, "GetdoneEscrow: deposit amount is not enough");
        } else {
            IERC20Upgradeable(input.erc20).safeTransferFrom(customer, address(this), input.price);
        }

        if (contractInfo.init == false) {
            contractInfo.merchantId = merchantId;
            contractInfo.appId = appId;
            contractInfo.contractId = contractId;
            contractInfo.customer = customer;
            contractInfo.talent = input.talent;
            contractInfo.erc20 = input.erc20;
            contractInfo.price = 0;
            contractInfo.deposit = input.price;
            contractInfo.paid = 0;
            contractInfo.refund = 0;
            contractInfo.isEndTalent = false;
            contractInfo.isEndCustomer = false;
            contractInfo.status = CONTRACT_STATUS_NEW;
            contractInfo.init = true;
        } else {
            contractInfo.status = contractInfo.status == CONTRACT_STATUS_WITHDRAWN ? CONTRACT_STATUS_NEW : contractInfo.status;
            contractInfo.deposit = contractInfo.deposit + input.price;
        }
        uint256 p = input.price;
        address erc20 = input.erc20;
        emit ContractDeposited(contractInfo.merchantId, contractInfo.appId, contractInfo.contractId, input.orderId, contractInfo.customer, p, erc20);
    }

    function createDisputation(uint256 merchantId, uint256 appId, uint256 contractId, address customer, uint256 expireAt) 
        public
        whenNotPaused
        nonReentrant
    {
        require(validApp(merchantId, appId), "GetdoneEscrow: App is invalid");
        address sender = _msgSender();
        ContractInfo memory contractInfo = contractInfos[merchantId][appId][customer][contractId];
        ContractDisputation storage contractDispute = contractDisputations[merchantId][appId][customer][contractId];
        
        require((!contractDispute.isCustomerVoted && !contractDispute.isTalentVoted), "GetdoneEscrow: contract cannot vote disputation");
        require((!contractInfo.isEndCustomer || !contractInfo.isEndTalent), "GetdoneEscrow: contract has been ended");
        uint256 defaultExpires = block.timestamp + minDisputationTime;
        uint256 validExpire = expireAt > defaultExpires ? expireAt : defaultExpires;

        require((contractInfo.customer == sender || contractInfo.talent == sender), "GetdoneEscrow: can not change contract if sender has not made one");

        contractDispute.contractId = contractId;
        contractDispute.isProcessed = false;
        contractDispute.expireAt = validExpire;
        contractDispute.isCustomerVoted = contractInfo.customer == sender;
        contractDispute.isTalentVoted = contractInfo.customer != sender;
        contractDispute.owner = sender;
        emit ContractDisputationCreated(merchantId, appId, contractId, sender, sender, contractDispute.isTalentVoted, contractDispute.isCustomerVoted, validExpire);
    }
    function approveDisputation(uint256 merchantId, uint256 appId, uint256 contractId, bool isAccept, address customer) 
        public
        whenNotPaused
        nonReentrant
    {
        require(validApp(merchantId, appId), "GetdoneEscrow: App is invalid");
        address sender = _msgSender();
        ContractInfo memory contractInfo = contractInfos[merchantId][appId][customer][contractId];
        ContractDisputation storage contractDispute = contractDisputations[merchantId][appId][customer][contractId];
        
        require(((contractDispute.isCustomerVoted || contractDispute.isTalentVoted) && contractDispute.expireAt > block.timestamp && !contractDispute.isProcessed), "GetdoneEscrow: contract cannot vote disputation");
        require((!contractInfo.isEndCustomer || !contractInfo.isEndTalent), "GetdoneEscrow: contract has been ended");
        require((contractInfo.customer == sender || contractInfo.talent == sender), "GetdoneEscrow: can not change contract if sender has not made one");

        contractDispute.isCustomerVoted = contractInfo.customer == sender ? isAccept : contractDispute.isCustomerVoted;
        contractDispute.isTalentVoted = contractInfo.customer != sender ? isAccept : contractDispute.isTalentVoted;
        emit ContractDisputationVoted(merchantId, appId, contractId, sender, contractDispute.owner, contractDispute.isTalentVoted, contractDispute.isCustomerVoted, contractDispute.expireAt);

        uint256 amountRefund = contractInfo.deposit;
        uint256 contractBalance = contractInfo.deposit + contractInfo.price - contractInfo.paid - contractInfo.refund;
        amountRefund = amountRefund + updateMilestoneBalance(contractInfo.merchantId, contractInfo.appId, contractInfo.customer, contractInfo.contractId);

        contractInfo.isEndCustomer = true;
        contractInfo.isEndTalent = true;
        contractInfo.deposit = 0;
        if (amountRefund > 0 && amountRefund <= contractBalance) {
            contractInfo.refund = contractInfo.refund + amountRefund;
            if (contractInfo.erc20 == address(0)) {
                payable(treasuryWallet(contractInfo.merchantId, contractInfo.appId)).transfer(amountRefund);
            } else {
                address erc20 = contractInfo.erc20;
                IERC20Upgradeable(erc20).safeTransfer(treasuryWallet(contractInfo.merchantId, contractInfo.appId), amountRefund);
            }
        }
        contractDispute.isProcessed = true;

        emit ContractDisputationProcessed(contractInfo.merchantId, contractInfo.appId, contractInfo.contractId, _msgSender(), amountRefund, contractInfo.erc20, contractDispute.isTalentVoted, contractDispute.isCustomerVoted, contractDispute.expireAt);
    }

    function processDisputation(uint256 merchantId, uint256 appId, uint256 contractId, address customer) 
        public
        whenNotPaused
        nonReentrant
    {
        require(adminWallet(merchantId, appId) == _msgSender(), "GetdoneEscrow: caller is not the admin");
        ContractInfo storage contractInfo = contractInfos[merchantId][appId][customer][contractId];
        ContractDisputation storage contractDispute = contractDisputations[merchantId][appId][customer][contractId];

        require(validApp(merchantId, appId), "GetdoneEscrow: App is invalid");
        require((!contractInfo.isEndCustomer || !contractInfo.isEndTalent), "GetdoneEscrow: contract has been ended");
        require(
            (
                (contractDispute.isCustomerVoted || contractDispute.isTalentVoted) &&
                contractDispute.expireAt < block.timestamp &&
                !contractDispute.isProcessed
            )
            , "GetdoneEscrow: contract cannot process disputation");

        uint256 amountRefund = contractInfo.deposit;
        uint256 contractBalance = contractInfo.deposit + contractInfo.price - contractInfo.paid - contractInfo.refund;
        amountRefund = amountRefund + updateMilestoneBalance(contractInfo.merchantId, contractInfo.appId, contractInfo.customer, contractInfo.contractId);

        contractInfo.isEndCustomer = true;
        contractInfo.isEndTalent = true;
        contractInfo.deposit = 0;
        if (amountRefund > 0 && amountRefund <= contractBalance) {
            contractInfo.refund = contractInfo.refund + amountRefund;
            if (contractInfo.erc20 == address(0)) {
                payable(treasuryWallet(contractInfo.merchantId, contractInfo.appId)).transfer(amountRefund);
            } else {
                address erc20 = contractInfo.erc20;
                IERC20Upgradeable(erc20).safeTransfer(treasuryWallet(contractInfo.merchantId, contractInfo.appId), amountRefund);
            }
        }
        contractDispute.isProcessed = true;

        emit ContractDisputationProcessed(contractInfo.merchantId, contractInfo.appId, contractInfo.contractId, _msgSender(), amountRefund, contractInfo.erc20, contractDispute.isTalentVoted, contractDispute.isCustomerVoted, contractDispute.expireAt);
    }

    function withdrawContract(uint256 merchantId, uint256 appId, uint256 contractId) 
        public
        whenNotPaused
        nonReentrant
    {
        address customer = _msgSender();
        ContractInfo storage contractInfo = contractInfos[merchantId][appId][customer][contractId];
        require(isEnd(merchantId, appId, contractId, customer) == false, "GetdoneEscrow: contract has been ended");
        require(isDisputation(merchantId, appId, contractId, customer) == false, "GetdoneEscrow: contract has disputation");
        require(contractInfo.milestoneIds.length == 0, "GetdoneEscrow: contract has been ended");
        require(contractInfo.customer == customer, "GetdoneEscrow: can not change sale if sender has not made one");

        uint256 refund = contractInfo.deposit;
        if (refund > 0) {
            if (contractInfo.erc20 == address(0)) {
                payable(customer).transfer(refund);
            } else {
                IERC20Upgradeable(contractInfo.erc20).safeTransfer(customer, refund);
            }
        }
        contractInfo.deposit = 0;
        contractInfo.status = CONTRACT_STATUS_WITHDRAWN;
        emit ContractWithdrawn(merchantId, appId, contractId, customer, refund, contractInfo.erc20);
    }

    function _payout(uint256 merchantId, uint256 appId, uint256 contractId, uint256 milestoneId, address receiver, uint256 price, address erc20)
        internal
    {
        uint256 fee = price * appFees[merchantId][appId] / ONE_HUNDRED_PERCENT;

        uint256 amount = price - fee;

        if (erc20 == address(0)) {
            if (fee > 0) {
                payable(adminWallet(merchantId, appId)).transfer(fee);
            }

            if (amount > 0) {
                payable(receiver).transfer(amount);
            }

        } else {
            if (fee > 0) {
                IERC20Upgradeable(erc20).safeTransfer(adminWallet(merchantId, appId), fee);
            }
            if (amount > 0) {
                IERC20Upgradeable(erc20).safeTransfer(receiver, amount);
            }
        }

        emit Payout(merchantId, appId, contractId, milestoneId, amount, fee, erc20, receiver);
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