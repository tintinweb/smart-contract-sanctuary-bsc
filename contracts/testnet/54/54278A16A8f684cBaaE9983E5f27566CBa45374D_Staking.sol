// SPDX-License-Identifier: MIT LICENSE

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

import "./NFT.sol";
import "./Token.sol";
import "./interfaces/IStaking.sol";
import "./interfaces/INFT.sol";
import "./interfaces/IBUCKS.sol";

contract Staking is AccessControl, IERC721Receiver, Pausable {
    /** ===== CONSTANTS ===== **/

    bytes32 public constant DAO = keccak256("DAO");

    // maximum level score
    uint8 public constant MAX_LEVEL = 11;

    // struct to store a stake's token, owner, and earning values
    struct Stake {
        uint16 tokenId;
        uint80 value;
        address owner;
    }

    /** ===== SEMI-CONSTANTS ===== **/

    // reference to the NFT contract
    NFT game;
    // reference to the $token contract for minting $token earnings
    Token token;

    // slave earn 10 $token per day
    uint256 public DAILY_token_RATE = 10 ether;

    // slave must have 2 days worth of $token to unstake or else it's too cold
    uint256 public MINIMUM_TO_EXIT = 1 days;

    // masters take a 20% tax on all $token claimed
    uint256 public token_CLAIM_TAX_PERCENTAGE = 30;

    // there will only ever be (roughly) 2.4 billion $token earned through staking
    uint256 public MAXIMUM_GLOBAL_token = 5000000 ether;

    uint256[] public probabilityToLoseEvryThing = [50, 50, 40, 30, 20, 10]; // (/100)

    // emergency rescue to allow unstaking without any checks but without $token
    bool public rescueEnabled = false;

    bool public canClaim = false;

    /** ===== VARIABLES ===== **/

    // maps tokenId to stake
    mapping(uint256 => Stake) public staking;

    // maps level to all master stakes with that level
    mapping(uint256 => Stake[]) public masterStack;

    // tracks location of each master in masterStack
    mapping(uint256 => uint256) public masterStackIndices;

    mapping(address => uint16[]) public userNFTStack;

    // total level scores staked
    uint256 public totalLevelStaked = 0;

    // any rewards distributed when no masters are staked
    uint256 public unaccountedRewards = 0;

    // amount of $token due for each level point staked
    uint256 public tokenPerLevel = 0;

    // amount of $token earned so far
    uint256 public totalTokenEarned;

    // number of slave staked in the staking
    uint256 public totalSlaveStaked;

    //===========================TODO ==========================
    // number of slave staked in the staking
    uint256 public totalMasterStaked;

    // number of Potus staked in the staking
    uint256 public totalPotusStaked;

    // number of slave staked in the staking
    uint256 public totalSlaveStolen;

    // the last time $token was claimed
    uint256 public lastClaimTimestamp;

    /** ===== EVENTS ===== **/
    event TokenStaked(address owner, uint256 tokenId, uint256 value);

    event SlaveClaimed(uint256 tokenId, uint256 earned, bool unstaked);

    event MasterClaimed(uint256 tokenId, uint256 earned, bool unstaked);

    /** ===== MODIFIER ===== **/
    bool private _reentrant = false;

    modifier nonReentrant() {
        require(!_reentrant, "You can't reentrantry");
        _reentrant = true;
        _;
        _reentrant = false;
    }

    /**
     * tracks $token earnings to ensure it stops once 2.4 billion is eclipsed
     */
    modifier _updateEarnings() {
        if (totalTokenEarned < MAXIMUM_GLOBAL_token) {
            totalTokenEarned +=
                ((block.timestamp - lastClaimTimestamp) *
                    totalSlaveStaked *
                    DAILY_token_RATE) /
                1 days;
            lastClaimTimestamp = block.timestamp;
        }
        _;
    }

    /** ===== CONSTRUCTOR ===== **/

    constructor(address _NFT, address payable _token) {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        grantRole(DAO, msg.sender);

        game = NFT(_NFT);
        token = Token(_token);
        _pause();
    }

    /** ===== EXTERNAL METHODS ===== **/

    /**
     * adds slave and masters to the staking and masterStack
     * @param account the address of the staker
     * @param tokenIds the IDs of the slave and masters to stake
     */
    function addManyToStaking(address account, uint16[] calldata tokenIds)
        external
        whenNotPaused
        nonReentrant
    {
        require(
            (account == _msgSender() && account == tx.origin) ||
                _msgSender() == address(game),
            "This is not the correct address"
        );

        for (uint256 i = 0; i < tokenIds.length; i++) {
            if (tokenIds[i] == 0) {
                continue;
            }

            _add(account, tokenIds[i]);

            if (_msgSender() != address(game)) {
                // dont do this step if its a mint + stake
                require(
                    game.ownerOf(tokenIds[i]) == _msgSender(),
                    "Don't play with other's Token"
                );
                game.transferFrom(_msgSender(), address(this), tokenIds[i]);
            }

            if (isSlave(tokenIds[i])) _addSlaveToStaking(account, tokenIds[i]);
            else _addMasterToMasterStack(account, tokenIds[i]);
        }
    }

    function claimAll() external {
        require(msg.sender == tx.origin, "Only Externally Owned Account");
        require(canClaim, "Claim is not currently possible");
        claimManyFromStaking(userNFTStack[_msgSender()], false);
        // claimManyFromStaking(this.getTokensOf(msg.sender),false);
    }

    function unstakeAll() external {
        require(msg.sender == tx.origin, "Only Externally Owned Account");
        require(canClaim, "Claim is not currently possible");
        claimManyFromStaking(userNFTStack[_msgSender()], true);
        // claimManyFromStaking(this.getTokensOf(msg.sender),true);
    }

    /**
     * realize $token earnings and optionally unstake tokens from the staking / masterStack
     * to unstake a slave it will require it has 2 days worth of $token unclaimed
     * @param tokenIds the IDs of the tokens to claim earnings from
     * @param unstake whether or not to unstake ALL of the tokens listed in tokenIds
     */
    function claimManyFromStaking(uint16[] memory tokenIds, bool unstake)
        public
        nonReentrant
        whenNotPaused
        _updateEarnings
    {
        require(
            msg.sender == tx.origin || tx.origin == address(this),
            "Only Externally Owned Account"
        );
        require(canClaim, "Claim is not currently possible");

        uint256 owed = 0;
        for (uint256 i = 0; i < tokenIds.length; i++) {
            if (isSlave(tokenIds[i]))
                owed += _claimSlaveFromStaking(tokenIds[i], unstake);
            else owed += _claimMasterFromMasterStack(tokenIds[i], unstake);
        }
        if (owed == 0) return;
        token.mintDAO(_msgSender(), owed);
    }

    /**
     * emergency unstake tokens
     * @param tokenIds the IDs of the tokens to claim earnings from
     */
    function rescue(uint256[] calldata tokenIds) external nonReentrant {
        require(rescueEnabled, "RESCUE not activated");
        uint256 tokenId;
        Stake memory stake;
        Stake memory lastStake;
        uint256 level;
        for (uint256 i = 0; i < tokenIds.length; i++) {
            tokenId = tokenIds[i];
            _remove(_msgSender(), tokenId);
            if (isSlave(tokenId)) {
                stake = staking[tokenId];
                require(stake.owner == _msgSender(), "Not your properties");
                game.transferFrom(address(this), _msgSender(), tokenId);
                // send back slave
                delete staking[tokenId];
                totalSlaveStaked -= 1;
                emit SlaveClaimed(tokenId, 0, true);
            } else {
                level = _levelForMaster(tokenId);
                stake = masterStack[level][masterStackIndices[tokenId]];
                require(stake.owner == _msgSender(), "Not your properties");
                totalLevelStaked -= level;

                // Decrease the counter of master/POTUS stack
                INFT.NFTMetadata memory s = game.getTokenMetadata(tokenId);
                if (s.Shift == 10) {
                    totalMasterStaked -= 1;
                } else {
                    totalPotusStaked -= 1;
                }

                // Remove Level from total staked
                game.transferFrom(address(this), _msgSender(), tokenId);
                // Send back master
                lastStake = masterStack[level][masterStack[level].length - 1];
                masterStack[level][masterStackIndices[tokenId]] = lastStake;
                // Shuffle last master to current position
                masterStackIndices[lastStake.tokenId] = masterStackIndices[
                    tokenId
                ];
                masterStack[level].pop();
                // Remove duplicate
                delete masterStackIndices[tokenId];
                // Delete old mapping
                emit MasterClaimed(tokenId, 0, true);
            }
        }
    }

    /** ===== INTERNAL METHODS ===== **/

    /**
     * adds a single slave to the staking
     * @param account the address of the staker
     * @param tokenId the ID of the slave to add to the staking
     */
    function _addSlaveToStaking(address account, uint256 tokenId)
        internal
        whenNotPaused
        _updateEarnings
    {
        staking[tokenId] = Stake({
            owner: account,
            tokenId: uint16(tokenId),
            value: uint80(block.timestamp)
        });
        totalSlaveStaked += 1;
        emit TokenStaked(account, tokenId, block.timestamp);
    }

    // function _addSlaveToStakingWithTime(
    //   address account,
    //   uint256 tokenId,
    //   uint256 time
    // ) internal {
    //   totalTokenEarned +=
    //     ((time - lastClaimTimestamp) * totalSlaveStaked * DAILY_token_RATE) /
    //     1 days;

    //   staking[tokenId] = Stake({
    //     owner: account,
    //     tokenId: uint16(tokenId),
    //     value: uint80(time)
    //   });
    //   totalSlaveStaked += 1;
    //   emit TokenStaked(account, tokenId, time);
    // }

    /**
     * adds a single master to the masterStack
     * @param account the address of the staker
     * @param tokenId the ID of the master to add to the masterStack
     */
    function _addMasterToMasterStack(address account, uint256 tokenId)
        internal
    {
        uint256 level = _levelForMaster(tokenId);
        totalLevelStaked += level;
        // Portion of earnings ranges from 1 to 11
        masterStackIndices[tokenId] = masterStack[level].length;

        // Store the location of the master in the masterStack
        masterStack[level].push(
            Stake({
                owner: account,
                tokenId: uint16(tokenId),
                value: uint80(tokenPerLevel)
            })
        );

        INFT.NFTMetadata memory s = game.getTokenMetadata(tokenId);
        if (s.Shift == 10) {
            totalMasterStaked += 1;
        } else {
            totalPotusStaked += 1;
        }

        emit TokenStaked(account, tokenId, tokenPerLevel);
    }

    /**
     * realize $token earnings for a single slave and optionally unstake it
     * if not unstaking, pay a 20% tax to the staked masters
     * if unstaking, there is a 50% chance all $token is stolen
     * @param tokenId the ID of the slave to claim earnings from
     * @param unstake whether or not to unstake the slave
     * @return owed - the amount of $token earned
     */
    function _claimSlaveFromStaking(uint256 tokenId, bool unstake)
        internal
        returns (uint256 owed)
    {
        Stake memory stake = staking[tokenId];
        require(stake.owner == _msgSender(), "Not your properties");
        //require(!(unstake && block.timestamp - stake.value < MINIMUM_TO_EXIT),"You have to wait to have enough rewards");
        if (block.timestamp - stake.value > MINIMUM_TO_EXIT) {
            if (totalTokenEarned < MAXIMUM_GLOBAL_token) {
                owed =
                    ((block.timestamp - stake.value) * DAILY_token_RATE) /
                    1 days;
                token.bridgeAddClaimedTokens(_msgSender(), owed);
            } else if (stake.value > lastClaimTimestamp) {
                owed = 0;
                // $token production stopped already
            } else {
                owed =
                    ((lastClaimTimestamp - stake.value) * DAILY_token_RATE) /
                    1 days;
                token.bridgeAddClaimedTokens(_msgSender(), owed);
                // stop earning additional $token if it's all been earned
            }

            if (unstake) {
                uint256 numberOfDaysFromLastClaim = ((block.timestamp -
                    stake.value) / 1 days);
                address recipient = _msgSender();

                if (
                    random(tokenId) % 100 <
                    probabilityToLoseEvryThing[numberOfDaysFromLastClaim]
                ) {
                    recipient = randomMasterOwner(tokenId);
                    _payMasterTax(owed);
                    owed = 0;
                    totalSlaveStolen += 1;
                }

                _remove(_msgSender(), tokenId);
                delete staking[tokenId];
                totalSlaveStaked -= 1;

                game.transferFrom(address(this), recipient, tokenId);
            } else {
                _payMasterTax((owed * token_CLAIM_TAX_PERCENTAGE) / 100);
                // percentage tax to staked masters
                owed = (owed * (100 - token_CLAIM_TAX_PERCENTAGE)) / 100;
                // remainder goes to slave owner
                staking[tokenId] = Stake({
                    owner: _msgSender(),
                    tokenId: uint16(tokenId),
                    value: uint80(block.timestamp)
                });
                // reset stake
            }
            emit SlaveClaimed(tokenId, owed, unstake);
        }
    }

    /**
     * realize $token earnings for a single master and optionally unstake it
     * masters earn $token proportional to their Level rank
     * @param tokenId the ID of the master to claim earnings from
     * @param unstake whether or not to unstake the master
     * @return owed - the amount of $token earned
     */
    function _claimMasterFromMasterStack(uint256 tokenId, bool unstake)
        internal
        returns (uint256 owed)
    {
        require(game.ownerOf(tokenId) == address(this), "Wrong NFT");
        uint256 level = _levelForMaster(tokenId);
        Stake memory stake = masterStack[level][masterStackIndices[tokenId]];
        require(stake.owner == _msgSender(), "Not your properties");
        owed = (level) * (tokenPerLevel - stake.value);
        token.bridgeAddClaimedTokens(_msgSender(), owed);

        // Calculate portion of tokens based on Level
        if (unstake) {
            _remove(_msgSender(), tokenId);
            totalLevelStaked -= level;
            // Remove Level from total staked
            game.transferFrom(address(this), _msgSender(), tokenId);
            // Send back master
            Stake memory lastStake = masterStack[level][
                masterStack[level].length - 1
            ];
            masterStack[level][masterStackIndices[tokenId]] = lastStake;
            // Shuffle last master to current position
            masterStackIndices[lastStake.tokenId] = masterStackIndices[tokenId];
            masterStack[level].pop();
            // Remove duplicate
            delete masterStackIndices[tokenId];
            // Delete old mapping

            // Decrease the counter of master/POTUS stack
            INFT.NFTMetadata memory s = game.getTokenMetadata(tokenId);
            if (s.Shift == 10) {
                totalMasterStaked -= 1;
            } else {
                totalPotusStaked -= 1;
            }
        } else {
            masterStack[level][masterStackIndices[tokenId]] = Stake({
                owner: _msgSender(),
                tokenId: uint16(tokenId),
                value: uint80(tokenPerLevel)
            });
            // reset stake
        }
        emit MasterClaimed(tokenId, owed, unstake);
    }

    /**
     * add $token to claimable pot for the masterStack
     * @param amount $token to add to the pot
     */
    function _payMasterTax(uint256 amount) internal {
        if (totalLevelStaked == 0) {
            // if there's no staked masters
            unaccountedRewards += amount;
            // keep track of $token due to masters
            return;
        }
        // makes sure to include any unaccounted $token
        tokenPerLevel += (amount + unaccountedRewards) / totalLevelStaked;
        unaccountedRewards = 0;
    }

    function _remove(address account, uint256 _tokenId) internal {
        for (uint256 i = 0; i < userNFTStack[account].length; i++) {
            if (userNFTStack[account][i] == _tokenId) {
                userNFTStack[account][i] = userNFTStack[account][
                    userNFTStack[account].length - 1
                ];
                userNFTStack[account].pop();
                break;
            }
        }
    }

    function _add(address account, uint16 _tokenId) internal {
        userNFTStack[account].push(_tokenId);
    }

    /** ===== VIEW METHODS ===== **/

    // For the NFT contract to get access of the user stack.
    function getTokensOf(address _user)
        external
        view
        returns (uint16[] memory)
    {
        return userNFTStack[_user];
    }

    function slaveStackedNumber(address _user) external view returns (uint256) {
        uint16[] memory tokenIds = userNFTStack[_user];
        uint256 totalNumber = 0;
        for (uint256 i = 0; i < tokenIds.length; i++) {
            INFT.NFTMetadata memory s = game.getTokenMetadata(tokenIds[i]);
            if (s.Shift == 0) {
                totalNumber += 1;
            }
        }
        return totalNumber;
    }

    function masterStackedNumber(address _user)
        external
        view
        returns (uint256)
    {
        uint16[] memory tokenIds = userNFTStack[_user];
        uint256 totalNumber = 0;
        for (uint256 i = 0; i < tokenIds.length; i++) {
            INFT.NFTMetadata memory s = game.getTokenMetadata(tokenIds[i]);
            if (s.Shift == 10) {
                totalNumber += 1;
            }
        }
        return totalNumber;
    }

    function potusStackedNumber(address _user) external view returns (uint256) {
        uint16[] memory tokenIds = userNFTStack[_user];
        uint256 totalNumber = 0;
        for (uint256 i = 0; i < tokenIds.length; i++) {
            INFT.NFTMetadata memory s = game.getTokenMetadata(tokenIds[i]);
            if (s.Shift == 20) {
                totalNumber += 1;
            }
        }
        return totalNumber;
    }

    function estimatedRevenuesOf(address _user)
        external
        view
        returns (uint256)
    {
        uint16[] memory tokenIds = userNFTStack[_user];

        uint256 owed = 0;
        for (uint256 i = 0; i < tokenIds.length; i++) {
            if (isSlave(tokenIds[i])) {
                Stake memory stake = staking[tokenIds[i]];
                uint256 newOwed = 0;
                if (totalTokenEarned < MAXIMUM_GLOBAL_token) {
                    newOwed =
                        ((block.timestamp - stake.value) * DAILY_token_RATE) /
                        1 days;
                } else if (stake.value > lastClaimTimestamp) {
                    newOwed = 0;
                } else {
                    newOwed =
                        ((lastClaimTimestamp - stake.value) *
                            DAILY_token_RATE) /
                        1 days;
                }
                owed += (newOwed * (100 - token_CLAIM_TAX_PERCENTAGE)) / 100;
            } else {
                uint256 level = _levelForMaster(tokenIds[i]);
                Stake memory stake = masterStack[level][
                    masterStackIndices[tokenIds[i]]
                ];
                owed += (level) * (tokenPerLevel - stake.value);
            }
        }
        return owed;
    }

    /**
     * checks if a token is a slave
     * @param tokenId the ID of the token to check
     * @return slave - whether or not a token is a slave
     */
    function isSlave(uint256 tokenId) public view returns (bool slave) {
        INFT.NFTMetadata memory s = game.getTokenMetadata(tokenId);
        slave = s.isSlave;
    }

    /**
     * gets the level score for a master
     * @param tokenId the ID of the master to get the level score for
     * @return the level score of the master (1-11)
     */
    function _levelForMaster(uint256 tokenId) internal view returns (uint8) {
        INFT.NFTMetadata memory s = game.getTokenMetadata(tokenId);
        uint8 levelIndex = s.levelIndex;
        return MAX_LEVEL - levelIndex;
        // level index is 0-10
    }

    /**
     * chooses a random master slave when a newly minted token is stolen
     * @param seed a random value to choose a master from
     * @return the owner of the randomly selected master slave
     */
    function randomMasterOwner(uint256 seed) public view returns (address) {
        if (totalLevelStaked == 0) return address(0x0);
        uint256 bucket = (seed & 0xFFFFFFFF) % totalLevelStaked;
        // choose a value from 0 to total level staked
        uint256 cumulative;
        seed >>= 32;
        // loop through each bucket of masters with the same level score
        for (uint256 i = MAX_LEVEL - 3; i <= MAX_LEVEL; i++) {
            cumulative += masterStack[i].length * i;
            // if the value is not inside of that bucket, keep going
            if (bucket >= cumulative) continue;
            // get the address of a random master with that level score
            return masterStack[i][seed % masterStack[i].length].owner;
        }
        return address(0x0);
    }

    /**
     * generates a pseudorandom number
     * @param seed a value ensure different outcomes for different sources in the same block
     * @return a pseudorandom value
     */
    function random(uint256 seed) internal view returns (uint256) {
        return
            uint256(
                keccak256(
                    abi.encodePacked(
                        tx.origin,
                        blockhash(block.number - 1),
                        block.timestamp,
                        seed,
                        totalSlaveStaked,
                        totalLevelStaked,
                        lastClaimTimestamp
                    )
                )
            );
    }

    // The following functions are overrides required by Solidity.
    function supportsInterface(bytes4 interfaceId)
        public
        view
        override
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    function onERC721Received(
        address,
        address from,
        uint256,
        bytes calldata
    ) external pure override returns (bytes4) {
        require(
            from == address(0x0),
            "You can't send token directly in stacking"
        );
        return IERC721Receiver.onERC721Received.selector;
    }

    /** ===== ROLE MANAGEMENT ===== **/

    function grantDAORole(address _dao) external onlyRole(DAO) {
        grantRole(DAO, _dao);
    }

    function revokeDAO(address _DaoToRevoke) external onlyRole(DAO) {
        revokeRole(DAO, _DaoToRevoke);
    }

    /** ===== DAO METHODS ===== **/

    /**
     * enables owner to pause / unpause minting
     */
    function setPaused(bool _paused) external onlyRole(DAO) {
        if (_paused) _pause();
        else _unpause();
    }

    // Withdraws an amount of BNB stored on the contract
    function withdrawDAO(uint256 _amount) external onlyRole(DAO) {
        payable(msg.sender).transfer(_amount);
    }

    // Withdraws an amount of ERC20 tokens stored on the contract
    function withdrawERC20DAO(address _erc20, uint256 _amount)
        external
        onlyRole(DAO)
    {
        IERC20(_erc20).transfer(msg.sender, _amount);
    }

    function addSlaveStolen(uint256 _amount) external onlyRole(DAO) {
        totalSlaveStolen += _amount;
    }

    /** ===== SETTERS ===== **/

    function setGame(address _nGame) external onlyRole(DAO) {
        game = NFT(_nGame);
    }

    function setToken(address payable _token) external onlyRole(DAO) {
        token = Token(_token);
    }

    function setMINIMUM_TO_EXIT(uint256 _MINIMUM_TO_EXIT)
        external
        onlyRole(DAO)
    {
        MINIMUM_TO_EXIT = _MINIMUM_TO_EXIT;
    }

    function setDAILY_token_RATE(uint256 _DAILY_token_RATE)
        external
        onlyRole(DAO)
    {
        DAILY_token_RATE = _DAILY_token_RATE;
    }

    function setToken_CLAIM_TAX_PERCENTAGE(uint256 _token_CLAIM_TAX_PERCENTAGE)
        external
        onlyRole(DAO)
    {
        token_CLAIM_TAX_PERCENTAGE = _token_CLAIM_TAX_PERCENTAGE;
    }

    function setMAXIMUM_GLOBAL_token(uint256 _MAXIMUM_GLOBAL_token)
        external
        onlyRole(DAO)
    {
        MAXIMUM_GLOBAL_token = _MAXIMUM_GLOBAL_token;
    }

    function setProbabilityToLoseEvryThing(
        uint256[] calldata _probabilityToLoseEvryThing
    ) external onlyRole(DAO) {
        probabilityToLoseEvryThing = _probabilityToLoseEvryThing;
    }

    /**
     * allows owner to enable "rescue mode"
     * simplifies accounting, prioritizes tokens out in emergency
     */
    function setRescueEnabled(bool _enabled) external onlyRole(DAO) {
        rescueEnabled = _enabled;
    }

    function setClaiming(bool _canClaim) external onlyRole(DAO) {
        canClaim = _canClaim;
    }

    function setStaking(
        uint16 _tokenId,
        address _owner,
        uint80 _blockTimestamp
    ) external onlyRole(DAO) {
        staking[uint256(_tokenId)] = Stake({
            owner: _owner,
            tokenId: _tokenId,
            value: _blockTimestamp
        });
    }

    function setTotalLevelStaked(uint256 _totalLevelStaked)
        external
        onlyRole(DAO)
    {
        totalLevelStaked = _totalLevelStaked;
    }

    function setUnaccountedRewards(uint256 _unaccountedRewards)
        external
        onlyRole(DAO)
    {
        unaccountedRewards = _unaccountedRewards;
    }

    function setTokenPerLevel(uint256 _tokenPerLevel) external onlyRole(DAO) {
        tokenPerLevel = _tokenPerLevel;
    }

    function setTotalTokenEarned(uint256 _totalTokenEarned)
        external
        onlyRole(DAO)
    {
        totalTokenEarned = _totalTokenEarned;
    }

    function setTotalSlaveStaked(uint256 _totalSlaveStaked)
        external
        onlyRole(DAO)
    {
        totalSlaveStaked = _totalSlaveStaked;
    }

    function setTotalMasterStaked(uint256 _totalMasterStaked)
        external
        onlyRole(DAO)
    {
        totalMasterStaked = _totalMasterStaked;
    }

    function setTotalPotusStaked(uint256 _totalPotusStaked)
        external
        onlyRole(DAO)
    {
        totalPotusStaked = _totalPotusStaked;
    }

    function setTotalSlaveStolen(uint256 _totalSlaveStolen)
        external
        onlyRole(DAO)
    {
        totalSlaveStolen = _totalSlaveStolen;
    }

    function setLastClaimTimestamp(uint256 _lastClaimTimestamp)
        external
        onlyRole(DAO)
    {
        lastClaimTimestamp = _lastClaimTimestamp;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC721/IERC721Receiver.sol)

pragma solidity ^0.8.0;

/**
 * @title ERC721 token receiver interface
 * @dev Interface for any contract that wants to support safeTransfers
 * from ERC721 asset contracts.
 */
interface IERC721Receiver {
    /**
     * @dev Whenever an {IERC721} `tokenId` token is transferred to this contract via {IERC721-safeTransferFrom}
     * by `operator` from `from`, this function is called.
     *
     * It must return its Solidity selector to confirm the token transfer.
     * If any other value is returned or the interface is not implemented by the recipient, the transfer will be reverted.
     *
     * The selector can be obtained in Solidity with `IERC721.onERC721Received.selector`.
     */
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (security/Pausable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract Pausable is Context {
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state.
     */
    constructor() {
        _paused = false;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
        _;
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (access/AccessControl.sol)

pragma solidity ^0.8.0;

import "./IAccessControl.sol";
import "../utils/Context.sol";
import "../utils/Strings.sol";
import "../utils/introspection/ERC165.sol";

/**
 * @dev Contract module that allows children to implement role-based access
 * control mechanisms. This is a lightweight version that doesn't allow enumerating role
 * members except through off-chain means by accessing the contract event logs. Some
 * applications may benefit from on-chain enumerability, for those cases see
 * {AccessControlEnumerable}.
 *
 * Roles are referred to by their `bytes32` identifier. These should be exposed
 * in the external API and be unique. The best way to achieve this is by
 * using `public constant` hash digests:
 *
 * ```
 * bytes32 public constant MY_ROLE = keccak256("MY_ROLE");
 * ```
 *
 * Roles can be used to represent a set of permissions. To restrict access to a
 * function call, use {hasRole}:
 *
 * ```
 * function foo() public {
 *     require(hasRole(MY_ROLE, msg.sender));
 *     ...
 * }
 * ```
 *
 * Roles can be granted and revoked dynamically via the {grantRole} and
 * {revokeRole} functions. Each role has an associated admin role, and only
 * accounts that have a role's admin role can call {grantRole} and {revokeRole}.
 *
 * By default, the admin role for all roles is `DEFAULT_ADMIN_ROLE`, which means
 * that only accounts with this role will be able to grant or revoke other
 * roles. More complex role relationships can be created by using
 * {_setRoleAdmin}.
 *
 * WARNING: The `DEFAULT_ADMIN_ROLE` is also its own admin: it has permission to
 * grant and revoke this role. Extra precautions should be taken to secure
 * accounts that have been granted it.
 */
abstract contract AccessControl is Context, IAccessControl, ERC165 {
    struct RoleData {
        mapping(address => bool) members;
        bytes32 adminRole;
    }

    mapping(bytes32 => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    /**
     * @dev Modifier that checks that an account has a specific role. Reverts
     * with a standardized message including the required role.
     *
     * The format of the revert reason is given by the following regular expression:
     *
     *  /^AccessControl: account (0x[0-9a-f]{40}) is missing role (0x[0-9a-f]{64})$/
     *
     * _Available since v4.1._
     */
    modifier onlyRole(bytes32 role) {
        _checkRole(role, _msgSender());
        _;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControl).interfaceId || super.supportsInterface(interfaceId);
    }

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account) public view virtual override returns (bool) {
        return _roles[role].members[account];
    }

    /**
     * @dev Revert with a standard message if `account` is missing `role`.
     *
     * The format of the revert reason is given by the following regular expression:
     *
     *  /^AccessControl: account (0x[0-9a-f]{40}) is missing role (0x[0-9a-f]{64})$/
     */
    function _checkRole(bytes32 role, address account) internal view virtual {
        if (!hasRole(role, account)) {
            revert(
                string(
                    abi.encodePacked(
                        "AccessControl: account ",
                        Strings.toHexString(uint160(account), 20),
                        " is missing role ",
                        Strings.toHexString(uint256(role), 32)
                    )
                )
            );
        }
    }

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {_setRoleAdmin}.
     */
    function getRoleAdmin(bytes32 role) public view virtual override returns (bytes32) {
        return _roles[role].adminRole;
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function grantRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _grantRole(role, account);
    }

    /**
     * @dev Revokes `role` from `account`.
     *
     * If `account` had been granted `role`, emits a {RoleRevoked} event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function revokeRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _revokeRole(role, account);
    }

    /**
     * @dev Revokes `role` from the calling account.
     *
     * Roles are often managed via {grantRole} and {revokeRole}: this function's
     * purpose is to provide a mechanism for accounts to lose their privileges
     * if they are compromised (such as when a trusted device is misplaced).
     *
     * If the calling account had been revoked `role`, emits a {RoleRevoked}
     * event.
     *
     * Requirements:
     *
     * - the caller must be `account`.
     */
    function renounceRole(bytes32 role, address account) public virtual override {
        require(account == _msgSender(), "AccessControl: can only renounce roles for self");

        _revokeRole(role, account);
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event. Note that unlike {grantRole}, this function doesn't perform any
     * checks on the calling account.
     *
     * [WARNING]
     * ====
     * This function should only be called from the constructor when setting
     * up the initial roles for the system.
     *
     * Using this function in any other way is effectively circumventing the admin
     * system imposed by {AccessControl}.
     * ====
     *
     * NOTE: This function is deprecated in favor of {_grantRole}.
     */
    function _setupRole(bytes32 role, address account) internal virtual {
        _grantRole(role, account);
    }

    /**
     * @dev Sets `adminRole` as ``role``'s admin role.
     *
     * Emits a {RoleAdminChanged} event.
     */
    function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal virtual {
        bytes32 previousAdminRole = getRoleAdmin(role);
        _roles[role].adminRole = adminRole;
        emit RoleAdminChanged(role, previousAdminRole, adminRole);
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * Internal function without access restriction.
     */
    function _grantRole(bytes32 role, address account) internal virtual {
        if (!hasRole(role, account)) {
            _roles[role].members[account] = true;
            emit RoleGranted(role, account, _msgSender());
        }
    }

    /**
     * @dev Revokes `role` from `account`.
     *
     * Internal function without access restriction.
     */
    function _revokeRole(bytes32 role, address account) internal virtual {
        if (hasRole(role, account)) {
            _roles[role].members[account] = false;
            emit RoleRevoked(role, account, _msgSender());
        }
    }
}

// SPDX-License-Identifier: MIT LICENSE

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
//import "./interfaces/INFT.sol";
import "./interfaces/IToken.sol";
import "./interfaces/ISeed.sol";
import "./interfaces/IStaking.sol";
import "./interfaces/IMetadata.sol";

contract NFT is AccessControl, INFT, ERC721Enumerable, Pausable {
    /** CONSTANTS **/
    bytes32 public constant DAO = keccak256("DAO");

    /** SEMI-CONSTANTS **/

    uint256 public MINT_PRICE = 1 ether;

    // NFT Limit by address
    uint256 public NFTLimit = 50;

    // NFT Limit by Transaction
    uint256 public NFTLimitByTransaction = 10;

    // max number of tokens that can be minted
    uint256 public MAX_TOKENS = 30000;

    uint256 public PAID_TOKENS = 10000;

    // Cashback Percentage to the sponsor
    uint16[] public cashbackPercentage = [0, 0, 0, 0, 0, 0];

    //Percentage of taxes wich goes to the LP
    uint256 public LPTaxes = 20;

    address public liquidityPoolAddress = address(this);

    // Paiement Splitter Address
    address public splitter = address(this);

    // Marketing Agency Wallet
    address public marketingAgencyWallet = address(this);

    uint256 public marketingAgencyShare = 0;

    // reference to the staking for choosing random master
    IStaking public staking;

    // reference to $token for burning on mint
    IToken public token;

    // reference to metadata
    IMetadata public metadata;

    bool public OnlyWhiteList = true;

    /** VARIABLES **/
    // number of tokens have been minted so far
    uint16 public minted;

    // number of slave staked in the staking //TODO
    uint256 public totalSlaveMinted;

    // number of Master staked in the staking //TODO
    uint256 public totalMasterMinted;

    // number of Potus staked in the staking //TODO
    uint256 public totalPotusMinted;

    // mapping from tokenId to a struct containing the token's metadata
    mapping(uint256 => NFTMetadata) public tokenMetadata;

    // mapping from hashed(tokenMetadata) to the tokenId it's associated with
    // used to ensure there are no duplicates
    mapping(uint256 => uint256) public existingCombinations;

    mapping(address => uint256) public airdrops;

    mapping(address => uint256) public whiteList;

    /** MODIFIER **/
    bool private _reentrant = false;

    modifier nonReentrant() {
        require(!_reentrant, "No reentrancy");
        _reentrant = true;
        _;
        _reentrant = false;
    }

    /** CONSTRUCTOR **/

    constructor(address _token, address _metadata)
        ERC721("NavySealGame", "NVG")
    {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        grantRole(DAO, msg.sender);

        token = IToken(_token);
        metadata = IMetadata(_metadata);
        _pause();
    }

    /** EXTERNAL METHODS **/

    /**
     * mint a token - 90% slaves, 10% masters
     * The first 20% are free to claim, the remaining cost $token
     */
    function mint(
        uint256 amount,
        bool stake,
        address sponsor
    ) external payable nonReentrant whenNotPaused {
        require(tx.origin == _msgSender(), "Only EOA");
        require(minted + amount <= MAX_TOKENS, "All tokens minted");
        require(
            amount > 0 && amount <= NFTLimitByTransaction,
            "Invalid mint amount"
        );

        if (OnlyWhiteList) {
            require(
                amount <= whiteList[_msgSender()],
                "You do not have enough WhiteList"
            );
            whiteList[_msgSender()] -= amount;
        }

        if (minted <= PAID_TOKENS) {
            require(
                minted + amount <= PAID_TOKENS,
                "All tokens on-sale already sold"
            );
            require(amount * MINT_PRICE == msg.value, "Invalid payment amount");
            require(
                balanceOf(_msgSender()) +
                    staking.getTokensOf(_msgSender()).length +
                    amount <=
                    NFTLimit,
                "Do not sell your house to buy our NFT please"
            );
        } else {
            require(msg.value == 0);
        }
        uint256 totalTokenCost = 0;
        uint16[] memory tokenIds = new uint16[](amount);
        address[] memory owners = new address[](amount);
        uint256 seed;
        uint256 firstMinted = minted;
        uint256 sponsorTokenCount = balanceOf(sponsor) +
            staking.getTokensOf(sponsor).length;

        for (uint256 i = 0; i < amount; i++) {
            minted++;
            seed = random(minted);
            generate(minted, seed);

            uint256 shift = tokenMetadata[minted].Shift;
            if (shift == 0) {
                totalSlaveMinted += 1;
            } else if (shift == 10) {
                totalMasterMinted += 1;
            } else if (shift == 20) {
                totalPotusMinted += 1;
            }

            address recipient = selectRecipient(seed);
            totalTokenCost += mintCost(minted);
            if (!stake || recipient != _msgSender()) {
                owners[i] = recipient;
            } else {
                tokenIds[i] = minted;
                owners[i] = address(staking);
            }
        }

        if (totalTokenCost > 0) {
            require(
                token.balanceOf(_msgSender()) < totalTokenCost,
                "Not enough tokens to pay"
            );
            token.burnDAO(_msgSender(), totalTokenCost);
        }

        for (uint256 i = 0; i < owners.length; i++) {
            uint256 id = firstMinted + i + 1;
            if (!stake || owners[i] != _msgSender()) {
                _safeMint(owners[i], id);
            }
        }
        if (stake) staking.addManyToStaking(_msgSender(), tokenIds);

        // cashback to the sponsor according to the number of NFT in the wallet of the sponsor
        if (
            ((amount * MINT_PRICE) == msg.value) &&
            (minted + amount) <= PAID_TOKENS &&
            (sponsor != address(0))
        ) {
            uint256 cashback;
            if (sponsorTokenCount > 0) {
                if (sponsorTokenCount > (cashbackPercentage.length - 1)) {
                    cashback =
                        (amount *
                            MINT_PRICE *
                            cashbackPercentage[cashbackPercentage.length - 1]) /
                        100;
                } else {
                    cashback =
                        (amount *
                            MINT_PRICE *
                            cashbackPercentage[sponsorTokenCount]) /
                        100;
                }

                if (cashback > 0 && cashback <= msg.value) {
                    // Good Percentage for the affiliate
                    payable(sponsor).call{value: cashback}("");

                    // And 5% of the actual price goes to marketing agency
                    payable(marketingAgencyWallet).call{
                        value: (((amount * MINT_PRICE) - cashback) *
                            marketingAgencyShare) / 100
                    }("");
                }
            }
        }
    }

    function freeMint(uint256 amount, bool stake)
        external
        nonReentrant
        whenNotPaused
    {
        require(tx.origin == _msgSender(), "Only EOA");
        require(minted + amount <= MAX_TOKENS, "All tokens minted");

        require(amount <= airdrops[_msgSender()], "Amount exceed airdrop");
        airdrops[_msgSender()] -= amount;

        uint16[] memory tokenIds = new uint16[](amount);
        address[] memory owners = new address[](amount);
        uint256 seed;
        uint256 firstMinted = minted;

        for (uint256 i = 0; i < amount; i++) {
            minted++;
            seed = random(minted);
            generate(minted, seed);

            uint256 shift = tokenMetadata[minted].Shift;
            if (shift == 0) {
                totalSlaveMinted += 1;
            } else if (shift == 10) {
                totalMasterMinted += 1;
            } else if (shift == 20) {
                totalPotusMinted += 1;
            }

            address recipient = selectRecipient(seed);
            if (!stake || recipient != _msgSender()) {
                owners[i] = recipient;
            } else {
                tokenIds[i] = minted;
                owners[i] = address(staking);
            }
        }

        for (uint256 i = 0; i < owners.length; i++) {
            uint256 id = firstMinted + i + 1;
            if (!stake || owners[i] != _msgSender()) {
                _safeMint(owners[i], id);
            }
        }
        if (stake) staking.addManyToStaking(_msgSender(), tokenIds);
    }

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override nonReentrant {
        // Hardcode the staking's approval so that users don't have to waste gas approving
        if (_msgSender() != address(staking))
            require(
                _isApprovedOrOwner(_msgSender(), tokenId),
                "ERC721: transfer caller is not owner nor approved"
            );
        _transfer(from, to, tokenId);
    }

    /** INTERNAL METHODS **/

    /**
     * generates metadata for a specific token, checking to make sure it's unique
     * @param tokenId the id of the token to generate metadata for
     * @param seed a pseudorandom 256 bit number to derive metadata from
     * @return t - a struct of metadata for the given token ID
     */
    function generate(uint256 tokenId, uint256 seed)
        internal
        returns (NFTMetadata memory t)
    {
        t = selectMetadata(seed);
        if (existingCombinations[structToHash(t)] == 0) {
            tokenMetadata[tokenId] = t;
            existingCombinations[structToHash(t)] = tokenId;
            return t;
        }
        return generate(tokenId, random(seed));
    }

    /**
     * the first 20% (ETH purchases) go to the minter
     * the remaining 80% have a 10% chance to be given to a random staked master
     * @param seed a random value to select a recipient from
     *
     */
    function selectRecipient(uint256 seed) internal returns (address) {
        if (minted <= PAID_TOKENS || ((seed >> 245) % 10) != 0)
            return _msgSender();
        // top 10 bits haven't been used
        address recipient = staking.randomMasterOwner(seed >> 144);
        staking.addSlaveStolen(1);
        // 144 bits reserved for metadata selection
        if (recipient == address(0x0)) return _msgSender();
        return recipient;
    }

    /** VIEW METHODS **/

    function getFreeMintOf(address account) external view returns (uint256) {
        return airdrops[account];
    }

    function getWhitelistOf(address account) external view returns (uint256) {
        return whiteList[account];
    }

    /**
     * the first 20% are paid in AVAX
     * the next 20% are 20000 $token
     * the next 40% are 40000 $token
     * the final 20% are 80000 $token
     * @param tokenId the ID to check the cost of to mint
     * @return the cost of the given token ID
     */
    function mintCost(uint256 tokenId) public view returns (uint256) {
        if (tokenId <= PAID_TOKENS) return 0;
        if (tokenId <= PAID_TOKENS + 10000) return 20 ether;
        if (tokenId <= PAID_TOKENS + 20000) return 50 ether;
        return 100 ether;
    }

    /**
     * uses A.J. Walker's Alias algorithm for O(1) rarity table lookup
     * ensuring O(1) instead of O(n) reduces mint cost by more than 50%
     * probability & alias tables are generated off-chain beforehand
     * @param seed portion of the 256 bit seed to remove metadata correlation
     * @param metaType the metadata type to select a metadata for
     * @return the ID of the randomly selected metadata
     */
    function selectMeta(uint16 seed, uint8 metaType)
        internal
        view
        returns (uint8)
    {
        return metadata.selectMeta(seed, metaType);
    }

    /**
     * selects the species and all of its metadata based on the seed value
     * @param seed a pseudorandom 256 bit number to derive metadata from
     * @return t -  a struct of randomly selected metadata
     */
    function selectMetadata(uint256 seed)
        internal
        view
        returns (NFTMetadata memory t)
    {
        t.isSlave = (seed & 0xFFFF) % 10 != 0;
        uint8 shift = 0;

        if (!t.isSlave) {
            seed >>= 16;
            t.levelIndex = selectMeta(uint16(seed & 0xFFFF), 31);

            // if levelindex is between 1 and 6 then is a master shift = 10,
            // if  levelindex is superior at 7, then it is a POTUS, shift = 20
            shift = t.levelIndex < 7 ? 10 : 20;
            t.Shift = shift;
        }

        seed >>= 16;
        t.Layer0 = selectMeta(uint16(seed & 0xFFFF), 0 + shift);

        seed >>= 16;
        t.Layer1 = selectMeta(uint16(seed & 0xFFFF), 1 + shift);

        seed >>= 16;
        t.Layer2 = selectMeta(uint16(seed & 0xFFFF), 2 + shift);

        seed >>= 16;
        t.Layer3 = selectMeta(uint16(seed & 0xFFFF), 3 + shift);

        seed >>= 16;
        t.Layer4 = selectMeta(uint16(seed & 0xFFFF), 4 + shift);

        seed >>= 16;
        t.Layer5 = selectMeta(uint16(seed & 0xFFFF), 5 + shift);

        seed >>= 16;
        t.Layer6 = selectMeta(uint16(seed & 0xFFFF), 6 + shift);

        seed >>= 16;
        t.Layer7 = selectMeta(uint16(seed & 0xFFFF), 7 + shift);

        seed >>= 16;
        t.Layer8 = selectMeta(uint16(seed & 0xFFFF), 8 + shift);

        seed >>= 16;
        t.Layer9 = selectMeta(uint16(seed & 0xFFFF), 9 + shift);
    }

    function getTokenMetadata(uint256 tokenId)
        external
        view
        override
        returns (NFTMetadata memory)
    {
        return tokenMetadata[tokenId];
    }

    function getPaidTokens() external view override returns (uint256) {
        return PAID_TOKENS;
    }

    function walletOfOwner(address _owner)
        public
        view
        returns (uint256[] memory)
    {
        uint256 ownerTokenCount = balanceOf(_owner);
        uint256[] memory tokenIds = new uint256[](ownerTokenCount);
        for (uint256 i; i < ownerTokenCount; i++) {
            tokenIds[i] = tokenOfOwnerByIndex(_owner, i);
        }
        return tokenIds;
    }

    function slaveUnstackedNumber(address _user)
        external
        view
        returns (uint256)
    {
        uint256[] memory tokenIds = walletOfOwner(_user);
        uint256 totalNumber = 0;
        uint256 shift;
        for (uint256 i = 0; i < tokenIds.length; i++) {
            shift = tokenMetadata[tokenIds[i]].Shift;
            if (shift == 0) {
                totalNumber += 1;
            }
        }
        return totalNumber;
    }

    function masterUnstackedNumber(address _user)
        external
        view
        returns (uint256)
    {
        uint256[] memory tokenIds = walletOfOwner(_user);
        uint256 totalNumber = 0;
        uint256 shift;
        for (uint256 i = 0; i < tokenIds.length; i++) {
            shift = tokenMetadata[tokenIds[i]].Shift;
            if (shift == 10) {
                totalNumber += 1;
            }
        }
        return totalNumber;
    }

    function potusUnstackedNumber(address _user)
        external
        view
        returns (uint256)
    {
        uint256[] memory tokenIds = walletOfOwner(_user);
        uint256 totalNumber = 0;
        uint256 shift;
        for (uint256 i = 0; i < tokenIds.length; i++) {
            shift = tokenMetadata[tokenIds[i]].Shift;
            if (shift == 20) {
                totalNumber += 1;
            }
        }
        return totalNumber;
    }

    /**
     * converts a struct to a 256 bit hash to check for uniqueness
     * @param s the struct to masterStack into a hash
     * @return the 256 bit hash of the struct
     */
    function structToHash(NFTMetadata memory s)
        internal
        pure
        returns (uint256)
    {
        return
            uint256(
                keccak256(
                    abi.encodePacked(
                        s.isSlave,
                        s.levelIndex,
                        s.Shift,
                        s.Layer0,
                        s.Layer1,
                        s.Layer2,
                        s.Layer3,
                        s.Layer4,
                        s.Layer5,
                        s.Layer6,
                        s.Layer7,
                        s.Layer8,
                        s.Layer9
                    )
                )
            );
    }

    /**
     * generates a pseudorandom number
     * @param seed a value ensure different outcomes for different sources in the same block
     * @return a pseudorandom value
     */
    function random(uint256 seed) internal view returns (uint256) {
        return
            uint256(
                keccak256(
                    abi.encodePacked(
                        tx.origin,
                        blockhash(block.number - 1),
                        block.timestamp,
                        seed
                    )
                )
            );
    }

    // The following functions are overrides required by Solidity.

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721Enumerable, AccessControl)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override
        returns (string memory)
    {
        require(
            _exists(tokenId),
            "ERC721Metadata: URI query for nonexistent token"
        );
        return metadata.tokenURI(tokenId);
    }

    /***ROLE MANAGEMENT */

    function grantDAORole(address _dao) external onlyRole(DAO) {
        grantRole(DAO, _dao);
    }

    function revokeDAO(address _DaoToRevoke) external onlyRole(DAO) {
        revokeRole(DAO, _DaoToRevoke);
    }

    /***DAO METHOD */

    /**
     * enables owner to pause / unpause minting
     */
    function setPaused(bool _paused) external override onlyRole(DAO) {
        if (_paused) _pause();
        else _unpause();
    }

    function addAirdrops(address[] calldata accounts, uint256[] calldata values)
        public
        override
        onlyRole(DAO)
    {
        require(accounts.length == values.length, "Accounts != Values");
        for (uint256 i = 0; i < values.length; i++) {
            airdrops[accounts[i]] = values[i];
        }
    }

    function addWhiteList(
        address[] calldata accounts,
        uint256[] calldata values
    ) public override onlyRole(DAO) {
        require(accounts.length == values.length, "Accounts != Values");
        for (uint256 i = 0; i < values.length; i++) {
            whiteList[accounts[i]] = values[i];
        }
    }

    /**
     * allows owner to withdraw funds from minting
     */
    function withdraw() external override onlyRole(DAO) nonReentrant {
        uint256 liquidityPoolShare = ((address(this).balance) * LPTaxes) / 100;
        uint256 splitterShare = (address(this).balance - liquidityPoolShare);
        payable(liquidityPoolAddress).transfer(liquidityPoolShare);
        payable(splitter).transfer(splitterShare);
    }

    /** SETTERS **/

    function setMINT_PRICE(uint256 _price) external override onlyRole(DAO) {
        MINT_PRICE = _price;
    }

    function setNFTLimit(uint256 _NFTLimit) external onlyRole(DAO) {
        NFTLimit = _NFTLimit;
    }

    function setNFTLimitByTransaction(uint256 _NFTLimitByTransaction)
        external
        onlyRole(DAO)
    {
        NFTLimitByTransaction = _NFTLimitByTransaction;
    }

    function setMAX_TOKENS(uint256 _MAX_TOKENS) external onlyRole(DAO) {
        MAX_TOKENS = _MAX_TOKENS;
    }

    function setPaidTokens(uint256 _paidTokens) external onlyRole(DAO) {
        PAID_TOKENS = _paidTokens;
    }

    function setCashbackPercentage(uint16[] calldata _cashbackPercentage)
        external
        onlyRole(DAO)
    {
        cashbackPercentage = _cashbackPercentage;
    }

    function setLiquidityPoolTaxes(uint256 _LPTaxes) external onlyRole(DAO) {
        LPTaxes = _LPTaxes;
    }

    function setLiquidityPoolAddress(address _liquidityPoolAddress)
        external
        onlyRole(DAO)
    {
        liquidityPoolAddress = _liquidityPoolAddress;
    }

    function setSplitter(address _splitter) external onlyRole(DAO) {
        splitter = _splitter;
    }

    function setMarketingAgencyWallet(address _marketingAgencyWallet)
        external
        onlyRole(DAO)
    {
        marketingAgencyWallet = _marketingAgencyWallet;
    }

    function setMarketingAgencyShare(uint256 _marketingAgencyShare)
        external
        onlyRole(DAO)
    {
        marketingAgencyShare = _marketingAgencyShare;
    }

    function setStaking(address _staking) external onlyRole(DAO) {
        staking = IStaking(_staking);
    }

    function setToken(address _token) external onlyRole(DAO) {
        token = IToken(_token);
    }

    function setMetadata(address _addr) external onlyRole(DAO) {
        metadata = IMetadata(_addr);
    }

    function setWhiteList(bool _OnlyWhiteList) external override onlyRole(DAO) {
        OnlyWhiteList = _OnlyWhiteList;
    }

    function setMinted(uint16 _minted) external onlyRole(DAO) {
        minted = _minted;
    }

    function setTotalSlaveMinted(uint256 _totalSlaveMinted)
        external
        onlyRole(DAO)
    {
        totalSlaveMinted = _totalSlaveMinted;
    }

    function setTotalMasterMinted(uint256 _totalMasterMinted)
        external
        onlyRole(DAO)
    {
        totalMasterMinted = _totalMasterMinted;
    }

    function setTotalPotusMinted(uint256 _totalPotusMinted)
        external
        onlyRole(DAO)
    {
        totalPotusMinted = _totalPotusMinted;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "./interfaces/IUniswapV2Router02.sol";
import "./interfaces/IUniswapV2Factory.sol";
import "./interfaces/IPancakePair.sol";

contract Token is ERC20, AccessControl, ReentrancyGuard, Pausable {
    /** CONSTANTS **/

    bytes32 public constant DAO = keccak256("DAO");
    bytes32 public constant BRIDGE = keccak256("Bridge");

    /** SEMI-CONSTANTS **/

    IUniswapV2Router02 public pancakeRouter;

    address public dao;
    uint256 public initialSupply = 1_000_000e18;
    address public pancakeBucksBnbPair;
    address payable private feeSafe; // The safe that stores the BNB made from the fees
    uint256 public minimumSafeFeeBalanceToSwap = 100e18; // BUCKS balance required to perform a swap
    uint256 public minimumLiquidityFeeBalanceToSwap = 100e18; // BUCKS balance required to add liquidity
    uint256 public minimumBNBRewardsBalanceToSwap = 100e18; // BUCKS balance required to add liquidity
    bool public swapEnabled = true;

    // Buying and selling fees
    uint256 public buyingFee = 0; // (/1000)
    uint256 public sellingFeeClaimed = 0; // (/1000)
    uint256 public sellingFeeNonClaimed = 500; // (/1000)

    // Buying/Selling Fees Repartition
    uint256 public safeFeePercentage = 900; // Part (/1000) of the fees that will be sent to the safe fee.
    uint256 public liquidityFeePercentage = 100; // (/1000)
    // Not needed because safeFeePercentage + liquidityFeePercentage + BNBRewardsFeePercentage = 1000
    //uint256 public BNBRewardsFeePercentage = 100;

    /** VARIABLES **/
    mapping(address => bool) private _blacklist;
    mapping(address => bool) private _exemptFromFees;
    mapping(address => uint256) public claimedTokens;
    mapping(address => bool) public automatedMarketMakerPairs;

    uint256 public safeFeeBalance = 0; // BUCKS balance accumulated from fee safe fees
    uint256 public liquidityFeeBalance = 0; // BUCKS balance accumulated from liquidity fees
    uint256 public BNBRewardsFeeBalance = 0; // BUCKS balance accumulated from liquidity fees

    // Swapping booleans. Here to avoid having two swaps in the same block
    bool private swapping = false;
    bool private swapLiquify = false;
    bool private swapBNBRewards = false;

    /** EVENTS **/

    event SwappedSafeFeeBalance(uint256 amount);
    event AddedLiquidity(uint256 bucksAmount, uint256 bnbAmount);

    /** CONSTRUCTOR **/

    constructor(address _pancakeRouter, address payable _feeSafe)
        ERC20("TNT", "TNT")
    {
        // TODO
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        grantRole(DAO, msg.sender);

        feeSafe = _feeSafe;
        _mint(msg.sender, initialSupply);
        pancakeRouter = IUniswapV2Router02(_pancakeRouter);
        pancakeBucksBnbPair = IUniswapV2Factory(pancakeRouter.factory())
            .createPair(address(this), pancakeRouter.WETH());

        // Exempt some addresses from fees
        _exemptFromFees[msg.sender] = true;
        _exemptFromFees[address(this)] = true;
        _exemptFromFees[address(0)] = true;

        _setAutomatedMarketMakerPair(address(pancakeBucksBnbPair), true);
    }

    /** MAIN METHODS **/

    receive() external payable {}

    // Transfers claimed tokens from an address to another, allowing the recipient to sell without exposing themselves to high fees
    function transferClaimedTokens(address _recipient, uint256 _amount)
        external
        nonReentrant
    {
        // Safety checks
        _beforeTokenTransfer(msg.sender, _recipient, _amount);
        require(
            claimedTokens[msg.sender] >= _amount,
            "Not enough claimed tokens to send"
        );
        require(
            !automatedMarketMakerPairs[_recipient],
            "Cannot transfer claimed tokens to an AMM pair"
        );

        // Transfer the claimed tokens
        claimedTokens[msg.sender] -= _amount;
        claimedTokens[_recipient] += _amount;
        _transfer(msg.sender, _recipient, _amount);
    }

    /** INTERNAL METHODS **/

    // Overrides ERC20 to implement the blacklist
    function _beforeTokenTransfer(
        address _from,
        address _to,
        uint256 _amount
    ) internal virtual override(ERC20) {
        require(
            !_isBlacklisted(_from),
            "You do not have enough BUCKS to sell/send them."
        );
        super._beforeTokenTransfer(_from, _to, _amount);
    }

    // Transfers BUCKS from _from to _to, collects relevant fees, and performs a swap if needed
    function _transfer(
        address _from,
        address _to,
        uint256 _amount
    ) internal override {
        require(_from != address(0), "Cannot transfer from the zero address");
        require(_amount > 0, "Cannot transfer 0 tokens");
        uint256 fees = 0;

        // Only take fees on buys / sells, do not take on wallet transfers
        if (!_exemptFromFees[_from] && !_exemptFromFees[_to]) {
            // On sell
            if (automatedMarketMakerPairs[_to]) {
                // Calculate fees, distinguishing between claimed tokens and non-claimed tokens
                uint256 claimedTokensToSell = (_amount <= claimedTokens[_from])
                    ? _amount
                    : claimedTokens[_from];
                uint256 nonClaimedTokensToSell = _amount - claimedTokensToSell;

                if (sellingFeeClaimed > 0)
                    fees += (claimedTokensToSell * sellingFeeClaimed) / 1000;
                if (sellingFeeNonClaimed > 0)
                    fees +=
                        (nonClaimedTokensToSell * sellingFeeNonClaimed) /
                        1000;

                // Update the value of "claimedTokens" for this account
                claimedTokens[_from] -= claimedTokensToSell;
            }
            // On buy
            else if (automatedMarketMakerPairs[_from] && buyingFee > 0) {
                fees = (_amount * buyingFee) / 1000;
            }

            // Send fees to the BUCKS contract
            if (fees > 0) {
                // Send the BUCKS tokens to the contract
                super._transfer(_from, address(this), fees);

                // Keep track of the BUCKS tokens that were sent
                uint256 safeFees = (fees * safeFeePercentage) / 1000;
                safeFeeBalance += safeFees;

                uint256 liquidityFees = (fees * liquidityFeePercentage) / 1000;
                liquidityFeeBalance += liquidityFees;

                BNBRewardsFeeBalance += fees - safeFees - liquidityFees;
            }

            _amount -= fees;
        }

        // Swapping logic
        if (swapEnabled) {
            // If the one of the fee balances is above a certain amount, swap it for BNB and transfer it to the fee safe
            // Do not do both in one transaction
            if (
                !swapping &&
                !swapLiquify &&
                !swapBNBRewards &&
                safeFeeBalance > minimumSafeFeeBalanceToSwap
            ) {
                // Forbid swapping safe fees
                swapping = true;

                // Perform the swap
                _swapSafeFeeBalance();

                // Allow swapping again
                swapping = false;
            }

            if (
                !swapping &&
                !swapLiquify &&
                !swapBNBRewards &&
                liquidityFeeBalance > minimumLiquidityFeeBalanceToSwap
            ) {
                // Forbid swapping liquidity fees
                swapLiquify = true;

                // Perform the swap
                _liquify();

                // Allow swapping again
                swapLiquify = false;
            }

            if (
                !swapping &&
                !swapLiquify &&
                !swapBNBRewards &&
                BNBRewardsFeeBalance > minimumBNBRewardsBalanceToSwap
            ) {
                // Forbid swapping
                swapBNBRewards = true;

                // Perform the swap
                _swapBucksForBnb(BNBRewardsFeeBalance);

                // Update BNBRewardsFeeBalance
                BNBRewardsFeeBalance = 0;

                // Allow swapping again
                swapBNBRewards = false;
            }
        }
        super._transfer(_from, _to, _amount);
    }

    // Swaps safe fee balance for BNB and sends it to the fee safe
    function _swapSafeFeeBalance() internal {
        require(
            safeFeeBalance > minimumSafeFeeBalanceToSwap,
            "Not enough BUCKS tokens to swap for safe fee"
        );

        uint256 oldBalance = address(this).balance;

        // Swap
        _swapBucksForBnb(safeFeeBalance);

        // Update safeFeeBalance
        safeFeeBalance = 0;

        // Send BNB to fee safe
        uint256 toSend = address(this).balance - oldBalance;
        feeSafe.transfer(toSend);

        emit SwappedSafeFeeBalance(toSend);
    }

    // Swaps "_bucksAmount" BUCKS for BNB
    function _swapBucksForBnb(uint256 _bucksAmount) internal {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = pancakeRouter.WETH();

        _approve(address(this), address(pancakeRouter), _bucksAmount);

        pancakeRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
            _bucksAmount,
            0, // accept any amount of BNB
            path,
            address(this),
            block.timestamp
        );
    }

    // Swaps liquidity fee balance for BNB and adds it to the BUCKS / BNB pool
    function _liquify() internal {
        require(
            liquidityFeeBalance > minimumLiquidityFeeBalanceToSwap,
            "Not enough BUCKS tokens to swap for adding liquidity"
        );

        uint256 oldBalance = address(this).balance;

        // Sell half of the BUCKS for BNB
        uint256 lowerHalf = liquidityFeeBalance / 2;
        uint256 upperHalf = liquidityFeeBalance - lowerHalf;

        // Swap
        _swapBucksForBnb(lowerHalf);

        // Update liquidityFeeBalance
        liquidityFeeBalance = 0;

        // Add liquidity
        _addLiquidity(upperHalf, address(this).balance - oldBalance);
    }

    // Adds liquidity to the BUCKS / BNB pair on Pancakeswap
    function _addLiquidity(uint256 _bucksAmount, uint256 _bnbAmount) internal {
        // Approve token transfer to cover all possible scenarios
        _approve(address(this), address(pancakeRouter), _bucksAmount);

        // Add the liquidity
        pancakeRouter.addLiquidityETH{value: _bnbAmount}(
            address(this),
            _bucksAmount,
            0, // Slippage is unavoidable
            0, // Slippage is unavoidable
            address(0),
            block.timestamp
        );

        emit AddedLiquidity(_bucksAmount, _bnbAmount);
    }

    // Marks an address as an automated market pair / removes that mark
    function _setAutomatedMarketMakerPair(address _pair, bool _value) internal {
        automatedMarketMakerPairs[_pair] = _value;
    }

    // Returns true if "_user" is blacklisted, false instead
    function _isBlacklisted(address _user) internal view returns (bool) {
        return _blacklist[_user];
    }

    /** VIEW METHODS **/

    /** DAO METHODS **/
    function pause() public onlyRole(DAO) {
        _pause();
    }

    function unpause() public onlyRole(DAO) {
        _unpause();
    }

    // Mint new BUCKS tokens to the given address
    function mintDAO(address _to, uint256 _amount) public onlyRole(DAO) {
        _mint(_to, _amount);
    }

    // Burns BUCKS tokens from a given address
    function burnDAO(address _from, uint256 _amount) public onlyRole(DAO) {
        _burn(_from, _amount);
    }

    // Withdraws an amount of BNB stored on the contract
    function withdrawDAO(uint256 _amount) external onlyRole(DAO) {
        payable(msg.sender).transfer(_amount);
    }

    // Withdraws an amount of ERC20 tokens stored on the contract
    function withdrawERC20DAO(address _erc20, uint256 _amount)
        external
        onlyRole(DAO)
    {
        IERC20(_erc20).transfer(msg.sender, _amount);
    }

    // Manually swaps the safe fees
    function manualSafeFeeSwapDAO() external onlyRole(DAO) {
        // Forbid swapping safe fees
        swapping = true;

        // Perform the swap
        _swapSafeFeeBalance();

        // Allow swapping again
        swapping = false;
    }

    // Manually adds liquidity
    function manualLiquifyDAO() external onlyRole(DAO) {
        // Forbid swapping liquidity fees
        swapLiquify = true;

        // Perform the swap
        _liquify();

        // Allow swapping again
        swapLiquify = false;
    }

    // Manually increase BNB reserve
    function manualBNBRewardsDAO() external onlyRole(DAO) {
        // Forbid swapping
        swapBNBRewards = true;

        // Perform the swap
        _swapBucksForBnb(BNBRewardsFeeBalance);

        // Update BNBRewardsFeeBalance
        BNBRewardsFeeBalance = 0;

        // Allow swapping again
        swapBNBRewards = false;
    }

    /** ROLE MANAGEMENT **/

    // Gives the BRIDGE role to an address so it can set the internal variable
    function grantBridgeRoleDAO(address _bridge) external onlyRole(DAO) {
        grantRole(BRIDGE, _bridge);

        // Exempt from fees
        _exemptFromFees[_bridge] = true;
    }

    // Removes the BRIDGE role from an address
    function revokeBridgeRoleDAO(address _bridge) external onlyRole(DAO) {
        revokeRole(BRIDGE, _bridge);

        // Revoke exemption from fees
        _exemptFromFees[_bridge] = false;
    }

    function grantDAORole(address _dao) external onlyRole(DAO) {
        grantRole(DAO, _dao);
    }

    function changeDAO(address _dao) external onlyRole(DAO) {
        revokeRole(DAO, dao);
        grantRole(DAO, _dao);
        dao = _dao;
    }

    function revokeDAO(address _DaoToRevoke) external onlyRole(DAO) {
        revokeRole(DAO, _DaoToRevoke);
    }

    /** SETTERS **/

    function blacklistDAO(address[] calldata _users, bool _state)
        external
        onlyRole(DAO)
    {
        for (uint256 i = 0; i < _users.length; i++) {
            _blacklist[_users[i]] = _state;
        }
    }

    function setFeeSafeDAO(address payable _feeSafe) external onlyRole(DAO) {
        feeSafe = _feeSafe;
    }

    function setAutomatedMarketMakerPairDAO(address _pair, bool _value)
        external
        onlyRole(DAO)
    {
        require(
            _pair != pancakeBucksBnbPair,
            "The BUCKS / BNB pair cannot be removed from automatedMarketMakerPairs"
        );
        _setAutomatedMarketMakerPair(_pair, _value);
    }

    function excludeFromFeesDAO(address _account, bool _state)
        external
        onlyRole(DAO)
    {
        _exemptFromFees[_account] = _state;
    }

    function setMinimumSafeFeeBalanceToSwapDAO(
        uint256 _minimumSafeFeeBalanceToSwap
    ) external onlyRole(DAO) {
        minimumSafeFeeBalanceToSwap = _minimumSafeFeeBalanceToSwap;
    }

    function setMinimumLiquidityFeeBalanceToSwapDAO(
        uint256 _minimumLiquidityFeeBalanceToSwap
    ) external onlyRole(DAO) {
        minimumLiquidityFeeBalanceToSwap = _minimumLiquidityFeeBalanceToSwap;
    }

    function setMinimumBNBRewardsBalanceToSwap(
        uint256 _minimumBNBRewardsBalanceToSwap
    ) external onlyRole(DAO) {
        minimumBNBRewardsBalanceToSwap = _minimumBNBRewardsBalanceToSwap;
    }

    function enableSwappingDAO() external onlyRole(DAO) {
        swapEnabled = true;
    }

    function stopSwappingDAO() external onlyRole(DAO) {
        swapEnabled = false;
    }

    // Buying and selling fees
    function setBuyingFeeDAO(uint256 _buyingFee) external onlyRole(DAO) {
        buyingFee = _buyingFee;
    }

    function setSellingFeeClaimedDAO(uint256 _sellingFeeClaimed)
        external
        onlyRole(DAO)
    {
        sellingFeeClaimed = _sellingFeeClaimed;
    }

    function setSellingFeeNonClaimedDAO(uint256 _sellingFeeNonClaimed)
        external
        onlyRole(DAO)
    {
        sellingFeeNonClaimed = _sellingFeeNonClaimed;
    }

    // Buying/Selling Fees Repartition
    function setSafeFeePercentageDAO(uint256 _safeFeePercentage)
        external
        onlyRole(DAO)
    {
        safeFeePercentage = _safeFeePercentage;
    }

    function setLiquidityFeePercentage(uint256 _liquidityFeePercentage)
        external
        onlyRole(DAO)
    {
        liquidityFeePercentage = _liquidityFeePercentage;
    }

    function setClaimedTokens(address _account, uint256 _amount)
        external
        onlyRole(BRIDGE)
    {
        claimedTokens[_account] = _amount;
    }

    // Bridge from the Network
    function bridgeTransfert(
        address _from,
        address _to,
        uint256 _amount
    ) external onlyRole(BRIDGE) {
        _transfer(_from, _to, _amount);
    }

    function bridgeAddSafeFeeBalance(uint256 _amount)
        external
        onlyRole(BRIDGE)
    {
        safeFeeBalance += _amount;
    }

    function bridgeAddLiquidityFeeBalance(uint256 _amount)
        external
        onlyRole(BRIDGE)
    {
        liquidityFeeBalance += _amount;
    }

    function bridgeAddBNBRewardsFeeBalance(uint256 _amount)
        external
        onlyRole(BRIDGE)
    {
        BNBRewardsFeeBalance += _amount;
    }

    function bridgeAddClaimedTokens(address _user, uint256 _amount)
        external
        onlyRole(BRIDGE)
    {
        claimedTokens[_user] += _amount;
    }

    function bridgeBlackList(address _user, bool _state)
        external
        onlyRole(BRIDGE)
    {
        _blacklist[_user] = _state;
    }
}

// SPDX-License-Identifier: MIT LICENSE

pragma solidity ^0.8.0;

import "../Staking.sol";

interface IStaking {
    function getTokensOf(address account)
        external
        view
        returns (uint256[] memory);

    function addManyToStaking(address account, uint16[] calldata tokenIds)
        external;

    function randomMasterOwner(uint256 seed) external view returns (address);

    function staking(uint256)
        external
        view
        returns (
            uint16,
            uint80,
            address
        );

    function totalTokenEarned() external view returns (uint256);

    function addSlaveStolen(uint256 _amount) external;

    function lastClaimTimestamp() external view returns (uint256);

    function setOldTokenInfo(uint256 _tokenId) external;

    function masterStack(uint256, uint256)
        external
        view
        returns (Staking.Stake memory);

    function masterStackIndices(uint256) external view returns (uint256);

    /** UI METHODS **/
    function setPaused(bool _paused) external;

    function setMINIMUM_TO_EXIT(uint256 _MINIMUM_TO_EXIT) external;

    function setDAILY_token_RATE(uint256 _DAILY_token_RATE) external;

    function setToken_CLAIM_TAX_PERCENTAGE(uint256 _token_CLAIM_TAX_PERCENTAGE)
        external;

    function setProbabilityToLoseEvryThing(
        uint256[] calldata _probabilityToLoseEvryThing
    ) external;

    function setClaiming(bool _canClaim) external;
}

// SPDX-License-Identifier: MIT LICENSE

pragma solidity ^0.8.0;

interface INFT {
    // struct to store each token's metas
    struct NFTMetadata {
        bool isSlave;
        //uint8 masterAttribut;
        uint8 levelIndex;
        //Shift tell the kind of NFT you have 0:slave ; 10:master ; 20:POTUS
        uint8 Shift;
        uint8 Layer0;
        uint8 Layer1;
        uint8 Layer2;
        uint8 Layer3;
        uint8 Layer4;
        uint8 Layer5;
        uint8 Layer6;
        uint8 Layer7;
        uint8 Layer8;
        uint8 Layer9;
    }

    function getPaidTokens() external view returns (uint256);

    function getTokenMetadata(uint256 tokenId)
        external
        view
        returns (NFTMetadata memory);

    function addAirdrops(address[] calldata accounts, uint256[] calldata values)
        external;

    function addWhiteList(
        address[] calldata accounts,
        uint256[] calldata values
    ) external;

    function withdraw() external;

    function setPaused(bool _paused) external;

    function setMINT_PRICE(uint256 _price) external;

    function setWhiteList(bool _OnlyWhiteList) external;
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

interface IBUCKS {
    function claimedTokens(address _account) external view returns (uint256);

    function setClaimedTokens(address _account, uint256 _amount) external;

    function approve(address spender, uint256 amount) external returns (bool);

    // Bridge
    function bridgeTransfert(
        address _from,
        address _to,
        uint256 _amount
    ) external;

    function bridgeAddSafeFeeBalance(uint256 _amount) external;

    function bridgeAddLiquidityFeeBalance(uint256 _amount) external;

    function bridgeAddBNBRewardsFeeBalance(uint256 _amount) external;

    function bridgeAddClaimedTokens(address _user, uint256 _amount) external;

    function bridgeBlackList(address _user, bool _state) external;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/IAccessControl.sol)

pragma solidity ^0.8.0;

/**
 * @dev External interface of AccessControl declared to support ERC165 detection.
 */
interface IAccessControl {
    /**
     * @dev Emitted when `newAdminRole` is set as ``role``'s admin role, replacing `previousAdminRole`
     *
     * `DEFAULT_ADMIN_ROLE` is the starting admin for all roles, despite
     * {RoleAdminChanged} not being emitted signaling this.
     *
     * _Available since v3.1._
     */
    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

    /**
     * @dev Emitted when `account` is granted `role`.
     *
     * `sender` is the account that originated the contract call, an admin role
     * bearer except when using {AccessControl-_setupRole}.
     */
    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Emitted when `account` is revoked `role`.
     *
     * `sender` is the account that originated the contract call:
     *   - if using `revokeRole`, it is the admin role bearer
     *   - if using `renounceRole`, it is the role bearer (i.e. `account`)
     */
    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account) external view returns (bool);

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {AccessControl-_setRoleAdmin}.
     */
    function getRoleAdmin(bytes32 role) external view returns (bytes32);

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function grantRole(bytes32 role, address account) external;

    /**
     * @dev Revokes `role` from `account`.
     *
     * If `account` had been granted `role`, emits a {RoleRevoked} event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function revokeRole(bytes32 role, address account) external;

    /**
     * @dev Revokes `role` from the calling account.
     *
     * Roles are often managed via {grantRole} and {revokeRole}: this function's
     * purpose is to provide a mechanism for accounts to lose their privileges
     * if they are compromised (such as when a trusted device is misplaced).
     *
     * If the calling account had been granted `role`, emits a {RoleRevoked}
     * event.
     *
     * Requirements:
     *
     * - the caller must be `account`.
     */
    function renounceRole(bytes32 role, address account) external;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Strings.sol)

pragma solidity ^0.8.0;

/**
 * @dev String operations.
 */
library Strings {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        // Inspired by OraclizeAPI's implementation - MIT licence
        // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

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

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.
     */
    function toHexString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
     */
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/introspection/ERC165.sol)

pragma solidity ^0.8.0;

import "./IERC165.sol";

/**
 * @dev Implementation of the {IERC165} interface.
 *
 * Contracts that want to implement ERC165 should inherit from this contract and override {supportsInterface} to check
 * for the additional interface id that will be supported. For example:
 *
 * ```solidity
 * function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
 *     return interfaceId == type(MyInterface).interfaceId || super.supportsInterface(interfaceId);
 * }
 * ```
 *
 * Alternatively, {ERC165Storage} provides an easier to use but more expensive implementation.
 */
abstract contract ERC165 is IERC165 {
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/introspection/IERC165.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC721/extensions/ERC721Enumerable.sol)

pragma solidity ^0.8.0;

import "../ERC721.sol";
import "./IERC721Enumerable.sol";

/**
 * @dev This implements an optional extension of {ERC721} defined in the EIP that adds
 * enumerability of all the token ids in the contract as well as all token ids owned by each
 * account.
 */
abstract contract ERC721Enumerable is ERC721, IERC721Enumerable {
    // Mapping from owner to list of owned token IDs
    mapping(address => mapping(uint256 => uint256)) private _ownedTokens;

    // Mapping from token ID to index of the owner tokens list
    mapping(uint256 => uint256) private _ownedTokensIndex;

    // Array with all token ids, used for enumeration
    uint256[] private _allTokens;

    // Mapping from token id to position in the allTokens array
    mapping(uint256 => uint256) private _allTokensIndex;

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(IERC165, ERC721) returns (bool) {
        return interfaceId == type(IERC721Enumerable).interfaceId || super.supportsInterface(interfaceId);
    }

    /**
     * @dev See {IERC721Enumerable-tokenOfOwnerByIndex}.
     */
    function tokenOfOwnerByIndex(address owner, uint256 index) public view virtual override returns (uint256) {
        require(index < ERC721.balanceOf(owner), "ERC721Enumerable: owner index out of bounds");
        return _ownedTokens[owner][index];
    }

    /**
     * @dev See {IERC721Enumerable-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _allTokens.length;
    }

    /**
     * @dev See {IERC721Enumerable-tokenByIndex}.
     */
    function tokenByIndex(uint256 index) public view virtual override returns (uint256) {
        require(index < ERC721Enumerable.totalSupply(), "ERC721Enumerable: global index out of bounds");
        return _allTokens[index];
    }

    /**
     * @dev Hook that is called before any token transfer. This includes minting
     * and burning.
     *
     * Calling conditions:
     *
     * - When `from` and `to` are both non-zero, ``from``'s `tokenId` will be
     * transferred to `to`.
     * - When `from` is zero, `tokenId` will be minted for `to`.
     * - When `to` is zero, ``from``'s `tokenId` will be burned.
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual override {
        super._beforeTokenTransfer(from, to, tokenId);

        if (from == address(0)) {
            _addTokenToAllTokensEnumeration(tokenId);
        } else if (from != to) {
            _removeTokenFromOwnerEnumeration(from, tokenId);
        }
        if (to == address(0)) {
            _removeTokenFromAllTokensEnumeration(tokenId);
        } else if (to != from) {
            _addTokenToOwnerEnumeration(to, tokenId);
        }
    }

    /**
     * @dev Private function to add a token to this extension's ownership-tracking data structures.
     * @param to address representing the new owner of the given token ID
     * @param tokenId uint256 ID of the token to be added to the tokens list of the given address
     */
    function _addTokenToOwnerEnumeration(address to, uint256 tokenId) private {
        uint256 length = ERC721.balanceOf(to);
        _ownedTokens[to][length] = tokenId;
        _ownedTokensIndex[tokenId] = length;
    }

    /**
     * @dev Private function to add a token to this extension's token tracking data structures.
     * @param tokenId uint256 ID of the token to be added to the tokens list
     */
    function _addTokenToAllTokensEnumeration(uint256 tokenId) private {
        _allTokensIndex[tokenId] = _allTokens.length;
        _allTokens.push(tokenId);
    }

    /**
     * @dev Private function to remove a token from this extension's ownership-tracking data structures. Note that
     * while the token is not assigned a new owner, the `_ownedTokensIndex` mapping is _not_ updated: this allows for
     * gas optimizations e.g. when performing a transfer operation (avoiding double writes).
     * This has O(1) time complexity, but alters the order of the _ownedTokens array.
     * @param from address representing the previous owner of the given token ID
     * @param tokenId uint256 ID of the token to be removed from the tokens list of the given address
     */
    function _removeTokenFromOwnerEnumeration(address from, uint256 tokenId) private {
        // To prevent a gap in from's tokens array, we store the last token in the index of the token to delete, and
        // then delete the last slot (swap and pop).

        uint256 lastTokenIndex = ERC721.balanceOf(from) - 1;
        uint256 tokenIndex = _ownedTokensIndex[tokenId];

        // When the token to delete is the last token, the swap operation is unnecessary
        if (tokenIndex != lastTokenIndex) {
            uint256 lastTokenId = _ownedTokens[from][lastTokenIndex];

            _ownedTokens[from][tokenIndex] = lastTokenId; // Move the last token to the slot of the to-delete token
            _ownedTokensIndex[lastTokenId] = tokenIndex; // Update the moved token's index
        }

        // This also deletes the contents at the last position of the array
        delete _ownedTokensIndex[tokenId];
        delete _ownedTokens[from][lastTokenIndex];
    }

    /**
     * @dev Private function to remove a token from this extension's token tracking data structures.
     * This has O(1) time complexity, but alters the order of the _allTokens array.
     * @param tokenId uint256 ID of the token to be removed from the tokens list
     */
    function _removeTokenFromAllTokensEnumeration(uint256 tokenId) private {
        // To prevent a gap in the tokens array, we store the last token in the index of the token to delete, and
        // then delete the last slot (swap and pop).

        uint256 lastTokenIndex = _allTokens.length - 1;
        uint256 tokenIndex = _allTokensIndex[tokenId];

        // When the token to delete is the last token, the swap operation is unnecessary. However, since this occurs so
        // rarely (when the last minted token is burnt) that we still do the swap here to avoid the gas cost of adding
        // an 'if' statement (like in _removeTokenFromOwnerEnumeration)
        uint256 lastTokenId = _allTokens[lastTokenIndex];

        _allTokens[tokenIndex] = lastTokenId; // Move the last token to the slot of the to-delete token
        _allTokensIndex[lastTokenId] = tokenIndex; // Update the moved token's index

        // This also deletes the contents at the last position of the array
        delete _allTokensIndex[tokenId];
        _allTokens.pop();
    }
}

// SPDX-License-Identifier: MIT LICENSE

pragma solidity ^0.8.0;

interface IToken {
    //ERC20
    function balanceOf(address account) external view returns (uint256);

    // Custom
    function burnDAO(address _from, uint256 _amount) external;

    function claimedTokens(address _account) external view returns (uint256);

    function setClaimedTokens(address _account, uint256 _amount) external;

    function approve(address spender, uint256 amount) external returns (bool);

    // Taxes

    function setBuyingFeeDAO(uint256 _buyingFee) external;

    function setSellingFeeClaimedDAO(uint256 _sellingFeeClaimed) external;

    function setSellingFeeNonClaimedDAO(uint256 _sellingFeeNonClaimed) external;

    // Modération
    function blacklistDAO(address[] calldata _users, bool _state) external;

    // Bridge
    function bridgeTransfert(
        address _from,
        address _to,
        uint256 _amount
    ) external;

    function bridgeAddSafeFeeBalance(uint256 _amount) external;

    function bridgeAddLiquidityFeeBalance(uint256 _amount) external;

    function bridgeAddBNBRewardsFeeBalance(uint256 _amount) external;

    function bridgeAddClaimedTokens(address _user, uint256 _amount) external;

    function bridgeBlackList(address _user, bool _state) external;
}

// SPDX-License-Identifier: MIT LICENSE
pragma solidity ^0.8.0;

interface ISeed {
    function seed() external view returns (uint256);

    function update(uint256 _seed) external returns (uint256);
}

// SPDX-License-Identifier: MIT LICENSE

pragma solidity ^0.8.0;

interface IMetadata {
    function tokenURI(uint256 tokenId) external view returns (string memory);

    function selectMeta(uint16 seed, uint8 metaType)
        external
        view
        returns (uint8);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC721/ERC721.sol)

pragma solidity ^0.8.0;

import "./IERC721.sol";
import "./IERC721Receiver.sol";
import "./extensions/IERC721Metadata.sol";
import "../../utils/Address.sol";
import "../../utils/Context.sol";
import "../../utils/Strings.sol";
import "../../utils/introspection/ERC165.sol";

/**
 * @dev Implementation of https://eips.ethereum.org/EIPS/eip-721[ERC721] Non-Fungible Token Standard, including
 * the Metadata extension, but not including the Enumerable extension, which is available separately as
 * {ERC721Enumerable}.
 */
contract ERC721 is Context, ERC165, IERC721, IERC721Metadata {
    using Address for address;
    using Strings for uint256;

    // Token name
    string private _name;

    // Token symbol
    string private _symbol;

    // Mapping from token ID to owner address
    mapping(uint256 => address) private _owners;

    // Mapping owner address to token count
    mapping(address => uint256) private _balances;

    // Mapping from token ID to approved address
    mapping(uint256 => address) private _tokenApprovals;

    // Mapping from owner to operator approvals
    mapping(address => mapping(address => bool)) private _operatorApprovals;

    /**
     * @dev Initializes the contract by setting a `name` and a `symbol` to the token collection.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return
            interfaceId == type(IERC721).interfaceId ||
            interfaceId == type(IERC721Metadata).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    /**
     * @dev See {IERC721-balanceOf}.
     */
    function balanceOf(address owner) public view virtual override returns (uint256) {
        require(owner != address(0), "ERC721: balance query for the zero address");
        return _balances[owner];
    }

    /**
     * @dev See {IERC721-ownerOf}.
     */
    function ownerOf(uint256 tokenId) public view virtual override returns (address) {
        address owner = _owners[tokenId];
        require(owner != address(0), "ERC721: owner query for nonexistent token");
        return owner;
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
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");

        string memory baseURI = _baseURI();
        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, tokenId.toString())) : "";
    }

    /**
     * @dev Base URI for computing {tokenURI}. If set, the resulting URI for each
     * token will be the concatenation of the `baseURI` and the `tokenId`. Empty
     * by default, can be overriden in child contracts.
     */
    function _baseURI() internal view virtual returns (string memory) {
        return "";
    }

    /**
     * @dev See {IERC721-approve}.
     */
    function approve(address to, uint256 tokenId) public virtual override {
        address owner = ERC721.ownerOf(tokenId);
        require(to != owner, "ERC721: approval to current owner");

        require(
            _msgSender() == owner || isApprovedForAll(owner, _msgSender()),
            "ERC721: approve caller is not owner nor approved for all"
        );

        _approve(to, tokenId);
    }

    /**
     * @dev See {IERC721-getApproved}.
     */
    function getApproved(uint256 tokenId) public view virtual override returns (address) {
        require(_exists(tokenId), "ERC721: approved query for nonexistent token");

        return _tokenApprovals[tokenId];
    }

    /**
     * @dev See {IERC721-setApprovalForAll}.
     */
    function setApprovalForAll(address operator, bool approved) public virtual override {
        _setApprovalForAll(_msgSender(), operator, approved);
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
        //solhint-disable-next-line max-line-length
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");

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
        safeTransferFrom(from, to, tokenId, "");
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
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");
        _safeTransfer(from, to, tokenId, _data);
    }

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * `_data` is additional data, it has no specified format and it is sent in call to `to`.
     *
     * This internal function is equivalent to {safeTransferFrom}, and can be used to e.g.
     * implement alternative mechanisms to perform token transfer, such as signature-based.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function _safeTransfer(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) internal virtual {
        _transfer(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, _data), "ERC721: transfer to non ERC721Receiver implementer");
    }

    /**
     * @dev Returns whether `tokenId` exists.
     *
     * Tokens can be managed by their owner or approved accounts via {approve} or {setApprovalForAll}.
     *
     * Tokens start existing when they are minted (`_mint`),
     * and stop existing when they are burned (`_burn`).
     */
    function _exists(uint256 tokenId) internal view virtual returns (bool) {
        return _owners[tokenId] != address(0);
    }

    /**
     * @dev Returns whether `spender` is allowed to manage `tokenId`.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view virtual returns (bool) {
        require(_exists(tokenId), "ERC721: operator query for nonexistent token");
        address owner = ERC721.ownerOf(tokenId);
        return (spender == owner || getApproved(tokenId) == spender || isApprovedForAll(owner, spender));
    }

    /**
     * @dev Safely mints `tokenId` and transfers it to `to`.
     *
     * Requirements:
     *
     * - `tokenId` must not exist.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function _safeMint(address to, uint256 tokenId) internal virtual {
        _safeMint(to, tokenId, "");
    }

    /**
     * @dev Same as {xref-ERC721-_safeMint-address-uint256-}[`_safeMint`], with an additional `data` parameter which is
     * forwarded in {IERC721Receiver-onERC721Received} to contract recipients.
     */
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

    /**
     * @dev Mints `tokenId` and transfers it to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {_safeMint} whenever possible
     *
     * Requirements:
     *
     * - `tokenId` must not exist.
     * - `to` cannot be the zero address.
     *
     * Emits a {Transfer} event.
     */
    function _mint(address to, uint256 tokenId) internal virtual {
        require(to != address(0), "ERC721: mint to the zero address");
        require(!_exists(tokenId), "ERC721: token already minted");

        _beforeTokenTransfer(address(0), to, tokenId);

        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(address(0), to, tokenId);

        _afterTokenTransfer(address(0), to, tokenId);
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
    function _burn(uint256 tokenId) internal virtual {
        address owner = ERC721.ownerOf(tokenId);

        _beforeTokenTransfer(owner, address(0), tokenId);

        // Clear approvals
        _approve(address(0), tokenId);

        _balances[owner] -= 1;
        delete _owners[tokenId];

        emit Transfer(owner, address(0), tokenId);

        _afterTokenTransfer(owner, address(0), tokenId);
    }

    /**
     * @dev Transfers `tokenId` from `from` to `to`.
     *  As opposed to {transferFrom}, this imposes no restrictions on msg.sender.
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
    ) internal virtual {
        require(ERC721.ownerOf(tokenId) == from, "ERC721: transfer from incorrect owner");
        require(to != address(0), "ERC721: transfer to the zero address");

        _beforeTokenTransfer(from, to, tokenId);

        // Clear approvals from the previous owner
        _approve(address(0), tokenId);

        _balances[from] -= 1;
        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(from, to, tokenId);

        _afterTokenTransfer(from, to, tokenId);
    }

    /**
     * @dev Approve `to` to operate on `tokenId`
     *
     * Emits a {Approval} event.
     */
    function _approve(address to, uint256 tokenId) internal virtual {
        _tokenApprovals[tokenId] = to;
        emit Approval(ERC721.ownerOf(tokenId), to, tokenId);
    }

    /**
     * @dev Approve `operator` to operate on all of `owner` tokens
     *
     * Emits a {ApprovalForAll} event.
     */
    function _setApprovalForAll(
        address owner,
        address operator,
        bool approved
    ) internal virtual {
        require(owner != operator, "ERC721: approve to caller");
        _operatorApprovals[owner][operator] = approved;
        emit ApprovalForAll(owner, operator, approved);
    }

    /**
     * @dev Internal function to invoke {IERC721Receiver-onERC721Received} on a target address.
     * The call is not executed if the target address is not a contract.
     *
     * @param from address representing the previous owner of the given token ID
     * @param to target address that will receive the tokens
     * @param tokenId uint256 ID of the token to be transferred
     * @param _data bytes optional data to send along with the call
     * @return bool whether the call correctly returned the expected magic value
     */
    function _checkOnERC721Received(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) private returns (bool) {
        if (to.isContract()) {
            try IERC721Receiver(to).onERC721Received(_msgSender(), from, tokenId, _data) returns (bytes4 retval) {
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

    /**
     * @dev Hook that is called before any token transfer. This includes minting
     * and burning.
     *
     * Calling conditions:
     *
     * - When `from` and `to` are both non-zero, ``from``'s `tokenId` will be
     * transferred to `to`.
     * - When `from` is zero, `tokenId` will be minted for `to`.
     * - When `to` is zero, ``from``'s `tokenId` will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {}
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC721/extensions/IERC721Enumerable.sol)

pragma solidity ^0.8.0;

import "../IERC721.sol";

/**
 * @title ERC-721 Non-Fungible Token Standard, optional enumeration extension
 * @dev See https://eips.ethereum.org/EIPS/eip-721
 */
interface IERC721Enumerable is IERC721 {
    /**
     * @dev Returns the total amount of tokens stored by the contract.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns a token ID owned by `owner` at a given `index` of its token list.
     * Use along with {balanceOf} to enumerate all of ``owner``'s tokens.
     */
    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256);

    /**
     * @dev Returns a token ID at a given `index` of all the tokens stored by the contract.
     * Use along with {totalSupply} to enumerate all tokens.
     */
    function tokenByIndex(uint256 index) external view returns (uint256);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC721/IERC721.sol)

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165.sol";

/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721 is IERC165 {
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
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

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
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);

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
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC721/extensions/IERC721Metadata.sol)

pragma solidity ^0.8.0;

import "../IERC721.sol";

/**
 * @title ERC-721 Non-Fungible Token Standard, optional metadata extension
 * @dev See https://eips.ethereum.org/EIPS/eip-721
 */
interface IERC721Metadata is IERC721 {
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
// OpenZeppelin Contracts (last updated v4.5.0) (utils/Address.sol)

pragma solidity ^0.8.1;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;

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
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/ERC20.sol)

pragma solidity ^0.8.0;

import "./IERC20.sol";
import "./extensions/IERC20Metadata.sol";
import "../../utils/Context.sol";

/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin Contracts guidelines: functions revert
 * instead returning `false` on failure. This behavior is nonetheless
 * conventional and does not conflict with the expectations of ERC20
 * applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * The default value of {decimals} is 18. To select a different value for
     * {decimals} you should overload it.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless this function is
     * overridden;
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * NOTE: If `amount` is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * NOTE: Does not update the allowance if the current allowance
     * is the maximum `uint256`.
     *
     * Requirements:
     *
     * - `from` and `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     * - the caller must have allowance for ``from``'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, _allowances[owner][spender] + addedValue);
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = _allowances[owner][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    /**
     * @dev Moves `amount` of tokens from `sender` to `recipient`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     */
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
        }
        _balances[to] += amount;

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
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

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
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

    /**
     * @dev Spend `amount` form the allowance of `owner` toward `spender`.
     *
     * Does not update the allowance amount in case of infinite allowance.
     * Revert if not enough allowance is available.
     *
     * Might emit an {Approval} event.
     */
    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * has been transferred to `to`.
     * - when `from` is zero, `amount` tokens have been minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens have been burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}

// SPDX-License-Identifier: MIT
// Uniswap V2
pragma solidity 0.8.4;

interface IUniswapV2Router02 {
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function swapExactTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
        external
        payable
        returns (
            uint256 amountToken,
            uint256 amountETH,
            uint256 liquidity
        );

    function getAmountsOut(uint256 amountIn, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);

    function getPair(address tokenA, address tokenB)
        external
        view
        returns (address pair);
}

// SPDX-License-Identifier: MIT
// Uniswap V2
pragma solidity >=0.5.0;

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);

    function getPair(address tokenA, address tokenB)
        external
        view
        returns (address pair);
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0;

interface IPancakePair {
    function getReserves()
        external
        view
        returns (
            uint112 reserve0,
            uint112 reserve1,
            uint32 blockTimestampLast
        );
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";

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