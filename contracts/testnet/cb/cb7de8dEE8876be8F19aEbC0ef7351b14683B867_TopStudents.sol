pragma solidity 0.5.9;

contract TopStudents {
    mapping(address => uint256) public scores;
    uint256 public activeMaxSize;
    
    uint256 public activeLength;
    mapping(address => address) _activeList;
    address constant ACTIVE_GUARD = address(1);
    
    uint256 public reservedLength;
    mapping(address => address) _reservedList;
    address constant RESERVED_GUARD = address(2);
    
    constructor(uint256 _maxSize) public {
        activeMaxSize = _maxSize;
        _activeList[ACTIVE_GUARD] = ACTIVE_GUARD;
        _reservedList[RESERVED_GUARD] = RESERVED_GUARD;
    }
    
    function addStudent(address student, uint256 score) public {
        require(!studentExisted(student));
        scores[student] = score;
        address index = _findIndex(score);
        _addStudent(student, index);
        _rebalanceLists();
    }
    
    function removeStudent(address student) public {
        require(studentExisted(student));
        scores[student] = 0;
        address prevStudent = _findPrevStudent(student);
        _removeStudent(student, prevStudent);
        _rebalanceLists();
    }
    
    function updateScore(address student, uint256 score) public {
        require(studentExisted(student));
        scores[student] = score;
        _removeStudent(student, _findPrevStudent(student));
        _addStudent(student, _findIndex(score));
        _rebalanceLists();
    }
    
    function setAciveMaxSize(uint256 newMaxSize) public {
        activeMaxSize = newMaxSize;
        _rebalanceLists();
    }
    
    function studentExisted(address student) public view returns (bool) {
        return _activeList[student] != address(0) || _reservedList[student] != address(0);
    }
    
    function isInTop(address student) public view returns(bool) {
        return _activeList[student] != address(0);
    }
    
    function getTop() public view returns(address[] memory) {
        address[] memory topList = new address[](activeLength);
        address currentAddress = _activeList[ACTIVE_GUARD];
        for (uint i = 0; currentAddress != ACTIVE_GUARD; ++i) {
            topList[i] = currentAddress;
            currentAddress = _activeList[currentAddress];
        }
        return topList;
    }
    
    
    
    function _addStudent(address student, address prevStudent) internal {
        if (isInTop(prevStudent)) {
            _activeList[student] = _activeList[prevStudent];
            _activeList[prevStudent] = student;
            activeLength++;
        } else{
            _reservedList[student] = _reservedList[prevStudent];
            _reservedList[prevStudent] = student;
            reservedLength++;
        }
    }
    
    function _removeStudent(address student, address prevStudent) internal {
        if (isInTop(prevStudent)) {
            _activeList[prevStudent] = _activeList[student];
            _activeList[student] = address(0);
            activeLength--;
        } else {
            _reservedList[prevStudent] = _reservedList[student];
            _reservedList[student] = address(0);
            reservedLength--;
        }
    }
    
    function _isPrevStudent(address student, address prevStudent, bool isActive) internal view returns(bool) {
        if (isActive)
            return _activeList[prevStudent] == student;
        else
            return _reservedList[prevStudent] == student;
    }
    
    function _findPrevStudent(address student) internal view returns(address) {
        if(isInTop(student)) {
            address currentAddress = ACTIVE_GUARD;
            while(_activeList[currentAddress] != ACTIVE_GUARD) {
                if(_isPrevStudent(student, currentAddress, true))
                    return currentAddress;
                currentAddress = _activeList[currentAddress];
            }
            revert();
        } else {
            address currentAddress = RESERVED_GUARD;
            while(_reservedList[currentAddress] != RESERVED_GUARD) {
                if(_isPrevStudent(student, currentAddress, false))
                    return currentAddress;
                currentAddress = _reservedList[currentAddress];
            }
            revert();
        }
        
    }
    
    function _verifyIndex(address prevStudent, uint256 newValue, address nextStudent, bool isActive)
        internal
        view
        returns(bool)
    {
        if (isActive)
            return  (prevStudent == ACTIVE_GUARD || scores[prevStudent] < newValue) && 
                    (nextStudent == ACTIVE_GUARD || newValue <= scores[nextStudent]);
        else
            return  (prevStudent == RESERVED_GUARD || scores[prevStudent] >= newValue) && 
                    (nextStudent == RESERVED_GUARD || newValue > scores[nextStudent]);
    }
    
    function _findIndex(uint256 score) internal view returns (address) {
        bool isMinActive = _verifyIndex(ACTIVE_GUARD, score, _activeList[ACTIVE_GUARD], true);
        bool isMaxReserved = _verifyIndex(RESERVED_GUARD, score, _reservedList[RESERVED_GUARD], false);
        if (isMinActive && isMaxReserved)
        {
            if (activeLength < activeMaxSize)
                return ACTIVE_GUARD;
            else
                return RESERVED_GUARD;
        }
        if (isMaxReserved) {
            address currentIndex = _activeList[ACTIVE_GUARD];
            while (currentIndex != ACTIVE_GUARD) {
                if (_verifyIndex(currentIndex, score, _activeList[currentIndex], true))
                    return currentIndex;
                currentIndex = _activeList[currentIndex];
            }
            revert();
        } else if (isMinActive) {
            address currentIndex = _reservedList[RESERVED_GUARD];
            while (currentIndex != RESERVED_GUARD) {
                 if (_verifyIndex(currentIndex, score, _reservedList[currentIndex], false))
                    return currentIndex;
                currentIndex = _reservedList[currentIndex];
            }
          return currentIndex;
        } else {
          revert();
        }
    }
    
    function _rebalanceLists() internal {
        while (activeLength < activeMaxSize && reservedLength > 0) {
              address student = _reservedList[RESERVED_GUARD];
              _removeStudent(student, RESERVED_GUARD);
              _addStudent(student, ACTIVE_GUARD);
        }
        while (activeLength > activeMaxSize) {
              address student = _activeList[ACTIVE_GUARD];
              _removeStudent(student, ACTIVE_GUARD);
              _addStudent(student, RESERVED_GUARD);
        }
  }
}