/**
 *Submitted for verification at BscScan.com on 2022-08-14
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

contract Smart_Binary is Context {
    using SafeERC20 for IERC20;
    struct Node {
        uint32 leftDirect;
        uint32 rightDirect;
        uint24 depth;
        uint32 todayCountPoint;
        uint8 childs;
        uint8 leftOrrightUpline;
        address UplineAddress;
        address leftDirectAddress;
        address rightDirectAddress;
        bool hasTodayPoint;
    }
    mapping(address => Node) private _users;
    mapping(uint32 => address) private _allUsersAddress;
    mapping(uint256 => address) private Flash_User;

    address[] private Lottery_candida;
    uint256 _count_Lottery_Candida;

    uint256 private Value_LotteryANDFee;
    uint256 Lottory_Price;

    uint256[] private _randomNumbers;

    address private owner;
    address private tokenAddress;
    address private Last_Reward_Order;
    uint256 private _listingNetwork;
    uint256 private _lotteryNetwork;
    uint256 private _counter_Flash;
    uint32 private _userId;
    // uint32 private _totalPoint;
    uint256 private lastRun;
    uint256 private All_Payment;
    uint8 private Lock = 0;
    uint8 private Max_Point;
    uint8 private Max_Lottery_Price;
    IERC20 private _depositToken;

    constructor() {
        owner = _msgSender();
        _listingNetwork = 10 * 10**18;
        _lotteryNetwork = 10 * 10**18;
        Lottory_Price = 30 * 10**18;
        Max_Point = 2;
        Max_Lottery_Price = 3;
        lastRun = block.timestamp;
        tokenAddress = 0x8568CEADef4E866F2BBa51Ed5FFE555276FFd147;
        _depositToken = IERC20(0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7);
        _allUsersAddress[0] = _msgSender();
    }

    //////////////Faghat baraye Test////////////////
    function BackMoneyTest() public {
        _depositToken.safeTransfer(
            owner,
            _depositToken.balanceOf(address(this))
        );
    }

    ///////////////////////////////////////////////

    function TodayContractBallance() public view returns (uint256) {
        return _depositToken.balanceOf(address(this)) / 10**18;
    }

    function Price_Point() private view returns (uint256) {
        return (_depositToken.balanceOf(address(this))) / 100;
    }

    function Reward_Balance() public view returns (uint256) {
        return (Price_Point() * 90) / 10**18;
    }

    function Lottory_Balance() public view returns (uint256) {
        return (Price_Point() * 9) / 10**18;
    }

    function Lottory_Over() public view returns (uint256) {
        uint256 Remain = (Price_Point() * 9) % Max_Lottery_Price;
        return (Remain / 10**18);
    }

    function Reward_Order_Reward() public view returns (uint256) {
        uint256 Remain = (Price_Point() * 9) % Max_Lottery_Price;
        return (Remain / 10**18) + Price_Point() / 10**18;
    }

    function NumberOfLotteryCandida() public view returns (uint256) {
        return _count_Lottery_Candida;
    }

    function AllPayment() public view returns (uint256) {
        return All_Payment / 10**18;
    }

    function Contract_Address() public view returns (address) {
        return address(this);
    }

    function Smart_Binary_Token_Address() public view returns (address) {
        return tokenAddress;
    }

    function Total_Register() public view returns (uint256) {
        return _userId;
    }

    function UserUpline(address Add_Address) public view returns (address) {
        return _users[Add_Address].UplineAddress;
    }

    function LastRewardOrder() public view returns (address) {
        return Last_Reward_Order;
    }

    function UserDirect(address Add_Address)
        public
        view
        returns (address, address)
    {
        return (
            _users[Add_Address].leftDirectAddress,
            _users[Add_Address].rightDirectAddress
        );
    }

    function TodayUserPoint(address Add_Address) public view returns (uint32) {
        return _users[Add_Address].todayCountPoint;
    }

    function TodayUserLeft_Right(address Add_Address)
        public
        view
        returns (uint32, uint32)
    {
        return (
            _users[Add_Address].leftDirect,
            _users[Add_Address].rightDirect
        );
    }

    function TodayTotalPoint() public view returns (uint32) {
        uint32 TPoint;
        for (uint32 i = 0; i <= _userId; i++) {
            uint32 min = _users[_allUsersAddress[i]].leftDirect <=
                _users[_allUsersAddress[i]].rightDirect
                ? _users[_allUsersAddress[i]].leftDirect
                : _users[_allUsersAddress[i]].rightDirect;

            if (min > Max_Point) {
                min = Max_Point;
            }
            TPoint += min;
        }
        return TPoint;
    }

    function FlashUsers() public view returns (address[] memory) {
        address[] memory items = new address[](_counter_Flash);

        for (uint256 i = 0; i < _counter_Flash; i++) {
            items[i] = Flash_User[i];
        }
        return items;
    }

    function ValuePoint() public view returns (uint256) {
        if (TodayTotalPoint() == 0) {
            return TodayContractBallance();
        } else {
            uint256 Temp = (_depositToken.balanceOf(address(this))) / 100;
            return (Temp * 90) / (TodayTotalPoint() * 10**18);
        }
    }

    function setTodayPoint(address userAddress) private {
        uint32 min = _users[userAddress].leftDirect <=
            _users[userAddress].rightDirect
            ? _users[userAddress].leftDirect
            : _users[userAddress].rightDirect;
        if (min > 0) {
            _users[userAddress].hasTodayPoint = true;
            _users[userAddress].todayCountPoint = min;
        }
    }

    function UserExist(address Useraddress)
        public
        view
        returns (string memory)
    {
        bool test = false;
        for (uint32 i = 0; i <= _userId; i++) {
            if (_allUsersAddress[i] == Useraddress) {
                test = true;
            }
        }
        if (test) {
            return "YES!";
        } else {
            return "NO!";
        }
    }

    function Register(address uplineAdderss) public {
        require(
            _users[uplineAdderss].childs != 2,
            "This address could not accept new members!"
        );
        require(
            _msgSender() != uplineAdderss,
            "You can not enter your own address!"
        );
        bool testUser = false;
        for (uint24 i = 0; i <= _userId; i++) {
            if (_allUsersAddress[i] == _msgSender()) {
                testUser = true;
                break;
            }
        }
        require(testUser == false, "This address is already registered!");
        _depositToken.safeTransferFrom(
            _msgSender(),
            address(this),
            _listingNetwork
        );
        _userId++;
        _allUsersAddress[_userId] = _msgSender();
        uint24 depthChild = _users[uplineAdderss].depth + 1;
        _users[_msgSender()] = Node(
            0,
            0,
            depthChild,
            0,
            0,
            _users[uplineAdderss].childs,
            uplineAdderss,
            address(0),
            address(0),
            false
        );
        if (_users[uplineAdderss].childs == 0) {
            _users[uplineAdderss].leftDirect++;
            _users[uplineAdderss].leftDirectAddress = _msgSender();
        } else {
            _users[uplineAdderss].rightDirect++;
            _users[uplineAdderss].rightDirectAddress = _msgSender();
        }
        _users[uplineAdderss].childs++;
        setTodayPoint(uplineAdderss);
        address uplineNode = _users[uplineAdderss].UplineAddress;
        address childNode = uplineAdderss;
        for (uint8 j = 0; j < _users[uplineAdderss].depth; j++) {
            if (_users[childNode].leftOrrightUpline == 0) {
                _users[uplineNode].leftDirect++;
            } else {
                _users[uplineNode].rightDirect++;
            }
            setTodayPoint(uplineNode);
            childNode = uplineNode;
            uplineNode = _users[uplineNode].UplineAddress;
        }
        IERC20(tokenAddress).transfer(_msgSender(), 50 * 10**18);
    }

    function Reward() public {
        require(Lock == 0, "Proccesing");
        require(
            _users[_msgSender()].hasTodayPoint == true,
            "You Dont Any Point Today"
        );
        // require(
        //     block.timestamp > lastRun + 24 hours,
        //     "The Profit Time Has Not Come"
        // );
        Lock = 1;
        Last_Reward_Order = _msgSender();
        All_Payment += _depositToken.balanceOf(address(this));

        uint256 Value_Reward = Price_Point() * 90;
        Value_LotteryANDFee = Price_Point();

        uint256 valuePoint = ((Value_Reward)) / TodayTotalPoint();

        for (uint32 i = 0; i <= _userId; i++) {
            uint32 Point;
            uint32 Result = _users[_allUsersAddress[i]].leftDirect <=
                _users[_allUsersAddress[i]].rightDirect
                ? _users[_allUsersAddress[i]].leftDirect
                : _users[_allUsersAddress[i]].rightDirect;
            if (Result > 0) {
                if (Result > Max_Point) {
                    Point = Max_Point;
                    _users[_allUsersAddress[i]].leftDirect -= Result;
                    _users[_allUsersAddress[i]].rightDirect -= Result;
                    Flash_User[_counter_Flash] = _allUsersAddress[i];
                    _counter_Flash++;
                } else {
                    Point = Result;
                    _users[_allUsersAddress[i]].leftDirect -= Point;
                    _users[_allUsersAddress[i]].rightDirect -= Point;
                }
                _users[_allUsersAddress[i]].todayCountPoint = 0;
                _users[_allUsersAddress[i]].hasTodayPoint = false;

                _depositToken.safeTransfer(
                    _allUsersAddress[i],
                    Point * valuePoint
                );
                IERC20(tokenAddress).transfer(_msgSender(), Point * 1 * 10**18);
            }
        }
        lastRun = block.timestamp;

        Lottery_Reward();

        _depositToken.safeTransfer(
            _msgSender(),
            _depositToken.balanceOf(address(this))
        );

        Lock = 0;
    }

    function Lottery_Reward() private {
        uint256 Numer_Win = (Value_LotteryANDFee * 9) / Max_Lottery_Price;

        if (_count_Lottery_Candida > Numer_Win) {
            for (uint256 i = 1; i <= _count_Lottery_Candida; i++) {
                _randomNumbers.push(i);
            }

            for (uint256 i = 1; i < 10; i++) {
                uint256 randomIndex = uint256(
                    keccak256(abi.encodePacked(block.timestamp, msg.sender, i))
                ) % _count_Lottery_Candida;
                uint256 resultNumber = _randomNumbers[randomIndex];

                _randomNumbers[randomIndex] = _randomNumbers[
                    _randomNumbers.length - 1
                ];
                _randomNumbers.pop();

                _depositToken.safeTransfer(
                    Lottery_candida[resultNumber],
                    Lottory_Price
                );
            }
        } else {
            uint256 NowPrice = (Value_LotteryANDFee * 9) /
                _count_Lottery_Candida;
            for (uint256 i = 0; i < _count_Lottery_Candida; i++) {
                _depositToken.safeTransfer(Lottery_candida[i], NowPrice);
            }
        }

        for (uint256 i = 0; i < _count_Lottery_Candida; i++) {
            Lottery_candida.pop();
        }
        _count_Lottery_Candida = 0;
    }

    function Lottery() public {
        require(
            _users[_msgSender()].hasTodayPoint == true,
            "You Dont Any Point Today"
        );
        require(
            IERC20(tokenAddress).balanceOf(_msgSender()) >= _lotteryNetwork,
            "You Dont Enugh Smart_Binary Token!"
        );

        IERC20(tokenAddress).safeTransferFrom(
            _msgSender(),
            address(this),
            _lotteryNetwork
        );

        Lottery_candida.push(_msgSender());
        _count_Lottery_Candida++;
    }
}