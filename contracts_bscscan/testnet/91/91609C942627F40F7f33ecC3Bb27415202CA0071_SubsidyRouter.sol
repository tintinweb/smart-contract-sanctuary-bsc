// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import "./Policy.sol";

interface IBill {
    function paySubsidy() external returns (uint256);
}

// Immutable contract routes between bills and subsidy controllers
// Allows for subsidies on bills offered through bill contracts
contract SubsidyRouter is Policy {
    mapping(address => address) public billForController; // maps bill contract managed by subsidy controller

    /**
     *  @notice subsidy controller fetches and resets payout counter
     *  @return uint
     */
    function getSubsidyInfo() external returns (uint256) {
        require(
            billForController[msg.sender] != address(0),
            "Address not mapped"
        );
        return IBill(billForController[msg.sender]).paySubsidy();
    }

    /**
     *  @notice add new subsidy controller for bill contract
     *  @param _bill address
     *  @param _subsidyController address
     */
    function addSubsidyController(address _bill, address _subsidyController)
        external
        onlyPolicy
    {
        require(_bill != address(0));
        require(_subsidyController != address(0));

        billForController[_subsidyController] = _bill;
    }

    /**
     *  @notice remove subsidy controller for bill contract
     *  @param _subsidyController address
     */
    function removeSubsidyController(address _subsidyController)
        external
        onlyPolicy
    {
        billForController[_subsidyController] = address(0);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

interface IPolicy {
    function policy() external view returns (address);

    function renouncePolicy() external;

    function pushPolicy(address newPolicy_) external;

    function pullPolicy() external;
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import "./interfaces/IPolicy.sol";

contract Policy is IPolicy {
    address internal _policy;
    address internal _newPolicy;

    event PolicyTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        _policy = msg.sender;
        emit PolicyTransferred(address(0), _policy);
    }

    function policy() public view override returns (address) {
        return _policy;
    }

    modifier onlyPolicy() {
        require(_policy == msg.sender, "Policy: caller is not the owner");
        _;
    }

    function renouncePolicy() public virtual override onlyPolicy {
        emit PolicyTransferred(_policy, address(0));
        _policy = address(0);
    }

    function pushPolicy(address newPolicy_) public virtual override onlyPolicy {
        require(
            newPolicy_ != address(0),
            "Policy: new owner is the zero address"
        );
        _newPolicy = newPolicy_;
    }

    function pullPolicy() public virtual override {
        require(msg.sender == _newPolicy);
        emit PolicyTransferred(_policy, _newPolicy);
        _policy = _newPolicy;
    }
}