// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0 <0.9.0;

import "@openzeppelin/contracts/access/Ownable.sol";

//Interface for BaseToken
interface IBaseToken {
    function mint(address to, uint256 amount) external;
}

//Interface for TokenVesting
interface ITokenVesting {
    function createVestingSchedule(
        address _beneficiary,
        uint256 _start,
        uint256 _cliff,
        uint256 _duration,
        uint256 _slicePeriodSeconds,
        bool _revocable,
        uint256 _amount
    ) external;
    function transferOwnership(address newOwner) external;
}

/** @title Interaction. */
contract Interaction is Ownable {
    address public vestingContractAddr;
    address public tokenContractAddr;
    address public bondingCurveContractAddr;
    address[] private genesisInvestor;

    event MintAndCreateVesting(address _userAddress, uint256 _amount);

    modifier onlyBondingCurve() {
        require(msg.sender == bondingCurveContractAddr, "Not bonding curve");
        _;
    }

    function renounceOwnership() public override onlyOwner {
        revert("Can't renounceOwnership");
    }

    /**
     * @notice Set operator, treasury, and injector addresses
     * @dev Only callable by owner
     * @param _vestingContractAddr: address of the vesting contract
     * @param _tokenContractAddr: address of the token contract
     * @param _bondingCurveContractAddr: address of the bonding curve contract
     */
    function setAddr(address _tokenContractAddr, address _vestingContractAddr, address _bondingCurveContractAddr) external onlyOwner {
        require(_vestingContractAddr != address(0), "Cannot be zero address");
        require(_tokenContractAddr != address(0), "Cannot be zero address");
        require(_bondingCurveContractAddr != address(0), "Cannot be zero address");
       
        vestingContractAddr = _vestingContractAddr;
        tokenContractAddr = _tokenContractAddr;
        bondingCurveContractAddr = _bondingCurveContractAddr;
    }

    /**
     * @notice Add a new genesis investor
     * @dev Only callable by owner
     * @param _genesisInvestorWalletAddr: address of the new genesis investor
     */
    function addGenesisInvestor(address _genesisInvestorWalletAddr) external onlyOwner {
        require(_genesisInvestorWalletAddr != address(0), "Cannot be zero address");
       
        genesisInvestor.push(_genesisInvestorWalletAddr);
    }

    function _isGenesisInvestors(address _genesisInvestorWalletAddr) internal view returns (bool) {
        for (uint i = 0; i < genesisInvestor.length; i++) {
            if (genesisInvestor[i] == _genesisInvestorWalletAddr) {
                return true;
            }
        }

        return false;
    }

    /**
    * @notice Transfer vesting contract ownership
    * @dev Only callable by owner
    */
    function transferVestingOwnership(address _newOwner) public onlyOwner {
        require(_newOwner != address(0), "Ownable: new owner is the zero address");
        ITokenVesting(vestingContractAddr).transferOwnership(_newOwner);
    } 

    /**
    * @notice Mint tokens for TokenVesting contract & create a new vesting schedule for a beneficiary.
    * @param _userAddress The beneficiary address.
    * @param _amount The number of token to mint and vest.
    */
    function mintAndCreateVesting(address _userAddress, uint256 _amount) public onlyBondingCurve {

        /**
        * @notice Mint tokens for a recipient.
        * @param to The recipient address.
        * @param amount The number of token to mint.
        */
        IBaseToken(tokenContractAddr).mint(vestingContractAddr, _amount);

        /**
        * @notice Creates a new vesting schedule for a beneficiary.
        * @param _beneficiary address of the beneficiary to whom vested tokens are transferred
        * @param _start start time of the vesting period
        * @param _cliff duration in seconds of the cliff in which tokens will begin to vest
        * @param _duration duration in seconds of the period in which the tokens will vest
        * @param _slicePeriodSeconds duration of a slice period for the vesting in seconds
        * @param _revocable whether the vesting is revocable or not
        * @param _amount total amount of tokens to be released at the end of the vesting
        */
        if (_isGenesisInvestors(_userAddress)) {
            //50% liquid
            ITokenVesting(vestingContractAddr).createVestingSchedule(
                _userAddress,
                block.timestamp,
                1 seconds,
                1 seconds,
                1,
                true,
                _amount * 50 / 100
            );

            //50% liquid after 6 months
            ITokenVesting(vestingContractAddr).createVestingSchedule(
                _userAddress,
                block.timestamp,
                182.5 days,
                182.5 days,
                1,
                true,
                _amount * 50 / 100
            );
        } else {
            //10% liquid
            ITokenVesting(vestingContractAddr).createVestingSchedule(
                _userAddress,
                block.timestamp,
                1 seconds,
                1 seconds,
                1,
                true,
                _amount * 10 / 100
            );

            //25% liquid after 6 months
            ITokenVesting(vestingContractAddr).createVestingSchedule(
                _userAddress,
                block.timestamp,
                181 days,
                181 days,
                1,
                true,
                _amount * 25 / 100
            );

            //65% liquid after 12 months
            ITokenVesting(vestingContractAddr).createVestingSchedule(
                _userAddress,
                block.timestamp,
                365 days,
                365 days,
                1,
                true,
                _amount * 65 / 100
            );
        }
        emit MintAndCreateVesting(_userAddress, _amount); 
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