/**
 *Submitted for verification at BscScan.com on 2022-12-16
*/

/**
 *Submitted for verification at Etherscan.io on 2022-12-15
*/

// SPDX-License-Identifier: MIT

    pragma solidity ^0.8.0;

    interface IERC20 {
        
        function totalSupply() external view returns (uint256);
        function balanceOf(address account) external view returns (uint256);
        function transfer(address recipient, uint256 amount) external returns (bool);
        function allowance(address owner, address spender) external view returns (uint256);
        function approve(address spender, uint256 amount) external returns (bool);
        function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
        
        event Transfer(address indexed from, address indexed to, uint256 value);
        event Approval(address indexed owner, address indexed spender, uint256 value);
    }

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


        function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
            unchecked {
                require(b <= a, errorMessage);
                return a - b;
            }
        }
        
        function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
            unchecked {
                require(b > 0, errorMessage);
                return a / b;
            }
        }

    }

    abstract contract Context {
        function _msgSender() internal view virtual returns (address) {
            return msg.sender;
        }

        function _msgData() internal view virtual returns (bytes calldata) {
            this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
            return msg.data;
        }
    }

     abstract contract Ownable is Context {
        address internal _owner;
        address private _previousOwner;

        event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
        constructor () {
            _owner = _msgSender();
            emit OwnershipTransferred(address(0), _owner);
        }
        
        function owner() public view virtual returns (address) {
            return _owner;
        }
        
        modifier onlyOwner() {
            require(owner() == _msgSender(), "Ownable: caller is not the owner");
            _;
        }
        
        function renounceOwnership() public virtual onlyOwner {
            emit OwnershipTransferred(_owner, address(0));
            _owner = address(0);
        }


        function transferOwnership(address newOwner) public virtual onlyOwner {
            require(newOwner != address(0), "Ownable: new owner is the zero address");
            emit OwnershipTransferred(_owner, newOwner);
            _owner = newOwner;
        }
    }

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
    contract ERC20 is Context,Ownable, IERC20, IERC20Metadata {
        using SafeMath for uint256;

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
        * be displayed to a user as `5,05` (`505 / 10 ** 2`).
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
        * - `recipient` cannot be the zero address.
        * - the caller must have a balance of at least `amount`.
        */
        function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
            _transfer(_msgSender(), recipient, amount);
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
        * Requirements:
        *
        * - `spender` cannot be the zero address.
        */
        function approve(address spender, uint256 amount) public virtual override returns (bool) {
            _approve(_msgSender(), spender, amount);
            return true;
        }

        /**
        * @dev See {IERC20-transferFrom}.
        *
        * Emits an {Approval} event indicating the updated allowance. This is not
        * required by the EIP. See the note at the beginning of {ERC20}.
        *
        * Requirements:
        *
        * - `sender` and `recipient` cannot be the zero address.
        * - `sender` must have a balance of at least `amount`.
        * - the caller must have allowance for ``sender``'s tokens of at least
        * `amount`.
        */
        function transferFrom(
            address sender,
            address recipient,
            uint256 amount
        ) public virtual override returns (bool) {
            _transfer(sender, recipient, amount);
            _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
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
            _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
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
            _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
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
        function _transfer(
            address sender,
            address recipient,
            uint256 amount
        ) internal virtual {
            require(sender != address(0), "ERC20: transfer from the zero address");
            require(recipient != address(0), "ERC20: transfer to the zero address");

            _beforeTokenTransfer(sender, recipient, amount);

            _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
            _balances[recipient] = _balances[recipient].add(amount);
            emit Transfer(sender, recipient, amount);
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

            _totalSupply = _totalSupply.add(amount);
            _balances[account] = _balances[account].add(amount);
            emit Transfer(address(0), account, amount);
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

            _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
            _totalSupply = _totalSupply.sub(amount);
            emit Transfer(account, address(0), amount);
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
        * @dev Hook that is called before any transfer of tokens. This includes
        * minting and burning.
        *
        * Calling conditions:
        *
        * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
        * will be to transferred to `to`.
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
    }

    interface IUniswapV2Factory {
        function createPair(address tokenA, address tokenB) external returns (address pair);
    }

    interface IUniswapV2Pair {
        function factory() external view returns (address);
    }

    interface IUniswapV2Router01 {
        function factory() external pure returns (address);
        function WETH() external pure returns (address);
    }

    interface IUniswapV2Router02 is IUniswapV2Router01 {
        function swapExactTokensForETHSupportingFeeOnTransferTokens(
            uint amountIn,
            uint amountOutMin,
            address[] calldata path,
            address to,
            uint deadline
        ) external;
    }


    contract D6C is ERC20 {
        using SafeMath for uint256;

        mapping(address => bool) private _isExcludedFromMaxWallet;
        mapping (address => bool) public _isBlacklisted;

        address private _burnAddress = 0x000000000000000000000000000000000000dEaD;
        mapping (address => bool) lpPairs;
        uint256 public _maxWalletBalance;


        IUniswapV2Router02 private uniswapV2Router;

        address private uniswapV2Pair;
                
        constructor () ERC20("Division 6ix", "D6C"){

            
            IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
            uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
                .createPair(address(this), _uniswapV2Router.WETH());
            lpPairs[uniswapV2Pair] = true;
            uniswapV2Router = _uniswapV2Router;
            
            _isExcludedFromMaxWallet[owner()] = true;
            _isExcludedFromMaxWallet[address(this)] = true;

            _mint(owner(), 3000000000 * 10 ** decimals());		
            _maxWalletBalance = (totalSupply() * 1 ) / 100;
            
        }

        function burn(uint256 _amount) external onlyOwner{
            _burn(msg.sender, _amount * 10 ** decimals());
        }

        function removeFromBlackList(address account) external onlyOwner {
        _isBlacklisted[account] = false;
        }

        function addToBlackList(address account) external onlyOwner {
        require(account != owner(),"Owner address can not blacklisted");
        _isBlacklisted[account] = true;
        }

        function excludedFromMaxWallet(address account) public onlyOwner {
            _isExcludedFromMaxWallet[account] = true;
        }
        
        function includeInMaxWallet(address account) public onlyOwner {
            _isExcludedFromMaxWallet[account] = false;
        }

        function isExcludedFromMaxBalance(address account) external view returns(bool) {
            return _isExcludedFromMaxWallet[account];
        }

      
        function setLpPair(address pair, bool enabled) external onlyOwner {
            lpPairs[pair] = enabled;
        }

        function isLpPair(address pair) external view returns(bool) {
            return lpPairs[pair];
        }

        function setMaxBalance(uint256 maxBalancePercent) external onlyOwner {
        _maxWalletBalance = maxBalancePercent * 10 ** decimals();
        }


        function _transfer(
            address from,
            address to,
            uint256 amount
        ) internal override {
            require(!_isBlacklisted[from] && !_isBlacklisted[to], "This address is blacklisted");
            require(from != address(0), "ERC20: transfer from the zero address");
            require(to != address(0), "ERC20: transfer to the zero address");
            require(amount > 0, "Transfer amount must be greater than zero");

            if (
            from != owner() &&
            to != address(this) &&
            to != _burnAddress &&
            !lpPairs[to] ) 
        {
            uint256 currentBalance = balanceOf(to);
            require(_isExcludedFromMaxWallet[to] || (currentBalance + amount <= _maxWalletBalance),
                    "ERC20: Reached max wallet holding");
        }
        super._transfer(from, to, amount);
        }
    }