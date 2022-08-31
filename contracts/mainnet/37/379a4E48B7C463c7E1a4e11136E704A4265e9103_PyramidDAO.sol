// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

import "./external/openzeppelin/ReentrancyGuard.sol";

import "./PyramidNFT.sol";
import "./PyramidGame.sol";
import "./Config.sol";

/*             .
██████  ██    ██ ██████   █████  ███    ███ ██ ██████      ██████   █████   ██████  
██   ██  ██  ██  ██   ██ ██   ██ ████  ████ ██ ██   ██     ██   ██ ██   ██ ██    ██ 
██████    ████   ██████  ███████ ██ ████ ██ ██ ██   ██     ██   ██ ███████ ██    ██ 
██         ██    ██   ██ ██   ██ ██  ██  ██ ██ ██   ██     ██   ██ ██   ██ ██    ██ 
██         ██    ██   ██ ██   ██ ██      ██ ██ ██████      ██████  ██   ██  ██████                                                                         
*/
contract PyramidDAO is Config, ReentrancyGuard {

    PyramidNFT public nft;
    PyramidGame public game;

    uint public totalGains;
    uint lastBalance;

    mapping(uint => uint) public pyramidPharaohs;
    mapping(uint => uint) public payedOut;

    uint public proposalCount;
    uint public currentProposal;

    // min time after which a vote can be executed if final decision is reached
    uint constant public MIN_VOTE_TIME = 12 * 60 * 60;

    // max time for voting - after this time can be executed with (not absolute) decision
    uint constant public MAX_VOTE_TIME = 24 * 60 * 60;

    // if not executed in this time, it is discarded
    uint constant public MAX_EXECUTION_TIME = 48 * 60 * 60;

    // see NFT contract - for efficiency duplicate constant
    uint constant GOD_COUNT = 20;
    uint constant MAX_GENESIS_PHARAOH_COUNT = 420;

    // genesis pharaoh part as a percentage of all gains
    uint constant PHARAOH_GOD_SHARES_NOT_ALL_MINTED_X64 = TWO_EXP_64 * 70 / 100;
    uint constant PHARAOH_GOD_SHARES_ALL_MINTED_X64 = TWO_EXP_64 * 80 / 100;

    struct ProposalData {
        uint proposalTimestamp;
        PyramidConfig config;
        address owner;
        uint votesBitmap;
        uint tokenId;
    }

    /**
     * @dev Simple crypto chat because why not
     */
    event ChatMsg(address from, bool sentAsNft, string msg);

    uint public lockedBitmap;
    mapping(uint => ProposalData) public proposals;
 
    constructor(PyramidGame _game, PyramidNFT _nft) { 
        game = _game;
        nft = _nft;
    }

    function proposeOwner(address owner, uint tokenId) external {
        require(tokenId > 0 && tokenId <= GOD_COUNT, "!god");
        require(owner != address(0), "address(0)");
        require(nft.ownerOf(tokenId) == msg.sender, "!owner");
        require(!getBit(lockedBitmap, tokenId), "locked");

        lockedBitmap = setBit(lockedBitmap, tokenId);
        PyramidConfig memory dummyConfig;
        uint votes = setBit(0, tokenId * 2 + 1);
        proposals[proposalCount] = ProposalData(block.timestamp, dummyConfig, owner, votes, tokenId);
        emit Proposal(msg.sender, proposalCount);
        proposalCount++;
    }

    function proposeConfig(PyramidConfig calldata config, uint tokenId) external {
        require(tokenId > 0 && tokenId <= GOD_COUNT, "!god");
        validateConfig(config);
        require(nft.ownerOf(tokenId) == msg.sender, "!owner");
        require(!getBit(lockedBitmap, tokenId), "locked");

        lockedBitmap = setBit(lockedBitmap, tokenId);
        uint votes = setBit(0, tokenId * 2 + 1);
        proposals[proposalCount] = ProposalData(block.timestamp, config, address(0), votes, tokenId);
        emit Proposal(msg.sender, proposalCount);
        proposalCount++;
    }   

    function vote(uint id, uint[] calldata tokenIDs, bool agree) external {
        require(id < proposalCount, ">=proposalCount");

        ProposalData storage prop = proposals[id];

        uint timePassed = block.timestamp - prop.proposalTimestamp;
        require(timePassed < MAX_VOTE_TIME, ">=MAX_VOTE_TIME");
       
        uint votes = 0;
        uint votesBitmap = prop.votesBitmap;
        for(uint i = 0; i < tokenIDs.length; i++) {
            uint tokenId = tokenIDs[i];
            if (tokenId <= GOD_COUNT) {
                require(nft.ownerOf(tokenId) == msg.sender, "!owner");
                // if valid token and not voted yet
                if (!hasVoted(votesBitmap, tokenId)) {
                    votesBitmap = setBit(votesBitmap, tokenId * 2 + (agree ? 1 : 0));
                    votes++;
                }
            }
        }

        if (votes > 0) {
            emit Vote(msg.sender, id, votes, agree);
            prop.votesBitmap = votesBitmap;
        }
    }

    function getResult(uint votesBitmap) public pure returns (uint yes, uint no, uint total) {
        total = GOD_COUNT;
        for(uint i = 1; i <= total; i++) {
            if (getBit(votesBitmap, i * 2)) {
                no++;
            } else if (getBit(votesBitmap, i * 2 + 1)) {
                yes++;
            }
        }
    }

    function hasVoted(uint votesBitmap, uint tokenId) internal pure returns (bool) {
        return getBit(votesBitmap, tokenId * 2) || getBit(votesBitmap, tokenId * 2 + 1);
    }

    // logs a chat message, restricted to owner of bl0x or NFT. 
    // If sendAsTokenId is > 0, the chat is logged as sent from the owner's NFT TokenID instead of the senders address.
    function chat(string calldata chatMessage, uint256 sendAsTokenId) public
    {
        if(sendAsTokenId > 0) {
            require(nft.ownerOf(sendAsTokenId) == msg.sender, '!ownerOf');
            emit ChatMsg(address(uint160(sendAsTokenId)), true, chatMessage);
        } else {
            (uint256 account, uint256 pyramid) = game.investedBlox(msg.sender);
            uint currentPyramid = game.currentPyramid();
            require((account > 0 && currentPyramid == pyramid) || nft.balanceOf(msg.sender) > 0, "!invested");
            emit ChatMsg(msg.sender, false, chatMessage);
        }   
    }

    function execute() external {

        uint proposalIndex = currentProposal;

        while (proposalIndex < proposalCount) {
            ProposalData memory prop = proposals[proposalIndex];
            uint timePassed = block.timestamp - prop.proposalTimestamp;
            if (timePassed > MAX_EXECUTION_TIME) {
                proposalIndex++;
                lockedBitmap = clearBit(lockedBitmap, prop.tokenId);
                emit Discard(msg.sender, proposalIndex);
            } else if (timePassed > MIN_VOTE_TIME) {
                (uint yes, uint no, uint total) = getResult(prop.votesBitmap);
                bool ready = (timePassed >= MAX_VOTE_TIME) || (yes * 2 > total) || (no * 2 > total);
                if (ready) {
                    // execute when majority says yes
                    if (yes > no) {
                        bool success = true;
                        if (prop.owner != address(0)) {
                            game.transferOwnership(prop.owner);
                            nft.transferOwnership(prop.owner);
                        } else {
                            game.setConfig(prop.config);
                        }
                        emit Execute(msg.sender, proposalIndex, success);
                    } else {
                        emit Discard(msg.sender, proposalIndex);
                    }
                    proposalIndex++;
                    lockedBitmap = clearBit(lockedBitmap, prop.tokenId);
                } else {
                    break;
                }
            } else {
                break;
            }
        }

        if (proposalIndex > currentProposal) {
            currentProposal = proposalIndex;
        }
    }

    // to recieve funds from game
    receive() external payable {

    }

    // mints pharaoh to collapser
    function mintPharaoh(uint pyramid) external {
        require(pyramid > 0, "pyramid==0");
        require(pyramid <= game.currentPyramid(), ">currentPyramid");

        uint startProcessedBl0x = game.pyramidStartBl0x(pyramid);
        (address collapser,,,) = game.bloxIdToPendingBuilds(startProcessedBl0x);

        require(msg.sender == collapser, "!collapser");

        require(pyramidPharaohs[pyramid] == 0, "already minted");

        pyramidPharaohs[pyramid] = nft.totalSupply() + 1;
        nft.mintPharaoh(collapser);
    }

    // payout all money for given tokenIDs - checks if they are owned
    function withdraw(uint[] calldata tokenIDs) external nonReentrant returns (uint toPayout) {

        // cashout bl0x to eth - if any available
        uint bl0xBalance = game.balanceOf(address(this));
        if (bl0xBalance > 0) {
            game.cashout(bl0xBalance);
        }

        uint completePyramidCount = game.currentPyramid() - 1;

        // not ready yet
        if (completePyramidCount == 0) {
            return 0;
        }

        uint balance = address(this).balance;
        totalGains += balance - lastBalance;

        uint minted = nft.genesisMinted();
        uint pharaohPercentageX64 = (minted == MAX_GENESIS_PHARAOH_COUNT) ? PHARAOH_GOD_SHARES_ALL_MINTED_X64 : PHARAOH_GOD_SHARES_NOT_ALL_MINTED_X64 * minted / MAX_GENESIS_PHARAOH_COUNT;
        uint godPercentageX64 = TWO_EXP_64 - pharaohPercentageX64;

        uint sharePerGod = (totalGains * godPercentageX64) / (TWO_EXP_64 * GOD_COUNT);
        uint pharaohCompleteShare = (totalGains * pharaohPercentageX64) / TWO_EXP_64;

        uint pharaohShareCount = completePyramidCount * minted + completePyramidCount * (completePyramidCount + 1) / 2;
        uint sharePerPharaoShare = pharaohCompleteShare / pharaohShareCount;

        uint i;
        for(; i < tokenIDs.length; i++) {
            uint tokenId = tokenIDs[i];
            require(nft.ownerOf(tokenId) == msg.sender, "!owner");
            
            uint share = tokenId > GOD_COUNT + minted ?
                         (completePyramidCount - (tokenId - GOD_COUNT - minted - 1)) * sharePerPharaoShare :
                         (tokenId > GOD_COUNT ? completePyramidCount * sharePerPharaoShare :
                         sharePerGod);

            uint payedOutForNFT = payedOut[tokenId];
            if (payedOutForNFT < share) {
                toPayout += share - payedOutForNFT;
                payedOut[tokenId] = share; 
            }
        }

        lastBalance = balance - toPayout;

        if (toPayout > 0) {
            (bool sent,) = payable(msg.sender).call{value: toPayout}("");
            require(sent, "Failed sending funds");
        }

        emit Withdraw(msg.sender, toPayout);
    }

    function setBit(uint bitmap, uint index) internal pure returns (uint) {
        return (bitmap | (1 << index));
    }

    function getBit(uint bitmap, uint index) internal pure returns (bool) {
        return (bitmap & (1 << index)) > 0;
    }

    function clearBit(uint bitmap, uint index) internal pure returns (uint) {
        return bitmap & ~(1 << index);
    }

    /**
     * @dev Emitted when a user submits a proposal
     */
    event Proposal(address indexed owner, uint256 id);

    /**
     * @dev Emitted when a user votes on a proposal
     */
    event Vote(address indexed owner, uint256 indexed proposal, uint256 votes, bool agree);

    /**
     * @dev Emitted when a proposal is executed
     */
    event Execute(address indexed owner, uint256 indexed proposal, bool success);

    /**
     * @dev Emitted when a proposal is discarded
     */
    event Discard(address indexed owner, uint256 indexed proposal);

    /**
     * @dev Emitted when dao funds are withdrawn
     */
    event Withdraw(address indexed owner, uint256 amount);
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
pragma solidity 0.8.4;

import "./external/chiru-labs/extensions/ERC721AQueryable.sol";
import "./external/openzeppelin/Base64.sol";
import "./external/openzeppelin/ReentrancyGuard.sol";
import "./external/openzeppelin/Ownable.sol";

/*
██████  ██    ██ ██████   █████  ███    ███ ██ ██████      ███    ██ ███████ ████████ 
██   ██  ██  ██  ██   ██ ██   ██ ████  ████ ██ ██   ██     ████   ██ ██         ██    
██████    ████   ██████  ███████ ██ ████ ██ ██ ██   ██     ██ ██  ██ █████      ██    
██         ██    ██   ██ ██   ██ ██  ██  ██ ██ ██   ██     ██  ██ ██ ██         ██    
██         ██    ██   ██ ██   ██ ██      ██ ██ ██████      ██   ████ ██         ██                                                                             
*/
contract PyramidNFT is ERC721AQueryable, Ownable, ReentrancyGuard {

    // ipfs folder with all images
    string public constant ipfsHash = "QmdqPHGmJV95SAx821UWXRY8CUsXJcru4JGsjaXDtWp96f";

    uint8 public constant GOD_COUNT = 20;
    uint8 public constant MAX_MINT = 10;
    uint8 public constant PHARAOH_NAMES_COUNT = 42;
    uint16 public constant MAX_GENESIS_PHARAOH_COUNT = 420;

    uint256 constant TWO_EXP_64 = 2**64;

    // mint prices
    uint128 public minMintPrice;
    uint128 public currentMintPrice;

    // mint status
    uint16 public genesisMinted;
    uint32 public lastMinted;

    // mint config
    uint80 public growthPerMintX64;
    uint32 public shrinkToHalfSecs;
    uint32 public genesisSaleStart;
    uint32 public genesisSaleEnd;

    // set owner
    constructor() ERC721A("Pyramid Gods & Pharaohs", "PGP") {
        
    }

    function godNames(uint i) internal pure returns (string memory) {
        return ["Sobek","Tefnut","Isis","Ra","Anubis","Bastet","Set","Khnum","Sekhmet","Kek",
                "Thoth","Amun","Horus","Maat","Ptah","Khonsu","Anhur","Geb","Hathor","Osiris"][i];
    }

    function pharaohNames(uint i) internal pure returns (string memory) {
        return ["Tutankhamun", "Mina", "Ramses", "Tuthmosis", "Amenhotep", "Hatshepsut", "Akhenaten", "Djoser", "Khufu","Snefru",
                "Khafre","Nefertari","Pepi","Seti","Cleopatra","Twosret", "Xerxes", "Senwosret", "Aya", "Siptah", "Zanakht", 
                "Sekhemkhet", "Khaba", "Huni", "Djedefre", "Nebka", "Menkaure", "Shepseskaf", "Thamphthis", "Userkaf", "Sahure", 
                "Isesi", "Unis", "Teti", "Intef", "Qakare", "Tao", "Kamose", "Osochor", "Siamun", "Pami", "Iuput"][i];
    }

    function pharaohNumbers(uint i) internal pure returns (string memory) {
        return ["I", "II", "III", "IV", "V", "VI", "VII", "VIII", "IX", "X"][i];
    }

    function mintGods(address a1, address a2) external onlyOwner() {
        require(totalSupply() == 0, "gods");
        _safeMint(a1, GOD_COUNT / 2);
        _safeMint(a2, GOD_COUNT / 2);
    }

    function setGenesisSale(uint128 _minPrice, uint80 _growth, uint32 _shrink, uint32 _startTime, uint32 _endTime) external onlyOwner {
        
        // can only be set when gods minted and no genesis pharaos minted yet
        require(totalSupply() == GOD_COUNT, "!gods");
        
        require(_startTime >= block.timestamp);
        require(_endTime > _startTime);
        require(_minPrice > 0);

        minMintPrice = _minPrice;
        growthPerMintX64 = _growth;
        shrinkToHalfSecs = _shrink;
        genesisSaleStart = _startTime;
        genesisSaleEnd = _endTime;
    }

    function genesisSalePrice(uint8 count) public view returns (uint total, uint128 nextPrice) {

        require(count > 0, "count=0");
        require(count <= MAX_MINT, "count>MAX_MINT");

        uint minTime = genesisSaleStart;
        uint maxTime = genesisSaleEnd;
        uint128 minPrice = minMintPrice;

        require(minTime > 0 && minTime < block.timestamp, "not started");
        require(maxTime > block.timestamp, "ended");

        if (lastMinted > 0) {
            uint timeFactorDecrease = TWO_EXP_64 + ((block.timestamp - lastMinted) * TWO_EXP_64 / shrinkToHalfSecs);
            nextPrice = uint128(currentMintPrice * TWO_EXP_64 / timeFactorDecrease);
            if (nextPrice < minPrice) {
                nextPrice = minPrice;
            }
        } else {
            nextPrice = minPrice;
        }
        
        total = nextPrice * count;
        
        uint128 grownPrice = uint128(nextPrice * (TWO_EXP_64 + growthPerMintX64) / TWO_EXP_64);

        nextPrice = (grownPrice > nextPrice + minPrice) ? grownPrice : nextPrice + minPrice;
    }

    // mints genesis pharaoh(s)
    function mintGenesisPharaoh(uint8 count) payable external nonReentrant {
        require(genesisMinted + count <= MAX_GENESIS_PHARAOH_COUNT, "not enough left");

        uint total;
        (total, currentMintPrice) = genesisSalePrice(count);

        require(msg.value >= total, "msg.value<price");

        // mint nft
        genesisMinted += count;
        lastMinted = uint32(block.timestamp);
        _safeMint(msg.sender, count);
    }

    // withdraw gains from genesis sale
    function withdraw() external onlyOwner nonReentrant {
        uint balance = address(this).balance;
        if (balance > 0) {
            // send funds to sale owner
            (bool sent,) = payable(owner()).call{value: balance}("");
            require(sent, "Failed sending funds");
        }
    }

    // mints pharao for pyramid, depends on owner/dao to validate pyramid
    function mintPharaoh(address to) external onlyOwner nonReentrant {
        require(genesisSaleEnd > 0 && block.timestamp >= genesisSaleEnd, "!ended");
        _safeMint(to, 1);
    }

    function getPharaohName(uint256 tokenId) public view returns (string memory) {

        require(tokenId > GOD_COUNT, "god");
        require(tokenId <= GOD_COUNT + genesisMinted || genesisSaleEnd < block.timestamp, "not defined yet");

        uint minted = genesisMinted;
        uint pharaohId = tokenId - GOD_COUNT;
        bool isGenesis = pharaohId <= minted;
        uint pharaohNumber = isGenesis ? pharaohId : pharaohId - minted;
        string memory name = pharaohNames((pharaohNumber - 1) % PHARAOH_NAMES_COUNT);
        uint index = ((pharaohNumber - 1) / PHARAOH_NAMES_COUNT);
        string memory number = isGenesis ? string(abi.encodePacked("Genesis ", pharaohNumbers(index % 10))) : pharaohNumbers(index % 10);
        return string(abi.encodePacked(name, " ", number));
    }

    function tokenURI(uint256 tokenId) override public view returns (string memory) {
        string memory name = tokenId > GOD_COUNT ? getPharaohName(tokenId) : godNames(tokenId - 1);
        string memory description = "Pyramid Gods & Pharaohs have direct access to pyramid gains and can participate in the Pyramid DAO.";
        string memory attrType = tokenId > GOD_COUNT ? (tokenId > GOD_COUNT + genesisMinted ? "PHARAOH" : "GENESIS PHARAOH") : "GOD";
        string memory fileName = tokenId > GOD_COUNT ? (tokenId > GOD_COUNT + genesisMinted ? "Pharaoh" : "GenesisPharaoh") : name;
        string memory attributes = string(abi.encodePacked('"attributes": [{"trait_type": "type", "value": "', attrType,'"}]'));
        bytes memory json = abi.encodePacked('{"name": "', name ,'", "description": "', description ,'","image": "ipfs://', ipfsHash,'/', fileName, '.jpg", ',attributes ,'}');
        string memory jsonBase64 = Base64.encode(json);
        return string(abi.encodePacked('data:application/json;base64,', jsonBase64));
    }

    // first god is token 1
    function _startTokenId() internal pure override returns (uint256) {
        return 1;
    }
}

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
// ERC721A Contracts v4.0.0
// Creator: Chiru Labs

pragma solidity 0.8.4;

import './IERC721AQueryable.sol';
import '../ERC721A.sol';

/**
 * @title ERC721A Queryable
 * @dev ERC721A subclass with convenience query functions.
 */
abstract contract ERC721AQueryable is ERC721A, IERC721AQueryable {
    /**
     * @dev Returns the `TokenOwnership` struct at `tokenId` without reverting.
     *
     * If the `tokenId` is out of bounds:
     *   - `addr` = `address(0)`
     *   - `startTimestamp` = `0`
     *   - `burned` = `false`
     *
     * If the `tokenId` is burned:
     *   - `addr` = `<Address of owner before token was burned>`
     *   - `startTimestamp` = `<Timestamp when token was burned>`
     *   - `burned = `true`
     *
     * Otherwise:
     *   - `addr` = `<Address of owner>`
     *   - `startTimestamp` = `<Timestamp of start of ownership>`
     *   - `burned = `false`
     */
    function explicitOwnershipOf(uint256 tokenId) public view override returns (TokenOwnership memory) {
        TokenOwnership memory ownership;
        if (tokenId < _startTokenId() || tokenId >= _nextTokenId()) {
            return ownership;
        }
        ownership = _ownershipAt(tokenId);
        if (ownership.burned) {
            return ownership;
        }
        return _ownershipOf(tokenId);
    }

    /**
     * @dev Returns an array of `TokenOwnership` structs at `tokenIds` in order.
     * See {ERC721AQueryable-explicitOwnershipOf}
     */
    function explicitOwnershipsOf(uint256[] memory tokenIds) external view override returns (TokenOwnership[] memory) {
        unchecked {
            uint256 tokenIdsLength = tokenIds.length;
            TokenOwnership[] memory ownerships = new TokenOwnership[](tokenIdsLength);
            for (uint256 i; i != tokenIdsLength; ++i) {
                ownerships[i] = explicitOwnershipOf(tokenIds[i]);
            }
            return ownerships;
        }
    }

    /**
     * @dev Returns an array of token IDs owned by `owner`,
     * in the range [`start`, `stop`)
     * (i.e. `start <= tokenId < stop`).
     *
     * This function allows for tokens to be queried if the collection
     * grows too big for a single call of {ERC721AQueryable-tokensOfOwner}.
     *
     * Requirements:
     *
     * - `start` < `stop`
     */
    function tokensOfOwnerIn(
        address owner,
        uint256 start,
        uint256 stop
    ) external view override returns (uint256[] memory) {
        unchecked {
            if (start >= stop) revert InvalidQueryRange();
            uint256 tokenIdsIdx;
            uint256 stopLimit = _nextTokenId();
            // Set `start = max(start, _startTokenId())`.
            if (start < _startTokenId()) {
                start = _startTokenId();
            }
            // Set `stop = min(stop, stopLimit)`.
            if (stop > stopLimit) {
                stop = stopLimit;
            }
            uint256 tokenIdsMaxLength = balanceOf(owner);
            // Set `tokenIdsMaxLength = min(balanceOf(owner), stop - start)`,
            // to cater for cases where `balanceOf(owner)` is too big.
            if (start < stop) {
                uint256 rangeLength = stop - start;
                if (rangeLength < tokenIdsMaxLength) {
                    tokenIdsMaxLength = rangeLength;
                }
            } else {
                tokenIdsMaxLength = 0;
            }
            uint256[] memory tokenIds = new uint256[](tokenIdsMaxLength);
            if (tokenIdsMaxLength == 0) {
                return tokenIds;
            }
            // We need to call `explicitOwnershipOf(start)`,
            // because the slot at `start` may not be initialized.
            TokenOwnership memory ownership = explicitOwnershipOf(start);
            address currOwnershipAddr;
            // If the starting slot exists (i.e. not burned), initialize `currOwnershipAddr`.
            // `ownership.address` will not be zero, as `start` is clamped to the valid token ID range.
            if (!ownership.burned) {
                currOwnershipAddr = ownership.addr;
            }
            for (uint256 i = start; i != stop && tokenIdsIdx != tokenIdsMaxLength; ++i) {
                ownership = _ownershipAt(i);
                if (ownership.burned) {
                    continue;
                }
                if (ownership.addr != address(0)) {
                    currOwnershipAddr = ownership.addr;
                }
                if (currOwnershipAddr == owner) {
                    tokenIds[tokenIdsIdx++] = i;
                }
            }
            // Downsize the array to fit.
            assembly {
                mstore(tokenIds, tokenIdsIdx)
            }
            return tokenIds;
        }
    }

    /**
     * @dev Returns an array of token IDs owned by `owner`.
     *
     * This function scans the ownership mapping and is O(totalSupply) in complexity.
     * It is meant to be called off-chain.
     *
     * See {ERC721AQueryable-tokensOfOwnerIn} for splitting the scan into
     * multiple smaller scans if the collection is large enough to cause
     * an out-of-gas error (10K pfp collections should be fine).
     */
    function tokensOfOwner(address owner) external view override returns (uint256[] memory) {
        unchecked {
            uint256 tokenIdsIdx;
            address currOwnershipAddr;
            uint256 tokenIdsLength = balanceOf(owner);
            uint256[] memory tokenIds = new uint256[](tokenIdsLength);
            TokenOwnership memory ownership;
            for (uint256 i = _startTokenId(); tokenIdsIdx != tokenIdsLength; ++i) {
                ownership = _ownershipAt(i);
                if (ownership.burned) {
                    continue;
                }
                if (ownership.addr != address(0)) {
                    currOwnershipAddr = ownership.addr;
                }
                if (currOwnershipAddr == owner) {
                    tokenIds[tokenIdsIdx++] = i;
                }
            }
            return tokenIds;
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (utils/Base64.sol)

pragma solidity 0.8.4;

/**
 * @dev Provides a set of functions to operate with Base64 strings.
 *
 * _Available since v4.5._
 */
library Base64 {
    /**
     * @dev Base64 Encoding/Decoding Table
     */
    string internal constant _TABLE = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

    /**
     * @dev Converts a `bytes` to its Bytes64 `string` representation.
     */
    function encode(bytes memory data) internal pure returns (string memory) {
        /**
         * Inspired by Brecht Devos (Brechtpd) implementation - MIT licence
         * https://github.com/Brechtpd/base64/blob/e78d9fd951e7b0977ddca77d92dc85183770daf4/base64.sol
         */
        if (data.length == 0) return "";

        // Loads the table into memory
        string memory table = _TABLE;

        // Encoding takes 3 bytes chunks of binary data from `bytes` data parameter
        // and split into 4 numbers of 6 bits.
        // The final Base64 length should be `bytes` data length multiplied by 4/3 rounded up
        // - `data.length + 2`  -> Round up
        // - `/ 3`              -> Number of 3-bytes chunks
        // - `4 *`              -> 4 characters for each chunk
        string memory result = new string(4 * ((data.length + 2) / 3));

        assembly {
            // Prepare the lookup table (skip the first "length" byte)
            let tablePtr := add(table, 1)

            // Prepare result pointer, jump over length
            let resultPtr := add(result, 32)

            // Run over the input, 3 bytes at a time
            for {
                let dataPtr := data
                let endPtr := add(data, mload(data))
            } lt(dataPtr, endPtr) {

            } {
                // Advance 3 bytes
                dataPtr := add(dataPtr, 3)
                let input := mload(dataPtr)

                // To write each character, shift the 3 bytes (18 bits) chunk
                // 4 times in blocks of 6 bits for each character (18, 12, 6, 0)
                // and apply logical AND with 0x3F which is the number of
                // the previous character in the ASCII table prior to the Base64 Table
                // The result is then added to the table to get the character to write,
                // and finally write it in the result pointer but with a left shift
                // of 256 (1 byte) - 8 (1 ASCII char) = 248 bits

                mstore8(resultPtr, mload(add(tablePtr, and(shr(18, input), 0x3F))))
                resultPtr := add(resultPtr, 1) // Advance

                mstore8(resultPtr, mload(add(tablePtr, and(shr(12, input), 0x3F))))
                resultPtr := add(resultPtr, 1) // Advance

                mstore8(resultPtr, mload(add(tablePtr, and(shr(6, input), 0x3F))))
                resultPtr := add(resultPtr, 1) // Advance

                mstore8(resultPtr, mload(add(tablePtr, and(input, 0x3F))))
                resultPtr := add(resultPtr, 1) // Advance
            }

            // When data `bytes` is not exactly 3 bytes long
            // it is padded with `=` characters at the end
            switch mod(mload(data), 3)
            case 1 {
                mstore8(sub(resultPtr, 1), 0x3d)
                mstore8(sub(resultPtr, 2), 0x3d)
            }
            case 2 {
                mstore8(sub(resultPtr, 1), 0x3d)
            }
        }

        return result;
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
// ERC721A Contracts v4.0.0
// Creator: Chiru Labs

pragma solidity 0.8.4;

import '../IERC721A.sol';

/**
 * @dev Interface of an ERC721AQueryable compliant contract.
 */
interface IERC721AQueryable is IERC721A {
    /**
     * Invalid query range (`start` >= `stop`).
     */
    error InvalidQueryRange();

    /**
     * @dev Returns the `TokenOwnership` struct at `tokenId` without reverting.
     *
     * If the `tokenId` is out of bounds:
     *   - `addr` = `address(0)`
     *   - `startTimestamp` = `0`
     *   - `burned` = `false`
     *
     * If the `tokenId` is burned:
     *   - `addr` = `<Address of owner before token was burned>`
     *   - `startTimestamp` = `<Timestamp when token was burned>`
     *   - `burned = `true`
     *
     * Otherwise:
     *   - `addr` = `<Address of owner>`
     *   - `startTimestamp` = `<Timestamp of start of ownership>`
     *   - `burned = `false`
     */
    function explicitOwnershipOf(uint256 tokenId) external view returns (TokenOwnership memory);

    /**
     * @dev Returns an array of `TokenOwnership` structs at `tokenIds` in order.
     * See {ERC721AQueryable-explicitOwnershipOf}
     */
    function explicitOwnershipsOf(uint256[] memory tokenIds) external view returns (TokenOwnership[] memory);

    /**
     * @dev Returns an array of token IDs owned by `owner`,
     * in the range [`start`, `stop`)
     * (i.e. `start <= tokenId < stop`).
     *
     * This function allows for tokens to be queried if the collection
     * grows too big for a single call of {ERC721AQueryable-tokensOfOwner}.
     *
     * Requirements:
     *
     * - `start` < `stop`
     */
    function tokensOfOwnerIn(
        address owner,
        uint256 start,
        uint256 stop
    ) external view returns (uint256[] memory);

    /**
     * @dev Returns an array of token IDs owned by `owner`.
     *
     * This function scans the ownership mapping and is O(totalSupply) in complexity.
     * It is meant to be called off-chain.
     *
     * See {ERC721AQueryable-tokensOfOwnerIn} for splitting the scan into
     * multiple smaller scans if the collection is large enough to cause
     * an out-of-gas error (10K pfp collections should be fine).
     */
    function tokensOfOwner(address owner) external view returns (uint256[] memory);
}

// SPDX-License-Identifier: MIT
// ERC721A Contracts v4.0.0
// Creator: Chiru Labs

pragma solidity 0.8.4;

import './IERC721A.sol';

/**
 * @dev ERC721 token receiver interface.
 */
interface ERC721A__IERC721Receiver {
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}

/**
 * @dev Implementation of https://eips.ethereum.org/EIPS/eip-721[ERC721] Non-Fungible Token Standard, including
 * the Metadata extension. Built to optimize for lower gas during batch mints.
 *
 * Assumes serials are sequentially minted starting at _startTokenId() (defaults to 0, e.g. 0, 1, 2, 3..).
 *
 * Assumes that an owner cannot have more than 2**64 - 1 (max value of uint64) of supply.
 *
 * Assumes that the maximum token id cannot exceed 2**256 - 1 (max value of uint256).
 */
contract ERC721A is IERC721A {
    // Mask of an entry in packed address data.
    uint256 private constant BITMASK_ADDRESS_DATA_ENTRY = (1 << 64) - 1;

    // The bit position of `numberMinted` in packed address data.
    uint256 private constant BITPOS_NUMBER_MINTED = 64;

    // The bit position of `numberBurned` in packed address data.
    uint256 private constant BITPOS_NUMBER_BURNED = 128;

    // The bit position of `aux` in packed address data.
    uint256 private constant BITPOS_AUX = 192;

    // Mask of all 256 bits in packed address data except the 64 bits for `aux`.
    uint256 private constant BITMASK_AUX_COMPLEMENT = (1 << 192) - 1;

    // The bit position of `startTimestamp` in packed ownership.
    uint256 private constant BITPOS_START_TIMESTAMP = 160;

    // The bit mask of the `burned` bit in packed ownership.
    uint256 private constant BITMASK_BURNED = 1 << 224;

    // The bit position of the `nextInitialized` bit in packed ownership.
    uint256 private constant BITPOS_NEXT_INITIALIZED = 225;

    // The bit mask of the `nextInitialized` bit in packed ownership.
    uint256 private constant BITMASK_NEXT_INITIALIZED = 1 << 225;

    // The tokenId of the next token to be minted.
    uint256 private _currentIndex;

    // The number of tokens burned.
    uint256 private _burnCounter;

    // Token name
    string private _name;

    // Token symbol
    string private _symbol;

    // Mapping from token ID to ownership details
    // An empty struct value does not necessarily mean the token is unowned.
    // See `_packedOwnershipOf` implementation for details.
    //
    // Bits Layout:
    // - [0..159]   `addr`
    // - [160..223] `startTimestamp`
    // - [224]      `burned`
    // - [225]      `nextInitialized`
    mapping(uint256 => uint256) private _packedOwnerships;

    // Mapping owner address to address data.
    //
    // Bits Layout:
    // - [0..63]    `balance`
    // - [64..127]  `numberMinted`
    // - [128..191] `numberBurned`
    // - [192..255] `aux`
    mapping(address => uint256) private _packedAddressData;

    // Mapping from token ID to approved address.
    mapping(uint256 => address) private _tokenApprovals;

    // Mapping from owner to operator approvals
    mapping(address => mapping(address => bool)) private _operatorApprovals;

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
        _currentIndex = _startTokenId();
    }

    /**
     * @dev Returns the starting token ID.
     * To change the starting token ID, please override this function.
     */
    function _startTokenId() internal view virtual returns (uint256) {
        return 0;
    }

    /**
     * @dev Returns the next token ID to be minted.
     */
    function _nextTokenId() internal view returns (uint256) {
        return _currentIndex;
    }

    /**
     * @dev Returns the total number of tokens in existence.
     * Burned tokens will reduce the count.
     * To get the total number of tokens minted, please see `_totalMinted`.
     */
    function totalSupply() public view override returns (uint256) {
        // Counter underflow is impossible as _burnCounter cannot be incremented
        // more than `_currentIndex - _startTokenId()` times.
        unchecked {
            return _currentIndex - _burnCounter - _startTokenId();
        }
    }

    /**
     * @dev Returns the total amount of tokens minted in the contract.
     */
    function _totalMinted() internal view returns (uint256) {
        // Counter underflow is impossible as _currentIndex does not decrement,
        // and it is initialized to `_startTokenId()`
        unchecked {
            return _currentIndex - _startTokenId();
        }
    }

    /**
     * @dev Returns the total number of tokens burned.
     */
    function _totalBurned() internal view returns (uint256) {
        return _burnCounter;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        // The interface IDs are constants representing the first 4 bytes of the XOR of
        // all function selectors in the interface. See: https://eips.ethereum.org/EIPS/eip-165
        // e.g. `bytes4(i.functionA.selector ^ i.functionB.selector ^ ...)`
        return
            interfaceId == 0x01ffc9a7 || // ERC165 interface ID for ERC165.
            interfaceId == 0x80ac58cd || // ERC165 interface ID for ERC721.
            interfaceId == 0x5b5e139f; // ERC165 interface ID for ERC721Metadata.
    }

    /**
     * @dev See {IERC721-balanceOf}.
     */
    function balanceOf(address owner) public view override returns (uint256) {
        if (_addressToUint256(owner) == 0) revert BalanceQueryForZeroAddress();
        return _packedAddressData[owner] & BITMASK_ADDRESS_DATA_ENTRY;
    }

    /**
     * Returns the number of tokens minted by `owner`.
     */
    function _numberMinted(address owner) internal view returns (uint256) {
        return (_packedAddressData[owner] >> BITPOS_NUMBER_MINTED) & BITMASK_ADDRESS_DATA_ENTRY;
    }

    /**
     * Returns the number of tokens burned by or on behalf of `owner`.
     */
    function _numberBurned(address owner) internal view returns (uint256) {
        return (_packedAddressData[owner] >> BITPOS_NUMBER_BURNED) & BITMASK_ADDRESS_DATA_ENTRY;
    }

    /**
     * Returns the auxillary data for `owner`. (e.g. number of whitelist mint slots used).
     */
    function _getAux(address owner) internal view returns (uint64) {
        return uint64(_packedAddressData[owner] >> BITPOS_AUX);
    }

    /**
     * Sets the auxillary data for `owner`. (e.g. number of whitelist mint slots used).
     * If there are multiple variables, please pack them into a uint64.
     */
    function _setAux(address owner, uint64 aux) internal {
        uint256 packed = _packedAddressData[owner];
        uint256 auxCasted;
        assembly { // Cast aux without masking.
            auxCasted := aux
        }
        packed = (packed & BITMASK_AUX_COMPLEMENT) | (auxCasted << BITPOS_AUX);
        _packedAddressData[owner] = packed;
    }

    /**
     * Returns the packed ownership data of `tokenId`.
     */
    function _packedOwnershipOf(uint256 tokenId) private view returns (uint256) {
        uint256 curr = tokenId;

        unchecked {
            if (_startTokenId() <= curr)
                if (curr < _currentIndex) {
                    uint256 packed = _packedOwnerships[curr];
                    // If not burned.
                    if (packed & BITMASK_BURNED == 0) {
                        // Invariant:
                        // There will always be an ownership that has an address and is not burned
                        // before an ownership that does not have an address and is not burned.
                        // Hence, curr will not underflow.
                        //
                        // We can directly compare the packed value.
                        // If the address is zero, packed is zero.
                        while (packed == 0) {
                            packed = _packedOwnerships[--curr];
                        }
                        return packed;
                    }
                }
        }
        revert OwnerQueryForNonexistentToken();
    }

    /**
     * Returns the unpacked `TokenOwnership` struct from `packed`.
     */
    function _unpackedOwnership(uint256 packed) private pure returns (TokenOwnership memory ownership) {
        ownership.addr = address(uint160(packed));
        ownership.startTimestamp = uint64(packed >> BITPOS_START_TIMESTAMP);
        ownership.burned = packed & BITMASK_BURNED != 0;
    }

    /**
     * Returns the unpacked `TokenOwnership` struct at `index`.
     */
    function _ownershipAt(uint256 index) internal view returns (TokenOwnership memory) {
        return _unpackedOwnership(_packedOwnerships[index]);
    }

    /**
     * @dev Initializes the ownership slot minted at `index` for efficiency purposes.
     */
    function _initializeOwnershipAt(uint256 index) internal {
        if (_packedOwnerships[index] == 0) {
            _packedOwnerships[index] = _packedOwnershipOf(index);
        }
    }

    /**
     * Gas spent here starts off proportional to the maximum mint batch size.
     * It gradually moves to O(1) as tokens get transferred around in the collection over time.
     */
    function _ownershipOf(uint256 tokenId) internal view returns (TokenOwnership memory) {
        return _unpackedOwnership(_packedOwnershipOf(tokenId));
    }

    /**
     * @dev See {IERC721-ownerOf}.
     */
    function ownerOf(uint256 tokenId) public view override returns (address) {
        return address(uint160(_packedOwnershipOf(tokenId)));
    }

    /**
     * @dev See {IERC721Metadata-name}.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev See {IERC721Metadata-symbol}.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev See {IERC721Metadata-tokenURI}.
     */
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        if (!_exists(tokenId)) revert URIQueryForNonexistentToken();

        string memory baseURI = _baseURI();
        return bytes(baseURI).length != 0 ? string(abi.encodePacked(baseURI, _toString(tokenId))) : '';
    }

    /**
     * @dev Base URI for computing {tokenURI}. If set, the resulting URI for each
     * token will be the concatenation of the `baseURI` and the `tokenId`. Empty
     * by default, can be overriden in child contracts.
     */
    function _baseURI() internal view virtual returns (string memory) {
        return '';
    }

    /**
     * @dev Casts the address to uint256 without masking.
     */
    function _addressToUint256(address value) private pure returns (uint256 result) {
        assembly {
            result := value
        }
    }

    /**
     * @dev Casts the boolean to uint256 without branching.
     */
    function _boolToUint256(bool value) private pure returns (uint256 result) {
        assembly {
            result := value
        }
    }

    /**
     * @dev See {IERC721-approve}.
     */
    function approve(address to, uint256 tokenId) public override {
        address owner = address(uint160(_packedOwnershipOf(tokenId)));
        if (to == owner) revert ApprovalToCurrentOwner();

        if (_msgSenderERC721A() != owner)
            if (!isApprovedForAll(owner, _msgSenderERC721A())) {
                revert ApprovalCallerNotOwnerNorApproved();
            }

        _tokenApprovals[tokenId] = to;
        emit Approval(owner, to, tokenId);
    }

    /**
     * @dev See {IERC721-getApproved}.
     */
    function getApproved(uint256 tokenId) public view override returns (address) {
        if (!_exists(tokenId)) revert ApprovalQueryForNonexistentToken();

        return _tokenApprovals[tokenId];
    }

    /**
     * @dev See {IERC721-setApprovalForAll}.
     */
    function setApprovalForAll(address operator, bool approved) public virtual override {
        if (operator == _msgSenderERC721A()) revert ApproveToCaller();

        _operatorApprovals[_msgSenderERC721A()][operator] = approved;
        emit ApprovalForAll(_msgSenderERC721A(), operator, approved);
    }

    /**
     * @dev See {IERC721-isApprovedForAll}.
     */
    function isApprovedForAll(address owner, address operator) public view virtual override returns (bool) {
        return _operatorApprovals[owner][operator];
    }

    /**
     * @dev See {IERC721-transferFrom}.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        _transfer(from, to, tokenId);
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        safeTransferFrom(from, to, tokenId, '');
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) public virtual override {
        _transfer(from, to, tokenId);
        if (to.code.length != 0)
            if (!_checkContractOnERC721Received(from, to, tokenId, _data)) {
                revert TransferToNonERC721ReceiverImplementer();
            }
    }

    /**
     * @dev Returns whether `tokenId` exists.
     *
     * Tokens can be managed by their owner or approved accounts via {approve} or {setApprovalForAll}.
     *
     * Tokens start existing when they are minted (`_mint`),
     */
    function _exists(uint256 tokenId) internal view returns (bool) {
        return
            _startTokenId() <= tokenId &&
            tokenId < _currentIndex && // If within bounds,
            _packedOwnerships[tokenId] & BITMASK_BURNED == 0; // and not burned.
    }

    /**
     * @dev Equivalent to `_safeMint(to, quantity, '')`.
     */
    function _safeMint(address to, uint256 quantity) internal {
        _safeMint(to, quantity, '');
    }

    /**
     * @dev Safely mints `quantity` tokens and transfers them to `to`.
     *
     * Requirements:
     *
     * - If `to` refers to a smart contract, it must implement
     *   {IERC721Receiver-onERC721Received}, which is called for each safe transfer.
     * - `quantity` must be greater than 0.
     *
     * Emits a {Transfer} event.
     */
    function _safeMint(
        address to,
        uint256 quantity,
        bytes memory _data
    ) internal {
        uint256 startTokenId = _currentIndex;
        if (_addressToUint256(to) == 0) revert MintToZeroAddress();
        if (quantity == 0) revert MintZeroQuantity();

        _beforeTokenTransfers(address(0), to, startTokenId, quantity);

        // Overflows are incredibly unrealistic.
        // balance or numberMinted overflow if current value of either + quantity > 1.8e19 (2**64) - 1
        // updatedIndex overflows if _currentIndex + quantity > 1.2e77 (2**256) - 1
        unchecked {
            // Updates:
            // - `balance += quantity`.
            // - `numberMinted += quantity`.
            //
            // We can directly add to the balance and number minted.
            _packedAddressData[to] += quantity * ((1 << BITPOS_NUMBER_MINTED) | 1);

            // Updates:
            // - `address` to the owner.
            // - `startTimestamp` to the timestamp of minting.
            // - `burned` to `false`.
            // - `nextInitialized` to `quantity == 1`.
            _packedOwnerships[startTokenId] =
                _addressToUint256(to) |
                (block.timestamp << BITPOS_START_TIMESTAMP) |
                (_boolToUint256(quantity == 1) << BITPOS_NEXT_INITIALIZED);

            uint256 updatedIndex = startTokenId;
            uint256 end = updatedIndex + quantity;

            if (to.code.length != 0) {
                do {
                    emit Transfer(address(0), to, updatedIndex);
                    if (!_checkContractOnERC721Received(address(0), to, updatedIndex++, _data)) {
                        revert TransferToNonERC721ReceiverImplementer();
                    }
                } while (updatedIndex < end);
                // Reentrancy protection
                if (_currentIndex != startTokenId) revert();
            } else {
                do {
                    emit Transfer(address(0), to, updatedIndex++);
                } while (updatedIndex < end);
            }
            _currentIndex = updatedIndex;
        }
        _afterTokenTransfers(address(0), to, startTokenId, quantity);
    }

    /**
     * @dev Mints `quantity` tokens and transfers them to `to`.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - `quantity` must be greater than 0.
     *
     * Emits a {Transfer} event.
     */
    function _mint(address to, uint256 quantity) internal {
        uint256 startTokenId = _currentIndex;
        if (_addressToUint256(to) == 0) revert MintToZeroAddress();
        if (quantity == 0) revert MintZeroQuantity();

        _beforeTokenTransfers(address(0), to, startTokenId, quantity);

        // Overflows are incredibly unrealistic.
        // balance or numberMinted overflow if current value of either + quantity > 1.8e19 (2**64) - 1
        // updatedIndex overflows if _currentIndex + quantity > 1.2e77 (2**256) - 1
        unchecked {
            // Updates:
            // - `balance += quantity`.
            // - `numberMinted += quantity`.
            //
            // We can directly add to the balance and number minted.
            _packedAddressData[to] += quantity * ((1 << BITPOS_NUMBER_MINTED) | 1);

            // Updates:
            // - `address` to the owner.
            // - `startTimestamp` to the timestamp of minting.
            // - `burned` to `false`.
            // - `nextInitialized` to `quantity == 1`.
            _packedOwnerships[startTokenId] =
                _addressToUint256(to) |
                (block.timestamp << BITPOS_START_TIMESTAMP) |
                (_boolToUint256(quantity == 1) << BITPOS_NEXT_INITIALIZED);

            uint256 updatedIndex = startTokenId;
            uint256 end = updatedIndex + quantity;

            do {
                emit Transfer(address(0), to, updatedIndex++);
            } while (updatedIndex < end);

            _currentIndex = updatedIndex;
        }
        _afterTokenTransfers(address(0), to, startTokenId, quantity);
    }

    /**
     * @dev Transfers `tokenId` from `from` to `to`.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     *
     * Emits a {Transfer} event.
     */
    function _transfer(
        address from,
        address to,
        uint256 tokenId
    ) private {
        uint256 prevOwnershipPacked = _packedOwnershipOf(tokenId);

        if (address(uint160(prevOwnershipPacked)) != from) revert TransferFromIncorrectOwner();

        address approvedAddress = _tokenApprovals[tokenId];

        bool isApprovedOrOwner = (_msgSenderERC721A() == from ||
            isApprovedForAll(from, _msgSenderERC721A()) ||
            approvedAddress == _msgSenderERC721A());

        if (!isApprovedOrOwner) revert TransferCallerNotOwnerNorApproved();
        if (_addressToUint256(to) == 0) revert TransferToZeroAddress();

        _beforeTokenTransfers(from, to, tokenId, 1);

        // Clear approvals from the previous owner.
        if (_addressToUint256(approvedAddress) != 0) {
            delete _tokenApprovals[tokenId];
        }

        // Underflow of the sender's balance is impossible because we check for
        // ownership above and the recipient's balance can't realistically overflow.
        // Counter overflow is incredibly unrealistic as tokenId would have to be 2**256.
        unchecked {
            // We can directly increment and decrement the balances.
            --_packedAddressData[from]; // Updates: `balance -= 1`.
            ++_packedAddressData[to]; // Updates: `balance += 1`.

            // Updates:
            // - `address` to the next owner.
            // - `startTimestamp` to the timestamp of transfering.
            // - `burned` to `false`.
            // - `nextInitialized` to `true`.
            _packedOwnerships[tokenId] =
                _addressToUint256(to) |
                (block.timestamp << BITPOS_START_TIMESTAMP) |
                BITMASK_NEXT_INITIALIZED;

            // If the next slot may not have been initialized (i.e. `nextInitialized == false`) .
            if (prevOwnershipPacked & BITMASK_NEXT_INITIALIZED == 0) {
                uint256 nextTokenId = tokenId + 1;
                // If the next slot's address is zero and not burned (i.e. packed value is zero).
                if (_packedOwnerships[nextTokenId] == 0) {
                    // If the next slot is within bounds.
                    if (nextTokenId != _currentIndex) {
                        // Initialize the next slot to maintain correctness for `ownerOf(tokenId + 1)`.
                        _packedOwnerships[nextTokenId] = prevOwnershipPacked;
                    }
                }
            }
        }

        emit Transfer(from, to, tokenId);
        _afterTokenTransfers(from, to, tokenId, 1);
    }

    /**
     * @dev Equivalent to `_burn(tokenId, false)`.
     */
    function _burn(uint256 tokenId) internal virtual {
        _burn(tokenId, false);
    }

    /**
     * @dev Destroys `tokenId`.
     * The approval is cleared when the token is burned.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     *
     * Emits a {Transfer} event.
     */
    function _burn(uint256 tokenId, bool approvalCheck) internal virtual {
        uint256 prevOwnershipPacked = _packedOwnershipOf(tokenId);

        address from = address(uint160(prevOwnershipPacked));
        address approvedAddress = _tokenApprovals[tokenId];

        if (approvalCheck) {
            bool isApprovedOrOwner = (_msgSenderERC721A() == from ||
                isApprovedForAll(from, _msgSenderERC721A()) ||
                approvedAddress == _msgSenderERC721A());

            if (!isApprovedOrOwner) revert TransferCallerNotOwnerNorApproved();
        }

        _beforeTokenTransfers(from, address(0), tokenId, 1);

        // Clear approvals from the previous owner.
        if (_addressToUint256(approvedAddress) != 0) {
            delete _tokenApprovals[tokenId];
        }

        // Underflow of the sender's balance is impossible because we check for
        // ownership above and the recipient's balance can't realistically overflow.
        // Counter overflow is incredibly unrealistic as tokenId would have to be 2**256.
        unchecked {
            // Updates:
            // - `balance -= 1`.
            // - `numberBurned += 1`.
            //
            // We can directly decrement the balance, and increment the number burned.
            // This is equivalent to `packed -= 1; packed += 1 << BITPOS_NUMBER_BURNED;`.
            _packedAddressData[from] += (1 << BITPOS_NUMBER_BURNED) - 1;

            // Updates:
            // - `address` to the last owner.
            // - `startTimestamp` to the timestamp of burning.
            // - `burned` to `true`.
            // - `nextInitialized` to `true`.
            _packedOwnerships[tokenId] =
                _addressToUint256(from) |
                (block.timestamp << BITPOS_START_TIMESTAMP) |
                BITMASK_BURNED |
                BITMASK_NEXT_INITIALIZED;

            // If the next slot may not have been initialized (i.e. `nextInitialized == false`) .
            if (prevOwnershipPacked & BITMASK_NEXT_INITIALIZED == 0) {
                uint256 nextTokenId = tokenId + 1;
                // If the next slot's address is zero and not burned (i.e. packed value is zero).
                if (_packedOwnerships[nextTokenId] == 0) {
                    // If the next slot is within bounds.
                    if (nextTokenId != _currentIndex) {
                        // Initialize the next slot to maintain correctness for `ownerOf(tokenId + 1)`.
                        _packedOwnerships[nextTokenId] = prevOwnershipPacked;
                    }
                }
            }
        }

        emit Transfer(from, address(0), tokenId);
        _afterTokenTransfers(from, address(0), tokenId, 1);

        // Overflow not possible, as _burnCounter cannot be exceed _currentIndex times.
        unchecked {
            _burnCounter++;
        }
    }

    /**
     * @dev Internal function to invoke {IERC721Receiver-onERC721Received} on a target contract.
     *
     * @param from address representing the previous owner of the given token ID
     * @param to target address that will receive the tokens
     * @param tokenId uint256 ID of the token to be transferred
     * @param _data bytes optional data to send along with the call
     * @return bool whether the call correctly returned the expected magic value
     */
    function _checkContractOnERC721Received(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) private returns (bool) {
        try ERC721A__IERC721Receiver(to).onERC721Received(_msgSenderERC721A(), from, tokenId, _data) returns (
            bytes4 retval
        ) {
            return retval == ERC721A__IERC721Receiver(to).onERC721Received.selector;
        } catch (bytes memory reason) {
            if (reason.length == 0) {
                revert TransferToNonERC721ReceiverImplementer();
            } else {
                assembly {
                    revert(add(32, reason), mload(reason))
                }
            }
        }
    }

    /**
     * @dev Hook that is called before a set of serially-ordered token ids are about to be transferred. This includes minting.
     * And also called before burning one token.
     *
     * startTokenId - the first token id to be transferred
     * quantity - the amount to be transferred
     *
     * Calling conditions:
     *
     * - When `from` and `to` are both non-zero, `from`'s `tokenId` will be
     * transferred to `to`.
     * - When `from` is zero, `tokenId` will be minted for `to`.
     * - When `to` is zero, `tokenId` will be burned by `from`.
     * - `from` and `to` are never both zero.
     */
    function _beforeTokenTransfers(
        address from,
        address to,
        uint256 startTokenId,
        uint256 quantity
    ) internal virtual {}

    /**
     * @dev Hook that is called after a set of serially-ordered token ids have been transferred. This includes
     * minting.
     * And also called after one token has been burned.
     *
     * startTokenId - the first token id to be transferred
     * quantity - the amount to be transferred
     *
     * Calling conditions:
     *
     * - When `from` and `to` are both non-zero, `from`'s `tokenId` has been
     * transferred to `to`.
     * - When `from` is zero, `tokenId` has been minted for `to`.
     * - When `to` is zero, `tokenId` has been burned by `from`.
     * - `from` and `to` are never both zero.
     */
    function _afterTokenTransfers(
        address from,
        address to,
        uint256 startTokenId,
        uint256 quantity
    ) internal virtual {}

    /**
     * @dev Returns the message sender (defaults to `msg.sender`).
     *
     * If you are writing GSN compatible contracts, you need to override this function.
     */
    function _msgSenderERC721A() internal view virtual returns (address) {
        return msg.sender;
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function _toString(uint256 value) internal pure returns (string memory ptr) {
        assembly {
            // The maximum value of a uint256 contains 78 digits (1 byte per digit),
            // but we allocate 128 bytes to keep the free memory pointer 32-byte word aliged.
            // We will need 1 32-byte word to store the length,
            // and 3 32-byte words to store a maximum of 78 digits. Total: 32 + 3 * 32 = 128.
            ptr := add(mload(0x40), 128)
            // Update the free memory pointer to allocate.
            mstore(0x40, ptr)

            // Cache the end of the memory to calculate the length later.
            let end := ptr

            // We write the string from the rightmost digit to the leftmost digit.
            // The following is essentially a do-while loop that also handles the zero case.
            // Costs a bit more than early returning for the zero case,
            // but cheaper in terms of deployment and overall runtime costs.
            for {
                // Initialize and perform the first pass without check.
                let temp := value
                // Move the pointer 1 byte leftwards to point to an empty character slot.
                ptr := sub(ptr, 1)
                // Write the character to the pointer. 48 is the ASCII index of '0'.
                mstore8(ptr, add(48, mod(temp, 10)))
                temp := div(temp, 10)
            } temp {
                // Keep dividing `temp` until zero.
                temp := div(temp, 10)
            } { // Body of the for loop.
                ptr := sub(ptr, 1)
                mstore8(ptr, add(48, mod(temp, 10)))
            }

            let length := sub(end, ptr)
            // Move the pointer 32 bytes leftwards to make room for the length.
            ptr := sub(ptr, 32)
            // Store the length.
            mstore(ptr, length)
        }
    }
}

// SPDX-License-Identifier: MIT
// ERC721A Contracts v4.0.0
// Creator: Chiru Labs

pragma solidity 0.8.4;

/**
 * @dev Interface of an ERC721A compliant contract.
 */
interface IERC721A {
    /**
     * The caller must own the token or be an approved operator.
     */
    error ApprovalCallerNotOwnerNorApproved();

    /**
     * The token does not exist.
     */
    error ApprovalQueryForNonexistentToken();

    /**
     * The caller cannot approve to their own address.
     */
    error ApproveToCaller();

    /**
     * The caller cannot approve to the current owner.
     */
    error ApprovalToCurrentOwner();

    /**
     * Cannot query the balance for the zero address.
     */
    error BalanceQueryForZeroAddress();

    /**
     * Cannot mint to the zero address.
     */
    error MintToZeroAddress();

    /**
     * The quantity of tokens minted must be more than zero.
     */
    error MintZeroQuantity();

    /**
     * The token does not exist.
     */
    error OwnerQueryForNonexistentToken();

    /**
     * The caller must own the token or be an approved operator.
     */
    error TransferCallerNotOwnerNorApproved();

    /**
     * The token must be owned by `from`.
     */
    error TransferFromIncorrectOwner();

    /**
     * Cannot safely transfer to a contract that does not implement the ERC721Receiver interface.
     */
    error TransferToNonERC721ReceiverImplementer();

    /**
     * Cannot transfer to the zero address.
     */
    error TransferToZeroAddress();

    /**
     * The token does not exist.
     */
    error URIQueryForNonexistentToken();

    struct TokenOwnership {
        // The address of the owner.
        address addr;
        // Keeps track of the start time of ownership with minimal overhead for tokenomics.
        uint64 startTimestamp;
        // Whether the token has been burned.
        bool burned;
    }

    /**
     * @dev Returns the total amount of tokens stored by the contract.
     *
     * Burned tokens are calculated here, use `_totalMinted()` if you want to count just minted tokens.
     */
    function totalSupply() external view returns (uint256);

    // ==============================
    //            IERC165
    // ==============================

    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);

    // ==============================
    //            IERC721
    // ==============================

    /**
     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
     */
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /**
     * @dev Returns the number of tokens in ``owner``'s account.
     */
    function balanceOf(address owner) external view returns (uint256 balance);

    /**
     * @dev Returns the owner of the `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function ownerOf(uint256 tokenId) external view returns (address owner);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be have been allowed to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Transfers `tokenId` token from `from` to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {safeTransferFrom} whenever possible.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Gives permission to `to` to transfer `tokenId` token to another account.
     * The approval is cleared when the token is transferred.
     *
     * Only a single account can be approved at a time, so approving the zero address clears previous approvals.
     *
     * Requirements:
     *
     * - The caller must own the token or be an approved operator.
     * - `tokenId` must exist.
     *
     * Emits an {Approval} event.
     */
    function approve(address to, uint256 tokenId) external;

    /**
     * @dev Approve or remove `operator` as an operator for the caller.
     * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.
     *
     * Requirements:
     *
     * - The `operator` cannot be the caller.
     *
     * Emits an {ApprovalForAll} event.
     */
    function setApprovalForAll(address operator, bool _approved) external;

    /**
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);

    // ==============================
    //        IERC721Metadata
    // ==============================

    /**
     * @dev Returns the token collection name.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the token collection symbol.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the Uniform Resource Identifier (URI) for `tokenId` token.
     */
    function tokenURI(uint256 tokenId) external view returns (string memory);
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