/**
 *Submitted for verification at BscScan.com on 2023-02-02
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 amount) external returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

interface IERC20Metadata is IERC20 {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

abstract contract Ownable {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        _transferOwnership(msg.sender);
    }

    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    function _checkOwner() internal view virtual {
        require(owner() == msg.sender, "Ownable: caller is not the owner");
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

contract UniverzToken is IERC20Metadata, Ownable {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;
    IERC20Metadata public exchangeToken;

    string private _name;
    string private _symbol;

    uint256[4] salePhasesPercentages;
    uint256[4] salePhasePrices;
    uint256[4] minPurchaseAmount;
    uint256 currentSalePhase;
    uint256 public soldTokens;
    uint256 public saleCounter;

    uint256 public percentDivider;
    bool    public buyingPaused;

    constructor() {
        _name = "Univerz";
        _symbol = "UNIV";

        exchangeToken = IERC20Metadata(
            0xAEA4A4E5b7C8CCe84d727206Fd5F46D702B6ec99
        );

        _mint(msg.sender, 800_000_000 * (10**decimals()));
        _mint(address(this), 200_000_000 * (10**decimals()));
        percentDivider = 100_00;
        salePhasesPercentages = [500, 500, 500, 500];
        minPurchaseAmount = [5000000, 10000000, 15000000, 25000000];
        salePhasePrices = [5000, 100000, 150000, 250000];
    }

    function buyToken(uint256 _payAmount) public {
        require(
            !buyingPaused,
            "The buying is currently paused. Can't buy at this moment"
        );
        require(
            soldTokens < (totalSupply() * 2000) / percentDivider,
            "Sale  is Over!"
        );
        require(
            _payAmount >= minPurchaseAmount[currentSalePhase],
            "You cannot buy minimum token than limit of phase"
        );
        exchangeToken.transferFrom(msg.sender, address(this), _payAmount);

        uint256 _amountOfTokens = getTokenAmount(_payAmount);

      

        require(
            _amountOfTokens <=
                ((totalSupply() * salePhasesPercentages[currentSalePhase]) /
                    percentDivider) -
                    saleCounter,
            " You cannot buy as much amount of token in current phase of presale.Because tokens more than your demand is sold out.Try to decrease the amount"
        );

        saleCounter += _amountOfTokens;
        if (
            saleCounter >=
            (totalSupply() * salePhasesPercentages[currentSalePhase]) /
                percentDivider &&
            currentSalePhase < 4
        ) {
            currentSalePhase++;
            saleCounter = 0;
        }

        this.transfer(msg.sender, _amountOfTokens);
        soldTokens += _amountOfTokens;
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

    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
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

    function transfer(address to, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {
        address owner = msg.sender;
        _transfer(owner, to, amount);
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
        address owner = msg.sender;
        _approve(owner, spender, amount);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address spender = msg.sender;
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue)
        public
        virtual
        returns (bool)
    {
        address owner = msg.sender;
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        virtual
        returns (bool)
    {
        address owner = msg.sender;
        uint256 currentAllowance = allowance(owner, spender);
        require(
            currentAllowance >= subtractedValue,
            "ERC20: decreased allowance below zero"
        );
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(
            fromBalance >= amount,
            "ERC20: transfer amount exceeds balance"
        );
        unchecked {
            _balances[from] = fromBalance - amount;

            _balances[to] += amount;
        }

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        unchecked {
            // Overflow not possible: balance + amount is at most totalSupply + amount, which is checked above.
            _balances[account] += amount;
        }
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
            // Overflow not possible: amount <= accountBalance <= totalSupply.
            _totalSupply -= amount;
        }

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
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

    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(
                currentAllowance >= amount,
                "ERC20: insufficient allowance"
            );
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    function getTokenAmount(uint256 _amount) public view returns (uint256) {
        return (_amount * 1e18) / salePhasePrices[currentSalePhase];
    }
    function pauseOrUnpauseBuying(bool _pause) external onlyOwner {
        buyingPaused = _pause;
    }

    function setSalePhasesPercentages(
        uint256[4] memory _percentages,
        uint256 _percentDivider
    ) external onlyOwner {
        salePhasesPercentages = _percentages;
        percentDivider = _percentDivider;
    }

    function setMinAmountofPurchase(uint256[4] memory _minPurchaseAmount)
        external
        onlyOwner
    {
        minPurchaseAmount = _minPurchaseAmount;
    }

    function withdrawStuckToken(IERC20Metadata _token, uint256 _amount)
        external
        onlyOwner
    {
        _token.transfer(msg.sender, _amount);
    }

    function changeExchangeToken(IERC20Metadata _token) external onlyOwner {
        exchangeToken = _token;
    }


}