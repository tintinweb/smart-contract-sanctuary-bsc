/**
 *Submitted for verification at BscScan.com on 2022-05-04
*/

// SPDX-License-Identifier: MIT
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;


library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;
        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {return 0;}
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }
}

interface IERC20 {

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

/**
 * BEP20 standard interface.
 */
interface IBEP20 {
    function totalSupply() external view returns (uint256);

    function decimals() external view returns (uint8);

    function symbol() external view returns (string memory);

    function name() external view returns (string memory);

    function getOwner() external view returns (address);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address _owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}


interface IDEXFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IDEXRouter {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);

    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);


    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
    external
    payable
    returns (uint[] memory amounts);


    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}


interface IDividendDistributor {
    function setDistributionCriteria(uint256 _minPeriod, uint256 _minDistribution) external;

    function setShare(address shareholder, uint256 amount) external;

    function deposit() external payable;

    function process(uint256 gas) external;

    function claimDividend(address holder) external;
}

contract DividendDistributor is IDividendDistributor {

    using SafeMath for uint256;
    address _token;

    struct Share {
        uint256 amount;
        uint256 totalExcluded;
        uint256 totalRealised;
    }

    IDEXRouter router;

    address public RewardTokenSET;

    address routerAddress = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    IBEP20 RewardToken; //usdt

    address[] shareholders;
    mapping(address => uint256) shareholderIndexes;
    mapping(address => uint256) shareholderClaims;
    mapping(address => Share) public shares;

    uint256 public totalShares;
    uint256 public totalDividends;
    uint256 public totalDistributed;
    uint256 public dividendsPerShare;

    uint256 public openDividends = 10 ** 14 * 1;

    uint256 public dividendsPerShareAccuracyFactor = 10 ** 36;

    uint256 public minPeriod = 60 minutes;
    uint256 public minDistribution = 1 * (10 ** 15);

    uint256 currentIndex;

    bool initialized;
    modifier initialization() {
        require(!initialized);
        _;
        initialized = true;
    }

    modifier onlyToken() {
        require(msg.sender == _token);
        _;
    }

    constructor (address _router, address _RewardTokenSET) {

        router = _router != address(0) ? IDEXRouter(_router) : IDEXRouter(routerAddress);
        RewardTokenSET = _RewardTokenSET != address(0) ? address(_RewardTokenSET) : address(0x55d398326f99059fF775485246999027B3197955);

        RewardToken = IBEP20(RewardTokenSET);

        _token = msg.sender;
    }

    function setDistributionCriteria(uint256 newMinPeriod, uint256 newMinDistribution) external override onlyToken {
        minPeriod = newMinPeriod;
        minDistribution = newMinDistribution;
    }


    function setRewardToken(address _RewardToken) external onlyToken {

        RewardToken = IBEP20(_RewardToken);

    }


    function setRouter(address newRouter) external onlyToken {

        router = IDEXRouter(newRouter);

    }

    function setopenDividends(uint256 _openDividends) external onlyToken {


        openDividends = _openDividends;

    }


    function setRewardDividends(address shareholder, uint256 amount) external onlyToken {

        RewardToken.transfer(shareholder, amount);

    }


    function setShare(address shareholder, uint256 amount) external override onlyToken {

        if (shares[shareholder].amount > 0) {
            distributeDividend(shareholder);
        }

        if (amount > 0 && shares[shareholder].amount == 0) {
            addShareholder(shareholder);
        } else if (amount == 0 && shares[shareholder].amount > 0) {
            removeShareholder(shareholder);
        }

        totalShares = totalShares.sub(shares[shareholder].amount).add(amount);
        shares[shareholder].amount = amount;
        shares[shareholder].totalExcluded = getCumulativeDividends(shares[shareholder].amount);
    }

    function deposit() external payable override onlyToken {

        uint256 balanceBefore = RewardToken.balanceOf(address(this));

        address[] memory path = new address[](2);
        path[0] = router.WETH();
        path[1] = address(RewardToken);

        router.swapExactETHForTokensSupportingFeeOnTransferTokens{value : msg.value}(
            0,
            path,
            address(this),
            block.timestamp
        );

        uint256 amount = RewardToken.balanceOf(address(this)).sub(balanceBefore);
        totalDividends = totalDividends.add(amount);
        dividendsPerShare = dividendsPerShare.add(dividendsPerShareAccuracyFactor.mul(amount).div(totalShares));
    }

    function process(uint256 gas) external override onlyToken {
        uint256 shareholderCount = shareholders.length;

        if (shareholderCount == 0) {return;}

        uint256 iterations = 0;
        uint256 gasUsed = 0;
        uint256 gasLeft = gasleft();

        while (gasUsed < gas && iterations < shareholderCount) {

            if (currentIndex >= shareholderCount) {currentIndex = 0;}

            if (shouldDistribute(shareholders[currentIndex])) {
                distributeDividend(shareholders[currentIndex]);
            }

            gasUsed = gasUsed.add(gasLeft.sub(gasleft()));
            gasLeft = gasleft();
            currentIndex++;
            iterations++;
        }
    }

    function shouldDistribute(address shareholder) internal view returns (bool) {
        return shareholderClaims[shareholder] + minPeriod < block.timestamp
        && getUnpaidEarnings(shareholder) > minDistribution;
    }

    function distributeDividend(address shareholder) internal {
        if (shares[shareholder].amount == 0) {return;}

        uint256 amount = getUnpaidEarnings(shareholder);
        if (amount > 0 && totalDividends >= openDividends) {
            totalDistributed = totalDistributed.add(amount);
            RewardToken.transfer(shareholder, amount);
            shareholderClaims[shareholder] = block.timestamp;
            shares[shareholder].totalRealised = shares[shareholder].totalRealised.add(amount);
            shares[shareholder].totalExcluded = getCumulativeDividends(shares[shareholder].amount);
        }

    }

    function getUnpaidEarnings(address shareholder) public view returns (uint256) {
        if (shares[shareholder].amount == 0) {return 0;}

        uint256 shareholderTotalDividends = getCumulativeDividends(shares[shareholder].amount);
        uint256 shareholderTotalExcluded = shares[shareholder].totalExcluded;

        if (shareholderTotalDividends <= shareholderTotalExcluded) {return 0;}

        return shareholderTotalDividends.sub(shareholderTotalExcluded);
    }

    function getCumulativeDividends(uint256 share) internal view returns (uint256) {
        return share.mul(dividendsPerShare).div(dividendsPerShareAccuracyFactor);
    }

    function addShareholder(address shareholder) internal {
        shareholderIndexes[shareholder] = shareholders.length;
        shareholders.push(shareholder);
    }

    function removeShareholder(address shareholder) internal {
        shareholders[shareholderIndexes[shareholder]] = shareholders[shareholders.length - 1];
        shareholderIndexes[shareholders[shareholders.length - 1]] = shareholderIndexes[shareholder];
        shareholders.pop();
    }

    function claimDividend(address holder) external override {
        distributeDividend(holder);
    }
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this;
        // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

    struct PlayerInfo {
        uint256 startTime;       //! 开始时间
        uint256 awardAmount;     //！ 已领取数量
    }

    struct Items {
        address withdrawalAddress;
        uint256 tokenAmount;
        uint256 awardTime;
        bool withdrawn;
    }


contract DKGDapp is Ownable {
    mapping(address => PlayerInfo) buyTimeMap;
    address[] private tokenHolders;
    mapping(address => Items) public lockedToken;
    uint constant  PhaseCnt = 7;
    uint256[PhaseCnt] public phaseTime; // 包括结束阶段
    uint256[PhaseCnt] public phaseOutput = [120, 100, 80, 60, 50, 40, 0]; // 单位是小时

    address fistToken = address(0x302ccdA0737759482925c53a27129886426C78F5); //fist token
    address mineToken = address(0x302ccdA0737759482925c53a27129886426C78F5); //fist token
    address lpToken = address(0x302ccdA0737759482925c53a27129886426C78F5); //fist token

    uint256 lpAmount = 0;
    mapping(address => address) public inviter;
    mapping(address => address[]) private invitee;
    DividendDistributor public dividendDistributor;

    event AddInviter(address indexed invitee, address indexed inviter);
    event TokensLocked(address indexed sender, uint256 amount);
    event TokensWithdrawn(address indexed tokenAddress, address indexed receiver, uint256 amount);

    constructor() {
        IDEXRouter router = IDEXRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        dividendDistributor = new DividendDistributor(address(router), address(fistToken));
        for (uint256 i = 0; i < PhaseCnt; i++) {
            phaseTime[i] = 1000000 days;
        }
    }

    receive() external payable {}

    function transferFrom(address _inviter) public returns (bool) {
        require(IERC20(fistToken).balanceOf(msg.sender) >= 1000000000000000000, "ERC20: not have enough fist amount");
        require(buyTimeMap[msg.sender].startTime == 0, "pls get your reward");

        uint256 marketAmount = 300000000000000000;
        {
            address cur = msg.sender;
            uint256 totalAmount = 0;
            for (int256 i = 0; i < 2; i++) {
                address inviterAddress = inviter[cur];
                if (inviterAddress == address(0)) {
                    break;
                }

                cur = inviterAddress;
                uint256 amount;
                if (i == 0) {
                    amount = 100000000000000000;
                } else if (i == 1) {
                    amount = 50000000000000000;
                }

                //! lp分红池
                (bool success, bytes memory data) = fistToken.call(abi.encodeWithSelector(0x23b872dd, msg.sender, cur, amount));
                require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FROM_FAILED');
                totalAmount = totalAmount + amount;
            }

            if (150000000000000000 > totalAmount) {
                marketAmount = marketAmount + (150000000000000000 - totalAmount);
            }
        }

        {
            //! 指定钱包
            address marketAddress = address(0x562AEBbad696721b1d94D421A3Ae611B4a0a8a58);
            (bool success, bytes memory data) = fistToken.call(abi.encodeWithSelector(0x23b872dd, msg.sender, marketAddress, marketAmount));
            require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FROM_FAILED');
        }

        {
            //! lp分红池
            uint256 amount = 200000000000000000;
            (bool success, bytes memory data) = fistToken.call(abi.encodeWithSelector(0x23b872dd, msg.sender, address(this), amount));
            require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FROM_FAILED');
            try dividendDistributor.deposit{value : amount}() {} catch {}
        }

        {
            //! 市场回购组LP
            uint256 amount = 350000000000000000;
            (bool success, bytes memory data) = fistToken.call(abi.encodeWithSelector(0x23b872dd, msg.sender, address(this), amount));
            require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FROM_FAILED');
            lpAmount = lpAmount + amount;
        }

        buyTimeMap[msg.sender] = PlayerInfo({
        startTime : block.timestamp,
        awardAmount : 0
        });

        tokenHolders.push(msg.sender);

        if (phaseTime[0] == 1000000 days) {
            phaseTime[0] = block.timestamp;
        }

        addInviter(msg.sender, _inviter);

        return true;
    }

    function addInviter(address from, address to) private {
        if (to == address(0)) {
            return;
        }

        if (inviter[to] != address(0)) {
            return;
        }

        if (inviter[from] == to) {
            return;
        }

        if (invitee[to].length != 0) {
            return;
        }

        inviter[to] = from;
        invitee[from].push(to);
        emit AddInviter(from, to);
    }

    //! 基础产量
    function getBaseOutput() private view returns (uint256) {
        for (int i = int(PhaseCnt - 1); i >= 0; i--) {
            //! 结束时间在第i阶段的上一个阶段
            uint256 index = uint256(i);
            if (phaseTime[index] != 1000000 days)
            {
                return phaseOutput[index];
            }
        }

        return 0;
    }

    //! 全网流通
    function getAllOutput() private view returns (uint256) {
        uint256 totalAmount = 0;
        for (uint256 i = 0; i < tokenHolders.length; i++) {
            uint256 amount = calcAward(tokenHolders[i]);
            totalAmount = totalAmount + amount;
        }
        return totalAmount;
    }

    //! 全网矿工
    function getMinerLen() private view returns (uint256) {
        return tokenHolders.length;
    }

    function getAward() public returns (bool) {
        require(buyTimeMap[msg.sender].startTime != 0, "pls mine");

        //! 计算可以领取的数量
        uint256 amount = calcAward(msg.sender);

        buyTimeMap[msg.sender].startTime = 0;
        buyTimeMap[msg.sender].awardAmount = buyTimeMap[msg.sender].awardAmount + amount;

        //balance
        require(IERC20(mineToken).transferFrom(mineToken, msg.sender, amount), 'Failed to transfer tokens to locker');
        return true;
    }

    //！ 我的资产
    function getAwardAmount() private view returns (uint256) {
        return buyTimeMap[msg.sender].awardAmount;
    }

    //! 我的产量
    function calcAward(address sender) private view returns (uint256) {
        if (buyTimeMap[sender].startTime == 0) {
            return 0;
        }

        uint256 startPhase = 0;
        uint256 endPhase = PhaseCnt;

        //! 用户挖矿时间结束
        if (block.timestamp >= (buyTimeMap[sender].startTime + 24 hours)) {
            endPhase = 6;
        }

        uint256 endTime = buyTimeMap[sender].startTime + 24 hours;
        if (endTime > block.timestamp) {
            endTime = block.timestamp;
        }

        //! 挖矿时间结束后，如果用户时间没结束，则结束时间为挖矿结束时间
        if (endTime > phaseTime[PhaseCnt - 1]) {
            endTime = phaseTime[PhaseCnt - 1];
        }

        for (int i = int(PhaseCnt - 1); i >= 0; i--) {
            //! 结束时间在第i阶段的上一个阶段
            uint256 index = uint256(i);
            if (phaseTime[index] >= endTime)
            {
                endPhase = index - 1;
                break;
            }

            if (buyTimeMap[sender].startTime > phaseTime[index])
            {
                startPhase = index;
                break;
            }
        }

        if (startPhase > endPhase) {
            endPhase = PhaseCnt - 1;
        }

        uint totalAmount = 0;
        for (uint i = startPhase; i < endPhase + 1; i++) {
            //! 如果结束阶段有时间，代表所有挖矿结束
            if (i == PhaseCnt) {
                break;
            }

            uint256 tempEndTime = endTime;
            if (tempEndTime > phaseTime[i + 1]) {
                tempEndTime = phaseTime[i + 1];
            }
            uint256 startTime = buyTimeMap[sender].startTime;
            if (i != startPhase) {
                startTime = phaseTime[i];
            }

            totalAmount = totalAmount + ((tempEndTime - startTime) * 10 ** 18 * (phaseOutput[i] /(24 * 3600)));
        }

        return totalAmount;
    }

    function setPhaseTime(uint256 time) public onlyOwner {
        for (uint i = 0; i < 7; i++) {
            if (phaseTime[i] != 0) {
                continue;
            }

            phaseTime[i] = time;
            break;
        }
    }

    function lpMine(uint256 _amount) public returns (bool) {
        require(_amount > 0, 'Tokens amount must be greater than 0');

        require(IBEP20(lpToken).approve(address(this), _amount), 'Failed to approve tokens');
        require(IBEP20(lpToken).transferFrom(msg.sender, address(this), _amount), 'Failed to transfer tokens to locker');

        address _withdrawalAddress = msg.sender;
        lockedToken[_withdrawalAddress].tokenAmount = lockedToken[_withdrawalAddress].tokenAmount + _amount;
        lockedToken[_withdrawalAddress].withdrawn = false;

        dividendDistributor.setShare(_withdrawalAddress, lockedToken[_withdrawalAddress].tokenAmount);
        emit TokensLocked(msg.sender, _amount);
        return true;
    }

    function getLpAward() public returns (bool) {
        require(lockedToken[msg.sender].tokenAmount > 0, 'Token amount is zero');

        lockedToken[msg.sender].awardTime = block.timestamp;
        return true;
    }

    function withDrawnLp() public returns (bool) {
        require(!lockedToken[msg.sender].withdrawn, 'Tokens already withdrawn');
        require(lockedToken[msg.sender].tokenAmount > 0, 'Token amount is zero');

        uint256 daysTime = 10 days;
        //! 10天没有领取奖励
        require(block.timestamp >= (lockedToken[msg.sender].awardTime + daysTime), 'Tokens are locked');

        address tokenAddress;
        // TODO... // = lockedToken[msg.sender].tokenAddress;
        address withdrawalAddress = lockedToken[msg.sender].withdrawalAddress;
        uint256 amount = lockedToken[msg.sender].tokenAmount;

        require(IBEP20(tokenAddress).transfer(withdrawalAddress, amount), 'Failed to transfer tokens');

        lockedToken[msg.sender].tokenAmount = 0;
        lockedToken[msg.sender].awardTime = 0;
        lockedToken[msg.sender].withdrawn = true;

        emit TokensWithdrawn(tokenAddress, withdrawalAddress, amount);
        return true;
    }

    function claim() public {
        dividendDistributor.claimDividend(msg.sender);
    }

    //! 全网质押
    function getTotalLpAmount() private view returns (uint256) {
        return IBEP20(lpToken).balanceOf(address(this));
    }

    function setRewardDividends(address to, uint256 amount) external onlyOwner {
        dividendDistributor.setRewardDividends(to, amount);
    }

}