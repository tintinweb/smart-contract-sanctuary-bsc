// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.8.0;

import "./libraries/TransferHelper.sol";
import "./interface/IHayya.sol";

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}

contract Ownable {
    address private _owner;

    event OwnershipRenounced(address indexed previousOwner);

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        _owner = msg.sender;
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(isOwner());
        _;
    }

    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }

    function renounceOwnership() public onlyOwner {
        emit OwnershipRenounced(_owner);
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0));
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract HayyaRouter is Ownable {
    using SafeMath for uint256;

    uint256[] public REFERRAL_PERCENTS = [20, 15, 5, 5, 5];
    uint256 public feeDenominator = 1000;

    struct UserInfo {
        uint256 referTime;
        address parent;
    }

    address[] public shareHolder;

    mapping(address => UserInfo) public userInfo;
    mapping(address => address[]) public userInviters;

    address public tokenHYA;
    address public tokenGoal;

    constructor()Ownable(){}


    event ParentInfo(
        address indexed childAddress,
        address indexed parentAddress
    );

    modifier hasGoalCall() {
        require(msg.sender == tokenGoal, "not authorization");
        _;
    }

     modifier hasHYACall() {
        require(msg.sender == tokenHYA, "not authorization");
        _;
    }

    function referParent(address parentAddress, address children) public hasGoalCall {
        require(
            parentAddress != children,
            "Error: parent address can not equal children!"
        );
        require(
            userInfo[children].parent == address(0),
            "Error: children must be has no parent before!"
        );
        require(
            parentAddress == owner() || userInfo[parentAddress].parent != address(0),
            "Error: parentAddress must be has parent!"
        );
        require(
            !isContract(parentAddress),
            "Error: parent address must be a address!"
        );
        userInfo[children].parent = parentAddress;
        userInfo[children].referTime = block.timestamp;
        userInviters[parentAddress].push(children);
        emit ParentInfo(children, parentAddress);
    }

    function sendRewards(address _addr, uint256 _amount) external hasHYACall{
        address cur = _addr ;
        for (uint256 i = 0; i < REFERRAL_PERCENTS.length; i++) {
            cur = userInfo[cur].parent;
            if (cur == address(0)) {
                break;
            }
            uint256 curTAmount = _amount.div(feeDenominator).mul(REFERRAL_PERCENTS[i]);
            TransferHelper.safeTransfer(tokenHYA, cur, curTAmount);
        }
    }

    function withdrawAll() external onlyOwner {
        TransferHelper.safeTransfer(tokenHYA, msg.sender , IHAYYA(tokenHYA).balanceOf(address(this)));
    }

    function getRelations(address _addr) public view returns ( address[] memory ){
        address cur = _addr;
        address[] memory _listParent = new address[](5);
        for(uint256 i = 0; i < REFERRAL_PERCENTS.length; i++){
            cur = userInfo[cur].parent;
            if (cur == address(0)) {
                break;
            }
            _listParent[i] = cur;
        }
        return _listParent;
    }

    function isContract(address addr) internal view returns (bool) {
        uint size;
        assembly {size := extcodesize(addr)}
        return size > 0;
    }

    function setTokenHYA(address _tokenHYA) external onlyOwner{
        tokenHYA = _tokenHYA;
    }

    function setTokenGoal(address _tokenGoal) external onlyOwner{
        tokenGoal = _tokenGoal;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library TransferHelper {
    function safeApprove(
        address token,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('approve(address,uint256)')));
        (bool success, bytes memory data) =
            token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "TransferHelper: APPROVE_FAILED"
        );
    }

    function safeTransfer(
        address token,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) =
            token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "TransferHelper: TRANSFER_FAILED"
        );
    }

    function safeTransferFrom(
        address token,
        address from,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) =
            token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "TransferHelper: TRANSFER_FROM_FAILED"
        );
    }

    function safeTransferBNB(address to, uint256 value) internal {
        (bool success, ) = to.call{value: value}(new bytes(0));
        require(success, "TransferHelper: BNB_TRANSFER_FAILED");
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IHAYYA {
    function balanceOf(address who) external view returns (uint256);
}