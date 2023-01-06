/**
 *Submitted for verification at BscScan.com on 2023-01-05
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

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
        return msg.data;
    }
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

contract staking is Ownable {
    using SafeMath for uint256;

    address public devWallet;

    address public treasury;

    uint256 private divider=10000;

    uint256 public depositTax=1000;

    uint256 public withdrawTax=800;

    uint256 public withdrawRTax=500;

    uint256 public rewardTax=750;

    uint256 public referralTax=300;
   
    uint256 public reStakeTax=0;

    uint256 public totalInvestedBUSD;

    uint256 public totalWithdrawBUSD;

    uint256 public totalDevRewardsBUSD;

    uint256 [] public percentage=[110,330,550];

    address  [] public  tokens=[0xeD24FC36d5Ee211Ea25A80239Fb8C4Cfd80f12Ee];
/**
     *  0xeD24FC36d5Ee211Ea25A80239Fb8C4Cfd80f12Ee BSC testnet BUSD Token
        0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56 BSC Mainnet BUSD Token
     */
    struct deposit{
        uint256 amount;
        uint256 depositTime;
        bool isToken;
        uint256 checkPointBUSD;
    }

    struct user {
        deposit[] deposits;
        address referAddress;
        uint256 referralRewardsBUSD;
        uint256 totalRewardWithdrawBUSD;
        uint256 checkBusd;
        uint256 withdrawCheckBUSD;
    }

    mapping (address=>user) public investor;

    event NewDeposit(address indexed user, uint256 amount);
    event Compound(address indexed user, uint256 amount);
    event Restake(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);
    event RewardWithdraw(address indexed user,uint256 amount);
    event WithdrawnReferralReward(address indexed user, uint256 amount);
    constructor() Ownable(0x9DE3b7d3510bf42C22Bf09F915b275a897d8f8dD){
        devWallet=0xe5ce24b30Ca442330C9dcd5a63d8D838A9a3bB62;
        treasury=0xb1aDB5F0A54098FBA21F33804a4B58632119Eccc;
    }
    modifier onlyDev(){
        require(msg.sender==devWallet,"Error: Caller is invalid");
        _;
    }
    function setTax(uint256 _withdrawTax) public  onlyOwner{
        require(_withdrawTax>=800 && _withdrawTax<=2000,"Withdraw Fees Must be in the range of 8 to 20%");
        withdrawTax=_withdrawTax;
    }

    function invest(uint256 amount,address refer,address token) public  {
        require(token==tokens[0],"Invalid Token");
       
        require(amount<=IERC20(token).allowance(msg.sender, address(this)),"Insufficient Allowance to the contract");
        uint256 tax=amount.mul(depositTax).div(divider);
        uint256 referralFee=amount.mul(referralTax).div(divider);
        IERC20(token).transferFrom(msg.sender, treasury, tax);
        IERC20(token).transferFrom(msg.sender, address(this), amount.sub(tax));
       
        if(token==tokens[0]){
            totalInvestedBUSD=totalInvestedBUSD.add(amount.sub(tax));
            if(refer==address(0) || refer==msg.sender||refer==address(this)){
            investor[msg.sender].deposits.push(deposit(amount.sub(tax), block.timestamp,true,block.timestamp));
            }else{
                investor[msg.sender].referAddress=refer;
                investor[msg.sender].referralRewardsBUSD+=referralFee;
                investor[msg.sender].deposits.push(deposit(amount.sub(tax), block.timestamp,true,block.timestamp));
            }
           
            investor[msg.sender].checkBusd=block.timestamp;
            if(msg.sender==devWallet) totalDevRewardsBUSD=0;
        }
       
        emit NewDeposit(msg.sender, amount);
    }
   
    function compound() public  {
            (uint256 amount)=calculateReward(msg.sender);
            if(msg.sender==devWallet) {
                amount+=totalDevRewardsBUSD;
                totalDevRewardsBUSD=0;
            }
            totalInvestedBUSD=totalInvestedBUSD.add(amount);
            require(amount>0,"Compound Amount very low");
             uint256 tax=amount.mul(rewardTax).div(divider);
             totalDevRewardsBUSD+=tax;
            investor[msg.sender].deposits.push(deposit(amount, block.timestamp,true,block.timestamp));
            emit Compound(msg.sender, amount);
            for(uint256 i=0;i<investor[msg.sender].deposits.length;i++){
                if(investor[msg.sender].deposits[i].isToken){
                    investor[msg.sender].deposits[i].checkPointBUSD=block.timestamp;
                }
            }
            investor[msg.sender].withdrawCheckBUSD=block.timestamp;
            investor[msg.sender].checkBusd=block.timestamp;
       
    }
    function reStake() public payable {
        uint256 amount;
            amount=getUserTotalReferralRewardsBUSD(msg.sender);
            totalInvestedBUSD=totalInvestedBUSD.add(amount);
            investor[msg.sender].deposits.push(deposit(amount, block.timestamp,true,block.timestamp));
            investor[msg.sender].referralRewardsBUSD=0;
            investor[msg.sender].checkBusd=block.timestamp;
            uint256 tax=amount.mul(reStakeTax).div(divider);
            IERC20(tokens[0]).transfer(treasury, tax);
            emit Restake(msg.sender, amount);
       
    }
    function withdrawReferralReward()public {
        uint256 totalDeposit;   
            totalDeposit=getUserTotalReferralRewardsBUSD(msg.sender);
            require(totalDeposit>0,"No Deposit Found");
            require(totalDeposit<=getContractBUSDBalance(),"Not Enough Token for withdrawal from contract please try after some time");
            totalWithdrawBUSD+=totalDeposit;
            investor[msg.sender].referralRewardsBUSD=0;
            IERC20(tokens[0]).transfer(msg.sender, totalDeposit);
        emit WithdrawnReferralReward(msg.sender, totalDeposit);

    }
    function withdrawDevReward()public onlyDev{
        uint256 totalDeposit;
            totalDeposit=totalDevRewardsBUSD;
            require(totalDeposit>0,"Fund is very low");
            require(totalDeposit<=getContractBUSDBalance(),"Not Enough Token for withdrawal from contract please try after some time");
            totalWithdrawBUSD+=totalDeposit;
            totalDevRewardsBUSD=0;
            IERC20(tokens[0]).transfer(msg.sender, totalDeposit);
    }
    function withdrawTokensBUSD(uint256 id)public {
        require (id <= investor[msg.sender].deposits.length,"Invalid Id");
        require (investor[msg.sender].deposits[id].isToken,"Not A BUSD Deposit");
        uint256 totalDeposit=investor[msg.sender].deposits[id].amount;
        require(totalDeposit>0,"No Deposit Found");
        require(totalDeposit<=getContractBUSDBalance(),"Not Enough Token for withdrawal from contract please try after some time");
        uint256 tax=totalDeposit.mul(withdrawTax).div(divider);
        IERC20(tokens[0]).transfer(msg.sender, totalDeposit.sub(tax));
        IERC20(tokens[0]).transfer(treasury, tax);
        remove(id);
        totalWithdrawBUSD+=totalDeposit;
        investor[msg.sender].checkBusd=block.timestamp;
        investor[msg.sender].withdrawCheckBUSD=block.timestamp;
       
        emit Withdrawn(msg.sender, totalDeposit);
    }
    function withdrawRewardBUSD()public {
        (uint256 totalRewards)=calculateReward(msg.sender);
        require(totalRewards>0,"No Rewards Found");
        require(totalRewards<=getContractBUSDBalance(),"Not Enough Token for withdrawal from contract please try after some time");
        uint256 tax=totalRewards.mul(rewardTax).div(divider);
        uint256 taxR=totalRewards.mul(withdrawRTax).div(divider);
        totalDevRewardsBUSD+=tax;
        totalWithdrawBUSD+=totalRewards;
        IERC20(tokens[0]).transfer(msg.sender, totalRewards.sub(taxR));
        if(investor[msg.sender].referAddress!=address(0)) investor[investor[msg.sender].referAddress].referralRewardsBUSD+=taxR;
        for(uint256 i=0;i<investor[msg.sender].deposits.length;i++){
            if(investor[msg.sender].deposits[i].isToken) investor[msg.sender].deposits[i].checkPointBUSD=block.timestamp;
        }
        investor[msg.sender].totalRewardWithdrawBUSD+=totalRewards;
        investor[msg.sender].checkBusd=block.timestamp;
       
        emit RewardWithdraw(msg.sender, totalRewards);
    } 
    function remove(uint256 index) internal {
       
        investor[msg.sender].deposits[index].amount =0;
        investor[msg.sender].deposits[index].depositTime =0;
        investor[msg.sender].deposits[index].checkPointBUSD =0;
    }
    function calculateReward(address _user) public view returns(uint256){
        uint256 totalRewardBUSD;
        uint256 reward1;
        uint256 reward2;
        uint256 reward3;
        user storage users=investor[_user];
        for(uint256 i=0;i<users.deposits.length;i++){
            uint256 time=block.timestamp.sub(users.deposits[i].checkPointBUSD);
                if(time<=20 days){
                    reward1+=users.deposits[i].amount.mul(percentage[0]).div(divider).mul(time).div(1 days);
                }else if(time>=20 days && time<=40 days){
                    reward2+=users.deposits[i].amount.mul(percentage[1]).div(divider).mul(time.sub(20 days)).div(1 days);
                    reward1+=users.deposits[i].amount.mul(percentage[0]).div(divider).mul(20 days).div(1 days);
                }else if(time>40 days){
                    reward3+=users.deposits[i].amount.mul(percentage[2]).div(divider).mul(time.sub(40 days)).div(1 days);
                    reward2+=users.deposits[i].amount.mul(percentage[1]).div(divider).mul(20 days).div(1 days);
                    reward1+=users.deposits[i].amount.mul(percentage[0]).div(divider).mul(20 days).div(1 days);
                }
                totalRewardBUSD=reward1.add(reward2).add(reward3);
        }
        return(totalRewardBUSD);
    }
    function getUserTotalDepositBUSD(address _user) public view returns(uint256 _totalInvestment){
        for(uint256 i=0;i<investor[_user].deposits.length;i++){
            if(investor[_user].deposits[i].isToken){
                _totalInvestment=_totalInvestment.add(investor[_user].deposits[i].amount);
            }
        }
    }
        function getUserTotalRewardWithdrawBUSD(address _user) public view returns(uint256 _totalWithdraw){
        _totalWithdraw=investor[_user].totalRewardWithdrawBUSD;
    }
        function getUserTotalReferralRewardsBUSD(address _user) public view returns(uint256 _totalReferralRewards){
        _totalReferralRewards=investor[_user].referralRewardsBUSD;
    }
    function getContractBUSDBalance() public view returns(uint256 totalBUSD){
        totalBUSD=IERC20(tokens[0]).balanceOf(address(this));
    }
    function getUserDepositHistoryBUSD( address _user) public view  returns(uint256[] memory,uint256[] memory){
        uint256[] memory amount = new uint256[](investor[_user].deposits.length);
        uint256[] memory time = new uint256[](investor[_user].deposits.length);
        for(uint256 i=0;i<investor[_user].deposits.length;i++){
            if(investor[_user].deposits[i].isToken){
                amount[i]=investor[_user].deposits[i].amount;
                time[i]=investor[_user].deposits[i].depositTime;
            }
        }
        return(amount,time);
    }
        receive() external payable {
     
    }
     
}