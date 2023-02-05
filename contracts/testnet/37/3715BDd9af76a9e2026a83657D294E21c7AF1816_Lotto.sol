// SPDX-License-Identifier: MIT
pragma solidity 0.8.12;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./interfaces/IChainlink.sol";

contract Lotto is Ownable {
    // Start Pool 1,000 BUSD then 80% of betting amount adding to pool and 5% to buyback and 15% to treasury.
    // If Pool is more than 7,500 BUSD, then 20% will go to buyback.
    address public immutable busd;
    address public immutable token;
    address public treasury;
    address public buyback;
    address public underlying;
    uint256 public tokenForDiscount;
    uint256 public discountPeriod;
    uint256 public discountForEarlyBPS;
    uint256 public discountForTokenBPS;
    uint256 public withdrawFeeBPS;
    uint256 public poolBPS;
    uint256 public buybackBPS;
    uint256 public treasuryBPS;
    uint256 public triggerPool;
    uint256 public prizePool;
    uint256 public priceRound;
    uint256 public nextRoundTime;
    uint256 public closeBeforeTime;
    uint256 public previousRoundId;
    bool public isStarted;

    struct Round {
        uint256 roundId;
        uint256 timestamp;
        uint256 chainlinkRound;
        uint256 number;
        uint256 prizePool;
    }

    mapping ( uint256 => mapping ( uint256 => mapping (address => uint256))) public userNumberBet; // round id => bet number => user => amount
    mapping ( uint256 => mapping ( uint256 => uint256)) public numberBet; // round id => bet number => amount
    mapping ( uint256 => mapping ( address => uint256)) public netBetted; // round id => user => amount

    Round[] public rounds;

    event OnStartLotto(uint256 _roundTime, uint256 _priceRound);
    event OnFinalizeLotto(uint256 _roundId, uint256 _number, uint256 _prizePool);
    event OnBet (address _player, uint256 _amount, uint256 _number, uint256 _roundId);
    event OnAddPool (address _player, uint256 _amount);
    event OnWithdraw (address _player, uint256 _amount);

    constructor(address _busd, address _token, address _underlying){
        require(_busd != address(0), "Lotto: BUSD address is zero");
        require(_token != address(0), "Lotto: Token address is zero");
        busd = _busd;
        token = _token;
        underlying = _underlying;
        treasury = _msgSender();
        buyback = _msgSender();
        nextRoundTime = block.timestamp + 14 days;
        closeBeforeTime = 15 * 60 * 60;
        buybackBPS = 500;
        treasuryBPS = 1500;
        triggerPool = 7500 * 10 ** 18;
        withdrawFeeBPS = 2000;
        discountForEarlyBPS = 1000;
        discountForTokenBPS = 2000;
        discountPeriod = 7 days;
        tokenForDiscount = 500000 * 10 ** 18;
        previousRoundId = 0;
        rounds.push(Round(previousRoundId, block.timestamp, 1, 1, 1000 * 10 ** 18)); // round time chainlinkround number prizepool
        userNumberBet[previousRoundId][1][_msgSender()] = 1000 * 10 ** 18;
        numberBet[previousRoundId][1] = 1000 * 10 ** 18;
        netBetted[previousRoundId][_msgSender()] = 1000 * 10 ** 18;
    }

    function getCurrentRoundId () public view returns (uint256) {
        return previousRoundId + 1;
    }

    function getCurrentNumberBetted (uint256 _number) public view returns (uint256) {
        return numberBet[getCurrentRoundId()][_number];
    }

    function getCurrentUserNumberBetted (address _user, uint256 _number) public view returns (uint256) {
        return userNumberBet[getCurrentRoundId()][_number][_user];
    }

    function getLatestLuckyNumber () public view returns (uint256) {
        return rounds[previousRoundId].number;
    }

    function checkLatestReward (address _user) public view returns (uint256) {
        uint256 _number = getLatestLuckyNumber();
        uint256 _amount = userNumberBet[previousRoundId][_number][_user];
        if (_amount > 0) {
            uint256 _prizePool = rounds[previousRoundId].prizePool;
            uint256 _reward = _amount * _prizePool / numberBet[previousRoundId][_number];
            return _reward;
        } else {
            return 0;
        }
    }

    function quoteDiscount (address _user, uint256 _amount) public view returns (uint256) {
        if (IERC20(token).balanceOf(_user) >= tokenForDiscount) {
            return _amount * discountForTokenBPS / 10000;
        } else if (block.timestamp <= nextRoundTime - discountPeriod) {
            return _amount * discountForEarlyBPS / 10000;
        } else {
            return 0;
        }
    }

    function withdraw () public {
        uint256 currentRoundId = getCurrentRoundId();
        uint256 _bettedAmount = netBetted[currentRoundId][_msgSender()];
        require(_bettedAmount > 0, "Lotto: Unavailable");
        netBetted[currentRoundId][_msgSender()] = 0;
        for (uint256 i = 0; i <= 9; i++) {
            if (userNumberBet[currentRoundId][i][_msgSender()] > 0) {
                numberBet[currentRoundId][i] -= userNumberBet[currentRoundId][i][_msgSender()];
                userNumberBet[currentRoundId][i][_msgSender()] = 0;
            }
        }
        uint256 _withdrawFee = _bettedAmount * withdrawFeeBPS / 10000;
        uint256 _netWithdraw = _bettedAmount - _withdrawFee;
        require(IERC20(busd).transfer(_msgSender(), _netWithdraw),"Lotto: Transfer failed");
        //IERC20(busd).transfer(buyback, _withdrawFee);

        emit OnWithdraw (_msgSender(), _bettedAmount);
    }

    function addPrizePool (uint256 _amount) public {
        require(_amount > 0, "Lotto: Amount must be greater than 0");
        IERC20(busd).transferFrom(_msgSender(), address(this), _amount);
        prizePool += _amount;

        emit OnAddPool (_msgSender(), _amount);
    }

    function bet (uint256 _amount, uint256 _number) public {
        require(_number < 10, "Lotto: Number must be less than 10");
        require(isStarted == false, "Lotto: Unavailable");
        require(block.timestamp <= nextRoundTime - closeBeforeTime, "Lotto: Unavailable");
        uint256 currentRoundId = getCurrentRoundId();
        uint256 _discount;
        if (prizePool >= triggerPool) {
            treasuryBPS = 0;
        }
        if (IERC20(token).balanceOf(_msgSender()) >= tokenForDiscount) {
            treasuryBPS = 0;
            _discount = discountForTokenBPS;
        } else if (block.timestamp <= nextRoundTime - discountPeriod) {
            if (treasuryBPS <= discountForEarlyBPS) treasuryBPS = 0;
            else treasuryBPS -= discountForEarlyBPS;
            _discount = discountForEarlyBPS;
        }
        uint256 addPool = _amount * poolBPS / 10000;
        uint256 addTreasury = _amount * treasuryBPS / 10000;
        uint256 netAmount = _amount * (10000 - _discount) / 10000;
        uint256 addBuyback = netAmount - addPool - addTreasury;
        IERC20(busd).transferFrom(_msgSender(), address(this), addPool);
        if (addTreasury > 0) IERC20(busd).transferFrom(_msgSender(), treasury, addTreasury);
        if (addBuyback > 0) IERC20(busd).transferFrom(_msgSender(), buyback, addBuyback);
        prizePool += addPool;
        userNumberBet[currentRoundId][_number][_msgSender()] += netAmount;
        numberBet[currentRoundId][_number] += netAmount;
        netBetted[currentRoundId][_msgSender()] += netAmount;

        emit OnBet (_msgSender(), netAmount, _number, currentRoundId);
    }

    function getChainlinkRound () public view returns (uint256) {
        return IChainlink(underlying).latestRound();
    }

    function getChainlinkPrice (uint256 _roundId) public view returns (int256) {
        return IChainlink(underlying).getAnswer(_roundId);
    }

    function startLotto () public {
        require(block.timestamp >= nextRoundTime, "Lotto: Not yet");
        require(isStarted == false, "Lotto: Already started");
        priceRound = getChainlinkRound() + 1;
        isStarted = true;

        emit OnStartLotto(nextRoundTime, priceRound);
    }

    function finalizeLotto () public {
        require(isStarted == true, "Lotto: Not started");
        previousRoundId ++;
        rounds.push(Round(previousRoundId, block.timestamp, pickingNumber(uint256(getChainlinkPrice(priceRound))), priceRound, prizePool)); // round time chainlinkround number prizepool
        isStarted = false;

        emit OnFinalizeLotto(previousRoundId, rounds[previousRoundId].number, rounds[previousRoundId].prizePool);
    }

    function pickingNumber (uint256 _number) public pure returns (uint256) {
        return _number % 10000000 / 1000000;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.12;

interface IChainlink {
    function latestRound() external view returns (uint256);

    function getAnswer(uint256 _roundId) external view returns (int256);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/*
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
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

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
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
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
        _setOwner(_msgSender());
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
        _setOwner(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}