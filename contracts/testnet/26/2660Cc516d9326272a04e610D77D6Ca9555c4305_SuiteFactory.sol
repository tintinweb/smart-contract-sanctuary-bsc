pragma solidity ^0.7.6;

// SPDX-License-Identifier: Apache License 2.0

import "./Suite.sol";
import "./ISuiteList.sol";
import "../Common/IERC20.sol";

contract SuiteFactory is Ownable {
    ISuiteList public _suiteList;
    IERC20 public _commissionToken;
    uint256 public _commissionAmount;

    constructor(address token, uint256 amount) {
        _commissionToken = IERC20(token);
        _commissionAmount = amount;
    }

    event SuiteDeployed(
        string suiteName,
        address suiteAddress,
        address suiteOwner
    );

    function deploySuite(string memory suiteName) external returns (address) {
        require(
            _suiteList._whiteList() != address(0),
            "WhiteList address not defined"
        );
        require(bytes(suiteName).length > 0, "Parameter suiteName is null");
        require(
            _commissionToken.balanceOf(msg.sender) >= _commissionAmount,
            "You don't have enough commission tokens for the action"
        );
        require(
            _commissionToken.allowance(msg.sender, address(this)) >=
                _commissionAmount,
            "Not enough delegated commission tokens for the action"
        );
        require(
            _commissionToken.transferFrom(
                msg.sender,
                address(this),
                _commissionAmount
            ),
            "Transfer commission failed"
        );
        Suite _suite = new Suite(suiteName, _suiteList._whiteList());
        _suite.transferOwnership(msg.sender);
        emit SuiteDeployed(suiteName, address(_suite), msg.sender);
        _suiteList.addSuite(address(_suite), msg.sender);

        return address(_suite);
    }

    function setSuiteList(address suiteListAddress) external onlyOwner {
        _suiteList = ISuiteList(suiteListAddress);
    }

    function setCommission(uint256 amount) external onlyOwner {
        _commissionAmount = amount;
    }

    function setComissionToken(address token) external onlyOwner {
        _commissionToken = IERC20(token);
    }
}

pragma solidity ^0.7.6;

// SPDX-License-Identifier: Apache License 2.0

import "../Common/Ownable.sol";

contract WhiteList is Ownable {
    mapping(bytes32 => address) public _allowedFactories;

    function add(bytes32 factoryType, address factoryAddress)
        external
        onlyOwner
    {
        _allowedFactories[factoryType] = factoryAddress;
    }

    function remove(bytes32 factoryType) external onlyOwner {
        _allowedFactories[factoryType] = address(0);
    }
}

pragma solidity ^0.7.6;

// SPDX-License-Identifier: Apache License 2.0

import "../Common/Ownable.sol";
import "./WhiteList.sol";

contract Suite is Ownable {
    WhiteList public _whiteList;

    string public _suiteName;

    modifier onlyWhiteListed(bytes32 contractType) {
        require(
            _whiteList._allowedFactories(contractType) == msg.sender,
            "Caller should be in White List"
        );
        _;
    }

    mapping(bytes32 => address) public contracts;

    constructor(string memory suiteName, address whiteList) {
        _suiteName = suiteName;
        _whiteList = WhiteList(whiteList);
    }

    function addContract(bytes32 contractType, address contractAddress)
        external
        onlyWhiteListed(contractType)
    {
        contracts[contractType] = contractAddress;
    }
}

pragma solidity ^0.7.6;

// SPDX-License-Identifier: Apache License 2.0

interface ISuiteList {
    function addSuite(address suiteAddress, address suiteOwner) external;

    function deleteSuite(address suiteAddress) external;

    function getSuitePage(uint256 startIndex, uint256 count)
        external
        view
        returns (address[] memory);

    function setSuiteFactory(address factoryAddress) external;

    function _whiteList() external view returns (address);

    function changeSuiteOwner(address suiteAddress, address candidateAddress)
        external;

    function isSuiteOwner(address suiteAddress, address candidateAddress)
        external
        view
        returns (bool);
}

pragma solidity ^0.7.4;
// "SPDX-License-Identifier: Apache License 2.0"

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
abstract contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev The Ownable constructor sets the original `owner` of the contract to the sender
     * account.
     */
    constructor () {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    /**
     * @return the address of the owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(isOwner());
        _;
    }

    /**
     * @return true if `msg.sender` is the owner of the contract.
     */
    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }

    /**
     * @dev Allows the current owner to relinquish control of the contract.
     * @notice Renouncing to ownership will leave the contract without an owner.
     * It will not be possible to call the functions with the `onlyOwner`
     * modifier anymore.
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Allows the current owner to transfer control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0));
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

pragma solidity ^0.7.4;
// "SPDX-License-Identifier: MIT"

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}