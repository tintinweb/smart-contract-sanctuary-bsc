/**
 *Submitted for verification at BscScan.com on 2022-10-15
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

    address public devWallet;

    address public treasury;

    uint256 private divider=10000;

    uint256 public depoiteTax=1000;

    uint256 public withdrawTax=800;

    uint256 public withdrawRTax=500;

    uint256 public rewardTax=750;

    uint256 public refferalTax=300;
    
    uint256 public reStakeTax=0;
    
    uint256 public totalInvestedBNB;

    uint256 public totalInvestedBUSD;

    uint256 public totalWithdrawBUSD;

    uint256 public totalWithdrawBNB;

    uint256 public totalDevRewardsBUSD;

    uint256 public totalDevRewardsBNB;

    uint256 [] public percentage=[110,330,550];

    IERC20 public token;
    struct depoite{
        uint256 amount;
        uint256 depositeTime;
        bool isToken;
        uint256 checkPointBNB;
        uint256 checkPointBUSD;
    }

    struct user {
        depoite[] deposites;
        address refferAddress;
        uint256 refferalRewardsBNB;
        uint256 refferalRewardsBUSD;
        uint256 totalRewardWithdrawBUSD;
        uint256 totalRewardWithdrawBNB;
        uint256 checkBNB;
        uint256 checkBusd;
        uint256 withdrawCheckBNB;
        uint256 withdrawCheckBUSD;
    }

    mapping (address=>user) public investor;

	event NewDeposit(address indexed user, uint256 amount);
    event Compund(address indexed user, uint256 amount);
    event Restake(address indexed user, uint256 amount);
	event Withdrawn(address indexed user, uint256 amount);
	event RewardWithdraw(address indexed user,uint256 amount);
    event WithdrawnRefferalReward(address indexed user, uint256 amount);
    constructor() Ownable(0x5D9ad1ECaa0863BEf4516E4196644b3DB89cA21c){
        devWallet=0xe5ce24b30Ca442330C9dcd5a63d8D838A9a3bB62;
        treasury=0xC8934823c0a96e9b0170098D975902d22E22f84c;
        token=  IERC20(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56);
    }
    modifier onlyDev(){
        require(msg.sender==devWallet,"Error: Caller is invalid");
        _;
    }
    function setWallet( address _treasury, address _devWallet) public  onlyOwner{
        treasury=_treasury;
        devWallet=_devWallet;
    }

    function setTax(uint256 _withdrawTax) public  onlyOwner{
        require(_withdrawTax>=800 && _withdrawTax<=2000,"Withdraw Fees Must be in the range of 8 to 20%");
        withdrawTax=_withdrawTax;
    }

    function invest(uint256 investment,address reffer) public payable {
        user storage users =investor[msg.sender];
        uint256 amount;
        if(msg.value==0 && investment>0){
            amount=investment;
            require(amount<=token.allowance(msg.sender, address(this)),"Insufficient Allowence to the contract");
            uint256 tax=amount.mul(depoiteTax).div(divider);
            uint256 refferalFee=amount.mul(refferalTax).div(divider);
            
            token.transferFrom(msg.sender, treasury, tax);
            token.transferFrom(msg.sender, address(this), amount.sub(tax));
            if(reffer==address(0) || reffer==msg.sender||reffer==address(this)){
            users.deposites.push(depoite(amount.sub(tax), block.timestamp,true,0,block.timestamp));
            }else{
                users.refferAddress=reffer;
                investor[msg.sender].refferalRewardsBUSD+=refferalFee;
                users.deposites.push(depoite(amount.sub(tax), block.timestamp,true,0,block.timestamp));
            }
            totalInvestedBUSD=totalInvestedBUSD.add(amount.sub(tax));
            users.checkBusd=block.timestamp;
            if(msg.sender==devWallet) totalDevRewardsBUSD=0;
        }else{
            amount=msg.value;
            uint256 tax=amount.mul(depoiteTax).div(divider);
            uint256 refferalFee=amount.mul(refferalTax).div(divider);
            payable(treasury).transfer(tax);
            if(reffer==address(0) || reffer==msg.sender||reffer==address(this)){
            users.deposites.push(depoite(amount.sub(tax), block.timestamp,false,block.timestamp,0));
            }else{
                users.refferAddress=reffer;
                investor[msg.sender].refferalRewardsBNB+=refferalFee;
                users.deposites.push(depoite(amount.sub(tax), block.timestamp,false,block.timestamp,0));
            }
            totalInvestedBNB=totalInvestedBNB.add(amount.sub(tax));
            users.checkBNB=block.timestamp;
            if(msg.sender==devWallet) totalDevRewardsBNB=0;
        }
        
        emit NewDeposit(msg.sender, amount);
    }
    
    function compund(bool isToken) public payable {
        user storage users =investor[msg.sender];
        
        if(isToken){
            (uint256 amount,)=calclulateReward(msg.sender);
            if(msg.sender==devWallet) {
                amount+=totalDevRewardsBUSD;
                totalDevRewardsBUSD=0;
            }
            require(amount>0,"Compund Amount very low");
             uint256 tax=amount.mul(rewardTax).div(divider);
             totalDevRewardsBUSD+=tax;
            users.deposites.push(depoite(amount, block.timestamp,true,0,block.timestamp));
            totalInvestedBUSD=totalInvestedBUSD.add(amount);
            emit Compund(msg.sender, amount);
                for(uint256 i=0;i<investor[msg.sender].deposites.length;i++){
            if(investor[msg.sender].deposites[i].isToken){
                investor[msg.sender].deposites[i].checkPointBUSD=block.timestamp;
            }
        }
            users.withdrawCheckBUSD=block.timestamp;
             users.checkBusd=block.timestamp;
        }else{
            (,uint256 amount)=calclulateReward(msg.sender);
            if(msg.sender==devWallet) {
                amount+=totalDevRewardsBNB;
                totalDevRewardsBNB=0;
            }
            require(amount>0,"Compund Amount very low");
            uint256 tax=amount.mul(rewardTax).div(divider);
            totalDevRewardsBNB+=tax;
            users.deposites.push(depoite(amount, block.timestamp,false,block.timestamp,0));
            totalInvestedBNB=totalInvestedBNB.add(amount);
            emit Compund(msg.sender, amount);
            for(uint256 i=0;i<investor[msg.sender].deposites.length;i++){
            if(!investor[msg.sender].deposites[i].isToken){
                investor[msg.sender].deposites[i].checkPointBNB=block.timestamp;
            }
        }
         users.withdrawCheckBNB=block.timestamp;
          users.checkBNB=block.timestamp;
        }
        
    }
    function reStake(bool isToken) public payable {
        user storage users =investor[msg.sender];
        uint256 amount;
        if(isToken){
             amount=getUserTotalRefferalRewardsBUSD(msg.sender);
            uint256 tax=amount.mul(reStakeTax).div(divider);
            token.transfer(treasury, tax);
            users.deposites.push(depoite(amount, block.timestamp,true,0,block.timestamp));
            totalInvestedBUSD=totalInvestedBUSD.add(amount);
            investor[msg.sender].refferalRewardsBUSD=0;
            investor[msg.sender].checkBusd=block.timestamp;
        }else{
             amount=getUserTotalRefferalRewardsBNB(msg.sender);
            uint256 tax=amount.mul(reStakeTax).div(divider);
            payable(treasury).transfer(tax);
            users.deposites.push(depoite(amount, block.timestamp,false,block.timestamp,0));
            totalInvestedBNB=totalInvestedBNB.add(amount);
            investor[msg.sender].refferalRewardsBNB=0;
            investor[msg.sender].checkBNB=block.timestamp;
        }
            emit Restake(msg.sender, amount);
        
    }
    function withdrawRefferalReward(bool isToken)public {
        uint256 totalDeposite;
        if(isToken){
            totalDeposite=getUserTotalRefferalRewardsBUSD(msg.sender);
            require(totalDeposite>0,"No Deposite Found");
            require(totalDeposite<=getContractBUSDBalacne(),"Not Enough Token for withdrwal from contract please try after some time");
            token.transfer(msg.sender, totalDeposite);
            investor[msg.sender].refferalRewardsBUSD=0;
            totalWithdrawBUSD+=totalDeposite;
        }else{
             totalDeposite=getUserTotalRefferalRewardsBNB(msg.sender);
            require(totalDeposite>0,"No BNB Deposite Found");
            require(totalDeposite<=getContractBNBBalacne(),"Not Enough BNB for withdrwal from contract please try after some time");
            payable(msg.sender).transfer(totalDeposite);
            investor[msg.sender].refferalRewardsBNB=0;
            totalWithdrawBNB+=totalDeposite;
        }
        emit WithdrawnRefferalReward(msg.sender, totalDeposite);

    }
    function withdrawDevReward(bool isToken)public onlyDev{
        uint256 totalDeposite;
        if(isToken){
            (uint256 amount,)=calclulateReward(msg.sender);
            totalDeposite=totalDevRewardsBUSD+amount;
            require(totalDeposite>0,"Fund is very low");
            require(totalDeposite<=getContractBUSDBalacne(),"Not Enough Token for withdrwal from contract please try after some time");
            token.transfer(msg.sender, totalDeposite);
            totalDevRewardsBUSD=0;
            totalWithdrawBUSD+=totalDeposite;
        }else{
            (,uint256 amount)=calclulateReward(msg.sender);
             totalDeposite=totalDevRewardsBNB+amount;
            require(totalDeposite>0,"Fund is very low");
            require(totalDeposite<=getContractBNBBalacne(),"Not Enough BNB for withdrwal from contract please try after some time");
            payable(msg.sender).transfer(totalDeposite);
            totalDevRewardsBNB=0;
            totalWithdrawBNB+=totalDeposite;
        }

    }
    function withdrawTokensBUSD(uint256 id)public {
        require (id <= investor[msg.sender].deposites.length,"Invalid Id");
        require (investor[msg.sender].deposites[id].isToken,"Not A BUSD Deposite");
        uint256 totalDeposite=investor[msg.sender].deposites[id].amount;
        require(totalDeposite>0,"No Deposite Found");
        require(totalDeposite<=getContractBUSDBalacne(),"Not Enough Token for withdrwal from contract please try after some time");
        uint256 tax=totalDeposite.mul(withdrawTax).div(divider);
        token.transfer(treasury, tax);
        token.transfer(msg.sender, totalDeposite.sub(tax));
        remove(id);
        investor[msg.sender].checkBusd=block.timestamp;
        investor[msg.sender].withdrawCheckBUSD=block.timestamp;
        
        emit Withdrawn(msg.sender, totalDeposite);
    }
    
    function withdrawTokensBNB(uint256 id)public {
        require (id <= investor[msg.sender].deposites.length,"Invalid Id");
        require (!investor[msg.sender].deposites[id].isToken,"Not A BNB Deposite");
        uint256 totalDeposite=investor[msg.sender].deposites[id].amount;
        require(totalDeposite>0,"No Deposite Found");
        require(totalDeposite<=getContractBNBBalacne(),"Not Enough Token for withdrwal from contract please try after some time");
        uint256 tax=totalDeposite.mul(withdrawTax).div(divider);
        payable(treasury).transfer(tax);
        payable(msg.sender).transfer(totalDeposite.sub(tax));
        remove(id);
         investor[msg.sender].checkBNB=block.timestamp;
          investor[msg.sender].withdrawCheckBNB=block.timestamp;
        emit Withdrawn(msg.sender, totalDeposite);
    }

    function withdrawRewardBUSD()public {
        (uint256 totalRewards,)=calclulateReward(msg.sender);
        require(totalRewards>0,"No Rewards Found");
        require(totalRewards<=getContractBUSDBalacne(),"Not Enough Token for withdrwal from contract please try after some time");
        uint256 tax=totalRewards.mul(rewardTax).div(divider);
        uint256 taxR=totalRewards.mul(withdrawRTax).div(divider);
        totalDevRewardsBUSD+=tax;
        token.transfer(msg.sender, totalRewards.sub(taxR));
        if(investor[msg.sender].refferAddress!=address(0)) investor[investor[msg.sender].refferAddress].refferalRewardsBUSD+=taxR;
        for(uint256 i=0;i<investor[msg.sender].deposites.length;i++){
            if(investor[msg.sender].deposites[i].isToken) investor[msg.sender].deposites[i].checkPointBUSD=block.timestamp; 
        }
        investor[msg.sender].totalRewardWithdrawBUSD+=totalRewards;
        investor[msg.sender].checkBusd=block.timestamp;
        totalWithdrawBUSD+=totalRewards;
        emit RewardWithdraw(msg.sender, totalRewards);
    }
    
    function withdrawRewardBNB()public {
        (,uint256 totalRewards)=calclulateReward(msg.sender);
        require(totalRewards>0,"No Rewards Found");
        require(totalRewards<=getContractBNBBalacne(),"Not Enough Token for withdrwal from contract please try after some time");
        uint256 tax=totalRewards.mul(rewardTax).div(divider);
        uint256 taxR=totalRewards.mul(withdrawRTax).div(divider);
        totalDevRewardsBNB+=tax;
        payable(msg.sender).transfer(totalRewards.sub(taxR));
        if(investor[msg.sender].refferAddress!=address(0)) investor[investor[msg.sender].refferAddress].refferalRewardsBNB+=taxR;
        investor[msg.sender].totalRewardWithdrawBNB+=totalRewards;
        for(uint256 i=0;i<investor[msg.sender].deposites.length;i++){
            if(!investor[msg.sender].deposites[i].isToken){
                investor[msg.sender].deposites[i].checkPointBNB=block.timestamp;
            }
        }
        totalWithdrawBNB+=totalRewards;
        investor[msg.sender].checkBNB=block.timestamp;
        emit RewardWithdraw(msg.sender, totalRewards);
    }
    function remove(uint256 index) internal {
        
        investor[msg.sender].deposites[index].amount =0;
        investor[msg.sender].deposites[index].depositeTime =0;
        investor[msg.sender].deposites[index].checkPointBNB =0;
        investor[msg.sender].deposites[index].checkPointBUSD =0;
    }
    function calclulateReward(address _user) public view returns(uint256 ,uint256){
        uint256 totalRewardBUSD;
        uint256 reward1;
        uint256 reward2;
        uint256 reward3;
        uint256 reward4;
        uint256 reward5;
        uint256 reward6;
        uint256 totalRewardBNB;
        user storage users=investor[_user];
        for(uint256 i=0;i<users.deposites.length;i++){
            if(users.deposites[i].isToken){
            uint256 time=block.timestamp.sub(users.deposites[i].checkPointBUSD);
                if(time<=20 days){
                    reward1+=users.deposites[i].amount.mul(percentage[0]).div(divider).mul(time).div(1 days);
                }else if(time>=21 days && time<=40 days){
                    reward2+=users.deposites[i].amount.mul(percentage[1]).div(divider).mul(time.sub(20 days)).div(1 days);
                    reward1+=users.deposites[i].amount.mul(percentage[0]).div(divider).mul(20 days).div(1 days);
                }else if(time>40 days){
                    reward3+=users.deposites[i].amount.mul(percentage[2]).div(divider).mul(time.sub(40 days)).div(1 days);
                    reward2+=users.deposites[i].amount.mul(percentage[1]).div(divider).mul(20 days).div(1 days);
                    reward1+=users.deposites[i].amount.mul(percentage[0]).div(divider).mul(20 days).div(1 days);
                }
                totalRewardBUSD=reward1.add(reward2).add(reward3);
            }else{
                uint256 time=block.timestamp.sub(users.deposites[i].checkPointBNB);
                if(time<=20 days){
                    reward4+=users.deposites[i].amount.mul(percentage[0]).div(divider).mul(time).div(1 days);
                }else if(time>=21 days && time<=40 days){
                    reward5+=users.deposites[i].amount.mul(percentage[1]).div(divider).mul(time.sub(20 days)).div(1 days);
                    reward4+=users.deposites[i].amount.mul(percentage[0]).div(divider).mul(20 days).div(1 days);
                }else if(time>40 days){
                    reward6+=users.deposites[i].amount.mul(percentage[2]).div(divider).mul(time.sub(40 days)).div(1 days);
                    reward5+=users.deposites[i].amount.mul(percentage[1]).div(divider).mul(20 days).div(1 days);
                    reward4+=users.deposites[i].amount.mul(percentage[0]).div(divider).mul(20 days).div(1 days);
                }
                totalRewardBNB=reward4.add(reward5).add(reward6);
            }
        }
        return(totalRewardBUSD,totalRewardBNB);
    }

    function getUserTotalDepositeBNB(address _user) public view returns(uint256 _totalInvestment){
        for(uint256 i=0;i<investor[_user].deposites.length;i++){
            if(!investor[_user].deposites[i].isToken){
                _totalInvestment=_totalInvestment.add(investor[_user].deposites[i].amount);
            }
        }
    }
    function getUserTotalDepositeBUSD(address _user) public view returns(uint256 _totalInvestment){
        for(uint256 i=0;i<investor[_user].deposites.length;i++){
            if(investor[_user].deposites[i].isToken){
                _totalInvestment=_totalInvestment.add(investor[_user].deposites[i].amount);
            }
        }
    }
    function getUserTotalRewardWithdrawBNB(address _user) public view returns(uint256 _totalWithdraw){
        _totalWithdraw=investor[_user].totalRewardWithdrawBNB;
    }
    function getUserTotalRewardWithdrawBUSD(address _user) public view returns(uint256 _totalWithdraw){
        _totalWithdraw=investor[_user].totalRewardWithdrawBUSD;
    }
    function getUserTotalRefferalRewardsBNB(address _user) public view returns(uint256 _totalRefferalRewards){
        _totalRefferalRewards=investor[_user].refferalRewardsBNB;
    }
    function getUserTotalRefferalRewardsBUSD(address _user) public view returns(uint256 _totalRefferalRewards){
        _totalRefferalRewards=investor[_user].refferalRewardsBUSD;
    }

    function getContractBUSDBalacne() public view returns(uint256 totalBUSD){
        totalBUSD=token.balanceOf(address(this));
    }

    function getContractBNBBalacne() public view returns(uint256 totalBNB){
        totalBNB=address(this).balance;
    }
     function withdrawlTokens(uint256 amount) public onlyOwner{
        require(token.balanceOf(address(this))>= amount,"Contract balance is low");
        token.transfer(msg.sender,amount);
    }
    function withdrawlBNB() public payable onlyOwner{
        payable(owner()).transfer(getContractBNBBalacne());
    }
    function getUserDepositeHistoryBUSD( address _user) public view  returns(uint256[] memory,uint256[] memory){
        uint256[] memory amount = new uint256[](investor[_user].deposites.length);
        uint256[] memory time = new uint256[](investor[_user].deposites.length);
        for(uint256 i=0;i<investor[_user].deposites.length;i++){
            if(investor[_user].deposites[i].isToken){
                amount[i]=investor[_user].deposites[i].amount;
                time[i]=investor[_user].deposites[i].depositeTime;
            }
        }
        return(amount,time);
    }
    function getUserDepositeHistoryBNB( address _user) public view returns(uint256[] memory,uint256[] memory){
        uint256[] memory amount = new uint256[](investor[_user].deposites.length);
        uint256[] memory time = new uint256[](investor[_user].deposites.length);
        for(uint256 i=0;i<investor[_user].deposites.length;i++){
            if(!investor[_user].deposites[i].isToken){
                amount[i]=investor[_user].deposites[i].amount;
                time[i]=investor[_user].deposites[i].depositeTime;
            }
        }
        return(amount,time);
    }
    receive() external payable {
      
    }
     
}