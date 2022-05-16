//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.7;
pragma experimental ABIEncoderV2;
import "@openzeppelin/contracts/access/Ownable.sol";

contract combine_beacon is Ownable {
    struct sFee {
        uint current_amount;
        uint replacement_amount;
        uint256 start;
    }

    struct sExchange {
        address current_logic_contract;
        address replacement_logic_contract;
        uint256 start;
    }
    struct aDiscount {
        address _user;
        uint _discount;
        uint _expires;
    }
    struct sDiscount {
        uint discount_amount;
        uint expires;
    }

    struct sExchangeInfo {
        address chefContract;
        address routerContract;
        address rewardToken;
        address intermediateToken;
        address baseToken;
        string pendingCall;
        string contractType_solo;
        string contractType_pooled;
        bool psV2;
    }

    mapping (string => mapping(string => sFee)) public mFee;
    mapping (string => sExchange) public mExchanges;
    mapping (address => sDiscount) public mDiscounts;
    mapping (string => sExchangeInfo) public mExchangeInfo;
    mapping (string => address) public mData;
    mapping (string => uint) public mDataUint;

    bool bitFlip;

    event sdFeeSet(string _exchange, string _function, uint _amount, uint256 _time, uint256 _current);
    event sdDiscountSet(address _user, uint _discount, uint _expires);
    event sdDiscountsSet(uint _count);
    event sdExchangeSet(string  _exchange, address _replacement_logic_contract, uint256 _start);
    event sdEexchangeInfoSet(string _name, address _chefContract, address _routerContract, bool _psV2, address _rewardToken, string _pendingCall,address _intermediateToken, address _baseToken, string _contractType_solo, string _contractType_pooled);
    event sdAddressSet(string _name, address _address);
    event sdDataUintSet(string _key, uint _value);

    ///@notice Calculate fee with discount from user
    ///@param _exchange Exchange name
    ///@param _type Type of fee
    ///@param _user User address
    ///@return amount - amount of the fee
    ///@return expires - unix timestamp when the discount expires

    function getFee(string memory _exchange, string memory _type, address _user) external view returns (uint,uint) {
        uint expires;

        sFee memory rv = mFee[_exchange][_type];
        sDiscount memory disc = mDiscounts[_user];
        if (rv.replacement_amount == 0 && rv.current_amount == 0) {
            rv = mFee['DEFAULT'][_type];
        }

        uint amount =  (rv.start != 0 && rv.start <= block.timestamp) ? rv.replacement_amount : rv.current_amount;   // 
        bool expired = (disc.discount_amount > 0 && (disc.expires > block.timestamp || disc.expires == 0)) ? false : true;

        if (expired) {            
            expires = 0;
        }
        else {
            amount = amount - (amount *(disc.discount_amount/100) / (10**18)); 
            expires = disc.expires;
        }

        return (amount,expires);
    }
    ///@notice Calculate fee without discount from user
    ///@param _exchange Exchange name
    ///@param _type Type of fee
    ///@return amount - amount of the fee
    ///@return expires - unix timestamp when the discount expires
    function getFee(string memory _exchange, string memory _type) external view returns (uint,uint) {
        sFee memory rv = mFee[_exchange][_type];
        if (rv.replacement_amount == 0 && rv.current_amount == 0) {
            rv = mFee['DEFAULT'][_type];
        }
        uint amount =  (rv.start != 0 && rv.start <= block.timestamp) ? rv.replacement_amount : rv.current_amount;
        return (amount,0); 
    }


    ///@notice get a constant setting and check for new value baed on timestamp
    ///@param _exchange Exchange name
    ///@param _type Name of constant
    ///@return value of constant

    function getConst(string memory _exchange, string memory _type) external view returns (uint) {
        sFee memory rv = mFee[_exchange][_type];
        if (rv.replacement_amount == 0 && rv.current_amount == 0) {
            rv = mFee['DEFAULT'][_type];
        }
        return (rv.start != 0 && rv.start <= block.timestamp) ? rv.replacement_amount : rv.current_amount;
    }

    ///@notice Accept a user and discount from the admin only
    ///@param _user User address
    ///@param _amount Discount amount
    ///@param _expires Unix timestamp when the discount expires
    function setDiscount(address _user, uint _amount, uint _expires) public onlyOwner {
        require(_amount <= 100 ether,"Cannot exceed 100%");
        mDiscounts[_user].discount_amount = _amount;
        if (_expires > 0 && _expires < 31536000) {
            _expires = block.timestamp + _expires;
        }
        mDiscounts[_user].expires = _expires;
        if (mDataUint["LASTDISCOUNT"] != block.timestamp) mDataUint['LASTDISCOUNT'] = block.timestamp;
        emit sdDiscountSet(_user,_amount,_expires);
    }

    ///@notice Accept an array of users and discounts from teh admin only
    ///@param _discount struct array of users and discounts    
    function setDiscountArray(aDiscount[] calldata  _discount) public onlyOwner{ 
        for (uint i = 0; i < _discount.length; i++) {
            setDiscount(_discount[i]._user, _discount[i]._discount, _discount[i]._expires);
        }
        emit sdDiscountsSet(_discount.length);
    }

    ///@notice get discount amount for a user
    ///@param _user User address
    ///@return discount amount
    ///@return Unix timestamp when the discount expires
    function getDiscount(address _user) external view returns (uint,uint) {
        sDiscount memory disc = mDiscounts[_user];
        return (disc.discount_amount, disc.expires);
    }

    ///@notice Sets a fee for an exchange and function
    ///@param _exchange Exchange name
    ///@param _type Function name
    ///@param _replacement_amount Amount of the fee
    ///@param _start Unix timestamp when the fee starts
    function setFee(string memory _exchange, string memory _type, uint _replacement_amount, uint256 _start) external onlyOwner {
        sFee memory rv = mFee[_exchange][_type];
        
        if (_start < 1209600) {
            _start = block.timestamp + _start;
        }
        
        if (rv.start != 0 && rv.start < block.timestamp) {
            mFee[_exchange][_type].current_amount = mFee[_exchange][_type].replacement_amount;
        }
        
        mFee[_exchange][_type].start = _start;
        mFee[_exchange][_type].replacement_amount = _replacement_amount;

        if (rv.current_amount == 0) {
            mFee[_exchange][_type].current_amount = _replacement_amount;
        }
        emit sdFeeSet(_exchange,_type,_replacement_amount,_start, block.timestamp);
    }
    
    ///@notice Get logic contract for an exchange
    ///@param _exchange Exchange name
    ///@return address of the logic contract
    function getExchange(string memory _exchange) external view returns(address) {
        sExchange memory rv = mExchanges[_exchange];

        if (rv.start != 0 && rv.start < block.timestamp) {
            return rv.replacement_logic_contract;
        }
        return rv.current_logic_contract;
    }

    //@notice Set address for a logic contract that comes into effect at specific timestamp
    ///@dev set _start to 0 to take effect immediately
    ///@param _exchange Exchange name
    ///@param _replacement_logic_contract Address of the logic contract
    ///@param _start Unix timestamp when the logic contract comes into effect
    function setExchange(string memory _exchange, address _replacement_logic_contract, uint256 _start) public onlyOwner {
        sExchange memory rv = mExchanges[_exchange];
        
        if (_start < 1209600) {
            _start = block.timestamp + _start;
        }
        
        if (rv.start != 0 && rv.start <= block.timestamp) {
            mExchanges[_exchange].current_logic_contract = mExchanges[_exchange].replacement_logic_contract;
        }
        
        mExchanges[_exchange].start = _start;
        mExchanges[_exchange].replacement_logic_contract = _replacement_logic_contract;
        if (mExchanges[_exchange].current_logic_contract == address(0) || _start <= block.timestamp) {
            mExchanges[_exchange].current_logic_contract = _replacement_logic_contract;
        }
        emit sdExchangeSet(_exchange, _replacement_logic_contract, _start);
    }
    
    //@notice Set information for exchange
    ///@param _name Exchange name
    ///@param _chefContract Address of the MasterChef contract for pool information
    ///@param _routerContract Address of the Router contract 
    ///@param _rewardToken Address of the reward token for exchange
    ///@param _pendingCall string of the function in the MasterChef contract that gets the pending reward for a pool
    ///@param _baseToken FUTURE CODE: Address of the token used as base for all calculations. Currently it is only BNB
    ///@param _contractType_solo Name of Logic Contract to be called  from "getExchange" for solo farming
    ///@param _contractType_pooled Name of Logic Contract to be called  from "getExchange" for pooled farming
    function setExchangeInfo(string memory _name, address _chefContract, address _routerContract, bool _psV2, address _rewardToken, string memory _pendingCall,address _intermediateToken, address _baseToken, string memory _contractType_solo, string memory _contractType_pooled) public onlyOwner {
        require(bytes(_name).length > 0, "Name cannot be empty");
        require(_chefContract != address(0), "Chef contract cannot be empty");
        require(_routerContract != address(0), "Route contract cannot be empty");
        require(_rewardToken != address(0), "Reward token cannot be empty");
        require(bytes(_pendingCall).length > 0, "Pending call cannot be empty");
        require(bytes(_contractType_solo).length > 0, "Contract type cannot be empty");
        require(bytes(_contractType_pooled).length > 0, "Contract type cannot be empty");

        mExchangeInfo[_name].chefContract = _chefContract;
        mExchangeInfo[_name].routerContract = _routerContract;
        mExchangeInfo[_name].psV2 = _psV2;
        mExchangeInfo[_name].rewardToken = _rewardToken;
        mExchangeInfo[_name].pendingCall = _pendingCall;
        mExchangeInfo[_name].intermediateToken = _intermediateToken;
        mExchangeInfo[_name].baseToken = _baseToken;
        mExchangeInfo[_name].contractType_solo = _contractType_solo;
        mExchangeInfo[_name].contractType_pooled = _contractType_pooled;
        emit sdEexchangeInfoSet(_name, _chefContract, _routerContract, _psV2, _rewardToken, _pendingCall, _intermediateToken, _baseToken, _contractType_solo, _contractType_pooled);        
    }
    
    ///@notice Get information for exchange
    ///@param _name Exchange name
    ///@return Structure containing exchange information creaded by setExchangeInfo
    function getExchangeInfo(string memory _name) external view returns (sExchangeInfo memory) {
        return mExchangeInfo[_name];
    }

    ///@notice Get identifier for contract type based on exchange name
    ///@param _name Exchange name
    ///@param _type Type of contract (0=solo, 1=pooled)
    ///@return _contract Name of contract type

    function getContractType(string memory _name, uint _type) public view returns (string memory _contract) {                
        _contract = _type== 0?mExchangeInfo[_name].contractType_solo:mExchangeInfo[_name].contractType_pooled;
    }


    ///@notice Set address of lookup key (ie. FEECOLLECTOR, ADMINUSER, etc)
    ///@param _key Key name
    ///@param _value Address of specified key
    function setAddress(string memory _key, address _value) public onlyOwner {
        require(bytes(_key).length > 0, "Key cannot be empty");
        require(_value != address(0), "Value cannot be empty");
        mData[_key] = _value;
        emit sdAddressSet(_key, _value);
    }

    ///@notice Get address of lookup key (ie. FEECOLLECTOR, ADMINUSER, etc)
    ///@param _key Key name
    ///@return Address of specified key
    function getAddress(string memory _key) external view returns(address) {
        return mData[_key];
    }

    ///@notice Get a uint of lookup key. Mostly used for LAST DEPOSITS
    ///@param _key Key name
    ///@return uint of specified key
    function getDataUint(string memory _key) external view returns (uint) {
        return mDataUint[_key];
    }

    ///@notice Set a uint of lookup key. Mostly used for LAST DEPOSITS
    ///@param _key Key name
    ///@param _value uint of specified key    
    function setDataUint(string memory _key, uint _value) external onlyOwner {
        require(bytes(_key).length > 0, "Key cannot be empty");
        mDataUint[_key] = _value;
        emit sdDataUintSet(_key, _value);
    }
}

// SPDX-License-Identifier: MIT

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