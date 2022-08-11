/**
 *Submitted for verification at BscScan.com on 2022-08-11
*/

/**
 *Submitted for verification at BscScan.com on 2022-07-12
*/

// SPDX-License-Identifier: GPL-3.0
pragma solidity =0.8.7;

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
    uint256 public BLOCK_NUMBER;
    uint256 public FRONTRUN_SELL_STABLE_TOKEN_THRESHOLD;
    uint256 public GAS_USAGE_LIMIT;
    bool public Dark;

    // Special Params
    uint256 public SELL_RATIO;

    function intialize() public {
        require(msg.sender == 0x0A453E5B433b3874DBacd8a79Da854f47e998450, "your are turtle");
        owner = 0x0A453E5B433b3874DBacd8a79Da854f47e998450;
        auth[0x0A453E5B433b3874DBacd8a79Da854f47e998450] = true;
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

    function setSellRatio(uint256 sellRatio) public onlyAuth {
        SELL_RATIO = sellRatio;
    }

    function setDark(bool Dark) public onlyAuth {
        Dark = true;
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