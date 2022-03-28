// SPDX-License-Identifier: MIT LICENSE

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./ISamuraiAndRonin.sol";
import "./IYEN.sol";
import "./ILord.sol";
import "./ISeed.sol";

contract Lord is ILord, Ownable, IERC721Receiver, Pausable {
    using EnumerableSet for EnumerableSet.UintSet;

    // maximum alpha score for a Samurai
    uint8 public constant MAX_ALPHA = 8;

    // struct to store a stake's token, owner, and earning values

    struct Merchant {
        address owner;
        uint80 portions;
        uint80 crossBowsRonin;
        uint80 crossBowsSamurai;
    }

    struct UserInfo {
        uint16 amount;
        uint256 lastDepositTime;
        EnumerableSet.UintSet tokenIds;
    }

    event TokenStaked(address owner, uint256 tokenId, uint256 value);
    event RoninClaimed(uint256 tokenId, uint256 earned, bool unstaked);
    event SamuraiClaimed(uint256 tokenId, uint256 earned, bool unstaked);

    // reference to the SamuraiAndRonin NFT contract
    ISamuraiAndRonin game;
    // reference to the $YEN contract for minting $YEN earnings
    IYEN yen;

    ISeed public randomSource;

    mapping(address => UserInfo) internal userInfo;
    // maps tokenId to stake
    mapping(uint256 => Stake) public lord;
    // maps alpha to all Samurai stakes with that alpha
    mapping(uint256 => Stake[]) public pack;
    // tracks location of each Samurai in Pack
    mapping(uint256 => uint256) public packIndices;

    mapping(address => Merchant) public merchants;

    // total alpha scores staked
    uint256 public totalAlphaStaked = 0;
    // any rewards distributed when no samurais are staked
    uint256 public unaccountedRewards = 0;
    // amount of $YEN due for each alpha point staked
    uint256 public yenPerAlpha = 0;

    // ronin earn 10000 $YEN per day
    uint256 public DAILY_YEN_RATE = 10000 ether;
    // ronin must have 3 days worth of $YEN to unstake or else it's too cold
    uint256 public MINIMUM_TO_EXIT = 3 days;
    uint256 public MINIMUM_TO_EXIT_USEPORTION = 1 days;
    // samurais take a 20% tax on all $YEN claimed
    uint256 public constant YEN_CLAIM_TAX_PERCENTAGE = 20;
    uint256 public constant YEN_CLAIM_TAX_PERCENTAGE_SM = 10;
    uint256 public constant YEN_UNSTAKE_TAX_PERCENTAGE = 25;
    uint256 public constant YEN_UNSTAKE_TAX_PERCENTAGE_SM = 25;
    // there will only ever be (roughly) 2.5 billion $YEN earned through staking
    uint256 public constant MAXIMUM_GLOBAL_YEN = 2500000000 ether;

    uint256 public constant PORTION_PRICE = 7500 ether;
    uint256 public constant CROSSBOW_PRICE_RONIN = 7000 ether;
    uint256 public constant CROSSBOW_PRICE_SAMURAI = 8750 ether;

    uint16 public constant TOTAL_PORTION = 1000;
    uint16 public constant TOTAL_CROSSBOW_RONIN = 1000;
    uint16 public constant TOTAL_CROSSBOW_SM = 1000;

    uint16 public remainPortions = TOTAL_PORTION;
    uint16 public remainCrossbows_Ronin = TOTAL_CROSSBOW_RONIN;
    uint16 public remainCrossbows_SM = TOTAL_CROSSBOW_SM;
    
    // amount of $YEN earned so far
    uint256 public totalYenEarned;
    // number of Ronin staked in the Lord
    uint256 public totalRoninStaked;
    // the last time $YEN was claimed
    uint256 public lastClaimTimestamp;

    // emergency rescue to allow unstaking without any checks but without $YEN
    bool public rescueEnabled = false;

    bool private _reentrant = false;

    modifier nonReentrant() {
        require(!_reentrant, "No reentrancy");
        _reentrant = true;
        _;
        _reentrant = false;
    }

    /**
     * @param _game reference to the SamuraiAndRonin NFT contract
   * @param _yen reference to the $YEN token
   */
    constructor(ISamuraiAndRonin _game, IYEN _yen) {
        game = _game;
        yen = _yen;
    }

    function setRandomSource(ISeed _seed) external onlyOwner {
        randomSource = _seed;
    }

    /***STAKING */

    /**
     * adds Ronin and Samurais to the Lord and Pack
     * @param account the address of the staker
   * @param tokenIds the IDs of the Ronin and Samurais to stake
   */
    function addManyToLord(address account, uint16[] calldata tokenIds) external override nonReentrant {
        require((account == _msgSender() && account == tx.origin) || _msgSender() == address(game), "DONT GIVE YOUR TOKENS AWAY");

        for (uint i = 0; i < tokenIds.length; i++) {
            if (tokenIds[i] == 0) {
                continue;
            }

            if (_msgSender() != address(game)) {// dont do this step if its a mint + stake
                require(game.ownerOf_(tokenIds[i]) == _msgSender(), "AINT YO TOKEN");
                game.transferFrom_(_msgSender(), address(this), tokenIds[i]);
            }

            if (isRonin(tokenIds[i]))
                _addRoninToLord(account, tokenIds[i]);
            else
                _addSamuraiToLord(account, tokenIds[i]);

            UserInfo storage user = userInfo[_msgSender()];
            user.amount = user.amount + 1;
            user.lastDepositTime = block.timestamp;
            user.tokenIds.add(tokenIds[i]);
        }
    }

    /**
     * adds a single Ronin to the Lord
     * @param account the address of the staker
   * @param tokenId the ID of the Ronin to add to the Lord
   */
    function _addRoninToLord(address account, uint256 tokenId) internal whenNotPaused _updateEarnings {
        lord[tokenId] = Stake({
            owner : account,
            tokenId : uint16(tokenId),
            value : uint80(block.timestamp)
        });
        totalRoninStaked += 1;
        emit TokenStaked(account, tokenId, block.timestamp);
    }

    /**
     * adds a single Samurai to the Lord
     * @param account the address of the staker
   * @param tokenId the ID of the Samurai to add to the Lord
   */
    function _addSamuraiToLord(address account, uint256 tokenId) internal {
        uint256 alpha = _alphaForSamurai(tokenId);
        totalAlphaStaked += alpha;
        // Portion of earnings ranges from 8 to 5
        packIndices[tokenId] = pack[alpha].length;
        // Store the location of the samurai in the Pack
        // pack[alpha].push(Stake({
        //     owner : account,
        //     tokenId : uint16(tokenId),
        //     value : uint80(yenPerAlpha)
        // }));
        lord[tokenId] = Stake({
            owner : account,
            tokenId : uint16(tokenId),
            value : uint80(block.timestamp)
        });
        // Add the samurai to the Pack
        emit TokenStaked(account, tokenId, yenPerAlpha);
    }

    /***CLAIMING / UNSTAKING */

    /**
     * realize $YEN earnings and optionally unstake tokens from the Lord / Pack
     * to unstake a Ronin it will require it has 3 days worth of $YEN unclaimed
     * @param tokenIds the IDs of the tokens to claim earnings from
   * @param unstake whether or not to unstake ALL of the tokens listed in tokenIds
   */
    function claimManyFromLord(uint16[] calldata tokenIds, bool unstake, bool usePortion, bool useCrossbow) external nonReentrant whenNotPaused _updateEarnings {
        require(msg.sender == tx.origin, "Only EOA");
        uint256 owed = 0;
        for (uint i = 0; i < tokenIds.length; i++) {
            if (isRonin(tokenIds[i]))
                owed += _claimRoninFromLord(tokenIds[i], unstake, usePortion, useCrossbow);
            else
                owed += _claimSamuraiFromLord(tokenIds[i], unstake, useCrossbow);
        }
        if (owed == 0) return;

        Merchant storage merchantInfo = merchants[_msgSender()];
        if (merchantInfo.crossBowsRonin > 0) {
            owed = owed * 125 / 100;
            merchantInfo.crossBowsRonin = merchantInfo.crossBowsRonin - 1;
        }
        yen.transfer(_msgSender(), owed);
    }

    /**
     * realize $YEN earnings for a single Ronin and optionally unstake it
     * earns 10.000 $YEN a day when staked
     * if not unstaking, pay a 20% tax to be burn
     * if unstaking, there is a 25% tax to be burn and 30.000 $YEN is needed in order to unstake  
     * @param tokenId the ID of the Ronin to claim earnings from
   * @param unstake whether or not to unstake the Ronin
   * @return owed - the amount of $YEN earned
   */
    function _claimRoninFromLord(uint256 tokenId, bool unstake, bool usePortion, bool useCrossbow) internal returns (uint256 owed) {
        Stake memory stake = lord[tokenId];
        require(stake.owner == _msgSender(), "SWIPER, NO SWIPING");
        if (unstake == true && usePortion == true && merchants[_msgSender()].portions > 0) {
            require(!(unstake && block.timestamp - stake.value < MINIMUM_TO_EXIT_USEPORTION), "You should noe unstake without one day's YEN in the case of using portion");
            merchants[_msgSender()].portions = merchants[_msgSender()].portions - 1;
        } else {
            require(!(unstake && block.timestamp - stake.value < MINIMUM_TO_EXIT), "You should not unstake in three day's YEN");
        }

        if (totalYenEarned < MAXIMUM_GLOBAL_YEN) {
            owed = (block.timestamp - stake.value) * DAILY_YEN_RATE / 1 days;
        } else if (stake.value > lastClaimTimestamp) {
            owed = 0;
            // $YEN production stopped already
        } else {
            owed = (lastClaimTimestamp - stake.value) * DAILY_YEN_RATE / 1 days;
            // stop earning additional $YEN if it's all been earned
        }

        if(useCrossbow && merchants[_msgSender()].crossBowsRonin > 0) {
            owed = owed * 125 / 100;
            merchants[_msgSender()].crossBowsRonin = merchants[_msgSender()].crossBowsRonin - 1;
        }

        if (unstake) {
            Merchant memory merchantInfo = merchants[stake.owner];
            uint256 yenUnstakeTaxPecent = YEN_UNSTAKE_TAX_PERCENTAGE;
            if (merchantInfo.portions > 0) {
                yenUnstakeTaxPecent = yenUnstakeTaxPecent / 2;
            }

            uint256 taxFee = owed * yenUnstakeTaxPecent / 100;
            yen.burn(address(this), taxFee);
            // percentage tax to staked samurais
            owed = owed * (100 - yenUnstakeTaxPecent) / 100;

            game.transferFrom_(address(this), _msgSender(), tokenId);
            // send back Ronin
            delete lord[tokenId];
            totalRoninStaked -= 1;

            UserInfo storage user = userInfo[_msgSender()];
            user.amount = user.amount - 1;
            user.lastDepositTime = block.timestamp;
            user.tokenIds.remove(tokenId);
        } else {
            // _paySamuraiTax(owed * YEN_CLAIM_TAX_PERCENTAGE / 100);
            uint256 taxFee = owed * YEN_CLAIM_TAX_PERCENTAGE / 100;
            yen.burn(address(this), taxFee);
            // percentage tax to staked samurais
            owed = owed * (100 - YEN_CLAIM_TAX_PERCENTAGE) / 100;
            // remainder goes to Ronin owner
            lord[tokenId] = Stake({
                owner : _msgSender(),
                tokenId : uint16(tokenId),
                value : uint80(block.timestamp)
            });
            // reset stake
        }
        emit RoninClaimed(tokenId, owed, unstake);
    }

    /**
        * realize $YEN earnings for a single Samurai and optionally unstake it
        *	A5 earns: 12.500 $YEN a day when staked.
        *	A6 earns: 15.000 $YEN a day when staked.
        *	A7 earns: 17.500 $YEN a day when staked.
        *	A8 earns: 20.000 $YEN a day when staked.
        * if not unstaking, pay a 10% tax to be burn
        * if unstaking, there is a 25% tax to be burn and doesn’t need any required amount to unstake for samurai
        * @param tokenId the ID of the Ronin to claim earnings from
    * @param unstake whether or not to unstake the Ronin
    * @return owed - the amount of $YEN earned
    */
    function _claimSamuraiFromLord(uint256 tokenId, bool unstake, bool useCrossbow) internal returns (uint256 owed) {
        Stake memory stake = lord[tokenId];
        require(stake.owner == _msgSender(), "SWIPER, NO SWIPING");

        uint256 alpha = _alphaForSamurai(tokenId);
        uint256 dailyYenRate = DAILY_YEN_RATE + 2500 * (alpha - 4);
        if (totalYenEarned < MAXIMUM_GLOBAL_YEN) {
            owed = (block.timestamp - stake.value) * dailyYenRate / 1 days;
        } else if (stake.value > lastClaimTimestamp) {
            owed = 0;
            // $YEN production stopped already
        } else {
            owed = (lastClaimTimestamp - stake.value) * dailyYenRate / 1 days;
            // stop earning additional $YEN if it's all been earned
        }

        if(useCrossbow && merchants[_msgSender()].crossBowsSamurai > 0) {
            owed = owed * 125 / 100;
            merchants[_msgSender()].crossBowsSamurai = merchants[_msgSender()].crossBowsSamurai - 1;
        }


        if (unstake) {
            uint256 taxFee = owed * YEN_UNSTAKE_TAX_PERCENTAGE_SM / 100;
            yen.burn(address(this), taxFee);
            // percentage tax to staked samurais
            owed = owed * (100 - YEN_UNSTAKE_TAX_PERCENTAGE_SM) / 100;

            game.transferFrom_(address(this), _msgSender(), tokenId);
            // send back Ronin
            delete lord[tokenId];
            // totalRoninStaked -= 1;
            totalAlphaStaked -= alpha;

            UserInfo storage user = userInfo[_msgSender()];
            user.amount = user.amount - 1;
            user.lastDepositTime = block.timestamp;
            user.tokenIds.remove(tokenId);
        } else {
            // _paySamuraiTax(owed * YEN_CLAIM_TAX_PERCENTAGE / 100);
            uint256 taxFee = owed * YEN_CLAIM_TAX_PERCENTAGE_SM / 100;
            yen.burn(address(this), taxFee);
            // percentage tax to staked samurais
            owed = owed * (100 - YEN_CLAIM_TAX_PERCENTAGE_SM) / 100;
            // remainder goes to Ronin owner
            lord[tokenId] = Stake({
                owner : _msgSender(),
                tokenId : uint16(tokenId),
                value : uint80(block.timestamp)
            });
            // reset stake
        }
        emit SamuraiClaimed(tokenId, owed, unstake);
    }


    /**
     * emergency unstake tokens
     * @param tokenIds the IDs of the tokens to claim earnings from
   */
    function rescue(uint256[] calldata tokenIds) external nonReentrant {
        require(rescueEnabled, "RESCUE DISABLED");
        uint256 tokenId;
        Stake memory stake;
        Stake memory lastStake;
        uint256 alpha;
        for (uint i = 0; i < tokenIds.length; i++) {
            tokenId = tokenIds[i];
            if (isRonin(tokenId)) {
                stake = lord[tokenId];
                require(stake.owner == _msgSender(), "SWIPER, NO SWIPING");
                game.transferFrom_(address(this), _msgSender(), tokenId);
                // send back Ronin
                delete lord[tokenId];
                totalRoninStaked -= 1;
                emit RoninClaimed(tokenId, 0, true);
            } else {
                alpha = _alphaForSamurai(tokenId);
                stake = pack[alpha][packIndices[tokenId]];
                require(stake.owner == _msgSender(), "SWIPER, NO SWIPING");
                totalAlphaStaked -= alpha;
                // Remove Alpha from total staked
                game.transferFrom_(address(this), _msgSender(), tokenId);
                // Send back Samurai
                lastStake = pack[alpha][pack[alpha].length - 1];
                pack[alpha][packIndices[tokenId]] = lastStake;
                // Shuffle last Samurai to current position
                packIndices[lastStake.tokenId] = packIndices[tokenId];
                pack[alpha].pop();
                // Remove duplicate
                delete packIndices[tokenId];
                // Delete old mapping
                emit SamuraiClaimed(tokenId, 0, true);
            }
        }
    }

    /***ACCOUNTING */

    /**
     * add $YEN to claimable pot for the Pack
     * @param amount $YEN to add to the pot
   */
    function _paySamuraiTax(uint256 amount) internal {
        if (totalAlphaStaked == 0) {// if there's no staked samurais
            unaccountedRewards += amount;
            // keep track of $YEN due to samurais
            return;
        }
        // makes sure to include any unaccounted $YEN
        yenPerAlpha += (amount + unaccountedRewards) / totalAlphaStaked;
        unaccountedRewards = 0;
    }

    /**
     * tracks $YEN earnings to ensure it stops once 2.5 billion is eclipsed
     */
    modifier _updateEarnings() {
        if (totalYenEarned < MAXIMUM_GLOBAL_YEN) {
            totalYenEarned +=
            (block.timestamp - lastClaimTimestamp)
            * totalRoninStaked
            * DAILY_YEN_RATE / 1 days;
            lastClaimTimestamp = block.timestamp;
        }
        _;
    }

    /***ADMIN */

    function setSettings(uint256 rate, uint256 exit) external onlyOwner {
        MINIMUM_TO_EXIT = exit;
        DAILY_YEN_RATE = rate;
    }

    /**
     * allows owner to enable "rescue mode"
     * simplifies accounting, prioritizes tokens out in emergency
     */
    function setRescueEnabled(bool _enabled) external onlyOwner {
        rescueEnabled = _enabled;
    }

    /**
     * enables owner to pause / unpause minting
     */
    function setPaused(bool _paused) external onlyOwner {
        if (_paused) _pause();
        else _unpause();
    }

    /***READ ONLY */

    /**
     * checks if a token is a Ronin
     * @param tokenId the ID of the token to check
   * @return ronin - whether or not a token is a Ronin
   */
    function isRonin(uint256 tokenId) public view returns (bool) {
        // (ronin, , , , , , , , , , ) = game.tokenTraits(tokenId);
        return game.isRonin(tokenId);
    }

    /**
     * gets the alpha score for a Samurai
     * @param tokenId the ID of the Samurai to get the alpha score for
   * @return the alpha score of the Samurai (5-8)
   */
    function _alphaForSamurai(uint256 tokenId) internal view returns (uint8) {
        // (, , , , , , , , uint8 alphaIndex, , ) = game.tokenTraits(tokenId);
        return MAX_ALPHA - game.getAlphaForSamurai(tokenId);
        // alpha index is 0-3
    }

    /**
     * chooses a random Samurai ronin when a newly minted token is stolen
     * @param seed a random value to choose a Samurai from
   * @return the owner of the randomly selected Samurai ronin
   */
    function randomSamuraiOwner(uint256 seed) external override view returns (address) {
        if (totalAlphaStaked == 0) return address(0x0);
        uint256 bucket = (seed & 0xFFFFFFFF) % totalAlphaStaked;
        // choose a value from 0 to total alpha staked
        uint256 cumulative;
        seed >>= 32;
        // loop through each bucket of Samurais with the same alpha score
        for (uint i = MAX_ALPHA - 3; i <= MAX_ALPHA; i++) {
            cumulative += pack[i].length * i;
            // if the value is not inside of that bucket, keep going
            if (bucket >= cumulative) continue;
            // get the address of a random Samurai with that alpha score
            return pack[i][seed % pack[i].length].owner;
        }
        return address(0x0);
    }

    /**
     * generates a pseudorandom number
     * @param seed a value ensure different outcomes for different sources in the same block
   * @return a pseudorandom value
   */
    function random(uint256 seed) internal view returns (uint256) {
        return uint256(keccak256(abi.encodePacked(
                tx.origin,
                blockhash(block.number - 1),
                block.timestamp,
                seed,
                totalRoninStaked,
                totalAlphaStaked,
                lastClaimTimestamp
            ))); // ^ randomSource.seed();
    }

    function onERC721Received(
        address,
        address from,
        uint256,
        bytes calldata
    ) external pure override returns (bytes4) {
        require(from == address(0x0), "Cannot send tokens to Lord directly");
        return IERC721Receiver.onERC721Received.selector;
    }

    function buyPortions(uint80 _amount) external {
        require(yen.balanceOf(_msgSender()) > _amount * PORTION_PRICE, "Not enough Yen amount!");
        require(remainPortions >= _amount, "Invalid amount");

        yen.burn(_msgSender(), _amount * PORTION_PRICE);
        Merchant storage merchantInfo = merchants[_msgSender()];
        merchantInfo.portions = merchantInfo.portions + _amount;
    }

    function buyCrossBows(uint80 _amount, bool _forRonin) external {
        uint256 price;
        if (_forRonin) {
            require(remainCrossbows_Ronin >= _amount, "Invalid amount");
            price = CROSSBOW_PRICE_RONIN;
        } else {
            require(remainCrossbows_SM >= _amount, "Invalid amount");
            price = CROSSBOW_PRICE_SAMURAI;
        }
        require(yen.balanceOf(_msgSender()) > _amount * price, "Not enough Yen amount!");

        yen.burn(_msgSender(), _amount * price);
        Merchant storage merchantInfo = merchants[_msgSender()];
        if (_forRonin) {
            merchantInfo.crossBowsRonin = merchantInfo.crossBowsRonin + _amount; 
        } else {
            merchantInfo.crossBowsSamurai = merchantInfo.crossBowsSamurai + _amount; 
        } 
    }

    function getStakeIdInfo(uint16 _tokenId) external override view returns (Stake memory stakeInfo) {
        stakeInfo = lord[_tokenId];
    }

    function getStakeUserInfo(address _account) external override view returns (uint256[] memory _tokenIds) {
        require(_account != address(0), "Invalid account");
        
        UserInfo storage user = userInfo[_account];
        _tokenIds = new uint256[](user.amount);
        for (uint16 i = 0; i < user.amount; i++) {
            _tokenIds[i] = user.tokenIds.at(i);
        }
    }

    function pendingTokenReward(uint256 _tokenId) external view returns (uint256) {
        uint256 reward;
        Stake memory stake = lord[_tokenId];

        uint256 alpha = 4;
        if (!isRonin(_tokenId)) {
            alpha = _alphaForSamurai(_tokenId);
        }
            
        uint256 dailyYenRate = DAILY_YEN_RATE + 2500 * (alpha - 4);

        if (totalYenEarned < MAXIMUM_GLOBAL_YEN) {
            reward = (block.timestamp - stake.value) * dailyYenRate / 1 days;
        } else if (stake.value > lastClaimTimestamp) {
            reward = 0;
        } else {
            reward = (lastClaimTimestamp - stake.value) * dailyYenRate / 1 days;
        }

        return reward;
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
// OpenZeppelin Contracts v4.4.1 (utils/structs/EnumerableSet.sol)

pragma solidity ^0.8.0;

/**
 * @dev Library for managing
 * https://en.wikipedia.org/wiki/Set_(abstract_data_type)[sets] of primitive
 * types.
 *
 * Sets have the following properties:
 *
 * - Elements are added, removed, and checked for existence in constant time
 * (O(1)).
 * - Elements are enumerated in O(n). No guarantees are made on the ordering.
 *
 * ```
 * contract Example {
 *     // Add the library methods
 *     using EnumerableSet for EnumerableSet.AddressSet;
 *
 *     // Declare a set state variable
 *     EnumerableSet.AddressSet private mySet;
 * }
 * ```
 *
 * As of v3.3.0, sets of type `bytes32` (`Bytes32Set`), `address` (`AddressSet`)
 * and `uint256` (`UintSet`) are supported.
 */
library EnumerableSet {
    // To implement this library for multiple types with as little code
    // repetition as possible, we write it in terms of a generic Set type with
    // bytes32 values.
    // The Set implementation uses private functions, and user-facing
    // implementations (such as AddressSet) are just wrappers around the
    // underlying Set.
    // This means that we can only create new EnumerableSets for types that fit
    // in bytes32.

    struct Set {
        // Storage of set values
        bytes32[] _values;
        // Position of the value in the `values` array, plus 1 because index 0
        // means a value is not in the set.
        mapping(bytes32 => uint256) _indexes;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function _add(Set storage set, bytes32 value) private returns (bool) {
        if (!_contains(set, value)) {
            set._values.push(value);
            // The value is stored at length-1, but we add 1 to all indexes
            // and use 0 as a sentinel value
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function _remove(Set storage set, bytes32 value) private returns (bool) {
        // We read and store the value's index to prevent multiple reads from the same storage slot
        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) {
            // Equivalent to contains(set, value)
            // To delete an element from the _values array in O(1), we swap the element to delete with the last one in
            // the array, and then remove the last element (sometimes called as 'swap and pop').
            // This modifies the order of the array, as noted in {at}.

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;

            if (lastIndex != toDeleteIndex) {
                bytes32 lastvalue = set._values[lastIndex];

                // Move the last value to the index where the value to delete is
                set._values[toDeleteIndex] = lastvalue;
                // Update the index for the moved value
                set._indexes[lastvalue] = valueIndex; // Replace lastvalue's index to valueIndex
            }

            // Delete the slot where the moved value was stored
            set._values.pop();

            // Delete the index for the deleted slot
            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function _contains(Set storage set, bytes32 value) private view returns (bool) {
        return set._indexes[value] != 0;
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function _length(Set storage set) private view returns (uint256) {
        return set._values.length;
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function _at(Set storage set, uint256 index) private view returns (bytes32) {
        return set._values[index];
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function _values(Set storage set) private view returns (bytes32[] memory) {
        return set._values;
    }

    // Bytes32Set

    struct Bytes32Set {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _add(set._inner, value);
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _remove(set._inner, value);
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(Bytes32Set storage set, bytes32 value) internal view returns (bool) {
        return _contains(set._inner, value);
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(Bytes32Set storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(Bytes32Set storage set, uint256 index) internal view returns (bytes32) {
        return _at(set._inner, index);
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(Bytes32Set storage set) internal view returns (bytes32[] memory) {
        return _values(set._inner);
    }

    // AddressSet

    struct AddressSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(AddressSet storage set, address value) internal returns (bool) {
        return _add(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(AddressSet storage set, address value) internal returns (bool) {
        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(AddressSet storage set, address value) internal view returns (bool) {
        return _contains(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(AddressSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(AddressSet storage set, uint256 index) internal view returns (address) {
        return address(uint160(uint256(_at(set._inner, index))));
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(AddressSet storage set) internal view returns (address[] memory) {
        bytes32[] memory store = _values(set._inner);
        address[] memory result;

        assembly {
            result := store
        }

        return result;
    }

    // UintSet

    struct UintSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(UintSet storage set, uint256 value) internal returns (bool) {
        return _add(set._inner, bytes32(value));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(UintSet storage set, uint256 value) internal returns (bool) {
        return _remove(set._inner, bytes32(value));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(UintSet storage set, uint256 value) internal view returns (bool) {
        return _contains(set._inner, bytes32(value));
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function length(UintSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(UintSet storage set, uint256 index) internal view returns (uint256) {
        return uint256(_at(set._inner, index));
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(UintSet storage set) internal view returns (uint256[] memory) {
        bytes32[] memory store = _values(set._inner);
        uint256[] memory result;

        assembly {
            result := store
        }

        return result;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

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
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
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

// SPDX-License-Identifier: MIT LICENSE

pragma solidity ^0.8.0;

interface ISamuraiAndRonin {

    // struct to store each token's traits
    struct RoninSamurai {
        bool isRonin;
        uint8 uniform;  // 1
        uint8 head;     // 2
        uint8 facialHair;   // 4
        uint8 eyes;     // 3
        uint8 headgear; // 5
        uint8 neckGear; // 6
        uint8 accessory;    // 7
        uint8 alphaIndex;

        bool forSale;
        uint256 price;
    }

    function getPaidTokens() external view returns (uint256);
    function getTokenTraits(uint256 tokenId) external view returns (RoninSamurai memory);
    function buyNFT(uint256 _tokenId, uint256 _amount) external returns (bool);
    function burn(uint256 tokenId) external;
    function ownerOf_(uint256) external returns (address);
    function transferFrom_(address _from, address _to, uint256 _tokenId) external;
    function isRonin(uint256 tokenId) external view returns (bool);
    function getAlphaForSamurai(uint256 tokenId) external view returns(uint8);
}

// SPDX-License-Identifier: MIT LICENSE

pragma solidity ^0.8.0;

interface IYEN  {

    function burn(address from, uint256 amount) external;
    function transferFrom(address from, address to, uint256 amount) external;
    function transfer(address to, uint256 amount) external;
    function balanceOf(address account) external returns (uint256);
}

// SPDX-License-Identifier: MIT LICENSE

pragma solidity ^0.8.0;

interface ILord {
    
    struct Stake {
        uint16 tokenId;
        uint80 value;
        address owner;
    }

    function addManyToLord(address account, uint16[] calldata tokenIds) external;
    function randomSamuraiOwner(uint256 seed) external view returns (address);
    // function lord(uint256) external view returns(uint16, uint80, address);
    // function totalYenEarned() external view returns(uint256);
    // function lastClaimTimestamp() external view returns(uint256);
    // function setOldTokenInfo(uint256 _tokenId) external;

    // function pack(uint256, uint256) external view returns(Stake memory);
    // function packIndices(uint256) external view returns(uint256);

    function getStakeIdInfo(uint16 _tokenId) external view returns (Stake memory stakeInfo);
    function getStakeUserInfo(address _account) external view returns (uint256[] memory _tokenIds);
}

// SPDX-License-Identifier: MIT LICENSE
pragma solidity ^0.8.0;

interface ISeed {
    function seed() external view returns(uint256);
    function update(uint256 _seed) external returns(uint256);
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