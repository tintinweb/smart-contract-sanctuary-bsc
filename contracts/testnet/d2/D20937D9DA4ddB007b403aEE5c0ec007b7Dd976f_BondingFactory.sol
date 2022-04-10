/**
 *Submitted for verification at BscScan.com on 2021-07-20
*/

// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity >=0.7.0 <0.9.0;

/// @title IProxy - Helper interface to access masterCopy of the Proxy on-chain
/// @author Richard Meissner - <[email protected]>
interface IProxy {
    function masterCopy() external view returns (address);
}

/// @title GnosisSafeProxy - Generic proxy contract allows to execute all transactions applying the code of a master contract.
/// @author Stefan George - <[email protected]>
/// @author Richard Meissner - <[email protected]>
contract Proxy {
    // singleton always needs to be first declared variable, to ensure that it is at the same location in the contracts to which calls are delegated.
    // To reduce deployment costs this variable is internal and needs to be retrieved via `getStorageAt`
    address internal singleton;

    /// @dev Constructor function sets address of singleton contract.
    /// @param _singleton Singleton address.
    constructor(address _singleton) {
        require(_singleton != address(0), "Invalid singleton address provided");
        singleton = _singleton;
    }

    /// @dev Fallback function forwards all transactions and returns all received return data.
    fallback() external payable {
        // solhint-disable-next-line no-inline-assembly
        assembly {
            let _singleton := and(sload(0), 0xffffffffffffffffffffffffffffffffffffffff)
        // 0xa619486e == keccak("masterCopy()"). The value is right padded to 32-bytes with 0s
            if eq(calldataload(0), 0xa619486e00000000000000000000000000000000000000000000000000000000) {
                mstore(0, _singleton)
                return (0, 0x20)
            }
            calldatacopy(0, 0, calldatasize())
            let success := delegatecall(gas(), _singleton, 0, calldatasize(), 0, 0)
            returndatacopy(0, 0, returndatasize())
            if eq(success, 0) {
                revert(0, returndatasize())
            }
            return (0, returndatasize())
        }
    }
}

interface ITreasure {
    function initialize(address _MILKY, address _MILKYLP, address __owner, address _depositToken, address _depositor, address _rewardManager) external;
}

interface IStaking {
    function initialize(address _MILKY, address _sMILKY, uint _epochLength, uint _firstEpochNumber, uint _firstEpochBlock, uint256 _rateReward, address _treasury, address __owner)
    external;
}

interface ISToken {
    function initialize(address stakingContract_, address __owner, string calldata name, uint8 dec, uint256 totalSup) external returns (bool);
}

interface IBonding {
    function initialize(
        address _milky,
        address _principle,
        address _calculator,
        address _treasury,
        address _dao,
        address _staking,
        address __owner,
        uint _controlVariable,
        uint _vestingTerm,
        uint _maxPayout,
        uint _fee
    ) external;
}

interface IBEP20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the token decimals.
     */
    function decimals() external view returns (uint8);

    /**
     * @dev Returns the token symbol.
     */
    function symbol() external view returns (string memory);

    /**
    * @dev Returns the token name.
    */
    function name() external view returns (string memory);

    /**
     * @dev Returns the bep token owner.
     */
    function getOwner() external view returns (address);

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
    function allowance(address _owner, address spender) external view returns (uint256);

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
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

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

contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Returns true if the caller is the current owner.
     */
    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() external onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) external onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     */
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract BondingFactory is Ownable {
    address public bondingBEP20Implement;
    address public bondingNativeImplement;
    address public stakingImplement;
    address public sTokenImplement;
    address public treasuryImplement;

    enum SetContractType{BEP20_BONDING, NATIVE_BONDING, STAKING, STOKEN, TREASURY}

    enum BondingType{BEP20, NATIVE}

    constructor(address _bondingBEP20Implement, address _bondingNativeImplement, address _stakingImplement, address _sTokenImplement, address _treasuryImplement) public {
        bondingBEP20Implement = _bondingBEP20Implement;
        bondingNativeImplement = _bondingNativeImplement;
        stakingImplement = _stakingImplement;
        sTokenImplement = _sTokenImplement;
        treasuryImplement = _treasuryImplement;
    }

    function setAddress(SetContractType _type, address _address) external onlyOwner {
        if (_type == SetContractType.BEP20_BONDING) {
            bondingBEP20Implement = _address;
        } else if (_type == SetContractType.NATIVE_BONDING) {
            bondingNativeImplement = _address;
        } else if (_type == SetContractType.STAKING) {
            stakingImplement = _address;
        } else if (_type == SetContractType.STOKEN) {
            sTokenImplement = _address;
        } else if (_type == SetContractType.TREASURY) {
            treasuryImplement = _address;
        }
    }

    struct ListAddress {
        address staking;
        address bonding;
        address sToken;
        address treasury;
    }

    struct BondCreatingData {
        // deposit token
        address stableCoin;
        // reward token
        address tea;
        // price feed to calculate data
        address priceFeed;
        // the place own bonding fee
        address dao;
        address owner;
        // totalSup init of sToken (not mul vs 10**dec)
        uint256 totalSup;
        // staking  reward each 8 hours(div 10**6)
        uint256 rate;
        // the discount when bonding (10000 = not discount)
        uint256 discount;
        // vesting block number of bonding
        uint256 bondingTime;
        // maxPayout can buy each bonding time totalSup * maxPayout / 100000
        uint256 maxPayout;
        // bonding fee amount*fee/10000
        uint256 bondingFee;
        // bonding with bnb or bep20
        BondingType _bondingType;
    }

    event BondCreated(address staking, address sToken, address bonding, address treasury);

    function createBonding(BondCreatingData memory data) public returns (address, address, address, address) {
        address treasury = address(new Proxy(treasuryImplement));
        address sToken = address(new Proxy(sTokenImplement));
        address staking = address(new Proxy(stakingImplement));
        address bonding;
        if (data._bondingType == BondingType.BEP20) {
            bonding = address(new Proxy(bondingBEP20Implement));
        } else {
            bonding = address(new Proxy(bondingNativeImplement));
        }

        ListAddress  memory listContract = ListAddress(staking, bonding, sToken, treasury);


        initializeStaking(data, listContract);
        initializeSToken(data, listContract);
        initializeBonding(data, listContract);
        initializeTreasury(data, listContract);
        emit BondCreated(staking, sToken, bonding, treasury);
        return (staking, sToken, bonding, treasury);

    }

    function initializeStaking(BondCreatingData memory data, ListAddress memory listContract) private {
        // force rebase each 8 hours
        IStaking(listContract.staking).initialize(data.tea, listContract.sToken, 9600, 0, block.number, data.rate, listContract.treasury, data.owner);
    }

    function initializeSToken(BondCreatingData memory data, ListAddress memory listContract) private {
        ISToken(listContract.sToken).initialize(listContract.staking, data.owner, IBEP20(data.tea).name(), IBEP20(data.tea).decimals(), data.totalSup);
    }

    function initializeBonding(BondCreatingData memory data, ListAddress memory listContract) private {
        IBonding(listContract.bonding).initialize(
            data.tea,
            data.stableCoin,
            data.priceFeed,
            listContract.treasury,
            data.dao,
            listContract.staking,
            data.owner,
            data.discount,
            data.bondingTime,
            data.maxPayout,
            data.bondingFee
        );
    }

    function initializeTreasury(BondCreatingData memory data, ListAddress memory listContract) private {
        ITreasure(listContract.treasury).initialize(data.tea, data.stableCoin, data.owner, data.stableCoin, listContract.bonding, listContract.staking);
    }
}