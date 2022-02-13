// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

import {ReentrancyGuard} from '@rari-capital/solmate/src/utils/ReentrancyGuard.sol';

/**
 * /!\ Warning /!\
 * Contrat variable optimized for Fantom network, carefully change the types for other networks
 */
contract FrogLottery is ReentrancyGuard {
    struct EpochInfo {
        uint256 goldfishJackpot;
        uint256 whalesJackpot;
        address[] goldfishWinners;
        uint32 totalWhalesBidders;
        address[] whaleWinners;
        uint32 totalGoldfishBidders;
    }
    /** Packed */
    address public owner;
    // Be sure to check that the underlying blockchain block # will not overflow > uint32
    uint32 public lotteryDeadlineBlock;
    uint32 public blocksPerLottery;
    uint16 public currentEpoch;
    /**********************************/

    uint256 public goldfishJackpot;
    uint256 public whalesJackpot;
    uint256 public minGoldfishBid;
    uint256 public minWhalesBid;
    uint32 public totalGoldfishBidders;
    uint32 public totalWhalesBidders;
    uint16 public withdrawalTax = 1000; // In bps
    bool public enabled = true;

    // Store the total bid per user
    // Reset per user after each lottery
    mapping(address => uint256) public goldFishBids;
    mapping(address => uint256) public whalesBids;

    // Position of entry (1st bidder => position 0, 2nd => position 1...)
    // We'll use these 2 to draw the winners
    mapping(uint32 => address) public goldfishBidderPositions;
    mapping(uint32 => address) public whalesBidderPositions;

    // Lottery winners
    // Starts from 0
    mapping(uint16 => EpochInfo) public epochInfo;

    mapping(address => bool) public blacklistedAddresses;

    address public DAO;
    // @notice Harvestable DAO tax in wei
    uint256 public harvestableTax;

    /// @notice User claimable rewards in wei
    mapping(address => uint256) public userRewards;

    constructor(
        address _DAO,
        uint32 _blocksPerLottery,
        uint256 _minGoldfishBid,
        uint256 _minWhalesBid
    ) {
        owner = msg.sender;
        DAO = _DAO;
        blocksPerLottery = _blocksPerLottery;
        minGoldfishBid = _minGoldfishBid;
        minWhalesBid = _minWhalesBid;
        lotteryDeadlineBlock = uint32(block.number) + _blocksPerLottery;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, 'FrogLottery: onlyOwner');
        _;
    }

    modifier canBid() {
        require(enabled, 'FrogLottery: Disabled');
        require(!blacklistedAddresses[msg.sender], 'FrogLottery: Blacklisted');
        require(lotteryDeadlineBlock > block.number, 'FrogLottery: Lottery over');
        _;
    }

    event Bid(address indexed bidder, uint16 indexedepoch, uint256 totalBidAmount);
    event Jackpot(uint16 indexed epoch, EpochInfo epochInfo);

    /**
     * Public calls
     */

    /// @notice Enter a new bid position
    /// @dev Should have a msg.value tied to it
    /// @param _mode The lottery to enter to, 0 = goldfish, 1 = whales
    function bid(uint8 _mode) external payable canBid {
        // We check if the bid has the minimum requirement
        uint256 prevBid = _mode == 0 ? goldFishBids[msg.sender] : whalesBids[msg.sender];
        // Can not realistically overflow, type(uint32).max = 4,294,967,295
        // FTM = $2 => 4,294,967,295 * 2 = $91,91,230,011 bid
        uint256 newBid = prevBid + msg.value / (10**18);
        require(newBid >= (_mode == 0 ? minGoldfishBid : minWhalesBid), 'FrogLottery: Insufficient amount');

        if (_mode == 0) {
            _processGoldfishBid(prevBid, newBid);
        } else {
            _processWhaleBid(prevBid, newBid);
        }

        emit Bid(msg.sender, currentEpoch, newBid);
    }

    /// @notice Claim pending rewards minus `daoTax`
    function claimRewards() external nonReentrant {
        uint256 amount = userRewards[msg.sender];
        require(amount > 0, 'FrogLottery: Insufficient amount');
        uint256 daoTax = (amount * withdrawalTax) / 10000;
        harvestableTax += daoTax;

        userRewards[msg.sender] = 0;

        _safeTransferETH(msg.sender, amount - daoTax);
    }

    /// @notice Return the goldfish and whale winners of a given epoch
    /// @param _epoch The epoch to look for
    /// @return goldfishWinners
    /// @return whaleWinners
    function getEpochWinners(uint16 _epoch)
        external
        view
        returns (address[] memory goldfishWinners, address[] memory whaleWinners)
    {
        EpochInfo storage epoch = epochInfo[_epoch];
        return (epoch.goldfishWinners, epoch.whaleWinners);
    }

    /**
     * Owner calls
     */

    /// Update the owner
    function changeOwner(address _newOwner) external onlyOwner {
        owner = _newOwner;
    }

    /// Update the DAO
    function setDAO(address _DAO) external onlyOwner {
        DAO = _DAO;
    }

    /// @notice Update the min bid amount for each type of lottery
    /// @param _minGoldfishBid The min goldfish bid (in eth)
    /// @param _minWhalesBid The min whales bid (in eth)
    function updateMinBid(uint32 _minGoldfishBid, uint32 _minWhalesBid) external onlyOwner {
        minGoldfishBid = _minGoldfishBid;
        minWhalesBid = _minWhalesBid;
    }

    /// @notice Update the DAO withdrawal tax
    /// @param _amount The new amount in Bps
    function updateWithdrawalTax(uint16 _amount) external onlyOwner {
        withdrawalTax = _amount;
    }

    /// Toggle [[enabled]]
    function togglePause() public onlyOwner {
        enabled = !enabled;
    }

    /// Send all funds to owner and pause the contract
    function emergencyWithdraw() external onlyOwner {
        _safeTransferETH(owner, address(this).balance);
        togglePause();
    }

    /// @notice Blacklist or whitelist an address
    /// @param _blacklisted The address to deal with
    /// @param _val Blacklisted or not
    function blacklistAddress(address _blacklisted, bool _val) external onlyOwner {
        blacklistedAddresses[_blacklisted] = _val;
    }

    /// The blocks per lottery
    function updateBlockPerLottery(uint32 _blockPerLottery) external onlyOwner {
        blocksPerLottery = _blockPerLottery;
    }

    /// @notice Draw the winners of the lottery, write epoch info,
    /// ditribute rewards and collect taxes and start a new lottery
    /// @param _seed A random number generated off-chain
    function drawWinners(uint256 _seed) external onlyOwner {
        require(enabled, 'FrogLottery: Disabled');
        require(block.number > lotteryDeadlineBlock, 'FrogLottery: Lottery ongoing');

        // We first get the position entry of the winners
        uint32[] memory goldfishWinnerPositions = _computeWinners(
            _computeRandom(_seed, uint256(keccak256('goldfish'))),
            totalGoldfishBidders
        );
        uint32[] memory whaleWinnerPositions = _computeWinners(
            _computeRandom(_seed, uint256(keccak256('whales'))),
            totalWhalesBidders
        );

        // We save epoch info, distribute rewards and reset the for the new epoch
        _writeEpochInfo(goldfishWinnerPositions, whaleWinnerPositions);

        // Send rewards to goldfish and whale winners
        _distributeRewards();
        emit Jackpot(currentEpoch, epochInfo[currentEpoch]);

        // New epoch
        _startNewLottery();
    }

    /// @notice Harvest DAO taxes
    /// @param amount The amount to collect
    function harvestDaoTax(uint256 amount) external onlyOwner {
        harvestableTax -= amount;
        _safeTransferETH(DAO, amount);
    }

    /**
     * Internal calls
     */

    /// @dev Process a goldfish bid by updating the info of the bidder,
    /// the total goldfish bidders and the goldfish jackpot
    /// @param _prevBid The previous bid of the bidder
    function _processGoldfishBid(uint256 _prevBid, uint256 _newBid) internal {
        // We update the bidder's bid
        // We increase the total amount of bidders only if it's a new bidder
        goldFishBids[msg.sender] = _newBid;
        goldfishBidderPositions[totalGoldfishBidders] = msg.sender;
        if (_prevBid == 0) {
            totalGoldfishBidders++;
        }
        goldfishJackpot += _newBid - _prevBid;
    }

    /// @dev Process a whale bid by updating the info of the bidder,
    /// the total whale bidders and the whale jackpot
    /// @param _prevBid The previous bid of the bidder
    function _processWhaleBid(uint256 _prevBid, uint256 _newBid) internal {
        // We update the bidder's bid
        // We increase the total amount of bidders only if it's a new bidder
        whalesBids[msg.sender] = _newBid;
        whalesBidderPositions[totalWhalesBidders] = msg.sender;
        if (_prevBid == 0) {
            totalWhalesBidders++;
        }
        whalesJackpot += _newBid - _prevBid;
    }

    function _writeEpochInfo(uint32[] memory _goldfishWinnerPositions, uint32[] memory _whaleWinnerPositions) internal {
        EpochInfo storage info = epochInfo[currentEpoch];

        // We initialize the arrays
        info.goldfishWinners = new address[](_goldfishWinnerPositions.length);
        info.whaleWinners = new address[](_whaleWinnerPositions.length);

        // We set the current epoch winner addresses
        address[] storage goldfishWinners = info.goldfishWinners;
        address[] storage whaleWinners = info.whaleWinners;

        for (uint256 i = 0; i < _goldfishWinnerPositions.length; i++) {
            address bidder = goldfishBidderPositions[_goldfishWinnerPositions[i]];
            goldfishWinners[i] = bidder;
        }
        for (uint256 i = 0; i < _whaleWinnerPositions.length; i++) {
            address bidder = whalesBidderPositions[_whaleWinnerPositions[i]];
            whaleWinners[i] = bidder;
        }

        // We set other infos
        info.goldfishJackpot = goldfishJackpot;
        info.totalGoldfishBidders = totalGoldfishBidders;
        info.whalesJackpot = whalesJackpot;
        info.totalWhalesBidders = totalWhalesBidders;
    }

    /// @notice Distribute rewards for the current epoch winners
    function _distributeRewards() internal {
        // Send goldfish rewards
        EpochInfo storage _epochInfo = epochInfo[currentEpoch];
        for (uint256 i = 0; i < _epochInfo.goldfishWinners.length; i++) {
            _saveRewards(
                _epochInfo.goldfishWinners[i],
                _getRewardAmount(i, _epochInfo.goldfishWinners.length, _epochInfo.goldfishJackpot)
            );
        }

        // Send whale rewards
        for (uint256 i = 0; i < _epochInfo.whaleWinners.length; i++) {
            _saveRewards(
                _epochInfo.whaleWinners[i],
                _getRewardAmount(i, _epochInfo.whaleWinners.length, _epochInfo.whalesJackpot)
            );
        }
    }

    /// @notice Save rewards of winner
    /// @dev Cast the `_amount` to wei before saving
    /// @param _winner The address of the winner
    /// @param _amount The amount won in wei
    function _saveRewards(address _winner, uint256 _amount) internal {
        userRewards[_winner] += _amount;
    }

    /// @notice Get the reward amount for each winner based on its position,
    /// the total amount of bidders and the jackpot
    /// @param _bidderPosition The position in the draw of the bidder
    /// @param _totalBidders The total amount of bidders
    /// @param _jackpot The jackpot (in ether)
    /// @return jackpot The amount won (in wei)
    function _getRewardAmount(
        uint256 _bidderPosition,
        uint256 _totalBidders,
        uint256 _jackpot
    ) internal pure returns (uint256 jackpot) {
        jackpot = _jackpot;
        // 1 bidder => get everything
        if (_totalBidders == 1) {
            jackpot = jackpot;
        }
        // 2 bidders => 1st 80%, 2nd 20%
        if (_totalBidders == 2) {
            if (_bidderPosition == 0) {
                jackpot = (jackpot * 80) / 100;
            } else {
                jackpot = (jackpot * 20) / 100;
            }
        }
        // 3 bidders => 1st 80% of 100%, 2nd 80% of 20%, 3rd 20% of 20%
        if (_totalBidders == 3) {
            if (_bidderPosition == 0) {
                jackpot = (jackpot * 80) / 100;
            } else if (_bidderPosition == 1) {
                jackpot = (((jackpot * 80) / 100) * 20) / 100;
            } else {
                jackpot = (((jackpot * 20) / 100) * 20) / 100;
            }
        }
        // 4 bidders+ => 1st 80% of 80%, 2nd 20% of 80%, 3rd 80% of 20%, 4th 20% of 20%
        if (_totalBidders >= 4) {
            if (_bidderPosition == 0) {
                jackpot = (((jackpot * 80) / 100) * 80) / 100;
            } else if (_bidderPosition == 1) {
                jackpot = (((jackpot * 20) / 100) * 80) / 100;
            } else if (_bidderPosition == 2) {
                jackpot = (((jackpot * 80) / 100) * 20) / 100;
            } else {
                jackpot = (((jackpot * 20) / 100) * 20) / 100;
            }
        }
        return jackpot;
    }

    /// @notice Start a new lottery
    function _startNewLottery() internal {
        goldfishJackpot = 0;
        totalGoldfishBidders = 0;
        whalesJackpot = 0;
        totalWhalesBidders = 0;
        lotteryDeadlineBlock = uint32(block.number) + blocksPerLottery;
        currentEpoch++;
    }

    /// @notice Get an array of winners
    /// @dev /!\ This can be very gas inneficient on certain scenario to prevent duplicates /!\
    /// O(n**2) complexity
    /// @param _seed The randomness
    /// @param _totalBidders Total number of bidders in the lottery
    /// @return _winners The array of winners
    function _computeWinners(uint256 _seed, uint256 _totalBidders) internal view returns (uint32[] memory _winners) {
        _winners = new uint32[](_totalBidders > 4 ? 4 : _totalBidders);
        for (uint256 i = 0; i < _winners.length; i++) {
            uint256 rng = _computeRandom(_seed, _totalBidders << i);
            _winners[i] = _preventDuplicates(_winners, uint32(rng % _totalBidders), i, _totalBidders);
        }

        return _winners;
    }

    /// @notice Return a value that is not contained in the passed `_winners` array
    /// @dev /!\ This can be very gas inneficient on certain scenario as it may be recursive /!\
    /// O(n) complexity where n <= 16
    /// @param _winners The array to check duplcation
    /// @param _winner The number to check if it exists in `_winners`
    /// @param _index The index of the winner, will ommit check if we compare the `_winner` to this index
    /// @param _totalBidders A boundary for `_winner` to be [0 >= `_winner` < `_totalBidders`]
    /// @return winner The unique number that is not contained in `_winners`
    function _preventDuplicates(
        uint32[] memory _winners,
        uint32 _winner,
        uint256 _index,
        uint256 _totalBidders
    ) internal view returns (uint32 winner) {
        winner = _winner;
        bool isDuplicate;
        for (uint256 i; i < _winners.length; i++) {
            if (_winners[i] == _winner && i != _index) {
                isDuplicate = true;
            }
        }
        if (isDuplicate) {
            // We set another value by blindly incrementing the winner position by 1
            // and resetting to 0 if index overflow
            winner = _preventDuplicates(_winners, _winner + 1 < _totalBidders ? _winner + 1 : 0, _index, _totalBidders);
        }
    }

    /// @notice Compute a random number
    /// @dev /!\ [[_seed]] needs to be at least 100% non-deterministic /!\
    /// @param [[_seed]] Randomness seed
    /// @param [[_additional]] An additional parameter for randomness
    /// @return Random number > 0, < type(uint256).max
    function _computeRandom(uint256 _seed, uint256 _additional) internal view returns (uint256) {
        return uint256(keccak256(abi.encodePacked(block.number, _seed, block.timestamp, _additional)));
    }

    /// author https://github.com/Rari-Capital/solmate/blob/main/src/utils/SafeTransferLib.sol
    function _safeTransferETH(address to, uint256 amount) internal {
        bool callStatus;

        assembly {
            // Transfer the ETH and store if it succeeded or not.
            callStatus := call(gas(), to, amount, 0, 0, 0, 0)
        }

        require(callStatus, 'ETH_TRANSFER_FAILED');
    }
}

// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.0;

/// @notice Gas optimized reentrancy protection for smart contracts.
/// @author Solmate (https://github.com/Rari-Capital/solmate/blob/main/src/utils/ReentrancyGuard.sol)
/// @author Modified from OpenZeppelin (https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/security/ReentrancyGuard.sol)
abstract contract ReentrancyGuard {
    uint256 private reentrancyStatus = 1;

    modifier nonReentrant() {
        require(reentrancyStatus == 1, "REENTRANCY");

        reentrancyStatus = 2;

        _;

        reentrancyStatus = 1;
    }
}