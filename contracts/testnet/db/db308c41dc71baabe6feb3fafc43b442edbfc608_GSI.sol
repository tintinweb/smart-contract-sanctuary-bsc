/**
 *Submitted for verification at BscScan.com on 2022-05-12
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IERC20
{
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IERC20Metadata is IERC20
{
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
}

contract GSI is IERC20, IERC20Metadata
{
    mapping(address => uint256) private _balance;
    mapping(address => mapping(address => uint256)) private _allowed;

    address private _owner;
    address private _marketingTaxWallet;
    address private _developmentTaxWallet;
    address private _charityTaxWallet;

    uint8 public deflation;
    uint8 public marketingTax;
    uint8 public developmentTax;
    uint8 public charityTax;

    bool public isBurnable;
    bool public isTaxable;
    
    string private _name;
    string private _symbol;
    uint8 private _decimals;

    uint256 private __airdropFund;
    uint256 private __teamFund;
    uint256 private __icoFund;
    uint256 private __liquidityFund;
    uint256 private __dexListingFund;
    uint256 private __cexListingFund;
    uint256 private __autoBurnReserveFund;

    uint256 private _totalSupply;
    uint256 public initialSupply;
    uint256 public minSupply;

    uint256 public totalBurn;
    uint256 public totalTaxCollected;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor(address ___MarketingTaxWallet___, address ___DevelopmentTaxWallet___, address ___CharityTaxWallet___)
    {
        _owner = msg.sender;
        _marketingTaxWallet = ___MarketingTaxWallet___;
        _developmentTaxWallet = ___DevelopmentTaxWallet___;
        _charityTaxWallet = ___CharityTaxWallet___;

        deflation = 5;
        marketingTax = 2;
        developmentTax = 2;
        charityTax = 1;

        isBurnable = isTaxable = false;

        _name = "Giant Shiba Inu";
        _symbol = "GSI";
        _decimals = 18;

        __airdropFund = 20000000000  * 10 ** _decimals;
        __teamFund = 50000000000 * 10 ** _decimals;
        __icoFund = 180000000000 * 10 ** _decimals;
        __liquidityFund = 300000000000 * 10 ** _decimals;
        __dexListingFund = 100000000000 * 10 ** _decimals;
        __cexListingFund = 50000000000 * 10 ** _decimals;
        __autoBurnReserveFund = 300000000000 * 10 ** _decimals;

        _totalSupply = __airdropFund + __teamFund + __icoFund + __liquidityFund + __dexListingFund + __cexListingFund + __autoBurnReserveFund;
        initialSupply = _totalSupply;
        minSupply = initialSupply - __autoBurnReserveFund;

        _balance[address(this)] = _totalSupply;
        emit Transfer(address(0), address(this), __airdropFund); //
        emit Transfer(address(0), address(this), __teamFund); //
        emit Transfer(address(0), address(this), __icoFund);
        emit Transfer(address(0), address(this), __liquidityFund);
        emit Transfer(address(0), address(this), __dexListingFund);
        emit Transfer(address(0), address(this), __cexListingFund);
        emit Transfer(address(0), address(this), __autoBurnReserveFund); //
    }

    modifier onlyOwner
    {
        require(msg.sender == _owner, "Permission denied, you're not the owner!");
        _;
    }

    function transferOwnership(address newOwner) public onlyOwner
    {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(msg.sender, newOwner);
        _owner = newOwner;
    }

    function renounceOwnership() public onlyOwner
    {
        emit OwnershipTransferred(msg.sender, address(0));
        _owner = address(0);
    }

    function burnable() public onlyOwner 
    {
        isBurnable = !isBurnable;
    }

    function setTaxWallets(address marketingTaxWallet, address developmentTaxWallet, address charityTaxWallet) onlyOwner public
    {
        _marketingTaxWallet = marketingTaxWallet;
        _developmentTaxWallet = developmentTaxWallet;
        _charityTaxWallet = charityTaxWallet;
    }

    function taxable() public onlyOwner
    {
        isTaxable = !isTaxable;
    }

    function airdrop(address[] memory recipient, uint256 amount) public onlyOwner returns (bool)
    {
        _balance[address(this)] -= amount;
        for(uint256 i=0; i<recipient.length; i++)
        {
            _balance[recipient[i]] += amount/recipient.length;
            emit Transfer(address(this), recipient[i], amount/recipient.length);
        }
        return true;
    }

    function name() public view virtual override returns (string memory)
    {
        return _name;
    }

    function symbol() public view virtual override returns (string memory)
    {
        return _symbol;
    }

    function decimals() public view virtual override returns (uint8)
    {
        return _decimals;
    }

    function totalSupply() public view virtual override returns (uint256)
    {
        return _totalSupply;
    }

    function balanceOf(address account) public view virtual override returns (uint256)
    {
        return _balance[account];
    }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool)
    {
        require(_balance[msg.sender] >= amount, "Your balance is too low!");
        require(recipient != address(0), "You don't have the permission to burn tokens!");
        _balance[msg.sender] -= amount;
        if(isBurnable && _totalSupply > minSupply &&  (amount * deflation / 100) <= (__autoBurnReserveFund - totalBurn))
        {
            _balance[address(this)] -= (amount * deflation / 100);
            _totalSupply -= (amount * deflation / 100);
            totalBurn += (amount * deflation / 100);
            emit Transfer(address(this), address(0), (amount * deflation / 100));
        }
        if(isTaxable)
        {
            _balance[_marketingTaxWallet] += amount * marketingTax / 100;
            emit Transfer(msg.sender, _marketingTaxWallet, amount * marketingTax / 100);
            _balance[_developmentTaxWallet] += amount * developmentTax / 100;
            emit Transfer(msg.sender, _developmentTaxWallet, amount * developmentTax / 100);
            _balance[_charityTaxWallet] += amount * charityTax / 100;
            emit Transfer(msg.sender, _charityTaxWallet, amount * charityTax /100);
            totalTaxCollected += amount * (marketingTax + developmentTax  + charityTax) / 100;
            uint taxableAmount = amount * (marketingTax + developmentTax + charityTax) / 100;
            _balance[recipient] += (amount - taxableAmount);
            emit Transfer(msg.sender, recipient, (amount - taxableAmount));
        }
        else
        {
            _balance[recipient] += amount;
            emit Transfer(msg.sender, recipient, amount);
        }
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256)
    {
        return _allowed[owner][spender];
    }

    function approve(address spender, uint amount) public virtual override returns (bool)
    {
        require(spender != address(0), "You don't have the permission to approve the null/zero address!");
        _allowed[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 amount) public virtual returns (bool)
    {
        require(spender != address(0), "You don't have the permission to approve the null/zero address!");
        _allowed[msg.sender][spender] += amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function decreaseAllowance(address spender, uint256 amount) public virtual returns (bool)
    {
        require(spender != address(0), "You don't have the permission to approve the null/zero address!");
        require(_allowed[msg.sender][spender] >= amount, "Allowance can't be less than zero!");
        _allowed[msg.sender][spender] -= amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }
 
    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool)
    {
        require(_balance[sender] >= amount, "Your balance is too low!");
        require(_allowed[sender][msg.sender] >= amount, "Your allowance is too low!");
        require(recipient != address(0), "You don't have the permission to burn tokens!");
        _balance[sender] -= amount;
        _allowed[sender][msg.sender] -= amount;
        if(isBurnable && _totalSupply > minSupply &&  (amount * deflation / 100) <= (__autoBurnReserveFund - totalBurn))
        {
            _balance[address(this)] -= (amount * deflation / 100);
            _totalSupply -= (amount * deflation / 100);
            totalBurn += (amount * deflation / 100);
            emit Transfer(address(this), address(0), (amount * deflation / 100));
        }
        if(isTaxable)
        {
            _balance[_marketingTaxWallet] += amount * marketingTax / 100;
            emit Transfer(sender, _marketingTaxWallet, amount * marketingTax / 100);
            _balance[_developmentTaxWallet] += amount * developmentTax / 100;
            emit Transfer(sender, _developmentTaxWallet, amount * developmentTax / 100);
            _balance[_charityTaxWallet] += amount * charityTax / 100;
            emit Transfer(sender, _charityTaxWallet, amount * charityTax /100);
            totalTaxCollected += amount * (marketingTax + developmentTax  + charityTax) / 100;
            uint taxableAmount = amount * (marketingTax + developmentTax + charityTax) / 100;
            _balance[recipient] += (amount - taxableAmount);
            emit Transfer(sender, recipient, (amount - taxableAmount));
        }
        else
        {
            _balance[recipient] += amount;
            emit Transfer(sender, recipient, amount);
        }
        return true;
    }
}