/**
 *Submitted for verification at BscScan.com on 2022-03-24
*/

/*
Pot Luck
A self-contained verifiably random lucky draw using Chainlink
Fixed entry price 0.1BNB
81.1% win rate
92% payout rate (87.4% after fees) 
75% chance of x1
5% chance of x2
1% chance of x5
0.1% chance of x20
50/50 double or nothing game opportunity after winning x2 or more!

5% game fees covers Chainlink costs and maintenance
100% rug-proof:
 Minimum balance maintained at 20x entry price. 
 Funds withdraw impossible until all entries are processed or a minimum balance is maintained to pay out all unprocessed entries 20x.
 Game will automatically deny new entries if the minimum contract balance is not met.
*/

// SPDX-License-Identifier: Unlicensed

pragma solidity 0.8.13;

library Address {
    function isContract(address account) internal view returns (bool) {
        // According to EIP-1052, 0x0 is the value returned for not-yet created accounts
        // and 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470 is returned
        // for accounts without code, i.e. `keccak256('')`
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
      return functionCall(target, data, "Address: low-level call failed");
    }
    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return _functionCallWithValue(target, data, 0, errorMessage);
    }
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }
    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        return _functionCallWithValue(target, data, value, errorMessage);
    }
    function _functionCallWithValue(address target, bytes memory data, uint256 weiValue, string memory errorMessage) private returns (bytes memory) {
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{ value: weiValue }(data);
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                // solhint-disable-next-line no-inline-assembly
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

interface IDraw {
  function chain(uint256 entry, uint32 words) external;
  function checkRequestId(uint256 entry) external view returns(uint256);
  function hasResults(uint256 entry) external view returns(bool);
  function checkResults(uint256 entry, uint256 id) external view returns(uint256);
}

contract PotLuck {
    using Address for address;
    struct entry {
        uint256 value;
        address sender;
        bool resultsProcessed;
        bool doubleOrNothingPlayed;
    }
    address dev;
    IDraw constant linker = IDraw(0x557E66946a9Ae4f981420DAb929E2ddcC1da5c5e);

    bool open = true;
    entry[] public entries;
    mapping (address => uint256[]) public MyEntryIds;
    mapping (address => uint256) private myNextDraw;
    uint256 public index = 1;
    uint256 public constant price = 100000000000000000;

    string public constant symbol = "POT";
    string public constant name = "Pot Luck";

    uint256 public totalPaid;
    uint256 public totalWon;

    event Jackpot(address indexed winner, uint256 amount);

    constructor () {
        dev = msg.sender;
        entries.push(entry(0, address(0), true, true)); //dead entry
    }

    receive() external payable {
        require(msg.value == price, "0.1BNB Pot Luck");
        require(open && address(this).balance >= price*20, "Game closed");

        addEntry(msg.sender, price, false);
    }

    function addEntry(address sender, uint256 value, bool doubleOrNothing) internal {
        MyEntryIds[sender].push(entries.length);
        entries.push(entry(value, sender, false, doubleOrNothing));
        linker.chain(entries.length-1, 1);
        totalPaid+=value;

        if(entries[index].resultsProcessed){
            index++;
        } else {
            if(processResults(index))
                index++;
        }
    }

    function processResults(uint256 entryId) public returns (bool){
        require(entryId > 0 && entryId <= index, "Not a valid entry");
        if(!entries[entryId].resultsProcessed) {
            if(linker.hasResults(entryId)) { 
                entries[entryId].resultsProcessed = true;
                myNextDraw[entries[entryId].sender]++;
                uint256 payout = checkPayout(entryId, entries[entryId].value, 0);
                if(payout > 0) {
                    totalWon+=payout;
                    (bool sent, ) = entries[entryId].sender.call{value: payout * 19 / 20}("");
                    require(sent, "Failed to send winnings");
                    (bool sentDev, ) = dev.call{value: payout / 20}("");
                    sentDev; //suppress compiler warning
                    if(payout > price)
                        emit Jackpot(entries[entryId].sender, payout);
                }
            } else {
                return false;
            }
        }
        return true;
    }

    function processQueue(uint256 number) external {
        for(uint i = index; i < entries.length && i-index < number; i++) {
            if(entries[i].resultsProcessed){
                index++;
            } else {
                if(processResults(i)){
                    index++;
                } else
                    return;
            }
        }
    }

    function ProcessMyNextEntry() external returns (bool){
        return processResults(MyNextEntryId(msg.sender));
    }

    function CurrentWinPercent() external view returns(uint256) {
        return totalWon * 100 / totalPaid;
    }

    function checkPayout(uint256 entryId, uint256 value, uint256 slot) internal view returns (uint256 payout) {
        if(value > price) {
            //double or nothing
            uint256 double = linker.checkResults(entryId, slot) % 100 + 1; //1-100
            if (double <= 50) {
                payout = 0; //50% chance
            } else {
                payout = value * 2; //50% chance
            }
        } else {
            uint256 result = linker.checkResults(entryId, slot) % 1000 + 1; //1-1000
            if (result <= 750) {
                payout = value; //75% chance
            } else if (result <= 939) {
                payout = 0; //18.9% chance
            } else if (result <= 989) {
                payout = value * 2; //5% chance
            } else if (result <= 999) {
                payout = value * 5; //1% chance
            } else {
                payout = value * 20; //0.1% chance
            }
        }
    }

    function MyNextEntryId(address wallet) public view returns (uint256) {
        return MyEntryIds[wallet][myNextDraw[wallet]];
    }

    function MyTotalEntries(address wallet) public view returns (uint256) {
        return MyEntryIds[wallet].length;
    }

    function DoubleOrNothing(uint256 entryId) external payable {
        require(open, "Game closed");
        require(entries[entryId].sender == msg.sender, "Invalid player");
        require(!entries[entryId].doubleOrNothingPlayed, "Already played Double or Nothing on this entry");
        (,uint256 payout) = checkEntryPayout(entryId);
        require(payout > price, "Sorry, this entry did not win at least 2x.");
        require(msg.value == payout, "Wrong value sent");
        require(address(this).balance >= (entries.length - index) * price * 20 + msg.value, "Insufficient pot balance to play Double or Nothing, try again later");

        entries[entryId].doubleOrNothingPlayed = true;
        addEntry(msg.sender, msg.value, true);
    }

    function checkEntryPayout(uint256 entryId) public view returns(string memory result, uint256 payout) {
        require(entryId > 0 && entryId <= index, "Invalid entry");
        if(linker.hasResults(entryId)) {
            payout = checkPayout(entryId, entries[entryId].value, 0);
            if(entries[entryId].resultsProcessed)
                result = payout > 0 ? "Winner! Payment processed." : "Better luck next time!";
            else
                result = payout > 0 ? "Winner! Your payment is still pending. Run ProcessMyNextEntry if you would like it now." : "Better luck next time!";
        } else {
            result = "Still processing";
            payout = 0;
        }
    }

    function MyLastPayout(address wallet) external view returns (string memory result, uint256 payout) {
        if(MyTotalEntries(wallet) == 0) {
            result = "No entries";
            payout = 0;
        } else {
            uint256 lastEntry;
            if(myNextDraw[wallet] == MyTotalEntries(wallet) -1)
                lastEntry = 0;
            else 
                lastEntry = myNextDraw[wallet]-1;

            (result, payout) = checkEntryPayout(MyEntryIds[wallet][lastEntry]);
        }
    }

    function totalEntries() external view returns(uint256) {{
        return entries.length-1;
    }}

    function setOpen(bool isOpen) external {
        require(msg.sender == dev);
        open = isOpen;
    }

    function PotBalance() external view returns(uint256) {
        return address(this).balance;
    }

    function updateDev(address _wallet) external {
        require(msg.sender == dev);
        require(_wallet != address(0));
        dev = _wallet;
    }

    function withdrawFees(address wallet, uint256 percent) external {
        require(msg.sender == dev);
        uint256 withdraw = address(this).balance * percent / 100;
        require(address(this).balance - withdraw >= (entries.length - index) * price * 20, "Can't withdraw possible winnings.");
        (bool sent, ) = wallet.call{value: withdraw}("");
        require(sent, "Transfer failed");
    }

    function deposit() payable external {  
    }
}