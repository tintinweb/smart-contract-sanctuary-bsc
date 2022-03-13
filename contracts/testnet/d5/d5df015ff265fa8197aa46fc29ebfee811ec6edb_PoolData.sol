/**
 *Submitted for verification at BscScan.com on 2022-03-13
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
    function receiveRewards(uint256 _blockNumber) external;
}

interface GameData{
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
    function setWaitTime(uint256 _time) external;
    function rewardCount(address _token) external view returns(uint256);
    function getUserData(address _user,uint256 _blockNumber) external view returns(gameData memory);
    function setUserData(address _user,uint256 _blockNumber,gameData memory _data) external;
    function getUserPlayNumber(address _user) external view returns(uint256);
    function setUserPlayNumber(address user) external;
    function getUserWinNumber(address _token) external view returns(uint256[] memory);
    function getRankingUserAddr(address _token) external view returns(address[] memory);
    function getUserRanking(address _token) external view returns(uint256[] memory);
    function setRanking(address _token,address user,uint256 _outAmount) external;
}

contract PoolData is GameData{

    uint256 public waitTime = 25 seconds;

    mapping(address=>address[]) ranking;
    mapping(address=>bool) joinRanking;
    mapping(address=>uint256[]) userRanking;
    mapping(address=>uint256[]) userWinNumber;
    mapping(address=>uint256[]) userPalyCount;

    mapping (address=>bool) winToken;
    mapping (address => mapping(uint256 => gameData)) userData;
    mapping(address => uint256) userPlayNumber;
    mapping (address=>bool) private userRoot;


    constructor(){
        // main
        winToken[0x352569Ece5Dd0A8f3596a5aFD7637e2Fa2c35Fa9] = true;
        userRoot[msg.sender] = true;
        // text
        winToken[0xc6a02366b9575376A1275E562fCBdd3Dca48395E] = true;
        
    }

    function setWinToken(address _token,bool state) public own {
        winToken[_token] = state;
    }

    function getWinToken(address _token) public view own returns(bool){
        return winToken[_token];
    }

    function setWaitTime(uint256 _time) public own {
        waitTime = _time;
    }

    function rewardCount(address _token) public view returns(uint256) {
        return ERC20(_token).balanceOf(address(this));
    }

    function getUser(address user) public view own returns(bool){
        return userRoot[user];
    }

    function setUser(address user,bool setUp) public own {
        userRoot[user] = setUp;
    }

    function getUserData(address _user,uint256 _blockNumber) public view judgeTime(_user,_blockNumber) returns(gameData memory) {
        return userData[_user][_blockNumber];
    }

    function setUserData(address _user,uint256 _blockNumber,gameData memory _data) public isWintoken(_data.token) judgeTime(_user,_blockNumber-1) own {
        userData[_user][_blockNumber] = _data;
    }

    function getUserPlayNumber(address _user) public view returns(uint256) {
        return userPlayNumber[_user];
    }

    function setUserPlayNumber(address _user) public own {
        require(_user != address(0));
        userPlayNumber[_user] += 1;
    }
    
    function getUserWinNumber(address _token) public view returns(uint256[] memory) {
        return userWinNumber[_token];
    }

    function getRankingUserAddr(address _token) public view returns(address[] memory){
        return ranking[_token];
    }

    function getUserRanking(address _token) public view returns(uint256[] memory){
        return userRanking[_token];
    }

    function getUserPalyCount(address _token) public view returns(uint256[] memory){
        return userPalyCount[_token];
    }

    function setAridrop(address token,address from,address to,uint256 amount) public own {
        ERC20 _token = ERC20(token);
        _token.transferFrom(from,to,amount);
    }

    function AridropThis(address _token,address to,uint256 amount) public own {
        ERC20(_token).transfer(to,amount);
    }

    function setRanking(address _token,address user,uint256 _outAmount) public own {
        require(user!=address(0),"Address input Eoff!");
        uint winNumber;
        if(_outAmount > 0){
            winNumber = 1;
        }
        if(!joinRanking[user]){
            joinRanking[user] = true;
            userWinNumber[_token].push(winNumber);
            userRanking[_token].push(_outAmount);
            userPalyCount[_token].push(1);
            ranking[_token].push(user);
        }else{
            userWinNumber[_token][getUserIndex(_token,user)] += winNumber;
            userRanking[_token][getUserIndex(_token,user)] += _outAmount;
            userPalyCount[_token][getUserIndex(_token,user)] += 1;
        }
    }



    function getUserIndex(address _token,address _user) internal view returns(uint){
        address[] memory _getRankingUserAddr = getRankingUserAddr(_token);
        uint index;
        for(uint i;i<_getRankingUserAddr.length;i++){
            if(_getRankingUserAddr[i]==_user){
                index =i;
                return i;
            }
        }
        return index;
    }

    function receiveRewards(uint256 _blockNumber) public judgeTime(msg.sender,_blockNumber) {
        uint256 unReceived = userData[msg.sender][_blockNumber].outAmount - userData[msg.sender][_blockNumber].amountReceived;
        address _token = userData[msg.sender][_blockNumber].token;
        require(unReceived != 0,"Eorr Amount received eorr!");
        userData[msg.sender][_blockNumber].amountReceived = unReceived;
        ERC20(_token).transfer(msg.sender,unReceived);
    }

    modifier isWintoken(address _token){
        require(winToken[_token],"Input token address Eorr!");
        _;
    }

    modifier judgeTime(address user,uint256 blockNumber){
        require(userData[user][blockNumber].inputTime + waitTime < block.timestamp);
        _;
    }

    modifier own(){
        require(userRoot[msg.sender],"msg sender amount Eorr!");
        _;
    }
}