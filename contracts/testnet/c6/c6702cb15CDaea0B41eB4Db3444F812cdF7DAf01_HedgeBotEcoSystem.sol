// SPDX-License-Identifier: MIT License
pragma solidity 0.8.19;

import "./SafeERC20.sol";

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
    * @dev Initializes the contract setting the deployer as the initial owner.
    */
    constructor () {
      address msgSender = _msgSender();
      _owner = msgSender;
      emit OwnershipTransferred(address(0), msgSender);
    }

    /**
    * @dev Returns the address of the current owner.
    */
    function owner() public view returns (address) {
      return _owner;
    }
    
    modifier onlyOwner() {
      require(_owner == _msgSender(), "Ownable: caller is not the owner");
      _;
    }
    
    function transferOwnership(address newOwner) public onlyOwner {
      _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {
      require(newOwner != address(0), "Ownable: new owner is the zero address");
      emit OwnershipTransferred(_owner, newOwner);
      _owner = newOwner;
    }
}


library SafeMath {
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

contract HedgeBotEcoSystem is Context, Ownable {
    using SafeMath for uint256;
	using SafeERC20 for IERC20;

    IERC20 public USD;
    IERC20 public HBT;
    address public paymentTokenAddress;
    address public HBTpaymentTokenAddress;

    event _Deposit(address indexed addr, uint256 amount, uint40 tm);
    event _StakingDeposit(address indexed addr, uint256 amount, uint16 duration,uint40 tm);
    event _Payout(address indexed addr, uint256 amount);
    event _Refund(address indexed addr, uint256 amount);
    event _StakeRefund(address indexed addr, uint256 amount);
		
    address payable public creator;
    address payable public treasury;
    address payable public botTrader;
    address payable public partnerTrader;
    address payable public dev;   
   
    uint8 public isDepoPaused = 0;
    uint8 public isStakingDepoPaused = 0;
    uint8 public isPayoutPaused = 0;
    uint256 private constant DAY = 24;
    uint256 public numDays = 7;    
    uint256 public numDays2 = 30; 
    
    uint256 public creatorFee = 10; //that's 1 percent actually    
    uint256 public botFee = 350; //that's 35 percent actually    
    uint256 public partnerFee = 350; //that's 35 percent actually    
    uint256 public treasuryFee = 50; //that's 5 percent actually    
    uint256 public devFee = 10; //that's 1 percent actually   
    uint256 public refundFee = 250; //that's 25 percent actually   
    uint16 constant FEE_DIVIDER = 1000; 
    uint16 constant PERCENT_DIVIDER = 100; 
  
    uint256 public invested;
    uint256 public contract_dividends;
    uint256 public staked;
    uint256 public withdrawn;
    uint256 public stake_withdrawn;
    uint256 public refunds;
        
    struct Tarif {
        uint256 life_days;
        uint256 percent;
    }

    struct Depo {
        uint256 tarif;
        uint256 amount;
        uint40 time;
    }

    struct StakingDepo {
        uint256 tarif;
        uint256 amount;
        uint16 duration;
        uint40 time;
    }

	struct Investor {
        address upline;
        uint256 dividends;
                
        uint256 total_invested;
        uint256 total_withdrawn;
	    uint256 total_refunded;
	    uint256 total_stake_refunded;
	    uint256 total_staked;
        
        uint40 lastWithdrawn;
        uint40 lastDeposit;
        uint40 lastStakingDeposit;
        uint40 lastStakingDuration;
        
        Depo[] deposits;
        StakingDepo[] stakingdeposits;
     }

    mapping(address => Investor) public investors;
    mapping(address => uint8) public banned;
    mapping(address => uint8) public unstaked;
    mapping(address => uint8) public pausedTrading;
    mapping(uint256 => Tarif) public tarifs;
    uint public nextMemberNo;
    uint public nextBannedWallet;
    uint public nextPausedWallet;
    constructor() {         
	    dev = payable(msg.sender);		
	    creator = payable(msg.sender);	
	    botTrader = payable(msg.sender);	/// Bot Trader
	    partnerTrader = payable(msg.sender);	// Partner Trader
	    treasury = payable(msg.sender);	// Treasury
        tarifs[0] = Tarif(7, 350);
        paymentTokenAddress = 0xF5F59E0F083d8Db04A8375eFC27Cea5ee0804972; // TEST USDC
        HBTpaymentTokenAddress = 0x875Da17F27F56D32BA37bB8A773f340F42f53aEb; // TEST HBT
		USD = IERC20(paymentTokenAddress);
		HBT = IERC20(HBTpaymentTokenAddress);
    }   
    function tradeDeposit(uint256 amount) external {
        
        Investor storage investor = investors[msg.sender];    
		uint256 balance = investor.total_staked;
        require(balance >= 10 ether, "Please Stake Minimum 10 HBT first to start trading!");

        require(isDepoPaused <= 0, "Deposit Transaction is Paused!");
		require(pausedTrading[msg.sender] == 0, "Wallet is paused for trading!");
        require(amount >= 1 ether, "Minimum Deposit is 1 USDC!");
        USD.safeTransferFrom(msg.sender,address(this), amount);
        investor.deposits.push(Depo({
            tarif: 0,
            amount: amount,
            time: uint40(block.timestamp)
        }));  
        
        investor.lastDeposit = uint40(block.timestamp);

        emit _Deposit(msg.sender, amount, uint40(block.timestamp));
		
		uint256 teamFee = SafeMath.div(SafeMath.mul(amount, devFee), FEE_DIVIDER);
        USD.safeTransfer(dev, teamFee);
		
        uint256 parnterTraderFee = SafeMath.div(SafeMath.mul(amount, partnerFee), FEE_DIVIDER);
        USD.safeTransfer(dev, parnterTraderFee);

        uint256 botTraderFee = SafeMath.div(SafeMath.mul(amount, botFee), FEE_DIVIDER);
        USD.safeTransfer(dev, botTraderFee);

        uint256 treasuryTotalFee = SafeMath.div(SafeMath.mul(amount, treasuryFee), FEE_DIVIDER);
        USD.safeTransfer(dev, treasuryTotalFee);

        investor.total_invested += amount;
        invested += amount;
    }
     
    function stakeDeposit(uint256 amount, uint16 duration) external {
        require(isStakingDepoPaused <= 0, "Staking is Paused!");
        require(amount >= 10 ether, "Minimum Deposit is 10 HBT!");

        Investor storage investor = investors[msg.sender];
        uint256 balance = investor.total_staked;
        balance = 1000 ether - balance;
        require(amount <= balance, "Maximum Deposit is 1000 HBT!");
        require(duration > 0 , "Duration for staking is not valid!");

        HBT.transferFrom(msg.sender,address(this), amount);

        if(investors[msg.sender].total_staked <= 0) {
            nextMemberNo++;    
        }

        investor.stakingdeposits.push(StakingDepo({
            tarif: 0,
            amount: amount,
            duration: duration,
            time: uint40(block.timestamp)
        }));  
        investor.lastStakingDeposit = uint40(block.timestamp);
        investor.lastStakingDuration = duration;
        emit _StakingDeposit(msg.sender, amount,duration, uint40(block.timestamp));
		
        investor.total_staked += amount;
        
        staked += amount;

        unstaked[msg.sender] = 0;
    }

    function rewardsWithdraw() external {     
		require(isPayoutPaused <= 0, 'Payout Transaction is Paused!');
		require(banned[msg.sender] == 0,'Banned Wallet!');
		require(unstaked[msg.sender] == 0,'Please stake HBT in order to receive rewards!');
        Investor storage investor = investors[msg.sender];

        require (block.timestamp >= (investor.lastWithdrawn + (DAY * numDays * 3600)), "Not due yet for next payout!");   

        getPayout(msg.sender);

        require(investor.dividends >= 0 ether, "Minimum payout must be greater than 0 USDC.");

        uint256 amount =  investor.dividends;
        investor.dividends = 0;
        
        investor.total_withdrawn += amount;
        
		USD.safeTransfer(msg.sender, amount);
		emit _Payout(msg.sender, amount);
		
		uint256 teamFee = SafeMath.div(SafeMath.mul(amount, creatorFee), FEE_DIVIDER);
        USD.safeTransfer(creator, teamFee);
        
		withdrawn += amount + teamFee;    
    }
	
    function withdrawStaking() external {     
	    require(unstaked[msg.sender] == 0, "Already Exited from Staking");

        Investor storage investor = investors[msg.sender];
        require (investor.lastStakingDeposit > 0, "You haven't started staking yet!");
        require (block.timestamp >= (investor.lastStakingDeposit + (investor.lastStakingDuration * 86400)), "Can not withdraw before time limit for staking!");
		uint256 refund = investor.total_staked;

        investor.total_staked -= refund;
        staked -= refund;
		investor.total_stake_refunded += refund;
		stake_withdrawn += refund;

		HBT.safeTransfer(msg.sender, refund);
		emit _StakeRefund(msg.sender, refund);

        investor.total_invested = 0;
        investor.lastDeposit = 0;
        investor.lastStakingDeposit = 0;
        delete investor.deposits;
        unstaked[msg.sender] = 1;
    }

    function exitTrading() external {     
	    require(banned[msg.sender] == 0, "Already Refunded and Wallet is Banned!");
        Investor storage investor = investors[msg.sender];    
        require (block.timestamp >= (investor.lastDeposit + (DAY * numDays2 * 3600)), "Not eligible for refund yet!");
        
		uint256 refund = investor.total_invested;
		investor.total_refunded += refund;
		refunds += refund;
	    nextBannedWallet++;
		uint256 fee = SafeMath.div(SafeMath.mul(refund, refundFee), FEE_DIVIDER);
        if(refund - fee > 0){
			refund = refund - fee;
		}
		USD.safeTransfer(msg.sender, refund);
		emit _Refund(msg.sender, refund);
		banned[msg.sender] = 1;
    }

    function computePayout(address _addr) view external returns(uint256 value) {
		if(banned[_addr] == 1){ return 0; }
        Investor storage investor = investors[_addr];

        for(uint256 i = 0; i < investor.deposits.length; i++) {
            Depo storage dep = investor.deposits[i];
            Tarif storage tarif = tarifs[dep.tarif];

            uint256 time_end = dep.time + tarif.life_days * 86400;
            uint40 from = investor.lastWithdrawn > dep.time ? investor.lastWithdrawn : dep.time;
            uint256 to = block.timestamp > time_end ? time_end : block.timestamp;

            if(from < to) {
                value += (dep.amount * (to - from) * tarif.percent) / 86400 / 100 / PERCENT_DIVIDER;
            }
        }
        return value;
    }

 
    function getPayout(address _addr) private {
        uint256 payout = this.computePayout(_addr);

        if(payout > 0) {            
            investors[_addr].lastWithdrawn = uint40(block.timestamp);
            investors[_addr].dividends += payout;
        }
    }      
    function nextWithdraw(address _addr) view external returns(uint40 next_sked) {
		if(banned[_addr] == 1) { return 0; }
        Investor storage investor = investors[_addr];
        if(investor.deposits.length > 0)
        {
          if(investor.lastWithdrawn == 0){
            return uint40(investor.lastDeposit + (DAY * numDays * 3600));
          }else{
            return uint40(investor.lastWithdrawn + (DAY * numDays * 3600));
          }
        }
        return 0;
    }
	function nextRefund(address _addr) view external returns(uint40 last_depo) {
		if(banned[_addr] == 1) { return 0; }
        Investor storage investor = investors[_addr];
        if(investor.deposits.length > 0)
        {
          return uint40(investor.lastDeposit + (DAY * numDays2 * 3600));
        }
        return 0;
    }
    function getContractBalance() public view returns (uint256) {
        return IERC20(paymentTokenAddress).balanceOf(address(this));
    }

    function pauseTrading(address wallet) public onlyOwner returns (bool success) {
        pausedTrading[wallet] = 1;
        nextPausedWallet++;
        return true;
    }
	
    

	function unpauseTrading(address wallet) public onlyOwner returns (bool success) {
        pausedTrading[wallet] = 0;
        if(nextPausedWallet > 0){ nextPausedWallet--; }
        return true;
    }	
    
    

	function setPercentage(uint256 total_perc) public onlyOwner returns (bool success) {
	    tarifs[0] = Tarif(7, total_perc);
        return true;
    }
    
    function setDevFee(uint256 newfee) public onlyOwner returns (bool success) {
	    devFee = newfee;
        return true;
    }
   
    function setCreatorFee(uint256 newfee) public onlyOwner returns (bool success) {
	    creatorFee = newfee;
        return true;
    }
	function setBotTraderFee(uint256 newfee) public onlyOwner returns (bool success) {
	    botFee = newfee;
        return true;
    }
    function setPartnerTraderFee(uint256 newfee) public onlyOwner returns (bool success) {
	    partnerFee = newfee;
        return true;
    }
    function setTreasuryFee(uint256 newfee) public onlyOwner returns (bool success) {
	    treasuryFee = newfee;
        return true;
    }
	function setRefundFee(uint256 newfee) public onlyOwner returns (bool success) {
		refundFee = newfee;
        return true;
    }
   

	function setDepoPause(uint8 newval) public onlyOwner returns (bool success) {
        isDepoPaused = newval;
        return true;
    }   
	function setStakingDepoPause(uint8 newval) public onlyOwner returns (bool success) {
        isStakingDepoPaused = newval;
        return true;
    }   

	function setPayoutPause(uint8 newval) public onlyOwner returns (bool success) {
        isPayoutPaused = newval;
        return true;
    }   
   
    function setBotTrader(address payable newval) public onlyOwner returns (bool success) {
        botTrader = newval;
        return true;
    }    
	function setPartnerTrader(address payable newval) public onlyOwner returns (bool success) {
        partnerTrader = newval;
        return true;
    }
    function setTreasury(address payable newval) public onlyOwner returns (bool success) {
        treasury = newval;
        return true;
    }
    function setcreator(address payable newval) public onlyOwner returns (bool success) {
        creator = newval;
        return true;
    }   

    function setDev(address payable newval) public onlyOwner returns (bool success) {
        dev = newval;
        return true;
    }     
   
    function setDays(uint newval) public onlyOwner returns (bool success) {    
        numDays = newval;
        return true;
    }    
    
    function setDays2(uint newval) public onlyOwner returns (bool success) {    
        numDays2 = newval;
        return true;
    }    

	function banTrader(address wallet) public onlyOwner returns (bool success) {
        banned[wallet] = 1;
        nextBannedWallet++;
        return true;
    }
	
	function unbanTrader(address wallet) public onlyOwner returns (bool success) {
        banned[wallet] = 0;
        if(nextBannedWallet > 0){ nextBannedWallet--; }
        return true;
    }	
   
		
    function userInfo(address _addr) view external returns(uint256 for_withdraw, 
                                                            uint256 numDeposits, uint256 lastStakingDeposit,uint256 lastStakingDuration,uint256 total_staked) {
        Investor storage investor = investors[_addr];

        uint256 payout = this.computePayout(_addr);
        return (
            payout + investor.dividends,
            investor.deposits.length,
            investor.lastStakingDeposit,
            investor.lastStakingDuration,
            investor.total_staked
        );
    } 
    
    function memberDeposit(address _addr, uint256 index) view external returns(uint40 time, uint256 amount, uint256 lifedays, uint256 percent)
    {
        Investor storage investor = investors[_addr];
        Depo storage dep = investor.deposits[index];
        Tarif storage tarif = tarifs[dep.tarif];
        return(dep.time, dep.amount, tarif.life_days, tarif.percent);
    }

    function memberStakeDeposit(address _addr, uint256 index) view external returns(uint40 time, uint256 amount, uint16 duration)
    {
        Investor storage investor = investors[_addr];
        StakingDepo storage s_dep = investor.stakingdeposits[index];
        return(s_dep.time, s_dep.amount, s_dep.duration);
    }

    function getBalance() public view returns(uint256) {
        return address(this).balance;
    }
    
    function getContractAddress() public view returns(address) {
        return address(this);
    }

    function getOwner() external view returns (address) {
        return owner();
    }
}