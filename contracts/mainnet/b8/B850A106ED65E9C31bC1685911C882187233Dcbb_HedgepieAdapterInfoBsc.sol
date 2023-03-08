// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.8.4;

import "./libraries/Ownable.sol";

contract HedgepieAdapterInfoBsc is Ownable {
    struct AdapterInfo {
        uint256 tvl;
        uint256 participant;
        uint256 traded;
        uint256 profit;
    }

    // nftId => AdapterInfo
    mapping(uint256 => AdapterInfo) public adapterInfo;

    // nftId => participant's address existing
    mapping(uint256 => mapping(address => bool)) public participants;

    // AdapterInfoEth managers mapping
    mapping(address => bool) public managers;

    /////////////////
    /// Modifiers ///
    /////////////////

    modifier isManager() {
        require(managers[msg.sender], "Invalid manager address");
        _;
    }

    ////////////////
    //// Events ////
    ////////////////

    event AdapterInfoUpdated(
        uint256 indexed tokenId,
        uint256 participant,
        uint256 traded,
        uint256 profit
    );
    event ManagerAdded(address manager);
    event ManagerRemoved(address manager);

    /////////////////////////
    /// Manager Functions ///
    /////////////////////////

    function updateTVLInfo(
        uint256 _tokenId,
        uint256 _value,
        bool _adding
    ) external isManager {
        adapterInfo[_tokenId].tvl = _adding
            ? adapterInfo[_tokenId].tvl + _value
            : adapterInfo[_tokenId].tvl < _value
            ? 0
            : adapterInfo[_tokenId].tvl - _value;
        _emitEvent(_tokenId);
    }

    function updateTradedInfo(
        uint256 _tokenId,
        uint256 _value,
        bool _adding
    ) external isManager {
        adapterInfo[_tokenId].traded = _adding
            ? adapterInfo[_tokenId].traded + _value
            : adapterInfo[_tokenId].traded - _value;
        _emitEvent(_tokenId);
    }

    function updateProfitInfo(
        uint256 _tokenId,
        uint256 _value,
        bool _adding
    ) external isManager {
        adapterInfo[_tokenId].profit = _adding
            ? adapterInfo[_tokenId].profit + _value
            : adapterInfo[_tokenId].profit - _value;
        _emitEvent(_tokenId);
    }

    function updateParticipantInfo(
        uint256 _tokenId,
        address _account,
        bool _adding
    ) external isManager {
        bool isExisted = participants[_tokenId][_account];

        if (_adding) {
            adapterInfo[_tokenId].participant = isExisted
                ? adapterInfo[_tokenId].participant
                : adapterInfo[_tokenId].participant + 1;

            if (!isExisted) participants[_tokenId][_account] = true;
        } else {
            adapterInfo[_tokenId].participant = isExisted
                ? adapterInfo[_tokenId].participant - 1
                : adapterInfo[_tokenId].participant;
            delete participants[_tokenId][_account];
            if (isExisted) participants[_tokenId][_account] = false;
        }

        if ((_adding && !isExisted) || (!_adding && isExisted))
            _emitEvent(_tokenId);
    }

    /////////////////////////
    //// Owner Functions ////
    /////////////////////////

    function setManager(address _adapter, bool _value) external onlyOwner {
        if (_value) emit ManagerAdded(_adapter);
        else emit ManagerRemoved(_adapter);

        managers[_adapter] = _value;
    }

    /////////////////////////
    /// Internal Functions //
    /////////////////////////

    function _emitEvent(uint256 _tokenId) internal {
        emit AdapterInfoUpdated(
            _tokenId,
            adapterInfo[_tokenId].participant,
            adapterInfo[_tokenId].traded,
            adapterInfo[_tokenId].profit
        );
    }
}

// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.8.4;

import "./Context.sol";

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
contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
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
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     */
    function _transferOwnership(address newOwner) internal {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.8.4;

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
contract Context {
    // Empty internal constructor, to prevent people from mistakenly deploying
    // an instance of this contract, which should be used via inheritance.
    constructor() {}

    function _msgSender() internal view returns (address) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}