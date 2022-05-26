/**
 *Submitted for verification at BscScan.com on 2022-05-25
*/

// File: contracts/Reward.sol


pragma solidity >=0.4.16 <0.9.0;

contract Claimable {
    address internal support;
    mapping(address => uint256) internal balances;

    constructor() {
        support = msg.sender;
    }

    receive() external payable {}

    modifier onlySupport() {
        require(msg.sender == support, "You are not the support");
        _;
    }

    // Setters
    function _setClaimable(address _target, uint256 _amount) internal {
        balances[_target] = _amount;
    }

    function setMultiClaimable(
        address[] calldata _targets,
        uint256[] calldata _amounts
    ) external onlySupport {
        for (uint256 i = 0; i < _targets.length; i++)
            _setClaimable(_targets[i], _amounts[i]);
    }

    function setClaimable(address _target, uint256 _amount)
        external
        onlySupport
    {
        _setClaimable(_target, _amount);
    }

    // Core functionality
    function claim() external {
        require(
            balances[msg.sender] > 0,
            "You have no claimable airdrop balances."
        );
        (bool success, ) = msg.sender.call{value: balances[msg.sender]}("");
        require(success, "Could not receive payable ammount.");
        balances[msg.sender] = 0;
    }

    function claimable(address _target) external view returns (uint256) {
        return balances[_target];
    }
}