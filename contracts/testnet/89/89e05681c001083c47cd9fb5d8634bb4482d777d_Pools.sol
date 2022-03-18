// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./ERC20.sol";
import "./Ownable.sol";
import "./SafeMath.sol";

contract Pools is Ownable {
    using SafeMath for uint256;

    uint256 private _currentPoolID;
    ERC20 public _busdContract;
    uint256[] private _poolsID;

    mapping(uint256 => uint256) public _poolsTotalAmount;
    mapping(uint256 => uint256) public _poolsCurrentAmount;
    mapping(uint256 => uint256) public _poolsTotalDistributeAmount;
    mapping(uint256 => uint256) public _poolsCurrentDistributeAmount;
    mapping(uint256 => uint256) public _poolsToDistributeAmount;
    mapping(uint256 => string) public _poolsName;
    mapping(uint256 => bool) public _poolsState;
    mapping(uint256 => mapping(address => uint256)) public _poolsUserAmount;
    mapping(uint256 => address[]) public _poolsUserAddress;

    constructor() {
        _currentPoolID = 0;
        _busdContract = ERC20(0xF5525bCf044834B5651AC061Cd8dc097e7Ca53Bf);
    }

    function getPoolsIDLength() external view returns (uint256) {
        return _poolsID.length;
    }

    function getPoolsIDByIndex(uint256 index) external view returns (uint256) {
        return _poolsID[index];
    }

    function getPoolsUserAmount(uint256 pool, address user)
        external
        view
        returns (uint256)
    {
        return _poolsUserAmount[pool][user];
    }

    function createPool(uint256 poolsTotalAmount, string memory poolsName)
        external
        onlyOwner
        returns (bool)
    {
        _createPool(poolsTotalAmount, poolsName);
        return true;
    }

    function _createPool(uint256 poolsTotalAmount, string memory poolsName)
        internal
        virtual
    {
        _poolsTotalAmount[_currentPoolID] = poolsTotalAmount;
        _poolsCurrentAmount[_currentPoolID] = 0;
        _poolsName[_currentPoolID] = poolsName;
        _poolsTotalDistributeAmount[_currentPoolID] = poolsTotalAmount * 2;
        _poolsCurrentDistributeAmount[_currentPoolID] = 0;
        _poolsToDistributeAmount[_currentPoolID] = 0;
        _poolsState[_currentPoolID] = true;
        _poolsID.push(_currentPoolID);
        _currentPoolID = _currentPoolID + 1;
    }

    function participatePool(uint256 _poolID, uint256 _userAmount)
        public
        returns (bool)
    {
        _participatePool(_msgSender(), _poolID, _userAmount);
        return true;
    }

    function _participatePool(
        address sender,
        uint256 _poolID,
        uint256 _userAmount
    ) internal {
        require(_poolID < _currentPoolID, "Pool ID do not exist");
        require(
            _poolsTotalAmount[_poolID] >=
                _poolsCurrentAmount[_poolID] + _userAmount
        );

        if (_poolsUserAmount[_poolID][sender] == 0) {
            _poolsUserAddress[_poolID].push(sender);
        }

        _busdContract.transferFrom(sender, address(this), _userAmount);
        _poolsUserAmount[_poolID][sender] =
            _poolsUserAmount[_poolID][sender] +
            _userAmount;
        _poolsCurrentAmount[_poolID] =
            _poolsCurrentAmount[_poolID] +
            _userAmount;
    }

    function leavePool(uint256 _poolID) public returns (bool) {
        _leavePool(_msgSender(), _poolID);
        return true;
    }

    function _leavePool(address sender, uint256 _poolID) internal {
        require(_poolID < _currentPoolID, "Pool ID do not exist");
        require(_poolsUserAmount[_poolID][sender] > 0);
        require(_poolsState[_poolID]);

        _busdContract.transferFrom(
            address(this),
            sender,
            _poolsUserAmount[_poolID][sender]
        );
        _poolsCurrentAmount[_poolID] =
            _poolsCurrentAmount[_poolID] -
            _poolsUserAmount[_poolID][sender];
        _poolsUserAmount[_poolID][sender] = 0;

        for (uint256 i = 0; i < _poolsUserAddress[_poolID].length; i++) {
            address userAddress = _poolsUserAddress[_poolID][i];

            if (userAddress == sender) {
                _poolsUserAddress[_poolID][i] = _poolsUserAddress[_poolID][
                    _poolsUserAddress[_poolID].length - 1
                ];
                _poolsUserAddress[_poolID].pop();
            }
        }
    }

    function insertRewardPool(uint256 _poolID, uint256 _userAmount)
        public
        onlyOwner
        returns (bool)
    {
        _insertRewardPool(_msgSender(), _poolID, _userAmount);
        return true;
    }

    function _insertRewardPool(
        address sender,
        uint256 _poolID,
        uint256 _userAmount
    ) internal {
        require(_poolID < _currentPoolID, "Pool ID do not exist");
        require(
            _poolsTotalDistributeAmount[_poolID] >=
                _poolsCurrentDistributeAmount[_poolID] + _userAmount
        );

        _busdContract.transferFrom(sender, address(this), _userAmount);
        _poolsToDistributeAmount[_poolID] =
            _poolsToDistributeAmount[_poolID] +
            _userAmount;
    }

    function distributePool(uint256 poolID) public onlyOwner returns (bool) {
        _distributePool(poolID);
        return true;
    }

    function _distributePool(uint256 poolID) internal {
        require(poolID < _currentPoolID, "Pool ID do not exist");

        for (uint256 i = 0; i < _poolsUserAddress[poolID].length; i++) {
            address userAddress = _poolsUserAddress[poolID][i];
            uint256 balance = (_poolsUserAmount[poolID][userAddress] * 100) /
                _poolsToDistributeAmount[poolID];

            _busdContract.transfer(userAddress, balance);
        }
        _poolsToDistributeAmount[poolID] = 0;
    }

    function changePoolState(uint256 pool, bool state)
        external
        onlyOwner
        returns (bool)
    {
        _changePoolState(pool, state);
        return true;
    }

    function _changePoolState(uint256 pool, bool state) internal {
        _poolsState[pool] = state;
    }
}