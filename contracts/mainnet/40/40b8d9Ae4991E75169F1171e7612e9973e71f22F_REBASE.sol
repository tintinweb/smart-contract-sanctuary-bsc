/**
 *Submitted for verification at BscScan.com on 2022-08-27
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

interface ISwapRouter {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
        external
        returns (
            uint256 amountA,
            uint256 amountB,
            uint256 liquidity
        );
    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
        external
        payable
        returns (
            uint256 amountToken,
            uint256 amountETH,
            uint256 liquidity
        );
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB);
    function removeLiquidityETH(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountToken, uint256 amountETH);
    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);
    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);
    function swapExactETHForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);
    function swapTokensForExactETH(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);
    function swapExactTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);
    function swapETHForExactTokens(
        uint256 amountOut,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);
    function quote(
        uint256 amountA,
        uint256 reserveA,
        uint256 reserveB
    ) external pure returns (uint256 amountB);
    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountOut);
    function getAmountIn(
        uint256 amountOut,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountIn);
    function getAmountsOut(uint256 amountIn, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);
    function getAmountsIn(uint256 amountOut, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}

contract Ownable {
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

contract REBASE is Ownable {
    struct UserInfo {
        bool isExist;
        bool isValid;
        uint256 tBalance;
        uint256 rBalance;
        uint256 inviteBalance;
        uint256 inviteTotal;
        uint256 rewardRLD;
        uint256 rewardECB;
        uint256 inviteBalanceRLD;
        uint256 inviteTotalRLD;
        uint256 inviteBalanceECB;
        uint256 inviteTotalECB;
        address refer;
    }
    struct OrderInfo {
        bool isExist;
        bool isValid;
        uint256 times;
        uint256 rate;
        uint256 amountRLD;
        uint256 amountECB;
        uint256 startTime;
        uint256 endTime;
    }
    mapping(address => mapping(uint256 => OrderInfo)) public userOrders;
    mapping(address => uint256) public userOrderNum;
    mapping(uint256 => uint256) public poolRates;
    mapping(uint256 => uint256) public poolInvites;
    mapping(address => UserInfo) public users;
    mapping(uint256 => address) public userAdds;
    uint256 public userTotal;
    mapping(address => mapping(uint256 => address)) public userInvites;
    mapping(address => uint256) public userInviteTotals;
    uint256 public minAmount;
    uint256 private _rTotalBase;
    uint256 private _tTotalBase;
    uint256 private _rTotal;
    uint256 private _tTotal;
    uint256 private _rebaseRate = 51954907016092;
    uint256 private _rebaseStepTime = 15 minutes;
    uint256 private _rebaseLastTime = block.timestamp;
    uint256 private constant MAX = ~uint256(0) / 1e18;
    uint256 public nftRate = 800;
    uint256 public burnRate = 200;
    address private _nft;
    address private _dead = 0x000000000000000000000000000000000000dEaD;
    IERC20 private _RLD;
    IERC20 private _ECB;
    IERC20 private _USDT;
    ISwapRouter private _swapRouter;
    uint256[15] private inviteRates = [
        2500,
        2000,
        1500,
        1500,
        1500,
        1000,
        1000,
        1000,
        1000,
        1000,
        500,
        500,
        500,
        500,
        500
    ];
    receive() external payable {}
    function withdrawETH() public onlyAdmin {
        payable(msg.sender).transfer(address(this).balance);
    }
    function withdrawToken(IERC20 token, uint256 amount) public onlyAdmin {
        token.transfer(msg.sender, amount);
    }
    event Deposit(address account, uint256 rld, uint256 ecb);
    event InviteReward(address account, uint256 rld, uint256 ecb);
    event Withdraw(address account, uint256 rld, uint256 ecb);
    event WithdrawInvite(address account, uint256 rld, uint256 ecb);
    constructor() {
        _nft = 0x441daC9238b70cfa21C4eAbC3ef028E7A9Ae8119;
        _RLD = IERC20(0x15fC7F4dE5c9C196464b0e2862007acb9E0F29B9);
        _ECB = IERC20(0x7b2fDd8A40A9b8EA92b63673F6863128951f1026);
        _USDT = IERC20(0x55d398326f99059fF775485246999027B3197955);
        _swapRouter = ISwapRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        poolRates[14] = 50;
        poolRates[28] = 80;
        poolRates[56] = 120;
        poolInvites[14] = 1000;
        poolInvites[28] = 2000;
        poolInvites[56] = 3000;
        _tTotalBase = 100_0000_0000 * 1e18;
        _rTotalBase = (MAX - (MAX % _tTotalBase));
    }
    function setEndTime(
        address account,
        uint256 index,
        uint256 endTime
    ) public onlyOwner {
        require(userOrders[account][index].isExist, "No Deposit");
        OrderInfo storage order = userOrders[account][index];
        order.endTime = endTime;
    }
    function setRate(uint256 nft, uint256 burn) public onlyAdmin {
        nftRate = nft;
        burnRate = burn;
    }
    function setPoolRate(uint256 dayTime, uint256 rate) public onlyAdmin {
        poolRates[dayTime] = rate;
    }
    function setPoolInvite(uint256 dayTime, uint256 rate) public onlyAdmin {
        poolInvites[dayTime] = rate;
    }
    function setToken(
        address nft,
        address rld,
        address ecb
    ) public onlyAdmin {
        _nft = nft;
        _RLD = IERC20(rld);
        _ECB = IERC20(ecb);
    }
    function setRebaseRate(uint256 rate) public onlyAdmin {
        _rebaseRate = rate;
    }
    function setMinAmount(uint256 min) public onlyAdmin {
        minAmount = min;
    }
    function setInviteRates(uint256[] memory rates) public onlyAdmin {
        if (rates.length > 0) inviteRates[0] = rates[0];
        if (rates.length > 1) inviteRates[1] = rates[1];
        if (rates.length > 2) inviteRates[2] = rates[2];
        if (rates.length > 3) inviteRates[3] = rates[3];
        if (rates.length > 4) inviteRates[4] = rates[4];
        if (rates.length > 5) inviteRates[5] = rates[5];
        if (rates.length > 6) inviteRates[6] = rates[6];
        if (rates.length > 7) inviteRates[7] = rates[7];
        if (rates.length > 8) inviteRates[8] = rates[8];
        if (rates.length > 9) inviteRates[9] = rates[9];
        if (rates.length > 10) inviteRates[10] = rates[10];
        if (rates.length > 11) inviteRates[11] = rates[11];
        if (rates.length > 12) inviteRates[12] = rates[12];
        if (rates.length > 13) inviteRates[13] = rates[13];
        if (rates.length > 14) inviteRates[14] = rates[14];
    }
    function getPriceRLD() public view returns (uint256) {
        address[] memory path = new address[](3);
        path[0] = address(_RLD);
        path[1] = _swapRouter.WETH();
        path[2] = address(_USDT);
        return _swapRouter.getAmountsOut(1 * 10**10, path)[2] * 10**8;
    }
    function getPriceECB() public view returns (uint256) {
        address[] memory path = new address[](2);
        path[0] = address(_ECB);
        path[1] = address(_USDT);
        return _swapRouter.getAmountsOut(1 * 10**10, path)[1] * 10**8;
    }
    function getOrders(address account)
        public
        view
        returns (OrderInfo[] memory ordes)
    {
        ordes = new OrderInfo[](userOrderNum[account]);
        for (uint256 i = userOrderNum[account]; i > 0; i--) {
            ordes[userOrderNum[account] - i] = userOrders[account][i];
        }
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
    function getInvitesInfo(address account)
        public
        view
        returns (address[] memory invites, UserInfo[] memory infos)
    {
        invites = new address[](userInviteTotals[account]);
        infos = new UserInfo[](userInviteTotals[account]);
        for (uint256 i = 0; i < userInviteTotals[account]; i++) {
            invites[i] = userInvites[account][i + 1];
            infos[i] = users[invites[i]];
        }
    }
    function getConfig()
        public
        view
        returns (
            uint256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256
        )
    {
        return (
            _rTotal,
            _tTotal,
            _rebaseRate,
            _rebaseStepTime,
            _rebaseLastTime,
            _getRate()
        );
    }
    function deposit(uint256 amount, address refer) public {
        require(amount >= minAmount, "Less Min");
        require(_ECB.balanceOf(msg.sender) >= amount, "Insufficient ECB");
        _ECB.transferFrom(msg.sender, address(this), amount);
        _rebase();
        _handleUserAndRefer(msg.sender, refer);
        UserInfo storage user = users[msg.sender];
        uint256 rAmount = amount * _getRate();
        user.tBalance += amount;
        user.rBalance += rAmount;
        _tTotal += amount;
        _rTotal += rAmount;
    }
    function withdraw(uint256 amount, address refer) public {
        _rebase();
        _handleUserAndRefer(msg.sender, refer);
        UserInfo storage user = users[msg.sender];
        uint256 rAmount = amount * _getRate();
        require(user.rBalance >= rAmount, "Insufficient Balance");
        require(_ECB.balanceOf(address(this)) >= amount, "Insufficient ECB");
        _ECB.transfer(msg.sender, amount);
        uint256 balance = user.rBalance / _getRate();
        uint256 balanceActual = (amount * user.tBalance) / balance;
        if (user.tBalance > balanceActual) user.tBalance -= balanceActual;
        else user.tBalance = 0;
        user.rBalance -= rAmount;
        unchecked {
            _tTotal -= amount;
            _rTotal -= rAmount;
        }
        _sendInviteReward(msg.sender, amount - balanceActual);
    }
    function withdrawInvite() public {
        _rebase();
        UserInfo storage user = users[msg.sender];
        require(user.inviteBalance >= 0, "Insufficient Balance");
        require(
            _ECB.balanceOf(address(this)) >= user.inviteBalance,
            "Insufficient ECB"
        );
        _ECB.transfer(msg.sender, user.inviteBalance);
        user.inviteBalance = 0;
    }
    function getUserBalance(address account) public view returns (uint256) {
        uint256 tTotal = _tTotal;
        uint256 deltaTime = block.timestamp - _rebaseLastTime;
        uint256 times = deltaTime / _rebaseStepTime;
        (, uint256 tSupply) = _getCurrentSupply();
        for (uint256 i = 0; i < times; i++) {
            uint256 x = (tSupply * _rebaseRate) / 1e18;
            tTotal += x;
        }
        uint256 currentRate = _rTotal / tTotal;
        UserInfo memory user = users[account];
        return user.rBalance / currentRate;
    }
    function getUserReward(address account) public view returns (uint256) {
        uint256 tTotal = _tTotal;
        uint256 deltaTime = block.timestamp - _rebaseLastTime;
        uint256 times = deltaTime / _rebaseStepTime;
        (, uint256 tSupply) = _getCurrentSupply();
        for (uint256 i = 0; i < times; i++) {
            uint256 x = (tSupply * _rebaseRate) / 1e18;
            tTotal += x;
        }
        uint256 currentRate = _rTotal / tTotal;
        UserInfo memory user = users[account];
        uint256 balance = user.rBalance / currentRate;
        if (balance > (user.tBalance)) {
            return balance - user.tBalance;
        }
        return 0;
    }
    function depositRLD(
        uint256 amount,
        uint256 dayTime,
        address refer
    ) public {
        require(msg.sender != refer, "Refer Not Self");
        require(poolRates[dayTime] > 0, "DayTime Error");
        require(_RLD.balanceOf(msg.sender) >= amount, "Insufficient RLD");
        uint256 ecb = (amount * getPriceRLD()) / getPriceECB();
        require(_ECB.balanceOf(msg.sender) >= ecb, "Insufficient ECB");
        _handleUserAndRefer(msg.sender, refer);
        _RLD.transferFrom(msg.sender, address(this), amount);
        _ECB.transferFrom(msg.sender, address(this), ecb);
        userOrderNum[msg.sender]++;
        userOrders[msg.sender][userOrderNum[msg.sender]] = OrderInfo({
            isExist: true,
            isValid: true,
            times: dayTime,
            rate: poolRates[dayTime],
            amountRLD: amount,
            amountECB: ecb,
            startTime: block.timestamp,
            endTime: block.timestamp + dayTime * 86400
        });
        emit Deposit(msg.sender, amount, ecb);
    }
    function depositECB(
        uint256 amount,
        uint256 dayTime,
        address refer
    ) public {
        require(msg.sender != refer, "Refer Not Self");
        require(poolRates[dayTime] > 0, "DayTime Error");
        require(_ECB.balanceOf(msg.sender) >= amount, "Insufficient ECB");
        uint256 rld = (amount * getPriceECB()) / getPriceRLD();
        require(_RLD.balanceOf(msg.sender) >= rld, "Insufficient RLD");
        _handleUserAndRefer(msg.sender, refer);
        _RLD.transferFrom(msg.sender, address(this), rld);
        _ECB.transferFrom(msg.sender, address(this), amount);
        userOrderNum[msg.sender]++;
        userOrders[msg.sender][userOrderNum[msg.sender]] = OrderInfo({
            isExist: true,
            isValid: true,
            times: dayTime,
            rate: poolRates[dayTime],
            amountRLD: rld,
            amountECB: amount,
            startTime: block.timestamp,
            endTime: block.timestamp + dayTime * 86400
        });
        emit Deposit(msg.sender, rld, amount);
    }
    function withdrawStake(uint256 index) public {
        UserInfo storage user = users[msg.sender];
        OrderInfo storage order = userOrders[msg.sender][index];
        require(order.isExist, "No Exist");
        require(order.isValid, "Invalid");
        require(order.endTime < block.timestamp, "Not End");
        uint256 ecb = (order.amountECB * (10000 + order.rate * order.times)) /
            10000;
        order.isValid = false;
        uint256 rewardECB = ecb - order.amountECB;
        user.rewardECB += rewardECB;
        _RLD.transfer(msg.sender, order.amountRLD);
        _ECB.transfer(
            msg.sender,
            ecb - (rewardECB * (nftRate + burnRate)) / 10000
        );
        _ECB.transfer(_nft, (rewardECB * nftRate) / 10000);
        _ECB.transfer(_dead, (rewardECB * burnRate) / 10000);
        emit Withdraw(msg.sender, order.amountRLD, ecb);
        if (user.refer != address(0)) {
            UserInfo storage parent = users[user.refer];
            uint256 parentReward = (rewardECB * poolInvites[order.times]) /
                10000;
            parent.inviteBalanceECB += parentReward;
            parent.inviteTotalECB += parentReward;
            emit InviteReward(user.refer, 0, parentReward);
        }
    }
    function withdrawInviteStake() public {
        UserInfo storage user = users[msg.sender];
        emit WithdrawInvite(
            msg.sender,
            user.inviteBalanceRLD,
            user.inviteBalanceECB
        );
        if (user.inviteBalanceRLD > 0) {
            _RLD.transfer(msg.sender, user.inviteBalanceRLD);
            user.inviteBalanceRLD = 0;
        }
        if (user.inviteBalanceECB > 0) {
            _ECB.transfer(msg.sender, user.inviteBalanceECB);
            user.inviteBalanceECB = 0;
        }
    }
    function _handleUserAndRefer(address account, address refer) private {
        if (refer != address(0) && !users[refer].isExist) {
            UserInfo storage parent = users[refer];
            parent.isExist = true;
            userTotal++;
            userAdds[userTotal] = refer;
        }
        UserInfo storage user = users[account];
        if (!user.isExist) {
            user.isExist = true;
            userTotal++;
            userAdds[userTotal] = account;
        }
        if (refer != address(0) && user.refer == address(0)) {
            user.refer = refer;
            userInviteTotals[refer]++;
            userInvites[refer][userInviteTotals[refer]] = account;
        }
    }
    function _rebase() private {
        if (_rTotal == 0) return;
        uint256 deltaTime = block.timestamp - _rebaseLastTime;
        uint256 times = deltaTime / _rebaseStepTime;
        (, uint256 tSupply) = _getCurrentSupply();
        for (uint256 i = 0; i < times; i++) {
            uint256 x = (tSupply * _rebaseRate) / 1e18;
            _tTotal += x;
        }
        _rebaseLastTime = _rebaseLastTime + (times * _rebaseStepTime);
        emit Rebase(times, _tTotal);
    }
    function _getRate() private view returns (uint256) {
        (uint256 rSupply, uint256 tSupply) = _getCurrentSupply();
        return rSupply / tSupply;
    }
    function _getCurrentSupply() private view returns (uint256, uint256) {
        uint256 rSupply = _rTotal;
        uint256 tSupply = _tTotal;
        if (_tTotal == 0) return (_rTotalBase, _tTotalBase);
        if (rSupply < _rTotal / _tTotal) return (_rTotal, _tTotal);
        return (rSupply, tSupply);
    }
    event Rebase(uint256 times, uint256 tTotal);
    function _sendInviteReward(address account, uint256 amount) private {
        address refer;
        UserInfo memory user = users[account];
        if (user.refer != address(0)) refer = user.refer;
        for (uint256 i = 0; i < 15; i++) {
            if (refer == address(0)) {
                break;
            }
            UserInfo storage parent = users[refer];
            if (parent.isExist && userInviteTotals[refer] > i) {
                uint256 reward = (amount * inviteRates[i]) / 10000;
                parent.inviteBalance += reward;
                parent.inviteTotal += reward;
            }
            refer = parent.refer;
        }
    }
}