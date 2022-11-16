/**
 *Submitted for verification at BscScan.com on 2022-11-16
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

    uint256 public depoiteTax=1000;

    uint256 public withdrawTax=800;

    uint256 public withdrawRTax=500;

    uint256 public rewardTax=750;

    uint256 public refferalTax=300;
    
    uint256 public reStakeTax=0;
    
    uint256 public totalInvestedBTC;

    uint256 public totalInvestedETH;

    uint256 public totalWithdrawETH;

    uint256 public totalWithdrawBTC;

    uint256 public totalDevRewardsETH;

    uint256 public totalDevRewardsBTC;

    uint256 [] public percentage=[110,330,550];

    address  [] public  tokens=[0xd66c6B4F0be8CE5b39D52E0Fd1344c389929B378,0x6ce8dA28E2f864420840cF74474eFf5fD80E65B8];

    struct depoite{
        uint256 amount;
        uint256 depositeTime;
        bool isToken;
        uint256 checkPointBTC;
        uint256 checkPointETH;
    }

    struct user {
        depoite[] deposites;
        address refferAddress;
        uint256 refferalRewardsBTC;
        uint256 refferalRewardsETH;
        uint256 totalRewardWithdrawETH;
        uint256 totalRewardWithdrawBTC;
        uint256 checkBTC;
        uint256 checkETH;
        uint256 withdrawCheckBTC;
        uint256 withdrawCheckETH;
    }

    mapping (address=>user) public investor;

	event NewDeposit(address indexed user, uint256 amount);
    event Compund(address indexed user, uint256 amount);
    event Restake(address indexed user, uint256 amount);
	event Withdrawn(address indexed user, uint256 amount);
	event RewardWithdraw(address indexed user,uint256 amount);
    event WithdrawnRefferalReward(address indexed user, uint256 amount);
    constructor() Ownable(0xe5ce24b30Ca442330C9dcd5a63d8D838A9a3bB62){
        devWallet=0xe5ce24b30Ca442330C9dcd5a63d8D838A9a3bB62;
        treasury=0x6876d459b0a71632130ffbcc491704E118377438;
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

    function invest(uint256 amount,address reffer,address token) public  {
        require(token==tokens[0] || token==tokens[1],"Invalid Token");
        
        require(amount<=IERC20(token).allowance(msg.sender, address(this)),"Insufficient Allowance to the contract");
        uint256 tax=amount.mul(depoiteTax).div(divider);
        uint256 refferalFee=amount.mul(refferalTax).div(divider);
        IERC20(token).transferFrom(msg.sender, treasury, tax);
        IERC20(token).transferFrom(msg.sender, address(this), amount.sub(tax));
        
        if(token==tokens[0]){
            totalInvestedETH=totalInvestedETH.add(amount.sub(tax));
            if(reffer==address(0) || reffer==msg.sender||reffer==address(this)){
            investor[msg.sender].deposites.push(depoite(amount.sub(tax), block.timestamp,true,0,block.timestamp));
            }else{
                investor[msg.sender].refferAddress=reffer;
                investor[msg.sender].refferalRewardsETH+=refferalFee;
                investor[msg.sender].deposites.push(depoite(amount.sub(tax), block.timestamp,true,0,block.timestamp));
            }
            
            investor[msg.sender].checkETH=block.timestamp;
            if(msg.sender==devWallet) totalDevRewardsETH=0;
        }else{
            totalInvestedBTC=totalInvestedBTC.add(amount.sub(tax));
            if(reffer==address(0) || reffer==msg.sender||reffer==address(this)){
            investor[msg.sender].deposites.push(depoite(amount.sub(tax), block.timestamp,false,block.timestamp,0));
            }else{
                investor[msg.sender].refferAddress=reffer;
                investor[msg.sender].refferalRewardsBTC+=refferalFee;
                investor[msg.sender].deposites.push(depoite(amount.sub(tax), block.timestamp,false,block.timestamp,0));
            }
            investor[msg.sender].checkBTC=block.timestamp;
            if(msg.sender==devWallet) totalDevRewardsBTC=0;
        }
        
        emit NewDeposit(msg.sender, amount);
    }
    
    function compund(address token) public  {
        require(token==tokens[0] || token==tokens[1],"Invalid Token");
        if(token==tokens[0]){
            (uint256 amount,)=calclulateReward(msg.sender);
            if(msg.sender==devWallet) {
                amount+=totalDevRewardsETH;
                totalDevRewardsETH=0;
            }
            totalInvestedETH=totalInvestedETH.add(amount);
            require(amount>0,"Compound Amount very low");
             uint256 tax=amount.mul(rewardTax).div(divider);
             totalDevRewardsETH+=tax;
            investor[msg.sender].deposites.push(depoite(amount, block.timestamp,true,0,block.timestamp));
            emit Compund(msg.sender, amount);
            for(uint256 i=0;i<investor[msg.sender].deposites.length;i++){
                if(investor[msg.sender].deposites[i].isToken){
                    investor[msg.sender].deposites[i].checkPointETH=block.timestamp;
                }
            }
            investor[msg.sender].withdrawCheckETH=block.timestamp;
            investor[msg.sender].checkETH=block.timestamp;
        }else{
            (,uint256 amount)=calclulateReward(msg.sender);
            if(msg.sender==devWallet) {
                amount+=totalDevRewardsBTC;
                totalDevRewardsBTC=0;
            }
            require(amount>0,"Compound Amount very low");
            totalInvestedBTC=totalInvestedBTC.add(amount);
            uint256 tax=amount.mul(rewardTax).div(divider);
            totalDevRewardsBTC+=tax;
            investor[msg.sender].deposites.push(depoite(amount, block.timestamp,false,block.timestamp,0));
            emit Compund(msg.sender, amount);
            for(uint256 i=0;i<investor[msg.sender].deposites.length;i++){
                if(!investor[msg.sender].deposites[i].isToken){
                    investor[msg.sender].deposites[i].checkPointBTC=block.timestamp;
                }
            }
            investor[msg.sender].withdrawCheckBTC=block.timestamp;
            investor[msg.sender].checkBTC=block.timestamp;
        }
        
    }
    function reStake(address token) public payable {
        require(token==tokens[0] || token==tokens[1],"Invalid Token");
        uint256 amount;
        if(token==tokens[0]){
            amount=getUserTotalRefferalRewardsETH(msg.sender);
            totalInvestedETH=totalInvestedETH.add(amount);
            investor[msg.sender].deposites.push(depoite(amount, block.timestamp,true,0,block.timestamp));
            investor[msg.sender].refferalRewardsETH=0;
            investor[msg.sender].checkETH=block.timestamp;
        }else{
            amount=getUserTotalRefferalRewardsBTC(msg.sender);
            totalInvestedBTC=totalInvestedBTC.add(amount);
            investor[msg.sender].deposites.push(depoite(amount, block.timestamp,false,block.timestamp,0));
           investor[msg.sender].refferalRewardsBTC=0;
            investor[msg.sender].checkBTC=block.timestamp;
        }
        uint256 tax=amount.mul(reStakeTax).div(divider);
            IERC20(token).transfer(treasury, tax);
            emit Restake(msg.sender, amount);
        
    }
    function withdrawRefferalReward(address token)public {
         require(token==tokens[0] || token==tokens[1],"Invalid Token");
        uint256 totalDeposite;
        if(token==tokens[0]){
            
            totalDeposite=getUserTotalRefferalRewardsETH(msg.sender);
            require(totalDeposite>0,"No Deposit Found");
            require(totalDeposite<=getContractETHBalacne(),"Not Enough Token for withdrawal from contract please try after some time");
            totalWithdrawETH+=totalDeposite;
            investor[msg.sender].refferalRewardsETH=0;
        }else{
            totalDeposite=getUserTotalRefferalRewardsBTC(msg.sender);
            require(totalDeposite>0,"No BTC Deposit Found");
            require(totalDeposite<=getContractBTCBalacne(),"Not Enough BTC for withdrawal from contract please try after some time");
            totalWithdrawBTC+=totalDeposite;
            investor[msg.sender].refferalRewardsBTC=0;
        }
        IERC20(token).transfer(msg.sender, totalDeposite);
        emit WithdrawnRefferalReward(msg.sender, totalDeposite);

    }
    function withdrawDevReward(address token)public onlyDev{
        require(token==tokens[0] || token==tokens[1],"Invalid Token");
        uint256 totalDeposite;
        if(token==tokens[0]){
            (uint256 amount,)=calclulateReward(msg.sender);
            totalDeposite=totalDevRewardsETH+amount;
            require(totalDeposite>0,"Fund is very low");
            require(totalDeposite<=getContractETHBalacne(),"Not Enough Token for withdrawal from contract please try after some time");
            totalWithdrawETH+=totalDeposite;
            totalDevRewardsETH=0;
        }else{
            (,uint256 amount)=calclulateReward(msg.sender);
            totalDeposite=totalDevRewardsBTC+amount;
            require(totalDeposite>0,"Fund is very low");
            require(totalDeposite<=getContractBTCBalacne(),"Not Enough BTC for withdrawal from contract please try after some time");
            totalWithdrawBTC+=totalDeposite;
            totalDevRewardsBTC=0;
        }
        IERC20(token).transfer(msg.sender, totalDeposite);

    }
    function withdrawTokensETH(uint256 id)public {
        require (id <= investor[msg.sender].deposites.length,"Invalid Id");
        require (investor[msg.sender].deposites[id].isToken,"Not A ETH Deposit");
        uint256 totalDeposite=investor[msg.sender].deposites[id].amount;
        require(totalDeposite>0,"No Deposit Found");
        require(totalDeposite<=getContractETHBalacne(),"Not Enough Token for withdrawal from contract please try after some time");
        uint256 tax=totalDeposite.mul(withdrawTax).div(divider);
        IERC20(tokens[0]).transfer(msg.sender, totalDeposite.sub(tax));
        IERC20(tokens[0]).transfer(msg.sender, tax);
        remove(id);
        totalWithdrawETH+=totalDeposite;
        investor[msg.sender].checkETH=block.timestamp;
        investor[msg.sender].withdrawCheckETH=block.timestamp;
        
        emit Withdrawn(msg.sender, totalDeposite);
    }
    
    function withdrawTokensBTC(uint256 id)public {
        require (id <= investor[msg.sender].deposites.length,"Invalid Id");
        require (!investor[msg.sender].deposites[id].isToken,"Not A BTC Deposit");
        uint256 totalDeposite=investor[msg.sender].deposites[id].amount;
        require(totalDeposite>0,"No Deposit Found");
        require(totalDeposite<=getContractBTCBalacne(),"Not Enough Token for withdrawal from contract please try after some time");
        uint256 tax=totalDeposite.mul(withdrawTax).div(divider);
        IERC20(tokens[1]).transfer(msg.sender, totalDeposite.sub(tax));
        IERC20(tokens[1]).transfer(msg.sender, tax);
        remove(id);
         investor[msg.sender].checkBTC=block.timestamp;
          investor[msg.sender].withdrawCheckBTC=block.timestamp;
          totalWithdrawBTC+=totalDeposite;
        emit Withdrawn(msg.sender, totalDeposite);
    }

    function withdrawRewardETH()public {
        (uint256 totalRewards,)=calclulateReward(msg.sender);
        require(totalRewards>0,"No Rewards Found");
        require(totalRewards<=getContractETHBalacne(),"Not Enough Token for withdrawal from contract please try after some time");
        uint256 tax=totalRewards.mul(rewardTax).div(divider);
        uint256 taxR=totalRewards.mul(withdrawRTax).div(divider);
        totalDevRewardsETH+=tax;
        totalWithdrawETH+=totalRewards;
        IERC20(tokens[0]).transfer(msg.sender, totalRewards.sub(taxR));
        if(investor[msg.sender].refferAddress!=address(0)) investor[investor[msg.sender].refferAddress].refferalRewardsETH+=taxR;
        for(uint256 i=0;i<investor[msg.sender].deposites.length;i++){
            if(investor[msg.sender].deposites[i].isToken) investor[msg.sender].deposites[i].checkPointETH=block.timestamp; 
        }
        investor[msg.sender].totalRewardWithdrawETH+=totalRewards;
        investor[msg.sender].checkETH=block.timestamp;
        
        emit RewardWithdraw(msg.sender, totalRewards);
    }
    
    function withdrawRewardBTC()public {
        (,uint256 totalRewards)=calclulateReward(msg.sender);
        require(totalRewards>0,"No Rewards Found");
        require(totalRewards<=getContractBTCBalacne(),"Not Enough Token for withdrawal from contract please try after some time");
        uint256 tax=totalRewards.mul(rewardTax).div(divider);
        uint256 taxR=totalRewards.mul(withdrawRTax).div(divider);
        totalDevRewardsBTC+=tax;
         totalWithdrawBTC+=totalRewards;
        IERC20(tokens[1]).transfer(msg.sender, totalRewards.sub(taxR));
        if(investor[msg.sender].refferAddress!=address(0)) investor[investor[msg.sender].refferAddress].refferalRewardsBTC+=taxR;
        investor[msg.sender].totalRewardWithdrawBTC=(investor[msg.sender].totalRewardWithdrawBTC).add(totalRewards);
        for(uint256 i=0;i<investor[msg.sender].deposites.length;i++){
            if(!investor[msg.sender].deposites[i].isToken){
                investor[msg.sender].deposites[i].checkPointBTC=block.timestamp;
            }
        }
       
        investor[msg.sender].checkBTC=block.timestamp;
        emit RewardWithdraw(msg.sender, totalRewards);
    }
    function remove(uint256 index) internal {
        
        investor[msg.sender].deposites[index].amount =0;
        investor[msg.sender].deposites[index].depositeTime =0;
        investor[msg.sender].deposites[index].checkPointBTC =0;
        investor[msg.sender].deposites[index].checkPointETH =0;
    }
    function calclulateReward(address _user) public view returns(uint256 ,uint256){
        uint256 totalRewardETH;
        uint256 reward1;
        uint256 reward2;
        uint256 reward3;
        uint256 reward4;
        uint256 reward5;
        uint256 reward6;
        uint256 totalRewardBTC;
        user storage users=investor[_user];
        for(uint256 i=0;i<users.deposites.length;i++){
            if(users.deposites[i].isToken){
            uint256 time=block.timestamp.sub(users.deposites[i].checkPointETH);
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
                totalRewardETH=reward1.add(reward2).add(reward3);
            }else{
                uint256 time=block.timestamp.sub(users.deposites[i].checkPointBTC);
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
                totalRewardBTC=reward4.add(reward5).add(reward6);
            }
        }
        return(totalRewardETH,totalRewardBTC);
    }

    function getUserTotalDepositeBTC(address _user) public view returns(uint256 _totalInvestment){
        for(uint256 i=0;i<investor[_user].deposites.length;i++){
            if(!investor[_user].deposites[i].isToken){
                _totalInvestment=_totalInvestment.add(investor[_user].deposites[i].amount);
            }
        }
    }
    function getUserTotalDepositeETH(address _user) public view returns(uint256 _totalInvestment){
        for(uint256 i=0;i<investor[_user].deposites.length;i++){
            if(investor[_user].deposites[i].isToken){
                _totalInvestment=_totalInvestment.add(investor[_user].deposites[i].amount);
            }
        }
    }
    function getUserTotalRewardWithdrawBTC(address _user) public view returns(uint256 _totalWithdraw){
        _totalWithdraw=investor[_user].totalRewardWithdrawBTC;
    }
    function getUserTotalRewardWithdrawETH(address _user) public view returns(uint256 _totalWithdraw){
        _totalWithdraw=investor[_user].totalRewardWithdrawETH;
    }
    function getUserTotalRefferalRewardsBTC(address _user) public view returns(uint256 _totalRefferalRewards){
        _totalRefferalRewards=investor[_user].refferalRewardsBTC;
    }
    function getUserTotalRefferalRewardsETH(address _user) public view returns(uint256 _totalRefferalRewards){
        _totalRefferalRewards=investor[_user].refferalRewardsETH;
    }

    function getContractETHBalacne() public view returns(uint256 totalETH){
        totalETH=IERC20(tokens[0]).balanceOf(address(this));
    }

    function getContractBTCBalacne() public view returns(uint256 totalBTC){
        totalBTC=IERC20(tokens[1]).balanceOf(address(this));
    }
    function getUserDepositeHistoryETH( address _user) public view  returns(uint256[] memory,uint256[] memory){
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
    function getUserDepositeHistoryBTC( address _user) public view returns(uint256[] memory,uint256[] memory){
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