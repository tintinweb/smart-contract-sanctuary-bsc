/**
 *Submitted for verification at BscScan.com on 2022-07-02
*/

// SPDX-License-Identifier: Unlicensed
pragma solidity >=0.4.22 <0.9.0;

//////////////////////////////////////////////
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal pure virtual returns (bytes calldata) {
        return msg.data;
    }
}

/////////////////////////////////////////////
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

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
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

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{value: weiValue}(
            data
        );
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                // solhint-disable-next-line no-inline-assembly
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

/////////////////////////////////////////////
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

/////////////////////////////////////////////
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
            // Return data is optional
            // solhint-disable-next-line max-line-length
            require(
                abi.decode(returndata, (bool)),
                "SafeERC20: ERC20 operation did not succeed"
            );
        }
    }
}

/////////////////////////////////////////////

contract Green is Context {

    using SafeERC20 for IERC20;

    struct Node {
        uint24 leftChild;
        uint24 rightChild;
        uint16 depth; //depth of tree
        uint24 todayCountPoint; //all today point
        uint8 childs; // 0(no child),1(left child),2(full)
        uint8 leftOrrightFather; //0(left child),1(right child)
        address fatherAddress;
        bool hasTodayPoint; //aya emruz point dashte?
    }


    mapping(address => Node) private _users;
    mapping(uint24 => address) private _allUsersAddress; /// address of each member

    address private owner;
    address private tokenAddress;
    uint256 private _listingNetwork;
    uint24 private _userId;
    uint24 private _totalPoint;
    uint256 private lastRun;
    uint8 private Lock = 0;
    string private Descriptions;
    IERC20 private _depositToken;

    constructor() {
        owner = _msgSender();
        _listingNetwork = 5 * 10 ** 18;
        lastRun = block.timestamp;

        Descriptions = "";

        tokenAddress = 0xC71D8e2e05C9aa713c06498Ea7a517A86064ad30; //address token mine
        _depositToken = IERC20(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56); //address busd

        // tokenAddress = 0x327ad8b5Bd08432804F7F2404ef19c1a9e2Fe283; //address token mine testi
        // _depositToken = IERC20(0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7); //address busd testi

        _allUsersAddress[0] = _msgSender();
    }

    // modifier onlyOwner() {
    //     require(_msgSender() == owner, "Not Owner");
    //     _;
    // }

    function Description() public view returns (string memory) {
        return Descriptions;
    }

    function TodayContractBallance() public view returns (uint256) {
        return _depositToken.balanceOf(address(this)) / 10 ** 18;
    }

    function ContractAddress() public view returns (address) {
        return address(this);
    }

    function TodayUserPoint(address Useraddress) public view returns (uint24) {
        return _users[Useraddress].todayCountPoint;
    }

    function TodayUserLeft_Right(address Useraddress)
        public
        view
        returns (uint24, uint24)
    {
        return (_users[Useraddress].leftChild, _users[Useraddress].rightChild);
    }

    function TodayTotalPoint() public view returns (uint24) {
        uint24 TPoint;
        for (uint24 i = 0; i <= _userId; i++) {
            uint24 min = _users[_allUsersAddress[i]].leftChild <=
                _users[_allUsersAddress[i]].rightChild
                ? _users[_allUsersAddress[i]].leftChild
                : _users[_allUsersAddress[i]].rightChild;
            TPoint += min;
        }

        return TPoint;
    }

    function setTodayPoint(address userAddress) private {
        uint24 min = _users[userAddress].leftChild <=
            _users[userAddress].rightChild
            ? _users[userAddress].leftChild
            : _users[userAddress].rightChild;
        if (min > 0) {
            _users[userAddress].hasTodayPoint = true;
            _users[userAddress].todayCountPoint = min;
        }
    }

    function UserExist(address Useraddress) public view returns (string memory) {
        bool test = false;
        for (uint24 i = 0; i <= _userId; i++) {
            if (_allUsersAddress[i] == Useraddress) {
                test = true;
            }
        }
        if (test) {
            return "User Address Exist";
        } else {
            return "User Address Not Exist";
        }
    }

    function RegisterNewUser(address refferalAdderss) public {
        require(
            _users[refferalAdderss].childs != 2,
            "This address could not accept new members!"
        );
        require(
            _msgSender() != refferalAdderss,
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

        uint16 depthChild = _users[refferalAdderss].depth + 1;
        _users[_msgSender()] = Node(
            0,
            0,
            depthChild,
            0,
            0,
            _users[refferalAdderss].childs,
            refferalAdderss,
            false
        );

        if (_users[refferalAdderss].childs == 0) {
            _users[refferalAdderss].leftChild++;
        } else {
            _users[refferalAdderss].rightChild++;
        }
        _users[refferalAdderss].childs++;

        setTodayPoint(refferalAdderss); 

        address fatherNode = _users[refferalAdderss].fatherAddress;
        address childNode = refferalAdderss;
        for (uint8 j = 0; j < _users[refferalAdderss].depth; j++) {
            if (_users[childNode].leftOrrightFather == 0) {
                _users[fatherNode].leftChild++;
            } else {
                _users[fatherNode].rightChild++;
            }
            setTodayPoint(fatherNode);
            childNode = fatherNode;
            fatherNode = _users[fatherNode].fatherAddress;
        }

        // IERC20(tokenAddress).transfer(_msgSender(), 30000000 * 10 ** 18);//Airdrop
        IERC20(tokenAddress).transfer(_msgSender(), 5500 * 10 ** 18);//Airdrop
    }

    function RewardPaymentOrder() public {
        require(Lock == 0, "Proccesing");
        require(
            _users[_msgSender()].hasTodayPoint == true,
            "You Dont Any Point Today"
        );
        require(block.timestamp > lastRun + 24 hours, "The Profit Time Has Not Come");

        Lock = 1;
        _totalPoint = TodayTotalPoint();
        uint256 valuePoint = (_depositToken.balanceOf(address(this)) - (_totalPoint * 10 ** 18)) /
            _totalPoint;

        for (uint24 i = 0; i <= _userId; i++) {
            uint24 Point;
            uint24 RvsL = _users[_allUsersAddress[i]].leftChild <=
                _users[_allUsersAddress[i]].rightChild
                ? _users[_allUsersAddress[i]].leftChild
                : _users[_allUsersAddress[i]].rightChild;
            if (RvsL > 0) {
                if (RvsL > 30) {
                    Point = 30;
                    _users[_allUsersAddress[i]].leftChild -= RvsL;
                    _users[_allUsersAddress[i]].rightChild -= RvsL;
                } else {
                    Point = RvsL;
                    _users[_allUsersAddress[i]].leftChild -= Point;
                    _users[_allUsersAddress[i]].rightChild -= Point;
                }

                _users[_allUsersAddress[i]].todayCountPoint = 0;
                _users[_allUsersAddress[i]].hasTodayPoint = false;

                _depositToken.safeTransfer(
                    _allUsersAddress[i],
                    Point * valuePoint
                );
            }
        }

        lastRun = block.timestamp;

        _depositToken.safeTransfer(
            owner,
            _depositToken.balanceOf(address(this))
        );
        Lock = 0;
    }
}