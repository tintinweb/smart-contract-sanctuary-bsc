/**
 *Submitted for verification at BscScan.com on 2022-12-22
*/

pragma solidity ^0.8.9;
//   ___                           _
//  / __| __ _  _ __   _ __  __ _ (_) __ _  _ _
// | (__ / _` || '  \ | '_ \/ _` || |/ _` || ' \
//  \___|\__,_||_|_|_|| .__/\__,_||_|\__, ||_||_|
//                    |_|            |___/
//  ___            _
// | __| __ _  __ | |_  ___  _ _  _  _
// | _| / _` |/ _||  _|/ _ \| '_|| || |
// |_|  \__,_|\__| \__|\___/|_|   \_, |
//                                |__/
interface AggregatorV3Interface {
    function decimals() external view returns (uint8);

    function description() external view returns (string memory);

    function version() external view returns (uint256);

    function getRoundData(uint80 _roundId)
        external
        view
        returns (
        uint80 roundId,
        int256 answer,
        uint256 startedAt,
        uint256 updatedAt,
        uint80 answeredInRound
        );

    function latestRoundData()
        external
        view
        returns (
        uint80 roundId,
        int256 answer,
        uint256 startedAt,
        uint256 updatedAt,
        uint80 answeredInRound
        );
}

contract CampaignFactory {
    address payable public owner;
    mapping(string => address) public campaigns;

    constructor() {
        owner = payable(msg.sender);
    }

    event campaignCreated(address campaignContractAddress);

    function createCampaign(
        uint256 _chainId,
        string memory _campaignId,
        address _prizeAddress,
        uint256 _prizeAmount,
        uint256 _maxEntries,
        uint256 _startTimestamp,
        uint256 _endTimestamp,
        bytes32 _sealedSeed,
        bytes32 r,
        bytes32 s,
        uint8 v
    ) public {
        require(
            campaigns[_campaignId] == address(0),
            "Campaign with this id already exists"
        );

        bytes32 message = hashMessage(
            msg.sender,
            _chainId,
            _campaignId,
            _prizeAddress,
            _prizeAmount,
            _maxEntries,
            _startTimestamp,
            _endTimestamp,
            _sealedSeed
        );

        require(
            ecrecover(message, v, r, s) == owner,
            "You need signatures from the owner to create a campaign"
        );

        Campaign c = new Campaign(
            owner,
            msg.sender,
            _campaignId,
            _prizeAddress,
            _prizeAmount,
            _maxEntries,
            _startTimestamp,
            _endTimestamp,
            _sealedSeed
        );

        campaigns[_campaignId] = address(c);
        emit campaignCreated(address(c));
    }

    function hashMessage(
        address _campaignOwner,
        uint256 _chainId,
        string memory _campaignId,
        address _prizeAddress,
        uint256 _prizeAmount,
        uint256 _maxEntries,
        uint256 _startTimestamp,
        uint256 _endTimestamp,
        bytes32 _sealedSeed
    ) public view returns (bytes32) {
        bytes memory pack = abi.encodePacked(
            this,
            _campaignOwner,
            _chainId,
            _campaignId,
            _prizeAddress,
            _prizeAmount,
            _maxEntries,
            _startTimestamp,
            _endTimestamp,
            _sealedSeed
        );
        return keccak256(pack);
    }

    function getCampaignContractAddress(string memory _campaignId)
        public
        view
        returns (address)
    {
        return campaigns[_campaignId];
    }
}

contract Campaign {
    address payable owner;
    address public token;

    address public campaignOwner;
    address public prizeAddress;

    string public campaignId;

    uint256 public prizeAmount;
    uint256 public maxEntries;

    uint256 public startTimestamp;
    uint256 public endTimestamp;

    bytes32 sealedSeed;

    uint256 public revealBlockNumber;
    bytes32 public revealedSeed;

    mapping(uint256 => address) public entries;
    mapping(address => uint256) public entryAddress;

    uint256 totalEntries;

    address dataFeedAddress;

    uint256 fee;

    event CampaignCreated(
        address campaignAddress,
        address campaignOwner,
        string campaignId,
        address prizeAddress,
        uint256 prizeAmount,
        uint256 maxEntries,
        uint256 startTimestamp,
        uint256 endTimestamp
    );

    constructor(
        address payable _owner,
        address _campaignOwner,
        string memory _campaignId,
        address _prizeAddress,
        uint256 _prizeAmount,
        uint256 _maxEntries,
        uint256 _startTimestamp,
        uint256 _endTimestamp,
        bytes32 _sealedSeed
    ) {
        owner = _owner;
        campaignOwner = _campaignOwner;
        campaignId = _campaignId;
        prizeAddress = _prizeAddress;
        prizeAmount = _prizeAmount;
        maxEntries = _maxEntries;
        startTimestamp = _startTimestamp;
        endTimestamp = _endTimestamp;
        sealedSeed = _sealedSeed;

        fee = getUSDInWEI(); //1 USD
    }

    function getDetail()
        public
        view
        returns (
            address _campaignOwner,
            string memory _campaignId,
            address _prizeAddress,
            uint256 _prizeAmount,
            uint256 _maxEntries,
            uint256 _startTimestamp,
            uint256 _endTimestamp,
            uint256 _entryCount
        )
    {
        return (
            campaignOwner,
            campaignId,
            prizeAddress,
            prizeAmount,
            maxEntries,
            startTimestamp,
            endTimestamp,
            totalEntries
        );
    }

    function hashMessage(address _user) public view returns (bytes32) {
        bytes memory pack = abi.encodePacked(this, _user);
        return keccak256(pack);
    }

    function isStarted() public view returns (bool) {
        return block.timestamp >= startTimestamp;
    }

    function isNotClosed() public view returns (bool) {
        return block.timestamp < endTimestamp;
    }

    function isNotFull() public view returns (bool) {
        return totalEntries < maxEntries;
    }

    function hasEntered(address _user) public view returns (bool) {
        return entryAddress[_user] > 0;
    }

    function getStatus()
        public
        view
        returns (
            bool _hasEntered,
            bool _isStarted,
            bool _isNotClosed,
            uint256 _totalEntries,
            uint256 _maxEntries,
            uint256 _fee
        )
    {
        return (
            hasEntered(msg.sender),
            isStarted(),
            isNotClosed(),
            totalEntries,
            maxEntries,
            fee
        );
    }

    function getUSDInWEI() public view returns (uint256) {
        address dataFeed;
        if (block.chainid == 1) {
            //Mainnet ETH/USD
            dataFeed = 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419;
        } else if (block.chainid == 5) {
            //Goerli ETH/USD
            dataFeed = 0xD4a33860578De61DBAbDc8BFdb98FD742fA7028e;
        } else if (block.chainid == 137) {
            //Polygon MATIC/USD
            dataFeed = 0xAB594600376Ec9fD91F8e885dADF0CE036862dE0;
        } else if (block.chainid == 80001) {
            //Mumbai MATIC/USD
            dataFeed = 0xd0D5e3DB44DE05E9F294BB0a3bEEaF030DE24Ada;
        } else if (block.chainid == 56) {
            //BSC BNB/
            return 0;
//          dataFeed = 0x0567F2323251f0Aab15c8dFb1967E4e8A7D42aeE;
        } else if (block.chainid == 97) {
            //BSC BNBT/USD
            dataFeed = 0x2514895c72f50D8bd4B4F9b1110F0D6bD2c97526;
        }
        AggregatorV3Interface priceFeed = AggregatorV3Interface(dataFeed);
        (, int256 price, , , ) = priceFeed.latestRoundData();
        return 1e26 / uint256(price);
    }

    function getFee() public view returns (uint256) {
        return fee;
    }

    function setEntry(
        bytes32 r,
        bytes32 s,
        uint8 v
    ) public payable {
        require(isNotFull(), "Already reached the maximum number of entries");
        require(isStarted(), "Campaign has not started yet");
        require(isNotClosed(), "Campaign has ended");
        require(entryAddress[msg.sender] == 0, "You have already entered");

        bytes32 message = hashMessage(msg.sender);

        require(
            ecrecover(message, v, r, s) == owner,
            "You need signatures from the owner to set an entry"
        );

        // 1-origin
        totalEntries++;
        entries[totalEntries] = msg.sender;
        entryAddress[msg.sender] = totalEntries;
        owner.transfer(msg.value);
    }

    function getEntryCount() public view returns (uint256) {
        return totalEntries;
    }

    function revealSeed(bytes32 _seed) public {
        require(!isNotClosed(), "Campaign has not ended yet");
        require(revealBlockNumber == 0, "Seed has already been revealed");
        require(
            keccak256(abi.encodePacked(campaignId, _seed)) == sealedSeed,
            "Seed is not correct"
        );
        require(
            msg.sender == owner || msg.sender == campaignOwner,
            "You are not the owner of the campaign"
        );
        revealBlockNumber = block.number + 1;
        revealedSeed = _seed;
    }

    function draw() public view returns (address[] memory _winners) {
        require(
            revealBlockNumber != 0 && revealBlockNumber < block.number,
            "Seed has not been revealed yet"
        );

        address[] memory winners = new address[](prizeAmount);

        if (totalEntries > 0) {
            for (uint256 i = 0; i < prizeAmount; i++) {
                uint256 winnerId = (
                    uint256(
                        keccak256(
                            abi.encodePacked(
                                blockhash(revealBlockNumber),
                                i,
                                revealedSeed
                            )
                        )
                    ) % totalEntries) + 1;

                if (totalEntries > prizeAmount) {
                    while(_addressCheck(winners, entries[winnerId])) {
                        winnerId = (winnerId % totalEntries) + 1;
                    }
                }
                winners[i] = entries[winnerId];
            }
        } else {
            for (uint256 i = 0; i < prizeAmount; i++) {
                winners[i] = campaignOwner;
            }
        }
        return winners;
    }

    function _addressCheck(address[] memory _users, address _user) private pure returns (bool) {
        for (uint i = 0; i < _users.length; i++) {
            if (_users[i] == _user) {
                return true;
            }
        }

        return false;
    }
}