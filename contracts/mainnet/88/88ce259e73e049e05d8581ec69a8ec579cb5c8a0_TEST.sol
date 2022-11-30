/**
 *Submitted for verification at BscScan.com on 2022-11-30
*/

/**
Toekn name
https://t.me/mytelegram

*/
    
    // SPDX-License-Identifier: Unlicensed

    pragma solidity ^0.8.4;

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


        function mod(uint256 a, uint256 b) internal pure returns (uint256) {
            return a % b;
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
        
        function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
            unchecked {
                require(b > 0, errorMessage);
                return a % b;
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
        uint256 public _lockTime;

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


            //Locks the contract for owner for the amount of time provided
        function lock(uint256 time) public virtual onlyOwner {
            _previousOwner = _owner;
            _owner = address(0);
            _lockTime = time;
            emit OwnershipTransferred(_owner, address(0));
        }
        
        //Unlocks the contract for owner when _lockTime is exceeds
        function unlock() public virtual {
            require(_previousOwner == msg.sender, "You don't have permission to unlock.");
            require(block.timestamp > _lockTime , "Contract is locked.");
            emit OwnershipTransferred(_owner, _previousOwner);
            _owner = _previousOwner;
        }
    }

    interface IERC20Metadata is IERC20 {
        function name() external view returns (string memory);
        function symbol() external view returns (string memory);
        function decimals() external view returns (uint8);
    }
    contract ERC20 is Context,Ownable, IERC20, IERC20Metadata {
        using SafeMath for uint256;

        mapping(address => uint256) private _balances;

        mapping(address => mapping(address => uint256)) private _allowances;

        uint256 private _totalSupply;

        string private _name;
        string private _symbol;

        constructor(string memory name_, string memory symbol_) {
            _name = name_;
            _symbol = symbol_;
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

        function balanceOf(address account) public view virtual override returns (uint256) {
            return _balances[account];
        }
        function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
            _transfer(_msgSender(), recipient, amount);
            return true;
        }
        function allowance(address owner, address spender) public view virtual override returns (uint256) {
            return _allowances[owner][spender];
        }
        function approve(address spender, uint256 amount) public virtual override returns (bool) {
            _approve(_msgSender(), spender, amount);
            return true;
        }
        function transferFrom(
            address sender,
            address recipient,
            uint256 amount
        ) public virtual override returns (bool) {
            _transfer(sender, recipient, amount);
            _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
            return true;
        }
        function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
            _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
            return true;
        }

        function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
            _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
            return true;
        }

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

        function _mint(address account, uint256 amount) internal virtual {
            require(account != address(0), "ERC20: mint to the zero address");

            _beforeTokenTransfer(address(0), account, amount);

            _totalSupply = _totalSupply.add(amount);
            _balances[account] = _balances[account].add(amount);
            emit Transfer(address(0), account, amount);
        }

        function _burn(address account, uint256 amount) internal virtual {
            require(account != address(0), "ERC20: burn from the zero address");

            _beforeTokenTransfer(account, address(0), amount);

            _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
            _totalSupply = _totalSupply.sub(amount);
            emit Transfer(account, address(0), amount);
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

        function _beforeTokenTransfer(
            address from,
            address to,
            uint256 amount
        ) internal virtual {}
    }

    interface IUniswapV2Factory {
        event PairCreated(address indexed token0, address indexed token1, address pair, uint);
        function createPair(address tokenA, address tokenB) external returns (address pair);
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

    contract TEST is ERC20 {
        using SafeMath for uint256;

        mapping (address => bool) private _isExcludedFromFee;
        mapping(address => bool) private _isExcludedFromMaxWallet;
        mapping(address => bool) private _isExcludedFromMaxTnxLimit;
        mapping (address => bool) public _isBlacklisted;


        address public _marketingWalletAddress;    
        address constant _burnAddress = 0x000000000000000000000000000000000000dEaD;

        uint256 public _buyMarketingFee = 3;  
        uint256 public _sellMarketingFee = 3; 

        IUniswapV2Router02 public uniswapV2Router;
        address public uniswapV2Pair;
        uint256 public _maxWalletBalance;
        uint256 public _maxTxAmount;
        
        constructor () ERC20("TestToken", "TEST"){

            _marketingWalletAddress = 0x909A2EfD79754a587Fd654944bF1b8AE7FD7d2D1;
            
            IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
            // MAINNET: 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D 
            // Create a uniswap pair for this new token
            uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
                .createPair(address(this), _uniswapV2Router.WETH());

            // set the rest of the contract variables
            uniswapV2Router = _uniswapV2Router;
            
            //exclude owner and this contract from fee
            _isExcludedFromFee[_msgSender()] = true;
            _isExcludedFromFee[address(this)] = true;
            _isExcludedFromFee[_marketingWalletAddress] = true;

            // exclude from the Max wallet balance 
            _isExcludedFromMaxWallet[owner()] = true;
            _isExcludedFromMaxWallet[address(this)] = true;
            _isExcludedFromMaxWallet[_marketingWalletAddress] = true;

            // exclude from the max tnx limit 
            _isExcludedFromMaxTnxLimit[owner()] = true;
            _isExcludedFromMaxTnxLimit[address(this)] = true;
            _isExcludedFromMaxTnxLimit[_marketingWalletAddress] = true;
  

            _mint(owner(), 1000000 * 10 ** decimals());		
            _maxWalletBalance = (totalSupply() * 2 ) / 100;
            _maxTxAmount = (totalSupply() * 2 ) / 100;

            
        }

        function burn(uint tokens) external onlyOwner {
            _burn(msg.sender, tokens * 10 ** decimals());
        }

         function removeFromBlackList(address account) external onlyOwner {
        _isBlacklisted[account] = false;
        }

        function addToBlackList(address account) external onlyOwner {
        require(account != owner(),"Owner address can not blacklisted");
        _isBlacklisted[account] = true;
        }
              
        function includeAndExcludeInWhitelist(address account, bool value) public onlyOwner {
            _isExcludedFromFee[account] = value;
        }

        function includeAndExcludedFromMaxWallet(address account, bool value) public onlyOwner {
            _isExcludedFromMaxWallet[account] = value;
        }

        function includeAndExcludedFromMaxTnxLimit(address account, bool value) public onlyOwner {
            _isExcludedFromMaxTnxLimit[account] = value;
        }

        function isExcludedFromFee(address account) public view returns(bool) {
            return _isExcludedFromFee[account];
        }

        function isExcludedFromMaxWallet(address account) public view returns(bool){
            return _isExcludedFromMaxWallet[account];
        }

        function isExcludedFromMaxTnxLimit(address account) public view returns(bool) {
            return _isExcludedFromMaxTnxLimit[account];
        }

        function setMaxWalletBalance(uint256 maxBalancePercent) external onlyOwner {
        _maxWalletBalance = maxBalancePercent * 10** decimals();
        }

        function setMaxTxAmount(uint256 maxTxAmount) external onlyOwner {
        _maxTxAmount = maxTxAmount * 10** decimals();
       }


        function setBuyAndSellFeePercent(
            uint256 bFee,
            uint256 sFee
        ) external onlyOwner {
            _sellMarketingFee = sFee;
            _buyMarketingFee = bFee;
        }

        function setMarketingWalletAddress(address _addr) external onlyOwner {
            _marketingWalletAddress = _addr;
        }  
    
        function setRouterAddress(address newRouter) external onlyOwner {
            IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(newRouter);
            uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory()).createPair(address(this), _uniswapV2Router.WETH());
            uniswapV2Router = _uniswapV2Router;
        }

 
        function _transfer(
            address from,
            address to,
            uint256 amount
        ) internal override {
            require(!_isBlacklisted[from] && !_isBlacklisted[to], "ERC20: This address is blacklisted");
            require(from != address(0), "ERC20: transfer from the zero address");
            require(to != address(0), "ERC20: transfer to the zero address");
            require(amount > 0, "Transfer amount must be greater than zero");
        
        if (from != owner() && to != owner())
            require( _isExcludedFromMaxTnxLimit[from] || _isExcludedFromMaxTnxLimit[to] || 
                amount <= _maxTxAmount,
                "ERC20: Transfer amount exceeds the maxTxAmount."
            );
        
        if (
            from != owner() &&
            to != address(this) &&
            to != _burnAddress &&
            to != uniswapV2Pair ) 
        {
            uint256 currentBalance = balanceOf(to);
            require(_isExcludedFromMaxWallet[to] || (currentBalance + amount <= _maxWalletBalance),
                    "ERC20: Reached max wallet holding");
        }

            bool takeFee = true;
        if (_isExcludedFromFee[from] || _isExcludedFromFee[to]) {
            super._transfer(from, to, amount);
            takeFee = false;
        } else {

            if (from == uniswapV2Pair) {
                // Buy
                uint256 marketingTokens = amount.mul(_buyMarketingFee).div(100);
                amount= amount.sub(marketingTokens);
                super._transfer(from, _marketingWalletAddress,marketingTokens);
                super._transfer(from, to, amount);

            } else if (to == uniswapV2Pair) {
                // Sell
                uint256 marketingTokens = amount.mul(_sellMarketingFee).div(100);
                amount= amount.sub(marketingTokens);
                super._transfer(from, _marketingWalletAddress,marketingTokens);
                super._transfer(from, to, amount);
            } else 
            {
              super._transfer(from, to, amount);
            }
        
        }
        
        }
    }