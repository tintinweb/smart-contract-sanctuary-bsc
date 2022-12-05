pragma solidity ^0.8.0;
// SPDX-License-Identifier: GPL-3.0

import "./WorldCupPreselectionMode.sol";

contract WorldCupPreselection is WorldCupPreselectionMode {
    using SafeMath for uint256;
    using SafeERC20 for ERC20;



    constructor(){}

    function betUPreselection(string memory _teams, uint256 _amount, uint256 _type) public nonReentrant {
        require(address(usdtContract) != address(0), "WorldCupPreselection: Token address not set!");
        _amount = _amount * 10 ** 18;
        require(_amount >= lowerLimitU && _amount <= upperLimitU, "WorldCupPreselection: Bet amount is not eligible!");
        usdtContract.transferFrom(msg.sender, address(this), _amount);
        uint256 amount = _amount.mul(worldCup.exchangeRateOf()).div(10 ** 18);
        _betPreselection(_teams, _amount, amount, _type, uint256(1));

    }


    function _betPreselection(string memory _teams, uint256 _uAmount, uint256 _amount, uint256 _type, uint256 a) private {
        require(tx.origin == _msgSender(), "Cannot be called by external contract");
        PreselectionInfo storage pres = preselectionInfos[_type];

        require(pres.stopTime > block.timestamp.sub(600), "WorldCupPreselection: Staking has stopped!");

        if (!isPledgePreselection[_type][msg.sender]) {
            preselectionNumber[_type][_teams] += 1;
            isPledgePreselection[_type][msg.sender] = true;
        }

        userPreselectionInfos[msg.sender][_type][_teams] += _uAmount;
        preselectionTeamAmount[_type][_teams] += _uAmount;
        pres.preselectionAmount += _uAmount;
        rebate(_type, _uAmount, _type);
        emit BetPreselection(msg.sender, _teams, _uAmount, _amount, _type, a, block.timestamp);

    }


    function rebate(uint256 _number, uint256 _amount, uint256 _type) private {

        (address inviter,) = invitation.getInvitation(msg.sender);
      
        uint256 number2 = 2;
        for (uint256 i = 0; i < 2; i++) {
            if (inviter != address(0)) {
                if (number2 > 0) {
                    uint256 rebateAmount = _amount.mul(number2).div(100);
                    uint256 amount = rebateAmount;
                    usdtContract.transfer(inviter, amount);
                    PreselectionInfo storage pres = preselectionInfos[_number];

                    pres.preselectionWithdrawAmount += rebateAmount;
                    number2 -= 1;

                    emit Rebate(msg.sender, inviter, _type, amount, block.timestamp);
                }

                (inviter,) = invitation.getInvitation(inviter);

            } else {
                i = 1000;
            }
        }


    }


    function withdrawPreselection(uint256 _type, string memory _teams) public nonReentrant {
        require(tx.origin == _msgSender(), "Cannot be called by external contract");
        require(stopWithdrawTime.add(stopDay.mul(86400)) > block.timestamp, "WorldCupPreselection: The withdrawal time has passed");
        uint256 withdrawAmount;

        require(!userIsWithdraws[msg.sender][_type][_teams], "WorldCupPreselection: Earnings have been withdrawn!");
        withdrawAmount = earningsPreselectionOf(msg.sender, _type, _teams);
        userIsWithdraws[msg.sender][_type][_teams] = true;

        if (withdrawAmount > 0) {
            usdtContract.transfer(msg.sender, withdrawAmount);
            preselectionInfos[_type].preselectionWithdrawAmount += withdrawAmount;

            emit WithdrawPreselection(msg.sender, _type, _teams, withdrawAmount, block.timestamp);
        } else {
            if(isWithdrawContract){
                uint256 amount = userPreselectionInfos[msg.sender][_type][_teams];
                if (amount >= wAmount) {
                    uint256 tokenId = worldCup.generateNFT(msg.sender);
                    require(tokenId > 0, "11");
                    emit WorldCupNFT(msg.sender, _type, _teams, tokenId, block.timestamp);

                }

            }

        }

    }


    function buyContract() public nonReentrant {
        require(tx.origin == _msgSender(), "Cannot be called by external contract");
        require(isOpenGift, "Gift contract has not been opened yet!");

        require(!isUser[msg.sender], "Rewards already received!");
        wsdContract.transferFrom(msg.sender, address(this), wsdAmount);

        uint256 amount;
        uint256 number = worldCup.importSeedFromThird(1000);
        if (number == 999) {
            amount = 50000;
        } else if (number > 996) {
            amount = 30000;
        } else if (number > 978) {
            amount = 20000;
        } else if (number > 949) {
            amount = 10000;
        } else if (number > 899) {
            amount = 5000;
        } else {
            amount = 3000;
        }
        isUser[msg.sender] = true;
        amount = amount * 10 ** 18;
        worldCup.setAgreements(msg.sender, amount / 100, amount);

        emit WorldCupAgreementBuy(msg.sender, msg.sender, wsdAmount, worldCup.agreementTotalNumbers(msg.sender), amount / 100, amount, block.timestamp);


    }

    function giftContract() public nonReentrant {
        require(tx.origin == _msgSender(), "Cannot be called by external contract");
        require(isOpenGift, "Gift contract has not been opened yet!");
        require(!isUser[msg.sender], "Rewards already received!");
        (address inviter,) = invitation.getInvitation(msg.sender);
        require(inviter != address(0), "No inviter bound!");

        uint256 amount;
        uint256 number = worldCup.importSeedFromThird(1000);
        if (number == 999) {
            amount = 30000;
        } else if (number > 996) {
            amount = 10000;
        } else if (number > 978) {
            amount = 8000;
        } else if (number > 949) {
            amount = 5000;
        } else if (number > 899) {
            amount = 3000;
        } else {
            amount = 1000;
        }

        amount = amount * 10 ** 18;
        worldCup.setAgreements(msg.sender, amount / 100, amount);

        isUser[msg.sender] = true;

        emit WorldCupAgreement(msg.sender, msg.sender, uint256(0), worldCup.agreementTotalNumbers(msg.sender), amount / 100, amount, block.timestamp);

    }

    function buyGiftContract(uint256 _cid) public nonReentrant {
        require(tx.origin == _msgSender(), "Cannot be called by external contract");
        require(openTime != 0, "No start time set");
        require(openTime < block.timestamp, "Event not started");
        uint256 _time = openDay * 86400 + openTime;
        require(_time > block.timestamp, "activity ends");
        require(userNumber[openTime][msg.sender] > 0, "no number of times");
        require(isUserReceive[openTime][msg.sender][_cid], "This id is not available");

        uint256 amount;
        uint256 number = worldCup.importSeedFromThird(1000);
        if (number == 999) {
            amount = 100000;
        } else if (number > 996) {
            amount = 50000;
        } else if (number > 978) {
            amount = 10000;
        } else if (number > 949) {
            amount = 5000;
        } else if (number > 909) {
            amount = 3000;
        } else if (number > 849) {
            amount = 2000;
        } else {
            amount = 1000;
        }


        amount = amount * 10 ** 18;
        worldCup.setAgreements(msg.sender, amount / 100, amount);

        userNumber[openTime][msg.sender] -= 1;
        isUserReceive[openTime][msg.sender][_cid] = false;

        emit WorldCupAgreementBuyGift(msg.sender, msg.sender, _cid, worldCup.agreementTotalNumbers(msg.sender), amount / 100, amount, block.timestamp);


    }

    function setIsOpenGift(bool _isOpen) public onlyOwner {
        isOpenGift = _isOpen;
    }


    function setWsdAmount(uint256 _wsdAmount) public onlyOwner {
        wsdAmount = _wsdAmount * 10 ** 18;
    }

    function setOpenDay(uint256 _openDay) public onlyOwner {
        openDay = _openDay;
    }

    function setOpenTime(uint256 _openTime) public onlyOwner {
        openTime = _openTime;
    }

    function setUserAmountOwner(address _userAmountOwner) public onlyOwner {
        userAmountOwner = _userAmountOwner;
    }

    function setIsWithdrawContract(bool _isWithdrawContract) public onlyOwner {
        isWithdrawContract = _isWithdrawContract;
    }

    function setUserAmount(address _msgSender, uint256 _cid) public nonReentrant {
        require(msg.sender == address(userAmountOwner), "Can only be called at a specific address!");
        require(!isUserWrite[_msgSender][_cid], "data already exists");
        userNumber[openTime][_msgSender] += 1;
        isUserReceive[openTime][_msgSender][_cid] = true;
        isUserWrite[_msgSender][_cid] = true;

    }


    function setTeams(string memory _team, uint256 _type) public onlyOwner {
        preselectionInfos[_type].teams = _team;

        emit SetTeams(_team, _type, block.timestamp);
    }

    function setStopTime(uint256 _stopTime, uint256 _type) public onlyOwner {
        preselectionInfos[_type].stopTime = _stopTime;
        emit SetStopTime(_stopTime, _type, block.timestamp);

    }

    function setIsDistribute(bool _isDistribute) public onlyOwner {
        isDistribute = _isDistribute;
        if (_isDistribute) {
            stopWithdrawTime = block.timestamp;
        } else {
            stopWithdrawTime = 0;
        }


        emit SetIsDistribute(_isDistribute, block.timestamp);
    }

    function setDestroy(uint256 _type) public onlyOwner {
        uint256 amount;
        if (!isDestroy[_type]) {
            PreselectionInfo storage pres = preselectionInfos[_type];
            amount = pres.preselectionAmount.div(10);
            usdtContract.transfer(address(0x38B0cE82EE40b9Fa44149229dc454d0DE17F1f22), amount);
            isDestroy[_type] = true;
        }
    }

    function setLimitUs(uint256 _lowerLimitU, uint256 _upperLimitU) public onlyOwner {
        lowerLimitU = _lowerLimitU * 10 ** 18;
        upperLimitU = _upperLimitU * 10 ** 18;
    }

    function setStopDay(uint256 _stopDay) public onlyOwner {
        stopDay = _stopDay;
    }

    function setAllocationRatio(uint256 _allocationRatio) public onlyOwner {
        allocationRatio = _allocationRatio;
    }


    function setWAmount(uint256 _wAmount) public onlyOwner {
        wAmount = _wAmount * 10 ** 18;
    }

    function setSpecialAmount(uint256 _type, uint256 _specialAmount) public onlyOwner {
        specialAmount[_type] = _specialAmount * 10 ** 18;
    }

    function setUsdtContract(address _token) public onlyOwner {
        usdtContract = ERC20(_token);
    }

    function setWsdContract(address _token) public onlyOwner {
        wsdContract = ERC20(_token);
    }


    function extractToken(address _token, address _to, uint256 _amount) public onlyOwner {
        ERC20(_token).transfer(_to, _amount);
    }

    function setContract(address _invitationContract, address _worldCup) public onlyOwner {
        invitation = Invitation(_invitationContract);
        worldCup = WorldCup(_worldCup);
    }


}