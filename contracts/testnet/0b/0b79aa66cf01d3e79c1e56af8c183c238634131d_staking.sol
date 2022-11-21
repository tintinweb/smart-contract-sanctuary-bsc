/**
 *Submitted for verification at BscScan.com on 2022-11-21
*/

/**
 *Submitted for verification at BscScan.com on 2022-11-19
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;
interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount)external returns (bool);
    function allowance(address owner, address spender) external
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

    address public devWallet; // developer wallet address

    address public treasury; // treasury wallet address 

    uint256 private divider=10000; 

    uint256 public depoiteTax=1000; // Deposit tax  

    uint256 public withdrawTax=800; // Withdraw tax  

    uint256 public withdrawRTax=500; // developer Tax  

    uint256 public rewardTax=750; //  reward withdraw tax  

    uint256 public refferalTax=300; //  refferal  tax  
    
    uint256 public reStakeTax=0; //  Restake rewards  tax  
    
    uint256 public totalInvestedWBNB; // Total Invested WBNB to contract

    uint256 public totalInvestedBUSD; // Total Invested BUSD to contract

    uint256 public totalWithdrawBUSD; // Total Withdraw BUSD from contract

    uint256 public totalWithdrawWBNB; // Total Withdraw WBNB  from contract

    uint256 public totalDevRewardsBUSD; // Total Developer rewads in BUSD

    uint256 public totalDevRewardsWBNB; // Total Developer rewads in WBNB

    uint256 [] public percentage=[110,330,550]; // reward percentage according to days (1.1,3.3,5.5)

    address  [] public  tokens=[0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56,0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c]; // investmnet tokens

    struct depoite{ // user deposite structure 
        uint256 amount;
        uint256 depositeTime;
        bool isToken;
        uint256 checkPointWBNB;
        uint256 checkPointBUSD;
    }

    struct user { // user information  structure 
        depoite[] deposites;
        address refferAddress;
        uint256 refferalRewardsWBNB;
        uint256 refferalRewardsBUSD;
        uint256 totalRewardWithdrawBUSD;
        uint256 totalRewardWithdrawWBNB;
        uint256 checkWBNB;
        uint256 checkBusd;
        uint256 withdrawCheckWBNB;
        uint256 withdrawCheckBUSD;
    }

    mapping (address=>user) public investor;

	event NewDeposit(address indexed user, uint256 amount); // Event For new deposit
    event Compund(address indexed user, uint256 amount); // Event For new Compund
    event Restake(address indexed user, uint256 amount); // Event For new Restake
	event Withdrawn(address indexed user, uint256 amount); // Event For  Withdrawn deposit amount
	event RewardWithdraw(address indexed user,uint256 amount); // Event For  Reward Withdraw  
    event WithdrawnRefferalReward(address indexed user, uint256 amount); // Event For  Reward Withdraw  
    constructor() Ownable(msg.sender){
        devWallet=0xe5ce24b30Ca442330C9dcd5a63d8D838A9a3bB62;
        treasury=0xb1aDB5F0A54098FBA21F33804a4B58632119Eccc;
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
        require(token==tokens[0] || token==tokens[1],"Invalid Token"); // check is token valid or not
        
        require(amount<=IERC20(token).allowance(msg.sender, address(this)),"Insufficient Allowence to the contract"); // check that contract have sufficient Allowence 
        uint256 tax=amount.mul(depoiteTax).div(divider); // calcluate deposit tax amount
        uint256 refferalFee=amount.mul(refferalTax).div(divider); // calcluate deposit tax amount
        IERC20(token).transferFrom(msg.sender, treasury, tax); // transfer deposite tax amount to the treasury
        IERC20(token).transferFrom(msg.sender, address(this), amount.sub(tax)); // transfer Reamining amount to the treasury
        
        if(token==tokens[0]){ // check if the token is BUSD 
            totalInvestedBUSD=totalInvestedBUSD.add(amount.sub(tax)); // add amount to total invested busd
            if(reffer==address(0) || reffer==msg.sender||reffer==address(this)){ // check the refferal address 
            investor[msg.sender].deposites.push(depoite(amount.sub(tax), block.timestamp,true,0,block.timestamp)); // push the data into users structure
            }else{ // push the data into users structure
                investor[msg.sender].refferAddress=reffer;
                investor[msg.sender].refferalRewardsBUSD+=refferalFee;
                investor[msg.sender].deposites.push(depoite(amount.sub(tax), block.timestamp,true,0,block.timestamp));
            }
            
            investor[msg.sender].checkBusd=block.timestamp; // update users invest check point 
            if(msg.sender==devWallet) totalDevRewardsBUSD=0; // Add developer rewards in wbusd
        }else{
            totalInvestedWBNB=totalInvestedWBNB.add(amount.sub(tax)); // add amount to total invested WBNB
            if(reffer==address(0) || reffer==msg.sender||reffer==address(this)){ // check the refferal address 
            investor[msg.sender].deposites.push(depoite(amount.sub(tax), block.timestamp,false,block.timestamp,0)); // push the data into users structure
            }else{ // push the data into users structure
                investor[msg.sender].refferAddress=reffer;
                investor[msg.sender].refferalRewardsWBNB+=refferalFee;
                investor[msg.sender].deposites.push(depoite(amount.sub(tax), block.timestamp,false,block.timestamp,0));
            }
            investor[msg.sender].checkWBNB=block.timestamp; // update users invest check point 
            if(msg.sender==devWallet) totalDevRewardsWBNB=0; // Add developer rewards in wbnb
        }
        
        emit NewDeposit(msg.sender, amount);
    }
    
    function compund(bool isToken) public  {
        if(isToken){ // check the token BUSD or WBNB
            (uint256 amount,)=calclulateReward(msg.sender);  // calclulate BUSD Reward for compound 
            if(msg.sender==devWallet) { // check if the caller is developer wallet 
                amount+=totalDevRewardsBUSD; // add the developer rewards in total amount
                totalDevRewardsBUSD=0; // null the total developer rewards 
            }
            totalInvestedBUSD=totalInvestedBUSD.add(amount);  // add amount to total invested BUSD 
            require(amount>0,"Compund Amount very low"); // check if the amount is greater than zero 
             uint256 tax=amount.mul(rewardTax).div(divider); // calcluate reward tax amount  
             totalDevRewardsBUSD+=tax;  // add to the developer wallet 
            investor[msg.sender].deposites.push(depoite(amount, block.timestamp,true,0,block.timestamp)); // add info to users investment array
            emit Compund(msg.sender, amount);
            for(uint256 i=0;i<investor[msg.sender].deposites.length;i++){ // update check BUSD point of the user 
                if(investor[msg.sender].deposites[i].isToken){
                    investor[msg.sender].deposites[i].checkPointBUSD=block.timestamp;
                }
            }
            investor[msg.sender].withdrawCheckBUSD=block.timestamp;
            investor[msg.sender].checkBusd=block.timestamp;
        }else{
            (,uint256 amount)=calclulateReward(msg.sender); // calclulate WBNB Reward for compound 
            if(msg.sender==devWallet) { // check if the caller is developer wallet 
                amount+=totalDevRewardsWBNB; // add the developer rewards in total amount
                totalDevRewardsWBNB=0;// null the total developer rewards 
            }
            require(amount>0,"Compund Amount very low"); // check if the amount is greater than zero 
            totalInvestedWBNB=totalInvestedWBNB.add(amount);  // add amount to total invested WBNB 
            uint256 tax=amount.mul(rewardTax).div(divider); // calcluate reward tax amount  
            totalDevRewardsWBNB+=tax; // add to the developer wallet 
            investor[msg.sender].deposites.push(depoite(amount, block.timestamp,false,block.timestamp,0)); // add info to users investment array
            emit Compund(msg.sender, amount);
            for(uint256 i=0;i<investor[msg.sender].deposites.length;i++){ // update check BUSD point of the user 
                if(!investor[msg.sender].deposites[i].isToken){
                    investor[msg.sender].deposites[i].checkPointWBNB=block.timestamp;
                }
            }
            investor[msg.sender].withdrawCheckWBNB=block.timestamp; // update withdraw checkpoint 
            investor[msg.sender].checkWBNB=block.timestamp; // update WBNB activity point  
        }
        
    }
    function reStake(address token) public payable {
        require(token==tokens[0] || token==tokens[1],"Invalid Token"); // check that token is valid or not 
        uint256 amount;
        if(token==tokens[0]){ // if the token is BUSD 
            amount=getUserTotalRefferalRewardsBUSD(msg.sender); // get the user total refferal rewards
            totalInvestedBUSD=totalInvestedBUSD.add(amount); // add to total investment of busd 
            investor[msg.sender].deposites.push(depoite(amount, block.timestamp,true,0,block.timestamp)); // add info to users investment array
            investor[msg.sender].refferalRewardsBUSD=0; // refferal rewards set to zero 
            investor[msg.sender].checkBusd=block.timestamp;  // update BUSD activity point
        }else{
            amount=getUserTotalRefferalRewardsWBNB(msg.sender);// get the user total refferal rewards
            totalInvestedWBNB=totalInvestedWBNB.add(amount); // add to total investment of WBNB 
            investor[msg.sender].deposites.push(depoite(amount, block.timestamp,false,block.timestamp,0)); // add info to users investment array
           investor[msg.sender].refferalRewardsWBNB=0;// refferal rewards set to zero 
            investor[msg.sender].checkWBNB=block.timestamp; // update WBNB activity point
        }
        uint256 tax=amount.mul(reStakeTax).div(divider); // calclulate restake amount tax
            IERC20(token).transfer(treasury, tax); // transfer tax to treasury
            emit Restake(msg.sender, amount);
        
    }
    function withdrawRefferalReward(address token)public {
         require(token==tokens[0] || token==tokens[1],"Invalid Token"); // check that token is valid or not 
        uint256 totalDeposite;
        if(token==tokens[0]){ // if token is busd
             
            totalDeposite=getUserTotalRefferalRewardsBUSD(msg.sender); // get user refferal rewards in busd
            require(totalDeposite>0,"No Deposite Found"); //check if there is any rewards 
            require(totalDeposite<=getContractBUSDBalacne(),"Not Enough Token for withdrwal from contract please try after some time");// check contract have enough tokens to transfer
            totalWithdrawBUSD+=totalDeposite; // Add to total withdraw BUSD from contract 
            investor[msg.sender].refferalRewardsBUSD=0; // set refferal withdraw rewards to zero 
        }else{
            totalDeposite=getUserTotalRefferalRewardsWBNB(msg.sender); // get user refferal rewards in BNB
            require(totalDeposite>0,"No WBNB Deposite Found"); //check if there is any rewards 
            require(totalDeposite<=getContractWBNBBalacne(),"Not Enough WBNB for withdrwal from contract please try after some time"); // check contract have enough tokens to transfer
            totalWithdrawWBNB+=totalDeposite;// Add to total withdraw BNB from contract 
            investor[msg.sender].refferalRewardsWBNB=0; // set refferal withdraw rewards to zero 
        }
        IERC20(token).transfer(msg.sender, totalDeposite); // Transer tokens to the caller.
        emit WithdrawnRefferalReward(msg.sender, totalDeposite);

    }
    function withdrawDevReward(address token)public onlyDev{
        require(token==tokens[0] || token==tokens[1],"Invalid Token"); // check that token is valid or not 
        uint256 totalDeposite;
        if(token==tokens[0]){
            (uint256 amount,)=calclulateReward(msg.sender); // get Developer rewards in busd
            totalDeposite=totalDevRewardsBUSD+amount;  // Calcluate developer total rewards 
            require(totalDeposite>0,"Fund is very low");//check if there is any rewards 
            require(totalDeposite<=getContractBUSDBalacne(),"Not Enough Token for withdrwal from contract please try after some time"); // check contract have enough tokens to transfer
            totalWithdrawBUSD+=totalDeposite; // Add to total withdraw BUSD from contract 
            totalDevRewardsBUSD=0; // set dev  rewards to zero 
        }else{
            (,uint256 amount)=calclulateReward(msg.sender); // get Developer rewards in WBNB
            totalDeposite=totalDevRewardsWBNB+amount; // Calcluate developer total rewards 
            require(totalDeposite>0,"Fund is very low");//check if there is any rewards 
            require(totalDeposite<=getContractWBNBBalacne(),"Not Enough WBNB for withdrwal from contract please try after some time"); // check contract have enough tokens to transfer
            totalWithdrawWBNB+=totalDeposite; // Add to total withdraw WBNB from contract 
            totalDevRewardsWBNB=0; // set dev  rewards to zero 
        }
        IERC20(token).transfer(msg.sender, totalDeposite);  // Transer tokens to the developer.

    }
    function withdrawTokensBUSD(uint256 id)public {
        require (id <= investor[msg.sender].deposites.length,"Invalid Id"); // Check that id is valid or not for that user 
        require (investor[msg.sender].deposites[id].isToken,"Not A BUSD Deposite"); // Check  if the id is a busd investment or not
        uint256 totalDeposite=investor[msg.sender].deposites[id].amount; // calcluate total amount 
        require(totalDeposite>0,"No Deposite Found"); //check if there is any rewards 
        require(totalDeposite<=getContractBUSDBalacne(),"Not Enough Token for withdrwal from contract please try after some time"); // check contract have enough tokens to transfer
        uint256 tax=totalDeposite.mul(withdrawTax).div(divider); // calcluate withdraw  tax amount  
        IERC20(tokens[0]).transfer(msg.sender, totalDeposite.sub(tax)); // transfer tax amount to the caller
        IERC20(tokens[0]).transfer(msg.sender, tax);
        remove(id); // remove that investment 
        totalWithdrawBUSD+=totalDeposite; // add to total BUSD withdraw from contract 
        investor[msg.sender].checkBusd=block.timestamp; // update check point 
        investor[msg.sender].withdrawCheckBUSD=block.timestamp;  // update BUSD check point 
        
        emit Withdrawn(msg.sender, totalDeposite);
    }
    
    function withdrawTokensWBNB(uint256 id)public {
        require (id <= investor[msg.sender].deposites.length,"Invalid Id"); // Check that id is valid or not for that user 
        require (!investor[msg.sender].deposites[id].isToken,"Not A WBNB Deposite"); // Check  if the id is a WBNB investment or not
        uint256 totalDeposite=investor[msg.sender].deposites[id].amount;// calcluate total amount 
        require(totalDeposite>0,"No Deposite Found"); //check if there is any rewards 
        require(totalDeposite<=getContractWBNBBalacne(),"Not Enough Token for withdrwal from contract please try after some time"); // check contract have enough tokens to transfer
        uint256 tax=totalDeposite.mul(withdrawTax).div(divider); // calcluate withdraw  tax amount  
        IERC20(tokens[1]).transfer(msg.sender, totalDeposite.sub(tax)); // transfer tax amount to the caller
        IERC20(tokens[1]).transfer(msg.sender, tax);
        remove(id); // remove that investment 
         investor[msg.sender].checkWBNB=block.timestamp; // update check point 
          investor[msg.sender].withdrawCheckWBNB=block.timestamp; // update BUSD check point 
          totalWithdrawWBNB+=totalDeposite; // add to total WBNB withdraw from contract
        emit Withdrawn(msg.sender, totalDeposite);
    }

    function withdrawRewardBUSD()public {
        (uint256 totalRewards,)=calclulateReward(msg.sender); // get user total rewards
        require(totalRewards>0,"No Rewards Found"); //check if there is any rewards 
        require(totalRewards<=getContractBUSDBalacne(),"Not Enough Token for withdrwal from contract please try after some time"); // check contract have enough tokens to transfer
        uint256 tax=totalRewards.mul(rewardTax).div(divider); // calcluate withdraw reward tax amount  
        uint256 taxR=totalRewards.mul(withdrawRTax).div(divider); // calcluate developer  reward  amount  
        totalDevRewardsBUSD+=tax; //  add tax to developer wallet 
        totalWithdrawBUSD+=totalRewards; // added to total busd withdraw
        IERC20(tokens[0]).transfer(msg.sender, totalRewards.sub(taxR)); // transfer remaining amount to user
        if(investor[msg.sender].refferAddress!=address(0)) investor[investor[msg.sender].refferAddress].refferalRewardsBUSD+=taxR; // added to user's refferal rewards 
        for(uint256 i=0;i<investor[msg.sender].deposites.length;i++){ // update users check point 
            if(investor[msg.sender].deposites[i].isToken) investor[msg.sender].deposites[i].checkPointBUSD=block.timestamp; 
        }
        investor[msg.sender].totalRewardWithdrawBUSD+=totalRewards; // update users total withdraw amount 
        investor[msg.sender].checkBusd=block.timestamp; // update check point 
        
        emit RewardWithdraw(msg.sender, totalRewards);
    }
    
    function withdrawRewardWBNB()public {
        (,uint256 totalRewards)=calclulateReward(msg.sender); // get user total rewards
        require(totalRewards>0,"No Rewards Found");//check if there is any rewards 
        require(totalRewards<=getContractWBNBBalacne(),"Not Enough Token for withdrwal from contract please try after some time");// check contract have enough tokens to transfer
        uint256 tax=totalRewards.mul(rewardTax).div(divider); // calcluate withdraw reward tax amount  
        uint256 taxR=totalRewards.mul(withdrawRTax).div(divider); // calcluate developer  reward  amount  
        totalDevRewardsWBNB+=tax; //  add tax to developer wallet 
         totalWithdrawWBNB+=totalRewards; // added to total busd withdraw
        IERC20(tokens[1]).transfer(msg.sender, totalRewards.sub(taxR)); // transfer remaining amount to user
        if(investor[msg.sender].refferAddress!=address(0)) investor[investor[msg.sender].refferAddress].refferalRewardsWBNB+=taxR;  // added to user's refferalrewards 
        investor[msg.sender].totalRewardWithdrawWBNB=(investor[msg.sender].totalRewardWithdrawWBNB).add(totalRewards); // update users total withdraw amount 
        for(uint256 i=0;i<investor[msg.sender].deposites.length;i++){ // update users check point 
            if(!investor[msg.sender].deposites[i].isToken){
                investor[msg.sender].deposites[i].checkPointWBNB=block.timestamp;
            }
        }
       
        investor[msg.sender].checkWBNB=block.timestamp; // update check point 
        emit RewardWithdraw(msg.sender, totalRewards);
    }
    function remove(uint256 index) internal {
        
        investor[msg.sender].deposites[index].amount =0;
        investor[msg.sender].deposites[index].depositeTime =0;
        investor[msg.sender].deposites[index].checkPointWBNB =0;
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
        uint256 totalRewardWBNB;
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
                uint256 time=block.timestamp.sub(users.deposites[i].checkPointWBNB);
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
                totalRewardWBNB=reward4.add(reward5).add(reward6);
            }
        }
        return(totalRewardBUSD,totalRewardWBNB);
    }

    function getUserTotalDepositeWBNB(address _user) public view returns(uint256 _totalInvestment){
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
    function getUserTotalRewardWithdrawWBNB(address _user) public view returns(uint256 _totalWithdraw){
        _totalWithdraw=investor[_user].totalRewardWithdrawWBNB;
    }
    function getUserTotalRewardWithdrawBUSD(address _user) public view returns(uint256 _totalWithdraw){
        _totalWithdraw=investor[_user].totalRewardWithdrawBUSD;
    }
    function getUserTotalRefferalRewardsWBNB(address _user) public view returns(uint256 _totalRefferalRewards){
        _totalRefferalRewards=investor[_user].refferalRewardsWBNB;
    }
    function getUserTotalRefferalRewardsBUSD(address _user) public view returns(uint256 _totalRefferalRewards){
        _totalRefferalRewards=investor[_user].refferalRewardsBUSD;
    }

    function getContractBUSDBalacne() public view returns(uint256 totalBUSD){
        totalBUSD=IERC20(tokens[0]).balanceOf(address(this));
    }

    function getContractWBNBBalacne() public view returns(uint256 totalWBNB){
        totalWBNB=IERC20(tokens[1]).balanceOf(address(this));
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
    function getUserDepositeHistoryWBNB( address _user) public view returns(uint256[] memory,uint256[] memory){
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