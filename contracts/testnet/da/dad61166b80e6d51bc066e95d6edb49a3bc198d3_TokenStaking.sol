/**
 *Submitted for verification at BscScan.com on 2022-09-27
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

contract TokenStaking is Ownable {
    using SafeMath for uint256;
    uint256 public rewardPercentage;    

    uint256 private divider=10000;

    uint256 public refferalFee=1000;

    uint256 public adminFee=2000;

    bool public hasStart=true;

    uint256 public minimumInvestment = 10 ether;

    uint256 public totalInvested;

    uint256 public totalRewardWithdrwal;

    address [] usersAddress;

    IERC20 token=IERC20(0xC6B4F375375B14ed742ED0BBf83e74952Fe015e3);

    struct stack{
        uint256 amount;
        address userAddress;
        uint256 withdrawTime;
        uint256 checkPoint;
        bool isWithdrawal;
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
 

    function setRewardPercentage(uint256 _percentage) public onlyOwner{
        rewardPercentage=_percentage;
    }

    function setTax(uint256 _refferalFee,uint256 _adminFee) public  onlyOwner{
        refferalFee=_refferalFee;
        adminFee = _adminFee;
    }

    function withdrawalToken(uint256 amount) public onlyOwner{
        require(totalInvested == 0,"Users are invested");
        require(token.balanceOf(address(this))>= amount.mul(1e18),"Contract balance is low");
        token.transfer(msg.sender,amount.mul(1e18));
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


    function userInfo(uint256 amount) internal{
        Stack[msg.sender].amount=amount;
        Stack[msg.sender].userAddress=msg.sender;
        Stack[msg.sender].isWithdrawal=false;
        Stack[msg.sender].checkPoint=block.timestamp;
    }
 
    function getUserRefferalRewards(address _address) public view returns(uint256 totalRewards, uint256 totalEarn){        
        totalRewards = refferralRewards[_address].totalRewards;        
        totalEarn = refferralRewards[_address].totalEarn;
    }

    
    function invest(uint256 amount,address reffer) public  {
        require(hasStart,"Sale is not satrted yet");
        require(amount<=token.allowance(msg.sender, address(this)),"Insufficient Allowence to the contract");

        if(reffer!=address(0) && reffer!=msg.sender){
            if(!checkExitsUser(msg.sender,reffer)){
                refAddress[msg.sender].push(reffer);
            }
        }

        token.transferFrom(msg.sender, address(this), amount);
        totalInvested=totalInvested.add(amount);
        userInfo(amount);
        emit NewDeposit(msg.sender, amount);
    }

    function withdrawInvestment() public {
        require(hasStart,"Sale is not Started yet");
        require(Stack[msg.sender].userAddress==msg.sender,"You are not the owner of this investment");
        require(Stack[msg.sender].amount>0," No investment Found!");
        uint256 totalAmount=(Stack[msg.sender].amount);
        uint256 totalRewards=calclulateReward(msg.sender);
        require(totalRewards.add(totalAmount) <= getContractTokenBalacne(),"Not Enough Token for withdrwal from contract please try after some time");

        uint256 totalRefferalRewards = totalRewards.mul(refferalFee).div(divider);
        uint256 adminReward = totalRewards.mul(adminFee).div(divider);
        uint256 userRemainingReards = totalRewards.sub(adminReward).sub(totalRefferalRewards);

        for (uint i=0; i<refAddress[msg.sender].length; i++) {
            uint256 refReward = totalRefferalRewards.div(refAddress[msg.sender].length);
            refferralRewards[refAddress[msg.sender][i]].totalRewards += refReward;
            refferralRewards[refAddress[msg.sender][i]].totalEarn += refReward;
        }   

        Stack[msg.sender].checkPoint = block.timestamp;
        Stack[msg.sender].isWithdrawal = true;
        Stack[msg.sender].amount  = 0;
        totalInvested -= totalAmount;
        totalRewardWithdrwal += totalRewards;
        
        token.transfer(owner(),adminReward);
        token.transfer(msg.sender, userRemainingReards);
        token.transfer(msg.sender, totalAmount);
        emit RewardWithdraw(msg.sender, userRemainingReards);
    }
    

    function claimRefferalRewards() public {        
        require(refferralRewards[msg.sender].totalRewards>0,"You don't have rewards yet");
        require(refferralRewards[msg.sender].totalRewards<=getContractTokenBalacne(),"Not Enough Token for withdrwal from contract please try after some time");
        uint256 rewards = refferralRewards[msg.sender].totalRewards;
        token.transfer(msg.sender, rewards);        
        refferralRewards[msg.sender].totalRewards -= rewards;
    }

    
    function calclulateReward(address _address) public view returns(uint256 reward){
        require(Stack[_address].amount > 0,"No investment Yet!");
        uint256 depositeAmount=Stack[_address].amount;
        uint256 time=block.timestamp.sub(Stack[_address].checkPoint);
        reward=depositeAmount.mul(rewardPercentage).div(divider).mul(time).div(1 days);
    }

    function getContractTokenBalacne() public view returns(uint256 totalTokens){
        totalTokens=token.balanceOf(address(this));
    }

    function getContractBNBBalacne() public view returns(uint256 totalBNB){
        totalBNB=address(this).balance;
    }
    
}