/**
 *Submitted for verification at BscScan.com on 2022-07-09
*/

// SPDX-License-Identifier: Unlicensed
pragma solidity >=0.4.22 <0.9.0;
////////////////////////////////////////////////////
  
    ///////   ///////   ///////
   //    //  //    //  //    
  ///////   ///////   ///////
 //    //  //    //       //
///////   ///////   ///////
 
////////////////////////////////////////////////////
// BINANCE  BINARY  SYSTEM  //
////////////////////////////////////////////////////

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
contract Binance_Binary_System is Context {
    using SafeERC20 for IERC20;
    struct Node {
        uint24 leftChild;
        uint24 rightChild;
        uint16 depth; 
        uint24 todayCountPoint; 
        uint8 childs; 
        uint8 leftOrrightFather; 
        address fatherAddress;
        bool hasTodayPoint; 
    }
    mapping(address => Node) private _users;
    mapping(uint24 => address) private _allUsersAddress; 
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
        _listingNetwork = 100 * 10 ** 18;
        lastRun = block.timestamp;
    Descriptions = "Welcome to Binance Binary System (BBS) 100% decentralized. Sign up $100. You have two legs. Invite two new users. You will be awarded commission for each user on the left and right up to 30 commissions per day. The difference are transferred to next day. When you flash out, difference will not be zero. 100% deposits are sent to the contract and are paid to users every 24 hours. The time of payment of commissions is determined by users who receives commission is allowed to write the commission payment order on the contract. You will be paid 30 million BBS. Total 1ID revenue for BBS liquidity is paid to Pancakeswap. The smart contract will continue to work non-stop. There is no income outside the system for anyone. Enjoy BBS.";        
        tokenAddress = 0x322892af820Fa4152192eBA57d32C3D23A476945; 
        _depositToken = IERC20(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56); 
        _allUsersAddress[0] = _msgSender();
    }
    function Description() public view returns (string memory) {
        return Descriptions;
    }
    function TodayContractBallance() public view returns (uint256) {
        return _depositToken.balanceOf(address(this)) / 10 ** 18;
    }
    function Contract_Address() public view returns (address) {
        return address(this);
    }
    function BBS_Address() public view returns (address) {
        return tokenAddress;
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
            return "User Exist";
        } else {
            return "User Not Exist";
        }
    }
    function SignUp(address refferalAdderss) public {
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
        IERC20(tokenAddress).transfer(_msgSender(), 30000000 * 10 ** 18);
    }
    function Commission() public {
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