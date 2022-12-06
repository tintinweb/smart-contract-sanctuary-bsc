// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;
import "ERC20.sol";
import "MythToken.sol";

contract BasePVPGames {
    address payable public owner;

    uint256 public gameCount;
    address public bobAddress;
    address payable public mythAddress;
    bool public startGames = true;
    bool public callBobGames = true;
    bool public withdrawEnabled = true;
    mapping(address => uint256) public bobBalanceOfToken;
    mapping(address => uint256) public ownerPercent;
    mapping(address => uint256) public bountyPercent;
    mapping(address => uint256) public pooledRewardsBounty;
    mapping(address => uint256) public pooledRewardsOwner;
    mapping(address => mapping(address => bool)) public canClaimBountyPool;
    mapping(address => mapping(address => bool)) public canClaimOwnerPool;
    // address payable public bountyPool;
    mapping(address => uint256) public minBetOfToken;
    mapping(address => uint256) public maxBetOfToken;
    mapping(address => mapping(address => uint256))
        public unclaimedRewardsOfUser;
    mapping(uint256 => bool) public resolvedBlocks;
    mapping(address => bool) public resolverAddresses;
    mapping(uint256 => gameStruct) public gameDataFromId;
    mapping(uint256 => uint256) public gameIdFromCountNumber;
    mapping(uint256 => bool) public activeGameId;
    mapping(uint256 => uint256) public blockNumberGameCount;
    mapping(uint256 => mapping(uint256 => uint256))
        public gameIdFromBlockNumberAndItter;

    struct gameStruct {
        uint8 gameType;
        uint8 challengerSide;
        uint8 gameState; // 0 means placed by challenger, 1 means called by caller, 2 means resolved
        uint256 gameCount;
        uint256 wagerAmount;
        uint256 blockInitialized;
        address betCurrency;
        address challenger;
        address caller;
    }
    event betLimitChanged(bool isMin, address currency, uint256 amount);
    event winningsAdded(address winner, address currency, uint256 amount);
    event gameCancelled(uint256 gameCount);
    event feesPaid(address currency, uint256 amount, bool isBounty);
    event feesClaimed(
        address currency,
        address claimer,
        uint256 amount,
        bool isBounty
    );
    event gameCalled(
        uint256 gameCount,
        uint256 blockNumberInitialized,
        address caller
    );
    event gameResolved(
        uint256 gameCount,
        bool challengerWinner,
        bytes32 resolutionSeed
    );
    event gameStarted(
        uint8 gameType,
        uint8 challengerSide,
        uint256 wagerAmount,
        uint256 gameCount,
        uint256 gameId,
        address challenger,
        address currency
    );
    event bobBalanceChanged(address currency, uint256 amount);
    event claimedWinnings(address winner, address currency, uint256 amount);

    constructor(address _myth) {
        owner = payable(msg.sender);
        mythAddress = payable(_myth);
    }

    function enableGames(bool _enable) external {
        require(msg.sender == owner, "only owner");
        startGames = _enable;
    }

    function enableBob(bool _enable) external {
        require(msg.sender == owner, "only owner");
        callBobGames = _enable;
    }

    function enableWithdraw(bool _enable) external {
        require(msg.sender == owner, "only owner");
        withdrawEnabled = _enable;
    }

    function changeBountyClaimer(
        address _token,
        address _claimer,
        bool _claimable
    ) external {
        require(msg.sender == owner, "only owner");
        canClaimBountyPool[_claimer][_token] = _claimable;
    }

    function changeOwnerClaimer(
        address _token,
        address _claimer,
        bool _claimable
    ) external {
        require(msg.sender == owner, "only owner");
        canClaimOwnerPool[_claimer][_token] = _claimable;
    }

    function changePercents(
        address _token,
        uint256 _bounty,
        uint256 _owner
    ) external {
        require(msg.sender == owner, "only owner");
        ownerPercent[_token] = _owner;
        bountyPercent[_token] = _bounty;
    }

    function changeMinBet(uint256 _amount, address _token) external {
        require(msg.sender == owner, "only owner");
        minBetOfToken[_token] = _amount;
        emit betLimitChanged(true, _token, _amount);
    }

    function changeMaxBet(uint256 _amount, address _token) external {
        require(msg.sender == owner, "only owner");
        maxBetOfToken[_token] = _amount;
        emit betLimitChanged(false, _token, _amount);
    }

    function changeResolver(address _address, bool _bool) external {
        require(msg.sender == owner, "only owner");
        resolverAddresses[_address] = _bool;
    }

    function changeBobAddress(address _address) external {
        require(msg.sender == owner, "only owner");
        bobAddress = _address;
    }

    function depoBob(address _token, uint256 _amount) external payable {
        require(msg.sender == owner, "only owner");
        if (_token == address(0)) {
            bobBalanceOfToken[address(0)] += msg.value;
            emit bobBalanceChanged(address(0), bobBalanceOfToken[address(0)]);
        } else {
            ERC20 tokenContract = ERC20(_token);
            tokenContract.transferFrom(msg.sender, address(this), _amount);
            bobBalanceOfToken[_token] += _amount;
            emit bobBalanceChanged(_token, bobBalanceOfToken[_token]);
        }
    }

    function changeBobsBalance(address _token, uint256 _amount) external {
        require(msg.sender == owner, "only owner");
        bobBalanceOfToken[_token] = _amount;
        emit bobBalanceChanged(_token, _amount);
    }

    function withdrawFees(
        address _token,
        uint256 _amount,
        bool _bounty
    ) external payable {
        if (_bounty) {
            require(
                canClaimBountyPool[msg.sender][_token],
                "Cannot Claim this tokens from bounty pool"
            );
            require(
                pooledRewardsBounty[_token] >= _amount,
                "Not enough pooled"
            );
            if (_token == address(0)) {
                pooledRewardsBounty[_token] -= _amount;
                (bool successUser, ) = msg.sender.call{value: _amount}("");
                require(successUser, "Transfer to user failed");
            } else {
                pooledRewardsBounty[_token] -= _amount;
                ERC20 tokenContract = ERC20(_token);
                tokenContract.transfer(msg.sender, _amount);
            }
        } else {
            require(
                canClaimOwnerPool[msg.sender][_token],
                "Cannot Claim this tokens from owner pool"
            );
            require(pooledRewardsOwner[_token] >= _amount, "Not enough pooled");
            if (_token == address(0)) {
                pooledRewardsOwner[_token] -= _amount;
                (bool successUser, ) = msg.sender.call{value: _amount}("");
                require(successUser, "Transfer to user failed");
            } else {
                pooledRewardsOwner[_token] -= _amount;
                ERC20 tokenContract = ERC20(_token);
                tokenContract.transfer(msg.sender, _amount);
            }
        }
        emit feesClaimed(_token, msg.sender, _amount, _bounty);
    }

    function rescueTokens(address _token, uint256 _amount) external payable {
        require(msg.sender == owner, "only owner");
        if (_token == address(0)) {
            (bool successUser, ) = msg.sender.call{value: _amount}("");
            require(successUser, "Transfer to user failed");
        } else {
            ERC20 tokenContract = ERC20(_token);
            tokenContract.transfer(msg.sender, _amount);
        }
    }

    function viewBalance(address _token) public view returns (uint256) {
        if (_token == address(0)) {
            return address(this).balance;
        } else {
            ERC20 tokenContract = ERC20(_token);
            tokenContract.balanceOf(address(this));
        }
    }

    function getUserRewards(address _currency, address _user)
        public
        view
        returns (uint256)
    {
        return unclaimedRewardsOfUser[_user][_currency];
    }

    function cancelGame(uint256 _gameCount) public payable {
        require(msg.value == 0, "Dont send bnb");
        uint256 _gameId = gameIdFromCountNumber[_gameCount];
        gameStruct memory tempGame = gameDataFromId[_gameId];
        require(
            tempGame.challenger == msg.sender || msg.sender == owner,
            "Only creator of game can cancel it"
        );

        require(tempGame.gameState == 0, "Game must be in placed state");
        gameDataFromId[_gameId].gameState = 2;
        if (tempGame.betCurrency == address(0)) {
            (bool successUser, ) = tempGame.challenger.call{
                value: tempGame.wagerAmount
            }("");
            require(successUser, "Transfer to user failed");
        } else if (tempGame.betCurrency == mythAddress) {
            MythToken mythContract = MythToken(mythAddress);
            mythContract.mintTokens(tempGame.wagerAmount, tempGame.challenger);
        } else {
            ERC20 tokenContract = ERC20(tempGame.betCurrency);
            tokenContract.transfer(tempGame.challenger, tempGame.wagerAmount);
        }
        activeGameId[_gameId] = false;
        emit gameCancelled(_gameCount);
    }

    function callBob(uint256 _gameCount) public {
        require(callBobGames, "Bob is not enabled");
        uint256 _gameId = gameIdFromCountNumber[_gameCount];
        gameStruct memory tempGame = gameDataFromId[_gameId];
        require(tempGame.gameState == 0, "Game must be in placed state");
        require(
            tempGame.challenger == msg.sender,
            "Only creator of game can call bob"
        );
        require(
            tempGame.wagerAmount <= maxBetOfToken[tempGame.betCurrency],
            "Bet too big for Bob"
        );
        if (tempGame.betCurrency != mythAddress) {
            require(
                bobBalanceOfToken[tempGame.betCurrency] >= tempGame.wagerAmount,
                "Bob Doesn't have enough"
            );
            bobBalanceOfToken[tempGame.betCurrency] -= tempGame.wagerAmount;
            emit bobBalanceChanged(
                tempGame.betCurrency,
                bobBalanceOfToken[tempGame.betCurrency]
            );
        }

        tempGame.caller = bobAddress;
        tempGame.blockInitialized = block.number;
        tempGame.gameState = 1;
        gameDataFromId[_gameId] = tempGame;
        uint256 currentBlockCount = blockNumberGameCount[block.number];
        gameIdFromBlockNumberAndItter[block.number][
            currentBlockCount
        ] = _gameId;
        blockNumberGameCount[block.number] += 1;
        emit gameCalled(tempGame.gameCount, block.number, bobAddress);
    }

    function callTokenGame(uint256 _gameCount) external {
        require(startGames, "Games are not enabled");
        uint256 _gameId = gameIdFromCountNumber[_gameCount];
        gameStruct memory tempGame = gameDataFromId[_gameId];
        require(address(0) != tempGame.betCurrency, "Bet Currency is BNB");
        require(tempGame.wagerAmount > 0, "This Game Has No Wager");
        require(tempGame.gameState == 0, "Game must be in placed state");
        tempGame.caller = msg.sender;
        tempGame.blockInitialized = block.number;
        tempGame.gameState = 1;
        gameDataFromId[_gameId] = tempGame;
        if (tempGame.betCurrency == mythAddress) {
            MythToken mythContract = MythToken(mythAddress);
            mythContract.burnTokens(tempGame.wagerAmount, msg.sender);
        } else {
            ERC20 tokenContract = ERC20(tempGame.betCurrency);
            tokenContract.transferFrom(
                msg.sender,
                address(this),
                tempGame.wagerAmount
            );
        }
        uint256 currentBlockCount = blockNumberGameCount[block.number];
        gameIdFromBlockNumberAndItter[block.number][
            currentBlockCount
        ] = _gameId;
        blockNumberGameCount[block.number] += 1;
        emit gameCalled(tempGame.gameCount, block.number, msg.sender);
    }

    function callGame(uint256 _gameCount) external payable {
        require(startGames, "Games are not enabled");

        uint256 _gameId = gameIdFromCountNumber[_gameCount];
        gameStruct memory tempGame = gameDataFromId[_gameId];
        require(address(0) == tempGame.betCurrency, "Bet Currency is not BNB");
        require(msg.value == tempGame.wagerAmount, "Send Wager Amount");
        require(tempGame.wagerAmount > 0, "This Game Has No Wager");
        require(tempGame.gameState == 0, "Game must be in placed state");
        tempGame.caller = msg.sender;
        tempGame.blockInitialized = block.number;
        tempGame.gameState = 1;
        gameDataFromId[_gameId] = tempGame;
        uint256 currentBlockCount = blockNumberGameCount[block.number];
        gameIdFromBlockNumberAndItter[block.number][
            currentBlockCount
        ] = _gameId;
        blockNumberGameCount[block.number] += 1;
        emit gameCalled(tempGame.gameCount, block.number, msg.sender);
    }

    function resolveBlock(uint256 _blockNumber, bytes32 _resolutionSeed)
        external
    {
        require(
            resolverAddresses[msg.sender],
            "Only resolvers can resolve blocks"
        );
        require(!resolvedBlocks[_blockNumber], "Block Already resolved");
        require(blockNumberGameCount[_blockNumber] > 0, "No games to resolve");
        require(_blockNumber < block.number, "Block not reached yet");
        resolvedBlocks[_blockNumber] = true;
        bool challengerWinner;
        for (uint256 i = 0; i < blockNumberGameCount[_blockNumber]; i++) {
            uint256 currentGameId = gameIdFromBlockNumberAndItter[_blockNumber][
                i
            ];
            gameStruct memory tempGame = gameDataFromId[currentGameId];
            if (tempGame.gameState != 1) continue;
            if (tempGame.gameType == 1) {
                challengerWinner = resolveFlip(
                    _resolutionSeed,
                    tempGame.gameCount,
                    tempGame.challengerSide
                );
            } else if (tempGame.gameType == 2) {
                challengerWinner = resolveDiceDuel(
                    _resolutionSeed,
                    tempGame.gameCount
                );
            } else if (tempGame.gameType == 3) {
                challengerWinner = resolveDeathRoll(
                    _resolutionSeed,
                    tempGame.gameCount
                );
            }
            challengerWinner
                ? payoutWinner(
                    tempGame.wagerAmount * 2,
                    tempGame.challenger,
                    tempGame.betCurrency
                )
                : payoutWinner(
                    tempGame.wagerAmount * 2,
                    tempGame.caller,
                    tempGame.betCurrency
                );
            gameDataFromId[currentGameId].gameState = 2;
            activeGameId[currentGameId] = false;
            emit gameResolved(
                tempGame.gameCount,
                challengerWinner,
                _resolutionSeed
            );
        }
    }

    function payoutWinner(
        uint256 _amount,
        address _winner,
        address _currency
    ) internal {
        if (_winner != bobAddress) {
            unclaimedRewardsOfUser[_winner][_currency] += _amount;
        } else {
            bobBalanceOfToken[_currency] += _amount;
            emit bobBalanceChanged(_currency, bobBalanceOfToken[_currency]);
        }
        emit winningsAdded(_winner, _currency, _amount);
    }

    function withdrawTokenWinnings(address _token) external {
        require(_token != address(0), "Cant be 0 Address");
        require(withdrawEnabled, "Withdraws are not enabled");
        uint256 currentRewards = unclaimedRewardsOfUser[msg.sender][_token];
        require(currentRewards > 1, "No pending rewards");
        unclaimedRewardsOfUser[msg.sender][_token] = 0;
        uint256 rewardPerCent = ((currentRewards - (currentRewards % 100000)) /
            1000);
        if (_token != mythAddress) {
            ERC20 tokenContract = ERC20(_token);

            uint256 _ownerPercent = ownerPercent[_token];
            uint256 _bountyPercent = bountyPercent[_token];
            if (_bountyPercent > 0) {
                pooledRewardsBounty[_token] += rewardPerCent * (_bountyPercent);
                emit feesPaid(_token, rewardPerCent * (_bountyPercent), true);
            }
            if (_ownerPercent > 0) {
                pooledRewardsOwner[_token] += rewardPerCent * (_ownerPercent);
                emit feesPaid(_token, rewardPerCent * (_ownerPercent), false);
            }

            tokenContract.transfer(
                msg.sender,
                rewardPerCent * (1000 - (_bountyPercent + _ownerPercent))
            );
            emit claimedWinnings(
                msg.sender,
                _token,
                rewardPerCent * (1000 - (_bountyPercent + _ownerPercent))
            );
        } else {
            MythToken mythContract = MythToken(mythAddress);
            mythContract.mintTokens(rewardPerCent * 980, msg.sender);
            emit claimedWinnings(msg.sender, _token, rewardPerCent * 980);
        }
    }

    function withdrawWinnings() external payable {
        require(withdrawEnabled, "Withdraws are not enabled");
        require(msg.value == 0, "Dont send bnb");
        require(
            unclaimedRewardsOfUser[msg.sender][address(0)] > 1,
            "No pending rewards"
        );
        require(
            unclaimedRewardsOfUser[msg.sender][address(0)] <=
                address(this).balance,
            "Smart Contract Doesnt have enough funds"
        );
        uint256 rewardsForPlayer = unclaimedRewardsOfUser[msg.sender][
            address(0)
        ];
        unclaimedRewardsOfUser[msg.sender][address(0)] = 0;
        uint256 rewardPerCent = ((rewardsForPlayer -
            (rewardsForPlayer % 100000)) / 1000);
        uint256 _ownerPercent = ownerPercent[address(0)];
        uint256 _bountyPercent = bountyPercent[address(0)];
        if (_bountyPercent > 0) {
            pooledRewardsBounty[address(0)] += rewardPerCent * (_bountyPercent);
            emit feesPaid(address(0), rewardPerCent * (_bountyPercent), true);
        }
        if (_ownerPercent > 0) {
            pooledRewardsOwner[address(0)] += rewardPerCent * (_ownerPercent);
            emit feesPaid(address(0), rewardPerCent * (_ownerPercent), false);
        }
        (bool successUser, ) = msg.sender.call{
            value: (rewardPerCent * (1000 - (_bountyPercent + _ownerPercent)))
        }("");
        require(successUser, "Transfer to user failed");
        emit claimedWinnings(
            msg.sender,
            address(0),
            rewardPerCent * (1000 - (_bountyPercent + _ownerPercent))
        );
    }

    function resolveDeathRoll(bytes32 _resolutionSeed, uint256 nonce)
        internal
        view
        returns (bool)
    {
        uint256 localNonce = 0;
        uint256 currentNumber = 1000;
        while (true) {
            uint256 roll = uint256(
                keccak256(abi.encodePacked(_resolutionSeed, nonce, localNonce))
            ) % currentNumber;
            localNonce++;
            if (roll == 0) {
                break;
            } else {
                currentNumber = roll;
            }
        }
        return localNonce % 2 == 0;
    }

    function resolveFlip(
        bytes32 _resolutionSeed,
        uint256 nonce,
        uint8 _side
    ) internal view returns (bool) {
        uint8 roll = uint8(
            uint256(keccak256(abi.encodePacked(_resolutionSeed, nonce))) % 2
        );
        return roll == _side;
    }

    function resolveDiceDuel(bytes32 _resolutionSeed, uint256 nonce)
        internal
        view
        returns (bool)
    {
        uint8 counter = 0;
        while (true) {
            uint256 roll1 = uint256(
                keccak256(abi.encodePacked(_resolutionSeed, nonce, counter + 1))
            ) % 6;
            uint256 roll2 = uint256(
                keccak256(abi.encodePacked(_resolutionSeed, nonce, counter + 2))
            ) % 6;
            uint256 roll3 = uint256(
                keccak256(abi.encodePacked(_resolutionSeed, nonce, counter + 3))
            ) % 6;
            uint256 roll4 = uint256(
                keccak256(abi.encodePacked(_resolutionSeed, nonce, counter + 4))
            ) % 6;
            if (roll1 + roll2 == roll3 + roll4) {
                counter += 4;
            } else {
                return (roll1 + roll2 > roll3 + roll4);
            }
        }
    }

    function startTokenGame(
        uint8 _gameType,
        uint8 _side,
        uint256 _amount,
        address _currency,
        bool _pvp
    ) external {
        require(startGames, "Games are not enabled");
        require(minBetOfToken[_currency] <= _amount, "Bet too small");
        require(_gameType >= 1 && _gameType <= 3, "Select correct gametype");
        require(_side >= 0 && _side <= 1, "Select correct side");
        uint256 counter = 1;
        while (true) {
            if (activeGameId[counter]) {
                counter += 1;
                continue;
            } else {
                if (_currency != mythAddress) {
                    ERC20 tokenContract = ERC20(_currency);
                    tokenContract.transferFrom(
                        msg.sender,
                        address(this),
                        _amount
                    );
                } else {
                    MythToken mythContract = MythToken(mythAddress);
                    mythContract.burnTokens(_amount, msg.sender);
                }

                activeGameId[counter] = true;
                gameIdFromCountNumber[gameCount] = counter;
                gameDataFromId[counter] = gameStruct(
                    _gameType,
                    _side,
                    0,
                    gameCount,
                    _amount,
                    0,
                    _currency,
                    msg.sender,
                    address(0)
                );
                emit gameStarted(
                    _gameType,
                    _side,
                    _amount,
                    gameCount,
                    counter,
                    msg.sender,
                    _currency
                );
                break;
            }
        }
        if (!_pvp) {
            callBob(gameCount);
        }
        gameCount++;
    }

    function startGame(
        uint8 _gameType,
        uint8 _side,
        bool _pvp
    ) external payable {
        require(startGames, "Games are not enabled");
        require(msg.value >= minBetOfToken[address(0)], "Bet too small");
        require(_gameType >= 1 && _gameType <= 3, "Select correct gametype");
        require(_side >= 0 && _side <= 1, "Select correct side");
        uint256 counter = 1;
        while (true) {
            if (activeGameId[counter]) {
                counter += 1;
                continue;
            } else {
                activeGameId[counter] = true;
                gameIdFromCountNumber[gameCount] = counter;
                gameDataFromId[counter] = gameStruct(
                    _gameType,
                    _side,
                    0,
                    gameCount,
                    msg.value,
                    0,
                    address(0),
                    msg.sender,
                    address(0)
                );
                emit gameStarted(
                    _gameType,
                    _side,
                    msg.value,
                    gameCount,
                    counter,
                    msg.sender,
                    address(0)
                );
                break;
            }
        }
        if (!_pvp) {
            callBob(gameCount);
        }
        gameCount++;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC20/ERC20.sol)

pragma solidity ^0.8.0;

import "IERC20.sol";
import "IERC20Metadata.sol";
import "Context.sol";

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
        _approve(owner, spender, allowance(owner, spender) + addedValue);
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
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    /**
     * @dev Moves `amount` of tokens from `from` to `to`.
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
     * @dev Updates `owner` s allowance for `spender` based on spent `amount`.
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
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
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
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;

import "IERC20.sol";

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
pragma solidity 0.8.13;
import "ERC20.sol";

interface IBEP20 {
    function totalSupply() external view returns (uint256);

    function decimals() external view returns (uint8);

    function symbol() external view returns (string memory);

    function name() external view returns (string memory);

    function getOwner() external view returns (address);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function allowance(address _owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

interface PancakeSwapFactory {
    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);
}

interface PancakeSwapRouter {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
        external
        returns (
            uint256 amountA,
            uint256 amountB,
            uint256 liquidity
        );

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

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;
        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }
}

// abstract contract Context {
//     function _msgSender() internal view virtual returns (address payable) {
//         return payable(msg.sender);
//     }

//     function _msgData() internal view virtual returns (bytes memory) {
//         this;
//         return msg.data;
//     }
// }

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        address msgSender = _msgSender();
        _owner = msgSender;
        authorizations[_owner] = true;
        emit OwnershipTransferred(address(0), msgSender);
    }

    mapping(address => bool) internal authorizations;

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

interface IDEXRouter {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
        external
        returns (
            uint256 amountA,
            uint256 amountB,
            uint256 liquidity
        );

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

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function quote(
        uint256 amountA,
        uint256 reserveA,
        uint256 reserveB
    ) external pure returns (uint256 amountB);

    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountOut);

    function getAmountIn(
        uint256 amountOut,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountIn);

    function getAmountsOut(uint256 amountIn, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);

    function getAmountsIn(uint256 amountOut, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);
}

contract MythToken is Ownable, IBEP20 {
    using SafeMath for uint256;

    uint8 private constant _decimals = 9;
    uint256 public _maxSupplyPossible = 1200000 * (10**_decimals);
    uint256 private _totalSupply = 1000000 * (10**_decimals);
    uint256 public _maxTxAmount = _totalSupply;
    uint256 public _walletMax = (_totalSupply * 250) / 10000;

    address private constant DEAD_WALLET =
        0x000000000000000000000000000000000000dEaD;
    address private constant ZERO_WALLET =
        0x0000000000000000000000000000000000000000;

    address private pancakeAddress = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    string private constant _name = "Myth";
    string private constant _symbol = "MYTH";

    bool public restrictWhales = true;

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    mapping(address => bool) public isFeeExempt;
    mapping(address => bool) public isTxLimitExempt;

    uint256 public tradeFee = 10;

    bool public takeBuyFee = true;
    bool public takeSellFee = true;
    bool public takeTransferFee = false;

    address private feeWallet;

    PancakeSwapRouter public router;
    address public pair;

    uint256 public launchedAt;
    bool public tradingOpen = false;
    bool public blacklistMode = true;
    bool public canUseBlacklist = true;
    mapping(address => bool) public isBlacklisted;

    mapping(address => bool) public isAuthorizedForTokenMints;

    bool private inSwapAndLiquify;
    bool public swapAndLiquifyEnabled = true;
    bool public swapAndLiquifyByLimitOnly = false;

    uint256 public swapThreshold = (_totalSupply * 4) / 2000;

    event AutoLiquify(uint256 amountBNB, uint256 amountBOG);
    event tokensMinted(uint256 amount, address mintedTo, address mintedBy);
    event tokensBurned(uint256 amount, address mintedTo, address mintedBy);
    event accountAuthorized(address account, bool status);
    modifier lockTheSwap() {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }

    constructor() {
        router = PancakeSwapRouter(pancakeAddress);
        pair = PancakeSwapFactory(router.factory()).createPair(
            router.WETH(),
            address(this)
        );
        _allowances[address(this)][address(router)] = type(uint256).max;
        _allowances[address(this)][address(pair)] = type(uint256).max;
        isAuthorizedForTokenMints[msg.sender] = true;
        isFeeExempt[msg.sender] = true;
        isFeeExempt[address(this)] = true;
        isFeeExempt[DEAD_WALLET] = true;

        isTxLimitExempt[msg.sender] = true;
        isTxLimitExempt[pair] = true;
        isTxLimitExempt[DEAD_WALLET] = true;

        feeWallet = msg.sender;

        _balances[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    receive() external payable {}

    function name() external pure override returns (string memory) {
        return _name;
    }

    function symbol() external pure override returns (string memory) {
        return _symbol;
    }

    function decimals() external pure override returns (uint8) {
        return _decimals;
    }

    function totalSupply() external view override returns (uint256) {
        return _totalSupply;
    }

    function getOwner() external view override returns (address) {
        return owner();
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function allowance(address holder, address spender)
        external
        view
        override
        returns (uint256)
    {
        return _allowances[holder][spender];
    }

    function getCirculatingSupply() public view returns (uint256) {
        return
            _totalSupply.sub(balanceOf(DEAD_WALLET)).sub(
                balanceOf(ZERO_WALLET)
            );
    }

    function approve(address spender, uint256 amount)
        public
        override
        returns (bool)
    {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function approveMax(address spender) external returns (bool) {
        return approve(spender, type(uint256).max);
    }

    function launched() internal view returns (bool) {
        return launchedAt != 0;
    }

    function launch() internal {
        launchedAt = block.number;
    }

    function mintTokens(uint256 amount, address account) external {
        require(isAuthorizedForTokenMints[msg.sender], "Not Authorized");
        require(
            _totalSupply + amount <= _maxSupplyPossible,
            "Tokens Minted Above Max Limit"
        );
        _balances[account] += amount;
        _totalSupply += amount;
        emit tokensMinted(amount, account, msg.sender);
        emit Transfer(address(0), account, amount);
    }

    function burnTokens(uint256 amount, address account) external {
        require(isAuthorizedForTokenMints[msg.sender], "Not Authorized");
        require(
            _balances[account] >= amount,
            "Account does not have enough balance to burn"
        );
        _balances[account] -= amount;
        _totalSupply -= amount;
        emit tokensBurned(amount, account, msg.sender);
        emit Transfer(account, address(0), amount);
    }

    function transfer(address recipient, uint256 amount)
        external
        override
        returns (bool)
    {
        return _transferFrom(msg.sender, recipient, amount);
    }

    function _basicTransfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(
            amount,
            "Insufficient Balance"
        );
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external override returns (bool) {
        if (_allowances[sender][msg.sender] != type(uint256).max) {
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender]
                .sub(amount, "Insufficient Allowance");
        }
        return _transferFrom(sender, recipient, amount);
    }

    function _transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) internal returns (bool) {
        if (inSwapAndLiquify) {
            return _basicTransfer(sender, recipient, amount);
        }
        if (!authorizations[sender] && !authorizations[recipient]) {
            require(tradingOpen, "Trading not open yet");
        }

        if (!launched() && recipient == pair) {
            require(_balances[sender] > 0, "Zero balance violated!");
            launch();
        }

        // Blacklist
        if (blacklistMode) {
            require(!isBlacklisted[sender], "Blacklisted");
        }

        //Exchange tokens
        _balances[sender] = _balances[sender].sub(
            amount,
            "Insufficient Balance"
        );

        if (!isTxLimitExempt[recipient] && restrictWhales) {
            require(
                _balances[recipient].add(amount) <= _walletMax,
                "Max wallet violated!"
            );
        }

        uint256 finalAmount = !isFeeExempt[sender] && !isFeeExempt[recipient]
            ? extractFee(sender, recipient, amount)
            : amount;
        _balances[recipient] = _balances[recipient].add(finalAmount);

        emit Transfer(sender, recipient, finalAmount);
        return true;
    }

    function extractFee(
        address sender,
        address recipient,
        uint256 amount
    ) internal returns (uint256) {
        uint256 feeApplicable = 0;
        if (recipient == pair && takeSellFee) {
            feeApplicable = tradeFee;
        }
        if (sender == pair && takeBuyFee) {
            feeApplicable = tradeFee;
        }
        if (sender != pair && recipient != pair) {
            if (takeTransferFee) {
                feeApplicable = tradeFee;
            } else {
                feeApplicable = 0;
            }
        }

        uint256 feeAmount = amount.mul(feeApplicable).div(100);

        _balances[feeWallet] = _balances[feeWallet].add(feeAmount);
        emit Transfer(sender, feeWallet, feeAmount);

        return amount.sub(feeAmount);
    }

    function setMaxSupplyPossible(uint256 newLimit) external onlyOwner {
        _maxSupplyPossible = newLimit;
    }

    function changeAuthorization(address _address, bool _status)
        external
        onlyOwner
    {
        isAuthorizedForTokenMints[_address] = _status;
        emit accountAuthorized(_address, _status);
    }

    function setWalletLimit(uint256 newLimit) external onlyOwner {
        require(newLimit > 0, "Wallet Limit needs to be more than 0%");
        _walletMax = (_totalSupply * newLimit) / 10000;
    }

    function tradingStatus(bool newStatus) public onlyOwner {
        tradingOpen = newStatus;
    }

    function openTrading() public onlyOwner {
        tradingOpen = true;
    }

    function setIsFeeExempt(address holder, bool exempt) external onlyOwner {
        isFeeExempt[holder] = exempt;
    }

    function fullWhitelist(address target) public onlyOwner {
        authorizations[target] = true;
        isFeeExempt[target] = true;
    }

    function setFees(uint256 newFee) external onlyOwner {
        require(newFee > 0, "Needs to be above 0");
        tradeFee = newFee;
    }

    function enable_blacklist(bool _status) public onlyOwner {
        blacklistMode = _status;
    }

    function manage_blacklist(address[] calldata addresses, bool status)
        public
        onlyOwner
    {
        for (uint256 i; i < addresses.length; ++i) {
            isBlacklisted[addresses[i]] = status;
        }
    }

    function isAuth(address _address, bool status) public onlyOwner {
        authorizations[_address] = status;
    }

    function setTakeBuyfee(bool status) public onlyOwner {
        takeBuyFee = status;
    }

    function setTakeSellfee(bool status) public onlyOwner {
        takeSellFee = status;
    }

    function setTakeTransferfee(bool status) public onlyOwner {
        takeTransferFee = status;
    }

    function setFeeReceivers(address _feeWallet) public onlyOwner {
        feeWallet = _feeWallet;
    }

    function rescueToken(address tokenAddress, uint256 tokens)
        public
        onlyOwner
        returns (bool success)
    {
        return IBEP20(tokenAddress).transfer(msg.sender, tokens);
    }

    function clearStuckBalance(uint256 amountPercentage) external onlyOwner {
        uint256 amountETH = address(this).balance;
        payable(msg.sender).transfer((amountETH * amountPercentage) / 100);
    }
}

contract LootBoxes {
    address payable public owner;
    address payable public owner2;

    uint256 public gameCount;
    uint256 public caseCountMax = 20;
    uint256 public bobMaxBet;
    address public bobAddress;
    address payable public tokenAddress;
    bool public startGames = true;
    bool public callBobGames = true;
    bool public withdrawEnabled = true;
    mapping(address => uint256) public unclaimedRewardsOfUser;
    mapping(address => uint256) public promotionalBalanceOfUser;
    mapping(uint256 => bool) public resolvedBlocks;
    mapping(address => bool) public resolverAddresses;
    mapping(uint256 => lobbyStruct) public lobbyDataFromId;
    mapping(uint256 => uint256) public lobbyIdFromGameId;
    mapping(uint256 => bool) public activeLobbyId;
    mapping(uint256 => uint256) public blockNumberGameCount;
    mapping(uint256 => mapping(uint256 => uint256))
        public lobbyIdFromBlockNumberAndItter;
    mapping(uint256 => mapping(uint256 => uint256))
        public caseIdFromLobbyIdRoundId;
    mapping(uint256 => caseData) public caseDataFromId;

    // path from caseId to prizes
    mapping(uint256 => mapping(uint256 => prizeData))
        public prizeDataFromCaseIdPrizeId;
    struct prizeData {
        uint256 lowTicket;
        uint256 highTicket;
        uint256 prizeAmount;
    }
    struct caseData {
        uint256 prizeCount;
        uint256 caseCost;
    }
    struct lobbyStruct {
        uint8 gameType; // 0 for solo, 1 for 1v1, 2 for 2v2, 3 for 1v1v1
        uint8 gameState; // 1 means placed by challenger, 2 means initialized , 3 means resolved
        uint16 numberOfCases;
        uint256 gameId; //Id of the game
        uint256 gameCost; //Total cost of the game
        uint256 blockInitialized;
        address creator;
        address caller1;
        address caller2;
        address caller3;
    }
    event winningsAdded(address winner, uint256 amount);
    event gameCancelled(uint256 gameCount);
    event lobbyJoined(address caller, uint256 gameCount, uint256 position);
    event lobbyLeft(address caller, uint256 gameCount, uint256 position);

    event gameStarted(
        uint256 gameCount,
        uint256 blockNumberInitialized,
        address creator,
        address caller1,
        address caller2,
        address caller3
    );
    event gameResolved(
        uint256 gameCount,
        uint256 winningAmount,
        address winner,
        address winner2,
        bytes32 resolutionSeed
    );
    event roundResolved(
        uint256 gameCount,
        uint256 roundCount,
        uint256 numberRolled1,
        uint256 numberRolled2,
        uint256 numberRolled3,
        uint256 numberRolled4
    );
    event lobbyMade(
        uint256 lobbyId,
        uint256 gameId,
        uint8 gameType,
        uint256[] caseIds,
        address lobbyCreator,
        uint256 lobbyCost,
        bool pvp
    );
    event claimedWinnings(address winner, uint256 amount);

    event caseAdded(uint256 caseId, uint256 caseCost);
    event prizeAdded(
        uint256 caseId,
        uint256 lowTicket,
        uint256 highTicket,
        uint256 prizeAmount
    );

    constructor(address _tokenAddress) {
        owner = payable(msg.sender);
        owner2 = payable(msg.sender);
        tokenAddress = payable(_tokenAddress);
        resolverAddresses[msg.sender] = true;
    }

    function alterCaseData(
        uint256 _caseId,
        uint256 _caseCost,
        uint256[] calldata _lowTickets,
        uint256[] calldata _highTickets,
        uint256[] calldata _prizeAmounts
    ) external {
        require(msg.sender == owner, "only owner");
        require(
            _lowTickets.length == _highTickets.length &&
                _highTickets.length == _prizeAmounts.length,
            "Lists are not equal lengths"
        );
        emit caseAdded(_caseId, _caseCost);
        for (uint256 i = 0; i < _lowTickets.length; i++) {
            emit prizeAdded(
                _caseId,
                _lowTickets[i],
                _highTickets[i],
                _prizeAmounts[i]
            );
            prizeDataFromCaseIdPrizeId[_caseId][i] = prizeData(
                _lowTickets[i],
                _highTickets[i],
                _prizeAmounts[i]
            );
        }
        caseDataFromId[_caseId] = caseData(_lowTickets.length, _caseCost);
    }

    function enableGames(bool _enable) external {
        require(msg.sender == owner, "only owner");
        startGames = _enable;
    }

    function addPromoBalance(address user, uint256 amount) external {
        require(
            resolverAddresses[msg.sender],
            "not permissioned to add promo balance"
        );
        promotionalBalanceOfUser[user] += amount;
    }

    function enableBob(bool _enable) external {
        require(msg.sender == owner, "only owner");
        callBobGames = _enable;
    }

    function enableWithdraw(bool _enable) external {
        require(msg.sender == owner, "only owner");
        withdrawEnabled = _enable;
    }

    function changeResolver(address _address, bool _bool) external {
        require(msg.sender == owner, "only owner");
        resolverAddresses[_address] = _bool;
    }

    function changeBobAddress(address _address) external {
        require(msg.sender == owner, "only owner");
        bobAddress = _address;
    }

    function changeOwner2(address _address) external {
        require(msg.sender == owner, "only owner");
        owner2 = payable(_address);
    }

    function rescueTokens(address _token, uint256 _amount) external payable {
        require(msg.sender == owner, "only owner");
        if (_token == address(0)) {
            (bool successUser, ) = msg.sender.call{value: _amount}("");
            require(successUser, "Transfer to user failed");
        } else {
            IBEP20 tokenContract = IBEP20(_token);
            tokenContract.transfer(msg.sender, _amount);
        }
    }

    function viewBalance(address _token) public view returns (uint256) {
        if (_token == address(0)) {
            return address(this).balance;
        } else {
            IBEP20 tokenContract = IBEP20(_token);
            tokenContract.balanceOf(address(this));
        }
    }

    function callBob(uint256 _gameId) public {
        uint256 _lobbyId = lobbyIdFromGameId[_gameId];
        address _bobAddress = bobAddress;
        lobbyStruct memory tempLobby = lobbyDataFromId[_lobbyId];
        require(tempLobby.gameState == 1, "Bob can only join placed lobbys");
        require(
            tempLobby.creator == msg.sender,
            "Only lobby creator can call bob"
        );
        lobbyDataFromId[_lobbyId].gameState = 2;
        if (tempLobby.gameType == 1) {
            lobbyDataFromId[_lobbyId].caller1 = _bobAddress;
            lobbyDataFromId[_lobbyId].blockInitialized = block.number;
            uint256 currentGameCountOfBlock = blockNumberGameCount[
                block.number
            ];
            blockNumberGameCount[block.number]++;
            lobbyIdFromBlockNumberAndItter[block.number][
                currentGameCountOfBlock
            ] = _lobbyId;
            emit lobbyJoined(_bobAddress, _gameId, 2);
            emit gameStarted(
                _gameId,
                block.number,
                tempLobby.creator,
                _bobAddress,
                address(0),
                address(0)
            );
        } else if (tempLobby.gameType == 2) {
            if (tempLobby.caller1 == address(0)) {
                lobbyDataFromId[_lobbyId].caller1 = _bobAddress;
                emit lobbyJoined(_bobAddress, _gameId, 2);
            }
            if (tempLobby.caller2 == address(0)) {
                lobbyDataFromId[_lobbyId].caller2 = _bobAddress;
                emit lobbyJoined(_bobAddress, _gameId, 3);
            }
            if (tempLobby.caller3 == address(0)) {
                lobbyDataFromId[_lobbyId].caller3 = _bobAddress;
                emit lobbyJoined(_bobAddress, _gameId, 4);
            }

            lobbyDataFromId[_lobbyId].blockInitialized = block.number;
            uint256 currentGameCountOfBlock = blockNumberGameCount[
                block.number
            ];
            blockNumberGameCount[block.number]++;
            lobbyIdFromBlockNumberAndItter[block.number][
                currentGameCountOfBlock
            ] = _lobbyId;
            emit gameStarted(
                _gameId,
                block.number,
                lobbyDataFromId[_lobbyId].creator,
                lobbyDataFromId[_lobbyId].caller1,
                lobbyDataFromId[_lobbyId].caller2,
                lobbyDataFromId[_lobbyId].caller3
            );
        } else if (tempLobby.gameType == 3) {
            if (tempLobby.caller1 == address(0)) {
                lobbyDataFromId[_lobbyId].caller1 = _bobAddress;
                emit lobbyJoined(_bobAddress, _gameId, 2);
            }
            if (tempLobby.caller2 == address(0)) {
                lobbyDataFromId[_lobbyId].caller2 = _bobAddress;
                emit lobbyJoined(_bobAddress, _gameId, 3);
            }

            lobbyDataFromId[_lobbyId].blockInitialized = block.number;
            uint256 currentGameCountOfBlock = blockNumberGameCount[
                block.number
            ];
            blockNumberGameCount[block.number]++;
            lobbyIdFromBlockNumberAndItter[block.number][
                currentGameCountOfBlock
            ] = _lobbyId;
            emit gameStarted(
                _gameId,
                block.number,
                lobbyDataFromId[_lobbyId].creator,
                lobbyDataFromId[_lobbyId].caller1,
                lobbyDataFromId[_lobbyId].caller2,
                address(0)
            );
        }
    }

    function addPlayerToLobby(
        address _user,
        uint256 _gameId,
        uint256 _position
    ) external {
        require(
            resolverAddresses[msg.sender],
            "not permissioned to add free battles"
        );
        require(_position >= 2 && _position <= 4, "choose valid position 2-4");
        uint256 _lobbyId = lobbyIdFromGameId[_gameId];
        lobbyStruct memory tempLobby = lobbyDataFromId[_lobbyId];
        require(tempLobby.gameState == 1, "Can only join placed lobbys");
        if (tempLobby.gameType == 1) {
            lobbyDataFromId[_lobbyId].caller1 = _user;
            lobbyDataFromId[_lobbyId].blockInitialized = block.number;
            lobbyDataFromId[_lobbyId].gameState = 2;
            emit lobbyJoined(_user, _gameId, 2);
            emit gameStarted(
                _gameId,
                block.number,
                tempLobby.creator,
                _user,
                address(0),
                address(0)
            );
        } else if (tempLobby.gameType == 2) {
            if (_position == 2) {
                require(
                    tempLobby.caller1 == address(0),
                    "Position already filled"
                );
                lobbyDataFromId[_lobbyId].caller1 = _user;
            } else if (_position == 3) {
                require(
                    tempLobby.caller2 == address(0),
                    "Position already filled"
                );
                lobbyDataFromId[_lobbyId].caller2 = _user;
            } else if (_position == 4) {
                require(
                    tempLobby.caller3 == address(0),
                    "Position already filled"
                );
                lobbyDataFromId[_lobbyId].caller3 = _user;
            }
            emit lobbyJoined(_user, _gameId, _position);
            if (isLobbyFull(_lobbyId)) {
                lobbyDataFromId[_lobbyId].blockInitialized = block.number;
                lobbyDataFromId[_lobbyId].gameState = 2;
                uint256 currentGameCountOfBlock = blockNumberGameCount[
                    block.number
                ];
                blockNumberGameCount[block.number]++;
                lobbyIdFromBlockNumberAndItter[block.number][
                    currentGameCountOfBlock
                ] = _lobbyId;
                emit gameStarted(
                    _gameId,
                    block.number,
                    lobbyDataFromId[_lobbyId].creator,
                    lobbyDataFromId[_lobbyId].caller1,
                    lobbyDataFromId[_lobbyId].caller2,
                    lobbyDataFromId[_lobbyId].caller3
                );
            }
        } else if (tempLobby.gameType == 3) {
            require(_position < 4, "invalid position");
            if (_position == 2) {
                require(
                    tempLobby.caller1 == address(0),
                    "Position already filled"
                );
                lobbyDataFromId[_lobbyId].caller1 = _user;
            } else if (_position == 3) {
                require(
                    tempLobby.caller2 == address(0),
                    "Position already filled"
                );
                lobbyDataFromId[_lobbyId].caller2 = _user;
            }
            emit lobbyJoined(_user, _gameId, _position);
            if (isLobbyFull3(_lobbyId)) {
                lobbyDataFromId[_lobbyId].blockInitialized = block.number;
                lobbyDataFromId[_lobbyId].gameState = 2;
                uint256 currentGameCountOfBlock = blockNumberGameCount[
                    block.number
                ];
                blockNumberGameCount[block.number]++;
                lobbyIdFromBlockNumberAndItter[block.number][
                    currentGameCountOfBlock
                ] = _lobbyId;
                emit gameStarted(
                    _gameId,
                    block.number,
                    lobbyDataFromId[_lobbyId].creator,
                    lobbyDataFromId[_lobbyId].caller1,
                    lobbyDataFromId[_lobbyId].caller2,
                    address(0)
                );
            }
        }
    }

    function joinLobby(
        uint256 _gameId,
        uint8 _position,
        bool _promo
    ) external {
        require(_position >= 2 && _position <= 4, "choose valid position 2-4");
        uint256 _lobbyId = lobbyIdFromGameId[_gameId];
        lobbyStruct memory tempLobby = lobbyDataFromId[_lobbyId];
        require(tempLobby.gameState == 1, "Can only join placed lobbys");
        if (!_promo) {
            MythToken tokenContract = MythToken(tokenAddress);
            tokenContract.burnTokens(tempLobby.gameCost, msg.sender);
        } else {
            require(
                promotionalBalanceOfUser[msg.sender] >= tempLobby.gameCost,
                "Not enough promo balance to join lobby"
            );
            promotionalBalanceOfUser[msg.sender] -= tempLobby.gameCost;
        }

        if (tempLobby.gameType == 1) {
            lobbyDataFromId[_lobbyId].caller1 = msg.sender;
            lobbyDataFromId[_lobbyId].blockInitialized = block.number;
            lobbyDataFromId[_lobbyId].gameState = 2;
            emit lobbyJoined(msg.sender, _gameId, 2);
            emit gameStarted(
                _gameId,
                block.number,
                tempLobby.creator,
                msg.sender,
                address(0),
                address(0)
            );
        } else if (tempLobby.gameType == 2) {
            if (_position == 2) {
                require(
                    tempLobby.caller1 == address(0),
                    "Position already filled"
                );
                lobbyDataFromId[_lobbyId].caller1 = msg.sender;
            } else if (_position == 3) {
                require(
                    tempLobby.caller2 == address(0),
                    "Position already filled"
                );
                lobbyDataFromId[_lobbyId].caller2 = msg.sender;
            } else if (_position == 4) {
                require(
                    tempLobby.caller3 == address(0),
                    "Position already filled"
                );
                lobbyDataFromId[_lobbyId].caller3 = msg.sender;
            }
            emit lobbyJoined(msg.sender, _gameId, _position);
            if (isLobbyFull(_lobbyId)) {
                lobbyDataFromId[_lobbyId].blockInitialized = block.number;
                lobbyDataFromId[_lobbyId].gameState = 2;
                uint256 currentGameCountOfBlock = blockNumberGameCount[
                    block.number
                ];
                blockNumberGameCount[block.number]++;
                lobbyIdFromBlockNumberAndItter[block.number][
                    currentGameCountOfBlock
                ] = _lobbyId;
                emit gameStarted(
                    _gameId,
                    block.number,
                    lobbyDataFromId[_lobbyId].creator,
                    lobbyDataFromId[_lobbyId].caller1,
                    lobbyDataFromId[_lobbyId].caller2,
                    lobbyDataFromId[_lobbyId].caller3
                );
            }
        } else if (tempLobby.gameType == 3) {
            require(_position < 4, "invalid position");
            if (_position == 2) {
                require(
                    tempLobby.caller1 == address(0),
                    "Position already filled"
                );
                lobbyDataFromId[_lobbyId].caller1 = msg.sender;
            } else if (_position == 3) {
                require(
                    tempLobby.caller2 == address(0),
                    "Position already filled"
                );
                lobbyDataFromId[_lobbyId].caller2 = msg.sender;
            }
            emit lobbyJoined(msg.sender, _gameId, _position);
            if (isLobbyFull3(_lobbyId)) {
                lobbyDataFromId[_lobbyId].blockInitialized = block.number;
                lobbyDataFromId[_lobbyId].gameState = 2;
                uint256 currentGameCountOfBlock = blockNumberGameCount[
                    block.number
                ];
                blockNumberGameCount[block.number]++;
                lobbyIdFromBlockNumberAndItter[block.number][
                    currentGameCountOfBlock
                ] = _lobbyId;
                emit gameStarted(
                    _gameId,
                    block.number,
                    lobbyDataFromId[_lobbyId].creator,
                    lobbyDataFromId[_lobbyId].caller1,
                    lobbyDataFromId[_lobbyId].caller2,
                    address(0)
                );
            }
        }
    }

    function isLobbyFull(uint256 _lobbyId) public view returns (bool) {
        lobbyStruct memory tempLobby = lobbyDataFromId[_lobbyId];
        if (tempLobby.caller1 == address(0)) {
            return false;
        }
        if (tempLobby.caller2 == address(0)) {
            return false;
        }
        if (tempLobby.caller3 == address(0)) {
            return false;
        }
        return true;
    }

    function isLobbyFull3(uint256 _lobbyId) public view returns (bool) {
        lobbyStruct memory tempLobby = lobbyDataFromId[_lobbyId];
        if (tempLobby.caller1 == address(0)) {
            return false;
        }
        if (tempLobby.caller2 == address(0)) {
            return false;
        }
        return true;
    }

    function resolveBlock(uint256 _blockNumber, bytes32 _resolutionSeed)
        external
    {
        require(
            resolverAddresses[msg.sender],
            "Only resolvers can resolve blocks"
        );
        require(!resolvedBlocks[_blockNumber], "Block Already resolved");
        require(blockNumberGameCount[_blockNumber] > 0, "No games to resolve");
        require(_blockNumber < block.number, "Block not reached yet");
        uint256 tempWinnings;
        address tempWinner;
        address tempWinner2;
        resolvedBlocks[_blockNumber] = true;
        for (uint256 i = 0; i < blockNumberGameCount[_blockNumber]; i++) {
            uint256 currentGameId = lobbyIdFromBlockNumberAndItter[
                _blockNumber
            ][i];
            lobbyStruct memory tempGame = lobbyDataFromId[currentGameId];
            if (tempGame.gameState != 2) continue;
            lobbyDataFromId[currentGameId].gameState = 3;
            if (tempGame.gameType == 0) {
                tempWinnings = getWinningsFromSoloOpening(
                    _resolutionSeed,
                    currentGameId
                );
                unclaimedRewardsOfUser[tempGame.creator] += tempWinnings;
                emit gameResolved(
                    tempGame.gameId,
                    tempWinnings,
                    tempGame.creator,
                    address(0),
                    _resolutionSeed
                );
                emit winningsAdded(tempGame.creator, tempWinnings);
            } else if (tempGame.gameType == 1) {
                (tempWinnings, tempWinner) = getWinningsFrom1v1(
                    _resolutionSeed,
                    currentGameId
                );
                if (tempWinner != bobAddress) {
                    unclaimedRewardsOfUser[tempWinner] += tempWinnings;
                    emit winningsAdded(tempWinner, tempWinnings);
                }
                emit gameResolved(
                    tempGame.gameId,
                    tempWinnings,
                    tempWinner,
                    address(0),
                    _resolutionSeed
                );
            } else if (tempGame.gameType == 2) {
                (tempWinnings, tempWinner, tempWinner2) = getWinningsFrom2v2(
                    _resolutionSeed,
                    currentGameId
                );
                if (tempWinner != bobAddress) {
                    unclaimedRewardsOfUser[tempWinner] += tempWinnings;
                    emit winningsAdded(tempWinner, tempWinnings);
                }
                if (tempWinner2 != bobAddress) {
                    unclaimedRewardsOfUser[tempWinner2] += tempWinnings;
                    emit winningsAdded(tempWinner2, tempWinnings);
                }
                emit gameResolved(
                    tempGame.gameId,
                    tempWinnings,
                    tempWinner,
                    tempWinner2,
                    _resolutionSeed
                );
            } else if (tempGame.gameType == 3) {
                (tempWinnings, tempWinner) = getWinningsFrom1v1v1(
                    _resolutionSeed,
                    currentGameId
                );
                if (tempWinner != bobAddress) {
                    unclaimedRewardsOfUser[tempWinner] += tempWinnings;
                    emit winningsAdded(tempWinner, tempWinnings);
                }
                emit gameResolved(
                    tempGame.gameId,
                    tempWinnings,
                    tempWinner,
                    address(0),
                    _resolutionSeed
                );
            }

            activeLobbyId[currentGameId] = false;
        }
    }

    function withdrawTokenWinnings() external {
        require(withdrawEnabled, "Withdraws are not enabled");
        uint256 currentRewards = unclaimedRewardsOfUser[msg.sender];
        require(currentRewards > 1, "No pending rewards");
        unclaimedRewardsOfUser[msg.sender] = 0;
        MythToken tokenContract = MythToken(tokenAddress);
        tokenContract.mintTokens(currentRewards, msg.sender);
        tokenContract.mintTokens(currentRewards / 50, owner);
        tokenContract.mintTokens(currentRewards / 50, owner2);
        emit claimedWinnings(msg.sender, currentRewards);
    }

    function getCostOfLootboxes(uint256[] calldata _lootboxIds)
        public
        view
        returns (uint256)
    {
        uint256 tempTotal;
        for (uint256 i = 0; i < _lootboxIds.length; i++) {
            uint256 tempCost = caseDataFromId[_lootboxIds[i]].caseCost;
            require(tempCost > 0, "case has no cost");
            tempTotal += tempCost;
        }
        return tempTotal;
    }

    function getPrizeFromTicket(uint256 _caseId, uint256 _ticket)
        public
        view
        returns (uint256)
    {
        uint256 prizeCountTemp = caseDataFromId[_caseId].prizeCount;
        for (uint256 i = 0; i < prizeCountTemp; i++) {
            prizeData memory tempPrize = prizeDataFromCaseIdPrizeId[_caseId][i];
            if (
                tempPrize.lowTicket <= _ticket &&
                tempPrize.highTicket >= _ticket
            ) {
                return tempPrize.prizeAmount;
            }
        }
        return 0;
    }

    function getWinningsFrom1v1v1(bytes32 resolutionSeed, uint256 lobbyId)
        internal
        returns (uint256, address)
    {
        lobbyStruct memory tempGame = lobbyDataFromId[lobbyId];
        uint256 tempTotal1;
        uint256 tempTotal2;
        uint256 tempTotal3;
        for (uint256 i = 0; i < tempGame.numberOfCases; i++) {
            uint256 caseId = caseIdFromLobbyIdRoundId[lobbyId][i];
            uint256 rolledTicket = uint256(
                keccak256(abi.encodePacked(resolutionSeed, lobbyId, i))
            ) % 100000;
            uint256 rolledTicket2 = uint256(
                keccak256(abi.encodePacked(resolutionSeed, lobbyId, 100 - i))
            ) % 100000;
            uint256 rolledTicket3 = uint256(
                keccak256(abi.encodePacked(resolutionSeed, lobbyId, 200 - i))
            ) % 100000;

            emit roundResolved(
                tempGame.gameId,
                i,
                rolledTicket,
                rolledTicket2,
                rolledTicket3,
                0
            );
            tempTotal1 += getPrizeFromTicket(caseId, rolledTicket);
            tempTotal2 += getPrizeFromTicket(caseId, rolledTicket2);
            tempTotal3 += getPrizeFromTicket(caseId, rolledTicket3);
        }
        uint256 tempWinnings = tempTotal1 + tempTotal2 + tempTotal3;
        if (tempTotal1 == tempTotal2 && tempTotal1 == tempTotal3) {
            uint256 tieBreak = uint256(
                keccak256(abi.encodePacked(resolutionSeed, tempGame.gameId))
            ) % 3;
            if (tieBreak == 0) {
                return (tempWinnings, tempGame.creator);
            } else if (tieBreak == 1) {
                return (tempWinnings, tempGame.caller1);
            } else if (tieBreak == 2) {
                return (tempWinnings, tempGame.caller2);
            }
        } else if (tempTotal1 > tempTotal2 && tempTotal1 > tempTotal3) {
            return (tempWinnings, tempGame.creator);
        } else if (tempTotal2 > tempTotal1 && tempTotal2 > tempTotal3) {
            return (tempWinnings, tempGame.caller1);
        } else if (tempTotal3 > tempTotal1 && tempTotal3 > tempTotal2) {
            return (tempWinnings, tempGame.caller2);
        } else {
            if (tempTotal1 == tempTotal2) {
                if (tieBreaker(resolutionSeed, tempGame.gameId)) {
                    return (tempWinnings, tempGame.creator);
                } else {
                    return (tempWinnings, tempGame.caller1);
                }
            } else if (tempTotal3 == tempTotal2) {
                if (tieBreaker(resolutionSeed, tempGame.gameId)) {
                    return (tempWinnings, tempGame.caller1);
                } else {
                    return (tempWinnings, tempGame.caller2);
                }
            } else {
                if (tieBreaker(resolutionSeed, tempGame.gameId)) {
                    return (tempWinnings, tempGame.creator);
                } else {
                    return (tempWinnings, tempGame.caller2);
                }
            }
        }
    }

    function getWinningsFrom2v2(bytes32 resolutionSeed, uint256 lobbyId)
        internal
        returns (
            uint256,
            address,
            address
        )
    {
        lobbyStruct memory tempGame = lobbyDataFromId[lobbyId];
        uint256 tempTotal1;
        uint256 tempTotal2;
        for (uint256 i = 0; i < tempGame.numberOfCases; i++) {
            uint256 caseId = caseIdFromLobbyIdRoundId[lobbyId][i];
            uint256 rolledTicket = uint256(
                keccak256(abi.encodePacked(resolutionSeed, lobbyId, i))
            ) % 100000;
            uint256 rolledTicket2 = uint256(
                keccak256(abi.encodePacked(resolutionSeed, lobbyId, 100 - i))
            ) % 100000;
            uint256 rolledTicket3 = uint256(
                keccak256(abi.encodePacked(resolutionSeed, lobbyId, 200 - i))
            ) % 100000;
            uint256 rolledTicket4 = uint256(
                keccak256(abi.encodePacked(resolutionSeed, lobbyId, 300 - i))
            ) % 100000;

            emit roundResolved(
                tempGame.gameId,
                i,
                rolledTicket,
                rolledTicket2,
                rolledTicket3,
                rolledTicket4
            );
            tempTotal1 += getPrizeFromTicket(caseId, rolledTicket);
            tempTotal1 += getPrizeFromTicket(caseId, rolledTicket2);
            tempTotal2 += getPrizeFromTicket(caseId, rolledTicket3);
            tempTotal2 += getPrizeFromTicket(caseId, rolledTicket4);
        }
        bool creatorWinner;
        if (tempTotal1 == tempTotal2) {
            creatorWinner = tieBreaker(resolutionSeed, tempGame.gameId);
        } else {
            creatorWinner = tempTotal1 > tempTotal2;
        }
        uint256 tempWinnings = (tempTotal1 + tempTotal2) / 2;
        if (creatorWinner) {
            return (tempWinnings, tempGame.creator, tempGame.caller1);
        } else {
            return (tempWinnings, tempGame.caller2, tempGame.caller3);
        }
    }

    function getWinningsFromSoloOpening(bytes32 resolutionSeed, uint256 lobbyId)
        internal
        returns (uint256)
    {
        lobbyStruct memory tempGame = lobbyDataFromId[lobbyId];
        uint256 tempTotal;
        for (uint256 i = 0; i < tempGame.numberOfCases; i++) {
            uint256 caseId = caseIdFromLobbyIdRoundId[lobbyId][i];
            uint256 rolledTicket = uint256(
                keccak256(abi.encodePacked(resolutionSeed, lobbyId, i))
            ) % 100000;

            emit roundResolved(tempGame.gameId, i, rolledTicket, 0, 0, 0);
            tempTotal += getPrizeFromTicket(caseId, rolledTicket);
        }
        return tempTotal;
    }

    function getWinningsFrom1v1(bytes32 resolutionSeed, uint256 lobbyId)
        internal
        returns (uint256, address)
    {
        lobbyStruct memory tempGame = lobbyDataFromId[lobbyId];
        uint256 tempTotal1;
        uint256 tempTotal2;
        for (uint256 i = 0; i < tempGame.numberOfCases; i++) {
            uint256 caseId = caseIdFromLobbyIdRoundId[lobbyId][i];
            uint256 rolledTicket = uint256(
                keccak256(abi.encodePacked(resolutionSeed, lobbyId, i))
            ) % 100000;
            uint256 rolledTicket2 = uint256(
                keccak256(abi.encodePacked(resolutionSeed, lobbyId, 100 - i))
            ) % 100000;

            emit roundResolved(
                tempGame.gameId,
                i,
                rolledTicket,
                rolledTicket2,
                0,
                0
            );
            tempTotal1 += getPrizeFromTicket(caseId, rolledTicket);
            tempTotal2 += getPrizeFromTicket(caseId, rolledTicket2);
        }
        bool creatorWinner;
        if (tempTotal1 == tempTotal2) {
            creatorWinner = tieBreaker(resolutionSeed, tempGame.gameId);
        } else {
            creatorWinner = tempTotal1 > tempTotal2;
        }
        if (creatorWinner) {
            return (tempTotal1 + tempTotal2, tempGame.creator);
        } else {
            return (tempTotal1 + tempTotal2, tempGame.caller1);
        }
    }

    function tieBreaker(bytes32 resolutionSeed, uint256 gameId)
        public
        view
        returns (bool)
    {
        return
            uint256(keccak256(abi.encodePacked(resolutionSeed, gameId))) % 2 ==
            0;
    }

    function startFreeLobby(
        uint8 _gameType, // 0 for solo, 1 for 1v1, 2 for 2v2, 3 for 1v1v1
        uint256[] calldata _lootboxIds,
        address player1,
        address player2,
        address player3,
        address player4
    ) external {
        require(
            resolverAddresses[msg.sender],
            "not permissioned to add free battles"
        );
        require(
            _lootboxIds.length <= caseCountMax && _lootboxIds.length > 0,
            "Too many lootboxes"
        );
        require(_gameType <= 3, "Select correct gametype");
        uint256 counter = 1;
        uint256 _gameCount = gameCount;
        uint256 lobbyCost = getCostOfLootboxes(_lootboxIds);
        while (true) {
            if (activeLobbyId[counter]) {
                counter += 1;
                continue;
            } else {
                activeLobbyId[counter] = true;
                lobbyIdFromGameId[_gameCount] = counter;

                for (uint256 i = 0; i < _lootboxIds.length; i++) {
                    caseIdFromLobbyIdRoundId[counter][i] = _lootboxIds[i];
                }
                lobbyDataFromId[counter] = lobbyStruct(
                    _gameType,
                    2,
                    uint16(_lootboxIds.length),
                    _gameCount,
                    lobbyCost,
                    block.number,
                    player1,
                    player2,
                    player3,
                    player4
                );
                emit lobbyMade(
                    counter,
                    _gameCount,
                    _gameType,
                    _lootboxIds,
                    msg.sender,
                    lobbyCost,
                    true
                );
                emit lobbyJoined(player2, _gameCount, 2);
                emit lobbyJoined(player3, _gameCount, 3);
                emit lobbyJoined(player4, _gameCount, 4);
                emit gameStarted(
                    _gameCount,
                    block.number,
                    player1,
                    player2,
                    player3,
                    player4
                );
                uint256 currentGameCountOfBlock = blockNumberGameCount[
                    block.number
                ];
                blockNumberGameCount[block.number]++;
                lobbyIdFromBlockNumberAndItter[block.number][
                    currentGameCountOfBlock
                ] = counter;
                break;
            }
        }

        gameCount++;
    }

    function startLobby(
        uint8 _gameType, // 0 for solo, 1 for 1v1, 2 for 2v2, 3 for 1v1v1
        uint256[] calldata _lootboxIds,
        bool _pvp,
        bool _promo
    ) external {
        require(startGames, "Games are not enabled");
        require(
            _lootboxIds.length <= caseCountMax && _lootboxIds.length > 0,
            "Too many lootboxes"
        );
        require(_gameType <= 3, "Select correct gametype");
        uint256 counter = 1;
        uint256 _gameCount = gameCount;
        uint256 lobbyCost = getCostOfLootboxes(_lootboxIds);
        if (!_promo) {
            MythToken tokenContract = MythToken(tokenAddress);
            tokenContract.burnTokens(lobbyCost, msg.sender);
        } else {
            require(
                promotionalBalanceOfUser[msg.sender] >= lobbyCost,
                "Not enough promo balance to start lobby"
            );
            promotionalBalanceOfUser[msg.sender] -= lobbyCost;
        }

        while (true) {
            if (activeLobbyId[counter]) {
                counter += 1;
                continue;
            } else {
                activeLobbyId[counter] = true;
                lobbyIdFromGameId[_gameCount] = counter;

                for (uint256 i = 0; i < _lootboxIds.length; i++) {
                    caseIdFromLobbyIdRoundId[counter][i] = _lootboxIds[i];
                }
                lobbyDataFromId[counter] = lobbyStruct(
                    _gameType,
                    1,
                    uint16(_lootboxIds.length),
                    _gameCount,
                    lobbyCost,
                    0,
                    msg.sender,
                    address(0),
                    address(0),
                    address(0)
                );
                emit lobbyMade(
                    counter,
                    _gameCount,
                    _gameType,
                    _lootboxIds,
                    msg.sender,
                    lobbyCost,
                    _pvp
                );
                break;
            }
        }
        if (_gameType == 0) {
            emit gameStarted(
                _gameCount,
                block.number,
                msg.sender,
                address(0),
                address(0),
                address(0)
            );
            lobbyDataFromId[counter].blockInitialized = block.number;
            lobbyDataFromId[counter].gameState = 2;
            uint256 currentGameCountOfBlock = blockNumberGameCount[
                block.number
            ];
            blockNumberGameCount[block.number]++;
            lobbyIdFromBlockNumberAndItter[block.number][
                currentGameCountOfBlock
            ] = counter;
        } else if (!_pvp) {
            callBob(_gameCount);
        }
        gameCount++;
    }
}