// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import "./interfaces/IERC20.sol";
import "./interfaces/IUniswapV2Factory.sol";
import "./interfaces/IUniswapV2Router02.sol";
import "./interfaces/IWETH.sol";
import "./interfaces/IPinkAntibot.sol";
import "./libraries/SafeMath.sol";
import "./libraries/Context.sol";
import "./libraries/Auth.sol";

contract StepHunt is Context, Auth, IERC20 {
    using SafeMath for uint256;

    //ERC20
    uint8 private _decimals = 18;
    uint256 private _totalSupply = 1_000_000_000 * (10**_decimals);
    string private _name = "StepHunt Governance Token";
    string private _symbol = "HUNT";
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    //Tokenomic
    uint256 public percentBuy = 500;
    uint256 public percentSell = 500;
    uint256 public percentTaxDenominator = 10000;

    uint256 public minimumSwapForWeth = 1 * (10**_decimals);

    bool public isAutoSwapForWeth = true;
    bool public isTaxBuyEnable = true;
    bool public isTaxSellEnable = true;
    bool public isPinkAntibotEnable = false;

    mapping(address => bool) public isExcludeFromFee;

    address public taxReceiverAddress = 0x2Ce7369d0Bf30A8FCA0a77376da0de196CB0C7EE;
    address ZERO = 0x0000000000000000000000000000000000000000;
    address DEAD = 0x000000000000000000000000000000000000dEaD;

    address public factoryAddress;
    address public wethAddress;
    address public routerAddress;
    
    address public pinkAntibotAddress;
    IPinkAntiBot public pinkAntiBot;
    
    mapping(address => bool) public isPair;

    bool inSwap;

    modifier swapping() {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor(
      address _routerAddress,
      address _pinkAntiBotAddress
    ) Auth(msg.sender) {

      routerAddress = _routerAddress;

      wethAddress = IUniswapV2Router02(routerAddress).WETH();
      factoryAddress = IUniswapV2Router02(routerAddress).factory();
      IUniswapV2Factory(factoryAddress).createPair(address(this), wethAddress);
      address pairWETH = IUniswapV2Factory(factoryAddress).getPair(address(this), wethAddress);
      isPair[pairWETH] = true;

      isExcludeFromFee[msg.sender] = true;
      isExcludeFromFee[routerAddress] = true;

      pinkAntibotAddress = _pinkAntiBotAddress;
      pinkAntiBot = IPinkAntiBot(_pinkAntiBotAddress);

      pinkAntiBot.setTokenOwner(msg.sender);
      
      _approve(address(this), routerAddress, _totalSupply);

      _balances[msg.sender] = _totalSupply;
      emit Transfer(address(0), msg.sender, _totalSupply);
    }

    receive() external payable {}

    function name() public view override returns (string memory) {
        return _name;
    }

    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    function getOwner() public view virtual override returns (address) {
        return _getOwner();
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

    function transfer(address recipient, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {
        _transfer(_msgSender(), recipient, amount);
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
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        if (_allowances[sender][msg.sender] != _totalSupply) {
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender]
                .sub(amount, "StepHunt: Insufficient Allowance");
        }
        _transfer(sender,recipient,amount);
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

    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        virtual
        returns (bool)
    {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(
            currentAllowance >= subtractedValue,
            "Blocksafu: decreased allowance below zero"
        );
        unchecked {
            _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "Blocksafu: approve from the zero address");
        require(spender != address(0), "Blocksafu: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
      _beforeTransferToken(sender, recipient, amount);
      if(isPinkAntibotEnable) pinkAntiBot.onPreTransferCheck(sender, recipient, amount);
      if(shouldTakeFee(sender, recipient)){
        _complexTransfer(sender, recipient, amount);
      } else {
        _basicTransfer(sender, recipient, amount);
      }
      _afterTransferToken(sender, recipient, amount);
    }

    function _basicTransfer(address sender, address recipient, uint256 amount) internal {
      _balances[sender] = _balances[sender].sub(amount);
      _balances[recipient] = _balances[recipient].add(amount);
      emit Transfer(sender, recipient, amount);
    }

    function _complexTransfer(address sender, address recipient, uint256 amount) internal {
      uint256 amountTransfer = getAmountTransfer(amount, sender);

      if(shouldSwapForWeth(sender)) _swapForWeth(_balances[address(this)]);

      _balances[sender] = _balances[sender].sub(amount);
      _balances[recipient] = _balances[recipient].add(amountTransfer);
      emit Transfer(sender, recipient, amount);
    }

    function getAmountTransfer(uint256 amount, address sender) internal returns(uint256){
      uint256 percentTotalTax;
      uint256 amountTax;
      if(isPair[sender]) {
        percentTotalTax = percentBuy;
      } else {
        percentTotalTax = percentSell;
      }

      amountTax = amount.mul(percentTotalTax).div(percentTaxDenominator);
    
      _balances[address(this)] = _balances[address(this)].add(amountTax);
      emit Transfer(sender, address(this), amount);

      return amount.sub(amountTax);
    }

    function _beforeTransferToken(address sender, address recipient, uint256 amount) internal view {
      
    }

    function _afterTransferToken(address sender, address recipient, uint256 amount) internal {
      
    }

    function burn(uint256 amount) external {
        require(_balances[_msgSender()] >= amount,"StepHunt: Insufficient Amount");
        _burn(_msgSender(), amount);
    }

    function _burn(address account, uint256 amount) internal virtual {
        _balances[account] = _balances[account].sub(amount);
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, DEAD, amount);
    }


    function shouldTakeFee(address sender, address recipient) internal view returns(bool){
      if(inSwap) return false;
      if(isExcludeFromFee[sender]) return false;
      if(isPair[sender] && !isTaxBuyEnable) return false;
      if(isPair[recipient] && !isTaxSellEnable) return false;
      return true;
    }

    function shouldSwapForWeth(address sender) internal view returns(bool){
      return (isAutoSwapForWeth && !isPair[sender] && !inSwap && _balances[address(this)] >= minimumSwapForWeth); 
    }

    function setIsPair(address pairAddress, bool state) external onlyOwner {
      isPair[pairAddress] = state;
    }

    function setPinkAntibotEnable(bool state) external onlyOwner {
      isPinkAntibotEnable = state;
    }

    function setPinkAntibotAddress(address _pinkAntiBotAddress) external onlyOwner {
      pinkAntibotAddress = _pinkAntiBotAddress;
      pinkAntiBot = IPinkAntiBot(_pinkAntiBotAddress); 
      pinkAntiBot.setTokenOwner(msg.sender);
    }

    function setTaxReceiver(address _taxReceiverAddress) external onlyOwner {
      taxReceiverAddress = _taxReceiverAddress;
    }

     function setIsTaxEnable(bool taxBuy, bool taxSell) external onlyOwner {
      isTaxBuyEnable = taxBuy;
      isTaxSellEnable = taxSell;
    }

    function setIsExcludeFromFee(address account, bool state) external authorized {
      isExcludeFromFee[account] = state;
    }

    function setAutoSwapForWeth(bool state,uint256 amount) external onlyOwner {
      require(amount <= _totalSupply,"StepHunt: Amount Swap For Weth max total supply");
      isAutoSwapForWeth = state;
      minimumSwapForWeth = amount;
    }

    function setPercentTaxBuy(uint256 _percentTax) external onlyOwner {
      require(_percentTax <= 5000,"StepHunt: Maximum Tax is 50%");
      percentBuy = _percentTax;
    }

    function setPercentTaxSell(uint256 _percentTax) external onlyOwner {
      require(_percentTax <= 5000,"StepHunt: Maximum Tax is 50%");
      percentSell = _percentTax;
    }
    

    function _buyToken(uint256 amount, address to) internal swapping {
      IUniswapV2Router02 router = IUniswapV2Router02(routerAddress);
      address[] memory path = new address[](2);
      path[0] = wethAddress;
      path[1] = address(this);
      
      router.swapExactETHForTokensSupportingFeeOnTransferTokens{value:amount}(
        0,
        path, 
        to, 
        block.timestamp.add(300)
      );
    }

    function _swapForWeth(uint256 amount) internal swapping {
      if(amount > 0) {
        IUniswapV2Router02 router = IUniswapV2Router02(routerAddress);

        uint256 balanceETHBefore = address(this).balance;

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = wethAddress;
        
        uint256[] memory estimate = router.getAmountsOut(amount, path);

        uint256 amountForSwap = estimate[1];

        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amount,
            amountForSwap,
            path,
            address(this),
            block.timestamp
        );
    
        uint256 balanceETHAfter = address(this).balance.sub(balanceETHBefore);

        //distribute
        payable(taxReceiverAddress).transfer(balanceETHAfter);
      }
    }

    function swapForWeth(uint256 amount) external onlyOwner {
      _swapForWeth(amount);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function decimals() external view returns (uint8);

    function symbol() external view returns (string memory);

    function name() external view returns (string memory);

    function getOwner() external view returns (address);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function allowance(address _owner, address spender)
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

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

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

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import './IUniswapV2Router01.sol';

interface IUniswapV2Router02 is IUniswapV2Router01 {
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

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IWETH {
    function deposit() external payable;
    function transfer(address to, uint value) external returns (bool);
    function withdraw(uint) external;
    function balanceOf(address account) external view returns (uint256);
    function approve(address guy, uint wad) external returns (bool);
    function transferFrom(address src, address dst, uint256 wad) external returns (bool);
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.9;

interface IPinkAntiBot {
  function setTokenOwner(address owner) external;

  function onPreTransferCheck(
    address from,
    address to,
    uint256 amount
  ) external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library SafeMath {
    function tryAdd(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    function trySub(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    function tryMul(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    function tryDiv(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    function tryMod(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

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

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

abstract contract Auth {
    address internal owner;
    mapping(address => bool) internal authorizations;

    constructor(address _owner) {
        owner = _owner;
        authorizations[_owner] = true;
    }

    modifier onlyOwner() {
        require(isOwner(msg.sender), "BabyToken: !OWNER");
        _;
    }

    modifier authorized() {
        require(isAuthorized(msg.sender), "BabyToken: !AUTHORIZED");
        _;
    }

    function authorize(address adr) public onlyOwner {
        authorizations[adr] = true;
    }

    function unauthorize(address adr) public onlyOwner {
        authorizations[adr] = false;
    }

    function isOwner(address account) public view returns (bool) {
        return account == owner;
    }

    function isAuthorized(address adr) public view returns (bool) {
        return authorizations[adr];
    }

    function transferOwnership(address payable adr) public onlyOwner {
        owner = adr;
        authorizations[adr] = true;
        emit OwnershipTransferred(adr);
    }

    function _getOwner() public view returns (address) {
        return owner;
    }

    event OwnershipTransferred(address owner);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

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
        uint8 v,
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
        uint8 v,
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