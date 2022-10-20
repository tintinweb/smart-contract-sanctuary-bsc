pragma solidity ^0.8.0;
// SPDX-License-Identifier: GPL-3.0


import "./WorldCupMode.sol";

contract WorldCup is WorldCupMode {
    using SafeMath for uint256;
    using SafeERC20 for ERC20;

    constructor(){}

    function purchaseUSDT(uint256 _number) public nonReentrant {
        require(isPurchaseUSDT, "Purchase not opened!");
        uint256 amount = AgreementAmount0 * _number;
        usdtContract.transferFrom(msg.sender, address(this), amount);
        _purchaseAgreement(_number);
        rebate(amount, uint256(1));

        emit Purchase(msg.sender, uint256(1), amount, block.timestamp);

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

        emit Purchase(msg.sender, uint256(2), amount, block.timestamp);
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

                if (incomesTime[inviter][msg.sender] <= 0) {
                    incomesTime[inviter][msg.sender] = _timeRefresh;
                }

                uint256 diff1 = block.timestamp.sub(incomesTime[inviter][msg.sender]).div(_timeToday);

                if (diff1 > 0) {
                    incomes[inviter][msg.sender] = 0;
                    incomesTime[inviter][msg.sender] += diff1.mul(_timeToday);
                }

                uint256 amount = _amount;
                if (validNumber[inviter] >= i + 1 || validNumber[inviter] >= 5) {
                    if (agreementTotalNumbers[inviter] > 0) {
                        bool isLevelBurn;
                        if (isOpenEqual) {
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
                        }


                        if (!isLevelBurn) {
                            if (!burnWhitelist[inviter]) {
                                if (agrAmountInviter.purchaseAgreementAmount > incomes[inviter][msg.sender]) {
                                    uint256 burn = agrAmountInviter.purchaseAgreementAmount.sub(incomes[inviter][msg.sender]);
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
                                    incomes[inviter][msg.sender] += amount;
                                } else {
                                    incomes[inviter][msg.sender] += amount.mul(10 ** wsdContract.decimals()).div(exchangeRateOf());
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

        uint256[] memory tokenIds =agreementOrderTokens[msg.sender][agrOrderId];
        require(!agrOrder.isStart, "Mining needs to be suspended first!");
        require(!agrOrder.isPledgeNFT, "The current contract is activated!");
        require(tokenIds.length <= 0, "There are also NFTs that have not been cancelled!");
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
            uint256[] memory tokenIds =agreementOrderTokens[msg.sender][agr.orderId];
            require(agrOrder.isPledgeNFT, "You need to put the main NFT first!");
            require(tokenIds.length < 10, "limit reached!");
            agreementOrderTokens[msg.sender][agr.orderId].push(tokenId);
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
        uint256[] memory tokenIds =agreementOrderTokens[msg.sender][number];
        isTokenId[tokenId] = uint256(0);
        if (agrOrder.tokenId == tokenId) {
            require(agrOrder.isPledgeNFT, "No NFTs added!");
            agrOrder.tokenId = 0;
            agrOrder.isPledgeNFT = false;
            agrOrder.rateOfReturn -= 50 * 10000;

        } else {

            require(tokenIds.length > 0, "limit reached!");
            for (uint256 i = 0; i < tokenIds.length; i++) {
                if (tokenIds[i] == tokenId) {
                    tokenIds[i] = tokenIds[tokenIds.length - 1];
                    agreementOrderTokens[msg.sender][number].pop();
                    i = tokenIds.length;
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

        if (!agrOrder.isPledgeNFT && tokenIds.length <= 0) {
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
        uint256[] memory tokenIds =agreementOrderTokens[msg.sender][orderId];
        isTokenId[tokenId] = uint256(0);
        if (agrOrder.tokenId == tokenId) {
            require(agrOrder.isPledgeNFT, "No NFTs added!");
            agrOrder.tokenId = _tokenId;

        } else {
            require(tokenIds.length > 0, "limit reached!");
            for (uint256 i = 0; i < tokenIds.length; i++) {
                if (tokenIds[i] == tokenId) {
                    tokenIds[i] = _tokenId;
                    i = tokenIds.length;
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

    function stakeEarningsOf(address _msgSender, uint256 agreementId) public override view returns (uint256){

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
        require(agreementId != _agreementId, "cannot be the same contract!");

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

        if (agrAmount.purchaseTime <= 0) {
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
        require(agreementsOwner[msg.sender], "Can only be called at a specific address!");
        agreementTotalNumbers[_msgSender] += 1;
        Agreement storage agreement = agreements[_msgSender][agreementTotalNumbers[_msgSender]];
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
        require(operableAddress[msg.sender], "Can only be called at a specific address!");
        (tokenId,) = _generateNFT(_msgSender);

        return tokenId;
    }

    function setOperableAddress(address _address,bool _isOperable) public onlyOwner {
        operableAddress[_address] = _isOperable;
    }



    function importSeedFromThird(uint256 number) public returns (uint256) {
        importSeed += 1;
        return
        uint256(keccak256(abi.encodePacked(block.timestamp, block.difficulty, importSeed))) % number;
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


    function setIsOpenEqual(bool _isOpenEqual) public onlyOwner {
        isOpenEqual = _isOpenEqual;
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
        emit SetBurnWhitelist(_msgSender, _number, block.timestamp);
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


    function setAgreementsOwner(address _msgSender, bool _isOwner) public onlyOwner {
        agreementsOwner[_msgSender] = _isOwner;
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


    function setContractAddress(address _USDTContract, address _wsdContract, address _NFTContract, address _invitationContract) public onlyOwner {
        usdtContract = ERC20(_USDTContract);
        wsdContract = ERC20(_wsdContract);
        NFTContract = INft(_NFTContract);
        invitation = Invitation(_invitationContract);
    }


    function extractToken(address _token, address _to, uint256 _amount) public onlyOwner {
        ERC20(_token).transfer(_to, _amount);
    }

}