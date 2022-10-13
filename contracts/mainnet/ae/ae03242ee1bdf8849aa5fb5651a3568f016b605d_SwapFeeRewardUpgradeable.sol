//SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/structs/EnumerableSetUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import "./interfaces/IBiswapNFT.sol";
import "./interfaces/IBiswapFactory.sol";
import "./interfaces/IBiswapPair.sol";
import "./interfaces/IOracle.sol";
import "./interfaces/IBiswapCollectiblesNFT.sol";
import "./interfaces/ISwapFeeRewardWithRBOld.sol";

contract SwapFeeRewardUpgradeable is Initializable, OwnableUpgradeable, ReentrancyGuardUpgradeable {
    struct TokensPath {
        address output;
        address anchor;
        address intermediate;
    }

    address public constant USDT = 0x55d398326f99059fF775485246999027B3197955;
    uint public constant maxMiningAmount = 100000000 ether; //todo reduce by already minted amount???
    uint public constant maxMiningInPhase = 5000 ether;
    uint public constant maxAccruedRBInPhase = 5000 ether;
    uint public constant defaultFeeDistribution = 90;
    address public constant factory = 0x858E3312ed3A876947EA49d572A7C42DE08af7EE;

    address public router;
    address public market;
    address public auction;

    uint public currentPhase;
    uint public currentPhaseRB;
    uint public totalMined;
    uint public totalAccruedRB;
    uint public rbWagerOnSwap; //Wager of RB
    uint public rbPercentMarket; // (div 10000)
    uint public rbPercentAuction; // (div 10000)
    address public targetToken;
    address public targetRBToken;

    IERC20Upgradeable public bswToken;
    IOracle public oracle;
    IBiswapNFT public biswapNFT;
    IBiswapCollectiblesNFT public collectiblesNFT;
    ISwapFeeRewardWithRBOld public constant oldSwapFeeReward =
        ISwapFeeRewardWithRBOld(0x04eFD76283A70334C72BB4015e90D034B9F3d245);

    mapping(address => uint) public nonces;
    mapping(address => uint) private _balances;
    mapping(address => mapping(address => address)) public intermediateToken; //intermediate tokens: output token =>  anchorToken => intermediate; if intermediate == 0 direct pair

    mapping(address => mapping(uint => uint)) public tradeVolume; //trade amount userAddress => day => accumulated amount
    mapping(uint => mapping(uint => uint)) public cashbackVolumeByMonth; //Accrue cashback by tokenId by month
    //percent of distribution between feeReward and robiBoost [0, 90] 0 => 90% feeReward and 10% robiBoost; 90 => 100% robiBoost
    //calculate: defaultFeeDistribution (90) - feeDistibution = feeReward
    mapping(address => uint) public feeDistribution; //todo del in prod

    mapping(address => uint) public percentReward; //percent reward: pair address => percent (base 100)

    struct Cashback {
        uint16 percent;
        uint128 monthlyLimit;
    }

    Cashback[] public cashbackPercent; // Cashback percent base 10000 index = level - 1
    address[] public pairsList; //list of pairs with reward

    event Withdraw(address userAddress, uint amount);
    event Rewarded(address account, address input, address output, uint amount, uint quantity);
    event NewRouter(address);
    event NewFactory(address);
    event NewMarket(address);
    event NewPhase(uint);
    event NewPhaseRB(uint);
    event NewAuction(address);
    event NewBiswapNFT(IBiswapNFT);
    event NewOracle(IOracle);
    event CashbackRewarded(
        uint tokenId,
        uint rewardAmount,
        uint currentMounth,
        uint accumulatedCashbackByMonth,
        uint balance
    );
    event WithdrawCashback(address user, uint tokenId, uint balance);
    event IntermediateTokenSet(TokensPath[]);
    event IntermediateTokenNotAdded(TokensPath);
    event NewCashbackPercent(Cashback[]);

    modifier onlyRouter() {
        require(msg.sender == router, "SwapFeeReward: caller is not the router");
        _;
    }

    modifier onlyMarket() {
        require(msg.sender == market, "SwapFeeReward: caller is not the market");
        _;
    }

    modifier onlyAuction() {
        require(msg.sender == auction, "SwapFeeReward: caller is not the auction");
        _;
    }

    function initialize(
        address _router,
        IERC20Upgradeable _bswToken,
        IOracle _Oracle,
        IBiswapNFT _biswapNFT,
        IBiswapCollectiblesNFT _collectiblesNFT,
        address _targetToken,
        address _targetRBToken,
        Cashback[] calldata _cashbackPercent
    ) public initializer {
        require(
            _router != address(0) && _targetToken != address(0) && _targetRBToken != address(0),
            "Address can not be zero"
        );
        __ReentrancyGuard_init();
        __Ownable_init();

        router = _router;
        bswToken = _bswToken;
        oracle = _Oracle;
        biswapNFT = _biswapNFT;
        collectiblesNFT = _collectiblesNFT;
        targetToken = _targetToken;
        targetRBToken = _targetRBToken;

        currentPhase = 1;
        currentPhaseRB = 1;
        rbWagerOnSwap = 1500;
        rbPercentMarket = 2222;
        rbPercentAuction = 2222;

        setCashbackPercent(_cashbackPercent);
    }

    function getCurrentMonth() public view returns (uint month) {
        month = block.timestamp / 30 days;
    }

    function setCashbackPercent(Cashback[] calldata newCashbackPercent) public onlyOwner {
        require(newCashbackPercent.length == collectiblesNFT.MAX_LEVEL(), "Wrong array size");
        delete cashbackPercent;
        for (uint i; i < newCashbackPercent.length; i++) {
            cashbackPercent.push(newCashbackPercent[i]);
        }
        emit NewCashbackPercent(newCashbackPercent);
    }

    function setIntermediateToken(TokensPath[] calldata tokens) external onlyOwner {
        for (uint i = 0; i < tokens.length; i++) {
            if (tokens[i].anchor != tokens[i].intermediate) {
                intermediateToken[tokens[i].output][tokens[i].anchor] = tokens[i].intermediate;
            } else {
                emit IntermediateTokenNotAdded(tokens[i]);
            }
        }
        emit IntermediateTokenSet(tokens);
    }

    function sortTokens(address tokenA, address tokenB) public pure returns (address token0, address token1) {
        require(tokenA != tokenB, "IDENTICAL_ADDRESSES");
        (token0, token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        require(token0 != address(0), "ZERO_ADDRESS");
    }

    function pairFor(address tokenA, address tokenB) public pure returns (address pair) {
        (address token0, address token1) = sortTokens(tokenA, tokenB);
        pair = address(
            uint160(
                uint(
                    keccak256(
                        abi.encodePacked(
                            hex"ff",
                            factory,
                            keccak256(abi.encodePacked(token0, token1)),
                            hex"fea293c909d87cd4153593f077b76bb7e94340200f4ee84211ae8e4f9bd7ffdf"
                        )
                    )
                )
            )
        );
    }

    function getSwapFee(address tokenA, address tokenB) internal view returns (uint swapFee) {
        swapFee = IBiswapPair(pairFor(tokenA, tokenB)).swapFee();
    }

    function setPhase(uint _newPhase) public onlyOwner returns (bool) {
        currentPhase = _newPhase;
        emit NewPhase(_newPhase);
        return true;
    }

    function setPhaseRB(uint _newPhase) public onlyOwner returns (bool) {
        currentPhaseRB = _newPhase;
        emit NewPhaseRB(_newPhase);
        return true;
    }

    function checkPairExist(address tokenA, address tokenB) public view returns (bool) {
        address pair = pairFor(tokenA, tokenB);
        return percentReward[pair] > 0;
    }

    struct SwapData {
        uint feeReturnAmount;
        uint rbAccrueAmount;
        uint cashBackAmount;
        uint selectedTokenId;
        uint amountOutInTargetRBToken;
        address pair;
        uint pairFee;
    }

    struct SwapInfo {
        uint amountOut;
        uint price;
        uint priceImpact;
        uint tradeFee;
        uint tradeFeeUSDT;
        uint feeReturn;
        uint feeReturnUSDT;
        uint rbAmount;
    }

    function getFeeDistribution(address account) public view returns (uint feeDistr) {
        feeDistr = defaultFeeDistribution - oldSwapFeeReward.feeDistribution(account);
    }

    function swapInfo(
        address account,
        address[] memory path,
        uint amountIn
    ) public view returns (SwapInfo memory _swapInfo) {
        require(path.length >= 2, "FeeRewardHelper: INVALID_PATH");
        uint[] memory amountsOut = new uint[](path.length);

        amountsOut[0] = amountIn;
        _swapInfo.tradeFee = 1;
        uint reserve0;

        uint feeDistr = getFeeDistribution(account);

        for (uint i; i < path.length - 1; i++) {
            IBiswapPair _pair = IBiswapPair(pairFor(path[i], path[i + 1]));
            uint _pairFee = 1000 - _pair.swapFee();
            (uint reserveIn, uint reserveOut, ) = _pair.getReserves();
            (reserveIn, reserveOut) = _pair.token0() == path[i] ? (reserveIn, reserveOut) : (reserveOut, reserveIn);
            if (i == 0) reserve0 = reserveIn;
            amountsOut[i + 1] = getAmountOut(amountsOut[i], reserveIn, reserveOut, _pairFee);

            SwapData memory swapData = calcSwap(account, feeDistr, path[i], path[i + 1], amountsOut[i + 1]);
            _swapInfo.rbAmount += swapData.rbAccrueAmount;
            _swapInfo.feeReturn += swapData.feeReturnAmount;
            _swapInfo.tradeFee *= _pairFee;
        }
        //1e18   -      1e18 *998 /
        _swapInfo.tradeFee = amountIn - (amountIn * _swapInfo.tradeFee) / (1000**(path.length - 1));
        _swapInfo.tradeFeeUSDT = getQuantity(path[0], _swapInfo.tradeFee, USDT);
        _swapInfo.feeReturnUSDT = getQuantity(targetToken, _swapInfo.feeReturn, USDT);
        _swapInfo.amountOut = amountsOut[path.length - 1];
        _swapInfo.price = (_swapInfo.amountOut * 1e12) / amountIn;

        uint amountInWithFee = amountIn - _swapInfo.tradeFee;
        _swapInfo.priceImpact = (1e12 * amountInWithFee) / (reserve0 + amountInWithFee);
    }

    function getAmountOut(
        uint amountIn,
        uint reserveIn,
        uint reserveOut,
        uint swapFee
    ) internal pure returns (uint amountOut) {
        require(amountIn > 0, "INSUFFICIENT_INPUT_AMOUNT");
        require(reserveIn > 0 && reserveOut > 0, "INSUFFICIENT_LIQUIDITY");
        uint amountInWithFee = amountIn * swapFee;
        uint numerator = amountInWithFee * reserveOut;
        uint denominator = reserveIn * 1000 + amountInWithFee;
        amountOut = numerator / denominator;
    }

    function swap(
        address account,
        address input,
        address output,
        uint amountOut
    ) public onlyRouter returns (bool) {
        SwapData memory swapData = calcSwap(account, getFeeDistribution(account), input, output, amountOut);
        if (swapData.feeReturnAmount == 0 && swapData.rbAccrueAmount == 0) return false;

        //Accrue RB
        if (swapData.rbAccrueAmount > 0 && address(biswapNFT) != address(0)) {
            if (totalAccruedRB + swapData.rbAccrueAmount <= currentPhaseRB * maxAccruedRBInPhase) {
                totalAccruedRB += swapData.rbAccrueAmount;
                biswapNFT.accrueRB(account, swapData.rbAccrueAmount); //event emitted from BiswapNFT
            }
        }

        //Accrue cashback
        if (swapData.selectedTokenId != 0 && swapData.cashBackAmount != 0) {
            _balances[address(uint160(swapData.selectedTokenId))] += swapData.cashBackAmount; //todo test withdraw cashback from NFT
            uint curMouth = getCurrentMonth();
            emit CashbackRewarded(
                swapData.selectedTokenId,
                swapData.cashBackAmount,
                curMouth,
                cashbackVolumeByMonth[swapData.selectedTokenId][curMouth],
                _balances[address(uint160(swapData.selectedTokenId))]
            );
        }

        //Accrue fee return
        uint _totalMined = totalMined;
        if (maxMiningAmount >= _totalMined + swapData.feeReturnAmount) {
            //todo check maybe increase total mined when accrue
            if (_totalMined + swapData.feeReturnAmount <= currentPhase * maxMiningInPhase) {
                _balances[account] += swapData.feeReturnAmount;
                emit Rewarded(account, input, output, amountOut, swapData.feeReturnAmount);
            }
        }

        //Save trade volume
        if (swapData.amountOutInTargetRBToken != 0) {
            tradeVolume[account][block.timestamp / 1 days] += swapData.amountOutInTargetRBToken;
        }

        return true;
    }
    //todo tests:
    // - calc feeReturnAmount, rbAccrueAmount, cashBackAmount when one of value of: amountOutInTargetRBToken, amountOutInTargetToken is zero
    // - check calc cashBackAmount when
    function calcSwap(
        address account,
        uint feeDistr,
        address input,
        address output,
        uint amountOut
    ) public view returns (SwapData memory swapData) {
        swapData.pair = pairFor(input, output);
        uint _percentReward = percentReward[swapData.pair];
        if (_percentReward == 0) {
            return swapData;
        }
        swapData.pairFee = IBiswapPair(swapData.pair).swapFee();
        swapData.amountOutInTargetRBToken = getQuantity(output, amountOut, targetRBToken);
        uint amountOutInTargetToken = getQuantity(output, amountOut, targetToken);
        if(swapData.amountOutInTargetRBToken == 0 && amountOutInTargetToken == 0) return swapData;
        swapData.feeReturnAmount =
            (((amountOutInTargetToken * swapData.pairFee) / (1000 - swapData.pairFee)) * _percentReward * feeDistr) /
            10000;
        swapData.rbAccrueAmount = (swapData.amountOutInTargetRBToken * (100 - feeDistr)) / (100 * rbWagerOnSwap);
        uint8 level;
        (swapData.selectedTokenId, level) = collectiblesNFT.getUserSelectedTokenId(account);
        if (swapData.selectedTokenId != 0 && account.code.length == 0) {
            Cashback memory currCashBack = cashbackPercent[level - 1];
            swapData.cashBackAmount =
                (((amountOutInTargetToken * swapData.pairFee) / (1000 - swapData.pairFee)) * currCashBack.percent) /
                10000;
            if (
                cashbackVolumeByMonth[swapData.selectedTokenId][getCurrentMonth()] + swapData.cashBackAmount >
                currCashBack.monthlyLimit
            ) {
                swapData.cashBackAmount =
                    currCashBack.monthlyLimit -
                    cashbackVolumeByMonth[swapData.selectedTokenId][getCurrentMonth()];
            }
        }
        return swapData;
    }

    function getUserCashbackBalances(address user)
        external
        view
        returns (uint[] memory tokensId, uint[] memory balances)
    {
        uint nftBalances = collectiblesNFT.balanceOf(user);
        tokensId = new uint[](nftBalances);
        balances = new uint[](nftBalances);
        for (uint i = 0; i < nftBalances; i++) {
            tokensId[i] = collectiblesNFT.tokenOfOwnerByIndex(user, i);
            balances[i] = _balances[address(uint160(tokensId[i]))];
        }
    }

    function userTradeVolume(
        address user,
        uint firstDay,
        uint lastDay
    ) public view returns (uint[] memory volumes) {
        require(lastDay >= firstDay, "last day must be egt firstDay");
        volumes = new uint[](lastDay - firstDay + 1);
        for (uint i; i < lastDay - firstDay + 1; i++) {
            volumes[i] = tradeVolume[user][firstDay + i];
        }
    }

    function accrueRBFromMarket(
        address account,
        address fromToken,
        uint amount
    ) public onlyMarket {
        amount = (amount * rbPercentMarket) / 10000;
        _accrueRB(account, fromToken, amount);
    }

    function accrueRBFromAuction(
        address account,
        address fromToken,
        uint amount
    ) public onlyAuction {
        amount = (amount * rbPercentAuction) / 10000;
        _accrueRB(account, fromToken, amount);
    }

    function _accrueRB(
        address account,
        address output,
        uint amount
    ) private {
        uint quantity = getQuantity(output, amount, targetRBToken);
        if (quantity > 0) {
            totalAccruedRB = totalAccruedRB + quantity;
            if (totalAccruedRB <= currentPhaseRB * maxAccruedRBInPhase) {
                biswapNFT.accrueRB(account, quantity);
            }
        }
    }

    function rewardBalance(address account) public view returns (uint) {
        return _balances[account];
    }

    function rewardTokenBalance(uint tokenId) public view returns (uint) {
        return _balances[address(uint160(tokenId))];
    }

    function permit(
        address spender,
        uint value,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) private {
        bytes32 message = keccak256(
            abi.encodePacked(
                "\x19Ethereum Signed Message:\n32",
                keccak256(abi.encodePacked(spender, value, nonces[spender]++))
            )
        );
        address recoveredAddress = ecrecover(message, v, r, s);
        require(recoveredAddress != address(0) && recoveredAddress == spender, "SwapFeeReward: INVALID_SIGNATURE");
    }

    function withdrawCashback(
        uint8 v,
        bytes32 r,
        bytes32 s,
        uint tokenId
    ) public nonReentrant returns (bool) {
        require(maxMiningAmount > totalMined, "SwapFeeReward: Mined all tokens");
        require(collectiblesNFT.ownerOf(tokenId) == msg.sender, "Not owner of token");
        uint balance = _balances[address(uint160(tokenId))];
        require(
            totalMined + balance <= currentPhase * maxMiningInPhase,
            "SwapFeeReward: Mined all tokens in this phase"
        );
        permit(msg.sender, balance, v, r, s);
        if (balance > 0) {
            _balances[address(uint160(tokenId))] -= balance;
            totalMined += balance;
            if (bswToken.transfer(msg.sender, balance)) {
                emit WithdrawCashback(msg.sender, tokenId, balance);
                return true;
            }
        }
        return false;
    }

    function withdraw(
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public nonReentrant returns (bool) {
        require(maxMiningAmount > totalMined, "SwapFeeReward: Mined all tokens");
        uint balance = _balances[msg.sender];
        require(
            totalMined + balance <= currentPhase * maxMiningInPhase,
            "SwapFeeReward: Mined all tokens in this phase"
        );
        permit(msg.sender, balance, v, r, s);
        if (balance > 0) {
            _balances[msg.sender] -= balance;
            totalMined += balance;
            if (bswToken.transfer(msg.sender, balance)) {
                emit Withdraw(msg.sender, balance);
                return true;
            }
        }
        return false;
    }

    function getQuantity(
        address outputToken,
        uint outputAmount,
        address anchorToken
    ) public view returns (uint) {
        uint quantity = 0;
        if (outputToken == anchorToken) {
            quantity = outputAmount;
        } else {
            address intermediate = intermediateToken[outputToken][anchorToken];
            if (intermediate == address(0)) {
                quantity = 0;
            } else if (intermediate == outputToken) {
                quantity = IOracle(oracle).consult(intermediate, outputAmount, anchorToken);
            } else {
                uint interQuantity = IOracle(oracle).consult(outputToken, outputAmount, intermediate);
                quantity = IOracle(oracle).consult(intermediate, interQuantity, anchorToken);
            }
        }
        //
        return quantity;
    }

    function setOracle(IOracle _oracle) public onlyOwner {
        require(address(_oracle) != address(0), "SwapMining: new oracle is the zero address");
        oracle = _oracle;
        emit NewOracle(_oracle);
    }

    function pairsListLength() public view returns (uint) {
        return pairsList.length;
    }

    function setPairs(uint[] calldata _percentReward, address[] calldata _pair) public onlyOwner {
        require(_percentReward.length == _pair.length, "Wrong arrays length");

        for (uint i; i < _pair.length; i++) {
            require(_pair[i] != address(0), "_pair is the zero address");
            require(_percentReward[i] <= 100 && _percentReward[i] > 0, "Wrong percent reward");
            if (percentReward[_pair[i]] == 0) pairsList.push(_pair[i]);
            percentReward[_pair[i]] = _percentReward[i];
        }
    }

    function delPairFromList(address pair, uint pid) public onlyOwner {
        address[] memory _pairsList = pairsList;
        require(pid < _pairsList.length, "pid out of bound");
        delete percentReward[pair];
        if (_pairsList[pid] != pair) {
            for (uint i; i < _pairsList.length; i++) {
                if (_pairsList[i] == pair) {
                    pairsList[i] = pairsList[pairsList.length - 1];
                    pairsList.pop();
                    return;
                }
            }
        } else {
            pairsList[pid] = pairsList[pairsList.length - 1];
            pairsList.pop();
        }
    }

    function setRobiBoostReward(
        uint _rbWagerOnSwap,
        uint _percentMarket,
        uint _percentAuction
    ) public onlyOwner {
        rbWagerOnSwap = _rbWagerOnSwap;
        rbPercentMarket = _percentMarket;
        rbPercentAuction = _percentAuction;
    }

    //  Use OLD FeeReward contract value
    //    function setFeeDistribution(uint newDistribution) public {
    //        require(newDistribution <= defaultFeeDistribution, "Wrong fee distribution");
    //        feeDistribution[msg.sender] = newDistribution;
    //        _newDistribution = newDistribution;
    //    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;
import "../proxy/utils/Initializable.sol";

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuardUpgradeable is Initializable {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    function __ReentrancyGuard_init() internal onlyInitializing {
        __ReentrancyGuard_init_unchained();
    }

    function __ReentrancyGuard_init_unchained() internal onlyInitializing {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (proxy/utils/Initializable.sol)

pragma solidity ^0.8.2;

import "../../utils/AddressUpgradeable.sol";

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since proxied contracts do not make use of a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * The initialization functions use a version number. Once a version number is used, it is consumed and cannot be
 * reused. This mechanism prevents re-execution of each "step" but allows the creation of new initialization steps in
 * case an upgrade adds a module that needs to be initialized.
 *
 * For example:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * contract MyToken is ERC20Upgradeable {
 *     function initialize() initializer public {
 *         __ERC20_init("MyToken", "MTK");
 *     }
 * }
 * contract MyTokenV2 is MyToken, ERC20PermitUpgradeable {
 *     function initializeV2() reinitializer(2) public {
 *         __ERC20Permit_init("MyToken");
 *     }
 * }
 * ```
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {ERC1967Proxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 *
 * [CAUTION]
 * ====
 * Avoid leaving a contract uninitialized.
 *
 * An uninitialized contract can be taken over by an attacker. This applies to both a proxy and its implementation
 * contract, which may impact the proxy. To prevent the implementation contract from being used, you should invoke
 * the {_disableInitializers} function in the constructor to automatically lock it when it is deployed:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * /// @custom:oz-upgrades-unsafe-allow constructor
 * constructor() {
 *     _disableInitializers();
 * }
 * ```
 * ====
 */
abstract contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     * @custom:oz-retyped-from bool
     */
    uint8 private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Triggered when the contract has been initialized or reinitialized.
     */
    event Initialized(uint8 version);

    /**
     * @dev A modifier that defines a protected initializer function that can be invoked at most once. In its scope,
     * `onlyInitializing` functions can be used to initialize parent contracts. Equivalent to `reinitializer(1)`.
     */
    modifier initializer() {
        bool isTopLevelCall = !_initializing;
        require(
            (isTopLevelCall && _initialized < 1) || (!AddressUpgradeable.isContract(address(this)) && _initialized == 1),
            "Initializable: contract is already initialized"
        );
        _initialized = 1;
        if (isTopLevelCall) {
            _initializing = true;
        }
        _;
        if (isTopLevelCall) {
            _initializing = false;
            emit Initialized(1);
        }
    }

    /**
     * @dev A modifier that defines a protected reinitializer function that can be invoked at most once, and only if the
     * contract hasn't been initialized to a greater version before. In its scope, `onlyInitializing` functions can be
     * used to initialize parent contracts.
     *
     * `initializer` is equivalent to `reinitializer(1)`, so a reinitializer may be used after the original
     * initialization step. This is essential to configure modules that are added through upgrades and that require
     * initialization.
     *
     * Note that versions can jump in increments greater than 1; this implies that if multiple reinitializers coexist in
     * a contract, executing them in the right order is up to the developer or operator.
     */
    modifier reinitializer(uint8 version) {
        require(!_initializing && _initialized < version, "Initializable: contract is already initialized");
        _initialized = version;
        _initializing = true;
        _;
        _initializing = false;
        emit Initialized(version);
    }

    /**
     * @dev Modifier to protect an initialization function so that it can only be invoked by functions with the
     * {initializer} and {reinitializer} modifiers, directly or indirectly.
     */
    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    /**
     * @dev Locks the contract, preventing any future reinitialization. This cannot be part of an initializer call.
     * Calling this in the constructor of a contract will prevent that contract from being initialized or reinitialized
     * to any version. It is recommended to use this to lock implementation contracts that are designed to be called
     * through proxies.
     */
    function _disableInitializers() internal virtual {
        require(!_initializing, "Initializable: contract is initializing");
        if (_initialized < type(uint8).max) {
            _initialized = type(uint8).max;
            emit Initialized(type(uint8).max);
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/ContextUpgradeable.sol";
import "../proxy/utils/Initializable.sol";

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
abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    function __Ownable_init() internal onlyInitializing {
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal onlyInitializing {
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

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (utils/structs/EnumerableSet.sol)

pragma solidity ^0.8.0;

/**
 * @dev Library for managing
 * https://en.wikipedia.org/wiki/Set_(abstract_data_type)[sets] of primitive
 * types.
 *
 * Sets have the following properties:
 *
 * - Elements are added, removed, and checked for existence in constant time
 * (O(1)).
 * - Elements are enumerated in O(n). No guarantees are made on the ordering.
 *
 * ```
 * contract Example {
 *     // Add the library methods
 *     using EnumerableSet for EnumerableSet.AddressSet;
 *
 *     // Declare a set state variable
 *     EnumerableSet.AddressSet private mySet;
 * }
 * ```
 *
 * As of v3.3.0, sets of type `bytes32` (`Bytes32Set`), `address` (`AddressSet`)
 * and `uint256` (`UintSet`) are supported.
 *
 * [WARNING]
 * ====
 *  Trying to delete such a structure from storage will likely result in data corruption, rendering the structure unusable.
 *  See https://github.com/ethereum/solidity/pull/11843[ethereum/solidity#11843] for more info.
 *
 *  In order to clean an EnumerableSet, you can either remove all elements one by one or create a fresh instance using an array of EnumerableSet.
 * ====
 */
library EnumerableSetUpgradeable {
    // To implement this library for multiple types with as little code
    // repetition as possible, we write it in terms of a generic Set type with
    // bytes32 values.
    // The Set implementation uses private functions, and user-facing
    // implementations (such as AddressSet) are just wrappers around the
    // underlying Set.
    // This means that we can only create new EnumerableSets for types that fit
    // in bytes32.

    struct Set {
        // Storage of set values
        bytes32[] _values;
        // Position of the value in the `values` array, plus 1 because index 0
        // means a value is not in the set.
        mapping(bytes32 => uint256) _indexes;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function _add(Set storage set, bytes32 value) private returns (bool) {
        if (!_contains(set, value)) {
            set._values.push(value);
            // The value is stored at length-1, but we add 1 to all indexes
            // and use 0 as a sentinel value
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function _remove(Set storage set, bytes32 value) private returns (bool) {
        // We read and store the value's index to prevent multiple reads from the same storage slot
        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) {
            // Equivalent to contains(set, value)
            // To delete an element from the _values array in O(1), we swap the element to delete with the last one in
            // the array, and then remove the last element (sometimes called as 'swap and pop').
            // This modifies the order of the array, as noted in {at}.

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;

            if (lastIndex != toDeleteIndex) {
                bytes32 lastValue = set._values[lastIndex];

                // Move the last value to the index where the value to delete is
                set._values[toDeleteIndex] = lastValue;
                // Update the index for the moved value
                set._indexes[lastValue] = valueIndex; // Replace lastValue's index to valueIndex
            }

            // Delete the slot where the moved value was stored
            set._values.pop();

            // Delete the index for the deleted slot
            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function _contains(Set storage set, bytes32 value) private view returns (bool) {
        return set._indexes[value] != 0;
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function _length(Set storage set) private view returns (uint256) {
        return set._values.length;
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function _at(Set storage set, uint256 index) private view returns (bytes32) {
        return set._values[index];
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function _values(Set storage set) private view returns (bytes32[] memory) {
        return set._values;
    }

    // Bytes32Set

    struct Bytes32Set {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _add(set._inner, value);
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _remove(set._inner, value);
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(Bytes32Set storage set, bytes32 value) internal view returns (bool) {
        return _contains(set._inner, value);
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(Bytes32Set storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(Bytes32Set storage set, uint256 index) internal view returns (bytes32) {
        return _at(set._inner, index);
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(Bytes32Set storage set) internal view returns (bytes32[] memory) {
        return _values(set._inner);
    }

    // AddressSet

    struct AddressSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(AddressSet storage set, address value) internal returns (bool) {
        return _add(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(AddressSet storage set, address value) internal returns (bool) {
        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(AddressSet storage set, address value) internal view returns (bool) {
        return _contains(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(AddressSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(AddressSet storage set, uint256 index) internal view returns (address) {
        return address(uint160(uint256(_at(set._inner, index))));
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(AddressSet storage set) internal view returns (address[] memory) {
        bytes32[] memory store = _values(set._inner);
        address[] memory result;

        /// @solidity memory-safe-assembly
        assembly {
            result := store
        }

        return result;
    }

    // UintSet

    struct UintSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(UintSet storage set, uint256 value) internal returns (bool) {
        return _add(set._inner, bytes32(value));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(UintSet storage set, uint256 value) internal returns (bool) {
        return _remove(set._inner, bytes32(value));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(UintSet storage set, uint256 value) internal view returns (bool) {
        return _contains(set._inner, bytes32(value));
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function length(UintSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(UintSet storage set, uint256 index) internal view returns (uint256) {
        return uint256(_at(set._inner, index));
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(UintSet storage set) internal view returns (uint256[] memory) {
        bytes32[] memory store = _values(set._inner);
        uint256[] memory result;

        /// @solidity memory-safe-assembly
        assembly {
            result := store
        }

        return result;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20Upgradeable {
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

//SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

interface IBiswapNFT {
    struct Token {
        uint robiBoost;
        uint level;
        bool stakeFreeze;
        uint createTimestamp;
    }

    struct TokenView {
        uint tokenId;
        uint robiBoost;
        uint level;
        bool stakeFreeze;
        uint createTimestamp;
        string uri;
    }

    function getLevel(uint tokenId) external view returns (uint);

    function getRB(uint tokenId) external view returns (uint);

    function getInfoForStaking(uint tokenId)
        external
        view
        returns (
            address tokenOwner,
            bool stakeFreeze,
            uint robiBoost
        );

    function getToken(uint _tokenId)
        external
        view
        returns (
            uint tokenId,
            address tokenOwner,
            uint level,
            uint rb,
            bool stakeFreeze,
            uint createTimestamp,
            uint remainToNextLevel,
            string memory uri
        );

    function accrueRB(address user, uint amount) external;

    function tokenFreeze(uint tokenId) external;

    function tokenUnfreeze(uint tokenId) external;

    function balanceOf(address owner) external view returns (uint256);

    function getRbBalance(address user) external view returns (uint);

    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256);

    function burnForCollectibles(address user, uint[] calldata tokenId) external returns (uint); //todo add in contract returns RB amount
}

//SPDX-License-Identifier: MIT
pragma solidity >=0.5.0;

interface IBiswapFactory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);
    function INIT_CODE_HASH() external pure returns (bytes32);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
    function setDevFee(address pair, uint32 _devFee) external;
    function setSwapFee(address pair, uint32 _swapFee) external;
}

//SPDX-License-Identifier: MIT
pragma solidity >=0.5.0;

interface IBiswapPair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);
    function swapFee() external view returns (uint32);
    function devFee() external view returns (uint32);

    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
    function setSwapFee(uint32) external;
    function setDevFee(uint32) external;
}

//SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

interface IOracle {
    function consult(address tokenIn, uint amountIn, address tokenOut) external view returns (uint amountOut);
}

//SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

interface IBiswapCollectiblesNFT {
  struct Token{
    uint8 level;
    uint32 createTimestamp;
  }

  struct TokenView{
    uint tokenId;
    uint8 level;
    uint32 createTimestamp;
    address tokenOwner;
    string uri;
    bool isSelected;
  }

  function DEFAULT_ADMIN_ROLE (  ) external view returns ( bytes32 );
  function TOKEN_MINTER_ROLE (  ) external view returns ( bytes32 );
  function MAX_LEVEL() external view returns (uint);
  function approve ( address to, uint256 tokenId ) external;
  function balanceOf ( address owner ) external view returns ( uint256 );
  function burn ( uint256 _tokenId ) external;
  function getApproved ( uint256 tokenId ) external view returns ( address );
  function getRoleAdmin ( bytes32 role ) external view returns ( bytes32 );
  function getToken ( uint256 tokenId ) external view returns ( TokenView calldata);
  function getUserTokens ( address user ) external view returns ( TokenView[] calldata);
  function getUserSelectedToken(address user) external view returns (TokenView memory token);
  function getUserSelectedTokenId(address user) external view returns (uint tokenId, uint8 level);
  function grantRole ( bytes32 role, address account ) external;
  function hasRole ( bytes32 role, address account ) external view returns ( bool );
  function initialize ( string calldata baseURI, string calldata name_, string calldata symbol_ ) external;
  function isApprovedForAll ( address owner, address operator ) external view returns ( bool );
  function mint ( address to, uint8 level ) external;
  function name (  ) external view returns ( string calldata);
  function ownerOf ( uint256 tokenId ) external view returns ( address );
  function renounceRole ( bytes32 role, address account ) external;
  function revokeRole ( bytes32 role, address account ) external;
  function safeTransferFrom ( address from, address to, uint256 tokenId ) external;
  function safeTransferFrom ( address from, address to, uint256 tokenId, bytes calldata data ) external;
  function setApprovalForAll ( address operator, bool approved ) external;
  function setBaseURI ( string calldata newBaseUri ) external;
  function supportsInterface ( bytes4 interfaceId ) external view returns ( bool );
  function symbol (  ) external view returns ( string calldata );
  function tokenByIndex ( uint256 index ) external view returns ( uint256 );
  function tokenOfOwnerByIndex ( address owner, uint256 index ) external view returns ( uint256 );
  function tokenURI ( uint256 tokenId ) external view returns ( string calldata );
  function totalSupply (  ) external view returns ( uint256 );
  function transferFrom ( address from, address to, uint256 tokenId ) external;
  function getTokenLevelsByUser(address user) external view returns(uint[] memory levels);

  event Initialize(string baseURI, string name, string symbol);
  event TokenMint(address indexed to, uint tokenId, Token token, string uri);
  event TokenSelected(uint tokenId, address indexed owner);
  event TokenReselected(uint oldTokenId, uint newTokenId, address indexed owner);
  event HookError(address receiver);


}

//SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

interface ISwapFeeRewardWithRBOld {

    struct PairsList {
        address pair;
        uint256 percentReward;
        bool enabled;
    }

    function getQuantity(
        address outputToken,
        uint256 outputAmount,
        address anchorToken
    ) external view returns (uint256);

    function pairFor(address tokenA, address tokenB) external view returns (address pair);
    function defaultFeeDistribution() external view returns(uint);
    function rbWagerOnSwap() external view returns(uint);
    function targetToken() external view returns(address);
    function pairOfPid(address) external view returns(uint);
    function isWhitelist(address _token) external view returns (bool);
    function pairsList(uint) external view returns(PairsList memory);
    function feeDistribution(address) external view returns(uint);
    function rewardBalance(address account) external view returns (uint);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (utils/Address.sol)

pragma solidity ^0.8.1;

/**
 * @dev Collection of functions related to the address type
 */
library AddressUpgradeable {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly
                /// @solidity memory-safe-assembly
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;
import "../proxy/utils/Initializable.sol";

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
abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal onlyInitializing {
    }

    function __Context_init_unchained() internal onlyInitializing {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}