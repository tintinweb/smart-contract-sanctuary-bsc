pragma solidity ^0.8.0;
// SPDX-License-Identifier: GPL-3.0

import "./SafeMath.sol";
import "./SafeERC20.sol";
import "./Ownable.sol";


contract INft {

    function mint(address recipient_, uint level) external returns (uint256){}

    function isApprovedOrOwner(address spender, uint256 tokenId) public view returns (bool){}

    function transferFrom(address from, address to, uint256 tokenId) public virtual {}

    function information(uint256 tokenId) public view returns (string memory, string memory){}

}

contract Invitation {
    function getInvitation(address user) external view returns (address inviter, address[] memory invitees) {}

}

contract PledgeSale {
    function isSellOf(uint256 tokenId) public view returns (bool){}
}

contract WorldCup {
    function isTokenId(uint256 tokenId) public view returns (uint256){}

    function agreementTotalNumbers(address _msgSender) public view returns (uint256){}

    function exchangeRateOf() public view returns (uint256) {}

    function setAgreements(address _msgSender, uint256 _amount, uint256 _rewardAmount) public {}
}

contract WorldCupQuiz is Ownable {
    using SafeMath for uint256;
    using SafeERC20 for ERC20;

    ERC20 public usdtContract;
    ERC20 public wsdContract;
    INft public nftContract;
    Invitation public invitation;
    PledgeSale public pledgeSale;
    WorldCup public worldCup;

    mapping(address => bool) public isOwner;
    uint256 public upperLimitU = 1000000 * 10 ** 18;
    uint256 public lowerLimitU = 50 * 10 ** 18;

    uint256 public stopDay = 7;
    uint256 public allocationRatio = 87;

    bool public isBetContract;
    bool public isWithdrawContract;

    mapping(uint256 => mapping(uint256 => uint256)) public playerGoals;
    mapping(uint256 => uint256[]) public playerId;
    mapping(uint256 => uint256[]) public playerIdGoals;

    mapping(uint256 => mapping(uint256 => uint256)) public playerIdNumber;
    mapping(uint256 => mapping(uint256 => uint256)) public playerNumber;
    mapping(uint256 => uint256) public playerUserNumberA;
    mapping(uint256 => uint256) public playerUserNumberB;
    mapping(address => mapping(uint256 => bool)) public is11FullA;
    mapping(address => mapping(uint256 => bool)) public is11FullB;
    mapping(uint256 => address) public tokenIdAddress;
    mapping(uint256 => mapping(uint256 => uint256)) public tokenIdNumber;
    mapping(uint256 => mapping(address => bool)) public isPledge;

    mapping(uint256 => ScreeningsInfo) public screeningsInfos;

    struct ScreeningsInfo {
        uint64 teamA;
        uint64 teamB;
        uint64 goalsA;
        uint64 goalsB;
        uint256 contestType;
        string grouping;
        bool isDistribute;
        uint256 stopWithdraw;
        uint256 stopBetting;
    }

    mapping(uint256 => ScreeningsInfo2) public screeningsInfos2;

    struct ScreeningsInfo2 {
        uint256 totalGoals;
        uint256 totalNumber;
        uint256 totalAmount;
        uint256 withdrawAmount;
    }

    mapping(address => mapping(uint256 => UserBetTokenIdInfo)) userBetTokenIdInfos;

    struct UserBetTokenIdInfo {
        mapping(uint256 => bool) isWithdrawTotalGoal;
        mapping(uint256 => bool) isWithdrawResult;
        mapping(uint256 => mapping(uint256 => bool)) isWithdrawGals;
        uint256[] tokenIdsA;
        uint256[] tokenIdsB;
        bool isWithdrawNFT;
    }

    mapping(address => mapping(uint256 => BetInfo)) public userBetInfosW;
    mapping(uint256 => BetInfo) screeningsBetInfosW;

    struct BetInfo {
        mapping(uint256 => uint256) totalGoalAmount;
        mapping(uint256 => uint256) resultAmount;
        mapping(uint256 => mapping(uint256 => uint256)) goalsAmount;
        uint256 totalGoalWithdrawAmount;
        uint256 resultWithdrawAmount;
        uint256 goalsWithdrawAmount;
        uint256 totalGoalAmounts;
        uint256 resultAmounts;
        uint256 goalsAmounts;
    }


    event SetPlayerGoals(uint256 _number, uint256 _name, uint256 _goal, uint256 _time1);
    event SetTotalGoals(uint256 number, uint256 _totalGoals, uint256 _time1);
    event SetScreeningsInfoTeam(uint256 _number, uint256 teamA, uint256 teamB, uint256 _time1);
    event SetScreeningsInfoGoals(uint256 _number, uint256 goalsA, uint256 goalsB, uint256 _time1);
    event SetScreeningsInfoStopBetting(uint256 _number, uint256 stopBetting, uint256 _time1);
    event SetScreeningsInfoIsDistribute(uint256 _number, bool _isDistribute, uint256 _time1);
    event SetContestType(uint256 _number, uint256 _contestType, uint256 _time1);
    event SetGrouping(uint256 _number, string _grouping, uint256 _time1);
    event BetU(address indexed _msgSender, uint256 _number, uint256 _amount, uint256 amount, uint256 _betType, uint256 _time1);
    event BetW(address indexed _msgSender, uint256 _number, uint256 amount, uint256 _betType, uint256 _time1);
    event Bet(address indexed _msgSender, uint256 _number, uint256 uamount, uint256 amount, uint256 _goalA, uint256 _goalB, uint256 _betType, uint256 _time1);
    event PledgeNFT(address indexed _msgSender, uint256 _number, uint256[] _tokenId, uint256 _type, uint256 _time1);
    event ReplacePledge(address indexed _msgSender, uint256 _tokenId, uint256 __tokenId, uint256 number, uint256 _type, uint256 _time);
    event RemoveNFT(address indexed _msgSender, uint256 _tokenId, uint256 number, uint256 _type, uint256 _time);
    event RemoveAllNFT(address indexed _msgSender, uint256 _number, uint256 _type, uint256 _time);
    event Withdraw(address indexed _msgSender, uint256 _number, uint256 _betType, uint256 _amount, uint256 _time);
    event WorldCupAgreement(address indexed _msgSender, address indexed _inviter, uint256 number, uint256 _number, uint256 _amount, uint256 _rewardAmount, uint256 _time);
    event WorldCupAgreementWithdraw(address indexed _msgSender, address indexed _inviter, uint256 number, uint256 _number, uint256 _amount, uint256 _rewardAmount, uint256 _time);
    event Rebate(address indexed _msgSender, address indexed _inviter, uint256 _number, uint256 _rebateAmount, uint256 _time);


    constructor(address _invitationContract, address _pledgeSale, address _worldCup){
        invitation = Invitation(_invitationContract);
        pledgeSale = PledgeSale(_pledgeSale);
        worldCup = WorldCup(_worldCup);
    }

    function betU(uint256 _number, uint256 _goalA, uint256 _goalB, uint256 _amount, uint256 _betType) public nonReentrant {
        require(address(usdtContract) != address(0), "WorldCupQuiz: Token address not set!");
        _amount = _amount * 10 ** 18;
        require(_amount >= lowerLimitU && _amount <= upperLimitU, "WorldCupQuiz: Bet amount is not eligible!");
        usdtContract.transferFrom(msg.sender, address(this), _amount);
        uint256 amount = _amount.mul(worldCup.exchangeRateOf()).div(10 ** 18);
        _bet(_number, _goalA, _goalB, _amount, amount, _betType);

        emit BetU(msg.sender, _number, _amount, amount, _betType, block.timestamp);
    }

    function betW(uint256 _number, uint256 _goalA, uint256 _goalB, uint256 _amount, uint256 _betType) public nonReentrant {
        require(address(wsdContract) != address(0), "WorldCupQuiz: Token address not set!");
        _amount = _amount * 10 ** 18;
        require(_amount >= lowerLimitU.mul(100) && _amount <= upperLimitU.mul(100), "WorldCupQuiz: Bet amount is not eligible!");
        wsdContract.transferFrom(msg.sender, address(this), _amount);

        _bet(_number, _goalA, _goalB, 0, _amount, _betType);
        emit BetW(msg.sender, _number, _amount, _betType, block.timestamp);
    }

    function _bet(uint256 _number, uint256 _goalA, uint256 _goalB, uint256 _uAmount, uint256 _amount, uint256 _betType) private {
        require(tx.origin == _msgSender(), "Cannot be called by external contract");
        ScreeningsInfo storage scc = screeningsInfos[_number];
        ScreeningsInfo2 storage sc2 = screeningsInfos2[_number];
        require(block.timestamp < scc.stopBetting.sub(600), "WorldCupQuiz: Staking has stopped!");

        BetInfo storage betInfoScreenings = screeningsBetInfosW[_number];
        BetInfo storage betInfoUser = userBetInfosW[msg.sender][_number];

        if (_betType == 1) {
            betInfoScreenings.resultAmounts += _amount;
            betInfoScreenings.resultAmount[_goalA] += _amount;
            betInfoUser.resultAmount[_goalA] += _amount;
        } else if (_betType == 2) {
            betInfoScreenings.totalGoalAmounts += _amount;
            betInfoScreenings.totalGoalAmount[_goalA] += _amount;
            betInfoUser.totalGoalAmount[_goalA] += _amount;
        } else if (_betType == 3) {
            betInfoScreenings.goalsAmounts += _amount;
            betInfoScreenings.goalsAmount[_goalA][_goalB] += _amount;
            betInfoUser.goalsAmount[_goalA][_goalB] += _amount;
        } else {
            require(false, "WorldCupQuiz: Please enter the correct type!");
        }
        sc2.totalAmount += _amount;

        if (!isPledge[_number][msg.sender]) {
            sc2.totalNumber += 1;
        }
        isPledge[_number][msg.sender] = true;

        rebate(_number, _amount, _betType);

        emit Bet(msg.sender, _number, _uAmount, _amount, _goalA, _goalB, _betType, block.timestamp);

    }

    function rebate(uint256 _number, uint256 _amount, uint256 _betType) private {
        BetInfo storage betInfoScreenings = screeningsBetInfosW[_number];
        (address inviter,) = invitation.getInvitation(msg.sender);
        uint256 number = 80;
        uint256 number2 = 2;
        ScreeningsInfo2 storage scc2 = screeningsInfos2[_number];
        for (uint256 i = 0; i < 7; i++) {
            if (inviter != address(0)) {
                if (number2 > 0) {
                    uint256 rebateAmount = _amount.mul(number2).div(100);
                    wsdContract.transfer(inviter, rebateAmount);
                    scc2.withdrawAmount += rebateAmount;
                    number2 -= 1;
                    if (_betType == 1) {
                        betInfoScreenings.resultWithdrawAmount += rebateAmount;
                    } else if (_betType == 2) {
                        betInfoScreenings.totalGoalWithdrawAmount += rebateAmount;
                    } else if (_betType == 3) {
                        betInfoScreenings.goalsWithdrawAmount += rebateAmount;
                    }
                    emit Rebate(msg.sender, inviter, _number, rebateAmount, block.timestamp);
                }
                if (isBetContract) {
                    uint256 agree = _amount.mul(6).div(100);
                    agree = agree.mul(number).div(100);
                    _setAgreements(inviter, agree.div(100), agree);
                    emit WorldCupAgreement(msg.sender, inviter, _number, worldCup.agreementTotalNumbers(inviter), agree.div(100), agree, block.timestamp);

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

    function _setAgreements(address inviter, uint256 _amount, uint256 _rewardAmount) private {
        worldCup.setAgreements(inviter, _amount, _rewardAmount);
    }

    function setAgreements(address inviter, uint256 _amount, uint256 _rewardAmount) public {
        require(isOwner[msg.sender], "Can only be called at a specific address!");
        _setAgreements(inviter, _amount, _rewardAmount);
    }

    function pledgeNFT(uint256 _number, uint256[] memory _tokenId, uint256 _type) public nonReentrant {
        require(tx.origin == _msgSender(), "Cannot be called by external contract");
        ScreeningsInfo storage scc = screeningsInfos[_number];
        //停止质押时间
        require(block.timestamp < scc.stopBetting.sub(600), "WorldCupQuiz: Staking has stopped!");
        UserBetTokenIdInfo storage userTokenIds = userBetTokenIdInfos[msg.sender][_number];

        for (uint256 i = 0; i < _tokenId.length; i++) {
            require(nftContract.isApprovedOrOwner(msg.sender, _tokenId[i]), "ERC721: transfer caller is not owner nor approved");
            require(worldCup.isTokenId(_tokenId[i]) <= 0, "WorldCupQuiz: NFT has been pledged!");
            require(!pledgeSale.isSellOf(_tokenId[i]), "WorldCupQuiz: This NFT is already being sold!");
            //NFT国别判断
            (string memory name,string memory nationality) = nftContract.information(_tokenId[i]);
            if (_type == 1) {
                require(userTokenIds.tokenIdsA.length.add(_tokenId.length) < 11, "WorldCupQuiz: No more than 11 NFTs!");
                require(getStringUint(nationality) == uint256(scc.teamA), "WorldCupQuiz: The pledge country is inconsistent!");

                userTokenIds.tokenIdsA.push(_tokenId[i]);
                tokenIdNumber[_tokenId[i]][_number] = userTokenIds.tokenIdsA.length;

                if (userTokenIds.tokenIdsA.length == 11) {
                    if (!is11FullA[msg.sender][_number]) {
                        playerUserNumberA[_number] += 1;
                        is11FullA[msg.sender][_number] = true;
                    }

                }

            } else {
                require(userTokenIds.tokenIdsB.length.add(_tokenId.length) < 11, "WorldCupQuiz: No more than 11 NFTs!");
                require(getStringUint(nationality) == uint256(scc.teamB), "WorldCupQuiz: The pledge country is inconsistent!");

                userTokenIds.tokenIdsB.push(_tokenId[i]);
                tokenIdNumber[_tokenId[i]][_number] = userTokenIds.tokenIdsB.length;

                if (userTokenIds.tokenIdsB.length == 11) {
                    if (!is11FullB[msg.sender][_number]) {
                        playerUserNumberB[_number] += 1;
                        is11FullB[msg.sender][_number] = true;
                    }
                }
            }
            tokenIdAddress[_tokenId[i]] = msg.sender;

            nftContract.transferFrom(msg.sender, address(this), _tokenId[i]);

            playerNumber[_number][getStringUint(name)] += 1;
        }
        emit PledgeNFT(msg.sender, _number, _tokenId, _type, block.timestamp);
    }


    function replaceNFT(uint256 number, uint256 _type, uint256 tokenId, uint256 _tokenId) public nonReentrant {
        require(tx.origin == _msgSender(), "Cannot be called by external contract");
        require(nftContract.isApprovedOrOwner(address(this), tokenId), "WorldCupQuiz: transfer caller is not owner nor approved");
        require(nftContract.isApprovedOrOwner(msg.sender, _tokenId), "ERC721: transfer caller is not owner nor approved");
        require(worldCup.isTokenId(_tokenId) <= 0, "WorldCupQuiz: NFT has been pledged!");
        require(!pledgeSale.isSellOf(_tokenId), "WorldCupQuiz: This NFT is already being sold!");
        ScreeningsInfo storage scc = screeningsInfos[number];
        require(block.timestamp < scc.stopBetting.sub(600), "WorldCupQuiz: Staking has stopped!");

        require(tokenIdAddress[tokenId] == msg.sender, "WorldCupQuiz: Inconsistent NFT addresses!");

        (string memory _name,string memory nationality) = nftContract.information(_tokenId);
        (string memory name,) = nftContract.information(tokenId);

        nftContract.transferFrom(address(this), msg.sender, tokenId);
        tokenIdAddress[tokenId] = address(0);

        nftContract.transferFrom(msg.sender, address(this), _tokenId);
        tokenIdAddress[_tokenId] = msg.sender;

        UserBetTokenIdInfo storage userTokenIds = userBetTokenIdInfos[msg.sender][number];

        uint256 tokenNumber = tokenIdNumber[tokenId][number];
        tokenIdNumber[_tokenId][number] = tokenNumber;
        if (_type == 1) {
            require(getStringUint(nationality) == uint256(scc.teamA), "WorldCupQuiz: The pledge country is inconsistent!");
            require(userTokenIds.tokenIdsA[tokenNumber - 1] == tokenId, "");
            userTokenIds.tokenIdsA[tokenNumber - 1] = _tokenId;

        } else {
            require(getStringUint(nationality) == uint256(scc.teamB), "WorldCupQuiz: The pledge country is inconsistent!");
            require(userTokenIds.tokenIdsB[tokenNumber - 1] == tokenId, "");
            userTokenIds.tokenIdsB[tokenNumber - 1] = _tokenId;
        }
        tokenIdNumber[tokenId][number] = 0;
        playerNumber[number][getStringUint(name)] -= 1;
        playerNumber[number][getStringUint(_name)] += 1;

        emit ReplacePledge(msg.sender, tokenId, _tokenId, number, _type, block.timestamp);
    }

    function removeNFT(uint256 number, uint256 _type, uint256 tokenId) public {
        require(tx.origin == _msgSender(), "Cannot be called by external contract");
        require(nftContract.isApprovedOrOwner(address(this), tokenId), "WorldCupQuiz: transfer caller is not owner nor approved");

        require(worldCup.isTokenId(tokenId) <= 0, "WorldCupQuiz: NFT has been pledged!");
        ScreeningsInfo storage scc = screeningsInfos[number];
        require(block.timestamp < scc.stopBetting.sub(600), "WorldCupQuiz: Staking has stopped!");

        require(tokenIdAddress[tokenId] == msg.sender, "WorldCupQuiz: Inconsistent NFT addresses!");
        nftContract.transferFrom(address(this), msg.sender, tokenId);
        tokenIdAddress[tokenId] = address(0);

        UserBetTokenIdInfo storage userTokenIds = userBetTokenIdInfos[msg.sender][number];
        (string memory name,) = nftContract.information(tokenId);
        uint256 tokenNumber = tokenIdNumber[tokenId][number];
        if (_type == 1) {
            require(userTokenIds.tokenIdsA[tokenNumber - 1] == tokenId, "");
            uint256 _tokenId = userTokenIds.tokenIdsA[userTokenIds.tokenIdsA.length - 1];
            userTokenIds.tokenIdsA[tokenNumber - 1] = _tokenId;
            tokenIdNumber[_tokenId][number] = tokenNumber;
            userTokenIds.tokenIdsA.pop();
            if (is11FullA[msg.sender][number]) {
                playerUserNumberA[number] -= 1;
                is11FullA[msg.sender][number] = false;
            }


        } else {
            require(userTokenIds.tokenIdsB[tokenNumber - 1] == tokenId, "");
            uint256 _tokenId = userTokenIds.tokenIdsB[userTokenIds.tokenIdsB.length - 1];
            userTokenIds.tokenIdsB[tokenNumber - 1] = _tokenId;
            tokenIdNumber[_tokenId][number] = tokenNumber;
            userTokenIds.tokenIdsB.pop();
            if (is11FullB[msg.sender][number]) {
                playerUserNumberB[number] -= 1;
                is11FullB[msg.sender][number] = false;
            }
        }
        tokenIdNumber[tokenId][number] = 0;

        playerNumber[number][getStringUint(name)] -= 1;

        emit RemoveNFT(msg.sender, tokenId, number, _type, block.timestamp);
    }

    function removeAllNFT(uint256 number, uint256 _type) public nonReentrant {
        require(tx.origin == _msgSender(), "Cannot be called by external contract");

        UserBetTokenIdInfo storage userInfo = userBetTokenIdInfos[msg.sender][number];

        if (_type == 1) {
            if (userInfo.tokenIdsA.length > 0) {
                for (uint256 i = 0; i < 12; i++) {
                    uint256 tokenId = userInfo.tokenIdsA[userInfo.tokenIdsA.length - 1];
                    require(tokenIdAddress[tokenId] == msg.sender, "WorldCupQuiz: Inconsistent NFT addresses!");
                    require(nftContract.isApprovedOrOwner(address(this), tokenId), "WorldCupQuiz: transfer caller is not owner nor approved");
                    nftContract.transferFrom(address(this), msg.sender, tokenId);
                    tokenIdAddress[tokenId] = address(0);
                    (string memory name,) = nftContract.information(tokenId);
                    playerNumber[number][getStringUint(name)] -= 1;
                    userInfo.tokenIdsA.pop();

                    if (userInfo.tokenIdsA.length <= 0) {
                        i = 1000;
                    }

                }
                if (is11FullA[msg.sender][number]) {
                    playerUserNumberA[number] -= 1;
                    is11FullA[msg.sender][number] = false;
                }
            }


        } else {
            if (userInfo.tokenIdsB.length > 0) {
                for (uint256 i = 0; i < 12; i++) {
                    uint256 tokenId = userInfo.tokenIdsB[userInfo.tokenIdsB.length - 1];
                    require(tokenIdAddress[tokenId] == msg.sender, "WorldCupQuiz: Inconsistent NFT addresses!");
                    require(nftContract.isApprovedOrOwner(address(this), tokenId), "WorldCupQuiz: transfer caller is not owner nor approved");
                    nftContract.transferFrom(address(this), msg.sender, tokenId);
                    tokenIdAddress[tokenId] = address(0);
                    (string memory name,) = nftContract.information(tokenId);
                    playerNumber[number][getStringUint(name)] -= 1;
                    userInfo.tokenIdsB.pop();

                    if (userInfo.tokenIdsB.length <= 0) {
                        i = 1000;
                    }
                }
                if (is11FullB[msg.sender][number]) {
                    playerUserNumberB[number] -= 1;
                    is11FullB[msg.sender][number] = false;
                }
            }
        }

        emit RemoveAllNFT(msg.sender, number, _type, block.timestamp);
    }

    function earningsOf(address _msgSender, uint256 _number, uint256 _goalA, uint256 _goalB, uint256 _betType) public view returns (uint256){
        ScreeningsInfo storage scc = screeningsInfos[_number];

        uint256 earningsAmount;

        if (scc.isDistribute) {

            BetInfo storage bet = screeningsBetInfosW[_number];
            BetInfo storage userBet = userBetInfosW[_msgSender][_number];

            if (_betType == 1) {
                uint256 result;
                if (scc.goalsA > scc.goalsB) {
                    result = 1;
                } else if (scc.goalsA < scc.goalsB) {
                    result = 2;
                } else {
                    result = 3;
                }
                uint256 _proportion = bet.resultAmounts.mul(allocationRatio).div(100);
                if (_goalA == result) {
                    earningsAmount = _proportion.mul(100000000000).div(bet.resultAmount[result]).mul(userBet.resultAmount[result]);
                }

            } else if (_betType == 2) {
                uint256 totalGoals = uint256(scc.goalsA).add(uint256(scc.goalsB));
                uint256 _proportion = bet.totalGoalAmounts.mul(allocationRatio).div(100);
                if (_goalA == totalGoals) {
                    earningsAmount = _proportion.mul(100000000000).div(bet.totalGoalAmount[totalGoals]).mul(userBet.totalGoalAmount[totalGoals]);
                }

            } else if (_betType == 3) {
                uint256 _proportion = bet.goalsAmounts.mul(allocationRatio).div(100);
                if (_goalA == scc.goalsA && _goalB == scc.goalsB) {
                    earningsAmount = _proportion.mul(100000000000).div(bet.goalsAmount[uint256(scc.goalsA)][uint256(scc.goalsB)]).mul(userBet.goalsAmount[uint256(scc.goalsA)][uint256(scc.goalsB)]);
                }

            } else if (_betType == 4) {
                (,, earningsAmount) = earningsNFTOf(_msgSender, _number);
                earningsAmount = earningsAmount.mul(100000000000);
            }
        }

        return earningsAmount.div(100000000000);
    }


    function earningsNFTOf(address _msgSender, uint256 _number) public view returns (uint256, uint256, uint256){

        UserBetTokenIdInfo storage userTokenIds = userBetTokenIdInfos[_msgSender][_number];
        ScreeningsInfo storage scc = screeningsInfos[_number];
        ScreeningsInfo2 storage scc2 = screeningsInfos2[_number];

        uint256 teamAward;
        uint256 playerAward;

        if (scc.isDistribute) {
            uint256 amount = scc2.totalAmount.mul(4).div(100);
            if (scc.goalsA > scc.goalsB) {
                if (userTokenIds.tokenIdsA.length == 11) {
                    teamAward = amount.div(playerUserNumberA[_number]);
                }

            } else if (scc.goalsA < scc.goalsB) {
                if (userTokenIds.tokenIdsB.length == 11) {
                    teamAward = amount.div(playerUserNumberB[_number]);
                }

            }
            if (userTokenIds.tokenIdsA.length > 0) {
                for (uint256 i = 0; i < userTokenIds.tokenIdsA.length; i++) {
                    (string memory name,) = nftContract.information(userTokenIds.tokenIdsA[i]);
                    uint256 aaa = amount.div(scc2.totalGoals).mul(playerGoals[_number][getStringUint(name)]);
                    playerAward += aaa.div(playerNumber[_number][getStringUint(name)]);

                }
            }

            if (userTokenIds.tokenIdsB.length > 0) {
                for (uint256 i = 0; i < userTokenIds.tokenIdsB.length; i++) {
                    (string memory name,) = nftContract.information(userTokenIds.tokenIdsB[i]);
                    uint256 aaa = amount.div(scc2.totalGoals).mul(playerGoals[_number][getStringUint(name)]);
                    playerAward += aaa.div(playerNumber[_number][getStringUint(name)]);

                }
            }
        }
        return (teamAward, playerAward, teamAward.add(playerAward));
    }


    function withdraw(uint256 _number, uint256 _goalA, uint256 _goalB, uint256 _betType) public nonReentrant {
        require(tx.origin == _msgSender(), "Cannot be called by external contract");
        ScreeningsInfo storage screeningsInfo = screeningsInfos[_number];
        ScreeningsInfo2 storage screeningsInfo2 = screeningsInfos2[_number];
        require(screeningsInfo.stopWithdraw.add(stopDay.mul(86400)) > block.timestamp, "WorldCupQuiz: The withdrawal time has passed");
        UserBetTokenIdInfo storage userInfo = userBetTokenIdInfos[msg.sender][_number];
        BetInfo storage userBet = userBetInfosW[msg.sender][_number];
        BetInfo storage screeningsBet = screeningsBetInfosW[_number];
        uint256 withdrawAmount = earningsOf(msg.sender, _number, _goalA, _goalB, _betType);
        if (withdrawAmount > 0) {

            wsdContract.transfer(msg.sender, withdrawAmount);
            screeningsInfo2.withdrawAmount += withdrawAmount;

            emit Withdraw(msg.sender, _number, _betType, withdrawAmount, block.timestamp);

        } else {
            if (isWithdrawContract) {
                uint256 agree;
                if (_betType == 1) {
                    agree = userBet.resultAmount[_goalA].div(2);

                } else if (_betType == 2) {
                    agree = userBet.totalGoalAmount[_goalA].div(2);

                } else if (_betType == 3) {
                    agree = userBet.goalsAmount[_goalA][_goalB].div(2);

                }
                _setAgreements(msg.sender, agree.div(100), agree);
                emit WorldCupAgreementWithdraw(msg.sender, msg.sender, _number, worldCup.agreementTotalNumbers(msg.sender), agree.div(100), agree, block.timestamp);
            }

        }

        if (_betType == 1) {
            require(!userInfo.isWithdrawResult[_goalA], "WorldCupQuiz: Earnings have been withdrawn!");
            userInfo.isWithdrawResult[_goalA] = true;
            userBet.resultAmount[_goalA] = 0;
            screeningsBet.resultWithdrawAmount += withdrawAmount;
        } else if (_betType == 2) {
            require(!userInfo.isWithdrawTotalGoal[_goalA], "WorldCupQuiz: Earnings have been withdrawn!");
            userInfo.isWithdrawTotalGoal[_goalA] = true;
            userBet.totalGoalAmount[_goalA] = 0;
            screeningsBet.totalGoalWithdrawAmount += withdrawAmount;
        } else if (_betType == 3) {
            require(!userInfo.isWithdrawGals[_goalA][_goalB], "WorldCupQuiz: Earnings have been withdrawn!");
            userInfo.isWithdrawGals[_goalA][_goalB] = true;
            userBet.goalsAmount[_goalA][_goalB] = 0;
            screeningsBet.goalsWithdrawAmount += withdrawAmount;
        } else if (_betType == 4) {
            require(!userInfo.isWithdrawNFT, "WorldCupQuiz: Earnings have been withdrawn!");
            userInfo.isWithdrawNFT = true;

        }

    }


    function totalAmountOf(uint256 _number, uint256 goalsA, uint256 goalsB, uint256 _betType) public view returns (uint256){
        BetInfo storage betInfoW = screeningsBetInfosW[_number];
        uint256 amount;
        if (_betType == 1) {
            amount = betInfoW.resultAmount[goalsA];
        } else if (_betType == 2) {
            amount = betInfoW.totalGoalAmount[goalsA];
        } else if (_betType == 3) {
            amount = betInfoW.goalsAmount[goalsA][goalsB];
        }
        return amount;
    }


    function userTotalGoalsAmountOf(address _msgSender, uint256 _number, uint256 goalsA, uint256 goalsB, uint256 _betType) public view returns (uint256){

        BetInfo storage betInfoW = userBetInfosW[_msgSender][_number];
        uint256 amount;
        if (_betType == 1) {
            amount = betInfoW.resultAmount[goalsA];
        } else if (_betType == 2) {
            amount = betInfoW.totalGoalAmount[goalsA];
        } else if (_betType == 3) {
            amount = betInfoW.goalsAmount[goalsA][goalsB];
        }
        return amount;
    }


    function userTokenIdOf(address _msgSender, uint256 _number) public view returns (uint256[] memory, uint256[] memory){
        UserBetTokenIdInfo storage userBetTokenIdInfo = userBetTokenIdInfos[_msgSender][_number];
        return (userBetTokenIdInfo.tokenIdsA, userBetTokenIdInfo.tokenIdsB);
    }

    function playerIdOf(uint256 _number) public view returns (uint256[] memory){
        return playerId[_number];
    }

    function playerIdGoalsOf(uint256 _number) public view returns (uint256[] memory){
        return playerIdGoals[_number];
    }


    function userIsWithdraw(address _msgSender, uint256 _number, uint256 goalsA, uint256 goalsB, uint256 _betType) public view returns (bool){
        UserBetTokenIdInfo storage userBetTokenIdInfo = userBetTokenIdInfos[_msgSender][_number];
        bool isWithdraw;
        if (_betType == 1) {
            isWithdraw = userBetTokenIdInfo.isWithdrawResult[goalsA];
        } else if (_betType == 2) {
            isWithdraw = userBetTokenIdInfo.isWithdrawTotalGoal[goalsA];
        } else if (_betType == 3) {
            isWithdraw = userBetTokenIdInfo.isWithdrawGals[goalsA][goalsB];
        } else if (_betType == 4) {
            isWithdraw = userBetTokenIdInfo.isWithdrawNFT;
        }
        return isWithdraw;
    }


    function setPlayerGoals(uint256 number, uint256 _name, uint256 _goal) public onlyOwner {
        playerGoals[number][_name] = _goal;
        if (playerIdNumber[number][_name] <= 0) {
            playerId[number].push(_name);
            playerIdGoals[number].push(_goal);
            playerIdNumber[number][_name] = playerId[number].length;
        } else {
            uint256 i = playerIdNumber[number][_name] - 1;
            playerIdGoals[number][i] = _goal;
        }

        emit SetPlayerGoals(number, _name, _goal, block.timestamp);
    }

    function setTotalGoals(uint256 number, uint256 _totalGoals) public onlyOwner {
        ScreeningsInfo2 storage scc2 = screeningsInfos2[number];
        scc2.totalGoals = _totalGoals;
        emit SetTotalGoals(number, _totalGoals, block.timestamp);
    }

    function setScreeningsInfoTeam(uint256 _number, uint64 teamA, uint64 teamB) public onlyOwner {
        ScreeningsInfo storage screeningsInfo = screeningsInfos[_number];
        screeningsInfo.teamA = teamA;
        screeningsInfo.teamB = teamB;
        emit SetScreeningsInfoTeam(_number, uint256(teamA), uint256(teamB), block.timestamp);
    }


    function setScreeningsInfoGoals(uint256 _number, uint64 goalsA, uint64 goalsB) public onlyOwner {
        ScreeningsInfo storage screeningsInfo = screeningsInfos[_number];
        screeningsInfo.goalsA = goalsA;
        screeningsInfo.goalsB = goalsB;
        emit SetScreeningsInfoGoals(_number, goalsA, goalsB, block.timestamp);
    }

    function setScreeningsInfoStopBetting(uint256 _number, uint128 stopBetting) public onlyOwner {
        ScreeningsInfo storage screeningsInfo = screeningsInfos[_number];
        screeningsInfo.stopBetting = stopBetting;
        emit SetScreeningsInfoStopBetting(_number, stopBetting, block.timestamp);
    }

    function setScreeningsInfoIsDistribute(uint256 _number, bool _isDistribute) public onlyOwner {
        ScreeningsInfo storage screeningsInfo = screeningsInfos[_number];
        screeningsInfo.isDistribute = _isDistribute;
        if (_isDistribute) {
            screeningsInfo.stopWithdraw = block.timestamp;
        } else {
            screeningsInfo.stopWithdraw = 0;
        }

        emit SetScreeningsInfoIsDistribute(_number, _isDistribute, block.timestamp);
    }

    function setContestType(uint256 _number, uint256 _contestType) public onlyOwner {
        ScreeningsInfo storage screeningsInfo = screeningsInfos[_number];
        screeningsInfo.contestType = _contestType;
        emit SetContestType(_number, _contestType, block.timestamp);
    }

    function setGrouping(uint256 _number, string memory _grouping) public onlyOwner {
        ScreeningsInfo storage screeningsInfo = screeningsInfos[_number];
        screeningsInfo.grouping = _grouping;
        emit SetGrouping(_number, _grouping, block.timestamp);
    }

    function setStopDay(uint256 _stopDay) public onlyOwner {
        stopDay = _stopDay;
    }

    function setAllocationRatio(uint256 _allocationRatio) public onlyOwner {
        allocationRatio = _allocationRatio;
    }

    function setLimitUs(uint256 _lowerLimitU, uint256 _upperLimitU) public onlyOwner {
        lowerLimitU = _lowerLimitU * 10 ** 18;
        upperLimitU = _upperLimitU * 10 ** 18;
    }

    function setIsOwner(address _address, bool _isOwner) public onlyOwner {
        isOwner[_address] = _isOwner;
    }


    function setIsWithdrawContract(bool _isWithdrawContract) public onlyOwner {
        isWithdrawContract = _isWithdrawContract;
    }

    function setIsBetContract(bool _isBetContract) public onlyOwner {
        isBetContract = _isBetContract;
    }

    function setUsdtContract(address _token) public onlyOwner {
        usdtContract = ERC20(_token);
    }

    function setWsdContract(address _token) public onlyOwner {
        wsdContract = ERC20(_token);
    }

    function setNftContract(address _token) public onlyOwner {
        nftContract = INft(_token);
    }

    function extractToken(address _token, address _to, uint256 _amount) public onlyOwner {
        ERC20(_token).transfer(_to, _amount);
    }

    function getStringUint(string memory b) public pure returns (uint256 number){
        bytes32 a;

        assembly{
            a := mload(add(b, 32))
        }

        for (uint i = 0; i < a.length; i++) {

            if (a[i] >= 0x30 && a[i] <= 0x39) {
                number = (uint8(a[i]) - 48) + number * 10;
            }
        }
        return number;
    }


}