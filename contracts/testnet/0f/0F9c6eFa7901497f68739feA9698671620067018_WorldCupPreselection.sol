pragma solidity ^0.8.0;
// SPDX-License-Identifier: GPL-3.0

import "./SafeMath.sol";
import "./SafeERC20.sol";
import "./Ownable.sol";

contract Invitation {
    function getInvitation(address user) external view returns (address inviter, address[] memory invitees) {}
}

contract WorldCup {
    function agreementTotalNumbers(address _msgSender) public view returns (uint256){}

    function exchangeRateOf() public view returns (uint256) {}

    function importSeedFromThird(uint256 number) public returns (uint256) {}
}

contract WorldCupQuiz {
    function setAgreements(address inviter, uint256 _amount, uint256 _rewardAmount) public {}

    function isBetContract() public view returns (bool) {}

    function isWithdrawContract() public view returns (bool) {}

}

contract InvitationAward {
    function isUser(address _msgSender) public view returns (bool) {}

    function userNumber(uint256 _time, address _msgSender) public view returns (uint256) {}

    function isUserReceive(uint256 _time, address _msgSender, uint256 _cid) public view returns (bool) {}

    function isUserWrite(address _msgSender, uint256 _cid) public view returns (bool) {}
}

contract WorldCupPreselection is Ownable {

    using SafeMath for uint256;
    using SafeERC20 for ERC20;

    ERC20 public usdtContract;
    ERC20 public wsdContract;
    Invitation public invitation;
    WorldCup public worldCup;
    WorldCupQuiz public worldCupQuiz;
    InvitationAward public award;
    //推荐是否领取
    mapping(address => bool) public isUser;

    //购买合同  可领取次数
    mapping(uint256 => mapping(address => uint256)) public userNumber;
    mapping(address => bool) public isUserNumber;
    mapping(uint256 => bool) public isCid;
    //购买合同  对应CID是否领取   false 为已领取
    mapping(uint256 => mapping(address => mapping(uint256 => bool))) public isUserReceive;

    mapping(address => mapping(uint256 => bool)) public isUserWrite;

    //是否开启 推荐领取
    bool public isOpenGift;

    //开启合同购买时间
    uint256 public openTime;
    //持续时间
    uint256 public openDay;

    //推荐购买金额
    uint256 public wsdAmount = 100 * 10 ** 18;

    //可写入数据地址
    address public userAmountOwner;

    mapping(uint256 => PreselectionInfo) public preselectionInfos;

    struct PreselectionInfo {
        string teams;
        uint256 stopTime;
        uint256 preselectionWithdrawAmount;
        uint256 preselectionAmount;
    }

    bool public isDistribute;
    uint256 public stopWithdrawTime;

    mapping(address => mapping(uint256 => mapping(string => uint256))) public  userPreselectionInfos;
    mapping(address => mapping(uint256 => mapping(string => bool))) public  userIsWithdraws;
    mapping(uint256 => mapping(string => uint256)) public  preselectionTeamAmount;
    mapping(uint256 => mapping(string => uint256)) public  preselectionNumber;
    //判断用户是否质押过
    mapping(uint256 => mapping(address => bool)) public isPledgePreselection;

    uint256 public upperLimitU = 1000000 * 10 ** 18;
    uint256 public lowerLimitU = 50 * 10 ** 18;

    uint256 public stopDay = 7;
    uint256 public allocationRatio = 87;
    uint256 public specialAmount;

    event BetUPreselection(address indexed _msgSender, string _teams, uint256 _amount, uint256 amount, uint256 _type, uint256 _time1);
    event BetWPreselection(address indexed _msgSender, string _teams, uint256 amount, uint256 _type, uint256 _time1);
    event BetPreselection(address indexed _msgSender, string _teams, uint256 uamount, uint256 amount, uint256 _type, uint256 _time1);
    event Rebate(address indexed _msgSender, address indexed _inviter, uint256 _type, uint256 _rebateAmount, uint256 _time);
    event WorldCupAgreement(address indexed _msgSender, address indexed _inviter, uint256 _type, uint256 _number, uint256 _amount, uint256 _rewardAmount, uint256 _time);
    event WorldCupAgreementWithdraw(address indexed _msgSender, address indexed _inviter, uint256 _type, uint256 _number, uint256 _amount, uint256 _rewardAmount, uint256 _time);
    event WorldCupAgreementBuyGift(address indexed _msgSender, address indexed _inviter, uint256 _cid, uint256 _number, uint256 _amount, uint256 _rewardAmount, uint256 _time);
    event WorldCupAgreementBuy(address indexed _msgSender, address indexed _inviter, uint256 _wsdAmount, uint256 _number, uint256 _amount, uint256 _rewardAmount, uint256 _time);

    event WithdrawPreselection(address indexed _msgSender, uint256 _type, string _teams, uint256 _amount, uint256 _time);
    event SetTeams(string _team, uint256 _type, uint256 _time);
    event SetStopTime(uint256 _stopTime, uint256 _type, uint256 _time);
    event SetIsDistribute(bool _isDistribute, uint256 _time);


    constructor(address _invitationContract, address _worldCup, address _award){
        invitation = Invitation(_invitationContract);
        worldCup = WorldCup(_worldCup);
        award = InvitationAward(_award);
    }


    //USDT下注      _type 0 32预测总冠军   1 8强预测  2 4四强预测  3 半决赛预测  4 总决赛    _teams选中国家的 ID  选中的  1   2 那么传  "12"
    // _amount传金额   1000u  那么传入  1000
    function betUPreselection(string memory _teams, uint256 _amount, uint256 _type) public nonReentrant {
        require(address(usdtContract) != address(0), "WorldCupPreselection: Token address not set!");
        _amount = _amount * 10 ** 18;
        require(_amount >= lowerLimitU && _amount <= upperLimitU, "WorldCupPreselection: Bet amount is not eligible!");
        usdtContract.transferFrom(msg.sender, address(this), _amount);
        uint256 amount = _amount.mul(worldCup.exchangeRateOf()).div(10 ** 18);
        _betPreselection(_teams, _amount, amount, _type);

        emit BetUPreselection(msg.sender, _teams, _amount, amount, _type, block.timestamp);
    }

    //WSD下注    _type 0 32预测总冠军   1 8强预测  2 4四强预测  3 半决赛预测  4 总决赛    _teams选中国家的 ID  选中的  1   2 那么传  "12"
    // _amount传金额   1000WSD  那么传入  1000
    function betWPreselection(string memory _teams, uint256 _amount, uint256 _type) public nonReentrant {
        require(address(wsdContract) != address(0), "WorldCupPreselection: Token address not set!");
        _amount = _amount * 10 ** 18;
        require(_amount >= lowerLimitU.mul(100) && _amount <= upperLimitU.mul(100), "WorldCupPreselection: Bet amount is not eligible!");
        wsdContract.transferFrom(msg.sender, address(this), _amount);

        _betPreselection(_teams, uint256(0), _amount, _type);
        emit BetWPreselection(msg.sender, _teams, _amount, _type, block.timestamp);
    }

    function _betPreselection(string memory _teams, uint256 _uAmount, uint256 _amount, uint256 _type) private {
        require(tx.origin == _msgSender(), "Cannot be called by external contract");
        PreselectionInfo storage pres = preselectionInfos[_type];

        require(pres.stopTime > block.timestamp.sub(600), "WorldCupPreselection: Staking has stopped!");

        if (!isPledgePreselection[_type][msg.sender]) {
            preselectionNumber[_type][_teams] += 1;
            isPledgePreselection[_type][msg.sender] = true;
        }

        userPreselectionInfos[msg.sender][_type][_teams] += _amount;
        preselectionTeamAmount[_type][_teams] += _amount;
        pres.preselectionAmount += _amount;
        rebate(_type, _amount, _type);
        emit BetPreselection(msg.sender, _teams, _uAmount, _amount, _type, block.timestamp);

    }

    //返佣奖励
    function rebate(uint256 _number, uint256 _amount, uint256 _type) private {

        (address inviter,) = invitation.getInvitation(msg.sender);
        uint256 number = 80;
        uint256 number2 = 2;
        for (uint256 i = 0; i < 7; i++) {
            if (inviter != address(0)) {
                if (number2 > 0) {
                    uint256 rebateAmount = _amount.mul(number2).div(100);
                    wsdContract.transfer(inviter, rebateAmount);
                    PreselectionInfo storage pres = preselectionInfos[_number];

                    pres.preselectionWithdrawAmount += rebateAmount;
                    number2 -= 1;

                    emit Rebate(msg.sender, inviter, _type, rebateAmount, block.timestamp);
                }
                //返合同
                if (worldCupQuiz.isBetContract()) {
                    uint256 agree = _amount.mul(6).div(100).mul(number).div(100);
                    worldCupQuiz.setAgreements(inviter, agree.div(100), agree);
                    emit WorldCupAgreement(msg.sender, inviter, _type, worldCup.agreementTotalNumbers(inviter), agree.div(100), agree, block.timestamp);

                    if (number > 50) {
                        number -= 10;
                    } else {
                        number = 10;
                    }

                }

                (inviter,) = invitation.getInvitation(inviter);

            } else {
                i = 1000;
            }
        }


    }

    function earningsPreselectionOf(address _msgSender, uint256 _type, string memory _teams) public view returns (uint256){
        uint256 earningsAmount;
        if (isDistribute) {
            if (keccak256(abi.encodePacked(_teams)) == keccak256(abi.encodePacked(preselectionInfos[_type].teams))) {
                uint256 amount = userPreselectionInfos[_msgSender][_type][_teams];
                if (amount > 0) {
                    PreselectionInfo storage pres = preselectionInfos[_type];
                    uint256 aaa = pres.preselectionAmount.add(specialAmount).mul(allocationRatio).div(100).mul(100000000000);
                    earningsAmount = aaa.div(preselectionTeamAmount[_type][_teams]).mul(amount);
                }
            }
        }

        return earningsAmount.div(100000000000);
    }

    function withdrawPreselection(uint256 _type, string memory _teams) public nonReentrant {
        require(tx.origin == _msgSender(), "Cannot be called by external contract");
        require(stopWithdrawTime.add(stopDay.mul(86400)) > block.timestamp, "WorldCupPreselection: The withdrawal time has passed");
        uint256 withdrawAmount;

        require(!userIsWithdraws[msg.sender][_type][_teams], "WorldCupPreselection: Earnings have been withdrawn!");
        withdrawAmount = earningsPreselectionOf(msg.sender, _type, _teams);
        userIsWithdraws[msg.sender][_type][_teams] = true;

        if (withdrawAmount > 0) {
            wsdContract.transfer(msg.sender, withdrawAmount);
            preselectionInfos[_type].preselectionWithdrawAmount += withdrawAmount;

            emit WithdrawPreselection(msg.sender, _type, _teams, withdrawAmount, block.timestamp);
        } else {
            if (worldCupQuiz.isWithdrawContract()) {
                uint256 agree = userPreselectionInfos[msg.sender][_type][_teams];

                worldCupQuiz.setAgreements(msg.sender, agree.div(100), agree);
                emit WorldCupAgreementWithdraw(msg.sender, msg.sender, _type, worldCup.agreementTotalNumbers(msg.sender), agree.div(100), agree, block.timestamp);
            }

        }

    }


    function buyContract() public nonReentrant {
        require(tx.origin == _msgSender(), "Cannot be called by external contract");
        require(isOpenGift, "Gift contract has not been opened yet!");

        if (!isUser[msg.sender]) {
            isUser[msg.sender] = award.isUser(msg.sender);
        }

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
        worldCupQuiz.setAgreements(msg.sender, amount / 100, amount);

        emit WorldCupAgreementBuy(msg.sender, msg.sender, wsdAmount, worldCup.agreementTotalNumbers(msg.sender), amount / 100, amount, block.timestamp);


    }

    function giftContract() public nonReentrant {
        require(tx.origin == _msgSender(), "Cannot be called by external contract");
        require(isOpenGift, "Gift contract has not been opened yet!");
        if (!isUser[msg.sender]) {
            isUser[msg.sender] = award.isUser(msg.sender);
        }

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
        worldCupQuiz.setAgreements(msg.sender, amount / 100, amount);

        isUser[msg.sender] = true;

        emit WorldCupAgreement(msg.sender, msg.sender, uint256(0), worldCup.agreementTotalNumbers(msg.sender), amount / 100, amount, block.timestamp);

    }

    function buyGiftContract(uint256 _cid) public nonReentrant {
        require(tx.origin == _msgSender(), "Cannot be called by external contract");
        require(openTime != 0, "No start time set");
        require(openTime < block.timestamp, "Event not started");
        uint256 _time = openDay * 86400 + openTime;
        require(_time > block.timestamp, "activity ends");
        if (!isUserNumber[msg.sender]) {
            userNumber[openTime][msg.sender] = award.userNumber(openTime, msg.sender);
            isUserNumber[msg.sender] = true;
        }
        if (!isCid[_cid]) {
            isUserReceive[openTime][msg.sender][_cid] = award.isUserReceive(openTime, msg.sender, _cid);
            isCid[_cid] = true;
        }

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
        worldCupQuiz.setAgreements(msg.sender, amount / 100, amount);

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

    function setUserAmount(address _msgSender, uint256 _cid) public nonReentrant {
        require(msg.sender == address(userAmountOwner), "Can only be called at a specific address!");
        if (!isUserWrite[_msgSender][_cid]) {
            isUserWrite[_msgSender][_cid] = award.isUserWrite(_msgSender, _cid);
        }

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
        stopWithdrawTime = block.timestamp;

        emit SetIsDistribute(_isDistribute, block.timestamp);
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

    function setSpecialAmount(uint256 _specialAmount) public onlyOwner {
        specialAmount = _specialAmount * 10 ** 18;
    }

    function setUsdtContract(address _token) public onlyOwner {
        usdtContract = ERC20(_token);
    }

    function setWsdContract(address _token) public onlyOwner {
        wsdContract = ERC20(_token);
    }

    function setWorldCupQuiz(address _worldCupQuiz) public onlyOwner {
        worldCupQuiz = WorldCupQuiz(_worldCupQuiz);
    }

    function extractToken(address _token, address _to, uint256 _amount) public onlyOwner {
        ERC20(_token).transfer(_to, _amount);
    }


}