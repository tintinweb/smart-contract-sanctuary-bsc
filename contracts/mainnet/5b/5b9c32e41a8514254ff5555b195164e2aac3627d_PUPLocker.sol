/**
 *Submitted for verification at BscScan.com on 2022-09-11
*/

// SPDX-License-Identifier: MIT
pragma solidity =0.8.7;

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint256);
}

interface IPair is IERC20 {
    function token0() external view returns (address);

    function token1() external view returns (address);
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
        require(address(this).balance >= amount, "k005");

        (bool success,) = recipient.call{value : amount}("");
        require(success, "k006");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "k007");
        require(isContract(target), "k008");

        (bool success, bytes memory returndata) = target.call{value : value}(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "k009");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "k010");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) private pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

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

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "t001");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "t002");
        uint256 c = a - b;
        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "t003");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "t004");
        uint256 c = a / b;
        return c;
    }
}


library SafeERC20 {
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        bytes memory returndata = address(token).functionCall(data, "e0");
        if (returndata.length > 0) {
            require(abi.decode(returndata, (bool)), "e1");
        }
    }
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    constructor() {
        _setOwner(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }
    modifier onlyOwner() {
        require(owner() == _msgSender(), "k002");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "k003");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

abstract contract ReentrancyGuard {
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }
    modifier nonReentrant() {
        require(_status != _ENTERED, "k004");
        _status = _ENTERED;
        _;
        _status = _NOT_ENTERED;
    }
}


contract PUPLocker is Ownable {
    using SafeMath for uint256;
    using Address for address;
    using SafeERC20 for IERC20;
    uint256 public lockIndex = 0;
    uint256 public fee = 0;
    uint256 public limit = 100;
    mapping(uint256 => lockItem) public lockerList;
    mapping(address => uint256[]) public userLockerList;
    mapping(address => uint256[]) public claimLockerList;
    mapping(IERC20 => uint256[]) public erc20TokenLockerList;
    mapping(address => bool) public whiteList;

    struct TokenItem {
        uint256 balanceOf;
        uint256 decimals;
        uint256 totalSupply;
        string name;
        string symbol;
        address[] tokenList;
        string[] nameList;
        string[] symbolList;
        uint256[] decimalsList;
    }

    struct lockItem {
        uint256 lockId;
        uint256 lockTime;
        uint256 unlockTime;
        uint256 lockAmount;
        IERC20 erc20Token;
        address account;
        address claimAddress;
        bool hasClaim;
        uint256 claimTime;
        TokenItem tokenInfo;
    }

    function setFee(uint256 _fee) external onlyOwner {
        fee = _fee;
    }

    function setLimit(uint256 _limit) external onlyOwner {
        limit = _limit;
    }

    function setWhiteList(address[] memory _addressList, bool _status) external onlyOwner {
        for (uint256 i = 0; i < _addressList.length; i++) {
            whiteList[_addressList[i]] = _status;
        }
    }

    function getLpInfo(IERC20 _token, address _user) public view returns (TokenItem memory lpInfo) {
        uint256 balanceOf = _token.balanceOf(_user);
        address[] memory tokenList = new address[](2);
        string[] memory nameList = new string[](2);
        string[] memory symbolList = new string[](2);
        uint256[] memory decimalsList = new uint256[](2);
        try IPair(address(_token)).token0() returns (address token){
            address token0 = token;
            address token1 = IPair(address(_token)).token1();
            tokenList[0] = token0;
            tokenList[1] = token1;
            nameList[0] = IERC20(token0).name();
            nameList[1] = IERC20(token1).name();
            symbolList[0] = IERC20(token0).symbol();
            symbolList[1] = IERC20(token1).symbol();
            decimalsList[0] = IERC20(token0).decimals();
            decimalsList[1] = IERC20(token1).decimals();
        } catch {
        }
        lpInfo = TokenItem(balanceOf, _token.decimals(), _token.totalSupply(), _token.name(), _token.symbol(), tokenList, nameList, symbolList, decimalsList);
    }

    function lock(address _claimAddress, IERC20 _token, uint256[] memory _unlockTimeList, uint256[] memory _lockAmountList) external payable {
        require(_unlockTimeList.length == _lockAmountList.length, "e001");
        if (whiteList[msg.sender]) {
            require(msg.value == 0, "e002");
        } else {
            require(msg.value == fee, "e003");
        }
        uint256 balance0 = _token.balanceOf(address(this));
        uint256 lockerNum = _unlockTimeList.length;
        uint256 totalAmount = 0;
        for (uint256 i = 0; i < lockerNum; i++) {
            totalAmount = totalAmount.add(_lockAmountList[i]);
        }
        _token.safeTransferFrom(msg.sender, address(this), totalAmount);
        uint256 balance1 = _token.balanceOf(address(this));
        uint256 addAmount = balance1.sub(balance0);
        require(totalAmount == addAmount, "e004");
        for (uint256 i = 0; i < lockerNum; i++) {
            lockItem memory x = (new lockItem[](1))[0];
            x.claimAddress = _claimAddress;
            x.lockId = lockIndex;
            x.lockTime = block.timestamp;
            x.unlockTime = _unlockTimeList[i];
            x.lockAmount = _lockAmountList[i];
            x.erc20Token = _token;
            x.account = msg.sender;
            x.hasClaim = false;
            x.tokenInfo = getLpInfo(_token, msg.sender);
            lockerList[lockIndex] = x;
            userLockerList[msg.sender].push(lockIndex);
            erc20TokenLockerList[_token].push(lockIndex);
            claimLockerList[_claimAddress].push(lockIndex);
            lockIndex = lockIndex.add(1);
        }
    }

    function appendErc20Token(uint256 _lockIndex, uint256 _appendAmount) external {
        require(msg.sender == lockerList[_lockIndex].account, "e005");
        require(block.timestamp < lockerList[_lockIndex].unlockTime, "e006");
        IERC20 _token = lockerList[_lockIndex].erc20Token;
        uint256 balance0 = _token.balanceOf(address(this));
        _token.safeTransferFrom(msg.sender, address(this), _appendAmount);
        uint256 balance1 = _token.balanceOf(address(this));
        uint256 addAmount = balance1.sub(balance0);
        require(_appendAmount == addAmount, "e007");
        lockerList[_lockIndex].lockAmount = lockerList[_lockIndex].lockAmount.add(_appendAmount);
    }

    function changeClaimAddress(uint256 _lockIndex, address _claimAddress) external {
        require(msg.sender == lockerList[_lockIndex].account, "e008");
        require(block.timestamp < lockerList[_lockIndex].unlockTime, "e009");
        lockerList[_lockIndex].claimAddress = _claimAddress;
    }

    function unlock(uint256 _lockIndex) external {
        require(msg.sender == lockerList[_lockIndex].claimAddress, "e010");
        require(block.timestamp >= lockerList[_lockIndex].unlockTime, "e011");
        require(!lockerList[_lockIndex].hasClaim, "e012");
        lockerList[_lockIndex].erc20Token.safeTransfer(msg.sender, lockerList[_lockIndex].lockAmount);
        lockerList[_lockIndex].hasClaim = true;
        lockerList[_lockIndex].claimTime = block.timestamp;
    }

    function getLockerListByIndexList(uint256[] memory _indexList) public view returns (uint256 lockerNum, uint256[] memory lockerIndexList, lockItem[] memory lockerInfoList, uint256[] memory totalSupplyList) {
        lockerNum = _indexList.length;
        lockerIndexList = _indexList;
        lockerInfoList = new lockItem[](lockerNum);
        totalSupplyList = new uint256[](lockerNum);
        uint256 j = 0;
        for (uint256 i = 0; i < lockerNum; i++) {
            uint256 _index = _indexList[i];
            lockerInfoList[i] = lockerList[_index];
            totalSupplyList[i] = lockerList[_index].erc20Token.totalSupply();
            j = j.add(1);
            if (j > limit) {
                break;
            }
        }
    }

    function getUserLockerIndexList(address _user) external view returns (uint256 lockerNum, uint256[] memory lockerIndexList) {
        lockerNum = userLockerList[_user].length;
        lockerIndexList = userLockerList[_user];
    }

    function getClaimLockerIndexList(address _user) external view returns (uint256 lockerNum, uint256[] memory lockerIndexList) {
        lockerNum = claimLockerList[_user].length;
        lockerIndexList = claimLockerList[_user];
    }

    function geterc20TokenLockerIndexList(IERC20 _token) external view returns (uint256 lockerNum, uint256[] memory lockerIndexList) {
        lockerNum = erc20TokenLockerList[_token].length;
        lockerIndexList = erc20TokenLockerList[_token];
    }

    function getUserLockerList(address _user) external view returns (uint256 lockerNum, uint256[] memory lockerIndexList, lockItem[] memory lockerInfoList, uint256[] memory totalSupplyList) {
        (lockerNum, lockerIndexList, lockerInfoList, totalSupplyList) = getLockerListByIndexList(userLockerList[_user]);
    }

    function getClaimLockerList(address _user) external view returns (uint256 lockerNum, uint256[] memory lockerIndexList, lockItem[] memory lockerInfoList, uint256[] memory totalSupplyList) {
        (lockerNum, lockerIndexList, lockerInfoList, totalSupplyList) = getLockerListByIndexList(claimLockerList[_user]);
    }

    function geterc20TokenLockerList(IERC20 _token) external view returns (uint256 lockerNum, uint256[] memory lockerIndexList, lockItem[] memory lockerInfoList, uint256[] memory totalSupplyList) {
        (lockerNum, lockerIndexList, lockerInfoList, totalSupplyList) = getLockerListByIndexList(erc20TokenLockerList[_token]);
    }

    function takeFee() external onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
    }

    function getIsWhiteList(address _user) external view returns (bool _isInWhiteList, uint256 _fee, uint256 _lockIndex) {
        _isInWhiteList = whiteList[_user];
        _fee = fee;
        _lockIndex = lockIndex;
    }

    receive() external payable {}
}