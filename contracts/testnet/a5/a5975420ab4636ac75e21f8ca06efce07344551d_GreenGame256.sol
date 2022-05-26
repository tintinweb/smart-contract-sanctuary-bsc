/**
 *Submitted for verification at BscScan.com on 2022-05-25
*/

// ----------------------------------------------------------------------------
// GreenGame™ Main Contract (2022)
// Version: 0.0.2
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

pragma solidity 0.8.14;

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

contract GreenGame256 is Ownable {
    struct Table {
        uint256 thValue;
        uint256 charityShare;
        uint256 refShare;
        uint256 donationsCount;
        uint256 donationShare;
        uint256 refDonationShare;
        uint256 maxDonationsCount;
        uint256[16]jumpValues;
        uint256[16]refMatrix;
        uint256[16]donationMatrix;
        uint256[16]donationRefMatrix;
        uint256[16]charityMatrix;
    }

    struct Stat {
        uint256 refSum;
        uint256 missedRefSum;
        uint256 donationSum;
        uint256 donationRefSum;
        uint256 missedDonationRefSum;
        uint256 donationsCountReceivedAlready;
    }
    mapping (bytes32 => Stat) ctstats; // 12 bytes table number + 20 bytes address

    struct Customer {
        uint256 id;
        uint256 table;
        Stat stat;
        address parent;
    }
    mapping (address => Customer) public customers;

    Table[] public tables;

    address public charityAddress;
    address public rootAddress;

    mapping(uint256 => mapping(uint256 => uint256)) public value2table;
    mapping(uint256 => address[]) public tableAddresses;

    uint256 public counter;

    event InvestmentReceived(uint256 table);
    event ReferralRewardSent(address indexed to, uint256 value, uint256 table);
    event DonationRewardSent(address indexed to, uint256 value, uint256 table);
    event DonationReferralRewardSent(address indexed to, uint256 value, uint256 table);
    event CharitySent(address indexed to, uint256 table);

    constructor(address root, address charity) {
        rootAddress = root;
        charityAddress = charity;

        // Zero Table
        Table memory zt;
        tables.push(zt);

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

    // buy without parent passed explicitly
    receive() external payable {
        buy(rootAddress);
    }

    function buy(address parent) public payable {
        require(parent != address(0));
        Customer storage customer = customers[msg.sender];
        Customer memory _customer = customer;

        if (_customer.id != 0) { // ignore any parent value if it's not a first purchase
            parent = _customer.parent;
        } else { // otherwise flag it for any first purchase
            counter += 1;
            customer.id = counter;
        }
        require(msg.value > 0);
        require(msg.sender != parent);
        require(msg.sender.code.length == 0);
        require(parent.code.length == 0);

        uint256 currentTable = _customer.table;
        uint256 newTable = value2table[currentTable][msg.value];
        require(newTable > currentTable);

        emit InvestmentReceived(newTable);

        // Get table params
        Table memory _t = tables[currentTable];
        // Table storage 
        uint256 donationsCount = tables[newTable].donationsCount;

        // Direct Ref Payout
        payoutReferralReward(parent, _t.refMatrix[newTable], newTable);

        uint256 maxRandom = tableAddresses[newTable].length;
        for (uint256 i = 1; i <= donationsCount; i++){
            // Donation Ref Payout
            address winner = tableAddresses[newTable][random(maxRandom, i)];
            payoutDonationReferralReward(customers[winner].parent, _t.donationRefMatrix[newTable], newTable);

            // Donation Payout
            payoutDonationReward(winner, _t.donationMatrix[newTable], newTable);
        }

        customer.table = newTable;
        for (uint256 i = currentTable; i < newTable; i++){
            tableAddresses[i + 1].push(msg.sender);
        }
        customer.parent = msg.sender;

        payout(charityAddress, _t.charityMatrix[newTable]);
        emit CharitySent(charityAddress, newTable);
    }

    function payoutDonationReward(address winner, uint256 value, uint256 tableNum) private {
        bytes32 key = bytes32(tableNum) | bytes20(winner);
        if ((tables[tableNum].maxDonationsCount != 0) && (ctstats[key].donationsCountReceivedAlready > tables[tableNum].maxDonationsCount)) {
            winner = rootAddress;
        }
        ctstats[key].donationsCountReceivedAlready++;
        ctstats[key].donationSum++;
        payout(winner, value);
        emit DonationRewardSent(winner, value, tableNum);
    }

    function payoutDonationReferralReward(address winnerParent, uint256 value, uint256 tableNum) private {
        bytes32 t32 = bytes32(tableNum);
        uint256 i = 0;
        while ((i < 5) && (customers[winnerParent].table < tableNum)) {

            ctstats[t32 | bytes20(winnerParent)].missedDonationRefSum += value;
            customers[winnerParent].stat.missedDonationRefSum += value;

            if (winnerParent == address(0)) {
                winnerParent = rootAddress;
                break;
            }
            winnerParent = customers[winnerParent].parent;
            i++;
        }
        if (i == 5) {
            winnerParent = rootAddress;
        }
        if (i == 0) {
            ctstats[t32 | bytes20(winnerParent)].donationRefSum += value;
            customers[winnerParent].stat.donationRefSum += value;
        }
        payout(winnerParent, value);
        emit DonationReferralRewardSent(winnerParent, value, tableNum);
    }

    function payoutReferralReward(address parent, uint256 value, uint256 tableNum) private {
        bytes32 t32 = bytes32(tableNum);
        uint256 i = 0;
        while ((i < 5) && (customers[parent].table < tableNum)) {

            ctstats[t32 | bytes20(parent)].missedRefSum += value;
            customers[parent].stat.missedRefSum += value;

            if (parent == address(0)) {
                parent = rootAddress;
                break;
            }
            parent = customers[parent].parent;
            i++;
        }
        if (i == 5) {
            parent = rootAddress;
        }

        ctstats[t32 | bytes20(parent)].refSum += value;

        payout(parent, value);
        emit ReferralRewardSent(parent, value, tableNum);
    }

    function getTableAddressesCount(uint256 num) public view returns (uint256) {
        return tableAddresses[num].length;
    }

    function getTablesCount() public view returns (uint256) {
        return tables.length;
    }

    function getTableThreshold(uint256 num) public view returns (uint256) {
        require (num <= tables.length);
        return tables[num].thValue;
    }

    function appendTable(uint256 thValue, uint256 charityShare, uint256 refShare, uint256 donationsCount, uint256 donationShare, uint256 refDonationShare, uint256 maxDonationsCount, bool forceRebuildJUmpValues) public onlyOwner {
        setTableParams(thValue, tables.length, charityShare, refShare, donationsCount, donationShare, refDonationShare, maxDonationsCount, forceRebuildJUmpValues);
        tableAddresses[uint256(tables.length - 1)].push(rootAddress);
    }

    function setTableParams(uint256 thValue, uint256 num, uint256 charityShare, uint256 refShare, uint256 donationsCount, uint256 donationShare, uint256 refDonationShare, uint256 maxDonationsCount, bool forceRebuildJUmpValues) public onlyOwner {
        Table memory t;
        t.thValue = thValue;
        t.charityShare = charityShare;
        t.refShare = refShare;
        t.donationsCount = donationsCount;
        t.donationShare = donationShare;
        t.refDonationShare = refDonationShare;
        t.maxDonationsCount = maxDonationsCount;
        require(num > 0);
        require(num <= tables.length);
        require(t.thValue > 0);
        require(t.charityShare + t.refShare + t.donationsCount * t.donationShare + t.donationsCount * t.refDonationShare == 100);

        // if it's not a first table
        if (num > 1) {
            // it should be greater than prev threshold
            require(t.thValue > tables[num - 1].thValue);
        }
        // if it's not a last table or a new one
        if (num < tables.length - 1) {
            // it should be less that next threshold
            require(t.thValue < tables[num + 1].thValue);
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

    function rebuildJumpValues() public onlyOwner {
        for (uint256 i = 0; i < tables.length; i++) {
            for (uint256 j = 0; j < tables.length; j++) {
                value2table[i][tables[i].jumpValues[j]] = 0;
            }
            delete tables[i].jumpValues;
        }

        // Initial state of Jump Matrix
        uint256 accum = 0;
        for (uint256 j = 1; j < tables.length; j++) {
            accum += tables[j].thValue;
            tables[0].jumpValues[j] = accum;
            // reversed mapping from sum to target table
            value2table[0][accum] = j;
            tables[0].refMatrix[j] = accum * tables[j].refShare / 100;
            tables[0].donationMatrix[j] = accum * tables[j].donationShare / 100;
            tables[0].donationRefMatrix[j] = accum * tables[j].refDonationShare / 100;
            tables[0].charityMatrix[j] = accum * tables[j].charityShare / 100;
        }

        // Rest part of Jump Matrix
        uint256 val;
        for (uint256 i = 1; i < tables.length; i++) {
            for (uint256 j = 1; j < tables.length; j++) {
                if (j < i) {
                    tables[i].jumpValues[j] = 0;
                } else {
                    val = tables[i - 1].jumpValues[j] - tables[i - 1].jumpValues[i];
                    tables[i].jumpValues[j] = val;
                    value2table[i][val] = j;

                    tables[i].refMatrix[j] = val * tables[j].refShare / 100;
                    tables[i].donationMatrix[j] = val * tables[j].donationShare / 100;
                    tables[i].donationRefMatrix[j] = val * tables[j].refDonationShare / 100;
                    tables[i].charityMatrix[j] = val * tables[j].charityShare / 100;
                }
            }
        }

        customers[rootAddress].table = tables.length;
    }

    function random(uint256 max, uint256 salt) public view returns(uint256) {
        return uint256(keccak256(abi.encodePacked(block.timestamp * salt, block.difficulty, msg.sender))) % max;
    }


    function payout(address receiver, uint256 value) private {
        require(receiver != address(0));
        payable(receiver).transfer(value);
    }

    // Admin Functions
    function setnewCharityAddress(address newCharityAddress) public onlyOwner {
        require(newCharityAddress != address(0));
        charityAddress = newCharityAddress;
    }

    function setnewRootAddress(address newRootAddress) public onlyOwner {
        require(newRootAddress != address(0));
        customers[newRootAddress].table = customers[rootAddress].table;
        rootAddress = newRootAddress;
        for (uint256 i = 0; i < tables.length; i++) {
            tableAddresses[i][0] = rootAddress;
        }
    }

    // for any accidentally lost funds
    function withdraw() public onlyOwner {
        payout(owner, address(this).balance);
    }

    // for any tokens lost and might be acccidentally sent to this contract
    function withdrawToken(address _tokenContract, uint256 _amount) public onlyOwner {
        IERC20 tokenContract = IERC20(_tokenContract);
        tokenContract.transfer(msg.sender, _amount);
    }
}