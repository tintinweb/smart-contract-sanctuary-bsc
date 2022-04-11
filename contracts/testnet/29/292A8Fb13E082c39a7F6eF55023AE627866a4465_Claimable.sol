/**
 *Submitted for verification at BscScan.com on 2022-04-11
*/

// File: contracts/Claimable.sol


pragma solidity >=0.4.16 <0.9.0;

interface Peach {
    function lockAndSend(address _to, uint256 _amount) external;
}

contract Claimable {
    address payable internal support;
    mapping(address => uint256) internal locked;
    Peach internal peach;

    constructor(address _peachAddress) {
        support = payable(msg.sender);
        peach = Peach(_peachAddress);
    }

    modifier onlySupport() {
        require(msg.sender == support, "You are not the support");
        _;
    }

    // Setters
    function _setClaimable(address _target, uint256 _amount) internal {
        locked[_target] = _amount;
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
    function claim() external payable {
        require(
            locked[msg.sender] > 0,
            "You have no claimable airdrop balance."
        );
        require(msg.value >= 10**15, "Please send at least 0.001 BNB.");
        (bool success, ) = support.call{value: msg.value}("");
        require(success, "Could not receive payable ammount.");
        peach.lockAndSend(msg.sender, locked[msg.sender]);
        locked[msg.sender] = 0;
    }
}