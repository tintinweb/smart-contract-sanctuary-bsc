// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;
import "ERC20.sol";

contract BasePVPGames {
    address payable public owner;

    uint256 public gameCount;
    address public bobAddress;
    bool public startGames;
    bool public callBobGames;
    bool public withdrawEnabled;
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

    constructor() {
        owner = payable(msg.sender);
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
        require(
            bobBalanceOfToken[tempGame.betCurrency] >= tempGame.wagerAmount,
            "Bob Doesn't have enough"
        );
        bobBalanceOfToken[tempGame.betCurrency] -= tempGame.wagerAmount;
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
        emit bobBalanceChanged(
            tempGame.betCurrency,
            bobBalanceOfToken[tempGame.betCurrency]
        );
    }

    function callTokenGame(uint256 _gameCount) external {
        require(startGames, "Games are not enabled");
        uint256 _gameId = gameIdFromCountNumber[_gameCount];
        gameStruct memory tempGame = gameDataFromId[_gameId];
        require(address(0) != tempGame.betCurrency, "Bet Currency is BNB");
        require(tempGame.wagerAmount > 0, "This Game Has No Wager");
        require(tempGame.gameState == 0, "Game must be in placed state");
        ERC20 tokenContract = ERC20(tempGame.betCurrency);
        tokenContract.transferFrom(
            msg.sender,
            address(this),
            tempGame.wagerAmount
        );
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
        ERC20 tokenContract = ERC20(_token);
        uint256 rewardPerCent = ((currentRewards - (currentRewards % 100000)) /
            1000);
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
                ERC20 tokenContract = ERC20(_currency);
                tokenContract.transferFrom(msg.sender, address(this), _amount);
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