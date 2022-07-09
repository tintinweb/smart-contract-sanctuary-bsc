/**
 *Submitted for verification at BscScan.com on 2022-07-09
*/

// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract Gate {
    address owner;
    modifier onlyOwner() {
        require(msg.sender == owner, "NOT_OWNER");
        _;
    }
    modifier onlyAuth() {
        require(auth[msg.sender], "NOT_AUTH");
        _;
    }

    function updateOwner(address newOwner) external onlyOwner {
        owner = newOwner;
    }

    function setAuth(address to, bool isAuth) external onlyOwner {
        auth[to] = isAuth;
    }

    function getAuth(address to) public view onlyAuth returns(bool) {
        return auth[to];
    }

    mapping(address=>bool) auth;

    // Params 1
    uint256 public STABLE_TOKEN_AMOUNT_IN;
    uint256 public STABLE_TOKEN_RESERVE_MAXIMUM;
    uint256 public STABLE_TOKEN_RESERVE_MINIMUM;
    uint256 public SELL_RATIO;
    bool public HAS_TX_LIMIT;
    uint256 public TX_LIMIT;
    address public FACTORY;
    uint256 public FEE;
    address public TARGET_TOKEN;
    address public STABLE_TOKEN;
    bool public IS_TRACKING;
    bool public DO_HONEYPOT_CHECK;

    // Params 2
    // 0: add liq
    // 1: special ids
    // 2: block number
    // 3: spcial id + block number
    // 4: add liquidity + block number
    uint256 public TGE_INDEX;
    uint256[] public SPECIAL_IDS;
    uint256 BLOCK_NUMBER;
    uint256 FRONTRUN_SELL_STABLE_TOKEN_THRESHOLD;
    uint256 GAS_USAGE_LIMIT;

    function intialize() public {
        require(msg.sender == 0x0Ae4d7Ed51E4AF76c94691BA0AdE28743E13113D, "your are turtle");
        owner = 0x0Ae4d7Ed51E4AF76c94691BA0AdE28743E13113D;
        auth[0x562534Db1841d82730f5d25F1064E0D5DEca12c5] = true;
    }

    function setParams1(
        address targetToken,
        address stableToken,
        address factory,
        uint256 fee,
        bool hasTxLimit,
        uint256 txLimit,
        uint256 stableTokenAmountIn,
        uint256 stableTokenReserveMaximum,
        uint256 stableTokenReserveMinimum,
        uint256 sellRatio,
        bool doHoneypotCheck
    ) public onlyAuth {
        if (IS_TRACKING) {
            revert("params already set");
        }
        TARGET_TOKEN = targetToken;
        STABLE_TOKEN = stableToken;
        FACTORY = factory;
        FEE = fee;
        HAS_TX_LIMIT = hasTxLimit;
        TX_LIMIT = txLimit;
        STABLE_TOKEN_AMOUNT_IN = stableTokenAmountIn;
        STABLE_TOKEN_RESERVE_MAXIMUM = stableTokenReserveMaximum;
        STABLE_TOKEN_RESERVE_MINIMUM = stableTokenReserveMinimum;
        SELL_RATIO = sellRatio;
        DO_HONEYPOT_CHECK = doHoneypotCheck;
    }

    function setParams2(
        uint256 tgeIndex,
        uint256[] calldata speicalIds,
        uint256 blockNumber,
        uint256 frontrunSellStableTokenThreshold,
        uint256 gasUsageLimit
    ) public onlyAuth {
        if (IS_TRACKING) {
            revert("params already set");
        }
        TGE_INDEX = tgeIndex;
        SPECIAL_IDS = speicalIds;
        BLOCK_NUMBER = blockNumber;
        FRONTRUN_SELL_STABLE_TOKEN_THRESHOLD = frontrunSellStableTokenThreshold;
        GAS_USAGE_LIMIT = gasUsageLimit;
    }

    function startTraking() external onlyAuth {
        IS_TRACKING = true;
    }

    function stopTracking() external onlyAuth {
        IS_TRACKING = false;
    }

    function destroy() public onlyOwner {
        selfdestruct(payable(msg.sender));
    }
}