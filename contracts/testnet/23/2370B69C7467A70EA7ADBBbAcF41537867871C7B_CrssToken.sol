// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

import "./interfaces/ICrssToken.sol";
import "../periphery/interfaces/ICrossRouter.sol";
import "../core/interfaces/ICrossFactory.sol";
import "../core/interfaces/ICrossPair.sol";

// CrssToken with Governance.
contract CrssToken is ICrssToken, OwnableUpgradeable {
    using SafeMath for uint256;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private __totalSupply;
    mapping(address => uint256) private __balances;

    address public override router;
    address public override farm;
    address public override crssBnbPair;

    uint8 constant DECIMALS = 18;
    uint256 public constant override maxSupply = 50 * 1e6 * 10**DECIMALS;
    uint256 public constant override magnifier = 1e4;

    uint256 public override devFeeRate;
    uint256 public override liquidityFeeRate;
    uint256 public override buybackFeeRate;

    uint256 public override maxTransferAmountRate;
    uint256 public maxSwapTransferAmountRate;

    address public override devTo;
    address public override buybackTo;
    address public constant override berryAddress = address(0);

    mapping(address => bool) public knownDexContract;
    mapping(address => bool) public knownPairContract;

    bool private shouldPayFee;

    DexSession private dexSession;

    // Data for Swap and Liquify Functionality

    bool private shouldSwapAndLiquify;
    uint256 private liquifyThreshold;
    uint256 private liquifyAccumulated;

    // Data for Implement Transaction-Oriented Overview

    struct TxHistory {
        address account;
        uint256 sent;
        uint256 received;
    }

    TxHistory[] public transfersInOneTx;

    struct SwapHistory {
        address txOrigin;
        uint256 sent;
        uint256 received;
    }
    mapping(address => SwapHistory) public swapTransfersInOneTx;

    address private txOrigin;

    // Data for Delegates

    mapping(address => address) internal __delegates;

    /// @notice A checkpoint for marking number of votes from a given block
    struct Checkpoint {
        uint32 fromBlock;
        uint256 votes;
    }

    /// @notice A record of votes checkpoints for each account, by index
    mapping(address => mapping(uint32 => Checkpoint)) public checkpoints;

    /// @notice The number of checkpoints for each account
    mapping(address => uint32) public numCheckpoints;

    /// @notice The EIP-712 typehash for the contract's domain
    bytes32 public constant DOMAIN_TYPEHASH =
        keccak256(
            "EIP712Domain(string name,uint256 chainId,address verifyingContract)"
        );

    /// @notice The EIP-712 typehash for the delegation struct used by the contract
    bytes32 public constant DELEGATION_TYPEHASH =
        keccak256("Delegation(address delegatee,uint256 nonce,uint256 expiry)");

    mapping(address => uint256) public nonces;

    /// @notice An event thats emitted when an account changes its delegate
    event DelegateChanged(
        address indexed delegator,
        address indexed fromDelegate,
        address indexed toDelegate
    );

    /// @notice An event thats emitted when a delegate account's vote balance changes
    event DelegateVotesChanged(
        address indexed delegate,
        uint256 previousBalance,
        uint256 newBalance
    );

    function initialize(address _router) external initializer {
        require(
            _msgSender() == ICrossRouter(_router).getOwner(),
            "Cross: FORBIDDEN"
        );
        __Ownable_init();
        _name = "Crosswise Token";
        _symbol = "CRSS";
        _decimals = 18;
        router = _router;

        devFeeRate = 4; // 0.04%
        liquidityFeeRate = 3; // 0.03%
        buybackFeeRate = 3; // 0.03%

        maxTransferAmountRate = 50;
        maxSwapTransferAmountRate = 50;
        shouldPayFee = true;

        knownDexContract[address(0)] = true;
        knownDexContract[address(this)] = true;
        knownDexContract[_router] = true;
        dexSession = DexSession.None;

        // Mint 1e6 Crss to the caller for testing
        // __mint(_msgSender(), 1e6 * 10 ** DECIMALS);
        // __moveDelegates(address(0), __delegates[_msgSender()], 1e6 * 10 ** DECIMALS);
    }

    function getOwner() external view override returns (address) {
        return owner();
    }

    function setRouter(address _router) external override onlyOwner {
        require(
            _msgSender() == ICrossRouter(_router).getOwner(),
            "Cross: FORBIDDEN"
        );
        router = _router;
        crssBnbPair = ICrossFactory(ICrossRouter(router).factory()).createPair(
            address(this),
            ICrossRouter(router).WETH()
        );
        knownDexContract[crssBnbPair] = true;
        knownPairContract[crssBnbPair] = true;
    }

    function setFarm(address crssFarm) external override {
        farm = crssFarm;
    }

    function setDexSession(DexSession session) public override {
        require(
            _msgSender() == router || _msgSender() == address(this),
            "Cross: FORBIDDEN"
        );
        if (dexSession == DexSession.None) {
            dexSession = session;
            shouldPayFee = true;
        } else if (session == DexSession.None) {
            dexSession = session;
            if (shouldSwapAndLiquify) {
                swapAndLiquify();
            }
        }
    }

    function getFeePer1e10()
        external
        view
        override
        returns (uint256 feeInner, uint256 feeOuter)
    {
        uint256 totalFeeRate = devFeeRate + buybackFeeRate + liquidityFeeRate;
        feeInner = totalFeeRate.mul(1e10).div(magnifier);
        feeOuter = totalFeeRate.mul(1e10).div(
            10000 - (devFeeRate + buybackFeeRate + liquidityFeeRate)
        );
    }

    function setPairContract(address account) external override {
        require(_msgSender() == router, "Cross: FORBIDDEN");
        knownDexContract[account] = true;
        knownPairContract[account] = true;
    }

    function setKnownDexContract(address account, bool status)
        external
        override
        onlyOwner
    {
        knownDexContract[account] = status;
    }

    function name() public view virtual returns (string memory) {
        return _name;
    }

    function symbol() public view virtual returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual returns (uint8) {
        return DECIMALS;
    }

    function totalSupply() public view virtual override returns (uint256) {
        return __totalSupply;
    }

    function balanceOf(address account)
        public
        view
        virtual
        override
        returns (uint256)
    {
        return __balances[account];
    }

    function mint(address _to, uint256 _amount) public override onlyOwner {
        _mint(_to, _amount);
    }

    function burn(address _from, uint256 _amount) public override onlyOwner {
        _burn(_from, _amount);
    }

    function berry(address _from, uint256 _amount) public onlyOwner {
        __transfer(_from, berryAddress, _amount);
        __moveDelegates(__delegates[_from], __delegates[berryAddress], _amount);
    }

    function transfer(address recipient, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(
            currentAllowance >= amount,
            "ERC20: transfer amount exceeds allowance"
        );
        _approve(sender, _msgSender(), currentAllowance - amount);

        _transfer(sender, recipient, amount); // No guarentee it doesn't make a change to _allowances. Revert if it fails.

        return true;
    }

    function allowance(address owner, address spender)
        public
        view
        virtual
        override
        returns (uint256)
    {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue)
        public
        virtual
        returns (bool)
    {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender] + addedValue
        );
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        virtual
        returns (bool)
    {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(
            currentAllowance >= subtractedValue,
            "ERC20: decreased allowance below zero"
        );
        _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        return true;
    }

    function _mint(address to, uint256 amount) internal virtual {
        require(
            __totalSupply + amount <= maxSupply,
            "ERC20: Exceed Max Supply"
        );
        __mint(to, amount);
        __moveDelegates(address(0), __delegates[to], amount);
    }

    function _burn(address account, uint256 amount) internal virtual {
        __burn(account, amount);
        __moveDelegates(__delegates[account], __delegates[address(0)], amount);
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        setDexSession(DexSession.Transfer);
        _checkTxWideTransferAmount(sender, recipient, amount);
        _checkTxWideSwapTransferAmount(sender, recipient, amount);

        if (
            shouldPayFee &&
            !(knownDexContract[sender] && knownDexContract[recipient])
        ) {
            amount -= _payFees(sender, amount);
            shouldPayFee = false;
        }

        __transfer(sender, recipient, amount);
        __moveDelegates(__delegates[sender], __delegates[recipient], amount);

        if (dexSession == DexSession.Transfer) {
            setDexSession(DexSession.None);
        }
        return;
    }

    function _checkTxWideTransferAmount(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        // Check the transaction-wide, accumulated transfer amount, rather than call-wide transfer amount.
        uint256 _maxTransferAmount = __totalSupply
            .mul(maxTransferAmountRate)
            .div(magnifier);
        if (sender == owner() || recipient == owner()) {} else if (
            tx.origin == txOrigin
        ) {
            for (uint256 i = 0; i < transfersInOneTx.length; i++) {
                if (transfersInOneTx[i].account == sender) {
                    transfersInOneTx[i].sent += amount;
                    require(
                        transfersInOneTx[i].sent < _maxTransferAmount,
                        "CrssToken: Exceed MaxTransferAmount"
                    );
                } else if (transfersInOneTx[i].account == recipient) {
                    transfersInOneTx[i].received += amount;
                    require(
                        transfersInOneTx[i].received < _maxTransferAmount,
                        "CrssToken: Exceed MaxTransferAmount"
                    );
                } else {
                    transfersInOneTx.push(TxHistory(sender, amount, 0));
                    transfersInOneTx.push(TxHistory(recipient, 0, amount));
                    require(
                        amount < _maxTransferAmount,
                        "CrssToken: Exceed MaxTransferAmount"
                    );
                }
            }
        } else {
            txOrigin = tx.origin;
            for (uint256 i = 0; i < transfersInOneTx.length; i++) {
                delete transfersInOneTx[i];
            }
            transfersInOneTx.push(TxHistory(sender, amount, 0));
            transfersInOneTx.push(TxHistory(recipient, 0, amount));
            require(
                amount < _maxTransferAmount,
                "CrssToken: Exceed MaxTransferAmount"
            );
        }
    }

    function _checkTxWideSwapTransferAmount(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        if (dexSession != DexSession.Swap) {
            return;
        }
        if (knownPairContract[sender]) {
            uint256 crssReserve = ICrossPair(sender).getCrssReserve(
                address(this)
            );
            uint256 _maxTransferAmount = crssReserve
                .mul(maxSwapTransferAmountRate)
                .div(magnifier);
            if (tx.origin != swapTransfersInOneTx[sender].txOrigin) {
                swapTransfersInOneTx[sender].txOrigin = tx.origin;
                swapTransfersInOneTx[sender].sent = 0;
                swapTransfersInOneTx[sender].received = 0;
            }
            swapTransfersInOneTx[sender].sent += amount;
            require(
                swapTransfersInOneTx[sender].sent < _maxTransferAmount,
                "Cross: Exceed Swap Amount"
            );
        }
        if (knownPairContract[recipient]) {
            uint256 crssReserve = ICrossPair(recipient).getCrssReserve(
                address(this)
            );
            uint256 _maxTransferAmount = crssReserve
                .mul(maxSwapTransferAmountRate)
                .div(magnifier);
            if (tx.origin != swapTransfersInOneTx[recipient].txOrigin) {
                swapTransfersInOneTx[recipient].txOrigin = tx.origin;
                swapTransfersInOneTx[recipient].sent = 0;
                swapTransfersInOneTx[recipient].received = 0;
            }
            swapTransfersInOneTx[recipient].received += amount;
            require(
                swapTransfersInOneTx[recipient].received < _maxTransferAmount,
                "Cross: Exceed Swap Amount"
            );
        }
    }

    function _payFees(address sender, uint256 amount)
        internal
        virtual
        returns (uint256 fees)
    {
        uint256 devFee = amount.mul(devFeeRate).div(10000);
        uint256 buybackFee = amount.mul(buybackFeeRate).div(10000);
        uint256 liquidityFee = amount.mul(liquidityFeeRate).div(10000);

        __transfer(sender, devTo, devFee);
        __moveDelegates(__delegates[sender], __delegates[devTo], devFee);

        __transfer(sender, buybackTo, buybackFee);
        __moveDelegates(
            __delegates[sender],
            __delegates[buybackTo],
            buybackFee
        );

        __transfer(sender, address(this), liquidityFee);
        __moveDelegates(
            __delegates[sender],
            __delegates[address(this)],
            liquidityFee
        );

        liquifyAccumulated += liquidityFee;
        if (liquifyAccumulated > liquifyThreshold) {
            shouldSwapAndLiquify = true;
        }
        fees = devFee + buybackFee + liquidityFee;
    }

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

    function __mint(address account, uint256 amount) internal virtual {
        require(_msgSender() == farm, "Cross: FORBIDDEN");
        require(account != address(0), "ERC20: mint to the zero address");

        __beforeTokenTransfer(address(0), account, amount);
        __totalSupply += amount;
        __balances[account] += amount;
        __afterTokenTransfer(address(0), account, amount);

        emit Transfer(address(0), account, amount);
    }

    function __burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");
        uint256 accountBalance = __balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");

        __beforeTokenTransfer(account, address(0), amount);
        __balances[account] = accountBalance - amount;
        __totalSupply -= amount;
        __afterTokenTransfer(account, address(0), amount);

        emit Transfer(account, address(0), amount);
    }

    function __transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        uint256 senderBalance = __balances[sender];
        require(
            senderBalance >= amount,
            "ERC20: transfer amount exceeds balance"
        );

        __beforeTokenTransfer(sender, recipient, amount);
        __balances[sender] = senderBalance - amount;
        __balances[recipient] += amount;
        __afterTokenTransfer(sender, recipient, amount);

        emit Transfer(sender, recipient, amount);
    }

    function __beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    function __afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    function swapAndLiquify() private {
        uint256 contractTokenBalance = balanceOf(address(this));
        // split the contract balance into halves
        uint256 _maxTransferAmount = maxTransferAmount();
        contractTokenBalance = contractTokenBalance > _maxTransferAmount
            ? _maxTransferAmount
            : contractTokenBalance;

        uint256 half = contractTokenBalance.div(2);
        uint256 otherHalf = contractTokenBalance.sub(half);

        // capture the contract's current ETH balance.
        // this is so that we can capture exactly the amount of ETH that the
        // swap creates, and not make the liquidity event include any ETH that
        // has been manually sent to the contract
        uint256 initialBalance = address(this).balance;

        // swap tokens for ETH
        swapTokensForBNB(half); // <- this breaks the ETH -> HATE swap when swap+liquify is triggered

        // how much ETH did we just swap into?
        uint256 newBalance = address(this).balance.sub(initialBalance);

        // add liquidity to uniswap
        addLiquidity(otherHalf, newBalance);
    }

    function swapTokensForBNB(uint256 tokenAmount) private {
        // generate the uniswap pair path of token -> WBNB
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = ICrossRouter(router).WETH();

        _approve(address(this), address(router), tokenAmount);

        // make the swap
        ICrossRouter(router).swapExactTokensForETHSupportingFeeOnTransferTokens(
                tokenAmount,
                0, // accept any amount of ETH
                path,
                address(this),
                block.timestamp
            );
    }

    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
        // approve token transfer to cover all possible scenarios
        _approve(address(this), address(router), tokenAmount);

        // add the liquidity
        (, , uint256 liquidity) = ICrossRouter(router).addLiquidityETH{
            value: ethAmount
        }(
            address(this),
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            address(this),
            block.timestamp
        );

        // AUDIT : CTC-01 | Return value not handled
        require(liquidity > 0, "Add liquidity failed");
    }

    function maxTransferAmount() public view returns (uint256) {
        return __totalSupply.mul(maxTransferAmountRate).div(magnifier);
    }

    function __delegate(address delegator, address delegatee) internal {
        address currentDelegate = __delegates[delegator];
        uint256 delegatorBalance = balanceOf(delegator); // balance of underlying CRSSs (not scaled);
        __delegates[delegator] = delegatee;

        emit DelegateChanged(delegator, currentDelegate, delegatee);

        __moveDelegates(currentDelegate, delegatee, delegatorBalance);
    }

    function delegates(address delegator) external view returns (address) {
        return __delegates[delegator];
    }

    function delegate(address delegatee) external {
        return __delegate(_msgSender(), delegatee);
    }

    function delegateBySig(
        address delegatee,
        uint256 nonce,
        uint256 expiry,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external {
        bytes32 domainSeparator = keccak256(
            abi.encode(
                DOMAIN_TYPEHASH,
                keccak256(bytes(name())),
                getChainId(),
                address(this)
            )
        );

        bytes32 structHash = keccak256(
            abi.encode(DELEGATION_TYPEHASH, delegatee, nonce, expiry)
        );

        bytes32 digest = keccak256(
            abi.encodePacked("\x19\x01", domainSeparator, structHash)
        );

        address signatory = ecrecover(digest, v, r, s);
        require(
            signatory != address(0),
            "CRSS::delegateBySig: invalid signature"
        );
        require(
            nonce == nonces[signatory]++,
            "CRSS::delegateBySig: invalid nonce"
        );
        require(
            block.timestamp <= expiry,
            "CRSS::delegateBySig: signature expired"
        );
        return __delegate(signatory, delegatee);
    }

    function getCurrentVotes(address account) external view returns (uint256) {
        uint32 nCheckpoints = numCheckpoints[account];
        return
            nCheckpoints > 0 ? checkpoints[account][nCheckpoints - 1].votes : 0;
    }

    function getPriorVotes(address account, uint256 blockNumber)
        external
        view
        returns (uint256)
    {
        require(
            blockNumber < block.number,
            "CRSS::getPriorVotes: not yet determined"
        );

        uint32 nCheckpoints = numCheckpoints[account];
        if (nCheckpoints == 0) {
            return 0;
        }

        // First check most recent balance
        if (checkpoints[account][nCheckpoints - 1].fromBlock <= blockNumber) {
            return checkpoints[account][nCheckpoints - 1].votes;
        }

        // Next check implicit zero balance
        if (checkpoints[account][0].fromBlock > blockNumber) {
            return 0;
        }

        uint32 lower = 0;
        uint32 upper = nCheckpoints - 1;
        while (upper > lower) {
            uint32 center = upper - (upper - lower) / 2; // ceil, avoiding overflow
            Checkpoint memory cp = checkpoints[account][center];
            if (cp.fromBlock == blockNumber) {
                return cp.votes;
            } else if (cp.fromBlock < blockNumber) {
                lower = center;
            } else {
                upper = center - 1;
            }
        }
        return checkpoints[account][lower].votes;
    }

    function safe32(uint256 n, string memory errorMessage)
        internal
        pure
        returns (uint32)
    {
        require(n < 2**32, errorMessage);
        return uint32(n);
    }

    function getChainId() internal view returns (uint256) {
        uint256 chainId;
        assembly {
            chainId := chainid()
        }
        return chainId;
    }

    function __moveDelegates(
        address srcRep,
        address dstRep,
        uint256 amount
    ) internal {
        if (srcRep != dstRep && amount > 0) {
            if (srcRep != address(0)) {
                // decrease old representative
                uint32 srcRepNum = numCheckpoints[srcRep];
                uint256 srcRepOld = srcRepNum > 0
                    ? checkpoints[srcRep][srcRepNum - 1].votes
                    : 0;
                uint256 srcRepNew = srcRepOld.sub(amount);
                __writeCheckpoint(srcRep, srcRepNum, srcRepOld, srcRepNew);
            }

            if (dstRep != address(0)) {
                // increase new representative
                uint32 dstRepNum = numCheckpoints[dstRep];
                uint256 dstRepOld = dstRepNum > 0
                    ? checkpoints[dstRep][dstRepNum - 1].votes
                    : 0;
                uint256 dstRepNew = dstRepOld.add(amount);
                __writeCheckpoint(dstRep, dstRepNum, dstRepOld, dstRepNew);
            }
        }
    }

    function __writeCheckpoint(
        address delegatee,
        uint32 nCheckpoints,
        uint256 oldVotes,
        uint256 newVotes
    ) internal {
        uint32 blockNumber = safe32(
            block.number,
            "CRSS::__writeCheckpoint: block number exceeds 32 bits"
        );

        if (
            nCheckpoints > 0 &&
            checkpoints[delegatee][nCheckpoints - 1].fromBlock == blockNumber
        ) {
            checkpoints[delegatee][nCheckpoints - 1].votes = newVotes;
        } else {
            checkpoints[delegatee][nCheckpoints] = Checkpoint(
                blockNumber,
                newVotes
            );
            numCheckpoints[delegatee] = nCheckpoints + 1;
        }

        emit DelegateVotesChanged(delegatee, oldVotes, newVotes);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/math/SafeMath.sol)

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is generally not needed starting with Solidity 0.8, since the compiler
 * now has built in overflow checking.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
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
        return a + b;
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
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
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
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
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
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
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
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

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
        __Context_init_unchained();
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal onlyInitializing {
        _transferOwnership(_msgSender());
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
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (proxy/utils/Initializable.sol)

pragma solidity ^0.8.0;

import "../../utils/AddressUpgradeable.sol";

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since a proxied contract can't have a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
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
 * contract, which may impact the proxy. To initialize the implementation contract, you can either invoke the
 * initializer manually, or you can include a constructor to automatically mark it as initialized when it is deployed:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * /// @custom:oz-upgrades-unsafe-allow constructor
 * constructor() initializer {}
 * ```
 * ====
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
        // If the contract is initializing we ignore whether _initialized is set in order to support multiple
        // inheritance patterns, but we only do this in the context of a constructor, because in other contexts the
        // contract may have been reentered.
        require(_initializing ? _isConstructor() : !_initialized, "Initializable: contract is already initialized");

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

    /**
     * @dev Modifier to protect an initialization function so that it can only be invoked by functions with the
     * {initializer} modifier, directly or indirectly.
     */
    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    function _isConstructor() private view returns (bool) {
        return !AddressUpgradeable.isContract(address(this));
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";

interface ICrssToken is IERC20Upgradeable {
    enum DexSession { None, Swap, AddLiquidity, RemoveLiquidity, Transfer } 
    
    function getOwner() external view returns (address);
    
    function router() external view returns (address);
    
    function farm() external view returns (address);
  
    function crssBnbPair() external view returns (address);

    function maxSupply() external view returns (uint256);

    function magnifier() external view returns (uint256);

    function buybackFeeRate() external view returns (uint256);

    function devFeeRate() external view returns (uint256);

    function liquidityFeeRate() external view returns (uint256);

    function maxTransferAmountRate() external view returns (uint256);

    function devTo() external view returns (address);

    function buybackTo() external view returns (address);

    function berryAddress() external view returns (address);

    function setRouter(address _router) external;

    function setFarm(address crssFarm) external;

    function mint(address _to, uint256 _amount) external;

    function burn(address _from, uint256 _amount) external;

    function setDexSession( DexSession session ) external;

    function setKnownDexContract(address account, bool status) external;

    function setPairContract(address account) external;

    function getFeePer1e10() external view returns (uint256 feeRateInner, uint256 feeRateOuter);

}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./IPancakeRouter02.sol";

interface ICrossRouter is IPancakeRouter02 {
    function setCrssContract(address _crssContract) external;

    function getOwner() external view returns (address);

    function addLiquiditySupportingFeeOnTransferTokens(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB, uint256 liquidity);
    
    function addLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external payable returns (uint256 amountToken, uint256 amountETH, uint256 liquidity);

    function removeLiquiditySupportingFeeOnTransferTokens(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./IPancakeFactory.sol";

interface ICrossFactory is IPancakeFactory {
    function setRouter(address _router) external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./IPancakePair.sol";

interface ICrossPair is IPancakePair {
    function setRouter(address _router) external;

    function getCrssReserve(address crss) external view returns(uint256 reserve);
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
        __Context_init_unchained();
    }

    function __Context_init_unchained() internal onlyInitializing {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Address.sol)

pragma solidity ^0.8.0;

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
        assembly {
            size := extcodesize(account)
        }
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
// OpenZeppelin Contracts v4.4.1 (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

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
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

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
pragma solidity ^0.8.0;

import "./IPancakeRouter01.sol";

interface IPancakeRouter02 is IPancakeRouter01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountETH);

    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IPancakeRouter01 {
    function factory() external view returns (address);

    function WETH() external view returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
        external
        returns (
            uint256 amountA,
            uint256 amountB,
            uint256 liquidity
        );

    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
        external
        payable
        returns (
            uint256 amountToken,
            uint256 amountETH,
            uint256 liquidity
        );

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETH(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountToken, uint256 amountETH);

    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETHWithPermit(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountToken, uint256 amountETH);

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactETHForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function swapTokensForExactETH(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapETHForExactTokens(
        uint256 amountOut,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

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

    function getAmountsOut(uint256 amountIn, address[] calldata path) external view returns (uint256[] memory amounts);

    function getAmountsIn(uint256 amountOut, address[] calldata path) external view returns (uint256[] memory amounts);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IPancakeFactory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint256);

    function feeTo() external view returns (address);

    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);

    function allPairs(uint256) external view returns (address pair);

    function allPairsLength() external view returns (uint256);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;

    function setFeeToSetter(address) external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IPancakePair {
    // event Approval(address indexed owner, address indexed spender, uint256 value);
    // event Transfer(address indexed from, address indexed to, uint256 value);

    function name() external pure returns (string memory);

    function symbol() external pure returns (string memory);

    function decimals() external pure returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 value) external returns (bool);

    function transfer(address to, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);

    function PERMIT_TYPEHASH() external pure returns (bytes32);

    function nonces(address owner) external view returns (uint256);

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    event Mint(address indexed sender, uint256 amount0, uint256 amount1);
    event Burn(address indexed sender, uint256 amount0, uint256 amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint256 amount0In,
        uint256 amount1In,
        uint256 amount0Out,
        uint256 amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);

    function MINIMUM_LIQUIDITY() external pure returns (uint256);

    function factory() external view returns (address);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves()
        external
        view
        returns (
            uint112 reserve0,
            uint112 reserve1,
            uint32 blockTimestampLast
        );

    function price0CumulativeLast() external view returns (uint256);

    function price1CumulativeLast() external view returns (uint256);

    function kLast() external view returns (uint256);

    function mint(address to) external returns (uint256 liquidity);

    function burn(address to) external returns (uint256 amount0, uint256 amount1);

    function swap(
        uint256 amount0Out,
        uint256 amount1Out,
        address to,
        bytes calldata data
    ) external;

    function skim(address to) external;

    function sync() external;

    function initialize(address, address) external;
}