/**
 *Submitted for verification at BscScan.com on 2022-07-19
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.14;

interface INST {
    function balanceOf(address account) external view returns (uint256);

    function decimals() external view returns (uint8);

    function mint(address account, uint256 amount) external returns (bool);

    function burn(address account, uint256 amount) external returns (bool);
}

interface INFT {
    function activateCard(address account) external returns (uint256);

    function ownerOf(uint256 tokenId) external view returns (address);

    function cardPrice(uint256 tokenId) external view returns (uint256);

    function cardDurable(uint256 tokenId) external view returns (uint256);
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

contract NSTGAME {
    string public constant name = "NSTGAME";
    string public constant symbol = "NSTGAME";

    address public owner;
    uint256 public totalReward;
    uint256 public pendingReward;
    uint256 public totalDurable;
    uint256 public totalUsersAmount;
    mapping(address => uint256) public totalUserReward;

    bool public isMint = false;
    uint256 public epoch = 86400;
    uint256 public maxDurable = 4999;
    uint256 public minDurableRate = 980;
    uint256 public maxDays = 5;

    uint256 public immutable tokenDecimals;
    address public immutable tokenAddress;
    address public immutable nmtAddress;
    address public immutable nftAddress;
    address public constant usdAddress =
        0x1F20F26a747916FaB87C1Fe342fa4FA787f2B2BF;

    address public burnAddress = 0x0000000000000000000000000000000000000010;
    uint256 public burnTokenAmount = 1000;
    uint256 public basePrice = 1e18;

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
    mapping(address => uint256) public userCard;
    mapping(address => uint256) public userMaxDurable;
    mapping(address => address) public invite;
    mapping(address => uint256) public durable;
    mapping(address => uint256) public lastMiner;
    mapping(address => uint256) public inviteCount;
    mapping(address => uint256) public rewardCount;

    event StartGame(address indexed _master, uint256 _tokenId);
    event BindInviter(address indexed _user, address indexed _inviter);
    event Fixed(address indexed operator, uint256 amount);
    event Minted(address indexed operator, address indexed to, uint256 amount);
    event WithdrawalReward(address indexed src, uint256 wad);
    event Recharge(
        address indexed spender,
        address indexed account,
        uint256 amount
    );

    /* Initializes contract with initial supply tokens to the creator of the contract */
    constructor(
        address _tokenAddress,
        address _nmtAddress,
        address _nftAddress
    ) {
        owner = payable(msg.sender);
        tokenAddress = _tokenAddress;
        nmtAddress = _nmtAddress;
        nftAddress = _nftAddress;
        tokenDecimals = 10**INST(tokenAddress).decimals();

        initGame();
    }

    modifier onlyOwner() {
        require(owner == msg.sender, "caller is not the owner");
        _;
    }

    function initGame() private {
        setGameConfig(0, 50, 20, 0, 0);
        setGameConfig(1, 20, 50, 20, 5);
        setGameConfig(2, 16, 55, 30, 10);
        setGameConfig(3, 14, 60, 40, 15);
        setGameConfig(4, 12, 65, 50, 20);
        setGameConfig(5, 10, 65, 60, 20);
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

    function setBurnAddr(address _newAddr) external onlyOwner {
        burnAddress = _newAddr;
    }

    function setMaxDurable(uint256 _value) external onlyOwner {
        maxDurable = _value * tokenDecimals;
    }

    function setMinDurableRate(uint256 _value) external onlyOwner {
        minDurableRate = _value;
    }

    function startMint() external onlyOwner {
        isMint = true;
    }

    function setBasePrice(uint256 _value)
        external
        onlyOwner
        returns (bool success)
    {
        basePrice = _value;
        return true;
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

    function setUserLand(uint256 tokenId_, address account_)
        external
        onlyOwner
    {
        require(
            INFT(nftAddress).ownerOf(tokenId_) == account_,
            "not owner error"
        );
        userCard[account_] = tokenId_;
    }

    function setEpoch(uint256 _epoch)
        external
        onlyOwner
        returns (bool success)
    {
        epoch = _epoch;
        return true;
    }

    function startGame() external {
        require(userCard[msg.sender] == 0, "game has been start");

        uint256 tokenId_ = INFT(nftAddress).activateCard(msg.sender);
        uint256 _durable = INFT(nftAddress).cardDurable(tokenId_);
        require(_durable > 0, "durable is 0");

        totalDurable += _durable;
        totalUsersAmount++;
        userCard[msg.sender] = tokenId_;
        durable[msg.sender] += _durable;
        userMaxDurable[msg.sender] = _durable;
        emit StartGame(msg.sender, tokenId_);
    }

    function repair(uint256 _value) external returns (bool success) {
        require(userCard[msg.sender] > 0, "land status error");
        require(_value > 0, "amount is zero");
        require(
            durable[msg.sender] + _value * 3 <= maxDurable * tokenDecimals,
            "maxDurable overflow"
        );

        uint256 balance = INST(tokenAddress).balanceOf(msg.sender);

        if (
            isMint &&
            durable[msg.sender] > 0 &&
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
            INST(tokenAddress).burn(msg.sender, sub_value);
        }

        _addDurable(_value, msg.sender);

        emit Fixed(msg.sender, _value);
        return true;
    }

    function exchangeDurable(address _account, uint256 _value)
        external
        returns (bool success)
    {
        require(_value > 0, "amount is zero");

        if (
            isMint &&
            durable[_account] > 0 &&
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
            durable[_account] + _value * 3 <= maxDurable * tokenDecimals,
            "maxDurable overflow"
        );

        extraBurnToken(_value);

        INST(tokenAddress).burn(msg.sender, _value);
        _addDurable(_value, _account);

        emit Fixed(_account, _value);
        return true;
    }

    function _addDurable(uint256 _value, address _account) private {
        uint256 addDurable = _value * 3;
        durable[_account] += addDurable;
        totalDurable += addDurable;

        if (durable[_account] > userMaxDurable[_account]) {
            userMaxDurable[_account] = durable[_account];
        }

        _uplineReward(_account, _value);
    }

    function _uplineReward(address _account, uint256 _value)
        private
        returns (bool success)
    {
        address invite1 = invite[_account];
        if (invite1 != address(0)) {
            uint8 lv = getDurableLv(invite1);
            uint8 scale = gameInfo[lv].inviteReward1;
            uint256 maxReward = getMaxReward(invite1);

            if (maxReward > 0 && scale > 0) {
                uint256 reward = (_value * scale) / 1000;

                if (reward > maxReward) {
                    reward = maxReward;
                }

                durable[invite1] -= reward;
                totalDurable -= reward;
                rewardCount[invite1] += reward;
                _mint(invite1, reward);
            }

            address invite2 = invite[invite1];
            if (invite2 != address(0)) {
                lv = getDurableLv(invite2);
                scale = gameInfo[lv].inviteReward2; // n/1000
                maxReward = getMaxReward(invite2);
                if (maxReward > 0 && scale > 0) {
                    uint256 reward = (_value * scale) / 1000;

                    if (reward > maxReward) {
                        reward = maxReward;
                    }

                    durable[invite2] -= reward;
                    totalDurable -= reward;
                    rewardCount[invite2] += reward;
                    _mint(invite2, reward);
                }
            }
        }
        return true;
    }

    function buy(uint256 amount_) external {
        uint256 getUSDTamount = (amount_ * basePrice) / tokenDecimals;
        TransferHelper.safeTransferFrom(
            usdAddress,
            msg.sender,
            address(this),
            getUSDTamount
        );
        TransferHelper.safeTransfer(tokenAddress, msg.sender, amount_);
    }

    function sell(uint256 amount_) external {
        uint256 getUSDTamount = (amount_ * basePrice) / tokenDecimals;
        TransferHelper.safeTransferFrom(
            tokenAddress,
            msg.sender,
            address(this),
            amount_
        );
        TransferHelper.safeTransfer(usdAddress, msg.sender, getUSDTamount);
    }

    function recharge(address _account, uint256 _value)
        external
        returns (bool success)
    {
        require(_value > 0, "amount is zero");

        INST(tokenAddress).burn(msg.sender, _value);

        totalReward += _value;
        pendingReward += _value;
        amountOf[_account] += _value;
        emit Recharge(msg.sender, _account, _value);
        return true;
    }

    function withdrawReward(uint256 _value) external returns (bool) {
        require(_value > 0, "amount is zero error");
        uint256 taxFee = transfer_fee(msg.sender, _value);

        require(amountOf[msg.sender] >= _value, "balanceOf error");
        amountOf[msg.sender] -= _value;
        pendingReward -= _value;

        INST(tokenAddress).mint(msg.sender, _value);
        if (taxFee > 0) {
            TransferHelper.safeTransferFrom(
                tokenAddress,
                msg.sender,
                burnAddress,
                taxFee
            );
        }

        emit WithdrawalReward(msg.sender, _value);
        return true;
    }

    function extraBurnToken(uint256 burnAmount_) private {
        if (burnAmount_ > 0 && burnTokenAmount > 0) {
            TransferHelper.safeTransferFrom(
                nmtAddress,
                msg.sender,
                burnAddress,
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
        emit BindInviter(msg.sender, invite_);
        return true;
    }

    function rewardAmount(address _account) public view returns (uint256) {
        uint256 reward;
        if (block.timestamp - lastMiner[_account] >= epoch) {
            uint8 lv = getDurableLv(_account);
            uint8 scale = gameInfo[lv].rewardRate;

            uint256 maxReward = getMaxReward(_account);
            if (scale > 0 && maxReward > 0) {
                uint256 miner_days = (block.timestamp - lastMiner[_account]) /
                    epoch;

                if (lastMiner[_account] == 0) {
                    miner_days = 1;
                } else if (miner_days > maxDays) {
                    miner_days = maxDays;
                }

                reward = (durable[_account] * miner_days * scale) / 10000;
                if (reward > maxReward) {
                    reward = maxReward;
                }
            }
        }

        return reward;
    }

    function mint() external returns (bool success) {
        require(getMaxReward(msg.sender) > 0, "durable is not enough");
        doMint(msg.sender);
        return true;
    }

    function doMint(address _account) private {
        uint256 tokenId_ = userCard[_account];
        require(tokenId_ > 0, "land status error");
        require(
            INFT(nftAddress).ownerOf(tokenId_) == _account,
            "nft ownerOf error"
        );
        require(isMint, "not start mint");
        require(durable[_account] > 0, "durable is zero");

        require(
            block.timestamp - lastMiner[_account] >= epoch,
            "last_miner error"
        );

        uint256 reward = rewardAmount(_account);
        require(reward > 0, "reward is zero");

        lastMiner[_account] = block.timestamp;
        durable[_account] -= reward;
        totalDurable -= reward;
        _mint(_account, reward);
    }

    function transfer_fee(address _from, uint256 _value)
        public
        view
        returns (uint256 fee)
    {
        uint8 lv = getDurableLv(_from);
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
        emit Minted(address(this), account, amount);
    }

    function getDurableLv(address account_) public view returns (uint8 Lv) {
        Lv = 0;
        uint256 durable_ = durable[account_];
        if (durable_ < 502 * tokenDecimals) {
            Lv = 0;
        } else if (durable_ < 5000 * tokenDecimals) {
            Lv = 1;
        } else if (durable_ < 10000 * tokenDecimals) {
            Lv = 2;
        } else if (durable_ < 20000 * tokenDecimals) {
            Lv = 3;
        } else if (durable_ < 40000 * tokenDecimals) {
            Lv = 4;
        } else if (durable_ >= 40000 * tokenDecimals) {
            Lv = 5;
        }
    }

    function getMaxReward(address account_) public view returns (uint256) {
        uint256 minDurable = (userMaxDurable[account_] * minDurableRate) / 1000;
        if (minDurable > durable[account_]) {
            return 0;
        }
        return durable[account_] - minDurable;
    }
}