/**
 *Submitted for verification at BscScan.com on 2022-10-12
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this;
        // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}


interface IERC20 {

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
    external
    returns (bool);

    function allowance(address owner, address spender)
    external
    view
    returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
}


contract Ownable is Context {
    address _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }


    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }


    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}



library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }


    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

library Address {

    function isContract(address account) internal view returns (bool) {
        return account.code.length > 0;
    }
}

contract ReentrancyGuard {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");
        _status = _ENTERED;
        _;
        _status = _NOT_ENTERED;
    }
}

contract Prize is Ownable,ReentrancyGuard {

    using SafeMath for uint256;
    using Address for address;
    address public teamAddress = address(0xb09ecE278e324ff889624B03A53D4D201c56bf2e);

    //mainnet
    address constant usdt = 0x55d398326f99059fF775485246999027B3197955;

    uint256 private UsdtRank1 = 5 * 10**18;
    uint256 private UsdtRank2 = 10 * 10**18;
    uint256 private UsdtRank3 = 20 * 10**18;
    uint256 private UsdtRank4 = 50 * 10**18;
    uint256 private UsdtRank5 = 100 * 10**18;

    uint256 playersMax = 100;
    address[] private GamePlayersRank1;
    address[] private GamePlayersRank2;
    address[] private GamePlayersRank3;
    address[] private GamePlayersRank4;
    address[] private GamePlayersRank5; 

    address[] private GameWinner1;
    address[] private GameWinner2;
    address[] private GameWinner3;
    address[] private GameWinner4;
    address[] private GameWinner5;

    constructor() {}

    modifier notContract() {
        require(!msg.sender.isContract(), "Contract Not Allow");
        _;
    }

    function participateGameRank1()external nonReentrant notContract{

        require(GamePlayersRank1.length < playersMax, "Exceed Max Players");
        IERC20(usdt).transferFrom(msg.sender, address(this), UsdtRank1);
        GamePlayersRank1.push(msg.sender);
        if(GamePlayersRank1.length >= 100){
            handleWinnersPrizeRank1();
            initWinPlayersRank1();
        }
    }

    function participateGameRank2()external nonReentrant notContract{

        require(GamePlayersRank2.length < playersMax, "Exceed Max Players");
        IERC20(usdt).transferFrom(msg.sender, address(this), UsdtRank2);
        GamePlayersRank2.push(msg.sender);
        if(GamePlayersRank2.length >= 100){
            handleWinnersPrizeRank2();
            initWinPlayersRank2();
        }
    }

    function participateGameRank3()external nonReentrant notContract{

        require(GamePlayersRank3.length < playersMax, "Exceed Max Players");
        IERC20(usdt).transferFrom(msg.sender, address(this), UsdtRank3);
        GamePlayersRank3.push(msg.sender);
        if(GamePlayersRank3.length >= 100){
            handleWinnersPrizeRank3();
            initWinPlayersRank3();
        }
    }

    function participateGameRank4()external nonReentrant notContract{

        require(GamePlayersRank4.length < playersMax, "Exceed Max Players");
        IERC20(usdt).transferFrom(msg.sender, address(this), UsdtRank4);
        GamePlayersRank4.push(msg.sender);
        if(GamePlayersRank4.length >= 100){
            handleWinnersPrizeRank4();
            initWinPlayersRank4();
        }
    }

    function participateGameRank5()external nonReentrant notContract{

        require(GamePlayersRank5.length < playersMax, "Exceed Max Players");
        IERC20(usdt).transferFrom(msg.sender, address(this), UsdtRank5);
        GamePlayersRank5.push(msg.sender);
        if(GamePlayersRank5.length >= 100){
            handleWinnersPrizeRank5();
            initWinPlayersRank5();
        }
    }


    function handleWinnersPrizeRank1()private{

        uint256[10] memory prizeAmount;
        uint256[9] memory winPlayers;

        initGameWinner1();//clear

        prizeAmount = getPrizeAmount(UsdtRank1);
        winPlayers = getWinPlayers(100);
 

        for(uint256 i=0;i<9;i++){
            IERC20(usdt).transfer(GamePlayersRank1[winPlayers[i]], prizeAmount[i]);
            GameWinner1.push(GamePlayersRank1[winPlayers[i]]);   
        }
        IERC20(usdt).transfer(teamAddress, prizeAmount[9]);    
    }

    function handleWinnersPrizeRank2()private{

        uint256[10] memory prizeAmount;
        uint256[9] memory winPlayers;

        initGameWinner2();//clear

        prizeAmount = getPrizeAmount(UsdtRank2);
        winPlayers = getWinPlayers(100);

        for(uint256 i=0;i<9;i++){
            IERC20(usdt).transfer(GamePlayersRank2[winPlayers[i]], prizeAmount[i]);
            GameWinner2.push(GamePlayersRank1[winPlayers[i]]);
        }
        IERC20(usdt).transfer(teamAddress, prizeAmount[9]);     
    }

    function handleWinnersPrizeRank3()private{

        uint256[10] memory prizeAmount;
        uint256[9] memory winPlayers;

        initGameWinner3();//clear

        prizeAmount = getPrizeAmount(UsdtRank3);
        winPlayers = getWinPlayers(100);

        

        for(uint256 i=0;i<9;i++){
            IERC20(usdt).transfer(GamePlayersRank3[winPlayers[i]], prizeAmount[i]);
            GameWinner3.push(GamePlayersRank1[winPlayers[i]]);
        }
        IERC20(usdt).transfer(teamAddress, prizeAmount[9]);      
    }

    function handleWinnersPrizeRank4()private{

        uint256[10] memory prizeAmount;
        uint256[9] memory winPlayers;

        initGameWinner4();//clear

        prizeAmount = getPrizeAmount(UsdtRank4);
        winPlayers = getWinPlayers(100);

        for(uint256 i=0;i<9;i++){
            IERC20(usdt).transfer(GamePlayersRank4[winPlayers[i]], prizeAmount[i]);
            GameWinner4.push(GamePlayersRank1[winPlayers[i]]);
        }
        IERC20(usdt).transfer(teamAddress, prizeAmount[9]);   
    }

    function handleWinnersPrizeRank5()private{

        uint256[10] memory prizeAmount;
        uint256[9] memory winPlayers;

        initGameWinner5();//clear

        prizeAmount = getPrizeAmount(UsdtRank5);
        winPlayers = getWinPlayers(100);

        for(uint256 i=0;i<9;i++){
            IERC20(usdt).transfer(GamePlayersRank5[winPlayers[i]], prizeAmount[i]);
            GameWinner5.push(GamePlayersRank1[winPlayers[i]]);
        }
        IERC20(usdt).transfer(teamAddress, prizeAmount[9]);    
    }

    function initWinPlayersRank1()private{
        delete GamePlayersRank1;
    }

     function initWinPlayersRank2()private{
        delete GamePlayersRank2;
    }

     function initWinPlayersRank3()private{
        delete GamePlayersRank3;
    }

     function initWinPlayersRank4()private{
        delete GamePlayersRank4;
    }

    function initWinPlayersRank5()private{
        delete GamePlayersRank5;
    }

    function initGameWinner1()private{
        delete GameWinner1;
    }

    function initGameWinner2()private{
        delete GameWinner2;
    }

    function initGameWinner3()private{
        delete GameWinner3;
    }

    function initGameWinner4()private{
        delete GameWinner4;
    }

    function initGameWinner5()private{
        delete GameWinner5;
    }
    
    function getGamePlayersRank1Length() public view returns(uint256){
        return GamePlayersRank1.length;
    }

    function getGamePlayersRank2Length() public view returns(uint256){
        return GamePlayersRank2.length;
    }

    function getGamePlayersRank3Length() public view returns(uint256){
        return GamePlayersRank3.length;
    }

    function getGamePlayersRank4Length() public view returns(uint256){
        return GamePlayersRank4.length;
    }

    function getGamePlayersRank5Length() public view returns(uint256){
        return GamePlayersRank5.length;
    }

    function getGameWinner1() public view returns(address[] memory){
        return GameWinner1;
    }

    function getGameWinner2() public view returns(address[] memory){
        return GameWinner2;
    }

    function getGameWinner3() public view returns(address[] memory){
        return GameWinner3;
    }

    function getGameWinner4() public view returns(address[] memory){
        return GameWinner4;
    }

    function getGameWinner5() public view returns(address[] memory){
        return GameWinner5;
    }

    function getWinPlayers(uint256 range) private view returns(uint256[9]memory){

        uint256 nonce = 0;
        uint256[9] memory WinPlayers;
        uint256 count = 0;
        
        while(count < 9){    
            bytes32 randomBytes = keccak256(abi.encodePacked(nonce, block.number, block.difficulty, msg.sender, block.timestamp));
            uint256 number = uint256(randomBytes).mod(range);
            if(count == 0){
                WinPlayers[count] = number;
                count++;
            }else{
                for(uint256 i =0; i < count; i++){

                    if(WinPlayers[i] == number){
                        break;      
                    }
                    if(i == count-1){
                        WinPlayers[count] = number;
                        count++;
                    }
                }
            }
            nonce++;
            require(nonce<16,"too many gas");     
        }
        return WinPlayers;

    }

    function getPrizeAmount(uint256 UsdtRank)private pure returns(uint256[10]memory){
        uint256[10] memory Prizes;
        uint256  Prize_All = 100 * UsdtRank;
        Prizes[0]=Prize_All/100*30;
        Prizes[1]=Prize_All/100*20;
        Prizes[2]=Prize_All/100*10;
        Prizes[3]=Prize_All/100*5;
        Prizes[4]=Prize_All/100*5;
        Prizes[5]=Prize_All/100*5;
        Prizes[6]=Prize_All/100*5;
        Prizes[7]=Prize_All/100*5;
        Prizes[8]=Prize_All/100*5;
        Prizes[9]=Prize_All/100*10;
        return Prizes;
    }

    receive() external payable {}

    function editUsdtRank(uint256 _UsdtRank1,uint256 _UsdtRank2,uint256 _UsdtRank3,uint256 _UsdtRank4,uint256 _UsdtRank5) external onlyOwner {
        UsdtRank1 = _UsdtRank1 * 10**18;
        UsdtRank2 = _UsdtRank2 * 10**18;
        UsdtRank3 = _UsdtRank3 * 10**18;
        UsdtRank4 = _UsdtRank4 * 10**18;
        UsdtRank5 = _UsdtRank5 * 10**18;
    }

    function editTeamAddress(address _teamAddress) external onlyOwner {
        teamAddress = _teamAddress;
    }

    function rescueToken(address tokenAddress, uint256 tokens)public onlyOwner returns (bool success){
        return IERC20(tokenAddress).transfer(msg.sender, tokens);
    }

    function rescueEth() onlyOwner public {
        uint256 amount = address(this).balance;
        payable(msg.sender).transfer(amount);
    }

}