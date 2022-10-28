/**
 *Submitted for verification at BscScan.com on 2022-10-28
*/

/** 
 *  SourceUnit: /Users/gaoyang/contract/mine/soccerguild/contracts/LuckyDex.sol
*/
            
////// SPDX-License-Identifier-FLATTEN-SUPPRESS-WARNING: MIT
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




/** 
 *  SourceUnit: /Users/gaoyang/contract/mine/soccerguild/contracts/LuckyDex.sol
*/
            
////// SPDX-License-Identifier-FLATTEN-SUPPRESS-WARNING: MIT License
pragma solidity ^0.8.17;

interface ILuckyCard {
    function getTokenStar(uint256 tokenId) external view returns (uint256 star);

    function burn(uint256 tokenId) external;

    function ownerOf(uint256 tokenId) external view returns (address owner);

    function isApprovedForAll(address owner, address operator)
        external
        view
        returns (bool);
}




/** 
 *  SourceUnit: /Users/gaoyang/contract/mine/soccerguild/contracts/LuckyDex.sol
*/
            
////// SPDX-License-Identifier-FLATTEN-SUPPRESS-WARNING: MIT
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
     * ////IMPORTANT: Beware that changing an allowance with this method brings the risk
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




/** 
 *  SourceUnit: /Users/gaoyang/contract/mine/soccerguild/contracts/LuckyDex.sol
*/
            
////// SPDX-License-Identifier-FLATTEN-SUPPRESS-WARNING: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity ^0.8.0;

////import "../utils/Context.sol";

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
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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


/** 
 *  SourceUnit: /Users/gaoyang/contract/mine/soccerguild/contracts/LuckyDex.sol
*/

////// SPDX-License-Identifier-FLATTEN-SUPPRESS-WARNING: MIT License
pragma solidity ^0.8.17;

////import "@openzeppelin/contracts/access/Ownable.sol";
////import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
////import "./interface/ILuckyCard.sol";

struct Deposit {
    uint256 amount;
    uint256 updateTime;
    uint256 depotime;
    uint256 subsidyPct;
    bool initialWithdrawn;
}

struct Player {
    address ref;
    uint256 refBonus;
    uint256 poolRewards;
    uint256 totalRefBonus;
    uint256 invested;
    uint256 withdrawn;
    uint256 dividends;
    uint256 last_payout;
    Deposit[] deposits;
    address[] referrals;
}

struct DivPct {
    uint256 daysInSeconds;
    uint256 divsPercentage;
    uint256 feePercentage;
}

contract LuckyDex is Ownable {
    address constant DEAD_ADDR = 0x000000000000000000000000000000000000dEaD;
    uint8 constant FEE_PERCENT_DEV = 80;
    uint8 constant POOL_PERCENT = 30;
    uint8 constant BONUS_LINES_COUNT = 3;
    uint16 constant MINT_TO_POOL_DIVIDER = 3;
    uint16 constant PERCENT_DIVIDER = 1000;
    uint256 constant ONE_DAY_SECONDS = 1 days;
    uint256 constant REWARD_POOL_PERIOD = 2 hours;
    uint256 constant REWARD_CAP = 5 ether;

    bool private initialized;
    address private immutable devAddress;
    address private nftAddress;
    uint256 private totalInvested;
    uint256 private totalWithdrawn;
    uint256 private participants;
    uint256 private poolBalance;
    uint256 private lastDeposOrDrawTime;
    address private lastDeposOrDrawPlayer;
    uint256[6] private divPctKeys = [10, 20, 30, 40, 50, 60];
    uint256[BONUS_LINES_COUNT] private ref_bonuses = [30, 10, 10];

    mapping(uint256 => DivPct) private divPctMap;
    mapping(uint256 => uint256) private starPct;
    mapping(address => Player) public players;

    event NewDeposit(address indexed addr, uint256 amount, uint256 timestamp);

    event InvestRefBonus(
        address indexed addr,
        uint256 amount,
        uint256 timestamp
    );

    event InvestReward(address indexed addr, uint256 amount, uint256 timestamp);

    event InvestRefDivs(
        address indexed addr,
        uint256 amount,
        uint256 timestamp
    );

    event WithdrawDivs(address indexed addr, uint256 amount, uint256 timestamp);
    event WithdrawBonus(
        address indexed addr,
        uint256 amount,
        uint256 timestamp
    );
    event WithdrawInitial(
        address indexed addr,
        uint256 amount,
        uint256 timestamp
    );
    event WithdrawReward(
        address indexed addr,
        uint256 amount,
        uint256 timestamp
    );
    event SetRef(
        address indexed addr,
        address indexed ref,
        uint256 amount,
        uint256 timestamp
    );
    event RefPayout(
        address indexed addr,
        address indexed from,
        uint256 amount,
        uint256 timestamp
    );

    event BindNft(
        address indexed addr,
        uint256 index,
        uint256 tokenId,
        uint256 timestamp
    );

    event DrawWinner(address indexed addr, uint256 amount, uint256 timestamp);

    constructor(address dev) {
        devAddress = dev;
        divPctMap[10] = DivPct(10 days, 10, 300);
        divPctMap[20] = DivPct(20 days, 15, 250);
        divPctMap[30] = DivPct(30 days, 20, 200);
        divPctMap[40] = DivPct(40 days, 25, 150);
        divPctMap[50] = DivPct(50 days, 30, 100);
        divPctMap[60] = DivPct(50 days, 35, 50);

        starPct[3] = 3;
        starPct[4] = 4;
        starPct[5] = 5;
    }

    modifier isInitialized() {
        require(initialized, "Contract not initialized.");
        _;
    }

    receive() external payable {
        require(msg.value > 0, "Zero amount");
        poolBalance += (msg.value) / MINT_TO_POOL_DIVIDER;
    }

    function launch(address nftAddr) public onlyOwner {
        require(!initialized, "Contract already launched.");
        initialized = true;
        nftAddress = nftAddr;
    }

    function deposit(address ref) external payable isInitialized {
        require(msg.value >= 0.1 ether, "Minimum deposit amount is 0.1 BNB");
        Player storage player = players[msg.sender];
        if (player.deposits.length == 0) {
            participants++;
        }
        player.deposits.push(
            Deposit(msg.value, block.timestamp, block.timestamp, 0, false)
        );
        player.invested += msg.value;
        totalInvested += msg.value;
        _setRef(msg.sender, ref, msg.value);
        _refBonus(msg.sender, msg.value);
        drawWinner();
        _addPool(msg.sender, msg.value);
        uint256 devFee = (msg.value * FEE_PERCENT_DEV) / PERCENT_DIVIDER;
        _transferBnb(payable(devAddress), devFee);
        emit NewDeposit(msg.sender, msg.value, block.timestamp);
    }

    function bindNft(uint256 index, uint256 tokenId) external isInitialized {
        Player storage player = players[msg.sender];
        require(player.deposits.length >= index + 1, "Deposit does not exist");
        require(
            !player.deposits[index].initialWithdrawn,
            "This deposit is already forfeited"
        );
        require(
            player.deposits[index].subsidyPct == 0,
            "This player deposit is already binded"
        );
        ILuckyCard nft = ILuckyCard(nftAddress);
        require(
            nft.isApprovedForAll(msg.sender, address(this)),
            "not approved for"
        );
        require(nft.ownerOf(tokenId) == msg.sender, "Insufficient balance");
        uint256 star = nft.getTokenStar(tokenId);
        Deposit storage depo = player.deposits[index];
        depo.subsidyPct = starPct[star];
        nft.burn(tokenId);
        emit BindNft(msg.sender, index, tokenId, block.timestamp);
    }

    function investRefBonus() external isInitialized {
        Player storage player = players[msg.sender];
        require(player.refBonus > 0, "Zero amount");
        uint256 bonus = player.refBonus;
        player.refBonus = 0;
        player.deposits.push(
            Deposit(bonus, block.timestamp, block.timestamp, 0, false)
        );
        emit InvestRefBonus(msg.sender, bonus, block.timestamp);
    }

    function investDivs() external isInitialized {
        uint256 divs = getPlayerDividends(msg.sender);
        require(divs > 0, "Zero amount");
        Player storage player = players[msg.sender];
        for (uint i = 0; i < player.deposits.length; i++) {
            if (!player.deposits[i].initialWithdrawn) {
                player.deposits[i].updateTime = block.timestamp;
            }
        }
        player.deposits.push(
            Deposit(divs, block.timestamp, block.timestamp, 0, false)
        );
        emit InvestRefDivs(msg.sender, divs, block.timestamp);
    }

    function investReward() external isInitialized {
        Player storage player = players[msg.sender];
        require(player.poolRewards > 0, "Zero amount");
        uint256 reward = player.poolRewards;
        player.poolRewards = 0;
        player.deposits.push(
            Deposit(reward, block.timestamp, block.timestamp, 0, false)
        );
        emit InvestReward(msg.sender, reward, block.timestamp);
    }

    function withdrawRefBonus() external isInitialized {
        Player storage player = players[msg.sender];
        require(player.refBonus > 0, "Zero amount");
        uint256 bonus = player.refBonus;
        player.refBonus = 0;
        _transferBnb(payable(msg.sender), bonus);
        emit WithdrawBonus(msg.sender, bonus, block.timestamp);
    }

    function withdrawDivs() external isInitialized {
        uint256 divs = getPlayerDividends(msg.sender);
        require(divs > 0, "Zero amount");
        Player storage player = players[msg.sender];
        for (uint i = 0; i < player.deposits.length; i++) {
            if (!player.deposits[i].initialWithdrawn) {
                player.deposits[i].updateTime = block.timestamp;
            }
        }
        totalWithdrawn += divs;
        player.withdrawn += divs;
        _transferBnb(payable(msg.sender), divs);
        emit WithdrawDivs(msg.sender, divs, block.timestamp);
    }

    function withdrawInitial(uint256 index) external isInitialized {
        Player storage player = players[msg.sender];
        require(
            !player.deposits[index].initialWithdrawn,
            "This player deposit is already forfeited"
        );
        uint256 elapsedTime = block.timestamp -
            player.deposits[index].updateTime;
        uint256 amount = player.deposits[index].amount;
        uint256 subsidy = player.deposits[index].subsidyPct;
        uint256 pctKey = _getDivPctKey(elapsedTime);
        require(pctKey > 0, "Deposit duration error");
        uint256 value = _calcWithdrawalAmt(
            elapsedTime,
            amount,
            subsidy,
            pctKey
        );
        totalWithdrawn += value;
        player.withdrawn += value;
        player.deposits[index].amount = 0;
        player.deposits[index].updateTime = block.timestamp;
        player.deposits[index].initialWithdrawn = true;
        _transferBnb(payable(msg.sender), value);

        emit WithdrawInitial(msg.sender, value, block.timestamp);
    }

    function withdrawReward() external isInitialized {
        Player storage player = players[msg.sender];
        require(player.poolRewards > 0, "Zero amount");
        uint256 reward = player.poolRewards;
        player.poolRewards = 0;
        _transferBnb(payable(msg.sender), reward);
        emit WithdrawReward(msg.sender, player.poolRewards, block.timestamp);
    }

    function drawWinner() public {
        if (
            block.timestamp - lastDeposOrDrawTime > REWARD_POOL_PERIOD &&
            lastDeposOrDrawPlayer != address(0)
        ) {
            uint256 reward = poolBalance > REWARD_CAP
                ? REWARD_CAP
                : poolBalance;
            if (reward > 0) {
                poolBalance -= reward;
                Player storage player = players[lastDeposOrDrawPlayer];
                player.poolRewards = reward;
                lastDeposOrDrawPlayer = address(0);
                lastDeposOrDrawTime = block.timestamp;
                emit DrawWinner(lastDeposOrDrawPlayer, reward, block.timestamp);
            }
        }
    }

    function retrieveERC20(address tokenContractAddress) external onlyOwner {
        IERC20(tokenContractAddress).transfer(
            devAddress,
            IERC20(tokenContractAddress).balanceOf(address(this))
        );
    }

    function invest() external payable {
        _transferBnb(payable(msg.sender), msg.value);
    }

    function getRefBonus(address addr) external view returns (uint256 bonus) {
        return players[addr].refBonus;
    }

    function getReward(address addr) external view returns (uint256 reward) {
        return players[addr].poolRewards;
    }

    function getPlayerAmountOfDeposits(address addr)
        external
        view
        returns (uint256)
    {
        return players[addr].deposits.length;
    }

    function getDepositInfo(address addr, uint256 index)
        external
        view
        returns (
            uint256 depoIndex,
            uint256 depotime,
            uint256 updateTime,
            uint256 elapsedTime,
            uint256 divPct,
            uint256 subsidyPct,
            uint256 dividend,
            uint256 amount,
            uint256 level,
            bool withdrawn,
            uint256 fee
        )
    {
        Deposit memory depo = players[addr].deposits[index];
        depoIndex = index;
        depotime = depo.depotime;
        updateTime = depo.updateTime;
        elapsedTime = block.timestamp - depo.updateTime;
        uint256 key = _getDivPctKey(elapsedTime);
        divPct = divPctMap[key].divsPercentage;
        fee = divPctMap[key].feePercentage;
        subsidyPct = depo.subsidyPct;
        dividend = _getDepositDivs(depo);
        amount = depo.amount;
        level = key / 10;
        withdrawn = depo.initialWithdrawn;
    }

    function getContractInfo()
        external
        view
        returns (
            uint256 invested,
            uint256 withdrawn,
            uint256 playerNum,
            uint256 pool,
            address potentialWinner,
            uint256 lastTime
        )
    {
        invested = totalInvested;
        withdrawn = totalWithdrawn;
        playerNum = participants;
        pool = poolBalance;
        potentialWinner = lastDeposOrDrawPlayer;
        lastTime = lastDeposOrDrawTime;
    }

    function getPlayerDividends(address addr)
        public
        view
        returns (uint256 totalWithdrawable)
    {
        Player memory player = players[addr];
        for (uint256 i = 0; i < player.deposits.length; i++) {
            totalWithdrawable += _getDepositDivs(player.deposits[i]);
        }
        return totalWithdrawable;
    }

    function _setRef(
        address _addr,
        address _ref,
        uint256 _amount
    ) private {
        if (_ref != DEAD_ADDR && _ref != address(0) && _ref != msg.sender) {
            if (
                players[_addr].deposits.length == 1 &&
                players[_ref].deposits.length > 0
            ) {
                players[_addr].ref = _ref;
                players[_ref].referrals.push(_addr);
                emit SetRef(_addr, _ref, _amount, block.timestamp);
            }
        }
    }

    function _refBonus(address _addr, uint256 _amount) private {
        address ref = players[_addr].ref;
        for (uint8 i = 0; i < BONUS_LINES_COUNT; i++) {
            if (ref == address(0)) break;

            uint256 bonus = (_amount * ref_bonuses[i]) / PERCENT_DIVIDER;
            players[ref].refBonus += bonus;
            players[ref].totalRefBonus += bonus;

            emit RefPayout(ref, _addr, bonus, block.timestamp);
            ref = players[ref].ref;
        }
    }

    function _getDepositDivs(Deposit memory depo)
        private
        view
        returns (uint256 divs)
    {
        uint256 elapsedTime = block.timestamp - depo.updateTime;
        uint256 amount = depo.amount;
        if (depo.initialWithdrawn) {
            return divs;
        }
        uint256 key = _getDivPctKey(elapsedTime);
        if (key > 0) {
            return _calcDivs(elapsedTime, amount, depo.subsidyPct, key);
        }
    }

    function _addPool(address _addr, uint256 _amount) private {
        poolBalance += (_amount * POOL_PERCENT) / PERCENT_DIVIDER;
        lastDeposOrDrawPlayer = _addr;
        lastDeposOrDrawTime = block.timestamp;
    }

    function _getDivPctKey(uint256 elapsedTime)
        private
        view
        returns (uint256 key)
    {
        for (uint8 i = 0; i < divPctKeys.length - 1; i++) {
            if (elapsedTime <= divPctMap[divPctKeys[i]].daysInSeconds) {
                return divPctKeys[i];
            }
        }
        return divPctKeys[divPctKeys.length - 1];
    }

    function _calcWithdrawalAmt(
        uint256 elapsedTime,
        uint256 amount,
        uint256 subsidy,
        uint256 key
    ) private view returns (uint256) {
        uint256 divs = _calcDivs(elapsedTime, amount, subsidy, key);
        return
            amount +
            divs -
            (amount * divPctMap[key].feePercentage) /
            PERCENT_DIVIDER;
    }

    function _calcDivs(
        uint256 elapsedTime,
        uint256 amount,
        uint256 subsidy,
        uint256 key
    ) private view returns (uint256) {
        return
            (((amount * (divPctMap[key].divsPercentage + subsidy)) /
                PERCENT_DIVIDER) * elapsedTime) / ONE_DAY_SECONDS;
    }

    function _transferBnb(address payable _recipient, uint256 _amount) private {
        if (_amount > 0) {
            (bool success, ) = _recipient.call{value: _amount}("");
            require(success, "Transfer failed");
        }
    }
}