/**
 *Submitted for verification at BscScan.com on 2022-07-06
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

interface ISwapPair {
    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint256);
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;
    function MINIMUM_LIQUIDITY() external pure returns (uint256);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves()
        external
        view
        returns (
            uint112 reserve0,
            uint112 reserve1,
            uint32 blockTimestampLast
        );
    function price0CumulativeLast() external view returns (uint256);
    function price1CumulativeLast() external view returns (uint256);
    function kLast() external view returns (uint256);
    function mint(address to) external returns (uint256 liquidity);
    function burn(address to)
        external
        returns (uint256 amount0, uint256 amount1);
    function swap(
        uint256 amount0Out,
        uint256 amount1Out,
        address to,
        bytes calldata data
    ) external;
    function skim(address to) external;
    function sync() external;
    function initialize(address, address) external;
}

interface ISwapFactory {
    function getPair(address tokenA, address tokenB)
        external
        view
        returns (address pair);
    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);
}

interface ISwapRouter {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    function getAmountsOut(uint256 amountIn, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);
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

contract Stake is Ownable {
    using SafeMath for uint256;
    using Address for address;
    struct UserInfo {
        bool isExist;
        uint256 speed;
        uint256 amount;
        uint256 amountActual;
        uint256 lastTime;
        uint256 rewardBalance;
        uint256 rewardTotal;
        uint256 rewardTotalBak;
        uint256 rewardPerBlock;
        uint256 rewardLastBlock;
        uint256 inviteBalance;
        uint256 inviteTotal;
        uint256 inviteValid;
        address refer;
    }
    mapping(address => mapping(uint256 => address)) public inviteUsers;
    mapping(address => uint256) public inviteTotal;
    mapping(address => UserInfo) public users;
    mapping(uint256 => address) public userAdds;
    uint256 public userTotal;
    uint256 public stakeTotal;
    uint256 private _withdrawTotal;
    uint256 private _withdrawInviteTotal;
    uint256 private _taxFee;
    uint256 private _maxAmount = 2000 * 10**18;
    uint256 private _minAmount = 20 * 10**18;
    uint256 private _blockDay = 20332420;
    address private _teamAddress;
    address private _msdPair;
    address private _dead = 0x000000000000000000000000000000000000dEaD;
    ISwapRouter private _swapRouter;
    IERC20 private _USDT;
    IERC20 private _MSD;
    event Deposit(address user, uint256 amount, uint256 amountMSD);
    event Relieve(address user, uint256 amount);
    event ManagerFee(address user, uint256 amount);
    event Withdraw(address user, uint256 amount);
    event WithdrawInvite(address user, uint256 amount);
    receive() external payable {}
    function withdrawETH() public onlyAdmin {
        payable(msg.sender).transfer(address(this).balance);
    }
    function withdrawToken(IERC20 token) public onlyAdmin {
        token.transfer(msg.sender, token.balanceOf(address(this)));
    }
    constructor() {
        _teamAddress = 0x717b570377E9E3163E8B616eF67Dae28CF34A9c6;
        _msdPair = 0xa1de02571c0c4cF76312d848c4D258ae9b101DA9;
        _USDT = IERC20(0x55d398326f99059fF775485246999027B3197955);
        _MSD = IERC20(0x4b21439bbe6fc7Dc57387B206DbFdaBa04A5EC57);
        _swapRouter = ISwapRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        _blockDay = 18853870;
    }
    function getWithdrawTotal() public view returns (uint256) {
        return _withdrawTotal;
    }
    function getWithdrawInviteTotal() public view returns (uint256) {
        return _withdrawInviteTotal;
    }
    function getTaxFee() public view returns (uint256) {
        return _taxFee;
    }
    function setTaxFee(uint256 fee) public onlyAdmin {
        _taxFee = fee;
    }
    function getInvites(address account)
        public
        view
        returns (address[] memory invites)
    {
        invites = new address[](inviteTotal[account]);
        for (uint256 i = 0; i < inviteTotal[account]; i++) {
            invites[i] = inviteUsers[account][i + 1];
        }
    }
    function getPriceMSD() public view returns (uint256) {
        address[] memory path = new address[](2);
        path[0] = address(_MSD);
        path[1] = address(_USDT);
        (uint256 amount0, uint256 amount1, ) = ISwapPair(_msdPair)
            .getReserves();
        if (amount0 == 0 || amount1 == 0) {
            return 0;
        }
        return _swapRouter.getAmountsOut(1 * 10**18, path)[1];
    }
    function setToken(
        address token,
        address usdt,
        address pair,
        address teamAddress
    ) public onlyAdmin {
        _MSD = IERC20(token);
        _USDT = IERC20(usdt);
        _msdPair = pair;
        _teamAddress = teamAddress;
    }
    function depositUSDT(uint256 amount, address refer) public {
        require(refer != msg.sender, "Fail: Refer Not Self");
        require(_USDT.balanceOf(msg.sender) >= amount, "Insufficient USDT");
        _USDT.transferFrom(msg.sender, address(this), amount);
        stakeTotal = stakeTotal.add(amount);
        _deposit(amount, amount, refer);
    }
    function depositMSD(uint256 amount, address refer) public {
        require(refer != msg.sender, "Fail: Refer Not Self");
        require(_USDT.balanceOf(msg.sender) >= amount, "Insufficient MSD");
        _USDT.transferFrom(msg.sender, address(this), amount);
        uint256 amountMSD = amount.mul(1e18).div(getPriceMSD()).div(4);
        require(_MSD.balanceOf(msg.sender) >= amountMSD, "Insufficient MSD");
        _MSD.transferFrom(msg.sender, _dead, amountMSD);
        uint256 amountPower = amount.mul(10).div(8);
        stakeTotal = stakeTotal.add(amountPower);
        _deposit(amountPower, amount, refer);
    }
    function redeposit(address refer) public {
        updateUser(msg.sender);
        UserInfo storage user = users[msg.sender];
        uint256 amount = user.rewardBalance.add(user.inviteBalance);
        user.rewardBalance = 0;
        user.inviteBalance = 0;
        _deposit(amount, amount, refer);
    }
    function relieve() public {
        require(
            users[msg.sender].lastTime < block.timestamp - 86400,
            "Fail: No Relieve"
        );
        updateUser(msg.sender);
        UserInfo storage user = users[msg.sender];
        uint256 amount = user.amountActual;
        stakeTotal = stakeTotal.sub(amount);
        emit Relieve(msg.sender, amount);
        {
            uint256 rewPer = amount.mul(5).div(1000);
            if (user.refer != address(0)) {
                UserInfo storage reUser = users[user.refer];
                reUser.inviteBalance = reUser.inviteBalance.add(rewPer.mul(4));
                reUser.inviteTotal = reUser.inviteTotal.add(rewPer.mul(4));
                address referAdd = reUser.refer;
                for (uint256 i = 1; i < 7; i++) {
                    if (referAdd != address(0)) {
                        UserInfo storage _ur = users[referAdd];
                        _ur.inviteBalance = _ur.inviteBalance.add(rewPer);
                        _ur.inviteTotal = _ur.inviteTotal.add(rewPer);
                        referAdd = _ur.refer;
                    } else {
                        UserInfo storage _ur = users[_teamAddress];
                        _ur.inviteBalance = _ur.inviteBalance.add(rewPer);
                        _ur.inviteTotal = _ur.inviteTotal.add(rewPer);
                    }
                }
            } else {
                UserInfo storage _ur = users[_teamAddress];
                _ur.inviteBalance = _ur.inviteBalance.add(rewPer.mul(10));
                _ur.inviteTotal = _ur.inviteTotal.add(rewPer.mul(10));
            }
            amount = amount.sub(rewPer.mul(10));
        }
        uint256 feeManager = amount.mul(_taxFee).div(100);
        _USDT.transfer(msg.sender, amount.sub(feeManager));
        if (user.amount >= 200 * 10**18 && user.refer != address(0)) {
            UserInfo storage superUser = users[user.refer];
            superUser.inviteValid = superUser.inviteValid.sub(1);
            if (superUser.inviteValid < 10 && superUser.speed >= 1) {
                superUser.speed = 0;
                updateUser(user.refer);
                superUser.rewardPerBlock = superUser
                    .amount
                    .mul(25 + 5 * superUser.speed)
                    .div(28800 * 1000);
            } else if (
                superUser.inviteValid >= 10 &&
                superUser.inviteValid < 20 &&
                superUser.speed >= 2
            ) {
                superUser.speed = 1;
                updateUser(user.refer);
                superUser.rewardPerBlock = superUser
                    .amount
                    .mul(25 + 5 * superUser.speed)
                    .div(28800 * 1000);
            }
        }
        user.amount = 0;
        user.amountActual = 0;
        user.rewardTotal = 0;
        user.rewardPerBlock = 0;
        user.rewardLastBlock = block.number;
        emit ManagerFee(msg.sender, feeManager);
    }
    function withdraw() public {
        UserInfo storage user = users[msg.sender];
        updateUser(msg.sender);
        if (user.rewardBalance > 0) {
            emit Withdraw(msg.sender, user.rewardBalance);
            _withdrawTotal = _withdrawTotal.add(user.rewardBalance);
            uint256 feeManager = user.rewardBalance.mul(_taxFee).div(100);
            _USDT.transfer(msg.sender, user.rewardBalance.sub(feeManager));
            user.rewardBalance = 0;
            emit ManagerFee(msg.sender, feeManager);
        }
    }
    function withdrawInvite() public {
        UserInfo storage user = users[msg.sender];
        require(user.inviteBalance > 0, "Fail: No Balance");
        if (user.inviteBalance > 0) {
            emit WithdrawInvite(msg.sender, user.inviteBalance);
            _withdrawInviteTotal = _withdrawInviteTotal.add(user.inviteBalance);
            uint256 feeManager = user.inviteBalance.mul(_taxFee).div(100);
            _USDT.transfer(msg.sender, user.inviteBalance.sub(feeManager));
            user.inviteBalance = 0;
            emit ManagerFee(msg.sender, feeManager);
        }
    }
    function withdrawAll() public {
        UserInfo storage user = users[msg.sender];
        updateUser(msg.sender);
        if (user.rewardBalance > 0) {
            emit Withdraw(msg.sender, user.rewardBalance);
            _withdrawTotal = _withdrawTotal.add(user.rewardBalance);
            uint256 feeManager = user.rewardBalance.mul(_taxFee).div(100);
            _USDT.transfer(msg.sender, user.rewardBalance.sub(feeManager));
            user.rewardBalance = 0;
            emit ManagerFee(msg.sender, feeManager);
        }
        if (user.inviteBalance > 0) {
            emit WithdrawInvite(msg.sender, user.inviteBalance);
            _withdrawInviteTotal = _withdrawInviteTotal.add(user.inviteBalance);
            uint256 feeManager = user.inviteBalance.mul(_taxFee).div(100);
            _USDT.transfer(msg.sender, user.inviteBalance.sub(feeManager));
            user.inviteBalance = 0;
            emit ManagerFee(msg.sender, feeManager);
        }
    }
    function pendingReward(address account) external view returns (uint256) {
        UserInfo memory user = users[account];
        uint256 reward = user.rewardPerBlock.mul(
            (block.number.sub(user.rewardLastBlock))
        );
        if (user.rewardTotal.add(reward) > user.amount.mul(3 + user.speed)) {
            reward = user.amount.mul(3 + user.speed).sub(user.rewardTotal);
        }
        return reward.add(user.rewardBalance);
    }
    function pendingRewardDay(address account) external view returns (uint256) {
        UserInfo memory user = users[account];
        uint256 rewardToday = user.rewardPerBlock.mul(
            (block.number.sub(_blockDay).mod(28800))
        );
        uint256 reward = user.rewardPerBlock.mul(
            (block.number.sub(user.rewardLastBlock))
        );
        if (user.rewardTotal.add(reward) > user.amount.mul(3 + user.speed)) {
            reward = user.amount.mul(3 + user.speed).sub(user.rewardTotal);
        }
        if (reward > rewardToday) return rewardToday;
        return reward;
    }
    function getUserRewardTotal(address account)
        external
        view
        returns (uint256)
    {
        UserInfo memory user = users[account];
        uint256 reward = user.rewardPerBlock.mul(
            (block.number.sub(user.rewardLastBlock))
        );
        if (user.rewardTotal.add(reward) > user.amount.mul(3 + user.speed)) {
            reward = user.amount.mul(3 + user.speed).sub(user.rewardTotal);
        }
        return reward.add(user.rewardTotal);
    }
    function updateUser(address account) public {
        UserInfo storage user = users[account];
        if (user.amount > 0) {
            uint256 reward = user.rewardPerBlock.mul(
                (block.number.sub(user.rewardLastBlock))
            );
            if (
                user.rewardTotal.add(reward) > user.amount.mul(3 + user.speed)
            ) {
                reward = user.amount.mul(3 + user.speed).sub(user.rewardTotal);
            }
            user.rewardBalance = user.rewardBalance.add(reward);
            user.rewardTotal = user.rewardTotal.add(reward);
            user.rewardTotalBak = user.rewardTotalBak.add(reward);
        }
        user.rewardLastBlock = block.number;
    }
    function _deposit(
        uint256 amount,
        uint256 amountActual,
        address refer
    ) private {
        if (refer != address(0) && !users[refer].isExist) {
            users[refer] = UserInfo({
                isExist: true,
                speed: 0,
                amount: 0,
                amountActual: 0,
                lastTime: 0,
                rewardBalance: 0,
                rewardTotal: 0,
                rewardTotalBak: 0,
                rewardPerBlock: 0,
                rewardLastBlock: 0,
                inviteBalance: 0,
                inviteTotal: 0,
                inviteValid: 0,
                refer: address(0)
            });
            userTotal = userTotal.add(1);
            userAdds[userTotal] = refer;
        }
        updateUser(msg.sender);
        UserInfo storage user = users[msg.sender];
        {
            require(user.amount.add(amount) >= _minAmount, "Fail: Lt Min");
            require(user.amount.add(amount) <= _maxAmount, "Fail: Gt Max");
            user.amount = user.amount.add(amount);
            user.amountActual = user.amountActual.add(amountActual);
            user.rewardPerBlock = user.amount.mul(25 + 5 * user.speed).div(
                28800 * 1000
            );
            user.lastTime = block.timestamp;
        }
        if (!user.isExist) {
            user.isExist = true;
            userTotal = userTotal.add(1);
            userAdds[userTotal] = msg.sender;
        }
        if (user.refer == address(0) && refer != address(0)) {
            user.refer = refer;
            inviteTotal[refer] = inviteTotal[refer].add(1);
            inviteUsers[refer][inviteTotal[refer]] = msg.sender;
        }
        {
            uint256 rewPer = amountActual.mul(5).div(1000);
            if (user.refer != address(0)) {
                UserInfo storage reUser = users[user.refer];
                reUser.inviteBalance = reUser.inviteBalance.add(rewPer.mul(4));
                reUser.inviteTotal = reUser.inviteTotal.add(rewPer.mul(4));
                address referAdd = reUser.refer;
                for (uint256 i = 1; i < 7; i++) {
                    if (referAdd != address(0)) {
                        UserInfo storage _ur = users[referAdd];
                        _ur.inviteBalance = _ur.inviteBalance.add(rewPer);
                        _ur.inviteTotal = _ur.inviteTotal.add(rewPer);
                        referAdd = _ur.refer;
                    } else {
                        UserInfo storage _ur = users[_teamAddress];
                        _ur.inviteBalance = _ur.inviteBalance.add(rewPer);
                        _ur.inviteTotal = _ur.inviteTotal.add(rewPer);
                    }
                }
            } else {
                UserInfo storage _ur = users[_teamAddress];
                _ur.inviteBalance = _ur.inviteBalance.add(rewPer.mul(10));
                _ur.inviteTotal = _ur.inviteTotal.add(rewPer.mul(10));
            }
        }
        {
            _USDT.transfer(_teamAddress, amountActual.mul(48).div(1000));
        }
        if (
            user.amount >= 200 * 10**18 &&
            user.amount.sub(amount) < 200 * 10**18 &&
            user.refer != address(0)
        ) {
            UserInfo storage superUser = users[user.refer];
            superUser.inviteValid = superUser.inviteValid.add(1);
            if (superUser.inviteValid >= 20 && superUser.speed < 2) {
                superUser.speed = 2;
                updateUser(user.refer);
                superUser.rewardPerBlock = superUser
                    .amount
                    .mul(25 + 5 * superUser.speed)
                    .div(28800 * 1000);
            } else if (superUser.inviteValid >= 10 && superUser.speed < 1) {
                superUser.speed = 1;
                updateUser(user.refer);
                superUser.rewardPerBlock = superUser
                    .amount
                    .mul(25 + 5 * superUser.speed)
                    .div(28800 * 1000);
            }
        }
        emit Deposit(msg.sender, amount, 0);
    }
}