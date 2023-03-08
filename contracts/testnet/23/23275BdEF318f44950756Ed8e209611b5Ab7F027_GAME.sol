// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

interface ISFC {
    function balanceOf(address account) external view returns (uint256);

    function mint(address account, uint256 amount) external returns (bool);

    function burn(address account, uint256 amount) external returns (bool);
}

library TransferHelper {
    function safeTransfer(address token, address to, uint256 value) internal {
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

contract GAME {
    string public constant name = "SFCGAME";
    string public constant symbol = "SFCGAME";

    address public owner;
    uint256 public totalReward;
    uint256 public pendingReward;
    uint256 public totalPower;
    uint256 public totalUsersAmount;
    mapping(address => uint256) public totalUserReward;

    bool public isMint = false;
    uint256 public constant MAX_TOTAL_POWER = 533000000 ether;
    uint256 public currentTotalPower;
    uint256 public epoch_base = 86400;
    uint256 public epoch = 300; // 86400
    uint256 public startMintAt;
    uint256 public maxPower = 4999;
    uint256 public minPowerRate = 980;
    uint256 public maxDays = 5;

    uint256 public constant tokenDecimals = 1 ether;
    address public immutable tokenAddr;
    address public burnTokenAddr;

    address public fundAddress = 0x000000000000000000000000000000000000dEaD;
    uint256 public burnTokenAmount;

    mapping(uint8 => GameConfig) public gameInfo;
    struct GameConfig {
        uint8 level;
        uint8 feeRate;
        uint8 rewardRate;
        uint8 inviteReward1;
        uint8 inviteReward2;
    }

    /* This creates an array with all balances */
    mapping(address => uint256) public amountOf;
    mapping(address => uint256) public userMaxPower;
    mapping(address => address) public invite;
    mapping(address => uint256) public power;
    mapping(address => uint256) public lastMiner;
    mapping(address => uint256) public inviteCount;
    mapping(address => uint256) public rewardCount;

    event EmitBindInviter(address indexed _user, address indexed _inviter);
    event EmitBurn(address indexed operator, uint256 amount);
    event EmitMinted(
        address indexed operator,
        address indexed to,
        uint256 amount
    );
    event EmitWithdrawalReward(address indexed src, uint256 wad);

    /* Initializes contract with initial supply tokens to the creator of the contract */
    constructor(address _tokenAddr) {
        owner = payable(msg.sender);
        tokenAddr = _tokenAddr;
        initGame();
    }

    modifier onlyOwner() {
        require(owner == msg.sender, "caller is not the owner");
        _;
    }

    function initGame() private {
        setGameConfig(1, 99, 20, 20, 0);
        setGameConfig(2, 20, 50, 50, 10);
        setGameConfig(3, 18, 55, 60, 20);
        setGameConfig(4, 15, 60, 70, 35);
        setGameConfig(5, 12, 65, 80, 40);
        setGameConfig(6, 10, 65, 90, 50);
    }

    function setGameConfig(
        uint8 _level,
        uint8 _feeRate,
        uint8 _rewardRate,
        uint8 _inviteReward1,
        uint8 _inviteReward2
    ) public {
        require(
            msg.sender == owner || msg.sender == address(this),
            "caller is not the owner"
        );
        gameInfo[_level] = GameConfig(
            _level,
            _feeRate,
            _rewardRate,
            _inviteReward1,
            _inviteReward2
        );
    }

    function withdrawToken(
        address token,
        address to,
        uint256 amount
    ) external onlyOwner {
        TransferHelper.safeTransfer(token, to, amount);
    }

    function setFundAddr(address _newAddr) external onlyOwner {
        fundAddress = _newAddr;
    }

    function setMaxPower(uint256 _value) external onlyOwner {
        maxPower = _value;
    }

    function setMinPowerRate(uint256 _value) external onlyOwner {
        minPowerRate = _value;
    }

    function startMint() external onlyOwner {
        isMint = true;
        startMintAt = block.timestamp;
    }

    function setMaxDays(uint256 _value) external onlyOwner {
        maxDays = _value;
    }

    function setOwner(address payable new_owner) external onlyOwner {
        owner = new_owner;
    }

    function setburnTokenAmount(uint256 _value) external onlyOwner {
        burnTokenAmount = _value;
    }

    function setBurnTokenAddr(address _burnToken) external onlyOwner {
        burnTokenAddr = _burnToken;
    }

    function burn(uint256 _value) external returns (bool success) {
        require(_value > 0, "amount is zero");
        require(
            power[msg.sender] + _value * 3 <= maxPower * tokenDecimals,
            "maxPower overflow"
        );

        uint256 balance = ISFC(tokenAddr).balanceOf(msg.sender);

        if (
            isMint &&
            power[msg.sender] > 0 &&
            block.timestamp - lastMiner[msg.sender] >= epoch
        ) {
            uint256 _reward = getMaxReward(msg.sender);
            if (_reward > 0) {
                doMint(msg.sender);
            } else {
                lastMiner[msg.sender] = block.timestamp;
            }
        }

        require(balance + amountOf[msg.sender] >= _value, "amount too many");

        extraBurnToken(_value);

        if (amountOf[msg.sender] > _value) {
            amountOf[msg.sender] -= _value;
            pendingReward -= _value;
        } else {
            uint256 sub_value = _value - amountOf[msg.sender];
            pendingReward -= amountOf[msg.sender];
            amountOf[msg.sender] = 0;
            ISFC(tokenAddr).burn(msg.sender, sub_value);
        }

        _addPower(_value, msg.sender);

        emit EmitBurn(msg.sender, _value);
        return true;
    }

    function exchangePower(
        address _account,
        uint256 _value
    ) external returns (bool success) {
        require(_value > 0, "amount is zero");

        if (
            isMint &&
            power[_account] > 0 &&
            block.timestamp - lastMiner[_account] >= epoch
        ) {
            uint256 _reward = getMaxReward(_account);
            if (_reward > 0) {
                doMint(_account);
            } else {
                lastMiner[_account] = block.timestamp;
            }
        }

        require(
            power[_account] + _value * 3 <= maxPower * tokenDecimals,
            "maxPower overflow"
        );

        extraBurnToken(_value);

        ISFC(tokenAddr).burn(msg.sender, _value);
        _addPower(_value, _account);

        emit EmitBurn(msg.sender, _value);
        return true;
    }

    function _addPower(uint256 _value, address _account) private {
        uint256 addPower = _value * 3;
        currentTotalPower += addPower;
        require(MAX_TOTAL_POWER >= currentTotalPower, "MAX_TOTAL_POWER ERROR");
        power[_account] += addPower;
        totalPower += addPower;

        if (power[_account] > userMaxPower[_account]) {
            userMaxPower[_account] = power[_account];
        }

        _uplineReward(_account, _value);
    }

    function _uplineReward(
        address _account,
        uint256 _value
    ) private returns (bool success) {
        address invite1 = invite[_account];
        if (invite1 != address(0)) {
            uint8 lv = getPowerLv(invite1);
            uint8 scale = gameInfo[lv].inviteReward1;
            uint256 maxReward = getMaxReward(invite1);

            if (maxReward > 0 && scale > 0) {
                uint256 reward = (_value * scale) / 1000;

                if (reward > maxReward) {
                    reward = maxReward;
                }

                power[invite1] -= reward;
                totalPower -= reward;
                rewardCount[invite1] += reward;
                _mint(invite1, reward);
            }

            address invite2 = invite[invite1];
            if (invite2 != address(0)) {
                lv = getPowerLv(invite2);
                scale = gameInfo[lv].inviteReward2; // n/1000
                maxReward = getMaxReward(invite2);
                if (maxReward > 0 && scale > 0) {
                    uint256 reward = (_value * scale) / 1000;

                    if (reward > maxReward) {
                        reward = maxReward;
                    }

                    power[invite2] -= reward;
                    totalPower -= reward;
                    rewardCount[invite2] += reward;
                    _mint(invite2, reward);
                }
            }
        }
        return true;
    }

    function withdrawReward(uint256 _value) external returns (bool) {
        require(_value > 0, "amount is zero error");
        uint256 taxFee = transfer_fee(msg.sender, _value);

        require(amountOf[msg.sender] >= _value, "balanceOf error");
        amountOf[msg.sender] -= _value;
        pendingReward -= _value;

        ISFC(tokenAddr).mint(msg.sender, _value);
        if (taxFee > 0) {
            TransferHelper.safeTransferFrom(
                tokenAddr,
                msg.sender,
                fundAddress,
                taxFee
            );
        }

        emit EmitWithdrawalReward(msg.sender, _value);
        return true;
    }

    function extraBurnToken(uint256 burnAmount_) private {
        if (burnAmount_ > 0 && burnTokenAmount > 0) {
            TransferHelper.safeTransferFrom(
                burnTokenAddr,
                msg.sender,
                fundAddress,
                (burnTokenAmount * burnAmount_) / 10000
            );
        }
    }

    function registration(address invite_) external returns (bool success) {
        require(invite[msg.sender] == address(0), "repeat registration");
        require(msg.sender != invite_, "not self");
        require(
            invite_ == owner || invite[invite_] != address(0),
            "The inviter must have been bound"
        );

        invite[msg.sender] = invite_;
        inviteCount[invite_] += 1;
        emit EmitBindInviter(msg.sender, invite_);
        return true;
    }

    function rewardAmount(address _account) public view returns (uint256) {
        uint256 reward;
        if (block.timestamp - lastMiner[_account] >= epoch) {
            uint8 lv = getPowerLv(_account);
            uint8 scale = gameInfo[lv].rewardRate;

            uint256 maxReward = getMaxReward(_account);
            if (scale > 0 && maxReward > 0) {
                uint256 miner_days = (block.timestamp - lastMiner[_account]) /
                    epoch;

                if (lv == 1 || lastMiner[_account] == 0) {
                    miner_days = 1;
                } else if (miner_days > maxDays) {
                    miner_days = maxDays;
                }

                reward = (power[_account] * miner_days * scale) / 10000;
                if (reward > maxReward) {
                    reward = maxReward;
                }
            }
        }

        return reward;
    }

    function update_epoch() private returns (bool success) {
        epoch = epoch_base + (block.timestamp - startMintAt) / 365;
        return true;
    }

    function mint() external returns (bool success) {
        require(getMaxReward(msg.sender) > 0, "power is not enough");
        doMint(msg.sender);
        return true;
    }

    function doMint(address _account) private {
        require(isMint, "not start mint");
        require(power[_account] > 0, "power is zero");

        require(
            block.timestamp - lastMiner[_account] >= epoch,
            "last_miner error"
        );

        uint256 reward = rewardAmount(_account);
        require(reward > 0, "reward is zero");

        update_epoch();
        lastMiner[_account] = block.timestamp;
        power[_account] -= reward;
        totalPower -= reward;
        _mint(_account, reward);
    }

    function transfer_fee(
        address _from,
        uint256 _value
    ) public view returns (uint256 fee) {
        uint8 lv = getPowerLv(_from);
        uint8 scale = gameInfo[lv].feeRate;
        if (scale == 0) {
            return 0;
        }
        uint256 _fee = (_value * scale) / 100;
        return _fee;
    }

    function _mint(address account, uint256 amount) private {
        require(account != address(0), "mint to the zero address");
        totalReward += amount;
        pendingReward += amount;
        amountOf[account] += amount;
        totalUserReward[account] += amount;
        emit EmitMinted(address(this), account, amount);
    }

    function getPowerLv(address account_) public view returns (uint8 Lv) {
        Lv = 1;
        uint256 _power = power[account_];
        if (_power < 500 * tokenDecimals) {
            Lv = 1;
        } else if (_power < 2000 * tokenDecimals) {
            Lv = 2;
        } else if (_power < 5000 * tokenDecimals) {
            Lv = 3;
        } else if (_power < 10000 * tokenDecimals) {
            Lv = 4;
        } else if (_power < 20000 * tokenDecimals) {
            Lv = 5;
        } else if (_power >= 20000 * tokenDecimals) {
            Lv = 6;
        }
    }

    function getMaxReward(address account_) public view returns (uint256) {
        uint256 minPower = (userMaxPower[account_] * minPowerRate) / 1000;
        if (minPower > power[account_]) {
            return 0;
        }
        return power[account_] - minPower;
    }
}