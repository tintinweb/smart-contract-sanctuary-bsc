/**
 *Submitted for verification at BscScan.com on 2022-07-11
*/

/**
 *Submitted for verification at BscScan.com on 2022-07-07
*/

/**
 *Submitted for verification at BscScan.com on 2022-06-25
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.14;


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

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

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



contract Lottery is Ownable {

    address private token = 0x0bd026a4cf8c35e0A273223A0aFED384931d913b;
    IERC20 public lotteryToken = IERC20(token);
    mapping (uint256 => address) public winnersTop100;
    mapping (uint256 => address) public winnersTop100_200;

    mapping (address=> uint256) public winnersTop100Amounts;
    mapping (address=> uint256) public winnersTop100_200Amounts;
    mapping (address => bool) public excludedAddresses;

    address[] private lastWinnersTop100;
    address[] private lastWinnersTop100_200;
    uint256[] private lastWinnersTop100Amounts;
    uint256[] private lastWinnersTop100_200Amounts;
    address[] public excludedFromLottery;

    uint256 public top100WinnersCount;
    uint256 public top100_200WinnersCount;

    uint256 public minimumHoldAmount=50;

    uint256 public top100WinnerLenght = 5;
    uint256 public top100_200WinnerLenght = 5;
    uint256 public totalWinnerLenght = 10;

    bool private firstLottery = false;
    uint256 public lastGiveAwayTime;
    uint256 public giveAwayPeriod;

    address public operator;

    modifier onlyOperator{
        require(msg.sender == operator,"Only operator can call this function!");
        _;
    }

    constructor (){
        lastGiveAwayTime = block.timestamp;
        giveAwayPeriod = 604800;
        operator = msg.sender;
    }

    event PickWinner(bool lotteryEnded, uint256 time);

    function pickWinner() external onlyOwner{
        if(firstLottery)
        {
            if (lastGiveAwayTime!=0){
            require(lastGiveAwayTime + giveAwayPeriod < block.timestamp,"Next giveaway time has not met yet!");
            }
        }
        emit PickWinner(true,block.timestamp);
    }

    function setExcludeFromLottery (address _address) public{
        require(msg.sender == owner()  || msg.sender == operator,"Only owner or operator can call this function!");
        require(excludedAddresses[_address]==false,"Already excluded!");
        excludedAddresses[_address]=true;
        excludedFromLottery.push(_address);
    }

    function setIncludeToLottery (address _address) public{
        require(msg.sender == owner()  || msg.sender == operator,"Only owner or operator can call this function!");
        require(excludedAddresses[_address]==true,"Already included!");
        excludedAddresses[_address]=false;
        address check;
        uint i;
        address [] memory arr = excludedFromLottery;
        while(check!=_address){
            check = arr[i];
            unchecked{i++;}
        }
        if (i!=arr.length)
            excludedFromLottery[i-1]=excludedFromLottery[excludedFromLottery.length -1];
        excludedFromLottery.pop();
    }



    function setToken(address _token) external onlyOwner{
        token=_token;
        lotteryToken=IERC20(_token);
    }

    function setOperator(address _operator) public onlyOperator{
        require(operator!=owner(),"Owner can not be operator!");
        operator = _operator;
    }

    function setMinimumHoldAmount(uint256 amount) external onlyOwner{
        require(amount>=0,"Amount must be greater than 0!");
        minimumHoldAmount=amount;
    }

    function setWinnerLenght(uint256 top100, uint256 top100_200) external onlyOwner{
        require(top100>=0 && top100_200 >= 0,"Must be greater than 0!");
        top100WinnerLenght = top100;
        top100_200WinnerLenght = top100_200;
    }
    
    function setGiveAwayPeriod(uint256 _giveAwayPeriod) external onlyOwner{
        require(_giveAwayPeriod>0,"Giveaway time must be greater than zero!");
        giveAwayPeriod=_giveAwayPeriod;
    }

    function giveAwayTokens(address[] memory winners ) external onlyOperator{
        require(winners.length==totalWinnerLenght,"There is 10 winner at each giveaway!");
        require(lotteryToken!=IERC20(address(0)),"Giveaway token can not be the zero address!");

        if(firstLottery)
        {
            if (lastGiveAwayTime!=0){
            require(lastGiveAwayTime + giveAwayPeriod < block.timestamp,"Next giveaway time has not met yet!");
            }   
        }
        else
        {
            firstLottery=true;
        }

        uint32 i;
        
        for (i=0;i<winners.length;i++)
        {
            uint256 amount=IERC20(token).balanceOf(winners[i])/100;
            address winner = winners[i];
            IERC20(token).transfer(winner , amount);
            if(i<top100WinnerLenght)
            {
                winnersTop100[top100WinnersCount] = winner;
                winnersTop100Amounts[winner] = amount;
                top100WinnersCount++;

            }
            else{
                winnersTop100_200[top100_200WinnersCount] = winner;
                winnersTop100_200Amounts[winner] = amount;
                top100_200WinnersCount++;
            }
        }
        setLastTop100Winners();
        setLastTop100_200Winners();
        lastGiveAwayTime=block.timestamp;
    }


    function setLastTop100Winners() private{
        lastWinnersTop100 = new address[](0);
        lastWinnersTop100Amounts = new uint256[](0);
        for(uint256 i = top100WinnersCount ; i > top100WinnersCount - top100WinnerLenght ; i-- )
        {
            lastWinnersTop100.push(winnersTop100[i-1]);
            lastWinnersTop100Amounts.push(winnersTop100Amounts[winnersTop100[i-1]]);
        }
            
    }

    function setLastTop100_200Winners() private{
        lastWinnersTop100_200 = new address[](0);
        lastWinnersTop100_200Amounts = new uint256[](0);
        for(uint256 i = top100_200WinnersCount ; i > top100_200WinnersCount - top100_200WinnerLenght ; i-- )
        {
            lastWinnersTop100_200.push(winnersTop100_200[i-1]);
            lastWinnersTop100_200Amounts.push(winnersTop100_200Amounts[winnersTop100_200[i-1]]);
        }
    }

    function getLastWinnersTop100() public view returns(address[] memory, uint256[] memory){
        
        return (lastWinnersTop100,lastWinnersTop100Amounts);
    }

    function getLastWinnersTop100_200() public view returns(address[] memory,uint256[] memory){
        return (lastWinnersTop100_200,lastWinnersTop100_200Amounts);
    }

    function getExcludedFromLottery() public view returns(address [] memory){
        return excludedFromLottery;
    }

    function claimStuckToken(address _token) 
        external 
        onlyOwner 
    {
        if (_token == address(0x0)) {
            payable(msg.sender).transfer(address(this).balance);
            return;
        }
        IERC20 ERC20token = IERC20(_token);
        uint256 balance = ERC20token.balanceOf(address(this));
        ERC20token.transfer(msg.sender, balance);
    }


}