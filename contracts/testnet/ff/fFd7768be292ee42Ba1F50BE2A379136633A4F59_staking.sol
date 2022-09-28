/**
 *Submitted for verification at BscScan.com on 2022-09-22
*/

// SPDX-License-Identifier: MIT
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

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}


/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor(address newOwner) {
        _setOwner(newOwner);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
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

contract staking is Ownable {
    using SafeMath for uint256;
    uint256 public rewardPercentage;

    address public treasury;

    uint256 private divider=10000;
    
    uint256 public depoiteFee=1500;

    uint256 public withdrawFee=1500;

    uint256 public refferalFee=100;

    bool public hasStart=true;

    uint256 public currentID=1;

    uint256 public minimumAmount=100 ether;

    uint256 public maximumAmount=1000000 ether;

    uint256 public totalInvested;

    uint256 public totalRewardWithdrwal;

    address [] usersAddress;

    IERC20 token=IERC20(0xe826b470e02d88Db83cA62c84676b4E803c1636C);

    struct stack{
        uint256 amount;
        address userAddress;
        uint256 time;
        uint256 withdrawTime;
        uint256 stackId;
        uint256 checkPoint;
        bool isWithdrawal;
    }
    
    struct refRewards {
        uint256 totalRewards;
        uint256 totalEarn;
    }

    mapping (uint256=>stack) public Stack;
    mapping (address=>refRewards) public refferralRewards;
    mapping(address=>uint256[]) private userIds;
    
    event NewDeposit(address indexed user, uint256 amount);
	event Withdrawn(address indexed user, uint256 amount);
	event RewardWithdraw(address indexed user,uint256 amount);

    constructor() Ownable(msg.sender){
        rewardPercentage = 150;  
        treasury=0x3344a5E3066c58438E19D0f9400fA4aDac8f1460;
    }


    function toggleSale(bool _sale) public onlyOwner{
        hasStart=_sale;
    }

    function setMinMaxAmount(uint256 _min,uint256 _max) public onlyOwner{
        minimumAmount = _min;
        maximumAmount = _max;
    }    

    function setRewardPercentage(uint256 _percentage) public onlyOwner{
        rewardPercentage=_percentage;
    }

    function setTax(uint256 _depoiteFee,uint256 _withdrawFee,uint256 _refferalFee) public  onlyOwner{
        depoiteFee=_depoiteFee;
        withdrawFee=_withdrawFee;
        refferalFee=_refferalFee;
    }
    
    function setWallet( address _treasury) public  onlyOwner{
        treasury=_treasury;
    }

    function withdrawalToken(uint256 amount) public onlyOwner{
        require(token.balanceOf(address(this))>= amount.mul(1e18),"Contract balance is low");
        token.transfer(msg.sender,amount.mul(1e18));
    }

    function withdrawBnb() public onlyOwner{
        payable(owner()).transfer(address(this).balance);
    }

    function checkExitsUser(address _user) private view returns (bool){
       bool found=false;
        for (uint i=0; i<usersAddress.length; i++) {
            if(usersAddress[i]==_user){
                found=true;
                break;
            }
        }
        return found;
    }


    function userInfo(uint256 amount,uint256 lockingPeriod) internal{
        Stack[currentID].amount=amount;
        Stack[currentID].userAddress=msg.sender;
        Stack[currentID].time=block.timestamp;
        Stack[currentID].withdrawTime=lockingPeriod;
        Stack[currentID].stackId=currentID;
        Stack[currentID].isWithdrawal=false;
        Stack[currentID].checkPoint=block.timestamp;
        userIds[msg.sender].push(currentID);
        currentID=currentID+1; 
     }
 
    function getUserRefferalRewards(address _address) public view returns(uint256 totalRewards, uint256 totalEarn){        
        totalRewards = refferralRewards[_address].totalRewards;        
        totalEarn = refferralRewards[_address].totalEarn;
    }

    
    function invest(uint256 amount,address reffer,uint256 lockingPeriod) public  {
        require(hasStart,"Sale is not satrted yet");
        require(amount<=token.allowance(msg.sender, address(this)),"Insufficient Allowence to the contract");
        require(minimumAmount<=amount,"Amount greater then minimum amount");
        require(maximumAmount>=amount,"Amount less then maximum amount");
        uint256 depositeTax=amount.mul(depoiteFee).div(divider);
        uint256 RefferalTax=0;
        if(reffer!=address(0) && reffer!=msg.sender){
            RefferalTax=amount.mul(refferalFee).div(divider);            
            refferralRewards[reffer].totalRewards += RefferalTax;
            refferralRewards[reffer].totalEarn += RefferalTax;
        }
        token.transferFrom(msg.sender, treasury, depositeTax);
        token.transferFrom(msg.sender, address(this), amount.sub(depositeTax).sub(RefferalTax));
        if(!checkExitsUser(msg.sender)){
            usersAddress.push(msg.sender);
        }
        totalInvested=totalInvested.add(amount);
        userInfo(amount,lockingPeriod);
        emit NewDeposit(msg.sender, amount);
    }

    function withdrawReward( uint256 id)public {
        require(hasStart,"Sale is not Started yet");
        require(Stack[id].userAddress==msg.sender,"You are not the owner of this investment");
        uint256 totalRewards=calclulateReward(id);
        require(totalRewards>0,"No Rewards Found");
        require(totalRewards<=getContractBUSDBalacne(),"Not Enough Token for withdrwal from contract please try after some time");
        totalRewardWithdrwal=totalRewardWithdrwal+totalRewards;
        Stack[id].checkPoint=block.timestamp;
        token.transfer(msg.sender, totalRewards);
        emit RewardWithdraw(msg.sender, totalRewards);
    }
    
    function claimInvestedTokens(uint256 id) public{
        require(hasStart,"Stacking is not Start yet");
        require(!Stack[id].isWithdrawal,"Amount Already withdrawl");
        require(Stack[id].userAddress==msg.sender,"You are not the owner of this investment");        
        uint256 totalAmount=(Stack[id].amount);
        require(totalAmount<=getContractBUSDBalacne(),"Not Enough Token for withdrwal from contract please try after some time");
        Stack[id].isWithdrawal=true;
        uint256 Withdrawtax=totalAmount.mul(withdrawFee).div(divider);
        token.transfer(treasury, Withdrawtax);
        token.transfer(msg.sender, totalAmount.sub(Withdrawtax));
        totalRewardWithdrwal=totalRewardWithdrwal+totalAmount;
        emit Withdrawn(msg.sender, totalAmount);
    }

    function claimRefferalRewards() public {        
        require(refferralRewards[msg.sender].totalRewards>0,"You don't have rewards yet");
        require(refferralRewards[msg.sender].totalRewards<=getContractBUSDBalacne(),"Not Enough Token for withdrwal from contract please try after some time");
        uint256 rewards = refferralRewards[msg.sender].totalRewards;
        token.transfer(msg.sender, rewards);
        refferralRewards[msg.sender].totalRewards -= rewards;
    }

    function reinvest(uint256 id) public {
        require(hasStart,"Staking is not started");
        require(Stack[id].userAddress==msg.sender,"You are not the owner of this stake");
        require(!Stack[id].isWithdrawal,"You are already withdraw");
        uint256 reward = calclulateReward(id);
        Stack[id].amount += reward;
    }
    
    function calclulateReward(uint256 id) public view returns(uint256 reward){
        uint256 depositeAmount=Stack[id].amount;
        uint256 time=block.timestamp.sub(Stack[id].checkPoint);
        reward=depositeAmount.mul(rewardPercentage).div(divider).mul(time).div(1 days);
    }

    function getContractBUSDBalacne() public view returns(uint256 totalBUSD){
        totalBUSD=token.balanceOf(address(this));
    }

    function getContractBNBBalacne() public view returns(uint256 totalBNB){
        totalBNB=address(this).balance;
    }

    function totalUsers() public view returns(uint256 totalUsers){
        totalUsers=usersAddress.length;
    }
    function getUserDepositeIds(address _userAdd) public view returns(uint256[] memory){
         uint256[] memory ids = new uint256[](userIds[_userAdd].length);
         for(uint i=0;i<userIds[_userAdd].length;i++){
             ids[i]=userIds[_userAdd][i];
         }
         return ids;

    }
    
}