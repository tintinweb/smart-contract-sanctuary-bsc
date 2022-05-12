// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

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

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
}

contract ERC20 {
    string public name = "Fertilizer";
    string public symbol = "FERT";
    uint8 public decimals = 18;
    uint256 public totalSupply = 2000000 * 10**decimals;
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    address public owner;
    address public daoAddress;
    address public depositAddress;
    address public bckAddress;
    uint256 public baseBck = 1e18; //基础BCK
    uint256 public totalStaked; //总质押
    uint256 public rewardDuration = 120; //每天奖励一次 86400
    uint256 public rewardRate = 30; //奖励比例 30 / 10000000  每100W 产3个FERT
    mapping(address => uint256) public rewardAt; //上次领取奖励时间
    mapping(address => uint256) public stakedOf; // 质押数量
    mapping(address => uint256) public rewardOf; // 已领取奖励数量

    bool public isUpgrade = true; //是否升级

    // 质押事件
    event Staked(address indexed from, uint256 amount);
    // 取消质押事件
    event Unstaked(address indexed from, uint256 amount);
    // 领取奖励事件
    event Reward(address indexed to, uint256 amount);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed holder,
        address indexed spender,
        uint256 value
    );

    constructor(
        address depositAddress_,
        address dao_,
        address bckAddress_
    ) {
        owner = msg.sender;
        depositAddress = depositAddress_;
        bckAddress = bckAddress_;
        daoAddress = dao_;

        balanceOf[daoAddress] = totalSupply;
        emit Transfer(address(0), dao_, totalSupply);
    }

    modifier onlyOwner() {
        require(owner == msg.sender, "caller is not the owner");
        _;
    }

    function setOwner(address _owner) public onlyOwner {
        owner = _owner;
    }

    function closeUpgrade() public onlyOwner {
        isUpgrade = false;
    }

    function setDepositAddress(address _depositAddress) public onlyOwner {
        depositAddress = _depositAddress;
    }

    function setBckAddress(address _bckAddress) public onlyOwner {
        bckAddress = _bckAddress;
    }

    function setRewardDuration(uint256 _rewardDuration) public onlyOwner {
        rewardDuration = _rewardDuration;
    }

    function setRewardRate(uint256 _rewardRate) public onlyOwner {
        rewardRate = _rewardRate;
    }

    function airdrop(address[] memory addrlist, uint256[] memory amounts)
        public
        onlyOwner
    {
        require(addrlist.length > 0, "lsit empty error");
        for (uint256 i = 0; i < addrlist.length; i++) {
            address addr = addrlist[i];
            uint256 amount = amounts[i];
            balanceOf[addr] += amount;
            balanceOf[daoAddress] -= amount;
            emit Transfer(daoAddress, addr, amount);
        }
    }

    function upgradeStake(
        address[] memory addrlist,
        uint256[] memory stakeValue
    ) public onlyOwner {
        require(isUpgrade, "not upgrade");
        require(addrlist.length > 0, "lsit empty error");
        for (uint256 i = 0; i < addrlist.length; i++) {
            address addr = addrlist[i];
            uint256 amount = stakeValue[i];
            stakedOf[addr] += amount;
            totalStaked += amount;
            rewardAt[addr] = block.timestamp;
            emit Staked(addr, amount);
        }
    }

    // 质押
    function stake(uint256 amount) public virtual returns (bool) {
        require(amount > 0, "Staking: amount must be greater than 0");

        //自动领取上一次的收益
        if (stakedOf[msg.sender] > 0) {
            _reward();
        }

        //转入资产
        TransferHelper.safeTransferFrom(
            bckAddress,
            msg.sender,
            depositAddress,
            amount
        );

        stakedOf[msg.sender] += amount;
        totalStaked += amount;

        rewardAt[msg.sender] = block.timestamp;
        emit Staked(msg.sender, amount);
        return true;
    }

    // 取消质押
    function unstake(uint256 amount) public virtual returns (bool) {
        require(stakedOf[msg.sender] >= amount, "Staking: out of staked");

        stakedOf[msg.sender] -= amount;
        totalStaked -= amount;

        TransferHelper.safeTransferFrom(
            bckAddress,
            depositAddress,
            msg.sender,
            amount
        );

        emit Unstaked(msg.sender, amount);
        return true;
    }

    // 领取收益
    function reward() public virtual returns (bool) {
        require(stakedOf[msg.sender] > 0, "Staking: staked is 0");
        // 挖矿周期验证
        require(
            block.timestamp > rewardAt[msg.sender] + rewardDuration,
            "Staking: reward duration"
        );

        _reward();

        return true;
    }

    function _reward() private {
        uint256 rewards = rewardAmount(msg.sender);
        if (rewards > 0) {
            _mint(msg.sender, rewards);
            rewardOf[msg.sender] += rewards;
            rewardAt[msg.sender] = block.timestamp;
            emit Reward(msg.sender, rewards);
        }
    }

    // 计算应得奖励
    function rewardAmount(address _account)
        public
        view
        virtual
        returns (uint256)
    {
        if (block.timestamp > rewardAt[_account] + rewardDuration) {
            uint256 _days = (block.timestamp - rewardAt[_account]) /
                rewardDuration;

            if (_days > 7) {
                _days = 7; //单次最多领取7天的
            }

            if (rewardAt[_account] == 0) {
                _days = 1;
            }

            uint256 baseReward = (stakedOf[_account] * rewardRate * 1e18) /
                (10000000 * baseBck);

            return baseReward * _days;
        }
        return 0;
    }

    function transfer(address recipient, uint256 amount)
        public
        virtual
        returns (bool)
    {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function approve(address spender, uint256 amount)
        public
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
    ) public virtual returns (bool) {
        _transfer(sender, recipient, amount);

        uint256 currentAllowance = allowance[sender][msg.sender];
        require(
            currentAllowance >= amount,
            "ERC20: transfer amount exceeds allowance"
        );
        unchecked {
            _approve(sender, msg.sender, currentAllowance - amount);
        }

        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue)
        public
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
        public
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
    ) internal virtual {}
}