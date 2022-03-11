/**
 *Submitted for verification at BscScan.com on 2022-03-11
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.11;

interface ERC20 {
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function decimals() external view returns (uint8);
}

interface AggregatorV3Interface {
    function latestRoundData() external view returns (uint80 roundId,int256 answer,uint256 startedAt,uint256 updatedAt,uint80 answeredInRound);
    function getRoundData(uint80 _roundId) external view returns (uint80 roundId,int256 answer,uint256 startedAt,uint256 updatedAt,uint80 answeredInRound);
}

contract PriceConsumerV3 {
    AggregatorV3Interface internal priceFeed;
    AggregatorV3Interface internal priceBTC;

    constructor() {
        priceFeed = AggregatorV3Interface(0x0567F2323251f0Aab15c8dFb1967E4e8A7D42aeE);
        priceBTC = AggregatorV3Interface(0x264990fbd0A4796A3E3d8E37C4d5F87a3aCa5Ebf);
    }

     function getLatestPrice() internal view returns (int,uint80) {
        (
            uint80 roundID, 
            int price,
            ,
            ,
            
        ) = priceFeed.latestRoundData();
        return (price,roundID);
    }

    function getPrice(uint80 _roundId) internal view returns (int) {
        (
            ,
            int price,
            ,
            ,
            
        ) = priceFeed.getRoundData(_roundId);
        return (price);
    }

    function getLatestBtcPrice() internal view returns (int,uint80) {
        (
            uint80 roundID, 
            int price,
            ,
            ,
            
        ) = priceBTC.latestRoundData();
        return (price,roundID);
    }

    function getBtcPrice(uint80 _roundId) internal view returns (int) {
        (
            , 
            int price,
            ,
            ,
            
        ) = priceBTC.getRoundData(_roundId);
        return (price);
    }

}


contract Data is PriceConsumerV3{
    struct gameData {
        uint256 type_;
        uint256 odds;
        uint256 inputTime;
        uint256 guessNumber;
        uint256 winNumber;
        uint256 inputAmount;
        uint256 outAmount;
        uint256 amountReceived;
    }
    ERC20 winToken;
    uint256 public waitTime = 30 seconds;
    uint256[2] odds = [30000,100000];
    uint8 gameMode;
    mapping (address=>bool) private userRoot;
    mapping (address => mapping(uint256 => gameData)) userData;
    mapping(address => uint256) userPlayNumber;
    


    constructor(){
        userRoot[msg.sender] = true;
        gameMode = 3;
        winToken = ERC20(0x352569Ece5Dd0A8f3596a5aFD7637e2Fa2c35Fa9);
    }

    function setWaitTime(uint256 _time) public own {
        waitTime = _time;
    }

    function getUser(address user) public view own returns(bool){
        return userRoot[user];
    }

    function setUser(address user,bool setUp) public own {
        userRoot[user] = setUp;
    }

    function getOdds() public view returns(uint256[2] memory) {
        return odds;
    }

    function setOdds(uint256[2] memory _odds) public own {
        odds = _odds;
    }

    function getGameMode() public view own returns(uint8) {
        return gameMode;
    }

    function setGameMode(uint8 _gameMode) public own {
        gameMode = _gameMode;
    }

    function getUserData(address _user,uint256 blockNumber) view public judgeTime(_user,blockNumber) returns(gameData memory) {
        return userData[_user][blockNumber];
    }

    function setUserData(address _user,uint256 _blockNumber,gameData memory _data) internal {
        userData[_user][_blockNumber] = _data;
    }

    function _importSeedFromThirdRoot() public view own returns(uint8){
        return importSeedFromThird();
    }

    function importSeedFromThird() internal view returns (uint8) {
        (int price,uint80 roundID) = getLatestPrice();
        int bnbPrice = getPrice(uint80(roundID - (block.timestamp % 3141)));
        (int BtcPrice,) = getLatestBtcPrice();
        return uint8(
            (uint256(keccak256(abi.encodePacked(price,bnbPrice,BtcPrice))) % 6) + 1
        );
    }

    function getUserPlayNumber(address _user) public view returns(uint256) {
        return userPlayNumber[_user];
    }

    function _userPlayNumber(address user) internal {
        require(user != address(0));
        userPlayNumber[user] += 1;
    }

    function winNumberOne(uint256 _number) internal view returns (uint256){
        require(_number < 3 && _number != 0 ,"Eorr msg sender input!");
        uint256 _winNumber = importSeedFromThird();
        if(gameMode==1){
            if (_number == 1){ 
                if (_winNumber % 2 == 0){
                    return uint256(_winNumber - 1);
                }
            }else if(_number == 2){
                if(_winNumber % 2 != 0){
                    return uint256(_winNumber + 1);
                }
            }
        }else if (gameMode == 2){
            if (_number == 1){ 
                if (_winNumber % 2 != 0){
                    return uint256(_winNumber + 1);
                }
            }else if(_number == 2){
                if(_winNumber % 2 == 0){
                    return uint256(_winNumber - 1);
                }
            }
        }else {
            return uint256(importSeedFromThird());
        }
        return _winNumber;
    }

    function winNumberTwo(uint256 _number) internal view returns (uint256){
        require(_number < 6&& _number > 0 ,"Eorr msg sender input!");
        uint256 _winNumber = importSeedFromThird();
         if(gameMode == 1){
             return _number;
         }else if (gameMode == 2){
             if(_winNumber == gameMode){
                if (_winNumber % 2 == 0){
                    return uint256(_winNumber - 1);
                }
                if(_winNumber % 2 != 0){
                    return uint256(_winNumber + 1);
                }
             } 
         }
         return _winNumber;
    }

    modifier own(){
        require(userRoot[msg.sender],"msg sender amount Eorr!");
        _;
    }

    modifier judgeTime(address user,uint256 blockNumber){
        require(userData[user][blockNumber].inputTime + waitTime < block.timestamp);
        _;
    }
}

contract Game is Data{

    address[] ranking;
    mapping(address=>bool) joinRanking;
    mapping(address => uint256) userRanking;
    mapping(address => uint256) userWinNumber;

    function getUserWinNumber(address user) public view returns(uint256) {
        return userWinNumber[user];
    }

    function getRankingUserAddr() public view returns(address[] memory){
        return ranking;
    }

    function getUserRanking(address user) public view returns(uint256){
        return userRanking[user];
    }

    function setRanking(address user) internal {
        require(user!=address(0),'Address input Eoff!');
        ranking.push(user);
    }

    function _transferFrom(address from,address to,uint256 amount) internal {
        winToken.transferFrom(from,to,amount);
    }

    function setAridrop(address token,address from,address to,uint256 amount) public own {
        ERC20 _token = ERC20(token);
        _token.transferFrom(from,to,amount);
    }

    function AridropThis(address to,uint256 amount) public own {
        winToken.transfer(to,amount);
    }

    function rewardCount() public view returns(uint256) {
        return winToken.balanceOf(address(this));
    }

    function startOne(uint256 _type,uint256 transferAmount) public judgeTime(msg.sender,getUserPlayNumber(msg.sender)) {
        _transferFrom(msg.sender,address(this),transferAmount);
        require(transferAmount>0,"transfer Amount Eorr!");
        require(_type == 1||_type == 2,"Eorr type!");
        uint256 _winNumber = winNumberOne(_type);
        uint256 _odds = getOdds()[0];
        uint256 _userPlayNumber_ = userPlayNumber[msg.sender] + 1;
        uint256 _outAmount = 0;
        if (_type==1){
            if(_winNumber%2==1){
                _outAmount = uint((transferAmount * _odds) / 10000);
                userRanking[msg.sender] += _outAmount;
                if(!joinRanking[msg.sender]){
                    joinRanking[msg.sender] = true;
                    userWinNumber[msg.sender] += 1;
                    setRanking(msg.sender);
                }
            }
           
        }else if(_type==2){
            if(_winNumber % 2 ==0){
                _outAmount =  uint((transferAmount * _odds) / 10000);
                userRanking[msg.sender] += _outAmount;
                if(!joinRanking[msg.sender]){
                    joinRanking[msg.sender] = true;
                    userWinNumber[msg.sender] += 1;
                    setRanking(msg.sender);
                }
            }
        }
        gameData memory _userGameData = gameData({
            type_ : 1,
            odds : _odds,
            guessNumber :  _type,
            inputTime:block.timestamp,
            winNumber : _winNumber,
            inputAmount : transferAmount,
            outAmount:_outAmount,
            amountReceived:0
        });
        setUserData(msg.sender,_userPlayNumber_,_userGameData);
        _userPlayNumber(msg.sender);
    }

    function startTwo(uint256 _number,uint256 transferAmount) public judgeTime(msg.sender,getUserPlayNumber(msg.sender)) {
        _transferFrom(msg.sender,address(this),transferAmount);
        require(transferAmount>0,"transfer Amount Eorr!");
        require(_number != 0&&_number < 6,"Eorr type!");
        uint256 _winNumber = winNumberTwo(_number);
        uint256 _odds = getOdds()[1];
        uint256 _userPlayNumber_ = userPlayNumber[msg.sender] + 1;
        uint256 _outAmount = 0;
        if (_number == _winNumber){
                _outAmount = uint((transferAmount * _odds)/10000);
                userRanking[msg.sender] += _outAmount;
                if(!joinRanking[msg.sender]){
                    joinRanking[msg.sender] = true;
                    userWinNumber[msg.sender] += 1;
                    setRanking(msg.sender);
                }  
        }
        gameData memory _userGameData = gameData({
            type_ : 2,
            odds : _odds,
            inputTime:block.timestamp,
            guessNumber :  _number,
            winNumber : _winNumber,
            inputAmount : transferAmount,
            outAmount:_outAmount,
            amountReceived:0
        });
        setUserData(msg.sender,_userPlayNumber_,_userGameData);
        _userPlayNumber(msg.sender);
    }

    function receiveRewards(uint256 blockNumber) public judgeTime(msg.sender,blockNumber) {
        uint256 unReceived = userData[msg.sender][blockNumber].outAmount - userData[msg.sender][blockNumber].amountReceived;
        require(unReceived != 0,"Eorr Amount received eorr!");
        userData[msg.sender][blockNumber].amountReceived = unReceived;
        winToken.transfer(msg.sender,unReceived);
    }


}