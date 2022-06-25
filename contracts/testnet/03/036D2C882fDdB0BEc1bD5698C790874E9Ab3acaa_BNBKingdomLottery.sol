/**
 *Submitted for verification at BscScan.com on 2022-06-25
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.7;

contract Ownable{
    address private _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _owner = msg.sender;
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
        require(owner() == msg.sender, "Ownable: caller is not the owner");
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
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

library SafeMath {

  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a / b;
    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }

  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b != 0);
    return a % b;
  }
}

interface IRandomGenerator {
    function getRandomNumber(uint _count) external view returns (uint);
}

contract BNBKingdomLottery is Ownable {
    using SafeMath for uint256;

    IRandomGenerator public randomGenerator;

    bool public started;            // Lottery start
    uint16 public roundID;          // Lottery Round ID
    uint256 public roundStart;             // Round start time
    uint256 public ticketPrice;     // ticket price[ defulat =  0.01BNB, owner setable]
    uint256 public roundInterval;   // Round time interval
    uint256 public jackPotSize;

    struct PurchaseInfo {
        uint256 ticketIDFrom;
        uint256 tickets;
        address account;
    }

    struct LotteryInfo {
        uint256 lotteryTime;            // round start time
        address winnerAccount;          // winner of this round
        uint256 totalTicketCnt;         // total purcahsed ticket count of this count
        PurchaseInfo[] purchaseInfo;    // purchase info
        mapping(address => uint256) userInfo;   // address -> total purchased ticket count
    }

    mapping(uint16 => LotteryInfo) public lotteryInfo;     // lottery ID -> LOtteryInfo

    constructor(address _randomGenerator) {
        randomGenerator = IRandomGenerator(_randomGenerator);
        ticketPrice = 10000000000000000; // 0.01BNB
        jackPotSize = 1000000000000000000; // 1BNB
        roundInterval = 7 days;
        roundID = 1;
    }

    function startLottery() external onlyOwner {
        require(started == false, "Round already started");
        started = true;
        roundStart = block.timestamp;
    }

    function finishLottery() external onlyOwner {
        require(started == true, "Round already ended");
        started = false;
    }

    function setRoundInterval(uint256 _seconds) external onlyOwner {
        require(_seconds < 30 days, "Could not set over than 1 month");
        roundInterval = _seconds;
    }

    function UpdateRoundInfo() internal {
        uint256 winTicketID = randomGenerator.getRandomNumber(lotteryInfo[roundID].totalTicketCnt);
        
        PurchaseInfo[] memory info = lotteryInfo[roundID].purchaseInfo;
        uint256 mid;
        uint256 low = 0;
        uint256 high = info.length - 1;

        /* perform binary search */
        while (low <= high) {
            mid = low + (high - low)/2; // update mid
            
            if ((winTicketID >= info[mid].ticketIDFrom) && 
                (winTicketID < info[mid].ticketIDFrom + info[mid].tickets)) {
                break; // find winnerID
            }
            else if (winTicketID < info[mid].ticketIDFrom) { // search left subarray for val
                high = mid - 1;  // update high
            }
            else if (winTicketID > info[mid].ticketIDFrom) { // search right subarray for val
                low = mid + 1;        // update low
            }
        }
        lotteryInfo[roundID].winnerAccount = info[mid].account;
        roundID = roundID + 1;
        roundStart = roundStart + roundInterval;
        lotteryInfo[roundID].lotteryTime = roundStart;
    }

    function buyTickets(address _account, uint256 _amount) external onlyOwner {
        require(started == true, "Round didn't start, yet");

        if (block.timestamp > roundStart + roundInterval) {
            UpdateRoundInfo();
        }

        uint256 ticketCnt = _amount.div(ticketPrice);

        lotteryInfo[roundID].purchaseInfo.push(PurchaseInfo({
            ticketIDFrom: lotteryInfo[roundID].totalTicketCnt,
            tickets: ticketCnt,
            account: _account
        }));

        lotteryInfo[roundID].totalTicketCnt = lotteryInfo[roundID].totalTicketCnt + ticketCnt;
        lotteryInfo[roundID].userInfo[_account] = lotteryInfo[roundID].userInfo[_account] + ticketCnt;
    }
    
    function setTicketPrice(uint256 _price) external onlyOwner {
        require(started == false, "Round already started");

        ticketPrice = _price;
    }

    function setJackPotSize(uint256 _price) external onlyOwner {
        jackPotSize = _price;
    }

    function getUserTicketInfo(address _account) external view returns(uint256) {
        return lotteryInfo[roundID].userInfo[_account];
    }
}