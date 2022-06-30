// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

import "VRFv2SubscriptionManager.sol";
import "IRandomGenerator.sol";
import "IRandomGeneratorSetting.sol";

contract RandomGenerator is VRFv2SubscriptionManager, IRandomGenerator, IRandomGeneratorSetting {
    mapping(address => bool) private _visitors;

    mapping(address => uint256) private _visitorsArrIndex;

    address[] private _visitorsArr;

    uint256 private _tmpRandomNum;

    /**
     * @dev get a random number, permission check
     */
    function getRandomNumber() public virtual override returns (uint256 randomNum) {
        require(_visitors[msg.sender], "RandomGenerator: no permission to obtain random numbers");
        
        uint256 tmp;
        if (getRandomWordsLen() > 0) {
            tmp = getPopOneRandomWords();
            if (getRandomWordsLen() < 5) {
                internalOnceRequestRandomWords();
                _tmpRandomNum = uint256(keccak256(
                    abi.encodePacked(
                        tmp,
                        block.timestamp, 
                        _tmpRandomNum)));
            }
        } else {
            internalOnceRequestRandomWords();
            _tmpRandomNum = uint256(keccak256(
                abi.encodePacked(
                    block.timestamp, 
                    _tmpRandomNum)));
            tmp = _tmpRandomNum;
        }
        return tmp;
    }

    /**
     * @dev add random number visitor, permission check
     */
    function addVisitor(address visitor) public virtual override onlyOwner {
        require(!_visitors[visitor], "RandomGenerator: random number visitor already exists");
        _visitors[visitor] = true;
        _visitorsArrIndex[visitor] = _visitorsArr.length;
        _visitorsArr.push(visitor);
        emit AddVisitor(visitor);
    }

    /**
     * @dev delete random number visitor, permission check
     */
    function cancelVisitor(address visitor) public virtual override onlyOwner {
        require(_visitors[visitor], "RandomGenerator: random number visitor does not exist");

        uint256 lastVisitorIndex = _visitorsArr.length - 1;
        uint256 visitorIndex = _visitorsArrIndex[visitor];

        if (visitorIndex != lastVisitorIndex) {
            address lastVisitorAddress = _visitorsArr[lastVisitorIndex];

            _visitorsArr[visitorIndex] = lastVisitorAddress;
            _visitorsArrIndex[lastVisitorAddress] = visitorIndex;
        }
        
        delete _visitors[visitor];
        _visitorsArr.pop();
    
        emit CancelVisitor(visitor);
    }

    /**
     * @dev get address of random number visitor
     */
    function getVisitor() public virtual override view returns (address[] memory visitor) {
        return _visitorsArr;
    }
}