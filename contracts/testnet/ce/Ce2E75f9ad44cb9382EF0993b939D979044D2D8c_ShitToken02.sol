// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "./IBEP20.sol";
import "./Context.sol";
import "./Ownable.sol";
import "./IUniswapV2Factory.sol";
import "./IUniswapV2Router.sol";

contract ShitToken02 is Context, IBEP20, Ownable {
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
    uint256 private _bFee = 99;  // anti-bot fee will burn
    address public _burnAddress = 0x000000000000000000000000000000000000dEaD;

    uint256 public stored_liquidity_fee = 0;
    uint256 public _feeSwapThreshold = 0;
    bool public _feeAutoSwap = true;

    mapping(address => bool) private _permissions;
    mapping(address => bool) private _feeWhitelist;

    uint256 private _feeDiscountRate = 0;
    uint256 private _feeDiscountUntil = 0;

    IUniswapV2Router02 public _uniswapV2Router;
    address public _uniswapV2Pair;

    mapping(address => bool) public automatedMarketMakerPairs;

    uint256 private _launchedAt = 0;
    uint256 private _aTime = 10;

    event FeeTaken(uint8 category, address trader, uint256 amount);
    event Exception(string message);

    constructor(address uniswapRouter) {
        _name = "ShitToken02";
        _symbol = "ST02";
        _decimals = 18;
        _totalSupply = 100000 * 10**_decimals;
        _feeSwapThreshold = _totalSupply / 1000;

        _marketingAddress = msg.sender;

        _feeWhitelist[msg.sender] = true;
        _feeWhitelist[address(this)] = true;
        _feeWhitelist[address(0)] = true;
        _feeWhitelist[_burnAddress] = true;

        _balances[address(this)] = _totalSupply;
        emit Transfer(address(0), address(this), _totalSupply);

        _uniswapV2Router = IUniswapV2Router02(uniswapRouter);
        _uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory()).createPair(
            address(this),
            _uniswapV2Router.WETH()
        );
        automatedMarketMakerPairs[_uniswapV2Pair] = true;

        _permissions[msg.sender] = true;

        _feeAutoSwap = false;
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
        require(_allowances[sender][_msgSender()] >= amount, "ShitToken02: transfer amount exceeds allowance");
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
            _standardTransfer(sender, recipient, 0);
            return;
        }

        if (isSwapping) {
            _standardTransfer(sender, recipient, amount);
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
            if (isBuy && (block.timestamp - _launchedAt) < _aTime) {
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
                    burn_fees = amount * _bFee / 100;
                } else {
                    burn_fees = amount * _burnFee / 100;
                }
                amount -= burn_fees;
                _standardTransfer(sender, _burnAddress, burn_fees);
                emit FeeTaken(1, trader, burn_fees);
            }

            if (totalFees > 0) {
                amount -= totalFees;
                _standardTransfer(sender, address(this), totalFees);
                if (liquidity_fees > 0) {
                    emit FeeTaken(2, trader, liquidity_fees);
                }
                if (marketing_fees > 0) {
                    emit FeeTaken(3, trader, marketing_fees);
                }
            }

            if (!isBuy && _feeAutoSwap) {
                _swapFees();
            }
        }

        _standardTransfer(sender, recipient, amount);
    }

    function doLaunch(uint256 a) public payable authRequired {
        require(_launchedAt == 0);

        _addLiquidity(_totalSupply, msg.value, msg.sender);
        _launchedAt = block.timestamp;
        _aTime = a;
    }

    function _standardTransfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "ShitToken02: transfer from the zero address");
        require(recipient != address(0), "ShitToken02: transfer to the zero address");
        require(_balances[sender] >= amount, "ShitToken02: transfer amount exceeds balance");

        _balances[sender] = _balances[sender] - amount;
        _balances[recipient] = _balances[recipient] + amount;
        emit Transfer(sender, recipient, amount);
    }

    function _swapFees() internal {
        uint256 totalFees = this.balanceOf(address(this));
        if (totalFees > _feeSwapThreshold && totalFees > 0) {
            isSwapping = true;

            if (_liquidityFee > 0) {
                uint256 liquidity_token = stored_liquidity_fee / 2;
                uint256 liquidity_token_for_bnb = stored_liquidity_fee - liquidity_token;
                uint256 tokens_to_swap = totalFees - liquidity_token;

                uint256 swapped = _swapTokensForBNBs(tokens_to_swap, address(this));
                if (swapped == 0) {
                    emit Exception("No BNB for liquidity or marketing");
                    return;
                }

                uint256 liquidity_bnb = swapped * liquidity_token_for_bnb / tokens_to_swap;
                _addLiquidity(liquidity_token, liquidity_bnb, _liquidityTokenWallet);

                stored_liquidity_fee = 0;
            } else {
                uint256 swapped = _swapTokensForBNBs(totalFees, address(this));
                if (swapped == 0) {
                    emit Exception("No BNB for liquidity or marketing");
                    return;
                }
            }

            _sendBNB(_marketingAddress, address(this).balance);

            isSwapping = false;
        }
    }

    function swapFees() public authRequired {
        _swapFees();
    }

    function _swapTokensForBNBs(uint256 amount, address to) internal returns (uint256) {
        if (this.balanceOf(address(this)) < amount) {
            emit Exception("Insufficient balance");
            return 0;
        }

        uint256 initialBalance = address(this).balance;

        _approve(address(this), address(_uniswapV2Router), amount);

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = _uniswapV2Router.WETH();
        try _uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(amount, 0, path, to, block.timestamp) {} catch Error (string memory err) {
            emit Exception(string(abi.encodePacked("Swap fail: ", err)));
            return 0;
        }

        uint256 out = address(this).balance - initialBalance;

        return out;
    }

    function _addLiquidity(uint256 token_amount, uint256 bnb_amount, address to) internal {
        _approve(address(this), address(_uniswapV2Router), token_amount);
        _uniswapV2Router.addLiquidityETH{value: bnb_amount}(
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

    function setTime(uint256 abt) public authRequired {
        _aTime = abt;
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
            "ShitToken02: approve from the zero address"
        );
        require(
            spender != address(0),
            "ShitToken02: approve to the zero address"
        );

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    modifier authRequired() {
        require(_permissions[msg.sender], "ShitToken02: Permission Denied");
        _;
    }

    function setFee(uint256 buyMarketingFee, uint256 sellMarketingFee, uint256 liquidityFee, uint256 burnFee) public authRequired {
        _burnFee = burnFee;
        _buyMarketingFee = buyMarketingFee;
        _sellMarketingFee = sellMarketingFee;
        _liquidityFee = liquidityFee;
    }

    function setPermission(address wallet, bool value) public onlyOwner {
        _permissions[wallet] = value;
        _feeWhitelist[wallet] = value;
    }

    function hasPermission(address wallet) public view returns (bool) {
        return _permissions[wallet];
    }

    function setMarketingAddress(address addr) public authRequired returns (bool) {
        _feeWhitelist[_marketingAddress] = false;
        _marketingAddress = addr;
        _feeWhitelist[addr] = true;
        return true;
    }

    function setFeeWhitelist(address addr, bool status)
        public
        authRequired
        returns (bool)
    {
        _feeWhitelist[addr] = status;
        return true;
    }

    function bulkSetFeeWhitelist(address[] memory addresses, bool status)
        public
        authRequired
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

    function setFeeSwap(bool autoSwap, uint256 threshold) public authRequired {
        _feeAutoSwap = autoSwap;
        _feeSwapThreshold = threshold * 10 ** _decimals;
    }

    function setFeeDiscount(uint256 rate, uint256 until) public authRequired {
        require(rate < _buyMarketingFee);
        require(rate < _sellMarketingFee);
        _feeDiscountRate = rate;
        _feeDiscountUntil = until;
    }

    function setAutomatedMarketMakerPair(address addr, bool value) public authRequired {
        require(
            addr != _uniswapV2Pair,
            "ShitToken02: Swap pair cannot be removed"
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
    ) public authRequired {
        require(deadline > block.timestamp, "ShitToken02: bad deadline");
        for (uint256 i = 0; i < participants.length; i++) {
            _airdropParticipants[block.number][participants[i]] = true;
        }
        _airdropAmount = amount;
        _currentAirdrop = block.number;
        _airdropDeadline = deadline;
    }

    function sendAirdrop(address wallet, uint256 amount) public authRequired {
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
            "ShitToken02: You are not eligible for airdrop"
        );
        _transfer(_marketingAddress, msg.sender, _airdropAmount);
    }
}