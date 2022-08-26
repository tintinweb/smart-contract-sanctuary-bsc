/**
 *Submitted for verification at BscScan.com on 2022-08-26
*/

/**
 *Submitted for verification at BscScan.com on 2022-08-14
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB)
    external
    returns (address pair);
}

interface IUniswapV2Router {
    function factory() external pure returns (address);
}


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

contract ERC20 is Ownable, IERC20, IERC20Metadata {
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
        return 13;
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

interface IERC721Enumerable {
    /**
     * @dev Returns the number of tokens in ``owner``'s account.
     */
    function balanceOf(address owner) external view returns (uint256 balance);

    /**
     * @dev Returns a token ID owned by `owner` at a given `index` of its token list.
     * Use along with {balanceOf} to enumerate all of ``owner``'s tokens.
     */
    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256);
}

contract TaichiToken is ERC20 {
    address public uniswapV2Pair;
    address public USDTAddr = address(0x55d398326f99059fF775485246999027B3197955);
    IUniswapV2Router public uniswapV2Router = IUniswapV2Router(0x10ED43C718714eb63d5aA57B78B54704E256024E);


    address public marketingAddress1 = address(0x7d8D306Fb2F1Ba04e0B50e93FA73c3A0F61Ed0b8);
    address public marketingAddress2 = address(0xea66a12D8f7965B06Db2a84010cd7bA9636eb182);
    address public marketingAddress3 = address(0x19f4203dD5F7feF2391bab32Fd9Faecb26d1B552);

    address public nftHolderAddress  = address(0xC20b0D0E3BC70f90392cb371B15A994031efd2a7);

    IERC721Enumerable public taichiNFT = IERC721Enumerable(0x70222aB74C992A7fc947f675c213A30513AAafF1);

    uint256 public startTime = 1661602380;  

    uint256 public swapTokensAtAmount = 1 * 1e13; 
    uint256 private minBalance = 1e6;

    mapping(address => bool) private isExcludedFromFees;
    mapping(address => bool) private isBlackList;

    uint256 public waitLPHolderTokenNum;  
    mapping (address => uint256) public lpHolderTokenNum;
    mapping (address => uint256) public lpHolderTokenWithdrawed;

    uint256 public oneNFTHolderRewardTokenTotal;  
    mapping (uint256 => uint256) public nftTokenIdWithdrawedTokenNum;
    mapping (address => uint256) public nftHolderTokenWithdrawed;  
    uint8 public nftTotalSupply = 88;  

    address[] public buyUser;
    mapping(address => bool) public havePushBuyUser;
    uint256 public currentSplitIndex;
    uint8 public splitTimesPerTran = 20;

    constructor() ERC20("Taichi", "Taichi") {        
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(address(this), USDTAddr);

        isExcludedFromFees[address(0xdb53C1a1360F297C98e5D48D92bb1016747f4475)] = true;
        isExcludedFromFees[address(0xbc4f23c52E40c7d4aDF1Ecec89252538d186d33a)] = true;
        isExcludedFromFees[address(0x73638d9747A4964674eC36904D8Ad7C132619cE1)] = true;
        
        uint256 total = 8000 * 1e13;
        _mint(address(0xA169eDDdDc0830148D4E03773aA62b6eFa0077A9), total);
    }

    function setExcludeFromFees(address account, bool excluded) public onlyOwner {
        isExcludedFromFees[account] = excluded;
    }

    function setBlackList(address account, bool isBlack) public onlyOwner {
        isBlackList[account] = isBlack;
    }

    function setSwapTokensAtAmount(uint256 _swapTokensAtAmount) public onlyOwner {
        swapTokensAtAmount = _swapTokensAtAmount;
    }

    function setTaichiNFT(address _taichiNFTAddr) public onlyOwner {
        taichiNFT = IERC721Enumerable(_taichiNFTAddr);
    }

    function setAddrParam(address _marketingAddress1, address _marketingAddress2, address _marketingAddress3, address _nftHolderAddress) public onlyOwner {
        marketingAddress1 = _marketingAddress1;
        marketingAddress2 = _marketingAddress2;
        marketingAddress3 = _marketingAddress3;
        nftHolderAddress = _nftHolderAddress;
    }

    function burn(uint256 amount) public {
        _burn(_msgSender(), amount);
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        require(amount > 0, "Amount Zero");
        require(balanceOf(from) > minBalance, "Amount Zero");
        require(!isBlackList[from] && !isBlackList[to], "Black list address");

        if (amount + minBalance > balanceOf(from)) {
            amount = balanceOf(from) - minBalance;
        }
		
		if(from == address(this) || to == address(this)){
            super._transfer(from, to, amount);
            return;
        }

        if(currentSplitIndex > 0 || waitLPHolderTokenNum >= swapTokensAtAmount){
            splitLPHolderToken();
        } else {
            clearBuyUser(3);
        }


        bool takeFee = true;
        if (isExcludedFromFees[from] || isExcludedFromFees[to]) {
            takeFee = false;
        } else {
            if(from == uniswapV2Pair) {

            } else if (to == uniswapV2Pair) {
            
            } else {
                takeFee = false;
            }
        }

        if (takeFee) {
            super._transfer(from, nftHolderAddress,  amount * 70 / 10000);
            super._transfer(from, marketingAddress2, amount * 25  / 10000);
            super._transfer(from, marketingAddress3, amount * 50  / 10000);
            
            super._transfer(from, address(this), amount * 130 / 10000);
            waitLPHolderTokenNum += amount * 100 / 10000;
            oneNFTHolderRewardTokenTotal += amount * 30 / 10000 / nftTotalSupply;

            if(block.timestamp > startTime + 60 * 60) { 
                super._transfer(from, marketingAddress1, amount * 25  / 10000);
                amount = amount * 9700 / 10000;
            } else if(block.timestamp > startTime + 5 * 60 && block.timestamp <= startTime + 60 * 60) {
                if (from == uniswapV2Pair) {
                    super._transfer(from, marketingAddress1, amount * 25  / 10000);
                    amount = amount * 9700 / 10000;
                } else {
                    super._transfer(from, marketingAddress1, amount * 1725  / 10000);
                    amount = amount * 8000 / 10000;
                }                
            } else if(block.timestamp > startTime + 2 * 60 && block.timestamp <= startTime + 5 * 60) {
                super._transfer(from, marketingAddress1, amount * 1725  / 10000);
                amount = amount * 8000 / 10000;
            } else if(block.timestamp <= startTime + 2 * 60) {
                if (from == uniswapV2Pair) {
                    super._transfer(from, marketingAddress1, amount * 1725  / 10000);
                    amount = amount * 8000 / 10000;
                    isBlackList[to] = true;
                } else {
                    super._transfer(from, marketingAddress1, amount * 25  / 10000);
                    amount = amount * 9700 / 10000;
                }
            }
        }
        
        super._transfer(from, to, amount);
        
        if(!havePushBuyUser[from] && to == uniswapV2Pair){
            havePushBuyUser[from] = true;
            buyUser.push(from);
        }
    }

    function rescueToken(address tokenAddress, uint256 tokens) public onlyOwner returns (bool success) {
        return IERC20(tokenAddress).transfer(_msgSender(), tokens);
    }

    function rescueETH() external onlyOwner {
        uint256 balance = address(this).balance;
        payable(owner()).transfer(balance);
    }

    function splitLPHolderToken() private {
        uint256 thisAmount = waitLPHolderTokenNum;
        
        address user;
        uint256 totalAmount = IERC20(uniswapV2Pair).totalSupply();
        uint256 rate;

        uint256 buySize = buyUser.length;
        uint256 thisTimeSize = currentSplitIndex + splitTimesPerTran > buySize ? buySize : currentSplitIndex + splitTimesPerTran;

        for(uint256 i = currentSplitIndex; i < thisTimeSize; i++){
            user = buyUser[i];

            rate = IERC20(uniswapV2Pair).balanceOf(user) * 1000000 / totalAmount;
            uint256 userAmt = thisAmount * rate / 1000000;

            lpHolderTokenNum[user] += userAmt;

            waitLPHolderTokenNum -= userAmt;

            currentSplitIndex ++;
        }

        if(currentSplitIndex >= buySize){
            currentSplitIndex = 0;
        }
    }

    function clearBuyUser(uint256 num) public {
        if (buyUser.length <= 0) {
            return;
        }

        uint256 buyUserLen = buyUser.length;
        uint256 toIdx = buyUserLen > num ? buyUserLen - num : 0;
        for(uint256 i = buyUserLen - 1; i >= toIdx; ) {
            address user = buyUser[i];

            if (IERC20(uniswapV2Pair).balanceOf(user) <= 0) {
                buyUser[i] = buyUser[buyUser.length - 1];

                buyUser.pop();
                havePushBuyUser[user] = false;
            }

            if (i > 0) {
                i --;
            } else {
                break;
            }
        }
    }

    function getBuyUsersize() public view returns(uint256) {
        return buyUser.length;
    }

    function getNFTTokenIds(address user) public view returns(uint256[] memory nftTokenIds) {
        uint256 nftAmt = taichiNFT.balanceOf(user);
        if (nftAmt <= 0) {
            return nftTokenIds;
        }

        nftTokenIds = new uint256[](nftAmt);

        for (uint256 i = 0; i < nftAmt; i++) {
            nftTokenIds[i] = taichiNFT.tokenOfOwnerByIndex(user, i);
        }
    }
    
    function getRewardInfo(address user) public view returns(uint256 lpCanWithdraw, uint256 lpWithdrawed, uint256 nftCanWithdraw, uint256 nftWithdrawed) {
        lpCanWithdraw = lpHolderTokenNum[user] - lpHolderTokenWithdrawed[user];
        lpWithdrawed = lpHolderTokenWithdrawed[user];
        nftWithdrawed = nftHolderTokenWithdrawed[user];

        uint256 nftAmt = taichiNFT.balanceOf(user);
        for (uint256 i = 0; i < nftAmt; i++) {
            uint256 tokenId = taichiNFT.tokenOfOwnerByIndex(user, i);
            nftCanWithdraw += oneNFTHolderRewardTokenTotal - nftTokenIdWithdrawedTokenNum[tokenId];
        }

    }

    function userWithdrawFund() public returns (bool) {
        uint256 nftCanWithdraw;
        uint256 nftAmt = taichiNFT.balanceOf(_msgSender());
        for (uint256 i = 0; i < nftAmt; i++) {
            uint256 tokenId = taichiNFT.tokenOfOwnerByIndex(_msgSender(), i);
            nftCanWithdraw += oneNFTHolderRewardTokenTotal - nftTokenIdWithdrawedTokenNum[tokenId];

            nftTokenIdWithdrawedTokenNum[tokenId] = oneNFTHolderRewardTokenTotal;
        }

        uint256 canWithdraw = nftCanWithdraw + lpHolderTokenNum[_msgSender()] - lpHolderTokenWithdrawed[_msgSender()];
        require(canWithdraw > 0, "balance not enough");
        require(canWithdraw <= balanceOf(address(this)), "system balance not enough");

        super._transfer(address(this), _msgSender(), canWithdraw);

        lpHolderTokenWithdrawed[_msgSender()] = lpHolderTokenNum[_msgSender()];

        nftHolderTokenWithdrawed[_msgSender()] += nftCanWithdraw;

        return true;
    }
}