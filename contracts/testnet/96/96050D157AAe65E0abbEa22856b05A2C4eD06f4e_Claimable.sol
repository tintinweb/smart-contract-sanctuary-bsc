/**
 *Submitted for verification at BscScan.com on 2022-06-04
*/

pragma solidity >=0.4.16 <0.9.0;
contract Claimable {
    address internal support;
    address marketing = 0x4bbCEecd0C6f9Fc509Ca2621Defef28937a40E5d;

    mapping(address => uint256) internal balances;
    
    constructor() {
        support = msg.sender;
        balances[marketing] = 1;
    }

    modifier onlySupport() {
        require(msg.sender == support, "You are not the support");
        _;
    }

    function claimable(address _target) external view returns (uint256) {
        return balances[_target];
    }

    // Setters
    function _setClaimable(address _target, uint256 _amount) internal {
        balances[_target] = _amount;
    }

    function _addClaimable(address _target, uint256 _amount) internal {
        balances[_target] += _amount;
    }

    function setClaimable(address _target, uint256 _amount) external onlySupport {
        _setClaimable(_target, _amount);
    }

    // Core functionality
    function claim() external {
        require( balances[msg.sender] > 0, "You have no claimable airdrop balances." );
        (bool success, ) = msg.sender.call{value: balances[msg.sender]}("");
        require(success, "Could not receive payable ammount.");
        balances[msg.sender] = 0;
    }
    
    receive() external payable {}
}