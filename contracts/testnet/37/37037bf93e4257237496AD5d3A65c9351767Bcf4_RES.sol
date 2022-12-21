/**
 *Submitted for verification at BscScan.com on 2022-12-02
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

/// @notice Modern and gas efficient ERC20 + EIP-2612 implementation.
/// @author Solmate (https://github.com/transmissions11/solmate/blob/main/src/tokens/ERC20.sol)
/// @author Modified from Uniswap (https://github.com/Uniswap/uniswap-v2-core/blob/master/contracts/UniswapV2ERC20.sol)
/// @dev Do not manually set balances without updating totalSupply, as the sum of all user balances must not exceed it.
abstract contract ERC20 {
    /*//////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/

    event Transfer(address indexed from, address indexed to, uint256 amount);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 amount
    );

    uint256 public constant TOTAL_SUPPLY = 100_000_000_000_000_000 * 1e18;

    /*//////////////////////////////////////////////////////////////
                            METADATA STORAGE
    //////////////////////////////////////////////////////////////*/

    string public name;

    string public symbol;

    uint8 public immutable decimals;

    /*//////////////////////////////////////////////////////////////
                              ERC20 STORAGE
    //////////////////////////////////////////////////////////////*/

    uint256 public totalSupply;

    mapping(address => uint256) internal _balanceOf;

    mapping(address => mapping(address => uint256)) public allowance;

    /*//////////////////////////////////////////////////////////////
                            EIP-2612 STORAGE
    //////////////////////////////////////////////////////////////*/

    uint256 internal immutable INITIAL_CHAIN_ID;

    bytes32 internal immutable INITIAL_DOMAIN_SEPARATOR;

    mapping(address => uint256) public nonces;

    /*//////////////////////////////////////////////////////////////
                               CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    constructor(
        string memory _name,
        string memory _symbol,
        uint8 _decimals
    ) {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;

        INITIAL_CHAIN_ID = block.chainid;
        INITIAL_DOMAIN_SEPARATOR = computeDomainSeparator();
    }

    function _beforeTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual returns (uint256 fee);

    function _addBalance(address acct, uint256 amount) private {
        uint256 amountIn = (amount * TOTAL_SUPPLY) / totalSupply;
        unchecked {
            // handle this precision problem
            uint256 amountOut = (amountIn * totalSupply) / TOTAL_SUPPLY;
            if (amountOut < amount) {
                amountIn += 1;
            }
        }

        _balanceOf[acct] += amountIn;
    }

    function _subBalance(address acct, uint256 amount) private {
        amount = (amount * TOTAL_SUPPLY) / totalSupply;
        _balanceOf[acct] -= amount;
    }

    /*//////////////////////////////////////////////////////////////
                               ERC20 LOGIC
    //////////////////////////////////////////////////////////////*/

    function balanceOf(address acct) public view returns (uint256) {
        return ((_balanceOf[acct] * totalSupply) / TOTAL_SUPPLY);
    }

    function approve(address spender, uint256 amount)
        public
        virtual
        returns (bool)
    {
        allowance[msg.sender][spender] = amount;

        emit Approval(msg.sender, spender, amount);

        return true;
    }

    function transfer(address to, uint256 amount)
        public
        virtual
        returns (bool)
    {
        uint256 fee = _beforeTransfer(msg.sender, to, amount);
        uint256 actual = amount - fee;
        _subBalance(msg.sender, amount);
        _addBalance(to, actual);
        if (fee > 0) {
            _addBalance(address(this), fee);
            emit Transfer(msg.sender, address(this), fee);
        }
        emit Transfer(msg.sender, to, actual);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual returns (bool) {
        uint256 allowed = allowance[from][msg.sender]; // Saves gas for limited approvals.

        if (allowed != type(uint256).max)
            allowance[from][msg.sender] = allowed - amount;

        uint256 fee = _beforeTransfer(from, to, amount);
        uint256 actual = amount - fee;
        _subBalance(from, amount);
        _addBalance(to, actual);
        if (fee > 0) {
            _addBalance(address(this), fee);
            emit Transfer(from, address(this), fee);
        }
        emit Transfer(from, to, actual);
        return true;
    }

    /*//////////////////////////////////////////////////////////////
                             EIP-2612 LOGIC
    //////////////////////////////////////////////////////////////*/

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public virtual {
        require(deadline >= block.timestamp, "PERMIT_DEADLINE_EXPIRED");

        // Unchecked because the only math done is incrementing
        // the owner's nonce which cannot realistically overflow.
        unchecked {
            address recoveredAddress = ecrecover(
                keccak256(
                    abi.encodePacked(
                        "\x19\x01",
                        DOMAIN_SEPARATOR(),
                        keccak256(
                            abi.encode(
                                keccak256(
                                    "Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)"
                                ),
                                owner,
                                spender,
                                value,
                                nonces[owner]++,
                                deadline
                            )
                        )
                    )
                ),
                v,
                r,
                s
            );

            require(
                recoveredAddress != address(0) && recoveredAddress == owner,
                "INVALID_SIGNER"
            );

            allowance[recoveredAddress][spender] = value;
        }

        emit Approval(owner, spender, value);
    }

    function DOMAIN_SEPARATOR() public view virtual returns (bytes32) {
        return
            block.chainid == INITIAL_CHAIN_ID
                ? INITIAL_DOMAIN_SEPARATOR
                : computeDomainSeparator();
    }

    function computeDomainSeparator() internal view virtual returns (bytes32) {
        return
            keccak256(
                abi.encode(
                    keccak256(
                        "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
                    ),
                    keccak256(bytes(name)),
                    keccak256("1"),
                    block.chainid,
                    address(this)
                )
            );
    }

    /*//////////////////////////////////////////////////////////////
                        INTERNAL MINT/BURN LOGIC
    //////////////////////////////////////////////////////////////*/

    function _mint(address to, uint256 amount) internal virtual {
        totalSupply += amount;

        // Cannot overflow because the sum of all user
        // balances can't exceed the max uint256 value.
        unchecked {
            _balanceOf[to] += amount;
        }

        emit Transfer(address(0), to, amount);
    }

    function _burn(uint256 amount) internal virtual {
        // Cannot underflow because a user's balance
        // will never be larger than the total supply.
        unchecked {
            totalSupply -= amount;
        }

        emit Transfer(address(0), address(0), amount);
    }
}

interface IERC20 {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);
}

contract Wallet {
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    function withdraw(address token) external {
        assert(msg.sender == owner);
        IERC20(token).transfer(
            msg.sender,
            IERC20(token).balanceOf(address(this))
        );
    }
}

/// @notice Simple single owner authorization mixin.
/// @author Solmate (https://github.com/transmissions11/solmate/blob/main/src/auth/Owned.sol)
abstract contract Owned {
    /*//////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/

    event OwnerUpdated(address indexed user, address indexed newOwner);

    /*//////////////////////////////////////////////////////////////
                            OWNERSHIP STORAGE
    //////////////////////////////////////////////////////////////*/

    address public owner;

    modifier onlyOwner() virtual {
        require(msg.sender == owner, "UNAUTHORIZED");

        _;
    }

    /*//////////////////////////////////////////////////////////////
                               CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    constructor(address _owner) {
        owner = _owner;

        emit OwnerUpdated(address(0), _owner);
    }

    /*//////////////////////////////////////////////////////////////
                             OWNERSHIP LOGIC
    //////////////////////////////////////////////////////////////*/

    function setOwner(address newOwner) public virtual onlyOwner {
        owner = newOwner;

        emit OwnerUpdated(msg.sender, newOwner);
    }
}

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

/**
 * @title Rebase Token
 */
contract RES is ERC20, Owned {
    event RebaseWorkerChanged(address worker);
    event RebaseDone(uint256 delta, bool excludePair);
    event AllocationReservers(
        uint256 swapIn,
        uint256 swapOut,
        uint256 toLP,
        uint256 toMkt
    );
    event ConfigChanged(Config newConfig);

    address private constant _DEAD = 0x000000000000000000000000000000000000dEaD;
    uint256 private constant _ONE_TOKENS = 1e18;
    uint256 private constant _TAX_FACTOR = 756; // 7.56%
    uint256 private constant _MIN_SUPPLY = 10000 * _ONE_TOKENS;

    IERC20 public constant BASE_TOKEN =
        IERC20(0x337610d27c682E347C9cD60BD4b3b107C9d34dDd);
    // uniswap router
    IUniswapV2Router02 public constant SWAP_ROUTER =
        IUniswapV2Router02(0xD99D1c33F9fC3444f8101754aBC46c52416550D1);

    // work for swap token to usdt.
    Wallet private _wallet;

    // current token-basetoken pair in swap
    address public immutable pairToken;

    // receive 1/3 transfer fee
    address public marketing;
    // receive 1/3 transfer fee for burn RES
    address public master;
    // worker can call `rebase` function.
    address public worker;

    // The holder of the list, no transcation fees.
    mapping(address => bool) public noFees;
    // Allow transfer before running.
    mapping(address => bool) public whitelists;

    bool public isRunning;

    uint256 public lastHandleTime;

    // work config
    Config public config;

    struct Config {
        uint32 handleInterval;
        // if the fee balance exceeds totalsuppl/sellDivisor,
        // swap token to basetoken
        uint112 sellRequire;
    }

    constructor(address marketing_,address master_,uint32 handleInterval_,uint112 sellRequire_)
        ERC20("Reversal", "RES", 18)
        Owned(msg.sender)
    {
        require(marketing_ != address(0), "marketing is zero");
        require(master_ != address(0), "master is zero");

        _wallet = new Wallet();

        //deploy swap token pair
        IUniswapV2Factory factory = IUniswapV2Factory(SWAP_ROUTER.factory());

        pairToken = factory.createPair(address(this), address(BASE_TOKEN));
        marketing = marketing_;
        master=master_;

        noFees[msg.sender] = true;
        noFees[address(this)] = true;
        // no fee when add or remove liquidity
        noFees[address(SWAP_ROUTER)] = true;

        whitelists[msg.sender]=true;

        config=Config({
            handleInterval:handleInterval_,
            sellRequire:sellRequire_
        });

        lastHandleTime = block.timestamp;
        // mint
        _mint(msg.sender, TOTAL_SUPPLY);

        // approve once.
        approveForSwap();
    }

    /**
     * @dev approve once to save gas.
     * this function can be called by everyone.
     */
    function approveForSwap() public {
        allowance[address(this)][address(SWAP_ROUTER)] = type(uint256).max;
        BASE_TOKEN.approve(address(SWAP_ROUTER), type(uint256).max);
    }

    function rebase(uint256 delta, bool excludePair) external {
        // check
        require(msg.sender == worker, "only call by worker");
        uint256 oldSupply = totalSupply;
        require(oldSupply > _MIN_SUPPLY, "stabled");

        if (oldSupply - delta < _MIN_SUPPLY) {
            delta = oldSupply - _MIN_SUPPLY;
        }

        _burn(delta);

        if (excludePair) {
            // keep the pair balance to remain the same after rebaseing
            uint256 b = _balanceOf[pairToken];
            // append = _balance[pair] * ( oldSupply / newSupply -1 )
            _balanceOf[pairToken] = (b * oldSupply) / totalSupply;
        }
        emit RebaseDone(delta, excludePair);
        IUniswapV2Pair(pairToken).sync();
    }

    /**
     * @dev add lp + buyback
     */
    function handleReserves() external {
        Config memory cfg = config;
        // admin or time is up.
        require(
            msg.sender == owner ||
                uint256(cfg.handleInterval) + lastHandleTime < block.timestamp,
            "sleeping"
        );
        // allocation check
        uint256 minSell = (uint256(cfg.sellRequire) * _ONE_TOKENS);
        uint256 reserves = balanceOf(address(this));
        require(reserves >= minSell,"notenough");
        _allocationFees(minSell);
    }

    function _beforeTransfer(
        address from,
        address to,
        uint256 amount
    ) internal view override returns (uint256 reserves) {
        if(!isRunning){
            require(whitelists[from],"is not running");
        }

        require(to != address(0), "refuse");
        // Payment of swap transaction fees only.
        if (!noFees[from] && !noFees[to]) {
            reserves = (amount * _TAX_FACTOR) / 10_000;
        }
    }

    /**
     * @notice  distribution reservers
     * @dev swap token to basetoken and allocation basetoken.
     *
     * allocation rules:
     *
     *  1. 1/3: add liquidity RES-USD
     *  2. 1/3: transfer to marketing address.
     *  3. 1/3: transfer to master address to buy token and burn RES.
     */
    function _allocationFees(uint256 amount) private {
        // split the contract balance into quarters
        uint256 threequarters = (amount * 3) / 4;
        uint256 onequarter = amount - threequarters;

        // swap tokens for base token
        uint256 out = _swapToken(threequarters);
        if (out == 0) {
            return;
        }
        uint256 shared = out / 3;

        uint256 beforeBalance = BASE_TOKEN.balanceOf(address(this));
        SWAP_ROUTER.addLiquidity(
            address(this),
            address(BASE_TOKEN),
            onequarter,
            shared,
            0,
            0,
            address(this),
            type(uint256).max
        );
        uint256 lpUsedBaseToken = beforeBalance -
            BASE_TOKEN.balanceOf(address(this));
        // Transfer to marketing address
        BASE_TOKEN.transfer(marketing, shared);
        BASE_TOKEN.transfer(master, shared);

        emit AllocationReservers(threequarters, out, lpUsedBaseToken, shared);
    }

    /**
     * @dev swap token to BASE_TOKEN and returns the swap amount;
     */
    function _swapToken(uint256 amountIn) private returns (uint256) {
        // swap token -> base token
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = address(BASE_TOKEN);
        address to = address(this);
        uint256 before = IERC20(path[1]).balanceOf(to);

        // swap to the wallet and then withdraw from the wallet here.
        SWAP_ROUTER.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            amountIn,
            0, // accept any amount of base token.
            path,
            address(_wallet),
            block.timestamp
        );

        _wallet.withdraw(path[1]);

        // swap out = now - before
        return IERC20(path[1]).balanceOf(to) - before;
    }

    // -------------------------------------------------
    //  Administrator Action
    // -------------------------------------------------
    function setNoFee(address[] calldata accts, bool noFee) external onlyOwner {
        for (uint256 i = 0; i < accts.length; i++) {
            noFees[accts[i]] = noFee;
        }
    }
    function setWhitelists(address[] calldata accts, bool added) external onlyOwner {
        require(!isRunning,"not need");
        for (uint256 i = 0; i < accts.length; i++) {
            whitelists[accts[i]] = added;
        }
    }
    function startRun() external onlyOwner{
        require(!isRunning,"is running");
        isRunning=true;
    }

    function setConfig(Config calldata cfg) external onlyOwner {
        require(cfg.sellRequire > 0, "invalid");
        require(cfg.handleInterval >= 30 minutes, "invalid");
        config = cfg;
        emit ConfigChanged(cfg);
    }

    function setWorker(address worker_) external onlyOwner {
        worker = worker_; // allow empty
    }

    function setMarketing(address marketing_) external onlyOwner {
        require(marketing_ != address(0), "marketing is zero");
        marketing = marketing_;
    }
    function setMaster(address master_) external onlyOwner{
        require(master_ != address(0), "master is zero");
        master = master_;
    }
}