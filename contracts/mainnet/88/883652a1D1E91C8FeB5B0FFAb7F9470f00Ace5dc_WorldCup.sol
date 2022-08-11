pragma solidity ^0.8.0;
// SPDX-License-Identifier: GPL-3.0

import "./SafeMath.sol";
import "./SafeERC20.sol";
import "./Ownable.sol";


contract INft {
    function mint(address recipient_, uint level) external returns (uint256){}

    function isApprovedOrOwner(address spender, uint256 tokenId) public view returns (bool){}

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual {}

}

contract Invitation {
    function getInvitation(address user) external view returns (address inviter, address[] memory invitees) {}

    function getEarlyWarning(address user) external view returns (uint256 _amount, uint256 earlyWarning){}

    function setAccounts(address user, uint256 amount, uint256 earlyWarning) public {}
}

contract PledgeSale {
    function isSellOf(uint256 tokenId) public view returns (bool){}
}

contract WorldCup is Ownable {
    using SafeMath for uint256;
    using SafeERC20 for ERC20;

    uint256[76] _a = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 1, 2, 3, 4, 5, 6, 7, 8, 9, 1, 2, 3, 4, 5, 6, 7, 8, 1, 2, 3, 4, 5,
    6, 7, 1, 2, 3, 4, 5, 6, 1, 2, 3, 4, 5, 1, 2, 3, 4, 1, 2, 3, 1, 2, 1, 1, 2, 3, 4, 5, 6, 1, 2, 3, 4, 5, 1, 2, 3, 4, 1, 2, 3, 1, 2, 1];


    uint256 public AgreementAmount0 = 500 * 10 ** 18;
    uint256 public AgreementAmount1 = 1000 * 10 ** 18;
    uint256 public AgreementAmount2 = 3000 * 10 ** 18;
    uint256 public AgreementAmount3 = 6000 * 10 ** 18;
    uint256 public AgreementAmount4 = 12000 * 10 ** 18;
    uint256 public AgreementAmount5 = 24000 * 10 ** 18;
    uint256 public AgreementAmount6 = 50000 * 10 ** 18;


    uint256 constant public AgreementWSDAmount0 = 55000 * 10 ** 18;
    uint256 constant public AgreementWSDAmount1 = 120000 * 10 ** 18;
    uint256 constant public AgreementWSDAmount2 = 390000 * 10 ** 18;
    uint256 constant public AgreementWSDAmount3 = 900000 * 10 ** 18;
    uint256 constant public AgreementWSDAmount4 = 1920000 * 10 ** 18;
    uint256 constant public AgreementWSDAmount5 = 4320000 * 10 ** 18;
    uint256 constant public AgreementWSDAmount6 = 10000000 * 10 ** 18;

    address public usdtWSD;
    address public agreementsOwner;
    address public collectionAddress;
    address[] public operableAddress;

    uint256 importSeed;

    uint256 public exchangeRate;
    uint256 public baselineAmount;
    uint256 public exchangeRateBonus;
    uint256 public pledgeMaxNumber;
    uint256 public exchangeNFTNumber;
    uint256 public discount = 100;

    bool public isPurchaseUSDT;
    bool public isPurchaseWSD;
    bool public isWithdraw;
    bool public isPledge;
    bool public isUpgradeContractUSDT;
    bool public isUpgradeContractWSD;


    ERC20 public usdtContract;
    ERC20 public wsdContract;
    INft public NFTContract;
    Invitation public invitation;
    PledgeSale public pledgeSale;

    mapping(address => uint256) public agreementNumbers;
    mapping(address => uint256) public agreementTotalNumbers;
    mapping(address => uint256) public fragmentNumbers;
    mapping(address => uint256) public teamPerformance;
    mapping(uint256 => uint256) public isTokenId;
    mapping(address => uint256) public pledgeAgreementNumbers;
    mapping(address => uint256) public pledgeNumbers;
    mapping(uint256 => address) public ntfInitialAddress;
    mapping(address => bool) public burnWhitelist;
    mapping(address => uint256) public validNumber;
    mapping(address => bool) public isValid;

    uint256 _timeToday = 10800;
    uint256 _timeRefresh = 1659974400;


    mapping(address => AgreementAmount) public agreementAmounts;

    struct AgreementAmount {
        uint256 purchaseAgreementAmount;
        uint256 purchaseTodayAmount;
        uint256 purchaseTime;
        mapping(address => uint256) incomes;
        mapping(address => uint256) incomesTime;
    }


    mapping(uint256 => Attribute) public attributes;

    struct Attribute {
        uint256 attributeNumber;
        uint256 fusionNumber;
        uint256 probability;
    }

    mapping(address => mapping(uint256 => Agreement)) public agreements;

    struct Agreement {
        bool isPledge;
        bool isUpgrade;
        bool isFusion;
        uint256 tokenId;
        uint256 agreementId;
        uint256 fusionNumber;
        uint256 currentAmount;
        uint256 rewardAmount;
        uint256 pledgeTime;
        uint256 WithdrawalAmount;
        uint256 orderId;
    }

    mapping(address => mapping(uint256 => AgreementOrder)) public agreementOrders;

    struct AgreementOrder {
        bool isPledgeNFT;
        bool isStart;
        uint256 tokenId;
        uint256 currentAmount;
        uint256 rewardAmount;
        uint256 incomeAmount;
        bool isRateOfReturn;
        uint256 rateOfReturn;
        uint256 WithdrawalTime;
        uint256 WithdrawalAmount;
        uint256[] tokenIds;
        uint256 agreementId;
    }


    event PurchaseAgreement(address indexed _msgSender, uint256 _agreementId, uint256 _amount, uint256 _tokenId, uint256 _attributeNumber, uint256 _fragmentNumber, uint256 _time);
    event Rebate(address indexed _msgSender, address indexed _inviter, uint256 _type, uint256 _amount, uint _time);
    event PledgeAgreement(address indexed _msgSender, uint256 _number, uint256 _order, uint256 _time);
    event CancelPledge(address indexed _msgSender, uint256 _number, uint256 _order, uint256 _time);
    event ActivatePledge(address indexed _msgSender, uint256 _tokenId, uint256 number, uint256 _time);
    event RemovePledge(address indexed _msgSender, uint256 _tokenId, uint256 number, uint256 _time);
    event ReplacePledge(address indexed _msgSender, uint256 _tokenId, uint256 __tokenId, uint256 number, uint256 _time);
    event Switch(address indexed _msgSender, uint256 number, bool _isStart, uint256 _time);
    event Withdraw(address indexed _msgSender, uint256 _agreementId, uint256 _amount, uint256 _time);
    event FusionContract(address indexed _msgSender, uint256 _agreementId, uint256 _number, uint256 _time);
    event UpgradeContract(address indexed _msgSender, uint256 amount, uint256 _type, uint256 _agreementId, uint256 number, uint256 _amount, uint256 _time);
    event ExchangeNFT(address indexed _msgSender, uint256 _number, uint256 _tokenId, uint256 _time);
    event SetFragmentNumbers(address indexed _msgSender, address indexed inviter, uint256 number, uint256 _time);
    event SetAgreements(address indexed _agreementsOwner, address indexed _msgSender, uint256 _amount, uint256 _rewardAmount, uint256 _time);

    constructor(address _USDTContract, address _wsdContract, address _NFTContract, address _invitationContract){
        usdtContract = ERC20(_USDTContract);
        wsdContract = ERC20(_wsdContract);
        NFTContract = INft(_NFTContract);
        invitation = Invitation(_invitationContract);
    }

    function purchaseUSDT(uint256 _number) public nonReentrant {
        require(isPurchaseUSDT, "Purchase not opened!");
        uint256 amount = AgreementAmount0 * _number;
        usdtContract.transferFrom(msg.sender, address(this), amount);
        _purchaseAgreement(_number);
        rebate(amount, uint256(1));

        amount = usdtContract.balanceOf(address(this));

        if (amount > baselineAmount) {
            usdtContract.transfer(collectionAddress, amount.sub(baselineAmount));
        }
    }

    function purchaseWSD(uint256 _number) public nonReentrant {
        require(isPurchaseWSD, "Purchase not opened!");
        require(exchangeRateOf() > 0);
        uint256 amount = AgreementAmount0.mul(_number).mul(exchangeRateOf()).div(10 ** wsdContract.decimals());
        wsdContract.transferFrom(msg.sender, address(this), amount);
        _purchaseAgreement(_number);

        rebate(amount, uint256(2));

    }


    function _purchaseAgreement(uint256 _number) private {
        require(tx.origin == _msgSender(), "Cannot be called by external contract");
        require(_number > 0);
        AgreementAmount storage agrAmount = agreementAmounts[msg.sender];
        agrAmount.purchaseAgreementAmount += AgreementAmount0.mul(_number);
        uint256 time_ = block.timestamp;

        if (agrAmount.purchaseTime <= 0) {
            agrAmount.purchaseTime = _timeRefresh;
        }

        uint256 diff = time_.sub(agrAmount.purchaseTime).div(_timeToday);
        if (diff > 0) {
            agrAmount.purchaseTime += diff.mul(_timeToday);
            agrAmount.purchaseTodayAmount = AgreementAmount0.mul(_number);
        } else {
            agrAmount.purchaseTodayAmount += AgreementAmount0.mul(_number);
        }

        agreementNumbers[msg.sender] += _number;

        for (uint256 i = 0; i < _number; i++) {
            agreementTotalNumbers[msg.sender] += 1;
            Agreement storage agreement = agreements[msg.sender][agreementTotalNumbers[msg.sender]];
            agreement.currentAmount = AgreementAmount0;
            agreement.rewardAmount = AgreementWSDAmount0;
            agreement.pledgeTime = time_;

            (uint256 tokenId,uint256 attributeNumber) = _generateNFT(msg.sender);
            agreement.tokenId = tokenId;

            uint256 _fragmentNumber = importSeedFromThird(10000);
            uint256 fragmentNumber = 0;
            if (_fragmentNumber == 9999) {
                fragmentNumber = 9;
            } else if (_fragmentNumber > 9994) {
                fragmentNumber = 8;
            } else if (_fragmentNumber > 9989) {
                fragmentNumber = 7;
            } else if (_fragmentNumber > 9949) {
                fragmentNumber = 6;
            } else if (_fragmentNumber > 9899) {
                fragmentNumber = 5;
            } else if (_fragmentNumber > 9799) {
                fragmentNumber = 4;
            } else if (_fragmentNumber > 9299) {
                fragmentNumber = 3;
            } else if (_fragmentNumber > 7799) {
                fragmentNumber = 2;
            } else if (_fragmentNumber > 4299) {
                fragmentNumber = 1;
            }
            fragmentNumbers[msg.sender] += fragmentNumber;


            emit PurchaseAgreement(msg.sender, agreementTotalNumbers[msg.sender], AgreementAmount0, tokenId, attributeNumber, fragmentNumber, time_);
        }


    }

    function rebate(uint256 _amount, uint256 _type) private {
        (address inviter,) = invitation.getInvitation(msg.sender);
        uint256 number = 80;
        address inviter1 = address(0);

        if (!isValid[msg.sender]) {
            validNumber[inviter] += 1;
            isValid[msg.sender] = true;
        }

        for (uint256 i = 0; i < 7; i++) {
            if (inviter != address(0)) {
                (address inviter22,) = invitation.getInvitation(inviter);

                if (_type == 1) {
                    teamPerformance[inviter] += _amount;
                } else {
                    teamPerformance[inviter] += _amount.mul(10 ** wsdContract.decimals()).div(exchangeRateOf());
                }

                AgreementAmount storage agrAmountInviter = agreementAmounts[inviter];

                if (agrAmountInviter.incomesTime[msg.sender] <= 0) {
                    agrAmountInviter.incomesTime[msg.sender] = _timeRefresh;
                }

                uint256 diff1 = block.timestamp.sub(agrAmountInviter.incomesTime[msg.sender]).div(_timeToday);

                if (diff1 > 0) {
                    agrAmountInviter.incomes[msg.sender] = 0;
                    agrAmountInviter.incomesTime[msg.sender] += diff1.mul(_timeToday);
                }

                uint256 amount = _amount;
                if (validNumber[inviter] >= i + 1 || validNumber[inviter] >= 5) {
                    if (agreementTotalNumbers[inviter] > 0) {
                        bool isLevelBurn;
                        if (validNumber[inviter] >= 5) {
                            if (i == 0) {
                                if (teamPerformance[msg.sender] >= teamPerformance[inviter].sub(teamPerformance[msg.sender])) {
                                    amount = amount.mul(25).div(10000);
                                    isLevelBurn = true;
                                }
                            } else {
                                if (teamPerformance[inviter1] >= teamPerformance[inviter].sub(teamPerformance[inviter1])) {
                                    amount = amount.mul(25).div(10000);
                                    isLevelBurn = true;
                                }
                            }
                        }

                        if (!isLevelBurn) {
                            if (!burnWhitelist[inviter]) {
                                if (agrAmountInviter.purchaseAgreementAmount > agrAmountInviter.incomes[msg.sender]) {
                                    uint256 burn = agrAmountInviter.purchaseAgreementAmount.sub(agrAmountInviter.incomes[msg.sender]);
                                    if (_type != 1) {
                                        burn = burn.mul(exchangeRateOf()).div(10 ** wsdContract.decimals());
                                    }
                                    if (burn < amount) {
                                        amount = burn;
                                    }

                                } else {
                                    amount = 0;
                                }
                            }


                            if (amount > 0) {
                                if (_type == 1) {
                                    agrAmountInviter.incomes[msg.sender] += amount;
                                } else {
                                    agrAmountInviter.incomes[msg.sender] += amount.mul(10 ** wsdContract.decimals()).div(exchangeRateOf());
                                }
                                amount = amount.mul(12).div(100);
                                if (i == 0) {
                                    if (validNumber[inviter] > 1) {
                                        amount = amount.mul(number).div(100);
                                    } else {
                                        amount = amount.mul(20).div(100);
                                    }
                                } else {
                                    amount = amount.mul(number).div(100);
                                }

                            }
                        }
                        if (amount > 0) {
                            if (_type == 1) {
                                usdtContract.transfer(inviter, amount);
                            } else {
                                wsdContract.transfer(inviter, amount);
                            }
                            emit Rebate(msg.sender, inviter, _type, amount, block.timestamp);
                        }
                    }


                }

                inviter1 = inviter;
                inviter = inviter22;

                if (number > 50) {
                    number -= 10;
                } else {
                    number = 10;
                }

            } else {
                i = 10;
            }

        }


    }

    function pledgeAgreement(uint256 agreementId) private returns (uint256){
        require(tx.origin == _msgSender(), "Cannot be called by external contract");
        require(isPledge, "Staking is not enabled!");
        require(pledgeAgreementNumbers[msg.sender] < pledgeMaxNumber, "The pledge has been reached!");
        require(agreementNumbers[msg.sender] - pledgeAgreementNumbers[msg.sender] > 0, "no contract available!");

        pledgeAgreementNumbers[msg.sender] += 1;

        Agreement storage agr = agreements[msg.sender][agreementId];
        if (!agr.isPledge) {
            require(!agr.isFusion, "This contract has been merged!");
            agr.isPledge = true;

            for (uint256 i = 1; i <= pledgeAgreementNumbers[msg.sender]; i++) {
                AgreementOrder storage agrOrder = agreementOrders[msg.sender][i];
                if (agrOrder.agreementId == 0) {
                    agrOrder.agreementId = agreementId;
                    agrOrder.WithdrawalAmount = agr.WithdrawalAmount;
                    agrOrder.rewardAmount = agr.rewardAmount;
                    agr.orderId = i;
                    i = pledgeAgreementNumbers[msg.sender] + 1;
                }
            }
        }

        emit PledgeAgreement(msg.sender, agreementId, agr.orderId, block.timestamp);
        return agr.orderId;
    }

    function cancelPledge(uint256 agrOrderId) private {

        AgreementOrder storage agrOrder = agreementOrders[msg.sender][agrOrderId];
        Agreement storage agr = agreements[msg.sender][agrOrder.agreementId];
        require(!agrOrder.isStart, "Mining needs to be suspended first!");
        require(!agrOrder.isPledgeNFT, "The current contract is activated!");
        require(agrOrder.tokenIds.length <= 0, "There are also NFTs that have not been cancelled!");
        require(agrOrder.agreementId > 0, "without this pledge!");

        withdraw(agrOrder.agreementId);

        agr.WithdrawalAmount = agrOrder.WithdrawalAmount;
        agr.isPledge = false;
        agr.orderId = 0;

        pledgeAgreementNumbers[msg.sender] -= 1;

        emit CancelPledge(msg.sender, agrOrder.agreementId, agr.orderId, block.timestamp);
        agrOrder.agreementId = 0;

    }

    function addNFT(uint256 tokenId, uint256 agreementId) public nonReentrant {
        require(!pledgeSale.isSellOf(tokenId), "This NFT is already being sold!");
        Agreement storage agr = agreements[msg.sender][agreementId];
        if (!agr.isPledge) {
            pledgeAgreement(agreementId);
        }
        _activatePledge(tokenId, agreementId);
    }

    function _activatePledge(uint256 tokenId, uint256 agreementId) private {
        require(tx.origin == _msgSender(), "Cannot be called by external contract");
        require(NFTContract.isApprovedOrOwner(msg.sender, tokenId), "ERC721: transfer caller is not owner nor approved");
        require(isTokenId[tokenId] <= 0, "NFT has been pledged!");

        Agreement storage agr = agreements[msg.sender][agreementId];
        AgreementOrder storage agrOrder = agreementOrders[msg.sender][agr.orderId];

        require(!agrOrder.isStart, "Mining needs to be suspended first!");

        isTokenId[tokenId] = agr.orderId;
        if (!agrOrder.isPledgeNFT) {
            require(!agrOrder.isPledgeNFT, "The current contract is activated!");
            agrOrder.tokenId = tokenId;
            agrOrder.isPledgeNFT = true;
            agrOrder.rateOfReturn += 50 * 10000;

        } else {
            require(agrOrder.isPledgeNFT, "You need to put the main NFT first!");
            require(agrOrder.tokenIds.length < 10, "limit reached!");
            agrOrder.tokenIds.push(tokenId);
            Attribute storage attr = attributes[tokenId];
            agrOrder.rateOfReturn += attr.attributeNumber;

            if (!agrOrder.isRateOfReturn) {
                if (agrOrder.rateOfReturn >= exchangeRateBonus) {
                    agrOrder.rateOfReturn += 5 * 10000;
                    agrOrder.isRateOfReturn = true;
                }
            }


        }

        emit ActivatePledge(msg.sender, tokenId, agreementId, block.timestamp);


    }

    function removeNFT(uint256 tokenId) public {
        require(tx.origin == _msgSender(), "Cannot be called by external contract");
        require(NFTContract.isApprovedOrOwner(msg.sender, tokenId), "ERC721: transfer caller is not owner nor approved");
        require(isTokenId[tokenId] > 0, "The current NFT is not pledged!");
        uint256 number = isTokenId[tokenId];
        AgreementOrder storage agrOrder = agreementOrders[msg.sender][number];

        require(!agrOrder.isStart, "Mining needs to be suspended first!");

        isTokenId[tokenId] = uint256(0);
        if (agrOrder.tokenId == tokenId) {
            require(agrOrder.isPledgeNFT, "No NFTs added!");
            agrOrder.tokenId = 0;
            agrOrder.isPledgeNFT = false;
            agrOrder.rateOfReturn -= 50 * 10000;

        } else {
            require(agrOrder.tokenIds.length > 0, "limit reached!");
            for (uint256 i = 0; i < agrOrder.tokenIds.length; i++) {
                if (agrOrder.tokenIds[i] == tokenId) {
                    agrOrder.tokenIds[i] = agrOrder.tokenIds[agrOrder.tokenIds.length - 1];
                    agrOrder.tokenIds.pop();
                    i = agrOrder.tokenIds.length;
                }
            }
            Attribute storage attr = attributes[tokenId];
            agrOrder.rateOfReturn -= attr.attributeNumber;
        }

        if (agrOrder.isRateOfReturn) {
            if (agrOrder.rateOfReturn < exchangeRateBonus) {
                agrOrder.rateOfReturn -= 5 * 10000;
                agrOrder.isRateOfReturn = false;
            }

        }

        if (!agrOrder.isPledgeNFT && agrOrder.tokenIds.length <= 0) {
            cancelPledge(number);
        }

        emit RemovePledge(msg.sender, tokenId, number, block.timestamp);
    }

    function replaceNFT(uint256 tokenId, uint256 _tokenId) public {
        require(tx.origin == _msgSender(), "Cannot be called by external contract");
        require(NFTContract.isApprovedOrOwner(msg.sender, tokenId), "ERC721: transfer caller is not owner nor approved");
        require(NFTContract.isApprovedOrOwner(msg.sender, _tokenId), "ERC721: transfer caller is not owner nor approved");
        require(isTokenId[tokenId] > 0, "The current NFT is not pledged!");
        require(isTokenId[_tokenId] <= 0, "The current NFT is not pledged!");
        uint256 orderId = isTokenId[tokenId];
        isTokenId[_tokenId] = orderId;
        AgreementOrder storage agrOrder = agreementOrders[msg.sender][orderId];

        require(!agrOrder.isStart, "Mining needs to be suspended first!");

        isTokenId[tokenId] = uint256(0);
        if (agrOrder.tokenId == tokenId) {
            require(agrOrder.isPledgeNFT, "No NFTs added!");
            agrOrder.tokenId = _tokenId;

        } else {
            require(agrOrder.tokenIds.length > 0, "limit reached!");
            for (uint256 i = 0; i < agrOrder.tokenIds.length; i++) {
                if (agrOrder.tokenIds[i] == tokenId) {
                    agrOrder.tokenIds[i] = _tokenId;
                    i = agrOrder.tokenIds.length;
                }
            }
            Attribute storage attr = attributes[tokenId];
            Attribute storage _attr = attributes[_tokenId];
            agrOrder.rateOfReturn -= attr.attributeNumber;
            agrOrder.rateOfReturn += _attr.attributeNumber;
        }

        if (agrOrder.isRateOfReturn) {
            if (agrOrder.rateOfReturn < exchangeRateBonus) {
                agrOrder.rateOfReturn -= 5 * 10000;
                agrOrder.isRateOfReturn = false;
            }

        } else {
            if (agrOrder.rateOfReturn >= exchangeRateBonus) {
                agrOrder.rateOfReturn += 5 * 10000;
                agrOrder.isRateOfReturn = true;
            }
        }

        emit ReplacePledge(msg.sender, tokenId, _tokenId, orderId, block.timestamp);
    }

    function setUpSwitch(uint256 agreementId, bool _isStart) public nonReentrant {
        require(tx.origin == _msgSender(), "Cannot be called by external contract");
        Agreement storage agr = agreements[msg.sender][agreementId];
        require(agr.isPledge, "The current contract is not pledged!");
        AgreementOrder storage agrOrder = agreementOrders[msg.sender][agr.orderId];
        require(agrOrder.isStart != _isStart, "The switch is already in the current state!");
        uint256 time_ = block.timestamp;
        if (_isStart) {
            agrOrder.WithdrawalTime = time_;
        } else {
            agrOrder.incomeAmount = stakeEarningsOf(msg.sender, agreementId);
        }
        agrOrder.isStart = _isStart;
        emit Switch(msg.sender, agreementId, _isStart, time_);

    }

    function stakeEarningsOf(address _msgSender, uint256 agreementId) public view returns (uint256){

        Agreement storage agr = agreements[_msgSender][agreementId];
        AgreementOrder storage agrOrder = agreementOrders[_msgSender][agr.orderId];
        uint256 stakeEarningsAmount = uint256(0);
        uint256 rateOfReturn = agrOrder.rateOfReturn;

        if (agrOrder.isPledgeNFT && agrOrder.isStart) {
            uint256 amount = agrOrder.rewardAmount.mul(rateOfReturn.div(100)).div(100).div(10000).div(86400);
            uint256 countDay = block.timestamp.sub(agrOrder.WithdrawalTime);
            if (countDay > 0) {
                stakeEarningsAmount = amount.mul(countDay).add(agrOrder.incomeAmount);
                if (agrOrder.rewardAmount.sub(agrOrder.WithdrawalAmount) < stakeEarningsAmount) {
                    stakeEarningsAmount = agrOrder.rewardAmount.sub(agrOrder.WithdrawalAmount);
                }
            }

        } else {
            stakeEarningsAmount = agrOrder.incomeAmount;
        }

        return stakeEarningsAmount;
    }

    function withdraw(uint256 agreementId) public nonReentrant {
        require(tx.origin == _msgSender(), "Cannot be called by external contract");
        require(isWithdraw, "Withdrawal not enabled!");
        Agreement storage agr = agreements[msg.sender][agreementId];
        AgreementOrder storage agrOrder = agreementOrders[msg.sender][agr.orderId];
        require(agrOrder.WithdrawalAmount < agrOrder.rewardAmount, "");
        uint256 time_ = block.timestamp;

        uint256 countDay = time_.sub(agrOrder.WithdrawalTime);
        uint256 amountWithdraw;
        if (countDay > 0) {
            amountWithdraw = stakeEarningsOf(msg.sender, agreementId);
            wsdContract.safeTransfer(msg.sender, amountWithdraw);
            agrOrder.WithdrawalTime = time_;
            agrOrder.WithdrawalAmount += amountWithdraw;
            agrOrder.incomeAmount = 0;
        }


        emit Withdraw(msg.sender, agreementId, amountWithdraw, time_);

    }

    function fusionContract(uint256 agreementId, uint256 _agreementId) public nonReentrant {
        require(tx.origin == _msgSender(), "Cannot be called by external contract");
        require(agreementTotalNumbers[msg.sender] >= _agreementId, "There are currently no blank contracts!");
        require(agreementTotalNumbers[msg.sender] >= agreementId, "There are currently no blank contracts!");

        Agreement storage agr = agreements[msg.sender][agreementId];
        Agreement storage _agr = agreements[msg.sender][_agreementId];

        require(!agr.isUpgrade, "The upgraded contract cannot be merged!");
        require(!_agr.isUpgrade, "The upgraded contract cannot be merged!");
        require(!_agr.isPledge, "The current contract is pledged!");
        require(!_agr.isFusion, "This contract has been merged!");


        agr.currentAmount += _agr.currentAmount;
        agr.rewardAmount += _agr.rewardAmount;
        agr.WithdrawalAmount += _agr.WithdrawalAmount;
        agr.fusionNumber += 1;

        require(agr.currentAmount <= AgreementAmount6, "The fusion maximum has been reached!");

        if (agr.orderId > 0) {
            AgreementOrder storage agrOrder = agreementOrders[msg.sender][agr.orderId];
            require(!agrOrder.isStart, "Mining needs to be suspended first!");

            agrOrder.rewardAmount += _agr.rewardAmount;
            agrOrder.WithdrawalAmount += _agr.WithdrawalAmount;
        }


        _agr.agreementId = agreementId;
        _agr.isFusion = true;

        agreementNumbers[msg.sender] -= 1;

        emit FusionContract(msg.sender, agreementId, _agreementId, block.timestamp);

    }

    function upgradeContractUSDT(uint256 agreementId, uint256 number) public nonReentrant {
        require(isUpgradeContractUSDT, "Staking is not enabled!");
        _upgradeContract(agreementId, number, uint256(1));
    }

    function upgradeContractWSD(uint256 agreementId, uint256 number) public nonReentrant {
        require(isUpgradeContractWSD, "Staking is not enabled!");
        _upgradeContract(agreementId, number, uint256(2));
    }

    function _upgradeContract(uint256 agreementId, uint256 number, uint256 _type) private {
        require(tx.origin == _msgSender(), "Cannot be called by external contract");

        uint256 rewardAmount = uint256(0);
        uint256 amount = uint256(0);
        if (number == 1) {
            amount = AgreementAmount1;
            rewardAmount = AgreementWSDAmount1;
        } else if (number == 2) {
            amount = AgreementAmount2;
            rewardAmount = AgreementWSDAmount2;
        } else if (number == 3) {
            amount = AgreementAmount3;
            rewardAmount = AgreementWSDAmount3;
        } else if (number == 4) {
            amount = AgreementAmount4;
            rewardAmount = AgreementWSDAmount4;
        } else if (number == 5) {
            amount = AgreementAmount5;
            rewardAmount = AgreementWSDAmount5;
        } else if (number == 6) {
            amount = AgreementAmount6;
            rewardAmount = AgreementWSDAmount6;
        } else {
            require(false, "wrong amount!");
        }


        Agreement storage agr = agreements[msg.sender][agreementId];
        require(amount > agr.currentAmount, "cannot be less than the current contract amount!");
        uint256 amountA = amount.sub(agr.currentAmount);
        uint256 time_ = block.timestamp;

        AgreementAmount storage agrAmount = agreementAmounts[msg.sender];
        agrAmount.purchaseAgreementAmount += amountA;

        if(agrAmount.purchaseTime <=0){
            agrAmount.purchaseTime = _timeRefresh;
        }

        uint256 diff = time_.sub(agrAmount.purchaseTime).div(_timeToday);
        if (diff > 0) {
            agrAmount.purchaseTime += diff.mul(_timeToday);
            agrAmount.purchaseTodayAmount = amountA;
        } else {
            agrAmount.purchaseTodayAmount += amountA;
        }

        if (_type == 1) {
            usdtContract.transferFrom(msg.sender, address(this), amountA);
        } else {
            amountA = amountA.mul(exchangeRateOf()).div(10 ** wsdContract.decimals()).mul(discount).div(100);
            wsdContract.transferFrom(msg.sender, address(this), amountA);
        }

        agr.isUpgrade = true;
        agr.currentAmount = amount;
        agr.rewardAmount = rewardAmount;
        if (agr.orderId > 0) {
            AgreementOrder storage agrOrder = agreementOrders[msg.sender][agr.orderId];
            require(!agrOrder.isStart, "Mining needs to be suspended first!");
            agrOrder.rewardAmount = rewardAmount;
        }

        rebate(amountA, _type);

        emit UpgradeContract(msg.sender, amount, _type, agreementId, number, amountA, time_);
    }

    function exchangeNFT(uint256 number) public nonReentrant returns (uint256[] memory) {
        require(tx.origin == _msgSender(), "Cannot be called by external contract");
        require(fragmentNumbers[msg.sender] >= number.mul(exchangeNFTNumber), "Not enough sprites!");
        fragmentNumbers[msg.sender] -= number.mul(exchangeNFTNumber);
        uint256[] memory tokenIds = new uint256[](number);
        for (uint256 i = 0; i < number; i++) {
            (uint256 tokenId,) = _generateNFT(msg.sender);
            tokenIds[i] = tokenId;

            emit ExchangeNFT(msg.sender, number, tokenId, block.timestamp);
        }

        return tokenIds;

    }

    function attributeNumbersOf(uint256 _tokenId) public view returns (uint256, uint256, uint256){
        Attribute storage attr = attributes[_tokenId];
        return (attr.attributeNumber, attr.fusionNumber, attr.probability);
    }

    function setAttributeNumbers(uint256 _tokenId, uint256 _attributeNumber) public {
        require(msg.sender == address(pledgeSale), "Can only be called at a specific address!");
        attributes[_tokenId].attributeNumber = _attributeNumber;
    }

    function setAttribute(uint256 _tokenId, uint256 _attributeNumber, uint256 _fusionNumber, uint256 _probability) public {
        require(msg.sender == address(pledgeSale), "Can only be called at a specific address!");
        Attribute storage attr = attributes[_tokenId];
        attr.attributeNumber = _attributeNumber;
        attr.probability = _probability;
        attr.fusionNumber = _fusionNumber;
    }


    function setAgreements(address _msgSender, uint256 _amount, uint256 _rewardAmount) public {
        require(msg.sender == agreementsOwner, "Can only be called at a specific address!");
        agreementTotalNumbers[_msgSender] += 1;
        Agreement storage agreement = agreements[_msgSender][agreementTotalNumbers[msg.sender]];
        agreement.currentAmount = _amount;
        agreement.rewardAmount = _rewardAmount;
        agreement.pledgeTime = block.timestamp;

        emit SetAgreements(msg.sender, _msgSender, _amount, _rewardAmount, block.timestamp);
    }

    function _generateNFT(address _msgSender) private returns (uint256, uint256){

        uint256 tokenId = NFTContract.mint(_msgSender, importSeedFromThird(3));
        ntfInitialAddress[tokenId] = _msgSender;

        Attribute storage attribute = attributes[tokenId];
        attribute.attributeNumber = _a[importSeedFromThird(_a.length)].mul(10000);
        attribute.probability = 90;

        return (tokenId, attribute.attributeNumber);
    }

    function generateNFT(address _msgSender) public returns (uint256){
        uint256 tokenId;
        for (uint256 i = 0; i < operableAddress.length; i++) {
            if (msg.sender == operableAddress[i]) {
                (tokenId,) = _generateNFT(_msgSender);
                i = operableAddress.length + 1;
            }
        }
        return tokenId;
    }

    function setOperableAddress(address _address) public onlyOwner {
        operableAddress.push(_address);
    }

    function removeOperableAddress(address _address) public onlyOwner {
        for (uint256 i = 0; i < operableAddress.length; i++) {
            if (_address == operableAddress[i]) {
                operableAddress[i] = operableAddress[operableAddress.length - 1];
                operableAddress.pop();
                i = operableAddress.length + 1;
            }
        }
    }

    function agreementOrderTokenIds(address _msgSender, uint256 _orderId) public view returns (uint256[] memory){
        return agreementOrders[_msgSender][_orderId].tokenIds;
    }

    function importSeedFromThird(uint256 number) public returns (uint256) {
        importSeed += 1;
        return
        uint256(keccak256(abi.encodePacked(block.timestamp, block.difficulty, importSeed))) % number;
    }

    function exchangeRateOf() public view returns (uint256) {
        if (usdtWSD == address(0)) {
            return exchangeRate;
        }

        uint256 balanceUSDT = usdtContract.balanceOf(usdtWSD);
        uint256 balanceWSD = wsdContract.balanceOf(usdtWSD);

        return balanceWSD.mul(10 ** wsdContract.decimals()).div(balanceUSDT);
    }

    function setUSDTWSD(address _usdtWSD) public onlyOwner {
        usdtWSD = _usdtWSD;
    }

    function setExchangeRate(uint256 _exchangeRate) public onlyOwner {
        exchangeRate = _exchangeRate;
    }

    function setUpPurchaseWSD(bool _isPurchaseWSD) public onlyOwner {
        isPurchaseWSD = _isPurchaseWSD;
    }

    function setUpPurchaseUSDT(bool _isPurchaseUSDT) public onlyOwner {
        isPurchaseUSDT = _isPurchaseUSDT;
    }

    function setUpUpgradeContractWSD(bool _isUpgradeContractWSD) public onlyOwner {
        isUpgradeContractWSD = _isUpgradeContractWSD;
    }

    function setUpUpgradeContractUSDT(bool _isUpgradeContractUSDT) public onlyOwner {
        isUpgradeContractUSDT = _isUpgradeContractUSDT;
    }


    function setExchangeRateBonus(uint256 _exchangeRateBonus) public onlyOwner {
        exchangeRateBonus = _exchangeRateBonus * 10000;
    }

    function setIsWithdraw(bool _isWithdraw) public onlyOwner {
        isWithdraw = _isWithdraw;
    }

    function setIsPledge(bool _isPledge) public onlyOwner {
        isPledge = _isPledge;
    }

    function setPledgeMaxNumber(uint256 _number) public onlyOwner {
        pledgeMaxNumber = _number;
    }


    function setExchangeNFTNumber(uint256 _number) public onlyOwner {
        exchangeNFTNumber = _number;
    }

    function setBurnWhitelist(address _msgSender, bool _number) public onlyOwner {
        burnWhitelist[_msgSender] = _number;
    }

    function setFragmentNumbers(address _msgSender, uint256 number) public {
        require(msg.sender == address(pledgeSale), "Can only be called at a specific address!");
        fragmentNumbers[_msgSender] += number;
        emit SetFragmentNumbers(msg.sender, _msgSender, number, block.timestamp);
    }

    function setPledgeSale(address _pledgeSale) public onlyOwner {
        pledgeSale = PledgeSale(_pledgeSale);
    }

    function setBiscount(uint256 _discount) public onlyOwner {
        discount = _discount;
    }


    function setAgreementsOwner(address _agreementsOwner) public onlyOwner {
        agreementsOwner = _agreementsOwner;
    }

    function setAgreementAmount0(uint256 _AgreementAmount0) public onlyOwner {
        AgreementAmount0 = _AgreementAmount0;
    }

    function setAgreementAmount1(uint256 _AgreementAmount0) public onlyOwner {
        AgreementAmount1 = _AgreementAmount0;
    }

    function setAgreementAmount2(uint256 _AgreementAmount0) public onlyOwner {
        AgreementAmount2 = _AgreementAmount0;
    }

    function setAgreementAmount3(uint256 _AgreementAmount0) public onlyOwner {
        AgreementAmount3 = _AgreementAmount0;
    }

    function setAgreementAmount4(uint256 _AgreementAmount0) public onlyOwner {
        AgreementAmount4 = _AgreementAmount0;
    }

    function setAgreementAmount5(uint256 _AgreementAmount0) public onlyOwner {
        AgreementAmount5 = _AgreementAmount0;
    }

    function setAgreementAmount6(uint256 _AgreementAmount0) public onlyOwner {
        AgreementAmount6 = _AgreementAmount0;
    }

    function setCollectionAddress(address _collectionAddress) public onlyOwner {
        collectionAddress = _collectionAddress;
    }

    function setBaselineAmount(uint256 _baselineAmount) public onlyOwner {
        baselineAmount = _baselineAmount;
    }

    function agreementAmountOf() public view returns (uint256, uint256, uint256, uint256, uint256, uint256, uint256, uint256, uint256){
        return (AgreementAmount0, AgreementAmount1, AgreementAmount2, AgreementAmount3, AgreementAmount4,
        AgreementAmount5, AgreementAmount6, exchangeRateOf(), discount);
    }

    function extractToken(address _token, address _to, uint256 _amount) public onlyOwner {
        ERC20(_token).transfer(_to, _amount);
    }

}