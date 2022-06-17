// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./ERC721.sol";
import "./Ownable.sol";
import "./IPancakeBunnies.sol";
import "./BunnyTable.sol";
import "./ReentrancyGuard.sol";
import "./ISquadTable.sol";
import "./IVRFv2Minting.sol";
import "./IVRFv2Duel.sol";
import "./IVRFCoordinatorV2.sol";

contract PancakeDuels is ERC721, Ownable, ReentrancyGuard {

    using Strings for uint;
    using BunnyTable for uint8;

    event Minted(uint id, address holder, uint rndNumber);
    event SchoolPut(uint id, uint timestamp, uint8 skill, bool isBunnies, uint nftId, uint boosterId, address msgSender);
    event SchoolTaken(uint id, uint timestamp, uint boosterId, bool isBunnies, uint nftId, bool isOwnerOfBoth, address msgSender);
    event DuelOpened(uint boosterId, uint nftId, bool isBunnies, uint duelId, address msgSender, uint timestamp);
    event DuelFinished(uint duelId, uint timestamp, uint rnd, bool takerWins, uint mintCount, uint takerBID, address taker); 

    struct Booster {
        uint16 luckiness;
        uint16 cleverness; 
        uint16 cuteness;
        uint16 speediness;
        uint experience;
        uint multiplier;
    }

    struct SchoolEntity {
        bool isAttending;
        bool isBunnies;
        uint timestamp;
        uint nftId;
        uint id;
        uint8 skill;
    }

    struct Duel {
        bool finished;
        address maker;
        uint makerBoosterId;
        address taker;
        uint takerBoosterId;
    }

    struct RoundReadiness {
        bool isMintingReady;
        bool isTimeReady;
    }

    IVRFv2Minting private vrfm;
    IVRFv2Duel private vrfd;
    IPancakeBunnies private pancakeBunniesGetIds;
    ISquadTable private squadTable;
    IVRFCoordinatorV2 vrfc;
    IERC721 private pancakeBunnies;
    IERC721 private pancakeSquad;

    address private vrfmAddress;
    address private vrfdAddress;

    bool internal immutable isTestnet;

    uint private immutable maxSupply = 10_000;
    uint private immutable devSupply = 500;
    uint private immutable startTimestamp;

    uint public currentUserSupply = 0;
    uint public currentDevSupply = 0;
    uint public currentRound = 0;
    uint public duelCount = 0;
    uint public schoolCount = 0;
    uint public rnd = 0;
    uint public testnetTreasureAmount = 0;
    uint private rndNonce = 0;
    uint public mintPrice;
    uint public schoolPrice;
    uint public duelPrice;  
    uint public duelChainLinkFee = 0;
    uint public minMintChainLinkFee = 0;
    uint public maxMintChainLinkFee = 0;

    uint64 private mSubId;
    uint64 private dSubId;

    mapping (uint => Booster) public boosters;
    mapping (uint => SchoolEntity) public schoolEntities;
    mapping (uint => RoundReadiness) public round2Readiness;
    mapping (uint => bool) public bunniesLocks;
    mapping (uint => bool) public squadsLocks;
    mapping (uint => bool) public boosterId2ActiveDuel;
    mapping (uint => uint) public duelTimestamps;
    mapping (uint => uint) public round2Fund;
    mapping (uint => uint) public round2MultiplierCount;
    mapping (uint => mapping (uint => bool)) public round2ID2Withdrawn;
    mapping (uint => mapping (uint => uint)) public round2ID2Multiplier;

    Duel[] public duels;

    constructor(address _pb, address _ps, address _st, address _vrfc, address _vrf, address _vrfd, bool _isTestnet) 
        ERC721("Pancake Duels", "PD") Ownable() ReentrancyGuard() {
        pancakeBunnies = IERC721(_pb);
        pancakeSquad = IERC721(_ps);
        pancakeBunniesGetIds = IPancakeBunnies(_pb);
        squadTable = ISquadTable(_st);
        vrfm = IVRFv2Minting(_vrf);
        vrfmAddress = _vrf;
        vrfd = IVRFv2Duel(_vrfd);
        vrfdAddress = _vrfd;
        vrfc = IVRFCoordinatorV2(_vrfc);
        isTestnet = _isTestnet;

        mintPrice = _isTestnet ? 0.0035 ether : 0.1 ether;
        schoolPrice = _isTestnet ? 0.000164 ether : 0.004864 ether;
        duelPrice = _isTestnet ? 0.00025 ether : 0.0165 ether; 
        startTimestamp = block.timestamp;
    }

    function setSubs(uint64 mid, uint64 did) external onlyOwner {
        mSubId = mid;
        dSubId = did;
    }

    function setPrices(uint mp, uint sp, uint dp) external onlyOwner {
        mintPrice = mp;
        schoolPrice = sp;
        duelPrice = dp;
    }

    function setChainLinkFees(uint df, uint minMF, uint maxMF) external onlyOwner {
        require((duelPrice - duelPrice / 20) / 2 > df, "Too high df");
        require(mintPrice - mintPrice / 20 > maxMF, "Too high mf");
        require(minMF < maxMF, "min >= max");
        duelChainLinkFee = df;
        minMintChainLinkFee = minMF;
        maxMintChainLinkFee = maxMF;
    }

    function getBooster(uint id) external view returns (uint16, uint16, uint16, uint16, uint, uint) {
        Booster storage b = boosters[id];
        return (b.luckiness, b.cleverness, b.cuteness, b.speediness, b.experience, b.multiplier);
    }

    function mint(uint qty) external payable nonReentrant {
        require(qty > 0, "qty == 0. ");
        require(qty <= 40, "Too large qty. ");
        (uint96 clBalance,,,) = vrfc.getSubscription(mSubId);
        require(clBalance >= 1 ether, "Not enough CL");
        bool isDev = msg.sender == owner();
        if (!isDev)
            require(msg.value == qty * mintPrice, "Ether sent is not correct. ");

        checkRoundTimeAndSet();
        uint reqId = vrfm.requestRandomWords();
        uint id = !isDev ? currentUserSupply : (maxSupply - devSupply + currentDevSupply); 
        vrfm.setMint(reqId, id, qty, isDev, msg.sender);

        if (!isDev) {
            uint devFee = msg.value / 20 + calcMintChainLinkFee(qty);
            (bool success, ) = owner().call{value: devFee}("");
            require(success, "Error sending tx. ");
        }
    }

    function calcMintChainLinkFee(uint qty) internal view returns(uint) {
        return minMintChainLinkFee + qty * (maxMintChainLinkFee - minMintChainLinkFee) / 40;
    }

    function joinDuel(uint boosterId, uint nftId, bool isBunnies, uint duelId) 
        external payable checkDuelBasics(boosterId) nonReentrant {
        checkOwnerships(boosterId, nftId, isBunnies);
        require(duelCount > duelId, "No such duel id. ");
        require(duels[duelId].maker != msg.sender, "You are the duel maker. ");
        require(!duels[duelId].finished, "Duel finished. ");
        (uint96 clBalance,,,) = vrfc.getSubscription(dSubId);
        require(clBalance >= 0.135 ether, "Not enough CL");

        Duel storage duel = duels[duelId];
        Booster storage tb = boosters[boosterId];
        Booster storage mb = boosters[duel.makerBoosterId];
        require(mb.luckiness > tb.luckiness 
            || mb.cleverness > tb.cleverness
            || mb.cuteness > tb.cuteness
            || mb.speediness > tb.speediness
            || mb.experience > tb.experience
            , "Too imba to attack");
        duel.taker = msg.sender;
        duel.takerBoosterId = boosterId;

        uint reqId = vrfd.requestRandomWords();
        vrfd.setDuel(reqId, duelId);

        checkRoundTimeAndSet();
        distributeValue(duelChainLinkFee, true);
        (bool success, ) = owner().call{value: duelChainLinkFee}("");
        require(success, "Error sending df");
    }

    function fulfillDuel(uint id, uint randomValue) external {
        require(msg.sender == vrfdAddress, "Not VRFD");

        Duel storage duel = duels[id];
        (bool takerIsWinner, uint mintCount) = pickSkillsAndDetermineWinner(duel.takerBoosterId, duel.makerBoosterId, randomValue);

        emit DuelFinished(id, block.timestamp, randomValue, takerIsWinner, mintCount, duel.takerBoosterId, duel.taker);
        duel.finished = true;
        boosterId2ActiveDuel[duel.makerBoosterId] = false;
        duelTimestamps[duel.takerBoosterId] = block.timestamp;
        duelTimestamps[duel.makerBoosterId] = block.timestamp;

        if (mintCount > 0) {
            boosters[takerIsWinner ? duel.takerBoosterId : duel.makerBoosterId].multiplier += mintCount;
            round2MultiplierCount[currentRound] += mintCount;
            round2ID2Multiplier[currentRound][takerIsWinner ? duel.takerBoosterId : duel.makerBoosterId] += mintCount;
        }
    }

    function fulfillMint(uint id, uint randomValue, uint qty, bool isDev, address minter) external {
        require(msg.sender == vrfmAddress, "Not VRFM");

        uint end = id + qty;
        for (uint i = id; i < end; i++) {
            require(isDev ? currentDevSupply < devSupply : 
                currentUserSupply < maxSupply - devSupply, "Max supply reached. ");

            if (!isDev && currentUserSupply > 0 && currentUserSupply % 190 == 0) {
                uint round = (currentUserSupply / 190) - 1;
                round2Readiness[round].isMintingReady = true;
                round2Fund[round] += 190 * (mintPrice - mintPrice / 20 - calcMintChainLinkFee(qty)); 
            }

            uint randomNumber = uint256(keccak256(abi.encode(randomValue, i)));
            boosters[i] = Booster({
                luckiness: uint16(randomNumber & 255) + 1,
                cleverness: uint16((randomNumber >> 8) & 255) + 1,  
                cuteness: uint16((randomNumber >> 16) & 255) + 1, 
                speediness: uint16((randomNumber >> 24) & 255) + 1, 
                multiplier: 0, 
                experience: 0
            });

            _safeMint(minter, i);
            emit Minted(i, minter, randomNumber);
        }

        if (!isDev) {
            currentUserSupply += qty; 
        } else {
            currentDevSupply += qty; 
        }
    }

    function putToSchool(uint boosterId, uint nftId, bool isBunnies, uint8 skill) external payable nonReentrant {
        require(skill <= 3, "Skill must be between 0-3. ");
        require(msg.value == schoolPrice, "Not enough money sent. ");
        SchoolEntity storage se = schoolEntities[boosterId];
        require(!se.isAttending, "Booster NFT already in School. ");
        if (isBunnies) {
            require(!bunniesLocks[nftId], "NFT already in School. ");
        } else {
            require(!squadsLocks[nftId], "NFT already in School. ");
        }

        checkRoundTimeAndSet();
        checkOwnerships(boosterId, nftId, isBunnies);

        emit SchoolPut(schoolCount++, block.timestamp, skill, isBunnies, nftId, boosterId, msg.sender);
        se.timestamp = block.timestamp;
        se.skill = skill;
        se.isAttending = true;
        se.isBunnies = isBunnies;
        se.nftId = nftId;
        se.id = schoolCount - 1;
        if (isBunnies) {
            bunniesLocks[nftId] = true;
        } else {
            squadsLocks[nftId] = true;
        }

        distributeValue(0, false);
    }

    function takeOutOfSchool(uint boosterId) external {
        SchoolEntity storage se = schoolEntities[boosterId];
        require(se.isAttending, "Booster NFT not in School. ");
        if (se.isBunnies) { // Checks just in case, but it really should always be attending when booster is attending. 
            require(bunniesLocks[se.nftId], "NFT not in School. ");
        } else {
            require(squadsLocks[se.nftId], "NFT not in School. ");
        }
        if (isTestnet) {
            require(se.timestamp + 2 minutes <= block.timestamp, "Too early too be take out. ");
        } else {
            require(se.timestamp + 8 hours <= block.timestamp, "Too early too be take out. ");
        }

        bool isBoosterOwner = ownerOf(boosterId) == msg.sender;
        IERC721 ierc721 = se.isBunnies ? pancakeBunnies : pancakeSquad;
        bool isNFTOwner = ierc721.ownerOf(se.nftId) == msg.sender;
        require(isBoosterOwner || isNFTOwner, "You have to be either booster or nft owner. ");

        checkRoundTimeAndSet();
        emit SchoolTaken(se.id, block.timestamp, boosterId, se.isBunnies, se.nftId, isBoosterOwner == isNFTOwner, msg.sender);
        se.isAttending = false;
        if (se.isBunnies) {
            bunniesLocks[se.nftId] = false;
        } else {
            squadsLocks[se.nftId] = false;
        }

        if (isBoosterOwner == isNFTOwner) {
            addToSkills(boosterId, se);     
        }
    }

    function openDuel(uint boosterId, uint nftId, bool isBunnies) external payable checkDuelBasics(boosterId) nonReentrant {
        checkOwnerships(boosterId, nftId, isBunnies);
        (uint96 clBalance,,,) = vrfc.getSubscription(dSubId);
        require(clBalance >= 0.135 ether, "Not enough CL");

        emit DuelOpened(boosterId, nftId, isBunnies, duelCount, msg.sender, block.timestamp);
        boosterId2ActiveDuel[boosterId] = true;
        duels.push(Duel({ finished: false, maker: msg.sender, makerBoosterId: boosterId, taker: address(0), takerBoosterId: 10000 }));
        duelCount += 1;

        checkRoundTimeAndSet();
        distributeValue(duelChainLinkFee, true);
        (bool success, ) = owner().call{value: duelChainLinkFee}("");
        require(success, "Error sending df");
    }

    function withdrawTreasure(uint boosterId, uint round) external nonReentrant returns (uint amount) {
        require(ownerOf(boosterId) == msg.sender, "Not owner");
        require(!round2ID2Withdrawn[round][boosterId], "Already withdrawn");
        RoundReadiness storage readiness = round2Readiness[round];
        if (currentRound < 50)
            require(readiness.isMintingReady && readiness.isTimeReady, "Round not ready");
        else 
            require(readiness.isTimeReady, "Round not ready");
        require(round2MultiplierCount[round] > 0, "No multipliers");

        amount = round2ID2Multiplier[round][boosterId] * round2Fund[round] / round2MultiplierCount[round];
        round2ID2Withdrawn[round][boosterId] = true;
        if (isTestnet) {
            testnetTreasureAmount = amount;
        }

        checkRoundTimeAndSet();
        (bool success, ) = msg.sender.call{value: amount}("");
        require(success, "Error sending tx");
    }

    function checkRoundTimeAndSet() private {
        uint round = calculateRound();
        if (round > currentRound) {
            for (uint i = currentRound; i < round; i++) {
                round2Readiness[i].isTimeReady = true;
            }
            currentRound = round;
        }
    }

    function calculateRound() public view returns(uint) {
        return (block.timestamp - startTimestamp) / (isTestnet ? 30 minutes : 7 days);
    }

    function pickSkillsAndDetermineWinner(uint bId, uint mbId, uint rndNum) private 
     returns(bool takerIsWinner, uint mintCount) {
        Booster storage tb = boosters[bId];
        Booster storage mb = boosters[mbId];

        uint mv = (mb.luckiness + mb.cleverness + mb.cuteness + mb.speediness) / 4;
        uint tv = (tb.luckiness + tb.cleverness + tb.cuteness + tb.speediness) / 4;
        mintCount = mv > tv ? mv : tv;
        uint temp = (rndNum & 7) % 5; 
        if (temp == 0) {
            takerIsWinner = tb.luckiness > mb.luckiness;
        } else if (temp == 1) {
            takerIsWinner = tb.cleverness > mb.cleverness;
        }  else if (temp == 2) {
            takerIsWinner = tb.cuteness > mb.cuteness;
        } else if (temp == 3) {
            takerIsWinner = tb.speediness > mb.speediness;
        } else {
            takerIsWinner = tb.experience > mb.experience;
        }

        if (mb.luckiness >= tb.luckiness) {
            tb.experience += 1;
        } else {
            mb.experience += 1;
        }
        if (mb.cleverness >= tb.cleverness) {
            tb.experience += 1;
        } else {
            mb.experience += 1;
        }
        if (mb.cuteness >= tb.cuteness) {
            tb.experience += 1;
        } else {
            mb.experience += 1;
        }
        if (mb.speediness >= tb.speediness) {
            tb.experience += 1;
        } else {
            mb.experience += 1;
        }
        if (mb.experience >= tb.experience) {
            tb.experience += 1;
        } else {
            mb.experience += 1;
        }
    }

    modifier checkDuelBasics(uint boosterId) {
        require(!boosterId2ActiveDuel[boosterId], "You have opened a duel. ");
        require(msg.value == duelPrice, "Not enough money sent. ");
        require(duelTimestamps[boosterId] + 15 minutes <= block.timestamp, "Too early to duel. ");
        _;
    }

    function checkOwnerships(uint boosterId, uint nftId, bool isBunnies) private view {
        require(ownerOf(boosterId) == msg.sender, "You are not the Booster owner. ");
        IERC721 ierc721 = isBunnies ? pancakeBunnies : pancakeSquad;
        require(ierc721.ownerOf(nftId) == msg.sender, "You are not the NFT owner. ");
    }

    function addToSkills(uint boosterId, SchoolEntity storage se) private {
        uint16 sa =  se.isBunnies ? pancakeBunniesGetIds.getBunnyId(se.nftId).getSkillAdd() : squadTable.getRank(se.nftId);
        Booster storage booster = boosters[boosterId];
        unchecked {
            if (se.skill == 0) {
                booster.luckiness += sa;
                if (booster.luckiness <= sa) {
                    booster.luckiness = type(uint16).max;
                }
            } else if (se.skill == 1) {
                booster.cleverness += sa;
                if (booster.cleverness <= sa) {
                    booster.cleverness = type(uint16).max;
                }
            } else if (se.skill == 2) {
                booster.cuteness += sa;
                if (booster.cuteness <= sa) {
                    booster.cuteness = type(uint16).max;
                }
            } else {
                booster.speediness += sa;
                if (booster.speediness <= sa) {
                    booster.speediness = type(uint16).max;
                }
            }
        }         
    }

    function distributeValue(uint clFee, bool applyDevFee) private {
        uint devFee = applyDevFee ? msg.value / 20 : 0;
        uint treasuryFee = msg.value - devFee - clFee; 
        round2Fund[currentRound] += treasuryFee;
        (bool success, ) = owner().call{value: devFee}("");
        require(success, "Error sending tx. ");
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import "./IERC721.sol";
import "./IERC721Receiver.sol";
import "./IERC721Metadata.sol";
import "./Address.sol";
import "./Strings.sol";
import "./ERC165.sol";

contract ERC721 is ERC165, IERC721, IERC721Metadata {
    using Address for address;
    using Strings for uint256;

    string private _name;

    string private _symbol;

    mapping(uint256 => address) private _owners;

    mapping(address => uint256) private _balances;

    mapping(uint256 => address) private _tokenApprovals;

    mapping(address => mapping(address => bool)) private _operatorApprovals;

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return
            interfaceId == type(IERC721).interfaceId ||
            interfaceId == type(IERC721Metadata).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    function balanceOf(address owner) public view virtual override returns (uint256) {
        require(owner != address(0), "ERC721: balance query for the zero address");
        return _balances[owner];
    }

    function ownerOf(uint256 tokenId) public view virtual override returns (address) {
        address owner = _owners[tokenId];
        require(owner != address(0), "ERC721: owner query for nonexistent token");
        return owner;
    }

    function name() public view virtual override returns (string memory) {
        return _name;
    }

    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "nonexistent token");

        string memory bu = _baseURI();
        return bytes(bu).length > 0 ? string(abi.encodePacked(bu, tokenId.toString(), ".json")) : "";
    }

    function _baseURI() internal view virtual returns (string memory) {
        return "https://www.pancakeduels.com/";
    }

    function approve(address to, uint256 tokenId) public virtual override {
        address owner = ERC721.ownerOf(tokenId);
        require(to != owner, "ERC721: approval to current owner");

        require(
            msg.sender == owner || isApprovedForAll(owner, msg.sender),
            "ERC721: approve caller is not owner nor approved for all"
        );

        _approve(to, tokenId);
    }

    function getApproved(uint256 tokenId) public view virtual override returns (address) {
        require(_exists(tokenId), "ERC721: approved query for nonexistent token");

        return _tokenApprovals[tokenId];
    }

    function setApprovalForAll(address operator, bool approved) public virtual override {
        _setApprovalForAll(msg.sender, operator, approved);
    }

    function isApprovedForAll(address owner, address operator) public view virtual override returns (bool) {
        return _operatorApprovals[owner][operator];
    }

    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] memory ids
    ) public {
        require(
            from == msg.sender || isApprovedForAll(from, msg.sender),
            "Caller is not owner nor approved"
        );
        _safeBatchTransferFrom(from, to, ids);
    }

    function _safeBatchTransferFrom(
        address from,
        address to,
        uint256[] memory ids
    ) internal virtual {
        require(to != address(0), "Transfer to the 0 address");

        for (uint256 i = 0; i < ids.length; ++i) {
            safeTransferFrom(from, to, ids[i]);
        }
    }

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        //solhint-disable-next-line max-line-length
        require(_isApprovedOrOwner(msg.sender, tokenId), "ERC721: transfer caller is not owner nor approved");

        _transfer(from, to, tokenId);
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        safeTransferFrom(from, to, tokenId, "");
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) public virtual override {
        require(_isApprovedOrOwner(msg.sender, tokenId), "ERC721: transfer caller is not owner nor approved");
        _safeTransfer(from, to, tokenId, _data);
    }

    function _safeTransfer(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) internal virtual {
        _transfer(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, _data), "ERC721: transfer to non ERC721Receiver implementer");
    }

    function _exists(uint256 tokenId) internal view virtual returns (bool) {
        return _owners[tokenId] != address(0);
    }

    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view virtual returns (bool) {
        require(_exists(tokenId), "ERC721: operator query for nonexistent token");
        address owner = ERC721.ownerOf(tokenId);
        return (spender == owner || isApprovedForAll(owner, spender) || getApproved(tokenId) == spender);
    }

    function _safeMint(address to, uint256 tokenId) internal virtual {
        _safeMint(to, tokenId, "");
    }

    function _safeMint(
        address to,
        uint256 tokenId,
        bytes memory _data
    ) internal virtual {
        _mint(to, tokenId);
        require(
            _checkOnERC721Received(address(0), to, tokenId, _data),
            "ERC721: transfer to non ERC721Receiver implementer"
        );
    }

    function _mint(address to, uint256 tokenId) internal virtual {
        require(to != address(0), "ERC721: mint to the zero address");
        require(!_exists(tokenId), "ERC721: token already minted");

        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(address(0), to, tokenId);
    }

    function _transfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {
        require(ERC721.ownerOf(tokenId) == from, "ERC721: transfer from incorrect owner");
        require(to != address(0), "ERC721: transfer to the zero address");

        // Clear approvals from the previous owner
        _approve(address(0), tokenId);

        _balances[from] -= 1;
        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(from, to, tokenId);
    }

    function _approve(address to, uint256 tokenId) internal virtual {
        _tokenApprovals[tokenId] = to;
        emit Approval(ERC721.ownerOf(tokenId), to, tokenId);
    }

    function _setApprovalForAll(
        address owner,
        address operator,
        bool approved
    ) internal virtual {
        require(owner != operator, "ERC721: approve to caller");
        _operatorApprovals[owner][operator] = approved;
        emit ApprovalForAll(owner, operator, approved);
    }

    function _checkOnERC721Received(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) private returns (bool) {
        if (to.isContract()) {
            try IERC721Receiver(to).onERC721Received(msg.sender, from, tokenId, _data) returns (bytes4 retval) {
                return retval == IERC721Receiver.onERC721Received.selector;
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert("ERC721: transfer to non ERC721Receiver implementer");
                } else {
                    assembly {
                        revert(add(32, reason), mload(reason))
                    }
                }
            }
        } else {
            return true;
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

abstract contract Ownable {

    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _transferOwnership(msg.sender);
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
    
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

interface IPancakeBunnies {
    
    function getBunnyId(uint256 _tokenId) external view returns (uint8);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

library BunnyTable {

    function getSkillAdd(uint8 bid) internal pure returns(uint8) {
        if (bid == 20) {
            return 10;
        } else if (bid == 1 || bid == 2 || bid == 3) {
            return 8;
        } else if (bid == 0 || bid == 4 || bid == 21) {
            return 7;
        } else if (bid == 15 || bid == 22 || bid == 24
            || bid == 25) {
            return 5;
        } else if (bid == 10) {
            return 3;
        } else if (bid == 11 || bid == 12 || bid == 13
            || bid == 14 || bid == 16 || bid == 17
            || bid == 18 || bid == 19) {
            return 2;
        } else {
            return 1;
        }
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

abstract contract ReentrancyGuard {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

interface ISquadTable {

    function getRank(uint id) external view returns(uint8);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

interface IVRFv2Minting {

    function requestRandomWords() external returns (uint);

    function setMint(uint rid, uint id, uint qty, bool isDev, address minter) external;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

interface IVRFv2Duel {

    function requestRandomWords() external returns (uint);

    function setDuel(uint rid, uint id) external;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

interface IVRFCoordinatorV2 {

    function getSubscription(uint64 subId) external returns(uint96 balance, uint64 reqCount, address owner, address[] memory consumers);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import "./IERC165.sol";

interface IERC721 is IERC165 {

    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    function balanceOf(address owner) external view returns (uint256 balance);

    function ownerOf(uint256 tokenId) external view returns (address owner);

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    function approve(address to, uint256 tokenId) external;

    function setApprovalForAll(address operator, bool _approved) external;

    function getApproved(uint256 tokenId) external view returns (address operator);

    function isApprovedForAll(address owner, address operator) external view returns (bool);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

interface IERC721Receiver {

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import "./IERC721.sol";

interface IERC721Metadata is IERC721 {

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function tokenURI(uint256 tokenId) external view returns (string memory);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.1;

library Address {

    function isContract(address account) internal view returns (bool) {
        return account.code.length > 0;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

library Strings {

    function toString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import "./IERC165.sol";

abstract contract ERC165 is IERC165 {
    
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}