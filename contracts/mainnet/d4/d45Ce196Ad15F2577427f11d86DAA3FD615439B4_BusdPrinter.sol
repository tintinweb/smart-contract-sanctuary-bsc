/**
 *Submitted for verification at BscScan.com on 2022-09-11
*/

/* 
Telegram: t.me/Busd_printer
 *
 *   
 *   The newest high-yield experimental BUSD farm game!
 *
 *   [USAGE INSTRUCTION]
 *   1) Connect any BSC(BUSD) supported wallet
 *   2) Approve BUSD and buy Printers
 *   3) Wait for Printers to print BUSD
 *   4) Collect your BUSD!
 *
 *   [AFFILIATE PROGRAM]
 *   - 10% Direct Referral Commission
 *
 */

pragma solidity ^0.4.26;

contract ERC20 {
    function totalSupply() public constant returns (uint);
    function balanceOf(address tokenOwner) public constant returns (uint balance);
    function allowance(address tokenOwner, address spender) public constant returns (uint remaining);
    function transfer(address to, uint tokens) public returns (bool success);
    function approve(address spender, uint tokens) public returns (bool success);
    function transferFrom(address from, address to, uint tokens) public returns (bool success);
    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}

contract BusdPrinter {

    using SafeMath for uint256;
    
    address public BUSD = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;
    uint256 constant public INVEST_MIN_AMOUNT = 10 ether;
    uint256 constant public INVEST_MAX_AMOUNT = 50000 ether;
    uint256 constant public PROJECT_FEE = 80; // 8%
    uint256 constant public REFERRAL_BONUS = 100; // 10%
    uint256 constant public PERCENTS_DIVIDER = 1000;
    uint256 constant public FARM_RATE = 100; // 10% PER DAY
    uint256 constant public RATE_DIVISOR = 1000;
    uint256 constant public TIME_STEP = 1 days;
    
    uint256 constant public RELEASE_DATE = 1635084000; // 10 24 2021 2PM GMT
    
    // Magic Numbers
    uint256 public MA = 1e6;
    uint256 public MB = 1e6;
    uint256 public MC = 1 ether;
    
    mapping (address => uint256) public workers;
    mapping (address => uint256) public unclaimed;
    mapping (address => uint256) public checkpoints;
    mapping (address => address) public referrals;

    address public feeWallet;

    event Buy(address indexed user, uint256 amount);
    event Claim(address indexed user, uint256 amount);
    
    constructor() public {
        feeWallet = msg.sender;
    }

    function buy(address referrer, uint256 amount) public {
    
        require(block.timestamp >= RELEASE_DATE);
        
        // prevent tx overflows
        require(amount >= INVEST_MIN_AMOUNT && amount <= INVEST_MAX_AMOUNT);
        
        // transfer amount
        ERC20(BUSD).transferFrom(msg.sender, address(this), amount);
        
        // check if valid for buying
        uint256 s = getBuyRate(amount);
        require(s > 0);
        
        // check referrals
        referrer = (referrer == address(0)) ? feeWallet : referrer;
        if(referrals[msg.sender] == address(0)) {
            // new user
            referrals[msg.sender] = referrer;
            // give 10% commission
            unclaimed[referrer] = unclaimed[referrer].add(amount.mul(REFERRAL_BONUS).div(PERCENTS_DIVIDER));
        }
        
        // update user info
        unclaimed[msg.sender] = getClaimable(msg.sender);
        checkpoints[msg.sender] = block.timestamp;
        workers[msg.sender] = workers[msg.sender].add(s);
        
        // pay fee
        uint256 fee = amount.mul(PROJECT_FEE).div(PERCENTS_DIVIDER);
        ERC20(BUSD).transfer(feeWallet, fee);

        // update magic values
        MA = MA.sub(amount.div(MC));
        MB = MB.add(amount.div(MC));
        
        emit Buy(msg.sender, s);
    }
    
    function claim() public {
    
        require(block.timestamp >= RELEASE_DATE);
        
        uint256 claimable = getClaimable(msg.sender);
        require(claimable > 0);
        
        // update user info
        unclaimed[msg.sender] = 0;
        checkpoints[msg.sender] = block.timestamp;
        
        // pay fee
        uint256 fee = claimable.mul(PROJECT_FEE).div(PERCENTS_DIVIDER);
        ERC20(BUSD).transfer(feeWallet, fee);
        
        // update magic values
        MA = MA.add(claimable.div(MC));
        MB = MB.sub(claimable.div(MC));
        
        // prevent amount overflow
        claimable = (getContractBalance() > claimable) ? claimable : getContractBalance();
        
        ERC20(BUSD).transfer(msg.sender, claimable);
        emit Claim(msg.sender, claimable);
    }
    
    /* Combined claim + buy functions */
    function compound() public {
        
        require(block.timestamp >= RELEASE_DATE);
        
        // check BUSD amount claimable
        uint256 claimable = getClaimable(msg.sender);
        require(claimable > 0);
        
        // check if valid for buying
        uint256 s = getBuyRate(claimable);
        require(s > 0);
        
        // update user info
        unclaimed[msg.sender] = 0;
        checkpoints[msg.sender] = block.timestamp;
        workers[msg.sender] = workers[msg.sender].add(s);
        
        // pay fee
        uint256 fee = claimable.mul(PROJECT_FEE).div(PERCENTS_DIVIDER);
        ERC20(BUSD).transfer(feeWallet, fee);
        
        // Note: Updating Magic Values will equal to 0 change in values
        emit Buy(msg.sender, s);
    }
    
    function getContractBalance() public view returns(uint256) {
        return ERC20(BUSD).balanceOf(address(this));
    }
    
    function getClaimable(address user) public view returns(uint256 amount) {
        uint256 s = workers[user];
        if(s > 0) {
            uint256 start = checkpoints[user];
            uint256 end = block.timestamp;
            uint256 rate = s.mul(MC).mul(FARM_RATE).div(RATE_DIVISOR);
            amount = rate.mul(end.sub(start)).div(TIME_STEP).div(1000);
        }
        amount = amount.add(unclaimed[user]);
    }
    
    /* edited: precision from 0 decimals to 4 decimals */
    /* returns must be divided by 1000 */
    function getBuyRate(uint256 amount) public view returns(uint256) {
        amount = amount.sub(amount.mul(PROJECT_FEE).div(PERCENTS_DIVIDER));
        amount = amount.mul(1000); /**/
        amount = amount.div(MC);
        uint256 MA4 = MA.mul(1000); /**/
        uint256 MB4 = MB.mul(1000); /**/
        uint256 a = amount.mul(MA4).div(MB4);
        uint256 b = amount.mul(amount).mul(MA4).div(MB4.mul(MB4));
        return a.sub(b);
    }
    
    function getUserInfo(address user) public view returns(uint256 _workers, uint256 _claimable, uint256 _checkpoint, address _referrer) {
        _workers = workers[user];
        _claimable = getClaimable(user);
        _checkpoint = checkpoints[user];
        _referrer = referrals[user];
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