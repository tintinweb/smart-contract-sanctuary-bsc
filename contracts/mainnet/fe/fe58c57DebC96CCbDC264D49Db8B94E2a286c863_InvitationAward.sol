pragma solidity ^0.8.0;

// SPDX-License-Identifier: GPL-3.0

import "./Ownable.sol";

contract Invitation {
    function getInvitation(address user) external view returns (address inviter, address[] memory invitees) {}
}

contract WorldCup {
    function setAgreements(address _msgSender, uint256 _amount, uint256 _rewardAmount) public {}

    function agreementTotalNumbers(address _msgSender) public view returns (uint256){}

    function importSeedFromThird(uint256 number) public returns (uint256) {}
}


interface ERC20 {
    function transfer(address recipient, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

}


contract InvitationAward is Ownable {
    Invitation public invitation;
    WorldCup public worldCup;
    ERC20 public wsdContract;


    //推荐是否领取
    mapping(address => bool) public isUser;

    //购买合同  可领取次数
    mapping(uint256 => mapping(address => uint256)) public userNumber;
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

    event WorldCupAgreement(address indexed _msgSender, address indexed _inviter, uint256 _type, uint256 _number, uint256 _amount, uint256 _rewardAmount, uint256 _time);
    event WorldCupAgreementBuyGift(address indexed _msgSender, address indexed _inviter, uint256 _cid, uint256 _number, uint256 _amount, uint256 _rewardAmount, uint256 _time);
    event WorldCupAgreementBuy(address indexed _msgSender, address indexed _inviter, uint256 _wsdAmount, uint256 _number, uint256 _amount, uint256 _rewardAmount, uint256 _time);

    constructor(address _invitationContract, address _worldCup, address _wsdContract){
        invitation = Invitation(_invitationContract);
        worldCup = WorldCup(_worldCup);
        wsdContract = ERC20(_wsdContract);
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

    function setUserAmount(address _msgSender, uint256 _cid) public nonReentrant {
        require(msg.sender == address(userAmountOwner), "Can only be called at a specific address!");
        require(!isUserWrite[_msgSender][_cid], "data already exists");
        userNumber[openTime][_msgSender] += 1;
        isUserReceive[openTime][_msgSender][_cid] = true;
        isUserWrite[_msgSender][_cid] = true;

    }

    function extractToken(address _token, address _to, uint256 _amount) public onlyOwner {
        ERC20(_token).transfer(_to, _amount);
    }

}