//SPDX-License-Identifier: MIT
pragma solidity 0.8.14;

import "./IERC20.sol";

interface IToken {
    function getOwner() external view returns (address);
    function burn(uint256 amount) external returns (bool);
}

contract EmissionRecipient {

    address public constant accumulator = 0x9cb949e8c256C3EA5395bbe883E6Ee6a20Db6045;

    address public pool = 0xc4e864940C34cDF5086202c34Dff07365f5042Ab;

    uint256 public rate = 700000000000;  // 2% per day

    uint256 public lastReward;

    uint256 public devAmountPerBlock = 138888888900000000; // 0.1388888 * 28,800 blocks per day = 4,000 per day

    address[] public devAddrs;
    mapping ( address => bool ) public skipAddr;

    modifier onlyOwner() {
        require(
            msg.sender == IToken(accumulator).getOwner(),
            'Only Owner'
        );
        _;
    }

    constructor() {
        lastReward = block.number;

        devAddrs = new address[](7);
        devAddrs[0] = 0x2aB15F8e211eA475bC9275A4C2BFbC9A8130EE89;
        devAddrs[1] = 0xB695b344dfd4B25782Fc87B09439D98358771891;
        devAddrs[2] = 0xB1F73ebCC9866708618D74a6314f1c0b80308deE;
        devAddrs[3] = 0x851e5A29Ffa7651Ca7f94e166D52376f3315a092;
        devAddrs[4] = 0x88f348b5546FCEf9c44cEEcA6DB33F6136E2B74F;
        devAddrs[5] = 0xB6B46eD2a978D480dDf9F0700fec1899000554e3;
        devAddrs[6] = msg.sender;
    }

    function resetEmissions() external onlyOwner {
        lastReward = block.number;
    }

    function setLastRewardStartTime(uint startBlock) external onlyOwner {
        lastReward = startBlock;
    }

    function setAddr(uint index, address newAddr) external onlyOwner {
        if (index >= devAddrs.length) {
            devAddrs.push(newAddr);
        } else {
            devAddrs[index] = newAddr;
        }
    }

    function setSkipAddr(address addr, bool skip) external onlyOwner {
        skipAddr[addr] = skip;
    }

    function setDevAmountPerBlock(uint newAmountPerBlock) external onlyOwner {
        devAmountPerBlock = newAmountPerBlock;
    }

    function setPools(
        address pool_
    ) external onlyOwner {
        pool = pool_;
    }

    function setRates(
        uint rate_
    ) external onlyOwner {
        rate = rate_;
    }

    function withdraw(address token) external onlyOwner {
        IERC20(token).transfer(msg.sender, IERC20(token).balanceOf(address(this)));
    }

    function withdrawAmount(address token, uint amount) external onlyOwner {
        IERC20(token).transfer(msg.sender, amount);
    }

    function trigger() external {

        // amount to reward
        (
        uint amount, uint devAmount
        ) = amountToDistribute();
        
        // reset timer
        lastReward = block.number;

        // send reward to the vault
        _send(pool, amount);
        
        // send reward to devs
        _handleDevTokens(devAmount);
    }

    function amountInPool(address pool_) public view returns (uint256) {
        if (pool_ == address(0)) {
            return 0;
        }
        return IERC20(accumulator).balanceOf(pool_);
    }

    function timeSince() public view returns (uint256) {
        return lastReward < block.number ? block.number - lastReward : 0;
    }

    function qtyPerBlock(address pool_, uint256 dailyReturn) public view returns (uint256) {
        return ( amountInPool(pool_) * dailyReturn ) / 10**18;
    }

    function amountToDistribute() public view returns (uint256, uint256) {
        uint nTime = timeSince();
        return(
            qtyPerBlock(pool, rate) * nTime,
            devAmountPerBlock * nTime
        );
    }

    function _send(address to, uint amount) internal {
        uint bal = IERC20(accumulator).balanceOf(address(this));
        if (amount > bal) {
            amount = bal;
        }
        if (amount == 0) {
            return;
        }
        IERC20(accumulator).transfer(to, amount); 
    }

    function _handleDevTokens(uint256 amountPer) internal {

        uint len = devAddrs.length;
        for (uint i = 0; i < len;) {
            if (!skipAddr[devAddrs[i]]) {
                _send(devAddrs[i], amountPer);
            }
            unchecked { ++i; }
        }

    }
}