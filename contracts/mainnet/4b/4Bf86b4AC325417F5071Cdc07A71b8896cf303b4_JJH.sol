// SPDX-License-Identifier: MIT
pragma solidity ^0.7.0;

import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/math/SafeMathUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/SafeERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/EnumerableSetUpgradeable.sol";

interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}
interface IUniswapV2Pair {
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

    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}
import "../interfaces/IUniswapV2Router02.sol";
import "../interfaces/IVault.sol";
import "../interfaces/IWhitelistHelper.sol";
import "../interfaces/IERC20Extra.sol";

library Math {
    function min(uint x, uint y) internal pure returns (uint z) {
        z = x < y ? x : y;
    }

    // babylonian method (https://en.wikipedia.org/wiki/Methods_of_computing_square_roots#Babylonian_method)
    function sqrt(uint y) internal pure returns (uint z) {
        if (y > 3) {
            z = y;
            uint x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }
}

contract JJH is IERC20Upgradeable, OwnableUpgradeable {
    using SafeMathUpgradeable for uint256;
    using SafeERC20Upgradeable for IERC20Upgradeable;
    using EnumerableSetUpgradeable for EnumerableSetUpgradeable.AddressSet;

    uint256 private constant MINIMUM_LIQUIDITY = 10**3;
    uint256 private constant DENOMINATOR = 10000;
    uint256 private constant CLAIM_INTERVAL = 144000; // 144000; // 5 days
    uint256 private constant SWAP_FEE = 200;
    uint256 private constant MINING_RATE = 8000;
    uint256 private constant RECOMMENDATION_RATE = 2000;
    uint256 private constant CLAIM_AMOUNT = 20e18;
    uint256 private constant CLAIM_COUNT = 10;
    uint256 private constant NEXT_CLAIM_LIMIT = 15;
    uint256 private constant BLOCK_OF_DAY = 28800;
    address private constant BURN_ADDR = 0x000000000000000000000000000000000000dEaD;

    string private constant _name = "JJH";
    string private constant _symbol = "JJH";
    uint8 private constant _decimals = 18;

    uint256 public mintRate;

    uint256 public pendingTransfer;

    uint256 public effectiveLimit;
    uint256 public claimLimit;
    
    mapping(address => uint256) public claimCount;
    mapping(address => uint256) public lpShreshold;
    mapping(address => uint256) public nextClaimBlock;

    // prevent robot
    uint256 gasPriceLimit;
    mapping(address => uint256) public blockNumberLimit;

    address public ecologyFoundation;
    address public tradeRewardWallet;
    address public ecologyWallet;

    address public router;
    address public pair;
    address public token;
    address public bToken;
    address public cToken;
    address public vault;
    address public whitelistHelper;

    address public gov;

    // normal account
    bool public layer1UnLock;
    // whiltelist account
    bool public layer2UnLock;

    uint256 public restrictedBlock;

    uint256 public dailyInterestRate;

    mapping(address => uint256) public purchaseAmount;

    EnumerableSetUpgradeable.AddressSet private blacklist;
    EnumerableSetUpgradeable.AddressSet private excludedReward;
    EnumerableSetUpgradeable.AddressSet private lpHolder;

    uint256 public exploreRecord;
    uint256 public exploreNumber;

    uint256[] public rewardLimit;
    mapping(uint256 => uint256) public deductRate;
    mapping(address => uint256) public dynamicReward;

    uint256 public remainingLpReward;
    uint256 public startBlock;
    mapping(address => uint256) public lastBlock;
    mapping(address => uint256) public stakeAmount;

    mapping(address => address) public recommender;
    mapping(address => uint256) public recommendCount;
    mapping(address => mapping(address => uint256)) public recordAmount;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    address public manager;

    constructor() initializer {}

    function initialize(address _router, address _token, uint256 _startBlock) public initializer {
        __Ownable_init();

        gov = msg.sender;

        mintRate = 3750;
        effectiveLimit = 195e18;
        claimLimit = 200e18;
        gasPriceLimit = 10 gwei;
        rewardLimit = new uint256[](3);
        rewardLimit[0] = 1000e18;
        rewardLimit[1] = 1200e18;
        rewardLimit[2] = 2000e18;
        deductRate[rewardLimit[0]] = 2000;
        deductRate[rewardLimit[1]] = 5000;
        deductRate[rewardLimit[2]] = 8000;

        remainingLpReward = 9000000e18;

        exploreNumber = 15;
        dailyInterestRate = 400;
        startBlock = _startBlock;

        router = _router;
        pair = IUniswapV2Factory(IUniswapV2Router02(_router).factory()).createPair(_token, address(this));
        token = _token;

        _mint(address(this), remainingLpReward);
        _mint(msg.sender, 1000000e18);
    }

    function name() public view virtual returns (string memory) {
        return _name;
    }

    function symbol() public view virtual returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function blacklistLength() external view returns(uint256) {
        return blacklist.length();
    }

    function getBlacklist(uint256 index) external view returns(address) {
        return blacklist.at(index);
    }

    function addBlacklist(address account) external {
        require(msg.sender == manager);
        blacklist.add(account);
    }

    function removeBlacklist(address account) external {
        require(msg.sender == manager);
        blacklist.remove(account);
    }

    function setManager(address account) external {
        require(gov == msg.sender);
        manager = account;
    }

    function setGov(address _gov) external onlyOwner {
        gov = _gov;
    }

    function excludedLength() external view returns(uint256) {
        return excludedReward.length();
    }

    function isExcludedReward(address account) external view returns(bool) {
        return excludedReward.contains(account);
    }

    function getExcludedReward(uint256 index) external view returns(address) {
        return excludedReward.at(index);
    }

    function joinExcludedReward(address account) external {
        require(gov == msg.sender);
        excludedReward.add(account);
    }

    function exitExcludedReward(address account) external {
        require(gov == msg.sender);
        excludedReward.remove(account);
    }

    function setupRewardLimit(uint[3] memory _rewardLimit, uint[3] memory _deductRate) external onlyOwner {
        require(_rewardLimit.length == _deductRate.length, "not same length");
        for(uint8 i = 0; i < rewardLimit.length; i++) {
            delete deductRate[rewardLimit[i]];
        }

        rewardLimit = _rewardLimit;
        for(uint i = 0; i < _deductRate.length; i++) {
            deductRate[_rewardLimit[i]] = _deductRate[i];
        }
    }

    function setupLimit(uint256 _gasPriceLimit, uint256 _effectiveLimit, uint256 _claimLimit) external onlyOwner {
        gasPriceLimit = _gasPriceLimit;
        effectiveLimit = _effectiveLimit;
        claimLimit = _claimLimit;
    }

    function setupEcologyWallet(address _ecologyFoundation, address _tradeRewardWallet, address _ecologyWallet) external onlyOwner {
        ecologyFoundation = _ecologyFoundation;
        tradeRewardWallet = _tradeRewardWallet;
        ecologyWallet = _ecologyWallet;
    }

    function setupContract(address _bToken, address _cToken, address _vault, address _whitelistHelper) external onlyOwner {
        bToken = _bToken;
        cToken = _cToken;
        vault = _vault;
        whitelistHelper = _whitelistHelper;
    }

    function setMintRate(uint256 _mintRate) external onlyOwner {
        mintRate = _mintRate;
    }

    function unLock(uint256 layer, bool status) external onlyOwner {
        if(layer == 1) {
            layer1UnLock = status;
            if(status) {
                restrictedBlock = block.number;
            }
        } else if(layer == 2) {
            layer2UnLock = status;
        } else {
            revert("Not supported other layer");
        }
        
    }

    function setDailyInterestRate(uint256 _dailyInterestRate) external onlyOwner {
        dailyInterestRate = _dailyInterestRate;
    }

    function _swap(uint256 amount) internal {
        _approve(address(this), router, amount);
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = token;
        IUniswapV2Router02(router).swapExactTokensForTokensSupportingFeeOnTransferTokens(
            amount,
            0,
            path,
            vault,
            block.timestamp
        );
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function price() public view returns(uint256) {
        (uint reserve0, uint reserve1, ) = IUniswapV2Pair(pair).getReserves();
        address token0 = IUniswapV2Pair(pair).token0();

        (uint reserveA, uint reserveB) = token0 == address(this) ? (reserve1, reserve0) : (reserve0, reserve1);
        return reserveA.mul(1e18) / reserveB;
    }

    function updatePrice() external {
        _distribute(pendingTransfer);
    }

    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        if(sender == address(this)) {
            _directTransfer(sender, recipient, amount);
            return;
        }

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 fee;

        // (buy & remove liquidity) || (sell & add liquidity)
        if(sender == pair || recipient == pair) {

            fee = amount.mul(SWAP_FEE).div(DENOMINATOR);

            if(sender == owner() || recipient == owner() || recipient == BURN_ADDR) {
                fee = 0;
            } else {
                if(sender == pair) {
                    address[] memory path = new address[](2);
                    path[0] = address(this);
                    path[1] = token;
                    uint256 amountOut = IUniswapV2Router02(router).getAmountsOut(fee, path)[1];
                    uint256 bPrice = IERC20Extra(bToken).price();
                    uint256 mintAmount = amountOut.mul(1e18).mul(mintRate).div(bPrice).div(DENOMINATOR);
                    IERC20Extra(bToken).mint(recipient, mintAmount);
                }
            }

            pendingTransfer = pendingTransfer.add(fee);

            if(fee > 0) {
                _balances[address(this)] = _balances[address(this)].add(fee); 
                emit Transfer(sender, address(this), fee);
            }

        } else {
            _distribute(pendingTransfer);
        }
        IERC20Extra(cToken).updatePrice();

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount.sub(fee));
       
        emit Transfer(sender, recipient, amount);
    }

    function _distribute(uint256 amount) internal {
        if(amount > 0) {
            _swap(amount);
            pendingTransfer = 0;
            IVault(vault).withdraw(token, address(this));
            uint256 balance = IERC20Upgradeable(token).balanceOf(address(this));
            uint256 ecologyAmount = balance.div(4);
            IERC20Upgradeable(token).safeTransfer(ecologyFoundation, ecologyAmount);
            IERC20Upgradeable(token).safeTransfer(tradeRewardWallet, ecologyAmount);
            IERC20Upgradeable(token).safeTransfer(bToken, IERC20Upgradeable(token).balanceOf(address(this)));
        }
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual {
        if(from == address(0) || to == address(0)) {
          return;
        }

        if(blacklist.contains(from) || blacklist.contains(to)) {
            revert("account in blacklist");
        }

        address account = from != pair ? from : to;

        // addLiquidity, removeLiquidity, buy, sell operations to limit gas price
        (bool result, uint256 lpAmount, uint256 tokenAmount) = _isAddLiquidity(to, amount.sub(amount.mul(SWAP_FEE).div(DENOMINATOR)));

        if(from == pair || to == pair) {
            if(account != owner()) {
                // non-whitelist account to determine layer 1 unlock
                if(!IWhitelistHelper(whitelistHelper).whitelistVerify(account)) {
                    require(layer1UnLock, "layer 1 lock");
                }
                require(layer2UnLock, "layer 2 lock");
            }

            if(tx.gasprice > gasPriceLimit) {
                blacklist.add(account);
            }

            // prevent to buy and sell on the same block number
            // require(block.number > blockNumberLimit[account], "prohibit to buy and sell on the same block number");
            blockNumberLimit[account] = block.number;

            if(from == pair) {

                if(restrictedBlock == block.number || restrictedBlock + 1 == block.number) {
                    blacklist.add(to);
                }

                // layer 1 not unlock,  only can buy 100u amount
                if(!layer1UnLock) {
                    (uint reserve0, uint reserve1, ) = IUniswapV2Pair(pair).getReserves();
                    uint tokenReserve = IUniswapV2Pair(pair).token0() == token ? reserve0 : reserve1;
                    uint balance = IERC20Upgradeable(token).balanceOf(pair);
                    if(balance > tokenReserve) {
                        uint purchased = balance.sub(tokenReserve);
                        require(purchased <= uint256(100e18).sub(purchaseAmount[to]), "exceeds purchase amount");
                        purchaseAmount[to] = purchaseAmount[to].add(purchased);
                    }
                }
            } else {
                // if(!result && amount > balanceOf(from).mul(95).div(100)) {
                //     revert("prohibit sell exceeds 95% of total asset");
                // }
                // prevent to sell before at layer1 unlock
                if(!layer1UnLock) {
                    require(result, "prohibit to sell before at layer 1 unlock");
                }
            }
        } else {
            // bind recommender
            if(recommender[from] == address(0) && recommender[to] != from && recordAmount[to][from] > 0) {
                recommender[from] = to;
                recommendCount[to]++;
            }
            if(recordAmount[from][to] == 0) {
                recordAmount[from][to] = amount;
            }
        }

        if(block.number < startBlock) {
            lastBlock[account] = startBlock;
        } else if(block.number > startBlock && lastBlock[account] == 0) {
            lastBlock[account] = block.number;
        }
        
        _distributeReward(account);

        // whitelist claim token
        if(nextClaimBlock[account] != 0 && block.number > nextClaimBlock[account]) {
            nextClaimBlock[account] = 0;
            claimCount[account]++;
            _directTransfer(address(this), account, CLAIM_AMOUNT);
        }
        // remove liqudiity & transfer after, update next claim block.
        if(IERC20Upgradeable(pair).balanceOf(account) < lpShreshold[account] && nextClaimBlock[account] != 0) {
            nextClaimBlock[account] = 0;
        }

        if(result) {

            if(claimCount[account] < CLAIM_COUNT && IWhitelistHelper(whitelistHelper).whitelistVerify(account)) {
                uint256 lpPerValue = tokenAmount.mul(1e18).mul(2).div(lpAmount);
                uint256 totalLpAmount = IERC20Upgradeable(pair).balanceOf(account).add(lpAmount);
                // next claim token
                if(nextClaimBlock[account] == 0) {
                    // account wants to claim token for first time
                    if(claimCount[account] == 0 && lpPerValue.mul(totalLpAmount).div(1e18) >= claimLimit) {
                        lpShreshold[account] = claimLimit.mul(1e18).div(lpPerValue);
                        nextClaimBlock[account] = CLAIM_INTERVAL.add(block.number);
                    } else {
                        uint limit = price().mul(NEXT_CLAIM_LIMIT);
                        limit = claimLimit.add(claimCount[account].mul(limit));
                        if(lpPerValue.mul(totalLpAmount).div(1e18) >= limit) {
                            lpShreshold[account] = limit.mul(1e18).div(lpPerValue);
                            nextClaimBlock[account] = CLAIM_INTERVAL.add(block.number);
                        }
                    }
                }
            }

        }

    }

    function _calculateAForLp(uint256 lpAmount) internal view returns(uint256) {
        uint256 lpSupply = IUniswapV2Pair(pair).totalSupply();
        address token0 = IUniswapV2Pair(pair).token0();
        address token1 = IUniswapV2Pair(pair).token1();

        uint balance = token0 == address(this) ? IERC20Upgradeable(token0).balanceOf(pair) : IERC20Upgradeable(token1).balanceOf(pair);
        return balance.mul(lpAmount).div(lpSupply);
    }

    function _distributeReward(address account) internal {
        exploreEffectiveAccount();

        uint256 diff;
        if(lastBlock[account] < block.number) {
            diff = block.number.sub(lastBlock[account]);
            lastBlock[account] = block.number;
        }

        lpHolder.add(account);
        uint256 lpAmount = IUniswapV2Pair(pair).balanceOf(account);
        // prevent transfer lp token to affective distribute reward
        if(lpAmount < stakeAmount[account]) {
            stakeAmount[account] = lpAmount;
        }
        if(stakeAmount[account] > 0 && !excludedReward.contains(account) && diff > 0) {
            uint256 balance = _calculateAForLp(stakeAmount[account]);
            uint256 pending = balance.mul(diff).mul(dailyInterestRate).div(BLOCK_OF_DAY).div(DENOMINATOR);
            if(pending > remainingLpReward) {
                pending = remainingLpReward;
            }
            if(pending == 0) {
                return;
            }
            remainingLpReward = remainingLpReward.sub(pending);
            uint256 reward = pending.mul(MINING_RATE).div(DENOMINATOR);
            uint256 recommendReward = pending.sub(reward).div(5);
            _directTransfer(address(this), account, reward);
            address recommenderAddr = recommender[account];
            bool result;
            for(uint8 i = 0; i < 5; i++) {
                result = _effectiveAccount(recommenderAddr);
                if(result && recommendCount[recommenderAddr] > i) {
                    uint256 temp = recommendReward;
                    for(uint8 j = 3; j > 0; j--) {
                        if(dynamicReward[recommenderAddr] >= rewardLimit[j - 1]) {
                            uint burnAmount = recommendReward.mul(deductRate[rewardLimit[j - 1]]).div(DENOMINATOR);
                            temp = temp.sub(burnAmount);
                            _directTransfer(address(this), BURN_ADDR, burnAmount);
                            break;
                        }
                    }
                    _directTransfer(address(this), recommenderAddr, temp);
                    dynamicReward[recommenderAddr] = dynamicReward[recommenderAddr].add(temp);
                } else {
                    _directTransfer(address(this), ecologyWallet, recommendReward);
                }
                recommenderAddr = recommender[recommenderAddr];
            }
        }
        // remove liqudiity after, update stake amount at first time
        stakeAmount[account] = lpAmount;
    }

    function setExploreNumber(uint256 _number) external onlyOwner {
        exploreNumber = _number;
    }

    function exploreEffectiveAccount() public {
        address account;
        uint256 lpAmount;

        for(uint8 i = 0; i < exploreNumber && exploreRecord < lpHolder.length(); i++) {
            account = lpHolder.at(exploreRecord);
            lpAmount = IUniswapV2Pair(pair).balanceOf(account);
            
            if(lpAmount < stakeAmount[account]) {
                stakeAmount[account] = lpAmount;
            }

            if(lpAmount == 0) {
                lpHolder.remove(account);
            } else {
                exploreRecord++;
            }
        }

        if(exploreRecord >= lpHolder.length()) {
            exploreRecord = 0;
        }
    }

    // test
    // function addLpHolder(address[] memory addrs) external {
    //     for(uint i = 0; i < addrs.length; i++) {
    //         lpHolder.add(addrs[i]);
    //         stakeAmount[addrs[i]] = 100;
    //     }
    // }

    function lpHolderAt(uint index) external view returns(address) {
        return lpHolder.at(index);
    }

    function lpHolderLength() external view returns(uint256) {
        return lpHolder.length();
    }

    function _directTransfer(address from, address to, uint256 amount) internal {
        _balances[from] = _balances[from].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[to] = _balances[to].add(amount);
        if(amount > 0) {
            emit Transfer(from, to, amount);
        }
    }

    function _effectiveAccount(address account) internal view returns(bool) {
        if(account == address(0)) {
            return false;
        }
        uint256 balance = IERC20Upgradeable(pair).balanceOf(account);
 
        uint tokenBalance = IERC20Upgradeable(token).balanceOf(pair);
        uint256 lpSupply = IUniswapV2Pair(pair).totalSupply();
        uint256 amount = balance.mul(tokenBalance).div(lpSupply);
        if(amount.mul(2) >= effectiveLimit) {
            return true;
        }
        return false;
    }

    function _isAddLiquidity(address to, uint256 amount) internal view returns(bool result, uint256 liquidity, uint256 tokenAmount) {
        if(to == pair) {
            (uint reserve0, uint reserve1, ) = IUniswapV2Pair(pair).getReserves();
            address token0 = IUniswapV2Pair(pair).token0();
            uint tokenReserve = token0 == token ? reserve0 : reserve1;
            uint256 reserve = token0 == address(this) ? reserve0 : reserve1;
            tokenAmount = IERC20Upgradeable(token).balanceOf(pair);
            if(tokenAmount > tokenReserve) {
                tokenAmount = tokenAmount.sub(tokenReserve);
                uint256 lpSupply = IUniswapV2Pair(pair).totalSupply();
                if(lpSupply == 0) {
                    liquidity = Math.sqrt(tokenAmount.mul(amount)) - MINIMUM_LIQUIDITY;
                } else {
                    liquidity = Math.min(tokenAmount * lpSupply / tokenReserve, amount * lpSupply / reserve);
                }
                result = true;
            }
        }
    }

    uint256[44] private __gap;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.7.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20Upgradeable {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

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
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

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
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.7.0;

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
library SafeMathUpgradeable {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b > a) return (false, 0);
        return (true, a - b);
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a / b);
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a % b);
    }

    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        return a - b;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: modulo by zero");
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        return a - b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryDiv}.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a % b;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.7.0;

import "./IERC20Upgradeable.sol";
import "../../math/SafeMathUpgradeable.sol";
import "../../utils/AddressUpgradeable.sol";

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20Upgradeable {
    using SafeMathUpgradeable for uint256;
    using AddressUpgradeable for address;

    function safeTransfer(IERC20Upgradeable token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20Upgradeable token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(IERC20Upgradeable token, address spender, uint256 value) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        // solhint-disable-next-line max-line-length
        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20Upgradeable token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20Upgradeable token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20Upgradeable token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.7.0;

import "../utils/ContextUpgradeable.sol";
import "../proxy/Initializable.sol";
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
    function __Ownable_init() internal initializer {
        __Context_init_unchained();
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal initializer {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.7.0;

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
        mapping (bytes32 => uint256) _indexes;
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

        if (valueIndex != 0) { // Equivalent to contains(set, value)
            // To delete an element from the _values array in O(1), we swap the element to delete with the last one in
            // the array, and then remove the last element (sometimes called as 'swap and pop').
            // This modifies the order of the array, as noted in {at}.

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;

            // When the value to delete is the last one, the swap operation is unnecessary. However, since this occurs
            // so rarely, we still do the swap anyway to avoid the gas cost of adding an 'if' statement.

            bytes32 lastvalue = set._values[lastIndex];

            // Move the last value to the index where the value to delete is
            set._values[toDeleteIndex] = lastvalue;
            // Update the index for the moved value
            set._indexes[lastvalue] = toDeleteIndex + 1; // All indexes are 1-based

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
        require(set._values.length > index, "EnumerableSet: index out of bounds");
        return set._values[index];
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
}

// SPDX-License-Identifier: MIT
pragma solidity >= 0.6.0 <0.8.0;

import './IUniswapV2Router01.sol';

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

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

// SPDX-License-Identifier: MIT
pragma solidity ^0.7.0;

interface IVault {
    function withdraw(address token, address recipient) external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.7.0;

interface IWhitelistHelper {
  function whitelistVerify(address account) external view returns(bool);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.7.0;

interface IERC20Extra {
  function mint(address account, uint256 amount) external;
  function burn(address account, uint256 amount) external;
  function price() external view returns(uint256);
  function pendingTransfer() external view returns(uint256);
  function updatePrice() external;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.7.0;

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
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        // solhint-disable-next-line no-inline-assembly
        assembly { size := extcodesize(account) }
        return size > 0;
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

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain`call` is an unsafe replacement for a function call: use this
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
    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
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
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
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
    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                // solhint-disable-next-line no-inline-assembly
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

pragma solidity >=0.6.0 <0.8.0;
import "../proxy/Initializable.sol";

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal initializer {
        __Context_init_unchained();
    }

    function __Context_init_unchained() internal initializer {
    }
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT

// solhint-disable-next-line compiler-version
pragma solidity >=0.4.24 <0.8.0;

import "../utils/AddressUpgradeable.sol";

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since a proxied contract can't have a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {UpgradeableProxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 */
abstract contract Initializable {

    /**
     * @dev Indicates that the contract has been initialized.
     */
    bool private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Modifier to protect an initializer function from being invoked twice.
     */
    modifier initializer() {
        require(_initializing || _isConstructor() || !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }

    /// @dev Returns true if and only if the function is running in the constructor
    function _isConstructor() private view returns (bool) {
        return !AddressUpgradeable.isContract(address(this));
    }
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <0.8.0;

interface IUniswapV2Router01 {
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
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}