import "./SafeMath.sol";
import "./Auth.sol";

contract Raffler is Auth {

    constructor () Auth(msg.sender) {}

    using SafeMath for uint256;

    struct RaffleInfo {
        address addr;
        uint256 currRaffleBalance;
        uint256 balance;
        uint256 entries;
        uint256 idx;
    }

    struct WinnerInfo {
        address addr;
        uint256 prize;
    }

    uint256 holdFactor = 1;
    uint256 currFactor = 2;

    uint256 lastIdx = 0;
    RaffleInfo[] raffleInfos;
    mapping (address => RaffleInfo) addrToRaffleInfo;

    WinnerInfo[] winners;

    function raffle() external onlyOwner() returns(WinnerInfo[] memory) {
        
        uint256 totalEntries = 0;
        for (uint256 idx = 0; idx <= lastIdx; idx = idx.add(1)) {
            RaffleInfo memory raffleInfo = raffleInfos[idx];
            uint256 balance = raffleInfo.balance;
            uint256 diff = balance.sub(raffleInfo.currRaffleBalance);
            uint256 entries = (raffleInfo.currRaffleBalance.mul(currFactor)).add(diff.mul(holdFactor));
            addrToRaffleInfo[raffleInfo.addr].entries = entries;
            totalEntries = totalEntries.add(entries);
        }

        uint256 winnerNumber = uint256(keccak256(abi.encodePacked(block.timestamp))) % (totalEntries);
        uint256 start = 0;
        for (uint256 idx = 0; idx <= lastIdx; idx = idx.add(1)) {
            RaffleInfo memory raffleInfo = raffleInfos[idx];
            uint256 entries = raffleInfo.entries;
            if ((winnerNumber >= start) && (winnerNumber < (start.add(entries)))) {
                winners.push(WinnerInfo(raffleInfo.addr, 0));
            }
            addrToRaffleInfo[raffleInfo.addr].currRaffleBalance = 0;
            addrToRaffleInfo[raffleInfo.addr].entries = 0;
        }
        return winners;

    }

    function update(address from, address to, uint256 amount, uint256 fromBalance, uint256 toBalance) external authorized() {
        updateBuy(to, amount, toBalance);
        updateSell(from, amount, fromBalance);
    }

    function updateBuy(address addr, uint256 amount, uint256 balance) private {
        bool newAddr = addrToRaffleInfo[addr].addr == address(0);
        addrToRaffleInfo[addr].balance = balance;
        addrToRaffleInfo[addr].currRaffleBalance = addrToRaffleInfo[addr].currRaffleBalance.add(amount);
        if (newAddr) {
            lastIdx = lastIdx.add(1);
            addrToRaffleInfo[addr].addr = addr;
            addrToRaffleInfo[addr].idx = lastIdx;
            raffleInfos.push(addrToRaffleInfo[addr]);
        }
        else {
            uint256 idx = addrToRaffleInfo[addr].idx;
            raffleInfos[idx] = addrToRaffleInfo[addr];
        }

    }

    function updateSell(address addr, uint256 amount, uint256 balance) private {
        bool newAddr = addrToRaffleInfo[addr].addr == address(0);
        addrToRaffleInfo[addr].balance = balance;
        uint256 currBal = addrToRaffleInfo[addr].currRaffleBalance;
        uint256 amountToSub = (currBal > amount) ? amount : currBal;
        addrToRaffleInfo[addr].currRaffleBalance = addrToRaffleInfo[addr].currRaffleBalance.sub(amountToSub);
        if (newAddr) {
            lastIdx = lastIdx.add(1);
            addrToRaffleInfo[addr].addr = addr;
            addrToRaffleInfo[addr].idx = lastIdx;
            raffleInfos.push(addrToRaffleInfo[addr]);
        }
        else {
            uint256 idx = addrToRaffleInfo[addr].idx;
            raffleInfos[idx] = addrToRaffleInfo[addr];
        }
    }
}