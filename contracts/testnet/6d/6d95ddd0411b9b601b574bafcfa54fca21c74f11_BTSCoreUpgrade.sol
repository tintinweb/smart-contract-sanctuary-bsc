// SPDX-License-Identifier: Apache-2.0
pragma solidity >=0.8.0;
pragma abicoder v2;
import "@openzeppelin/contracts-upgradeable/utils/math/SafeMathUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./interfaces/IBTSPeriphery.sol";
import "./interfaces/IBTSCore.sol";
import "./libraries/String.sol";
import "./libraries/Types.sol";
import "./ERC20Tradable.sol";
import "./interfaces/IERC20Tradable.sol";

/**
   @title BTSCoreUpgrade contract
   @dev This contract is used to handle coin transferring service
   Note: The coin of following contract can be:
   Native Coin : The native coin of this chain
   Wrapped Native Coin : A tokenized ERC20 version of another native coin like ICX
*/
contract BTSCoreUpgrade is Initializable, IBTSCore, ReentrancyGuardUpgradeable {
    using SafeMathUpgradeable for uint256;
    using String for string;
    event SetOwnership(address indexed promoter, address indexed newOwner);
    event RemoveOwnership(address indexed remover, address indexed formerOwner);

    struct Coin {
        address addr;
        uint256 feeNumerator;
        uint256 fixedFee;
        uint256 coinType;
    }

    modifier onlyOwner() {
        require(owners[msg.sender] == true, "Unauthorized");
        _;
    }

    modifier onlyBTSPeriphery() {
        require(msg.sender == address(btsPeriphery), "Unauthorized");
        _;
    }

    uint256 private constant FEE_DENOMINATOR = 10**4;
    uint256 private constant RC_OK = 0;
    uint256 private constant RC_ERR = 1;

    uint256 private constant NATIVE_COIN_TYPE = 0;
    uint256 private constant NATIVE_WRAPPED_COIN_TYPE = 1;
    uint256 private constant NON_NATIVE_TOKEN_TYPE = 2;

    IBTSPeriphery internal btsPeriphery;

    address[] private listOfOwners;
    uint256[] private chargedAmounts; //   a list of amounts have been charged so far (use this when Fee Gathering occurs)
    string[] internal coinsName; // a string array stores names of supported coins
    string[] private chargedCoins; //   a list of coins' names have been charged so far (use this when Fee Gathering occurs)
    string internal nativeCoinName;

    mapping(address => bool) internal owners;
    mapping(string => uint256) internal aggregationFee; // storing Aggregation Fee in state mapping variable.
    mapping(address => mapping(string => Types.Balance)) internal balances;
    mapping(string => address) internal coins; //  a list of all supported coins
    mapping(string => Coin) internal coinDetails;

    function initialize(
        string calldata _nativeCoinName,
        uint256 _feeNumerator,
        uint256 _fixedFee
    ) public initializer {
        owners[msg.sender] = true;
        listOfOwners.push(msg.sender);
        emit SetOwnership(address(0), msg.sender);
        nativeCoinName = _nativeCoinName;
        coins[_nativeCoinName] = address(0);
        coinsName.push(_nativeCoinName);
        coinDetails[_nativeCoinName] = Coin(
            address(0),
            _feeNumerator,
            _fixedFee,
            NATIVE_COIN_TYPE
        );
    }

    /**
        @notice Get name of nativecoin
        @dev caller can be any
        @return Name of nativecoin
    */
    function getNativeCoinName() external override view returns (string memory) {
        return nativeCoinName;
    }

    /**
       @notice Adding another Onwer.
       @dev Caller must be an Onwer of BTP network
       @param _owner    Address of a new Onwer.
   */
    function addOwner(address _owner) external override onlyOwner {
        require(owners[_owner] == false, "ExistedOwner");
        owners[_owner] = true;
        listOfOwners.push(_owner);
        emit SetOwnership(msg.sender, _owner);
    }

    /**
       @notice Removing an existing Owner.
       @dev Caller must be an Owner of BTP network
       @dev If only one Owner left, unable to remove the last Owner
       @param _owner    Address of an Owner to be removed.
   */
    function removeOwner(address _owner) external override onlyOwner {
        require(listOfOwners.length > 1, "CannotRemoveMinOwner");
        require(owners[_owner] == true, "NotanOwner");
        delete owners[_owner];
        _remove(_owner);
        emit RemoveOwnership(msg.sender, _owner);
    }

    function _remove(address _addr) internal {
        for (uint256 i = 0; i < listOfOwners.length; i++)
            if (listOfOwners[i] == _addr) {
                listOfOwners[i] = listOfOwners[listOfOwners.length - 1];
                listOfOwners.pop();
                break;
            }
    }

    /**
       @notice Checking whether one specific address has Owner role.
       @dev Caller can be ANY
       @param _owner    Address needs to verify.
    */
    function isOwner(address _owner) external view override returns (bool) {
        return owners[_owner];
    }

    /**
       @notice Get a list of current Owners
       @dev Caller can be ANY
       @return      An array of addresses of current Owners
    */
    function getOwners() external view override returns (address[] memory) {
        return listOfOwners;
    }

    /**
        @notice update BTS Periphery address.
        @dev Caller must be an Owner of this contract
        _btsPeriphery Must be different with the existing one.
        @param _btsPeriphery    BTSPeriphery contract address.
    */
    function updateBTSPeriphery(address _btsPeriphery)
        external
        override
        onlyOwner
    {
        require(_btsPeriphery != address(0), "InvalidSetting");
        if (address(btsPeriphery) != address(0)) {
            require(
                btsPeriphery.hasPendingRequest() == false,
                "HasPendingRequest"
            );
        }
        btsPeriphery = IBTSPeriphery(_btsPeriphery);
    }

    /**
        @notice set fee ratio.
        @dev Caller must be an Owner of this contract
        The transfer fee is calculated by feeNumerator/FEE_DEMONINATOR. 
        The feeNumetator should be less than FEE_DEMONINATOR
        _feeNumerator if it is set to `10`, which means the default fee ratio is 0.1%.
        @param _feeNumerator    the fee numerator
    */
    function setFeeRatio(
        string calldata _name,
        uint256 _feeNumerator,
        uint256 _fixedFee
    ) external override onlyOwner {
        require(_feeNumerator <= FEE_DENOMINATOR, "InvalidSetting");
        require(_name.compareTo(nativeCoinName) || coins[_name] != address(0), "TokenNotExists");
        require(_fixedFee >= 0 && _feeNumerator >= 0, "LessThan0");
        coinDetails[_name].feeNumerator = _feeNumerator;
        coinDetails[_name].fixedFee = _fixedFee;
    }

    /**
        @notice Registers a wrapped coin and id number of a supporting coin.
        @dev Caller must be an Owner of this contract
        _name Must be different with the native coin name.
        _symbol symbol name for wrapped coin.
        _decimals decimal number
        @param _name    Coin name. 
    */
    function register(
        string calldata _name,
        string calldata _symbol,
        uint8 _decimals,
        uint256 _feeNumerator,
        uint256 _fixedFee,
        address _addr
    ) external override onlyOwner {
        require(!_name.compareTo(nativeCoinName), "ExistNativeCoin");
        require(coins[_name] == address(0), "ExistCoin");
        require(_feeNumerator <= FEE_DENOMINATOR, "InvalidFeeSetting");
        require(_fixedFee >= 0 && _feeNumerator >= 0, "LessThan0");
        if (_addr == address(0)) {
            address deployedERC20 = address(
                new ERC20Tradable(_name, _symbol, _decimals)
            );
            coins[_name] = deployedERC20;
            coinsName.push(_name);
            coinDetails[_name] = Coin(
                deployedERC20,
                _feeNumerator,
                _fixedFee,
                NATIVE_WRAPPED_COIN_TYPE
            );
        } else {
            coins[_name] = _addr;
            coinsName.push(_name);
            coinDetails[_name] = Coin(
                _addr,
                _feeNumerator,
                _fixedFee,
                NON_NATIVE_TOKEN_TYPE
            );
        }
        string[] memory tokenArr = new string[](1);
        tokenArr[0] = _name;
        uint[] memory valArr = new uint[](1);
        valArr[0] = type(uint256).max;
        btsPeriphery.setTokenLimit(tokenArr, valArr);
    }

    /**
       @notice Return all supported coins names
       @dev 
       @return _names   An array of strings.
    */
    function coinNames()
        external
        view
        override
        returns (string[] memory _names)
    {
        return coinsName;
    }

    /**
       @notice  Return an _id number of Coin whose name is the same with given _coinName.
       @dev     Return nullempty if not found.
       @return  _coinId     An ID number of _coinName.
    */
    function coinId(string calldata _coinName)
        external
        view
        override
        returns (address)
    {
        return coins[_coinName];
    }

    /**
       @notice  Check Validity of a _coinName
       @dev     Call by BTSPeriphery contract to validate a requested _coinName
       @return  _valid     true of false
    */
    function isValidCoin(string calldata _coinName)
        external
        view
        override
        returns (bool _valid)
    {
        return (coins[_coinName] != address(0) ||
            _coinName.compareTo(nativeCoinName));
    }

    /**
        @notice Get fee numerator and fixed fee
        @dev caller can be any
        @param _coinName Coin name
        @return _feeNumerator Fee numerator for given coin
        @return _fixedFee Fixed fee for given coin
    */
    function feeRatio(string calldata _coinName)
        external
        override
        view
        returns (uint _feeNumerator, uint _fixedFee)
    {
        Coin memory coin = coinDetails[_coinName];
        _feeNumerator = coin.feeNumerator;
        _fixedFee = coin.fixedFee;
    }

    /**
        @notice Return a usable/locked/refundable balance of an account based on coinName.
        @return _usableBalance the balance that users are holding.
        @return _lockedBalance when users transfer the coin, 
                it will be locked until getting the Service Message Response.
        @return _refundableBalance refundable balance is the balance that will be refunded to users.
    */
    function balanceOf(address _owner, string memory _coinName)
        external
        view
        override
        returns (
            uint256 _usableBalance,
            uint256 _lockedBalance,
            uint256 _refundableBalance,
            uint256 _userBalance
        )
    {
        if (_coinName.compareTo(nativeCoinName)) {
            return (
                0,
                balances[_owner][_coinName].lockedBalance,
                balances[_owner][_coinName].refundableBalance,
                address(_owner).balance
            );
        }
        address _erc20Address = coins[_coinName];
        IERC20 ierc20 = IERC20(_erc20Address);
        _userBalance = _erc20Address != address(0)
            ? ierc20.balanceOf(_owner)
            : 0;
        uint allowance = _erc20Address != address(0)
            ? ierc20.allowance(_owner, address(this))
            : 0;
        _usableBalance = allowance > _userBalance
            ? _userBalance
            : allowance;
        return (
            _usableBalance,
            balances[_owner][_coinName].lockedBalance,
            balances[_owner][_coinName].refundableBalance,
            _userBalance
        );
    }

    /**
        @notice Return a list Balance of an account.
        @dev The order of request's coinNames must be the same with the order of return balance
        Return 0 if not found.
        @return _usableBalances         An array of Usable Balances
        @return _lockedBalances         An array of Locked Balances
        @return _refundableBalances     An array of Refundable Balances
    */
    function balanceOfBatch(address _owner, string[] calldata _coinNames)
        external
        view
        override
        returns (
            uint256[] memory _usableBalances,
            uint256[] memory _lockedBalances,
            uint256[] memory _refundableBalances,
            uint256[] memory _userBalances
        )
    {
        _usableBalances = new uint256[](_coinNames.length);
        _lockedBalances = new uint256[](_coinNames.length);
        _refundableBalances = new uint256[](_coinNames.length);
        _userBalances = new uint256[](_coinNames.length);
        for (uint256 i = 0; i < _coinNames.length; i++) {
            (
                _usableBalances[i],
                _lockedBalances[i],
                _refundableBalances[i],
                _userBalances[i]
            ) = this.balanceOf(_owner, _coinNames[i]);
        }
        return (_usableBalances, _lockedBalances, _refundableBalances, _userBalances);
    }

    /**
        @notice Return a list accumulated Fees.
        @dev only return the asset that has Asset's value greater than 0
        @return _accumulatedFees An array of Asset
    */
    function getAccumulatedFees()
        external
        view
        override
        returns (Types.Asset[] memory _accumulatedFees)
    {
        _accumulatedFees = new Types.Asset[](coinsName.length);
        for (uint256 i = 0; i < coinsName.length; i++) {
            _accumulatedFees[i] = (
                Types.Asset(coinsName[i], aggregationFee[coinsName[i]])
            );
        }
        return _accumulatedFees;
    }

    /**
       @notice Allow users to deposit `msg.value` native coin into a BTSCore contract.
       @dev MUST specify msg.value
       @param _to  An address that a user expects to receive an amount of tokens.
    */
    function transferNativeCoin(string calldata _to) external payable override {

        btsPeriphery.checkTransferRestrictions(
            nativeCoinName,
            msg.sender,
            msg.value
        );
        //  Aggregation Fee will be charged on BSH Contract
        //  A new charging fee has been proposed. `fixedFee` is introduced
        //  _chargeAmt = fixedFee + msg.value * feeNumerator / FEE_DENOMINATOR
        //  Thus, it's likely that _chargeAmt is always greater than 0
        //  require(_chargeAmt > 0) can be omitted
        //  If msg.value less than _chargeAmt, it likely fails when calculating
        //  _amount = _value - _chargeAmt
        uint256 _chargeAmt = msg
            .value
            .mul(coinDetails[nativeCoinName].feeNumerator)
            .div(FEE_DENOMINATOR)
            .add(coinDetails[nativeCoinName].fixedFee);

        //  @dev msg.value is an amount request to transfer (include fee)
        //  Later on, it will be calculated a true amount that should be received at a destination
        _sendServiceMessage(
            msg.sender,
            _to,
            coinsName[0],
            msg.value,
            _chargeAmt
        );
    }

    /**
       @notice Allow users to deposit an amount of wrapped native coin `_coinName` from the `msg.sender` address into the BTSCore contract.
       @dev Caller must set to approve that the wrapped tokens can be transferred out of the `msg.sender` account by BTSCore contract.
       It MUST revert if the balance of the holder for token `_coinName` is lower than the `_value` sent.
       @param _coinName    A given name of a wrapped coin 
       @param _value       An amount request to transfer from a Requester (include fee)
       @param _to          Target BTP address.
    */
    function transfer(
        string calldata _coinName,
        uint256 _value,
        string calldata _to
    ) external override {
        require(!_coinName.compareTo(nativeCoinName), "InvalidWrappedCoin");
        address _erc20Address = coins[_coinName];
        require(_erc20Address != address(0), "UnregisterCoin");

        btsPeriphery.checkTransferRestrictions(
            _coinName,
            msg.sender,
            _value
        );

        //  _chargeAmt = fixedFee + msg.value * feeNumerator / FEE_DENOMINATOR
        //  Thus, it's likely that _chargeAmt is always greater than 0
        //  require(_chargeAmt > 0) can be omitted
        //  If _value less than _chargeAmt, it likely fails when calculating
        //  _amount = _value - _chargeAmt
        uint256 _chargeAmt = _value
            .mul(coinDetails[_coinName].feeNumerator)
            .div(FEE_DENOMINATOR)
            .add(coinDetails[_coinName].fixedFee);

        //  Transfer and Lock Token processes:
        //  BTSCore contract calls safeTransferFrom() to transfer the Token from Caller's account (msg.sender)
        //  Before that, Caller must approve (setApproveForAll) to accept
        //  token being transfer out by an Operator
        //  If this requirement is failed, a transaction is reverted.
        //  After transferring token, BTSCore contract updates Caller's locked balance
        //  as a record of pending transfer transaction
        //  When a transaction is completed without any error on another chain,
        //  Locked Token amount (bind to an address of caller) will be reset/subtract,
        //  then emit a successful TransferEnd event as a notification
        //  Otherwise, the locked amount will also be updated
        //  but BTSCore contract will issue a refund to Caller before emitting an error TransferEnd event
        IERC20Tradable(_erc20Address).transferFrom(
            msg.sender,
            address(this),
            _value
        );
        //  @dev _value is an amount request to transfer (include fee)
        //  Later on, it will be calculated a true amount that should be received at a destination
        _sendServiceMessage(msg.sender, _to, _coinName, _value, _chargeAmt);
    }

    /**
       @notice This private function handles overlapping procedure before sending a service message to BTSPeriphery
       @param _from             An address of a Requester
       @param _to               BTP address of of Receiver on another chain
       @param _coinName         A given name of a requested coin 
       @param _value            A requested amount to transfer from a Requester (include fee)
       @param _chargeAmt        An amount being charged for this request
    */
    function _sendServiceMessage(
        address _from,
        string calldata _to,
        string memory _coinName,
        uint256 _value,
        uint256 _chargeAmt
    ) private {
        //  Lock this requested _value as a record of a pending transferring transaction
        //  @dev `_value` is a requested amount to transfer, from a Requester, including charged fee
        //  The true amount to receive at a destination receiver is calculated by
        //  _amounts[0] = _value.sub(_chargeAmt);
        require(_value > _chargeAmt, "ValueGreaterThan0");
        lockBalance(_from, _coinName, _value);
        string[] memory _coins = new string[](1);
        _coins[0] = _coinName;
        uint256[] memory _amounts = new uint256[](1);
        _amounts[0] = _value.sub(_chargeAmt);
        uint256[] memory _fees = new uint256[](1);
        _fees[0] = _chargeAmt;

        //  @dev `_amounts` is a true amount to receive at a destination after deducting a charged fee
        btsPeriphery.sendServiceMessage(_from, _to, _coins, _amounts, _fees);
    }

    /**
       @notice Allow users to transfer multiple coins/wrapped coins to another chain
       @dev Caller must set to approve that the wrapped tokens can be transferred out of the `msg.sender` account by BTSCore contract.
       It MUST revert if the balance of the holder for token `_coinName` is lower than the `_value` sent.
       In case of transferring a native coin, it also checks `msg.value`
       The number of requested coins MUST be as the same as the number of requested values
       The requested coins and values MUST be matched respectively
       @param _coinNames    A list of requested transferring wrapped coins
       @param _values       A list of requested transferring values respectively with its coin name
       @param _to          Target BTP address.
    */
    function transferBatch(
        string[] calldata _coinNames,
        uint256[] memory _values,
        string calldata _to
    ) external payable override {
        require(_coinNames.length == _values.length, "InvalidRequest");
        require(_coinNames.length > 0, "Zero length arguments");
        uint256 size = msg.value != 0
            ? _coinNames.length.add(1)
            : _coinNames.length;
        string[] memory _coins = new string[](size);
        uint256[] memory _amounts = new uint256[](size);
        uint256[] memory _chargeAmts = new uint256[](size);
        Coin memory _coin;
        string memory coinName;
        uint value;

        for (uint256 i = 0; i < _coinNames.length; i++) {
            address _erc20Addresses = coins[_coinNames[i]];
            //  Does not need to check if _coinNames[i] == native_coin
            //  If _coinNames[i] is a native_coin, coins[_coinNames[i]] = 0
            require(_erc20Addresses != address(0), "UnregisterCoin");
            coinName = _coinNames[i];
            value = _values[i];
            require(value > 0,"ZeroOrLess");

            btsPeriphery.checkTransferRestrictions(
                coinName,
                msg.sender,
                value
            );

            IERC20Tradable(_erc20Addresses).transferFrom(
                msg.sender,
                address(this),
                value
            );

            _coin = coinDetails[coinName];
            //  _chargeAmt = fixedFee + msg.value * feeNumerator / FEE_DENOMINATOR
            //  Thus, it's likely that _chargeAmt is always greater than 0
            //  require(_chargeAmt > 0) can be omitted
            _coins[i] = coinName;
            _chargeAmts[i] = value
                .mul(_coin.feeNumerator)
                .div(FEE_DENOMINATOR)
                .add(_coin.fixedFee);
            _amounts[i] = value.sub(_chargeAmts[i]);

            //  Lock this requested _value as a record of a pending transferring transaction
            //  @dev Note that: _value is a requested amount to transfer from a Requester including charged fee
            //  The true amount to receive at a destination receiver is calculated by
            //  _amounts[i] = _values[i].sub(_chargeAmts[i]);
            lockBalance(msg.sender, coinName, value);
        }

        if (msg.value != 0) {
            btsPeriphery.checkTransferRestrictions(
                coinName,
                msg.sender,
                value
            );
            //  _chargeAmt = fixedFee + msg.value * feeNumerator / FEE_DENOMINATOR
            //  Thus, it's likely that _chargeAmt is always greater than 0
            //  require(_chargeAmt > 0) can be omitted
            _coins[size - 1] = nativeCoinName; // push native_coin at the end of request
            _chargeAmts[size - 1] = msg
                .value
                .mul(coinDetails[nativeCoinName].feeNumerator)
                .div(FEE_DENOMINATOR)
                .add(coinDetails[nativeCoinName].fixedFee);
            _amounts[size - 1] = msg.value.sub(_chargeAmts[size - 1]);
            lockBalance(msg.sender, nativeCoinName, msg.value);
        }

        //  @dev `_amounts` is true amounts to receive at a destination after deducting charged fees
        btsPeriphery.sendServiceMessage(
            msg.sender,
            _to,
            _coins,
            _amounts,
            _chargeAmts
        );
    }

    /**
        @notice Reclaim the token's refundable balance by an owner.
        @dev Caller must be an owner of coin
        The amount to claim must be smaller or equal than refundable balance
        @param _coinName   A given name of coin
        @param _value       An amount of re-claiming tokens
    */
    function reclaim(string calldata _coinName, uint256 _value)
        external
        override
        nonReentrant
    {
        require(
            balances[msg.sender][_coinName].refundableBalance >= _value,
            "Imbalance"
        );

        balances[msg.sender][_coinName].refundableBalance = balances[
            msg.sender
        ][_coinName].refundableBalance.sub(_value);

        this.refund(msg.sender, _coinName, _value);
    }

    //  Solidity does not allow using try_catch with interal/private function
    //  Thus, this function would be set as 'external`
    //  But, it has restriction. It should be called by this contract only
    //  In addition, there are only two functions calling this refund()
    //  + handleRequestService(): this function only called by BTSPeriphery
    //  + reclaim(): this function can be called by ANY
    //  In case of reentrancy attacks, the chance happenning on BTSPeriphery
    //  since it requires a request from BMC which requires verification fron BMV
    //  reclaim() has higher chance to have reentrancy attacks.
    //  So, it must be prevented by adding 'nonReentrant'
    function refund(
        address _to,
        string calldata _coinName,
        uint256 _value
    ) external {
        require(msg.sender == address(this), "Unauthorized");
        if (_coinName.compareTo(nativeCoinName)) {
            paymentTransfer(payable(_to), _value);
        } else {
            IERC20(coins[_coinName]).transfer(_to, _value);
        }
    }

    function paymentTransfer(address payable _to, uint256 _amount) private {
        (bool sent, ) = _to.call{ value: _amount }("");
        require(sent, "PaymentFailed");
    }

    /**
        @notice mint the wrapped coin.
        @dev Caller must be an BTSPeriphery contract
        Invalid _coinName will have an _id = 0. However, _id = 0 is also dedicated to Native Coin
        Thus, BTSPeriphery will check a validity of a requested _coinName before calling
        for the _coinName indicates with id = 0, it should send the Native Coin (Example: PRA) to user account
        @param _to    the account receive the minted coin
        @param _coinName    coin name
        @param _value    the minted amount   
    */
    function mint(
        address _to,
        string calldata _coinName,
        uint256 _value
    ) external override onlyBTSPeriphery {
        if (_coinName.compareTo(nativeCoinName)) {
            paymentTransfer(payable(_to), _value);
        } else if (
            coinDetails[_coinName].coinType == NATIVE_WRAPPED_COIN_TYPE
        ) {
            IERC20Tradable(coins[_coinName]).mint(_to, _value);
        } else if (coinDetails[_coinName].coinType == NON_NATIVE_TOKEN_TYPE) {
            IERC20(coins[_coinName]).transfer(_to, _value);
        }
    }

    /**
        @notice Handle a response of a requested service
        @dev Caller must be an BTSPeriphery contract
        @param _requester   An address of originator of a requested service
        @param _coinName    A name of requested coin
        @param _value       An amount to receive on a destination chain
        @param _fee         An amount of charged fee
    */
    function handleResponseService(
        address _requester,
        string calldata _coinName,
        uint256 _value,
        uint256 _fee,
        uint256 _rspCode
    ) external override onlyBTSPeriphery {
        //  Fee Gathering and Transfer Coin Request use the same method
        //  and both have the same response
        //  In case of Fee Gathering's response, `_requester` is this contract's address
        //  Thus, check that first
        //  -- If `_requester` is this contract's address, then check whethere response's code is RC_ERR
        //  In case of RC_ERR, adding back charged fees to `aggregationFee` state variable
        //  In case of RC_OK, ignore and return
        //  -- Otherwise, handle service's response as normal
        if (_requester == address(this)) {
            if (_rspCode == RC_ERR) {
                aggregationFee[_coinName] = aggregationFee[_coinName].add(
                    _value
                );
            }
            return;
        }
        uint256 _amount = _value.add(_fee);
        balances[_requester][_coinName].lockedBalance = balances[_requester][
            _coinName
        ].lockedBalance.sub(_amount);

        //  A new implementation has been proposed to prevent spam attacks
        //  In receiving error response, BTSCore refunds `_value`, not including `_fee`, back to Requestor
        if (_rspCode == RC_ERR) {
            try this.refund(_requester, _coinName, _value) {} catch {
                balances[_requester][_coinName].refundableBalance = balances[
                    _requester
                ][_coinName].refundableBalance.add(_value);
            }
        } else if (_rspCode == RC_OK) {
            address _erc20Address = coins[_coinName];
            if (
                !_coinName.compareTo(nativeCoinName) &&
                coinDetails[_coinName].coinType == NATIVE_WRAPPED_COIN_TYPE
            ) {
                IERC20Tradable(_erc20Address).burn(address(this), _value);
            }
        }
        aggregationFee[_coinName] = aggregationFee[_coinName].add(_fee);
    }

    /**
        @notice Handle a request of Fee Gathering
            Usage: Copy all charged fees to an array
        @dev Caller must be an BTSPeriphery contract
    */
    function transferFees(string calldata _fa)
        external
        override
        onlyBTSPeriphery
    {
        //  @dev Due to uncertainty in identifying a size of returning memory array
        //  and Solidity does not allow to use 'push' with memory array (only storage)
        //  thus, must use 'temp' storage state variable
        for (uint256 i = 0; i < coinsName.length; i++) {
            if (aggregationFee[coinsName[i]] != 0) {
                chargedCoins.push(coinsName[i]);
                chargedAmounts.push(aggregationFee[coinsName[i]]);
                delete aggregationFee[coinsName[i]];
            }
        }
        btsPeriphery.sendServiceMessage(
            address(this),
            _fa,
            chargedCoins,
            chargedAmounts,
            new uint256[](chargedCoins.length) //  chargedFees is an array of 0 since this is a fee gathering request
        );
        delete chargedCoins;
        delete chargedAmounts;
    }

    function lockBalance(
        address _to,
        string memory _coinName,
        uint256 _value
    ) private {
        balances[_to][_coinName].lockedBalance = balances[_to][_coinName]
            .lockedBalance
            .add(_value);
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
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC20/ERC20.sol)

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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (utils/math/SafeMath.sol)

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
library SafeMathUpgradeable {
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
     * @dev Returns the subtraction of two unsigned integers, with an overflow flag.
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (utils/Address.sol)

pragma solidity ^0.8.1;

/**
 * @dev Collection of functions related to the address type
 */
library AddressUpgradeable {
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
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20Upgradeable {
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
// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;
import "../proxy/utils/Initializable.sol";

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
abstract contract ReentrancyGuardUpgradeable is Initializable {
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

    function __ReentrancyGuard_init() internal onlyInitializing {
        __ReentrancyGuard_init_unchained();
    }

    function __ReentrancyGuard_init_unchained() internal onlyInitializing {
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

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (proxy/utils/Initializable.sol)

pragma solidity ^0.8.2;

import "../../utils/AddressUpgradeable.sol";

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since proxied contracts do not make use of a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * The initialization functions use a version number. Once a version number is used, it is consumed and cannot be
 * reused. This mechanism prevents re-execution of each "step" but allows the creation of new initialization steps in
 * case an upgrade adds a module that needs to be initialized.
 *
 * For example:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * contract MyToken is ERC20Upgradeable {
 *     function initialize() initializer public {
 *         __ERC20_init("MyToken", "MTK");
 *     }
 * }
 * contract MyTokenV2 is MyToken, ERC20PermitUpgradeable {
 *     function initializeV2() reinitializer(2) public {
 *         __ERC20Permit_init("MyToken");
 *     }
 * }
 * ```
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {ERC1967Proxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 *
 * [CAUTION]
 * ====
 * Avoid leaving a contract uninitialized.
 *
 * An uninitialized contract can be taken over by an attacker. This applies to both a proxy and its implementation
 * contract, which may impact the proxy. To prevent the implementation contract from being used, you should invoke
 * the {_disableInitializers} function in the constructor to automatically lock it when it is deployed:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * /// @custom:oz-upgrades-unsafe-allow constructor
 * constructor() {
 *     _disableInitializers();
 * }
 * ```
 * ====
 */
abstract contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     * @custom:oz-retyped-from bool
     */
    uint8 private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Triggered when the contract has been initialized or reinitialized.
     */
    event Initialized(uint8 version);

    /**
     * @dev A modifier that defines a protected initializer function that can be invoked at most once. In its scope,
     * `onlyInitializing` functions can be used to initialize parent contracts. Equivalent to `reinitializer(1)`.
     */
    modifier initializer() {
        bool isTopLevelCall = !_initializing;
        require(
            (isTopLevelCall && _initialized < 1) || (!AddressUpgradeable.isContract(address(this)) && _initialized == 1),
            "Initializable: contract is already initialized"
        );
        _initialized = 1;
        if (isTopLevelCall) {
            _initializing = true;
        }
        _;
        if (isTopLevelCall) {
            _initializing = false;
            emit Initialized(1);
        }
    }

    /**
     * @dev A modifier that defines a protected reinitializer function that can be invoked at most once, and only if the
     * contract hasn't been initialized to a greater version before. In its scope, `onlyInitializing` functions can be
     * used to initialize parent contracts.
     *
     * `initializer` is equivalent to `reinitializer(1)`, so a reinitializer may be used after the original
     * initialization step. This is essential to configure modules that are added through upgrades and that require
     * initialization.
     *
     * Note that versions can jump in increments greater than 1; this implies that if multiple reinitializers coexist in
     * a contract, executing them in the right order is up to the developer or operator.
     */
    modifier reinitializer(uint8 version) {
        require(!_initializing && _initialized < version, "Initializable: contract is already initialized");
        _initialized = version;
        _initializing = true;
        _;
        _initializing = false;
        emit Initialized(version);
    }

    /**
     * @dev Modifier to protect an initialization function so that it can only be invoked by functions with the
     * {initializer} and {reinitializer} modifiers, directly or indirectly.
     */
    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    /**
     * @dev Locks the contract, preventing any future reinitialization. This cannot be part of an initializer call.
     * Calling this in the constructor of a contract will prevent that contract from being initialized or reinitialized
     * to any version. It is recommended to use this to lock implementation contracts that are designed to be called
     * through proxies.
     */
    function _disableInitializers() internal virtual {
        require(!_initializing, "Initializable: contract is initializing");
        if (_initialized < type(uint8).max) {
            _initialized = type(uint8).max;
            emit Initialized(type(uint8).max);
        }
    }
}

// SPDX-License-Identifier: Apache-2.0
pragma solidity >=0.8.0;

library Types {
    /**
     * @Notice List of ALL Struct being used to Encode and Decode RLP Messages
     */

    //  SPR = State Hash + Pathch Receipt Hash + Receipt Hash
    struct SPR {
        bytes stateHash;
        bytes patchReceiptHash;
        bytes receiptHash;
    }

    struct BlockHeader {
        uint256 version;
        uint256 height;
        uint256 timestamp;
        bytes proposer;
        bytes prevHash;
        bytes voteHash;
        bytes nextValidators;
        bytes patchTxHash;
        bytes txHash;
        bytes logsBloom;
        SPR spr;
        bool isSPREmpty; //  add to check whether SPR is an empty struct
        //  It will not be included in serializing thereafter
    }

    //  TS = Timestamp + Signature
    struct TS {
        uint256 timestamp;
        bytes signature;
    }

    //  BPSI = blockPartSetID
    struct BPSI {
        uint256 n;
        bytes b;
    }

    struct Votes {
        uint256 round;
        BPSI blockPartSetID;
        TS[] ts;
    }

    struct BlockWitness {
        uint256 height;
        bytes[] witnesses;
    }

    struct EventProof {
        uint256 index;
        bytes[] eventMptNode;
    }

    struct BlockUpdate {
        BlockHeader bh;
        Votes votes;
        bytes[] validators;
    }

    struct ReceiptProof {
        uint256 index;
        bytes[] txReceipts;
        EventProof[] ep;
    }

    struct BlockProof {
        BlockHeader bh;
        BlockWitness bw;
    }

    struct RelayMessage {
        BlockUpdate[] buArray;
        BlockProof bp;
        bool isBPEmpty; //  add to check in a case BlockProof is an empty struct
        //  when RLP RelayMessage, this field will not be serialized
        ReceiptProof[] rp;
        bool isRPEmpty; //  add to check in a case ReceiptProof is an empty struct
        //  when RLP RelayMessage, this field will not be serialized
    }

    /**
     * @Notice List of ALL Structs being used by a BSH contract
     */
    enum ServiceType {
        REQUEST_COIN_TRANSFER,
        REQUEST_COIN_REGISTER,
        REPONSE_HANDLE_SERVICE,
        BLACKLIST_MESSAGE,
        CHANGE_TOKEN_LIMIT,
        UNKNOWN_TYPE
    }

    enum BlacklistService {
        ADD_TO_BLACKLIST,
        REMOVE_FROM_BLACKLIST
    }

    struct PendingTransferCoin {
        string from;
        string to;
        string[] coinNames;
        uint256[] amounts;
        uint256[] fees;
    }

    struct TransferCoin {
        string from;
        string to;
        Asset[] assets;
    }

    struct BlacklistMessage {
        BlacklistService serviceType;
        string[] addrs;
        string net;
    }

    struct TokenLimitMessage {
        string[] coinName;
        uint256[] tokenLimit;
        string net;
    }

    struct Asset {
        string coinName;
        uint256 value;
    }

    struct AssetTransferDetail {
        string coinName;
        uint256 value;
        uint256 fee;
    }

    struct Response {
        uint256 code;
        string message;
    }

    struct ServiceMessage {
        ServiceType serviceType;
        bytes data;
    }

    struct Coin {
        uint256 id;
        string symbol;
        uint256 decimals;
    }

    struct Balance {
        uint256 lockedBalance;
        uint256 refundableBalance;
    }

    struct Request {
        string serviceName;
        address bsh;
    }

    /**
     * @Notice List of ALL Structs being used by a BMC contract
     */

    struct VerifierStats {
        uint256 heightMTA; // MTA = Merkle Trie Accumulator
        uint256 offsetMTA;
        uint256 lastHeight; // Block height of last verified message which is BTP-Message contained
        bytes extra;
    }

    struct Service {
        string svc;
        address addr;
    }

    struct Verifier {
        string net;
        address addr;
    }

    struct Route {
        string dst; //  BTP Address of destination BMC
        string next; //  BTP Address of a BMC before reaching dst BMC
    }

    struct Link {
        address[] relays; //  Address of multiple Relays handle for this link network
        uint256 rxSeq;
        uint256 txSeq;
        uint256 blockIntervalSrc;
        uint256 blockIntervalDst;
        uint256 maxAggregation;
        uint256 delayLimit;
        uint256 relayIdx;
        uint256 rotateHeight;
        uint256 rxHeight;
        uint256 rxHeightSrc;
        bool isConnected;
    }

    struct LinkStats {
        uint256 rxSeq;
        uint256 txSeq;
        VerifierStats verifier;
        RelayStats[] relays;
        uint256 relayIdx;
        uint256 rotateHeight;
        uint256 rotateTerm;
        uint256 delayLimit;
        uint256 maxAggregation;
        uint256 rxHeightSrc;
        uint256 rxHeight;
        uint256 blockIntervalSrc;
        uint256 blockIntervalDst;
        uint256 currentHeight;
    }

    struct RelayStats {
        address addr;
        uint256 blockCount;
        uint256 msgCount;
    }

    struct BMCMessage {
        string src; //  an address of BMC (i.e. btp://1234.PARA/0x1234)
        string dst; //  an address of destination BMC
        string svc; //  service name of BSH
        int256 sn; //  sequence number of BMC
        bytes message; //  serializef Service Message from BSH
    }

    struct Connection {
        string from;
        string to;
    }

    struct EventMessage {
        string eventType;
        Connection conn;
    }

    struct BMCService {
        string serviceType;
        bytes payload;
    }

    struct GatherFeeMessage {
        string fa; //  BTP address of Fee Aggregator
        string[] svcs; //  a list of services
    }
}

// SPDX-License-Identifier: Apache-2.0
pragma solidity >=0.8.0;

/**
 * String Library
 *
 * This is a simple library of string functions which try to simplify
 * string operations in solidity.
 *
 * Please be aware some of these functions can be quite gas heavy so use them only when necessary
 *
 * The original library was modified. If you want to know more about the original version
 * please check this link: https://github.com/willitscale/solidity-util.git
 */
library String {
    /**
     * splitBTPAddress
     *
     * Split the BTP Address format i.e. btp://1234.iconee/0x123456789
     * into Network_address (1234.iconee) and Server_address (0x123456789)
     *
     * @param _base String base BTP Address format to be split
     * @dev _base must follow a BTP Address format
     *
     * @return string, string   The resulting strings of Network_address and Server_address
     */
    function splitBTPAddress(string memory _base)
        internal
        pure
        returns (string memory, string memory)
    {
        string[] memory temp = split(_base, "/");
        return (temp[2], temp[3]);
    }

    /**
     * Concat
     *
     * Appends two strings together and returns a new value
     *
     * @param _base When being used for a data type this is the extended object
     *              otherwise this is the string which will be the concatenated
     *              prefix
     * @param _value The value to be the concatenated suffix
     * @return string The resulting string from combinging the base and value
     */
    function concat(string memory _base, string memory _value)
        internal
        pure
        returns (string memory)
    {
        return string(abi.encodePacked(_base, _value));
    }

    /**
     * Index Of
     *
     * Locates and returns the position of a character within a string
     *
     * @param _base When being used for a data type this is the extended object
     *              otherwise this is the string acting as the haystack to be
     *              searched
     * @param _value The needle to search for, at present this is currently
     *               limited to one character
     * @return int The position of the needle starting from 0 and returning -1
     *             in the case of no matches found
     */
    function indexOf(string memory _base, string memory _value)
        internal
        pure
        returns (int256)
    {
        return _indexOf(_base, _value, 0);
    }

    /**
     * Index Of
     *
     * Locates and returns the position of a character within a string starting
     * from a defined offset
     *
     * @param _base When being used for a data type this is the extended object
     *              otherwise this is the string acting as the haystack to be
     *              searched
     * @param _value The needle to search for, at present this is currently
     *               limited to one character
     * @param _offset The starting point to start searching from which can start
     *                from 0, but must not exceed the length of the string
     * @return int The position of the needle starting from 0 and returning -1
     *             in the case of no matches found
     */
    function _indexOf(
        string memory _base,
        string memory _value,
        uint256 _offset
    ) internal pure returns (int256) {
        bytes memory _baseBytes = bytes(_base);
        bytes memory _valueBytes = bytes(_value);

        assert(_valueBytes.length == 1);

        for (uint256 i = _offset; i < _baseBytes.length; i++) {
            if (_baseBytes[i] == _valueBytes[0]) {
                return int256(i);
            }
        }

        return -1;
    }

    /**
     * Length
     *
     * Returns the length of the specified string
     *
     * @param _base When being used for a data type this is the extended object
     *              otherwise this is the string to be measured
     * @return uint The length of the passed string
     */
    function length(string memory _base) internal pure returns (uint256) {
        bytes memory _baseBytes = bytes(_base);
        return _baseBytes.length;
    }

    /*
     * String Split (Very high gas cost)
     *
     * Splits a string into an array of strings based off the delimiter value.
     * Please note this can be quite a gas expensive function due to the use of
     * storage so only use if really required.
     *
     * @param _base When being used for a data type this is the extended object
     *               otherwise this is the string value to be split.
     * @param _value The delimiter to split the string on which must be a single
     *               character
     * @return string[] An array of values split based off the delimiter, but
     *                  do not container the delimiter.
     */
    function split(string memory _base, string memory _value)
        internal
        pure
        returns (string[] memory splitArr)
    {
        bytes memory _baseBytes = bytes(_base);

        uint256 _offset = 0;
        uint256 _splitsCount = 1;
        while (_offset < _baseBytes.length - 1) {
            int256 _limit = _indexOf(_base, _value, _offset);
            if (_limit == -1) break;
            else {
                _splitsCount++;
                _offset = uint256(_limit) + 1;
            }
        }

        splitArr = new string[](_splitsCount);

        _offset = 0;
        _splitsCount = 0;
        while (_offset < _baseBytes.length - 1) {
            int256 _limit = _indexOf(_base, _value, _offset);
            if (_limit == -1) {
                _limit = int256(_baseBytes.length);
            }

            string memory _tmp = new string(uint256(_limit) - _offset);
            bytes memory _tmpBytes = bytes(_tmp);

            uint256 j = 0;
            for (uint256 i = _offset; i < uint256(_limit); i++) {
                _tmpBytes[j++] = _baseBytes[i];
            }
            _offset = uint256(_limit) + 1;
            splitArr[_splitsCount++] = string(_tmpBytes);
        }
        return splitArr;
    }

    /**
     * Compare To
     *
     * Compares the characters of two strings, to ensure that they have an
     * identical footprint
     *
     * @param _base When being used for a data type this is the extended object
     *               otherwise this is the string base to compare against
     * @param _value The string the base is being compared to
     * @return bool Simply notates if the two string have an equivalent
     */
    function compareTo(string memory _base, string memory _value)
        internal
        pure
        returns (bool)
    {
        if (
            keccak256(abi.encodePacked(_base)) ==
            keccak256(abi.encodePacked(_value))
        ) {
            return true;
        }
        return false;
    }

    function toString(uint256 _i) internal pure returns (string memory) {
        if (_i == 0) return "0";
        uint256 len;
        for (uint256 j = _i; j != 0; j /= 10) {
            len++;
        }
        bytes memory bstr = new bytes(len);
        for (uint256 k = len; k > 0; k--) {
            bstr[k - 1] = bytes1(uint8(48 + (_i % 10)));
            _i /= 10;
        }
        return string(bstr);
    }
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.5.8 <0.8.10;

import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";

interface IERC20Tradable is IERC20Upgradeable {
    function burn(address account, uint256 amount) external;

    function mint(address account, uint256 amount) external;
}

// SPDX-License-Identifier: Apache-2.0
pragma solidity >=0.8.0;
pragma abicoder v2;

import "./IBSH.sol";

/**
   @title Interface of BTSPeriphery contract
   @dev This contract is used to handle communications among BMCService and BTSCore contract
*/
interface IBTSPeriphery is IBSH {
    /**
     @notice Check whether BTSPeriphery has any pending transferring requests
     @return true or false
    */
    function hasPendingRequest() external view returns (bool);

    /**
     @notice Send Service Message from BTSCore contract to BMCService contract
     @dev Caller must be BTSCore only
     @param _to             A network address of destination chain
     @param _coinNames      A list of coin name that are requested to transfer  
     @param _values         A list of an amount to receive at destination chain respectively with its coin name
     @param _fees           A list of an amount of charging fee respectively with its coin name 
    */
    function sendServiceMessage(
        address _from,
        string calldata _to,
        string[] memory _coinNames,
        uint256[] memory _values,
        uint256[] memory _fees
    ) external;

    /** */
    function setTokenLimit(
        string[] memory _coinNames,
        uint256[] memory _tokenLimits
    ) external;
    /**
     @notice BSH handle BTP Message from BMC contract
     @dev Caller must be BMC contract only
     @param _from    An originated network address of a request
     @param _svc     A service name of BTSPeriphery contract     
     @param _sn      A serial number of a service request 
     @param _msg     An RLP message of a service request/service response
    */
    function handleBTPMessage(
        string calldata _from,
        string calldata _svc,
        uint256 _sn,
        bytes calldata _msg
    ) external override;

    /**
     @notice BSH handle BTP Error from BMC contract
     @dev Caller must be BMC contract only 
     @param _svc     A service name of BTSPeriphery contract     
     @param _sn      A serial number of a service request 
     @param _code    A response code of a message (RC_OK / RC_ERR)
     @param _msg     A response message
    */
    function handleBTPError(
        string calldata _src,
        string calldata _svc,
        uint256 _sn,
        uint256 _code,
        string calldata _msg
    ) external override;

    /**
     @notice BSH handle Gather Fee Message request from BMC contract
     @dev Caller must be BMC contract only
     @param _fa     A BTP address of fee aggregator
     @param _svc    A name of the service
    */
    function handleFeeGathering(string calldata _fa, string calldata _svc)
        external
        override;

    /**
        @notice Check if transfer is restricted
        @param _coinName    Name of the coin
        @param _user        Address to transfer from
        @param _value       Amount to transfer
    */
    function checkTransferRestrictions(
        string memory _coinName,
        address _user,
        uint256 _value
    ) external;

}

// SPDX-License-Identifier: Apache-2.0
pragma solidity >=0.8.0;
pragma abicoder v2;

import "../libraries/Types.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";

/**
   @title Interface of BTSCore contract
   @dev This contract is used to handle coin transferring service
   Note: The coin of following interface can be:
   Native Coin : The native coin of this chain
   Wrapped Native Coin : A tokenized ERC20 version of another native coin like ICX
*/
interface IBTSCore {
    /**
       @notice Adding another Onwer.
       @dev Caller must be an Onwer of BTP network
       @param _owner    Address of a new Onwer.
    */
    function addOwner(address _owner) external;

    /**
        @notice Get name of nativecoin
        @dev caller can be any
        @return Name of nativecoin
    */
    function getNativeCoinName() external view returns (string memory);

    /**
       @notice Removing an existing Owner.
       @dev Caller must be an Owner of BTP network
       @dev If only one Owner left, unable to remove the last Owner
       @param _owner    Address of an Owner to be removed.
    */
    function removeOwner(address _owner) external;

    /**
       @notice Checking whether one specific address has Owner role.
       @dev Caller can be ANY
       @param _owner    Address needs to verify.
    */
    function isOwner(address _owner) external view returns (bool);

    /**
       @notice Get a list of current Owners
       @dev Caller can be ANY
       @return      An array of addresses of current Owners
    */

    function getOwners() external view returns (address[] memory);

    /**
        @notice update BTS Periphery address.
        @dev Caller must be an Owner of this contract
        _btsPeriphery Must be different with the existing one.
        @param _btsPeriphery    BTSPeriphery contract address.
    */
    function updateBTSPeriphery(address _btsPeriphery) external;

    /**
        @notice set fee ratio.
        @dev Caller must be an Owner of this contract
        The transfer fee is calculated by feeNumerator/FEE_DEMONINATOR. 
        The feeNumetator should be less than FEE_DEMONINATOR
        _feeNumerator is set to `10` in construction by default, which means the default fee ratio is 0.1%.
        @param _feeNumerator    the fee numerator
    */
    function setFeeRatio(
        string calldata _name,
        uint256 _feeNumerator,
        uint256 _fixedFee
    ) external;

    /**
        @notice Registers a wrapped coin and id number of a supporting coin.
        @dev Caller must be an Owner of this contract
        _name Must be different with the native coin name.
        _symbol symbol name for wrapped coin.
        _decimals decimal number
        @param _name    Coin name. 
    */
    function register(
        string calldata _name,
        string calldata _symbol,
        uint8 _decimals,
        uint256 _feeNumerator,
        uint256 _fixedFee,
        address _addr
    ) external;

    /**
       @notice Return all supported coins names
       @dev 
       @return _names   An array of strings.
    */
    function coinNames() external view returns (string[] memory _names);

    /**
       @notice  Return an _id number of Coin whose name is the same with given _coinName.
       @dev     Return nullempty if not found.
       @return  _coinId     An ID number of _coinName.
    */
    function coinId(string calldata _coinName)
        external
        view
        returns (address _coinId);

    /**
       @notice  Check Validity of a _coinName
       @dev     Call by BTSPeriphery contract to validate a requested _coinName
       @return  _valid     true of false
    */
    function isValidCoin(string calldata _coinName)
        external
        view
        returns (bool _valid);

    /**
        @notice Get fee numerator and fixed fee
        @dev caller can be any
        @param _coinName Coin name
        @return _feeNumerator Fee numerator for given coin
        @return _fixedFee Fixed fee for given coin
    */
    function feeRatio(string calldata _coinName)
        external
        view
        returns (uint _feeNumerator, uint _fixedFee);

    /**
        @notice Return a usable/locked/refundable balance of an account based on coinName.
        @return _usableBalance the balance that users are holding.
        @return _lockedBalance when users transfer the coin, 
                it will be locked until getting the Service Message Response.
        @return _refundableBalance refundable balance is the balance that will be refunded to users.
    */
    function balanceOf(address _owner, string memory _coinName)
        external
        view
        returns (
            uint256 _usableBalance,
            uint256 _lockedBalance,
            uint256 _refundableBalance,
            uint256 _userBalance
        );

    /**
        @notice Return a list Balance of an account.
        @dev The order of request's coinNames must be the same with the order of return balance
        Return 0 if not found.
        @return _usableBalances         An array of Usable Balances
        @return _lockedBalances         An array of Locked Balances
        @return _refundableBalances     An array of Refundable Balances
    */
    function balanceOfBatch(address _owner, string[] calldata _coinNames)
        external
        view
        returns (
            uint256[] memory _usableBalances,
            uint256[] memory _lockedBalances,
            uint256[] memory _refundableBalances,
            uint256[] memory _userBalances
        );

    /**
        @notice Return a list accumulated Fees.
        @dev only return the asset that has Asset's value greater than 0
        @return _accumulatedFees An array of Asset
    */
    function getAccumulatedFees()
        external
        view
        returns (Types.Asset[] memory _accumulatedFees);

    /**
       @notice Allow users to deposit `msg.value` native coin into a BTSCore contract.
       @dev MUST specify msg.value
       @param _to  An address that a user expects to receive an amount of tokens.
    */
    function transferNativeCoin(string calldata _to) external payable;

    /**
       @notice Allow users to deposit an amount of wrapped native coin `_coinName` from the `msg.sender` address into the BTSCore contract.
       @dev Caller must set to approve that the wrapped tokens can be transferred out of the `msg.sender` account by BTSCore contract.
       It MUST revert if the balance of the holder for token `_coinName` is lower than the `_value` sent.
       @param _coinName    A given name of a wrapped coin 
       @param _value       An amount request to transfer.
       @param _to          Target BTP address.
    */
    function transfer(
        string calldata _coinName,
        uint256 _value,
        string calldata _to
    ) external;

    /**
       @notice Allow users to transfer multiple coins/wrapped coins to another chain
       @dev Caller must set to approve that the wrapped tokens can be transferred out of the `msg.sender` account by BTSCore contract.
       It MUST revert if the balance of the holder for token `_coinName` is lower than the `_value` sent.
       In case of transferring a native coin, it also checks `msg.value` with `_values[i]`
       It MUST revert if `msg.value` is not equal to `_values[i]`
       The number of requested coins MUST be as the same as the number of requested values
       The requested coins and values MUST be matched respectively
       @param _coinNames    A list of requested transferring coins/wrapped coins
       @param _values       A list of requested transferring values respectively with its coin name
       @param _to          Target BTP address.
    */
    function transferBatch(
        string[] memory _coinNames,
        uint256[] memory _values,
        string calldata _to
    ) external payable;

    /**
        @notice Reclaim the token's refundable balance by an owner.
        @dev Caller must be an owner of coin
        The amount to claim must be smaller or equal than refundable balance
        @param _coinName   A given name of coin
        @param _value       An amount of re-claiming tokens
    */
    function reclaim(string calldata _coinName, uint256 _value) external;

    /**
        @notice mint the wrapped coin.
        @dev Caller must be an BTSPeriphery contract
        Invalid _coinName will have an _id = 0. However, _id = 0 is also dedicated to Native Coin
        Thus, BTSPeriphery will check a validity of a requested _coinName before calling
        for the _coinName indicates with id = 0, it should send the Native Coin (Example: PRA) to user account
        @param _to    the account receive the minted coin
        @param _coinName    coin name
        @param _value    the minted amount   
    */
    function mint(
        address _to,
        string calldata _coinName,
        uint256 _value
    ) external;

    /**
        @notice Handle a request of Fee Gathering
        @dev    Caller must be an BTSPeriphery contract
        @param  _fa    BTP Address of Fee Aggregator 
    */
    function transferFees(string calldata _fa) external;

    /**
        @notice Handle a response of a requested service
        @dev Caller must be an BTSPeriphery contract
        @param _requester   An address of originator of a requested service
        @param _coinName    A name of requested coin
        @param _value       An amount to receive on a destination chain
        @param _fee         An amount of charged fee
    */
    function handleResponseService(
        address _requester,
        string calldata _coinName,
        uint256 _value,
        uint256 _fee,
        uint256 _rspCode
    ) external;
}

// SPDX-License-Identifier: Apache-2.0
pragma solidity >=0.8.0;
pragma abicoder v2;

interface IBSH {
    /**
     @notice BSH handle BTP Message from BMC contract
     @dev Caller must be BMC contract only
     @param _from    An originated network address of a request
     @param _svc     A service name of BSH contract     
     @param _sn      A serial number of a service request 
     @param _msg     An RLP message of a service request/service response
    */
    function handleBTPMessage(
        string calldata _from,
        string calldata _svc,
        uint256 _sn,
        bytes calldata _msg
    ) external;

    /**
     @notice BSH handle BTP Error from BMC contract
     @dev Caller must be BMC contract only 
     @param _svc     A service name of BSH contract     
     @param _sn      A serial number of a service request 
     @param _code    A response code of a message (RC_OK / RC_ERR)
     @param _msg     A response message
    */
    function handleBTPError(
        string calldata _src,
        string calldata _svc,
        uint256 _sn,
        uint256 _code,
        string calldata _msg
    ) external;

    /**
     @notice BSH handle Gather Fee Message request from BMC contract
     @dev Caller must be BMC contract only
     @param _fa     A BTP address of fee aggregator
     @param _svc    A name of the service
    */
    function handleFeeGathering(string calldata _fa, string calldata _svc)
        external;
}

// SPDX-License-Identifier: Apache-2.0
pragma solidity >=0.8.0;
pragma abicoder v2;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract ERC20Tradable is ERC20, Ownable {
    uint8 decimal;
    constructor(
        string memory _name,
        string memory _symbol,
        uint8 _decimals
    ) ERC20(_name, _symbol) {
        require(_decimals <= 77, "OverLimit");
        decimal = _decimals;
        // ERC20._setupDecimals(_decimals);
    }

    function decimals() override public view returns (uint8) {
        return decimal;
    }

    function burn(address account, uint256 amount) public onlyOwner {
        _burn(account, amount);
    }

    function mint(address account, uint256 amount) public onlyOwner {
        _mint(account, amount);
    }
}