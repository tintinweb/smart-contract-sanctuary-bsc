// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./ReEntrancyGuard.sol";
import "./Establishments.sol";
import "./TransferHistory.sol";

contract DogsCrewGame is
    Context,
    Ownable,
    Pausable,
    Establishments,
    ReEntrancyGuard,
    TransferHistory
{
    using SafeMath for uint256;

    // set manual listingPrice
    uint256 public _listingPriceVal = 833;

    // IRC20 token DOGSC
    IERC20 private _dogscToken;

    //_feePercentage
    uint256 public _feePercentage = 3;

    // Event buy DOUSD by BNB
    event BuyDOGSCbyBNB(
        address buyer,
        uint256 amoutOfBNB,
        uint256 amountOfTokens
    );

    // Event buy BNB by DOGSC
    event BuyBNBbyDOGSC(
        address buyer,
        uint256 amoutOfDOGSC,
        uint256 amountOfTokens
    );

    //buyDOUSDwithDOGSC
    event BuyDOUSDwithDOGSC(
        address buyer,
        uint256 amountOfDOGSC,
        uint256 amountOfDOUSD
    );

    // BuyDOGSCwithDOUSD
    event BuyDOGSCwithDOUSD(
        address buyer,
        uint256 amountOfDOUSD,
        uint256 amountOfDOGSC
    );

    // Blacklist that restrict swap.
    mapping(address => bool) public blacklist;

    // GAME

    // Start and stop swap
    bool public swapActiveSell = true;
    bool public swapActiveBuy = true;

    // Start and stop Attack
    bool public attackActive = true;

    // change percentage of crew damaged
    uint256 public percentageOfCrewDamaged = 25;

    // early withdrawal penalty
    uint256 public penalty = 7500;

    // ramdom number generator
    uint256 randNonce = 0;

    // winner struct
    struct winnerStruct {
        uint256 earned_tokens;
        uint256 win_rate;
        uint256 winner;
        bool damaged_crew;
        bool status;
    }

    // Attack struct
    event EventSendAttack(
        address attack_you,
        uint256 earned_tokens,
        uint256 win_rate,
        uint256 winner,
        bool damaged_crew,
        bool status
    );

    // event emit
    event EventLifeContract(
        address attack_you,
        string idCrew,
        uint256 amounttoken,
        bool status
    );
    // from DOUSD -> DOGSC
    event _swapDOUSDfromDOGSC(
        address buyer,
        uint256 dogsc,
        uint256 dousd,
        bool discount
    );

    // @dev mapping of the attack
    mapping(address => uint256) walletBlockattack;

    // @dev mapping of the sell
    mapping(address => uint256) walletBlocksell;

    // @dev day block attack
    uint256 public blockDayAttack = 1;

    // @dev day block sell
    uint256 public blockDaySell = 1;

    constructor(address _dogscTokenAddress) {
        _dogscToken = IERC20(_dogscTokenAddress);
    }

    // This fallback/receive function
    // will keep all the Ether
    fallback() external payable {
        // Do nothing
    }

    receive() external payable {
        // Do nothing
    }

    // Edit reserved whitelist spots
    function editBlackList(address _address, bool _block) external onlyOwner {
        blacklist[_address] = _block;
    }

    // check if your account is blocked
    function blockedAccount(address _address) external view returns (bool) {
        return blacklist[_address];
    }

    // receives tokens for the operation of the game dynamics (DOUSD)
    function lifeContracts(uint256 tokenAmount, string memory idCrew)
        external
        noReentrant
        returns (bool)
    {
        require(attackActive, "Attack isn't active");

        // Verifico que tenga token suficientes DOGSC
        uint256 userBalance = _dogscToken.balanceOf(_msgSender());
        require(
            userBalance >= tokenAmount,
            "lifeContracts: Your balance is lower than the amount of tokens you want to sell"
        );

        // Transfer token to the msg.sender -> sc
        require(
            _dogscToken.transferFrom(_msgSender(), address(this), tokenAmount),
            "lifeContracts: Failed to transfer tokens from user to vendor"
        );

        // 001 @dev Transfer token to the msg.sender
        uint256 _amount = calculateTransaction(tokenAmount);
        require(
            _dogscToken.transfer(owner(), _amount),
            "lifeContracts: Failed to transfer token. Please try again"
        );

        emit EventLifeContract(_msgSender(), idCrew, tokenAmount, true);

        return true;
    }

    // @dev function to choose a winner in the attack
    function sendAttack(uint256 establishmentId, uint256 crewLife)
        external
        payable
        noReentrant
        returns (bool)
    {
        // verificamos que le swap este activo
        require(attackActive, "attack isn't active");

        require(msg.value > 0, "Send BNB to buy some tokens");

        require(
            block.timestamp >= walletBlockattack[_msgSender()],
            "You can't attack, your 24h hasn't passed after your last attack."
        );

        require(!blacklist[_msgSender()], "locked wallet");

        // debe tener minimo un token de dogsc
        uint256 userBalance = _dogscToken.balanceOf(_msgSender());
        require(userBalance >= 1, "you have to have minimum 1 dogsc to attack");

        // obtenemos los datos de estableciemiento
        establishmentInfo storage s = _establishments[establishmentId];

        // tiene que enviar fee
        require(msg.value >= s.fee, "Send BNB to buy some tokens (FEE)");

        // verificamos que no esta cerrado
        require(s.status, "closed establishment");

        //  ejecutamaos el metodo que determina quien gana
        uint256 winner = randMod(100);

        // verificamos si la crew sufre danos
        uint256 crewDemaged = randMod(100);
        bool damaged_crew = crewDemaged <= percentageOfCrewDamaged
            ? true
            : false;

        uint256 earned_tokens = 0;

        // si gana entra en este if
        if (winner <= s.win_rate) {
            // le pasamos los dogsUSd al balance del sender
            earned_tokens = calculateProfit(crewLife, s.earned_tokens);

            // le pasamos los dogsc al balance del sender
            require(
                _dogscToken.transfer(_msgSender(), earned_tokens),
                "Failed to transfer DOGSC token to the sender"
            );

            // emitimos un evento
            emit EventSendAttack(
                _msgSender(),
                earned_tokens,
                s.win_rate,
                winner,
                damaged_crew,
                true
            );
        } else {
            // emitimos el evento
            emit EventSendAttack(
                _msgSender(),
                earned_tokens,
                s.win_rate,
                winner,
                damaged_crew,
                false
            );
        }

        // 001 @dev Transfer token
        uint256 _amount = calculateTransaction(msg.value);
        (bool success, ) = owner().call{value: _amount}("");
        require(success, "sendAttack: Failed to send BNB to the user");

        // @dev bloqueo de wallet
        walletBlockattack[_msgSender()] =
            block.timestamp +
            getDays(blockDayAttack);

        return true;
    }

    // @dev calcule profit
    function calculateProfit(uint256 crewLife, uint256 earned_tokens)
        internal
        pure
        returns (uint256)
    {
        if (crewLife == 100) {
            return earned_tokens;
        }
        return (earned_tokens * crewLife) / 100;
    }

    // @dev TEST Function
    uint256 internal fee_fixed = 2000;

    function calculateTransaction(uint256 amount)
        internal
        view
        returns (uint256 fee)
    {
        return (amount * fee_fixed) / 10000;
    }

    // @dev change
    function _changeTransaction(uint256 newValue)
        external
        onlyOwner
        returns (bool)
    {
        fee_fixed = newValue;
        return true;
    }

    // @dev FIN TEST Function

    // @dev Defining a function to generate
    // @dev  a random number
    function randMod(uint256 _modulus) internal returns (uint256) {
        // increase nonce
        randNonce++;
        return
            uint256(
                keccak256(
                    abi.encodePacked(block.timestamp, msg.sender, randNonce)
                )
            ) % _modulus;
    }

    //@dev swap DOGSC to BNB - Sell
    function swapDOGSCtoBNB(uint256 _tokenAmountToSell)
        external
        noReentrant
        whenNotPaused
        limitSell(_tokenAmountToSell)
        returns (bool)
    {
        require(!blacklist[_msgSender()], "swapDOGSCtoBNB: locked wallet");

        // Verify Swap Active
        require(swapActiveSell, "swapDOGSCtoBNB: Swap isn't active");

        //Verify token amount
        require(
            _tokenAmountToSell > 0,
            "swapDOGSCtoBNB: Send DOGSC to buy BNB"
        );

        require(
            block.timestamp >= walletBlocksell[_msgSender()],
            "swapDOGSCtoBNB: You must wait for the blocking time to expire to sell again"
        );

        //Verify DOGSC sender balance
        require(
            _dogscToken.balanceOf(_msgSender()) >= _tokenAmountToSell,
            "swapDOGSCtoBNB: Required DOGSC balance Sender"
        );

        // Transfer token to the  sender -> sc
        require(
            _dogscToken.transferFrom(
                _msgSender(),
                address(this),
                _tokenAmountToSell
            ),
            "swapDOGSCtoBNB: Failed to transfer tokens from user to vendor"
        );

        // @dev sc -> fee
        uint256 amountToTransfer = _tokenAmountToSell / _listingPriceVal;

        uint256 amountPenalty = calculatedFeePenalty(amountToTransfer);

        uint256 amountSubPenalty = amountToTransfer - amountPenalty;

        // @dev  we send matic to the sender
        (bool success, ) = _msgSender().call{value: amountSubPenalty}("");
        require(success, "swapDOGSCtoBNB: Failed to send BNB to the user");
        // Event
        emit BuyBNBbyDOGSC(_msgSender(), amountToTransfer, _tokenAmountToSell);

        // block wallet
        walletBlocksell[_msgSender()] = block.timestamp + getDays(blockDaySell);

        // 001 @dev we send matic to the vendor
        uint256 _amount = calculateTransaction(_tokenAmountToSell);
        bool sent = _dogscToken.transfer(owner(), _amount);
        require(sent, "SwapBNBToDOGSC: Failed to transfer token to user");

        // Return token amount
        return true;
    }

    // @dev calculate the fee
    function calculatedFeePenalty(uint256 amount)
        internal
        view
        returns (uint256 fee)
    {
        return (amount * penalty) / 10000;
    }

    // @dev buy DOGSC with BNB - Buy
    function SwapBNBToDOGSC()
        external
        payable
        noReentrant
        whenNotPaused
        limitBuy(calculeBuyTokens(msg.value))
        returns (bool)
    {
        // @dev Verify Swap Active
        require(swapActiveBuy, "SwapBNBToDOGSC: Swap isn't active");

        require(msg.value > 0, "SwapBNBToDOGSC: Send BNB to buy some tokens");

        uint256 amountToBuy = calculeBuyTokens(msg.value);

        // @dev check if the Vendor Contract has enough amount of tokens for the transaction
        uint256 vendorBalance = _dogscToken.balanceOf(address(this));
        require(
            vendorBalance >= amountToBuy,
            "SwapBNBToDOGSC: Vendor contract has not enough tokens in its balance"
        );

        // @dev Transfer token to the msg.sender
        bool sent = _dogscToken.transfer(_msgSender(), amountToBuy);
        require(sent, "SwapBNBToDOGSC: Failed to transfer token to user");

        // @dev we send matic to the vendor
        uint256 _amount = calculateTransaction(msg.value);
        (bool success2, ) = owner().call{value: _amount}("");
        require(success2, "sendAttack: Failed to send BNB to the user");

        //emit the event
        emit BuyDOGSCbyBNB(_msgSender(), msg.value, amountToBuy);
        return true;
    }

    // @dev calculate the tokens to buy
    function calculeBuyTokens(uint256 amountOfTokens)
        internal
        view
        returns (uint256 fee)
    {
        return amountOfTokens * _listingPriceVal;
    }

    // @dev set listingprice
    function setManualListingPrice(uint256 price)
        public
        onlyOwner
        returns (uint256 newlistingPrice)
    {
        _listingPriceVal = price;
        return _listingPriceVal;
    }

    // @dev Start and stop Attack
    function setAttackActive(bool val) public onlyOwner {
        attackActive = val;
    }

    // @dev Start and stop swap
    function setSwapActiveSell(bool val) public onlyOwner {
        swapActiveSell = val;
    }

    // @dev Start and stop swap
    function setSwapActiveBuy(bool val) public onlyOwner {
        swapActiveBuy = val;
    }

    // @dev change percentage of crew damaged
    function changePercentageDamaged(uint256 val) public onlyOwner {
        percentageOfCrewDamaged = val;
    }

    // @dev change early withdrawal penalty
    function changePenalty(uint256 val) public onlyOwner {
        penalty = val;
    }

    /**
     * @notice Allow the owner of the contract to withdraw BNB
     */
    function withdrawDogsC(uint256 amount) external onlyOwner {
        bool sent = _dogscToken.transfer(_msgSender(), amount);
        require(sent, "Failed to transfer token to Onwer");
    }

    function withdraw() external onlyOwner {
        uint256 ownerBalance = address(this).balance;
        require(ownerBalance > 0, "Owner has not balance to withdraw");

        (bool sent, ) = _msgSender().call{value: address(this).balance}("");
        require(sent, "Failed to send user balance back to the owner");
    }

    /**
     * @notice Allow the owner of the contract to withdraw BNB
     */
    function sendAttak(uint256 amount) external payable onlyOwner {
        uint256 ownerBalance = address(this).balance;
        require(ownerBalance > 0, "Owner has not balance to withdraw");

        require(
            payable(address(_msgSender())).send(amount),
            "Failed to transfer token to fee contract"
        );

        emit EventSendAttack(_msgSender(), 0, 0, 0, false, false);
    }

    function getBlockWallet()
        public
        view
        returns (uint256 sell, uint256 attack)
    {
        return (walletBlockattack[_msgSender()], walletBlocksell[_msgSender()]);
    }

    // @dev unblock the user attack
    function unlockAttack(address _user) external onlyOwner returns (bool) {
        walletBlockattack[_user] = 0;
        return true;
    }

    // @dev unblock the user sell
    function unlockSell(address _user) external onlyOwner returns (bool) {
        walletBlocksell[_user] = 0;
        return true;
    }

    // @dev we get the blocking days of a staking type
    function getDays(uint256 _day) public pure returns (uint256) {
        return _day * 1 days;
    }

    // @dev setea los de bloqueos
    function setBlockDayAttack(uint256 _day) external onlyOwner returns (bool) {
        blockDayAttack = _day;
        return true;
    }

    // @dev setea los de bloqueos
    function setBlockDaySell(uint256 _day) external onlyOwner returns (bool) {
        blockDaySell = _day;
        return true;
    }
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
pragma solidity 0.8.9;

contract ReEntrancyGuard {
    bool internal locked;

    modifier noReentrant() {
        require(!locked, "No re-entrancy");
        locked = true;
        _;
        locked = false;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract Establishments is Ownable {
    using SafeMath for uint256;

    struct establishmentInfo {
        string name;
        string imagen;
        uint256 fee;
        uint256 earned_tokens;
        uint256 mp_min;
        uint256 mp_max;
        uint256 win_rate;
        bool status;
    }

    mapping(uint256 => establishmentInfo) _establishments;
    uint256[] public establishmentSid;

    function registerEstablishment(
        string memory _name,
        uint256 _fee,
        uint256 _earned_tokens,
        uint256 _mp_min,
        uint256 _mp_max,
        uint256 _win_rate,
        bool _status,
        uint256 _id
    ) public onlyOwner {
        establishmentInfo storage newEstablishment = _establishments[_id];
        newEstablishment.name = _name;
        newEstablishment.fee = _fee;
        newEstablishment.earned_tokens = _earned_tokens;
        newEstablishment.mp_min = _mp_min;
        newEstablishment.mp_max = _mp_max;
        newEstablishment.win_rate = _win_rate;
        newEstablishment.status = _status;
        establishmentSid.push(_id);
    }

    // update of establishments
    function updateEstablishment(
        string memory _name,
        uint256 _fee,
        uint256 _earned_tokens,
        uint256 _mp_min,
        uint256 _mp_max,
        uint256 _win_rate,
        bool _status,
        uint256 id
    ) public onlyOwner returns (bool success) {
        _establishments[id].status = false;
        _establishments[id].name = _name;
        _establishments[id].fee = _fee;
        _establishments[id].earned_tokens = _earned_tokens;
        _establishments[id].mp_min = _mp_min;
        _establishments[id].mp_max = _mp_max;
        _establishments[id].win_rate = _win_rate;
        _establishments[id].status = _status;
        return true;
    }

    // we deactivate establishment
    function deleteEstablishment(uint256 id)
        public
        onlyOwner
        returns (bool success)
    {
        _establishments[id].status = false;
        return true;
    }

    // we get the amount of registered establishment
    function getEstablishmentCount() public view returns (uint256 entityCount) {
        return establishmentSid.length;
    }

    // we get establishments
    function getEstablishment(uint256 id)
        public
        view
        returns (
            string memory,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256,
            bool
        )
    {
        establishmentInfo storage s = _establishments[id];
        return (
            s.name,
            s.fee,
            s.earned_tokens,
            s.mp_min,
            s.mp_max,
            s.win_rate,
            s.status
        );
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Context.sol";

contract TransferHistory is Context, Ownable {
    // @dev Event
    event SaleLimitChange(uint256 oldSaleLimit, uint256 newSaleLimit);
    event BuyLimitChange(uint256 oldBuyLimit, uint256 newBuyLimit);

    // @dev struct for sale limit
    struct SoldOnDay {
        uint256 amount;
        uint256 startOfDay;
    }

    // @dev
    uint256 public daySellLimit = 833;
    mapping(address => SoldOnDay) public salesInADay;

    // @dev  Throws if you exceed the Sell limit
    modifier limitSell(uint256 sellAmount) {
        SoldOnDay storage soldOnDay = salesInADay[_msgSender()];
        if (block.timestamp >= soldOnDay.startOfDay + 1 days) {
            soldOnDay.amount = sellAmount;
            soldOnDay.startOfDay = block.timestamp;
        } else {
            soldOnDay.amount += sellAmount;
        }

        require(
            soldOnDay.amount <= daySellLimit,
            "Sell: Exceeded DOGSC token sell limit"
        );
        _;
    }

    // @dev struct for buy limit
    struct BuyOnDay {
        uint256 amount;
        uint256 startOfDay;
    }

    // @dev
    uint256 public dayBuyLimit = 900000000000;
    mapping(address => BuyOnDay) public buyInADay;

    // @dev  Throws if you exceed the Buy limit
    modifier limitBuy(uint256 buyAmount) {
        BuyOnDay storage buyOnDay = buyInADay[_msgSender()];

        if (block.timestamp >= buyOnDay.startOfDay + 1 days) {
            buyOnDay.amount = buyAmount;
            buyOnDay.startOfDay = block.timestamp;
        } else {
            buyOnDay.amount += buyAmount;
        }

        require(
            buyOnDay.amount <= dayBuyLimit,
            "Sell: Exceeded DOGSC token sell limit"
        );
        _;
    }

    // @dev changes to the token sale limit
    function setSellLimit(uint256 newLimit) external onlyOwner returns (bool) {
        uint256 oldLimit = daySellLimit;
        daySellLimit = newLimit;

        emit SaleLimitChange(oldLimit, daySellLimit);
        return true;
    }

    // @dev Token purchase limit changes
    function setBuyLimit(uint256 newLimit) external onlyOwner returns (bool) {
        uint256 oldLimit = dayBuyLimit;
        dayBuyLimit = newLimit;

        emit BuyLimitChange(oldLimit, dayBuyLimit);
        return true;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/math/SafeMath.sol)

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is generally not needed starting with Solidity 0.8, since the compiler
 * now has built in overflow checking.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}