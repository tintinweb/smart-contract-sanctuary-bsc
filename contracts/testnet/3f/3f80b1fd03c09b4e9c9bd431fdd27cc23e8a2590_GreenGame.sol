/**
 *Submitted for verification at BscScan.com on 2022-05-19
*/

// ----------------------------------------------------------------------------
// GreenGame™ Main Contract (2022)
// Version: 0.0.1
// ----------------------------------------------------------------------------
// SPDX-License-Identifier: MIT
// ----------------------------------------------------------------------------
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
// EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
// OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
// IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
// DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
// TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE
// OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
// ----------------------------------------------------------------------------

pragma solidity 0.8.13;

interface IERC20 {
    function transfer(address _to, uint256 _amount) external returns (bool);
}

contract Ownable {
    address public owner;
    address public newOwner;

    event OwnershipTransferred(address from, address to);

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address transferOwner) public onlyOwner {
        require(transferOwner != newOwner);
        newOwner = transferOwner;
    }

    function acceptOwnership() public {
        require(msg.sender == newOwner);
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
        newOwner = address(0);
    }
}

contract GreenGame is Ownable {
    struct Table {
        uint256 thValue;
        uint256 charityShare;
        uint256 refShare;
        uint256 donationsCount;
        uint256 donationShare;
        uint256 refDonationShare;
        uint256 maxDonationsCount;
    }

    Table[] public tables;

    address public charityAddress;
    address public rootAddress;

    mapping(address => uint8) public address2table;

    uint256[256][256] public jumpValues; // [table_from][table_to] => amount

    mapping(uint8 => mapping(uint256 => uint8)) public value2table;
    mapping(uint8 => address[]) public tableAddresses;
    mapping(uint8 => mapping(address => uint256)) public donationsCountReceivedAlready;

    mapping(uint8 => mapping(address => uint256)) public refTableSum;
    mapping(uint8 => mapping(address => uint256)) public missedRefTableSum;
    mapping(uint8 => mapping(address => uint256)) public donationTableSum;
    mapping(uint8 => mapping(address => uint256)) public donationRefTableSum;
    mapping(uint8 => mapping(address => uint256)) public missedDonationRefTableSum;

    mapping(address => uint256) public refSum;
    mapping(address => uint256) public missedRefSum;
    mapping(address => uint256) public donationSum;
    mapping(address => uint256) public donationRefSum;
    mapping(address => uint256) public missedDonationRefSum;

    mapping(uint8 => mapping(uint8 => uint256)) public refMatrix; // [table_from][table_to] => ref
    mapping(uint8 => mapping(uint8 => uint256)) public donationMatrix; // [table_from][table_to] => donation
    mapping(uint8 => mapping(uint8 => uint256)) public donationRefMatrix; // [table_from][table_to] => donation ref
    mapping(uint8 => mapping(uint8 => uint256)) public charityMatrix; // [table_from][table_to] => charity

    mapping(address => address) public parents;

    event InvestmentReceived(uint8 table);
    event ReferralRewardSent(address indexed to, uint256 value, uint8 table);
    event DonationRewardSent(address indexed to, uint256 value, uint8 table);
    event DonationReferralRewardSent(address indexed to, uint256 value, uint8 table);
    event CharitySent(address indexed to, uint8 table);

    function inc8(uint8 x) private pure returns (uint8) {
        unchecked { return x + 1; }
    }

    function dec8(uint8 x) private pure returns (uint8) {
        unchecked { return x - 1; }
    }

    function inc256(uint256 x) private pure returns (uint256) {
        unchecked { return x + 1; }
    }

    function dec256(uint256 x) private pure returns (uint256) {
        unchecked { return x - 1; }
    }

    function setnewRootAddress(address newRootAddress) public onlyOwner {
        require(newRootAddress != address(0));
        address2table[newRootAddress] = address2table[rootAddress];
        rootAddress = newRootAddress;
        for (uint8 i = 0; i < tables.length; i = inc8(i)) {
            tableAddresses[i][0] = rootAddress;
        }
    }

    function getTableAddressesCount(uint8 num) public view returns (uint256) {
        return tableAddresses[num].length;
    }

    function payout(address receiver, uint256 value) private {
        require(receiver != address(0));
        payable(receiver).transfer(value);
    }

    // for any accidentally lost funds
    function withdraw() public onlyOwner {
        payout(owner, address(this).balance);
    }

    function appendTable(uint256 thValue, uint8 charityShare, uint8 refShare, uint8 donationsCount, uint8 donationShare, uint8 refDonationShare, uint8 maxDonationsCount, bool forceRebuildJUmpValues) public onlyOwner {
        setTableParams(thValue, uint8(tables.length), charityShare, refShare, donationsCount, donationShare, refDonationShare, maxDonationsCount, forceRebuildJUmpValues);
        tableAddresses[uint8(dec256(tables.length))].push(rootAddress);
    }

    function payoutDonationReferralReward(address winnerParent, uint256 value, uint8 tableNum) private {
        uint8 i = 0;
        while ((i < 5) && (address2table[winnerParent] < tableNum)) {
            missedDonationRefTableSum[tableNum][winnerParent] += value;
            missedDonationRefSum[winnerParent] += value;
            if (winnerParent == address(0)) {
                winnerParent = rootAddress;
                break;
            }
            winnerParent = parents[winnerParent];
            i = inc8(i);
        }
        if (i == 5) {
            winnerParent = rootAddress;
        }
        if (i == 0) {
            donationRefTableSum[tableNum][winnerParent] += value;
            donationRefSum[winnerParent] += value;
        }
        payout(winnerParent, value);
        emit DonationReferralRewardSent(winnerParent, value, tableNum);
    }

    function rebuildJumpValues() public onlyOwner {
        for (uint8 i = 0; i < tables.length; i = inc8(i)) {
            for (uint8 j = 0; j < tables.length; j = inc8(j)) {
                value2table[i][jumpValues[i][j]] = 0;
                jumpValues[i][j] = 0;
            }
        }

        // Initial state of Jump Matrix
        uint256 accum = 0;
        for (uint8 j = 1; j < tables.length; j = inc8(j)) {
            accum += tables[j].thValue;
            jumpValues[0][j] = accum;
            // reversed mapping from sum to target table
            value2table[0][accum] = j;
            unchecked {
                refMatrix[0][j] = accum * tables[j].refShare / 100;
                donationMatrix[0][j] = accum * tables[j].donationShare / 100;
                donationRefMatrix[0][j] = accum * tables[j].refDonationShare / 100;
                charityMatrix[0][j] = accum * tables[j].charityShare / 100;
            }
        }

        // Rest part of Jump Matrix
        uint256 val;
        for (uint8 i = 1; i < tables.length; i = inc8(i)) {
            for (uint8 j = 1; j < tables.length; j = inc8(j)) {
                if (j < i) {
                    jumpValues[i][j] = 0;
                } else {
                    val = jumpValues[dec8(i)][j] - jumpValues[dec8(i)][i];
                    jumpValues[i][j] = val;
                    value2table[i][val] = j;
                    unchecked {
                        refMatrix[i][j] = val * tables[j].refShare / 100;
                        donationMatrix[i][j] = val * tables[j].donationShare / 100;
                        donationRefMatrix[i][j] = val * tables[j].refDonationShare / 100;
                        charityMatrix[i][j] = val * tables[j].charityShare / 100;
                    }
                }
            }
        }

        address2table[rootAddress] = uint8(tables.length);
    }

    // for any tokens lost and might be acccidentally sent to this contract
    function withdrawToken(address _tokenContract, uint256 _amount) public onlyOwner {
        IERC20 tokenContract = IERC20(_tokenContract);
        tokenContract.transfer(msg.sender, _amount);
    }

    function payoutReferralReward(address parent, uint256 value, uint8 tableNum) private {
        uint8 i = 0;
        while ((i < 5) && (address2table[parent] < tableNum)) {
            missedRefTableSum[tableNum][parent] += value;
            missedRefSum[parent] += value;
            if (parent == address(0)) {
                parent = rootAddress;
                break;
            }
            parent = parents[parent];
            i = inc8(i);
        }
        if (i == 5) {
            parent = rootAddress;
        }
        refTableSum[tableNum][parent] += value;
        refSum[parent] += value;
        payout(parent, value);
        emit ReferralRewardSent(parent, value, tableNum);
    }

    function getTableThreshold(uint8 num) public view returns (uint256) {
        require (num <= tables.length);
        return tables[num].thValue;
    }

    function process(address parent) private {
        uint8 currentTable = address2table[msg.sender];
        uint8 newTable = value2table[currentTable][msg.value];
        require(newTable > currentTable);

        emit InvestmentReceived(newTable);

        // Get table params
        Table memory t = tables[newTable];

        // Direct Ref Payout
        payoutReferralReward(parent, refMatrix[currentTable][newTable], newTable);

        for (uint8 i = 1; i <= t.donationsCount; i = inc8(i)){
            // Donation Ref Payout
            address winner = tableAddresses[newTable][random(tableAddresses[newTable].length, i)];
            payoutDonationReferralReward(parents[winner], donationRefMatrix[currentTable][newTable], newTable);

            // Donation Payout
            payoutDonationReward(winner, donationMatrix[currentTable][newTable], newTable);
        }

        address2table[msg.sender] = newTable;
        for (uint8 i = currentTable; i < newTable; i = inc8(i)){
            tableAddresses[inc8(i)].push(msg.sender);
        }
        parents[msg.sender] = parent;

        payout(charityAddress, charityMatrix[currentTable][newTable]);
        emit CharitySent(charityAddress, newTable);
    }

    function getTablesCount() public view returns (uint256) {
        return tables.length;
    }

    function setTableParams(uint256 thValue, uint8 num, uint8 charityShare, uint8 refShare, uint8 donationsCount, uint8 donationShare, uint8 refDonationShare, uint8 maxDonationsCount, bool forceRebuildJUmpValues) public onlyOwner {
        Table memory t = Table(thValue, charityShare, refShare, donationsCount, donationShare, refDonationShare, maxDonationsCount);
        require(num > 0);
        require(num <= tables.length);
        require(t.thValue > 0);
        unchecked {
            require(t.charityShare + t.refShare + t.donationsCount * t.donationShare + t.donationsCount * t.refDonationShare == 100);
        }

        // if it's not a first table
        if (num > 1) {
            // it should be greater than prev threshold
            require(t.thValue > tables[dec8(num)].thValue);
        }
        // if it's not a last table or a new one
        if (num < dec256(tables.length)) {
            // it should be less that next threshold
            require(t.thValue < tables[inc8(num)].thValue);
        }

        if (num == tables.length) {
            tables.push(t);
        } else {
            tables[num].thValue = t.thValue;
        }

        if (forceRebuildJUmpValues) {
            rebuildJumpValues();
        }
    }

    function setnewCharityAddress(address newCharityAddress) public onlyOwner {
        require(newCharityAddress != address(0));
        charityAddress = newCharityAddress;
    }

    function payoutDonationReward(address winner, uint256 value, uint8 tableNum) private {
        if ((tables[tableNum].maxDonationsCount != 0) && (donationsCountReceivedAlready[tableNum][winner] > tables[tableNum].maxDonationsCount)) {
            winner = rootAddress;
        }
        donationsCountReceivedAlready[tableNum][winner] = inc256(donationsCountReceivedAlready[tableNum][winner]);
        donationTableSum[tableNum][winner] += value;
        payout(winner, value);
        emit DonationRewardSent(winner, value, tableNum);
    }

    // buy with parent
    function buy(address parent) public payable {
        require(msg.value > 0);
        require(parent != address(0));
        if (parents[msg.sender] != parent) { // prevent an attempt to change parent
            process(parents[msg.sender]);
        } else {
            process(parent);
        }
    }

    function random(uint256 max, uint8 salt) public view returns(uint256) {
        unchecked {
            return uint256(keccak256(abi.encodePacked(block.timestamp * salt, block.difficulty, msg.sender))) % max;
        }
    }

    // buy without parent passed explicitly
    receive() external payable {
        require(msg.value > 0);
        if (parents[msg.sender] == address(0)) { // no parent found
            process(rootAddress);
        } else {
            process(parents[msg.sender]);
        }
    }

    constructor(address root, address charity) {
        rootAddress = root;
        charityAddress = charity;

        // Zero Table
        tables.push(Table(0, 0, 0, 0, 0, 0, 0));

        // League #1
        appendTable(100000_000000_000000, 10, 25, 5, 8, 5, 30, false); // 100000000000000000
        appendTable(200000_000000_000000, 10, 25, 5, 8, 5, 30, false); // 200000000000000000
        appendTable(400000_000000_000000, 10, 25, 5, 8, 5, 30, false); // 400000000000000000
        appendTable(800000_000000_000000, 10, 25, 5, 8, 5, 30, false); // 800000000000000000

        // League #2
        appendTable(1_600000_000000_000000, 10, 25, 5, 9, 4, 40, false); // 1600000000000000000
        appendTable(3_200000_000000_000000, 10, 25, 5, 9, 4, 40, false); // 3200000000000000000
        appendTable(6_400000_000000_000000, 10, 25, 5, 9, 4, 40, false); // 6400000000000000000

        // League #3
        appendTable(12_500000_000000_000000, 10, 25, 5, 10, 3, 50, false); // 12500000000000000000
        appendTable(25_000000_000000_000000, 10, 25, 5, 10, 3, 50, false); // 25000000000000000000

        // League #4
        appendTable(50_000000_000000_000000, 10, 25, 5, 11, 2, 0, false); // 50000000000000000000

        rebuildJumpValues();
    }
}