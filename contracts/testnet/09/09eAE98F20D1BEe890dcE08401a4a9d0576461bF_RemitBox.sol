pragma solidity ^0.8.0;
// SPDX-License-Identifier: GPL-3.0

import "./SafeMath.sol";
import "./SafeERC20.sol";
import "./Ownable.sol";


contract Invitation {
    function getInvitation(address user) external view returns (address inviter, address[] memory invitees) {}
}

contract WorldCup {
    function generateNFT(address _msgSender) public returns (uint256){}

    function burnWhitelist(address _msgSender) public returns (bool){}

}

contract RemitBox is Ownable {
    using SafeMath for uint256;
    using SafeERC20 for ERC20;

    uint256 importSeed;


    uint256 public frequency = 5;
    mapping(address => uint256) public userFrequency;
    mapping(address => uint256) public userTime;
    mapping(address => mapping(address => uint256)) public userBuyTime;

    bool public isWithdraw;
    bool public isPledge;
    bool public isPledgeToken;

    address public destroyAddress;


    ERC20 public usdtContract;
    ERC20 public wsdContract;
    Invitation public invitation;
    WorldCup public worldCup;

    mapping(address => uint256) public tokenNumber;
    mapping(address => Agreement) public agreements;

    struct Agreement {
        uint256 currentAmount;
        uint256 rewardAmount;
        uint256 incomeAmount;
        uint256 withdrawalAmount;
        uint256 withdrawalTime;
        uint256 tokenAmount;
        uint256 userAmount;
        uint256 tokenGrade;
        uint256 tokenRate;

    }

    mapping(address => Raise) public userRaise;

    struct Raise {
        uint256 startTime;
        uint256 endTime;
        uint256 userNumber;
        uint256 calculateTime;
    }

    mapping(uint256 => LotteryInfo) public lotteryInfos;

    struct LotteryInfo {
        uint256 wheelTotal;
        uint256 wheelMaxWin;
        uint256 wheelNowWin;
        uint256 wheelCount;
    }


    event PurchaseAgreement(address indexed _msgSender, uint256 amount, uint256 _amount, uint256 _amounts, bool isWinning, uint256 number, uint256 _time);
    event Rebate(address indexed _msgSender, address indexed _inviter, uint256 _amount, uint _time);
    event Withdraw(address indexed _msgSender, uint256 _amount, uint256 _time);
    event Purchase(address indexed _msgSender, uint256 _amount, uint256 _time);
    event TokenId(address indexed _msgSender, uint256 _tokenId, uint256 _time);
    event ExtractToken(address indexed _msgSender, uint256 _userAmount, uint256 _time);
    event PledgeToken(address indexed _msgSender, uint256 _userAmount, uint256 _grade, uint256 _time);

    constructor(address _usdtContract, address _wsdContract, address _invitationContract, address _worldCup){
        usdtContract = ERC20(_usdtContract);
        wsdContract = ERC20(_wsdContract);
        worldCup = WorldCup(_worldCup);
        invitation = Invitation(_invitationContract);
    }

    function purchaseUSDT(uint256 amount) public nonReentrant {
        require(isPledge, "Purchase not opened!");
        uint256 _type;
        if (amount == 30) {
            _type = 1;
        } else if (amount == 50) {
            _type = 2;
        } else if (amount == 100) {
            _type = 3;
        } else if (amount == 500) {
            _type = 4;
        } else if (amount == 1000) {
            _type = 5;
        } else {
            require(false, "RemitBox: Incorrect amount entered!");
        }
        amount = amount * 10 ** 18;
        usdtContract.transferFrom(msg.sender, address(this), amount);
        _purchaseAgreement(amount, _type);
        emit Purchase(msg.sender, amount, block.timestamp);

    }

    function _purchaseAgreement(uint256 amount, uint256 _type) private {
        require(tx.origin == _msgSender(), "Cannot be called by external contract");

        //        uint256 _time = block.timestamp;

        require(userFrequency[msg.sender] < frequency, "no number of times!");
        if (userTime[msg.sender] <= 0) {
            userTime[msg.sender] = 1665763200;
        }

        uint256 diff = block.timestamp.sub(userTime[msg.sender]).div(86400);
        if (diff > 0) {
            userTime[msg.sender] += diff.mul(86400);
            userFrequency[msg.sender] = 0;
        }


        userFrequency[msg.sender] += 1;


        bool isWin = isWinning(_type);
        uint256 _amount;
        uint256 _amounts;
        uint256 number;
        Agreement storage agr = agreements[msg.sender];
        agr.currentAmount += amount;
        rebate(0);


        bool isSuper;
        Raise storage rai = userRaise[msg.sender];
        if (block.timestamp > rai.startTime && block.timestamp < rai.endTime) {
            isSuper = true;
        }

        if (agr.currentAmount >= 50000 * 10 ** 18) {
            number = 150;
        } else if (agr.currentAmount >= 20000 * 10 ** 18) {
            number = 140;
        } else if (agr.currentAmount >= 15000 * 10 ** 18) {
            number = 130;
        } else if (agr.currentAmount >= 10000 * 10 ** 18) {
            number = 125;
        } else if (agr.currentAmount >= 5000 * 10 ** 18) {
            number = 120;
        } else if (agr.currentAmount >= 3000 * 10 ** 18) {
            number = 115;
        } else if (agr.currentAmount >= 1000 * 10 ** 18) {
            number = 110;
        } else if (agr.currentAmount >= 500 * 10 ** 18) {
            number = 105;
        } else if (agr.currentAmount >= 50 * 10 ** 18) {
            number = 100;
        } else {
            number = 90;
        }


        if (isWin) {
            agr.tokenAmount += amount;
            agr.incomeAmount = stakeEarningsOf(msg.sender);
            agr.withdrawalTime = block.timestamp;
            if (isSuper) {
                number = number.mul(125);
                _amount = amount.mul(number).div(100);
            }else{
                _amount = amount.mul(number);
            }

            agr.rewardAmount += _amount;


        } else {
            agr.currentAmount -= amount;
            uint256 a = amount.mul(8);
            a = a.div(100);
            _amount = amount.add(a);
            usdtContract.transfer(msg.sender, _amount);

            rebate(a);
            if (isSuper) {
                _amounts = a.mul(25);
                _amounts = _amounts.div(100);
                usdtContract.transfer(msg.sender, _amounts);
            }

        }
        uint256 diff1 = agr.tokenAmount.div(500 * 10 ** 18);
        if (diff1 > 0) {
            agr.tokenAmount -= diff1.mul(500 * 10 ** 18);
            tokenNumber[msg.sender] += diff1;
        }
        emit PurchaseAgreement(msg.sender, amount, _amount, _amounts, isWin, number, block.timestamp);


    }

    function receiveNFT() public nonReentrant {
        require(tx.origin == _msgSender(), "Cannot be called by external contract");
        require(tokenNumber[msg.sender] > 0, "no number of times!");
        uint256 tokenId = worldCup.generateNFT(msg.sender);
        tokenNumber[msg.sender] -= 1;
        emit TokenId(msg.sender, tokenId, block.timestamp);
    }

    function isWinning(uint256 _type) private returns (bool isWin) {
        LotteryInfo storage lot = lotteryInfos[_type];
        if (lot.wheelTotal <= 0) {
            lot.wheelTotal = uint256(39);
            lot.wheelCount += uint256(1);
            lot.wheelNowWin = uint256(0);
            lot.wheelMaxWin = 8;
        } else {
            lot.wheelTotal -= uint256(1);
        }

        if (lot.wheelMaxWin == lot.wheelNowWin) {
            isWin = false;
            //must false
        } else if (lot.wheelMaxWin - lot.wheelNowWin >= lot.wheelTotal) {
            isWin = true;
            lot.wheelNowWin += uint256(1);
            // must true
        } else {
            uint256 randomNumber = importSeedFromThird(40);
            if (randomNumber < lot.wheelMaxWin) {
                isWin = true;
                lot.wheelNowWin += uint256(1);
            } else {
                isWin = false;
            }
        }

    }

    function rebate(uint256 _amount) private {
        (address inviter,) = invitation.getInvitation(msg.sender);
        uint256 number = 20;

        for (uint256 i = 0; i < 2; i++) {
            if (inviter != address(0)) {

                if (_amount <= 0) {
                    Raise  storage ra = userRaise[inviter];

                    if (ra.calculateTime <= 0) {
                        ra.calculateTime = 1665763200;
                    }

                    uint256 _a = 1800;
                    uint256 diff2 = block.timestamp.sub(ra.calculateTime).div(_a);
                    if (diff2 > 0) {
                        ra.calculateTime += diff2.mul(_a);
                        ra.userNumber = 0;

                    }
                    if (userBuyTime[inviter][msg.sender] <= 0) {
                        userBuyTime[inviter][msg.sender] = 1665763200;
                    }
                    uint256 asd = block.timestamp.sub(userBuyTime[inviter][msg.sender]).div(_a);
                    if (asd > 0) {
                        userBuyTime[inviter][msg.sender] += asd.mul(_a);
                        ra.userNumber += 1;
                        if (ra.userNumber >= 5) {
                            if (ra.startTime < block.timestamp) {
                                uint256 aaaa = block.timestamp.sub(ra.startTime).div(_a);
                                if (ra.startTime <= 0 || (aaaa > 0 && ra.endTime < block.timestamp)) {
                                    ra.startTime = ra.calculateTime.add(_a);
                                }

                                ra.endTime = ra.calculateTime.add(_a).add(_a);
                            }

                        }
                    }


                } else {
                    uint256 amount = _amount.mul(number).div(100);

                    if (amount > 0) {
                        usdtContract.transfer(inviter, amount);
                        emit Rebate(msg.sender, inviter, amount, block.timestamp);

                    }
                }


                (inviter,) = invitation.getInvitation(inviter);

                if (number > 10) {
                    number -= 10;
                }

            } else {
                i = 10;
            }

        }


    }

    function stakeEarningsOf(address _msgSender) public view returns (uint256){

        Agreement storage agr = agreements[_msgSender];
        uint256 stakeEarningsAmount = uint256(0);

        if (agr.rewardAmount > 0) {
            uint256 diff = block.timestamp.sub(agr.withdrawalTime);
            stakeEarningsAmount = agr.rewardAmount.mul(100000000).mul(agr.tokenRate).div(10000).div(86400);
            stakeEarningsAmount = stakeEarningsAmount.mul(diff).div(100000000);
            stakeEarningsAmount += agr.incomeAmount;

            if (stakeEarningsAmount >= agr.rewardAmount) {
                stakeEarningsAmount = agr.rewardAmount;
            }
        }

        return stakeEarningsAmount;
    }

    function withdraw() public nonReentrant {
        require(tx.origin == _msgSender(), "Cannot be called by external contract");
        require(isWithdraw, "Withdrawal not enabled!");
        Agreement storage agr = agreements[msg.sender];
        uint256 time_ = block.timestamp;
        uint256 amountWithdraw = stakeEarningsOf(msg.sender);
        if (amountWithdraw > 0) {
            uint256 amount = amountWithdraw.mul(5).div(100);
            uint256 _amount = amountWithdraw.sub(amount);
            wsdContract.safeTransfer(msg.sender, _amount);
            wsdContract.safeTransfer(destroyAddress, amount);
            agr.withdrawalTime = time_;
            agr.withdrawalAmount += amountWithdraw;
            agr.rewardAmount -= amountWithdraw;
            agr.incomeAmount = 0;
        }


        emit Withdraw(msg.sender, amountWithdraw, time_);

    }

    function pledgeToken(uint256 grade) public nonReentrant {
        require(tx.origin == _msgSender(), "Cannot be called by external contract");
        require(isPledgeToken, "RemitBox: Pledge not opened!");
        Agreement storage agr = agreements[msg.sender];
        require(agr.tokenGrade < grade, "RemitBox: The upgraded level cannot be less than the current level!");
        uint256 wsdAmount;
        if (grade == 1) {
            wsdAmount = 5000 * 10 ** 18;
            agr.tokenRate = 50;
        } else if (grade == 2) {
            wsdAmount = 10000 * 10 ** 18;
            agr.tokenRate = 100;
        } else if (grade == 3) {
            wsdAmount = 20000 * 10 ** 18;
            agr.tokenRate = 150;
        } else if (grade == 4) {
            wsdAmount = 50000 * 10 ** 18;
            agr.tokenRate = 200;
        } else if (grade == 5) {
            wsdAmount = 80000 * 10 ** 18;
            agr.tokenRate = 250;
        } else if (grade == 6) {
            wsdAmount = 100000 * 10 ** 18;
            agr.tokenRate = 300;
        } else {
            require(false, "RemitBox: Incorrect level entered!");
        }
        uint256 amount = wsdAmount.sub(agr.userAmount);
        agr.tokenGrade = grade;
        wsdContract.transferFrom(msg.sender, address(this), amount);
        agr.userAmount = wsdAmount;

        emit PledgeToken(msg.sender, amount, grade, block.timestamp);
    }

    function extractToken() public nonReentrant {
        require(tx.origin == _msgSender(), "Cannot be called by external contract");
        Agreement storage agr = agreements[msg.sender];
        wsdContract.transfer(msg.sender, agr.userAmount);
        require(agr.userAmount > 0, "No amount to withdraw!");
        agr.incomeAmount = stakeEarningsOf(msg.sender);
        agr.withdrawalTime = block.timestamp;

        emit ExtractToken(msg.sender, agr.userAmount, block.timestamp);
        agr.userAmount = 0;
        agr.tokenRate = 0;
        agr.tokenGrade = 0;

    }


    function importSeedFromThird(uint256 number) public returns (uint256) {
        importSeed += 1;
        return
        uint256(keccak256(abi.encodePacked(block.timestamp, block.difficulty, importSeed))) % number;
    }

    function setIsWithdraw(bool _isWithdraw) public onlyOwner {
        isWithdraw = _isWithdraw;
    }

    function setIsPledge(bool _isPledge) public onlyOwner {
        isPledge = _isPledge;
    }

    function setIsPledgeToken(bool _isPledgeToken) public onlyOwner {
        isPledgeToken = _isPledgeToken;
    }

    function setDestroyAddress(address _destroyAddress) public onlyOwner {
        destroyAddress = _destroyAddress;
    }

    function setFrequency(uint256 _frequency) public onlyOwner {
        frequency = _frequency;
    }


    function extractToken(address _token, address _to, uint256 _amount) public onlyOwner {
        ERC20(_token).transfer(_to, _amount);
    }

}