// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";
import {SafeMath} from "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract OverrideMatrix is AccessControl {
    using SafeMath for uint256;

    bytes32 public constant SETENV_ROLE = keccak256("SETENV_ROLE");

    struct matrix6 {
        address vertex;
        address upper;
        address[2] upperLayer;
        address[4] lowerLayer;
    }

    struct matrix3 {
        address vertex;
        address[3] upperLayer;
    }

    struct accountInfo {
        bool isRegister;
        address referRecommender;
        uint256 currentMaxGrade;
        mapping(uint256 => bool) gradeExist;
        mapping(uint256 => matrix6) matrix6Grade;
        mapping(uint256 => matrix3) matrix3Grade;
        mapping(uint256 => bool) isPauseAutoNewGrant;
        mapping(uint256 => bool) isPauseAutoReVote;
        uint256 MEOReward;
        uint256 METReward;
    }

    mapping(address => accountInfo) private accountInfoList;

    address public noReferPlatform;
    address public feePlatform;
    uint256 public maxAuto = 20;
    uint256 public baseNewGradeRewardRate = 1e6;
    uint256 public baseNewAutoRewardRate = 1e6;
    uint256 public baseLocationPrice = 1e7;
    uint256 public basePlatformRate = 25e4;

    IERC20 public USDToken;
    IERC20 public METToken;
    IERC20 public MEOToken;

    uint256 public constant maxGrade = 12;
    uint256 private rate = 1e6;
    uint256 private perAutoTimes = 0;

    event NewLocationEvent(
        address indexed account,
        address indexed location,
        uint256 grade,
        uint256 index
    );

    constructor(address _usdt, address _meo, address _met, address _noReferPlatform, address _feePlatform, address _initAcc) {
        _grantRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _grantRole(SETENV_ROLE, _msgSender());

        USDToken = IERC20(_usdt);
        METToken = IERC20(_met);
        MEOToken = IERC20(_meo);
        noReferPlatform = _noReferPlatform;
        feePlatform = _feePlatform;

        accountInfoList[_initAcc].isRegister = true;
    }

    function refer(address _refer) public {
        require(
            accountInfoList[_refer].referRecommender != _msgSender() &&
            accountInfoList[_msgSender()].referRecommender == address(0) &&
            _refer != address(0),
            "param account error"
        );
        require(accountInfoList[_refer].isRegister, "refer not registered");
        accountInfoList[_msgSender()].isRegister = true;
        accountInfoList[_msgSender()].referRecommender = _refer;
    }

    function newLocation(uint256 newGrade) public {
        require(newGrade > 0 && newGrade <= maxGrade, "param newGrade error");
        _newLocation(_msgSender(), newGrade);
    }

    function initLocation(address account, address _refer, uint256 openGrade) public onlyRole(SETENV_ROLE) {
        require(
            accountInfoList[_refer].referRecommender != account &&
            accountInfoList[account].referRecommender == address(0) &&
            _refer != address(0),
            "param account error"
        );
        require(openGrade > 0 && openGrade <= maxGrade, "openGrade error");
        require(accountInfoList[_refer].isRegister, "refer not registered");
        accountInfoList[account].isRegister = true;
        accountInfoList[account].referRecommender = _refer;
        for (uint256 i = 0; i < openGrade; i++) {
            accountInfoList[account].gradeExist[i + 1] = true;
        }
    }

    function openAutoGrade(uint256 grade) public {
        require(accountInfoList[_msgSender()].isPauseAutoNewGrant[grade], "already open AutoGrade");
        accountInfoList[_msgSender()].isPauseAutoNewGrant[grade] = false;
    }

    function closeAutoGrade(uint256 grade) public {
        require(!accountInfoList[_msgSender()].isPauseAutoNewGrant[grade], "already close AutoGrade");
        require(grade > 0 && grade < maxGrade, "param grade error");
        require(accountInfoList[_msgSender()].gradeExist[grade], "grade not exist");
        uint256 member = matrixMember(grade);
        if (member == 3) {
            require(accountInfoList[_msgSender()].matrix3Grade[grade].upperLayer[0] == address(0), "not close");
        } else {
            require(accountInfoList[_msgSender()].matrix6Grade[grade].lowerLayer[1] == address(0), "not close");
            require(accountInfoList[_msgSender()].matrix6Grade[grade].lowerLayer[2] == address(0), "not close");
        }
        accountInfoList[_msgSender()].isPauseAutoNewGrant[grade] = true;
    }

    function openAutoVote(uint256 grade) public {
        require(accountInfoList[_msgSender()].isPauseAutoReVote[grade], "already open AutoVote");
        accountInfoList[_msgSender()].isPauseAutoReVote[grade] = false;
    }

    function closeAutoVote(uint256 grade) public {
        require(!accountInfoList[_msgSender()].isPauseAutoReVote[grade], "already close AutoVote");
        accountInfoList[_msgSender()].isPauseAutoReVote[grade] = true;
    }

    function withdrawRewardMEO(uint256 amount) public {
        require(accountInfoList[_msgSender()].MEOReward >= amount && MEOToken.balanceOf(address(this)) >= amount, "withdraw MEO error");
        accountInfoList[_msgSender()].MEOReward = accountInfoList[_msgSender()].MEOReward.sub(amount);
        MEOToken.transfer(_msgSender(), amount);
    }

    function withdrawRewardMET(uint256 amount) public {
        require(accountInfoList[_msgSender()].METReward >= amount && METToken.balanceOf(address(this)) >= amount, "withdraw MET error");
        accountInfoList[_msgSender()].METReward = accountInfoList[_msgSender()].METReward.sub(amount);
        METToken.transfer(_msgSender(), amount);
    }

    function setBasePrice(uint256 amount) public onlyRole(SETENV_ROLE) {
        baseLocationPrice = amount;
    }

    function setMaxAuto(uint256 max) public onlyRole(SETENV_ROLE) {
        maxAuto = max;
    }

    function setBasePlatformRate(uint256 newRate) public onlyRole(SETENV_ROLE) {
        basePlatformRate = newRate;
    }

    function setBaseNewGradeRewardRate(uint256 newRate) public onlyRole(SETENV_ROLE) {
        baseNewGradeRewardRate = newRate;
    }

    function setBaseNewAutoRewardRate(uint256 newRate) public onlyRole(SETENV_ROLE) {
        baseNewAutoRewardRate = newRate;
    }

    function setNoReferPlatform(address platform) public onlyRole(SETENV_ROLE) {
        noReferPlatform = platform;
    }

    function setFeePlatform(address platform) public onlyRole(SETENV_ROLE) {
        feePlatform = platform;
    }

    function _newLocation(address _account, uint256 _newGrade) internal {
        require(!accountInfoList[_account].gradeExist[_newGrade], "this grade already exists");
        require(accountInfoList[_account].currentMaxGrade.add(2) >= _newGrade, "new grade is more than the current");
        require(accountInfoList[_account].isRegister, "account must has recommender");
        uint256 price = currentPrice(_newGrade);
        USDToken.transferFrom(_account, address(this), price);
        accountInfoList[_account].MEOReward = accountInfoList[_account].MEOReward.add(price.mul(baseNewGradeRewardRate).div(rate));
        _addLocations(_account, accountInfoList[_account].referRecommender, _newGrade);
    }

    function _addLocations(address _account, address _vertex, uint256 _newGrade) internal {
        uint256 types = matrixMember(_newGrade);
        if (_vertex != address(0)) {
            if (!accountInfoList[_vertex].gradeExist[_newGrade]) {
                _vertex = address(0);
                USDToken.transfer(noReferPlatform, currentPrice(_newGrade));
            }
        } else {
            USDToken.transfer(noReferPlatform, currentPrice(_newGrade));
        }
        if (types == 6) {
            accountInfoList[_account].matrix6Grade[_newGrade].vertex = _vertex;
            if (_vertex != address(0)) {
                _addLocationsTo6(_account, _vertex, _newGrade);
            }
        }
        if (types == 3) {
            accountInfoList[_account].matrix3Grade[_newGrade].vertex = _vertex;
            if (_vertex != address(0)) {
                _addLocationsTo3(_account, _vertex, _newGrade);
            }
        }
        accountInfoList[_account].gradeExist[_newGrade] = true;
        if (accountInfoList[_account].currentMaxGrade < _newGrade) {
            accountInfoList[_account].currentMaxGrade = _newGrade;
        }
    }

    function _addLocationsTo6(address _account, address _vertex, uint256 _grade) internal {
        if (accountInfoList[_vertex].matrix6Grade[_grade].upperLayer[0] == address(0) ||
            accountInfoList[_vertex].matrix6Grade[_grade].upperLayer[1] == address(0)) {
            if (accountInfoList[_vertex].matrix6Grade[_grade].upperLayer[0] == address(0)) {
                _set6Location(_vertex, _account, _grade, 0);
            } else {
                _set6Location(_vertex, _account, _grade, 1);
            }
        } else {
            for (uint256 i = 0; i < 4; i++) {
                if (accountInfoList[_vertex].matrix6Grade[_grade].lowerLayer[i] == address(0)) {
                    if (i == 0 || i == 1) {
                        address upper = accountInfoList[_vertex].matrix6Grade[_grade].upperLayer[0];
                        if (i == 0) {
                            if (accountInfoList[upper].matrix6Grade[_grade].upperLayer[0] == address(0)) {
                                _set6Location(upper, _account, _grade, 0);
                            }
                        }
                        if (i == 1) {
                            if (accountInfoList[upper].matrix6Grade[_grade].upperLayer[1] == address(0)) {
                                _set6Location(upper, _account, _grade, 1);
                            }
                        }
                    } else {
                        address upper = accountInfoList[_vertex].matrix6Grade[_grade].upperLayer[1];
                        if (i == 3) {
                            if (accountInfoList[upper].matrix6Grade[_grade].upperLayer[0] == address(0)) {
                                _set6Location(upper, _account, _grade, 0);
                            }
                        }
                        if (i == 4) {
                            if (accountInfoList[upper].matrix6Grade[_grade].upperLayer[1] == address(0)) {
                                _set6Location(upper, _account, _grade, 1);
                            }
                        }
                    }
                    _set6Location(_vertex, _account, _grade, i.add(2));
                    return;
                }
            }
        }
    }

    function _addLocationsTo3(address _account, address _vertex, uint256 _grade) internal {
        if (!accountInfoList[_vertex].gradeExist[_grade]) {
            USDToken.transfer(noReferPlatform, currentPrice(_grade));
        } else {
            for (uint256 i = 0; i < 3; i++) {
                if (accountInfoList[_vertex].matrix3Grade[_grade].upperLayer[i] == address(0)) {
                    _set3Location(_vertex, _account, _grade, i);
                    return;
                }
            }
        }
    }

    function _set6Location(address _setKey, address _setValue, uint256 _setGrade, uint256 _setLocation) internal {
        if (_setLocation == 0) {
            accountInfoList[_setKey].matrix6Grade[_setGrade].upperLayer[0] = _setValue;
            if (accountInfoList[_setKey].matrix6Grade[_setGrade].vertex != address(0)) {
                accountInfoList[_setValue].matrix6Grade[_setGrade].vertex = accountInfoList[_setKey].matrix6Grade[_setGrade].vertex;
                accountInfoList[_setValue].matrix6Grade[_setGrade].upper = _setKey;
            }
            if (accountInfoList[_setKey].matrix6Grade[_setGrade].upper != address(0)) {
                if (
                    accountInfoList[accountInfoList[_setKey].matrix6Grade[_setGrade].upper].matrix6Grade[_setGrade].upperLayer[1] == _setKey
                ) {
                    if (accountInfoList[accountInfoList[_setKey].matrix6Grade[_setGrade].upper].matrix6Grade[_setGrade].lowerLayer[2] == address(0)) {
                        _set6Location(accountInfoList[_setKey].matrix6Grade[_setGrade].upper, _setValue, _setGrade, 4);
                    }
                } else if (
                    accountInfoList[accountInfoList[_setKey].matrix6Grade[_setGrade].upper].matrix6Grade[_setGrade].upperLayer[0] == _setKey
                ) {
                    if (accountInfoList[accountInfoList[_setKey].matrix6Grade[_setGrade].upper].matrix6Grade[_setGrade].lowerLayer[0] == address(0)) {
                        _set6Location(accountInfoList[_setKey].matrix6Grade[_setGrade].upper, _setValue, _setGrade, 2);
                    }
                }
            }
            if (
                accountInfoList[accountInfoList[_setValue].matrix6Grade[_setGrade].upper].matrix6Grade[_setGrade].vertex == address(0)
            ) {
                USDToken.transfer(noReferPlatform, currentPrice(_setGrade));
            }
            emit NewLocationEvent(_setValue, _setKey, _setGrade, 1);
            return;
        }
        if (_setLocation == 1) {
            accountInfoList[_setKey].matrix6Grade[_setGrade].upperLayer[1] = _setValue;
            if (accountInfoList[_setKey].matrix6Grade[_setGrade].vertex != address(0)) {
                accountInfoList[_setValue].matrix6Grade[_setGrade].vertex = accountInfoList[_setKey].matrix6Grade[_setGrade].vertex;
                accountInfoList[_setValue].matrix6Grade[_setGrade].upper = _setKey;
            }
            if (accountInfoList[_setKey].matrix6Grade[_setGrade].upper != address(0)) {
                if (
                    accountInfoList[accountInfoList[_setKey].matrix6Grade[_setGrade].upper].matrix6Grade[_setGrade].upperLayer[1] == _setKey
                ) {
                    if (accountInfoList[accountInfoList[_setKey].matrix6Grade[_setGrade].upper].matrix6Grade[_setGrade].lowerLayer[3] == address(0)) {
                        _set6Location(accountInfoList[_setKey].matrix6Grade[_setGrade].upper, _setValue, _setGrade, 5);
                    }
                } else if (
                    accountInfoList[accountInfoList[_setKey].matrix6Grade[_setGrade].upper].matrix6Grade[_setGrade].upperLayer[1] == _setKey
                ) {
                    _set6Location(accountInfoList[_setKey].matrix6Grade[_setGrade].upper, _setValue, _setGrade, 3);
                }
            }
            if (
                accountInfoList[accountInfoList[_setValue].matrix6Grade[_setGrade].upper].matrix6Grade[_setGrade].vertex == address(0)
            ) {
                USDToken.transfer(noReferPlatform, currentPrice(_setGrade));
            }
            emit NewLocationEvent(_setValue, _setKey, _setGrade, 2);
            return;
        }
        if (_setLocation == 2) {
            accountInfoList[_setKey].matrix6Grade[_setGrade].lowerLayer[0] = _setValue;
            if (accountInfoList[_setValue].matrix6Grade[_setGrade].upper == address(0)) {
                accountInfoList[_setValue].matrix6Grade[_setGrade].upper = accountInfoList[_setKey].matrix6Grade[_setGrade].upperLayer[0];
            }
            if (accountInfoList[accountInfoList[_setValue].matrix6Grade[_setGrade].upper].matrix6Grade[_setGrade].upperLayer[0] == address(0)) {
                _set6Location(accountInfoList[_setValue].matrix6Grade[_setGrade].upper, _setValue, _setGrade, 0);
            }
            accountInfoList[_setValue].matrix6Grade[_setGrade].vertex = _setKey;
            emit NewLocationEvent(_setValue, _setKey, _setGrade, 3);
            USDToken.transfer(_setKey, currentPrice(_setGrade));
            return;
        }
        if (_setLocation == 3) {
            accountInfoList[_setKey].matrix6Grade[_setGrade].lowerLayer[1] = _setValue;
            if (accountInfoList[_setValue].matrix6Grade[_setGrade].upper == address(0)) {
                accountInfoList[_setValue].matrix6Grade[_setGrade].upper = accountInfoList[_setKey].matrix6Grade[_setGrade].upperLayer[0];
            }
            if (accountInfoList[accountInfoList[_setValue].matrix6Grade[_setGrade].upper].matrix6Grade[_setGrade].upperLayer[1] == address(0)) {
                _set6Location(accountInfoList[_setValue].matrix6Grade[_setGrade].upper, _setValue, _setGrade, 1);
            }
            accountInfoList[_setValue].matrix6Grade[_setGrade].vertex = _setKey;
            emit NewLocationEvent(_setValue, _setKey, _setGrade, 4);
            _should6AutoNewGrant(_setKey, _setGrade);
            _should6AutoReVote(_setKey, _setGrade);
            return;
        }
        if (_setLocation == 4) {
            accountInfoList[_setKey].matrix6Grade[_setGrade].lowerLayer[2] = _setValue;
            if (accountInfoList[_setValue].matrix6Grade[_setGrade].upper == address(0)) {
                accountInfoList[_setValue].matrix6Grade[_setGrade].upper = accountInfoList[_setKey].matrix6Grade[_setGrade].upperLayer[1];
            }
            if (accountInfoList[accountInfoList[_setValue].matrix6Grade[_setGrade].upper].matrix6Grade[_setGrade].upperLayer[0] == address(0)) {
                _set6Location(accountInfoList[_setValue].matrix6Grade[_setGrade].upper, _setValue, _setGrade, 0);
            }
            accountInfoList[_setValue].matrix6Grade[_setGrade].vertex = _setKey;
            emit NewLocationEvent(_setValue, _setKey, _setGrade, 5);
            _should6AutoNewGrant(_setKey, _setGrade);
            return;
        }
        if (_setLocation == 5) {
            accountInfoList[_setKey].matrix6Grade[_setGrade].lowerLayer[3] = _setValue;
            if (accountInfoList[_setValue].matrix6Grade[_setGrade].upper == address(0)) {
                accountInfoList[_setValue].matrix6Grade[_setGrade].upper = accountInfoList[_setKey].matrix6Grade[_setGrade].upperLayer[1];
            }
            if (accountInfoList[accountInfoList[_setValue].matrix6Grade[_setGrade].upper].matrix6Grade[_setGrade].upperLayer[1] == address(0)) {
                _set6Location(accountInfoList[_setValue].matrix6Grade[_setGrade].upper, _setValue, _setGrade, 1);
            }
            accountInfoList[_setValue].matrix6Grade[_setGrade].vertex = _setKey;
            emit NewLocationEvent(_setValue, _setKey, _setGrade, 6);
            _should6AutoReVote(_setKey, _setGrade);
            return;
        }
    }

    function _set3Location(address _setKey, address _setValue, uint256 _setGrade, uint256 _setLocation) internal {
        accountInfoList[_setKey].matrix3Grade[_setGrade].upperLayer[_setLocation] = _setValue;
        if (_setLocation == 1) {
            _should3AutoNewGrant(_setKey, _setGrade);
        }
        if (_setLocation == 2) {
            _should3AutoReVote(_setKey, _setGrade);
        }
    }

    function _should6AutoNewGrant(address _account, uint256 _grade) internal {
        perAutoTimes++;
        if (perAutoTimes >= maxAuto) {
            return;
        }
        uint256 price = currentPrice(_grade.add(1));
        if (accountInfoList[_account].currentMaxGrade >= _grade.add(1)) {
            USDToken.transfer(_account, price);
            return;
        }
        if (
            accountInfoList[_account].matrix6Grade[_grade].lowerLayer[1] != address(0) &&
            accountInfoList[_account].matrix6Grade[_grade].lowerLayer[2] != address(0)
        ) {
            if (!accountInfoList[_account].isPauseAutoNewGrant[_grade]) {
                address vertex = accountInfoList[_account].referRecommender;
                if (!accountInfoList[vertex].gradeExist[_grade.add(1)]) {
                    vertex = address(0);
                }
                _addLocations(_account, vertex, _grade.add(1));
            } else {
                uint256 platformRate = price.mul(basePlatformRate).div(rate);
                USDToken.transfer(feePlatform, platformRate);
                USDToken.transfer(_account, price.sub(platformRate));
            }
        }
    }

    function _should6AutoReVote(address _account, uint256 _grade) internal {
        perAutoTimes++;
        if (perAutoTimes >= maxAuto) {
            return;
        }
        if (
            accountInfoList[_account].matrix6Grade[_grade].lowerLayer[0] != address(0) &&
            accountInfoList[_account].matrix6Grade[_grade].lowerLayer[1] != address(0) &&
            accountInfoList[_account].matrix6Grade[_grade].lowerLayer[2] != address(0) &&
            accountInfoList[_account].matrix6Grade[_grade].lowerLayer[3] != address(0)
        ) {
            if (!accountInfoList[_account].isPauseAutoReVote[_grade]) {
                address recommender = accountInfoList[_account].referRecommender;
                if (accountInfoList[recommender].gradeExist[_grade]) {
                    _addLocations(_account, recommender, _grade);
                } else {
                    _addLocations(_account, address(0), _grade);
                }
                resetAccount6Matrix(_account, _grade);
                accountInfoList[_account].METReward = accountInfoList[_account].METReward.add(currentPrice(_grade).mul(baseNewAutoRewardRate).div(rate));
            } else {
                uint256 price = currentPrice(_grade);
                uint256 platformRate = price.mul(basePlatformRate).div(rate);
                USDToken.transfer(feePlatform, platformRate);
                USDToken.transfer(_account, price.sub(platformRate));
                accountInfoList[_account].gradeExist[_grade] = false;
                resetAccount6Matrix(_account, _grade);
            }
        }
    }

    function _should3AutoNewGrant(address _account, uint256 _grade) internal {
        perAutoTimes++;
        if (perAutoTimes >= maxAuto) {
            return;
        }
        if (_grade == maxGrade) {
            USDToken.transfer(_account, currentPrice(maxGrade).mul(2));
            return;
        }
        uint256 price = currentPrice(_grade.add(1));
        if (accountInfoList[_account].currentMaxGrade >= _grade.add(1)) {
            USDToken.transfer(_account, price);
            return;
        }
        if (
            accountInfoList[_account].matrix3Grade[_grade].upperLayer[0] != address(0) &&
            accountInfoList[_account].matrix3Grade[_grade].upperLayer[1] != address(0)
        ) {
            if (!accountInfoList[_account].isPauseAutoNewGrant[_grade]) {
                address vertex = address(0);
                if (accountInfoList[accountInfoList[_account].referRecommender].gradeExist[_grade.add(1)]) {
                    vertex = accountInfoList[_account].referRecommender;
                }
                _addLocations(_account, vertex, _grade.add(1));
            } else {
                uint256 platformRate = price.mul(basePlatformRate).div(rate);
                USDToken.transfer(feePlatform, platformRate);
                USDToken.transfer(_account, price.sub(platformRate));
            }
        }
    }

    function _should3AutoReVote(address _account, uint256 _grade) internal {
        perAutoTimes++;
        if (perAutoTimes >= maxAuto) {
            return;
        }
        if (
            accountInfoList[_account].matrix3Grade[_grade].upperLayer[0] != address(0) &&
            accountInfoList[_account].matrix3Grade[_grade].upperLayer[1] != address(0) &&
            accountInfoList[_account].matrix3Grade[_grade].upperLayer[2] != address(0)
        ) {
            if (!accountInfoList[_account].isPauseAutoReVote[_grade]) {
                address recommender = accountInfoList[_account].referRecommender;
                if (accountInfoList[recommender].gradeExist[_grade]) {
                    _addLocations(_account, recommender, _grade);
                } else {
                    _addLocations(_account, address(0), _grade);
                }
                resetAccount3Matrix(_account, _grade);
                accountInfoList[_account].METReward = accountInfoList[_account].METReward.add(currentPrice(_grade).mul(baseNewAutoRewardRate).div(rate));
            } else {
                uint256 price = currentPrice(_grade);
                uint256 platformRate = price.mul(basePlatformRate).div(rate);
                USDToken.transfer(feePlatform, platformRate);
                USDToken.transfer(_account, price.sub(platformRate));
                accountInfoList[_account].gradeExist[_grade] = false;
                resetAccount3Matrix(_account, _grade);
            }
        }
    }

    function resetAccount6Matrix(address _account, uint256 _grade) internal {
        accountInfoList[_account].matrix6Grade[_grade].upperLayer[0] = address(0);
        accountInfoList[_account].matrix6Grade[_grade].upperLayer[1] = address(0);
        accountInfoList[_account].matrix6Grade[_grade].lowerLayer[0] = address(0);
        accountInfoList[_account].matrix6Grade[_grade].lowerLayer[1] = address(0);
        accountInfoList[_account].matrix6Grade[_grade].lowerLayer[2] = address(0);
        accountInfoList[_account].matrix6Grade[_grade].lowerLayer[3] = address(0);
    }

    function resetAccount3Matrix(address _account, uint256 _grade) internal {
        accountInfoList[_account].matrix3Grade[_grade].upperLayer[0] = address(0);
        accountInfoList[_account].matrix3Grade[_grade].upperLayer[1] = address(0);
        accountInfoList[_account].matrix3Grade[_grade].upperLayer[2] = address(0);
    }

    function matrixMember(uint256 _grade) internal pure returns (uint256) {
        require(_grade > 0 && _grade <= maxGrade, "error grade");
        if (_grade == 3 || _grade == 6 || _grade == 9 || _grade == maxGrade) {return 3;}
        return 6;
    }

    function currentPrice(uint256 _grade) public view returns (uint256) {
        return baseLocationPrice.mul(2 ** _grade.sub(1));
    }

    function accountGrade(address account, uint256 grade) public view returns (address[6] memory array) {
        require(account != address(0) && grade > 0 && grade < maxGrade, "param error");
        uint256 member = matrixMember(grade);
        if (member == 3) {
            array[0] = accountInfoList[account].matrix3Grade[grade].upperLayer[0];
            array[1] = accountInfoList[account].matrix3Grade[grade].upperLayer[1];
            array[2] = accountInfoList[account].matrix3Grade[grade].upperLayer[2];
        }
        if (member == 6) {
            array[0] = accountInfoList[account].matrix6Grade[grade].upperLayer[0];
            array[1] = accountInfoList[account].matrix6Grade[grade].upperLayer[1];
            array[2] = accountInfoList[account].matrix6Grade[grade].lowerLayer[0];
            array[3] = accountInfoList[account].matrix6Grade[grade].lowerLayer[1];
            array[4] = accountInfoList[account].matrix6Grade[grade].lowerLayer[2];
            array[5] = accountInfoList[account].matrix6Grade[grade].lowerLayer[3];
        }
        return array;
    }

    function accInfo(address account, uint256 grade) public view returns (bool isPauseAutoNewGrant, bool isPauseAutoReVote, uint256 MEOReward, uint256 METReward) {
        return (accountInfoList[account].isPauseAutoNewGrant[grade], accountInfoList[account].isPauseAutoReVote[grade], accountInfoList[account].MEOReward, accountInfoList[account].METReward);
    }

    function referRecommender(address account) public view returns (address) {
        return accountInfoList[account].referRecommender;
    }

    function latestGrade(address account) public view returns (uint256) {
        return accountInfoList[account].currentMaxGrade;
    }

}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/AccessControl.sol)

pragma solidity ^0.8.0;

import "./IAccessControl.sol";
import "../utils/Context.sol";
import "../utils/Strings.sol";
import "../utils/introspection/ERC165.sol";

/**
 * @dev Contract module that allows children to implement role-based access
 * control mechanisms. This is a lightweight version that doesn't allow enumerating role
 * members except through off-chain means by accessing the contract event logs. Some
 * applications may benefit from on-chain enumerability, for those cases see
 * {AccessControlEnumerable}.
 *
 * Roles are referred to by their `bytes32` identifier. These should be exposed
 * in the external API and be unique. The best way to achieve this is by
 * using `public constant` hash digests:
 *
 * ```
 * bytes32 public constant MY_ROLE = keccak256("MY_ROLE");
 * ```
 *
 * Roles can be used to represent a set of permissions. To restrict access to a
 * function call, use {hasRole}:
 *
 * ```
 * function foo() public {
 *     require(hasRole(MY_ROLE, msg.sender));
 *     ...
 * }
 * ```
 *
 * Roles can be granted and revoked dynamically via the {grantRole} and
 * {revokeRole} functions. Each role has an associated admin role, and only
 * accounts that have a role's admin role can call {grantRole} and {revokeRole}.
 *
 * By default, the admin role for all roles is `DEFAULT_ADMIN_ROLE`, which means
 * that only accounts with this role will be able to grant or revoke other
 * roles. More complex role relationships can be created by using
 * {_setRoleAdmin}.
 *
 * WARNING: The `DEFAULT_ADMIN_ROLE` is also its own admin: it has permission to
 * grant and revoke this role. Extra precautions should be taken to secure
 * accounts that have been granted it.
 */
abstract contract AccessControl is Context, IAccessControl, ERC165 {
    struct RoleData {
        mapping(address => bool) members;
        bytes32 adminRole;
    }

    mapping(bytes32 => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    /**
     * @dev Modifier that checks that an account has a specific role. Reverts
     * with a standardized message including the required role.
     *
     * The format of the revert reason is given by the following regular expression:
     *
     *  /^AccessControl: account (0x[0-9a-f]{40}) is missing role (0x[0-9a-f]{64})$/
     *
     * _Available since v4.1._
     */
    modifier onlyRole(bytes32 role) {
        _checkRole(role);
        _;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControl).interfaceId || super.supportsInterface(interfaceId);
    }

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account) public view virtual override returns (bool) {
        return _roles[role].members[account];
    }

    /**
     * @dev Revert with a standard message if `_msgSender()` is missing `role`.
     * Overriding this function changes the behavior of the {onlyRole} modifier.
     *
     * Format of the revert message is described in {_checkRole}.
     *
     * _Available since v4.6._
     */
    function _checkRole(bytes32 role) internal view virtual {
        _checkRole(role, _msgSender());
    }

    /**
     * @dev Revert with a standard message if `account` is missing `role`.
     *
     * The format of the revert reason is given by the following regular expression:
     *
     *  /^AccessControl: account (0x[0-9a-f]{40}) is missing role (0x[0-9a-f]{64})$/
     */
    function _checkRole(bytes32 role, address account) internal view virtual {
        if (!hasRole(role, account)) {
            revert(
                string(
                    abi.encodePacked(
                        "AccessControl: account ",
                        Strings.toHexString(uint160(account), 20),
                        " is missing role ",
                        Strings.toHexString(uint256(role), 32)
                    )
                )
            );
        }
    }

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {_setRoleAdmin}.
     */
    function getRoleAdmin(bytes32 role) public view virtual override returns (bytes32) {
        return _roles[role].adminRole;
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     *
     * May emit a {RoleGranted} event.
     */
    function grantRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _grantRole(role, account);
    }

    /**
     * @dev Revokes `role` from `account`.
     *
     * If `account` had been granted `role`, emits a {RoleRevoked} event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     *
     * May emit a {RoleRevoked} event.
     */
    function revokeRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _revokeRole(role, account);
    }

    /**
     * @dev Revokes `role` from the calling account.
     *
     * Roles are often managed via {grantRole} and {revokeRole}: this function's
     * purpose is to provide a mechanism for accounts to lose their privileges
     * if they are compromised (such as when a trusted device is misplaced).
     *
     * If the calling account had been revoked `role`, emits a {RoleRevoked}
     * event.
     *
     * Requirements:
     *
     * - the caller must be `account`.
     *
     * May emit a {RoleRevoked} event.
     */
    function renounceRole(bytes32 role, address account) public virtual override {
        require(account == _msgSender(), "AccessControl: can only renounce roles for self");

        _revokeRole(role, account);
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event. Note that unlike {grantRole}, this function doesn't perform any
     * checks on the calling account.
     *
     * May emit a {RoleGranted} event.
     *
     * [WARNING]
     * ====
     * This function should only be called from the constructor when setting
     * up the initial roles for the system.
     *
     * Using this function in any other way is effectively circumventing the admin
     * system imposed by {AccessControl}.
     * ====
     *
     * NOTE: This function is deprecated in favor of {_grantRole}.
     */
    function _setupRole(bytes32 role, address account) internal virtual {
        _grantRole(role, account);
    }

    /**
     * @dev Sets `adminRole` as ``role``'s admin role.
     *
     * Emits a {RoleAdminChanged} event.
     */
    function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal virtual {
        bytes32 previousAdminRole = getRoleAdmin(role);
        _roles[role].adminRole = adminRole;
        emit RoleAdminChanged(role, previousAdminRole, adminRole);
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * Internal function without access restriction.
     *
     * May emit a {RoleGranted} event.
     */
    function _grantRole(bytes32 role, address account) internal virtual {
        if (!hasRole(role, account)) {
            _roles[role].members[account] = true;
            emit RoleGranted(role, account, _msgSender());
        }
    }

    /**
     * @dev Revokes `role` from `account`.
     *
     * Internal function without access restriction.
     *
     * May emit a {RoleRevoked} event.
     */
    function _revokeRole(bytes32 role, address account) internal virtual {
        if (hasRole(role, account)) {
            _roles[role].members[account] = false;
            emit RoleRevoked(role, account, _msgSender());
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (utils/math/SafeMath.sol)

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is generally not needed starting with Solidity 0.8, since the compiler
 * now has built in overflow checking.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/IAccessControl.sol)

pragma solidity ^0.8.0;

/**
 * @dev External interface of AccessControl declared to support ERC165 detection.
 */
interface IAccessControl {
    /**
     * @dev Emitted when `newAdminRole` is set as ``role``'s admin role, replacing `previousAdminRole`
     *
     * `DEFAULT_ADMIN_ROLE` is the starting admin for all roles, despite
     * {RoleAdminChanged} not being emitted signaling this.
     *
     * _Available since v3.1._
     */
    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

    /**
     * @dev Emitted when `account` is granted `role`.
     *
     * `sender` is the account that originated the contract call, an admin role
     * bearer except when using {AccessControl-_setupRole}.
     */
    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Emitted when `account` is revoked `role`.
     *
     * `sender` is the account that originated the contract call:
     *   - if using `revokeRole`, it is the admin role bearer
     *   - if using `renounceRole`, it is the role bearer (i.e. `account`)
     */
    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account) external view returns (bool);

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {AccessControl-_setRoleAdmin}.
     */
    function getRoleAdmin(bytes32 role) external view returns (bytes32);

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function grantRole(bytes32 role, address account) external;

    /**
     * @dev Revokes `role` from `account`.
     *
     * If `account` had been granted `role`, emits a {RoleRevoked} event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function revokeRole(bytes32 role, address account) external;

    /**
     * @dev Revokes `role` from the calling account.
     *
     * Roles are often managed via {grantRole} and {revokeRole}: this function's
     * purpose is to provide a mechanism for accounts to lose their privileges
     * if they are compromised (such as when a trusted device is misplaced).
     *
     * If the calling account had been granted `role`, emits a {RoleRevoked}
     * event.
     *
     * Requirements:
     *
     * - the caller must be `account`.
     */
    function renounceRole(bytes32 role, address account) external;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (utils/Strings.sol)

pragma solidity ^0.8.0;

/**
 * @dev String operations.
 */
library Strings {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";
    uint8 private constant _ADDRESS_LENGTH = 20;

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        // Inspired by OraclizeAPI's implementation - MIT licence
        // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.
     */
    function toHexString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
     */
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }

    /**
     * @dev Converts an `address` with fixed length of 20 bytes to its not checksummed ASCII `string` hexadecimal representation.
     */
    function toHexString(address addr) internal pure returns (string memory) {
        return toHexString(uint256(uint160(addr)), _ADDRESS_LENGTH);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/introspection/ERC165.sol)

pragma solidity ^0.8.0;

import "./IERC165.sol";

/**
 * @dev Implementation of the {IERC165} interface.
 *
 * Contracts that want to implement ERC165 should inherit from this contract and override {supportsInterface} to check
 * for the additional interface id that will be supported. For example:
 *
 * ```solidity
 * function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
 *     return interfaceId == type(MyInterface).interfaceId || super.supportsInterface(interfaceId);
 * }
 * ```
 *
 * Alternatively, {ERC165Storage} provides an easier to use but more expensive implementation.
 */
abstract contract ERC165 is IERC165 {
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/introspection/IERC165.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}