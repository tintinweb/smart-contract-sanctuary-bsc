/**
 *Submitted for verification at BscScan.com on 2022-05-07
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

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

    function stakeOf(address account_) external view returns (uint256);

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

// ????????????????????????,?????????????????????
// ????????????????????????,??????????????????????????????,?????????????????????
// ???????????????????????????token????????????????????????-????????????
contract DepositUSD {
    address public usdAddress; // usd??????

    uint256 public totalStaked; //?????????
    mapping(address => uint256) public stakedOf; // ????????????

    uint256 public totalFees; //????????????
    uint256 public totalUsedFees; //??????????????????
    uint256 public bonusReward; //????????????

    mapping(address => mapping(string => uint256)) public totalReward; //????????? reward[??????token]
    //?????????????????? reward[??????token][usefor] =??? ????????????
    // usefor(string) invite(????????????),,,,
    mapping(address => mapping(string => uint256)) public useforReward; //???????????????

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
    ) public onlyUseFor {
        TransferHelper.safeTransfer(token_, to_, amount_);
    }

    function stakeUsd(address account_, uint256 amount_) public onlyUseFor {
        totalStaked += amount_;
        stakedOf[account_] += amount_;
    }

    function unstakeUsd(address account_, uint256 amount_) public onlyUseFor {
        totalStaked -= amount_;
        stakedOf[account_] -= amount_;
        TransferHelper.safeTransfer(usdAddress, account_, amount_);
    }

    // ????????????????????????
    function getReward(address token_, string memory usefor)
        public
        view
        returns (uint256)
    {
        return totalReward[token_][usefor] - useforReward[token_][usefor];
    }

    // ??????????????????????????????token???????????????,????????????????????????
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

    // ????????????
    function takeReward(
        address token_,
        string memory usefor,
        address account_,
        uint256 amount_
    ) public onlyUseFor {
        require(getReward(token_, usefor) >= amount_, "not enough fee");
        useforReward[token_][usefor] += amount_;
        TransferHelper.safeTransfer(token_, account_, amount_);
    }

    function getFee() public view returns (uint256) {
        return totalFees - totalUsedFees;
    }

    function depositFee(uint256 amount_) public {
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

    function bonusFee(uint256 amount_) public onlyUseFor {
        require(getFee() >= amount_, "not enough fee");
        totalUsedFees += amount_;
        bonusReward += amount_;
    }

    function takeFee(address account_, uint256 amount_) public onlyUseFor {
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