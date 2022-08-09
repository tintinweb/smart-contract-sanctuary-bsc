// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;

import './OwnableMultiple.sol';
import './interfaces/IStreAMMProtocolFee.sol';

/**
 * @title StreAMMProtocolFee
 * @dev Implements fees for creating token pairs
 * All relative fees are used as parts per 10,000.
 * i.e. 200 is 2% and 10 is 0.1%
 */
contract StreAMMProtocolFee is OwnableMultiple, IStreAMMProtocolFee {
    uint256 public constant MAX_SWAPPING_FEE = 2500; // maximum fee per swap

    // general value applied to all for all pairs
    address payable public override feeTo; //receiver of token creation fee and streAMM fee
    uint256 public override pairCreationFee; //absolute fee charged on token pair creation
    uint256 public override discountedFee; //relative fee for discounted trades
    uint256 public override streAMMFee; //relative fee sent to feeTo address on each trade

    // default values for pairs which can be changed by the admin after creation
    uint256 public override defaultLiquidityLockerFee; // relative fee for default liquidity locker fee
    uint256 public override defaultLPFee; // relative fee for default liquidity provider fee

    /**
     * @dev Sets the pair creation fee receiver address and the absolute pair creation fee.
     * @param _feeTo address of the fee receiver
     * @param _pairCreationFee absolute value of the pair creation fee
     * @param _discountedFee relative value for discounted trading fee
     * @param _llFee relative value for default liquidity locker fee
     * @param _lpFee relative value for default liquidity provider fee
     * @param _streAMMFee relative value for default streAMM fee
     */
    constructor(
        address payable _feeTo,
        uint256 _pairCreationFee,
        uint256 _discountedFee,
        uint256 _llFee,
        uint256 _lpFee,
        uint256 _streAMMFee
    ) {
        require(_feeTo != address(0), 'StreAMMProtocolFee: Zero address');
        require(
            _discountedFee < MAX_SWAPPING_FEE && _llFee + _lpFee + _streAMMFee < MAX_SWAPPING_FEE,
            'StreAMMProtocolFee: Fees too high'
        );
        require(_discountedFee < _llFee + _lpFee + _streAMMFee, 'StreAMMProtocolFee: Discounted fee too high');
        require(_llFee % 2 == 0 && _streAMMFee % 2 == 0, 'StreAMMProtocolFee: Odd fee');

        feeTo = _feeTo;
        pairCreationFee = _pairCreationFee;
        discountedFee = _discountedFee;
        defaultLiquidityLockerFee = _llFee;
        defaultLPFee = _lpFee;
        streAMMFee = _streAMMFee;
        _addOwner(msg.sender);
    }

    /**
     * @dev set default liquidity locker fee applied to a new created pair
     * This fee can be changed afterwards by the admin defined in StreAMMFactory
     * @param _llFee relative value for default liquidity locker fee in parts per 10,000
     */
    function setDefaultLiquidityLockerFee(uint256 _llFee) external onlyOwner {
        require(_llFee + defaultLPFee + streAMMFee < MAX_SWAPPING_FEE, 'StreAMMProtocolFee: Fees too high');
        require(_llFee % 2 == 0, 'StreAMMProtocolFee: Odd fee');
        defaultLiquidityLockerFee = _llFee;
    }

    /**
     * @dev set default LP fee applied to a new created pair
     * This fee can be changed afterwards by the admin defined in StreAMMFactory
     * @param _lpFee relative value for default lp fee fee in parts per 10,000
     */
    function setDefaultLPFee(uint256 _lpFee) external onlyOwner {
        require(
            _lpFee + defaultLiquidityLockerFee + streAMMFee < MAX_SWAPPING_FEE,
            'StreAMMProtocolFee: Fees too high'
        );
        defaultLPFee = _lpFee;
    }

    /**
     * @dev set default streAMM fee applied to a new created pair
     * This fee can be changed afterwards by the admin defined in StreAMMFactory
     * @param _streAMMFee relative value for default streAMM fee fee in parts per 10,000
     */
    function setStreAMMFee(uint256 _streAMMFee) external onlyOwner {
        require(
            _streAMMFee + defaultLPFee + defaultLiquidityLockerFee < MAX_SWAPPING_FEE,
            'StreAMMProtocolFee: Fees too high'
        );
        require(_streAMMFee % 2 == 0, 'StreAMMProtocolFee: Odd fee');
        streAMMFee = _streAMMFee;
    }

    /**
     * @dev set discounted trading fee by contract owner
     * This fee has to be paid on trading discounted (user has to have discounts rights)
     * @param _discountedFee relative value for discounted fee in parts per 10,000
     */
    function setDiscountedFee(uint256 _discountedFee) external onlyOwner {
        require(_discountedFee < MAX_SWAPPING_FEE, 'StreAMMProtocolFee: Invalid fee');
        discountedFee = _discountedFee;
    }

    /**
     * @dev set the pair creation and streAmm fee receiver address by contract owner
     * @param _feeReceiver address of the new fee receiver
     */
    function setFeeReceiver(address payable _feeReceiver) external onlyOwner {
        require(_feeReceiver != address(0), 'StreAMMProtocolFee: Zero address');
        feeTo = _feeReceiver;
    }

    /**
     * @dev set absolute pair creation fee by contract owner
     * This fee has to be payed once on pair creation
     * @param _pairCreationFee absolute value for pair creation fee
     */
    function setPairCreationFee(uint256 _pairCreationFee) external onlyOwner {
        pairCreationFee = _pairCreationFee;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;

/**
 * @dev Interface of the StreAMMProtocolFee contract
 */
interface IStreAMMProtocolFee {
    /**
     * @dev get the default stream fee applied to a new created pair
     */
    function defaultLiquidityLockerFee() external view returns (uint256);

    /**
     * @dev get the default LP fee applied to a new created pair
     */
    function defaultLPFee() external view returns (uint256);

    /**
     * @dev get the StreAMM fee applied all pairs
     */
    function streAMMFee() external view returns (uint256);

    /**
     * @dev get the address of the StreAMM and creation fee receiving account
     */
    function feeTo() external view returns (address payable);

    /**
     * @dev get the absolute pair creation fee in native token charged on every new pair
     * creation
     */
    function pairCreationFee() external view returns (uint256);

    /**
     * @dev get the relative fee for discounted trades
     */
    function discountedFee() external view returns (uint256);
}

// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

/**
 * @dev Interface of the OwnableMultiple contract
 */
interface IOwnableMultiple {
    /**
     * @dev Returns owner addrass for given index
     */
    function owners(uint256) external view returns (address);

    /**
     * @dev Returns if an address is an Owner
     */
    function isOwner(address _caller) external view returns (bool);

    /**
     * @dev Returns the total number of owners
     */
    function ownersLength() external view returns (uint256);
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;

import './interfaces/IOwnableMultiple.sol';

abstract contract OwnableMultiple is IOwnableMultiple {
    address[] public override owners; // streAMM owners array. Owners are allowed to change pool owners and fees

    event OwnerAdded(address indexed newOwner);
    event OwnerRemoved(address indexed oldOwner);

    modifier onlyOwner() {
        require(isOwner(msg.sender), 'Ownable: caller is not the owner');
        _;
    }

    /**
     * @dev adds an address to Owner list
     */
    function addOwner(address _newOwner) public onlyOwner {
        _addOwner(_newOwner);
    }

    /**
     * @dev adds an address to Owner list
     */
    function addOwners(address[] memory _newOwners) public onlyOwner {
        _addOwners(_newOwners);
    }

    /**
     * @dev removes an array of addresses from Owner list
     */
    function removeOwners(address[] memory _oldOwners) external onlyOwner {
        require(_oldOwners.length < ownersLength(), 'Ownable: Can not remove all owners');
        _removeOwners(_oldOwners);
    }

    /**
     * @dev Returns if an address is an Owner
     */
    function isOwner(address _caller) public view override returns (bool) {
        for (uint256 i; i < owners.length; i++) {
            if (owners[i] == _caller) return true;
        }
        return false;
    }

    /**
     * @dev Returns the total number of owners
     */
    function ownersLength() public view override returns (uint256) {
        return owners.length;
    }

    /**
     * @dev internal function for adding an array of address to Owner list
     */
    function _addOwners(address[] memory _newOwners) internal {
        for (uint256 i; i < _newOwners.length; i++) {
            _addOwner(_newOwners[i]);
        }
    }

    /**
     * @dev internal function for adding an address to Owner list
     */
    function _addOwner(address _newOwner) internal {
        bool exists;
        for (uint256 j; j < owners.length; j++) {
            if (owners[j] == _newOwner) {
                exists = true;
                break;
            }
        }
        if (!exists) {
            owners.push(_newOwner);
            emit OwnerAdded(_newOwner);
        }
    }

    /**
     * @dev internal function for removing an array of addresses from Owner list
     */
    function _removeOwners(address[] memory _oldOwners) internal {
        for (uint256 i; i < _oldOwners.length; i++) {
            _removeOwner(_oldOwners[i]);
        }
    }

    /**
     * @dev internal function for deleting an address from Owner list
     */
    function _removeOwner(address _oldOwner) internal {
        for (uint256 i; i < owners.length; i++) {
            if (owners[i] == _oldOwner) {
                owners[i] = owners[owners.length - 1];
                owners.pop();
                emit OwnerRemoved(_oldOwner);
                break;
            }
        }
    }
}