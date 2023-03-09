//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./NarfexP2pBuyOffer.sol";
import "./INarfexP2pRouter.sol";

interface INarfexKYC {
    function isKYCVerified(address _client) external view returns(bool);
    function getIsBlacklisted(address _account) external view returns(bool);
    function getCanTrade(address _account) external view returns(bool);
}

interface INarfexLawyers {
    function getLawyer() external view returns(address);
}

interface INarfexExchangerPool {
    function getValidatorLimit(address _validator, address _fiatAddress) external view returns(uint);
}

interface IOffer {
    function getOffer() external view returns(address, address, address, bool, bool, uint, uint, uint, uint, uint);
}

/// @title Offers factory for Narfex P2P service
/// @author Danil Sakhinov
/// @dev Allows to create p2p offers
contract NarfexP2pBuyFactory is Ownable {

    struct Offer { /// Offer getter structure
        address offerAddress;
        address fiatAddress;
        address ownerAddress;
        bool isBuy;
        bool isActive;
        uint commission;
        uint totalCommission;
        uint minTrade;
        uint maxTrade;
        uint tradesQuote;
    }

    address immutable public WETH;
    uint constant ETH_PRECISION = 10**18;
    INarfexKYC public kyc;
    INarfexLawyers public lawyers;
    INarfexP2pRouter public router;
    uint public tradesLimit = 2; /// Trades count per one offer in one time

    mapping(address=>address[]) private _offers; /// Fiat=>Offer
    mapping(address=>mapping(address=>bool)) private _validatorHaveOffer; /// Fiat=>Validator=>Have
    mapping(address=>address[]) private _validatorOffers; /// Validator=>Offer
    mapping(address=>uint16) private _fees; /// Protocol fees

    /// @param _WETH Wrap ETH address
    /// @param _kyc KYC contract address
    /// @param _lawyers Lawyers contract address
    /// @param _router NarfexP2pRouter contract address
    constructor(
        address _WETH,
        address _kyc,
        address _lawyers,
        address _router
    ) {
        WETH = _WETH;
        kyc = INarfexKYC(_kyc);
        lawyers = INarfexLawyers(_lawyers);
        router = INarfexP2pRouter(_router);
        emit SetKYCContract(_kyc);
        emit SetLawyersContract(_lawyers);
        emit SetRouter(_router);
        emit SetTradesLimit(2);
    }

    event CreateOffer(address indexed validator, address indexed fiatAddress, address offer, bool isBuy);
    event SetFiatFee(address fiatAddress, uint16 fee);
    event SetRouter(address routerAddress);
    event SetKYCContract(address kycContract);
    event SetLawyersContract(address lawyersContract);
    event SetTradesLimit(uint amount);

    /// @notice Create Buy Offer by validator
    /// @param _fiatAddress Fiat
    /// @param _commission Validator commission with 4 digits of precision (10000 = 100%);
    function create(address _fiatAddress, uint16 _commission) public {
        require(!_validatorHaveOffer[_fiatAddress][msg.sender], "You already have this offer");
        require(kyc.getCanTrade(msg.sender), "You can't trade");
        require(router.getIsFiat(_fiatAddress), "Token is not fiat");
        NarfexP2pBuyOffer offer = new NarfexP2pBuyOffer(address(this), msg.sender, _fiatAddress, _commission);
        _offers[_fiatAddress].push(address(offer));
        _validatorHaveOffer[_fiatAddress][msg.sender] = true;
        _validatorOffers[msg.sender].push(address(offer));
        emit CreateOffer(msg.sender, _fiatAddress, address(offer), true);
    }

    /// @notice Get all validator offers with data
    /// @param _account Validator
    /// @param _offset Start index
    /// @param _limit Results limit. Zero for no limit
    /// @return array of Offer struct
    function getValidatorOffers(address _account, uint _offset, uint _limit) public view returns(Offer[] memory) {
        return _getOffersData(_validatorOffers[_account], _offset, _limit);
    }

    /// @notice Get all offers with data for single fiat
    /// @param _fiat Fiat address
    /// @param _offset Start index
    /// @param _limit Results limit. Zero for no limit
    /// @return array of Offer struct
    function getOffers(address _fiat, uint _offset, uint _limit) public view returns(Offer[] memory) {
        return _getOffersData(_offers[_fiat], _offset, _limit);
    }

    function _getOffersData(
        address[] storage _array,
        uint _offset,
        uint _limit
        ) private view returns(Offer[] memory) {
        uint length = _array.length - _offset;
        uint offersCount = (_limit > 0 && _limit < length)
            ? _limit
            : length;
        Offer[] memory offers = new Offer[](offersCount);
        unchecked {
            for (uint i = _offset; i < _offset + offersCount; i++) {
                offers[i] = _getOfferData(_array[i]);
            }
        }
        return offers;
    }

    function _getOfferData(address _offerAddress) private view returns(Offer memory) {
        (
            address offerAddress,
            address fiatAddress,
            address ownerAddress,
            bool isBuy,
            bool isActive,
            uint commission,
            uint totalCommission,
            uint minTrade,
            uint maxTrade,
            uint tradesQuote
        ) = IOffer(_offerAddress).getOffer();
        return Offer({
            offerAddress: offerAddress,
            fiatAddress: fiatAddress,
            ownerAddress: ownerAddress,
            isBuy: isBuy,
            isActive: isActive,
            commission: commission,
            totalCommission: totalCommission,
            minTrade: minTrade,
            maxTrade: maxTrade,
            tradesQuote: tradesQuote
        });
    }

    /// @notice Get is account in the global platform blacklist
    /// @param _client Account address
    /// @return Is blacklisted
    function getIsBlacklisted(address _client) public view returns(bool) {
        return kyc.getIsBlacklisted(_client);
    }

    /// @notice Get is validator can trade
    /// @param _validator Account address
    /// @return Is can create offers and receive new trades
    function getCanTrade(address _validator) public view returns(bool) {
        return kyc.getCanTrade(_validator);
    }

    /// @notice Get validator fiat limit
    /// @param _validator Account address
    /// @param _fiatAddress Fiat
    /// @return Limit amount
    function getValidatorLimit(address _validator, address _fiatAddress) external view returns(uint) {
        return INarfexExchangerPool(router.getPool()).getValidatorLimit(_validator, _fiatAddress);
    }

    /// @notice Get protocol fee for a single fiat
    /// @param _fiatAddress Fiat
    /// @return Fee in precents
    function getFiatFee(address _fiatAddress) external view returns(uint) {
        return _fees[_fiatAddress];
    }

    /// @notice Get is account verified
    /// @param _client Account address
    /// @return Is verified
    function isKYCVerified(address _client) external view returns(bool) {
        return kyc.isKYCVerified(_client);
    }

    /// @notice How many trades can exist in an offer at the same time
    /// @return Limit amount
    function getTradesLimit() external view returns(uint) {
        return tradesLimit;
    }

    /// @notice Randomly get the address of an active lawyer
    /// @return Lawyer account address
    function getLawyer() external view returns(address) {
        return lawyers.getLawyer();
    }

    /// @notice Get router address
    /// @return Router address
    function getRouter() external view returns(address) {
        return address(router);
    }

    /// @notice Get token price in ETH (or BNB for BSC and etc.)
    /// @param _token Token address
    /// @return Token price
    /// @dev To estimate the gas price in fiat
    function getETHPrice(address _token) external view returns(uint) {
        return router.getETHPrice(_token);
    }

    /// Admin setters

    function setFiatFee(address _fiatAddress, uint16 _fee) public onlyOwner {
        _fees[_fiatAddress] = _fee;
        emit SetFiatFee(_fiatAddress, _fee);
    }
    function setRouter(address _router) public onlyOwner {
        require(address(router) != _router, "The same router");
        router = INarfexP2pRouter(_router);
        emit SetRouter(_router);
    }
    function setKYCContract(address _newAddress) public onlyOwner {
        require(address(kyc) != _newAddress, "The same address");
        kyc = INarfexKYC(_newAddress);
        emit SetKYCContract(_newAddress);
    }
    function setLawyersContract(address _newAddress) public onlyOwner {
        require(address(lawyers) != _newAddress, "The same address");
        lawyers = INarfexLawyers(_newAddress);
        emit SetLawyersContract(_newAddress);
    }
    function setTradesLimit(uint _limit) public onlyOwner {
        tradesLimit = _limit;
        emit SetTradesLimit(_limit);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

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

//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "./INarfexP2pFactory.sol";
import "./INarfexP2pRouter.sol";

/// @title Buy offer in Narfex P2P service
/// @author Danil Sakhinov
/// @dev Allow to create trades with current offer parameters
contract NarfexP2pBuyOffer {

    struct Trade {
        uint8 status; // 0 = closed, 1 = active, 2 = created by owner
        uint32 createDate;
        uint moneyAmount; // Fiat to send to bank account
        uint fiatAmount; // Initial amount - commission - fee
        uint fiatLocked; // Initial amount - commission
        address client;
        address lawyer;
        uint bankAccountId;
        bytes32 chatRoom;
    }

    INarfexP2pFactory immutable factory;
    address immutable public fiat;
    address immutable public owner;
    uint constant DAY = 86400;
    uint constant PERCENT_PRECISION = 10**4;
    uint constant ETH_PRECISION = 10**18;

    uint16 public commission;
    uint public minTradeAmount;
    uint public maxTradeAmount;
    bool public isKYCRequired;

    address[] private _currentClients;
    string[] private _bankAccounts;
    bool private _isActive;
    bool[7][24] private _activeHours;
    mapping(address => Trade) private _trades;
    mapping(address => bool) private _blacklist;

    event Blacklisted(address _client);
    event Unblacklisted(address _client);
    event Disable();
    event Enable();
    event ScheduleUpdate();
    event AddBankAccount(uint _index, string _jsonData);
    event ClearBankAccount(uint _index);
    event KYCRequired();
    event KYCUnrequired();
    event SetCommission(uint _percents);
    event CreateTrade(address _client, uint moneyAmount, uint fiatAmount);
    event Withdraw(uint _amount);
    event SetLawyer(address _client, address _offer, address _lawyer);

    /// @param _factory Factory address
    /// @param _owner Validator as offer owner
    /// @param _fiatAddress Fiat
    /// @param _commission in percents with precision 4 digits (10000 = 100%);
    constructor(
        address _factory,
        address _owner,
        address _fiatAddress,
        uint16 _commission
    ) {
        owner = _owner;
        fiat = _fiatAddress;
        factory = INarfexP2pFactory(_factory);
        _isActive = true;
        /// Fill all hours as active
        unchecked {
            for (uint8 w; w < 7; w++) {
                for (uint8 h; h < 24; h++) {
                    _activeHours[w][h] = true;
                }
            }
        }
        isKYCRequired = true;
        setCommission(_commission);
        emit KYCRequired();
        emit SetCommission(_commission);
        emit Enable();
    }

    modifier onlyOwner() {
        require(owner == msg.sender, "Caller is not the owner");
        _;
    }

    /// @notice Check trade is active
    /// @return isActive
    /// @dev Checks permanent activity, allowance by Protocol and schedule
    function getIsActive() public view returns(bool isActive) {
        if (!_isActive) return false;
        if (factory.getCanTrade(owner)) return false;
        uint8 weekDay = uint8((block.timestamp / DAY + 4) % 7);
        uint8 hour = uint8((block.timestamp / 60 / 60) % 24);
        return _activeHours[weekDay][hour];
    }

    /// @notice Get current fiat balance in this offer contract
    /// @return Fiat balance
    function getBalance() public view returns(uint) {
        return IERC20(fiat).balanceOf(address(this));
    }

    /// @notice Get fiat amount locked by current trades
    /// @return Locked fiat amount
    function getLockedAmount() public view returns(uint) {
        uint locked;
        unchecked {
            for (uint i; i < _currentClients.length; i++) {
                address client = _currentClients[i];
                if (client != address(0)) {
                    locked += _trades[client].fiatLocked;
                }
            }
        }
        return locked;
    }

    /// @notice Get how much balance available for new trades of withdraw
    /// @return Available balance
    function getAvailableBalance() public view returns(uint) {
        return getBalance() - getLockedAmount();
    }

    /// @notice Get fiat limit for a new trade
    /// @return Fiat limit
    function getTradeLimitAvailable() private view returns(uint) {
        uint balance = getAvailableBalance();
        uint poolLimit = factory.getValidatorLimit(owner, fiat);
        uint limit = maxTradeAmount;
        if (balance < limit) limit = balance;
        if (poolLimit < limit) limit = poolLimit;
        return limit;
    }

    /// @notice Get sum of Protocol and Offer commissions
    /// @return Commission in percents with precision 4 digits
    function getTotalCommission() private view returns(uint) {
        return uint(factory.getFiatFee(fiat) + commission);
    }

    /// @notice Sets offer commission
    /// @param _percents Commission in percents with 4 digits of precision
    function setCommission(uint16 _percents) public onlyOwner {
        require (factory.getFiatFee(fiat) + _percents < PERCENT_PRECISION, "Commission too high");
        commission = _percents;
        emit SetCommission(_percents);
    }

    /// @notice Get offer data in one request
    /// @return Offer address
    /// @return Fiat address
    /// @return Validator address
    /// @return Is this Buy offer
    /// @return Is current offer active now
    /// @return Offer commission
    /// @return Total commission
    /// @return Minimum fiat amount for trade start
    /// @return Maximum fiat amount fot trade start
    /// @return Trades quote
    function getOffer() public view returns(address, address, address, bool, bool, uint, uint, uint, uint, uint) {
        return (
            address(this),
            fiat,
            owner,
            true,
            getIsActive(),
            uint(commission),
            getTotalCommission(),
            minTradeAmount,
            getTradeLimitAvailable(),
            getTradesQuote()
        );
    }

    /// @notice Get current client trade
    /// @param _client Client account address
    /// @return Trade data
    function getTrade(address _client) public view returns(Trade memory) {
        Trade memory trade = _trades[_client];
        return trade;
    }

    /// @notice Get current trades
    /// @return Array of Trade structure
    function getCurrentTrades() public view returns(Trade[] memory) {
        Trade[] memory trades = new Trade[](_currentClients.length);
        unchecked {
            for (uint i; i < _currentClients.length; i++) {
                trades[i] = getTrade(_currentClients[i]);
            }
        }
        return trades;
    }

    /// @notice Returns the offer schedule
    /// @return Activity hours
    function getSchedule() public view returns(bool[7][24] memory) {
        return _activeHours;
    }

    /// @notice Set new schedule
    /// @param _schedule [weekDay][hour] => isActive
    function setSchedule(bool[7][24] calldata _schedule) public onlyOwner {
        _activeHours = _schedule;
        emit ScheduleUpdate();
    }

    /// @notice Get is client blacklisted by Offer or Protocol
    /// @param _client Account address
    /// @return Is blacklisted
    function getIsBlacklisted(address _client) public view returns(bool) {
        return _blacklist[_client] || factory.getIsBlacklisted(_client);
    }

    /// @notice Add client to offer blacklist
    /// @param _client Account address
    function addToBlacklist(address _client) public onlyOwner {
        require(!_blacklist[_client], "Client already in blacklist");
        _blacklist[_client] = true;
        emit Blacklisted(_client);
    }

    /// @notice Remove client from offer blacklist
    /// @param _client Account address
    function removeFromBlacklist(address _client) public onlyOwner {
        require(_blacklist[_client], "Client is not in your blacklist");
        _blacklist[_client] = false;
        emit Unblacklisted(_client);
    }

    /// @notice Set the offer is permanently active
    /// @param _newState Is active bool value
    function setActiveness(bool _newState) public onlyOwner {
        require(_isActive != _newState, "Already seted");
        _isActive = _newState;
        if (_newState) {
            emit Enable();
        } else {
            emit Disable();
        }
    }

    /// @notice Set is KYC verification required
    /// @param _newState Is required
    function setKYCRequirement(bool _newState) public onlyOwner {
        require(isKYCRequired != _newState, "Already seted");
        isKYCRequired = _newState;
        if (_newState) {
            emit KYCRequired();
        } else {
            emit KYCUnrequired();
        }
    }

    /// @notice Add validator's bank account
    /// @param _jsonData JSON encoded object
    function addBankAccount(string calldata _jsonData) public onlyOwner {
        _bankAccounts.push(_jsonData);
        emit AddBankAccount(_bankAccounts.length - 1, _jsonData);
    }

    /// @notice Clead bank account data
    /// @param _index Account index
    function clearBankAccount(uint _index) public onlyOwner {
        _bankAccounts[_index] = '';
    }

    /// @notice Returns validator bank accounts
    /// @return Array of strings with JSON encoded objects
    function getBankAccounts() public view returns(string[] memory) {
        return _bankAccounts;
    }

    /// @notice Is account have a trade in this offer
    /// @param _client Account address
    /// @return Is have trade
    function isClientHaveTrade(address _client) public view returns(bool) {
        unchecked {
            for (uint i; i < _currentClients.length; i++) {
                if (_currentClients[i] == _client) return true;
            }
        }
        return false;
    }

    /// @notice Returns how many trades can be created
    /// @return Trades amount
    function getTradesQuote() public view returns(uint) {
        uint limit = factory.getTradesLimit();
        return limit > _currentClients.length
            ? limit - _currentClients.length
            : 0;
    }

    /// @notice Withdraw unlocked fiat amount to the owner
    /// @param _amount Amount to withdraw
    function withdraw(uint _amount) public onlyOwner {
        require(_amount <= getAvailableBalance(), "Not enouth free balance");
        SafeERC20.safeTransferFrom(IERC20(fiat), address(this), msg.sender, _amount);
        emit Withdraw(_amount);
    }

    /// @notice Add random lawyer to the trade
    /// @param _client Client in a trade
    /// @dev Can be called by client and validator once per trade
    /// @dev Factory can change the lawyer at any time
    function setLawyer(address _client) public {
        Trade storage trade = _trades[_client];
        require(trade.status > 0, "Trade is not active");
        require(trade.lawyer == address(0) || msg.sender == address(factory), "Trade already have a lawyer");
        require(
            msg.sender == address(this)
            || msg.sender == owner
            || msg.sender == trade.client
            || msg.sender == address(factory),
            "You don't have permission to this trade"
            );
        trade.lawyer = factory.getLawyer();
        emit SetLawyer(_client, address(this), trade.lawyer);
    }

    /// @notice Creade a new trade
    /// @param moneyAmount How much money the client should send to the bank account of the validator
    /// @param bankAccountId Choosed bank account index
    function createTrade(
        uint moneyAmount,
        uint bankAccountId
    ) public {
        require(getIsActive(), "Offer is not active now");
        require(!getIsBlacklisted(msg.sender), "Your account is blacklisted");
        require(!isKYCRequired || factory.isKYCVerified(msg.sender), "KYC verification required");
        require(bytes(_bankAccounts[bankAccountId]).length > 0, "Bank account is not available");
        require(!isClientHaveTrade(msg.sender), "You already have a trade");
        require(getTradesQuote() >= 1, "Too much trades in this offer");

        uint fiatToLock = moneyAmount - (moneyAmount * commission / PERCENT_PRECISION);
        uint fiatAmount = moneyAmount - (moneyAmount * getTotalCommission() / PERCENT_PRECISION);
        require(moneyAmount >= minTradeAmount, "Too small trade");
        require(fiatAmount <= getTradeLimitAvailable(), "Too big trade");
        bytes32 chatRoom = keccak256(abi.encodePacked(
            block.timestamp,
            owner,
            msg.sender
            ));

        _trades[msg.sender] = Trade({
            status: 1, /// Normally created trade
            createDate: uint32(block.timestamp),
            moneyAmount: moneyAmount,
            fiatAmount: fiatAmount,
            fiatLocked: fiatToLock,
            client: msg.sender,
            lawyer: address(0),
            bankAccountId: bankAccountId,
            chatRoom: chatRoom
        });
        _currentClients.push(msg.sender);
        emit CreateTrade(msg.sender, moneyAmount, fiatAmount);
    }

    /// @notice Create a new trade by the validator when requested by the client
    /// @param moneyAmount How much money the client should send to the bank account of the validator
    /// @param bankAccountId Choosed bank account index
    /// @param clientAddress Client account address
    /// @dev The method is called when the client has no gas
    /// @dev The client will pay for the gas with fiat later
    function createTrade(
        uint moneyAmount,
        uint bankAccountId,
        address clientAddress
    ) public onlyOwner {
        uint gas = gasleft() * tx.gasprice;
        require(getIsActive(), "Offer is not active now");
        require(!getIsBlacklisted(clientAddress), "Client's account is blacklisted");
        require(!isKYCRequired || factory.isKYCVerified(clientAddress), "KYC verification required");
        require(bytes(_bankAccounts[bankAccountId]).length > 0, "Bank account is not available");
        require(!isClientHaveTrade(clientAddress), "Client already have a trade");
        require(getTradesQuote() >= 1, "Too much trades in this offer");

        uint fiatToLock = moneyAmount - (moneyAmount * commission / PERCENT_PRECISION);
        uint fiatAmount = moneyAmount - (moneyAmount * getTotalCommission() / PERCENT_PRECISION);
        require(moneyAmount >= minTradeAmount, "Too small trade");
        require(fiatAmount <= getTradeLimitAvailable(), "Too big trade");

        /// Subtract fiat equivalent of gas deduction from the final fiat amount
        {
            uint ethFiatPrice = ETH_PRECISION / factory.getETHPrice(fiat);
            uint gasFiatDeduction = ethFiatPrice * gas;
            fiatToLock -= gasFiatDeduction;
            fiatAmount -= gasFiatDeduction;
        }

        bytes32 chatRoom = keccak256(abi.encodePacked(
            block.timestamp,
            owner,
            clientAddress
            ));

        _trades[clientAddress] = Trade({
            status: 2, /// Trade created by validator
            createDate: uint32(block.timestamp),
            moneyAmount: moneyAmount,
            fiatAmount: fiatAmount,
            fiatLocked: fiatToLock,
            client: clientAddress,
            lawyer: address(0),
            bankAccountId: bankAccountId,
            chatRoom: chatRoom
        });
        _currentClients.push(clientAddress);
        emit CreateTrade(clientAddress, moneyAmount, fiatAmount);
        
        /// Add a lawyer right away
        setLawyer(clientAddress);
    }

    function removeClientFromCurrent(address _client) private {
        unchecked {
            uint j;
            for (uint i; i < _currentClients.length - 1; i++) {
                if (_currentClients[i] == _client) {
                    j++;
                }
                if (j > 0) {
                    _currentClients[i] = _currentClients[i + 1];
                }
            }
            if (j > 0) {
                _currentClients.pop();
            }
        }
    }

    /// @notice Cancel trade
    /// @param _client Client account address
    /// @dev If the deal is canceled by a lawyer, he will be compensated for gas costs
    /// @dev Can't be called by validator
    function cancelTrade(address _client) public {
        uint gas = gasleft() * tx.gasprice;
        Trade storage trade = _trades[_client];
        require (trade.status > 0, "Trade is not active");
        require (msg.sender == trade.client || msg.sender == trade.lawyer, "You don't have permission");

        if (msg.sender == trade.lawyer) {
            /// If cancel called by lawyer send fiat equivalent of gas to lawyer
            uint ethFiatPrice = ETH_PRECISION / factory.getETHPrice(fiat);
            uint gasFiatDeduction = ethFiatPrice * gas;
            if (gasFiatDeduction > trade.fiatLocked) {
                gasFiatDeduction = trade.fiatLocked;
            }
            SafeERC20.safeTransferFrom(IERC20(fiat), address(this), trade.lawyer, gasFiatDeduction);
        }

        trade.status = 0;
        removeClientFromCurrent(_client);
    }

    /// @notice Finish the trade
    /// @param _client Client account address
    /// @dev If the trade is finished by a lawyer, he will be compensated for gas costs
    /// @dev Can be called by validator of lawyer
    /// @dev If the trade was initiated by the validator, the funds will be converted to ETH
    /// @dev If the trade was initiated by the validator, the caller will receive gas compensation
    function confirmTrade(address _client) public {
        uint gas = gasleft() * tx.gasprice;
        Trade storage trade = _trades[_client];
        require (trade.status > 0, "Trade is not active");
        require (msg.sender == owner || msg.sender == trade.lawyer, "You don't have permission");

        /// Pay fee to the pool
        uint fee = trade.fiatLocked - trade.fiatAmount;
        INarfexP2pRouter router = INarfexP2pRouter(factory.getRouter());
        router.payFee(fiat, fee);

        uint fiatAmount = trade.fiatAmount;
        uint gasFiatDeduction;
        if (msg.sender == trade.lawyer || trade.status == 2) {
            /// Subtract fiat equivalent of gas deduction
            uint ethFiatPrice = ETH_PRECISION / factory.getETHPrice(fiat);
            gasFiatDeduction = ethFiatPrice * gas;
            fiatAmount -= gasFiatDeduction;
        }
        if (msg.sender == trade.lawyer) {
            /// If confirmation called by lawyer send fiat equivalent of gas to lawyer
            SafeERC20.safeTransferFrom(IERC20(fiat), address(this), trade.lawyer, gasFiatDeduction);
        }

        if (trade.status == 2) {
            /// Swap fiat to ETH and send to client
            router.swapToETH(_client, fiat, trade.fiatAmount);
        } else {
            /// Send fiat to client
            SafeERC20.safeTransferFrom(IERC20(fiat), address(this), _client, trade.fiatAmount);
        }

        trade.status = 0;
        removeClientFromCurrent(_client);
    }
}

//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.17;

interface INarfexP2pRouter {
    function payFee(address _fiatAddress, uint _fiatAmount) external;
    function swapToETH(address to, address token, uint amount) external;
    function getPool() external view returns(address);
    function getOracle() external view returns(address);
    function getETHPrice(address _token) external view returns(uint);
    function getIsFiat(address _token) external view returns(bool);
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
// OpenZeppelin Contracts (last updated v4.8.0) (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";
import "../extensions/draft-IERC20Permit.sol";
import "../../../utils/Address.sol";

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    function safePermit(
        IERC20Permit token,
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal {
        uint256 nonceBefore = token.nonces(owner);
        token.permit(owner, spender, value, deadline, v, r, s);
        uint256 nonceAfter = token.nonces(owner);
        require(nonceAfter == nonceBefore + 1, "SafeERC20: permit did not succeed");
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address-functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.17;

interface INarfexP2pFactory {
    function getIsBlacklisted(address _client) external view returns(bool);
    function getValidatorLimit(address _validator, address _fiatAddress) external view returns(uint);
    function getFiatFee(address _fiatAddress) external view returns(uint);
    function isKYCVerified(address _client) external view returns(bool);
    function getTradesLimit() external view returns(uint);
    function getETHPrice(address _token) external view returns(uint);
    function getLawyer() external view returns(address);
    function getRouter() external view returns(address);
    function getCanTrade(address _validator) external view returns(bool);
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
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/draft-IERC20Permit.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 Permit extension allowing approvals to be made via signatures, as defined in
 * https://eips.ethereum.org/EIPS/eip-2612[EIP-2612].
 *
 * Adds the {permit} method, which can be used to change an account's ERC20 allowance (see {IERC20-allowance}) by
 * presenting a message signed by the account. By not relying on {IERC20-approve}, the token holder account doesn't
 * need to send a transaction, and thus is not required to hold Ether at all.
 */
interface IERC20Permit {
    /**
     * @dev Sets `value` as the allowance of `spender` over ``owner``'s tokens,
     * given ``owner``'s signed approval.
     *
     * IMPORTANT: The same issues {IERC20-approve} has related to transaction
     * ordering also apply here.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `deadline` must be a timestamp in the future.
     * - `v`, `r` and `s` must be a valid `secp256k1` signature from `owner`
     * over the EIP712-formatted function arguments.
     * - the signature must use ``owner``'s current nonce (see {nonces}).
     *
     * For more information on the signature format, see the
     * https://eips.ethereum.org/EIPS/eip-2612#specification[relevant EIP
     * section].
     */
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    /**
     * @dev Returns the current nonce for `owner`. This value must be
     * included whenever a signature is generated for {permit}.
     *
     * Every successful call to {permit} increases ``owner``'s nonce by one. This
     * prevents a signature from being used multiple times.
     */
    function nonces(address owner) external view returns (uint256);

    /**
     * @dev Returns the domain separator used in the encoding of the signature for {permit}, as defined by {EIP712}.
     */
    // solhint-disable-next-line func-name-mixedcase
    function DOMAIN_SEPARATOR() external view returns (bytes32);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (utils/Address.sol)

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
        return functionCallWithValue(target, data, 0, "Address: low-level call failed");
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
        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
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
        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
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
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verify that a low level call to smart-contract was successful, and revert (either by bubbling
     * the revert reason or using the provided one) in case of unsuccessful call or if target was not a contract.
     *
     * _Available since v4.8._
     */
    function verifyCallResultFromTarget(
        address target,
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        if (success) {
            if (returndata.length == 0) {
                // only check isContract if the call was successful and the return data is empty
                // otherwise we already know that it was a contract
                require(isContract(target), "Address: call to non-contract");
            }
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    /**
     * @dev Tool to verify that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason or using the provided one.
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
            _revert(returndata, errorMessage);
        }
    }

    function _revert(bytes memory returndata, string memory errorMessage) private pure {
        // Look for revert reason and bubble it up if present
        if (returndata.length > 0) {
            // The easiest way to bubble the revert reason is using memory via assembly
            /// @solidity memory-safe-assembly
            assembly {
                let returndata_size := mload(returndata)
                revert(add(32, returndata), returndata_size)
            }
        } else {
            revert(errorMessage);
        }
    }
}