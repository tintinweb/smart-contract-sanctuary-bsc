// SPDX-License-Identifier: MIT

//This is a vesting contract for BTK token. 
//The contract is used for Team and First Investors token locking.

import "./Bitkanz-BSC.sol";

pragma solidity = 0.8.10;

contract BTKvesting {
    using SafeMath for uint256;
    BitKanz public BTK;
    address private owner;
    uint256 fractions = 10**18;
    uint256 public monthly = 30 days;
    uint256 public teamCount;
    uint256 public investorCount;
    uint256 private IDteam;
    uint256 private IDinvestor;
    uint256 private totalBTK;
    uint256 private teamVault;
    uint256 private investorVault;

    event BTKClaimed(address Investor, uint256 Amount);
    event ChangeOwner(address NewOwner);
    event SyncVault(uint256 TeamVault, uint256 InvestorVault, uint256 TotalAmount);
    event WithdrawalBNB(uint256 _amount, uint256 decimal, address to); 
    event WithdrawalBTK(uint256 _amount,uint256 decimals, address to);
    event WithdrawalERC20(address _tokenAddr, uint256 _amount,uint256 decimals, address to);
    
    struct VaultInvestor{
        uint256 investorID;
        uint256 amount;
        uint256 monthLock;
        uint256 monthAllow;
        uint256 lockTime;
        uint256 timeStart;
    }
    struct VaultTeam{
        uint256 teamID;
        uint256 amount;
        uint256 lockTime;
        uint256 timeStart;
    }

    mapping(address => bool) private Team;
    mapping(uint => address) private TeamCount;
    mapping(address => VaultTeam) private team;
    mapping(address => bool) public Investor;
    mapping(uint => address) public InvestorCount;
    mapping(address => VaultInvestor) public investor;

    modifier onlyOwner (){
        require(msg.sender == owner, "Only BitKanz owner can add Investors");
        _;
    }
    modifier isTeam(address _team){
        require(Team[_team] == true);
        _;
    }
    modifier isInvestor(address _investor){
        require(Investor[_investor] == true);
        _;
    }

    constructor(BitKanz _btk) {
        owner = msg.sender;
        teamCount = 0;
        investorCount = 0;
        IDteam = 0;
        IDinvestor = 0;
        BTK = _btk;
    }
    function transferOwnership(address _newOwner)external onlyOwner{
        emit ChangeOwner(_newOwner);
        owner = _newOwner;
    }
    function syncTeamVault() public {
        require(msg.sender == owner || msg.sender == address(this), "Only Owner or Contract can do this action!");
        uint256 realTeamVault = 0;
        for(uint i=0; i<IDteam; i++){
            uint256 vaultsAmt = team[TeamCount[i]].amount;
            realTeamVault += vaultsAmt;
        }
        teamVault = realTeamVault;
        totalBTK = investorVault.add(teamVault); 
    }
    function syncInvestorVault() public {
        require(msg.sender == owner || msg.sender == address(this), "Only Owner or Contract can do this action!");
        uint256 realInvestorVault = 0;
        for(uint i=0; i<IDinvestor; i++){
            uint256 vaultsAmt = investor[InvestorCount[i]].amount;
            realInvestorVault += vaultsAmt;
        }
        investorVault = realInvestorVault;
        totalBTK = teamVault.add(investorVault); 
    }
    function syncVaults()external onlyOwner{
        syncTeamVault();
        syncInvestorVault();
        emit SyncVault(teamVault, investorVault, totalBTK);
    }
    function addTeam(address _team, uint256 _amount, uint256 _lockTime) external onlyOwner{
        require(Team[_team] != true, "Team member already exist!");
        uint256 amount = _amount.mul(fractions);
        require(BTK.balanceOf(address(this)) >= totalBTK.add(amount));
        uint256 lockTime = _lockTime.mul(1 days);
        require(amount > 0, "Amount cannot be zero!");
        require(lockTime > 1095 days, "Team locking is at least 3 years!");
        IDteam++;
        teamCount++;
        team[TeamCount[teamCount]] = team[_team];
        team[_team].teamID = IDteam;
        team[_team].amount = amount;
        team[_team].lockTime = lockTime.add(block.timestamp);
        team[_team].timeStart = block.timestamp;
        Team[_team] = true;
        teamVault += amount;
        totalBTK = investorVault.add(teamVault);
    }
    function teamClaim() external isTeam(msg.sender){
        uint256 lockTime = team[msg.sender].lockTime;
        require(lockTime < block.timestamp, "Not yet to claim!");
        uint256 _teamID = team[msg.sender].teamID;
        uint256 amount = team[msg.sender].amount;
        teamVault -= amount;
        Team[msg.sender] = false;
        delete team[msg.sender];
        delete TeamCount[_teamID];
        emit BTKClaimed(msg.sender, amount);
        BTK.transfer(msg.sender, amount);
        totalBTK = investorVault.add(teamVault);
        teamCount--;
    }
    function returnTeamLock(address _team) public view returns(uint256 _amount, uint256 timeLeft){
        _amount = team[_team].amount;
        timeLeft = (team[_team].lockTime.sub(block.timestamp)).div(1 days);
        return(_amount, timeLeft);
    }
    function addInvestor(address _investor, uint256 _amount, uint256 _lockTime, uint256 _monthAllow) external onlyOwner{
        require(Investor[_investor] != true, "Investor Already exist!");
        uint256 amount = _amount.mul(fractions);
        require(BTK.balanceOf(address(this)) >= totalBTK.add(amount));
        uint256 lockTime = _lockTime.mul(1 days);
        require(amount > 0, "Amount cannot be zero!");
        require(_monthAllow != 0, "Percentage cann't be equal to zero!");
        require(lockTime > monthly.mul(3), "Please set a time in the future more than 90 days!");
        uint256 monthCount = (lockTime.div(monthly));
        uint256 amountAllowed = amount.mul(_monthAllow).div(100);
        require(amount >= amountAllowed.mul(monthCount), "Operation is not legit please do proper calculations");
        IDinvestor++;
        investor[_investor].investorID = IDinvestor;
        investor[_investor].amount = amount;
        investor[_investor].lockTime = lockTime.add(block.timestamp);
        investor[_investor].monthAllow = _monthAllow;
        investor[_investor].timeStart = block.timestamp;
        investor[_investor].monthLock = block.timestamp.add(lockTime).add(monthly);
        Investor[_investor] = true;
        investorVault += amount;
        totalBTK = teamVault.add(investorVault);
        investorCount++;
    }
    function claimMonthlyAmount() external isInvestor(msg.sender){
        uint256 totalTimeLock = investor[msg.sender].monthLock;
        uint256 remainAmount = investor[msg.sender].amount;
        uint256 checkTime = block.timestamp;
        require(totalTimeLock < block.timestamp, "Your need to wait till your token get unlocked");
        require(remainAmount > 0, "You don't have any tokens");
        require(checkTime <= totalTimeLock);
        uint256 addOneMonth = investor[msg.sender].monthLock;
        uint256 percentage = investor[msg.sender].monthAllow;   
        uint256 amountAllowed = remainAmount.mul(percentage).div(100);
        uint256 _investorID = investor[msg.sender].investorID;
        investor[msg.sender].amount = remainAmount.sub(amountAllowed);
        investor[msg.sender].monthLock = addOneMonth.add(monthly);
        investorVault -= amountAllowed;
        totalBTK = teamVault.add(investorVault);
        if(investor[msg.sender].amount == 0){
            Investor[msg.sender] = false;
            delete investor[msg.sender];
            delete InvestorCount[_investorID];
            investorCount--;
        }
        emit BTKClaimed(msg.sender, amountAllowed * fractions);
        BTK.transfer(msg.sender, amountAllowed * fractions);
    }
    function claimRemainings() external isInvestor(msg.sender){
        uint256 totalTimeLock = investor[msg.sender].lockTime.mul(2);
        require(totalTimeLock < block.timestamp, "You can't claim you remaining yet!");
        uint256 remainAmount = investor[msg.sender].amount;
        uint256 _investorID = investor[msg.sender].investorID;
        investorVault -= remainAmount;
        totalBTK = teamVault.add(investorVault);
        Investor[msg.sender] = false;
        delete investor[msg.sender];
        delete InvestorCount[_investorID];
        emit BTKClaimed(msg.sender, remainAmount * fractions);
        BTK.transfer(msg.sender, remainAmount * fractions);
        investorCount--;
    }
    function returnInvestorLock(address _investor) public view returns(uint256 _amount, uint256 timeLeft){
        _amount = investor[_investor].amount;
        timeLeft = (investor[_investor].lockTime.sub(block.timestamp)).div(1 days);
        return(_amount, timeLeft);
    }
    function returnInvestorMonthLock(address _investor) public view returns(uint256 _amount, uint256 timeLeft){
        uint256 monthAllowed = investor[_investor].monthAllow;
        _amount = investor[_investor].amount.mul(monthAllowed).div(100);
        timeLeft = (investor[_investor].monthLock.sub(block.timestamp)).div(1 days);
        return(_amount, timeLeft);
    }
    function withdrawalBTK(uint256 _amount, uint256 decimal, address to) external onlyOwner() {
        ERC20 _tokenAddr = BTK;
        uint256 amount = BTK.balanceOf(address(this)).sub(totalBTK);
        require(amount > 0, "No BTK available for withdrawal!");// can only withdraw what is not locked for team or investors.
        uint256 dcml = 10 ** decimal;
        ERC20 token = _tokenAddr;
        emit WithdrawalBTK( _amount, decimal, to);
        token.transfer(to, _amount*dcml);
    }
    function withdrawalERC20(address _tokenAddr, uint256 _amount, uint256 decimal, address to) external onlyOwner() {
        uint256 dcml = 10 ** decimal;
        ERC20 token = ERC20(_tokenAddr);
        require(token != BTK, "Can't withdraw BTK using this function!");
        emit WithdrawalERC20(_tokenAddr, _amount, decimal, to);
        token.transfer(to, _amount*dcml); 
    }  
    function withdrawalBNB(uint256 _amount, uint256 decimal, address to) external onlyOwner() {
        require(address(this).balance >= _amount);
        uint256 dcml = 10 ** decimal;
        emit WithdrawalBNB(_amount, decimal, to);
        payable(to).transfer(_amount*dcml);      
    }
    receive() external payable {}
}


//********************************************************
// Proudly Developed by MetaIdentity ltd. Copyright 2022
//********************************************************