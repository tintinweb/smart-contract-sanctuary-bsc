// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.8.4;

import "./libraries/Ownable.sol";
import "./interfaces/IAdapter.sol";

contract HedgepieAdapterManager is Ownable {
    struct AdapterInfo {
        address addr;
        string name;
        bool status;
    }

    // Info of each adapter
    AdapterInfo[] public adapterInfo;
    // investor address
    address public investor;

    event AdapterAdded(address strategy);
    event AdapterRemoveed(address strategy);

    /**
     * @notice Throws if adapter is not active
     */
    modifier onlyActiveAdapter(address _adapter) {
        bool isExisted = false;
        for (uint256 i = 0; i < adapterInfo.length; i++) {
            if (
                adapterInfo[i].addr == address(_adapter) &&
                adapterInfo[i].status
            ) {
                isExisted = true;
                break;
            }
        }
        require(isExisted, "Error: Adapter is not active");
        _;
    }

    /**
     * @notice Throws if called by any account other than the investor.
     */
    modifier onlyInvestor() {
        require(msg.sender == investor, "Error: caller is not investor");
        _;
    }

    /**
     * @notice Get a list of adapters
     */
    function getAdapters() external view returns (AdapterInfo[] memory) {
        return adapterInfo;
    }

    /**
     * @notice Get strategy address of adapter contract
     * @param _adapter  adapter address
     */
    function getAdapterStrat(address _adapter)
        external
        view
        onlyActiveAdapter(_adapter)
        returns (address adapterStrat)
    {
        adapterStrat = IAdapter(_adapter).strategy();
    }

    /**
     * @notice Get Deposit call data of adapter contract
     * @param _adapter  adapter address
     * @param _amount  deposit amount
     */
    function getDepositCallData(address _adapter, uint256 _amount)
        external
        view
        onlyActiveAdapter(_adapter)
        onlyInvestor
        returns (
            address to,
            uint256 value,
            bytes memory data
        )
    {
        require(_amount > 0, "Amount can not be 0");
        return IAdapter(_adapter).getInvestCallData(_amount);
    }

    /**
     * @notice Get Withdraw call data of adapter contract
     * @param _adapter  adapter address
     * @param _amount  deposit amount
     */
    function getWithdrawCallData(address _adapter, uint256 _amount)
        external
        view
        onlyActiveAdapter(_adapter)
        onlyInvestor
        returns (
            address to,
            uint256 value,
            bytes memory data
        )
    {
        require(_amount > 0, "Amount can not be 0");
        return IAdapter(_adapter).getDevestCallData(_amount);
    }

    // ===== Owner functions =====
    /**
     * @notice Add adapter
     * @param _adapter  adapter address
     */
    function addAdapter(address _adapter) external onlyOwner {
        require(_adapter != address(0), "Invalid adapter address");

        adapterInfo.push(
            AdapterInfo({
                addr: _adapter,
                name: IAdapter(_adapter).name(),
                status: true
            })
        );

        emit AdapterAdded(_adapter);
    }

    /**
     * @notice Remove adapter
     * @param _adapterId  adapter id
     * @param _status  adapter status
     */
    function setAdapter(uint256 _adapterId, bool _status) external onlyOwner {
        require(_adapterId < adapterInfo.length, "Invalid adapter address");

        adapterInfo[_adapterId].status = _status;
    }

    /**
     * @notice Set investor contract
     * @param _investor  investor address
     */
    function setInvestor(address _investor) external onlyOwner {
        require(_investor != address(0), "Invalid investor address");
        investor = _investor;
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

interface IAdapter {
    function getPaths() external view returns (address[][] memory);

    function stakingToken() external view returns (address);

    function poolID() external view returns (address);

    function strategy() external view returns (address strategy);

    function pendingReward() external view returns (uint256 reward);

    function name() external view returns (string memory);

    function repayToken() external view returns (address);

    function rewardToken() external view returns (address);

    function router() external view returns (address);

    function getAdapterStrategy(uint256 _adapter)
        external
        view
        returns (address strategy);

    function getWithdrawalAmount(address _user, uint256 _nftId)
        external
        view
        returns (uint256 amount);

    function getInvestCallData(uint256 _amount)
        external
        view
        returns (
            address to,
            uint256 value,
            bytes memory data
        );

    function getDevestCallData(uint256 _amount)
        external
        view
        returns (
            address to,
            uint256 value,
            bytes memory data
        );

    function getReward(address _user) external view returns (uint256);

    function increaseWithdrawalAmount(
        address _user,
        uint256 _nftId,
        uint256 _amount
    ) external;

    function setInvestor(address _investor) external;
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