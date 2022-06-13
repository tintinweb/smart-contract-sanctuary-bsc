/**
 *Submitted for verification at BscScan.com on 2022-06-13
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title SafeMath
 * @dev Math operations with safety checks that revert on error
 */
library SafeMath {
    /**
     * @dev Returns the largest of two numbers.
     */
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    /**
     * @dev Returns the smallest of two numbers.
     */
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    /**
     * @dev Calculates the average of two numbers. Since these are integers,
     * averages of an even and odd number cannot be represented, and will be
     * rounded down.
     */
    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b) / 2 can overflow, so we distribute
        return (a / 2) + (b / 2) + (((a % 2) + (b % 2)) / 2);
    }

    /**
     * @dev Multiplies two numbers, reverts on overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b);

        return c;
    }

    /**
     * @dev Integer division of two numbers truncating the quotient, reverts on division by zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0); // Solidity only automatically asserts when dividing by 0
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Subtracts two numbers, reverts on overflow (i.e. if subtrahend is greater than minuend).
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Adds two numbers, reverts on overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);

        return c;
    }

    /**
     * @dev Divides two numbers and returns the remainder (unsigned integer modulo),
     * reverts when dividing by zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}

contract Ownable {
    address public _owner;

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
        require(_owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    function changeOwner(address newOwner) public onlyOwner {
        _owner = newOwner;
    }
}

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address who) external view returns (uint256);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function transfer(address to, uint256 value) external returns (bool);

    function approve(address spender, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

interface IPancakeRouter01 {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function quote(
        uint256 amountA,
        uint256 reserveA,
        uint256 reserveB
    ) external pure returns (uint256 amountB);

    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountOut);

    function getAmountIn(
        uint256 amountOut,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountIn);

    function getAmountsOut(uint256 amountIn, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);

    function getAmountsIn(uint256 amountOut, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);
}

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure.
 * To use this library you can add a `using SafeERC20 for ERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using SafeMath for uint256;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        require(token.transfer(to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        require(token.transferFrom(from, to, value));
    }

    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require((value == 0) || (token.allowance(msg.sender, spender) == 0));
        require(token.approve(spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(
            value
        );
        require(token.approve(spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(
            value
        );
        require(token.approve(spender, newAllowance));
    }
}

contract AladMiner is Ownable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    // mainnet
    IPancakeRouter01 public PancakeRouter01 =
        IPancakeRouter01(0x10ED43C718714eb63d5aA57B78B54704E256024E);

    IERC20 public pToken;
    IERC20 public token;
    IERC20 public admittanceToken;

    uint256 public paypToken = 1e18;
    uint256 public minadmittanceToken = 1e18;

    uint256 private _rate = 625;
    uint256 private _totalrate = 100;

    uint256 public nowTotalHash;
    uint256 public nowExpectedRewards;
    uint256 public nowPartnerExpectedRewards;

    uint256 public cliff = 600;

    mapping(address => address) internal _parents;
    mapping(address => address[]) internal _aleadyMyChilders;
    mapping(address => uint256) internal _aleadyMyChildersIndexes;
    mapping(address => bool) public isAleadyMyChilders;
    mapping(address => address[]) internal _mychilders;
    mapping(address => AccountInfo) public accountInfo;

    uint256[20] levelConfig = [
        15,
        10,
        8,
        4,
        1,
        1,
        1,
        1,
        1,
        1,
        1,
        1,
        1,
        1,
        1,
        1,
        1,
        1,
        1,
        1
    ];

    struct AccountInfo {
        uint256 jClaimAt;
        uint256 dClaimAt;
        uint256 capital;
        uint256 teamCapital;
        uint256 receivedRewards;
        uint256 todayReceivedDynamicRewards;
        uint256 getDynamicRewards;
        uint256 getTranslateRewards;
        uint256 selfExpectedRewards;
        uint256 teamExpectedRewards;
        uint256 receivedPRewards;
        uint256 getPRewards;
        uint256 teamSizeSuns;
    }

    event BindingParents(address indexed user, address inviter);
    event Deposit(
        address indexed user,
        uint256 capital,
        uint256 selfExpectedRewards
    );
    event Withdrawn(
        address indexed user,
        uint256 amount,
        uint256 feeAmount,
        bool isPrivate
    );

    constructor(
        IERC20 _pToken,
        IERC20 _token,
        IERC20 _admittanceToken
    ) {
        _owner = msg.sender;

        pToken = _pToken;
        token = _token;
        admittanceToken = _admittanceToken;
    }

    function deposit(uint256 amount) external {
        require(
            admittanceToken.balanceOf(msg.sender) >= minadmittanceToken,
            "Insufficient permissions"
        );
        require(amount > 0, "Insufficient amount");

        if (isAleadyMyChilders[msg.sender]) {
            removeAleadyMyChilds(msg.sender);

            _mychilders[_parents[msg.sender]].push(msg.sender);

            address inv = msg.sender;
            for (uint256 i = 0; i <= 20; i++) {
                inv = _parents[inv];

                if (inv != address(0)) accountInfo[inv].teamSizeSuns++;
            }
        }

        address inviter = msg.sender;

        uint256 expectedRewards = amount
            .mul(_rate)
            .mul(1e18)
            .div(_totalrate)
            .div(getp2());

        uint256 pVip;
        for (uint256 ind = 1; ind <= 20; ind++) {
            inviter = _parents[inviter];

            if (ind == 1) pVip = getVip(inviter);

            AccountInfo storage acc = accountInfo[inviter];

            acc.teamCapital = acc.teamCapital.add(
                amount.mul(1e18).div(getp2())
            );
            acc.teamExpectedRewards = acc.teamExpectedRewards.add(
                expectedRewards
            );

            if (getVip(inviter) >= ind && getVip(inviter) >= pVip) {
                uint256 rew0 = amount
                    .mul(1e18)
                    .mul(levelConfig[ind - 1])
                    .div(100)
                    .div(getp2());

                uint256 rew1 = acc.capital.mul(levelConfig[ind - 1]).div(100);

                uint256 trew;
                if (rew0 > rew1) {
                    trew = rew1;
                } else {
                    trew = rew0;
                }

                if (
                    acc.receivedRewards.add(trew).add(acc.getDynamicRewards) <=
                    acc.selfExpectedRewards
                ) {
                    acc.getDynamicRewards = acc.getDynamicRewards.add(trew);
                } else {
                    acc.getDynamicRewards = acc
                        .selfExpectedRewards
                        .sub(acc.receivedRewards)
                        .sub(acc.getDynamicRewards);
                }

                if (pToken.balanceOf(inviter) >= paypToken)
                    nowPartnerExpectedRewards = nowPartnerExpectedRewards.add(
                        amount.mul(1e18).div(getp2())
                    );
            }
        }

        token.safeTransferFrom(msg.sender, address(this), amount);

        if (accountInfo[msg.sender].jClaimAt == 0)
            accountInfo[msg.sender].jClaimAt = block.timestamp;
        if (accountInfo[msg.sender].dClaimAt == 0)
            accountInfo[msg.sender].dClaimAt = block.timestamp;
        accountInfo[msg.sender].capital = accountInfo[msg.sender].capital.add(
            amount.mul(1e18).div(getp2())
        );
        accountInfo[msg.sender].selfExpectedRewards = accountInfo[msg.sender]
            .selfExpectedRewards
            .add(expectedRewards);

        nowTotalHash = nowTotalHash.add(amount);
        nowExpectedRewards = nowExpectedRewards.add(
            amount.mul(1e18).div(getp2())
        );

        emit Deposit(msg.sender, amount, expectedRewards);
    }

    function releaseDividends(address[] memory partners, uint256 amount)
        external
        onlyOwner
    {
        for (uint256 i = 0; i < partners.length; i++) {
            uint256 ph = accountInfo[partners[i]].teamExpectedRewards;
            accountInfo[partners[i]].getPRewards = accountInfo[partners[i]]
                .getPRewards
                .add(amount.mul(ph).div(nowPartnerExpectedRewards));
        }
    }

    function pWithdraw() external {
        if (accountInfo[msg.sender].getPRewards > 0) {
            accountInfo[msg.sender].receivedPRewards = accountInfo[msg.sender]
                .receivedPRewards
                .add(accountInfo[msg.sender].getPRewards);
            accountInfo[msg.sender].getPRewards = 0;

            token.safeTransfer(msg.sender, accountInfo[msg.sender].getPRewards);
        }
    }

    function earnedPrivateRewards(address user)
        public
        view
        returns (uint256, uint256)
    {
        AccountInfo memory acc = accountInfo[user];
        if (acc.receivedRewards >= acc.selfExpectedRewards) return (0, 0);

        uint256 r = block.timestamp.sub(acc.jClaimAt) / cliff;

        uint256 cWithdraw = acc.getTranslateRewards +
            acc.selfExpectedRewards.mul(5).div(10000).mul(r);

        uint256 accRes = acc.selfExpectedRewards.sub(acc.receivedRewards);

        return
            accRes >= cWithdraw
                ? (cWithdraw, cWithdraw.mul(getp2()).div(1e18))
                : (accRes, accRes.mul(getp2()).div(1e18));
    }

    function earnedDynamicRewards(address user)
        public
        view
        returns (uint256, uint256)
    {
        AccountInfo memory acc = accountInfo[user];
        if (acc.receivedRewards == acc.selfExpectedRewards) return (0, 0);

        uint256 r = block.timestamp.sub(acc.dClaimAt) / cliff;

        uint256 accRes = acc.capital.mul(r + 1).sub(
            acc.todayReceivedDynamicRewards
        );

        return
            acc.getDynamicRewards <= accRes
                ? (
                    acc.getDynamicRewards,
                    acc.getDynamicRewards.mul(getp2()).div(1e18)
                )
                : (accRes, accRes.mul(getp2()).div(1e18));
    }

    function withdrawPrivateRewards(uint256 amount) external {
        require(
            block.timestamp.sub(accountInfo[msg.sender].jClaimAt) >= cliff,
            "Insufficient claim time"
        );

        uint256 vip = getVip(msg.sender) + 1;

        uint256 r = 10;
        if (admittanceToken.balanceOf(msg.sender) >= vip * 1e18) r = 0;

        (, uint256 trew) = earnedPrivateRewards(msg.sender);

        require(trew >= amount, "Insufficient amount");

        if (amount > 0) {
            accountInfo[msg.sender].jClaimAt = block.timestamp;
            accountInfo[msg.sender].receivedRewards = accountInfo[msg.sender]
                .receivedRewards
                .add(amount.mul(1e18).div(getp2()));
            if (
                accountInfo[msg.sender].receivedRewards ==
                accountInfo[msg.sender].selfExpectedRewards
            ) {
                accountInfo[msg.sender].capital = 0;
            }
            if (amount < trew) {
                accountInfo[msg.sender].getTranslateRewards = accountInfo[
                    msg.sender
                ].getTranslateRewards.add(
                        (trew - amount).mul(1e18).div(getp2())
                    );
            }

            token.safeTransfer(msg.sender, amount.mul(100 - r).div(100));
            if (r > 0)
                token.safeTransfer(address(this), amount.mul(r).div(100));
        }

        emit Withdrawn(
            msg.sender,
            amount.mul(100 - r).div(100),
            amount.mul(r).div(100),
            true
        );
    }

    function withdrawDynamicRewards() external {
        require(
            accountInfo[msg.sender].dClaimAt >= block.timestamp,
            "Insufficient claim time"
        );
        uint256 vip = getVip(msg.sender) + 1;

        uint256 r = 10;
        if (admittanceToken.balanceOf(msg.sender) >= vip * 1e18) r = 0;

        (uint256 rew0, uint256 trew0) = earnedDynamicRewards(msg.sender);

        uint256 rew = rew0.div(10);
        uint256 trew = trew0.div(10);

        if (trew > 0) {
            accountInfo[msg.sender].receivedRewards = accountInfo[msg.sender]
                .receivedRewards
                .add(rew);
            if (
                accountInfo[msg.sender].receivedRewards ==
                accountInfo[msg.sender].selfExpectedRewards
            ) {
                accountInfo[msg.sender].capital = 0;
            }
            accountInfo[msg.sender].getDynamicRewards = accountInfo[msg.sender]
                .getDynamicRewards
                .sub(rew);

            uint256 bt = (block.timestamp - accountInfo[msg.sender].dClaimAt) /
                cliff;
            if (bt > 0) {
                accountInfo[msg.sender].dClaimAt = accountInfo[msg.sender]
                    .dClaimAt
                    .add(cliff * (bt + 1));

                if (accountInfo[msg.sender].capital * bt >= rew) {
                    accountInfo[msg.sender].todayReceivedDynamicRewards = 0;
                } else {
                    accountInfo[msg.sender].todayReceivedDynamicRewards = rew
                        .sub(accountInfo[msg.sender].capital * bt);
                }
            } else {
                accountInfo[msg.sender]
                    .todayReceivedDynamicRewards = accountInfo[msg.sender]
                    .todayReceivedDynamicRewards
                    .add(rew);
            }

            token.safeTransfer(msg.sender, trew.mul(100 - r).div(100));
            if (r > 0) token.safeTransfer(address(this), trew.mul(r).div(100));
        }

        emit Withdrawn(
            msg.sender,
            trew.mul(100 - r).div(100),
            trew.mul(r).div(100),
            false
        );
    }

    function removeAleadyMyChilds(address user) internal {
        address parent = _parents[user];
        isAleadyMyChilders[user] = false;
        _aleadyMyChilders[parent][
            _aleadyMyChildersIndexes[parent]
        ] = _aleadyMyChilders[parent][_aleadyMyChilders[parent].length - 1];
        _aleadyMyChildersIndexes[
            _aleadyMyChilders[parent][_aleadyMyChilders[parent].length - 1]
        ] = _aleadyMyChildersIndexes[parent];
        _aleadyMyChilders[parent].pop();
    }

    function bindParent(address parent) external {
        require(_parents[msg.sender] == address(0), "Already bind");
        require(parent != address(0), "ERROR parent, address is zero");
        require(parent != msg.sender, "ERROR parent, address is self");
        _parents[msg.sender] = parent;
        isAleadyMyChilders[msg.sender] = true;
        _aleadyMyChildersIndexes[parent] = _aleadyMyChilders[parent].length;
        _aleadyMyChilders[parent].push(msg.sender);
        emit BindingParents(msg.sender, parent);
    }

    function setParentByAdmin(address user, address parent) external {
        require(_parents[user] == address(0), "Already bind");
        require(msg.sender == _owner);
        _parents[user] = parent;
        isAleadyMyChilders[user] = true;
        _aleadyMyChildersIndexes[parent] = _aleadyMyChilders[parent].length;
        _aleadyMyChilders[parent].push(user);
    }

    function changeadmittanceToken(IERC20 newadmittanceToken)
        external
        onlyOwner
    {
        admittanceToken = newadmittanceToken;
    }

    function changeMinadmittanceToken(uint256 newMinadmittanceToken)
        external
        onlyOwner
    {
        minadmittanceToken = newMinadmittanceToken;
    }

    function changepToken(IERC20 newpToken) external onlyOwner {
        pToken = newpToken;
    }

    function changetoken(IERC20 newtoken) external onlyOwner {
        token = newtoken;
    }

    function changePaypToken(uint256 newPaypToken) external onlyOwner {
        paypToken = newPaypToken;
    }

    function changeRate(uint256 newRate) external onlyOwner {
        _rate = newRate;
    }

    function rate() public view returns (uint256) {
        return _rate;
    }

    function totalRate() public view returns (uint256) {
        return _totalrate;
    }

    function getParent(address user) public view returns (address) {
        return _parents[user];
    }

    function getVip(address user) public view returns (uint256) {
        uint256 cLen = _mychilders[user].length;
        return cLen >= 20 ? 20 : cLen;
    }

    function getMyChildersLen(address user) public view returns (uint256) {
        return _mychilders[user].length;
    }

    function getMyChilders(
        address user,
        uint256 start,
        uint256 limit
    ) public view returns (address[] memory, uint256[] memory) {
        uint256 cLen = _mychilders[user].length;
        address[] memory c;
        uint256[] memory v;
        if (cLen > start) {
            uint256 size = cLen - start > limit ? limit : cLen - start;
            c = new address[](size);
            v = new uint256[](size);
            for (uint256 i = 0; i < size; i++) {
                address a = _mychilders[user][start + i];
                c[i] = a;
                v[i] = getVip(a);
            }
        }
        return (c, v);
    }

    function getAleadyMyChilders(
        address user,
        uint256 start,
        uint256 limit
    ) public view returns (address[] memory) {
        if (start == 0 && limit == 0) return _aleadyMyChilders[user];
        uint256 cLen = _aleadyMyChilders[user].length;
        address[] memory c;
        if (cLen > start) {
            uint256 size = cLen - start > limit ? limit : cLen - start;
            c = new address[](size);
            for (uint256 i = 0; i < size; i++) {
                c[i] = _aleadyMyChilders[user][start + i];
            }
        }
        return c;
    }

    function getp2() public view returns (uint256) {
        uint256[] memory amounts;
        address[] memory path = new address[](3);
        path[0] = address(token);
        path[1] = address(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c);
        path[2] = address(0x55d398326f99059fF775485246999027B3197955);
        amounts = PancakeRouter01.getAmountsIn(1e18, path);
        if (amounts.length > 0) {
            return amounts[0];
        } else {
            return 0;
        }
    }

    function OwnerWithdraw(address _to, uint256 _amount) public onlyOwner {
        token.safeTransfer(_to, _amount);
    }

    function OwnerAllWithdraw(address _to) public onlyOwner {
        token.safeTransfer(_to, token.balanceOf(address(this)));
    }
}