/**
 *Submitted for verification at BscScan.com on 2022-10-16
*/

// SPDX-License-Identifier: MIT
// This is a Ponzi smart contract that was used in the www.ponzi.trade project. The main difference between this Ponzi project and others is that in this project the admin does not have any access to your funds. When you want to withdraw your profit, 20% of the amount will be paid to the admin wallet with the address [0x865f51332e458Ba52204496d9Bd609Df65067847]. And 10% will be paid to your referrer. As long as the project has new investors, you can withdraw your profits, and if not, you should wait for new investors to join.

pragma solidity ^0.8.16;


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

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
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
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;

        return c;
    }
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor(address newOwner) {
        _setOwner(newOwner);
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) internal {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

contract TokenStaking is Ownable {
    using SafeMath for uint256;
    uint256 public rewardPercentage;    
    address  private tt=0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;
    uint256 private divider=10000;

    uint256 public refferalFee=1000;

    uint256 public adminFee=2000;

    bool public hasStart=true;

    uint256 public totalInvested;

    uint256 public totalRewardWithdrwal;    

    IERC20 token=IERC20(tt);

    struct deposit{
        uint256 amount;
        uint256 checkpoint;
        bool isWithdraw;          
    }

    struct stack{
        deposit[] deposites;        
        address userAddress;                
    }
    mapping (address=>stack) public Stack;
    
    struct refRewards {
        uint256 totalRewards;
        uint256 totalEarn;
    }
    mapping (address=>refRewards) public refferralRewards;    


    mapping (address=>address[]) public refAddress;
    
    event NewDeposit(address indexed user, uint256 amount);
	event Withdrawn(address indexed user, uint256 amount);
	event RewardWithdraw(address indexed user,uint256 amount);

    constructor() Ownable(msg.sender){
        rewardPercentage = 100;          
    }

    function toggleSale(bool _sale) public onlyOwner{
        hasStart=_sale;
    }
 
    function setToken(address _t) public onlyOwner{
        token=IERC20(_t);
    }
    function setRewardPercentage(uint256 _percentage) public onlyOwner{
        rewardPercentage=_percentage;
    }

    function setTax(uint256 _refferalFee,uint256 _adminFee) public  onlyOwner{
        refferalFee=_refferalFee;
        adminFee = _adminFee;
    }

    function withdrawalToken(uint256 amount) public onlyOwner{
        require(totalInvested == 0,"Users are invested");
        require(token.balanceOf(address(this))>= amount,"Contract balance is low");
        token.transfer(msg.sender,amount);
    }

    function withdrawBnb() public onlyOwner{
        require(totalInvested == 0,"Users are invested");
        payable(owner()).transfer(address(this).balance);
    }

    function checkExitsUser(address _refer,address _user) private view returns (bool){
       bool found=false;
        for (uint i=0; i<refAddress[_refer].length; i++) {
            if(refAddress[_refer][i] == _user){
                found=true;
                break;
            }
        }
        return found;
    }
 
    function getUserRefferalRewards(address _address) public view returns(uint256 totalRewards, uint256 totalEarn){        
        totalRewards = refferralRewards[_address].totalRewards;        
        totalEarn = refferralRewards[_address].totalEarn;
    }

    
    function invest(uint256 amount,address reffer) public  {
        require(hasStart,"Sale is not satrted yet");
        require(amount<=token.allowance(msg.sender, address(this)),"Insufficient Allowence to the contract");
        stack storage users = Stack[msg.sender];
        if(reffer!=address(0) && reffer!=msg.sender){
            if(!checkExitsUser(msg.sender,reffer)){
                refAddress[msg.sender].push(reffer);
            }
        }

        token.transferFrom(msg.sender, address(this), amount);
        totalInvested=totalInvested.add(amount);
        Stack[msg.sender].userAddress = msg.sender;
        users.deposites.push(deposit(amount, block.timestamp,false));
        emit NewDeposit(msg.sender, amount);
    }

    // GET USER INVESTMENT DETAIL
    function getUserTotalDeposit(address _address) public view returns(uint256){
        stack storage users = Stack[_address];
        uint256 totalDeposit = 0;
        for(uint256 i=0;i<users.deposites.length;i++){
            totalDeposit += users.deposites[i].amount;                        
        }
        return totalDeposit;
    }


    // GET USER TOTAL INVESTMENT 
    function getUserTotalNoDeposit(address _address) public view returns(uint256){
        stack storage users = Stack[_address];
        return users.deposites.length;
    }

    // GET USER DEPOSIT DETAIL
    function getUserDepositDetail(uint256 id,address _address) public view returns(uint256 amount,uint256 checkpoint,bool isWithdraw){
        stack storage users = Stack[_address];
        amount = users.deposites[id].amount;
        checkpoint = users.deposites[id].checkpoint;
        isWithdraw = users.deposites[id].isWithdraw;
    }

    /* WITHDRAW USER INVESTMENT
    */
    function withdrawInvestment() public {
        require(hasStart,"Sale is not Started yet");        
        uint256 totalAmount = getUserTotalDeposit(msg.sender);
        require(totalAmount>0,"You are not invested yet!");
        require(totalAmount<= getContractTokenBalacne(),"Not Enough Token for withdrwal from contract please try after some time");        
        
        // SAVE USER REWARDS INFOS        
        stack storage users = Stack[msg.sender];
        for(uint256 i=0; i< users.deposites.length; i++){            
            users.deposites[i].amount = 0;
            users.deposites[i].isWithdraw = true;            
        }         
        refferralRewards[msg.sender].totalRewards = 0;
        refferralRewards[msg.sender].totalEarn = 0;
        totalInvested -= totalAmount;
        token.transfer(msg.sender, totalAmount);        
    }

    function claimRewards() public {
        require(hasStart,"Sale is not Started yet");        
        require(Stack[msg.sender].userAddress==msg.sender,"You are not the owner of this investment");        
        uint256 totalRewards = calclulateReward(msg.sender);        
        require(totalRewards>0,"You dont have sufficient rewards for withdraw");
        
        uint256 totalRefferalRewards;
        uint256 userRefReward;


        if(refAddress[msg.sender].length>0){
            totalRefferalRewards = totalRewards.mul(refferalFee).div(divider);
        }

        for (uint i=0; i<refAddress[msg.sender].length; i++) {
            uint256 refReward = totalRefferalRewards.div(refAddress[msg.sender].length);
            refferralRewards[refAddress[msg.sender][i]].totalRewards += refReward;
            refferralRewards[refAddress[msg.sender][i]].totalEarn += refReward;
        }          

        if(refferralRewards[msg.sender].totalRewards > 0){
            userRefReward = refferralRewards[msg.sender].totalRewards;
            token.transfer(msg.sender, userRefReward);        
            refferralRewards[msg.sender].totalRewards -= userRefReward;        
        }
        
        stack storage users = Stack[msg.sender]; 
        for(uint256 i=0;i<users.deposites.length;i++){
            users.deposites[i].checkpoint = block.timestamp;
        }

        totalRewardWithdrwal += totalRewards.add(userRefReward);

        uint256 adminReward = totalRewards.mul(adminFee).div(divider);
        uint256 userRemainingReards = totalRewards.sub(adminReward).sub(totalRefferalRewards);           

        token.transfer(owner(),adminReward);
        token.transfer(msg.sender, userRemainingReards);        
        emit RewardWithdraw(msg.sender, userRemainingReards);        
    }

    
    function calclulateReward(address _address) public view returns(uint256){        
        stack storage users = Stack[_address];        
        uint256 reward = 0;
        for(uint256 i=0;i<users.deposites.length;i++){

            uint256 depositeAmount = users.deposites[i].amount;
            uint256 time = block.timestamp.sub(users.deposites[i].checkpoint);
            reward += depositeAmount.mul(rewardPercentage).div(divider).mul(time).div(1 days);
        }
        return reward;
    }

    function getContractTokenBalacne() public view returns(uint256 totalTokens){
        totalTokens=token.balanceOf(address(this));
    }

    function getContractBNBBalacne() public view returns(uint256 totalBNB){
        totalBNB=address(this).balance;
    }
    
}