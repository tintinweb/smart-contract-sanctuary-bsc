/**
 *Submitted for verification at BscScan.com on 2022-08-12
*/

//SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.4;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns(bytes calldata) {
        return msg.data;
    }
}

contract Raffle {

    string public projectName;
    bool private isToken;
    uint256 public start;
    uint256 public duration;
    bool public isLimitableRaffle;
    uint256 public limitedRaffleNum;
    uint256 public spotNum;
    uint256 public ticketPrice;
    uint256 public protectionFee;
    uint256 public returnFeeRate;
    bool isRaffled = false; 
    bool isCanceled = false;
    
    address[] public winnerAddress;
    uint256 public totalTiketNum;
    uint256 public uniqueUserNum;

    constructor ( string memory _projectName, bool _isToken, uint256 _start, uint256 _duration, bool _isLimitableRaffle, uint256 _limitedRaffleNum, uint256 _spotNum, uint256 _ticketPrice, uint256 _protectionFee, uint256 _returnFeeRate) payable {
        projectName = _projectName;
        isToken = _isToken; // Token or NFT
        start = _start;
        duration = _duration;
        isLimitableRaffle = _isLimitableRaffle;
        limitedRaffleNum = _limitedRaffleNum;
        spotNum = _spotNum;
        ticketPrice = _ticketPrice;
        protectionFee = _protectionFee;
        returnFeeRate = _returnFeeRate;
        //setProjectName(_projectName) 이런식으로 변경
    }
     
    

    // raffle 패드 보증금 : wl 미적용시 반환 불가


    function newRaffle(string memory _projectName) external {
        projectName = _projectName;
    }
    
    // ----------------------set project info------------------------------
    function setProjectName(string memory _projectName) external{ //admin만 가능
        projectName = _projectName;
    }

    function  setStart(uint256 _start) external { //owner, admin 가능
        // 래플 시작전에만 가능하게 세팅
        // require(start < block.timestamp < start + duration, "It must be set earlier than the current time.");
        // require(_start < block.timestamp, "It must be set earlier than the current time.");
        start = _start;
    }
    
    function setDuration(uint256 _duration) external { //owner, admin 가능
        // 래플 끝나기전에만 가능하게 세팅
        duration = _duration;
    }

    function setIsLimitableRaffle(bool _isLimitableRaffle) external { //admin 가능
        require(start + duration < block.timestamp,"It cannot be set after raffle is closed.");
        isLimitableRaffle = _isLimitableRaffle;
        if(isLimitableRaffle && !_isLimitableRaffle ) limitedRaffleNum = 0;
    }

    function setLimitedRaffleNum(uint256 _limitedRaffleNum) external { //admin 가능
        require(start + duration < block.timestamp,"It cannot be set after raffle is closed.");
        require(isLimitableRaffle, "This raffle has no limits.");
        limitedRaffleNum = _limitedRaffleNum;
    }

    function setSpotNum(uint256 _spotNum) external { //admin 가능
        require(start + duration < block.timestamp,"It cannot be set after raffle is closed."); 
        spotNum = _spotNum;
    }

    function setTicketPrice(uint256 _ticketPrice) external { //admin 가능
        require(start + duration < block.timestamp,"It cannot be set after raffle is closed.");
        ticketPrice = _ticketPrice;
    }
    // function setProtectionFee(uint256 _protectionFee) external { //admin 가능
    //     protectionFee = _protectionFee;
    // }
    // function setReturnFeeRate(uint256 _returnFeeRate) external { //admin 가능
    //     returnFeeRate = _returnFeeRate;
    // }

    //------------------------raffle function----------------------------------
    
        /* 
            1. raffle 참여하기 기능
                - 1. 일단 래플이 진행중인지 확인
                  2. 유저가 조건을 만족했는지 확인
                    a. 돈이 있는지
                    b. 최대 맥스를 넘지 않았는지
                  3. 조건 확인했으면 래플참여
                    a. 티켓가격대로 돈 전송
                    b. 래플리스트에 추가
            2. raffle 기능
                - 1. 일단 래플이 끝났는지 확인
                  2. 래플 진행
                  3. 위너리스트에 입력
        */


    //------------------------보증금 환급기능----------------------------------

        /*  1. raffle이 끝났는지 확인
            2. 화이트리스트가 잘 적용되었는지 확인
                a. pad 로그확인
                b. 없을시 3일후 민원없으면 환불
            A. 화리 적용되었을경우, 반환비율에 따라 환불 후 토큰 소각
            B. 화리 안적용되었을경우, 반환금 없음, 토큰 환불
        */

    //------------------------담청리스트 기능----------------------------------
}