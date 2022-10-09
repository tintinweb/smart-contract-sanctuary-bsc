/**
 *Submitted for verification at BscScan.com on 2022-10-09
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
interface IStake {
    struct UserInfo {
        bool isExist;
        uint256 balance;
        uint256 rewardTotal;
        uint256 amount;
        uint256 rewardDebt;
        uint256 inviteRewardBalance;
        uint256 inviteRewardTotal;
        address refer;
    }
    function userInvites(address account, uint256 index)
        external
        view
        returns (address);
    function userInviteTotals(address account) external view returns (uint256);
    function users(uint256 index) external view returns (address);
    function userInfos(address account) external view returns (UserInfo memory);
    function userTotal() external view returns (uint256);
    function getRewardTotal() external view returns (uint256);
    function getInvites(address account)
        external
        view
        returns (address[] memory);
}
contract Stake is Ownable {
    using SafeMath for uint256;
    using Address for address;
    struct UserInfo {
        bool isExist;
        uint256 balance;
        uint256 rewardTotal;
        uint256 amount;
        uint256 rewardDebt;
        uint256 inviteRewardBalance;
        uint256 inviteRewardTotal;
        address refer;
    }
    mapping(address => mapping(uint256 => address)) public userInvites;
    mapping(address => uint256) public userInviteTotals;
    mapping(address => UserInfo) public userInfos;
    mapping(uint256 => address) public users;
    uint256 public userTotal;
    uint256 private _perBlockDiff = 12056327160;
    uint256 private _perBlockMax = 520833333333333 + 12056327160 * 864000;
    uint256 private _perBlockMin = 520833333333333;
    uint256 private _perBlockLast;
    uint256 private _rewardPerLP;
    uint256 private _lastRewardBlock;
    uint256 private _rewardTotal;
    uint256 private _withdrawTotal;
    uint256 private _startRewardBlock;
    uint256 private _endRewardBlock;
    IERC20 private _LP;
    IERC20 private _MARS;
    IStake private _STAKE;
    event Deposit(
        address refer,
        address user,
        uint256 amount,
        uint256 amountTotal
    );
    event Relieve(
        address refer,
        address user,
        uint256 amount,
        uint256 amountTotal
    );
    event Withdraw(address user, uint256 amount);
    receive() external payable {}
    function withdrawETH() public onlyAdmin {
        payable(msg.sender).transfer(address(this).balance);
    }
    function withdrawToken(IERC20 token) public onlyAdmin {
        token.transfer(msg.sender, token.balanceOf(address(this)));
    }
    function setEndBlock(uint256 endBlock) public onlyAdmin {
        _endRewardBlock = endBlock;
    }
    function synchroInvite(uint256 startIndex, uint256 total) public onlyAdmin {
        for (uint256 i = startIndex; i < startIndex + total; i++) {
            address account = _STAKE.users(i);
            if (!userInfos[account].isExist) {
                IStake.UserInfo memory info = _STAKE.userInfos(account);
                address refer = info.refer;
                UserInfo storage user = userInfos[account];
                if (!user.isExist) {
                    user.isExist = true;
                    userTotal = userTotal.add(1);
                    users[userTotal] = account;
                }
                if (
                    user.refer == address(0) &&
                    refer != address(0) &&
                    refer != account
                ) {
                    user.refer = refer;
                    userInviteTotals[refer] = userInviteTotals[refer].add(1);
                    userInvites[refer][userInviteTotals[refer]] = account;
                }
            }
        }
    }
    constructor() {
        _lastRewardBlock = block.number;
        _LP = IERC20(0xE877E2F70BD980b2adA86f636401F220Df3B8686);
        _MARS = IERC20(0x2d0e4B21307b9C142150385121Ee19549002B27B);
        _STAKE = IStake(0x8362f230b6411D9f0bc3Df5E2e419dA02b8960D8);
    }
    function getRewardTotal() public view returns (uint256) {
        uint256 multiplier = _getMultiplier();
        uint256 cakeReward = getMultiplierReward(multiplier);
        return _rewardTotal.add(cakeReward);
    }
    function getWithdrawTotal() public view returns (uint256) {
        return _withdrawTotal;
    }
    function getRewardPerLP() public view returns (uint256) {
        uint256 accCakePerShare = _rewardPerLP;
        uint256 lpSupply = _LP.balanceOf(address(this));
        if (block.number > _lastRewardBlock && lpSupply != 0) {
            uint256 multiplier = _getMultiplier();
            uint256 cakeReward = getMultiplierReward(multiplier);
            accCakePerShare = accCakePerShare.add(
                cakeReward.mul(1e12).div(lpSupply)
            );
        }
        return accCakePerShare;
    }
    function getInvites(address account)
        public
        view
        returns (address[] memory invites)
    {
        invites = new address[](userInviteTotals[account]);
        for (uint256 i = 0; i < userInviteTotals[account]; i++) {
            invites[i] = userInvites[account][i + 1];
        }
    }
    function setToken(address token, address lp) public onlyAdmin {
        _LP = IERC20(lp);
        _MARS = IERC20(token);
    }
    function deposit(uint256 _amount, address refer) public {
        require(_LP.balanceOf(msg.sender) >= _amount, "Insufficient LP");
        require(msg.sender != refer, "Not Self");
        if (refer != address(0) && !userInfos[refer].isExist) {
            userInfos[refer] = UserInfo({
                isExist: true,
                balance: 0,
                rewardTotal: 0,
                amount: 0,
                rewardDebt: 0,
                inviteRewardBalance: 0,
                inviteRewardTotal: 0,
                refer: address(0)
            });
            userTotal = userTotal.add(1);
            users[userTotal] = refer;
        }
        UserInfo storage user = userInfos[msg.sender];
        updatePool();
        if (user.amount > 0) {
            uint256 pending = user.amount.mul(_rewardPerLP).div(1e12).sub(
                user.rewardDebt
            );
            if (pending > 0) {
                user.balance = user.balance.add(pending);
                user.rewardTotal = user.rewardTotal.add(pending);
            }
        }
        if (_amount > 0) {
            _LP.transferFrom(msg.sender, address(this), _amount);
            user.amount = user.amount.add(_amount);
        }
        user.rewardDebt = user.amount.mul(_rewardPerLP).div(1e12);
        if (!user.isExist) {
            user.isExist = true;
            userTotal = userTotal.add(1);
            users[userTotal] = msg.sender;
        }
        if (
            user.refer == address(0) &&
            refer != address(0) &&
            refer != msg.sender
        ) {
            user.refer = refer;
            userInviteTotals[refer] = userInviteTotals[refer].add(1);
            userInvites[refer][userInviteTotals[refer]] = msg.sender;
        }
        emit Deposit(user.refer, msg.sender, _amount, user.amount);
    }
    function relieve(uint256 _amount) public {
        UserInfo storage user = userInfos[msg.sender];
        require(user.amount >= _amount, "withdraw: not good");
        updatePool();
        uint256 pending = user.amount.mul(_rewardPerLP).div(1e12).sub(
            user.rewardDebt
        );
        if (pending > 0) {
            user.balance = user.balance.add(pending);
            user.rewardTotal = user.rewardTotal.add(pending);
        }
        if (_amount > 0) {
            user.amount = user.amount.sub(_amount);
            _LP.transfer(msg.sender, _amount);
        }
        user.rewardDebt = user.amount.mul(_rewardPerLP).div(1e12);
        emit Relieve(user.refer, msg.sender, _amount, user.amount);
    }
    function withdraw() public {
        UserInfo storage user = userInfos[msg.sender];
        updatePool();
        uint256 pending = user.amount.mul(_rewardPerLP).div(1e12).sub(
            user.rewardDebt
        );
        if (pending > 0) {
            user.balance = user.balance.add(pending);
            user.rewardTotal = user.rewardTotal.add(pending);
        }
        user.rewardDebt = user.amount.mul(_rewardPerLP).div(1e12);
        if (user.inviteRewardBalance > 0) {
            _MARS.transfer(msg.sender, user.inviteRewardBalance);
        }
        uint256 amount = user.balance;
        if (user.balance > 0) {
            _MARS.transfer(msg.sender, user.balance);
        }
        _withdrawTotal = _withdrawTotal.add(
            user.balance.add(user.inviteRewardBalance)
        );
        user.balance = 0;
        user.inviteRewardBalance = 0;
        if (amount > 0 && user.refer != address(0)) {
            UserInfo storage parent = userInfos[user.refer];
            parent.inviteRewardBalance = parent.inviteRewardBalance.add(
                amount.div(10)
            );
            parent.inviteRewardTotal = parent.inviteRewardTotal.add(
                amount.div(10)
            );
            if (parent.refer != address(0)) {
                UserInfo storage superParent = userInfos[parent.refer];
                superParent.inviteRewardBalance = superParent
                    .inviteRewardBalance
                    .add(amount.div(10));
                superParent.inviteRewardTotal = superParent
                    .inviteRewardTotal
                    .add(amount.div(10));
            }
        }
    }
    function pendingReward(address _user) external view returns (uint256) {
        UserInfo memory user = userInfos[_user];
        uint256 accCakePerShare = _rewardPerLP;
        uint256 lpSupply = _LP.balanceOf(address(this));
        if (block.number > _lastRewardBlock && lpSupply != 0) {
            uint256 multiplier = _getMultiplier();
            uint256 cakeReward = getMultiplierReward(multiplier);
            accCakePerShare = accCakePerShare.add(
                cakeReward.mul(1e12).div(lpSupply)
            );
        }
        return
            user.amount.mul(accCakePerShare).div(1e12).sub(user.rewardDebt).add(
                user.balance
            );
    }
    function getUserRewardTotal(address _user) external view returns (uint256) {
        UserInfo memory user = userInfos[_user];
        uint256 accCakePerShare = _rewardPerLP;
        uint256 lpSupply = _LP.balanceOf(address(this));
        if (block.number > _lastRewardBlock && lpSupply != 0) {
            uint256 multiplier = _getMultiplier();
            uint256 cakeReward = getMultiplierReward(multiplier);
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
        if (_rewardTotal == 0) {
            _rewardTotal = _STAKE.getRewardTotal();
        }
        uint256 lpSupply = _LP.balanceOf(address(this));
        if (_startRewardBlock == 0) {
            _startRewardBlock = block.number;
            _endRewardBlock = _startRewardBlock.add(28800 * 550);
        }
        if (lpSupply == 0) {
            _lastRewardBlock = block.number;
            _perBlockLast = _perBlockMin;
            return;
        }
        uint256 multiplier = _getMultiplier();
        uint256 cakeReward;
        if (multiplier >= 30 * 28800) {
            cakeReward = multiplier.div(30 * 28800).mul(4950000000000000000000);
        }
        uint256 mod = multiplier.mod(30 * 28800);
        if (_perBlockLast.add(mod * _perBlockDiff) <= _perBlockMax) {
            cakeReward = cakeReward.add(
                ((_perBlockLast * 2 + mod * _perBlockDiff) / 2) * mod
            );
            _perBlockLast = _perBlockLast.add(mod * _perBlockDiff);
        } else {
            uint256 modDiff = (_perBlockMax.sub(_perBlockLast)).div(
                _perBlockDiff
            );
            cakeReward = cakeReward.add(
                ((_perBlockLast + _perBlockMax) / 2) * modDiff
            );
            cakeReward = cakeReward.add(
                ((_perBlockMin * 2 + (mod - modDiff) * _perBlockDiff) / 2) *
                    (mod - modDiff)
            );
            _perBlockLast = _perBlockMin.add((mod - modDiff) * _perBlockDiff);
        }
        _rewardTotal = _rewardTotal.add(cakeReward);
        _rewardPerLP = _rewardPerLP.add(cakeReward.mul(1e12).div(lpSupply));
        _lastRewardBlock = block.number;
        if (_rewardTotal >= 9_0000 * 1e18 && _endRewardBlock > block.number) {
            _endRewardBlock = block.number;
        }
    }
    function getMultiplierReward(uint256 multiplier)
        private
        view
        returns (uint256)
    {
        uint256 cakeReward;
        if (multiplier >= 30 * 28800) {
            cakeReward = multiplier.div(30 * 28800).mul(4950000000000000000000);
        }
        uint256 mod = multiplier.mod(30 * 28800);
        if (_perBlockLast.add(mod * _perBlockDiff) <= _perBlockMax) {
            cakeReward = cakeReward.add(
                ((_perBlockLast * 2 + mod * _perBlockDiff) / 2) * mod
            );
        } else {
            uint256 modDiff = (_perBlockMax.sub(_perBlockLast)).div(
                _perBlockDiff
            );
            cakeReward = cakeReward.add(
                ((_perBlockLast + _perBlockMax) / 2) * modDiff
            );
            cakeReward = cakeReward.add(
                ((_perBlockMin * 2 + (mod - modDiff) * _perBlockDiff) / 2) *
                    (mod - modDiff)
            );
        }
        return cakeReward;
    }
    function _getMultiplier() private view returns (uint256) {
        if (_endRewardBlock > block.number) {
            return block.number.sub(_lastRewardBlock);
        } else {
            return 0;
        }
    }
}