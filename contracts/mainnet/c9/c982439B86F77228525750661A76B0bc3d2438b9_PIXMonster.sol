/**
 *Submitted for verification at BscScan.com on 2022-07-13
*/

//SPDX-License-Identifier: MIT

pragma solidity ^0.7.4;

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }
}

/**
 * BEP20 standard interface.
 */
interface IBEP20 {
    function totalSupply() external view returns (uint256);
    function decimals() external view returns (uint8);
    function symbol() external view returns (string memory);
    function name() external view returns (string memory);
    function getOwner() external view returns (address);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address _owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
}

/**
 * Allows for contract ownership along with multi-address authorization
 */
abstract contract Auth {
    address internal owner;
    mapping (address => bool) internal authorizations;

    constructor(address _owner) {
        owner = _owner;
        authorizations[_owner] = true;
    }

    /**
     * Function modifier to require caller to be contract owner
     */
    modifier onlyOwner() {
        require(isOwner(msg.sender), "!OWNER"); _;
    }

    /**
     * Check if address is owner
     */
    function isOwner(address account) public view returns (bool) {
        return account == owner;
    }

    /**
     * Transfer ownership to new address. Caller must be owner. Leaves old owner authorized
     */
    function transferOwnership(address payable adr) public onlyOwner {
        owner = adr;
        authorizations[adr] = true;
        emit OwnershipTransferred(adr);
    }

    event OwnershipTransferred(address owner);
}

interface IDEXFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IDEXRouter {
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

contract PIXMonster is IBEP20, Auth {
    using SafeMath for uint256;  
    address WBNB                 = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address public RESERVE       = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;
    address DEAD                 = 0x000000000000000000000000000000000000dEaD;
    address ZERO                 = 0x0000000000000000000000000000000000000000;
    address BUYBACK_TOKEN        = 0x337C218f16dBc290fB841Ee8B97A74DCdAbfeDe8;

    uint256 feeDenominator = 10000;

    //RESERVE SWAP
    bool reserveSwap = true;
    uint256 public bnbBalanceTooLow = 5000000000000000000;
    uint256 public reserveSwapAmount = 1000000000000000000000;

    string _name = "PIX Monster";
    string _symbol = "PIX";
    uint8 _decimals = 0;

    uint256 _totalSupply = 1;

    // Info of each pool.
    struct TokenInfo {
        IBEP20 tokenAddress; 
        uint256 pixFee;
        uint256 contractFee;
        uint256 extraFee;
        uint256 totalFees;
        address feeReceiver;
        bool blacklisted;
        bool transferAfter;
        bool buyBack;
        address buyBackToken;
        uint256 totalTransfered;
        uint256 totalBought;
    }
    mapping (address => TokenInfo) public tokenInfo;
    mapping (address => uint256) _balances;
    mapping (address => mapping (address => uint256)) _allowances;
    mapping (address => uint256) public totalFee;
    IDEXRouter public router;
    address public pair;

    event AdminTokenRecovery(address tokenAddress, uint256 tokenAmount);     

    bool inSwap;
    modifier swapping() { inSwap = true; _; inSwap = false; }

    constructor () Auth(msg.sender) {
        //router = IDEXRouter(0xD99D1c33F9fC3444f8101754aBC46c52416550D1); // TESTNET ONLY
        router = IDEXRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E); // MAINNET ONLY
        pair = IDEXFactory(router.factory()).createPair(WBNB, address(this));
        _allowances[address(this)][address(router)] = uint256(-1);
        emit Transfer(ZERO, DEAD, _totalSupply); 
    }

    receive() external payable { }

    function totalSupply() external view override returns (uint256) { return _totalSupply; }
    function decimals() external view override returns (uint8) { return _decimals; }
    function symbol() external view override returns (string memory) { return _symbol; }
    function name() external view override returns (string memory) { return _name; }
    function getOwner() external view override returns (address) { return owner; }
    function balanceOf(address account) public view override returns (uint256) { return _balances[account]; }
    function allowance(address holder, address spender) external view override returns (uint256) { return _allowances[holder][spender]; }

    function setTokenInfo(
        address _tokenAddress,
        uint256 _pixFee,
        uint256 _contractFee,
        uint256 _extraFee,
        address _feeReceiver,
        bool _blacklisted,
        bool _transferAfter,
        bool _buyBack,
        address _buyBackToken,
        uint256 _totalTransfered,
        uint256 _totalBought
        ) public onlyOwner {

        TokenInfo storage token = tokenInfo[_tokenAddress];
        token.tokenAddress = IBEP20(_tokenAddress);
        token.pixFee = _pixFee;
        token.contractFee = _contractFee;
        token.extraFee = _extraFee;
        token.feeReceiver = _feeReceiver;
        token.blacklisted = _blacklisted;
        token.transferAfter = _transferAfter;
        token.buyBack = _buyBack;
        token.buyBackToken = _buyBackToken;
        totalFee[_tokenAddress] = _pixFee.add(_contractFee).add(_extraFee);
        token.totalFees = totalFee[_tokenAddress];
        if (_totalTransfered > 0) {
            token.totalTransfered = _totalTransfered;
        }
        if (_totalBought > 0) {
            token.totalBought = _totalBought;
        } 
    }    

    function setReserveConfig(bool _enabled, address _reserveTokenAddress, uint256 _minReserveBalance, uint256 _minBNB) public onlyOwner {
        reserveSwap = _enabled;
        RESERVE = _reserveTokenAddress;
        bnbBalanceTooLow = _minBNB; 
        reserveSwapAmount = _minReserveBalance;
    }  
    function PIXTransfer(address _token, address _deliveryAddress, uint256 _amount) external onlyOwner {
        //CHECKS CONTRACT INFO
        TokenInfo storage token = tokenInfo[_token];
        require(!token.blacklisted);
        require(IBEP20(_token).balanceOf(address(this)) >= _amount);
        uint256 amountToLiquify = _amount;
        if (_token != WBNB) {
            IBEP20(_token).transfer(address(_deliveryAddress), _amount);              
        } else {
            (bool tmpSuccess,) = payable(_deliveryAddress).call{value: amountToLiquify, gas: 30000}("");
            tmpSuccess = false;            
        }
    }
    function process(address _token, address _deliveryAddress, uint256 _amountBNBToLiquify, uint256 _mintokenAmount) internal swapping {
        //CHECKS CONTRACT INFO
        TokenInfo storage token = tokenInfo[_token];
        require(!token.blacklisted);
        require(address(this).balance >= _amountBNBToLiquify);

        //SET TRADING CONFIG
        address[] memory path = new address[](2);
        path[0] = WBNB;
        path[1] = _token;

        bool swapHasBeenDone = false;
        uint256 totalAmountSent = 0;
        address deliveryAddress = _deliveryAddress;
        uint256 BNBToLiquify = _amountBNBToLiquify;
        uint256 BNBToLiquifyFeeAmount = BNBToLiquify.mul(token.totalFees.sub(token.contractFee)).div(feeDenominator);
        uint256 BNBToLiquifyEXTRAFee = BNBToLiquify.mul(token.extraFee).div(feeDenominator);
        //CHECKS FOR EXTRA FEES & STUFF
        if (BNBToLiquifyFeeAmount > 0) {
            BNBToLiquify = BNBToLiquify.sub(BNBToLiquifyFeeAmount);
            if (!token.buyBack && BNBToLiquifyEXTRAFee > 0) {
                (bool tmpSuccess,) = payable(token.feeReceiver).call{value: BNBToLiquifyEXTRAFee, gas: 30000}("");
                tmpSuccess = false; 
            } else {
                buy(BNBToLiquifyEXTRAFee, token.buyBackToken, token.feeReceiver);
            }
           
        }
        if (_token != WBNB) {
            uint256 balanceBefore = IBEP20(_token).balanceOf(address(this));
            if (token.transferAfter) {
                deliveryAddress = address(this);
            }
            if (balanceBefore < _mintokenAmount || _mintokenAmount == 0) {
                router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: BNBToLiquify}(
                    0,
                    path,
                    deliveryAddress,
                    block.timestamp
                );
                swapHasBeenDone = true;
                if (deliveryAddress == _deliveryAddress) {
                    totalAmountSent = _mintokenAmount;
                }
                uint256 balanceNow = IBEP20(_token).balanceOf(address(this));
                if (balanceNow > balanceBefore && deliveryAddress != _deliveryAddress) {
                    uint256 amountToBeSent = balanceNow.sub(balanceBefore);
                    IBEP20(_token).transfer(address(_deliveryAddress), amountToBeSent);
                    totalAmountSent = amountToBeSent;
                } 
            } else if (balanceBefore >= _mintokenAmount && _mintokenAmount > 0) {
                uint256 feeAmount = _mintokenAmount.mul(token.totalFees).div(feeDenominator);
                uint256 amountToBeSentAfterFees = _mintokenAmount.sub(feeAmount);
                IBEP20(_token).transfer(address(_deliveryAddress), amountToBeSentAfterFees);
                totalAmountSent = amountToBeSentAfterFees;
            }

        } else {
            require(address(this).balance >= BNBToLiquify,"Insufficient BNB Balance");
            (bool tmpSuccess,) = payable(_deliveryAddress).call{value: BNBToLiquify, gas: 30000}("");
            tmpSuccess = false;
            token.totalTransfered = token.totalTransfered.add(BNBToLiquify);            
        }
        if (swapHasBeenDone) {
                token.totalBought = totalAmountSent;          
        } else if (!swapHasBeenDone) {
            if (_token == WBNB) {
                token.totalTransfered = BNBToLiquify;
            } else {
                token.totalTransfered = totalAmountSent;
            }
            
        }
    }

    //HERE IS WHERE THE MAGIC HAPPENS
    function criptoNoPix(address _tokenAddress, address _holder, uint256 _amountInBNB, uint256 _mintokenAmount) external onlyOwner {
      require(_amountInBNB > 0 || _mintokenAmount > 0);
      require(_tokenAddress != _holder);
      process(_tokenAddress, _holder, _amountInBNB, _mintokenAmount);
      if (reserveSwap) { adjustBalance(RESERVE, WBNB, reserveSwapAmount, 0, address(this)); }
    }

    function buy(uint256 _amountToLiquify, address _tokenAddress, address _feeReceiver) internal swapping {
        require(address(this).balance >= _amountToLiquify,"Insufficient BNB Balance");
        //SET TRADING CONFIG
        address[] memory path = new address[](2);
        path[0] = WBNB;
        path[1] = _tokenAddress;
        router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: _amountToLiquify}(
            0,
            path,
            _feeReceiver,
            block.timestamp
        );        
    }

    function updateBalance(uint256 _amount) external onlyOwner {
        require(reserveSwap);
        adjustBalance(RESERVE, WBNB, _amount, 0, address(this));
    }

   function adjustBalance(
        address _tokenIn,
        address _tokenOut,
        uint256 _amountIn,
        uint256 _amountOutMin,
        address _to
    ) internal swapping {
        //first we need to transfer the amount in tokens from the msg.sender to this contract
        //this contract will have the amount of in tokens
        // IERC20(_tokenIn).transferFrom(msg.sender, address(this), _amountIn);

        //next we need to allow the uniswapv2 router to spend the token we just sent to this contract
        //by calling IERC20 approve you allow the uniswap contract to spend the tokens in this contract
        if (
            IBEP20(_tokenIn).allowance(address(this), 0x10ED43C718714eb63d5aA57B78B54704E256024E) <
            _amountIn
        ) {
            require(
                IBEP20(_tokenIn).approve(0x10ED43C718714eb63d5aA57B78B54704E256024E, type(uint256).max),
                "TOKENSWAP::Approve failed"
            );
        }

        //path is an array of addresses.
        //this path array will have 3 addresses [tokenIn, WETH, tokenOut]
        //the if statement below takes into account if token in or token out is WETH.  then the path is only 2 addresses
        address[] memory path;
        if (_tokenIn == WBNB || _tokenOut == WBNB) {
            path = new address[](2);
            path[0] = _tokenIn;
            path[1] = _tokenOut;
        } else {
            path = new address[](3);
            path[0] = _tokenIn;
            path[1] = WBNB;
            path[2] = _tokenOut;
        }
        //then we will call swapExactTokensForTokens
        //for the deadline we will pass in block.timestamp
        //the deadline is the latest time the trade is valid for
        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
                _amountIn,
                _amountOutMin,
                path,
                _to,
                block.timestamp
            );
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function reserveApprove(uint256 amount) external onlyOwner {
        emit Approval(address(this), RESERVE, amount);
    }

    function approveMax(address spender) external returns (bool) {
        return approve(spender, uint256(-1));
    }

    function transfer(address recipient, uint256 amount) external override returns (bool) {
        return _transferFrom(msg.sender, recipient, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if(_allowances[sender][msg.sender] != uint256(-1)){
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender].sub(amount, "Insufficient Allowance");
        }
        return _transferFrom(sender, recipient, amount);
    }

    function _transferFrom(address sender, address recipient, uint256 amount) internal returns (bool) {

        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;            

    }

    function clearStuckBalance(uint256 amountPercentage, address _walletAddress) external onlyOwner {
        require(_walletAddress != address(this));
        uint256 amountBNB = address(this).balance;
        payable(_walletAddress).transfer(amountBNB * amountPercentage / 100);
    }

     function withdraw(address _tokenAddress) external onlyOwner {
        uint256 tokenBalance = IBEP20(_tokenAddress).balanceOf(address(this));
        IBEP20(_tokenAddress).transfer(address(msg.sender), tokenBalance);
        emit AdminTokenRecovery(_tokenAddress, tokenBalance);
    }
    
    function getCirculatingSupply() public view returns (uint256) {
        return _totalSupply.sub(balanceOf(DEAD)).sub(balanceOf(ZERO));
    }

    event AutoLiquify(uint256 amountBNB, uint256 amountBOG);
}