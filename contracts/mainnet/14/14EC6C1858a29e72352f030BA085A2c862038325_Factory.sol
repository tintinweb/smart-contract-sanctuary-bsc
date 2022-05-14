/**
 *Submitted for verification at BscScan.com on 2022-05-14
*/

// SPDX-License-Identifier: MIT 
pragma solidity >=0.4.22 <0.9.0;

contract Factory {
	using SafeMath for uint256;

    string public name = "Dappy Factory";

    uint256 constant public ADMIN_FEE        = 20;  //2%
	uint256 constant public PERCENTS_DIVIDER = 1000;
	uint256 constant public TIME_STEP = 1 days;

    uint256 public DEPOSIT_MIN_AMOUNT;
    uint256 public DEPOSIT_MAX_AMOUNT;
    uint256 public PUBLISH_FEE;

	struct Investor {
        uint256 principle;
        uint256 position;
		uint256 checkpoint;
        uint256 withdrawn;
        uint256 overdraw;
	}

    struct Dappy {
        address owner;
        uint256 start;
        uint256 hedge;
        uint256 rate;
        uint256 ownerFee;
        string title;
        string description;
        string accent;
        bool theme;
    }

    Dappy[] internal dappys;

    mapping(uint256 => mapping(address => Investor)) private investors;
    mapping(uint256 => mapping(address => uint256)) private allowances;
    mapping(uint256 => uint256) private balances;
    mapping(address => uint256) private discounts;

    address payable public admin;


    constructor(uint256 networkMinimum) {
        //set admin
        admin = payable(msg.sender);

        //set discount
        setDiscount(admin, 1000);

        //calibrate for destination network
        DEPOSIT_MIN_AMOUNT = networkMinimum;
        DEPOSIT_MAX_AMOUNT = DEPOSIT_MIN_AMOUNT.mul(1000);
        PUBLISH_FEE        = DEPOSIT_MIN_AMOUNT.mul(2000);
    }

    modifier exists(uint256 atIndex) {
        require(atIndex < dappys.length, "Dappy at index does not exist.");
        _;
    }

    modifier onlyOwner(uint256 atIndex) {
        require(getDappy(atIndex).owner == msg.sender, "Not authorized.");
        _;
    }

    modifier onlyAdmin() {
        require(msg.sender == admin, "Not authorized.");
        _;
    }

    function publish(
        uint256 start,
        uint256 hedge,
        uint256 rate,
        uint256 fee,
        string memory title,
        string memory description,
        string memory accent,
        bool theme 
    ) 
        public
        payable
    {
        //validate fee
        uint256 publishFee = getPublishFee(msg.sender);

        //validate payment
        require(msg.value == publishFee, "Incorrect publish fee paid.");

        //validate parameters
        require(start >= block.timestamp, "Invalid parameter: start (start cannot be < now).");
        require(hedge >= 510,  "Invalid parameter: hedge (minimum is 510).");
        require(hedge <= 1000, "Invalid parameter: hedge (maximum is 1000).");
        require(rate  >= 1,    "Invalid parameter: rate  (minimum is 1).");
        require(rate  <= 100,  "Invalid parameter: rate  (maximum is 100).");
        require(fee   >= 0,    "Invalid parameter: fee   (minimum is 0).");
        require(fee   <= 100,  "Invalid parameter: fee   (maximum is 100).");

        //pay admin
        admin.transfer(publishFee);

        //publish dappy
        dappys.push(Dappy(msg.sender, start, hedge, rate, fee, title, description, accent, theme));
    }

    function invest(uint256 atIndex) public payable exists(atIndex) {
		require(msg.value >= DEPOSIT_MIN_AMOUNT, "Minimum deposit amount is 0.01");
		require(msg.value <= DEPOSIT_MAX_AMOUNT, "Maximum deposit amount is 1000");

        //if outstanding rewards
        uint256 rewards = calculateRewards(atIndex, msg.sender);
        if(rewards > 0) { compound(atIndex); }

        //dappy ref
        Dappy memory dappy = getDappy(atIndex);

        //owner fee
        uint256 fee1 = msg.value.mul(dappy.ownerFee).div(PERCENTS_DIVIDER);
        address payable owner = payable(dappy.owner);
        owner.transfer(fee1);

        //admin fee
        uint256 fee2 = msg.value.mul(ADMIN_FEE).div(PERCENTS_DIVIDER);
        admin.transfer(fee2);

        //deposit amount
        uint256 NETamount = msg.value.sub(fee1).sub(fee2); 

        //investor
        Investor storage investor = investors[atIndex][msg.sender];
        investor.principle = investor.principle.add(NETamount);
        investor.position  = investor.position.add(NETamount);
        investor.checkpoint= block.timestamp;

        //balances
        balances[atIndex] = balances[atIndex].add(NETamount);

        //allowances
        uint256 hedgeAmount = NETamount.mul(dappy.hedge).div(PERCENTS_DIVIDER);
        uint256 newAllowance= getAllowance(atIndex, owner).add(NETamount.sub(hedgeAmount));
        setAllowance(atIndex, owner, newAllowance);
    }

    function compound(uint256 atIndex) public exists(atIndex) {
        //get rewards
        uint256 rewards = calculateRewards(atIndex, msg.sender);
        require(rewards > 0, "No rewards.");

        //investor
        Investor storage investor = investors[atIndex][msg.sender];
        investor.position = investor.position.add(rewards);
        investor.checkpoint = block.timestamp;

        //dappy ref
        Dappy memory dappy = getDappy(atIndex);

        //overdraw
        if(investor.withdrawn < investor.principle) {
            investor.overdraw = investor.overdraw > 0 ? investor.overdraw.sub(dappy.rate.div(10)) : 0;
        }
    }

    function withdraw(uint256 atIndex) public exists(atIndex) {
        //get rewards
        uint256 rewards = calculateRewards(atIndex, msg.sender);
        require(rewards > 0, "No rewards.");

        //balance?
        if(rewards > balances[atIndex]) {
           rewards = balances[atIndex]; 
        }

        //admin fee
        uint256 fee = rewards.mul(ADMIN_FEE).div(PERCENTS_DIVIDER);
        admin.transfer(fee);

        //rewards amount
        uint256 NETamount = rewards.sub(fee);

        //investor
        Investor storage investor = investors[atIndex][msg.sender];
        investor.checkpoint= block.timestamp;
        investor.withdrawn = investor.withdrawn.add(NETamount);

        //dappy ref
        Dappy memory dappy= getDappy(atIndex);

        //overdraw
        investor.overdraw = investor.overdraw < dappy.rate.sub(dappy.rate.div(10)) ? investor.overdraw.add(dappy.rate.div(10)) : investor.overdraw;

        //balances
        balances[atIndex] = balances[atIndex].sub(rewards);

        //allowance
        address owner       = dappy.owner;
        uint256 hedgeAmount = NETamount.mul(dappy.hedge).div(PERCENTS_DIVIDER);
        uint256 allowance   = getAllowance(atIndex, owner);

        //workaround of subtraction overflow
        if(allowance >= NETamount.sub(hedgeAmount)) {
            allowance = allowance.sub(NETamount.sub(hedgeAmount));
        } else {
            allowance = 0;
        }
        setAllowance(atIndex, owner, allowance);

        //transfer
        payable(msg.sender).transfer(NETamount);
    }

    function calculateRewards(uint256 atIndex, address atAddress) public view exists(atIndex) returns (uint256 result) {
        Dappy memory dappy = getDappy(atIndex);

        //is started?
        if(block.timestamp < dappy.start) return 0;

        //if started? continue
        Investor memory investor = getInvestor(atIndex, atAddress);
        uint256 rate      = dappy.rate;
        uint256 checkpoint= investor.checkpoint;
        uint256 position  = investor.position;
        uint256 overdraw  = investor.overdraw;

        //has checkpoint?
        if(checkpoint == 0) return 0;

        //period
        uint256 from      = checkpoint > dappy.start ? checkpoint : dappy.start;
        uint256 period    = block.timestamp.sub(from);
        uint256 periodDays= period.div(TIME_STEP); 

        //overdraw penalty
        uint256 penalties = overdraw;
        
        //hoarding penalty
        uint256 perPeriod;

        for (uint256 i = 0; i < periodDays; i++) {
            perPeriod = perPeriod.add(position.mul(rate.sub(penalties)).div(PERCENTS_DIVIDER));
            penalties = penalties < dappy.rate.sub(dappy.rate.div(10)) ? penalties.add(dappy.rate.div(10)) : penalties;
        }

        //returns
        result = perPeriod;
    }

    function calculatePenalties(uint256 atIndex, address atAddress) public view returns (uint256 result) {
        Dappy memory dappy = getDappy(atIndex);

        //is started?
        if(block.timestamp < dappy.start) return 0;

        //investor
        Investor memory investor = getInvestor(atIndex, atAddress);
        uint256 checkpoint= investor.checkpoint;
        uint256 overdraw  = investor.overdraw;

        //has checkpoint?
        if(checkpoint == 0) return 0;

        //period
        uint256 from      = checkpoint > dappy.start ? checkpoint : dappy.start;
        uint256 period    = block.timestamp.sub(from);
        uint256 periodDays= period.div(TIME_STEP); 

        //overdraw penalty
        uint256 penalties = overdraw;

        for (uint256 i = 0; i < periodDays; i++) {
            penalties = penalties < dappy.rate.sub(dappy.rate.div(10)) ? penalties.add(dappy.rate.div(10)) : penalties;
        }

        //returns
        result = penalties;
    }

    function ownerWithdraw(uint256 atIndex, uint256 amount) public exists(atIndex) onlyOwner(atIndex) {
        //validate amount
        address atOwner = msg.sender;
        require(amount <= getAllowance(atIndex, atOwner), "Amount exceeds allowance.");

        //balances
        balances[atIndex] = balances[atIndex].sub(amount);

        //allowances
        uint256 newAllowance= getAllowance(atIndex, atOwner).sub(amount);
        setAllowance(atIndex, atOwner, newAllowance);

        //transfer
        payable(atOwner).transfer(amount);
    }

    function ownerDeposit(uint256 atIndex) public payable exists(atIndex) onlyOwner(atIndex) {
        uint256 amount = msg.value;
        address atOwner= msg.sender;

        //balances
        balances[atIndex] = balances[atIndex].add(amount);

        //allowances
        uint256 newAllowance= getAllowance(atIndex, atOwner).add(amount);
        setAllowance(atIndex, atOwner, newAllowance);
    }

    function setAllowance(uint256 atIndex, address atAddress, uint256 toAmount) private exists(atIndex) {
        allowances[atIndex][atAddress] = toAmount;
    }

    function setDiscount(address atAddress, uint256 toPercent) public onlyAdmin() {
        discounts[atAddress] = toPercent;
    }

    function getDiscount(address atAddress) public view returns (uint256) {
        return discounts[atAddress];
    }

    function getPublishFee(address atAddress) public view returns (uint256) {
        uint256 fee = PUBLISH_FEE;
        return fee.sub(fee.mul(getDiscount(atAddress)).div(PERCENTS_DIVIDER));
    }

    function getDappy(uint256 atIndex) public view returns (Dappy memory) {
        return dappys[atIndex];
    }

    function getDappys() public view returns (Dappy[] memory) {
        return dappys;
    }

    function getInvestor(uint256 atIndex, address atAddress) public view returns (Investor memory) {
        return investors[atIndex][atAddress];
    }

    function getBalance(uint256 atIndex) public view returns (uint256) {
        return balances[atIndex];
    }

    function getAllowance(uint256 atIndex, address atAddress) public view returns (uint256) {
        return allowances[atIndex][atAddress];
    }

	function getContractBalance() public view returns (uint256) {
		return address(this).balance;
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