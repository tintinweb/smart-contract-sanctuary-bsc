// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./ModuleBase.sol";
import "./Lockable.sol";
import "./IERC20.sol";
import "./ECDSA.sol";

contract METStake is ModuleBase, Lockable, ECDSA {

    address internal signer;

    uint256 public constant routine_length = 5;
    address internal metAddress;

    struct StakeData {
        address account;
        uint256 amount;
        uint256 rtime;//routine time length
        uint256 rrate;//routine rate
        uint256 stime;//stake time;
        uint256 ctime;//claim time
        uint256 level;
        bool claimed;
        bool exists;
    }

    uint256 internal stakeLength;

    mapping(uint256 => StakeData) mapStake;

    mapping(address => uint256) mapUserStakeLength;
    mapping(address => mapping(uint256 => uint256)) mapUserStakeData;

    uint256 internal claimedLength;
    mapping(uint256 => uint256) mapClaimedData;

    event metStaked(address account, uint256 amount, uint256 rtime, uint256 rrate, uint256 stime, uint256 level, uint256 stakeIndex);
    event mmtClaimed(address account, uint256 stakeIndex);

    constructor(address _auth, address _moduleMgr, address _metAddress) ModuleBase(_auth, _moduleMgr) {
        metAddress = _metAddress;
    }

    function setSigner(address _signer) external onlyOwner {
        signer = _signer;
    }

    function getSigner() external view returns (address res) {
        res = signer;
    }

    function getStakeLength() external view returns (uint256 res) {
        res =   stakeLength;
    }

    function getStakeData(uint256 index) external view returns (
        bool res,
        address account,
        uint256 amount,
        uint256 rtime,
        uint256 rrate,
        uint256 stime,
        uint256 ctime,
        uint256 level,
        bool claimed
    ) {
       if(mapStake[index].exists) {
            res = true;
            account = mapStake[index].account;
            amount = mapStake[index].amount;
            rtime = mapStake[index].rtime;
            rrate = mapStake[index].rrate;
            stime = mapStake[index].stime;
            ctime = mapStake[index].ctime;
            level = mapStake[index].level;
            claimed = mapStake[index].claimed;
        }
    }

    function getUserStakeLength(address account) external view returns (uint256 res) {
        res = mapUserStakeLength[account];
    }

    function getUserStakeData(address account, uint256 userStakeIndex) external view returns (
        bool res,
        uint256 amount,
        uint256 rtime,
        uint256 rrate,
        uint256 stime,
        uint256 ctime,
        uint256 level,
        bool claimed
    ) {
        uint256 index = mapUserStakeData[account][userStakeIndex];
        if(index > 0) {
            if(mapStake[index].exists) {
                res = true;
                amount = mapStake[index].amount;
                rtime = mapStake[index].rtime;
                rrate = mapStake[index].rrate;
                stime = mapStake[index].stime;
                ctime = mapStake[index].ctime;
                level = mapStake[index].level;
                claimed = mapStake[index].claimed;
            }
        }
    }

    function getClaimedLength() external view returns (uint256 res) {
        return claimedLength;
    }

    function getClaimedDataIndex(uint256 claimIndex) external view returns (uint256 stakeIndex) {
        stakeIndex = mapClaimedData[claimIndex];
    }

    function stakeMET(uint256 amount, uint256 stakeTime, uint256 rewardRate, uint256 level, bytes memory signature) external lock {
        require(msg.sender != address(0));
        require(amount > 0, "amount zero");
        string memory message = string(abi.encodePacked(Strings.addressToString(msg.sender),
                                                        Strings.uint256ToString(amount),
                                                        Strings.uint256ToString(stakeTime),
                                                        Strings.uint256ToString(rewardRate),
                                                        Strings.uint256ToString(level)
                                                    ));
        require(_IsSignValid(message, signature), "invalid signature");
        require(IERC20(metAddress).balanceOf(msg.sender) >= amount, "insufficient balance");
        require(IERC20(metAddress).allowance(msg.sender, address(this)) >= amount, "not approve");
        mapStake[++stakeLength] = StakeData(msg.sender, amount, stakeTime, rewardRate, block.timestamp, 0, level, false, true);
        mapUserStakeLength[msg.sender] ++;
        mapUserStakeData[msg.sender][mapUserStakeLength[msg.sender]] = stakeLength;
        require(IERC20(metAddress).transferFrom(msg.sender, address(this), amount), "stake error");
        emit metStaked(msg.sender, amount, stakeTime, rewardRate, block.timestamp, level, stakeLength);
    }

    function claimMMT(uint256 userStakeIndex) external lock {
        uint256 stakeIndex = mapUserStakeData[msg.sender][userStakeIndex];
        require(mapStake[stakeIndex].exists, "stake not exists");
        require(!mapStake[stakeIndex].claimed, "claimed");
        StakeData memory sd = mapStake[stakeIndex];
        require(block.timestamp >= sd.stime + sd.rtime, "not meet release time");
        uint256 mmtAmountOut = sd.amount * sd.rrate / 10000;
        require(mmtAmountOut > 0, "err:mmt amout rate");
        mapStake[stakeIndex].claimed = true;
        mapStake[stakeIndex].ctime = block.timestamp;
        ++claimedLength;
        mapClaimedData[claimedLength] = stakeIndex;
        require(IERC20(metAddress).balanceOf(address(this)) >= sd.amount, "insufficient fund");
        require(IERC20(metAddress).transfer(0x000000000000000000000000000000000000dEaD, sd.amount), "err:transfer met to dead");
        require(IERC20(auth.getFarmToken()).balanceOf(address(this)) >= mmtAmountOut, "insufficient fund");
        require(IERC20(auth.getFarmToken()).transfer(msg.sender, mmtAmountOut), "err:transfer mmt to staker");
        emit mmtClaimed(msg.sender, stakeIndex);
    }

    function _IsSignValid(string memory message, bytes memory signature) internal view returns(bool) {
        return signer == recover(
            keccak256(
                abi.encodePacked(
                    "\x19Ethereum Signed Message:\n",
                    Strings.toString(bytes(message).length),
                    message
                )
            ),
            signature
        );
    }
}