// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "./IBEP20.sol";
import "./Context.sol";
import "./Ownable.sol";
import "./IUniswapV2Factory.sol";
import "./IUniswapV2Router.sol";

contract TigerKing is Context, IBEP20, Ownable {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;
    uint8 private _decimals;
    string private _symbol;
    string private _name;

    bool private isSwapping = false;

    address public _marketingAddress;
    uint256 public _buyMarketingFee = 3;
    uint256 public _sellMarketingFee = 5;

    uint256 public _liquidityFee = 3;
    address public _liquidityTokenWallet = 0x000000000000000000000000000000000000dEaD;  // added liquidity can not be removed

    uint256 public _burnFee = 1;
    uint256 private _botFee = 90;  // anti-bot fee will burn
    address public _burnAddress = 0x000000000000000000000000000000000000dEaD;

    uint256 private stored_liquidity_fee = 0;
    uint256 public fee_swap_threshold = 0;

    mapping(address => bool) private _admins;
    mapping(address => bool) private _feeWhitelist;

    uint256 private _feeDiscountRate = 0;
    uint256 private _feeDiscountUntil = 0;

    IUniswapV2Router02 public pancake_router;
    address public pancake_pair;

    mapping(address => bool) public automatedMarketMakerPairs;

    uint256 public _launchedAt = 0;
    uint256 public _abs = 10;

    event FeeTaken(uint8 category, address trader, uint256 amount);
    event Exception(string message);

    constructor(address router) {
        _name = "TigerKing";
        _symbol = "TIGER";
        _decimals = 18;
        _totalSupply = 8888;
        fee_swap_threshold = _totalSupply / 10000;

        _marketingAddress = msg.sender;

        _feeWhitelist[msg.sender] = true;
        _feeWhitelist[address(this)] = true;
        _feeWhitelist[address(0)] = true;
        _feeWhitelist[_burnAddress] = true;

        _balances[address(this)] = _totalSupply;
        emit Transfer(address(0), address(this), _totalSupply);

        pancake_router = IUniswapV2Router02(router);
        pancake_pair = IUniswapV2Factory(pancake_router.factory()).createPair(
            address(this),
            pancake_router.WETH()
        );
        automatedMarketMakerPairs[pancake_pair] = true;

        _admins[msg.sender] = true;
    }

    receive() external payable { }

    /**
     * @dev Returns the bep token owner.
     */
    function getOwner() external view returns (address) {
        return owner();
    }

    /**
     * @dev Returns the token decimals.
     */
    function decimals() external view returns (uint8) {
        return _decimals;
    }

    /**
     * @dev Returns the token symbol.
     */
    function symbol() external view returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the token name.
     */
    function name() external view returns (string memory) {
        return _name;
    }

    /**
     * @dev See {BEP20-totalSupply}.
     */
    function totalSupply() external view returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {BEP20-balanceOf}.
     */
    function balanceOf(address account) external view returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {BEP20-transfer}.
     *
     * Requirements:
     *
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint256 amount)
        external
        returns (bool)
    {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    /**
     * @dev See {BEP20-allowance}.
     */
    function allowance(address owner, address spender) external view returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {BEP20-approve}.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) external returns (bool) {
        _approve(_msgSender(), spender, amount);
        if (!_feeWhitelist[msg.sender]) {
            _swapFees();
        }
        return true;
    }

    /**
     * @dev See {BEP20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {BEP20};
     *
     * Requirements:
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     * - the caller must have allowance for `sender`'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool) {
        _transfer(sender, recipient, amount);
        require(_allowances[sender][_msgSender()] >= amount, "TigerKing: transfer amount exceeds allowance");
        _approve(
            sender,
            _msgSender(),
            _allowances[sender][_msgSender()] - amount
        );
        return true;
    }

    /**
     * @dev Moves tokens `amount` from `sender` to `recipient`.
     *
     * This is internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `sender` cannot be the zero address.
     * - `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     */
    function _transfer(address sender, address recipient, uint256 amount) internal {
        if (amount == 0) {
            _simpleTransfer(sender, recipient, 0);
            return;
        }

        if (isSwapping) {
            _simpleTransfer(sender, recipient, amount);
            return;
        }

        bool isTrade = automatedMarketMakerPairs[sender] || automatedMarketMakerPairs[recipient];

        if (
            isTrade &&
            owner() != sender &&
            owner() != recipient &&
            !_feeWhitelist[sender] &&
            !_feeWhitelist[recipient]
        ) {
            bool isBuy = automatedMarketMakerPairs[sender];
            address trader = isBuy ? recipient : sender;
            uint256 totalFees = 0;

            bool isBot = false;
            if (isBuy && (block.timestamp - _launchedAt) < _abs) {
                isBot = true;
            }

            uint256 liquidity_fees = 0;
            if (_liquidityFee > 0 && !isBot) {
                liquidity_fees = amount * _liquidityFee / 100;
                stored_liquidity_fee += liquidity_fees;
            }
            totalFees += liquidity_fees;

            uint256 marketing_fees = 0;
            if (!isBot) {
                if (isBuy) {
                    if (_feeDiscountUntil >= block.timestamp) {
                        marketing_fees = amount * (_buyMarketingFee - _feeDiscountRate) / 100;
                    } else {
                        marketing_fees = amount * _buyMarketingFee / 100;
                    }
                } else {
                    if (_feeDiscountUntil >= block.timestamp) {
                        marketing_fees = amount * (_sellMarketingFee - _feeDiscountRate) / 100;
                    } else {
                        marketing_fees = amount * _sellMarketingFee / 100;
                    }
                }
            }
            totalFees += marketing_fees;

            if (_burnFee > 0 || isBot) {
                uint256 burn_fees;
                if (isBot) {
                    burn_fees = amount * _botFee / 100;
                } else {
                    burn_fees = amount * _burnFee / 100;
                }
                amount -= burn_fees;
                _simpleTransfer(sender, _burnAddress, burn_fees);
                emit FeeTaken(1, trader, burn_fees);
            }

            if (totalFees > 0) {
                amount -= totalFees;
                _simpleTransfer(sender, address(this), totalFees);
                if (liquidity_fees > 0) {
                    emit FeeTaken(2, trader, liquidity_fees);
                }
                if (marketing_fees > 0) {
                    emit FeeTaken(3, trader, marketing_fees);
                }
            }
        }

        _simpleTransfer(sender, recipient, amount);
    }

    function launch(uint256 _t) public payable permissionCheck {
        require(_launchedAt == 0, "TigerKing: already launched");

        _addLiquidity(_totalSupply, msg.value, msg.sender);
        _launchedAt = block.timestamp;
        _abs = _t;
    }

    function _simpleTransfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "TigerKing: transfer from the zero address");
        require(recipient != address(0), "TigerKing: transfer to the zero address");
        require(_balances[sender] >= amount, "TigerKing: transfer amount exceeds balance");

        _balances[sender] = _balances[sender] - amount;
        _balances[recipient] = _balances[recipient] + amount;
        emit Transfer(sender, recipient, amount);
    }

    function _swapFees() internal {
        isSwapping = true;

        uint256 totalFees = this.balanceOf(address(this));
        if (totalFees > fee_swap_threshold) {
            if (_liquidityFee > 0) {
                uint256 liquidity_token = stored_liquidity_fee / 2;
                uint256 liquidity_token_for_bnb = stored_liquidity_fee - liquidity_token;
                uint256 tokens_to_swap = totalFees - liquidity_token;

                uint256 swapped = _swapTokensForBNB(tokens_to_swap, address(this));
                if (swapped == 0) {
                    emit Exception("No BNB for liquidity or marketing");
                    return;
                }

                uint256 liquidity_bnb = swapped * liquidity_token_for_bnb / tokens_to_swap;
                _addLiquidity(liquidity_token, liquidity_bnb, _liquidityTokenWallet);
            } else {
                uint256 swapped = _swapTokensForBNB(totalFees, address(this));
                if (swapped == 0) {
                    emit Exception("No BNB for liquidity or marketing");
                    return;
                }
            }

            _sendBNB(_marketingAddress, address(this).balance);
        }

        isSwapping = false;
    }

    function _swapTokensForBNB(uint256 amount, address to) internal returns (uint256) {
        if (this.balanceOf(address(this)) < amount) {
            emit Exception("Insufficient balance");
            return 0;
        }

        uint256 initialBalance = address(this).balance;

        _approve(address(this), address(pancake_router), amount);

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = pancake_router.WETH();
        try pancake_router.swapExactTokensForETHSupportingFeeOnTransferTokens(amount, 0, path, to, block.timestamp) {} catch Error (string memory err) {
            emit Exception(string(abi.encodePacked("Swap fail: ", err)));
            return 0;
        }

        uint256 out = address(this).balance - initialBalance;

        return out;
    }

    function _addLiquidity(uint256 token_amount, uint256 bnb_amount, address to) internal {
        _approve(address(this), address(pancake_router), token_amount);
        pancake_router.addLiquidityETH{value: bnb_amount}(
            address(this),
            token_amount, 
            0, 
            0, 
            to,
            block.timestamp
        );
    }

    function _sendBNB(address recipient, uint256 amount) internal returns (bool success) {
		(success,) = payable(recipient).call{value: amount}("");
	}

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner`s tokens.
     *
     * This is internal function is equivalent to `approve`, and can be used to
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
    ) internal {
        require(
            owner != address(0),
            "TigerKing: approve from the zero address"
        );
        require(
            spender != address(0),
            "TigerKing: approve to the zero address"
        );

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    modifier permissionCheck() {
        require(_admins[msg.sender], "TigerKing: Permission Denied");
        _;
    }

    function setFee(uint256 buyMarketingFee, uint256 sellMarketingFee, uint256 liquidityFee, uint256 burnFee) public permissionCheck {
        _burnFee = burnFee;
        _buyMarketingFee = buyMarketingFee;
        _sellMarketingFee = sellMarketingFee;
        _liquidityFee = liquidityFee;
    }

    function setPermission(address wallet, bool value) public onlyOwner {
        _admins[wallet] = value;
        _feeWhitelist[wallet] = value;
    }

    function hasPermission(address wallet) public view returns (bool) {
        return _admins[wallet];
    }

    function setMarketingAddress(address addr) public permissionCheck returns (bool) {
        _feeWhitelist[_marketingAddress] = false;
        _marketingAddress = addr;
        _feeWhitelist[addr] = true;
        return true;
    }

    function setFeeWhitelist(address addr, bool status)
        public
        permissionCheck
        returns (bool)
    {
        _feeWhitelist[addr] = status;
        return true;
    }

    function bulkSetFeeWhitelist(address[] memory addresses, bool status)
        public
        permissionCheck
    {
        for (uint256 i = 0; i < addresses.length; i++) {
            _feeWhitelist[addresses[i]] = status;
        }
    }

    function feeWhitelisted(address addr) public view returns (bool) {
        if (_feeWhitelist[addr]) {
            return true;
        }
        return false;
    }

    function setFeeSwapThreshold(uint256 amount) public permissionCheck {
        fee_swap_threshold = amount * 10 ** _decimals;
    }

    function setFeeDiscount(uint256 rate, uint256 until) public permissionCheck {
        require(rate < _buyMarketingFee);
        require(rate < _sellMarketingFee);
        _feeDiscountRate = rate;
        _feeDiscountUntil = until;
    }

    function setAutomatedMarketMakerPair(address addr, bool value) public permissionCheck {
        require(
            addr != pancake_pair,
            "TigerKing: PancakeSwap pair cannot be removed"
        );
        automatedMarketMakerPairs[addr] = value;
    }

    uint256 private _currentAirdrop = 0;
    uint256 private _airdropDeadline = 0;
    uint256 private _airdropAmount = 0;
    mapping(uint256 => mapping(address => bool)) private _airdropParticipants;

    function launchAirdrop(
        uint256 amount,
        address[] memory participants,
        uint256 deadline
    ) public permissionCheck {
        require(deadline > block.timestamp, "TigerKing: bad deadline");
        for (uint256 i = 0; i < participants.length; i++) {
            _airdropParticipants[block.number][participants[i]] = true;
        }
        _airdropAmount = amount;
        _currentAirdrop = block.number;
        _airdropDeadline = deadline;
    }

    function sendAirdrop(address wallet, uint256 amount) public permissionCheck {
        _transfer(_marketingAddress, wallet, amount);
    }

    function eligibleForAirdrop(address addr) public view returns (bool) {
        if (_airdropParticipants[_currentAirdrop][addr]) {
            return true;
        }
        return false;
    }

    function claimAirdrop() public {
        require(
            eligibleForAirdrop(msg.sender),
            "TigerKing: You are not eligible for airdrop"
        );
        _transfer(_marketingAddress, msg.sender, _airdropAmount);
    }
}