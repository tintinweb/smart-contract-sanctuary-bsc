// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

import "./external/openzeppelin/IERC20Metadata.sol";
import "./external/openzeppelin/ReentrancyGuard.sol";
import "./external/openzeppelin/Ownable.sol";

import "./Config.sol";

/*             .
██████  ██    ██ ██████   █████  ███    ███ ██ ██████       ██████   █████  ███    ███ ███████ 
██   ██  ██  ██  ██   ██ ██   ██ ████  ████ ██ ██   ██     ██       ██   ██ ████  ████ ██      
██████    ████   ██████  ███████ ██ ████ ██ ██ ██   ██     ██   ███ ███████ ██ ████ ██ █████   
██         ██    ██   ██ ██   ██ ██  ██  ██ ██ ██   ██     ██    ██ ██   ██ ██  ██  ██ ██      
██         ██    ██   ██ ██   ██ ██      ██ ██ ██████       ██████  ██   ██ ██      ██ ███████ 
*/
contract PyramidGame is IERC20Metadata, Ownable, ReentrancyGuard, Config {
    // constants
    uint256 constant TWO_EXP_32 = 2**32;
    uint256 constant TWO_EXP_128 = 2**128;
    uint256 constant TWO_EXP_192 = 2**192;
    uint256 constant MAX_INT = 2**256 - 1;
    uint8 constant MAX_LEVEL = 21;

    constructor() {
    }

    // to configure first pyramid
    function setInitialConfig(PyramidConfig calldata config, address firstPharaoh) external onlyOwner {
        require(currentPyramid == 0, "currentPyramid > 0");
        setConfigInternal(config, msg.sender);
        initNextPyramid(firstPharaoh);
    }

    struct PendingBuilds {
        address addr; // bl0x owner
        uint16 bl0xCount; // how many bl0x where minted
        uint80 blockNum; // blocknumber when minted (uint80 sufficient for chains we want)
        uint256 collapseMinHash; // one of the hashes must be below this value for the pyramid to collapse
    }

    struct Investment {
        uint256 account; // can save up to 22 levels of investments
        uint256 pyramid; // which pyramid was saved
    }

    mapping(uint256 => PendingBuilds) public bloxIdToPendingBuilds;
    mapping(uint256 => PyramidConfig) public pyramidConfigs;
    mapping(uint256 => uint256) public pyramidStartBl0x;
    mapping(address => Investment) public investedBlox;

    uint256 public currentPyramid;
    uint256 public currentBl0x;
    uint256 public currentProbX64;
    uint256 public lastProcessedBl0x;
    uint256 public lastMintTime;

    function currentLevel() external view returns (uint256) {
        return calculateLevelFromBl0x(currentBl0x);
    }

    function addAccounting(
        uint256 whatLevel,
        uint256 account,
        uint256 howManyToAdd
    ) internal pure returns (uint256) {
        require(whatLevel <= MAX_LEVEL, ">max level");
        require(howManyToAdd <= 2**whatLevel, ">level allowed");

        uint256 shiftSoMany = getLevelShift(whatLevel);
        require(
            ((account >> shiftSoMany) % (2**whatLevel)) + howManyToAdd <=
                (2**whatLevel),
            "level overflow"
        );
        return account + (howManyToAdd << shiftSoMany);
    }

    function addAccountingMultiLevel(
        uint256 firstBl0x,
        uint256 lastBl0x,
        uint256 level,
        uint256 account
    ) internal pure returns (uint256 finalAccount) {
        while (lastBl0x >= firstBl0x) {
            uint256 nextLevelFirstBl0xId = getNextLevelFirstBl0xId(level);
            if (lastBl0x >= nextLevelFirstBl0xId) {
                account = addAccounting(
                    level,
                    account,
                    nextLevelFirstBl0xId - firstBl0x
                );
                level++;
                firstBl0x = nextLevelFirstBl0xId;
            } else {
                account = addAccounting(
                    level,
                    account,
                    lastBl0x - firstBl0x + 1
                );
                break;
            }
        }
        return account;
    }

    function getBl0xCountForLevel(uint256 level)
        internal
        pure
        returns (uint256)
    {
        return level == 0 ? 1 : 1 << level;
    }

    function getNextLevelFirstBl0xId(uint256 level)
        internal
        pure
        returns (uint256)
    {
        return (2**(level + 1) - 1);
    }

    function calculateLevelFromBl0x(uint bl0x)
        internal 
        pure 
        returns (uint256 level)
    {
        bl0x++;
        bl0x = bl0x >> 1;
        while (bl0x > 0) {
            level++;
            bl0x = bl0x >> 1;
        }
    }

    function getBonusLevelBl0x(address addr)
        internal
        view
        returns (uint256 level, uint256 bl0x)
    {
        uint256 addressPyramid = investedBlox[addr].pyramid;
        if (addressPyramid != currentPyramid) {
            bl0x = getBloxCountForOldPyramid(addressPyramid);
        } else {
            bl0x = currentBl0x;
        }
        level = calculateLevelFromBl0x(bl0x);
    }

    // get list of all pending builds
    function getPendingBuilds()
        external
        view
        returns (
            uint256[] memory indexes,
            uint16[] memory counts,
            uint80[] memory blocks,
            address[] memory owners,
            uint256[] memory collapseMinHashes
        )
    {
        uint256 bl0x = lastProcessedBl0x + 1;
        uint256 firstBl0x;
        uint256 lastBl0x = pyramidStartBl0x[currentPyramid] + currentBl0x;

        PendingBuilds memory pendingBuy;
        uint256 count;

        while (bl0x <= lastBl0x) {
            pendingBuy = bloxIdToPendingBuilds[bl0x];
            // if not too late
            if (block.number - pendingBuy.blockNum <= 255) {
                if (count == 0) {
                    firstBl0x = bl0x;
                }
                count++;
            }
            bl0x += pendingBuy.bl0xCount;
        }

        indexes = new uint256[](count);
        counts = new uint16[](count);
        blocks = new uint80[](count);
        owners = new address[](count);
        collapseMinHashes = new uint256[](count);

        bl0x = firstBl0x;

        for (uint256 i = 0; i < count; i++) {
            pendingBuy = bloxIdToPendingBuilds[bl0x];
            indexes[i] = bl0x;
            counts[i] = pendingBuy.bl0xCount;
            blocks[i] = pendingBuy.blockNum;
            owners[i] = pendingBuy.addr;
            collapseMinHashes[i] = pendingBuy.collapseMinHash;
            bl0x += pendingBuy.bl0xCount;
        }
    }

    // returns which address owns a certain block
    // only used from UI
    function getBl0xOwner(uint256 pyramid, uint256 bl0x)
        external
        view
        returns (address, uint256)
    {
        require(pyramid > 0, "pyramid==0");
        require(pyramid <= currentPyramid, ">currentPyramid");

        require(
            pyramid < currentPyramid || bl0x <= currentBl0x,
            ">currentBl0x"
        );
        require(
            pyramid == currentPyramid ||
                bl0x <= getBloxCountForOldPyramid(pyramid),
            ">lastBl0xNumber"
        );

        uint startBl0x = pyramidStartBl0x[pyramid];

        // search full pyramid - this should be possible for reasonable build sizes
        // its external view anyway
        for (
            uint256 index = startBl0x + bl0x;
            index >= startBl0x;
            index--
        ) {
            if (bloxIdToPendingBuilds[index].bl0xCount > 0) {
                return (
                    bloxIdToPendingBuilds[index].addr,
                    bloxIdToPendingBuilds[index].blockNum
                );
            }
        }

        return (address(0), 0);
    }

    // Gets bonus which is accumulated until now in current pyramid
    function getCurrentBonus(address addr) external view returns (uint256) {

        if (investedBlox[addr].pyramid != currentPyramid) {
            return 0;
        }
        uint256 bonusX64 = calculateBonus(
            investedBlox[addr].account,
            currentPyramid,
            calculateLevelFromBl0x(currentBl0x),
            currentBl0x
        );
        return getBonusAmount(bonusX64);
    }

    function getLevelShift(uint256 level) internal pure returns (uint256) {
        return (level * (level + 1)) / 2;
    }

    function getLevelAmount(uint256 account, uint256 level)
        internal
        pure
        returns (uint256)
    {
        uint256 shift = getLevelShift(level);
        return (account >> shift) % (1 << (level + 1));
    }

    function calculateBonus(
        uint256 account,
        uint256 pyramid,
        uint256 currentLvl,
        uint256 currentBlx
    ) internal view returns (uint256 bonusX64) {
        PyramidConfig storage config = pyramidConfigs[pyramid];

        uint256 payoutFactorX64 = TWO_EXP_64 -
            config.payoutFactorX64 -
            config.ownerFactorX64;

        uint256 nextFirstBlock = getNextLevelFirstBl0xId(currentLvl);
        uint256 lastCompleteLevel = currentBlx == nextFirstBlock - 1
            ? currentLvl
            : currentLvl - 1;
        uint256 lastLineProgress = currentBlx == nextFirstBlock - 1
            ? 0
            : currentBlx + 2 - ((2**currentLvl));
        uint256 lastLineRatioX64 = lastLineProgress == 0
            ? 0
            : (lastLineProgress * TWO_EXP_64) /
                getBl0xCountForLevel(currentLvl);

        // for each level requested how much was invested, calculate payout accordingly
        for (uint256 i = 0; i <= MAX_LEVEL; i++) {
            if (i > lastCompleteLevel) {
                break;
            }

            uint256 soManyForThisLevel = getLevelAmount(account, i);
            bonusX64 +=
                (((lastCompleteLevel - i) * TWO_EXP_64 + lastLineRatioX64) *
                    soManyForThisLevel *
                    payoutFactorX64) /
                TWO_EXP_64;
        }
    }

    function getBonusAmount(uint256 bonusX64) internal pure returns (uint256) {
        return (bonusX64 * (10**decimals())) / TWO_EXP_64;
    }

    function convertAmount(
        uint256 amount,
        uint256 oldPyramid,
        uint256 newPyramid
    ) internal view returns (uint256) {
        if (oldPyramid == 0 || oldPyramid == newPyramid) {
            return amount;
        } else {
            uint256 oldBl0xPrice = pyramidConfigs[oldPyramid].bl0xPrice;
            uint256 newBl0xPrice = pyramidConfigs[newPyramid].bl0xPrice;
            if (oldBl0xPrice == newBl0xPrice) {
                return amount;
            } else {
                return (amount * oldBl0xPrice) / newBl0xPrice;
            }
        }
    }

    // payouts to current address
    // IMPORTANT: don't call for current pyramid before finished
    function doPayout(address addr) internal {
        uint256 account = investedBlox[addr].account;
        if (account == 0) {
            return;
        }

        uint256 pyramid = investedBlox[addr].pyramid;
        (uint256 level, uint256 bl0x) = getBonusLevelBl0x(addr);

        uint256 bonusX64 = calculateBonus(account, pyramid, level, bl0x);

        // clear account
        investedBlox[addr].account = 0;

        // nothing to payout so skip payout part
        if (bonusX64 == 0) {
            return;
        }

        uint256 pyramidBonusAmount = getBonusAmount(bonusX64);

        // emit event
        emit Payout(addr, pyramid, pyramidBonusAmount);

        // transfer bonus amount converted to current pyramid bl0x price
        uint256 bonusAmount = convertAmount(
            pyramidBonusAmount,
            pyramid,
            currentPyramid
        );

        // transfer from blox in contract to addr
        _transfer(address(this), addr, bonusAmount);
    }

    // method to convert back to ETH - amount with decimals
    function cashout(uint256 amount) external nonReentrant {
        _burn(msg.sender, amount);

        uint256 value = (amount * pyramidConfigs[currentPyramid].bl0xPrice) /
            (10**decimals());

        (bool sent, ) = payable(msg.sender).call{value: value}("");
        require(sent, "!sent");

        emit Withdraw(msg.sender, value);
    }

    // fallback recieve function - used for simple wallet playing
    receive() external payable {
        mint();
    }

    // mint function to buy blocks
    function mint() public payable nonReentrant { 

         // calculate how much can be added
        uint256 bl0xPrice = pyramidConfigs[currentPyramid].bl0xPrice;
        uint256 allBl0xCount = msg.value / bl0xPrice;
        require(allBl0xCount > 0 && allBl0xCount < type(uint16).max, "!bl0xCount");

        uint16 bl0xCount = uint16(allBl0xCount);

        uint256 bl0xAmount = bl0xCount * (10**decimals());
        _mint(address(this), bl0xAmount);

        addInternal(bl0xCount);

        // return excess eth
        uint price = bl0xCount * bl0xPrice;
        if (msg.value > price) {
            (bool sent, ) = msg.sender.call{value: msg.value - price}("");
            require(sent, "!sent");
        }        
        
        // emit event
        emit Deposit(msg.sender, price);
    }

    // function to add bl0xCount blocks from users blocks balance
    function add(uint16 bl0xCount) public {

        require(bl0xCount > 0, "bl0xCount=0");

        uint256 bl0xAmount = bl0xCount * (10**decimals());
        transfer(address(this), bl0xAmount);

        addInternal(bl0xCount);
    }

    // function to add bl0xCount blocks from users blocks balance
    // can be called directly or implicit via token sending
    function addInternal(uint16 bl0xCount) internal {

        uint256 pyramid = currentPyramid;
        require(pyramid > 0, "pyramid=0");

        uint256 bl0x = currentBl0x + 1;
        uint256 level = calculateLevelFromBl0x(bl0x - 1);
        uint256 lastBl0x = bl0x + bl0xCount - 1;

        (uint256 probX64, uint256 nextProbX64) = getCollapseProbabilityX64Internal(
                bl0x - 1,
                currentProbX64,
                bl0xCount,
                0,
                true
            );

        currentProbX64 = nextProbX64;

        uint256 collapseMinHash = calculateMinHashForProbability(
            probX64,
            pyramidConfigs[pyramid].randomBlocks
        );


        // advance lastProcessedBl0x for expired blocks
        handleCollapse(true);

        bloxIdToPendingBuilds[
            pyramidStartBl0x[pyramid] + bl0x
        ] = PendingBuilds(msg.sender, bl0xCount, uint80(block.number), collapseMinHash);

        // make entries for bl0x
        uint256 currentInvestment = investedBlox[msg.sender].account;

        // check if old bl0x still there
        if (currentInvestment > 0 && investedBlox[msg.sender].pyramid != pyramid) {
            doPayout(msg.sender);
            currentInvestment = 0;
        }

        currentInvestment = addAccountingMultiLevel(
            bl0x,
            lastBl0x,
            level,
            currentInvestment
        );
        investedBlox[msg.sender] = Investment(
            currentInvestment,
            pyramid
        );

        currentBl0x = lastBl0x;

        lastMintTime = block.timestamp;

        emit Buyin(msg.sender, pyramid, bl0x, bl0xCount);
    }

    function collapse(
        address collapser
    ) private {

        uint256 pyramid = currentPyramid;
        uint256 bl0x = currentBl0x;
        uint256 level = calculateLevelFromBl0x(bl0x);

        // send winnerCut to collapser
        uint256 winnerCut = getCollapseBonusWithDigits(pyramid);
        _transfer(address(this), collapser, winnerCut);

        // send owner cut + not assigned bl0x to owner
        // "virtual first Bl0x" is not touched
        uint256 ownerCut = getOwnerBonusWithDigits(pyramid);
        // this is the way to calculate the not assigned blocks
        uint256 bonusX64 = calculateBonus(
            1,
            pyramid,
            level,
            bl0x
        );
        uint256 noAssigned = getBonusAmount(bonusX64);
        _transfer(address(this), owner(), ownerCut + noAssigned);

        emit Collapse(pyramid, collapser, bl0x, winnerCut);

        // payout for collapser
        doPayout(collapser);

        initNextPyramid(collapser);
    }

    function initNextPyramid(address collapser) internal {
        // set last processed block to start of new pyramid
        if (currentPyramid > 0) {
            lastProcessedBl0x = pyramidStartBl0x[currentPyramid] + currentBl0x + 1;
        }

        // set collapser data
        bloxIdToPendingBuilds[lastProcessedBl0x] = PendingBuilds(
            collapser,
            1,
            uint80(block.number),
            0
        );

        // reseting pyramid values
        currentBl0x = 0;
        lastMintTime = block.timestamp;
        currentPyramid++;
        currentProbX64 = 0;

        // if next level not yet configured - take same config
        if (pyramidConfigs[currentPyramid].bl0xPrice == 0) {
            pyramidConfigs[currentPyramid] = pyramidConfigs[currentPyramid - 1];
        }

        // set start blox of new pyramid
        pyramidStartBl0x[currentPyramid] = lastProcessedBl0x;

        // adjust block amount for collapser to new pyramid
        _verifyBl0xPrice(collapser);

        // add investment for collapser
        investedBlox[collapser] = Investment(1, currentPyramid);

        emit Init(currentPyramid, collapser);
    }

    function getBloxCountForOldPyramid(uint pyramid) internal view returns (uint) {
        return pyramidStartBl0x[pyramid + 1] - pyramidStartBl0x[pyramid] - 1;
    }

    function getCollapseBonusWithDigits(uint pyramid) public view returns (uint256) {
        uint bloxCount = (pyramid < currentPyramid) ? getBloxCountForOldPyramid(pyramid) : currentBl0x;
        return
            (bloxCount *
                pyramidConfigs[currentPyramid].payoutFactorX64 *
                (10**decimals())) / TWO_EXP_64;
    }

    function getOwnerBonusWithDigits(uint pyramid) public view returns (uint256) {
        uint bloxCount = (pyramid < currentPyramid) ? getBloxCountForOldPyramid(pyramid) : currentBl0x;
        return
            (bloxCount *
                pyramidConfigs[currentPyramid].ownerFactorX64 *
                (10**decimals())) / TWO_EXP_64;
    }

    // checks if pyramid is collapsed in current state
    // if onlyAdvance is set - it only advances until pending builds
    function handleCollapse(bool onlyAdvance) public returns (bool, address) {
        // load index from storage
        uint256 bl0x = lastProcessedBl0x + 1;
        uint256 pyramid = currentPyramid;
        uint256 lastCurrentBl0x = pyramidStartBl0x[pyramid] + currentBl0x;
        uint8 randomBlocks = pyramidConfigs[pyramid].randomBlocks;

        PendingBuilds storage pendingBuy;
        while (bl0x <= lastCurrentBl0x) {
            pendingBuy = bloxIdToPendingBuilds[bl0x];
            // when not to early
            if (
                (pendingBuy.blockNum + randomBlocks <= block.number) ||
                (pendingBuy.collapseMinHash == MAX_INT)
            ) {
                // and not to late
                if (
                    (block.number - pendingBuy.blockNum <= 255) ||
                    (pendingBuy.collapseMinHash == MAX_INT)
                ) {
                    if (onlyAdvance) {
                        // stop here - reached pending builds
                        break;
                    }
                    if (
                        oneBlockHashBelow(
                            pendingBuy.blockNum,
                            pendingBuy.collapseMinHash,
                            bl0x,
                            randomBlocks
                        )
                    ) {
                        // collapse the whole pyramid - also not yet processed block
                        collapse(pendingBuy.addr);
                        return (true, pendingBuy.addr);
                    }
                }
                bl0x += pendingBuy.bl0xCount;
            } else {
                break;
            }
        }

        lastProcessedBl0x = bl0x - 1;
        return (false, address(0));
    }

    function getMultiCollapseProbabilityX64(uint256 max)
        external
        view
        returns (uint64[] memory)
    {
        uint64[] memory result = new uint64[](max);
        uint256 cp = currentProbX64;
        uint256 accumProbX64;
        uint256 prob;
        for (uint256 i = 0; i < max; i++) {
            (prob, cp) = getCollapseProbabilityX64Internal(
                currentBl0x,
                cp,
                1,
                0,
                i == 0
            );
            accumProbX64 =
                TWO_EXP_64 -
                ((TWO_EXP_64 - prob) * (TWO_EXP_64 - accumProbX64)) /
                TWO_EXP_64;
            result[i] = uint64(
                accumProbX64 == TWO_EXP_64 ? TWO_EXP_64 - 1 : accumProbX64
            );
        }
        return result;
    }

    /**
     * Calculates probability of collapsing when minting next n blocks
     */
    function getCollapseProbabilityX64(uint256 nBlocks, uint256 timeDeltaSecs)
        external
        view
        returns (uint256 prob)
    {
        (prob, ) = getCollapseProbabilityX64Internal(
            currentBl0x,
            currentProbX64,
            nBlocks,
            timeDeltaSecs,
            true
        );
    }

    /**
     * Calculates probability of collapsing when minting next n blocks
     */
    function getCollapseProbabilityX64Internal(
        uint256 cb,
        uint256 cp,
        uint256 nBlocks,
        uint256 timeDeltaSecs,
        bool useTime
    ) internal view returns (uint256 prob, uint256 nextProb) {
        require(nBlocks > 0, "nBlocks==0");

        PyramidConfig storage config = pyramidConfigs[currentPyramid];

        uint256 maxBlockIndex = 2**(MAX_LEVEL + 1) - 2;

        require(nBlocks <= maxBlockIndex - cb, ">MAX_LEVEL");

        uint256 winAmountX64 = (
            cb >= config.probStartBl0x ? cb : config.probStartBl0x
        ) * config.payoutFactorX64;

        // fair probability for playing game considering payout
        uint256 baseProbX64 = TWO_EXP_128 / winAmountX64;
        if (cb < config.probStartBl0x) {
            baseProbX64 = (baseProbX64 * cb) / config.probStartBl0x;
        }

        // growth and shrink factor depending on base probablity
        uint256 growthX64 = (config.probGrowthPerSecondX64 * baseProbX64) /
            TWO_EXP_64;

        if (useTime) {
            cp =
                cp +
                (block.timestamp - lastMintTime + timeDeltaSecs) *
                growthX64;
            cp = cp > TWO_EXP_64 ? TWO_EXP_64 : cp;
        }

        uint256 nonCollapseProd = TWO_EXP_64;
        uint256 i;
        for (; i < nBlocks; i++) {
            nonCollapseProd = (nonCollapseProd * (TWO_EXP_64 - cp)) / TWO_EXP_64;
            cp = (cp * config.probShrinkPerMintX64) / TWO_EXP_64;
        }
        prob = TWO_EXP_64 - nonCollapseProd;
        nextProb = cp;

        // last block - 100% collapse
        if (nBlocks == maxBlockIndex - cb) {
            prob = TWO_EXP_64;
            nextProb = TWO_EXP_64;
        }
    }

    function calculateFactorX64(
        uint256 baseFactorX64,
        uint256 minValueX64,
        uint256 maxValueX64
    ) private pure returns (uint256) {
        if (minValueX64 < maxValueX64) {
            return
                minValueX64 +
                (baseFactorX64 * (maxValueX64 - minValueX64)) /
                TWO_EXP_64;
        } else {
            return
                minValueX64 -
                (baseFactorX64 * (minValueX64 - maxValueX64)) /
                TWO_EXP_64;
        }
    }

    /**
     * _probX64 desired probability (TWO_EXP_64 -> 100% / 0 -> 0%)
     * _numBlocks must be a power of 2 (1,2,4,8,..,128)
     */
    function calculateMinHashForProbability(uint256 _probX64, uint8 _numBlocks)
        internal
        pure
        returns (uint256)
    {
        require(_probX64 <= TWO_EXP_64, ">TWO_EXP_64"); // max 100%

        if (_probX64 == TWO_EXP_64) {
            return MAX_INT;
        }

        uint256 _currentProb = TWO_EXP_64 - _probX64;
        _numBlocks = _numBlocks >> 1;
        while (_numBlocks > 0) {
            _currentProb = sqrt(_currentProb) * TWO_EXP_32;
            _numBlocks = _numBlocks >> 1;
        }
        _currentProb = TWO_EXP_64 - _currentProb;
        return _currentProb * TWO_EXP_192;
    }

    /**
     * Checks last _numBlocks beginning from a _startBlock
     * _value should be calculated (beforehand) as uint.max * (1 - (1 - desiredProbability) ^ (1 / _numBlocks))
     * If blocks are not manipulated the probability than at least one blockhash < _value is the same as desiredProbability
     * If one more blocks are manipulated probability slightly changes but with big enough _numBlocks its in a reasonble range
     * @return if there was (at least) one block hash below the given value
     */
    function oneBlockHashBelow(
        uint256 _startBlock,
        uint256 _value,
        uint256 _seed,
        uint8 _numBlocks
    ) public view returns (bool) {
        // if its 100% probable return true without checking
        if (_value == MAX_INT) {
            return true;
        }

        require(_startBlock + _numBlocks <= block.number, "too early");

        uint256 _delta = block.number - _startBlock;
        require(_delta <= 255, "too late");

        uint256 _bn;

        for (_bn = _startBlock; _bn < _startBlock + _numBlocks; _bn++) {
            uint256 hash = uint256(
                keccak256(abi.encodePacked(blockhash(_bn), _seed))
            );
            if (hash < _value) {
                return true;
            }
        }
        return false;
    }

    function sqrt(uint256 x) internal pure returns (uint256 result) {
        if (x == 0) {
            return 0;
        }

        // Calculate the square root of the perfect square of a power of two that is the closest to x.
        uint256 xAux = x;
        result = 1;
        if (xAux >= 0x100000000000000000000000000000000) {
            xAux >>= 128;
            result <<= 64;
        }
        if (xAux >= 0x10000000000000000) {
            xAux >>= 64;
            result <<= 32;
        }
        if (xAux >= 0x100000000) {
            xAux >>= 32;
            result <<= 16;
        }
        if (xAux >= 0x10000) {
            xAux >>= 16;
            result <<= 8;
        }
        if (xAux >= 0x100) {
            xAux >>= 8;
            result <<= 4;
        }
        if (xAux >= 0x10) {
            xAux >>= 4;
            result <<= 2;
        }
        if (xAux >= 0x8) {
            result <<= 1;
        }

        // The operations can never overflow because the result is max 2^127 when it enters this block.
        unchecked {
            result = (result + x / result) >> 1;
            result = (result + x / result) >> 1;
            result = (result + x / result) >> 1;
            result = (result + x / result) >> 1;
            result = (result + x / result) >> 1;
            result = (result + x / result) >> 1;
            result = (result + x / result) >> 1; // Seven iterations should be enough
            uint256 roundedDownResult = x / result;
            return result >= roundedDownResult ? roundedDownResult : result;
        }
    }

    /**
     * @dev Sets pyramid config for next game
     */
    function setConfig(PyramidConfig memory config) external onlyOwner {
        setConfigInternal(config, msg.sender);
    }

    function setConfigInternal(PyramidConfig memory config, address sender) internal {
        validateConfig(config);
        pyramidConfigs[currentPyramid + 1] = config;
        emit ChangeConfig(currentPyramid + 1, sender);
    }

    /**
     * @dev Emitted when a user deposit ETH for bl0x - amount in ETH
     */
    event Deposit(address indexed owner, uint256 amount);

    /**
     * @dev Emitted when a user withdraws bl0x for ETH - amount in ETH
     */
    event Withdraw(address indexed owner, uint256 amount);

    /**
     * @dev Emitted when a user buys blocks in the pyramid
     */
    event Buyin(
        address indexed owner,
        uint256 indexed pyramid,
        uint256 index,
        uint16 count
    );

    /**
     * @dev Emitted when a pyramid blocks are payed out
     */
    event Payout(
        address indexed owner,
        uint256 indexed pyramid,
        uint256 bonusAmount
    );

    /**
     * @dev Emitted when the first blox of a new piramid is built
     */
    event Init(uint256 indexed pyramid, address indexed pharaoh);

    /**
     * @dev Emitted when a piramid collapses
     */
    event Collapse(
        uint256 indexed pyramid,
        address indexed collapser,
        uint256 lastBl0xNumber,
        uint256 winAmount
    );

    /**
     * @dev Emitted when the config for the next pyramid is changed
     */
    event ChangeConfig(uint256 indexed pyramid, address indexed changer);

    // ERC20 custom implementation
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    function name() public pure override returns (string memory) {
        return "Pyramid Blocks";
    }

    function symbol() public pure override returns (string memory) {
        return "BL0x";
    }

    function decimals() public pure override returns (uint8) {
        return 18;
    }

    // calculates total supply based on ETH balance of contract
    function totalSupply() public view override returns (uint256) {
        return address(this).balance * (10**decimals()) / pyramidConfigs[currentPyramid].bl0xPrice;
    }

    function balanceOf(address addr) public view override returns (uint256) {
        uint256 balance = _balances[addr];
        uint256 addrPyramid = investedBlox[addr].pyramid;
        if (balance > 0) {
            balance = convertAmount(balance, addrPyramid, currentPyramid);
        }

        // bonus only valid when pyramid collapsed
        if (addrPyramid != currentPyramid) {
            uint256 account = investedBlox[addr].account;
            if (account > 0) {
                (uint256 level, uint256 bl0x) = getBonusLevelBl0x(addr);
                uint256 bonusX64 = calculateBonus(
                    account,
                    addrPyramid,
                    level,
                    bl0x
                );
                uint256 bonusAmount = getBonusAmount(bonusX64);
                if (bonusAmount > 0) {
                    balance += convertAmount(
                        bonusAmount,
                        addrPyramid,
                        currentPyramid
                    );
                }
            }
        }
        return balance;
    }

    function transfer(address to, uint256 amount)
        public
        override
        returns (bool)
    {
        address owner = msg.sender;
        _transfer(owner, to, amount);
        return true;
    }

    function allowance(address owner, address spender)
        public
        view
        override
        returns (uint256)
    {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount)
        public
        override
        returns (bool)
    {
        address owner = msg.sender;
        _approve(owner, spender, amount);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public override returns (bool) {
        address spender = msg.sender;
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        // check if bl0x prices are up to date - and payout if needed
        _verifyBl0xPrice(from);
        _verifyBl0xPrice(to);

        uint256 fromBalance = _balances[from];

        require(
            fromBalance >= amount,
            "ERC20: transfer amount exceeds balance"
        );
        unchecked {
            _balances[from] = fromBalance - amount;
        }
        _balances[to] += amount;

        emit Transfer(from, to, amount);
    }

    // guarantees that account is ready to recieve tokens of CURRENT price level
    function _verifyBl0xPrice(address addr) internal {
        Investment storage invested = investedBlox[addr];
        uint256 addrPyramid = invested.pyramid;
        uint256 pyramid = currentPyramid;
        if (addrPyramid != pyramid) {
            uint256 balance = _balances[addr];
            if (invested.account > 0) {
                doPayout(addr);
            } else if (balance > 0) {
                uint256 storedBl0xPrice = pyramidConfigs[addrPyramid].bl0xPrice;
                uint256 currentBl0xPrice = pyramidConfigs[pyramid].bl0xPrice;
                // if price changed - change amount
                if (storedBl0xPrice != currentBl0xPrice) {
                    // convert to new price
                    _balances[addr] = (balance * storedBl0xPrice) / currentBl0xPrice;
                    invested.pyramid = pyramid;
                }
            } else {
                invested.pyramid = pyramid;
            }
        }
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _verifyBl0xPrice(account);

        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _verifyBl0xPrice(account);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }

        emit Transfer(account, address(0), amount);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(
                currentAllowance >= amount,
                "ERC20: insufficient allowance"
            );
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity 0.8.4;

import "./IERC20.sol";

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

pragma solidity 0.8.4;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity 0.8.4;

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(msg.sender);
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == msg.sender, "Ownable: caller is not the owner");
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

// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

abstract contract Config {

    uint256 constant TWO_EXP_64 = 2**64;

    struct PyramidConfig {

        // payed out to collapser 
        uint64 payoutFactorX64;

        // payed out to owner/dao
        uint64 ownerFactorX64;

        // growth of probability per second (multiplied with base probability)
        uint64 probGrowthPerSecondX64;

        // shrink multiplier per mint
        uint64 probShrinkPerMintX64;

        // price in wei
        uint128 bl0xPrice;

        // block where max base probability is reached
        uint32 probStartBl0x;
        
        // random blocks used for probability calc
        uint8 randomBlocks;

    }

    function validateConfig(PyramidConfig memory config) internal pure {
        require(config.payoutFactorX64 + config.ownerFactorX64 <= TWO_EXP_64, "factorSum>E64");
        require(config.bl0xPrice > 0, "bl0xPrice==0");
        require(config.probStartBl0x > 0, "probStartBl0x==0");
        require(config.randomBlocks == 1 || config.randomBlocks == 2 || config.randomBlocks == 4 || config.randomBlocks == 8 || config.randomBlocks == 16 || config.randomBlocks == 32 || config.randomBlocks == 64 || config.randomBlocks == 128, "randomBlocks?");
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)

pragma solidity 0.8.4;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}