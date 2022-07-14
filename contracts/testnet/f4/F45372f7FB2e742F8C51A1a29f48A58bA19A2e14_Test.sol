// SPDX-License-Identifier: MIT

pragma solidity 0.8.14;

contract Test {
    uint256 public currentId;

    mapping(address => uint256) public addressToId;
    mapping(uint256 => address) public idToAddress;

    mapping(address => address) public userToReferrer;
    mapping(address => address[]) public directPartners;

    receive() external payable {}

    fallback() external payable {}

    event print(uint256 boq);
    event NewReferral(address indexed user, address indexed referral);

    function _addUser(address _user, address _referrer) private {
        addressToId[_user] = currentId;
        idToAddress[currentId] = _user;
        userToReferrer[_user] = _referrer;
        directPartners[_referrer].push(_user);
        currentId++;
        emit NewReferral(_referrer, _user);
    }

    function seedUsers(address mlmAddress) external {
        (bool succsess, bytes memory response) = mlmAddress.call(
            abi.encodeWithSignature("currentId()")
        );
        uint256 oldCurrentId = abi.decode(response, (uint256));

        require(currentId <= oldCurrentId, "Add is finishd");
        uint256 j = currentId;
        for (uint256 i = currentId; i < j + 500; i++) {
            if (i <= oldCurrentId) {
                break;
            }
            if (i >= currentId) {
                (bool succsess1, bytes memory response1) = mlmAddress.call(
                    abi.encodeWithSignature("idToAddress(uint256)", i)
                );
                address user = abi.decode(response1, (address));
                (bool succsess2, bytes memory response2) = mlmAddress.call(
                    abi.encodeWithSignature("userToReferrer(address)", user)
                );
                address refferer = abi.decode(response2, (address));

                if (refferer != address(0)) {
                    _addUser(user, refferer);
                }
            }
        }
    }

    function sett(uint256 _top) external {
        currentId = _top;
    }

    function setUser(address _user, address _ref) external {
        for (uint256 i; i < 500; i++) {
            _addUser(_user, _ref);
        }
    }
}