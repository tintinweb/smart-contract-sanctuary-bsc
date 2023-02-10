/**
 *Submitted for verification at BscScan.com on 2023-02-09
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;


interface ILinkedin {
    function mySuper(address user) external view returns (address);
    function myJuniors(address user) external view returns (address[] memory);
    function getSuperList(address user, uint256 list) external view returns (address[] memory);
}


contract Linkedin is ILinkedin {
    mapping (address => address) private _mySuper;     // super
    mapping (address => address[]) private _myJuniors; // juniors
    

    constructor() {}


    event BoundSuper(address my, address mySuper);
    

    function boundSuper(address superAddress) external {
        address my = msg.sender;
        require(superAddress != my, "not bound yourself");
        require(!isContract(my), "you not contract");
        require(!isContract(superAddress), "super not contract");
        require(superAddress != address(0), "not bound zaro address");
        require(_mySuper[my] == address(0), "haved super");

        address _s = _mySuper[superAddress];
        // 30 closed cycle checked
        for(uint256 i; i < 30; i++) {
            require(_s != my, "closed cycle");
            _s = _mySuper[_s];
        }
        _mySuper[my] = superAddress;
        _myJuniors[superAddress].push(my);
        emit BoundSuper(my, superAddress);
    }

    function isContract(address account) internal view returns (bool) {
        return account.code.length > 0;
    }

    function mySuper(address user) external view returns (address) {
        return _mySuper[user];
    }

    function myJuniors(address user) external view returns (address[] memory) {
        uint256 len = _myJuniors[user].length;
        address[] memory _juniors = new address[](len);
        for(uint256 i = 0; i < len; i++) {
            _juniors[i] = _myJuniors[user][i];
        }
        return _juniors;
    }

    function getSuperList(address user, uint256 list) external view returns (address[] memory) {
        require(list > 0, "zero list error");
        address[] memory _supers = new address[](list);
        address _super = user;
        for(uint256 i = 0; i < list; i++) {
            _super = _mySuper[_super];
            _supers[i] = _super;
        }
        return _supers;
    }
    
}