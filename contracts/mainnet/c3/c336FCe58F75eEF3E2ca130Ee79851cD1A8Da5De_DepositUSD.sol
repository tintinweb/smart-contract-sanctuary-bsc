// SPDX-License-Identifier: MIT
pragma solidity 0.8.14;

interface IUSD {
    function owner() external view returns (address);

    function minerTo() external view returns (address);

    function stakeTo() external view returns (address);

    function rewardTo() external view returns (address);

    function inviter(address account_) external view returns (address);
}

library TransferHelper {
    function safeTransfer(
        address token,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(
            abi.encodeWithSelector(0xa9059cbb, to, value)
        );
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "TransferHelper: TRANSFER_FAILED"
        );
    }

    function safeTransferFrom(
        address token,
        address from,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(
            abi.encodeWithSelector(0x23b872dd, from, to, value)
        );
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "TransferHelper: TRANSFER_FROM_FAILED"
        );
    }
}

interface IDepositUSD {
    function withdrawToken(
        address token_,
        address to_,
        uint256 amount_
    ) external;

    function stakeUsd(address account_, uint256 amount_) external;

    function unstakeUsd(address account_, uint256 amount_) external;

    function depositFee(uint256 amount_) external;

    function takeFee(address account_, uint256 amount_) external;

    function getFee() external view returns (uint256);

    function stakedOf(address account_) external view returns (uint256);

    function takeReward(
        address token_,
        string memory usefor,
        address account_,
        uint256 amount_
    ) external;

    function getReward(address token_, string memory usefor)
        external
        view
        returns (uint256);
}

// 存储合约只支持钱,不支持主动存钱
// 为了用户的安全性,在每次升级使用合约后,用户需重新授权
// 在使用合约里面收取token并发送到存储合约-无手续费
contract DepositUSD {
    address public usdAddress; // usd合约

    uint256 public totalStaked; //总质押
    mapping(address => uint256) public stakedOf; // 质押数量

    uint256 public totalFees; //总手续费
    uint256 public totalUsedFees; //已支付手续费
    uint256 public bonusReward; //分红奖励

    mapping(address => mapping(string => uint256)) public totalReward; //总奖励 reward[奖励token]
    //奖励使用情况 reward[奖励token][usefor] =》 支付奖励
    // usefor(string) invite(邀请奖励),,,,
    mapping(address => mapping(string => uint256)) public useforReward; //已支付奖励

    constructor(address usd_) {
        usdAddress = usd_;
    }

    modifier onlyUseFor() {
        require(
            msg.sender == minerTo() ||
                msg.sender == stakeTo() ||
                msg.sender == owner() ||
                msg.sender == rewardTo(),
            "caller can not be allowed"
        );
        _;
    }

    function withdrawToken(
        address token_,
        address to_,
        uint256 amount_
    ) external onlyUseFor {
        TransferHelper.safeTransfer(token_, to_, amount_);
    }

    function stakeUsd(address account_, uint256 amount_) external onlyUseFor {
        totalStaked += amount_;
        stakedOf[account_] += amount_;
    }

    function unstakeUsd(address account_, uint256 amount_) external onlyUseFor {
        totalStaked -= amount_;
        stakedOf[account_] -= amount_;
        TransferHelper.safeTransfer(usdAddress, account_, amount_);
    }

    // 获取可使用的奖励
    function getReward(address token_, string memory usefor)
        public
        view
        returns (uint256)
    {
        return totalReward[token_][usefor] - useforReward[token_][usefor];
    }

    // 请将存储合约加入奖励token白名单使用,以免除手续费溢出
    function depositReward(
        address token_,
        string memory usefor,
        uint256 amount_
    ) public {
        totalReward[token_][usefor] += amount_;
        TransferHelper.safeTransferFrom(
            token_,
            msg.sender,
            address(this),
            amount_
        );
    }

    // 使用奖励
    function takeReward(
        address token_,
        string memory usefor,
        address account_,
        uint256 amount_
    ) external onlyUseFor {
        require(getReward(token_, usefor) >= amount_, "not enough fee");
        useforReward[token_][usefor] += amount_;
        TransferHelper.safeTransfer(token_, account_, amount_);
    }

    function getFee() public view returns (uint256) {
        return totalFees - totalUsedFees;
    }

    function depositFee(uint256 amount_) external {
        if (msg.sender != usdAddress) {
            TransferHelper.safeTransferFrom(
                usdAddress,
                msg.sender,
                address(this),
                amount_
            );
        }
        totalFees += amount_;
    }

    function bonusFee(uint256 amount_) external onlyUseFor {
        require(getFee() >= amount_, "not enough fee");
        totalUsedFees += amount_;
        bonusReward += amount_;
    }

    function takeFee(address account_, uint256 amount_) external onlyUseFor {
        if (amount_ > bonusReward) {
            amount_ = bonusReward;
        }
        bonusReward -= amount_;
        TransferHelper.safeTransfer(usdAddress, account_, amount_);
    }

    function owner() public view returns (address) {
        return IUSD(usdAddress).owner();
    }

    function minerTo() public view returns (address) {
        return IUSD(usdAddress).minerTo();
    }

    function stakeTo() public view returns (address) {
        return IUSD(usdAddress).stakeTo();
    }

    function rewardTo() public view returns (address) {
        return IUSD(usdAddress).rewardTo();
    }
}

contract UpgradeMaster {
    uint256 public effectiveTime = 300; // 升级合约的有效时间

    address public owner; // 拥有者地址
    Upgrade public _minerTo; // 矿工合约地址
    Upgrade public _stakeTo; // 质押合约地址
    Upgrade public _rewardTo; // 奖励合约地址

    struct Upgrade {
        address prev; // 原合约地址
        address to; // 升级合约地址
        uint256 effectiveTime; // 生效时间
    }

    modifier onlyOwner() {
        require(owner == msg.sender, "caller is not the owner");
        _;
    }

    modifier onlyMiner() {
        require(minerTo() == msg.sender, "caller is not the miner");
        _;
    }

    function minerTo() public view returns (address) {
        return _getUpgradeTo(_minerTo);
    }

    function stakeTo() public view returns (address) {
        return _getUpgradeTo(_stakeTo);
    }

    function rewardTo() public view returns (address) {
        return _getUpgradeTo(_rewardTo);
    }

    function setEffectiveTime(uint256 newEffectiveTime) external onlyOwner {
        require(
            newEffectiveTime > effectiveTime,
            "new effective time is too short"
        );
        effectiveTime = newEffectiveTime;
    }

    function setOwner(address to) external onlyOwner {
        owner = to;
    }

    function setMinerTo(address to) external onlyOwner {
        _upgradeTo(_minerTo, to);
    }

    function setStakeTo(address to) external onlyOwner {
        _upgradeTo(_stakeTo, to);
    }

    function setRewardTo(address to) external onlyOwner {
        _upgradeTo(_rewardTo, to);
    }

    function _getUpgradeTo(Upgrade memory upgrade_)
        internal
        view
        returns (address)
    {
        if (block.timestamp >= upgrade_.effectiveTime) {
            return upgrade_.to;
        } else {
            return upgrade_.prev;
        }
    }

    function _upgradeTo(Upgrade storage upgrade_, address to) internal {
        // 第一次设置直接生效
        if (upgrade_.effectiveTime == 0) {
            upgrade_.to = to;
        }

        if (block.timestamp >= upgrade_.effectiveTime) {
            upgrade_.prev = upgrade_.to;
        }

        upgrade_.to = to;
        upgrade_.effectiveTime = block.timestamp + effectiveTime;
    }
}

contract TokenUSD is UpgradeMaster {
    string public name = "TokenUSD";
    string public symbol = "TokenUSD";
    uint8 public decimals = 18;
    uint256 public totalSupply = 0;
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    mapping(address => bool) public whiteFrom; // 转出白名单
    mapping(address => bool) public whiteTo; // 转入白名单
    mapping(address => bool) public blackFrom; // 转出黑名单

    mapping(address => address) public inviter; // 邀请人
    mapping(address => uint256) public inviteCount; // 邀请人数量

    uint256 public feeRate = 30; //转账手续费 feeRate / 10000 30
    uint256 public feeMax = 1e18; // 最高手续费 默认1U 1e18

    address public immutable depositAddress; // 存款合约地址

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed holder,
        address indexed spender,
        uint256 value
    );
    event BindInviter(address indexed _user, address indexed _inviter);

    constructor(
        string memory name_,
        string memory symbol_,
        uint8 decimals_
    ) {
        name = name_;
        symbol = symbol_;
        decimals = decimals_;
        owner = msg.sender;

        depositAddress = address(new DepositUSD(address(this)));

        // 初始化白名单
        whiteFrom[address(this)] = true;
        whiteTo[address(this)] = true;

        whiteFrom[depositAddress] = true;
        whiteTo[depositAddress] = true;
    }

    function transfer(address recipient, uint256 amount)
        external
        virtual
        returns (bool)
    {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function approve(address spender, uint256 amount)
        external
        virtual
        returns (bool)
    {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external virtual returns (bool) {
        uint256 currentAllowance = allowance[sender][msg.sender];
        require(
            currentAllowance >= amount,
            "ERC20: transfer amount exceeds allowance"
        );

        unchecked {
            _approve(sender, msg.sender, currentAllowance - amount);
        }

        _transfer(sender, recipient, amount);

        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue)
        external
        virtual
        returns (bool)
    {
        _approve(
            msg.sender,
            spender,
            allowance[msg.sender][spender] + addedValue
        );
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
        external
        virtual
        returns (bool)
    {
        uint256 currentAllowance = allowance[msg.sender][spender];
        require(
            currentAllowance >= subtractedValue,
            "ERC20: decreased allowance below zero"
        );
        unchecked {
            _approve(msg.sender, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(!blackFrom[sender], "ERC20: transfer from black list");
        // require(!blackFrom[to], "ERC20: transfer to black list");

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = balanceOf[sender];
        require(
            senderBalance >= amount,
            "ERC20: transfer amount exceeds balance"
        );
        unchecked {
            balanceOf[sender] = senderBalance - amount;
        }
        balanceOf[recipient] += amount;

        emit Transfer(sender, recipient, amount);

        _afterTokenTransfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");
        totalSupply += amount;
        balanceOf[account] += amount;
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");
        require(balanceOf[account] >= amount, "ERC20: burn more than balance");
        require(totalSupply >= amount, "ERC20: burn more than total supply");
        totalSupply -= amount;
        balanceOf[account] -= amount;
        emit Transfer(account, address(0), amount);
    }

    function _approve(
        address holder,
        address spender,
        uint256 amount
    ) internal virtual {
        require(holder != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        allowance[holder][spender] = amount;
        emit Approval(holder, spender, amount);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        if (whiteFrom[from] || whiteTo[to]) {
            return;
        }

        if (from == address(0) || to == address(0)) {
            return;
        }

        uint256 fee = (amount * feeRate) / 10000;
        if (fee > feeMax) {
            fee = feeMax;
        }

        //扣减手续费
        balanceOf[to] -= fee;
        //存入存款合约
        IDepositUSD(depositAddress).depositFee(fee);
        balanceOf[depositAddress] += fee;
        emit Transfer(to, depositAddress, fee);
    }

    function mint(address recipient, uint256 amount)
        external
        virtual
        onlyMiner
        returns (bool)
    {
        _mint(recipient, amount);
        return true;
    }

    function burn(address account, uint256 amount)
        external
        virtual
        onlyMiner
        returns (bool)
    {
        _burn(account, amount);
        return true;
    }

    // 绑定邀请人
    function setInviter(address inviter_) external virtual returns (bool) {
        require(inviter[msg.sender] == address(0), "already bind inviter");
        require(msg.sender != inviter_, "can't bind self");
        // 上级必须已经绑定过邀请人或者绑定管理员帐号
        require(
            inviter_ == owner || inviter[inviter_] != address(0),
            "inviter must be binded"
        );

        inviter[msg.sender] = inviter_;
        inviteCount[inviter_] += 1;
        emit BindInviter(msg.sender, inviter_);
        return true;
    }

    //设置黑名单
    function setBlackFrom(address addr, bool value) external onlyOwner {
        blackFrom[addr] = value;
    }

    //设置白名单
    function setWhite(
        address addr,
        bool from,
        bool to
    ) external onlyOwner {
        whiteFrom[addr] = from;
        whiteTo[addr] = to;
    }

    //设置手续费
    function setFeeMax(uint256 newFeeMax) external onlyOwner {
        feeMax = newFeeMax;
    }

    //设置手续费率
    function setFeeRate(uint256 newFeeRate) external onlyOwner {
        require(newFeeRate <= 10000, "fee rate error");
        feeRate = newFeeRate;
    }
}