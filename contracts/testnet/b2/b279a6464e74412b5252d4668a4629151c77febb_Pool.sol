/**
 *Submitted for verification at BscScan.com on 2022-05-10
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this;
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;
    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        _setOwner(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
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

library SafeMath {
    function tryAdd(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }

    function trySub(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        if (b > a) return (false, 0);
        return (true, a - b);
    }

    function tryMul(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }

    function tryDiv(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        if (b == 0) return (false, 0);
        return (true, a / b);
    }

    function tryMod(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        if (b == 0) return (false, 0);
        return (true, a % b);
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: modulo by zero");
        return a % b;
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        return a - b;
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a / b;
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a % b;
    }
}

library Address {
    function isContract(address account) internal view returns (bool) {
        // According to EIP-1052, 0x0 is the value returned for not-yet created accounts
        // and 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470 is returned
        // for accounts without code, i.e. `keccak256('')`
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            codehash := extcodehash(account)
        }
        return (codehash != accountHash && codehash != 0x0);
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

contract Pool is Ownable {
    using SafeMath for uint256;
    using Address for address;

    IERC20 public stakeToken;
    uint256 public stakeSeconds;
    uint256 public stakeAmount;
    uint256 public startTime;
    uint256 public endTime;
    uint256 public maxWhiteCount;

    mapping(address => uint256) private shares;
    mapping(address => uint256) private shareTime;
    mapping(address => bool) private shareForWhite;

    uint256 public totalShares;
    uint256 public shareCount;
    uint256 public whiteCount;
    address[] private whiteList;

    constructor(
        address _stakeTokenAddr,
        uint256 _stakeSeconds,
        uint256 _stakeAmount,
        uint256[2] memory _time,
        uint256 _maxWhiteCount
    ) {
        stakeToken = IERC20(_stakeTokenAddr); //0x789e1dfC67f3411bBdF2A3E79A167Be628415664
        stakeSeconds = _stakeSeconds;
        stakeAmount = _stakeAmount;
        startTime = _time[0];
        endTime = _time[1];
        maxWhiteCount = _maxWhiteCount;
    }

    function stake(uint256 _amount) external {
        require(_amount == stakeAmount, "amount not equal to stakeAmount");
        require(
            block.timestamp >= startTime && block.timestamp <= endTime,
            "not pledge activity time"
        );
        require(whiteCount < maxWhiteCount, "whiteCount is max");
        require(shares[msg.sender] == 0, "sender is staked");
        bool success = stakeToken.transferFrom(
            msg.sender,
            address(this),
            _amount
        );
        if (success) updateTotalShare(msg.sender, _amount, 1);
    }

    function unStake(uint256 _amount) external {
        require(
            shareTime[msg.sender].add(stakeSeconds) <= block.timestamp,
            "The pledge period has not expired"
        );
        require(
            _amount == shares[msg.sender] &&
                stakeToken.balanceOf(address(this)) >= _amount,
            "amount not equal to stakeAmount"
        );
        bool success = stakeToken.transfer(msg.sender, _amount);
        if (success) updateTotalShare(msg.sender, _amount, 2);
    }

    function updateTotalShare(
        address sender,
        uint256 _amount,
        uint256 _type
    ) internal {
        if (_type == 1) {
            shareCount++;
            whiteCount++;
            totalShares += _amount;
            shareForWhite[sender] = true;
            shareTime[sender] = block.timestamp;
            shares[sender] += _amount;
            whiteList.push(sender);
        } else {
            shares[sender] -= _amount;
        }
    }

    function withdrawToken(
        address token,
        address recipient,
        uint256 amount
    ) public onlyOwner {
        IERC20(token).transfer(recipient, amount);
    }

    function setStakeToken(address _token) external onlyOwner {
        stakeToken = IERC20(_token);
    }

    function setStakeSeconds(uint256 _seconds) external onlyOwner {
        stakeSeconds = _seconds;
    }

    function setStakeAmount(uint256 _amount) external onlyOwner {
        stakeAmount = _amount;
    }

    function setTimes(uint256[2] calldata _times) external onlyOwner {
        startTime = _times[0];
        endTime = _times[1];
    }

    function setMaxWhiteCount(uint256 _maxWhiteCount) external onlyOwner {
        maxWhiteCount = _maxWhiteCount;
    }

    function getBalance() external view returns (uint256) {
        return stakeToken.balanceOf(msg.sender);
    }

    function getShare() external view returns (uint256) {
        return shares[msg.sender];
    }

    function getShareTime() external view returns (uint256) {
        return shareTime[msg.sender];
    }

    function getShareForWhite(address _addr) external view returns (bool) {
        return shareForWhite[_addr];
    }

    function getWhiteList(uint8 start, uint8 end)
        external
        view
        returns (address[] memory)
    {
        require(start <= end && end <= whiteList.length - 1);
        address[] memory list = new address[](end + 1);
        uint8 i = 0;
        for (start; start <= end; start++) {
            list[i] = whiteList[start];
            i++;
        }
        return list;
    }

    receive() external payable {}

    fallback() external payable {
        require(msg.data.length == 0);
    }
}