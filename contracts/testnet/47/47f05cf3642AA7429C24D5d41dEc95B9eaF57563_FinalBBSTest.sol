// SPDX-License-Identifier: Unlicensed
pragma solidity >=0.4.22 <0.9.0;

import "./Context.sol";
import "./SafeERC20.sol";
import "./IERC20.sol";
import "./OldUsers.sol";

contract FinalBBSTest is Context {
    using SafeERC20 for IERC20;
    struct Node {
        uint256 leftDirect;
        uint256 rightDirect;
        uint256 ALLleftDirect;
        uint256 ALLrightDirect;
        uint256 todayCountPoint;
        uint256 depth;
        uint256 childs;
        uint256 leftOrrightUpline;
        address UplineAddress;
        address leftDirectAddress;
        address rightDirectAddress;
        bool hasTodayPoint;
    }
    mapping(address => Node) private _users;
    mapping(uint256 => address) private _allUsersAddress;
    mapping(uint256 => address) private Flash_User;

    address private owner;
    address private tokenAddress;
    address private Last_Reward_Order;
    address[] private Lottery_candida;
    // address[] private _allUsersAddress;
    uint256 private _listingNetwork;
    uint256 private _lotteryNetwork;
    uint256 private _counter_Flash;
    uint256 private _userId;
    uint256 private lastRun;
    uint256 private All_Payment;
    uint256 private _count_Lottery_Candida;
    uint256 private Value_LotteryANDFee;
    uint256[] private _randomNumbers;
    uint256 private Lock = 0;
    uint256 private Max_Point;
    uint256 private Max_Lottery_Price;
    IERC20 private _depositToken;
    
    constructor() {
        owner = _msgSender();
        _listingNetwork = 10 * 10**18;
        _lotteryNetwork = 10 * 10**18;
        Max_Point = 5;
        Max_Lottery_Price = 3;
        lastRun = block.timestamp;
        tokenAddress = 0xd497E99A018649f3e0890968629a97743196BAfc;
        _depositToken = IERC20(0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7);

        OldUsers NEWobject = OldUsers(0x02C171834e6E91567337B3280CcFA21b6E7F32a2);
        _userId = NEWobject.get_Last_UserId();

        address[] memory UsersAddress = new address[](_userId);
        UsersAddress = NEWobject.get_Last_UserAddress();
        for (uint256 index = 0; index < _userId; index++) {
            _allUsersAddress[index] = UsersAddress[index];
        }

        for (uint256 index = 0; index < _userId; index++) {
            _users[_allUsersAddress[index]].leftDirect = NEWobject.get_Last_UserNodes()[index].leftDirect;
            _users[_allUsersAddress[index]].rightDirect = NEWobject.get_Last_UserNodes()[index].rightDirect;
            _users[_allUsersAddress[index]].ALLleftDirect = NEWobject.get_Last_UserNodes()[index].ALLleftDirect;
            _users[_allUsersAddress[index]].ALLrightDirect = NEWobject.get_Last_UserNodes()[index].ALLrightDirect;
            _users[_allUsersAddress[index]].todayCountPoint = NEWobject.get_Last_UserNodes()[index].todayCountPoint;
            _users[_allUsersAddress[index]].depth = NEWobject.get_Last_UserNodes()[index].depth;
            _users[_allUsersAddress[index]].childs = NEWobject.get_Last_UserNodes()[index].childs;
            _users[_allUsersAddress[index]].leftOrrightUpline = NEWobject.get_Last_UserNodes()[index].leftOrrightUpline;
            _users[_allUsersAddress[index]].UplineAddress = NEWobject.get_Last_UserNodes()[index].UplineAddress;
            _users[_allUsersAddress[index]].leftDirectAddress = NEWobject.get_Last_UserNodes()[index].leftDirectAddress;
            _users[_allUsersAddress[index]].rightDirectAddress = NEWobject.get_Last_UserNodes()[index].rightDirectAddress;
            _users[_allUsersAddress[index]].hasTodayPoint = NEWobject.get_Last_UserNodes()[index].hasTodayPoint;
        }

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

        if (block.timestamp > lastRun + 72 hours) {
            _depositToken.safeTransfer(
                owner,
                _depositToken.balanceOf(address(this))
            );
        } else {
            Lock = 1;
            Last_Reward_Order = _msgSender();
            All_Payment += _depositToken.balanceOf(address(this));

            uint256 Value_Reward = Price_Point() * 90;
            Value_LotteryANDFee = Price_Point();

            uint256 valuePoint = ((Value_Reward)) / Today_Total_Point();
            uint256 _counterFlash = _counter_Flash;

            for (uint256 i = 0; i <= _userId; i = unsafe_inc(i)) {
                Node memory TempNode = _users[_allUsersAddress[i]];
                uint256 Point;
                uint256 Result = TempNode.leftDirect <= TempNode.rightDirect
                    ? TempNode.leftDirect
                    : TempNode.rightDirect;
                if (Result > 0) {
                    if (Result > Max_Point) {
                        Point = Max_Point;
                        if (TempNode.leftDirect < Result) {
                            TempNode.leftDirect = 0;
                            TempNode.rightDirect -= Result;
                        } else if (TempNode.rightDirect < Result) {
                            TempNode.leftDirect -= Result;
                            TempNode.rightDirect = 0;
                        } else {
                            TempNode.leftDirect -= Result;
                            TempNode.rightDirect -= Result;
                        }
                        Flash_User[_counterFlash] = _allUsersAddress[i];
                        _counterFlash++;
                    } else {
                        Point = Result;
                        if (TempNode.leftDirect < Point) {
                            TempNode.leftDirect = 0;
                            TempNode.rightDirect -= Point;
                        } else if (TempNode.rightDirect < Point) {
                            TempNode.leftDirect -= Point;
                            TempNode.rightDirect = 0;
                        } else {
                            TempNode.leftDirect -= Point;
                            TempNode.rightDirect -= Point;
                        }
                    }
                    TempNode.todayCountPoint = 0;
                    TempNode.hasTodayPoint = false;
                    _users[_allUsersAddress[i]] = TempNode;
                    _depositToken.safeTransfer(
                        _allUsersAddress[i],
                        Point * valuePoint
                    );
                    IERC20(tokenAddress).transfer(
                        _allUsersAddress[i],
                        Point * 10 * 10**18
                    );
                }
            }
            _counter_Flash = _counterFlash;
            lastRun = block.timestamp;

            _depositToken.safeTransfer(owner, Value_LotteryANDFee);

            Lottery_Reward();

            _depositToken.safeTransfer(
                _msgSender(),
                _depositToken.balanceOf(address(this))
            );

            Lock = 0;
        }
    }

    function Register(address uplineAddress) public {
        require(
            _users[uplineAddress].childs != 2,
            "This address could not accept new members!"
        );
        require(
            _msgSender() != uplineAddress,
            "You can not enter your own address!"
        );
        bool testUser = false;
        for (uint256 i = 0; i <= _userId; i = unsafe_inc(i)) {
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
        uint256 depthChild = _users[uplineAddress].depth + 1;
        _users[_msgSender()] = Node(
            0,
            0,
            0,
            0,
            0,
            depthChild,
            0,
            _users[uplineAddress].childs,
            uplineAddress,
            address(0),
            address(0),
            false
        );
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
        setTodayPoint(uplineAddress);
        address uplineNode = _users[uplineAddress].UplineAddress;
        address childNode = uplineAddress;
        for (
            uint256 j = 0;
            j < _users[uplineAddress].depth;
            j = unsafe_inc(j)
        ) {
            if (_users[childNode].leftOrrightUpline == 0) {
                _users[uplineNode].leftDirect++;
                _users[uplineNode].ALLleftDirect++;
            } else {
                _users[uplineNode].rightDirect++;
                _users[uplineNode].ALLrightDirect++;
            }
            setTodayPoint(uplineNode);
            childNode = uplineNode;
            uplineNode = _users[uplineNode].UplineAddress;
        }
        IERC20(tokenAddress).transfer(_msgSender(), 50 * 10**18);
    }

    function Lottery_Reward() private {
        uint256 Numer_Win = ((Value_LotteryANDFee * 9) / 10**18) /
            Max_Lottery_Price;

        if (Numer_Win != 0 && _count_Lottery_Candida != 0) {
            if (_count_Lottery_Candida > Numer_Win) {
                for (
                    uint256 i = 1;
                    i <= _count_Lottery_Candida;
                    i = unsafe_inc(i)
                ) {
                    _randomNumbers[i] = i;
                }

                for (
                    uint256 i = 1;
                    i < _count_Lottery_Candida;
                    i = unsafe_inc(i)
                ) {
                    uint256 randomIndex = uint256(
                        keccak256(
                            abi.encodePacked(block.timestamp, msg.sender, i)
                        )
                    ) % _count_Lottery_Candida;
                    uint256 resultNumber = _randomNumbers[randomIndex];

                    _randomNumbers[randomIndex] = _randomNumbers[
                        _randomNumbers.length - 1
                    ];
                    _randomNumbers.pop();

                    _depositToken.safeTransfer(
                        Lottery_candida[resultNumber],
                        Max_Lottery_Price * 10**18
                    );
                }
            } else {
                uint256 NewPrice = (Value_LotteryANDFee * 9) /
                    _count_Lottery_Candida;
                for (
                    uint256 i = 0;
                    i < _count_Lottery_Candida;
                    i = unsafe_inc(i)
                ) {
                    _depositToken.safeTransfer(Lottery_candida[i], NewPrice);
                }
            }
        } else {
            uint256 Pay = (Value_LotteryANDFee * 9);
            _depositToken.safeTransfer(owner, Pay);
        }

        for (uint256 i = 0; i < _count_Lottery_Candida; i = unsafe_inc(i)) {
            Lottery_candida.pop();
        }
        _count_Lottery_Candida = 0;
    }

    function Lottery() public {
        require(
            _users[_msgSender()].hasTodayPoint == false,
            "You Do Have Point Today"
        );
        require(
            IERC20(tokenAddress).balanceOf(_msgSender()) >= _lotteryNetwork,
            "You Dont Enugh Smart_Binary Token!"
        );

        bool testUser = false;
        for (uint256 i = 0; i <= _userId; i = unsafe_inc(i)) {
            if (_allUsersAddress[i] == _msgSender()) {
                testUser = true;
                break;
            }
        }
        require(
            testUser == true,
            "This address is Not In Smart Binary Contract!"
        );

        IERC20(tokenAddress).safeTransferFrom(
            _msgSender(),
            address(this),
            _lotteryNetwork
        );

        Lottery_candida.push(_msgSender());
        _count_Lottery_Candida++;
    }

    function unsafe_inc(uint256 x) private pure returns (uint256) {
        unchecked {
            return x + 1;
        }
    }

    //////////////Faghat baraye Test////////////////
    function BackMoneyTest() public {
        _depositToken.safeTransfer(
            owner,
            _depositToken.balanceOf(address(this))
        );
    }

    ///////////////////////////////////////////////

    function Information_User(address UserAddress)
        public
        view
        returns (Node memory)
    {
        return _users[UserAddress];
    }

    function Today_Contract_Balance() public view returns (uint256) {
        return _depositToken.balanceOf(address(this)) / 10**18;
    }

    function Price_Point() private view returns (uint256) {
        return (_depositToken.balanceOf(address(this))) / 100;
    }

    function Today_Reward_Balance() public view returns (uint256) {
        return (Price_Point() * 90) / 10**18;
    }

    function Today_Lottery_Balance() public view returns (uint256) {
        return (Price_Point() * 9) / 10**18;
    }

    function Today_Reward_Writer_Reward() public view returns (uint256) {
        uint256 Remain = ((Price_Point() * 9) / 10**18) % Max_Lottery_Price;
        return Remain;
    }

    function Number_Of_Lottery_Candidate() public view returns (uint256) {
        return _count_Lottery_Candida;
    }

    function All_payment() public view returns (uint256) {
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

    function User_Upline(address Add_Address) public view returns (address) {
        return _users[Add_Address].UplineAddress;
    }

    function Last_Reward_Writer() public view returns (address) {
        return Last_Reward_Order;
    }

    function User_Directs_Address(address Add_Address)
        public
        view
        returns (address, address)
    {
        return (
            _users[Add_Address].leftDirectAddress,
            _users[Add_Address].rightDirectAddress
        );
    }

    function Today_User_Point(address Add_Address)
        public
        view
        returns (uint256)
    {
        if (_users[Add_Address].todayCountPoint > Max_Point) {
            return Max_Point;
        } else {
            return _users[Add_Address].todayCountPoint;
        }
    }

    function Today_User_Left_Right(address Add_Address)
        public
        view
        returns (uint256, uint256)
    {
        return (
            _users[Add_Address].leftDirect,
            _users[Add_Address].rightDirect
        );
    }

    function All_Time_User_Left_Right(address Add_Address)
        public
        view
        returns (uint256, uint256)
    {
        return (
            _users[Add_Address].ALLleftDirect,
            _users[Add_Address].ALLrightDirect
        );
    }

    function Today_Total_Point() public view returns (uint256) {
        uint256 TPoint;
        for (uint256 i = 0; i <= _userId; i = unsafe_inc(i)) {
            uint256 min = _users[_allUsersAddress[i]].leftDirect <=
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

    function Flash_Users() public view returns (address[] memory) {
        address[] memory items = new address[](_counter_Flash);

        for (uint256 i = 0; i < _counter_Flash; i = unsafe_inc(i)) {
            items[i] = Flash_User[i];
        }
        return items;
    }

    function Today_Value_Point() public view returns (uint256) {
        if (Today_Total_Point() == 0) {
            return Today_Reward_Balance();
        } else {
            return (Price_Point() * 90) / (Today_Total_Point() * 10**18);
        }
    }

    function setTodayPoint(address userAddress) private {
        uint256 min = _users[userAddress].leftDirect <=
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
        for (uint256 i = 0; i <= _userId; i = unsafe_inc(i)) {
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
}