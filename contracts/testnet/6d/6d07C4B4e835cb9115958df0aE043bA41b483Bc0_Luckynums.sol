// SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

import "./SafeERC20.sol";

contract Luckynums {

    using SafeERC20 for IERC20;

    IERC20 private token;

    mapping(address => uint) private releaseTime;

    mapping(address => uint) private pledge;

    mapping(bytes32 => mapping(address => bool)) private roles;

    bytes32 private constant ADMIN = keccak256(abi.encode("ADMIN"));

    bytes32 private constant USER = keccak256(abi.encode("USER"));

    event GrantRole(bytes32 indexed role, address indexed account);

    event RevokeRole(bytes32 indexed role, address indexed account);

    event Launch(address account, uint amount, uint ReleaseTime);

    event Release(address account, uint amount);

    event Withdraw(address account, uint amount);

    event Log(string func, address sender, uint value, bytes data);

    modifier onlyRole(bytes32 _role) {
        require(roles[_role][msg.sender], "not authorized");
        _;
    }
   
    constructor(address _token) {
        token = IERC20(_token);
        _grantRole(ADMIN, msg.sender);
    }

    fallback() external payable {
        emit Log("fallback", msg.sender, msg.value, msg.data);
    }

    receive() external payable {
        emit Log("receive", msg.sender, msg.value, '');
    }

    function withdrawEth(address payable _to, uint _amount) external payable onlyRole(ADMIN) {
        bool success = _to.send(_amount);
        require(success, "send failed");
        emit Log("withdrawEth", _to, _amount, '');
    }

    function _grantRole(bytes32 _role, address _account) internal {
        roles[_role][_account] = true;
        emit GrantRole(_role, _account);
    }

    function grantRole(bytes32 _role, address _account) external onlyRole(ADMIN) {
        _grantRole(_role, _account);
    }

    function revokeRole(bytes32 _role, address _account) external onlyRole(ADMIN) {
        roles[_role][_account] = false;
        emit RevokeRole(_role, _account);
    }

    function setToken(IERC20 _token) external onlyRole(ADMIN) {
        token = _token;
    }

    function setReleaseTime(address _account, uint _releaseTime) external onlyRole(ADMIN) {
        require(_releaseTime > block.timestamp, "TokenTimelock: release time is before current time");
        releaseTime[_account] = _releaseTime;
    }

    function getReleaseTime(address _account) external view returns (uint) {
        return releaseTime[_account];
    }

    function getPledge(address _account) external view returns (uint) {
        return pledge[_account];
    }

    function getToken() external view returns (IERC20) {
        return token;
    }

    function getHash(string memory _str) external pure returns (bytes32) {
        return keccak256(abi.encode(_str));
    }

    function getAllowance(address _owner, address _spender) external view returns (uint) {
        return token.allowance(_owner, _spender);
    }
    
    function balanceOf(address _account) external view returns (uint){
        return token.balanceOf(_account);
    }

    function increase(address _spender, uint _num) external onlyRole(ADMIN) {
        token.safeIncreaseAllowance(_spender, _num); 
    }
    
    function decrease(address _spender, uint _num) external onlyRole(ADMIN) {
        token.safeDecreaseAllowance(_spender, _num);
    }

    function launch(uint _amount) external {
        require(_amount > 100000000, "minimum pledge 100 usdt");
        token.safeTransferFrom(msg.sender, address(this), _amount);
        pledge[msg.sender] += _amount;
        releaseTime[msg.sender] = block.timestamp + 30 days;
        emit Launch(msg.sender, _amount, releaseTime[msg.sender]);
    }

    function release(address _account) external {
        require(block.timestamp >= releaseTime[_account], "TokenTimelock: current time is before release time");
        uint256 amount = token.balanceOf(address(this));
        require(amount > (pledge[_account] * 101 / 100), "TokenTimelock: not enough tokens to release");
        token.safeTransfer(_account, pledge[_account] * 101 / 100);
        pledge[_account] = 0;
        emit Release(_account, pledge[_account] * 101 / 100);
    }

    function withdrawToken(address _account, uint _amount) external {
        require(token.allowance(address(this), _account) >= _amount, "transfer amount exceeds allowance");
        token.safeTransfer(_account, _amount);
        emit Withdraw(_account, _amount);
    }
}