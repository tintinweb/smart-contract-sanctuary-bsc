/**
 *Submitted for verification at BscScan.com on 2023-02-13
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;


// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.
library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }
}


// Interface of the ERC20 standard as defined in the EIP.
interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function allowance(address from, address to) external view returns (uint256);
    function approve(address to, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}


// safe transfer
library TransferHelper {
    function safeApprove(address token, address to, uint value) internal {
        // bytes4(keccak256(bytes('approve(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: APPROVE_FAILED');
    }

    function safeTransfer(address token, address to, uint value) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FAILED');
    }

    function safeTransferFrom(address token, address from, address to, uint value) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FROM_FAILED');
    }

    function safeTransferETH(address to, uint value) internal {
        (bool success,) = to.call{value:value}(new bytes(0));
        // (bool success,) = to.call.value(value)(new bytes(0));
        require(success, 'TransferHelper: ETH_TRANSFER_FAILED');
    }
}


// PriceUSDTCalcuator interface
interface IPriceUSDTCalcuator {
    function tokenPriceUSDT(address token) external view returns(uint256);
    function lpPriceUSDT(address lp) external view returns(uint256);
}

// CardNFT interface
interface ICardNFT {
    function card(address account) external view returns(uint256);
    function mintCard(address account, uint256 grade) external;
    function burnCard(address account) external;
}

// crystal interface
interface ICrystal {
    function crystalPriceUSDT() external view returns (uint256);
    function mintCrystal(address account, uint256 amount) external returns (bool);
    function burnCrystal(address account, uint256 amount) external returns (bool);
}

// ETELeaderTracker interface
interface IETELeaderTracker {
    function swapToLeader(address _eteToken) external;
}


// owner
abstract contract Ownable {
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, 'owner error');
        _;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        if (newOwner != address(0)) {
            owner = newOwner;
        }
    }
}


// LockPositions interface
interface ILockPositions {
    function lockPriceUSDT(uint256) external view returns (uint256);
    function buyPriceUSDT(uint256) external view returns (uint256);
}


// mining v1
// tpis: lockLp=ETE-ETH-LP, eteUserToken=SETE, eteCardToken=XETE.
contract LockPositions is ILockPositions, Ownable {
    using SafeMath for uint256;


    address public cardNFT;            // card contract address.
    address public priceUSDTCalcuator; // price usdt calculator contract address.
    address public lockLp;             // lock lp use LP, and LP swap eteCardToken.
    address public usdt;
    address public ete;
    address public eteUserToken;
    address public eteCardToken;
    address public crystal;
    address public eteLeaderTracker;   // ete leader tracker contract address.

    // lock price usdt amount, 1=glory card, 2=star card, other=not exist.
    mapping(uint256 => uint256) public lockPriceUSDT;
    // usdt buy card and burn ete get card of need usdt amount.
    mapping(uint256 => uint256) public buyPriceUSDT;

    // account lock LP gain eteCardToken record. 0=never before,1=gain glory eteCardToken,2=gain star eteCardToken.
    // tips: beacuse gain eteCardToken for once, but card can upgrade, so star card as upper limint.
    mapping(address => uint256) public lockGainEteCardTokenRecord; 
    // get crystal multiple ratio. default 100%
    uint256 public crystalMul = 100;


    constructor(
        address cardNFT_,
        address priceUSDTCalcuator_,
        address lockLp_,
        address usdt_,
        address ete_,
        address eteUserToken_,
        address eteCardToken_,
        address crystal_,
        address eteLeaderTracker_
    ) {
        cardNFT = cardNFT_;
        priceUSDTCalcuator = priceUSDTCalcuator_;
        lockLp = lockLp_;
        usdt = usdt_;
        ete = ete_;
        eteUserToken = eteUserToken_;
        eteCardToken = eteCardToken_;
        crystal = crystal_;
        eteLeaderTracker = eteLeaderTracker_;

        // default lock price usdt.
        lockPriceUSDT[1] = 1000*(1e18);
        lockPriceUSDT[2] = 2000*(1e18);
        // default usdt buy and burn ete get card usdt amount.
        buyPriceUSDT[1] = 500*(1e18);
        buyPriceUSDT[2] = 1000*(1e18);
    }


    event LockingGainCard(address account, uint256 card, uint256 usdtAmount, uint256 lpAmount, uint256 crystalAmount, uint256 eteCardTokenAmount);
    event PayUSDTGainCard(address account, uint256 card, uint256 usdtAmount);
    event BurnETEGainCard(address account, uint256 card, uint256 usdtAmount, uint256 eteAmount);
    event LpSwapEteUserToken(address account, uint256 lpAmount, uint256 eteUserTokenAmount);
    event EteUserTokenAmountSwapETE(address account, uint256 eteUserTokenAmount, uint256 eteAmount);


    function setCardNFT(address newCardNFT) public onlyOwner {
        cardNFT = newCardNFT;
    }
    function setPriceUSDTCalcuator(address newPriceUSDTCalcuator) public onlyOwner {
        priceUSDTCalcuator = newPriceUSDTCalcuator;
    }
    function setLockLp(address newLockLp) public onlyOwner {
        lockLp = newLockLp;
    }
    function setUSDT(address newUSDT) public onlyOwner {
        usdt = newUSDT;
    }
    function setETE(address newETE) public onlyOwner {
        ete = newETE;
    }
    function setEteUserToken(address newEteUserToken) public onlyOwner {
        eteUserToken = newEteUserToken;
    }
    function setEteCardToken(address newEteCardToken) public onlyOwner {
        eteCardToken = newEteCardToken;
    }
    function setCrystal(address newCrystal) public onlyOwner {
        crystal = newCrystal;
    }
    function setEteLeaderTracker(address newEteLeaderTracker) public onlyOwner {
        eteLeaderTracker = newEteLeaderTracker;
    }

    function setLockPriceUSDT(uint256 card, uint256 newPriceUSDT) public onlyOwner {
        require(card == 1 || card == 2, "card error");
        require(newPriceUSDT > 0, "price error");
        lockPriceUSDT[card] = newPriceUSDT;
    }

    function setBuyPriceUSDT(uint256 card, uint256 newPriceUSDT) public onlyOwner {
        require(card == 1 || card == 2, "card error");
        require(newPriceUSDT > 0, "price error");
        buyPriceUSDT[card] = newPriceUSDT;
    }

    function setCrystalMul(uint256 newCrystalMul) public onlyOwner {
        crystalMul = newCrystalMul;
    }


    // lock lp get card and eteCardToken and crystal.
    // @card: 1=glory card, 2=star card.
    function lockLpGainCard(uint256 card) public {
        require(card == 1 || card == 2, "card error");
        address account = msg.sender;
        uint256 amount = lockPriceUSDT[card]; // usdt amount.
        require(card > ICardNFT(cardNFT).card(account), "already is card");
        
        // before calculate price.
        uint256 lpPrice = IPriceUSDTCalcuator(priceUSDTCalcuator).lpPriceUSDT(lockLp);
        uint256 crystalPrice = ICrystal(crystal).crystalPriceUSDT();
        uint256 lpAmount = lpPrice.mul(amount).div(1e18);                                    // transfer lp amount
        uint256 crystalAmount = amount.mul(1e18).div(crystalPrice).mul(crystalMul).div(100); // transfer crystal amount
        // pay lp, gain card and crystal.
        require(lpAmount > 0, "lp amount is zero");
        TransferHelper.safeTransferFrom(lockLp, account, address(this), lpAmount);
        ICardNFT(cardNFT).mintCard(account, card);
        ICrystal(crystal).mintCrystal(account, crystalAmount);

        // eteCardToken
        uint256 accountLockRecord = lockGainEteCardTokenRecord[account];
        uint256 eteCardTokenAmount = 0;
        // 2-0, 2-1, 1-0.
        if(card > accountLockRecord) {
            eteCardTokenAmount = accountLockRecord == 1 ? lockPriceUSDT[2].sub(lockPriceUSDT[1]) : amount;
            if(eteCardTokenAmount > 0) TransferHelper.safeTransfer(eteCardToken, account, eteCardTokenAmount);
            lockGainEteCardTokenRecord[account] = card;
        }

        // emit
        emit LockingGainCard(account, card, amount, lpAmount, crystalAmount, eteCardTokenAmount);
    }

    // pay usdt buy card.
    function payUSDTGainCard(uint256 card) public {
        require(card == 1 || card == 2, "card error");
        address account = msg.sender;
        require(card > ICardNFT(cardNFT).card(account), "already is card");

        uint256 amount = buyPriceUSDT[card];
        require(amount > 0, "usdt amount is zero");
        TransferHelper.safeTransferFrom(usdt, account, address(this), amount);
        ICardNFT(cardNFT).mintCard(account, card);

        // emit
        emit PayUSDTGainCard(account, card, amount);

        // help swap
        _helpSwap();
    }

    // burn ete buy card.
    function burnETEGainCard(uint256 card) public {
        require(card == 1 || card == 2, "card error");
        address account = msg.sender;
        require(card > ICardNFT(cardNFT).card(account), "already is card");

        uint256 etePrice = IPriceUSDTCalcuator(priceUSDTCalcuator).tokenPriceUSDT(ete);
        uint256 amount = buyPriceUSDT[card];
        uint256 burnETEAmount = amount.mul(1e18).div(etePrice);
        require(burnETEAmount > 0, "ete amount is zero");
        TransferHelper.safeTransferFrom(ete, account, address(0), burnETEAmount);
        ICardNFT(cardNFT).mintCard(account, card);

        // emit
        emit BurnETEGainCard(account, card, amount, burnETEAmount);

        // help swap
        _helpSwap();
    }

    // ete-eth-lp swap eq value usdt as eteUserToken.
    function lpSwapEteUserToken(uint256 lpAmount) public {
        require(lpAmount > 0, "amount is zero error");

        uint256 lpPrice = IPriceUSDTCalcuator(priceUSDTCalcuator).lpPriceUSDT(lockLp);
        uint256 eteUserTokenAmount = lpAmount.mul(lpPrice).div(1e18);

        address account = msg.sender;
        TransferHelper.safeTransferFrom(lockLp, account, address(this), lpAmount);
        require(eteUserTokenAmount > 0, "sete amount is zero");
        TransferHelper.safeTransfer(eteUserToken, account, eteUserTokenAmount);

        // emit
        emit LpSwapEteUserToken(account, lpAmount, eteUserTokenAmount);

        // help swap
        _helpSwap();
    }

    // eteUserToken swap eq value usdt as ete
    function eteUserTokenSwapETE(uint256 eteUserTokenAmount) public {
        require(eteUserTokenAmount > 0, "amount is zero error");

        uint256 etePrice = IPriceUSDTCalcuator(priceUSDTCalcuator).tokenPriceUSDT(ete);
        uint256 eteAmount = eteUserTokenAmount.mul(1e18).div(etePrice);

        address account = msg.sender;
        TransferHelper.safeTransferFrom(eteUserToken, account, address(this), eteUserTokenAmount);
        require(eteAmount > 0, "ete amount is zero");
        TransferHelper.safeTransfer(ete, account, eteAmount);

        // emit
        emit EteUserTokenAmountSwapETE(account, eteUserTokenAmount, eteAmount);

        // help swap
        _helpSwap();
    }

    // help swap earn.
    function _helpSwap() private {
        try IETELeaderTracker(eteLeaderTracker).swapToLeader(ete) {} catch {}
    }

    // take token
    function takeToken(address token, address to, uint256 value) external onlyOwner {
        require(to != address(0), "zero address error");
        require(value > 0, "value zero error");
        TransferHelper.safeTransfer(token, to, value);
    }

}