// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.9;

import "./Policy.sol";

interface IBill {
    function paySubsidy() external returns (uint256);
}

// Immutable contract routes between bills and subsidy controllers
// Allows for subsidies on bills offered through bill contracts
contract SubsidyRouter is Policy {
    mapping(address => address) public billForController; // maps bill contract managed by subsidy controller

    event SetSubsidyController(address newController, address bill);
    event RemoveSubsidyController(address removedController, address bill);

    /**
     *  @notice subsidy controller fetches and resets payout counter
     *  @return uint
     */
    function paySubsidy() external returns (uint256) {
        address billAddress = billForController[msg.sender];
        require(
            billAddress != address(0),
            "Address not mapped"
        );
        return IBill(billAddress).paySubsidy();
    }

    /**
     *  @notice add new subsidy controller for bill contract
     *  @param _bill address
     *  @param _subsidyController address
     */
    function setSubsidyController(address _bill, address _subsidyController)
        external
        onlyPolicy
    {
        require(_bill != address(0), "Bill cannot address zero");
        require(_subsidyController != address(0), "Controller cannot address zero");

        billForController[_subsidyController] = _bill;
        emit SetSubsidyController(billForController[_subsidyController], _bill);
    }

    /**
     *  @notice remove subsidy controller for bill contract
     *  @param _subsidyController address
     */
    function removeSubsidyController(address _subsidyController)
        external
        onlyPolicy
    {
        emit RemoveSubsidyController(_subsidyController, billForController[_subsidyController]);
        billForController[_subsidyController] = address(0);
    }
}

// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.8.9;

interface IPolicy {
    function policy() external view returns (address);

    function renouncePolicy() external;

    function pushPolicy(address newPolicy_) external;

    function pullPolicy() external;
}

// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.8.9;

import "./interfaces/IPolicy.sol";

contract Policy is IPolicy {
    address internal _policy;
    address internal _newPolicy;

    event PolicyTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    event PolicyPushed(
        address indexed newPolicy
    );

    constructor() {
        _policy = msg.sender;
        emit PolicyTransferred(address(0), _policy);
    }

    function policy() public view override returns (address) {
        return _policy;
    }

    function newPolicy() public view returns (address) {
        return _newPolicy;
    }

    modifier onlyPolicy() {
        require(_policy == msg.sender, "Caller is not the owner");
        _;
    }

    function renouncePolicy() public virtual override onlyPolicy {
        emit PolicyTransferred(_policy, address(0));
        _policy = address(0);
        _newPolicy = address(0);
    }

    function pushPolicy(address newPolicy_) public virtual override onlyPolicy {
        require(
            newPolicy_ != address(0),
            "New owner is the zero address"
        );
        emit PolicyPushed(newPolicy_);
        _newPolicy = newPolicy_;
    }

    function pullPolicy() public virtual override {
        require(msg.sender == _newPolicy, "msg.sender is not new policy");
        emit PolicyTransferred(_policy, _newPolicy);
        _policy = _newPolicy;
    }
}